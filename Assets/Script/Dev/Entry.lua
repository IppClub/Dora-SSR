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
local _anon_func_1 = function(source) -- 313
	local _val_0 = Path:getExt(source):lower() -- 313
	return "ts" == _val_0 or "tsx" == _val_0 -- 313
end -- 313
allEntries.scanDir = function(path, dir, noPreview) -- 303
	if noPreview == nil then -- 303
		noPreview = false -- 303
	end -- 303
	local entries = { } -- 304
	if not dir:match("^%.") then -- 305
		local root = Path(path, dir) -- 306
		local files = getAllFiles(root, { -- 307
			"lua", -- 307
			"xml", -- 307
			yueext, -- 307
			"tl", -- 307
			"wasm" -- 307
		}) -- 307
		local atomPie = Content:exist(Path(root, ".git", "dora-atompie-id")) -- 308
		local sourceOnly = nil -- 309
		if atomPie then -- 310
			local project = oldRequire("Script.Dev.AtomPieProject") -- 311
			local source = project.entryAt(root) -- 312
			if source then -- 312
				if _anon_func_1(source) then -- 313
					local stem = Path:replaceExt(source, "") -- 314
					local compiled -- 315
					for _index_0 = 1, #files do -- 315
						local file = files[_index_0] -- 315
						if Path:replaceExt(file, "") == stem then -- 316
							compiled = true -- 316
							break -- 316
						end -- 316
					end -- 315
					if not compiled then -- 317
						sourceOnly = source -- 318
						files[#files + 1] = source -- 319
					end -- 317
				end -- 313
			end -- 312
		end -- 310
		for _index_0 = 1, #files do -- 320
			local file = files[_index_0] -- 320
			if "init" == Path:getName(file):lower() then -- 321
				local fileName = Path:replaceExt(file, "") -- 322
				fileName = Path(path, dir, fileName) -- 323
				local projectPath = Path:getPath(fileName) -- 324
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 325
				local repo = nil -- 326
				if Content:exist(repoFile) then -- 327
					local str = Content:load(repoFile) -- 328
					if str then -- 328
						repo = json.decode(str) -- 329
					end -- 328
				end -- 327
				local entryName = Path:getName(projectPath) -- 330
				local entryAdded -- 331
				for _index_1 = 1, #entries do -- 331
					local _des_0 = entries[_index_1] -- 331
					local ename, efile = _des_0.entryName, _des_0.fileName -- 331
					if entryName == ename and efile == fileName then -- 332
						entryAdded = true -- 332
						break -- 332
					end -- 332
				end -- 331
				if entryAdded then -- 333
					goto _continue_0 -- 333
				end -- 333
				local examples = { } -- 334
				local tests = { } -- 335
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 336
				if Content:exist(examplePath) then -- 337
					local _list_0 = getFileEntries(examplePath) -- 338
					for _index_1 = 1, #_list_0 do -- 338
						local _des_0 = _list_0[_index_1] -- 338
						local name, ePath = _des_0.entryName, _des_0.fileName -- 338
						local entry = { -- 340
							entryName = name, -- 340
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 341
							workDir = projectPath -- 342
						} -- 339
						examples[#examples + 1] = entry -- 344
					end -- 338
				end -- 337
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 345
				if Content:exist(testPath) then -- 346
					local _list_0 = getFileEntries(testPath) -- 347
					for _index_1 = 1, #_list_0 do -- 347
						local _des_0 = _list_0[_index_1] -- 347
						local name, tPath = _des_0.entryName, _des_0.fileName -- 347
						local entry = { -- 349
							entryName = name, -- 349
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 350
							workDir = projectPath -- 351
						} -- 348
						tests[#tests + 1] = entry -- 353
					end -- 347
				end -- 346
				local entry = { -- 354
					entryName = entryName, -- 354
					fileName = fileName, -- 354
					projectPath = projectPath, -- 354
					examples = examples, -- 354
					tests = tests, -- 354
					repo = repo, -- 354
					atomPie = atomPie, -- 354
					needsBuild = file == sourceOnly -- 354
				} -- 354
				local bannerFile -- 355
				do -- 355
					local _val_0 -- 355
					repeat -- 355
						if noPreview then -- 356
							_val_0 = nil -- 356
							break -- 356
						end -- 356
						if not config.showPreview then -- 357
							_val_0 = nil -- 357
							break -- 357
						end -- 357
						local f = Path(projectPath, ".dora", "banner.jpg") -- 358
						if Content:exist(f) then -- 359
							_val_0 = f -- 359
							break -- 359
						end -- 359
						f = Path(projectPath, ".dora", "banner.png") -- 360
						if Content:exist(f) then -- 361
							_val_0 = f -- 361
							break -- 361
						end -- 361
						f = Path(projectPath, "Image", "banner.jpg") -- 362
						if Content:exist(f) then -- 363
							_val_0 = f -- 363
							break -- 363
						end -- 363
						f = Path(projectPath, "Image", "banner.png") -- 364
						if Content:exist(f) then -- 365
							_val_0 = f -- 365
							break -- 365
						end -- 365
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 366
						if Content:exist(f) then -- 367
							_val_0 = f -- 367
							break -- 367
						end -- 367
					until true -- 355
					bannerFile = _val_0 -- 355
				end -- 355
				if bannerFile then -- 369
					entry.bannerFile = bannerFile -- 372
					thread(function() -- 373
						if Cache:loadAsync(bannerFile) then -- 374
							local bannerTex = Texture2D(bannerFile) -- 375
							if bannerTex then -- 375
								entry.bannerTex = bannerTex -- 376
							end -- 375
						end -- 374
					end) -- 373
				end -- 369
				entries[#entries + 1] = entry -- 377
			end -- 321
			::_continue_0:: -- 321
		end -- 320
	end -- 305
	return entries -- 378
end -- 303
local getProjectEntries -- 380
getProjectEntries = function(path, noPreview) -- 380
	if noPreview == nil then -- 380
		noPreview = false -- 380
	end -- 380
	local entries = { } -- 381
	local _list_0 = Content:getDirs(path) -- 382
	for _index_0 = 1, #_list_0 do -- 382
		local dir = _list_0[_index_0] -- 382
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 383
		for _index_1 = 1, #_list_1 do -- 383
			local entry = _list_1[_index_1] -- 383
			entries[#entries + 1] = entry -- 384
		end -- 383
	end -- 382
	table.sort(entries, function(a, b) -- 385
		return a.entryName < b.entryName -- 385
	end) -- 385
	return entries -- 386
end -- 380
_module_0["getProjectEntries"] = getProjectEntries -- 380
local gamesInDev -- 388
local doraTools -- 389
local isToolEntry -- 391
isToolEntry = function(entry) -- 391
	do -- 392
		local _type_0 = type(entry) -- 392
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 392
		if _tab_0 then -- 392
			local categories -- 392
			do -- 392
				local _obj_0 = entry.repo -- 392
				local _type_1 = type(_obj_0) -- 392
				if "table" == _type_1 or "userdata" == _type_1 then -- 392
					categories = _obj_0.categories -- 392
				end -- 392
			end -- 392
			if categories ~= nil then -- 392
				for _index_0 = 1, #categories do -- 393
					local category = categories[_index_0] -- 393
					if "string" == type(category) and category:lower() == "tool" then -- 394
						return true -- 395
					end -- 394
				end -- 393
			end -- 392
		end -- 392
	end -- 392
	return false -- 391
end -- 391
local getEntryTitle -- 397
getEntryTitle = function(entry) -- 397
	local title -- 398
	do -- 398
		local repo = entry.repo -- 398
		if repo then -- 398
			if repo.title and "table" == type(repo.title) then -- 399
				if useChinese then -- 400
					title = repo.title.zh -- 400
				else -- 400
					title = repo.title.en -- 400
				end -- 400
			end -- 399
		end -- 398
	end -- 398
	if title ~= nil then -- 401
		return title -- 401
	else -- 401
		return entry.entryName -- 401
	end -- 401
end -- 397
allEntries.rebuildEntries = function() -- 403
	gamesInDev = { } -- 404
	do -- 405
		local _accum_0 = { } -- 405
		local _len_0 = 1 -- 405
		local _list_0 = allEntries.builtinTools -- 405
		for _index_0 = 1, #_list_0 do -- 405
			local tool = _list_0[_index_0] -- 405
			_accum_0[_len_0] = tool -- 405
			_len_0 = _len_0 + 1 -- 405
		end -- 405
		doraTools = _accum_0 -- 405
	end -- 405
	local _list_0 = allEntries.projectEntries -- 406
	for _index_0 = 1, #_list_0 do -- 406
		local entry = _list_0[_index_0] -- 406
		if not entry.atomPie and isToolEntry(entry) then -- 407
			entry.kind = "tool" -- 408
			doraTools[#doraTools + 1] = entry -- 409
		else -- 411
			entry.kind = "game" -- 411
			gamesInDev[#gamesInDev + 1] = entry -- 412
		end -- 407
	end -- 406
	for i = #allEntries, 1, -1 do -- 413
		allEntries[i] = nil -- 414
	end -- 413
	for _index_0 = 1, #gamesInDev do -- 415
		local game = gamesInDev[_index_0] -- 415
		allEntries[#allEntries + 1] = game -- 416
		local examples, tests = game.examples, game.tests -- 417
		for _index_1 = 1, #examples do -- 418
			local example = examples[_index_1] -- 418
			allEntries[#allEntries + 1] = example -- 419
		end -- 418
		for _index_1 = 1, #tests do -- 420
			local test = tests[_index_1] -- 420
			allEntries[#allEntries + 1] = test -- 421
		end -- 420
	end -- 415
end -- 403
local updateEntries -- 423
updateEntries = function() -- 423
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 424
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 425
	local _list_0 = allEntries.builtinTools -- 426
	for _index_0 = 1, #_list_0 do -- 426
		local tool = _list_0[_index_0] -- 426
		tool.kind = "tool" -- 427
		tool.builtin = true -- 428
	end -- 426
	return allEntries.rebuildEntries() -- 429
end -- 423
allEntries.refreshDirtyProjects = function() -- 431
	if not allEntries.hasDirty then -- 432
		return -- 432
	end -- 432
	local dirty = allEntries.dirty -- 433
	allEntries.dirty = { } -- 434
	allEntries.hasDirty = false -- 435
	for projectPath in pairs(dirty) do -- 436
		do -- 437
			local _accum_0 = { } -- 437
			local _len_0 = 1 -- 437
			local _list_0 = allEntries.projectEntries -- 437
			for _index_0 = 1, #_list_0 do -- 437
				local entry = _list_0[_index_0] -- 437
				if entry.projectPath ~= projectPath then -- 437
					_accum_0[_len_0] = entry -- 437
					_len_0 = _len_0 + 1 -- 437
				end -- 437
			end -- 437
			allEntries.projectEntries = _accum_0 -- 437
		end -- 437
		local parentPath = Path:getPath(projectPath) -- 438
		local dir = Path:getFilename(projectPath) -- 439
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 440
		for _index_0 = 1, #_list_0 do -- 440
			local entry = _list_0[_index_0] -- 440
			if entry.projectPath == projectPath then -- 441
				do -- 442
					local _obj_0 = allEntries.projectEntries -- 442
					_obj_0[#_obj_0 + 1] = entry -- 442
				end -- 442
				break -- 443
			end -- 441
		end -- 440
	end -- 436
	table.sort(allEntries.projectEntries, function(a, b) -- 444
		return a.entryName < b.entryName -- 444
	end) -- 444
	return allEntries.rebuildEntries() -- 445
end -- 431
updateEntries() -- 447
local getLaunchEntries -- 449
getLaunchEntries = function(refresh) -- 449
	if refresh == nil then -- 449
		refresh = false -- 449
	end -- 449
	if refresh then -- 450
		updateEntries() -- 450
	end -- 450
	local toInfo -- 451
	toInfo = function(entry, kind) -- 451
		local file = entry.fileName -- 452
		local asProj = not entry.builtin -- 453
		return { -- 455
			name = getEntryTitle(entry), -- 455
			file = file, -- 456
			kind = kind, -- 457
			asProj = asProj -- 458
		} -- 454
	end -- 451
	local games -- 460
	do -- 460
		local _accum_0 = { } -- 460
		local _len_0 = 1 -- 460
		for _index_0 = 1, #gamesInDev do -- 460
			local game = gamesInDev[_index_0] -- 460
			_accum_0[_len_0] = toInfo(game, "game") -- 460
			_len_0 = _len_0 + 1 -- 460
		end -- 460
		games = _accum_0 -- 460
	end -- 460
	local tools -- 461
	do -- 461
		local _accum_0 = { } -- 461
		local _len_0 = 1 -- 461
		for _index_0 = 1, #doraTools do -- 461
			local tool = doraTools[_index_0] -- 461
			_accum_0[_len_0] = toInfo(tool, "tool") -- 461
			_len_0 = _len_0 + 1 -- 461
		end -- 461
		tools = _accum_0 -- 461
	end -- 461
	return { -- 462
		games = games, -- 462
		tools = tools -- 462
	} -- 462
end -- 449
_module_0["getLaunchEntries"] = getLaunchEntries -- 449
local _anon_func_2 = function(entry, useChinese) -- 479
	local _obj_0 = entry.repo -- 479
	if _obj_0 ~= nil then -- 479
		local _obj_1 = _obj_0.description -- 479
		if _obj_1 ~= nil then -- 479
			return _obj_1[useChinese and "zh" or "en"] -- 479
		end -- 479
		return nil -- 479
	end -- 479
	return nil -- 479
end -- 479
local getMobileFeedEntries -- 464
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 464
	if refresh == nil then -- 464
		refresh = false -- 464
	end -- 464
	if dirtyProjectPath == nil then -- 464
		dirtyProjectPath = nil -- 464
	end -- 464
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 465
		allEntries.dirty[dirtyProjectPath] = true -- 466
		allEntries.hasDirty = true -- 467
	end -- 465
	if refresh then -- 468
		allEntries.dirty = { } -- 469
		allEntries.hasDirty = false -- 470
		updateEntries() -- 471
	else -- 473
		allEntries.refreshDirtyProjects() -- 473
	end -- 468
	local items = { } -- 474
	for _index_0 = 1, #gamesInDev do -- 475
		local entry = gamesInDev[_index_0] -- 475
		items[#items + 1] = { -- 477
			id = entry.entryName, -- 477
			title = getEntryTitle(entry), -- 478
			description = _anon_func_2(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 479
			fileName = entry.fileName, -- 480
			workDir = Path:getPath(entry.fileName), -- 481
			bannerFile = entry.bannerFile, -- 482
			needsBuild = entry.needsBuild, -- 483
			kind = "local" -- 484
		} -- 476
	end -- 475
	return items -- 486
end -- 464
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 464
local doCompile -- 488
doCompile = function(minify) -- 488
	if building then -- 489
		return -- 489
	end -- 489
	building = true -- 490
	local startTime = App.runningTime -- 491
	local luaFiles = { } -- 492
	local yueFiles = { } -- 493
	local xmlFiles = { } -- 494
	local tlFiles = { } -- 495
	local writablePath = Content.writablePath -- 496
	local buildPaths = { -- 498
		{ -- 499
			Content.assetPath, -- 499
			Path(writablePath, ".build"), -- 500
			"" -- 501
		} -- 498
	} -- 497
	for _index_0 = 1, #gamesInDev do -- 504
		local _des_0 = gamesInDev[_index_0] -- 504
		local fileName = _des_0.fileName -- 504
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 505
		buildPaths[#buildPaths + 1] = { -- 507
			Path(writablePath, gamePath), -- 507
			Path(writablePath, ".build", gamePath), -- 508
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 509
			gamePath -- 510
		} -- 506
	end -- 504
	for _index_0 = 1, #buildPaths do -- 511
		local _des_0 = buildPaths[_index_0] -- 511
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 511
		if not Content:exist(inputPath) then -- 512
			goto _continue_0 -- 512
		end -- 512
		local _list_0 = getAllFiles(inputPath, { -- 514
			"lua" -- 514
		}) -- 514
		for _index_1 = 1, #_list_0 do -- 514
			local file = _list_0[_index_1] -- 514
			luaFiles[#luaFiles + 1] = { -- 516
				file, -- 516
				Path(inputPath, file), -- 517
				Path(outputPath, file), -- 518
				gamePath -- 519
			} -- 515
		end -- 514
		local _list_1 = getAllFiles(inputPath, { -- 521
			yueext -- 521
		}) -- 521
		for _index_1 = 1, #_list_1 do -- 521
			local file = _list_1[_index_1] -- 521
			yueFiles[#yueFiles + 1] = { -- 523
				file, -- 523
				Path(inputPath, file), -- 524
				Path(outputPath, Path:replaceExt(file, "lua")), -- 525
				searchPath, -- 526
				gamePath -- 527
			} -- 522
		end -- 521
		local _list_2 = getAllFiles(inputPath, { -- 529
			"xml" -- 529
		}) -- 529
		for _index_1 = 1, #_list_2 do -- 529
			local file = _list_2[_index_1] -- 529
			xmlFiles[#xmlFiles + 1] = { -- 531
				file, -- 531
				Path(inputPath, file), -- 532
				Path(outputPath, Path:replaceExt(file, "lua")), -- 533
				gamePath -- 534
			} -- 530
		end -- 529
		local _list_3 = getAllFiles(inputPath, { -- 536
			"tl" -- 536
		}) -- 536
		for _index_1 = 1, #_list_3 do -- 536
			local file = _list_3[_index_1] -- 536
			if not file:match(".*%.d%.tl$") then -- 537
				tlFiles[#tlFiles + 1] = { -- 539
					file, -- 539
					Path(inputPath, file), -- 540
					Path(outputPath, Path:replaceExt(file, "lua")), -- 541
					searchPath, -- 542
					gamePath -- 543
				} -- 538
			end -- 537
		end -- 536
		::_continue_0:: -- 512
	end -- 511
	local paths -- 545
	do -- 545
		local _tbl_0 = { } -- 545
		local _list_0 = { -- 546
			luaFiles, -- 546
			yueFiles, -- 546
			xmlFiles, -- 546
			tlFiles -- 546
		} -- 546
		for _index_0 = 1, #_list_0 do -- 546
			local files = _list_0[_index_0] -- 546
			for _index_1 = 1, #files do -- 547
				local file = files[_index_1] -- 547
				_tbl_0[Path:getPath(file[3])] = true -- 545
			end -- 545
		end -- 545
		paths = _tbl_0 -- 545
	end -- 545
	for path in pairs(paths) do -- 549
		Content:mkdir(path) -- 549
	end -- 549
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 551
	local fileCount = 0 -- 552
	local errors = { } -- 553
	for _index_0 = 1, #yueFiles do -- 554
		local _des_0 = yueFiles[_index_0] -- 554
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 554
		local filename -- 555
		if gamePath then -- 555
			filename = Path(gamePath, file) -- 555
		else -- 555
			filename = file -- 555
		end -- 555
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 556
			if not codes then -- 557
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 558
				return -- 559
			end -- 557
			local success, result = LintYueGlobals(codes, globals) -- 560
			local yueCodes -- 561
			if not success then -- 562
				yueCodes = Content:load(input) -- 563
				if yueCodes then -- 563
					local CheckTIC80Code -- 564
					do -- 564
						local _obj_0 = require("Utils") -- 564
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 564
					end -- 564
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 565
					if isTIC80 then -- 566
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 567
					end -- 566
				end -- 563
			end -- 562
			if success then -- 568
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 569
			else -- 571
				if yueCodes then -- 571
					local globalErrors = { } -- 572
					for _index_1 = 1, #result do -- 573
						local _des_1 = result[_index_1] -- 573
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 573
						local countLine = 1 -- 574
						local code = "" -- 575
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 576
							if countLine == line then -- 577
								code = lineCode -- 578
								break -- 579
							end -- 577
							countLine = countLine + 1 -- 580
						end -- 576
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 581
					end -- 573
					if #globalErrors > 0 then -- 582
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 582
					end -- 582
				else -- 584
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 584
				end -- 571
				if #errors == 0 then -- 585
					return codes -- 585
				end -- 585
			end -- 568
		end, function(success) -- 556
			if success then -- 586
				print("Yue compiled: " .. tostring(filename)) -- 586
			end -- 586
			fileCount = fileCount + 1 -- 587
		end) -- 556
	end -- 554
	thread(function() -- 589
		for _index_0 = 1, #xmlFiles do -- 590
			local _des_0 = xmlFiles[_index_0] -- 590
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 590
			local filename -- 591
			if gamePath then -- 591
				filename = Path(gamePath, file) -- 591
			else -- 591
				filename = file -- 591
			end -- 591
			local sourceCodes = Content:loadAsync(input) -- 592
			local codes, err = xml.tolua(sourceCodes) -- 593
			if not codes then -- 594
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 595
			else -- 597
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 597
				print("Xml compiled: " .. tostring(filename)) -- 598
			end -- 594
			fileCount = fileCount + 1 -- 599
		end -- 590
	end) -- 589
	thread(function() -- 601
		for _index_0 = 1, #tlFiles do -- 602
			local _des_0 = tlFiles[_index_0] -- 602
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 602
			local filename -- 603
			if gamePath then -- 603
				filename = Path(gamePath, file) -- 603
			else -- 603
				filename = file -- 603
			end -- 603
			local sourceCodes = Content:loadAsync(input) -- 604
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 605
			if not codes then -- 606
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 607
			else -- 609
				Content:saveAsync(output, codes) -- 609
				print("Teal compiled: " .. tostring(filename)) -- 610
			end -- 606
			fileCount = fileCount + 1 -- 611
		end -- 602
	end) -- 601
	return thread(function() -- 613
		wait(function() -- 614
			return fileCount == totalFiles -- 614
		end) -- 614
		if minify then -- 615
			local _list_0 = { -- 616
				yueFiles, -- 616
				xmlFiles, -- 616
				tlFiles -- 616
			} -- 616
			for _index_0 = 1, #_list_0 do -- 616
				local files = _list_0[_index_0] -- 616
				for _index_1 = 1, #files do -- 616
					local file = files[_index_1] -- 616
					local output = Path:replaceExt(file[3], "lua") -- 617
					luaFiles[#luaFiles + 1] = { -- 619
						Path:replaceExt(file[1], "lua"), -- 619
						output, -- 620
						output -- 621
					} -- 618
				end -- 616
			end -- 616
			local FormatMini -- 623
			do -- 623
				local _obj_0 = require("luaminify") -- 623
				FormatMini = _obj_0.FormatMini -- 623
			end -- 623
			for _index_0 = 1, #luaFiles do -- 624
				local _des_0 = luaFiles[_index_0] -- 624
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 624
				if Content:exist(input) then -- 625
					local sourceCodes = Content:loadAsync(input) -- 626
					local res, err = FormatMini(sourceCodes) -- 627
					if res then -- 628
						Content:saveAsync(output, res) -- 629
						print("Minify: " .. tostring(file)) -- 630
					else -- 632
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 632
					end -- 628
				else -- 634
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 634
				end -- 625
			end -- 624
			package.loaded["luaminify.FormatMini"] = nil -- 635
			package.loaded["luaminify.ParseLua"] = nil -- 636
			package.loaded["luaminify.Scope"] = nil -- 637
			package.loaded["luaminify.Util"] = nil -- 638
		end -- 615
		local errorMessage = table.concat(errors, "\n") -- 639
		if errorMessage ~= "" then -- 640
			print(errorMessage) -- 640
		end -- 640
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 641
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 642
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 643
		Content:clearPathCache() -- 644
		teal.clear() -- 645
		yue.clear() -- 646
		building = false -- 647
	end) -- 613
end -- 488
local doClean -- 649
doClean = function() -- 649
	if building then -- 650
		return -- 650
	end -- 650
	local writablePath = Content.writablePath -- 651
	local targetDir = Path(writablePath, ".build") -- 652
	Content:clearPathCache() -- 653
	if Content:remove(targetDir) then -- 654
		return print("Cleaned: " .. tostring(targetDir)) -- 655
	end -- 654
end -- 649
local screenScale = 2.0 -- 657
local scaleContent = false -- 658
local isInEntry = true -- 659
local currentEntry = nil -- 660
local footerWindow = nil -- 662
local entryWindow = nil -- 663
local testingThread = nil -- 664
local mobileMode = config.mobileFeed -- 665
local pendingUIMode = nil -- 666
local feedHost = nil -- 667
local remixHost = nil -- 668
local startMobileUI = nil -- 669
local webControlled = false -- 670
local mobileHosts = { } -- 671
local suspendedMobileHosts = { } -- 672
local trackMobileHost -- 674
trackMobileHost = function(host) -- 674
	do -- 675
		local _accum_0 = { } -- 675
		local _len_0 = 1 -- 675
		for _index_0 = 1, #mobileHosts do -- 675
			local item = mobileHosts[_index_0] -- 675
			if item.parent then -- 675
				_accum_0[_len_0] = item -- 675
				_len_0 = _len_0 + 1 -- 675
			end -- 675
		end -- 675
		mobileHosts = _accum_0 -- 675
	end -- 675
	mobileHosts[#mobileHosts + 1] = host -- 676
	return host -- 677
end -- 674
local clearMobileUI -- 679
clearMobileUI = function() -- 679
	for _index_0 = 1, #mobileHosts do -- 680
		local host = mobileHosts[_index_0] -- 680
		if host.parent then -- 681
			host:removeFromParent(true) -- 681
		end -- 681
	end -- 680
	mobileHosts = { } -- 682
	suspendedMobileHosts = { } -- 683
	feedHost = nil -- 684
	remixHost = nil -- 685
end -- 679
local syncWebIDEControl -- 687
syncWebIDEControl = function() -- 687
	local connected = HttpServer.wsConnectionCount > 0 -- 688
	if connected then -- 689
		pendingUIMode = nil -- 690
		for _index_0 = 1, #mobileHosts do -- 691
			local host = mobileHosts[_index_0] -- 691
			if not host.parent then -- 692
				goto _continue_0 -- 692
			end -- 692
			if not (suspendedMobileHosts[host] ~= nil) then -- 693
				suspendedMobileHosts[host] = host.visible -- 694
				host:emit("SuspendLocalUI") -- 695
			end -- 693
			host.visible = false -- 696
			::_continue_0:: -- 692
		end -- 691
	elseif webControlled then -- 697
		for host, visible in pairs(suspendedMobileHosts) do -- 698
			if host.parent then -- 699
				host.visible = visible -- 700
				host:emit("ResumeLocalUI") -- 701
			end -- 699
		end -- 698
		suspendedMobileHosts = { } -- 702
	end -- 689
	webControlled = connected -- 703
	return connected -- 704
end -- 687
local getUIMode -- 706
getUIMode = function() -- 706
	return mobileMode and "mobile" or "traditional" -- 706
end -- 706
_module_0["getUIMode"] = getUIMode -- 706
local setUIMode -- 707
setUIMode = function(mode) -- 707
	if not (("mobile" == mode or "traditional" == mode)) then -- 708
		return false -- 708
	end -- 708
	if HttpServer.wsConnectionCount > 0 then -- 709
		return false -- 709
	end -- 709
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 710
		return false -- 710
	end -- 710
	local wantsMobile = mode == "mobile" -- 711
	if wantsMobile == mobileMode then -- 712
		return true -- 712
	end -- 712
	if mobileMode then -- 713
		if not (feedHost and feedHost.visible) then -- 714
			return false -- 714
		end -- 714
		feedHost:emit("SwitchUIMode") -- 716
		return pendingUIMode == false -- 717
	end -- 713
	pendingUIMode = true -- 718
	return true -- 719
end -- 707
_module_0["setUIMode"] = setUIMode -- 707
local applyUIMode -- 721
applyUIMode = function(enabled) -- 721
	if HttpServer.wsConnectionCount > 0 then -- 723
		return false -- 723
	end -- 723
	if enabled then -- 724
		local ok, err = pcall(startMobileUI) -- 725
		if not ok then -- 726
			if feedHost then -- 727
				feedHost:removeFromParent(true) -- 727
			end -- 727
			feedHost = nil -- 728
			mobileMode = false -- 729
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 730
			return false -- 731
		end -- 726
	else -- 733
		clearMobileUI() -- 733
		updateEntries() -- 734
	end -- 724
	mobileMode = enabled -- 735
	config.mobileFeed = enabled -- 736
	return true -- 737
end -- 721
local setupEventHandlers = nil -- 739
local allClear -- 741
allClear = function() -- 741
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 743
		clearMobileUI() -- 743
	end -- 743
	local systemNodes = { } -- 746
	local preserveSystemNode -- 747
	preserveSystemNode = function(node) -- 747
		if systemNodes[node] then -- 748
			return -- 748
		end -- 748
		systemNodes[node] = true -- 749
		do -- 750
			local clip = tolua.cast(node, "ClipNode") -- 750
			if clip then -- 750
				if clip.stencil then -- 751
					preserveSystemNode(clip.stencil) -- 751
				end -- 751
			end -- 750
		end -- 750
		return node:eachChild(function(child) -- 752
			preserveSystemNode(child) -- 753
			return false -- 754
		end) -- 752
	end -- 747
	for _index_0 = 1, #Routine do -- 755
		local routine = Routine[_index_0] -- 755
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 757
			goto _continue_0 -- 758
		else -- 760
			Routine:remove(routine) -- 760
		end -- 756
		::_continue_0:: -- 756
	end -- 755
	for _index_0 = 1, #moduleCache do -- 761
		local module = moduleCache[_index_0] -- 761
		package.loaded[module] = nil -- 762
	end -- 761
	moduleCache = { } -- 763
	Director:cleanup() -- 764
	Entity:clear() -- 765
	Platformer.Data:clear() -- 766
	Platformer.UnitAction:clear() -- 767
	Audio:stopAll(0.2) -- 768
	Struct:clear() -- 769
	View.nearPlaneDistance = 0.1 -- 772
	View.farPlaneDistance = 10000 -- 773
	View.fieldOfView = 45 -- 774
	View.postEffect = nil -- 775
	View.scale = scaleContent and screenScale or 1 -- 776
	Director.clearColor = Color(0xff1a1a1a) -- 777
	teal.clear() -- 778
	yue.clear() -- 779
	preserveSystemNode(Director.systemUI) -- 782
	for _, item in pairs(ubox()) do -- 783
		local node = tolua.cast(item, "Node") -- 784
		if node then -- 784
			if not systemNodes[node] then -- 785
				node:cleanup() -- 785
			end -- 785
		end -- 784
	end -- 783
	collectgarbage() -- 786
	collectgarbage() -- 787
	Wasm:clear() -- 788
	thread(function() -- 789
		sleep() -- 790
		return Cache:removeUnused() -- 791
	end) -- 789
	setupEventHandlers() -- 792
	Content.searchPaths = searchPaths -- 793
	App.idled = true -- 794
end -- 741
_module_0["allClear"] = allClear -- 741
local clearTempFiles -- 796
clearTempFiles = function() -- 796
	local writablePath = Content.writablePath -- 797
	local uploadPath = Path(writablePath, ".upload") -- 798
	if Content:exist(uploadPath) then -- 799
		local _list_0 = Content:getDirs(uploadPath) -- 801
		for _index_0 = 1, #_list_0 do -- 801
			local dir = _list_0[_index_0] -- 801
			if dir ~= "resume" then -- 802
				Content:remove(Path(uploadPath, dir)) -- 802
			end -- 802
		end -- 801
		local _list_1 = Content:getFiles(uploadPath) -- 803
		for _index_0 = 1, #_list_1 do -- 803
			local file = _list_1[_index_0] -- 803
			Content:remove(Path(uploadPath, file)) -- 804
		end -- 803
	end -- 799
	if Content:exist(Path(writablePath, ".download")) then -- 805
		return Content:remove(Path(writablePath, ".download")) -- 805
	end -- 805
end -- 796
local waitForWebStart = true -- 807
thread(function() -- 808
	sleep(2) -- 809
	waitForWebStart = false -- 810
end) -- 808
local reloadDevEntry -- 812
reloadDevEntry = function() -- 812
	return thread(function() -- 812
		waitForWebStart = true -- 813
		doClean() -- 814
		allClear() -- 815
		_G.require = oldRequire -- 816
		Dora.require = oldRequire -- 817
		package.loaded["Script.Dev.Entry"] = nil -- 818
		package.loaded["Script.Dev.WebServer"] = nil -- 819
		return Director.systemScheduler:schedule(function() -- 820
			Routine:clear() -- 821
			oldRequire("Script.Dev.Entry") -- 822
			return true -- 823
		end) -- 820
	end) -- 812
end -- 812
local setWorkspace -- 825
setWorkspace = function(path) -- 825
	clearTempFiles() -- 826
	Content.writablePath = path -- 827
	config.writablePath = Content.writablePath -- 828
	return thread(function() -- 829
		sleep() -- 830
		return reloadDevEntry() -- 831
	end) -- 829
end -- 825
_module_0["setWorkspace"] = setWorkspace -- 825
local quit = false -- 833
local activeSearchId = 0 -- 835
local handleSearchFiles -- 837
handleSearchFiles = function(payload) -- 837
	if not payload then -- 838
		return -- 838
	end -- 838
	local id = payload.id -- 839
	if id == nil then -- 840
		return -- 840
	end -- 840
	activeSearchId = id -- 841
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 842
	if path == nil then -- 843
		path = "" -- 843
	end -- 843
	if exts == nil then -- 844
		exts = { } -- 844
	end -- 844
	if globs == nil then -- 845
		globs = { } -- 845
	end -- 845
	if extensionLevels == nil then -- 846
		extensionLevels = { } -- 846
	end -- 846
	if pattern == nil then -- 847
		pattern = "" -- 847
	end -- 847
	if pattern == "" then -- 849
		return -- 849
	end -- 849
	local useRegex = payload.useRegex == true -- 850
	local caseSensitive = payload.caseSensitive == true -- 851
	local includeContent = payload.includeContent ~= false -- 852
	local contentWindow = payload.contentWindow or 0 -- 853
	return Director.systemScheduler:schedule(once(function() -- 854
		local stopped = false -- 855
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 856
			if activeSearchId ~= id then -- 857
				stopped = true -- 858
				return true -- 859
			end -- 857
			emit("AppWS", "Send", json.encode({ -- 861
				name = "SearchFilesResult", -- 861
				id = id, -- 861
				result = result -- 861
			})) -- 860
			return false -- 863
		end) -- 856
		return emit("AppWS", "Send", json.encode({ -- 865
			name = "SearchFilesDone", -- 865
			id = id, -- 865
			stopped = stopped -- 865
		})) -- 864
	end)) -- 854
end -- 837
local stop -- 868
stop = function() -- 868
	if isInEntry then -- 869
		return false -- 869
	end -- 869
	allClear() -- 870
	isInEntry = true -- 871
	currentEntry = nil -- 872
	return true -- 873
end -- 868
_module_0["stop"] = stop -- 868
local getCurrentEntryStatus -- 875
getCurrentEntryStatus = function() -- 875
	local entry = currentEntry -- 876
	if not (entry and not isInEntry) then -- 877
		return { -- 877
			success = true, -- 877
			running = false, -- 877
			runId = allEntries.runId -- 877
		} -- 877
	end -- 877
	local status = { -- 879
		success = true, -- 879
		running = true, -- 880
		kind = entry.runKind or "file", -- 881
		runId = allEntries.runId, -- 882
		entryName = entry.entryName, -- 883
		fileName = entry.fileName -- 884
	} -- 878
	if entry.workDir then -- 885
		status.workDir = entry.workDir -- 885
	end -- 885
	if entry.projectRoot then -- 886
		status.projectRoot = entry.projectRoot -- 886
	end -- 886
	return status -- 887
end -- 875
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 875
local _anon_func_3 = function(_with_0) -- 906
	local _val_0 = App.platform -- 906
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 906
end -- 906
local _anon_func_4 = function(_with_0) -- 931
	local _val_0 = App.platform -- 931
	return "Windows" == _val_0 or "macOS" == _val_0 -- 931
end -- 931
setupEventHandlers = function() -- 889
	local _with_0 = Director.postNode -- 890
	_with_0:onAppEvent(function(eventType) -- 891
		if "Quit" == eventType then -- 892
			quit = true -- 893
			allClear() -- 894
			return clearTempFiles() -- 895
		elseif "Shutdown" == eventType then -- 896
			return stop() -- 897
		end -- 891
	end) -- 891
	_with_0:onAppChange(function(settingName) -- 898
		if "Theme" == settingName then -- 899
			config.themeColor = App.themeColor:toARGB() -- 900
		elseif "Locale" == settingName then -- 901
			config.locale = App.locale -- 902
			updateLocale() -- 903
			return teal.clear(true) -- 904
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 905
			if _anon_func_3(_with_0) then -- 906
				if "FullScreen" == settingName then -- 908
					config.fullScreen = App.fullScreen -- 908
				elseif "Position" == settingName then -- 909
					local _obj_0 = App.winPosition -- 909
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 909
				elseif "Size" == settingName then -- 910
					local width, height -- 911
					do -- 911
						local _obj_0 = App.winSize -- 911
						width, height = _obj_0.width, _obj_0.height -- 911
					end -- 911
					config.winWidth = width -- 912
					config.winHeight = height -- 913
				end -- 907
			end -- 906
		end -- 898
	end) -- 898
	_with_0:onAppWS(function(event) -- 914
		if event.type == "Close" then -- 915
			if HttpServer.wsConnectionCount == 0 then -- 916
				updateEntries() -- 917
			end -- 916
			return -- 918
		end -- 915
		if not (event.type == "Receive") then -- 919
			return -- 919
		end -- 919
		local data = json.decode(event.msg) -- 920
		if not data then -- 921
			return -- 921
		end -- 921
		local _exp_0 = data.name -- 922
		if "SearchFiles" == _exp_0 then -- 923
			return handleSearchFiles(data) -- 924
		elseif "SearchFilesStop" == _exp_0 then -- 925
			if data.id == nil or data.id == activeSearchId then -- 926
				activeSearchId = 0 -- 927
			end -- 926
		end -- 922
	end) -- 914
	_with_0:slot("UpdateEntries", function() -- 928
		return updateEntries() -- 928
	end) -- 928
	_with_0:gslot("AtomPieOpenProject", function(id) -- 929
		allEntries.atomPieActivated = true -- 930
		if _anon_func_4(_with_0) and App.webIDEEnabled then -- 931
			emit("AppWebView", "/ide/hide", false) -- 932
		end -- 931
		return allEntries.openAtomPieProject(id) -- 933
	end) -- 929
	return _with_0 -- 890
end -- 889
setupEventHandlers() -- 934
clearTempFiles() -- 935
local downloadFile -- 937
downloadFile = function(url, target) -- 937
	return Director.systemScheduler:schedule(once(function() -- 937
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 938
			if quit then -- 939
				return true -- 939
			end -- 939
			emit("AppWS", "Send", json.encode({ -- 941
				name = "Download", -- 941
				url = url, -- 941
				status = "downloading", -- 941
				progress = current / total -- 942
			})) -- 940
			return false -- 938
		end) -- 938
		return emit("AppWS", "Send", json.encode(success and { -- 945
			name = "Download", -- 945
			url = url, -- 945
			status = "completed", -- 945
			progress = 1.0 -- 946
		} or { -- 948
			name = "Download", -- 948
			url = url, -- 948
			status = "failed", -- 948
			progress = 0.0 -- 949
		})) -- 944
	end)) -- 937
end -- 937
_module_0["downloadFile"] = downloadFile -- 937
local _anon_func_5 = function(file, require, workDir) -- 961
	if workDir == nil then -- 961
		workDir = Path:getPath(file) -- 961
	end -- 961
	Content:insertSearchPath(1, workDir) -- 962
	local scriptPath = Path(workDir, "Script") -- 963
	if Content:exist(scriptPath) then -- 964
		Content:insertSearchPath(1, scriptPath) -- 965
	end -- 964
	local result = require(file) -- 966
	if "function" == type(result) then -- 967
		result() -- 967
	end -- 967
	return nil -- 968
end -- 961
local _anon_func_6 = function(_with_0, err, fontSize, width) -- 997
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 997
	label.alignment = "Left" -- 998
	label.textWidth = width - fontSize -- 999
	label.text = err -- 1000
	return label -- 997
end -- 997
local enterEntryAsync -- 952
enterEntryAsync = function(entry) -- 952
	allEntries.runId = allEntries.runId + 1 -- 953
	isInEntry = false -- 954
	App.idled = false -- 955
	emit(Profiler.EventName, "ClearLoader") -- 956
	currentEntry = entry -- 957
	local file, workDir = entry.fileName, entry.workDir -- 958
	sleep() -- 959
	return xpcall(_anon_func_5, function(msg) -- 968
		local err = debug.traceback(msg) -- 970
		Log("Error", err) -- 971
		allClear() -- 972
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 973
		local viewWidth, viewHeight -- 974
		do -- 974
			local _obj_0 = View.size -- 974
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 974
		end -- 974
		local width, height = viewWidth - 20, viewHeight - 20 -- 975
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 976
		Director.ui:addChild((function() -- 977
			local root = AlignNode() -- 977
			do -- 978
				local _obj_0 = App.bufferSize -- 978
				width, height = _obj_0.width, _obj_0.height -- 978
			end -- 978
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 979
			root:onAppChange(function(settingName) -- 980
				if settingName == "Size" then -- 980
					do -- 981
						local _obj_0 = App.bufferSize -- 981
						width, height = _obj_0.width, _obj_0.height -- 981
					end -- 981
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 982
				end -- 980
			end) -- 980
			root:addChild((function() -- 983
				local _with_0 = ScrollArea({ -- 984
					width = width, -- 984
					height = height, -- 985
					paddingX = 0, -- 986
					paddingY = 50, -- 987
					viewWidth = height, -- 988
					viewHeight = height -- 989
				}) -- 983
				root:onAlignLayout(function(w, h) -- 991
					_with_0.position = Vec2(w / 2, h / 2) -- 992
					w = w - 20 -- 993
					h = h - 20 -- 994
					_with_0.view.children.first.textWidth = w - fontSize -- 995
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 996
				end) -- 991
				_with_0.view:addChild(_anon_func_6(_with_0, err, fontSize, width)) -- 997
				return _with_0 -- 983
			end)()) -- 983
			return root -- 977
		end)()) -- 977
		return err -- 1001
	end, file, require, workDir) -- 960
end -- 952
_module_0["enterEntryAsync"] = enterEntryAsync -- 952
local enterDemoEntry -- 1003
enterDemoEntry = function(entry) -- 1003
	return thread(function() -- 1003
		return enterEntryAsync(entry) -- 1003
	end) -- 1003
end -- 1003
local reloadCurrentEntry -- 1005
reloadCurrentEntry = function() -- 1005
	if currentEntry then -- 1006
		allClear() -- 1007
		return enterDemoEntry(currentEntry) -- 1008
	end -- 1006
end -- 1005
Director.clearColor = Color(0xff1a1a1a) -- 1010
local descColor = Color(0xffa1a1a1) -- 1011
local extraOperations -- 1014
do -- 1014
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 1015
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 1016
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 1017
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 1018
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1019
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1020
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1021
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1022
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1023
	local ossLicenses = nil -- 1024
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1025
	local failedSetFolder = false -- 1026
	local statusFlags = { -- 1027
		"NoResize", -- 1027
		"NoMove", -- 1027
		"NoCollapse", -- 1027
		"AlwaysAutoResize", -- 1027
		"NoSavedSettings" -- 1027
	} -- 1027
	extraOperations = function() -- 1034
		local zh = useChinese -- 1035
		if isDesktop then -- 1036
			local alwaysOnTop = config.alwaysOnTop -- 1037
			do -- 1038
				local changed -- 1038
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1038
				if changed then -- 1038
					App.alwaysOnTop = alwaysOnTop -- 1039
					config.alwaysOnTop = alwaysOnTop -- 1040
				end -- 1038
			end -- 1038
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1041
			do -- 1042
				local changed -- 1042
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1042
				if changed then -- 1042
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1043
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1044
				end -- 1042
			end -- 1042
			SameLine() -- 1045
			TextColored(descColor, "(?)") -- 1046
			if IsItemHovered() then -- 1047
				BeginTooltip(function() -- 1048
					return PushTextWrapPos(360, function() -- 1049
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1050
					end) -- 1049
				end) -- 1048
			end -- 1047
		end -- 1036
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1065
		do -- 1069
			local changed -- 1069
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1069
			if changed then -- 1069
				config.showPreview = showPreview -- 1070
				updateEntries() -- 1071
				if not showPreview then -- 1072
					thread(function() -- 1073
						collectgarbage() -- 1074
						return Cache:removeUnused("Texture") -- 1075
					end) -- 1073
				end -- 1072
			end -- 1069
		end -- 1069
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1076
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1077
			if changed then -- 1077
				config.webIDEEnabled = webIDEEnabled -- 1078
				App.webIDEEnabled = webIDEEnabled -- 1079
			end -- 1077
		end -- 1076
		do -- 1080
			local themeColor = App.themeColor -- 1081
			local writablePath = config.writablePath -- 1082
			SeparatorText(zh and "工作目录" or "Workspace") -- 1083
			PushTextWrapPos(400, function() -- 1084
				return TextColored(themeColor, writablePath) -- 1085
			end) -- 1084
			if not isDesktop then -- 1086
				goto skipSetting -- 1086
			end -- 1086
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1087
			if Button(zh and "改变目录" or "Set Folder") then -- 1088
				App:openFileDialog(true, function(path) -- 1089
					if path == "" then -- 1090
						return -- 1090
					end -- 1090
					local relPath = Path:getRelative(Content.assetPath, path) -- 1091
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1092
						return setWorkspace(path) -- 1093
					else -- 1095
						failedSetFolder = true -- 1095
					end -- 1092
				end) -- 1089
			end -- 1088
			if failedSetFolder then -- 1096
				failedSetFolder = false -- 1097
				OpenPopup(popupName) -- 1098
			end -- 1096
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1099
			BeginPopupModal(popupName, statusFlags, function() -- 1100
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1101
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1102
					return CloseCurrentPopup() -- 1103
				end -- 1102
			end) -- 1100
			SameLine() -- 1104
			if Button(zh and "使用默认" or "Use Default") then -- 1105
				setWorkspace(Content.appPath) -- 1106
			end -- 1105
			Separator() -- 1107
			::skipSetting:: -- 1108
		end -- 1080
		renderAgentStorage(zh) -- 1109
		if isOSSLicenseExist then -- 1110
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1111
				if not ossLicenses then -- 1112
					local licenseText = Content:load("LICENSES") -- 1113
					if licenseText then -- 1113
						local GSplit -- 1114
						do -- 1114
							local _obj_0 = require("Utils") -- 1114
							GSplit = _obj_0.GSplit -- 1114
						end -- 1114
						ossLicenses = { } -- 1115
						licenseText = licenseText:gsub("\r\n", "\n") -- 1116
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1117
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1118
							if name then -- 1118
								ossLicenses[#ossLicenses + 1] = { -- 1119
									name, -- 1119
									text -- 1119
								} -- 1119
							end -- 1118
						end -- 1117
					end -- 1113
				end -- 1112
				if ossLicenses then -- 1120
					OpenPopup(ossLicensePopup) -- 1120
				end -- 1120
			end -- 1111
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1121
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1122
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1123
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1124
				return BeginPopupModal(ossLicensePopup, true, { -- 1127
					"NoSavedSettings" -- 1127
				}, function() -- 1128
					for _index_0 = 1, #ossLicenses do -- 1129
						local _des_0 = ossLicenses[_index_0] -- 1129
						local firstLine, text = _des_0[1], _des_0[2] -- 1129
						local name, license = firstLine:match("(.+): (.+)") -- 1131
						if name then -- 1131
							TextColored(themeColor, name) -- 1132
							SameLine() -- 1133
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1134
								return TextWrapped(text) -- 1134
							end) -- 1134
						end -- 1131
					end -- 1129
				end) -- 1124
			end) -- 1124
		end -- 1110
		if not App.debugging then -- 1137
			return -- 1137
		end -- 1137
		return TreeNode(zh and "开发操作" or "Development", function() -- 1138
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1139
				OpenPopup("build") -- 1139
			end -- 1139
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1140
				return BeginPopup("build", function() -- 1140
					if Selectable(zh and "编译" or "Compile") then -- 1141
						doCompile(false) -- 1141
					end -- 1141
					Separator() -- 1142
					if Selectable(zh and "压缩" or "Minify") then -- 1143
						doCompile(true) -- 1143
					end -- 1143
					Separator() -- 1144
					if Selectable(zh and "清理" or "Clean") then -- 1145
						return doClean() -- 1145
					end -- 1145
				end) -- 1140
			end) -- 1140
			if isInEntry then -- 1146
				if waitForWebStart then -- 1147
					BeginDisabled(function() -- 1148
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1148
					end) -- 1148
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1149
					reloadDevEntry() -- 1150
				end -- 1147
			end -- 1146
			do -- 1151
				local changed -- 1151
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1151
				if changed then -- 1151
					View.scale = scaleContent and screenScale or 1 -- 1152
				end -- 1151
			end -- 1151
			do -- 1153
				local changed -- 1153
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1153
				if changed then -- 1153
					config.engineDev = engineDev -- 1154
				end -- 1153
			end -- 1153
			do -- 1155
				local changed -- 1155
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1155
				if changed then -- 1155
					config.webIDETourCompleted = webIDETourCompleted -- 1156
				end -- 1155
			end -- 1155
			if testingThread then -- 1157
				return BeginDisabled(function() -- 1158
					return Button(zh and "开始自动测试" or "Test automatically") -- 1158
				end) -- 1158
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1159
				testingThread = thread(function() -- 1160
					local _ <close> = setmetatable({ }, { -- 1161
						__close = function() -- 1161
							allClear() -- 1162
							testingThread = nil -- 1163
							isInEntry = true -- 1164
							currentEntry = nil -- 1165
							return print("Testing done!") -- 1166
						end -- 1161
					}) -- 1161
					for _, entry in ipairs(allEntries) do -- 1167
						allClear() -- 1168
						print("Start " .. tostring(entry.entryName)) -- 1169
						enterDemoEntry(entry) -- 1170
						sleep(2) -- 1171
						print("Stop " .. tostring(entry.entryName)) -- 1172
					end -- 1167
				end) -- 1160
			end -- 1157
		end) -- 1138
	end -- 1034
end -- 1014
local icon = Path("Script", "Dev", "icon_s.png") -- 1174
local iconTex = nil -- 1175
thread(function() -- 1176
	if Cache:loadAsync(icon) then -- 1176
		iconTex = Texture2D(icon) -- 1176
	end -- 1176
end) -- 1176
local webStatus = nil -- 1178
local urlClicked = nil -- 1179
local authCode = string.format("%06d", math.random(0, 999999)) -- 1181
local authCodeTTL = 30.0 -- 1183
_module_0.getAuthCode = function() -- 1184
	return authCode -- 1184
end -- 1184
_module_0.invalidateAuthCode = function() -- 1185
	authCode = string.format("%06d", math.random(0, 999999)) -- 1186
	authCodeTTL = 30.0 -- 1187
end -- 1185
local AuthSession -- 1189
do -- 1189
	local pending = nil -- 1190
	local session = nil -- 1191
	AuthSession = { -- 1193
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1193
			pending = { -- 1195
				sessionId = sessionId, -- 1195
				confirmCode = confirmCode, -- 1196
				expiresAt = expiresAt, -- 1197
				ttl = ttl, -- 1198
				approved = false -- 1199
			} -- 1194
		end, -- 1193
		getPending = function() -- 1201
			return pending -- 1201
		end, -- 1201
		approvePending = function(sessionId) -- 1203
			if pending and pending.sessionId == sessionId then -- 1204
				pending.approved = true -- 1205
				return true -- 1206
			end -- 1204
			return false -- 1207
		end, -- 1203
		clearPending = function() -- 1209
			pending = nil -- 1209
		end, -- 1209
		setSession = function(sessionId, sessionSecret) -- 1211
			session = { -- 1213
				sessionId = sessionId, -- 1213
				sessionSecret = sessionSecret -- 1214
			} -- 1212
		end, -- 1211
		getSession = function() -- 1216
			return session -- 1216
		end -- 1216
	} -- 1192
end -- 1189
_module_0["AuthSession"] = AuthSession -- 1189
local transparant = Color(0x0) -- 1219
local windowFlags = { -- 1220
	"NoTitleBar", -- 1220
	"NoResize", -- 1220
	"NoMove", -- 1220
	"NoCollapse", -- 1220
	"NoSavedSettings", -- 1220
	"NoFocusOnAppearing", -- 1220
	"NoBringToFrontOnFocus" -- 1220
} -- 1220
local statusFlags = { -- 1229
	"NoTitleBar", -- 1229
	"NoResize", -- 1229
	"NoMove", -- 1229
	"NoCollapse", -- 1229
	"AlwaysAutoResize", -- 1229
	"NoSavedSettings" -- 1229
} -- 1229
local displayWindowFlags = { -- 1237
	"NoDecoration", -- 1237
	"NoSavedSettings", -- 1237
	"NoMove", -- 1237
	"NoScrollWithMouse", -- 1237
	"AlwaysAutoResize", -- 1237
	"NoFocusOnAppearing" -- 1237
} -- 1237
allEntries.drawAtomPieStatus = function(width, top) -- 1245
	local status = allEntries.atomPieStatus -- 1246
	if not (status and status.phase) then -- 1247
		return 0 -- 1247
	end -- 1247
	if status.expiresAt and App.runningTime >= status.expiresAt then -- 1248
		allEntries.atomPieStatus = nil -- 1249
		return 0 -- 1250
	end -- 1248
	local zh = useChinese -- 1251
	local message -- 1252
	do -- 1252
		local _exp_0 = status.phase -- 1252
		if "resolve" == _exp_0 then -- 1253
			message = zh and "正在读取原子派作品…" or "Looking up AtomPie project…" -- 1253
		elseif "clone" == _exp_0 then -- 1254
			message = zh and "正在拉取源码…" or "Cloning source…" -- 1254
		elseif "verify" == _exp_0 then -- 1255
			message = zh and "正在校验源码…" or "Verifying source…" -- 1255
		else -- 1256
			message = zh and "导入失败，请从原子派重试" or "Import failed. Try again from AtomPie." -- 1256
		end -- 1252
	end -- 1252
	ImGui.SetNextWindowPos(Vec2(0, top), "Always") -- 1257
	ImGui.SetNextWindowSize(Vec2(width, 38), "Always") -- 1258
	ImGui.Begin("AtomPie Import", windowFlags, function() -- 1259
		ImGui.Text(message) -- 1260
		if status.progress and width >= 340 then -- 1261
			ImGui.SameLine() -- 1262
			return ImGui.ProgressBar(status.progress, Vec2(-1, 18)) -- 1263
		end -- 1261
	end) -- 1259
	return 38 -- 1264
end -- 1245
allEntries.drawGameTest = function(game, zh) -- 1266
	if game.needsBuild then -- 1267
		return ImGui.TextDisabled(zh and "编译后可测试" or "Build required to play") -- 1268
	elseif ImGui.Button(tostring(zh and '开始测试' or 'Game Test') .. "##" .. tostring(game.fileName), Vec2(-1, 40)) then -- 1269
		return enterDemoEntry(game) -- 1270
	end -- 1267
end -- 1266
local _anon_func_7 = function(allEntries, currentIndex) -- 1337
	if currentIndex > 1 then -- 1337
		return allEntries[currentIndex - 1] -- 1338
	else -- 1340
		return allEntries[#allEntries] -- 1340
	end -- 1337
end -- 1337
local _anon_func_8 = function(allEntries, currentIndex) -- 1344
	if currentIndex < #allEntries then -- 1344
		return allEntries[currentIndex + 1] -- 1345
	else -- 1347
		return allEntries[1] -- 1347
	end -- 1344
end -- 1344
do -- 1273
	local gamepadInputWindowFlags = { -- 1274
		"NoDecoration", -- 1274
		"NoSavedSettings", -- 1274
		"NoMove", -- 1274
		"NoScrollbar", -- 1274
		"NoScrollWithMouse", -- 1274
		"NoFocusOnAppearing", -- 1274
		"NoBringToFrontOnFocus" -- 1274
	} -- 1274
	local initFooter = true -- 1283
	local gamepadInputFocused = false -- 1284
	footerWindow = threadLoop(function() -- 1285
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1286
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1287
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1288
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1289
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1290
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1291
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1292
		if mobileMode then -- 1293
			return -- 1293
		end -- 1293
		local zh = useChinese -- 1294
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1295
		if authCodeTTL <= 0 then -- 1296
			authCodeTTL = 30.0 -- 1297
			authCode = string.format("%06d", math.random(0, 999999)) -- 1298
		end -- 1296
		if HttpServer.wsConnectionCount > 0 then -- 1299
			return -- 1300
		end -- 1299
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1301
			if App.platform == "Emscripten" then -- 1302
				stop() -- 1304
			else -- 1306
				allClear() -- 1306
				App.devMode = false -- 1307
				App:shutdown() -- 1308
			end -- 1302
		end -- 1301
		do -- 1309
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1310
			if ctrl and Keyboard:isKeyDown("Q") then -- 1311
				stop() -- 1312
			end -- 1311
			if ctrl and Keyboard:isKeyDown("Z") then -- 1313
				reloadCurrentEntry() -- 1314
			end -- 1313
			if ctrl and Keyboard:isKeyDown(",") then -- 1315
				if showFooter then -- 1316
					showStats = not showStats -- 1316
				else -- 1316
					showStats = true -- 1316
				end -- 1316
				showFooter = true -- 1317
				config.showFooter = showFooter -- 1318
				config.showStats = showStats -- 1319
			end -- 1315
			if ctrl and Keyboard:isKeyDown(".") then -- 1320
				if showFooter then -- 1321
					showConsole = not showConsole -- 1321
				else -- 1321
					showConsole = true -- 1321
				end -- 1321
				showFooter = true -- 1322
				config.showFooter = showFooter -- 1323
				config.showConsole = showConsole -- 1324
			end -- 1320
			if ctrl and Keyboard:isKeyDown("/") then -- 1325
				showFooter = not showFooter -- 1326
				config.showFooter = showFooter -- 1327
			end -- 1325
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1328
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1329
			local currentIndex = nil -- 1330
			for i, entry in ipairs(allEntries) do -- 1331
				if currentEntry == entry then -- 1332
					currentIndex = i -- 1333
				end -- 1332
			end -- 1331
			if left then -- 1334
				allClear() -- 1335
				if currentIndex == nil then -- 1336
					currentIndex = #allEntries + 1 -- 1336
				end -- 1336
				enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 1337
			end -- 1334
			if right then -- 1341
				allClear() -- 1342
				if currentIndex == nil then -- 1343
					currentIndex = 0 -- 1343
				end -- 1343
				enterDemoEntry(_anon_func_8(allEntries, currentIndex)) -- 1344
			end -- 1341
		end -- 1309
		if not showEntry then -- 1348
			return -- 1348
		end -- 1348
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1350
			reloadDevEntry() -- 1354
		end -- 1350
		if initFooter then -- 1355
			initFooter = false -- 1356
		end -- 1355
		local width, height -- 1358
		do -- 1358
			local _obj_0 = App.visualSize -- 1358
			width, height = _obj_0.width, _obj_0.height -- 1358
		end -- 1358
		if isInEntry then -- 1359
			gamepadInputFocused = false -- 1360
		else -- 1362
			SetNextWindowBgAlpha(0.0) -- 1362
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1363
			SetNextWindowPos(Vec2.zero, "Always") -- 1364
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1365
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1366
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1367
						if not gamepadInputFocused then -- 1368
							SetWindowFocus("DoraGamepadInput") -- 1369
							gamepadInputFocused = true -- 1370
						end -- 1368
					end) -- 1367
				end) -- 1366
			end) -- 1365
		end -- 1359
		if isInEntry or showFooter then -- 1372
			SetNextWindowSize(Vec2(width, 50)) -- 1373
			SetNextWindowPos(Vec2(0, height - 50)) -- 1374
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1375
				return PushStyleVar("WindowRounding", 0, function() -- 1376
					return Begin("Footer", windowFlags, function() -- 1377
						Separator() -- 1378
						if iconTex then -- 1379
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1380
								showStats = not showStats -- 1381
								config.showStats = showStats -- 1382
							end -- 1380
							SameLine() -- 1383
							if Button(">_", Vec2(30, 30)) then -- 1384
								showConsole = not showConsole -- 1385
								config.showConsole = showConsole -- 1386
							end -- 1384
						end -- 1379
						if isInEntry and updateState.available then -- 1387
							SameLine() -- 1388
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1389
								allClear() -- 1390
								enterDemoEntry({ -- 1392
									entryName = "SelfUpdater", -- 1392
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1393
								}) -- 1391
							end -- 1389
						end -- 1387
						if not isInEntry then -- 1394
							SameLine() -- 1395
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1396
							local currentIndex = nil -- 1397
							for i, entry in ipairs(allEntries) do -- 1398
								if currentEntry == entry then -- 1399
									currentIndex = i -- 1400
								end -- 1399
							end -- 1398
							if currentIndex then -- 1401
								if currentIndex > 1 then -- 1402
									SameLine() -- 1403
									if Button("<<", Vec2(30, 30)) then -- 1404
										allClear() -- 1405
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1406
									end -- 1404
								end -- 1402
								if currentIndex < #allEntries then -- 1407
									SameLine() -- 1408
									if Button(">>", Vec2(30, 30)) then -- 1409
										allClear() -- 1410
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1411
									end -- 1409
								end -- 1407
							end -- 1401
							SameLine() -- 1412
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1413
								reloadCurrentEntry() -- 1414
							end -- 1413
							if back then -- 1415
								allClear() -- 1416
								isInEntry = true -- 1417
								currentEntry = nil -- 1418
							end -- 1415
						end -- 1394
					end) -- 1377
				end) -- 1376
			end) -- 1375
		end -- 1372
		if isInEntry then -- 1420
			local showURL = true -- 1421
			local webIDEWidth -- 1422
			do -- 1422
				local base -- 1423
				if updateState.available then -- 1423
					base = 460 -- 1423
				else -- 1423
					base = 360 -- 1423
				end -- 1423
				local extra = 35 -- 1424
				webIDEWidth = base + extra -- 1425
			end -- 1422
			if width < webIDEWidth then -- 1426
				showURL = false -- 1426
			end -- 1426
			SetNextWindowBgAlpha(0.0) -- 1427
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1428
			Begin("Web IDE", displayWindowFlags, function() -- 1429
				local pending = AuthSession.getPending() -- 1430
				local hovered = false -- 1431
				if not pending and showURL then -- 1432
					do -- 1433
						local url -- 1433
						if webStatus ~= nil then -- 1433
							url = webStatus.url -- 1433
						end -- 1433
						if url then -- 1433
							if isDesktop and not config.fullScreen then -- 1434
								if urlClicked then -- 1435
									BeginDisabled(function() -- 1436
										return Button(url) -- 1436
									end) -- 1436
								elseif Button(url) then -- 1437
									urlClicked = once(function() -- 1438
										return sleep(5) -- 1438
									end) -- 1438
									App:openURL("http://localhost:8866") -- 1439
								end -- 1435
							else -- 1441
								TextColored(descColor, url) -- 1441
							end -- 1434
						else -- 1443
							TextColored(descColor, zh and '不可用' or 'not available') -- 1443
						end -- 1433
					end -- 1433
					hovered = IsItemHovered() -- 1444
				else -- 1446
					TextColored(descColor, "(?)") -- 1446
					hovered = IsItemHovered() -- 1447
				end -- 1432
				SameLine() -- 1448
				local themeColor = App.themeColor -- 1449
				if pending then -- 1450
					if not pending.approved then -- 1451
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1452
						local ttl = pending.ttl or 1 -- 1453
						PushStyleColor("Text", themeColor, function() -- 1454
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1455
							hovered = hovered or IsItemHovered() -- 1456
						end) -- 1454
						SameLine() -- 1457
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1458
							AuthSession.approvePending(pending.sessionId) -- 1459
						end -- 1458
						if hovered then -- 1460
							return BeginTooltip(function() -- 1461
								return PushTextWrapPos(280, function() -- 1462
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1463
								end) -- 1462
							end) -- 1461
						end -- 1460
					end -- 1451
				else -- 1465
					PushStyleColor("Text", themeColor, function() -- 1465
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1466
						hovered = hovered or IsItemHovered() -- 1467
					end) -- 1465
					if hovered then -- 1468
						return BeginTooltip(function() -- 1469
							return PushTextWrapPos(280, function() -- 1470
								local url -- 1471
								if webStatus ~= nil then -- 1471
									url = webStatus.url -- 1471
								end -- 1471
								if url then -- 1471
									local address -- 1472
									if showURL then -- 1472
										address = "Web IDE" -- 1472
									else -- 1472
										address = url -- 1472
									end -- 1472
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1473
								else -- 1475
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1475
								end -- 1471
							end) -- 1470
						end) -- 1469
					end -- 1468
				end -- 1450
			end) -- 1429
		end -- 1420
		if not isInEntry then -- 1476
			SetNextWindowSize(Vec2(50, 50)) -- 1477
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1478
			PushStyleColor("WindowBg", transparant, function() -- 1479
				return Begin("Show", displayWindowFlags, function() -- 1479
					if width >= 370 then -- 1480
						local changed -- 1481
						changed, showFooter = Checkbox("##dev", showFooter) -- 1481
						if changed then -- 1481
							config.showFooter = showFooter -- 1482
						end -- 1481
					end -- 1480
				end) -- 1479
			end) -- 1479
		end -- 1476
		if isInEntry or showFooter then -- 1484
			if showStats then -- 1485
				PushStyleVar("WindowRounding", 0, function() -- 1486
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1487
					SetNextWindowSize(Vec2(0, height - 50)) -- 1488
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1489
					config.showStats = showStats -- 1490
				end) -- 1486
			end -- 1485
			if showConsole then -- 1491
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1492
				return PushStyleVar("WindowRounding", 6, function() -- 1493
					return ShowConsole() -- 1494
				end) -- 1493
			end -- 1491
		end -- 1484
	end) -- 1285
end -- 1273
do -- 1497
	local MaxWidth <const> = 960 -- 1498
	local toolOpen = false -- 1500
	local filterText = nil -- 1501
	allEntries.anyEntryMatched = false -- 1502
	allEntries.match = function(name) -- 1503
		local res = not filterText or name:lower():match(filterText) -- 1504
		if res then -- 1505
			allEntries.anyEntryMatched = true -- 1505
		end -- 1505
		return res -- 1506
	end -- 1503
	allEntries.thinSep = function() -- 1508
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1508
			return ImGui.SeparatorText("") -- 1508
		end) -- 1508
	end -- 1508
	entryWindow = threadLoop(function() -- 1509
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1510
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1511
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1512
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1513
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1514
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1515
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1516
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1517
		local connected = syncWebIDEControl() -- 1518
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1520
			if not allEntries.pendingPackagePath then -- 1521
				local path = App:takeReceivedFile() -- 1522
				if path ~= "" then -- 1523
					allEntries.pendingPackagePath = path -- 1523
				end -- 1523
			end -- 1521
			if allEntries.pendingPackagePath then -- 1524
				pendingUIMode = true -- 1524
			end -- 1524
		end -- 1520
		if (pendingUIMode ~= nil) then -- 1526
			local nextMode = pendingUIMode -- 1527
			pendingUIMode = nil -- 1528
			applyUIMode(nextMode) -- 1529
		end -- 1526
		if mobileMode and not connected then -- 1530
			if isInEntry and not feedHost then -- 1531
				applyUIMode(true) -- 1531
			end -- 1531
			if isInEntry and feedHost and feedHost.visible then -- 1532
				allEntries.revealAtomPieInFeed() -- 1533
				allEntries.drawAtomPieStatus(App.visualSize.width, 60) -- 1534
			end -- 1532
			return -- 1535
		end -- 1530
		if App.fpsLimited ~= config.fpsLimited then -- 1536
			config.fpsLimited = App.fpsLimited -- 1537
		end -- 1536
		if App.targetFPS ~= config.targetFPS then -- 1538
			config.targetFPS = App.targetFPS -- 1539
		end -- 1538
		if View.vsync ~= config.vsync then -- 1540
			config.vsync = View.vsync -- 1541
		end -- 1540
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1542
			config.fixedFPS = Director.scheduler.fixedFPS -- 1543
		end -- 1542
		if Director.profilerSending ~= config.webProfiler then -- 1544
			config.webProfiler = Director.profilerSending -- 1545
		end -- 1544
		if urlClicked then -- 1546
			local _, result = coroutine.resume(urlClicked) -- 1547
			if result then -- 1548
				coroutine.close(urlClicked) -- 1549
				urlClicked = nil -- 1550
			end -- 1548
		end -- 1546
		if not isInEntry then -- 1551
			return -- 1551
		end -- 1551
		local zh = useChinese -- 1552
		local themeColor = App.themeColor -- 1553
		if connected then -- 1554
			local width, height -- 1555
			do -- 1555
				local _obj_0 = App.visualSize -- 1555
				width, height = _obj_0.width, _obj_0.height -- 1555
			end -- 1555
			SetNextWindowBgAlpha(0.5) -- 1556
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1557
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1558
				Separator() -- 1559
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1560
				if iconTex then -- 1561
					Image(icon, Vec2(24, 24)) -- 1562
					SameLine() -- 1563
				end -- 1561
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1564
				TextColored(descColor, slogon) -- 1565
				return Separator() -- 1566
			end) -- 1558
			return -- 1567
		end -- 1554
		if not showEntry then -- 1568
			return -- 1568
		end -- 1568
		local fullWidth, height -- 1570
		do -- 1570
			local _obj_0 = App.visualSize -- 1570
			fullWidth, height = _obj_0.width, _obj_0.height -- 1570
		end -- 1570
		local width = math.min(MaxWidth, fullWidth) -- 1571
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1572
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1573
		SetNextWindowPos(Vec2.zero) -- 1574
		SetNextWindowBgAlpha(0) -- 1575
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1576
		do -- 1577
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1578
				return Begin("Dora Dev", windowFlags, function() -- 1579
					Dummy(Vec2(fullWidth - 20, 0)) -- 1580
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1581
					SameLine() -- 1582
					if Button(zh and "Go 模式" or "Go Mode") then -- 1583
						setUIMode("mobile") -- 1584
					end -- 1583
					if fullWidth >= 540 then -- 1585
						SameLine() -- 1586
						Dummy(Vec2(fullWidth - 540, 0)) -- 1587
						SameLine() -- 1588
						SetNextItemWidth(zh and -95 or -140) -- 1589
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1590
							"AutoSelectAll" -- 1590
						}) then -- 1590
							config.filter = filterBuf.text -- 1591
							allEntries.atomPieFocusedFile = nil -- 1592
							allEntries.atomPieReveal = nil -- 1593
						end -- 1590
						SameLine() -- 1594
						if Button(zh and '下载' or 'Download') then -- 1595
							allClear() -- 1596
							enterDemoEntry({ -- 1598
								entryName = "ResourceDownloader", -- 1598
								fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1599
							}) -- 1597
						end -- 1595
					end -- 1585
					return Separator() -- 1600
				end) -- 1579
			end) -- 1578
		end -- 1577
		allEntries.anyEntryMatched = false -- 1602
		local importHeight = allEntries.drawAtomPieStatus(fullWidth, 50) -- 1603
		SetNextWindowPos(Vec2(0, 50 + importHeight)) -- 1604
		SetNextWindowSize(Vec2(fullWidth, height - 100 - importHeight)) -- 1605
		local scrollbarSize <const> = 25 -- 1607
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1608
		do -- 1609
			return PushStyleColor("WindowBg", transparant, function() -- 1610
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1611
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1612
						return PushStyleVar("Alpha", 1, function() -- 1613
							return Begin("Content", windowFlags, function() -- 1614
								local DemoViewWidth <const> = 220 -- 1615
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1616
								if filterText then -- 1617
									filterText = filterText:lower() -- 1617
								end -- 1617
								if App.platform == "Emscripten" then -- 1618
									Dora.globals.webProjects.draw(zh, themeColor) -- 1619
									allEntries.anyEntryMatched = true -- 1620
								end -- 1618
								if #gamesInDev > 0 then -- 1621
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1622
									Columns(columns, false) -- 1623
									local realViewWidth = GetColumnWidth() - 50 -- 1624
									for _index_0 = 1, #gamesInDev do -- 1625
										local game = gamesInDev[_index_0] -- 1625
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1626
										local displayName -- 1635
										if repo then -- 1635
											if zh then -- 1636
												displayName = repo.title.zh -- 1636
											else -- 1636
												displayName = repo.title.en -- 1636
											end -- 1636
										end -- 1635
										if displayName == nil then -- 1637
											displayName = gameName -- 1637
										end -- 1637
										local focused = allEntries.atomPieFocusedFile == fileName -- 1638
										if allEntries.match(displayName) or focused then -- 1639
											allEntries.anyEntryMatched = true -- 1640
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1641
											SameLine() -- 1642
											if focused then -- 1643
												PushStyleColor("Text", themeColor, function() -- 1644
													return TextWrapped(displayName) -- 1644
												end) -- 1644
												if allEntries.atomPieReveal then -- 1645
													ImGui.SetScrollY(0) -- 1646
													allEntries.atomPieReveal = nil -- 1647
												end -- 1645
											else -- 1649
												TextWrapped(displayName) -- 1649
											end -- 1643
											if columns > 1 then -- 1650
												if bannerFile and bannerTex then -- 1651
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1652
													local displayWidth <const> = realViewWidth -- 1653
													texHeight = displayWidth * texHeight / texWidth -- 1654
													texWidth = displayWidth -- 1655
													Dummy(Vec2.zero) -- 1656
													SameLine() -- 1657
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1658
												end -- 1651
												allEntries.drawGameTest(game, zh) -- 1659
											else -- 1661
												if bannerFile and bannerTex then -- 1661
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1662
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1663
													local sizing = 0.8 -- 1664
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1665
													texWidth = displayWidth * sizing -- 1666
													if texWidth > 500 then -- 1667
														sizing = 0.6 -- 1668
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1669
														texWidth = displayWidth * sizing -- 1670
													end -- 1667
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1671
													Dummy(Vec2(padding, 0)) -- 1672
													SameLine() -- 1673
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1674
												end -- 1661
												allEntries.drawGameTest(game, zh) -- 1675
											end -- 1650
											if #tests == 0 and #examples == 0 then -- 1676
												allEntries.thinSep() -- 1677
											end -- 1676
											NextColumn() -- 1678
										end -- 1639
										local showSep = false -- 1679
										if #examples > 0 then -- 1680
											local showExample = false -- 1681
											for _index_1 = 1, #examples do -- 1682
												local _des_0 = examples[_index_1] -- 1682
												local entryName = _des_0.entryName -- 1682
												if allEntries.match(entryName) then -- 1683
													showExample = true -- 1683
													break -- 1683
												end -- 1683
											end -- 1682
											if showExample then -- 1684
												showSep = true -- 1685
												Columns(1, false) -- 1686
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1687
												SameLine() -- 1688
												local opened -- 1689
												if (filterText ~= nil) then -- 1689
													opened = showExample -- 1689
												else -- 1689
													opened = false -- 1689
												end -- 1689
												if game.exampleOpen == nil then -- 1690
													game.exampleOpen = opened -- 1690
												end -- 1690
												SetNextItemOpen(game.exampleOpen) -- 1691
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1692
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1693
														Columns(maxColumns, false) -- 1694
														for _index_1 = 1, #examples do -- 1695
															local example = examples[_index_1] -- 1695
															local entryName = example.entryName -- 1696
															if not allEntries.match(entryName) then -- 1697
																goto _continue_0 -- 1697
															end -- 1697
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1698
																if Button(entryName, Vec2(-1, 40)) then -- 1699
																	enterDemoEntry(example) -- 1700
																end -- 1699
																return NextColumn() -- 1701
															end) -- 1698
															opened = true -- 1702
															::_continue_0:: -- 1696
														end -- 1695
													end) -- 1693
												end) -- 1692
												game.exampleOpen = opened -- 1703
											end -- 1684
										end -- 1680
										if #tests > 0 then -- 1704
											local showTest = false -- 1705
											for _index_1 = 1, #tests do -- 1706
												local _des_0 = tests[_index_1] -- 1706
												local entryName = _des_0.entryName -- 1706
												if allEntries.match(entryName) then -- 1707
													showTest = true -- 1707
													break -- 1707
												end -- 1707
											end -- 1706
											if showTest then -- 1708
												showSep = true -- 1709
												Columns(1, false) -- 1710
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1711
												SameLine() -- 1712
												local opened -- 1713
												if (filterText ~= nil) then -- 1713
													opened = showTest -- 1713
												else -- 1713
													opened = false -- 1713
												end -- 1713
												if game.testOpen == nil then -- 1714
													game.testOpen = opened -- 1714
												end -- 1714
												SetNextItemOpen(game.testOpen) -- 1715
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1716
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1717
														Columns(maxColumns, false) -- 1718
														for _index_1 = 1, #tests do -- 1719
															local test = tests[_index_1] -- 1719
															local entryName = test.entryName -- 1720
															if not allEntries.match(entryName) then -- 1721
																goto _continue_0 -- 1721
															end -- 1721
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1722
																if Button(entryName, Vec2(-1, 40)) then -- 1723
																	enterDemoEntry(test) -- 1724
																end -- 1723
																return NextColumn() -- 1725
															end) -- 1722
															opened = true -- 1726
															::_continue_0:: -- 1720
														end -- 1719
													end) -- 1717
												end) -- 1716
												game.testOpen = opened -- 1727
											end -- 1708
										end -- 1704
										if showSep then -- 1728
											Columns(1, false) -- 1729
											allEntries.thinSep() -- 1730
											Columns(columns, false) -- 1731
										end -- 1728
									end -- 1625
								end -- 1621
								if #doraTools > 0 then -- 1732
									local showTool = false -- 1733
									for _index_0 = 1, #doraTools do -- 1734
										local _des_0 = doraTools[_index_0] -- 1734
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1734
										local displayName -- 1735
										if repo then -- 1735
											if zh then -- 1736
												displayName = repo.title.zh -- 1736
											else -- 1736
												displayName = repo.title.en -- 1736
											end -- 1736
										end -- 1735
										if displayName == nil then -- 1737
											displayName = entryName -- 1737
										end -- 1737
										if allEntries.match(displayName) then -- 1738
											showTool = true -- 1738
											break -- 1738
										end -- 1738
									end -- 1734
									if not showTool then -- 1739
										goto endEntry -- 1739
									end -- 1739
									Columns(1, false) -- 1740
									TextColored(themeColor, "Dora SSR:") -- 1741
									SameLine() -- 1742
									Text(zh and "开发支持" or "Development Support") -- 1743
									Separator() -- 1744
									if #doraTools > 0 then -- 1745
										local opened -- 1746
										if (filterText ~= nil) then -- 1746
											opened = showTool -- 1746
										else -- 1746
											opened = false -- 1746
										end -- 1746
										SetNextItemOpen(toolOpen) -- 1747
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1748
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1749
												Columns(maxColumns, false) -- 1750
												for _index_0 = 1, #doraTools do -- 1751
													local tool = doraTools[_index_0] -- 1751
													local entryName, repo = tool.entryName, tool.repo -- 1752
													local displayName -- 1753
													if repo then -- 1753
														if zh then -- 1754
															displayName = repo.title.zh -- 1754
														else -- 1754
															displayName = repo.title.en -- 1754
														end -- 1754
													end -- 1753
													if displayName == nil then -- 1755
														displayName = entryName -- 1755
													end -- 1755
													if not allEntries.match(displayName) then -- 1756
														goto _continue_0 -- 1756
													end -- 1756
													if Button(displayName, Vec2(-1, 40)) then -- 1757
														enterDemoEntry(tool) -- 1758
													end -- 1757
													NextColumn() -- 1759
													::_continue_0:: -- 1752
												end -- 1751
												Columns(1, false) -- 1760
												opened = true -- 1761
											end) -- 1749
										end) -- 1748
										toolOpen = opened -- 1762
									end -- 1745
								end -- 1732
								::endEntry:: -- 1763
								if not allEntries.anyEntryMatched then -- 1764
									SetNextWindowBgAlpha(0) -- 1765
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1766
									Begin("Entries Not Found", displayWindowFlags, function() -- 1767
										Separator() -- 1768
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1769
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1770
										return Separator() -- 1771
									end) -- 1767
								end -- 1764
								Columns(1, false) -- 1772
								Dummy(Vec2(100, 80)) -- 1773
								return ScrollWhenDraggingOnVoid() -- 1774
							end) -- 1614
						end) -- 1613
					end) -- 1612
				end) -- 1611
			end) -- 1610
		end -- 1609
	end) -- 1509
end -- 1497
if not (App.platform == "Emscripten") then -- 1779
	local sceneModuleCache = moduleCache -- 1780
	moduleCache = { } -- 1781
	webStatus = oldRequire("Script.Dev.WebServer") -- 1782
	moduleCache = sceneModuleCache -- 1783
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1784
		thread(function() -- 1785
			sleep() -- 1786
			wait(function() -- 1787
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1787
			end) -- 1787
			if App.webIDEEnabled and not allEntries.atomPieActivated then -- 1788
				return emit("AppWebView", "/ide/show", true) -- 1788
			end -- 1788
		end) -- 1785
	end -- 1784
end -- 1779
local _anon_func_9 = function(saved) -- 1811
	local _val_0 = saved.kind -- 1811
	return "local" == _val_0 or "discover" == _val_0 -- 1811
end -- 1811
local _anon_func_10 = function(saved) -- 1815
	local _val_0 = saved.activeTab -- 1815
	return "local" == _val_0 or "discover" == _val_0 -- 1815
end -- 1815
startMobileUI = function() -- 1790
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1791
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1792
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1793
	local getMobileFeedResources -- 1794
	do -- 1794
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1794
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1794
	end -- 1794
	local loadCachedCatalog -- 1795
	do -- 1795
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1795
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1795
	end -- 1795
	local getResourceInstallPath, getInstalledCatalogResource -- 1796
	do -- 1796
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1796
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1796
	end -- 1796
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1797
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1798
	local feedOptions = nil -- 1799
	local mobileLaunchErrors = { } -- 1800
	local withMobileLaunchErrors -- 1801
	withMobileLaunchErrors = function(items) -- 1801
		for _index_0 = 1, #items do -- 1802
			local item = items[_index_0] -- 1802
			item.launchError = mobileLaunchErrors[item.id] -- 1803
		end -- 1802
		return items -- 1804
	end -- 1801
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1805
	local loadRememberedMobileFeedState -- 1806
	loadRememberedMobileFeedState = function() -- 1806
		local raw = rememberedMobileFeedData -- 1807
		if not (type(raw) == "string" and raw ~= "") then -- 1808
			return -- 1808
		end -- 1808
		local ok, saved = pcall(json.decode, raw) -- 1809
		if not (ok and type(saved) == "table") then -- 1810
			return -- 1810
		end -- 1810
		if type(saved.id) == "string" and _anon_func_9(saved) then -- 1811
			local state = { -- 1812
				activeTab = saved.kind -- 1812
			} -- 1812
			state[saved.kind] = saved -- 1813
			return state -- 1814
		end -- 1811
		local state = { -- 1815
			activeTab = _anon_func_10(saved) and saved.activeTab or "local" -- 1815
		} -- 1815
		local _list_0 = { -- 1816
			"local", -- 1816
			"discover" -- 1816
		} -- 1816
		for _index_0 = 1, #_list_0 do -- 1816
			local kind = _list_0[_index_0] -- 1816
			local entry = saved[kind] -- 1817
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1818
				state[kind] = entry -- 1818
			end -- 1818
		end -- 1816
		return state -- 1819
	end -- 1806
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1820
		activeTab = "local" -- 1820
	} -- 1820
	local rememberMobileFeedEntry -- 1821
	rememberMobileFeedEntry = function(entry) -- 1821
		rememberedMobileFeedState.activeTab = entry.kind -- 1822
		rememberedMobileFeedState[entry.kind] = { -- 1824
			id = entry.id, -- 1824
			kind = entry.kind, -- 1825
			workDir = entry.workDir, -- 1826
			fileName = entry.fileName -- 1827
		} -- 1823
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1829
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1830
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1831
			rememberedMobileFeedData -- 1831
		}) -- 1831
	end -- 1821
	local restartMobileFeed -- 1832
	restartMobileFeed = function(entry) -- 1832
		if feedHost then -- 1833
			feedHost:removeFromParent(true) -- 1833
		end -- 1833
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1834
		local initialEntries = { } -- 1835
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1836
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1837
		feedOptions.initialEntries = initialEntries -- 1838
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1839
	end -- 1832
	local startMobilePlay -- 1840
	startMobilePlay = function(entry) -- 1840
		if HttpServer.wsConnectionCount > 0 then -- 1841
			return -- 1841
		end -- 1841
		if entry.needsBuild then -- 1842
			mobileLaunchErrors[entry.id] = useChinese and "编译后可试玩" or "Build required to play" -- 1843
			restartMobileFeed(entry) -- 1844
			return -- 1845
		end -- 1842
		local originFeed = feedHost -- 1846
		if remixHost then -- 1847
			remixHost:removeFromParent(true) -- 1847
		end -- 1847
		remixHost = nil -- 1848
		mobileLaunchErrors[entry.id] = nil -- 1849
		entry.launchError = nil -- 1850
		local playActive = true -- 1851
		local restoreMobileFeed -- 1852
		restoreMobileFeed = function() -- 1852
			if not playActive then -- 1853
				return -- 1853
			end -- 1853
			playActive = false -- 1854
			allClear() -- 1855
			isInEntry = true -- 1856
			currentEntry = nil -- 1857
			return restartMobileFeed(entry) -- 1858
		end -- 1852
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1860
			onExit = function() -- 1860
				return restoreMobileFeed() -- 1860
			end, -- 1860
			onRuntimeError = function() -- 1861
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1862
				return restoreMobileFeed() -- 1863
			end -- 1861
		})) -- 1859
		return thread(function() -- 1865
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1869
			if not playActive then -- 1870
				return -- 1870
			end -- 1870
			if success then -- 1871
				if originFeed and originFeed.parent then -- 1872
					originFeed.visible = false -- 1872
				end -- 1872
				return -- 1873
			end -- 1871
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1874
			return restoreMobileFeed() -- 1875
		end) -- 1865
	end -- 1840
	feedOptions = { -- 1877
		takeReceivedFile = function() -- 1877
			if allEntries.pendingPackagePath then -- 1878
				local path = allEntries.pendingPackagePath -- 1879
				allEntries.pendingPackagePath = nil -- 1880
				return path -- 1881
			end -- 1878
			return App:takeReceivedFile() -- 1882
		end, -- 1877
		onSwitchMode = function() -- 1883
			if HttpServer.wsConnectionCount == 0 then -- 1883
				pendingUIMode = false -- 1883
			end -- 1883
		end, -- 1883
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1884
		getLocalEntries = function(importedProjectPath) -- 1885
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1886
			feedOptions.dirtyProjectPath = nil -- 1887
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1888
			local cached = loadCachedCatalog() -- 1889
			if cached.success and cached.snapshot then -- 1890
				for _index_0 = 1, #items do -- 1891
					local entry = items[_index_0] -- 1891
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1892
					if resource then -- 1893
						entry.resource = resource -- 1894
						entry.catalogCommit = cached.snapshot.commit -- 1895
					end -- 1893
				end -- 1891
			end -- 1890
			return items -- 1896
		end, -- 1885
		syncDiscover = function(onProgress, onDone, force) -- 1897
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1897
		end, -- 1897
		getDiscoverEntries = function() -- 1898
			local cached = loadCachedCatalog() -- 1899
			if not (cached.success and cached.snapshot) then -- 1900
				return { } -- 1900
			end -- 1900
			local items = { } -- 1901
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1902
			for _index_0 = 1, #_list_0 do -- 1902
				local resource = _list_0[_index_0] -- 1902
				local installed = lifecycle.isMobileResourceReady(resource) -- 1903
				local installPath = getResourceInstallPath(resource.id) -- 1904
				items[#items + 1] = { -- 1906
					id = resource.id, -- 1906
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1907
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1908
					kind = "discover", -- 1909
					bannerFile = resource.bannerPath, -- 1910
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1911
					sourceUrl = resource.versions[1].sources[1].url, -- 1912
					workDir = installed and installPath or nil, -- 1913
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1914
					installed = installed, -- 1915
					resource = resource, -- 1916
					catalogCommit = cached.snapshot.commit, -- 1917
					launchError = mobileLaunchErrors[resource.id] -- 1918
				} -- 1905
			end -- 1902
			return items -- 1920
		end, -- 1898
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1921
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1922
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1923
			end), repairIncomplete, isCanceled) -- 1922
		end, -- 1921
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1925
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1926
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1927
			end), isCanceled) -- 1926
		end, -- 1925
		createProject = function(name, language) -- 1929
			local result = projectCreate.createMobileProject(name, language) -- 1930
			if not result.success then -- 1931
				return result -- 1931
			end -- 1931
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1932
			for _index_0 = 1, #_list_0 do -- 1932
				local entry = _list_0[_index_0] -- 1932
				if entry.workDir == result.workDir then -- 1933
					return { -- 1934
						success = true, -- 1934
						entry = entry -- 1934
					} -- 1934
				end -- 1933
			end -- 1932
			return { -- 1935
				success = false, -- 1935
				error = "created-project-not-found" -- 1935
			} -- 1935
		end, -- 1929
		onPlay = function(entry) -- 1936
			return startMobilePlay(entry) -- 1936
		end, -- 1936
		onRemix = function(entry) -- 1937
			if HttpServer.wsConnectionCount > 0 then -- 1938
				return -- 1938
			end -- 1938
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1939
			local originFeed = feedHost -- 1940
			feedHost.visible = false -- 1941
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1943
				entry = entry, -- 1943
				onProjectChanged = function(current) -- 1944
					feedOptions.dirtyProjectPath = current.workDir -- 1944
				end, -- 1944
				onBack = function() -- 1945
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1946
						originFeed:emit("RestoreFeedEntry", entry) -- 1947
						originFeed.visible = true -- 1948
					end -- 1946
				end, -- 1945
				onPlay = function(current) -- 1949
					return startMobilePlay(current) -- 1949
				end -- 1949
			})) -- 1942
		end -- 1937
	} -- 1876
	return restartMobileFeed() -- 1952
end -- 1790
if mobileMode then -- 1954
	applyUIMode(true) -- 1954
end -- 1954
allEntries.revealAtomPieInFeed = function() -- 1956
	if not allEntries.atomPieReveal then -- 1957
		return -- 1957
	end -- 1957
	local _list_0 = getMobileFeedEntries() -- 1958
	for _index_0 = 1, #_list_0 do -- 1958
		local entry = _list_0[_index_0] -- 1958
		if entry.fileName == allEntries.atomPieFocusedFile then -- 1959
			feedHost:emit("RestoreFeedEntry", entry) -- 1960
			allEntries.atomPieReveal = nil -- 1961
			break -- 1962
		end -- 1959
	end -- 1958
end -- 1956
allEntries.openAtomPieProject = function(id) -- 1964
	local atomPieProject = oldRequire("Script.Dev.AtomPieProject") -- 1965
	local status = { } -- 1966
	Log("Info", "Opening AtomPie project " .. tostring(id) .. "…") -- 1967
	local accepted = atomPieProject.open(id, (function(file) -- 1968
		updateEntries() -- 1969
		Log("Info", "AtomPie project ready: " .. tostring(file)) -- 1970
		if allEntries.atomPieStatus == status then -- 1971
			allEntries.atomPieStatus = nil -- 1972
			allEntries.atomPieFocusedFile = Path:replaceExt(file, "") -- 1973
			if not mobileMode then -- 1974
				for i, game in ipairs(gamesInDev) do -- 1975
					if game.fileName == allEntries.atomPieFocusedFile then -- 1976
						table.remove(gamesInDev, i) -- 1977
						table.insert(gamesInDev, 1, game) -- 1978
						break -- 1979
					end -- 1976
				end -- 1975
			end -- 1974
			allEntries.atomPieReveal = true -- 1980
		end -- 1971
	end), (function(message) -- 1981
		Log("Error", "Could not open AtomPie project " .. tostring(id) .. ": " .. tostring(tostring(message))) -- 1982
		status.phase = "error" -- 1983
		status.progress = nil -- 1984
		status.expiresAt = App.runningTime + 10 -- 1985
	end), function(phase, progress) -- 1986
		status.phase = phase -- 1987
		status.progress = progress -- 1988
	end) -- 1968
	if accepted then -- 1989
		allEntries.atomPieStatus = status -- 1989
	end -- 1989
end -- 1964
return _module_0 -- 1
