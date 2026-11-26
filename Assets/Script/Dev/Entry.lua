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
local Set, Struct, LintYueGlobals, GetProjectSearchPaths -- 269
do -- 269
	local _obj_0 = require("Utils") -- 269
	Set, Struct, LintYueGlobals, GetProjectSearchPaths = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GetProjectSearchPaths -- 269
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
local _anon_func_5 = function(GetProjectSearchPaths, entry, file, require, workDir) -- 1015
	if workDir == nil then -- 1015
		workDir = Path:getPath(file) -- 1015
	end -- 1015
	local _list_0 = GetProjectSearchPaths(workDir) -- 1016
	for _index_0 = 1, #_list_0 do -- 1016
		local directory = _list_0[_index_0] -- 1016
		Content:insertSearchPath(1, directory) -- 1017
	end -- 1016
	local result = require(file) -- 1018
	if "function" == type(result) then -- 1019
		result(entry.argument) -- 1019
	end -- 1019
	return nil -- 1020
end -- 1015
local _anon_func_6 = function(_with_0, err, fontSize, width) -- 1049
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 1049
	label.alignment = "Left" -- 1050
	label.textWidth = width - fontSize -- 1051
	label.text = err -- 1052
	return label -- 1049
end -- 1049
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
	return xpcall(_anon_func_5, function(msg) -- 1020
		local err = debug.traceback(msg) -- 1022
		Log("Error", err) -- 1023
		allClear() -- 1024
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 1025
		local viewWidth, viewHeight -- 1026
		do -- 1026
			local _obj_0 = View.size -- 1026
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 1026
		end -- 1026
		local width, height = viewWidth - 20, viewHeight - 20 -- 1027
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 1028
		Director.ui:addChild((function() -- 1029
			local root = AlignNode() -- 1029
			do -- 1030
				local _obj_0 = App.bufferSize -- 1030
				width, height = _obj_0.width, _obj_0.height -- 1030
			end -- 1030
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1031
			root:onAppChange(function(settingName) -- 1032
				if settingName == "Size" then -- 1032
					do -- 1033
						local _obj_0 = App.bufferSize -- 1033
						width, height = _obj_0.width, _obj_0.height -- 1033
					end -- 1033
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1034
				end -- 1032
			end) -- 1032
			root:addChild((function() -- 1035
				local _with_0 = ScrollArea({ -- 1036
					width = width, -- 1036
					height = height, -- 1037
					paddingX = 0, -- 1038
					paddingY = 50, -- 1039
					viewWidth = height, -- 1040
					viewHeight = height -- 1041
				}) -- 1035
				root:onAlignLayout(function(w, h) -- 1043
					_with_0.position = Vec2(w / 2, h / 2) -- 1044
					w = w - 20 -- 1045
					h = h - 20 -- 1046
					_with_0.view.children.first.textWidth = w - fontSize -- 1047
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 1048
				end) -- 1043
				_with_0.view:addChild(_anon_func_6(_with_0, err, fontSize, width)) -- 1049
				return _with_0 -- 1035
			end)()) -- 1035
			return root -- 1029
		end)()) -- 1029
		return err -- 1053
	end, GetProjectSearchPaths, entry, file, require, workDir) -- 1014
end -- 1004
_module_0["enterEntryAsync"] = enterEntryAsync -- 1004
local enterDemoEntry -- 1055
enterDemoEntry = function(entry) -- 1055
	return thread(function() -- 1055
		return enterEntryAsync(entry) -- 1055
	end) -- 1055
end -- 1055
local reloadCurrentEntry -- 1057
reloadCurrentEntry = function() -- 1057
	if currentEntry then -- 1058
		allClear() -- 1059
		return enterDemoEntry(currentEntry) -- 1060
	end -- 1058
end -- 1057
Director.clearColor = Color(0xff1a1a1a) -- 1062
local descColor = Color(0xffa1a1a1) -- 1063
local extraOperations -- 1066
do -- 1066
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 1067
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 1068
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 1069
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 1070
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1071
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1072
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1073
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1074
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1075
	local ossLicenses = nil -- 1076
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1077
	local failedSetFolder = false -- 1078
	local statusFlags = { -- 1079
		"NoResize", -- 1079
		"NoMove", -- 1079
		"NoCollapse", -- 1079
		"AlwaysAutoResize", -- 1079
		"NoSavedSettings" -- 1079
	} -- 1079
	extraOperations = function() -- 1086
		local zh = useChinese -- 1087
		if isDesktop then -- 1088
			local alwaysOnTop = config.alwaysOnTop -- 1089
			do -- 1090
				local changed -- 1090
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1090
				if changed then -- 1090
					App.alwaysOnTop = alwaysOnTop -- 1091
					config.alwaysOnTop = alwaysOnTop -- 1092
				end -- 1090
			end -- 1090
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1093
			do -- 1094
				local changed -- 1094
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1094
				if changed then -- 1094
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1095
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1096
				end -- 1094
			end -- 1094
			SameLine() -- 1097
			TextColored(descColor, "(?)") -- 1098
			if IsItemHovered() then -- 1099
				BeginTooltip(function() -- 1100
					return PushTextWrapPos(360, function() -- 1101
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1102
					end) -- 1101
				end) -- 1100
			end -- 1099
		end -- 1088
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1117
		do -- 1121
			local changed -- 1121
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1121
			if changed then -- 1121
				config.showPreview = showPreview -- 1122
				updateEntries() -- 1123
				if not showPreview then -- 1124
					thread(function() -- 1125
						collectgarbage() -- 1126
						return Cache:removeUnused("Texture") -- 1127
					end) -- 1125
				end -- 1124
			end -- 1121
		end -- 1121
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1128
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1129
			if changed then -- 1129
				config.webIDEEnabled = webIDEEnabled -- 1130
				App.webIDEEnabled = webIDEEnabled -- 1131
			end -- 1129
		end -- 1128
		do -- 1132
			local themeColor = App.themeColor -- 1133
			local writablePath = config.writablePath -- 1134
			SeparatorText(zh and "工作目录" or "Workspace") -- 1135
			PushTextWrapPos(400, function() -- 1136
				return TextColored(themeColor, writablePath) -- 1137
			end) -- 1136
			if not isDesktop then -- 1138
				goto skipSetting -- 1138
			end -- 1138
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1139
			if Button(zh and "改变目录" or "Set Folder") then -- 1140
				App:openFileDialog(true, function(path) -- 1141
					if path == "" then -- 1142
						return -- 1142
					end -- 1142
					local relPath = Path:getRelative(Content.assetPath, path) -- 1143
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1144
						return setWorkspace(path) -- 1145
					else -- 1147
						failedSetFolder = true -- 1147
					end -- 1144
				end) -- 1141
			end -- 1140
			if failedSetFolder then -- 1148
				failedSetFolder = false -- 1149
				OpenPopup(popupName) -- 1150
			end -- 1148
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1151
			BeginPopupModal(popupName, statusFlags, function() -- 1152
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1153
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1154
					return CloseCurrentPopup() -- 1155
				end -- 1154
			end) -- 1152
			SameLine() -- 1156
			if Button(zh and "使用默认" or "Use Default") then -- 1157
				setWorkspace(Content.appPath) -- 1158
			end -- 1157
			Separator() -- 1159
			::skipSetting:: -- 1160
		end -- 1132
		renderAgentStorage(zh) -- 1161
		if isOSSLicenseExist then -- 1162
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1163
				if not ossLicenses then -- 1164
					local licenseText = Content:load("LICENSES") -- 1165
					if licenseText then -- 1165
						local GSplit -- 1166
						do -- 1166
							local _obj_0 = require("Utils") -- 1166
							GSplit = _obj_0.GSplit -- 1166
						end -- 1166
						ossLicenses = { } -- 1167
						licenseText = licenseText:gsub("\r\n", "\n") -- 1168
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1169
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1170
							if name then -- 1170
								ossLicenses[#ossLicenses + 1] = { -- 1171
									name, -- 1171
									text -- 1171
								} -- 1171
							end -- 1170
						end -- 1169
					end -- 1165
				end -- 1164
				if ossLicenses then -- 1172
					OpenPopup(ossLicensePopup) -- 1172
				end -- 1172
			end -- 1163
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1173
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1174
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1175
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1176
				return BeginPopupModal(ossLicensePopup, true, { -- 1179
					"NoSavedSettings" -- 1179
				}, function() -- 1180
					for _index_0 = 1, #ossLicenses do -- 1181
						local _des_0 = ossLicenses[_index_0] -- 1181
						local firstLine, text = _des_0[1], _des_0[2] -- 1181
						local name, license = firstLine:match("(.+): (.+)") -- 1183
						if name then -- 1183
							TextColored(themeColor, name) -- 1184
							SameLine() -- 1185
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1186
								return TextWrapped(text) -- 1186
							end) -- 1186
						end -- 1183
					end -- 1181
				end) -- 1176
			end) -- 1176
		end -- 1162
		if not App.debugging then -- 1189
			return -- 1189
		end -- 1189
		return TreeNode(zh and "开发操作" or "Development", function() -- 1190
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1191
				OpenPopup("build") -- 1191
			end -- 1191
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1192
				return BeginPopup("build", function() -- 1192
					if Selectable(zh and "编译" or "Compile") then -- 1193
						doCompile(false) -- 1193
					end -- 1193
					Separator() -- 1194
					if Selectable(zh and "压缩" or "Minify") then -- 1195
						doCompile(true) -- 1195
					end -- 1195
					Separator() -- 1196
					if Selectable(zh and "清理" or "Clean") then -- 1197
						return doClean() -- 1197
					end -- 1197
				end) -- 1192
			end) -- 1192
			if isInEntry then -- 1198
				if waitForWebStart then -- 1199
					BeginDisabled(function() -- 1200
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1200
					end) -- 1200
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1201
					reloadDevEntry() -- 1202
				end -- 1199
			end -- 1198
			do -- 1203
				local changed -- 1203
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1203
				if changed then -- 1203
					View.scale = scaleContent and screenScale or 1 -- 1204
				end -- 1203
			end -- 1203
			do -- 1205
				local changed -- 1205
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1205
				if changed then -- 1205
					config.engineDev = engineDev -- 1206
				end -- 1205
			end -- 1205
			do -- 1207
				local changed -- 1207
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1207
				if changed then -- 1207
					config.webIDETourCompleted = webIDETourCompleted -- 1208
				end -- 1207
			end -- 1207
			if testingThread then -- 1209
				return BeginDisabled(function() -- 1210
					return Button(zh and "开始自动测试" or "Test automatically") -- 1210
				end) -- 1210
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1211
				testingThread = thread(function() -- 1212
					local _ <close> = setmetatable({ }, { -- 1213
						__close = function() -- 1213
							allClear() -- 1214
							testingThread = nil -- 1215
							isInEntry = true -- 1216
							currentEntry = nil -- 1217
							return print("Testing done!") -- 1218
						end -- 1213
					}) -- 1213
					for _, entry in ipairs(allEntries) do -- 1219
						allClear() -- 1220
						print("Start " .. tostring(entry.entryName)) -- 1221
						enterDemoEntry(entry) -- 1222
						sleep(2) -- 1223
						print("Stop " .. tostring(entry.entryName)) -- 1224
					end -- 1219
				end) -- 1212
			end -- 1209
		end) -- 1190
	end -- 1086
end -- 1066
local icon = Path(Content.assetPath, "Script", "Dev", "icon_s.png") -- 1226
local iconTex = nil -- 1227
Director.systemScheduler:schedule(once(function() -- 1228
	if Cache:loadAsync(icon) then -- 1228
		iconTex = Texture2D(icon) -- 1228
	end -- 1228
end)) -- 1228
local webStatus = nil -- 1230
local urlClicked = nil -- 1231
local authCode = string.format("%06d", math.random(0, 999999)) -- 1233
local authCodeTTL = 30.0 -- 1235
_module_0.getAuthCode = function() -- 1236
	return authCode -- 1236
end -- 1236
_module_0.invalidateAuthCode = function() -- 1237
	authCode = string.format("%06d", math.random(0, 999999)) -- 1238
	authCodeTTL = 30.0 -- 1239
end -- 1237
local AuthSession -- 1241
do -- 1241
	local pending = nil -- 1242
	local session = nil -- 1243
	AuthSession = { -- 1245
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1245
			pending = { -- 1247
				sessionId = sessionId, -- 1247
				confirmCode = confirmCode, -- 1248
				expiresAt = expiresAt, -- 1249
				ttl = ttl, -- 1250
				approved = false -- 1251
			} -- 1246
		end, -- 1245
		getPending = function() -- 1253
			return pending -- 1253
		end, -- 1253
		approvePending = function(sessionId) -- 1255
			if pending and pending.sessionId == sessionId then -- 1256
				pending.approved = true -- 1257
				return true -- 1258
			end -- 1256
			return false -- 1259
		end, -- 1255
		clearPending = function() -- 1261
			pending = nil -- 1261
		end, -- 1261
		setSession = function(sessionId, sessionSecret) -- 1263
			session = { -- 1265
				sessionId = sessionId, -- 1265
				sessionSecret = sessionSecret -- 1266
			} -- 1264
		end, -- 1263
		getSession = function() -- 1268
			return session -- 1268
		end -- 1268
	} -- 1244
end -- 1241
_module_0["AuthSession"] = AuthSession -- 1241
local transparant = Color(0x0) -- 1271
local windowFlags = { -- 1272
	"NoTitleBar", -- 1272
	"NoResize", -- 1272
	"NoMove", -- 1272
	"NoCollapse", -- 1272
	"NoSavedSettings", -- 1272
	"NoFocusOnAppearing", -- 1272
	"NoBringToFrontOnFocus" -- 1272
} -- 1272
local statusFlags = { -- 1281
	"NoTitleBar", -- 1281
	"NoResize", -- 1281
	"NoMove", -- 1281
	"NoCollapse", -- 1281
	"AlwaysAutoResize", -- 1281
	"NoSavedSettings" -- 1281
} -- 1281
local displayWindowFlags = { -- 1289
	"NoDecoration", -- 1289
	"NoSavedSettings", -- 1289
	"NoMove", -- 1289
	"NoScrollWithMouse", -- 1289
	"AlwaysAutoResize", -- 1289
	"NoFocusOnAppearing" -- 1289
} -- 1289
local _anon_func_7 = function(allEntries, currentIndex) -- 1362
	if currentIndex > 1 then -- 1362
		return allEntries[currentIndex - 1] -- 1363
	else -- 1365
		return allEntries[#allEntries] -- 1365
	end -- 1362
end -- 1362
local _anon_func_8 = function(allEntries, currentIndex) -- 1369
	if currentIndex < #allEntries then -- 1369
		return allEntries[currentIndex + 1] -- 1370
	else -- 1372
		return allEntries[1] -- 1372
	end -- 1369
end -- 1369
local _anon_func_9 = function(allEntries) -- 1412
	local _val_0 = allEntries.urlHandlerState -- 1412
	return "other" == _val_0 or "error" == _val_0 -- 1412
end -- 1412
do -- 1298
	local gamepadInputWindowFlags = { -- 1299
		"NoDecoration", -- 1299
		"NoSavedSettings", -- 1299
		"NoMove", -- 1299
		"NoScrollbar", -- 1299
		"NoScrollWithMouse", -- 1299
		"NoFocusOnAppearing", -- 1299
		"NoBringToFrontOnFocus" -- 1299
	} -- 1299
	local initFooter = true -- 1308
	local gamepadInputFocused = false -- 1309
	footerWindow = threadLoop(function() -- 1310
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1311
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1312
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1313
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1314
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1315
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1316
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1317
		if mobileMode then -- 1318
			return -- 1318
		end -- 1318
		local zh = useChinese -- 1319
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1320
		if authCodeTTL <= 0 then -- 1321
			authCodeTTL = 30.0 -- 1322
			authCode = string.format("%06d", math.random(0, 999999)) -- 1323
		end -- 1321
		if HttpServer.wsConnectionCount > 0 then -- 1324
			return -- 1325
		end -- 1324
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1326
			if App.platform == "Emscripten" then -- 1327
				stop() -- 1329
			else -- 1331
				allClear() -- 1331
				App.devMode = false -- 1332
				App:shutdown() -- 1333
			end -- 1327
		end -- 1326
		do -- 1334
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1335
			if ctrl and Keyboard:isKeyDown("Q") then -- 1336
				stop() -- 1337
			end -- 1336
			if ctrl and Keyboard:isKeyDown("Z") then -- 1338
				reloadCurrentEntry() -- 1339
			end -- 1338
			if ctrl and Keyboard:isKeyDown(",") then -- 1340
				if showFooter then -- 1341
					showStats = not showStats -- 1341
				else -- 1341
					showStats = true -- 1341
				end -- 1341
				showFooter = true -- 1342
				config.showFooter = showFooter -- 1343
				config.showStats = showStats -- 1344
			end -- 1340
			if ctrl and Keyboard:isKeyDown(".") then -- 1345
				if showFooter then -- 1346
					showConsole = not showConsole -- 1346
				else -- 1346
					showConsole = true -- 1346
				end -- 1346
				showFooter = true -- 1347
				config.showFooter = showFooter -- 1348
				config.showConsole = showConsole -- 1349
			end -- 1345
			if ctrl and Keyboard:isKeyDown("/") then -- 1350
				showFooter = not showFooter -- 1351
				config.showFooter = showFooter -- 1352
			end -- 1350
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1353
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1354
			local currentIndex = nil -- 1355
			for i, entry in ipairs(allEntries) do -- 1356
				if currentEntry == entry then -- 1357
					currentIndex = i -- 1358
				end -- 1357
			end -- 1356
			if left then -- 1359
				allClear() -- 1360
				if currentIndex == nil then -- 1361
					currentIndex = #allEntries + 1 -- 1361
				end -- 1361
				enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 1362
			end -- 1359
			if right then -- 1366
				allClear() -- 1367
				if currentIndex == nil then -- 1368
					currentIndex = 0 -- 1368
				end -- 1368
				enterDemoEntry(_anon_func_8(allEntries, currentIndex)) -- 1369
			end -- 1366
		end -- 1334
		if not showEntry then -- 1373
			return -- 1373
		end -- 1373
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1375
			reloadDevEntry() -- 1379
		end -- 1375
		if initFooter then -- 1380
			initFooter = false -- 1381
		end -- 1380
		local width, height -- 1383
		do -- 1383
			local _obj_0 = App.visualSize -- 1383
			width, height = _obj_0.width, _obj_0.height -- 1383
		end -- 1383
		if isInEntry then -- 1384
			gamepadInputFocused = false -- 1385
		else -- 1387
			SetNextWindowBgAlpha(0.0) -- 1387
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1388
			SetNextWindowPos(Vec2.zero, "Always") -- 1389
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1390
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1391
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1392
						if not gamepadInputFocused then -- 1393
							SetWindowFocus("DoraGamepadInput") -- 1394
							gamepadInputFocused = true -- 1395
						end -- 1393
					end) -- 1392
				end) -- 1391
			end) -- 1390
		end -- 1384
		if isInEntry or showFooter then -- 1397
			SetNextWindowSize(Vec2(width, 50)) -- 1398
			SetNextWindowPos(Vec2(0, height - 50)) -- 1399
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1400
				return PushStyleVar("WindowRounding", 0, function() -- 1401
					return Begin("Footer", windowFlags, function() -- 1402
						Separator() -- 1403
						if iconTex then -- 1404
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1405
								showStats = not showStats -- 1406
								config.showStats = showStats -- 1407
							end -- 1405
							SameLine() -- 1408
						end -- 1404
						if Button(">_", Vec2(30, 30)) then -- 1409
							showConsole = not showConsole -- 1410
							config.showConsole = showConsole -- 1411
						end -- 1409
						if App.platform == "Windows" and _anon_func_9(allEntries) then -- 1412
							SameLine() -- 1413
							if Button(zh and "注册浏览器链接" or "Register browser links") then -- 1414
								emit("AppURLHandler", "register") -- 1415
							end -- 1414
						end -- 1412
						if isInEntry and updateState.available then -- 1416
							SameLine() -- 1417
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1418
								allClear() -- 1419
								enterDemoEntry({ -- 1421
									entryName = "SelfUpdater", -- 1421
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1422
								}) -- 1420
							end -- 1418
						end -- 1416
						if not isInEntry then -- 1423
							SameLine() -- 1424
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1425
							local currentIndex = nil -- 1426
							for i, entry in ipairs(allEntries) do -- 1427
								if currentEntry == entry then -- 1428
									currentIndex = i -- 1429
								end -- 1428
							end -- 1427
							if currentIndex then -- 1430
								if currentIndex > 1 then -- 1431
									SameLine() -- 1432
									if Button("<<", Vec2(30, 30)) then -- 1433
										allClear() -- 1434
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1435
									end -- 1433
								end -- 1431
								if currentIndex < #allEntries then -- 1436
									SameLine() -- 1437
									if Button(">>", Vec2(30, 30)) then -- 1438
										allClear() -- 1439
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1440
									end -- 1438
								end -- 1436
							end -- 1430
							SameLine() -- 1441
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1442
								reloadCurrentEntry() -- 1443
							end -- 1442
							if back then -- 1444
								allClear() -- 1445
								isInEntry = true -- 1446
								currentEntry = nil -- 1447
							end -- 1444
						end -- 1423
					end) -- 1402
				end) -- 1401
			end) -- 1400
		end -- 1397
		if isInEntry then -- 1449
			local showURL = true -- 1450
			local webIDEWidth -- 1451
			do -- 1451
				local base -- 1452
				if updateState.available then -- 1452
					base = 460 -- 1452
				else -- 1452
					base = 360 -- 1452
				end -- 1452
				local extra = 35 -- 1453
				webIDEWidth = base + extra -- 1454
			end -- 1451
			if width < webIDEWidth then -- 1455
				showURL = false -- 1455
			end -- 1455
			SetNextWindowBgAlpha(0.0) -- 1456
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1457
			Begin("Web IDE", displayWindowFlags, function() -- 1458
				local pending = AuthSession.getPending() -- 1459
				local hovered = false -- 1460
				if not pending and showURL then -- 1461
					do -- 1462
						local url -- 1462
						if webStatus ~= nil then -- 1462
							url = webStatus.url -- 1462
						end -- 1462
						if url then -- 1462
							if isDesktop and not config.fullScreen then -- 1463
								if urlClicked then -- 1464
									BeginDisabled(function() -- 1465
										return Button(url) -- 1465
									end) -- 1465
								elseif Button(url) then -- 1466
									urlClicked = once(function() -- 1467
										return sleep(5) -- 1467
									end) -- 1467
									App:openURL("http://localhost:8866") -- 1468
								end -- 1464
							else -- 1470
								TextColored(descColor, url) -- 1470
							end -- 1463
						else -- 1472
							TextColored(descColor, zh and '不可用' or 'not available') -- 1472
						end -- 1462
					end -- 1462
					hovered = IsItemHovered() -- 1473
				else -- 1475
					TextColored(descColor, "(?)") -- 1475
					hovered = IsItemHovered() -- 1476
				end -- 1461
				SameLine() -- 1477
				local themeColor = App.themeColor -- 1478
				if pending then -- 1479
					if not pending.approved then -- 1480
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1481
						local ttl = pending.ttl or 1 -- 1482
						PushStyleColor("Text", themeColor, function() -- 1483
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1484
							hovered = hovered or IsItemHovered() -- 1485
						end) -- 1483
						SameLine() -- 1486
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1487
							AuthSession.approvePending(pending.sessionId) -- 1488
						end -- 1487
						if hovered then -- 1489
							return BeginTooltip(function() -- 1490
								return PushTextWrapPos(280, function() -- 1491
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1492
								end) -- 1491
							end) -- 1490
						end -- 1489
					end -- 1480
				else -- 1494
					PushStyleColor("Text", themeColor, function() -- 1494
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1495
						hovered = hovered or IsItemHovered() -- 1496
					end) -- 1494
					if hovered then -- 1497
						return BeginTooltip(function() -- 1498
							return PushTextWrapPos(280, function() -- 1499
								local url -- 1500
								if webStatus ~= nil then -- 1500
									url = webStatus.url -- 1500
								end -- 1500
								if url then -- 1500
									local address -- 1501
									if showURL then -- 1501
										address = "Web IDE" -- 1501
									else -- 1501
										address = url -- 1501
									end -- 1501
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1502
								else -- 1504
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1504
								end -- 1500
							end) -- 1499
						end) -- 1498
					end -- 1497
				end -- 1479
			end) -- 1458
		end -- 1449
		if not isInEntry then -- 1505
			SetNextWindowSize(Vec2(50, 50)) -- 1506
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1507
			PushStyleColor("WindowBg", transparant, function() -- 1508
				return Begin("Show", displayWindowFlags, function() -- 1508
					if width >= 370 then -- 1509
						local changed -- 1510
						changed, showFooter = Checkbox("##dev", showFooter) -- 1510
						if changed then -- 1510
							config.showFooter = showFooter -- 1511
						end -- 1510
					end -- 1509
				end) -- 1508
			end) -- 1508
		end -- 1505
		if isInEntry or showFooter then -- 1513
			if showStats then -- 1514
				PushStyleVar("WindowRounding", 0, function() -- 1515
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1516
					SetNextWindowSize(Vec2(0, height - 50)) -- 1517
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1518
					config.showStats = showStats -- 1519
				end) -- 1515
			end -- 1514
			if showConsole then -- 1520
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1521
				return PushStyleVar("WindowRounding", 6, function() -- 1522
					return ShowConsole() -- 1523
				end) -- 1522
			end -- 1520
		end -- 1513
	end) -- 1310
end -- 1298
local _anon_func_10 = function() -- 1719
	local _val_0 = App.platform -- 1719
	return "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 1719
end -- 1719
do -- 1526
	local MaxWidth <const> = 960 -- 1527
	local toolOpen = false -- 1529
	local filterText = nil -- 1530
	allEntries.anyEntryMatched = false -- 1531
	allEntries.match = function(name) -- 1532
		local res = not filterText or name:lower():match(filterText) -- 1533
		if res then -- 1534
			allEntries.anyEntryMatched = true -- 1534
		end -- 1534
		return res -- 1535
	end -- 1532
	allEntries.thinSep = function() -- 1537
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1537
			return ImGui.SeparatorText("") -- 1537
		end) -- 1537
	end -- 1537
	entryWindow = threadLoop(function() -- 1538
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1539
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1540
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1541
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1542
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1543
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1544
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1545
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1546
		local connected = syncWebIDEControl() -- 1547
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1549
			if not allEntries.pendingPackagePath then -- 1550
				local path = App:takeReceivedFile() -- 1551
				if path ~= "" then -- 1552
					allEntries.pendingPackagePath = path -- 1552
				end -- 1552
			end -- 1550
			if allEntries.pendingPackagePath then -- 1553
				allEntries.mobileControl.pendingUIMode = true -- 1553
			end -- 1553
		end -- 1549
		if (allEntries.mobileControl.pendingUIMode ~= nil) then -- 1555
			local nextMode = allEntries.mobileControl.pendingUIMode -- 1556
			allEntries.mobileControl.pendingUIMode = nil -- 1557
			applyUIMode(nextMode) -- 1558
		end -- 1555
		if mobileMode and not connected then -- 1559
			if allEntries.importReveal and feedHost and feedHost.visible then -- 1560
				local _list_0 = getMobileFeedEntries() -- 1561
				for _index_0 = 1, #_list_0 do -- 1561
					local entry = _list_0[_index_0] -- 1561
					if entry.fileName == allEntries.importFocusedFile then -- 1562
						feedHost:emit("RestoreFeedEntry", entry) -- 1563
						allEntries.importReveal = false -- 1564
						break -- 1565
					end -- 1562
				end -- 1561
			end -- 1560
			if isInEntry and not feedHost then -- 1566
				applyUIMode(true) -- 1566
			end -- 1566
			return -- 1567
		end -- 1559
		if App.fpsLimited ~= config.fpsLimited then -- 1568
			config.fpsLimited = App.fpsLimited -- 1569
		end -- 1568
		if App.targetFPS ~= config.targetFPS then -- 1570
			config.targetFPS = App.targetFPS -- 1571
		end -- 1570
		if View.vsync ~= config.vsync then -- 1572
			config.vsync = View.vsync -- 1573
		end -- 1572
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1574
			config.fixedFPS = Director.scheduler.fixedFPS -- 1575
		end -- 1574
		if Director.profilerSending ~= config.webProfiler then -- 1576
			config.webProfiler = Director.profilerSending -- 1577
		end -- 1576
		if urlClicked then -- 1578
			local _, result = coroutine.resume(urlClicked) -- 1579
			if result then -- 1580
				coroutine.close(urlClicked) -- 1581
				urlClicked = nil -- 1582
			end -- 1580
		end -- 1578
		if not isInEntry then -- 1583
			return -- 1583
		end -- 1583
		local zh = useChinese -- 1584
		local themeColor = App.themeColor -- 1585
		if connected then -- 1586
			local width, height -- 1587
			do -- 1587
				local _obj_0 = App.visualSize -- 1587
				width, height = _obj_0.width, _obj_0.height -- 1587
			end -- 1587
			SetNextWindowBgAlpha(0.5) -- 1588
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1589
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1590
				Separator() -- 1591
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1592
				if iconTex then -- 1593
					Image(icon, Vec2(24, 24)) -- 1594
					SameLine() -- 1595
				end -- 1593
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1596
				TextColored(descColor, slogon) -- 1597
				return Separator() -- 1598
			end) -- 1590
			return -- 1599
		end -- 1586
		if not showEntry then -- 1600
			return -- 1600
		end -- 1600
		local fullWidth, height -- 1602
		do -- 1602
			local _obj_0 = App.visualSize -- 1602
			fullWidth, height = _obj_0.width, _obj_0.height -- 1602
		end -- 1602
		local width = math.min(MaxWidth, fullWidth) -- 1603
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1604
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1605
		SetNextWindowPos(Vec2.zero) -- 1606
		SetNextWindowBgAlpha(0) -- 1607
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1608
		do -- 1609
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1610
				return Begin("Dora Dev", windowFlags, function() -- 1611
					Dummy(Vec2(fullWidth - 20, 0)) -- 1612
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1613
					SameLine() -- 1614
					if Button(zh and "Go 模式" or "Go Mode") then -- 1615
						setUIMode("mobile") -- 1616
					end -- 1615
					if fullWidth >= 540 then -- 1617
						SameLine() -- 1618
						Dummy(Vec2(fullWidth - 540, 0)) -- 1619
						SameLine() -- 1620
						SetNextItemWidth(zh and -95 or -140) -- 1621
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1622
							"AutoSelectAll" -- 1622
						}) then -- 1622
							config.filter = filterBuf.text -- 1623
							allEntries.importFocusedFile = nil -- 1624
							allEntries.importReveal = false -- 1625
						end -- 1622
						SameLine() -- 1626
						if Button(zh and '下载' or 'Download') then -- 1627
							ImGui.OpenPopup("project-download") -- 1627
						end -- 1627
						ImGui.BeginPopup("project-download", function() -- 1628
							if ImGui.Selectable(zh and "从 Git 仓库导入…" or "Import Git repository…") then -- 1629
								emit("RepositoryImport", nil) -- 1630
							end -- 1629
							if ImGui.Selectable(zh and "浏览资源目录…" or "Browse resource catalog…") then -- 1631
								allClear() -- 1632
								return enterDemoEntry({ -- 1634
									entryName = "ResourceDownloader", -- 1634
									fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1635
								}) -- 1633
							end -- 1631
						end) -- 1628
					end -- 1617
					return Separator() -- 1636
				end) -- 1611
			end) -- 1610
		end -- 1609
		allEntries.anyEntryMatched = false -- 1638
		SetNextWindowPos(Vec2(0, 50)) -- 1639
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1640
		local scrollbarSize <const> = 25 -- 1642
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1643
		do -- 1644
			return PushStyleColor("WindowBg", transparant, function() -- 1645
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1646
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1647
						return PushStyleVar("Alpha", 1, function() -- 1648
							return Begin("Content", windowFlags, function() -- 1649
								local DemoViewWidth <const> = 220 -- 1650
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1651
								if filterText then -- 1652
									filterText = filterText:lower() -- 1652
								end -- 1652
								if App.platform == "Emscripten" then -- 1653
									Dora.globals.webProjects.draw(zh, themeColor) -- 1654
									allEntries.anyEntryMatched = true -- 1655
								end -- 1653
								if #gamesInDev > 0 then -- 1656
									if App.platform == "Windows" then -- 1657
										if windowsExport.busy then -- 1658
											ImGui.TextDisabled(zh and "正在导出 Windows 游戏…" or "Exporting Windows game…") -- 1658
										end -- 1658
										if windowsExport.message then -- 1659
											TextWrapped(windowsExport.message) -- 1659
										end -- 1659
									end -- 1657
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1660
									Columns(columns, false) -- 1661
									local realViewWidth = GetColumnWidth() - 50 -- 1662
									for _index_0 = 1, #gamesInDev do -- 1663
										local game = gamesInDev[_index_0] -- 1663
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1664
										local displayName -- 1673
										if repo then -- 1673
											if zh then -- 1674
												displayName = repo.title.zh -- 1674
											else -- 1674
												displayName = repo.title.en -- 1674
											end -- 1674
										end -- 1673
										if displayName == nil then -- 1675
											displayName = gameName -- 1675
										end -- 1675
										if allEntries.match(displayName) or allEntries.importFocusedFile == fileName then -- 1676
											allEntries.anyEntryMatched = true -- 1677
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1678
											SameLine() -- 1679
											if allEntries.importFocusedFile == fileName then -- 1680
												PushStyleColor("Text", themeColor, function() -- 1681
													return TextWrapped(displayName) -- 1681
												end) -- 1681
											else -- 1683
												TextWrapped(displayName) -- 1683
											end -- 1680
											if allEntries.importFocusedFile == fileName and allEntries.importReveal then -- 1684
												ImGui.SetScrollHereY(0.5) -- 1685
												allEntries.importReveal = false -- 1686
											end -- 1684
											if columns > 1 then -- 1687
												if bannerFile and bannerTex then -- 1688
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1689
													local displayWidth <const> = realViewWidth -- 1690
													texHeight = displayWidth * texHeight / texWidth -- 1691
													texWidth = displayWidth -- 1692
													Dummy(Vec2.zero) -- 1693
													SameLine() -- 1694
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1695
												end -- 1688
												if game.needsBuild then -- 1696
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1697
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1698
													enterDemoEntry(game) -- 1699
												end -- 1696
											else -- 1701
												if bannerFile and bannerTex then -- 1701
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1702
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1703
													local sizing = 0.8 -- 1704
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1705
													texWidth = displayWidth * sizing -- 1706
													if texWidth > 500 then -- 1707
														sizing = 0.6 -- 1708
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1709
														texWidth = displayWidth * sizing -- 1710
													end -- 1707
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1711
													Dummy(Vec2(padding, 0)) -- 1712
													SameLine() -- 1713
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1714
												end -- 1701
												if game.needsBuild then -- 1715
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1716
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1717
													enterDemoEntry(game) -- 1718
												end -- 1715
											end -- 1687
											if _anon_func_10() and not windowsExport.busy and not game.needsBuild then -- 1719
												if Button(tostring(zh and "导出 Windows ZIP" or "Export Windows ZIP") .. "##" .. tostring(fileName), Vec2(-1, 30)) then -- 1720
													allEntries.exportWindowsGame(game, displayName) -- 1721
												end -- 1720
											end -- 1719
											if #tests == 0 and #examples == 0 then -- 1722
												allEntries.thinSep() -- 1723
											end -- 1722
											NextColumn() -- 1724
										end -- 1676
										local showSep = false -- 1725
										if #examples > 0 then -- 1726
											local showExample = false -- 1727
											for _index_1 = 1, #examples do -- 1728
												local _des_0 = examples[_index_1] -- 1728
												local entryName = _des_0.entryName -- 1728
												if allEntries.match(entryName) then -- 1729
													showExample = true -- 1729
													break -- 1729
												end -- 1729
											end -- 1728
											if showExample then -- 1730
												showSep = true -- 1731
												Columns(1, false) -- 1732
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1733
												SameLine() -- 1734
												local opened -- 1735
												if (filterText ~= nil) then -- 1735
													opened = showExample -- 1735
												else -- 1735
													opened = false -- 1735
												end -- 1735
												if game.exampleOpen == nil then -- 1736
													game.exampleOpen = opened -- 1736
												end -- 1736
												SetNextItemOpen(game.exampleOpen) -- 1737
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1738
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1739
														Columns(maxColumns, false) -- 1740
														for _index_1 = 1, #examples do -- 1741
															local example = examples[_index_1] -- 1741
															local entryName = example.entryName -- 1742
															if not allEntries.match(entryName) then -- 1743
																goto _continue_0 -- 1743
															end -- 1743
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1744
																if Button(entryName, Vec2(-1, 40)) then -- 1745
																	enterDemoEntry(example) -- 1746
																end -- 1745
																return NextColumn() -- 1747
															end) -- 1744
															opened = true -- 1748
															::_continue_0:: -- 1742
														end -- 1741
													end) -- 1739
												end) -- 1738
												game.exampleOpen = opened -- 1749
											end -- 1730
										end -- 1726
										if #tests > 0 then -- 1750
											local showTest = false -- 1751
											for _index_1 = 1, #tests do -- 1752
												local _des_0 = tests[_index_1] -- 1752
												local entryName = _des_0.entryName -- 1752
												if allEntries.match(entryName) then -- 1753
													showTest = true -- 1753
													break -- 1753
												end -- 1753
											end -- 1752
											if showTest then -- 1754
												showSep = true -- 1755
												Columns(1, false) -- 1756
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1757
												SameLine() -- 1758
												local opened -- 1759
												if (filterText ~= nil) then -- 1759
													opened = showTest -- 1759
												else -- 1759
													opened = false -- 1759
												end -- 1759
												if game.testOpen == nil then -- 1760
													game.testOpen = opened -- 1760
												end -- 1760
												SetNextItemOpen(game.testOpen) -- 1761
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1762
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1763
														Columns(maxColumns, false) -- 1764
														for _index_1 = 1, #tests do -- 1765
															local test = tests[_index_1] -- 1765
															local entryName = test.entryName -- 1766
															if not allEntries.match(entryName) then -- 1767
																goto _continue_0 -- 1767
															end -- 1767
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1768
																if Button(entryName, Vec2(-1, 40)) then -- 1769
																	enterDemoEntry(test) -- 1770
																end -- 1769
																return NextColumn() -- 1771
															end) -- 1768
															opened = true -- 1772
															::_continue_0:: -- 1766
														end -- 1765
													end) -- 1763
												end) -- 1762
												game.testOpen = opened -- 1773
											end -- 1754
										end -- 1750
										if showSep then -- 1774
											Columns(1, false) -- 1775
											allEntries.thinSep() -- 1776
											Columns(columns, false) -- 1777
										end -- 1774
									end -- 1663
								end -- 1656
								if #doraTools > 0 then -- 1778
									local showTool = false -- 1779
									for _index_0 = 1, #doraTools do -- 1780
										local _des_0 = doraTools[_index_0] -- 1780
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1780
										local displayName -- 1781
										if repo then -- 1781
											if zh then -- 1782
												displayName = repo.title.zh -- 1782
											else -- 1782
												displayName = repo.title.en -- 1782
											end -- 1782
										end -- 1781
										if displayName == nil then -- 1783
											displayName = entryName -- 1783
										end -- 1783
										if allEntries.match(displayName) then -- 1784
											showTool = true -- 1784
											break -- 1784
										end -- 1784
									end -- 1780
									if not showTool then -- 1785
										goto endEntry -- 1785
									end -- 1785
									Columns(1, false) -- 1786
									TextColored(themeColor, "Dora SSR:") -- 1787
									SameLine() -- 1788
									Text(zh and "开发支持" or "Development Support") -- 1789
									Separator() -- 1790
									if #doraTools > 0 then -- 1791
										local opened -- 1792
										if (filterText ~= nil) then -- 1792
											opened = showTool -- 1792
										else -- 1792
											opened = false -- 1792
										end -- 1792
										SetNextItemOpen(toolOpen) -- 1793
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1794
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1795
												Columns(maxColumns, false) -- 1796
												for _index_0 = 1, #doraTools do -- 1797
													local tool = doraTools[_index_0] -- 1797
													local entryName, repo = tool.entryName, tool.repo -- 1798
													local displayName -- 1799
													if repo then -- 1799
														if zh then -- 1800
															displayName = repo.title.zh -- 1800
														else -- 1800
															displayName = repo.title.en -- 1800
														end -- 1800
													end -- 1799
													if displayName == nil then -- 1801
														displayName = entryName -- 1801
													end -- 1801
													if not allEntries.match(displayName) then -- 1802
														goto _continue_0 -- 1802
													end -- 1802
													if Button(displayName, Vec2(-1, 40)) then -- 1803
														enterDemoEntry(tool) -- 1804
													end -- 1803
													NextColumn() -- 1805
													::_continue_0:: -- 1798
												end -- 1797
												Columns(1, false) -- 1806
												opened = true -- 1807
											end) -- 1795
										end) -- 1794
										toolOpen = opened -- 1808
									end -- 1791
								end -- 1778
								::endEntry:: -- 1809
								if not allEntries.anyEntryMatched then -- 1810
									SetNextWindowBgAlpha(0) -- 1811
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1812
									Begin("Entries Not Found", displayWindowFlags, function() -- 1813
										Separator() -- 1814
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1815
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1816
										return Separator() -- 1817
									end) -- 1813
								end -- 1810
								Columns(1, false) -- 1818
								Dummy(Vec2(100, 80)) -- 1819
								return ScrollWhenDraggingOnVoid() -- 1820
							end) -- 1649
						end) -- 1648
					end) -- 1647
				end) -- 1646
			end) -- 1645
		end -- 1644
	end) -- 1538
end -- 1526
if not (App.platform == "Emscripten") then -- 1825
	local sceneModuleCache = moduleCache -- 1826
	moduleCache = { } -- 1827
	webStatus = oldRequire("Script.Dev.WebServer") -- 1828
	moduleCache = sceneModuleCache -- 1829
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1830
		thread(function() -- 1831
			wait(function() -- 1832
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1832
			end) -- 1832
			if App.webIDEEnabled then -- 1833
				return emit("AppWebView", "/ide/show", true) -- 1833
			end -- 1833
		end) -- 1831
	end -- 1830
end -- 1825
local _anon_func_11 = function(saved) -- 1856
	local _val_0 = saved.kind -- 1856
	return "local" == _val_0 or "discover" == _val_0 -- 1856
end -- 1856
local _anon_func_12 = function(saved) -- 1860
	local _val_0 = saved.activeTab -- 1860
	return "local" == _val_0 or "discover" == _val_0 -- 1860
end -- 1860
startMobileUI = function() -- 1835
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1836
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1837
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1838
	local getMobileFeedResources -- 1839
	do -- 1839
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1839
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1839
	end -- 1839
	local loadCachedCatalog -- 1840
	do -- 1840
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1840
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1840
	end -- 1840
	local getResourceInstallPath, getInstalledCatalogResource -- 1841
	do -- 1841
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1841
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1841
	end -- 1841
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1842
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1843
	local feedOptions = nil -- 1844
	local mobileLaunchErrors = { } -- 1845
	local withMobileLaunchErrors -- 1846
	withMobileLaunchErrors = function(items) -- 1846
		for _index_0 = 1, #items do -- 1847
			local item = items[_index_0] -- 1847
			item.launchError = mobileLaunchErrors[item.id] -- 1848
		end -- 1847
		return items -- 1849
	end -- 1846
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1850
	local loadRememberedMobileFeedState -- 1851
	loadRememberedMobileFeedState = function() -- 1851
		local raw = rememberedMobileFeedData -- 1852
		if not (type(raw) == "string" and raw ~= "") then -- 1853
			return -- 1853
		end -- 1853
		local ok, saved = pcall(json.decode, raw) -- 1854
		if not (ok and type(saved) == "table") then -- 1855
			return -- 1855
		end -- 1855
		if type(saved.id) == "string" and _anon_func_11(saved) then -- 1856
			local state = { -- 1857
				activeTab = saved.kind -- 1857
			} -- 1857
			state[saved.kind] = saved -- 1858
			return state -- 1859
		end -- 1856
		local state = { -- 1860
			activeTab = _anon_func_12(saved) and saved.activeTab or "local" -- 1860
		} -- 1860
		local _list_0 = { -- 1861
			"local", -- 1861
			"discover" -- 1861
		} -- 1861
		for _index_0 = 1, #_list_0 do -- 1861
			local kind = _list_0[_index_0] -- 1861
			local entry = saved[kind] -- 1862
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1863
				state[kind] = entry -- 1863
			end -- 1863
		end -- 1861
		return state -- 1864
	end -- 1851
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1865
		activeTab = "local" -- 1865
	} -- 1865
	local rememberMobileFeedEntry -- 1866
	rememberMobileFeedEntry = function(entry) -- 1866
		rememberedMobileFeedState.activeTab = entry.kind -- 1867
		rememberedMobileFeedState[entry.kind] = { -- 1869
			id = entry.id, -- 1869
			kind = entry.kind, -- 1870
			workDir = entry.workDir, -- 1871
			fileName = entry.fileName -- 1872
		} -- 1868
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1874
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1875
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1876
			rememberedMobileFeedData -- 1876
		}) -- 1876
	end -- 1866
	local restartMobileFeed -- 1877
	restartMobileFeed = function(entry) -- 1877
		if feedHost then -- 1878
			feedHost:removeFromParent(true) -- 1878
		end -- 1878
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1879
		local initialEntries = { } -- 1880
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1881
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1882
		feedOptions.initialEntries = initialEntries -- 1883
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1884
	end -- 1877
	local startMobilePlay -- 1885
	startMobilePlay = function(entry) -- 1885
		if HttpServer.wsConnectionCount > 0 then -- 1886
			return -- 1886
		end -- 1886
		if entry.needsBuild then -- 1887
			mobileLaunchErrors[entry.id] = useChinese and "请先在 IDE 中编译项目" or "Build the project in the IDE first" -- 1888
			restartMobileFeed(entry) -- 1889
			return -- 1890
		end -- 1887
		local originFeed = feedHost -- 1891
		if remixHost then -- 1892
			remixHost:removeFromParent(true) -- 1892
		end -- 1892
		remixHost = nil -- 1893
		mobileLaunchErrors[entry.id] = nil -- 1894
		entry.launchError = nil -- 1895
		local playActive = true -- 1896
		local playHost = nil -- 1897
		local restoreMobileFeed -- 1898
		restoreMobileFeed = function() -- 1898
			if not playActive then -- 1899
				return -- 1899
			end -- 1899
			playActive = false -- 1900
			if playHost and playHost.parent then -- 1902
				playHost:removeFromParent(true) -- 1902
			end -- 1902
			playHost = nil -- 1903
			allClear() -- 1904
			isInEntry = true -- 1905
			currentEntry = nil -- 1906
			return restartMobileFeed(entry) -- 1907
		end -- 1898
		playHost = trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1909
			onExit = function() -- 1909
				return restoreMobileFeed() -- 1909
			end, -- 1909
			onRuntimeError = function() -- 1910
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1911
				return restoreMobileFeed() -- 1912
			end -- 1910
		})) -- 1908
		return thread(function() -- 1914
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1918
			if not playActive then -- 1919
				return -- 1919
			end -- 1919
			if success then -- 1920
				if originFeed and originFeed.parent then -- 1921
					originFeed.visible = false -- 1921
				end -- 1921
				return -- 1922
			end -- 1920
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1923
			return restoreMobileFeed() -- 1924
		end) -- 1914
	end -- 1885
	feedOptions = { -- 1926
		takeReceivedFile = function() -- 1926
			if allEntries.pendingPackagePath then -- 1927
				local path = allEntries.pendingPackagePath -- 1928
				allEntries.pendingPackagePath = nil -- 1929
				return path -- 1930
			end -- 1927
			return App:takeReceivedFile() -- 1931
		end, -- 1926
		onSwitchMode = function() -- 1932
			if HttpServer.wsConnectionCount == 0 then -- 1932
				allEntries.mobileControl.pendingUIMode = false -- 1932
			end -- 1932
		end, -- 1932
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1933
		getLocalEntries = function(importedProjectPath) -- 1934
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1935
			feedOptions.dirtyProjectPath = nil -- 1936
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1937
			local cached = loadCachedCatalog() -- 1938
			if cached.success and cached.snapshot then -- 1939
				for _index_0 = 1, #items do -- 1940
					local entry = items[_index_0] -- 1940
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1941
					if resource then -- 1942
						entry.resource = resource -- 1943
						entry.catalogCommit = cached.snapshot.commit -- 1944
					end -- 1942
				end -- 1940
			end -- 1939
			return items -- 1945
		end, -- 1934
		syncDiscover = function(onProgress, onDone, force) -- 1946
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1946
		end, -- 1946
		getDiscoverEntries = function() -- 1947
			local cached = loadCachedCatalog() -- 1948
			if not (cached.success and cached.snapshot) then -- 1949
				return { } -- 1949
			end -- 1949
			local items = { } -- 1950
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1951
			for _index_0 = 1, #_list_0 do -- 1951
				local resource = _list_0[_index_0] -- 1951
				local installed = lifecycle.isMobileResourceReady(resource) -- 1952
				local installPath = getResourceInstallPath(resource.id) -- 1953
				items[#items + 1] = { -- 1955
					id = resource.id, -- 1955
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1956
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1957
					kind = "discover", -- 1958
					bannerFile = resource.bannerPath, -- 1959
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1960
					sourceUrl = resource.versions[1].sources[1].url, -- 1961
					workDir = installed and installPath or nil, -- 1962
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1963
					installed = installed, -- 1964
					resource = resource, -- 1965
					catalogCommit = cached.snapshot.commit, -- 1966
					launchError = mobileLaunchErrors[resource.id] -- 1967
				} -- 1954
			end -- 1951
			return items -- 1969
		end, -- 1947
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1970
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1971
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1972
			end), repairIncomplete, isCanceled) -- 1971
		end, -- 1970
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1974
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1975
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1976
			end), isCanceled) -- 1975
		end, -- 1974
		createProject = function(name, language) -- 1978
			local result = projectCreate.createMobileProject(name, language) -- 1979
			if not result.success then -- 1980
				return result -- 1980
			end -- 1980
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1981
			for _index_0 = 1, #_list_0 do -- 1981
				local entry = _list_0[_index_0] -- 1981
				if entry.workDir == result.workDir then -- 1982
					return { -- 1983
						success = true, -- 1983
						entry = entry -- 1983
					} -- 1983
				end -- 1982
			end -- 1981
			return { -- 1984
				success = false, -- 1984
				error = "created-project-not-found" -- 1984
			} -- 1984
		end, -- 1978
		onPlay = function(entry) -- 1985
			return startMobilePlay(entry) -- 1985
		end, -- 1985
		onRemix = function(entry) -- 1986
			if HttpServer.wsConnectionCount > 0 then -- 1987
				return -- 1987
			end -- 1987
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1988
			local originFeed = feedHost -- 1989
			feedHost.visible = false -- 1990
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1992
				entry = entry, -- 1992
				onProjectChanged = function(current) -- 1993
					feedOptions.dirtyProjectPath = current.workDir -- 1993
				end, -- 1993
				onBack = function() -- 1994
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1995
						originFeed:emit("RestoreFeedEntry", entry) -- 1996
						originFeed.visible = true -- 1997
					end -- 1995
				end, -- 1994
				onPlay = function(current) -- 1998
					return startMobilePlay(current) -- 1998
				end -- 1998
			})) -- 1991
		end -- 1986
	} -- 1925
	return restartMobileFeed() -- 2001
end -- 1835
if mobileMode then -- 2003
	applyUIMode(true) -- 2003
end -- 2003
return _module_0 -- 1
