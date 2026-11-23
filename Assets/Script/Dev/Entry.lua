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
local pcall <const> = pcall -- 11
local pairs <const> = pairs -- 11
local string <const> = string -- 11
local print <const> = print -- 11
local xml <const> = xml -- 11
local teal <const> = teal -- 11
local wait <const> = wait -- 11
local HttpServer <const> = HttpServer -- 11
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
		if not (path == "lualib_bundle" or path == "Script.Dev.AgentHost" or path == "Script.Dev.AgentStoragePanel" or path:match("^Agent[./]")) then -- 24
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
oldRequire("Dev.ImportIDE") -- 101
if not (config.webIDEEnabled ~= nil) then -- 103
	config.webIDEEnabled = true -- 104
end -- 103
App.webIDEEnabled = config.webIDEEnabled -- 105
if not (config.writablePath ~= nil) then -- 107
	config.writablePath = Content.appPath -- 108
end -- 107
if not (config.webIDEConnected ~= nil) then -- 110
	config.webIDEConnected = false -- 111
end -- 110
if (config.fpsLimited ~= nil) then -- 113
	App.fpsLimited = config.fpsLimited -- 114
else -- 116
	config.fpsLimited = App.fpsLimited -- 116
end -- 113
if (config.targetFPS ~= nil) then -- 118
	App.targetFPS = math.floor(config.targetFPS) -- 119
else -- 121
	config.targetFPS = App.targetFPS -- 121
end -- 118
if (config.vsync ~= nil) then -- 123
	View.vsync = config.vsync -- 124
else -- 126
	config.vsync = View.vsync -- 126
end -- 123
if (config.fixedFPS ~= nil) then -- 128
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 129
else -- 131
	config.fixedFPS = Director.scheduler.fixedFPS -- 131
end -- 128
if not (config.showPreview ~= nil) then -- 133
	config.showPreview = true -- 134
end -- 133
if not (config.mobileFeed ~= nil) then -- 136
	local _val_0 = App.platform -- 137
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 137
end -- 136
if not (config.webIDETourCompleted ~= nil) then -- 139
	config.webIDETourCompleted = false -- 140
end -- 139
local showEntry = true -- 143
isDesktop = false -- 145
if (function() -- 146
	local _val_0 = App.platform -- 146
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 146
end)() then -- 146
	isDesktop = true -- 147
	if config.fullScreen then -- 148
		App.fullScreen = true -- 149
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 150
		local size = Size(config.winWidth, config.winHeight) -- 151
		if App.winSize ~= size then -- 152
			App.winSize = size -- 153
		end -- 152
		local winX, winY -- 154
		do -- 154
			local _obj_0 = App.winPosition -- 154
			winX, winY = _obj_0.x, _obj_0.y -- 154
		end -- 154
		if (config.winX ~= nil) then -- 155
			winX = config.winX -- 156
		else -- 158
			config.winX = -1 -- 158
		end -- 155
		if (config.winY ~= nil) then -- 159
			winY = config.winY -- 160
		else -- 162
			config.winY = -1 -- 162
		end -- 159
		App.winPosition = Vec2(winX, winY) -- 163
	end -- 148
	if (config.alwaysOnTop ~= nil) then -- 164
		App.alwaysOnTop = config.alwaysOnTop -- 165
	else -- 167
		config.alwaysOnTop = false -- 167
	end -- 164
	if (config.virtualGamepadEnabled ~= nil) then -- 168
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 169
	else -- 171
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 171
	end -- 168
end -- 146
if (config.themeColor ~= nil) then -- 173
	App.themeColor = Color(config.themeColor) -- 174
else -- 176
	config.themeColor = App.themeColor:toARGB() -- 176
end -- 173
if not (config.locale ~= nil) then -- 178
	config.locale = App.locale -- 179
end -- 178
local showStats = false -- 181
if (config.showStats ~= nil) then -- 182
	showStats = config.showStats -- 183
else -- 185
	config.showStats = showStats -- 185
end -- 182
local showConsole = false -- 187
if (config.showConsole ~= nil) then -- 188
	showConsole = config.showConsole -- 189
else -- 191
	config.showConsole = showConsole -- 191
end -- 188
local showFooter = true -- 193
if (config.showFooter ~= nil) then -- 194
	showFooter = config.showFooter -- 195
else -- 197
	config.showFooter = showFooter -- 197
end -- 194
local setFooterVisible -- 199
setFooterVisible = function(visible) -- 199
	if visible == nil then -- 199
		visible = true -- 199
	end -- 199
	showFooter = visible -- 200
	config.showFooter = showFooter -- 201
end -- 199
_module_0["setFooterVisible"] = setFooterVisible -- 199
local filterBuf = Buffer(20) -- 203
if (config.filter ~= nil) then -- 204
	filterBuf.text = config.filter -- 205
else -- 207
	config.filter = "" -- 207
end -- 204
local engineDev = false -- 209
if (config.engineDev ~= nil) then -- 210
	engineDev = config.engineDev -- 211
else -- 213
	config.engineDev = engineDev -- 213
end -- 210
if (config.webProfiler ~= nil) then -- 215
	Director.profilerSending = config.webProfiler -- 216
else -- 218
	config.webProfiler = true -- 218
	Director.profilerSending = true -- 219
end -- 215
if not (config.drawerWidth ~= nil) then -- 221
	config.drawerWidth = 200 -- 222
end -- 221
_module_0.getConfig = function() -- 224
	return config -- 224
end -- 224
_module_0.getEngineDev = function() -- 225
	if not App.debugging then -- 226
		return false -- 226
	end -- 226
	return config.engineDev -- 227
end -- 225
local _anon_func_0 = function() -- 232
	local _val_0 = App.platform -- 232
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 232
end -- 232
_module_0.connectWebIDE = function(embedded) -- 229
	if embedded == nil then -- 229
		embedded = false -- 229
	end -- 229
	if not config.webIDEConnected then -- 230
		config.webIDEConnected = true -- 231
		if not embedded and _anon_func_0() then -- 232
			local ratio = App.winSize.width / App.visualSize.width -- 233
			App.winSize = Size(640 * ratio, 480 * ratio) -- 234
		end -- 232
	end -- 230
end -- 229
local updateState = nil -- 237
local checkForUpdates -- 238
do -- 238
	local updateSceneCache = moduleCache -- 239
	moduleCache = { } -- 240
	local updater = oldRequire("Tools.SelfUpdater.Service") -- 241
	moduleCache = updateSceneCache -- 242
	updateState = updater.getState() -- 244
	if config.updateNotificationVersion ~= App.version then -- 245
		config.updateNotification = false -- 246
	end -- 245
	config.updateNotificationVersion = App.version -- 247
	updateState.available = config.updateNotification == true -- 248
	local publishUpdateState -- 249
	publishUpdateState = function(state) -- 249
		updateState = state -- 250
		config.updateNotification = state.available -- 251
		config.updateNotificationVersion = App.version -- 252
		config.ignoredUpdateVersion = state.ignoredVersion -- 253
		if state.checkedAt > 0 and not state.usedCache and state.checkedAt ~= config.lastUpdateCheck then -- 254
			config.lastUpdateCheck = state.checkedAt -- 255
		end -- 254
	end -- 249
	updater.bindEntryState((function() -- 256
		return updateState -- 256
	end), publishUpdateState, config.ignoredUpdateVersion) -- 256
	checkForUpdates = function(manual, source) -- 257
		if manual == nil then -- 257
			manual = true -- 257
		end -- 257
		if source == nil then -- 257
			source = nil -- 257
		end -- 257
		if not manual then -- 258
			if App.platform == "Emscripten" then -- 259
				return false -- 259
			end -- 259
			if (config.lastUpdateCheck ~= nil) and os.difftime(os.time(), config.lastUpdateCheck) < 7 * 24 * 60 * 60 then -- 260
				return false -- 261
			end -- 260
		end -- 258
		return updater.checkForUpdates(source) -- 262
	end -- 257
end -- 238
_module_0.getUpdateState = function() -- 263
	return updateState -- 263
end -- 263
_module_0.checkForUpdates = checkForUpdates -- 264
thread(function() -- 265
	sleep(2) -- 266
	return checkForUpdates(false) -- 267
end) -- 265
local Set, Struct, LintYueGlobals -- 269
do -- 269
	local _obj_0 = require("Utils") -- 269
	Set, Struct, LintYueGlobals = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals -- 269
end -- 269
local yueext = yue.options.extension -- 270
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 272
local building = false -- 274
local getAllFiles -- 276
getAllFiles = function(path, exts, recursive) -- 276
	if recursive == nil then -- 276
		recursive = true -- 276
	end -- 276
	local filters = Set(exts) -- 277
	local files -- 278
	if recursive then -- 278
		files = Content:getAllFiles(path) -- 279
	else -- 281
		files = Content:getFiles(path) -- 281
	end -- 278
	local _accum_0 = { } -- 282
	local _len_0 = 1 -- 282
	for _index_0 = 1, #files do -- 282
		local file = files[_index_0] -- 282
		if not filters[Path:getExt(file)] then -- 283
			goto _continue_0 -- 283
		end -- 283
		_accum_0[_len_0] = file -- 284
		_len_0 = _len_0 + 1 -- 283
		::_continue_0:: -- 283
	end -- 282
	return _accum_0 -- 282
end -- 276
_module_0["getAllFiles"] = getAllFiles -- 276
local getFileEntries -- 286
getFileEntries = function(path, recursive, excludeFiles) -- 286
	if recursive == nil then -- 286
		recursive = true -- 286
	end -- 286
	if excludeFiles == nil then -- 286
		excludeFiles = nil -- 286
	end -- 286
	local entries = { } -- 287
	local excludes -- 288
	if excludeFiles then -- 288
		excludes = Set(excludeFiles) -- 289
	end -- 288
	local _list_0 = getAllFiles(path, { -- 290
		"lua", -- 290
		"xml", -- 290
		yueext, -- 290
		"tl" -- 290
	}, recursive) -- 290
	for _index_0 = 1, #_list_0 do -- 290
		local file = _list_0[_index_0] -- 290
		local entryName = Path:getName(file) -- 291
		if excludes and excludes[entryName] then -- 292
			goto _continue_0 -- 293
		end -- 292
		local fileName = Path:replaceExt(file, "") -- 294
		fileName = Path(path, fileName) -- 295
		local entryAdded -- 296
		for _index_1 = 1, #entries do -- 296
			local _des_0 = entries[_index_1] -- 296
			local ename, efile = _des_0.entryName, _des_0.fileName -- 296
			if entryName == ename and efile == fileName then -- 297
				entryAdded = true -- 297
				break -- 297
			end -- 297
		end -- 296
		if entryAdded then -- 298
			goto _continue_0 -- 298
		end -- 298
		local entry = { -- 299
			entryName = entryName, -- 299
			fileName = fileName -- 299
		} -- 299
		entries[#entries + 1] = entry -- 300
		::_continue_0:: -- 291
	end -- 290
	table.sort(entries, function(a, b) -- 301
		return a.entryName < b.entryName -- 301
	end) -- 301
	return entries -- 302
end -- 286
local allEntries = { -- 304
	dirty = { }, -- 304
	hasDirty = false, -- 304
	runId = 0 -- 304
} -- 304
local _anon_func_1 = function(file) -- 350
	local _val_0 = Path:getExt(file) -- 350
	return "ts" == _val_0 or "tsx" == _val_0 -- 350
end -- 350
allEntries.scanDir = function(path, dir, noPreview) -- 306
	if noPreview == nil then -- 306
		noPreview = false -- 306
	end -- 306
	local entries = { } -- 307
	if not dir:match("^%.") then -- 308
		local root = Path(path, dir) -- 309
		local imported = Content:exist(Path(root, ".git", "dora-import-repository")) -- 310
		local exts = { -- 311
			"lua", -- 311
			"xml", -- 311
			yueext, -- 311
			"tl", -- 311
			"wasm" -- 311
		} -- 311
		if imported then -- 312
			exts[#exts + 1] = "ts" -- 313
			exts[#exts + 1] = "tsx" -- 314
		end -- 312
		local _list_0 = getAllFiles(root, exts) -- 315
		for _index_0 = 1, #_list_0 do -- 315
			local file = _list_0[_index_0] -- 315
			if "init" == Path:getName(file):lower() then -- 316
				local fileName = Path:replaceExt(file, "") -- 317
				fileName = Path(path, dir, fileName) -- 318
				local projectPath = Path:getPath(fileName) -- 319
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 320
				local repo = nil -- 321
				if Content:exist(repoFile) then -- 322
					local str = Content:load(repoFile) -- 323
					if str then -- 323
						repo = json.decode(str) -- 324
					end -- 323
				end -- 322
				local entryName = Path:getName(projectPath) -- 325
				local entryAdded -- 326
				for _index_1 = 1, #entries do -- 326
					local _des_0 = entries[_index_1] -- 326
					local ename, efile = _des_0.entryName, _des_0.fileName -- 326
					if entryName == ename and efile == fileName then -- 327
						entryAdded = true -- 327
						break -- 327
					end -- 327
				end -- 326
				if entryAdded then -- 328
					goto _continue_0 -- 328
				end -- 328
				local examples = { } -- 329
				local tests = { } -- 330
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 331
				if Content:exist(examplePath) then -- 332
					local _list_1 = getFileEntries(examplePath) -- 333
					for _index_1 = 1, #_list_1 do -- 333
						local _des_0 = _list_1[_index_1] -- 333
						local name, ePath = _des_0.entryName, _des_0.fileName -- 333
						local entry = { -- 335
							entryName = name, -- 335
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 336
							workDir = projectPath -- 337
						} -- 334
						examples[#examples + 1] = entry -- 339
					end -- 333
				end -- 332
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 340
				if Content:exist(testPath) then -- 341
					local _list_1 = getFileEntries(testPath) -- 342
					for _index_1 = 1, #_list_1 do -- 342
						local _des_0 = _list_1[_index_1] -- 342
						local name, tPath = _des_0.entryName, _des_0.fileName -- 342
						local entry = { -- 344
							entryName = name, -- 344
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 345
							workDir = projectPath -- 346
						} -- 343
						tests[#tests + 1] = entry -- 348
					end -- 342
				end -- 341
				local entry = { -- 349
					entryName = entryName, -- 349
					fileName = fileName, -- 349
					projectPath = projectPath, -- 349
					examples = examples, -- 349
					tests = tests, -- 349
					repo = repo -- 349
				} -- 349
				entry.needsBuild = imported and _anon_func_1(file) and not Content:exist(fileName .. ".lua") -- 350
				local bannerFile -- 351
				do -- 351
					local _val_0 -- 351
					repeat -- 351
						if noPreview then -- 352
							_val_0 = nil -- 352
							break -- 352
						end -- 352
						if not config.showPreview then -- 353
							_val_0 = nil -- 353
							break -- 353
						end -- 353
						local f = Path(projectPath, ".dora", "banner.jpg") -- 354
						if Content:exist(f) then -- 355
							_val_0 = f -- 355
							break -- 355
						end -- 355
						f = Path(projectPath, ".dora", "banner.png") -- 356
						if Content:exist(f) then -- 357
							_val_0 = f -- 357
							break -- 357
						end -- 357
						f = Path(projectPath, "Image", "banner.jpg") -- 358
						if Content:exist(f) then -- 359
							_val_0 = f -- 359
							break -- 359
						end -- 359
						f = Path(projectPath, "Image", "banner.png") -- 360
						if Content:exist(f) then -- 361
							_val_0 = f -- 361
							break -- 361
						end -- 361
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 362
						if Content:exist(f) then -- 363
							_val_0 = f -- 363
							break -- 363
						end -- 363
					until true -- 351
					bannerFile = _val_0 -- 351
				end -- 351
				if bannerFile then -- 365
					entry.bannerFile = bannerFile -- 368
					thread(function() -- 369
						if Cache:loadAsync(bannerFile) then -- 370
							local bannerTex = Texture2D(bannerFile) -- 371
							if bannerTex then -- 371
								entry.bannerTex = bannerTex -- 372
							end -- 371
						end -- 370
					end) -- 369
				end -- 365
				entries[#entries + 1] = entry -- 373
			end -- 316
			::_continue_0:: -- 316
		end -- 315
	end -- 308
	return entries -- 374
end -- 306
local getProjectEntries -- 376
getProjectEntries = function(path, noPreview) -- 376
	if noPreview == nil then -- 376
		noPreview = false -- 376
	end -- 376
	local entries = { } -- 377
	local _list_0 = Content:getDirs(path) -- 378
	for _index_0 = 1, #_list_0 do -- 378
		local dir = _list_0[_index_0] -- 378
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 379
		for _index_1 = 1, #_list_1 do -- 379
			local entry = _list_1[_index_1] -- 379
			entries[#entries + 1] = entry -- 380
		end -- 379
	end -- 378
	table.sort(entries, function(a, b) -- 381
		return a.entryName < b.entryName -- 381
	end) -- 381
	return entries -- 382
end -- 376
_module_0["getProjectEntries"] = getProjectEntries -- 376
local gamesInDev -- 384
local doraTools -- 385
local windowsExport = { -- 387
	busy = false -- 387
} -- 387
allEntries.exportWindowsGame = function(game, title) -- 388
	if windowsExport.busy then -- 389
		return -- 389
	end -- 389
	windowsExport.busy = true -- 390
	windowsExport.message = nil -- 391
	return App:openFileDialog(true, function(folder) -- 392
		if folder == "" then -- 393
			windowsExport.busy = false -- 394
			return -- 395
		end -- 393
		windowsExport.routine = thread(function() -- 396
			local success, result = pcall(function() -- 397
				local exportWindows = oldRequire("Script.Dev.NativeGameExport").exportWindows -- 398
				return exportWindows(game.projectPath, game.fileName, title, folder) -- 399
			end) -- 397
			windowsExport.busy = false -- 400
			windowsExport.routine = nil -- 401
			if success then -- 402
				windowsExport.message = (useChinese and "已导出 " or "Exported ") .. result -- 403
			else -- 405
				windowsExport.message = (useChinese and "导出失败：" or "Export failed: ") .. tostring(result) -- 405
			end -- 402
		end) -- 396
	end) -- 392
end -- 388
local isToolEntry -- 407
isToolEntry = function(entry) -- 407
	do -- 408
		local _type_0 = type(entry) -- 408
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 408
		if _tab_0 then -- 408
			local categories -- 408
			do -- 408
				local _obj_0 = entry.repo -- 408
				local _type_1 = type(_obj_0) -- 408
				if "table" == _type_1 or "userdata" == _type_1 then -- 408
					categories = _obj_0.categories -- 408
				end -- 408
			end -- 408
			if categories ~= nil then -- 408
				for _index_0 = 1, #categories do -- 409
					local category = categories[_index_0] -- 409
					if "string" == type(category) and category:lower() == "tool" then -- 410
						return true -- 411
					end -- 410
				end -- 409
			end -- 408
		end -- 408
	end -- 408
	return false -- 407
end -- 407
local getEntryTitle -- 413
getEntryTitle = function(entry) -- 413
	local title -- 414
	do -- 414
		local repo = entry.repo -- 414
		if repo then -- 414
			if repo.title and "table" == type(repo.title) then -- 415
				if useChinese then -- 416
					title = repo.title.zh -- 416
				else -- 416
					title = repo.title.en -- 416
				end -- 416
			end -- 415
		end -- 414
	end -- 414
	if title ~= nil then -- 417
		return title -- 417
	else -- 417
		return entry.entryName -- 417
	end -- 417
end -- 413
allEntries.rebuildEntries = function() -- 419
	gamesInDev = { } -- 420
	do -- 421
		local _accum_0 = { } -- 421
		local _len_0 = 1 -- 421
		local _list_0 = allEntries.builtinTools -- 421
		for _index_0 = 1, #_list_0 do -- 421
			local tool = _list_0[_index_0] -- 421
			_accum_0[_len_0] = tool -- 421
			_len_0 = _len_0 + 1 -- 421
		end -- 421
		doraTools = _accum_0 -- 421
	end -- 421
	local _list_0 = allEntries.projectEntries -- 422
	for _index_0 = 1, #_list_0 do -- 422
		local entry = _list_0[_index_0] -- 422
		if isToolEntry(entry) then -- 423
			entry.kind = "tool" -- 424
			doraTools[#doraTools + 1] = entry -- 425
		else -- 427
			entry.kind = "game" -- 427
			gamesInDev[#gamesInDev + 1] = entry -- 428
		end -- 423
	end -- 422
	for i = #allEntries, 1, -1 do -- 429
		allEntries[i] = nil -- 430
	end -- 429
	for _index_0 = 1, #gamesInDev do -- 431
		local game = gamesInDev[_index_0] -- 431
		allEntries[#allEntries + 1] = game -- 432
		local examples, tests = game.examples, game.tests -- 433
		for _index_1 = 1, #examples do -- 434
			local example = examples[_index_1] -- 434
			allEntries[#allEntries + 1] = example -- 435
		end -- 434
		for _index_1 = 1, #tests do -- 436
			local test = tests[_index_1] -- 436
			allEntries[#allEntries + 1] = test -- 437
		end -- 436
	end -- 431
end -- 419
local updateEntries -- 439
updateEntries = function() -- 439
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 440
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 441
	local _list_0 = allEntries.builtinTools -- 442
	for _index_0 = 1, #_list_0 do -- 442
		local tool = _list_0[_index_0] -- 442
		tool.kind = "tool" -- 443
		tool.builtin = true -- 444
		if tool.entryName == "RepositoryImporter" then -- 445
			tool.repo = { -- 446
				title = { -- 446
					en = "Import repository", -- 446
					zh = "从仓库导入" -- 446
				} -- 446
			} -- 446
		end -- 445
	end -- 442
	return allEntries.rebuildEntries() -- 447
end -- 439
allEntries.refreshDirtyProjects = function() -- 449
	if not allEntries.hasDirty then -- 450
		return -- 450
	end -- 450
	local dirty = allEntries.dirty -- 451
	allEntries.dirty = { } -- 452
	allEntries.hasDirty = false -- 453
	for projectPath in pairs(dirty) do -- 454
		do -- 455
			local _accum_0 = { } -- 455
			local _len_0 = 1 -- 455
			local _list_0 = allEntries.projectEntries -- 455
			for _index_0 = 1, #_list_0 do -- 455
				local entry = _list_0[_index_0] -- 455
				if entry.projectPath ~= projectPath then -- 455
					_accum_0[_len_0] = entry -- 455
					_len_0 = _len_0 + 1 -- 455
				end -- 455
			end -- 455
			allEntries.projectEntries = _accum_0 -- 455
		end -- 455
		local parentPath = Path:getPath(projectPath) -- 456
		local dir = Path:getFilename(projectPath) -- 457
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 458
		for _index_0 = 1, #_list_0 do -- 458
			local entry = _list_0[_index_0] -- 458
			if entry.projectPath == projectPath then -- 459
				do -- 460
					local _obj_0 = allEntries.projectEntries -- 460
					_obj_0[#_obj_0 + 1] = entry -- 460
				end -- 460
				break -- 461
			end -- 459
		end -- 458
	end -- 454
	table.sort(allEntries.projectEntries, function(a, b) -- 462
		return a.entryName < b.entryName -- 462
	end) -- 462
	return allEntries.rebuildEntries() -- 463
end -- 449
updateEntries() -- 465
local getLaunchEntries -- 467
getLaunchEntries = function(refresh) -- 467
	if refresh == nil then -- 467
		refresh = false -- 467
	end -- 467
	if refresh then -- 468
		updateEntries() -- 468
	end -- 468
	local toInfo -- 469
	toInfo = function(entry, kind) -- 469
		local file = entry.fileName -- 470
		local asProj = not entry.builtin -- 471
		return { -- 473
			name = getEntryTitle(entry), -- 473
			file = file, -- 474
			kind = kind, -- 475
			asProj = asProj -- 476
		} -- 472
	end -- 469
	local games -- 478
	do -- 478
		local _accum_0 = { } -- 478
		local _len_0 = 1 -- 478
		for _index_0 = 1, #gamesInDev do -- 478
			local game = gamesInDev[_index_0] -- 478
			_accum_0[_len_0] = toInfo(game, "game") -- 478
			_len_0 = _len_0 + 1 -- 478
		end -- 478
		games = _accum_0 -- 478
	end -- 478
	local tools -- 479
	do -- 479
		local _accum_0 = { } -- 479
		local _len_0 = 1 -- 479
		for _index_0 = 1, #doraTools do -- 479
			local tool = doraTools[_index_0] -- 479
			_accum_0[_len_0] = toInfo(tool, "tool") -- 479
			_len_0 = _len_0 + 1 -- 479
		end -- 479
		tools = _accum_0 -- 479
	end -- 479
	return { -- 480
		games = games, -- 480
		tools = tools -- 480
	} -- 480
end -- 467
_module_0["getLaunchEntries"] = getLaunchEntries -- 467
local _anon_func_2 = function(entry, useChinese) -- 497
	local _obj_0 = entry.repo -- 497
	if _obj_0 ~= nil then -- 497
		local _obj_1 = _obj_0.description -- 497
		if _obj_1 ~= nil then -- 497
			return _obj_1[useChinese and "zh" or "en"] -- 497
		end -- 497
		return nil -- 497
	end -- 497
	return nil -- 497
end -- 497
local getMobileFeedEntries -- 482
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 482
	if refresh == nil then -- 482
		refresh = false -- 482
	end -- 482
	if dirtyProjectPath == nil then -- 482
		dirtyProjectPath = nil -- 482
	end -- 482
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 483
		allEntries.dirty[dirtyProjectPath] = true -- 484
		allEntries.hasDirty = true -- 485
	end -- 483
	if refresh then -- 486
		allEntries.dirty = { } -- 487
		allEntries.hasDirty = false -- 488
		updateEntries() -- 489
	else -- 491
		allEntries.refreshDirtyProjects() -- 491
	end -- 486
	local items = { } -- 492
	for _index_0 = 1, #gamesInDev do -- 493
		local entry = gamesInDev[_index_0] -- 493
		items[#items + 1] = { -- 495
			id = entry.entryName, -- 495
			title = getEntryTitle(entry), -- 496
			description = _anon_func_2(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 497
			fileName = entry.fileName, -- 498
			workDir = Path:getPath(entry.fileName), -- 499
			bannerFile = entry.bannerFile, -- 500
			needsBuild = entry.needsBuild, -- 501
			kind = "local" -- 502
		} -- 494
	end -- 493
	return items -- 504
end -- 482
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 482
local doCompile -- 506
doCompile = function(minify) -- 506
	if building then -- 507
		return -- 507
	end -- 507
	building = true -- 508
	local startTime = App.runningTime -- 509
	local luaFiles = { } -- 510
	local yueFiles = { } -- 511
	local xmlFiles = { } -- 512
	local tlFiles = { } -- 513
	local writablePath = Content.writablePath -- 514
	local buildPaths = { -- 516
		{ -- 517
			Content.assetPath, -- 517
			Path(writablePath, ".build"), -- 518
			"" -- 519
		} -- 516
	} -- 515
	for _index_0 = 1, #gamesInDev do -- 522
		local _des_0 = gamesInDev[_index_0] -- 522
		local fileName = _des_0.fileName -- 522
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 523
		buildPaths[#buildPaths + 1] = { -- 525
			Path(writablePath, gamePath), -- 525
			Path(writablePath, ".build", gamePath), -- 526
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 527
			gamePath -- 528
		} -- 524
	end -- 522
	for _index_0 = 1, #buildPaths do -- 529
		local _des_0 = buildPaths[_index_0] -- 529
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 529
		if not Content:exist(inputPath) then -- 530
			goto _continue_0 -- 530
		end -- 530
		local _list_0 = getAllFiles(inputPath, { -- 532
			"lua" -- 532
		}) -- 532
		for _index_1 = 1, #_list_0 do -- 532
			local file = _list_0[_index_1] -- 532
			luaFiles[#luaFiles + 1] = { -- 534
				file, -- 534
				Path(inputPath, file), -- 535
				Path(outputPath, file), -- 536
				gamePath -- 537
			} -- 533
		end -- 532
		local _list_1 = getAllFiles(inputPath, { -- 539
			yueext -- 539
		}) -- 539
		for _index_1 = 1, #_list_1 do -- 539
			local file = _list_1[_index_1] -- 539
			yueFiles[#yueFiles + 1] = { -- 541
				file, -- 541
				Path(inputPath, file), -- 542
				Path(outputPath, Path:replaceExt(file, "lua")), -- 543
				searchPath, -- 544
				gamePath -- 545
			} -- 540
		end -- 539
		local _list_2 = getAllFiles(inputPath, { -- 547
			"xml" -- 547
		}) -- 547
		for _index_1 = 1, #_list_2 do -- 547
			local file = _list_2[_index_1] -- 547
			xmlFiles[#xmlFiles + 1] = { -- 549
				file, -- 549
				Path(inputPath, file), -- 550
				Path(outputPath, Path:replaceExt(file, "lua")), -- 551
				gamePath -- 552
			} -- 548
		end -- 547
		local _list_3 = getAllFiles(inputPath, { -- 554
			"tl" -- 554
		}) -- 554
		for _index_1 = 1, #_list_3 do -- 554
			local file = _list_3[_index_1] -- 554
			if not file:match(".*%.d%.tl$") then -- 555
				tlFiles[#tlFiles + 1] = { -- 557
					file, -- 557
					Path(inputPath, file), -- 558
					Path(outputPath, Path:replaceExt(file, "lua")), -- 559
					searchPath, -- 560
					gamePath -- 561
				} -- 556
			end -- 555
		end -- 554
		::_continue_0:: -- 530
	end -- 529
	local paths -- 563
	do -- 563
		local _tbl_0 = { } -- 563
		local _list_0 = { -- 564
			luaFiles, -- 564
			yueFiles, -- 564
			xmlFiles, -- 564
			tlFiles -- 564
		} -- 564
		for _index_0 = 1, #_list_0 do -- 564
			local files = _list_0[_index_0] -- 564
			for _index_1 = 1, #files do -- 565
				local file = files[_index_1] -- 565
				_tbl_0[Path:getPath(file[3])] = true -- 563
			end -- 563
		end -- 563
		paths = _tbl_0 -- 563
	end -- 563
	for path in pairs(paths) do -- 567
		Content:mkdir(path) -- 567
	end -- 567
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 569
	local fileCount = 0 -- 570
	local errors = { } -- 571
	for _index_0 = 1, #yueFiles do -- 572
		local _des_0 = yueFiles[_index_0] -- 572
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 572
		local filename -- 573
		if gamePath then -- 573
			filename = Path(gamePath, file) -- 573
		else -- 573
			filename = file -- 573
		end -- 573
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 574
			if not codes then -- 575
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 576
				return -- 577
			end -- 575
			local success, result = LintYueGlobals(codes, globals) -- 578
			local yueCodes -- 579
			if not success then -- 580
				yueCodes = Content:load(input) -- 581
				if yueCodes then -- 581
					local CheckTIC80Code -- 582
					do -- 582
						local _obj_0 = require("Utils") -- 582
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 582
					end -- 582
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 583
					if isTIC80 then -- 584
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 585
					end -- 584
				end -- 581
			end -- 580
			if success then -- 586
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 587
			else -- 589
				if yueCodes then -- 589
					local globalErrors = { } -- 590
					for _index_1 = 1, #result do -- 591
						local _des_1 = result[_index_1] -- 591
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 591
						local countLine = 1 -- 592
						local code = "" -- 593
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 594
							if countLine == line then -- 595
								code = lineCode -- 596
								break -- 597
							end -- 595
							countLine = countLine + 1 -- 598
						end -- 594
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 599
					end -- 591
					if #globalErrors > 0 then -- 600
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 600
					end -- 600
				else -- 602
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 602
				end -- 589
				if #errors == 0 then -- 603
					return codes -- 603
				end -- 603
			end -- 586
		end, function(success) -- 574
			if success then -- 604
				print("Yue compiled: " .. tostring(filename)) -- 604
			end -- 604
			fileCount = fileCount + 1 -- 605
		end) -- 574
	end -- 572
	thread(function() -- 607
		for _index_0 = 1, #xmlFiles do -- 608
			local _des_0 = xmlFiles[_index_0] -- 608
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 608
			local filename -- 609
			if gamePath then -- 609
				filename = Path(gamePath, file) -- 609
			else -- 609
				filename = file -- 609
			end -- 609
			local sourceCodes = Content:loadAsync(input) -- 610
			local codes, err = xml.tolua(sourceCodes) -- 611
			if not codes then -- 612
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 613
			else -- 615
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 615
				print("Xml compiled: " .. tostring(filename)) -- 616
			end -- 612
			fileCount = fileCount + 1 -- 617
		end -- 608
	end) -- 607
	thread(function() -- 619
		for _index_0 = 1, #tlFiles do -- 620
			local _des_0 = tlFiles[_index_0] -- 620
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 620
			local filename -- 621
			if gamePath then -- 621
				filename = Path(gamePath, file) -- 621
			else -- 621
				filename = file -- 621
			end -- 621
			local sourceCodes = Content:loadAsync(input) -- 622
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 623
			if not codes then -- 624
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 625
			else -- 627
				Content:saveAsync(output, codes) -- 627
				print("Teal compiled: " .. tostring(filename)) -- 628
			end -- 624
			fileCount = fileCount + 1 -- 629
		end -- 620
	end) -- 619
	return thread(function() -- 631
		wait(function() -- 632
			return fileCount == totalFiles -- 632
		end) -- 632
		if minify then -- 633
			local _list_0 = { -- 634
				yueFiles, -- 634
				xmlFiles, -- 634
				tlFiles -- 634
			} -- 634
			for _index_0 = 1, #_list_0 do -- 634
				local files = _list_0[_index_0] -- 634
				for _index_1 = 1, #files do -- 634
					local file = files[_index_1] -- 634
					local output = Path:replaceExt(file[3], "lua") -- 635
					luaFiles[#luaFiles + 1] = { -- 637
						Path:replaceExt(file[1], "lua"), -- 637
						output, -- 638
						output -- 639
					} -- 636
				end -- 634
			end -- 634
			local FormatMini -- 641
			do -- 641
				local _obj_0 = require("luaminify") -- 641
				FormatMini = _obj_0.FormatMini -- 641
			end -- 641
			for _index_0 = 1, #luaFiles do -- 642
				local _des_0 = luaFiles[_index_0] -- 642
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 642
				if Content:exist(input) then -- 643
					local sourceCodes = Content:loadAsync(input) -- 644
					local res, err = FormatMini(sourceCodes) -- 645
					if res then -- 646
						Content:saveAsync(output, res) -- 647
						print("Minify: " .. tostring(file)) -- 648
					else -- 650
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 650
					end -- 646
				else -- 652
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 652
				end -- 643
			end -- 642
			package.loaded["luaminify.FormatMini"] = nil -- 653
			package.loaded["luaminify.ParseLua"] = nil -- 654
			package.loaded["luaminify.Scope"] = nil -- 655
			package.loaded["luaminify.Util"] = nil -- 656
		end -- 633
		local errorMessage = table.concat(errors, "\n") -- 657
		if errorMessage ~= "" then -- 658
			print(errorMessage) -- 658
		end -- 658
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 659
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 660
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 661
		Content:clearPathCache() -- 662
		teal.clear() -- 663
		yue.clear() -- 664
		building = false -- 665
	end) -- 631
end -- 506
local doClean -- 667
doClean = function() -- 667
	if building then -- 668
		return -- 668
	end -- 668
	local writablePath = Content.writablePath -- 669
	local targetDir = Path(writablePath, ".build") -- 670
	Content:clearPathCache() -- 671
	if Content:remove(targetDir) then -- 672
		return print("Cleaned: " .. tostring(targetDir)) -- 673
	end -- 672
end -- 667
local screenScale = 2.0 -- 675
local scaleContent = false -- 676
local isInEntry = true -- 677
local currentEntry = nil -- 678
local footerWindow = nil -- 680
local entryWindow = nil -- 681
local testingThread = nil -- 682
local mobileMode = config.mobileFeed -- 683
allEntries.mobileControl = { } -- 684
local feedHost = nil -- 685
local remixHost = nil -- 686
local startMobileUI = nil -- 687
allEntries.mobileControl.webControlled = false -- 688
allEntries.mobileControl.mobileHosts = { } -- 689
allEntries.mobileControl.suspendedMobileHosts = { } -- 690
local trackMobileHost -- 692
trackMobileHost = function(host) -- 692
	do -- 693
		local _accum_0 = { } -- 693
		local _len_0 = 1 -- 693
		local _list_0 = allEntries.mobileControl.mobileHosts -- 693
		for _index_0 = 1, #_list_0 do -- 693
			local item = _list_0[_index_0] -- 693
			if item.parent then -- 693
				_accum_0[_len_0] = item -- 693
				_len_0 = _len_0 + 1 -- 693
			end -- 693
		end -- 693
		allEntries.mobileControl.mobileHosts = _accum_0 -- 693
	end -- 693
	do -- 694
		local _obj_0 = allEntries.mobileControl.mobileHosts -- 694
		_obj_0[#_obj_0 + 1] = host -- 694
	end -- 694
	return host -- 695
end -- 692
local clearMobileUI -- 697
clearMobileUI = function() -- 697
	local _list_0 = allEntries.mobileControl.mobileHosts -- 698
	for _index_0 = 1, #_list_0 do -- 698
		local host = _list_0[_index_0] -- 698
		if host.parent then -- 699
			host:removeFromParent(true) -- 699
		end -- 699
	end -- 698
	allEntries.mobileControl.mobileHosts = { } -- 700
	allEntries.mobileControl.suspendedMobileHosts = { } -- 701
	feedHost = nil -- 702
	remixHost = nil -- 703
end -- 697
local syncWebIDEControl -- 705
syncWebIDEControl = function() -- 705
	local connected = HttpServer.wsConnectionCount > 0 -- 706
	if connected then -- 707
		allEntries.mobileControl.pendingUIMode = nil -- 708
		local _list_0 = allEntries.mobileControl.mobileHosts -- 709
		for _index_0 = 1, #_list_0 do -- 709
			local host = _list_0[_index_0] -- 709
			if not host.parent then -- 710
				goto _continue_0 -- 710
			end -- 710
			if not (allEntries.mobileControl.suspendedMobileHosts[host] ~= nil) then -- 711
				allEntries.mobileControl.suspendedMobileHosts[host] = host.visible -- 712
				host:emit("SuspendLocalUI") -- 713
			end -- 711
			host.visible = false -- 714
			::_continue_0:: -- 710
		end -- 709
	elseif allEntries.mobileControl.webControlled then -- 715
		for host, visible in pairs(allEntries.mobileControl.suspendedMobileHosts) do -- 716
			if host.parent then -- 717
				host.visible = visible -- 718
				host:emit("ResumeLocalUI") -- 719
			end -- 717
		end -- 716
		allEntries.mobileControl.suspendedMobileHosts = { } -- 720
	end -- 707
	allEntries.mobileControl.webControlled = connected -- 721
	return connected -- 722
end -- 705
local getUIMode -- 724
getUIMode = function() -- 724
	return mobileMode and "mobile" or "traditional" -- 724
end -- 724
_module_0["getUIMode"] = getUIMode -- 724
local setUIMode -- 725
setUIMode = function(mode) -- 725
	if not (("mobile" == mode or "traditional" == mode)) then -- 726
		return false -- 726
	end -- 726
	if HttpServer.wsConnectionCount > 0 then -- 727
		return false -- 727
	end -- 727
	if (allEntries.mobileControl.pendingUIMode ~= nil) or not isInEntry or testingThread then -- 728
		return false -- 728
	end -- 728
	local wantsMobile = mode == "mobile" -- 729
	if wantsMobile == mobileMode then -- 730
		return true -- 730
	end -- 730
	if mobileMode then -- 731
		if not (feedHost and feedHost.visible) then -- 732
			return false -- 732
		end -- 732
		feedHost:emit("SwitchUIMode") -- 734
		return allEntries.mobileControl.pendingUIMode == false -- 735
	end -- 731
	allEntries.mobileControl.pendingUIMode = true -- 736
	return true -- 737
end -- 725
_module_0["setUIMode"] = setUIMode -- 725
local applyUIMode -- 739
applyUIMode = function(enabled) -- 739
	if HttpServer.wsConnectionCount > 0 then -- 741
		return false -- 741
	end -- 741
	if enabled then -- 742
		local ok, err = pcall(startMobileUI) -- 743
		if not ok then -- 744
			if feedHost then -- 745
				feedHost:removeFromParent(true) -- 745
			end -- 745
			feedHost = nil -- 746
			mobileMode = false -- 747
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 748
			return false -- 749
		end -- 744
	else -- 751
		clearMobileUI() -- 751
		updateEntries() -- 752
	end -- 742
	mobileMode = enabled -- 753
	config.mobileFeed = enabled -- 754
	return true -- 755
end -- 739
local setupEventHandlers = nil -- 757
local enterEntryAsync = nil -- 758
local allClear -- 760
allClear = function() -- 760
	if allEntries.mobileControl.webControlled or HttpServer.wsConnectionCount > 0 then -- 762
		clearMobileUI() -- 762
	end -- 762
	local systemNodes = { } -- 765
	local preserveSystemNode -- 766
	preserveSystemNode = function(node) -- 766
		if systemNodes[node] then -- 767
			return -- 767
		end -- 767
		systemNodes[node] = true -- 768
		do -- 769
			local clip = tolua.cast(node, "ClipNode") -- 769
			if clip then -- 769
				if clip.stencil then -- 770
					preserveSystemNode(clip.stencil) -- 770
				end -- 770
			end -- 769
		end -- 769
		return node:eachChild(function(child) -- 771
			preserveSystemNode(child) -- 772
			return false -- 773
		end) -- 771
	end -- 766
	for _index_0 = 1, #Routine do -- 774
		local routine = Routine[_index_0] -- 774
		if footerWindow == routine or entryWindow == routine or testingThread == routine or windowsExport.routine == routine then -- 776
			goto _continue_0 -- 777
		else -- 779
			Routine:remove(routine) -- 779
		end -- 775
		::_continue_0:: -- 775
	end -- 774
	for _index_0 = 1, #moduleCache do -- 780
		local module = moduleCache[_index_0] -- 780
		package.loaded[module] = nil -- 781
	end -- 780
	moduleCache = { } -- 782
	Director:cleanup() -- 783
	Entity:clear() -- 784
	Platformer.Data:clear() -- 785
	Platformer.UnitAction:clear() -- 786
	Audio:stopAll(0.2) -- 787
	Struct:clear() -- 788
	View.nearPlaneDistance = 0.1 -- 791
	View.farPlaneDistance = 10000 -- 792
	View.fieldOfView = 45 -- 793
	View.postEffect = nil -- 794
	View.scale = scaleContent and screenScale or 1 -- 795
	Director.clearColor = Color(0xff1a1a1a) -- 796
	teal.clear() -- 797
	yue.clear() -- 798
	preserveSystemNode(Director.systemUI) -- 801
	for _, item in pairs(ubox()) do -- 802
		local node = tolua.cast(item, "Node") -- 803
		if node then -- 803
			if not systemNodes[node] then -- 804
				node:cleanup() -- 804
			end -- 804
		end -- 803
	end -- 802
	collectgarbage() -- 805
	collectgarbage() -- 806
	Wasm:clear() -- 807
	thread(function() -- 808
		sleep() -- 809
		return Cache:removeUnused() -- 810
	end) -- 808
	setupEventHandlers() -- 811
	Content.searchPaths = searchPaths -- 812
	App.idled = true -- 813
end -- 760
_module_0["allClear"] = allClear -- 760
local clearTempFiles -- 815
clearTempFiles = function() -- 815
	local writablePath = Content.writablePath -- 816
	local uploadPath = Path(writablePath, ".upload") -- 817
	if Content:exist(uploadPath) then -- 818
		local _list_0 = Content:getDirs(uploadPath) -- 820
		for _index_0 = 1, #_list_0 do -- 820
			local dir = _list_0[_index_0] -- 820
			if dir ~= "resume" then -- 821
				Content:remove(Path(uploadPath, dir)) -- 821
			end -- 821
		end -- 820
		local _list_1 = Content:getFiles(uploadPath) -- 822
		for _index_0 = 1, #_list_1 do -- 822
			local file = _list_1[_index_0] -- 822
			Content:remove(Path(uploadPath, file)) -- 823
		end -- 822
	end -- 818
	if Content:exist(Path(writablePath, ".download")) then -- 824
		return Content:remove(Path(writablePath, ".download")) -- 824
	end -- 824
end -- 815
local waitForWebStart = true -- 826
thread(function() -- 827
	sleep(2) -- 828
	waitForWebStart = false -- 829
end) -- 827
local reloadDevEntry -- 831
reloadDevEntry = function() -- 831
	return thread(function() -- 831
		waitForWebStart = true -- 832
		doClean() -- 833
		allClear() -- 834
		_G.require = oldRequire -- 835
		Dora.require = oldRequire -- 836
		package.loaded["Script.Dev.Entry"] = nil -- 837
		package.loaded["Script.Dev.WebServer"] = nil -- 838
		return Director.systemScheduler:schedule(function() -- 839
			Routine:clear() -- 840
			oldRequire("Script.Dev.Entry") -- 841
			return true -- 842
		end) -- 839
	end) -- 831
end -- 831
local setWorkspace -- 844
setWorkspace = function(path) -- 844
	clearTempFiles() -- 845
	Content.writablePath = path -- 846
	config.writablePath = Content.writablePath -- 847
	return thread(function() -- 848
		sleep() -- 849
		return reloadDevEntry() -- 850
	end) -- 848
end -- 844
_module_0["setWorkspace"] = setWorkspace -- 844
local quit = false -- 852
local activeSearchId = 0 -- 854
local handleSearchFiles -- 856
handleSearchFiles = function(payload) -- 856
	if not payload then -- 857
		return -- 857
	end -- 857
	local id = payload.id -- 858
	if id == nil then -- 859
		return -- 859
	end -- 859
	activeSearchId = id -- 860
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 861
	if path == nil then -- 862
		path = "" -- 862
	end -- 862
	if exts == nil then -- 863
		exts = { } -- 863
	end -- 863
	if globs == nil then -- 864
		globs = { } -- 864
	end -- 864
	if extensionLevels == nil then -- 865
		extensionLevels = { } -- 865
	end -- 865
	if pattern == nil then -- 866
		pattern = "" -- 866
	end -- 866
	if pattern == "" then -- 868
		return -- 868
	end -- 868
	local useRegex = payload.useRegex == true -- 869
	local caseSensitive = payload.caseSensitive == true -- 870
	local includeContent = payload.includeContent ~= false -- 871
	local contentWindow = payload.contentWindow or 0 -- 872
	return Director.systemScheduler:schedule(once(function() -- 873
		local stopped = false -- 874
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 875
			if activeSearchId ~= id then -- 876
				stopped = true -- 877
				return true -- 878
			end -- 876
			emit("AppWS", "Send", json.encode({ -- 880
				name = "SearchFilesResult", -- 880
				id = id, -- 880
				result = result -- 880
			})) -- 879
			return false -- 882
		end) -- 875
		return emit("AppWS", "Send", json.encode({ -- 884
			name = "SearchFilesDone", -- 884
			id = id, -- 884
			stopped = stopped -- 884
		})) -- 883
	end)) -- 873
end -- 856
local stop -- 887
stop = function() -- 887
	if isInEntry then -- 888
		return false -- 888
	end -- 888
	allClear() -- 889
	isInEntry = true -- 890
	currentEntry = nil -- 891
	return true -- 892
end -- 887
_module_0["stop"] = stop -- 887
local getCurrentEntryStatus -- 894
getCurrentEntryStatus = function() -- 894
	local entry = currentEntry -- 895
	if not (entry and not isInEntry) then -- 896
		return { -- 896
			success = true, -- 896
			running = false, -- 896
			runId = allEntries.runId -- 896
		} -- 896
	end -- 896
	local status = { -- 898
		success = true, -- 898
		running = true, -- 899
		kind = entry.runKind or "file", -- 900
		runId = allEntries.runId, -- 901
		entryName = entry.entryName, -- 902
		fileName = entry.fileName -- 903
	} -- 897
	if entry.workDir then -- 904
		status.workDir = entry.workDir -- 904
	end -- 904
	if entry.projectRoot then -- 905
		status.projectRoot = entry.projectRoot -- 905
	end -- 905
	return status -- 906
end -- 894
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 894
local _anon_func_3 = function(_with_0) -- 930
	local _val_0 = App.platform -- 930
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 930
end -- 930
local _anon_func_4 = function(_with_0) -- 964
	local _val_0 = App.platform -- 964
	return "Windows" == _val_0 or "macOS" == _val_0 or "Android" == _val_0 -- 964
end -- 964
setupEventHandlers = function() -- 908
	local _with_0 = Director.postNode -- 909
	if App.platform == "Windows" then -- 910
		_with_0:gslot("AppURLHandlerState", function(state) -- 911
			allEntries.urlHandlerState = state -- 912
			if state == "missing" then -- 913
				return emit("AppURLHandler", "register") -- 913
			end -- 913
		end) -- 911
		emit("AppURLHandler", "query") -- 914
	end -- 910
	_with_0:onAppEvent(function(eventType) -- 915
		if "Quit" == eventType then -- 916
			quit = true -- 917
			allClear() -- 918
			return clearTempFiles() -- 919
		elseif "Shutdown" == eventType then -- 920
			return stop() -- 921
		end -- 915
	end) -- 915
	_with_0:onAppChange(function(settingName) -- 922
		if "Theme" == settingName then -- 923
			config.themeColor = App.themeColor:toARGB() -- 924
		elseif "Locale" == settingName then -- 925
			config.locale = App.locale -- 926
			updateLocale() -- 927
			return teal.clear(true) -- 928
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 929
			if _anon_func_3(_with_0) then -- 930
				if "FullScreen" == settingName then -- 932
					config.fullScreen = App.fullScreen -- 932
				elseif "Position" == settingName then -- 933
					local _obj_0 = App.winPosition -- 933
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 933
				elseif "Size" == settingName then -- 934
					local width, height -- 935
					do -- 935
						local _obj_0 = App.winSize -- 935
						width, height = _obj_0.width, _obj_0.height -- 935
					end -- 935
					config.winWidth = width -- 936
					config.winHeight = height -- 937
				end -- 931
			end -- 930
		end -- 922
	end) -- 922
	_with_0:onAppWS(function(event) -- 938
		if event.type == "Close" then -- 939
			if HttpServer.wsConnectionCount == 0 then -- 940
				updateEntries() -- 941
			end -- 940
			return -- 942
		end -- 939
		if not (event.type == "Receive") then -- 943
			return -- 943
		end -- 943
		local data = json.decode(event.msg) -- 944
		if not data then -- 945
			return -- 945
		end -- 945
		local _exp_0 = data.name -- 946
		if "SearchFiles" == _exp_0 then -- 947
			return handleSearchFiles(data) -- 948
		elseif "SearchFilesStop" == _exp_0 then -- 949
			if data.id == nil or data.id == activeSearchId then -- 950
				activeSearchId = 0 -- 951
			end -- 950
		end -- 946
	end) -- 938
	_with_0:slot("UpdateEntries", function() -- 952
		return updateEntries() -- 952
	end) -- 952
	_with_0:gslot("RepositoryImport", function(repository) -- 953
		return Director.systemScheduler:schedule(once(function() -- 954
			if not (currentEntry and currentEntry.entryName == "RepositoryImporter") then -- 955
				local importIDE = oldRequire("Dev.ImportIDE") -- 956
				allEntries.importRestoreIDE = importIDE.getNativeState() == "visible" -- 957
			end -- 955
			if mobileMode then -- 960
				clearMobileUI() -- 960
			end -- 960
			allClear() -- 961
			if _anon_func_4(_with_0) and App.webIDEEnabled then -- 964
				emit("AppWebView", "/ide/hide", false) -- 964
			end -- 964
			return enterEntryAsync({ -- 966
				entryName = "RepositoryImporter", -- 966
				fileName = Path(Content.assetPath, "Script", "Tools", "RepositoryImporter"), -- 967
				runKind = "tool", -- 968
				argument = repository -- 969
			}) -- 965
		end)) -- 954
	end) -- 953
	_with_0:gslot("RepositoryImported", function() -- 971
		return updateEntries() -- 971
	end) -- 971
	_with_0:gslot("RepositoryImportDone", function() -- 972
		return Director.systemScheduler:schedule(once(function() -- 973
			stop() -- 974
			if allEntries.importRestoreIDE then -- 975
				allEntries.importRestoreIDE = false -- 976
				return emit("AppWebView", "/ide/show", true) -- 977
			end -- 975
		end)) -- 973
	end) -- 972
	_with_0:gslot("RepositoryImportReveal", function(file) -- 978
		return Director.systemScheduler:schedule(once(function() -- 979
			stop() -- 980
			updateEntries() -- 981
			allEntries.importFocusedFile = Path:replaceExt(file, "") -- 982
			allEntries.importReveal = true -- 983
		end)) -- 979
	end) -- 978
	return _with_0 -- 909
end -- 908
setupEventHandlers() -- 986
clearTempFiles() -- 987
local downloadFile -- 989
downloadFile = function(url, target) -- 989
	return Director.systemScheduler:schedule(once(function() -- 989
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 990
			if quit then -- 991
				return true -- 991
			end -- 991
			emit("AppWS", "Send", json.encode({ -- 993
				name = "Download", -- 993
				url = url, -- 993
				status = "downloading", -- 993
				progress = current / total -- 994
			})) -- 992
			return false -- 990
		end) -- 990
		return emit("AppWS", "Send", json.encode(success and { -- 997
			name = "Download", -- 997
			url = url, -- 997
			status = "completed", -- 997
			progress = 1.0 -- 998
		} or { -- 1000
			name = "Download", -- 1000
			url = url, -- 1000
			status = "failed", -- 1000
			progress = 0.0 -- 1001
		})) -- 996
	end)) -- 989
end -- 989
_module_0["downloadFile"] = downloadFile -- 989
local _anon_func_5 = function(entry, file, require, workDir) -- 1015
	if workDir == nil then -- 1015
		workDir = Path:getPath(file) -- 1015
	end -- 1015
	Content:insertSearchPath(1, workDir) -- 1016
	local scriptPath = Path(workDir, "Script") -- 1017
	if Content:exist(scriptPath) then -- 1018
		Content:insertSearchPath(1, scriptPath) -- 1019
	end -- 1018
	local result = require(file) -- 1020
	if "function" == type(result) then -- 1021
		result(entry.argument) -- 1021
	end -- 1021
	return nil -- 1022
end -- 1015
local _anon_func_6 = function(_with_0, err, fontSize, width) -- 1051
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 1051
	label.alignment = "Left" -- 1052
	label.textWidth = width - fontSize -- 1053
	label.text = err -- 1054
	return label -- 1051
end -- 1051
enterEntryAsync = function(entry) -- 1004
	allEntries.runId = allEntries.runId + 1 -- 1005
	local launchRunId = allEntries.runId -- 1006
	isInEntry = false -- 1007
	App.idled = false -- 1008
	emit(Profiler.EventName, "ClearLoader") -- 1009
	currentEntry = entry -- 1010
	local file, workDir = entry.fileName, entry.workDir -- 1011
	sleep() -- 1012
	if launchRunId ~= allEntries.runId or isInEntry or currentEntry ~= entry then -- 1013
		return false, "superseded" -- 1013
	end -- 1013
	return xpcall(_anon_func_5, function(msg) -- 1022
		local err = debug.traceback(msg) -- 1024
		Log("Error", err) -- 1025
		allClear() -- 1026
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 1027
		local viewWidth, viewHeight -- 1028
		do -- 1028
			local _obj_0 = View.size -- 1028
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 1028
		end -- 1028
		local width, height = viewWidth - 20, viewHeight - 20 -- 1029
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 1030
		Director.ui:addChild((function() -- 1031
			local root = AlignNode() -- 1031
			do -- 1032
				local _obj_0 = App.bufferSize -- 1032
				width, height = _obj_0.width, _obj_0.height -- 1032
			end -- 1032
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1033
			root:onAppChange(function(settingName) -- 1034
				if settingName == "Size" then -- 1034
					do -- 1035
						local _obj_0 = App.bufferSize -- 1035
						width, height = _obj_0.width, _obj_0.height -- 1035
					end -- 1035
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1036
				end -- 1034
			end) -- 1034
			root:addChild((function() -- 1037
				local _with_0 = ScrollArea({ -- 1038
					width = width, -- 1038
					height = height, -- 1039
					paddingX = 0, -- 1040
					paddingY = 50, -- 1041
					viewWidth = height, -- 1042
					viewHeight = height -- 1043
				}) -- 1037
				root:onAlignLayout(function(w, h) -- 1045
					_with_0.position = Vec2(w / 2, h / 2) -- 1046
					w = w - 20 -- 1047
					h = h - 20 -- 1048
					_with_0.view.children.first.textWidth = w - fontSize -- 1049
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 1050
				end) -- 1045
				_with_0.view:addChild(_anon_func_6(_with_0, err, fontSize, width)) -- 1051
				return _with_0 -- 1037
			end)()) -- 1037
			return root -- 1031
		end)()) -- 1031
		return err -- 1055
	end, entry, file, require, workDir) -- 1014
end -- 1004
_module_0["enterEntryAsync"] = enterEntryAsync -- 1004
local enterDemoEntry -- 1057
enterDemoEntry = function(entry) -- 1057
	return thread(function() -- 1057
		return enterEntryAsync(entry) -- 1057
	end) -- 1057
end -- 1057
local reloadCurrentEntry -- 1059
reloadCurrentEntry = function() -- 1059
	if currentEntry then -- 1060
		allClear() -- 1061
		return enterDemoEntry(currentEntry) -- 1062
	end -- 1060
end -- 1059
Director.clearColor = Color(0xff1a1a1a) -- 1064
local descColor = Color(0xffa1a1a1) -- 1065
local extraOperations -- 1068
do -- 1068
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 1069
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 1070
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 1071
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 1072
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1073
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1074
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1075
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1076
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1077
	local ossLicenses = nil -- 1078
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1079
	local failedSetFolder = false -- 1080
	local statusFlags = { -- 1081
		"NoResize", -- 1081
		"NoMove", -- 1081
		"NoCollapse", -- 1081
		"AlwaysAutoResize", -- 1081
		"NoSavedSettings" -- 1081
	} -- 1081
	extraOperations = function() -- 1088
		local zh = useChinese -- 1089
		if isDesktop then -- 1090
			local alwaysOnTop = config.alwaysOnTop -- 1091
			do -- 1092
				local changed -- 1092
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1092
				if changed then -- 1092
					App.alwaysOnTop = alwaysOnTop -- 1093
					config.alwaysOnTop = alwaysOnTop -- 1094
				end -- 1092
			end -- 1092
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1095
			do -- 1096
				local changed -- 1096
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1096
				if changed then -- 1096
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1097
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1098
				end -- 1096
			end -- 1096
			SameLine() -- 1099
			TextColored(descColor, "(?)") -- 1100
			if IsItemHovered() then -- 1101
				BeginTooltip(function() -- 1102
					return PushTextWrapPos(360, function() -- 1103
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1104
					end) -- 1103
				end) -- 1102
			end -- 1101
		end -- 1090
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1119
		do -- 1123
			local changed -- 1123
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1123
			if changed then -- 1123
				config.showPreview = showPreview -- 1124
				updateEntries() -- 1125
				if not showPreview then -- 1126
					thread(function() -- 1127
						collectgarbage() -- 1128
						return Cache:removeUnused("Texture") -- 1129
					end) -- 1127
				end -- 1126
			end -- 1123
		end -- 1123
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1130
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1131
			if changed then -- 1131
				config.webIDEEnabled = webIDEEnabled -- 1132
				App.webIDEEnabled = webIDEEnabled -- 1133
			end -- 1131
		end -- 1130
		do -- 1134
			local themeColor = App.themeColor -- 1135
			local writablePath = config.writablePath -- 1136
			SeparatorText(zh and "工作目录" or "Workspace") -- 1137
			PushTextWrapPos(400, function() -- 1138
				return TextColored(themeColor, writablePath) -- 1139
			end) -- 1138
			if not isDesktop then -- 1140
				goto skipSetting -- 1140
			end -- 1140
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1141
			if Button(zh and "改变目录" or "Set Folder") then -- 1142
				App:openFileDialog(true, function(path) -- 1143
					if path == "" then -- 1144
						return -- 1144
					end -- 1144
					local relPath = Path:getRelative(Content.assetPath, path) -- 1145
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1146
						return setWorkspace(path) -- 1147
					else -- 1149
						failedSetFolder = true -- 1149
					end -- 1146
				end) -- 1143
			end -- 1142
			if failedSetFolder then -- 1150
				failedSetFolder = false -- 1151
				OpenPopup(popupName) -- 1152
			end -- 1150
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1153
			BeginPopupModal(popupName, statusFlags, function() -- 1154
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1155
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1156
					return CloseCurrentPopup() -- 1157
				end -- 1156
			end) -- 1154
			SameLine() -- 1158
			if Button(zh and "使用默认" or "Use Default") then -- 1159
				setWorkspace(Content.appPath) -- 1160
			end -- 1159
			Separator() -- 1161
			::skipSetting:: -- 1162
		end -- 1134
		renderAgentStorage(zh) -- 1163
		if isOSSLicenseExist then -- 1164
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1165
				if not ossLicenses then -- 1166
					local licenseText = Content:load("LICENSES") -- 1167
					if licenseText then -- 1167
						local GSplit -- 1168
						do -- 1168
							local _obj_0 = require("Utils") -- 1168
							GSplit = _obj_0.GSplit -- 1168
						end -- 1168
						ossLicenses = { } -- 1169
						licenseText = licenseText:gsub("\r\n", "\n") -- 1170
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1171
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1172
							if name then -- 1172
								ossLicenses[#ossLicenses + 1] = { -- 1173
									name, -- 1173
									text -- 1173
								} -- 1173
							end -- 1172
						end -- 1171
					end -- 1167
				end -- 1166
				if ossLicenses then -- 1174
					OpenPopup(ossLicensePopup) -- 1174
				end -- 1174
			end -- 1165
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1175
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1176
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1177
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1178
				return BeginPopupModal(ossLicensePopup, true, { -- 1181
					"NoSavedSettings" -- 1181
				}, function() -- 1182
					for _index_0 = 1, #ossLicenses do -- 1183
						local _des_0 = ossLicenses[_index_0] -- 1183
						local firstLine, text = _des_0[1], _des_0[2] -- 1183
						local name, license = firstLine:match("(.+): (.+)") -- 1185
						if name then -- 1185
							TextColored(themeColor, name) -- 1186
							SameLine() -- 1187
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1188
								return TextWrapped(text) -- 1188
							end) -- 1188
						end -- 1185
					end -- 1183
				end) -- 1178
			end) -- 1178
		end -- 1164
		if not App.debugging then -- 1191
			return -- 1191
		end -- 1191
		return TreeNode(zh and "开发操作" or "Development", function() -- 1192
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1193
				OpenPopup("build") -- 1193
			end -- 1193
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1194
				return BeginPopup("build", function() -- 1194
					if Selectable(zh and "编译" or "Compile") then -- 1195
						doCompile(false) -- 1195
					end -- 1195
					Separator() -- 1196
					if Selectable(zh and "压缩" or "Minify") then -- 1197
						doCompile(true) -- 1197
					end -- 1197
					Separator() -- 1198
					if Selectable(zh and "清理" or "Clean") then -- 1199
						return doClean() -- 1199
					end -- 1199
				end) -- 1194
			end) -- 1194
			if isInEntry then -- 1200
				if waitForWebStart then -- 1201
					BeginDisabled(function() -- 1202
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1202
					end) -- 1202
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1203
					reloadDevEntry() -- 1204
				end -- 1201
			end -- 1200
			do -- 1205
				local changed -- 1205
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1205
				if changed then -- 1205
					View.scale = scaleContent and screenScale or 1 -- 1206
				end -- 1205
			end -- 1205
			do -- 1207
				local changed -- 1207
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1207
				if changed then -- 1207
					config.engineDev = engineDev -- 1208
				end -- 1207
			end -- 1207
			do -- 1209
				local changed -- 1209
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1209
				if changed then -- 1209
					config.webIDETourCompleted = webIDETourCompleted -- 1210
				end -- 1209
			end -- 1209
			if testingThread then -- 1211
				return BeginDisabled(function() -- 1212
					return Button(zh and "开始自动测试" or "Test automatically") -- 1212
				end) -- 1212
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1213
				testingThread = thread(function() -- 1214
					local _ <close> = setmetatable({ }, { -- 1215
						__close = function() -- 1215
							allClear() -- 1216
							testingThread = nil -- 1217
							isInEntry = true -- 1218
							currentEntry = nil -- 1219
							return print("Testing done!") -- 1220
						end -- 1215
					}) -- 1215
					for _, entry in ipairs(allEntries) do -- 1221
						allClear() -- 1222
						print("Start " .. tostring(entry.entryName)) -- 1223
						enterDemoEntry(entry) -- 1224
						sleep(2) -- 1225
						print("Stop " .. tostring(entry.entryName)) -- 1226
					end -- 1221
				end) -- 1214
			end -- 1211
		end) -- 1192
	end -- 1088
end -- 1068
local icon = Path(Content.assetPath, "Script", "Dev", "icon_s.png") -- 1228
local iconTex = nil -- 1229
Director.systemScheduler:schedule(once(function() -- 1230
	if Cache:loadAsync(icon) then -- 1230
		iconTex = Texture2D(icon) -- 1230
	end -- 1230
end)) -- 1230
local webStatus = nil -- 1232
local urlClicked = nil -- 1233
local authCode = string.format("%06d", math.random(0, 999999)) -- 1235
local authCodeTTL = 30.0 -- 1237
_module_0.getAuthCode = function() -- 1238
	return authCode -- 1238
end -- 1238
_module_0.invalidateAuthCode = function() -- 1239
	authCode = string.format("%06d", math.random(0, 999999)) -- 1240
	authCodeTTL = 30.0 -- 1241
end -- 1239
local AuthSession -- 1243
do -- 1243
	local pending = nil -- 1244
	local session = nil -- 1245
	AuthSession = { -- 1247
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1247
			pending = { -- 1249
				sessionId = sessionId, -- 1249
				confirmCode = confirmCode, -- 1250
				expiresAt = expiresAt, -- 1251
				ttl = ttl, -- 1252
				approved = false -- 1253
			} -- 1248
		end, -- 1247
		getPending = function() -- 1255
			return pending -- 1255
		end, -- 1255
		approvePending = function(sessionId) -- 1257
			if pending and pending.sessionId == sessionId then -- 1258
				pending.approved = true -- 1259
				return true -- 1260
			end -- 1258
			return false -- 1261
		end, -- 1257
		clearPending = function() -- 1263
			pending = nil -- 1263
		end, -- 1263
		setSession = function(sessionId, sessionSecret) -- 1265
			session = { -- 1267
				sessionId = sessionId, -- 1267
				sessionSecret = sessionSecret -- 1268
			} -- 1266
		end, -- 1265
		getSession = function() -- 1270
			return session -- 1270
		end -- 1270
	} -- 1246
end -- 1243
_module_0["AuthSession"] = AuthSession -- 1243
local transparant = Color(0x0) -- 1273
local windowFlags = { -- 1274
	"NoTitleBar", -- 1274
	"NoResize", -- 1274
	"NoMove", -- 1274
	"NoCollapse", -- 1274
	"NoSavedSettings", -- 1274
	"NoFocusOnAppearing", -- 1274
	"NoBringToFrontOnFocus" -- 1274
} -- 1274
local statusFlags = { -- 1283
	"NoTitleBar", -- 1283
	"NoResize", -- 1283
	"NoMove", -- 1283
	"NoCollapse", -- 1283
	"AlwaysAutoResize", -- 1283
	"NoSavedSettings" -- 1283
} -- 1283
local displayWindowFlags = { -- 1291
	"NoDecoration", -- 1291
	"NoSavedSettings", -- 1291
	"NoMove", -- 1291
	"NoScrollWithMouse", -- 1291
	"AlwaysAutoResize", -- 1291
	"NoFocusOnAppearing" -- 1291
} -- 1291
local _anon_func_7 = function(allEntries, currentIndex) -- 1364
	if currentIndex > 1 then -- 1364
		return allEntries[currentIndex - 1] -- 1365
	else -- 1367
		return allEntries[#allEntries] -- 1367
	end -- 1364
end -- 1364
local _anon_func_8 = function(allEntries, currentIndex) -- 1371
	if currentIndex < #allEntries then -- 1371
		return allEntries[currentIndex + 1] -- 1372
	else -- 1374
		return allEntries[1] -- 1374
	end -- 1371
end -- 1371
local _anon_func_9 = function(allEntries) -- 1414
	local _val_0 = allEntries.urlHandlerState -- 1414
	return "other" == _val_0 or "error" == _val_0 -- 1414
end -- 1414
do -- 1300
	local gamepadInputWindowFlags = { -- 1301
		"NoDecoration", -- 1301
		"NoSavedSettings", -- 1301
		"NoMove", -- 1301
		"NoScrollbar", -- 1301
		"NoScrollWithMouse", -- 1301
		"NoFocusOnAppearing", -- 1301
		"NoBringToFrontOnFocus" -- 1301
	} -- 1301
	local initFooter = true -- 1310
	local gamepadInputFocused = false -- 1311
	footerWindow = threadLoop(function() -- 1312
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1313
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1314
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1315
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1316
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1317
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1318
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1319
		if mobileMode then -- 1320
			return -- 1320
		end -- 1320
		local zh = useChinese -- 1321
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1322
		if authCodeTTL <= 0 then -- 1323
			authCodeTTL = 30.0 -- 1324
			authCode = string.format("%06d", math.random(0, 999999)) -- 1325
		end -- 1323
		if HttpServer.wsConnectionCount > 0 then -- 1326
			return -- 1327
		end -- 1326
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1328
			if App.platform == "Emscripten" then -- 1329
				stop() -- 1331
			else -- 1333
				allClear() -- 1333
				App.devMode = false -- 1334
				App:shutdown() -- 1335
			end -- 1329
		end -- 1328
		do -- 1336
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1337
			if ctrl and Keyboard:isKeyDown("Q") then -- 1338
				stop() -- 1339
			end -- 1338
			if ctrl and Keyboard:isKeyDown("Z") then -- 1340
				reloadCurrentEntry() -- 1341
			end -- 1340
			if ctrl and Keyboard:isKeyDown(",") then -- 1342
				if showFooter then -- 1343
					showStats = not showStats -- 1343
				else -- 1343
					showStats = true -- 1343
				end -- 1343
				showFooter = true -- 1344
				config.showFooter = showFooter -- 1345
				config.showStats = showStats -- 1346
			end -- 1342
			if ctrl and Keyboard:isKeyDown(".") then -- 1347
				if showFooter then -- 1348
					showConsole = not showConsole -- 1348
				else -- 1348
					showConsole = true -- 1348
				end -- 1348
				showFooter = true -- 1349
				config.showFooter = showFooter -- 1350
				config.showConsole = showConsole -- 1351
			end -- 1347
			if ctrl and Keyboard:isKeyDown("/") then -- 1352
				showFooter = not showFooter -- 1353
				config.showFooter = showFooter -- 1354
			end -- 1352
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1355
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1356
			local currentIndex = nil -- 1357
			for i, entry in ipairs(allEntries) do -- 1358
				if currentEntry == entry then -- 1359
					currentIndex = i -- 1360
				end -- 1359
			end -- 1358
			if left then -- 1361
				allClear() -- 1362
				if currentIndex == nil then -- 1363
					currentIndex = #allEntries + 1 -- 1363
				end -- 1363
				enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 1364
			end -- 1361
			if right then -- 1368
				allClear() -- 1369
				if currentIndex == nil then -- 1370
					currentIndex = 0 -- 1370
				end -- 1370
				enterDemoEntry(_anon_func_8(allEntries, currentIndex)) -- 1371
			end -- 1368
		end -- 1336
		if not showEntry then -- 1375
			return -- 1375
		end -- 1375
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1377
			reloadDevEntry() -- 1381
		end -- 1377
		if initFooter then -- 1382
			initFooter = false -- 1383
		end -- 1382
		local width, height -- 1385
		do -- 1385
			local _obj_0 = App.visualSize -- 1385
			width, height = _obj_0.width, _obj_0.height -- 1385
		end -- 1385
		if isInEntry then -- 1386
			gamepadInputFocused = false -- 1387
		else -- 1389
			SetNextWindowBgAlpha(0.0) -- 1389
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1390
			SetNextWindowPos(Vec2.zero, "Always") -- 1391
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1392
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1393
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1394
						if not gamepadInputFocused then -- 1395
							SetWindowFocus("DoraGamepadInput") -- 1396
							gamepadInputFocused = true -- 1397
						end -- 1395
					end) -- 1394
				end) -- 1393
			end) -- 1392
		end -- 1386
		if isInEntry or showFooter then -- 1399
			SetNextWindowSize(Vec2(width, 50)) -- 1400
			SetNextWindowPos(Vec2(0, height - 50)) -- 1401
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1402
				return PushStyleVar("WindowRounding", 0, function() -- 1403
					return Begin("Footer", windowFlags, function() -- 1404
						Separator() -- 1405
						if iconTex then -- 1406
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1407
								showStats = not showStats -- 1408
								config.showStats = showStats -- 1409
							end -- 1407
							SameLine() -- 1410
						end -- 1406
						if Button(">_", Vec2(30, 30)) then -- 1411
							showConsole = not showConsole -- 1412
							config.showConsole = showConsole -- 1413
						end -- 1411
						if App.platform == "Windows" and _anon_func_9(allEntries) then -- 1414
							SameLine() -- 1415
							if Button(zh and "注册浏览器链接" or "Register browser links") then -- 1416
								emit("AppURLHandler", "register") -- 1417
							end -- 1416
						end -- 1414
						if isInEntry and updateState.available then -- 1418
							SameLine() -- 1419
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1420
								allClear() -- 1421
								enterDemoEntry({ -- 1423
									entryName = "SelfUpdater", -- 1423
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1424
								}) -- 1422
							end -- 1420
						end -- 1418
						if not isInEntry then -- 1425
							SameLine() -- 1426
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1427
							local currentIndex = nil -- 1428
							for i, entry in ipairs(allEntries) do -- 1429
								if currentEntry == entry then -- 1430
									currentIndex = i -- 1431
								end -- 1430
							end -- 1429
							if currentIndex then -- 1432
								if currentIndex > 1 then -- 1433
									SameLine() -- 1434
									if Button("<<", Vec2(30, 30)) then -- 1435
										allClear() -- 1436
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1437
									end -- 1435
								end -- 1433
								if currentIndex < #allEntries then -- 1438
									SameLine() -- 1439
									if Button(">>", Vec2(30, 30)) then -- 1440
										allClear() -- 1441
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1442
									end -- 1440
								end -- 1438
							end -- 1432
							SameLine() -- 1443
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1444
								reloadCurrentEntry() -- 1445
							end -- 1444
							if back then -- 1446
								allClear() -- 1447
								isInEntry = true -- 1448
								currentEntry = nil -- 1449
							end -- 1446
						end -- 1425
					end) -- 1404
				end) -- 1403
			end) -- 1402
		end -- 1399
		if isInEntry then -- 1451
			local showURL = true -- 1452
			local webIDEWidth -- 1453
			do -- 1453
				local base -- 1454
				if updateState.available then -- 1454
					base = 460 -- 1454
				else -- 1454
					base = 360 -- 1454
				end -- 1454
				local extra = 35 -- 1455
				webIDEWidth = base + extra -- 1456
			end -- 1453
			if width < webIDEWidth then -- 1457
				showURL = false -- 1457
			end -- 1457
			SetNextWindowBgAlpha(0.0) -- 1458
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1459
			Begin("Web IDE", displayWindowFlags, function() -- 1460
				local pending = AuthSession.getPending() -- 1461
				local hovered = false -- 1462
				if not pending and showURL then -- 1463
					do -- 1464
						local url -- 1464
						if webStatus ~= nil then -- 1464
							url = webStatus.url -- 1464
						end -- 1464
						if url then -- 1464
							if isDesktop and not config.fullScreen then -- 1465
								if urlClicked then -- 1466
									BeginDisabled(function() -- 1467
										return Button(url) -- 1467
									end) -- 1467
								elseif Button(url) then -- 1468
									urlClicked = once(function() -- 1469
										return sleep(5) -- 1469
									end) -- 1469
									App:openURL("http://localhost:8866") -- 1470
								end -- 1466
							else -- 1472
								TextColored(descColor, url) -- 1472
							end -- 1465
						else -- 1474
							TextColored(descColor, zh and '不可用' or 'not available') -- 1474
						end -- 1464
					end -- 1464
					hovered = IsItemHovered() -- 1475
				else -- 1477
					TextColored(descColor, "(?)") -- 1477
					hovered = IsItemHovered() -- 1478
				end -- 1463
				SameLine() -- 1479
				local themeColor = App.themeColor -- 1480
				if pending then -- 1481
					if not pending.approved then -- 1482
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1483
						local ttl = pending.ttl or 1 -- 1484
						PushStyleColor("Text", themeColor, function() -- 1485
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1486
							hovered = hovered or IsItemHovered() -- 1487
						end) -- 1485
						SameLine() -- 1488
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1489
							AuthSession.approvePending(pending.sessionId) -- 1490
						end -- 1489
						if hovered then -- 1491
							return BeginTooltip(function() -- 1492
								return PushTextWrapPos(280, function() -- 1493
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1494
								end) -- 1493
							end) -- 1492
						end -- 1491
					end -- 1482
				else -- 1496
					PushStyleColor("Text", themeColor, function() -- 1496
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1497
						hovered = hovered or IsItemHovered() -- 1498
					end) -- 1496
					if hovered then -- 1499
						return BeginTooltip(function() -- 1500
							return PushTextWrapPos(280, function() -- 1501
								local url -- 1502
								if webStatus ~= nil then -- 1502
									url = webStatus.url -- 1502
								end -- 1502
								if url then -- 1502
									local address -- 1503
									if showURL then -- 1503
										address = "Web IDE" -- 1503
									else -- 1503
										address = url -- 1503
									end -- 1503
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1504
								else -- 1506
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1506
								end -- 1502
							end) -- 1501
						end) -- 1500
					end -- 1499
				end -- 1481
			end) -- 1460
		end -- 1451
		if not isInEntry then -- 1507
			SetNextWindowSize(Vec2(50, 50)) -- 1508
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1509
			PushStyleColor("WindowBg", transparant, function() -- 1510
				return Begin("Show", displayWindowFlags, function() -- 1510
					if width >= 370 then -- 1511
						local changed -- 1512
						changed, showFooter = Checkbox("##dev", showFooter) -- 1512
						if changed then -- 1512
							config.showFooter = showFooter -- 1513
						end -- 1512
					end -- 1511
				end) -- 1510
			end) -- 1510
		end -- 1507
		if isInEntry or showFooter then -- 1515
			if showStats then -- 1516
				PushStyleVar("WindowRounding", 0, function() -- 1517
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1518
					SetNextWindowSize(Vec2(0, height - 50)) -- 1519
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1520
					config.showStats = showStats -- 1521
				end) -- 1517
			end -- 1516
			if showConsole then -- 1522
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1523
				return PushStyleVar("WindowRounding", 6, function() -- 1524
					return ShowConsole() -- 1525
				end) -- 1524
			end -- 1522
		end -- 1515
	end) -- 1312
end -- 1300
do -- 1528
	local MaxWidth <const> = 960 -- 1529
	local toolOpen = false -- 1531
	local filterText = nil -- 1532
	allEntries.anyEntryMatched = false -- 1533
	allEntries.match = function(name) -- 1534
		local res = not filterText or name:lower():match(filterText) -- 1535
		if res then -- 1536
			allEntries.anyEntryMatched = true -- 1536
		end -- 1536
		return res -- 1537
	end -- 1534
	allEntries.thinSep = function() -- 1539
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1539
			return ImGui.SeparatorText("") -- 1539
		end) -- 1539
	end -- 1539
	entryWindow = threadLoop(function() -- 1540
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1541
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1542
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1543
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1544
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1545
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1546
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1547
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1548
		local connected = syncWebIDEControl() -- 1549
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1551
			if not allEntries.pendingPackagePath then -- 1552
				local path = App:takeReceivedFile() -- 1553
				if path ~= "" then -- 1554
					allEntries.pendingPackagePath = path -- 1554
				end -- 1554
			end -- 1552
			if allEntries.pendingPackagePath then -- 1555
				allEntries.mobileControl.pendingUIMode = true -- 1555
			end -- 1555
		end -- 1551
		if (allEntries.mobileControl.pendingUIMode ~= nil) then -- 1557
			local nextMode = allEntries.mobileControl.pendingUIMode -- 1558
			allEntries.mobileControl.pendingUIMode = nil -- 1559
			applyUIMode(nextMode) -- 1560
		end -- 1557
		if mobileMode and not connected then -- 1561
			if allEntries.importReveal and feedHost and feedHost.visible then -- 1562
				local _list_0 = getMobileFeedEntries() -- 1563
				for _index_0 = 1, #_list_0 do -- 1563
					local entry = _list_0[_index_0] -- 1563
					if entry.fileName == allEntries.importFocusedFile then -- 1564
						feedHost:emit("RestoreFeedEntry", entry) -- 1565
						allEntries.importReveal = false -- 1566
						break -- 1567
					end -- 1564
				end -- 1563
			end -- 1562
			if isInEntry and not feedHost then -- 1568
				applyUIMode(true) -- 1568
			end -- 1568
			return -- 1569
		end -- 1561
		if App.fpsLimited ~= config.fpsLimited then -- 1570
			config.fpsLimited = App.fpsLimited -- 1571
		end -- 1570
		if App.targetFPS ~= config.targetFPS then -- 1572
			config.targetFPS = App.targetFPS -- 1573
		end -- 1572
		if View.vsync ~= config.vsync then -- 1574
			config.vsync = View.vsync -- 1575
		end -- 1574
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1576
			config.fixedFPS = Director.scheduler.fixedFPS -- 1577
		end -- 1576
		if Director.profilerSending ~= config.webProfiler then -- 1578
			config.webProfiler = Director.profilerSending -- 1579
		end -- 1578
		if urlClicked then -- 1580
			local _, result = coroutine.resume(urlClicked) -- 1581
			if result then -- 1582
				coroutine.close(urlClicked) -- 1583
				urlClicked = nil -- 1584
			end -- 1582
		end -- 1580
		if not isInEntry then -- 1585
			return -- 1585
		end -- 1585
		local zh = useChinese -- 1586
		local themeColor = App.themeColor -- 1587
		if connected then -- 1588
			local width, height -- 1589
			do -- 1589
				local _obj_0 = App.visualSize -- 1589
				width, height = _obj_0.width, _obj_0.height -- 1589
			end -- 1589
			SetNextWindowBgAlpha(0.5) -- 1590
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1591
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1592
				Separator() -- 1593
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1594
				if iconTex then -- 1595
					Image(icon, Vec2(24, 24)) -- 1596
					SameLine() -- 1597
				end -- 1595
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1598
				TextColored(descColor, slogon) -- 1599
				return Separator() -- 1600
			end) -- 1592
			return -- 1601
		end -- 1588
		if not showEntry then -- 1602
			return -- 1602
		end -- 1602
		local fullWidth, height -- 1604
		do -- 1604
			local _obj_0 = App.visualSize -- 1604
			fullWidth, height = _obj_0.width, _obj_0.height -- 1604
		end -- 1604
		local width = math.min(MaxWidth, fullWidth) -- 1605
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1606
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1607
		SetNextWindowPos(Vec2.zero) -- 1608
		SetNextWindowBgAlpha(0) -- 1609
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1610
		do -- 1611
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1612
				return Begin("Dora Dev", windowFlags, function() -- 1613
					Dummy(Vec2(fullWidth - 20, 0)) -- 1614
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1615
					SameLine() -- 1616
					if Button(zh and "Go 模式" or "Go Mode") then -- 1617
						setUIMode("mobile") -- 1618
					end -- 1617
					if fullWidth >= 540 then -- 1619
						SameLine() -- 1620
						Dummy(Vec2(fullWidth - 540, 0)) -- 1621
						SameLine() -- 1622
						SetNextItemWidth(zh and -95 or -140) -- 1623
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1624
							"AutoSelectAll" -- 1624
						}) then -- 1624
							config.filter = filterBuf.text -- 1625
							allEntries.importFocusedFile = nil -- 1626
							allEntries.importReveal = false -- 1627
						end -- 1624
						SameLine() -- 1628
						if Button(zh and '下载' or 'Download') then -- 1629
							ImGui.OpenPopup("project-download") -- 1629
						end -- 1629
						ImGui.BeginPopup("project-download", function() -- 1630
							if ImGui.Selectable(zh and "从 Git 仓库导入…" or "Import Git repository…") then -- 1631
								emit("RepositoryImport", nil) -- 1632
							end -- 1631
							if ImGui.Selectable(zh and "浏览资源目录…" or "Browse resource catalog…") then -- 1633
								allClear() -- 1634
								return enterDemoEntry({ -- 1636
									entryName = "ResourceDownloader", -- 1636
									fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1637
								}) -- 1635
							end -- 1633
						end) -- 1630
					end -- 1619
					return Separator() -- 1638
				end) -- 1613
			end) -- 1612
		end -- 1611
		allEntries.anyEntryMatched = false -- 1640
		SetNextWindowPos(Vec2(0, 50)) -- 1641
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1642
		local scrollbarSize <const> = 25 -- 1644
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1645
		do -- 1646
			return PushStyleColor("WindowBg", transparant, function() -- 1647
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1648
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1649
						return PushStyleVar("Alpha", 1, function() -- 1650
							return Begin("Content", windowFlags, function() -- 1651
								local DemoViewWidth <const> = 220 -- 1652
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1653
								if filterText then -- 1654
									filterText = filterText:lower() -- 1654
								end -- 1654
								if App.platform == "Emscripten" then -- 1655
									Dora.globals.webProjects.draw(zh, themeColor) -- 1656
									allEntries.anyEntryMatched = true -- 1657
								end -- 1655
								if #gamesInDev > 0 then -- 1658
									if App.platform == "Windows" then -- 1659
										if windowsExport.busy then -- 1660
											ImGui.TextDisabled(zh and "正在导出 Windows 游戏…" or "Exporting Windows game…") -- 1660
										end -- 1660
										if windowsExport.message then -- 1661
											TextWrapped(windowsExport.message) -- 1661
										end -- 1661
									end -- 1659
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1662
									Columns(columns, false) -- 1663
									local realViewWidth = GetColumnWidth() - 50 -- 1664
									for _index_0 = 1, #gamesInDev do -- 1665
										local game = gamesInDev[_index_0] -- 1665
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1666
										local displayName -- 1675
										if repo then -- 1675
											if zh then -- 1676
												displayName = repo.title.zh -- 1676
											else -- 1676
												displayName = repo.title.en -- 1676
											end -- 1676
										end -- 1675
										if displayName == nil then -- 1677
											displayName = gameName -- 1677
										end -- 1677
										if allEntries.match(displayName) or allEntries.importFocusedFile == fileName then -- 1678
											allEntries.anyEntryMatched = true -- 1679
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1680
											SameLine() -- 1681
											if allEntries.importFocusedFile == fileName then -- 1682
												PushStyleColor("Text", themeColor, function() -- 1683
													return TextWrapped(displayName) -- 1683
												end) -- 1683
											else -- 1685
												TextWrapped(displayName) -- 1685
											end -- 1682
											if allEntries.importFocusedFile == fileName and allEntries.importReveal then -- 1686
												ImGui.SetScrollHereY(0.5) -- 1687
												allEntries.importReveal = false -- 1688
											end -- 1686
											if columns > 1 then -- 1689
												if bannerFile and bannerTex then -- 1690
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1691
													local displayWidth <const> = realViewWidth -- 1692
													texHeight = displayWidth * texHeight / texWidth -- 1693
													texWidth = displayWidth -- 1694
													Dummy(Vec2.zero) -- 1695
													SameLine() -- 1696
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1697
												end -- 1690
												if game.needsBuild then -- 1698
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1699
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1700
													enterDemoEntry(game) -- 1701
												end -- 1698
											else -- 1703
												if bannerFile and bannerTex then -- 1703
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1704
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1705
													local sizing = 0.8 -- 1706
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1707
													texWidth = displayWidth * sizing -- 1708
													if texWidth > 500 then -- 1709
														sizing = 0.6 -- 1710
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1711
														texWidth = displayWidth * sizing -- 1712
													end -- 1709
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1713
													Dummy(Vec2(padding, 0)) -- 1714
													SameLine() -- 1715
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1716
												end -- 1703
												if game.needsBuild then -- 1717
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1718
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1719
													enterDemoEntry(game) -- 1720
												end -- 1717
											end -- 1689
											if App.platform == "Windows" and not windowsExport.busy and not game.needsBuild then -- 1721
												if Button(tostring(zh and "导出 Windows ZIP" or "Export Windows ZIP") .. "##" .. tostring(fileName), Vec2(-1, 30)) then -- 1722
													allEntries.exportWindowsGame(game, displayName) -- 1723
												end -- 1722
											end -- 1721
											if #tests == 0 and #examples == 0 then -- 1724
												allEntries.thinSep() -- 1725
											end -- 1724
											NextColumn() -- 1726
										end -- 1678
										local showSep = false -- 1727
										if #examples > 0 then -- 1728
											local showExample = false -- 1729
											for _index_1 = 1, #examples do -- 1730
												local _des_0 = examples[_index_1] -- 1730
												local entryName = _des_0.entryName -- 1730
												if allEntries.match(entryName) then -- 1731
													showExample = true -- 1731
													break -- 1731
												end -- 1731
											end -- 1730
											if showExample then -- 1732
												showSep = true -- 1733
												Columns(1, false) -- 1734
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1735
												SameLine() -- 1736
												local opened -- 1737
												if (filterText ~= nil) then -- 1737
													opened = showExample -- 1737
												else -- 1737
													opened = false -- 1737
												end -- 1737
												if game.exampleOpen == nil then -- 1738
													game.exampleOpen = opened -- 1738
												end -- 1738
												SetNextItemOpen(game.exampleOpen) -- 1739
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1740
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1741
														Columns(maxColumns, false) -- 1742
														for _index_1 = 1, #examples do -- 1743
															local example = examples[_index_1] -- 1743
															local entryName = example.entryName -- 1744
															if not allEntries.match(entryName) then -- 1745
																goto _continue_0 -- 1745
															end -- 1745
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1746
																if Button(entryName, Vec2(-1, 40)) then -- 1747
																	enterDemoEntry(example) -- 1748
																end -- 1747
																return NextColumn() -- 1749
															end) -- 1746
															opened = true -- 1750
															::_continue_0:: -- 1744
														end -- 1743
													end) -- 1741
												end) -- 1740
												game.exampleOpen = opened -- 1751
											end -- 1732
										end -- 1728
										if #tests > 0 then -- 1752
											local showTest = false -- 1753
											for _index_1 = 1, #tests do -- 1754
												local _des_0 = tests[_index_1] -- 1754
												local entryName = _des_0.entryName -- 1754
												if allEntries.match(entryName) then -- 1755
													showTest = true -- 1755
													break -- 1755
												end -- 1755
											end -- 1754
											if showTest then -- 1756
												showSep = true -- 1757
												Columns(1, false) -- 1758
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1759
												SameLine() -- 1760
												local opened -- 1761
												if (filterText ~= nil) then -- 1761
													opened = showTest -- 1761
												else -- 1761
													opened = false -- 1761
												end -- 1761
												if game.testOpen == nil then -- 1762
													game.testOpen = opened -- 1762
												end -- 1762
												SetNextItemOpen(game.testOpen) -- 1763
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1764
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1765
														Columns(maxColumns, false) -- 1766
														for _index_1 = 1, #tests do -- 1767
															local test = tests[_index_1] -- 1767
															local entryName = test.entryName -- 1768
															if not allEntries.match(entryName) then -- 1769
																goto _continue_0 -- 1769
															end -- 1769
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1770
																if Button(entryName, Vec2(-1, 40)) then -- 1771
																	enterDemoEntry(test) -- 1772
																end -- 1771
																return NextColumn() -- 1773
															end) -- 1770
															opened = true -- 1774
															::_continue_0:: -- 1768
														end -- 1767
													end) -- 1765
												end) -- 1764
												game.testOpen = opened -- 1775
											end -- 1756
										end -- 1752
										if showSep then -- 1776
											Columns(1, false) -- 1777
											allEntries.thinSep() -- 1778
											Columns(columns, false) -- 1779
										end -- 1776
									end -- 1665
								end -- 1658
								if #doraTools > 0 then -- 1780
									local showTool = false -- 1781
									for _index_0 = 1, #doraTools do -- 1782
										local _des_0 = doraTools[_index_0] -- 1782
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1782
										local displayName -- 1783
										if repo then -- 1783
											if zh then -- 1784
												displayName = repo.title.zh -- 1784
											else -- 1784
												displayName = repo.title.en -- 1784
											end -- 1784
										end -- 1783
										if displayName == nil then -- 1785
											displayName = entryName -- 1785
										end -- 1785
										if allEntries.match(displayName) then -- 1786
											showTool = true -- 1786
											break -- 1786
										end -- 1786
									end -- 1782
									if not showTool then -- 1787
										goto endEntry -- 1787
									end -- 1787
									Columns(1, false) -- 1788
									TextColored(themeColor, "Dora SSR:") -- 1789
									SameLine() -- 1790
									Text(zh and "开发支持" or "Development Support") -- 1791
									Separator() -- 1792
									if #doraTools > 0 then -- 1793
										local opened -- 1794
										if (filterText ~= nil) then -- 1794
											opened = showTool -- 1794
										else -- 1794
											opened = false -- 1794
										end -- 1794
										SetNextItemOpen(toolOpen) -- 1795
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1796
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1797
												Columns(maxColumns, false) -- 1798
												for _index_0 = 1, #doraTools do -- 1799
													local tool = doraTools[_index_0] -- 1799
													local entryName, repo = tool.entryName, tool.repo -- 1800
													local displayName -- 1801
													if repo then -- 1801
														if zh then -- 1802
															displayName = repo.title.zh -- 1802
														else -- 1802
															displayName = repo.title.en -- 1802
														end -- 1802
													end -- 1801
													if displayName == nil then -- 1803
														displayName = entryName -- 1803
													end -- 1803
													if not allEntries.match(displayName) then -- 1804
														goto _continue_0 -- 1804
													end -- 1804
													if Button(displayName, Vec2(-1, 40)) then -- 1805
														enterDemoEntry(tool) -- 1806
													end -- 1805
													NextColumn() -- 1807
													::_continue_0:: -- 1800
												end -- 1799
												Columns(1, false) -- 1808
												opened = true -- 1809
											end) -- 1797
										end) -- 1796
										toolOpen = opened -- 1810
									end -- 1793
								end -- 1780
								::endEntry:: -- 1811
								if not allEntries.anyEntryMatched then -- 1812
									SetNextWindowBgAlpha(0) -- 1813
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1814
									Begin("Entries Not Found", displayWindowFlags, function() -- 1815
										Separator() -- 1816
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1817
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1818
										return Separator() -- 1819
									end) -- 1815
								end -- 1812
								Columns(1, false) -- 1820
								Dummy(Vec2(100, 80)) -- 1821
								return ScrollWhenDraggingOnVoid() -- 1822
							end) -- 1651
						end) -- 1650
					end) -- 1649
				end) -- 1648
			end) -- 1647
		end -- 1646
	end) -- 1540
end -- 1528
if not (App.platform == "Emscripten") then -- 1827
	local sceneModuleCache = moduleCache -- 1828
	moduleCache = { } -- 1829
	webStatus = oldRequire("Script.Dev.WebServer") -- 1830
	moduleCache = sceneModuleCache -- 1831
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1832
		thread(function() -- 1833
			wait(function() -- 1834
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1834
			end) -- 1834
			if App.webIDEEnabled then -- 1835
				return emit("AppWebView", "/ide/show", true) -- 1835
			end -- 1835
		end) -- 1833
	end -- 1832
end -- 1827
local _anon_func_10 = function(saved) -- 1858
	local _val_0 = saved.kind -- 1858
	return "local" == _val_0 or "discover" == _val_0 -- 1858
end -- 1858
local _anon_func_11 = function(saved) -- 1862
	local _val_0 = saved.activeTab -- 1862
	return "local" == _val_0 or "discover" == _val_0 -- 1862
end -- 1862
startMobileUI = function() -- 1837
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1838
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1839
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1840
	local getMobileFeedResources -- 1841
	do -- 1841
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1841
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1841
	end -- 1841
	local loadCachedCatalog -- 1842
	do -- 1842
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1842
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1842
	end -- 1842
	local getResourceInstallPath, getInstalledCatalogResource -- 1843
	do -- 1843
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1843
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1843
	end -- 1843
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1844
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1845
	local feedOptions = nil -- 1846
	local mobileLaunchErrors = { } -- 1847
	local withMobileLaunchErrors -- 1848
	withMobileLaunchErrors = function(items) -- 1848
		for _index_0 = 1, #items do -- 1849
			local item = items[_index_0] -- 1849
			item.launchError = mobileLaunchErrors[item.id] -- 1850
		end -- 1849
		return items -- 1851
	end -- 1848
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1852
	local loadRememberedMobileFeedState -- 1853
	loadRememberedMobileFeedState = function() -- 1853
		local raw = rememberedMobileFeedData -- 1854
		if not (type(raw) == "string" and raw ~= "") then -- 1855
			return -- 1855
		end -- 1855
		local ok, saved = pcall(json.decode, raw) -- 1856
		if not (ok and type(saved) == "table") then -- 1857
			return -- 1857
		end -- 1857
		if type(saved.id) == "string" and _anon_func_10(saved) then -- 1858
			local state = { -- 1859
				activeTab = saved.kind -- 1859
			} -- 1859
			state[saved.kind] = saved -- 1860
			return state -- 1861
		end -- 1858
		local state = { -- 1862
			activeTab = _anon_func_11(saved) and saved.activeTab or "local" -- 1862
		} -- 1862
		local _list_0 = { -- 1863
			"local", -- 1863
			"discover" -- 1863
		} -- 1863
		for _index_0 = 1, #_list_0 do -- 1863
			local kind = _list_0[_index_0] -- 1863
			local entry = saved[kind] -- 1864
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1865
				state[kind] = entry -- 1865
			end -- 1865
		end -- 1863
		return state -- 1866
	end -- 1853
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1867
		activeTab = "local" -- 1867
	} -- 1867
	local rememberMobileFeedEntry -- 1868
	rememberMobileFeedEntry = function(entry) -- 1868
		rememberedMobileFeedState.activeTab = entry.kind -- 1869
		rememberedMobileFeedState[entry.kind] = { -- 1871
			id = entry.id, -- 1871
			kind = entry.kind, -- 1872
			workDir = entry.workDir, -- 1873
			fileName = entry.fileName -- 1874
		} -- 1870
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1876
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1877
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1878
			rememberedMobileFeedData -- 1878
		}) -- 1878
	end -- 1868
	local restartMobileFeed -- 1879
	restartMobileFeed = function(entry) -- 1879
		if feedHost then -- 1880
			feedHost:removeFromParent(true) -- 1880
		end -- 1880
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1881
		local initialEntries = { } -- 1882
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1883
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1884
		feedOptions.initialEntries = initialEntries -- 1885
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1886
	end -- 1879
	local startMobilePlay -- 1887
	startMobilePlay = function(entry) -- 1887
		if HttpServer.wsConnectionCount > 0 then -- 1888
			return -- 1888
		end -- 1888
		if entry.needsBuild then -- 1889
			mobileLaunchErrors[entry.id] = useChinese and "请先在 IDE 中编译项目" or "Build the project in the IDE first" -- 1890
			restartMobileFeed(entry) -- 1891
			return -- 1892
		end -- 1889
		local originFeed = feedHost -- 1893
		if remixHost then -- 1894
			remixHost:removeFromParent(true) -- 1894
		end -- 1894
		remixHost = nil -- 1895
		mobileLaunchErrors[entry.id] = nil -- 1896
		entry.launchError = nil -- 1897
		local playActive = true -- 1898
		local playHost = nil -- 1899
		local restoreMobileFeed -- 1900
		restoreMobileFeed = function() -- 1900
			if not playActive then -- 1901
				return -- 1901
			end -- 1901
			playActive = false -- 1902
			if playHost and playHost.parent then -- 1904
				playHost:removeFromParent(true) -- 1904
			end -- 1904
			playHost = nil -- 1905
			allClear() -- 1906
			isInEntry = true -- 1907
			currentEntry = nil -- 1908
			return restartMobileFeed(entry) -- 1909
		end -- 1900
		playHost = trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1911
			onExit = function() -- 1911
				return restoreMobileFeed() -- 1911
			end, -- 1911
			onRuntimeError = function() -- 1912
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1913
				return restoreMobileFeed() -- 1914
			end -- 1912
		})) -- 1910
		return thread(function() -- 1916
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1920
			if not playActive then -- 1921
				return -- 1921
			end -- 1921
			if success then -- 1922
				if originFeed and originFeed.parent then -- 1923
					originFeed.visible = false -- 1923
				end -- 1923
				return -- 1924
			end -- 1922
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1925
			return restoreMobileFeed() -- 1926
		end) -- 1916
	end -- 1887
	feedOptions = { -- 1928
		takeReceivedFile = function() -- 1928
			if allEntries.pendingPackagePath then -- 1929
				local path = allEntries.pendingPackagePath -- 1930
				allEntries.pendingPackagePath = nil -- 1931
				return path -- 1932
			end -- 1929
			return App:takeReceivedFile() -- 1933
		end, -- 1928
		onSwitchMode = function() -- 1934
			if HttpServer.wsConnectionCount == 0 then -- 1934
				allEntries.mobileControl.pendingUIMode = false -- 1934
			end -- 1934
		end, -- 1934
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1935
		getLocalEntries = function(importedProjectPath) -- 1936
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1937
			feedOptions.dirtyProjectPath = nil -- 1938
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1939
			local cached = loadCachedCatalog() -- 1940
			if cached.success and cached.snapshot then -- 1941
				for _index_0 = 1, #items do -- 1942
					local entry = items[_index_0] -- 1942
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1943
					if resource then -- 1944
						entry.resource = resource -- 1945
						entry.catalogCommit = cached.snapshot.commit -- 1946
					end -- 1944
				end -- 1942
			end -- 1941
			return items -- 1947
		end, -- 1936
		syncDiscover = function(onProgress, onDone, force) -- 1948
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1948
		end, -- 1948
		getDiscoverEntries = function() -- 1949
			local cached = loadCachedCatalog() -- 1950
			if not (cached.success and cached.snapshot) then -- 1951
				return { } -- 1951
			end -- 1951
			local items = { } -- 1952
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1953
			for _index_0 = 1, #_list_0 do -- 1953
				local resource = _list_0[_index_0] -- 1953
				local installed = lifecycle.isMobileResourceReady(resource) -- 1954
				local installPath = getResourceInstallPath(resource.id) -- 1955
				items[#items + 1] = { -- 1957
					id = resource.id, -- 1957
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1958
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1959
					kind = "discover", -- 1960
					bannerFile = resource.bannerPath, -- 1961
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1962
					sourceUrl = resource.versions[1].sources[1].url, -- 1963
					workDir = installed and installPath or nil, -- 1964
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1965
					installed = installed, -- 1966
					resource = resource, -- 1967
					catalogCommit = cached.snapshot.commit, -- 1968
					launchError = mobileLaunchErrors[resource.id] -- 1969
				} -- 1956
			end -- 1953
			return items -- 1971
		end, -- 1949
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1972
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1973
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1974
			end), repairIncomplete, isCanceled) -- 1973
		end, -- 1972
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1976
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1977
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1978
			end), isCanceled) -- 1977
		end, -- 1976
		createProject = function(name, language) -- 1980
			local result = projectCreate.createMobileProject(name, language) -- 1981
			if not result.success then -- 1982
				return result -- 1982
			end -- 1982
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1983
			for _index_0 = 1, #_list_0 do -- 1983
				local entry = _list_0[_index_0] -- 1983
				if entry.workDir == result.workDir then -- 1984
					return { -- 1985
						success = true, -- 1985
						entry = entry -- 1985
					} -- 1985
				end -- 1984
			end -- 1983
			return { -- 1986
				success = false, -- 1986
				error = "created-project-not-found" -- 1986
			} -- 1986
		end, -- 1980
		onPlay = function(entry) -- 1987
			return startMobilePlay(entry) -- 1987
		end, -- 1987
		onRemix = function(entry) -- 1988
			if HttpServer.wsConnectionCount > 0 then -- 1989
				return -- 1989
			end -- 1989
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1990
			local originFeed = feedHost -- 1991
			feedHost.visible = false -- 1992
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1994
				entry = entry, -- 1994
				onProjectChanged = function(current) -- 1995
					feedOptions.dirtyProjectPath = current.workDir -- 1995
				end, -- 1995
				onBack = function() -- 1996
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1997
						originFeed:emit("RestoreFeedEntry", entry) -- 1998
						originFeed.visible = true -- 1999
					end -- 1997
				end, -- 1996
				onPlay = function(current) -- 2000
					return startMobilePlay(current) -- 2000
				end -- 2000
			})) -- 1993
		end -- 1988
	} -- 1927
	return restartMobileFeed() -- 2003
end -- 1837
if mobileMode then -- 2005
	applyUIMode(true) -- 2005
end -- 2005
return _module_0 -- 1
