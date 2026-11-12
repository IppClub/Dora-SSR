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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "updateNotificationVersion", "ignoredUpdateVersion", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "agentLLMConfigVersion", "mobileRemixLLMConfigId", "mobileLargeText", "webIDEEnabled") -- 60
config:load() -- 98
if not (config.webIDEEnabled ~= nil) then -- 100
	config.webIDEEnabled = true -- 101
end -- 100
App.webIDEEnabled = config.webIDEEnabled -- 102
if not (config.writablePath ~= nil) then -- 104
	config.writablePath = Content.appPath -- 105
end -- 104
if not (config.webIDEConnected ~= nil) then -- 107
	config.webIDEConnected = false -- 108
end -- 107
if (config.fpsLimited ~= nil) then -- 110
	App.fpsLimited = config.fpsLimited -- 111
else -- 113
	config.fpsLimited = App.fpsLimited -- 113
end -- 110
if (config.targetFPS ~= nil) then -- 115
	App.targetFPS = math.floor(config.targetFPS) -- 116
else -- 118
	config.targetFPS = App.targetFPS -- 118
end -- 115
if (config.vsync ~= nil) then -- 120
	View.vsync = config.vsync -- 121
else -- 123
	config.vsync = View.vsync -- 123
end -- 120
if (config.fixedFPS ~= nil) then -- 125
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 126
else -- 128
	config.fixedFPS = Director.scheduler.fixedFPS -- 128
end -- 125
if not (config.showPreview ~= nil) then -- 130
	config.showPreview = true -- 131
end -- 130
if not (config.mobileFeed ~= nil) then -- 133
	local _val_0 = App.platform -- 134
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 134
end -- 133
if not (config.webIDETourCompleted ~= nil) then -- 136
	config.webIDETourCompleted = false -- 137
end -- 136
local showEntry = true -- 140
isDesktop = false -- 142
if (function() -- 143
	local _val_0 = App.platform -- 143
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 143
end)() then -- 143
	isDesktop = true -- 144
	if config.fullScreen then -- 145
		App.fullScreen = true -- 146
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 147
		local size = Size(config.winWidth, config.winHeight) -- 148
		if App.winSize ~= size then -- 149
			App.winSize = size -- 150
		end -- 149
		local winX, winY -- 151
		do -- 151
			local _obj_0 = App.winPosition -- 151
			winX, winY = _obj_0.x, _obj_0.y -- 151
		end -- 151
		if (config.winX ~= nil) then -- 152
			winX = config.winX -- 153
		else -- 155
			config.winX = -1 -- 155
		end -- 152
		if (config.winY ~= nil) then -- 156
			winY = config.winY -- 157
		else -- 159
			config.winY = -1 -- 159
		end -- 156
		App.winPosition = Vec2(winX, winY) -- 160
	end -- 145
	if (config.alwaysOnTop ~= nil) then -- 161
		App.alwaysOnTop = config.alwaysOnTop -- 162
	else -- 164
		config.alwaysOnTop = false -- 164
	end -- 161
	if (config.virtualGamepadEnabled ~= nil) then -- 165
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 166
	else -- 168
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 168
	end -- 165
end -- 143
if (config.themeColor ~= nil) then -- 170
	App.themeColor = Color(config.themeColor) -- 171
else -- 173
	config.themeColor = App.themeColor:toARGB() -- 173
end -- 170
if not (config.locale ~= nil) then -- 175
	config.locale = App.locale -- 176
end -- 175
local showStats = false -- 178
if (config.showStats ~= nil) then -- 179
	showStats = config.showStats -- 180
else -- 182
	config.showStats = showStats -- 182
end -- 179
local showConsole = false -- 184
if (config.showConsole ~= nil) then -- 185
	showConsole = config.showConsole -- 186
else -- 188
	config.showConsole = showConsole -- 188
end -- 185
local showFooter = true -- 190
if (config.showFooter ~= nil) then -- 191
	showFooter = config.showFooter -- 192
else -- 194
	config.showFooter = showFooter -- 194
end -- 191
local setFooterVisible -- 196
setFooterVisible = function(visible) -- 196
	if visible == nil then -- 196
		visible = true -- 196
	end -- 196
	showFooter = visible -- 197
	config.showFooter = showFooter -- 198
end -- 196
_module_0["setFooterVisible"] = setFooterVisible -- 196
local filterBuf = Buffer(20) -- 200
if (config.filter ~= nil) then -- 201
	filterBuf.text = config.filter -- 202
else -- 204
	config.filter = "" -- 204
end -- 201
local engineDev = false -- 206
if (config.engineDev ~= nil) then -- 207
	engineDev = config.engineDev -- 208
else -- 210
	config.engineDev = engineDev -- 210
end -- 207
if (config.webProfiler ~= nil) then -- 212
	Director.profilerSending = config.webProfiler -- 213
else -- 215
	config.webProfiler = true -- 215
	Director.profilerSending = true -- 216
end -- 212
if not (config.drawerWidth ~= nil) then -- 218
	config.drawerWidth = 200 -- 219
end -- 218
_module_0.getConfig = function() -- 221
	return config -- 221
end -- 221
_module_0.getEngineDev = function() -- 222
	if not App.debugging then -- 223
		return false -- 223
	end -- 223
	return config.engineDev -- 224
end -- 222
local _anon_func_0 = function() -- 229
	local _val_0 = App.platform -- 229
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 229
end -- 229
_module_0.connectWebIDE = function(embedded) -- 226
	if embedded == nil then -- 226
		embedded = false -- 226
	end -- 226
	if not config.webIDEConnected then -- 227
		config.webIDEConnected = true -- 228
		if not embedded and _anon_func_0() then -- 229
			local ratio = App.winSize.width / App.visualSize.width -- 230
			App.winSize = Size(640 * ratio, 480 * ratio) -- 231
		end -- 229
	end -- 227
end -- 226
local updateState = nil -- 234
local checkForUpdates -- 235
do -- 235
	local updateSceneCache = moduleCache -- 236
	moduleCache = { } -- 237
	local updater = oldRequire("Tools.SelfUpdater.Service") -- 238
	moduleCache = updateSceneCache -- 239
	updateState = updater.getState() -- 241
	if config.updateNotificationVersion ~= App.version then -- 242
		config.updateNotification = false -- 243
	end -- 242
	config.updateNotificationVersion = App.version -- 244
	updateState.available = config.updateNotification == true -- 245
	local publishUpdateState -- 246
	publishUpdateState = function(state) -- 246
		updateState = state -- 247
		config.updateNotification = state.available -- 248
		config.updateNotificationVersion = App.version -- 249
		config.ignoredUpdateVersion = state.ignoredVersion -- 250
		if state.checkedAt > 0 and not state.usedCache and state.checkedAt ~= config.lastUpdateCheck then -- 251
			config.lastUpdateCheck = state.checkedAt -- 252
		end -- 251
	end -- 246
	updater.bindEntryState((function() -- 253
		return updateState -- 253
	end), publishUpdateState, config.ignoredUpdateVersion) -- 253
	checkForUpdates = function(manual, source) -- 254
		if manual == nil then -- 254
			manual = true -- 254
		end -- 254
		if source == nil then -- 254
			source = nil -- 254
		end -- 254
		if not manual then -- 255
			if App.platform == "Emscripten" then -- 256
				return false -- 256
			end -- 256
			if (config.lastUpdateCheck ~= nil) and os.difftime(os.time(), config.lastUpdateCheck) < 7 * 24 * 60 * 60 then -- 257
				return false -- 258
			end -- 257
		end -- 255
		return updater.checkForUpdates(source) -- 259
	end -- 254
end -- 235
_module_0.getUpdateState = function() -- 260
	return updateState -- 260
end -- 260
_module_0.checkForUpdates = checkForUpdates -- 261
thread(function() -- 262
	sleep(2) -- 263
	return checkForUpdates(false) -- 264
end) -- 262
local Set, Struct, LintYueGlobals -- 266
do -- 266
	local _obj_0 = require("Utils") -- 266
	Set, Struct, LintYueGlobals = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals -- 266
end -- 266
local yueext = yue.options.extension -- 267
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 269
local building = false -- 271
local getAllFiles -- 273
getAllFiles = function(path, exts, recursive) -- 273
	if recursive == nil then -- 273
		recursive = true -- 273
	end -- 273
	local filters = Set(exts) -- 274
	local files -- 275
	if recursive then -- 275
		files = Content:getAllFiles(path) -- 276
	else -- 278
		files = Content:getFiles(path) -- 278
	end -- 275
	local _accum_0 = { } -- 279
	local _len_0 = 1 -- 279
	for _index_0 = 1, #files do -- 279
		local file = files[_index_0] -- 279
		if not filters[Path:getExt(file)] then -- 280
			goto _continue_0 -- 280
		end -- 280
		_accum_0[_len_0] = file -- 281
		_len_0 = _len_0 + 1 -- 280
		::_continue_0:: -- 280
	end -- 279
	return _accum_0 -- 279
end -- 273
_module_0["getAllFiles"] = getAllFiles -- 273
local getFileEntries -- 283
getFileEntries = function(path, recursive, excludeFiles) -- 283
	if recursive == nil then -- 283
		recursive = true -- 283
	end -- 283
	if excludeFiles == nil then -- 283
		excludeFiles = nil -- 283
	end -- 283
	local entries = { } -- 284
	local excludes -- 285
	if excludeFiles then -- 285
		excludes = Set(excludeFiles) -- 286
	end -- 285
	local _list_0 = getAllFiles(path, { -- 287
		"lua", -- 287
		"xml", -- 287
		yueext, -- 287
		"tl" -- 287
	}, recursive) -- 287
	for _index_0 = 1, #_list_0 do -- 287
		local file = _list_0[_index_0] -- 287
		local entryName = Path:getName(file) -- 288
		if excludes and excludes[entryName] then -- 289
			goto _continue_0 -- 290
		end -- 289
		local fileName = Path:replaceExt(file, "") -- 291
		fileName = Path(path, fileName) -- 292
		local entryAdded -- 293
		for _index_1 = 1, #entries do -- 293
			local _des_0 = entries[_index_1] -- 293
			local ename, efile = _des_0.entryName, _des_0.fileName -- 293
			if entryName == ename and efile == fileName then -- 294
				entryAdded = true -- 294
				break -- 294
			end -- 294
		end -- 293
		if entryAdded then -- 295
			goto _continue_0 -- 295
		end -- 295
		local entry = { -- 296
			entryName = entryName, -- 296
			fileName = fileName -- 296
		} -- 296
		entries[#entries + 1] = entry -- 297
		::_continue_0:: -- 288
	end -- 287
	table.sort(entries, function(a, b) -- 298
		return a.entryName < b.entryName -- 298
	end) -- 298
	return entries -- 299
end -- 283
local allEntries = { -- 301
	dirty = { }, -- 301
	hasDirty = false, -- 301
	runId = 0 -- 301
} -- 301
allEntries.scanDir = function(path, dir, noPreview) -- 303
	if noPreview == nil then -- 303
		noPreview = false -- 303
	end -- 303
	local entries = { } -- 304
	if not dir:match("^%.") then -- 305
		local _list_0 = getAllFiles(Path(path, dir), { -- 306
			"lua", -- 306
			"xml", -- 306
			yueext, -- 306
			"tl", -- 306
			"wasm" -- 306
		}) -- 306
		for _index_0 = 1, #_list_0 do -- 306
			local file = _list_0[_index_0] -- 306
			if "init" == Path:getName(file):lower() then -- 307
				local fileName = Path:replaceExt(file, "") -- 308
				fileName = Path(path, dir, fileName) -- 309
				local projectPath = Path:getPath(fileName) -- 310
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 311
				local repo = nil -- 312
				if Content:exist(repoFile) then -- 313
					local str = Content:load(repoFile) -- 314
					if str then -- 314
						repo = json.decode(str) -- 315
					end -- 314
				end -- 313
				local entryName = Path:getName(projectPath) -- 316
				local entryAdded -- 317
				for _index_1 = 1, #entries do -- 317
					local _des_0 = entries[_index_1] -- 317
					local ename, efile = _des_0.entryName, _des_0.fileName -- 317
					if entryName == ename and efile == fileName then -- 318
						entryAdded = true -- 318
						break -- 318
					end -- 318
				end -- 317
				if entryAdded then -- 319
					goto _continue_0 -- 319
				end -- 319
				local examples = { } -- 320
				local tests = { } -- 321
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 322
				if Content:exist(examplePath) then -- 323
					local _list_1 = getFileEntries(examplePath) -- 324
					for _index_1 = 1, #_list_1 do -- 324
						local _des_0 = _list_1[_index_1] -- 324
						local name, ePath = _des_0.entryName, _des_0.fileName -- 324
						local entry = { -- 326
							entryName = name, -- 326
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 327
							workDir = projectPath -- 328
						} -- 325
						examples[#examples + 1] = entry -- 330
					end -- 324
				end -- 323
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 331
				if Content:exist(testPath) then -- 332
					local _list_1 = getFileEntries(testPath) -- 333
					for _index_1 = 1, #_list_1 do -- 333
						local _des_0 = _list_1[_index_1] -- 333
						local name, tPath = _des_0.entryName, _des_0.fileName -- 333
						local entry = { -- 335
							entryName = name, -- 335
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 336
							workDir = projectPath -- 337
						} -- 334
						tests[#tests + 1] = entry -- 339
					end -- 333
				end -- 332
				local entry = { -- 340
					entryName = entryName, -- 340
					fileName = fileName, -- 340
					projectPath = projectPath, -- 340
					examples = examples, -- 340
					tests = tests, -- 340
					repo = repo -- 340
				} -- 340
				local bannerFile -- 341
				do -- 341
					local _val_0 -- 341
					repeat -- 341
						if noPreview then -- 342
							_val_0 = nil -- 342
							break -- 342
						end -- 342
						if not config.showPreview then -- 343
							_val_0 = nil -- 343
							break -- 343
						end -- 343
						local f = Path(projectPath, ".dora", "banner.jpg") -- 344
						if Content:exist(f) then -- 345
							_val_0 = f -- 345
							break -- 345
						end -- 345
						f = Path(projectPath, ".dora", "banner.png") -- 346
						if Content:exist(f) then -- 347
							_val_0 = f -- 347
							break -- 347
						end -- 347
						f = Path(projectPath, "Image", "banner.jpg") -- 348
						if Content:exist(f) then -- 349
							_val_0 = f -- 349
							break -- 349
						end -- 349
						f = Path(projectPath, "Image", "banner.png") -- 350
						if Content:exist(f) then -- 351
							_val_0 = f -- 351
							break -- 351
						end -- 351
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 352
						if Content:exist(f) then -- 353
							_val_0 = f -- 353
							break -- 353
						end -- 353
					until true -- 341
					bannerFile = _val_0 -- 341
				end -- 341
				if bannerFile then -- 355
					entry.bannerFile = bannerFile -- 358
					thread(function() -- 359
						if Cache:loadAsync(bannerFile) then -- 360
							local bannerTex = Texture2D(bannerFile) -- 361
							if bannerTex then -- 361
								entry.bannerTex = bannerTex -- 362
							end -- 361
						end -- 360
					end) -- 359
				end -- 355
				entries[#entries + 1] = entry -- 363
			end -- 307
			::_continue_0:: -- 307
		end -- 306
	end -- 305
	return entries -- 364
end -- 303
local getProjectEntries -- 366
getProjectEntries = function(path, noPreview) -- 366
	if noPreview == nil then -- 366
		noPreview = false -- 366
	end -- 366
	local entries = { } -- 367
	local _list_0 = Content:getDirs(path) -- 368
	for _index_0 = 1, #_list_0 do -- 368
		local dir = _list_0[_index_0] -- 368
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 369
		for _index_1 = 1, #_list_1 do -- 369
			local entry = _list_1[_index_1] -- 369
			entries[#entries + 1] = entry -- 370
		end -- 369
	end -- 368
	table.sort(entries, function(a, b) -- 371
		return a.entryName < b.entryName -- 371
	end) -- 371
	return entries -- 372
end -- 366
_module_0["getProjectEntries"] = getProjectEntries -- 366
local gamesInDev -- 374
local doraTools -- 375
local isToolEntry -- 377
isToolEntry = function(entry) -- 377
	do -- 378
		local _type_0 = type(entry) -- 378
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 378
		if _tab_0 then -- 378
			local categories -- 378
			do -- 378
				local _obj_0 = entry.repo -- 378
				local _type_1 = type(_obj_0) -- 378
				if "table" == _type_1 or "userdata" == _type_1 then -- 378
					categories = _obj_0.categories -- 378
				end -- 378
			end -- 378
			if categories ~= nil then -- 378
				for _index_0 = 1, #categories do -- 379
					local category = categories[_index_0] -- 379
					if "string" == type(category) and category:lower() == "tool" then -- 380
						return true -- 381
					end -- 380
				end -- 379
			end -- 378
		end -- 378
	end -- 378
	return false -- 377
end -- 377
local getEntryTitle -- 383
getEntryTitle = function(entry) -- 383
	local title -- 384
	do -- 384
		local repo = entry.repo -- 384
		if repo then -- 384
			if repo.title and "table" == type(repo.title) then -- 385
				if useChinese then -- 386
					title = repo.title.zh -- 386
				else -- 386
					title = repo.title.en -- 386
				end -- 386
			end -- 385
		end -- 384
	end -- 384
	if title ~= nil then -- 387
		return title -- 387
	else -- 387
		return entry.entryName -- 387
	end -- 387
end -- 383
allEntries.rebuildEntries = function() -- 389
	gamesInDev = { } -- 390
	do -- 391
		local _accum_0 = { } -- 391
		local _len_0 = 1 -- 391
		local _list_0 = allEntries.builtinTools -- 391
		for _index_0 = 1, #_list_0 do -- 391
			local tool = _list_0[_index_0] -- 391
			_accum_0[_len_0] = tool -- 391
			_len_0 = _len_0 + 1 -- 391
		end -- 391
		doraTools = _accum_0 -- 391
	end -- 391
	local _list_0 = allEntries.projectEntries -- 392
	for _index_0 = 1, #_list_0 do -- 392
		local entry = _list_0[_index_0] -- 392
		if isToolEntry(entry) then -- 393
			entry.kind = "tool" -- 394
			doraTools[#doraTools + 1] = entry -- 395
		else -- 397
			entry.kind = "game" -- 397
			gamesInDev[#gamesInDev + 1] = entry -- 398
		end -- 393
	end -- 392
	for i = #allEntries, 1, -1 do -- 399
		allEntries[i] = nil -- 400
	end -- 399
	for _index_0 = 1, #gamesInDev do -- 401
		local game = gamesInDev[_index_0] -- 401
		allEntries[#allEntries + 1] = game -- 402
		local examples, tests = game.examples, game.tests -- 403
		for _index_1 = 1, #examples do -- 404
			local example = examples[_index_1] -- 404
			allEntries[#allEntries + 1] = example -- 405
		end -- 404
		for _index_1 = 1, #tests do -- 406
			local test = tests[_index_1] -- 406
			allEntries[#allEntries + 1] = test -- 407
		end -- 406
	end -- 401
end -- 389
local updateEntries -- 409
updateEntries = function() -- 409
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 410
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 411
	local _list_0 = allEntries.builtinTools -- 412
	for _index_0 = 1, #_list_0 do -- 412
		local tool = _list_0[_index_0] -- 412
		tool.kind = "tool" -- 413
		tool.builtin = true -- 414
	end -- 412
	return allEntries.rebuildEntries() -- 415
end -- 409
allEntries.refreshDirtyProjects = function() -- 417
	if not allEntries.hasDirty then -- 418
		return -- 418
	end -- 418
	local dirty = allEntries.dirty -- 419
	allEntries.dirty = { } -- 420
	allEntries.hasDirty = false -- 421
	for projectPath in pairs(dirty) do -- 422
		do -- 423
			local _accum_0 = { } -- 423
			local _len_0 = 1 -- 423
			local _list_0 = allEntries.projectEntries -- 423
			for _index_0 = 1, #_list_0 do -- 423
				local entry = _list_0[_index_0] -- 423
				if entry.projectPath ~= projectPath then -- 423
					_accum_0[_len_0] = entry -- 423
					_len_0 = _len_0 + 1 -- 423
				end -- 423
			end -- 423
			allEntries.projectEntries = _accum_0 -- 423
		end -- 423
		local parentPath = Path:getPath(projectPath) -- 424
		local dir = Path:getFilename(projectPath) -- 425
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 426
		for _index_0 = 1, #_list_0 do -- 426
			local entry = _list_0[_index_0] -- 426
			if entry.projectPath == projectPath then -- 427
				do -- 428
					local _obj_0 = allEntries.projectEntries -- 428
					_obj_0[#_obj_0 + 1] = entry -- 428
				end -- 428
				break -- 429
			end -- 427
		end -- 426
	end -- 422
	table.sort(allEntries.projectEntries, function(a, b) -- 430
		return a.entryName < b.entryName -- 430
	end) -- 430
	return allEntries.rebuildEntries() -- 431
end -- 417
updateEntries() -- 433
local getLaunchEntries -- 435
getLaunchEntries = function(refresh) -- 435
	if refresh == nil then -- 435
		refresh = false -- 435
	end -- 435
	if refresh then -- 436
		updateEntries() -- 436
	end -- 436
	local toInfo -- 437
	toInfo = function(entry, kind) -- 437
		local file = entry.fileName -- 438
		local asProj = not entry.builtin -- 439
		return { -- 441
			name = getEntryTitle(entry), -- 441
			file = file, -- 442
			kind = kind, -- 443
			asProj = asProj -- 444
		} -- 440
	end -- 437
	local games -- 446
	do -- 446
		local _accum_0 = { } -- 446
		local _len_0 = 1 -- 446
		for _index_0 = 1, #gamesInDev do -- 446
			local game = gamesInDev[_index_0] -- 446
			_accum_0[_len_0] = toInfo(game, "game") -- 446
			_len_0 = _len_0 + 1 -- 446
		end -- 446
		games = _accum_0 -- 446
	end -- 446
	local tools -- 447
	do -- 447
		local _accum_0 = { } -- 447
		local _len_0 = 1 -- 447
		for _index_0 = 1, #doraTools do -- 447
			local tool = doraTools[_index_0] -- 447
			_accum_0[_len_0] = toInfo(tool, "tool") -- 447
			_len_0 = _len_0 + 1 -- 447
		end -- 447
		tools = _accum_0 -- 447
	end -- 447
	return { -- 448
		games = games, -- 448
		tools = tools -- 448
	} -- 448
end -- 435
_module_0["getLaunchEntries"] = getLaunchEntries -- 435
local _anon_func_1 = function(entry, useChinese) -- 465
	local _obj_0 = entry.repo -- 465
	if _obj_0 ~= nil then -- 465
		local _obj_1 = _obj_0.description -- 465
		if _obj_1 ~= nil then -- 465
			return _obj_1[useChinese and "zh" or "en"] -- 465
		end -- 465
		return nil -- 465
	end -- 465
	return nil -- 465
end -- 465
local getMobileFeedEntries -- 450
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 450
	if refresh == nil then -- 450
		refresh = false -- 450
	end -- 450
	if dirtyProjectPath == nil then -- 450
		dirtyProjectPath = nil -- 450
	end -- 450
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 451
		allEntries.dirty[dirtyProjectPath] = true -- 452
		allEntries.hasDirty = true -- 453
	end -- 451
	if refresh then -- 454
		allEntries.dirty = { } -- 455
		allEntries.hasDirty = false -- 456
		updateEntries() -- 457
	else -- 459
		allEntries.refreshDirtyProjects() -- 459
	end -- 454
	local items = { } -- 460
	for _index_0 = 1, #gamesInDev do -- 461
		local entry = gamesInDev[_index_0] -- 461
		items[#items + 1] = { -- 463
			id = entry.entryName, -- 463
			title = getEntryTitle(entry), -- 464
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 465
			fileName = entry.fileName, -- 466
			workDir = Path:getPath(entry.fileName), -- 467
			bannerFile = entry.bannerFile, -- 468
			kind = "local" -- 469
		} -- 462
	end -- 461
	return items -- 471
end -- 450
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 450
local doCompile -- 473
doCompile = function(minify) -- 473
	if building then -- 474
		return -- 474
	end -- 474
	building = true -- 475
	local startTime = App.runningTime -- 476
	local luaFiles = { } -- 477
	local yueFiles = { } -- 478
	local xmlFiles = { } -- 479
	local tlFiles = { } -- 480
	local writablePath = Content.writablePath -- 481
	local buildPaths = { -- 483
		{ -- 484
			Content.assetPath, -- 484
			Path(writablePath, ".build"), -- 485
			"" -- 486
		} -- 483
	} -- 482
	for _index_0 = 1, #gamesInDev do -- 489
		local _des_0 = gamesInDev[_index_0] -- 489
		local fileName = _des_0.fileName -- 489
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 490
		buildPaths[#buildPaths + 1] = { -- 492
			Path(writablePath, gamePath), -- 492
			Path(writablePath, ".build", gamePath), -- 493
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 494
			gamePath -- 495
		} -- 491
	end -- 489
	for _index_0 = 1, #buildPaths do -- 496
		local _des_0 = buildPaths[_index_0] -- 496
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 496
		if not Content:exist(inputPath) then -- 497
			goto _continue_0 -- 497
		end -- 497
		local _list_0 = getAllFiles(inputPath, { -- 499
			"lua" -- 499
		}) -- 499
		for _index_1 = 1, #_list_0 do -- 499
			local file = _list_0[_index_1] -- 499
			luaFiles[#luaFiles + 1] = { -- 501
				file, -- 501
				Path(inputPath, file), -- 502
				Path(outputPath, file), -- 503
				gamePath -- 504
			} -- 500
		end -- 499
		local _list_1 = getAllFiles(inputPath, { -- 506
			yueext -- 506
		}) -- 506
		for _index_1 = 1, #_list_1 do -- 506
			local file = _list_1[_index_1] -- 506
			yueFiles[#yueFiles + 1] = { -- 508
				file, -- 508
				Path(inputPath, file), -- 509
				Path(outputPath, Path:replaceExt(file, "lua")), -- 510
				searchPath, -- 511
				gamePath -- 512
			} -- 507
		end -- 506
		local _list_2 = getAllFiles(inputPath, { -- 514
			"xml" -- 514
		}) -- 514
		for _index_1 = 1, #_list_2 do -- 514
			local file = _list_2[_index_1] -- 514
			xmlFiles[#xmlFiles + 1] = { -- 516
				file, -- 516
				Path(inputPath, file), -- 517
				Path(outputPath, Path:replaceExt(file, "lua")), -- 518
				gamePath -- 519
			} -- 515
		end -- 514
		local _list_3 = getAllFiles(inputPath, { -- 521
			"tl" -- 521
		}) -- 521
		for _index_1 = 1, #_list_3 do -- 521
			local file = _list_3[_index_1] -- 521
			if not file:match(".*%.d%.tl$") then -- 522
				tlFiles[#tlFiles + 1] = { -- 524
					file, -- 524
					Path(inputPath, file), -- 525
					Path(outputPath, Path:replaceExt(file, "lua")), -- 526
					searchPath, -- 527
					gamePath -- 528
				} -- 523
			end -- 522
		end -- 521
		::_continue_0:: -- 497
	end -- 496
	local paths -- 530
	do -- 530
		local _tbl_0 = { } -- 530
		local _list_0 = { -- 531
			luaFiles, -- 531
			yueFiles, -- 531
			xmlFiles, -- 531
			tlFiles -- 531
		} -- 531
		for _index_0 = 1, #_list_0 do -- 531
			local files = _list_0[_index_0] -- 531
			for _index_1 = 1, #files do -- 532
				local file = files[_index_1] -- 532
				_tbl_0[Path:getPath(file[3])] = true -- 530
			end -- 530
		end -- 530
		paths = _tbl_0 -- 530
	end -- 530
	for path in pairs(paths) do -- 534
		Content:mkdir(path) -- 534
	end -- 534
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 536
	local fileCount = 0 -- 537
	local errors = { } -- 538
	for _index_0 = 1, #yueFiles do -- 539
		local _des_0 = yueFiles[_index_0] -- 539
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 539
		local filename -- 540
		if gamePath then -- 540
			filename = Path(gamePath, file) -- 540
		else -- 540
			filename = file -- 540
		end -- 540
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 541
			if not codes then -- 542
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 543
				return -- 544
			end -- 542
			local success, result = LintYueGlobals(codes, globals) -- 545
			local yueCodes -- 546
			if not success then -- 547
				yueCodes = Content:load(input) -- 548
				if yueCodes then -- 548
					local CheckTIC80Code -- 549
					do -- 549
						local _obj_0 = require("Utils") -- 549
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 549
					end -- 549
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 550
					if isTIC80 then -- 551
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 552
					end -- 551
				end -- 548
			end -- 547
			if success then -- 553
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 554
			else -- 556
				if yueCodes then -- 556
					local globalErrors = { } -- 557
					for _index_1 = 1, #result do -- 558
						local _des_1 = result[_index_1] -- 558
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 558
						local countLine = 1 -- 559
						local code = "" -- 560
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 561
							if countLine == line then -- 562
								code = lineCode -- 563
								break -- 564
							end -- 562
							countLine = countLine + 1 -- 565
						end -- 561
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 566
					end -- 558
					if #globalErrors > 0 then -- 567
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 567
					end -- 567
				else -- 569
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 569
				end -- 556
				if #errors == 0 then -- 570
					return codes -- 570
				end -- 570
			end -- 553
		end, function(success) -- 541
			if success then -- 571
				print("Yue compiled: " .. tostring(filename)) -- 571
			end -- 571
			fileCount = fileCount + 1 -- 572
		end) -- 541
	end -- 539
	thread(function() -- 574
		for _index_0 = 1, #xmlFiles do -- 575
			local _des_0 = xmlFiles[_index_0] -- 575
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 575
			local filename -- 576
			if gamePath then -- 576
				filename = Path(gamePath, file) -- 576
			else -- 576
				filename = file -- 576
			end -- 576
			local sourceCodes = Content:loadAsync(input) -- 577
			local codes, err = xml.tolua(sourceCodes) -- 578
			if not codes then -- 579
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 580
			else -- 582
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 582
				print("Xml compiled: " .. tostring(filename)) -- 583
			end -- 579
			fileCount = fileCount + 1 -- 584
		end -- 575
	end) -- 574
	thread(function() -- 586
		for _index_0 = 1, #tlFiles do -- 587
			local _des_0 = tlFiles[_index_0] -- 587
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 587
			local filename -- 588
			if gamePath then -- 588
				filename = Path(gamePath, file) -- 588
			else -- 588
				filename = file -- 588
			end -- 588
			local sourceCodes = Content:loadAsync(input) -- 589
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 590
			if not codes then -- 591
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 592
			else -- 594
				Content:saveAsync(output, codes) -- 594
				print("Teal compiled: " .. tostring(filename)) -- 595
			end -- 591
			fileCount = fileCount + 1 -- 596
		end -- 587
	end) -- 586
	return thread(function() -- 598
		wait(function() -- 599
			return fileCount == totalFiles -- 599
		end) -- 599
		if minify then -- 600
			local _list_0 = { -- 601
				yueFiles, -- 601
				xmlFiles, -- 601
				tlFiles -- 601
			} -- 601
			for _index_0 = 1, #_list_0 do -- 601
				local files = _list_0[_index_0] -- 601
				for _index_1 = 1, #files do -- 601
					local file = files[_index_1] -- 601
					local output = Path:replaceExt(file[3], "lua") -- 602
					luaFiles[#luaFiles + 1] = { -- 604
						Path:replaceExt(file[1], "lua"), -- 604
						output, -- 605
						output -- 606
					} -- 603
				end -- 601
			end -- 601
			local FormatMini -- 608
			do -- 608
				local _obj_0 = require("luaminify") -- 608
				FormatMini = _obj_0.FormatMini -- 608
			end -- 608
			for _index_0 = 1, #luaFiles do -- 609
				local _des_0 = luaFiles[_index_0] -- 609
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 609
				if Content:exist(input) then -- 610
					local sourceCodes = Content:loadAsync(input) -- 611
					local res, err = FormatMini(sourceCodes) -- 612
					if res then -- 613
						Content:saveAsync(output, res) -- 614
						print("Minify: " .. tostring(file)) -- 615
					else -- 617
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 617
					end -- 613
				else -- 619
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 619
				end -- 610
			end -- 609
			package.loaded["luaminify.FormatMini"] = nil -- 620
			package.loaded["luaminify.ParseLua"] = nil -- 621
			package.loaded["luaminify.Scope"] = nil -- 622
			package.loaded["luaminify.Util"] = nil -- 623
		end -- 600
		local errorMessage = table.concat(errors, "\n") -- 624
		if errorMessage ~= "" then -- 625
			print(errorMessage) -- 625
		end -- 625
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 626
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 627
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 628
		Content:clearPathCache() -- 629
		teal.clear() -- 630
		yue.clear() -- 631
		building = false -- 632
	end) -- 598
end -- 473
local doClean -- 634
doClean = function() -- 634
	if building then -- 635
		return -- 635
	end -- 635
	local writablePath = Content.writablePath -- 636
	local targetDir = Path(writablePath, ".build") -- 637
	Content:clearPathCache() -- 638
	if Content:remove(targetDir) then -- 639
		return print("Cleaned: " .. tostring(targetDir)) -- 640
	end -- 639
end -- 634
local screenScale = 2.0 -- 642
local scaleContent = false -- 643
local isInEntry = true -- 644
local currentEntry = nil -- 645
local footerWindow = nil -- 647
local entryWindow = nil -- 648
local testingThread = nil -- 649
local mobileMode = config.mobileFeed -- 650
local pendingUIMode = nil -- 651
local feedHost = nil -- 652
local remixHost = nil -- 653
local startMobileUI = nil -- 654
local webControlled = false -- 655
local mobileHosts = { } -- 656
local suspendedMobileHosts = { } -- 657
local trackMobileHost -- 659
trackMobileHost = function(host) -- 659
	do -- 660
		local _accum_0 = { } -- 660
		local _len_0 = 1 -- 660
		for _index_0 = 1, #mobileHosts do -- 660
			local item = mobileHosts[_index_0] -- 660
			if item.parent then -- 660
				_accum_0[_len_0] = item -- 660
				_len_0 = _len_0 + 1 -- 660
			end -- 660
		end -- 660
		mobileHosts = _accum_0 -- 660
	end -- 660
	mobileHosts[#mobileHosts + 1] = host -- 661
	return host -- 662
end -- 659
local clearMobileUI -- 664
clearMobileUI = function() -- 664
	for _index_0 = 1, #mobileHosts do -- 665
		local host = mobileHosts[_index_0] -- 665
		if host.parent then -- 666
			host:removeFromParent(true) -- 666
		end -- 666
	end -- 665
	mobileHosts = { } -- 667
	suspendedMobileHosts = { } -- 668
	feedHost = nil -- 669
	remixHost = nil -- 670
end -- 664
local syncWebIDEControl -- 672
syncWebIDEControl = function() -- 672
	local connected = HttpServer.wsConnectionCount > 0 -- 673
	if connected then -- 674
		pendingUIMode = nil -- 675
		for _index_0 = 1, #mobileHosts do -- 676
			local host = mobileHosts[_index_0] -- 676
			if not host.parent then -- 677
				goto _continue_0 -- 677
			end -- 677
			if not (suspendedMobileHosts[host] ~= nil) then -- 678
				suspendedMobileHosts[host] = host.visible -- 679
				host:emit("SuspendLocalUI") -- 680
			end -- 678
			host.visible = false -- 681
			::_continue_0:: -- 677
		end -- 676
	elseif webControlled then -- 682
		for host, visible in pairs(suspendedMobileHosts) do -- 683
			if host.parent then -- 684
				host.visible = visible -- 685
				host:emit("ResumeLocalUI") -- 686
			end -- 684
		end -- 683
		suspendedMobileHosts = { } -- 687
	end -- 674
	webControlled = connected -- 688
	return connected -- 689
end -- 672
local getUIMode -- 691
getUIMode = function() -- 691
	return mobileMode and "mobile" or "traditional" -- 691
end -- 691
_module_0["getUIMode"] = getUIMode -- 691
local setUIMode -- 692
setUIMode = function(mode) -- 692
	if not (("mobile" == mode or "traditional" == mode)) then -- 693
		return false -- 693
	end -- 693
	if HttpServer.wsConnectionCount > 0 then -- 694
		return false -- 694
	end -- 694
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 695
		return false -- 695
	end -- 695
	local wantsMobile = mode == "mobile" -- 696
	if wantsMobile == mobileMode then -- 697
		return true -- 697
	end -- 697
	if mobileMode then -- 698
		if not (feedHost and feedHost.visible) then -- 699
			return false -- 699
		end -- 699
		feedHost:emit("SwitchUIMode") -- 701
		return pendingUIMode == false -- 702
	end -- 698
	pendingUIMode = true -- 703
	return true -- 704
end -- 692
_module_0["setUIMode"] = setUIMode -- 692
local applyUIMode -- 706
applyUIMode = function(enabled) -- 706
	if HttpServer.wsConnectionCount > 0 then -- 708
		return false -- 708
	end -- 708
	if enabled then -- 709
		local ok, err = pcall(startMobileUI) -- 710
		if not ok then -- 711
			if feedHost then -- 712
				feedHost:removeFromParent(true) -- 712
			end -- 712
			feedHost = nil -- 713
			mobileMode = false -- 714
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 715
			return false -- 716
		end -- 711
	else -- 718
		clearMobileUI() -- 718
		updateEntries() -- 719
	end -- 709
	mobileMode = enabled -- 720
	config.mobileFeed = enabled -- 721
	return true -- 722
end -- 706
local setupEventHandlers = nil -- 724
local allClear -- 726
allClear = function() -- 726
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 728
		clearMobileUI() -- 728
	end -- 728
	local systemNodes = { } -- 731
	local preserveSystemNode -- 732
	preserveSystemNode = function(node) -- 732
		if systemNodes[node] then -- 733
			return -- 733
		end -- 733
		systemNodes[node] = true -- 734
		do -- 735
			local clip = tolua.cast(node, "ClipNode") -- 735
			if clip then -- 735
				if clip.stencil then -- 736
					preserveSystemNode(clip.stencil) -- 736
				end -- 736
			end -- 735
		end -- 735
		return node:eachChild(function(child) -- 737
			preserveSystemNode(child) -- 738
			return false -- 739
		end) -- 737
	end -- 732
	for _index_0 = 1, #Routine do -- 740
		local routine = Routine[_index_0] -- 740
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 742
			goto _continue_0 -- 743
		else -- 745
			Routine:remove(routine) -- 745
		end -- 741
		::_continue_0:: -- 741
	end -- 740
	for _index_0 = 1, #moduleCache do -- 746
		local module = moduleCache[_index_0] -- 746
		package.loaded[module] = nil -- 747
	end -- 746
	moduleCache = { } -- 748
	Director:cleanup() -- 749
	Entity:clear() -- 750
	Platformer.Data:clear() -- 751
	Platformer.UnitAction:clear() -- 752
	Audio:stopAll(0.2) -- 753
	Struct:clear() -- 754
	View.nearPlaneDistance = 0.1 -- 757
	View.farPlaneDistance = 10000 -- 758
	View.fieldOfView = 45 -- 759
	View.postEffect = nil -- 760
	View.scale = scaleContent and screenScale or 1 -- 761
	Director.clearColor = Color(0xff1a1a1a) -- 762
	teal.clear() -- 763
	yue.clear() -- 764
	preserveSystemNode(Director.systemUI) -- 767
	for _, item in pairs(ubox()) do -- 768
		local node = tolua.cast(item, "Node") -- 769
		if node then -- 769
			if not systemNodes[node] then -- 770
				node:cleanup() -- 770
			end -- 770
		end -- 769
	end -- 768
	collectgarbage() -- 771
	collectgarbage() -- 772
	Wasm:clear() -- 773
	thread(function() -- 774
		sleep() -- 775
		return Cache:removeUnused() -- 776
	end) -- 774
	setupEventHandlers() -- 777
	Content.searchPaths = searchPaths -- 778
	App.idled = true -- 779
end -- 726
_module_0["allClear"] = allClear -- 726
local clearTempFiles -- 781
clearTempFiles = function() -- 781
	local writablePath = Content.writablePath -- 782
	local uploadPath = Path(writablePath, ".upload") -- 783
	if Content:exist(uploadPath) then -- 784
		local _list_0 = Content:getDirs(uploadPath) -- 786
		for _index_0 = 1, #_list_0 do -- 786
			local dir = _list_0[_index_0] -- 786
			if dir ~= "resume" then -- 787
				Content:remove(Path(uploadPath, dir)) -- 787
			end -- 787
		end -- 786
		local _list_1 = Content:getFiles(uploadPath) -- 788
		for _index_0 = 1, #_list_1 do -- 788
			local file = _list_1[_index_0] -- 788
			Content:remove(Path(uploadPath, file)) -- 789
		end -- 788
	end -- 784
	if Content:exist(Path(writablePath, ".download")) then -- 790
		return Content:remove(Path(writablePath, ".download")) -- 790
	end -- 790
end -- 781
local waitForWebStart = true -- 792
thread(function() -- 793
	sleep(2) -- 794
	waitForWebStart = false -- 795
end) -- 793
local reloadDevEntry -- 797
reloadDevEntry = function() -- 797
	return thread(function() -- 797
		waitForWebStart = true -- 798
		doClean() -- 799
		allClear() -- 800
		_G.require = oldRequire -- 801
		Dora.require = oldRequire -- 802
		package.loaded["Script.Dev.Entry"] = nil -- 803
		package.loaded["Script.Dev.WebServer"] = nil -- 804
		return Director.systemScheduler:schedule(function() -- 805
			Routine:clear() -- 806
			oldRequire("Script.Dev.Entry") -- 807
			return true -- 808
		end) -- 805
	end) -- 797
end -- 797
local setWorkspace -- 810
setWorkspace = function(path) -- 810
	clearTempFiles() -- 811
	Content.writablePath = path -- 812
	config.writablePath = Content.writablePath -- 813
	return thread(function() -- 814
		sleep() -- 815
		return reloadDevEntry() -- 816
	end) -- 814
end -- 810
_module_0["setWorkspace"] = setWorkspace -- 810
local quit = false -- 818
local activeSearchId = 0 -- 820
local handleSearchFiles -- 822
handleSearchFiles = function(payload) -- 822
	if not payload then -- 823
		return -- 823
	end -- 823
	local id = payload.id -- 824
	if id == nil then -- 825
		return -- 825
	end -- 825
	activeSearchId = id -- 826
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 827
	if path == nil then -- 828
		path = "" -- 828
	end -- 828
	if exts == nil then -- 829
		exts = { } -- 829
	end -- 829
	if globs == nil then -- 830
		globs = { } -- 830
	end -- 830
	if extensionLevels == nil then -- 831
		extensionLevels = { } -- 831
	end -- 831
	if pattern == nil then -- 832
		pattern = "" -- 832
	end -- 832
	if pattern == "" then -- 834
		return -- 834
	end -- 834
	local useRegex = payload.useRegex == true -- 835
	local caseSensitive = payload.caseSensitive == true -- 836
	local includeContent = payload.includeContent ~= false -- 837
	local contentWindow = payload.contentWindow or 0 -- 838
	return Director.systemScheduler:schedule(once(function() -- 839
		local stopped = false -- 840
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 841
			if activeSearchId ~= id then -- 842
				stopped = true -- 843
				return true -- 844
			end -- 842
			emit("AppWS", "Send", json.encode({ -- 846
				name = "SearchFilesResult", -- 846
				id = id, -- 846
				result = result -- 846
			})) -- 845
			return false -- 848
		end) -- 841
		return emit("AppWS", "Send", json.encode({ -- 850
			name = "SearchFilesDone", -- 850
			id = id, -- 850
			stopped = stopped -- 850
		})) -- 849
	end)) -- 839
end -- 822
local stop -- 853
stop = function() -- 853
	if isInEntry then -- 854
		return false -- 854
	end -- 854
	allClear() -- 855
	isInEntry = true -- 856
	currentEntry = nil -- 857
	return true -- 858
end -- 853
_module_0["stop"] = stop -- 853
local getCurrentEntryStatus -- 860
getCurrentEntryStatus = function() -- 860
	local entry = currentEntry -- 861
	if not (entry and not isInEntry) then -- 862
		return { -- 862
			success = true, -- 862
			running = false, -- 862
			runId = allEntries.runId -- 862
		} -- 862
	end -- 862
	local status = { -- 864
		success = true, -- 864
		running = true, -- 865
		kind = entry.runKind or "file", -- 866
		runId = allEntries.runId, -- 867
		entryName = entry.entryName, -- 868
		fileName = entry.fileName -- 869
	} -- 863
	if entry.workDir then -- 870
		status.workDir = entry.workDir -- 870
	end -- 870
	if entry.projectRoot then -- 871
		status.projectRoot = entry.projectRoot -- 871
	end -- 871
	return status -- 872
end -- 860
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 860
local _anon_func_2 = function(_with_0) -- 891
	local _val_0 = App.platform -- 891
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 891
end -- 891
setupEventHandlers = function() -- 874
	local _with_0 = Director.postNode -- 875
	_with_0:onAppEvent(function(eventType) -- 876
		if "Quit" == eventType then -- 877
			quit = true -- 878
			allClear() -- 879
			return clearTempFiles() -- 880
		elseif "Shutdown" == eventType then -- 881
			return stop() -- 882
		end -- 876
	end) -- 876
	_with_0:onAppChange(function(settingName) -- 883
		if "Theme" == settingName then -- 884
			config.themeColor = App.themeColor:toARGB() -- 885
		elseif "Locale" == settingName then -- 886
			config.locale = App.locale -- 887
			updateLocale() -- 888
			return teal.clear(true) -- 889
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 890
			if _anon_func_2(_with_0) then -- 891
				if "FullScreen" == settingName then -- 893
					config.fullScreen = App.fullScreen -- 893
				elseif "Position" == settingName then -- 894
					local _obj_0 = App.winPosition -- 894
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 894
				elseif "Size" == settingName then -- 895
					local width, height -- 896
					do -- 896
						local _obj_0 = App.winSize -- 896
						width, height = _obj_0.width, _obj_0.height -- 896
					end -- 896
					config.winWidth = width -- 897
					config.winHeight = height -- 898
				end -- 892
			end -- 891
		end -- 883
	end) -- 883
	_with_0:onAppWS(function(event) -- 899
		if event.type == "Close" then -- 900
			if HttpServer.wsConnectionCount == 0 then -- 901
				updateEntries() -- 902
			end -- 901
			return -- 903
		end -- 900
		if not (event.type == "Receive") then -- 904
			return -- 904
		end -- 904
		local data = json.decode(event.msg) -- 905
		if not data then -- 906
			return -- 906
		end -- 906
		local _exp_0 = data.name -- 907
		if "SearchFiles" == _exp_0 then -- 908
			return handleSearchFiles(data) -- 909
		elseif "SearchFilesStop" == _exp_0 then -- 910
			if data.id == nil or data.id == activeSearchId then -- 911
				activeSearchId = 0 -- 912
			end -- 911
		end -- 907
	end) -- 899
	_with_0:slot("UpdateEntries", function() -- 913
		return updateEntries() -- 913
	end) -- 913
	return _with_0 -- 875
end -- 874
setupEventHandlers() -- 915
clearTempFiles() -- 916
local downloadFile -- 918
downloadFile = function(url, target) -- 918
	return Director.systemScheduler:schedule(once(function() -- 918
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 919
			if quit then -- 920
				return true -- 920
			end -- 920
			emit("AppWS", "Send", json.encode({ -- 922
				name = "Download", -- 922
				url = url, -- 922
				status = "downloading", -- 922
				progress = current / total -- 923
			})) -- 921
			return false -- 919
		end) -- 919
		return emit("AppWS", "Send", json.encode(success and { -- 926
			name = "Download", -- 926
			url = url, -- 926
			status = "completed", -- 926
			progress = 1.0 -- 927
		} or { -- 929
			name = "Download", -- 929
			url = url, -- 929
			status = "failed", -- 929
			progress = 0.0 -- 930
		})) -- 925
	end)) -- 918
end -- 918
_module_0["downloadFile"] = downloadFile -- 918
local _anon_func_3 = function(file, require, workDir) -- 942
	if workDir == nil then -- 942
		workDir = Path:getPath(file) -- 942
	end -- 942
	Content:insertSearchPath(1, workDir) -- 943
	local scriptPath = Path(workDir, "Script") -- 944
	if Content:exist(scriptPath) then -- 945
		Content:insertSearchPath(1, scriptPath) -- 946
	end -- 945
	local result = require(file) -- 947
	if "function" == type(result) then -- 948
		result() -- 948
	end -- 948
	return nil -- 949
end -- 942
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 978
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 978
	label.alignment = "Left" -- 979
	label.textWidth = width - fontSize -- 980
	label.text = err -- 981
	return label -- 978
end -- 978
local enterEntryAsync -- 933
enterEntryAsync = function(entry) -- 933
	allEntries.runId = allEntries.runId + 1 -- 934
	isInEntry = false -- 935
	App.idled = false -- 936
	emit(Profiler.EventName, "ClearLoader") -- 937
	currentEntry = entry -- 938
	local file, workDir = entry.fileName, entry.workDir -- 939
	sleep() -- 940
	return xpcall(_anon_func_3, function(msg) -- 949
		local err = debug.traceback(msg) -- 951
		Log("Error", err) -- 952
		allClear() -- 953
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 954
		local viewWidth, viewHeight -- 955
		do -- 955
			local _obj_0 = View.size -- 955
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 955
		end -- 955
		local width, height = viewWidth - 20, viewHeight - 20 -- 956
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 957
		Director.ui:addChild((function() -- 958
			local root = AlignNode() -- 958
			do -- 959
				local _obj_0 = App.bufferSize -- 959
				width, height = _obj_0.width, _obj_0.height -- 959
			end -- 959
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 960
			root:onAppChange(function(settingName) -- 961
				if settingName == "Size" then -- 961
					do -- 962
						local _obj_0 = App.bufferSize -- 962
						width, height = _obj_0.width, _obj_0.height -- 962
					end -- 962
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 963
				end -- 961
			end) -- 961
			root:addChild((function() -- 964
				local _with_0 = ScrollArea({ -- 965
					width = width, -- 965
					height = height, -- 966
					paddingX = 0, -- 967
					paddingY = 50, -- 968
					viewWidth = height, -- 969
					viewHeight = height -- 970
				}) -- 964
				root:onAlignLayout(function(w, h) -- 972
					_with_0.position = Vec2(w / 2, h / 2) -- 973
					w = w - 20 -- 974
					h = h - 20 -- 975
					_with_0.view.children.first.textWidth = w - fontSize -- 976
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 977
				end) -- 972
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 978
				return _with_0 -- 964
			end)()) -- 964
			return root -- 958
		end)()) -- 958
		return err -- 982
	end, file, require, workDir) -- 941
end -- 933
_module_0["enterEntryAsync"] = enterEntryAsync -- 933
local enterDemoEntry -- 984
enterDemoEntry = function(entry) -- 984
	return thread(function() -- 984
		return enterEntryAsync(entry) -- 984
	end) -- 984
end -- 984
local reloadCurrentEntry -- 986
reloadCurrentEntry = function() -- 986
	if currentEntry then -- 987
		allClear() -- 988
		return enterDemoEntry(currentEntry) -- 989
	end -- 987
end -- 986
Director.clearColor = Color(0xff1a1a1a) -- 991
local descColor = Color(0xffa1a1a1) -- 992
local extraOperations -- 995
do -- 995
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 996
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 997
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 998
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 999
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1000
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1001
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1002
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1003
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1004
	local ossLicenses = nil -- 1005
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1006
	local failedSetFolder = false -- 1007
	local statusFlags = { -- 1008
		"NoResize", -- 1008
		"NoMove", -- 1008
		"NoCollapse", -- 1008
		"AlwaysAutoResize", -- 1008
		"NoSavedSettings" -- 1008
	} -- 1008
	extraOperations = function() -- 1015
		local zh = useChinese -- 1016
		if isDesktop then -- 1017
			local alwaysOnTop = config.alwaysOnTop -- 1018
			do -- 1019
				local changed -- 1019
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1019
				if changed then -- 1019
					App.alwaysOnTop = alwaysOnTop -- 1020
					config.alwaysOnTop = alwaysOnTop -- 1021
				end -- 1019
			end -- 1019
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1022
			do -- 1023
				local changed -- 1023
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1023
				if changed then -- 1023
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1024
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1025
				end -- 1023
			end -- 1023
			SameLine() -- 1026
			TextColored(descColor, "(?)") -- 1027
			if IsItemHovered() then -- 1028
				BeginTooltip(function() -- 1029
					return PushTextWrapPos(360, function() -- 1030
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1031
					end) -- 1030
				end) -- 1029
			end -- 1028
		end -- 1017
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1046
		do -- 1050
			local changed -- 1050
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1050
			if changed then -- 1050
				config.showPreview = showPreview -- 1051
				updateEntries() -- 1052
				if not showPreview then -- 1053
					thread(function() -- 1054
						collectgarbage() -- 1055
						return Cache:removeUnused("Texture") -- 1056
					end) -- 1054
				end -- 1053
			end -- 1050
		end -- 1050
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1057
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1058
			if changed then -- 1058
				config.webIDEEnabled = webIDEEnabled -- 1059
				App.webIDEEnabled = webIDEEnabled -- 1060
			end -- 1058
		end -- 1057
		do -- 1061
			local themeColor = App.themeColor -- 1062
			local writablePath = config.writablePath -- 1063
			SeparatorText(zh and "工作目录" or "Workspace") -- 1064
			PushTextWrapPos(400, function() -- 1065
				return TextColored(themeColor, writablePath) -- 1066
			end) -- 1065
			if not isDesktop then -- 1067
				goto skipSetting -- 1067
			end -- 1067
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1068
			if Button(zh and "改变目录" or "Set Folder") then -- 1069
				App:openFileDialog(true, function(path) -- 1070
					if path == "" then -- 1071
						return -- 1071
					end -- 1071
					local relPath = Path:getRelative(Content.assetPath, path) -- 1072
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1073
						return setWorkspace(path) -- 1074
					else -- 1076
						failedSetFolder = true -- 1076
					end -- 1073
				end) -- 1070
			end -- 1069
			if failedSetFolder then -- 1077
				failedSetFolder = false -- 1078
				OpenPopup(popupName) -- 1079
			end -- 1077
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1080
			BeginPopupModal(popupName, statusFlags, function() -- 1081
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1082
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1083
					return CloseCurrentPopup() -- 1084
				end -- 1083
			end) -- 1081
			SameLine() -- 1085
			if Button(zh and "使用默认" or "Use Default") then -- 1086
				setWorkspace(Content.appPath) -- 1087
			end -- 1086
			Separator() -- 1088
			::skipSetting:: -- 1089
		end -- 1061
		renderAgentStorage(zh) -- 1090
		if isOSSLicenseExist then -- 1091
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1092
				if not ossLicenses then -- 1093
					local licenseText = Content:load("LICENSES") -- 1094
					if licenseText then -- 1094
						local GSplit -- 1095
						do -- 1095
							local _obj_0 = require("Utils") -- 1095
							GSplit = _obj_0.GSplit -- 1095
						end -- 1095
						ossLicenses = { } -- 1096
						licenseText = licenseText:gsub("\r\n", "\n") -- 1097
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1098
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1099
							if name then -- 1099
								ossLicenses[#ossLicenses + 1] = { -- 1100
									name, -- 1100
									text -- 1100
								} -- 1100
							end -- 1099
						end -- 1098
					end -- 1094
				end -- 1093
				if ossLicenses then -- 1101
					OpenPopup(ossLicensePopup) -- 1101
				end -- 1101
			end -- 1092
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1102
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1103
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1104
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1105
				return BeginPopupModal(ossLicensePopup, true, { -- 1108
					"NoSavedSettings" -- 1108
				}, function() -- 1109
					for _index_0 = 1, #ossLicenses do -- 1110
						local _des_0 = ossLicenses[_index_0] -- 1110
						local firstLine, text = _des_0[1], _des_0[2] -- 1110
						local name, license = firstLine:match("(.+): (.+)") -- 1112
						if name then -- 1112
							TextColored(themeColor, name) -- 1113
							SameLine() -- 1114
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1115
								return TextWrapped(text) -- 1115
							end) -- 1115
						end -- 1112
					end -- 1110
				end) -- 1105
			end) -- 1105
		end -- 1091
		if not App.debugging then -- 1118
			return -- 1118
		end -- 1118
		return TreeNode(zh and "开发操作" or "Development", function() -- 1119
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1120
				OpenPopup("build") -- 1120
			end -- 1120
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1121
				return BeginPopup("build", function() -- 1121
					if Selectable(zh and "编译" or "Compile") then -- 1122
						doCompile(false) -- 1122
					end -- 1122
					Separator() -- 1123
					if Selectable(zh and "压缩" or "Minify") then -- 1124
						doCompile(true) -- 1124
					end -- 1124
					Separator() -- 1125
					if Selectable(zh and "清理" or "Clean") then -- 1126
						return doClean() -- 1126
					end -- 1126
				end) -- 1121
			end) -- 1121
			if isInEntry then -- 1127
				if waitForWebStart then -- 1128
					BeginDisabled(function() -- 1129
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1129
					end) -- 1129
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1130
					reloadDevEntry() -- 1131
				end -- 1128
			end -- 1127
			do -- 1132
				local changed -- 1132
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1132
				if changed then -- 1132
					View.scale = scaleContent and screenScale or 1 -- 1133
				end -- 1132
			end -- 1132
			do -- 1134
				local changed -- 1134
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1134
				if changed then -- 1134
					config.engineDev = engineDev -- 1135
				end -- 1134
			end -- 1134
			do -- 1136
				local changed -- 1136
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1136
				if changed then -- 1136
					config.webIDETourCompleted = webIDETourCompleted -- 1137
				end -- 1136
			end -- 1136
			if testingThread then -- 1138
				return BeginDisabled(function() -- 1139
					return Button(zh and "开始自动测试" or "Test automatically") -- 1139
				end) -- 1139
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1140
				testingThread = thread(function() -- 1141
					local _ <close> = setmetatable({ }, { -- 1142
						__close = function() -- 1142
							allClear() -- 1143
							testingThread = nil -- 1144
							isInEntry = true -- 1145
							currentEntry = nil -- 1146
							return print("Testing done!") -- 1147
						end -- 1142
					}) -- 1142
					for _, entry in ipairs(allEntries) do -- 1148
						allClear() -- 1149
						print("Start " .. tostring(entry.entryName)) -- 1150
						enterDemoEntry(entry) -- 1151
						sleep(2) -- 1152
						print("Stop " .. tostring(entry.entryName)) -- 1153
					end -- 1148
				end) -- 1141
			end -- 1138
		end) -- 1119
	end -- 1015
end -- 995
local icon = Path("Script", "Dev", "icon_s.png") -- 1155
local iconTex = nil -- 1156
thread(function() -- 1157
	if Cache:loadAsync(icon) then -- 1157
		iconTex = Texture2D(icon) -- 1157
	end -- 1157
end) -- 1157
local webStatus = nil -- 1159
local urlClicked = nil -- 1160
local authCode = string.format("%06d", math.random(0, 999999)) -- 1162
local authCodeTTL = 30.0 -- 1164
_module_0.getAuthCode = function() -- 1165
	return authCode -- 1165
end -- 1165
_module_0.invalidateAuthCode = function() -- 1166
	authCode = string.format("%06d", math.random(0, 999999)) -- 1167
	authCodeTTL = 30.0 -- 1168
end -- 1166
local AuthSession -- 1170
do -- 1170
	local pending = nil -- 1171
	local session = nil -- 1172
	AuthSession = { -- 1174
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1174
			pending = { -- 1176
				sessionId = sessionId, -- 1176
				confirmCode = confirmCode, -- 1177
				expiresAt = expiresAt, -- 1178
				ttl = ttl, -- 1179
				approved = false -- 1180
			} -- 1175
		end, -- 1174
		getPending = function() -- 1182
			return pending -- 1182
		end, -- 1182
		approvePending = function(sessionId) -- 1184
			if pending and pending.sessionId == sessionId then -- 1185
				pending.approved = true -- 1186
				return true -- 1187
			end -- 1185
			return false -- 1188
		end, -- 1184
		clearPending = function() -- 1190
			pending = nil -- 1190
		end, -- 1190
		setSession = function(sessionId, sessionSecret) -- 1192
			session = { -- 1194
				sessionId = sessionId, -- 1194
				sessionSecret = sessionSecret -- 1195
			} -- 1193
		end, -- 1192
		getSession = function() -- 1197
			return session -- 1197
		end -- 1197
	} -- 1173
end -- 1170
_module_0["AuthSession"] = AuthSession -- 1170
local transparant = Color(0x0) -- 1200
local windowFlags = { -- 1201
	"NoTitleBar", -- 1201
	"NoResize", -- 1201
	"NoMove", -- 1201
	"NoCollapse", -- 1201
	"NoSavedSettings", -- 1201
	"NoFocusOnAppearing", -- 1201
	"NoBringToFrontOnFocus" -- 1201
} -- 1201
local statusFlags = { -- 1210
	"NoTitleBar", -- 1210
	"NoResize", -- 1210
	"NoMove", -- 1210
	"NoCollapse", -- 1210
	"AlwaysAutoResize", -- 1210
	"NoSavedSettings" -- 1210
} -- 1210
local displayWindowFlags = { -- 1218
	"NoDecoration", -- 1218
	"NoSavedSettings", -- 1218
	"NoMove", -- 1218
	"NoScrollWithMouse", -- 1218
	"AlwaysAutoResize", -- 1218
	"NoFocusOnAppearing" -- 1218
} -- 1218
local _anon_func_5 = function(allEntries, currentIndex) -- 1291
	if currentIndex > 1 then -- 1291
		return allEntries[currentIndex - 1] -- 1292
	else -- 1294
		return allEntries[#allEntries] -- 1294
	end -- 1291
end -- 1291
local _anon_func_6 = function(allEntries, currentIndex) -- 1298
	if currentIndex < #allEntries then -- 1298
		return allEntries[currentIndex + 1] -- 1299
	else -- 1301
		return allEntries[1] -- 1301
	end -- 1298
end -- 1298
do -- 1227
	local gamepadInputWindowFlags = { -- 1228
		"NoDecoration", -- 1228
		"NoSavedSettings", -- 1228
		"NoMove", -- 1228
		"NoScrollbar", -- 1228
		"NoScrollWithMouse", -- 1228
		"NoFocusOnAppearing", -- 1228
		"NoBringToFrontOnFocus" -- 1228
	} -- 1228
	local initFooter = true -- 1237
	local gamepadInputFocused = false -- 1238
	footerWindow = threadLoop(function() -- 1239
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1240
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1241
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1242
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1243
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1244
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1245
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1246
		if mobileMode then -- 1247
			return -- 1247
		end -- 1247
		local zh = useChinese -- 1248
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1249
		if authCodeTTL <= 0 then -- 1250
			authCodeTTL = 30.0 -- 1251
			authCode = string.format("%06d", math.random(0, 999999)) -- 1252
		end -- 1250
		if HttpServer.wsConnectionCount > 0 then -- 1253
			return -- 1254
		end -- 1253
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1255
			if App.platform == "Emscripten" then -- 1256
				stop() -- 1258
			else -- 1260
				allClear() -- 1260
				App.devMode = false -- 1261
				App:shutdown() -- 1262
			end -- 1256
		end -- 1255
		do -- 1263
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1264
			if ctrl and Keyboard:isKeyDown("Q") then -- 1265
				stop() -- 1266
			end -- 1265
			if ctrl and Keyboard:isKeyDown("Z") then -- 1267
				reloadCurrentEntry() -- 1268
			end -- 1267
			if ctrl and Keyboard:isKeyDown(",") then -- 1269
				if showFooter then -- 1270
					showStats = not showStats -- 1270
				else -- 1270
					showStats = true -- 1270
				end -- 1270
				showFooter = true -- 1271
				config.showFooter = showFooter -- 1272
				config.showStats = showStats -- 1273
			end -- 1269
			if ctrl and Keyboard:isKeyDown(".") then -- 1274
				if showFooter then -- 1275
					showConsole = not showConsole -- 1275
				else -- 1275
					showConsole = true -- 1275
				end -- 1275
				showFooter = true -- 1276
				config.showFooter = showFooter -- 1277
				config.showConsole = showConsole -- 1278
			end -- 1274
			if ctrl and Keyboard:isKeyDown("/") then -- 1279
				showFooter = not showFooter -- 1280
				config.showFooter = showFooter -- 1281
			end -- 1279
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1282
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1283
			local currentIndex = nil -- 1284
			for i, entry in ipairs(allEntries) do -- 1285
				if currentEntry == entry then -- 1286
					currentIndex = i -- 1287
				end -- 1286
			end -- 1285
			if left then -- 1288
				allClear() -- 1289
				if currentIndex == nil then -- 1290
					currentIndex = #allEntries + 1 -- 1290
				end -- 1290
				enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1291
			end -- 1288
			if right then -- 1295
				allClear() -- 1296
				if currentIndex == nil then -- 1297
					currentIndex = 0 -- 1297
				end -- 1297
				enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1298
			end -- 1295
		end -- 1263
		if not showEntry then -- 1302
			return -- 1302
		end -- 1302
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1304
			reloadDevEntry() -- 1308
		end -- 1304
		if initFooter then -- 1309
			initFooter = false -- 1310
		end -- 1309
		local width, height -- 1312
		do -- 1312
			local _obj_0 = App.visualSize -- 1312
			width, height = _obj_0.width, _obj_0.height -- 1312
		end -- 1312
		if isInEntry then -- 1313
			gamepadInputFocused = false -- 1314
		else -- 1316
			SetNextWindowBgAlpha(0.0) -- 1316
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1317
			SetNextWindowPos(Vec2.zero, "Always") -- 1318
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1319
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1320
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1321
						if not gamepadInputFocused then -- 1322
							SetWindowFocus("DoraGamepadInput") -- 1323
							gamepadInputFocused = true -- 1324
						end -- 1322
					end) -- 1321
				end) -- 1320
			end) -- 1319
		end -- 1313
		if isInEntry or showFooter then -- 1326
			SetNextWindowSize(Vec2(width, 50)) -- 1327
			SetNextWindowPos(Vec2(0, height - 50)) -- 1328
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1329
				return PushStyleVar("WindowRounding", 0, function() -- 1330
					return Begin("Footer", windowFlags, function() -- 1331
						Separator() -- 1332
						if iconTex then -- 1333
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1334
								showStats = not showStats -- 1335
								config.showStats = showStats -- 1336
							end -- 1334
							SameLine() -- 1337
							if Button(">_", Vec2(30, 30)) then -- 1338
								showConsole = not showConsole -- 1339
								config.showConsole = showConsole -- 1340
							end -- 1338
						end -- 1333
						if isInEntry and updateState.available then -- 1341
							SameLine() -- 1342
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1343
								allClear() -- 1344
								enterDemoEntry({ -- 1346
									entryName = "SelfUpdater", -- 1346
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1347
								}) -- 1345
							end -- 1343
						end -- 1341
						if not isInEntry then -- 1348
							SameLine() -- 1349
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1350
							local currentIndex = nil -- 1351
							for i, entry in ipairs(allEntries) do -- 1352
								if currentEntry == entry then -- 1353
									currentIndex = i -- 1354
								end -- 1353
							end -- 1352
							if currentIndex then -- 1355
								if currentIndex > 1 then -- 1356
									SameLine() -- 1357
									if Button("<<", Vec2(30, 30)) then -- 1358
										allClear() -- 1359
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1360
									end -- 1358
								end -- 1356
								if currentIndex < #allEntries then -- 1361
									SameLine() -- 1362
									if Button(">>", Vec2(30, 30)) then -- 1363
										allClear() -- 1364
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1365
									end -- 1363
								end -- 1361
							end -- 1355
							SameLine() -- 1366
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1367
								reloadCurrentEntry() -- 1368
							end -- 1367
							if back then -- 1369
								allClear() -- 1370
								isInEntry = true -- 1371
								currentEntry = nil -- 1372
							end -- 1369
						end -- 1348
					end) -- 1331
				end) -- 1330
			end) -- 1329
		end -- 1326
		if isInEntry then -- 1374
			local showURL = true -- 1375
			local webIDEWidth -- 1376
			do -- 1376
				local base -- 1377
				if updateState.available then -- 1377
					base = 460 -- 1377
				else -- 1377
					base = 360 -- 1377
				end -- 1377
				local extra = 35 -- 1378
				webIDEWidth = base + extra -- 1379
			end -- 1376
			if width < webIDEWidth then -- 1380
				showURL = false -- 1380
			end -- 1380
			SetNextWindowBgAlpha(0.0) -- 1381
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1382
			Begin("Web IDE", displayWindowFlags, function() -- 1383
				local pending = AuthSession.getPending() -- 1384
				local hovered = false -- 1385
				if not pending and showURL then -- 1386
					do -- 1387
						local url -- 1387
						if webStatus ~= nil then -- 1387
							url = webStatus.url -- 1387
						end -- 1387
						if url then -- 1387
							if isDesktop and not config.fullScreen then -- 1388
								if urlClicked then -- 1389
									BeginDisabled(function() -- 1390
										return Button(url) -- 1390
									end) -- 1390
								elseif Button(url) then -- 1391
									urlClicked = once(function() -- 1392
										return sleep(5) -- 1392
									end) -- 1392
									App:openURL("http://localhost:8866") -- 1393
								end -- 1389
							else -- 1395
								TextColored(descColor, url) -- 1395
							end -- 1388
						else -- 1397
							TextColored(descColor, zh and '不可用' or 'not available') -- 1397
						end -- 1387
					end -- 1387
					hovered = IsItemHovered() -- 1398
				else -- 1400
					TextColored(descColor, "(?)") -- 1400
					hovered = IsItemHovered() -- 1401
				end -- 1386
				SameLine() -- 1402
				local themeColor = App.themeColor -- 1403
				if pending then -- 1404
					if not pending.approved then -- 1405
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1406
						local ttl = pending.ttl or 1 -- 1407
						PushStyleColor("Text", themeColor, function() -- 1408
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1409
							hovered = hovered or IsItemHovered() -- 1410
						end) -- 1408
						SameLine() -- 1411
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1412
							AuthSession.approvePending(pending.sessionId) -- 1413
						end -- 1412
						if hovered then -- 1414
							return BeginTooltip(function() -- 1415
								return PushTextWrapPos(280, function() -- 1416
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1417
								end) -- 1416
							end) -- 1415
						end -- 1414
					end -- 1405
				else -- 1419
					PushStyleColor("Text", themeColor, function() -- 1419
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1420
						hovered = hovered or IsItemHovered() -- 1421
					end) -- 1419
					if hovered then -- 1422
						return BeginTooltip(function() -- 1423
							return PushTextWrapPos(280, function() -- 1424
								local url -- 1425
								if webStatus ~= nil then -- 1425
									url = webStatus.url -- 1425
								end -- 1425
								if url then -- 1425
									local address -- 1426
									if showURL then -- 1426
										address = "Web IDE" -- 1426
									else -- 1426
										address = url -- 1426
									end -- 1426
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1427
								else -- 1429
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1429
								end -- 1425
							end) -- 1424
						end) -- 1423
					end -- 1422
				end -- 1404
			end) -- 1383
		end -- 1374
		if not isInEntry then -- 1430
			SetNextWindowSize(Vec2(50, 50)) -- 1431
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1432
			PushStyleColor("WindowBg", transparant, function() -- 1433
				return Begin("Show", displayWindowFlags, function() -- 1433
					if width >= 370 then -- 1434
						local changed -- 1435
						changed, showFooter = Checkbox("##dev", showFooter) -- 1435
						if changed then -- 1435
							config.showFooter = showFooter -- 1436
						end -- 1435
					end -- 1434
				end) -- 1433
			end) -- 1433
		end -- 1430
		if isInEntry or showFooter then -- 1438
			if showStats then -- 1439
				PushStyleVar("WindowRounding", 0, function() -- 1440
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1441
					SetNextWindowSize(Vec2(0, height - 50)) -- 1442
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1443
					config.showStats = showStats -- 1444
				end) -- 1440
			end -- 1439
			if showConsole then -- 1445
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1446
				return PushStyleVar("WindowRounding", 6, function() -- 1447
					return ShowConsole() -- 1448
				end) -- 1447
			end -- 1445
		end -- 1438
	end) -- 1239
end -- 1227
do -- 1451
	local MaxWidth <const> = 960 -- 1452
	local toolOpen = false -- 1454
	local filterText = nil -- 1455
	allEntries.anyEntryMatched = false -- 1456
	allEntries.match = function(name) -- 1457
		local res = not filterText or name:lower():match(filterText) -- 1458
		if res then -- 1459
			allEntries.anyEntryMatched = true -- 1459
		end -- 1459
		return res -- 1460
	end -- 1457
	allEntries.thinSep = function() -- 1462
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1462
			return ImGui.SeparatorText("") -- 1462
		end) -- 1462
	end -- 1462
	entryWindow = threadLoop(function() -- 1463
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1464
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1465
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1466
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1467
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1468
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1469
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1470
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1471
		local connected = syncWebIDEControl() -- 1472
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1474
			if not allEntries.pendingPackagePath then -- 1475
				local path = App:takeReceivedFile() -- 1476
				if path ~= "" then -- 1477
					allEntries.pendingPackagePath = path -- 1477
				end -- 1477
			end -- 1475
			if allEntries.pendingPackagePath then -- 1478
				pendingUIMode = true -- 1478
			end -- 1478
		end -- 1474
		if (pendingUIMode ~= nil) then -- 1480
			local nextMode = pendingUIMode -- 1481
			pendingUIMode = nil -- 1482
			applyUIMode(nextMode) -- 1483
		end -- 1480
		if mobileMode and not connected then -- 1484
			if isInEntry and not feedHost then -- 1485
				applyUIMode(true) -- 1485
			end -- 1485
			return -- 1486
		end -- 1484
		if App.fpsLimited ~= config.fpsLimited then -- 1487
			config.fpsLimited = App.fpsLimited -- 1488
		end -- 1487
		if App.targetFPS ~= config.targetFPS then -- 1489
			config.targetFPS = App.targetFPS -- 1490
		end -- 1489
		if View.vsync ~= config.vsync then -- 1491
			config.vsync = View.vsync -- 1492
		end -- 1491
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1493
			config.fixedFPS = Director.scheduler.fixedFPS -- 1494
		end -- 1493
		if Director.profilerSending ~= config.webProfiler then -- 1495
			config.webProfiler = Director.profilerSending -- 1496
		end -- 1495
		if urlClicked then -- 1497
			local _, result = coroutine.resume(urlClicked) -- 1498
			if result then -- 1499
				coroutine.close(urlClicked) -- 1500
				urlClicked = nil -- 1501
			end -- 1499
		end -- 1497
		if not isInEntry then -- 1502
			return -- 1502
		end -- 1502
		local zh = useChinese -- 1503
		local themeColor = App.themeColor -- 1504
		if connected then -- 1505
			local width, height -- 1506
			do -- 1506
				local _obj_0 = App.visualSize -- 1506
				width, height = _obj_0.width, _obj_0.height -- 1506
			end -- 1506
			SetNextWindowBgAlpha(0.5) -- 1507
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1508
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1509
				Separator() -- 1510
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1511
				if iconTex then -- 1512
					Image(icon, Vec2(24, 24)) -- 1513
					SameLine() -- 1514
				end -- 1512
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1515
				TextColored(descColor, slogon) -- 1516
				return Separator() -- 1517
			end) -- 1509
			return -- 1518
		end -- 1505
		if not showEntry then -- 1519
			return -- 1519
		end -- 1519
		local fullWidth, height -- 1521
		do -- 1521
			local _obj_0 = App.visualSize -- 1521
			fullWidth, height = _obj_0.width, _obj_0.height -- 1521
		end -- 1521
		local width = math.min(MaxWidth, fullWidth) -- 1522
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1523
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1524
		SetNextWindowPos(Vec2.zero) -- 1525
		SetNextWindowBgAlpha(0) -- 1526
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1527
		do -- 1528
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1529
				return Begin("Dora Dev", windowFlags, function() -- 1530
					Dummy(Vec2(fullWidth - 20, 0)) -- 1531
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1532
					SameLine() -- 1533
					if Button(zh and "Go 模式" or "Go Mode") then -- 1534
						setUIMode("mobile") -- 1535
					end -- 1534
					if fullWidth >= 540 then -- 1536
						SameLine() -- 1537
						Dummy(Vec2(fullWidth - 540, 0)) -- 1538
						SameLine() -- 1539
						SetNextItemWidth(zh and -95 or -140) -- 1540
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1541
							"AutoSelectAll" -- 1541
						}) then -- 1541
							config.filter = filterBuf.text -- 1542
						end -- 1541
						SameLine() -- 1543
						if Button(zh and '下载' or 'Download') then -- 1544
							allClear() -- 1545
							enterDemoEntry({ -- 1547
								entryName = "ResourceDownloader", -- 1547
								fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1548
							}) -- 1546
						end -- 1544
					end -- 1536
					return Separator() -- 1549
				end) -- 1530
			end) -- 1529
		end -- 1528
		allEntries.anyEntryMatched = false -- 1551
		SetNextWindowPos(Vec2(0, 50)) -- 1552
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1553
		local scrollbarSize <const> = 25 -- 1555
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1556
		do -- 1557
			return PushStyleColor("WindowBg", transparant, function() -- 1558
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1559
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1560
						return PushStyleVar("Alpha", 1, function() -- 1561
							return Begin("Content", windowFlags, function() -- 1562
								local DemoViewWidth <const> = 220 -- 1563
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1564
								if filterText then -- 1565
									filterText = filterText:lower() -- 1565
								end -- 1565
								if App.platform == "Emscripten" then -- 1566
									Dora.globals.webProjects.draw(zh, themeColor) -- 1567
									allEntries.anyEntryMatched = true -- 1568
								end -- 1566
								if #gamesInDev > 0 then -- 1569
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1570
									Columns(columns, false) -- 1571
									local realViewWidth = GetColumnWidth() - 50 -- 1572
									for _index_0 = 1, #gamesInDev do -- 1573
										local game = gamesInDev[_index_0] -- 1573
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1574
										local displayName -- 1583
										if repo then -- 1583
											if zh then -- 1584
												displayName = repo.title.zh -- 1584
											else -- 1584
												displayName = repo.title.en -- 1584
											end -- 1584
										end -- 1583
										if displayName == nil then -- 1585
											displayName = gameName -- 1585
										end -- 1585
										if allEntries.match(displayName) then -- 1586
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1587
											SameLine() -- 1588
											TextWrapped(displayName) -- 1589
											if columns > 1 then -- 1590
												if bannerFile and bannerTex then -- 1591
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1592
													local displayWidth <const> = realViewWidth -- 1593
													texHeight = displayWidth * texHeight / texWidth -- 1594
													texWidth = displayWidth -- 1595
													Dummy(Vec2.zero) -- 1596
													SameLine() -- 1597
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1598
												end -- 1591
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1599
													enterDemoEntry(game) -- 1600
												end -- 1599
											else -- 1602
												if bannerFile and bannerTex then -- 1602
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1603
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1604
													local sizing = 0.8 -- 1605
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1606
													texWidth = displayWidth * sizing -- 1607
													if texWidth > 500 then -- 1608
														sizing = 0.6 -- 1609
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1610
														texWidth = displayWidth * sizing -- 1611
													end -- 1608
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1612
													Dummy(Vec2(padding, 0)) -- 1613
													SameLine() -- 1614
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1615
												end -- 1602
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1616
													enterDemoEntry(game) -- 1617
												end -- 1616
											end -- 1590
											if #tests == 0 and #examples == 0 then -- 1618
												allEntries.thinSep() -- 1619
											end -- 1618
											NextColumn() -- 1620
										end -- 1586
										local showSep = false -- 1621
										if #examples > 0 then -- 1622
											local showExample = false -- 1623
											for _index_1 = 1, #examples do -- 1624
												local _des_0 = examples[_index_1] -- 1624
												local entryName = _des_0.entryName -- 1624
												if allEntries.match(entryName) then -- 1625
													showExample = true -- 1625
													break -- 1625
												end -- 1625
											end -- 1624
											if showExample then -- 1626
												showSep = true -- 1627
												Columns(1, false) -- 1628
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1629
												SameLine() -- 1630
												local opened -- 1631
												if (filterText ~= nil) then -- 1631
													opened = showExample -- 1631
												else -- 1631
													opened = false -- 1631
												end -- 1631
												if game.exampleOpen == nil then -- 1632
													game.exampleOpen = opened -- 1632
												end -- 1632
												SetNextItemOpen(game.exampleOpen) -- 1633
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1634
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1635
														Columns(maxColumns, false) -- 1636
														for _index_1 = 1, #examples do -- 1637
															local example = examples[_index_1] -- 1637
															local entryName = example.entryName -- 1638
															if not allEntries.match(entryName) then -- 1639
																goto _continue_0 -- 1639
															end -- 1639
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1640
																if Button(entryName, Vec2(-1, 40)) then -- 1641
																	enterDemoEntry(example) -- 1642
																end -- 1641
																return NextColumn() -- 1643
															end) -- 1640
															opened = true -- 1644
															::_continue_0:: -- 1638
														end -- 1637
													end) -- 1635
												end) -- 1634
												game.exampleOpen = opened -- 1645
											end -- 1626
										end -- 1622
										if #tests > 0 then -- 1646
											local showTest = false -- 1647
											for _index_1 = 1, #tests do -- 1648
												local _des_0 = tests[_index_1] -- 1648
												local entryName = _des_0.entryName -- 1648
												if allEntries.match(entryName) then -- 1649
													showTest = true -- 1649
													break -- 1649
												end -- 1649
											end -- 1648
											if showTest then -- 1650
												showSep = true -- 1651
												Columns(1, false) -- 1652
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1653
												SameLine() -- 1654
												local opened -- 1655
												if (filterText ~= nil) then -- 1655
													opened = showTest -- 1655
												else -- 1655
													opened = false -- 1655
												end -- 1655
												if game.testOpen == nil then -- 1656
													game.testOpen = opened -- 1656
												end -- 1656
												SetNextItemOpen(game.testOpen) -- 1657
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1658
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1659
														Columns(maxColumns, false) -- 1660
														for _index_1 = 1, #tests do -- 1661
															local test = tests[_index_1] -- 1661
															local entryName = test.entryName -- 1662
															if not allEntries.match(entryName) then -- 1663
																goto _continue_0 -- 1663
															end -- 1663
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1664
																if Button(entryName, Vec2(-1, 40)) then -- 1665
																	enterDemoEntry(test) -- 1666
																end -- 1665
																return NextColumn() -- 1667
															end) -- 1664
															opened = true -- 1668
															::_continue_0:: -- 1662
														end -- 1661
													end) -- 1659
												end) -- 1658
												game.testOpen = opened -- 1669
											end -- 1650
										end -- 1646
										if showSep then -- 1670
											Columns(1, false) -- 1671
											allEntries.thinSep() -- 1672
											Columns(columns, false) -- 1673
										end -- 1670
									end -- 1573
								end -- 1569
								if #doraTools > 0 then -- 1674
									local showTool = false -- 1675
									for _index_0 = 1, #doraTools do -- 1676
										local _des_0 = doraTools[_index_0] -- 1676
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1676
										local displayName -- 1677
										if repo then -- 1677
											if zh then -- 1678
												displayName = repo.title.zh -- 1678
											else -- 1678
												displayName = repo.title.en -- 1678
											end -- 1678
										end -- 1677
										if displayName == nil then -- 1679
											displayName = entryName -- 1679
										end -- 1679
										if allEntries.match(displayName) then -- 1680
											showTool = true -- 1680
											break -- 1680
										end -- 1680
									end -- 1676
									if not showTool then -- 1681
										goto endEntry -- 1681
									end -- 1681
									Columns(1, false) -- 1682
									TextColored(themeColor, "Dora SSR:") -- 1683
									SameLine() -- 1684
									Text(zh and "开发支持" or "Development Support") -- 1685
									Separator() -- 1686
									if #doraTools > 0 then -- 1687
										local opened -- 1688
										if (filterText ~= nil) then -- 1688
											opened = showTool -- 1688
										else -- 1688
											opened = false -- 1688
										end -- 1688
										SetNextItemOpen(toolOpen) -- 1689
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1690
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1691
												Columns(maxColumns, false) -- 1692
												for _index_0 = 1, #doraTools do -- 1693
													local tool = doraTools[_index_0] -- 1693
													local entryName, repo = tool.entryName, tool.repo -- 1694
													local displayName -- 1695
													if repo then -- 1695
														if zh then -- 1696
															displayName = repo.title.zh -- 1696
														else -- 1696
															displayName = repo.title.en -- 1696
														end -- 1696
													end -- 1695
													if displayName == nil then -- 1697
														displayName = entryName -- 1697
													end -- 1697
													if not allEntries.match(displayName) then -- 1698
														goto _continue_0 -- 1698
													end -- 1698
													if Button(displayName, Vec2(-1, 40)) then -- 1699
														enterDemoEntry(tool) -- 1700
													end -- 1699
													NextColumn() -- 1701
													::_continue_0:: -- 1694
												end -- 1693
												Columns(1, false) -- 1702
												opened = true -- 1703
											end) -- 1691
										end) -- 1690
										toolOpen = opened -- 1704
									end -- 1687
								end -- 1674
								::endEntry:: -- 1705
								if not allEntries.anyEntryMatched then -- 1706
									SetNextWindowBgAlpha(0) -- 1707
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1708
									Begin("Entries Not Found", displayWindowFlags, function() -- 1709
										Separator() -- 1710
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1711
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1712
										return Separator() -- 1713
									end) -- 1709
								end -- 1706
								Columns(1, false) -- 1714
								Dummy(Vec2(100, 80)) -- 1715
								return ScrollWhenDraggingOnVoid() -- 1716
							end) -- 1562
						end) -- 1561
					end) -- 1560
				end) -- 1559
			end) -- 1558
		end -- 1557
	end) -- 1463
end -- 1451
if not (App.platform == "Emscripten") then -- 1721
	local sceneModuleCache = moduleCache -- 1722
	moduleCache = { } -- 1723
	webStatus = oldRequire("Script.Dev.WebServer") -- 1724
	moduleCache = sceneModuleCache -- 1725
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1726
		thread(function() -- 1727
			wait(function() -- 1728
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1728
			end) -- 1728
			if App.webIDEEnabled then -- 1729
				return emit("AppWebView", "/ide/show", true) -- 1729
			end -- 1729
		end) -- 1727
	end -- 1726
end -- 1721
local _anon_func_7 = function(saved) -- 1752
	local _val_0 = saved.kind -- 1752
	return "local" == _val_0 or "discover" == _val_0 -- 1752
end -- 1752
local _anon_func_8 = function(saved) -- 1756
	local _val_0 = saved.activeTab -- 1756
	return "local" == _val_0 or "discover" == _val_0 -- 1756
end -- 1756
startMobileUI = function() -- 1731
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1732
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1733
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1734
	local getMobileFeedResources -- 1735
	do -- 1735
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1735
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1735
	end -- 1735
	local loadCachedCatalog -- 1736
	do -- 1736
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1736
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1736
	end -- 1736
	local getResourceInstallPath, getInstalledCatalogResource -- 1737
	do -- 1737
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1737
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1737
	end -- 1737
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1738
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1739
	local feedOptions = nil -- 1740
	local mobileLaunchErrors = { } -- 1741
	local withMobileLaunchErrors -- 1742
	withMobileLaunchErrors = function(items) -- 1742
		for _index_0 = 1, #items do -- 1743
			local item = items[_index_0] -- 1743
			item.launchError = mobileLaunchErrors[item.id] -- 1744
		end -- 1743
		return items -- 1745
	end -- 1742
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1746
	local loadRememberedMobileFeedState -- 1747
	loadRememberedMobileFeedState = function() -- 1747
		local raw = rememberedMobileFeedData -- 1748
		if not (type(raw) == "string" and raw ~= "") then -- 1749
			return -- 1749
		end -- 1749
		local ok, saved = pcall(json.decode, raw) -- 1750
		if not (ok and type(saved) == "table") then -- 1751
			return -- 1751
		end -- 1751
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1752
			local state = { -- 1753
				activeTab = saved.kind -- 1753
			} -- 1753
			state[saved.kind] = saved -- 1754
			return state -- 1755
		end -- 1752
		local state = { -- 1756
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1756
		} -- 1756
		local _list_0 = { -- 1757
			"local", -- 1757
			"discover" -- 1757
		} -- 1757
		for _index_0 = 1, #_list_0 do -- 1757
			local kind = _list_0[_index_0] -- 1757
			local entry = saved[kind] -- 1758
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1759
				state[kind] = entry -- 1759
			end -- 1759
		end -- 1757
		return state -- 1760
	end -- 1747
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1761
		activeTab = "local" -- 1761
	} -- 1761
	local rememberMobileFeedEntry -- 1762
	rememberMobileFeedEntry = function(entry) -- 1762
		rememberedMobileFeedState.activeTab = entry.kind -- 1763
		rememberedMobileFeedState[entry.kind] = { -- 1765
			id = entry.id, -- 1765
			kind = entry.kind, -- 1766
			workDir = entry.workDir, -- 1767
			fileName = entry.fileName -- 1768
		} -- 1764
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1770
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1771
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1772
			rememberedMobileFeedData -- 1772
		}) -- 1772
	end -- 1762
	local restartMobileFeed -- 1773
	restartMobileFeed = function(entry) -- 1773
		if feedHost then -- 1774
			feedHost:removeFromParent(true) -- 1774
		end -- 1774
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1775
		local initialEntries = { } -- 1776
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1777
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1778
		feedOptions.initialEntries = initialEntries -- 1779
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1780
	end -- 1773
	local startMobilePlay -- 1781
	startMobilePlay = function(entry) -- 1781
		if HttpServer.wsConnectionCount > 0 then -- 1782
			return -- 1782
		end -- 1782
		local originFeed = feedHost -- 1783
		if remixHost then -- 1784
			remixHost:removeFromParent(true) -- 1784
		end -- 1784
		remixHost = nil -- 1785
		mobileLaunchErrors[entry.id] = nil -- 1786
		entry.launchError = nil -- 1787
		local playActive = true -- 1788
		local restoreMobileFeed -- 1789
		restoreMobileFeed = function() -- 1789
			if not playActive then -- 1790
				return -- 1790
			end -- 1790
			playActive = false -- 1791
			allClear() -- 1792
			isInEntry = true -- 1793
			currentEntry = nil -- 1794
			return restartMobileFeed(entry) -- 1795
		end -- 1789
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1797
			onExit = function() -- 1797
				return restoreMobileFeed() -- 1797
			end, -- 1797
			onRuntimeError = function() -- 1798
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1799
				return restoreMobileFeed() -- 1800
			end -- 1798
		})) -- 1796
		return thread(function() -- 1802
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1806
			if not playActive then -- 1807
				return -- 1807
			end -- 1807
			if success then -- 1808
				if originFeed and originFeed.parent then -- 1809
					originFeed.visible = false -- 1809
				end -- 1809
				return -- 1810
			end -- 1808
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1811
			return restoreMobileFeed() -- 1812
		end) -- 1802
	end -- 1781
	feedOptions = { -- 1814
		takeReceivedFile = function() -- 1814
			if allEntries.pendingPackagePath then -- 1815
				local path = allEntries.pendingPackagePath -- 1816
				allEntries.pendingPackagePath = nil -- 1817
				return path -- 1818
			end -- 1815
			return App:takeReceivedFile() -- 1819
		end, -- 1814
		onSwitchMode = function() -- 1820
			if HttpServer.wsConnectionCount == 0 then -- 1820
				pendingUIMode = false -- 1820
			end -- 1820
		end, -- 1820
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1821
		getLocalEntries = function(importedProjectPath) -- 1822
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1823
			feedOptions.dirtyProjectPath = nil -- 1824
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1825
			local cached = loadCachedCatalog() -- 1826
			if cached.success and cached.snapshot then -- 1827
				for _index_0 = 1, #items do -- 1828
					local entry = items[_index_0] -- 1828
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1829
					if resource then -- 1830
						entry.resource = resource -- 1831
						entry.catalogCommit = cached.snapshot.commit -- 1832
					end -- 1830
				end -- 1828
			end -- 1827
			return items -- 1833
		end, -- 1822
		syncDiscover = function(onProgress, onDone, force) -- 1834
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1834
		end, -- 1834
		getDiscoverEntries = function() -- 1835
			local cached = loadCachedCatalog() -- 1836
			if not (cached.success and cached.snapshot) then -- 1837
				return { } -- 1837
			end -- 1837
			local items = { } -- 1838
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1839
			for _index_0 = 1, #_list_0 do -- 1839
				local resource = _list_0[_index_0] -- 1839
				local installed = lifecycle.isMobileResourceReady(resource) -- 1840
				local installPath = getResourceInstallPath(resource.id) -- 1841
				items[#items + 1] = { -- 1843
					id = resource.id, -- 1843
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1844
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1845
					kind = "discover", -- 1846
					bannerFile = resource.bannerPath, -- 1847
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1848
					sourceUrl = resource.versions[1].sources[1].url, -- 1849
					workDir = installed and installPath or nil, -- 1850
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1851
					installed = installed, -- 1852
					resource = resource, -- 1853
					catalogCommit = cached.snapshot.commit, -- 1854
					launchError = mobileLaunchErrors[resource.id] -- 1855
				} -- 1842
			end -- 1839
			return items -- 1857
		end, -- 1835
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1858
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1859
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1860
			end), repairIncomplete, isCanceled) -- 1859
		end, -- 1858
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1862
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1863
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1864
			end), isCanceled) -- 1863
		end, -- 1862
		createProject = function(name, language) -- 1866
			local result = projectCreate.createMobileProject(name, language) -- 1867
			if not result.success then -- 1868
				return result -- 1868
			end -- 1868
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1869
			for _index_0 = 1, #_list_0 do -- 1869
				local entry = _list_0[_index_0] -- 1869
				if entry.workDir == result.workDir then -- 1870
					return { -- 1871
						success = true, -- 1871
						entry = entry -- 1871
					} -- 1871
				end -- 1870
			end -- 1869
			return { -- 1872
				success = false, -- 1872
				error = "created-project-not-found" -- 1872
			} -- 1872
		end, -- 1866
		onPlay = function(entry) -- 1873
			return startMobilePlay(entry) -- 1873
		end, -- 1873
		onRemix = function(entry) -- 1874
			if HttpServer.wsConnectionCount > 0 then -- 1875
				return -- 1875
			end -- 1875
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1876
			local originFeed = feedHost -- 1877
			feedHost.visible = false -- 1878
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1880
				entry = entry, -- 1880
				onProjectChanged = function(current) -- 1881
					feedOptions.dirtyProjectPath = current.workDir -- 1881
				end, -- 1881
				onBack = function() -- 1882
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1883
						originFeed:emit("RestoreFeedEntry", entry) -- 1884
						originFeed.visible = true -- 1885
					end -- 1883
				end, -- 1882
				onPlay = function(current) -- 1886
					return startMobilePlay(current) -- 1886
				end -- 1886
			})) -- 1879
		end -- 1874
	} -- 1813
	return restartMobileFeed() -- 1889
end -- 1731
if mobileMode then -- 1891
	applyUIMode(true) -- 1891
end -- 1891
return _module_0 -- 1
