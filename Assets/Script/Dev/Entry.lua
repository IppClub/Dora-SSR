-- [yue]: Script/Dev/Entry.yue
-- [yue]: Assets/Script/Dev/Entry.yue
local _module_0 = { } -- 1
local _ENV = Dora(Dora.ImGui) -- 9
local ProjectSearch = require("ProjectSearch") -- 10
local App <const> = App -- 12
local ShowConsole <const> = ShowConsole -- 12
local _G <const> = _G -- 12
local package <const> = package -- 12
local Dora <const> = Dora -- 12
local Content <const> = Content -- 12
local Path <const> = Path -- 12
local DB <const> = DB -- 12
local type <const> = type -- 12
local Log <const> = Log -- 12
local tostring <const> = tostring -- 12
local math <const> = math -- 12
local View <const> = View -- 12
local Director <const> = Director -- 12
local Size <const> = Size -- 12
local Vec2 <const> = Vec2 -- 12
local Controller <const> = Controller -- 12
local Color <const> = Color -- 12
local Buffer <const> = Buffer -- 12
local os <const> = os -- 12
local thread <const> = thread -- 12
local sleep <const> = sleep -- 12
local yue <const> = yue -- 12
local SetDefaultFont <const> = SetDefaultFont -- 12
local table <const> = table -- 12
local json <const> = json -- 12
local Cache <const> = Cache -- 12
local Texture2D <const> = Texture2D -- 12
local pcall <const> = pcall -- 12
local pairs <const> = pairs -- 12
local string <const> = string -- 12
local print <const> = print -- 12
local xml <const> = xml -- 12
local teal <const> = teal -- 12
local wait <const> = wait -- 12
local HttpServer <const> = HttpServer -- 12
local tolua <const> = tolua -- 12
local Routine <const> = Routine -- 12
local Entity <const> = Entity -- 12
local Platformer <const> = Platformer -- 12
local Audio <const> = Audio -- 12
local ubox <const> = ubox -- 12
local collectgarbage <const> = collectgarbage -- 12
local Wasm <const> = Wasm -- 12
local once <const> = once -- 12
local emit <const> = emit -- 12
local HttpClient <const> = HttpClient -- 12
local Profiler <const> = Profiler -- 12
local xpcall <const> = xpcall -- 12
local debug <const> = debug -- 12
local AlignNode <const> = AlignNode -- 12
local Label <const> = Label -- 12
local ImGui <const> = ImGui -- 12
local setmetatable <const> = setmetatable -- 12
local ipairs <const> = ipairs -- 12
local threadLoop <const> = threadLoop -- 12
local Keyboard <const> = Keyboard -- 12
local coroutine <const> = coroutine -- 12
local rawset <const> = rawset -- 12
local getmetatable <const> = getmetatable -- 12
App.idled = true -- 14
App.devMode = true -- 15
ShowConsole(true) -- 16
local moduleCache = { } -- 18
local oldRequire = _G.require -- 19
local require -- 20
require = function(path) -- 20
	local loaded = package.loaded[path] -- 21
	if loaded == nil then -- 22
		if not (path == "lualib_bundle" or path == "Script.Dev.AgentHost" or path == "Script.Dev.AgentStoragePanel" or path:match("^Agent[./]")) then -- 25
			moduleCache[#moduleCache + 1] = path -- 26
		end -- 25
		return oldRequire(path) -- 27
	end -- 22
	return loaded -- 28
end -- 20
_G.require = require -- 29
Dora.require = require -- 30
local searchPaths = Content.searchPaths -- 32
local useChinese = (App.locale:match("^zh") ~= nil) -- 34
local updateLocale -- 35
updateLocale = function() -- 35
	useChinese = (App.locale:match("^zh") ~= nil) -- 36
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 37
	Content.searchPaths = searchPaths -- 38
end -- 35
local isDesktop -- 40
do -- 40
	local _val_0 = App.platform -- 40
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 40
end -- 40
if DB:exist("Config") then -- 42
	do -- 43
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 43
		local _type_0 = type(_exp_0) -- 44
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 44
		if _tab_0 then -- 44
			local locale -- 44
			do -- 44
				local _obj_0 = _exp_0[1] -- 44
				local _type_1 = type(_obj_0) -- 44
				if "table" == _type_1 or "userdata" == _type_1 then -- 44
					locale = _obj_0[1] -- 44
				end -- 44
			end -- 44
			if locale ~= nil then -- 44
				if App.locale ~= locale then -- 44
					App.locale = locale -- 45
					updateLocale() -- 46
				end -- 44
			end -- 44
		end -- 43
	end -- 43
	if isDesktop then -- 47
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 48
		local _type_0 = type(_exp_0) -- 49
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 49
		if _tab_0 then -- 49
			local writablePath -- 49
			do -- 49
				local _obj_0 = _exp_0[1] -- 49
				local _type_1 = type(_obj_0) -- 49
				if "table" == _type_1 or "userdata" == _type_1 then -- 49
					writablePath = _obj_0[1] -- 49
				end -- 49
			end -- 49
			if writablePath ~= nil then -- 49
				if writablePath ~= "" and Content:exist(writablePath) and Content:isdir(writablePath) then -- 50
					Content.writablePath = writablePath -- 51
				else -- 53
					Log("Warning", "saved writable path \"" .. tostring(writablePath) .. "\" is unavailable; using \"" .. tostring(Content.writablePath) .. "\" instead") -- 53
					if not DB:exec("update Config set value_str = ? where name = ?", { -- 54
						Content.writablePath, -- 54
						"writablePath" -- 54
					}) then -- 54
						Log("Warning", "failed to persist the fallback writable path") -- 55
					end -- 54
				end -- 50
			end -- 49
		end -- 48
	end -- 47
end -- 42
local Config = require("Config") -- 57
if App.platform == "Emscripten" then -- 59
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 59
end -- 59
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "updateNotificationVersion", "ignoredUpdateVersion", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "agentLLMConfigVersion", "mobileRemixLLMConfigId", "mobileLargeText", "webIDEEnabled") -- 61
config:load() -- 99
oldRequire("Dev.ImportIDE") -- 102
if not (config.webIDEEnabled ~= nil) then -- 104
	config.webIDEEnabled = true -- 105
end -- 104
App.webIDEEnabled = config.webIDEEnabled -- 106
if not (config.writablePath ~= nil) then -- 108
	config.writablePath = Content.appPath -- 109
end -- 108
if not (config.webIDEConnected ~= nil) then -- 111
	config.webIDEConnected = false -- 112
end -- 111
if (config.fpsLimited ~= nil) then -- 114
	App.fpsLimited = config.fpsLimited -- 115
else -- 117
	config.fpsLimited = App.fpsLimited -- 117
end -- 114
if (config.targetFPS ~= nil) then -- 119
	App.targetFPS = math.floor(config.targetFPS) -- 120
else -- 122
	config.targetFPS = App.targetFPS -- 122
end -- 119
if (config.vsync ~= nil) then -- 124
	View.vsync = config.vsync -- 125
else -- 127
	config.vsync = View.vsync -- 127
end -- 124
if (config.fixedFPS ~= nil) then -- 129
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 130
else -- 132
	config.fixedFPS = Director.scheduler.fixedFPS -- 132
end -- 129
if not (config.showPreview ~= nil) then -- 134
	config.showPreview = true -- 135
end -- 134
if not (config.mobileFeed ~= nil) then -- 137
	local _val_0 = App.platform -- 138
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 138
end -- 137
if not (config.webIDETourCompleted ~= nil) then -- 140
	config.webIDETourCompleted = false -- 141
end -- 140
local showEntry = true -- 144
isDesktop = false -- 146
if (function() -- 147
	local _val_0 = App.platform -- 147
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 147
end)() then -- 147
	isDesktop = true -- 148
	if config.fullScreen then -- 149
		App.fullScreen = true -- 150
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 151
		local size = Size(config.winWidth, config.winHeight) -- 152
		if App.winSize ~= size then -- 153
			App.winSize = size -- 154
		end -- 153
		local winX, winY -- 155
		do -- 155
			local _obj_0 = App.winPosition -- 155
			winX, winY = _obj_0.x, _obj_0.y -- 155
		end -- 155
		if (config.winX ~= nil) then -- 156
			winX = config.winX -- 157
		else -- 159
			config.winX = -1 -- 159
		end -- 156
		if (config.winY ~= nil) then -- 160
			winY = config.winY -- 161
		else -- 163
			config.winY = -1 -- 163
		end -- 160
		App.winPosition = Vec2(winX, winY) -- 164
	end -- 149
	if (config.alwaysOnTop ~= nil) then -- 165
		App.alwaysOnTop = config.alwaysOnTop -- 166
	else -- 168
		config.alwaysOnTop = false -- 168
	end -- 165
	if (config.virtualGamepadEnabled ~= nil) then -- 169
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 170
	else -- 172
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 172
	end -- 169
end -- 147
if (config.themeColor ~= nil) then -- 174
	App.themeColor = Color(config.themeColor) -- 175
else -- 177
	config.themeColor = App.themeColor:toARGB() -- 177
end -- 174
if not (config.locale ~= nil) then -- 179
	config.locale = App.locale -- 180
end -- 179
local showStats = false -- 182
if (config.showStats ~= nil) then -- 183
	showStats = config.showStats -- 184
else -- 186
	config.showStats = showStats -- 186
end -- 183
local showConsole = false -- 188
if (config.showConsole ~= nil) then -- 189
	showConsole = config.showConsole -- 190
else -- 192
	config.showConsole = showConsole -- 192
end -- 189
local showFooter = true -- 194
if (config.showFooter ~= nil) then -- 195
	showFooter = config.showFooter -- 196
else -- 198
	config.showFooter = showFooter -- 198
end -- 195
local setFooterVisible -- 200
setFooterVisible = function(visible) -- 200
	if visible == nil then -- 200
		visible = true -- 200
	end -- 200
	showFooter = visible -- 201
	config.showFooter = showFooter -- 202
end -- 200
_module_0["setFooterVisible"] = setFooterVisible -- 200
local filterBuf = Buffer(20) -- 204
if (config.filter ~= nil) then -- 205
	filterBuf.text = config.filter -- 206
else -- 208
	config.filter = "" -- 208
end -- 205
local engineDev = false -- 210
if (config.engineDev ~= nil) then -- 211
	engineDev = config.engineDev -- 212
else -- 214
	config.engineDev = engineDev -- 214
end -- 211
if (config.webProfiler ~= nil) then -- 216
	Director.profilerSending = config.webProfiler -- 217
else -- 219
	config.webProfiler = true -- 219
	Director.profilerSending = true -- 220
end -- 216
if not (config.drawerWidth ~= nil) then -- 222
	config.drawerWidth = 200 -- 223
end -- 222
_module_0.getConfig = function() -- 225
	return config -- 225
end -- 225
_module_0.getEngineDev = function() -- 226
	if not App.debugging then -- 227
		return false -- 227
	end -- 227
	return config.engineDev -- 228
end -- 226
local _anon_func_0 = function() -- 233
	local _val_0 = App.platform -- 233
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 233
end -- 233
_module_0.connectWebIDE = function(embedded) -- 230
	if embedded == nil then -- 230
		embedded = false -- 230
	end -- 230
	if not config.webIDEConnected then -- 231
		config.webIDEConnected = true -- 232
		if not embedded and _anon_func_0() then -- 233
			local ratio = App.winSize.width / App.visualSize.width -- 234
			App.winSize = Size(640 * ratio, 480 * ratio) -- 235
		end -- 233
	end -- 231
end -- 230
local updateState = nil -- 238
local checkForUpdates -- 239
do -- 239
	local updateSceneCache = moduleCache -- 240
	moduleCache = { } -- 241
	local updater = oldRequire("Tools.SelfUpdater.Service") -- 242
	moduleCache = updateSceneCache -- 243
	updateState = updater.getState() -- 245
	if config.updateNotificationVersion ~= App.version then -- 246
		config.updateNotification = false -- 247
	end -- 246
	config.updateNotificationVersion = App.version -- 248
	updateState.available = config.updateNotification == true -- 249
	local publishUpdateState -- 250
	publishUpdateState = function(state) -- 250
		updateState = state -- 251
		config.updateNotification = state.available -- 252
		config.updateNotificationVersion = App.version -- 253
		config.ignoredUpdateVersion = state.ignoredVersion -- 254
		if state.checkedAt > 0 and not state.usedCache and state.checkedAt ~= config.lastUpdateCheck then -- 255
			config.lastUpdateCheck = state.checkedAt -- 256
		end -- 255
	end -- 250
	updater.bindEntryState((function() -- 257
		return updateState -- 257
	end), publishUpdateState, config.ignoredUpdateVersion) -- 257
	checkForUpdates = function(manual, source) -- 258
		if manual == nil then -- 258
			manual = true -- 258
		end -- 258
		if source == nil then -- 258
			source = nil -- 258
		end -- 258
		if not manual then -- 259
			if App.platform == "Emscripten" then -- 260
				return false -- 260
			end -- 260
			if (config.lastUpdateCheck ~= nil) and os.difftime(os.time(), config.lastUpdateCheck) < 7 * 24 * 60 * 60 then -- 261
				return false -- 262
			end -- 261
		end -- 259
		return updater.checkForUpdates(source) -- 263
	end -- 258
end -- 239
_module_0.getUpdateState = function() -- 264
	return updateState -- 264
end -- 264
_module_0.checkForUpdates = checkForUpdates -- 265
thread(function() -- 266
	sleep(2) -- 267
	return checkForUpdates(false) -- 268
end) -- 266
local Set, Struct, LintYueGlobals -- 270
do -- 270
	local _obj_0 = require("Utils") -- 270
	Set, Struct, LintYueGlobals = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals -- 270
end -- 270
local yueext = yue.options.extension -- 271
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 273
local building = false -- 275
local getAllFiles -- 277
getAllFiles = function(path, exts, recursive) -- 277
	if recursive == nil then -- 277
		recursive = true -- 277
	end -- 277
	local filters = Set(exts) -- 278
	local files -- 279
	if recursive then -- 279
		files = Content:getAllFiles(path) -- 280
	else -- 282
		files = Content:getFiles(path) -- 282
	end -- 279
	local _accum_0 = { } -- 283
	local _len_0 = 1 -- 283
	for _index_0 = 1, #files do -- 283
		local file = files[_index_0] -- 283
		if not filters[Path:getExt(file)] then -- 284
			goto _continue_0 -- 284
		end -- 284
		_accum_0[_len_0] = file -- 285
		_len_0 = _len_0 + 1 -- 284
		::_continue_0:: -- 284
	end -- 283
	return _accum_0 -- 283
end -- 277
_module_0["getAllFiles"] = getAllFiles -- 277
local getFileEntries -- 287
getFileEntries = function(path, recursive, excludeFiles) -- 287
	if recursive == nil then -- 287
		recursive = true -- 287
	end -- 287
	if excludeFiles == nil then -- 287
		excludeFiles = nil -- 287
	end -- 287
	local entries = { } -- 288
	local excludes -- 289
	if excludeFiles then -- 289
		excludes = Set(excludeFiles) -- 290
	end -- 289
	local _list_0 = getAllFiles(path, { -- 291
		"lua", -- 291
		"xml", -- 291
		yueext, -- 291
		"tl" -- 291
	}, recursive) -- 291
	for _index_0 = 1, #_list_0 do -- 291
		local file = _list_0[_index_0] -- 291
		local entryName = Path:getName(file) -- 292
		if excludes and excludes[entryName] then -- 293
			goto _continue_0 -- 294
		end -- 293
		local fileName = Path:replaceExt(file, "") -- 295
		fileName = Path(path, fileName) -- 296
		local entryAdded -- 297
		for _index_1 = 1, #entries do -- 297
			local _des_0 = entries[_index_1] -- 297
			local ename, efile = _des_0.entryName, _des_0.fileName -- 297
			if entryName == ename and efile == fileName then -- 298
				entryAdded = true -- 298
				break -- 298
			end -- 298
		end -- 297
		if entryAdded then -- 299
			goto _continue_0 -- 299
		end -- 299
		local entry = { -- 300
			entryName = entryName, -- 300
			fileName = fileName -- 300
		} -- 300
		entries[#entries + 1] = entry -- 301
		::_continue_0:: -- 292
	end -- 291
	table.sort(entries, function(a, b) -- 302
		return a.entryName < b.entryName -- 302
	end) -- 302
	return entries -- 303
end -- 287
local allEntries = { -- 305
	dirty = { }, -- 305
	hasDirty = false, -- 305
	runId = 0 -- 305
} -- 305
local _anon_func_1 = function(file) -- 351
	local _val_0 = Path:getExt(file) -- 351
	return "ts" == _val_0 or "tsx" == _val_0 -- 351
end -- 351
allEntries.scanDir = function(path, dir, noPreview) -- 307
	if noPreview == nil then -- 307
		noPreview = false -- 307
	end -- 307
	local entries = { } -- 308
	if not dir:match("^%.") then -- 309
		local root = Path(path, dir) -- 310
		local imported = Content:exist(Path(root, ".git", "dora-import-repository")) -- 311
		local exts = { -- 312
			"lua", -- 312
			"xml", -- 312
			yueext, -- 312
			"tl", -- 312
			"wasm" -- 312
		} -- 312
		if imported then -- 313
			exts[#exts + 1] = "ts" -- 314
			exts[#exts + 1] = "tsx" -- 315
		end -- 313
		local _list_0 = getAllFiles(root, exts) -- 316
		for _index_0 = 1, #_list_0 do -- 316
			local file = _list_0[_index_0] -- 316
			if "init" == Path:getName(file):lower() then -- 317
				local fileName = Path:replaceExt(file, "") -- 318
				fileName = Path(path, dir, fileName) -- 319
				local projectPath = Path:getPath(fileName) -- 320
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 321
				local repo = nil -- 322
				if Content:exist(repoFile) then -- 323
					local str = Content:load(repoFile) -- 324
					if str then -- 324
						repo = json.decode(str) -- 325
					end -- 324
				end -- 323
				local entryName = Path:getName(projectPath) -- 326
				local entryAdded -- 327
				for _index_1 = 1, #entries do -- 327
					local _des_0 = entries[_index_1] -- 327
					local ename, efile = _des_0.entryName, _des_0.fileName -- 327
					if entryName == ename and efile == fileName then -- 328
						entryAdded = true -- 328
						break -- 328
					end -- 328
				end -- 327
				if entryAdded then -- 329
					goto _continue_0 -- 329
				end -- 329
				local examples = { } -- 330
				local tests = { } -- 331
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 332
				if Content:exist(examplePath) then -- 333
					local _list_1 = getFileEntries(examplePath) -- 334
					for _index_1 = 1, #_list_1 do -- 334
						local _des_0 = _list_1[_index_1] -- 334
						local name, ePath = _des_0.entryName, _des_0.fileName -- 334
						local entry = { -- 336
							entryName = name, -- 336
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 337
							workDir = projectPath -- 338
						} -- 335
						examples[#examples + 1] = entry -- 340
					end -- 334
				end -- 333
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 341
				if Content:exist(testPath) then -- 342
					local _list_1 = getFileEntries(testPath) -- 343
					for _index_1 = 1, #_list_1 do -- 343
						local _des_0 = _list_1[_index_1] -- 343
						local name, tPath = _des_0.entryName, _des_0.fileName -- 343
						local entry = { -- 345
							entryName = name, -- 345
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 346
							workDir = projectPath -- 347
						} -- 344
						tests[#tests + 1] = entry -- 349
					end -- 343
				end -- 342
				local entry = { -- 350
					entryName = entryName, -- 350
					fileName = fileName, -- 350
					projectPath = projectPath, -- 350
					examples = examples, -- 350
					tests = tests, -- 350
					repo = repo -- 350
				} -- 350
				entry.needsBuild = imported and _anon_func_1(file) and not Content:exist(fileName .. ".lua") -- 351
				local bannerFile -- 352
				do -- 352
					local _val_0 -- 352
					repeat -- 352
						if noPreview then -- 353
							_val_0 = nil -- 353
							break -- 353
						end -- 353
						if not config.showPreview then -- 354
							_val_0 = nil -- 354
							break -- 354
						end -- 354
						local f = Path(projectPath, ".dora", "banner.jpg") -- 355
						if Content:exist(f) then -- 356
							_val_0 = f -- 356
							break -- 356
						end -- 356
						f = Path(projectPath, ".dora", "banner.png") -- 357
						if Content:exist(f) then -- 358
							_val_0 = f -- 358
							break -- 358
						end -- 358
						f = Path(projectPath, "Image", "banner.jpg") -- 359
						if Content:exist(f) then -- 360
							_val_0 = f -- 360
							break -- 360
						end -- 360
						f = Path(projectPath, "Image", "banner.png") -- 361
						if Content:exist(f) then -- 362
							_val_0 = f -- 362
							break -- 362
						end -- 362
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 363
						if Content:exist(f) then -- 364
							_val_0 = f -- 364
							break -- 364
						end -- 364
					until true -- 352
					bannerFile = _val_0 -- 352
				end -- 352
				if bannerFile then -- 366
					entry.bannerFile = bannerFile -- 369
					thread(function() -- 370
						if Cache:loadAsync(bannerFile) then -- 371
							local bannerTex = Texture2D(bannerFile) -- 372
							if bannerTex then -- 372
								entry.bannerTex = bannerTex -- 373
							end -- 372
						end -- 371
					end) -- 370
				end -- 366
				entries[#entries + 1] = entry -- 374
			end -- 317
			::_continue_0:: -- 317
		end -- 316
	end -- 309
	return entries -- 375
end -- 307
local getProjectEntries -- 377
getProjectEntries = function(path, noPreview) -- 377
	if noPreview == nil then -- 377
		noPreview = false -- 377
	end -- 377
	local entries = { } -- 378
	local _list_0 = Content:getDirs(path) -- 379
	for _index_0 = 1, #_list_0 do -- 379
		local dir = _list_0[_index_0] -- 379
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 380
		for _index_1 = 1, #_list_1 do -- 380
			local entry = _list_1[_index_1] -- 380
			entries[#entries + 1] = entry -- 381
		end -- 380
	end -- 379
	table.sort(entries, function(a, b) -- 382
		return a.entryName < b.entryName -- 382
	end) -- 382
	return entries -- 383
end -- 377
_module_0["getProjectEntries"] = getProjectEntries -- 377
local gamesInDev -- 385
local doraTools -- 386
local windowsExport = { -- 388
	busy = false -- 388
} -- 388
allEntries.exportWindowsGame = function(game, title) -- 389
	if windowsExport.busy then -- 390
		return -- 390
	end -- 390
	windowsExport.busy = true -- 391
	windowsExport.message = nil -- 392
	return App:openFileDialog(true, function(folder) -- 393
		if folder == "" then -- 394
			windowsExport.busy = false -- 395
			return -- 396
		end -- 394
		windowsExport.routine = thread(function() -- 397
			local success, result = pcall(function() -- 398
				local exportWindows = oldRequire("Script.Dev.NativeGameExport").exportWindows -- 399
				return exportWindows(game.projectPath, game.fileName, title, folder) -- 400
			end) -- 398
			windowsExport.busy = false -- 401
			windowsExport.routine = nil -- 402
			if success then -- 403
				windowsExport.message = (useChinese and "已导出 " or "Exported ") .. result -- 404
			else -- 406
				windowsExport.message = (useChinese and "导出失败：" or "Export failed: ") .. tostring(result) -- 406
			end -- 403
		end) -- 397
	end) -- 393
end -- 389
local isToolEntry -- 408
isToolEntry = function(entry) -- 408
	do -- 409
		local _type_0 = type(entry) -- 409
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 409
		if _tab_0 then -- 409
			local categories -- 409
			do -- 409
				local _obj_0 = entry.repo -- 409
				local _type_1 = type(_obj_0) -- 409
				if "table" == _type_1 or "userdata" == _type_1 then -- 409
					categories = _obj_0.categories -- 409
				end -- 409
			end -- 409
			if categories ~= nil then -- 409
				for _index_0 = 1, #categories do -- 410
					local category = categories[_index_0] -- 410
					if "string" == type(category) and category:lower() == "tool" then -- 411
						return true -- 412
					end -- 411
				end -- 410
			end -- 409
		end -- 409
	end -- 409
	return false -- 408
end -- 408
local getEntryTitle -- 414
getEntryTitle = function(entry) -- 414
	local title -- 415
	do -- 415
		local repo = entry.repo -- 415
		if repo then -- 415
			if repo.title and "table" == type(repo.title) then -- 416
				if useChinese then -- 417
					title = repo.title.zh -- 417
				else -- 417
					title = repo.title.en -- 417
				end -- 417
			end -- 416
		end -- 415
	end -- 415
	if title ~= nil then -- 418
		return title -- 418
	else -- 418
		return entry.entryName -- 418
	end -- 418
end -- 414
allEntries.rebuildEntries = function() -- 420
	gamesInDev = { } -- 421
	do -- 422
		local _accum_0 = { } -- 422
		local _len_0 = 1 -- 422
		local _list_0 = allEntries.builtinTools -- 422
		for _index_0 = 1, #_list_0 do -- 422
			local tool = _list_0[_index_0] -- 422
			_accum_0[_len_0] = tool -- 422
			_len_0 = _len_0 + 1 -- 422
		end -- 422
		doraTools = _accum_0 -- 422
	end -- 422
	local _list_0 = allEntries.projectEntries -- 423
	for _index_0 = 1, #_list_0 do -- 423
		local entry = _list_0[_index_0] -- 423
		if isToolEntry(entry) then -- 424
			entry.kind = "tool" -- 425
			doraTools[#doraTools + 1] = entry -- 426
		else -- 428
			entry.kind = "game" -- 428
			gamesInDev[#gamesInDev + 1] = entry -- 429
		end -- 424
	end -- 423
	for i = #allEntries, 1, -1 do -- 430
		allEntries[i] = nil -- 431
	end -- 430
	for _index_0 = 1, #gamesInDev do -- 432
		local game = gamesInDev[_index_0] -- 432
		allEntries[#allEntries + 1] = game -- 433
		local examples, tests = game.examples, game.tests -- 434
		for _index_1 = 1, #examples do -- 435
			local example = examples[_index_1] -- 435
			allEntries[#allEntries + 1] = example -- 436
		end -- 435
		for _index_1 = 1, #tests do -- 437
			local test = tests[_index_1] -- 437
			allEntries[#allEntries + 1] = test -- 438
		end -- 437
	end -- 432
end -- 420
local updateEntries -- 440
updateEntries = function() -- 440
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 441
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 442
	local _list_0 = allEntries.builtinTools -- 443
	for _index_0 = 1, #_list_0 do -- 443
		local tool = _list_0[_index_0] -- 443
		tool.kind = "tool" -- 444
		tool.builtin = true -- 445
		if tool.entryName == "RepositoryImporter" then -- 446
			tool.repo = { -- 447
				title = { -- 447
					en = "Import repository", -- 447
					zh = "从仓库导入" -- 447
				} -- 447
			} -- 447
		end -- 446
	end -- 443
	return allEntries.rebuildEntries() -- 448
end -- 440
allEntries.refreshDirtyProjects = function() -- 450
	if not allEntries.hasDirty then -- 451
		return -- 451
	end -- 451
	local dirty = allEntries.dirty -- 452
	allEntries.dirty = { } -- 453
	allEntries.hasDirty = false -- 454
	for projectPath in pairs(dirty) do -- 455
		do -- 456
			local _accum_0 = { } -- 456
			local _len_0 = 1 -- 456
			local _list_0 = allEntries.projectEntries -- 456
			for _index_0 = 1, #_list_0 do -- 456
				local entry = _list_0[_index_0] -- 456
				if entry.projectPath ~= projectPath then -- 456
					_accum_0[_len_0] = entry -- 456
					_len_0 = _len_0 + 1 -- 456
				end -- 456
			end -- 456
			allEntries.projectEntries = _accum_0 -- 456
		end -- 456
		local parentPath = Path:getPath(projectPath) -- 457
		local dir = Path:getFilename(projectPath) -- 458
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 459
		for _index_0 = 1, #_list_0 do -- 459
			local entry = _list_0[_index_0] -- 459
			if entry.projectPath == projectPath then -- 460
				do -- 461
					local _obj_0 = allEntries.projectEntries -- 461
					_obj_0[#_obj_0 + 1] = entry -- 461
				end -- 461
				break -- 462
			end -- 460
		end -- 459
	end -- 455
	table.sort(allEntries.projectEntries, function(a, b) -- 463
		return a.entryName < b.entryName -- 463
	end) -- 463
	return allEntries.rebuildEntries() -- 464
end -- 450
updateEntries() -- 466
local getLaunchEntries -- 468
getLaunchEntries = function(refresh) -- 468
	if refresh == nil then -- 468
		refresh = false -- 468
	end -- 468
	if refresh then -- 469
		updateEntries() -- 469
	end -- 469
	local toInfo -- 470
	toInfo = function(entry, kind) -- 470
		local file = entry.fileName -- 471
		local asProj = not entry.builtin -- 472
		return { -- 474
			name = getEntryTitle(entry), -- 474
			file = file, -- 475
			kind = kind, -- 476
			asProj = asProj -- 477
		} -- 473
	end -- 470
	local games -- 479
	do -- 479
		local _accum_0 = { } -- 479
		local _len_0 = 1 -- 479
		for _index_0 = 1, #gamesInDev do -- 479
			local game = gamesInDev[_index_0] -- 479
			_accum_0[_len_0] = toInfo(game, "game") -- 479
			_len_0 = _len_0 + 1 -- 479
		end -- 479
		games = _accum_0 -- 479
	end -- 479
	local tools -- 480
	do -- 480
		local _accum_0 = { } -- 480
		local _len_0 = 1 -- 480
		for _index_0 = 1, #doraTools do -- 480
			local tool = doraTools[_index_0] -- 480
			_accum_0[_len_0] = toInfo(tool, "tool") -- 480
			_len_0 = _len_0 + 1 -- 480
		end -- 480
		tools = _accum_0 -- 480
	end -- 480
	return { -- 481
		games = games, -- 481
		tools = tools -- 481
	} -- 481
end -- 468
_module_0["getLaunchEntries"] = getLaunchEntries -- 468
local _anon_func_2 = function(entry, useChinese) -- 498
	local _obj_0 = entry.repo -- 498
	if _obj_0 ~= nil then -- 498
		local _obj_1 = _obj_0.description -- 498
		if _obj_1 ~= nil then -- 498
			return _obj_1[useChinese and "zh" or "en"] -- 498
		end -- 498
		return nil -- 498
	end -- 498
	return nil -- 498
end -- 498
local getMobileFeedEntries -- 483
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 483
	if refresh == nil then -- 483
		refresh = false -- 483
	end -- 483
	if dirtyProjectPath == nil then -- 483
		dirtyProjectPath = nil -- 483
	end -- 483
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 484
		allEntries.dirty[dirtyProjectPath] = true -- 485
		allEntries.hasDirty = true -- 486
	end -- 484
	if refresh then -- 487
		allEntries.dirty = { } -- 488
		allEntries.hasDirty = false -- 489
		updateEntries() -- 490
	else -- 492
		allEntries.refreshDirtyProjects() -- 492
	end -- 487
	local items = { } -- 493
	for _index_0 = 1, #gamesInDev do -- 494
		local entry = gamesInDev[_index_0] -- 494
		items[#items + 1] = { -- 496
			id = entry.entryName, -- 496
			title = getEntryTitle(entry), -- 497
			description = _anon_func_2(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 498
			fileName = entry.fileName, -- 499
			workDir = Path:getPath(entry.fileName), -- 500
			bannerFile = entry.bannerFile, -- 501
			needsBuild = entry.needsBuild, -- 502
			kind = "local" -- 503
		} -- 495
	end -- 494
	return items -- 505
end -- 483
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 483
local doCompile -- 507
doCompile = function(minify) -- 507
	if building then -- 508
		return -- 508
	end -- 508
	building = true -- 509
	local startTime = App.runningTime -- 510
	local luaFiles = { } -- 511
	local yueFiles = { } -- 512
	local xmlFiles = { } -- 513
	local tlFiles = { } -- 514
	local writablePath = Content.writablePath -- 515
	local buildPaths = { -- 517
		{ -- 518
			Content.assetPath, -- 518
			Path(writablePath, ".build"), -- 519
			"" -- 520
		} -- 517
	} -- 516
	for _index_0 = 1, #gamesInDev do -- 523
		local _des_0 = gamesInDev[_index_0] -- 523
		local fileName = _des_0.fileName -- 523
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 524
		buildPaths[#buildPaths + 1] = { -- 526
			Path(writablePath, gamePath), -- 526
			Path(writablePath, ".build", gamePath), -- 527
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 528
			gamePath -- 529
		} -- 525
	end -- 523
	for _index_0 = 1, #buildPaths do -- 530
		local _des_0 = buildPaths[_index_0] -- 530
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 530
		if not Content:exist(inputPath) then -- 531
			goto _continue_0 -- 531
		end -- 531
		local _list_0 = getAllFiles(inputPath, { -- 533
			"lua" -- 533
		}) -- 533
		for _index_1 = 1, #_list_0 do -- 533
			local file = _list_0[_index_1] -- 533
			luaFiles[#luaFiles + 1] = { -- 535
				file, -- 535
				Path(inputPath, file), -- 536
				Path(outputPath, file), -- 537
				gamePath -- 538
			} -- 534
		end -- 533
		local _list_1 = getAllFiles(inputPath, { -- 540
			yueext -- 540
		}) -- 540
		for _index_1 = 1, #_list_1 do -- 540
			local file = _list_1[_index_1] -- 540
			yueFiles[#yueFiles + 1] = { -- 542
				file, -- 542
				Path(inputPath, file), -- 543
				Path(outputPath, Path:replaceExt(file, "lua")), -- 544
				searchPath, -- 545
				gamePath -- 546
			} -- 541
		end -- 540
		local _list_2 = getAllFiles(inputPath, { -- 548
			"xml" -- 548
		}) -- 548
		for _index_1 = 1, #_list_2 do -- 548
			local file = _list_2[_index_1] -- 548
			xmlFiles[#xmlFiles + 1] = { -- 550
				file, -- 550
				Path(inputPath, file), -- 551
				Path(outputPath, Path:replaceExt(file, "lua")), -- 552
				gamePath -- 553
			} -- 549
		end -- 548
		local _list_3 = getAllFiles(inputPath, { -- 555
			"tl" -- 555
		}) -- 555
		for _index_1 = 1, #_list_3 do -- 555
			local file = _list_3[_index_1] -- 555
			if not file:match(".*%.d%.tl$") then -- 556
				tlFiles[#tlFiles + 1] = { -- 558
					file, -- 558
					Path(inputPath, file), -- 559
					Path(outputPath, Path:replaceExt(file, "lua")), -- 560
					searchPath, -- 561
					gamePath -- 562
				} -- 557
			end -- 556
		end -- 555
		::_continue_0:: -- 531
	end -- 530
	local paths -- 564
	do -- 564
		local _tbl_0 = { } -- 564
		local _list_0 = { -- 565
			luaFiles, -- 565
			yueFiles, -- 565
			xmlFiles, -- 565
			tlFiles -- 565
		} -- 565
		for _index_0 = 1, #_list_0 do -- 565
			local files = _list_0[_index_0] -- 565
			for _index_1 = 1, #files do -- 566
				local file = files[_index_1] -- 566
				_tbl_0[Path:getPath(file[3])] = true -- 564
			end -- 564
		end -- 564
		paths = _tbl_0 -- 564
	end -- 564
	for path in pairs(paths) do -- 568
		Content:mkdir(path) -- 568
	end -- 568
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 570
	local fileCount = 0 -- 571
	local errors = { } -- 572
	for _index_0 = 1, #yueFiles do -- 573
		local _des_0 = yueFiles[_index_0] -- 573
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 573
		local filename -- 574
		if gamePath then -- 574
			filename = Path(gamePath, file) -- 574
		else -- 574
			filename = file -- 574
		end -- 574
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 575
			if not codes then -- 576
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 577
				return -- 578
			end -- 576
			local success, result = LintYueGlobals(codes, globals) -- 579
			local yueCodes -- 580
			if not success then -- 581
				yueCodes = Content:load(input) -- 582
				if yueCodes then -- 582
					local CheckTIC80Code -- 583
					do -- 583
						local _obj_0 = require("Utils") -- 583
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 583
					end -- 583
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 584
					if isTIC80 then -- 585
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 586
					end -- 585
				end -- 582
			end -- 581
			if success then -- 587
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 588
			else -- 590
				if yueCodes then -- 590
					local globalErrors = { } -- 591
					for _index_1 = 1, #result do -- 592
						local _des_1 = result[_index_1] -- 592
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 592
						local countLine = 1 -- 593
						local code = "" -- 594
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 595
							if countLine == line then -- 596
								code = lineCode -- 597
								break -- 598
							end -- 596
							countLine = countLine + 1 -- 599
						end -- 595
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 600
					end -- 592
					if #globalErrors > 0 then -- 601
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 601
					end -- 601
				else -- 603
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 603
				end -- 590
				if #errors == 0 then -- 604
					return codes -- 604
				end -- 604
			end -- 587
		end, function(success) -- 575
			if success then -- 605
				print("Yue compiled: " .. tostring(filename)) -- 605
			end -- 605
			fileCount = fileCount + 1 -- 606
		end) -- 575
	end -- 573
	thread(function() -- 608
		for _index_0 = 1, #xmlFiles do -- 609
			local _des_0 = xmlFiles[_index_0] -- 609
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 609
			local filename -- 610
			if gamePath then -- 610
				filename = Path(gamePath, file) -- 610
			else -- 610
				filename = file -- 610
			end -- 610
			local sourceCodes = Content:loadAsync(input) -- 611
			local codes, err = xml.tolua(sourceCodes) -- 612
			if not codes then -- 613
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 614
			else -- 616
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 616
				print("Xml compiled: " .. tostring(filename)) -- 617
			end -- 613
			fileCount = fileCount + 1 -- 618
		end -- 609
	end) -- 608
	thread(function() -- 620
		for _index_0 = 1, #tlFiles do -- 621
			local _des_0 = tlFiles[_index_0] -- 621
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 621
			local filename -- 622
			if gamePath then -- 622
				filename = Path(gamePath, file) -- 622
			else -- 622
				filename = file -- 622
			end -- 622
			local sourceCodes = Content:loadAsync(input) -- 623
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 624
			if not codes then -- 625
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 626
			else -- 628
				Content:saveAsync(output, codes) -- 628
				print("Teal compiled: " .. tostring(filename)) -- 629
			end -- 625
			fileCount = fileCount + 1 -- 630
		end -- 621
	end) -- 620
	return thread(function() -- 632
		wait(function() -- 633
			return fileCount == totalFiles -- 633
		end) -- 633
		if minify then -- 634
			local _list_0 = { -- 635
				yueFiles, -- 635
				xmlFiles, -- 635
				tlFiles -- 635
			} -- 635
			for _index_0 = 1, #_list_0 do -- 635
				local files = _list_0[_index_0] -- 635
				for _index_1 = 1, #files do -- 635
					local file = files[_index_1] -- 635
					local output = Path:replaceExt(file[3], "lua") -- 636
					luaFiles[#luaFiles + 1] = { -- 638
						Path:replaceExt(file[1], "lua"), -- 638
						output, -- 639
						output -- 640
					} -- 637
				end -- 635
			end -- 635
			local FormatMini -- 642
			do -- 642
				local _obj_0 = require("luaminify") -- 642
				FormatMini = _obj_0.FormatMini -- 642
			end -- 642
			for _index_0 = 1, #luaFiles do -- 643
				local _des_0 = luaFiles[_index_0] -- 643
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 643
				if Content:exist(input) then -- 644
					local sourceCodes = Content:loadAsync(input) -- 645
					local res, err = FormatMini(sourceCodes) -- 646
					if res then -- 647
						Content:saveAsync(output, res) -- 648
						print("Minify: " .. tostring(file)) -- 649
					else -- 651
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 651
					end -- 647
				else -- 653
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 653
				end -- 644
			end -- 643
			package.loaded["luaminify.FormatMini"] = nil -- 654
			package.loaded["luaminify.ParseLua"] = nil -- 655
			package.loaded["luaminify.Scope"] = nil -- 656
			package.loaded["luaminify.Util"] = nil -- 657
		end -- 634
		local errorMessage = table.concat(errors, "\n") -- 658
		if errorMessage ~= "" then -- 659
			print(errorMessage) -- 659
		end -- 659
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 660
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 661
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 662
		Content:clearPathCache() -- 663
		teal.clear() -- 664
		yue.clear() -- 665
		building = false -- 666
	end) -- 632
end -- 507
local doClean -- 668
doClean = function() -- 668
	if building then -- 669
		return -- 669
	end -- 669
	local writablePath = Content.writablePath -- 670
	local targetDir = Path(writablePath, ".build") -- 671
	Content:clearPathCache() -- 672
	if Content:remove(targetDir) then -- 673
		return print("Cleaned: " .. tostring(targetDir)) -- 674
	end -- 673
end -- 668
local screenScale = 2.0 -- 676
local scaleContent = false -- 677
local isInEntry = true -- 678
local currentEntry = nil -- 679
local footerWindow = nil -- 681
local entryWindow = nil -- 682
local testingThread = nil -- 683
local mobileMode = config.mobileFeed -- 684
allEntries.mobileControl = { } -- 685
local feedHost = nil -- 686
local remixHost = nil -- 687
local startMobileUI = nil -- 688
allEntries.mobileControl.webControlled = false -- 689
allEntries.mobileControl.mobileHosts = { } -- 690
allEntries.mobileControl.suspendedMobileHosts = { } -- 691
local trackMobileHost -- 693
trackMobileHost = function(host) -- 693
	do -- 694
		local _accum_0 = { } -- 694
		local _len_0 = 1 -- 694
		local _list_0 = allEntries.mobileControl.mobileHosts -- 694
		for _index_0 = 1, #_list_0 do -- 694
			local item = _list_0[_index_0] -- 694
			if item.parent then -- 694
				_accum_0[_len_0] = item -- 694
				_len_0 = _len_0 + 1 -- 694
			end -- 694
		end -- 694
		allEntries.mobileControl.mobileHosts = _accum_0 -- 694
	end -- 694
	do -- 695
		local _obj_0 = allEntries.mobileControl.mobileHosts -- 695
		_obj_0[#_obj_0 + 1] = host -- 695
	end -- 695
	return host -- 696
end -- 693
local clearMobileUI -- 698
clearMobileUI = function() -- 698
	local _list_0 = allEntries.mobileControl.mobileHosts -- 699
	for _index_0 = 1, #_list_0 do -- 699
		local host = _list_0[_index_0] -- 699
		if host.parent then -- 700
			host:removeFromParent(true) -- 700
		end -- 700
	end -- 699
	allEntries.mobileControl.mobileHosts = { } -- 701
	allEntries.mobileControl.suspendedMobileHosts = { } -- 702
	feedHost = nil -- 703
	remixHost = nil -- 704
end -- 698
local syncWebIDEControl -- 706
syncWebIDEControl = function() -- 706
	local connected = HttpServer.wsConnectionCount > 0 -- 707
	if connected then -- 708
		allEntries.mobileControl.pendingUIMode = nil -- 709
		local _list_0 = allEntries.mobileControl.mobileHosts -- 710
		for _index_0 = 1, #_list_0 do -- 710
			local host = _list_0[_index_0] -- 710
			if not host.parent then -- 711
				goto _continue_0 -- 711
			end -- 711
			if not (allEntries.mobileControl.suspendedMobileHosts[host] ~= nil) then -- 712
				allEntries.mobileControl.suspendedMobileHosts[host] = host.visible -- 713
				host:emit("SuspendLocalUI") -- 714
			end -- 712
			host.visible = false -- 715
			::_continue_0:: -- 711
		end -- 710
	elseif allEntries.mobileControl.webControlled then -- 716
		for host, visible in pairs(allEntries.mobileControl.suspendedMobileHosts) do -- 717
			if host.parent then -- 718
				host.visible = visible -- 719
				host:emit("ResumeLocalUI") -- 720
			end -- 718
		end -- 717
		allEntries.mobileControl.suspendedMobileHosts = { } -- 721
	end -- 708
	allEntries.mobileControl.webControlled = connected -- 722
	return connected -- 723
end -- 706
local getUIMode -- 725
getUIMode = function() -- 725
	return mobileMode and "mobile" or "traditional" -- 725
end -- 725
_module_0["getUIMode"] = getUIMode -- 725
local setUIMode -- 726
setUIMode = function(mode) -- 726
	if not (("mobile" == mode or "traditional" == mode)) then -- 727
		return false -- 727
	end -- 727
	if HttpServer.wsConnectionCount > 0 then -- 728
		return false -- 728
	end -- 728
	if (allEntries.mobileControl.pendingUIMode ~= nil) or not isInEntry or testingThread then -- 729
		return false -- 729
	end -- 729
	local wantsMobile = mode == "mobile" -- 730
	if wantsMobile == mobileMode then -- 731
		return true -- 731
	end -- 731
	if mobileMode then -- 732
		if not (feedHost and feedHost.visible) then -- 733
			return false -- 733
		end -- 733
		feedHost:emit("SwitchUIMode") -- 735
		return allEntries.mobileControl.pendingUIMode == false -- 736
	end -- 732
	allEntries.mobileControl.pendingUIMode = true -- 737
	return true -- 738
end -- 726
_module_0["setUIMode"] = setUIMode -- 726
local applyUIMode -- 740
applyUIMode = function(enabled) -- 740
	if HttpServer.wsConnectionCount > 0 then -- 742
		return false -- 742
	end -- 742
	if enabled then -- 743
		local ok, err = pcall(startMobileUI) -- 744
		if not ok then -- 745
			if feedHost then -- 746
				feedHost:removeFromParent(true) -- 746
			end -- 746
			feedHost = nil -- 747
			mobileMode = false -- 748
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 749
			return false -- 750
		end -- 745
	else -- 752
		clearMobileUI() -- 752
		updateEntries() -- 753
	end -- 743
	mobileMode = enabled -- 754
	config.mobileFeed = enabled -- 755
	return true -- 756
end -- 740
local setupEventHandlers = nil -- 758
local enterEntryAsync = nil -- 759
local allClear -- 761
allClear = function() -- 761
	if allEntries.mobileControl.webControlled or HttpServer.wsConnectionCount > 0 then -- 763
		clearMobileUI() -- 763
	end -- 763
	local systemNodes = { } -- 766
	local preserveSystemNode -- 767
	preserveSystemNode = function(node) -- 767
		if systemNodes[node] then -- 768
			return -- 768
		end -- 768
		systemNodes[node] = true -- 769
		do -- 770
			local clip = tolua.cast(node, "ClipNode") -- 770
			if clip then -- 770
				if clip.stencil then -- 771
					preserveSystemNode(clip.stencil) -- 771
				end -- 771
			end -- 770
		end -- 770
		return node:eachChild(function(child) -- 772
			preserveSystemNode(child) -- 773
			return false -- 774
		end) -- 772
	end -- 767
	for _index_0 = 1, #Routine do -- 775
		local routine = Routine[_index_0] -- 775
		if footerWindow == routine or entryWindow == routine or testingThread == routine or windowsExport.routine == routine then -- 777
			goto _continue_0 -- 778
		else -- 780
			Routine:remove(routine) -- 780
		end -- 776
		::_continue_0:: -- 776
	end -- 775
	for _index_0 = 1, #moduleCache do -- 781
		local module = moduleCache[_index_0] -- 781
		package.loaded[module] = nil -- 782
	end -- 781
	moduleCache = { } -- 783
	Director:cleanup() -- 784
	Entity:clear() -- 785
	Platformer.Data:clear() -- 786
	Platformer.UnitAction:clear() -- 787
	Audio:stopAll(0.2) -- 788
	Struct:clear() -- 789
	View.nearPlaneDistance = 0.1 -- 792
	View.farPlaneDistance = 10000 -- 793
	View.fieldOfView = 45 -- 794
	View.postEffect = nil -- 795
	View.scale = scaleContent and screenScale or 1 -- 796
	Director.clearColor = Color(0xff1a1a1a) -- 797
	teal.clear() -- 798
	yue.clear() -- 799
	preserveSystemNode(Director.systemUI) -- 802
	for _, item in pairs(ubox()) do -- 803
		local node = tolua.cast(item, "Node") -- 804
		if node then -- 804
			if not systemNodes[node] then -- 805
				node:cleanup() -- 805
			end -- 805
		end -- 804
	end -- 803
	collectgarbage() -- 806
	collectgarbage() -- 807
	Wasm:clear() -- 808
	thread(function() -- 809
		sleep() -- 810
		return Cache:removeUnused() -- 811
	end) -- 809
	setupEventHandlers() -- 812
	Content.searchPaths = searchPaths -- 813
	App.idled = true -- 814
end -- 761
_module_0["allClear"] = allClear -- 761
local clearTempFiles -- 816
clearTempFiles = function() -- 816
	local writablePath = Content.writablePath -- 817
	local uploadPath = Path(writablePath, ".upload") -- 818
	if Content:exist(uploadPath) then -- 819
		local _list_0 = Content:getDirs(uploadPath) -- 821
		for _index_0 = 1, #_list_0 do -- 821
			local dir = _list_0[_index_0] -- 821
			if dir ~= "resume" then -- 822
				Content:remove(Path(uploadPath, dir)) -- 822
			end -- 822
		end -- 821
		local _list_1 = Content:getFiles(uploadPath) -- 823
		for _index_0 = 1, #_list_1 do -- 823
			local file = _list_1[_index_0] -- 823
			Content:remove(Path(uploadPath, file)) -- 824
		end -- 823
	end -- 819
	if Content:exist(Path(writablePath, ".download")) then -- 825
		return Content:remove(Path(writablePath, ".download")) -- 825
	end -- 825
end -- 816
local waitForWebStart = true -- 827
thread(function() -- 828
	sleep(2) -- 829
	waitForWebStart = false -- 830
end) -- 828
local reloadDevEntry -- 832
reloadDevEntry = function() -- 832
	return thread(function() -- 832
		waitForWebStart = true -- 833
		doClean() -- 834
		allClear() -- 835
		_G.require = oldRequire -- 836
		Dora.require = oldRequire -- 837
		package.loaded["Script.Dev.Entry"] = nil -- 838
		package.loaded["Script.Dev.WebServer"] = nil -- 839
		return Director.systemScheduler:schedule(function() -- 840
			Routine:clear() -- 841
			oldRequire("Script.Dev.Entry") -- 842
			return true -- 843
		end) -- 840
	end) -- 832
end -- 832
local setWorkspace -- 845
setWorkspace = function(path) -- 845
	clearTempFiles() -- 846
	Content.writablePath = path -- 847
	config.writablePath = Content.writablePath -- 848
	return thread(function() -- 849
		sleep() -- 850
		return reloadDevEntry() -- 851
	end) -- 849
end -- 845
_module_0["setWorkspace"] = setWorkspace -- 845
local quit = false -- 853
local activeSearchId = 0 -- 855
local handleSearchFiles -- 857
handleSearchFiles = function(payload) -- 857
	if not payload then -- 858
		return -- 858
	end -- 858
	local id = payload.id -- 859
	if id == nil then -- 860
		return -- 860
	end -- 860
	activeSearchId = id -- 861
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 862
	if path == nil then -- 863
		path = "" -- 863
	end -- 863
	if exts == nil then -- 864
		exts = { } -- 864
	end -- 864
	if globs == nil then -- 865
		globs = { } -- 865
	end -- 865
	if extensionLevels == nil then -- 866
		extensionLevels = { } -- 866
	end -- 866
	if pattern == nil then -- 867
		pattern = "" -- 867
	end -- 867
	if pattern == "" then -- 869
		return -- 869
	end -- 869
	local useRegex = payload.useRegex == true -- 870
	local caseSensitive = payload.caseSensitive == true -- 871
	local includeContent = payload.includeContent ~= false -- 872
	local contentWindow = payload.contentWindow or 0 -- 873
	return Director.systemScheduler:schedule(once(function() -- 874
		local stopped = false -- 875
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 876
			if activeSearchId ~= id then -- 877
				stopped = true -- 878
				return true -- 879
			end -- 877
			emit("AppWS", "Send", json.encode({ -- 881
				name = "SearchFilesResult", -- 881
				id = id, -- 881
				result = result -- 881
			})) -- 880
			return false -- 883
		end) -- 876
		return emit("AppWS", "Send", json.encode({ -- 885
			name = "SearchFilesDone", -- 885
			id = id, -- 885
			stopped = stopped -- 885
		})) -- 884
	end)) -- 874
end -- 857
local stop -- 888
stop = function() -- 888
	if isInEntry then -- 889
		return false -- 889
	end -- 889
	allClear() -- 890
	isInEntry = true -- 891
	currentEntry = nil -- 892
	return true -- 893
end -- 888
_module_0["stop"] = stop -- 888
local getCurrentEntryStatus -- 895
getCurrentEntryStatus = function() -- 895
	local entry = currentEntry -- 896
	if not (entry and not isInEntry) then -- 897
		return { -- 897
			success = true, -- 897
			running = false, -- 897
			runId = allEntries.runId -- 897
		} -- 897
	end -- 897
	local status = { -- 899
		success = true, -- 899
		running = true, -- 900
		kind = entry.runKind or "file", -- 901
		runId = allEntries.runId, -- 902
		entryName = entry.entryName, -- 903
		fileName = entry.fileName -- 904
	} -- 898
	if entry.workDir then -- 905
		status.workDir = entry.workDir -- 905
	end -- 905
	if entry.projectRoot then -- 906
		status.projectRoot = entry.projectRoot -- 906
	end -- 906
	return status -- 907
end -- 895
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 895
local _anon_func_3 = function(_with_0) -- 931
	local _val_0 = App.platform -- 931
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 931
end -- 931
local _anon_func_4 = function(_with_0) -- 965
	local _val_0 = App.platform -- 965
	return "Windows" == _val_0 or "macOS" == _val_0 or "Android" == _val_0 -- 965
end -- 965
setupEventHandlers = function() -- 909
	local _with_0 = Director.postNode -- 910
	if App.platform == "Windows" then -- 911
		_with_0:gslot("AppURLHandlerState", function(state) -- 912
			allEntries.urlHandlerState = state -- 913
			if state == "missing" then -- 914
				return emit("AppURLHandler", "register") -- 914
			end -- 914
		end) -- 912
		emit("AppURLHandler", "query") -- 915
	end -- 911
	_with_0:onAppEvent(function(eventType) -- 916
		if "Quit" == eventType then -- 917
			quit = true -- 918
			allClear() -- 919
			return clearTempFiles() -- 920
		elseif "Shutdown" == eventType then -- 921
			return stop() -- 922
		end -- 916
	end) -- 916
	_with_0:onAppChange(function(settingName) -- 923
		if "Theme" == settingName then -- 924
			config.themeColor = App.themeColor:toARGB() -- 925
		elseif "Locale" == settingName then -- 926
			config.locale = App.locale -- 927
			updateLocale() -- 928
			return teal.clear(true) -- 929
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 930
			if _anon_func_3(_with_0) then -- 931
				if "FullScreen" == settingName then -- 933
					config.fullScreen = App.fullScreen -- 933
				elseif "Position" == settingName then -- 934
					local _obj_0 = App.winPosition -- 934
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 934
				elseif "Size" == settingName then -- 935
					local width, height -- 936
					do -- 936
						local _obj_0 = App.winSize -- 936
						width, height = _obj_0.width, _obj_0.height -- 936
					end -- 936
					config.winWidth = width -- 937
					config.winHeight = height -- 938
				end -- 932
			end -- 931
		end -- 923
	end) -- 923
	_with_0:onAppWS(function(event) -- 939
		if event.type == "Close" then -- 940
			if HttpServer.wsConnectionCount == 0 then -- 941
				updateEntries() -- 942
			end -- 941
			return -- 943
		end -- 940
		if not (event.type == "Receive") then -- 944
			return -- 944
		end -- 944
		local data = json.decode(event.msg) -- 945
		if not data then -- 946
			return -- 946
		end -- 946
		local _exp_0 = data.name -- 947
		if "SearchFiles" == _exp_0 then -- 948
			return handleSearchFiles(data) -- 949
		elseif "SearchFilesStop" == _exp_0 then -- 950
			if data.id == nil or data.id == activeSearchId then -- 951
				activeSearchId = 0 -- 952
			end -- 951
		end -- 947
	end) -- 939
	_with_0:slot("UpdateEntries", function() -- 953
		return updateEntries() -- 953
	end) -- 953
	_with_0:gslot("RepositoryImport", function(repository) -- 954
		return Director.systemScheduler:schedule(once(function() -- 955
			if not (currentEntry and currentEntry.entryName == "RepositoryImporter") then -- 956
				local importIDE = oldRequire("Dev.ImportIDE") -- 957
				allEntries.importRestoreIDE = importIDE.getNativeState() == "visible" -- 958
			end -- 956
			if mobileMode then -- 961
				clearMobileUI() -- 961
			end -- 961
			allClear() -- 962
			if _anon_func_4(_with_0) and App.webIDEEnabled then -- 965
				emit("AppWebView", "/ide/hide", false) -- 965
			end -- 965
			return enterEntryAsync({ -- 967
				entryName = "RepositoryImporter", -- 967
				fileName = Path(Content.assetPath, "Script", "Tools", "RepositoryImporter"), -- 968
				runKind = "tool", -- 969
				argument = repository -- 970
			}) -- 966
		end)) -- 955
	end) -- 954
	_with_0:gslot("RepositoryImported", function() -- 972
		return updateEntries() -- 972
	end) -- 972
	_with_0:gslot("RepositoryImportDone", function() -- 973
		return Director.systemScheduler:schedule(once(function() -- 974
			stop() -- 975
			if allEntries.importRestoreIDE then -- 976
				allEntries.importRestoreIDE = false -- 977
				return emit("AppWebView", "/ide/show", true) -- 978
			end -- 976
		end)) -- 974
	end) -- 973
	_with_0:gslot("RepositoryImportReveal", function(file) -- 979
		return Director.systemScheduler:schedule(once(function() -- 980
			stop() -- 981
			updateEntries() -- 982
			allEntries.importFocusedFile = Path:replaceExt(file, "") -- 983
			allEntries.importReveal = true -- 984
		end)) -- 980
	end) -- 979
	return _with_0 -- 910
end -- 909
setupEventHandlers() -- 987
clearTempFiles() -- 988
local downloadFile -- 990
downloadFile = function(url, target) -- 990
	return Director.systemScheduler:schedule(once(function() -- 990
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 991
			if quit then -- 992
				return true -- 992
			end -- 992
			emit("AppWS", "Send", json.encode({ -- 994
				name = "Download", -- 994
				url = url, -- 994
				status = "downloading", -- 994
				progress = current / total -- 995
			})) -- 993
			return false -- 991
		end) -- 991
		return emit("AppWS", "Send", json.encode(success and { -- 998
			name = "Download", -- 998
			url = url, -- 998
			status = "completed", -- 998
			progress = 1.0 -- 999
		} or { -- 1001
			name = "Download", -- 1001
			url = url, -- 1001
			status = "failed", -- 1001
			progress = 0.0 -- 1002
		})) -- 997
	end)) -- 990
end -- 990
_module_0["downloadFile"] = downloadFile -- 990
local _anon_func_5 = function(ProjectSearch, entry, file, require, workDir) -- 1016
	if workDir == nil then -- 1016
		workDir = Path:getPath(file) -- 1016
	end -- 1016
	local _list_0 = ProjectSearch(workDir) -- 1017
	for _index_0 = 1, #_list_0 do -- 1017
		local directory = _list_0[_index_0] -- 1017
		Content:insertSearchPath(1, directory) -- 1018
	end -- 1017
	local result = require(file) -- 1019
	if "function" == type(result) then -- 1020
		result(entry.argument) -- 1020
	end -- 1020
	return nil -- 1021
end -- 1016
local _anon_func_6 = function(_with_0, err, fontSize, width) -- 1050
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 1050
	label.alignment = "Left" -- 1051
	label.textWidth = width - fontSize -- 1052
	label.text = err -- 1053
	return label -- 1050
end -- 1050
enterEntryAsync = function(entry) -- 1005
	allEntries.runId = allEntries.runId + 1 -- 1006
	local launchRunId = allEntries.runId -- 1007
	isInEntry = false -- 1008
	App.idled = false -- 1009
	emit(Profiler.EventName, "ClearLoader") -- 1010
	currentEntry = entry -- 1011
	local file, workDir = entry.fileName, entry.workDir -- 1012
	sleep() -- 1013
	if launchRunId ~= allEntries.runId or isInEntry or currentEntry ~= entry then -- 1014
		return false, "superseded" -- 1014
	end -- 1014
	return xpcall(_anon_func_5, function(msg) -- 1021
		local err = debug.traceback(msg) -- 1023
		Log("Error", err) -- 1024
		allClear() -- 1025
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 1026
		local viewWidth, viewHeight -- 1027
		do -- 1027
			local _obj_0 = View.size -- 1027
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 1027
		end -- 1027
		local width, height = viewWidth - 20, viewHeight - 20 -- 1028
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 1029
		Director.ui:addChild((function() -- 1030
			local root = AlignNode() -- 1030
			do -- 1031
				local _obj_0 = App.bufferSize -- 1031
				width, height = _obj_0.width, _obj_0.height -- 1031
			end -- 1031
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1032
			root:onAppChange(function(settingName) -- 1033
				if settingName == "Size" then -- 1033
					do -- 1034
						local _obj_0 = App.bufferSize -- 1034
						width, height = _obj_0.width, _obj_0.height -- 1034
					end -- 1034
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1035
				end -- 1033
			end) -- 1033
			root:addChild((function() -- 1036
				local _with_0 = ScrollArea({ -- 1037
					width = width, -- 1037
					height = height, -- 1038
					paddingX = 0, -- 1039
					paddingY = 50, -- 1040
					viewWidth = height, -- 1041
					viewHeight = height -- 1042
				}) -- 1036
				root:onAlignLayout(function(w, h) -- 1044
					_with_0.position = Vec2(w / 2, h / 2) -- 1045
					w = w - 20 -- 1046
					h = h - 20 -- 1047
					_with_0.view.children.first.textWidth = w - fontSize -- 1048
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 1049
				end) -- 1044
				_with_0.view:addChild(_anon_func_6(_with_0, err, fontSize, width)) -- 1050
				return _with_0 -- 1036
			end)()) -- 1036
			return root -- 1030
		end)()) -- 1030
		return err -- 1054
	end, ProjectSearch, entry, file, require, workDir) -- 1015
end -- 1005
_module_0["enterEntryAsync"] = enterEntryAsync -- 1005
local enterDemoEntry -- 1056
enterDemoEntry = function(entry) -- 1056
	return thread(function() -- 1056
		return enterEntryAsync(entry) -- 1056
	end) -- 1056
end -- 1056
local reloadCurrentEntry -- 1058
reloadCurrentEntry = function() -- 1058
	if currentEntry then -- 1059
		allClear() -- 1060
		return enterDemoEntry(currentEntry) -- 1061
	end -- 1059
end -- 1058
Director.clearColor = Color(0xff1a1a1a) -- 1063
local descColor = Color(0xffa1a1a1) -- 1064
local extraOperations -- 1067
do -- 1067
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 1068
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 1069
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 1070
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 1071
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1072
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1073
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1074
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1075
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1076
	local ossLicenses = nil -- 1077
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1078
	local failedSetFolder = false -- 1079
	local statusFlags = { -- 1080
		"NoResize", -- 1080
		"NoMove", -- 1080
		"NoCollapse", -- 1080
		"AlwaysAutoResize", -- 1080
		"NoSavedSettings" -- 1080
	} -- 1080
	extraOperations = function() -- 1087
		local zh = useChinese -- 1088
		if isDesktop then -- 1089
			local alwaysOnTop = config.alwaysOnTop -- 1090
			do -- 1091
				local changed -- 1091
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1091
				if changed then -- 1091
					App.alwaysOnTop = alwaysOnTop -- 1092
					config.alwaysOnTop = alwaysOnTop -- 1093
				end -- 1091
			end -- 1091
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1094
			do -- 1095
				local changed -- 1095
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1095
				if changed then -- 1095
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1096
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1097
				end -- 1095
			end -- 1095
			SameLine() -- 1098
			TextColored(descColor, "(?)") -- 1099
			if IsItemHovered() then -- 1100
				BeginTooltip(function() -- 1101
					return PushTextWrapPos(360, function() -- 1102
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1103
					end) -- 1102
				end) -- 1101
			end -- 1100
		end -- 1089
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1118
		do -- 1122
			local changed -- 1122
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1122
			if changed then -- 1122
				config.showPreview = showPreview -- 1123
				updateEntries() -- 1124
				if not showPreview then -- 1125
					thread(function() -- 1126
						collectgarbage() -- 1127
						return Cache:removeUnused("Texture") -- 1128
					end) -- 1126
				end -- 1125
			end -- 1122
		end -- 1122
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1129
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1130
			if changed then -- 1130
				config.webIDEEnabled = webIDEEnabled -- 1131
				App.webIDEEnabled = webIDEEnabled -- 1132
			end -- 1130
		end -- 1129
		do -- 1133
			local themeColor = App.themeColor -- 1134
			local writablePath = config.writablePath -- 1135
			SeparatorText(zh and "工作目录" or "Workspace") -- 1136
			PushTextWrapPos(400, function() -- 1137
				return TextColored(themeColor, writablePath) -- 1138
			end) -- 1137
			if not isDesktop then -- 1139
				goto skipSetting -- 1139
			end -- 1139
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1140
			if Button(zh and "改变目录" or "Set Folder") then -- 1141
				App:openFileDialog(true, function(path) -- 1142
					if path == "" then -- 1143
						return -- 1143
					end -- 1143
					local relPath = Path:getRelative(Content.assetPath, path) -- 1144
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1145
						return setWorkspace(path) -- 1146
					else -- 1148
						failedSetFolder = true -- 1148
					end -- 1145
				end) -- 1142
			end -- 1141
			if failedSetFolder then -- 1149
				failedSetFolder = false -- 1150
				OpenPopup(popupName) -- 1151
			end -- 1149
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1152
			BeginPopupModal(popupName, statusFlags, function() -- 1153
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1154
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1155
					return CloseCurrentPopup() -- 1156
				end -- 1155
			end) -- 1153
			SameLine() -- 1157
			if Button(zh and "使用默认" or "Use Default") then -- 1158
				setWorkspace(Content.appPath) -- 1159
			end -- 1158
			Separator() -- 1160
			::skipSetting:: -- 1161
		end -- 1133
		renderAgentStorage(zh) -- 1162
		if isOSSLicenseExist then -- 1163
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1164
				if not ossLicenses then -- 1165
					local licenseText = Content:load("LICENSES") -- 1166
					if licenseText then -- 1166
						local GSplit -- 1167
						do -- 1167
							local _obj_0 = require("Utils") -- 1167
							GSplit = _obj_0.GSplit -- 1167
						end -- 1167
						ossLicenses = { } -- 1168
						licenseText = licenseText:gsub("\r\n", "\n") -- 1169
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1170
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1171
							if name then -- 1171
								ossLicenses[#ossLicenses + 1] = { -- 1172
									name, -- 1172
									text -- 1172
								} -- 1172
							end -- 1171
						end -- 1170
					end -- 1166
				end -- 1165
				if ossLicenses then -- 1173
					OpenPopup(ossLicensePopup) -- 1173
				end -- 1173
			end -- 1164
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1174
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1175
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1176
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1177
				return BeginPopupModal(ossLicensePopup, true, { -- 1180
					"NoSavedSettings" -- 1180
				}, function() -- 1181
					for _index_0 = 1, #ossLicenses do -- 1182
						local _des_0 = ossLicenses[_index_0] -- 1182
						local firstLine, text = _des_0[1], _des_0[2] -- 1182
						local name, license = firstLine:match("(.+): (.+)") -- 1184
						if name then -- 1184
							TextColored(themeColor, name) -- 1185
							SameLine() -- 1186
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1187
								return TextWrapped(text) -- 1187
							end) -- 1187
						end -- 1184
					end -- 1182
				end) -- 1177
			end) -- 1177
		end -- 1163
		if not App.debugging then -- 1190
			return -- 1190
		end -- 1190
		return TreeNode(zh and "开发操作" or "Development", function() -- 1191
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1192
				OpenPopup("build") -- 1192
			end -- 1192
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1193
				return BeginPopup("build", function() -- 1193
					if Selectable(zh and "编译" or "Compile") then -- 1194
						doCompile(false) -- 1194
					end -- 1194
					Separator() -- 1195
					if Selectable(zh and "压缩" or "Minify") then -- 1196
						doCompile(true) -- 1196
					end -- 1196
					Separator() -- 1197
					if Selectable(zh and "清理" or "Clean") then -- 1198
						return doClean() -- 1198
					end -- 1198
				end) -- 1193
			end) -- 1193
			if isInEntry then -- 1199
				if waitForWebStart then -- 1200
					BeginDisabled(function() -- 1201
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1201
					end) -- 1201
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1202
					reloadDevEntry() -- 1203
				end -- 1200
			end -- 1199
			do -- 1204
				local changed -- 1204
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1204
				if changed then -- 1204
					View.scale = scaleContent and screenScale or 1 -- 1205
				end -- 1204
			end -- 1204
			do -- 1206
				local changed -- 1206
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1206
				if changed then -- 1206
					config.engineDev = engineDev -- 1207
				end -- 1206
			end -- 1206
			do -- 1208
				local changed -- 1208
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1208
				if changed then -- 1208
					config.webIDETourCompleted = webIDETourCompleted -- 1209
				end -- 1208
			end -- 1208
			if testingThread then -- 1210
				return BeginDisabled(function() -- 1211
					return Button(zh and "开始自动测试" or "Test automatically") -- 1211
				end) -- 1211
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1212
				testingThread = thread(function() -- 1213
					local _ <close> = setmetatable({ }, { -- 1214
						__close = function() -- 1214
							allClear() -- 1215
							testingThread = nil -- 1216
							isInEntry = true -- 1217
							currentEntry = nil -- 1218
							return print("Testing done!") -- 1219
						end -- 1214
					}) -- 1214
					for _, entry in ipairs(allEntries) do -- 1220
						allClear() -- 1221
						print("Start " .. tostring(entry.entryName)) -- 1222
						enterDemoEntry(entry) -- 1223
						sleep(2) -- 1224
						print("Stop " .. tostring(entry.entryName)) -- 1225
					end -- 1220
				end) -- 1213
			end -- 1210
		end) -- 1191
	end -- 1087
end -- 1067
local icon = Path(Content.assetPath, "Script", "Dev", "icon_s.png") -- 1227
local iconTex = nil -- 1228
Director.systemScheduler:schedule(once(function() -- 1229
	if Cache:loadAsync(icon) then -- 1229
		iconTex = Texture2D(icon) -- 1229
	end -- 1229
end)) -- 1229
local webStatus = nil -- 1231
local urlClicked = nil -- 1232
local authCode = string.format("%06d", math.random(0, 999999)) -- 1234
local authCodeTTL = 30.0 -- 1236
_module_0.getAuthCode = function() -- 1237
	return authCode -- 1237
end -- 1237
_module_0.invalidateAuthCode = function() -- 1238
	authCode = string.format("%06d", math.random(0, 999999)) -- 1239
	authCodeTTL = 30.0 -- 1240
end -- 1238
local AuthSession -- 1242
do -- 1242
	local pending = nil -- 1243
	local session = nil -- 1244
	AuthSession = { -- 1246
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1246
			pending = { -- 1248
				sessionId = sessionId, -- 1248
				confirmCode = confirmCode, -- 1249
				expiresAt = expiresAt, -- 1250
				ttl = ttl, -- 1251
				approved = false -- 1252
			} -- 1247
		end, -- 1246
		getPending = function() -- 1254
			return pending -- 1254
		end, -- 1254
		approvePending = function(sessionId) -- 1256
			if pending and pending.sessionId == sessionId then -- 1257
				pending.approved = true -- 1258
				return true -- 1259
			end -- 1257
			return false -- 1260
		end, -- 1256
		clearPending = function() -- 1262
			pending = nil -- 1262
		end, -- 1262
		setSession = function(sessionId, sessionSecret) -- 1264
			session = { -- 1266
				sessionId = sessionId, -- 1266
				sessionSecret = sessionSecret -- 1267
			} -- 1265
		end, -- 1264
		getSession = function() -- 1269
			return session -- 1269
		end -- 1269
	} -- 1245
end -- 1242
_module_0["AuthSession"] = AuthSession -- 1242
local transparant = Color(0x0) -- 1272
local windowFlags = { -- 1273
	"NoTitleBar", -- 1273
	"NoResize", -- 1273
	"NoMove", -- 1273
	"NoCollapse", -- 1273
	"NoSavedSettings", -- 1273
	"NoFocusOnAppearing", -- 1273
	"NoBringToFrontOnFocus" -- 1273
} -- 1273
local statusFlags = { -- 1282
	"NoTitleBar", -- 1282
	"NoResize", -- 1282
	"NoMove", -- 1282
	"NoCollapse", -- 1282
	"AlwaysAutoResize", -- 1282
	"NoSavedSettings" -- 1282
} -- 1282
local displayWindowFlags = { -- 1290
	"NoDecoration", -- 1290
	"NoSavedSettings", -- 1290
	"NoMove", -- 1290
	"NoScrollWithMouse", -- 1290
	"AlwaysAutoResize", -- 1290
	"NoFocusOnAppearing" -- 1290
} -- 1290
local _anon_func_7 = function(allEntries, currentIndex) -- 1363
	if currentIndex > 1 then -- 1363
		return allEntries[currentIndex - 1] -- 1364
	else -- 1366
		return allEntries[#allEntries] -- 1366
	end -- 1363
end -- 1363
local _anon_func_8 = function(allEntries, currentIndex) -- 1370
	if currentIndex < #allEntries then -- 1370
		return allEntries[currentIndex + 1] -- 1371
	else -- 1373
		return allEntries[1] -- 1373
	end -- 1370
end -- 1370
local _anon_func_9 = function(allEntries) -- 1413
	local _val_0 = allEntries.urlHandlerState -- 1413
	return "other" == _val_0 or "error" == _val_0 -- 1413
end -- 1413
do -- 1299
	local gamepadInputWindowFlags = { -- 1300
		"NoDecoration", -- 1300
		"NoSavedSettings", -- 1300
		"NoMove", -- 1300
		"NoScrollbar", -- 1300
		"NoScrollWithMouse", -- 1300
		"NoFocusOnAppearing", -- 1300
		"NoBringToFrontOnFocus" -- 1300
	} -- 1300
	local initFooter = true -- 1309
	local gamepadInputFocused = false -- 1310
	footerWindow = threadLoop(function() -- 1311
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1312
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1313
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1314
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1315
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1316
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1317
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1318
		if mobileMode then -- 1319
			return -- 1319
		end -- 1319
		local zh = useChinese -- 1320
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1321
		if authCodeTTL <= 0 then -- 1322
			authCodeTTL = 30.0 -- 1323
			authCode = string.format("%06d", math.random(0, 999999)) -- 1324
		end -- 1322
		if HttpServer.wsConnectionCount > 0 then -- 1325
			return -- 1326
		end -- 1325
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1327
			if App.platform == "Emscripten" then -- 1328
				stop() -- 1330
			else -- 1332
				allClear() -- 1332
				App.devMode = false -- 1333
				App:shutdown() -- 1334
			end -- 1328
		end -- 1327
		do -- 1335
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1336
			if ctrl and Keyboard:isKeyDown("Q") then -- 1337
				stop() -- 1338
			end -- 1337
			if ctrl and Keyboard:isKeyDown("Z") then -- 1339
				reloadCurrentEntry() -- 1340
			end -- 1339
			if ctrl and Keyboard:isKeyDown(",") then -- 1341
				if showFooter then -- 1342
					showStats = not showStats -- 1342
				else -- 1342
					showStats = true -- 1342
				end -- 1342
				showFooter = true -- 1343
				config.showFooter = showFooter -- 1344
				config.showStats = showStats -- 1345
			end -- 1341
			if ctrl and Keyboard:isKeyDown(".") then -- 1346
				if showFooter then -- 1347
					showConsole = not showConsole -- 1347
				else -- 1347
					showConsole = true -- 1347
				end -- 1347
				showFooter = true -- 1348
				config.showFooter = showFooter -- 1349
				config.showConsole = showConsole -- 1350
			end -- 1346
			if ctrl and Keyboard:isKeyDown("/") then -- 1351
				showFooter = not showFooter -- 1352
				config.showFooter = showFooter -- 1353
			end -- 1351
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1354
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1355
			local currentIndex = nil -- 1356
			for i, entry in ipairs(allEntries) do -- 1357
				if currentEntry == entry then -- 1358
					currentIndex = i -- 1359
				end -- 1358
			end -- 1357
			if left then -- 1360
				allClear() -- 1361
				if currentIndex == nil then -- 1362
					currentIndex = #allEntries + 1 -- 1362
				end -- 1362
				enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 1363
			end -- 1360
			if right then -- 1367
				allClear() -- 1368
				if currentIndex == nil then -- 1369
					currentIndex = 0 -- 1369
				end -- 1369
				enterDemoEntry(_anon_func_8(allEntries, currentIndex)) -- 1370
			end -- 1367
		end -- 1335
		if not showEntry then -- 1374
			return -- 1374
		end -- 1374
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1376
			reloadDevEntry() -- 1380
		end -- 1376
		if initFooter then -- 1381
			initFooter = false -- 1382
		end -- 1381
		local width, height -- 1384
		do -- 1384
			local _obj_0 = App.visualSize -- 1384
			width, height = _obj_0.width, _obj_0.height -- 1384
		end -- 1384
		if isInEntry then -- 1385
			gamepadInputFocused = false -- 1386
		else -- 1388
			SetNextWindowBgAlpha(0.0) -- 1388
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1389
			SetNextWindowPos(Vec2.zero, "Always") -- 1390
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1391
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1392
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1393
						if not gamepadInputFocused then -- 1394
							SetWindowFocus("DoraGamepadInput") -- 1395
							gamepadInputFocused = true -- 1396
						end -- 1394
					end) -- 1393
				end) -- 1392
			end) -- 1391
		end -- 1385
		if isInEntry or showFooter then -- 1398
			SetNextWindowSize(Vec2(width, 50)) -- 1399
			SetNextWindowPos(Vec2(0, height - 50)) -- 1400
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1401
				return PushStyleVar("WindowRounding", 0, function() -- 1402
					return Begin("Footer", windowFlags, function() -- 1403
						Separator() -- 1404
						if iconTex then -- 1405
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1406
								showStats = not showStats -- 1407
								config.showStats = showStats -- 1408
							end -- 1406
							SameLine() -- 1409
						end -- 1405
						if Button(">_", Vec2(30, 30)) then -- 1410
							showConsole = not showConsole -- 1411
							config.showConsole = showConsole -- 1412
						end -- 1410
						if App.platform == "Windows" and _anon_func_9(allEntries) then -- 1413
							SameLine() -- 1414
							if Button(zh and "注册浏览器链接" or "Register browser links") then -- 1415
								emit("AppURLHandler", "register") -- 1416
							end -- 1415
						end -- 1413
						if isInEntry and updateState.available then -- 1417
							SameLine() -- 1418
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1419
								allClear() -- 1420
								enterDemoEntry({ -- 1422
									entryName = "SelfUpdater", -- 1422
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1423
								}) -- 1421
							end -- 1419
						end -- 1417
						if not isInEntry then -- 1424
							SameLine() -- 1425
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1426
							local currentIndex = nil -- 1427
							for i, entry in ipairs(allEntries) do -- 1428
								if currentEntry == entry then -- 1429
									currentIndex = i -- 1430
								end -- 1429
							end -- 1428
							if currentIndex then -- 1431
								if currentIndex > 1 then -- 1432
									SameLine() -- 1433
									if Button("<<", Vec2(30, 30)) then -- 1434
										allClear() -- 1435
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1436
									end -- 1434
								end -- 1432
								if currentIndex < #allEntries then -- 1437
									SameLine() -- 1438
									if Button(">>", Vec2(30, 30)) then -- 1439
										allClear() -- 1440
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1441
									end -- 1439
								end -- 1437
							end -- 1431
							SameLine() -- 1442
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1443
								reloadCurrentEntry() -- 1444
							end -- 1443
							if back then -- 1445
								allClear() -- 1446
								isInEntry = true -- 1447
								currentEntry = nil -- 1448
							end -- 1445
						end -- 1424
					end) -- 1403
				end) -- 1402
			end) -- 1401
		end -- 1398
		if isInEntry then -- 1450
			local showURL = true -- 1451
			local webIDEWidth -- 1452
			do -- 1452
				local base -- 1453
				if updateState.available then -- 1453
					base = 460 -- 1453
				else -- 1453
					base = 360 -- 1453
				end -- 1453
				local extra = 35 -- 1454
				webIDEWidth = base + extra -- 1455
			end -- 1452
			if width < webIDEWidth then -- 1456
				showURL = false -- 1456
			end -- 1456
			SetNextWindowBgAlpha(0.0) -- 1457
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1458
			Begin("Web IDE", displayWindowFlags, function() -- 1459
				local pending = AuthSession.getPending() -- 1460
				local hovered = false -- 1461
				if not pending and showURL then -- 1462
					do -- 1463
						local url -- 1463
						if webStatus ~= nil then -- 1463
							url = webStatus.url -- 1463
						end -- 1463
						if url then -- 1463
							if isDesktop and not config.fullScreen then -- 1464
								if urlClicked then -- 1465
									BeginDisabled(function() -- 1466
										return Button(url) -- 1466
									end) -- 1466
								elseif Button(url) then -- 1467
									urlClicked = once(function() -- 1468
										return sleep(5) -- 1468
									end) -- 1468
									App:openURL("http://localhost:8866") -- 1469
								end -- 1465
							else -- 1471
								TextColored(descColor, url) -- 1471
							end -- 1464
						else -- 1473
							TextColored(descColor, zh and '不可用' or 'not available') -- 1473
						end -- 1463
					end -- 1463
					hovered = IsItemHovered() -- 1474
				else -- 1476
					TextColored(descColor, "(?)") -- 1476
					hovered = IsItemHovered() -- 1477
				end -- 1462
				SameLine() -- 1478
				local themeColor = App.themeColor -- 1479
				if pending then -- 1480
					if not pending.approved then -- 1481
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1482
						local ttl = pending.ttl or 1 -- 1483
						PushStyleColor("Text", themeColor, function() -- 1484
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1485
							hovered = hovered or IsItemHovered() -- 1486
						end) -- 1484
						SameLine() -- 1487
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1488
							AuthSession.approvePending(pending.sessionId) -- 1489
						end -- 1488
						if hovered then -- 1490
							return BeginTooltip(function() -- 1491
								return PushTextWrapPos(280, function() -- 1492
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1493
								end) -- 1492
							end) -- 1491
						end -- 1490
					end -- 1481
				else -- 1495
					PushStyleColor("Text", themeColor, function() -- 1495
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1496
						hovered = hovered or IsItemHovered() -- 1497
					end) -- 1495
					if hovered then -- 1498
						return BeginTooltip(function() -- 1499
							return PushTextWrapPos(280, function() -- 1500
								local url -- 1501
								if webStatus ~= nil then -- 1501
									url = webStatus.url -- 1501
								end -- 1501
								if url then -- 1501
									local address -- 1502
									if showURL then -- 1502
										address = "Web IDE" -- 1502
									else -- 1502
										address = url -- 1502
									end -- 1502
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1503
								else -- 1505
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1505
								end -- 1501
							end) -- 1500
						end) -- 1499
					end -- 1498
				end -- 1480
			end) -- 1459
		end -- 1450
		if not isInEntry then -- 1506
			SetNextWindowSize(Vec2(50, 50)) -- 1507
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1508
			PushStyleColor("WindowBg", transparant, function() -- 1509
				return Begin("Show", displayWindowFlags, function() -- 1509
					if width >= 370 then -- 1510
						local changed -- 1511
						changed, showFooter = Checkbox("##dev", showFooter) -- 1511
						if changed then -- 1511
							config.showFooter = showFooter -- 1512
						end -- 1511
					end -- 1510
				end) -- 1509
			end) -- 1509
		end -- 1506
		if isInEntry or showFooter then -- 1514
			if showStats then -- 1515
				PushStyleVar("WindowRounding", 0, function() -- 1516
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1517
					SetNextWindowSize(Vec2(0, height - 50)) -- 1518
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1519
					config.showStats = showStats -- 1520
				end) -- 1516
			end -- 1515
			if showConsole then -- 1521
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1522
				return PushStyleVar("WindowRounding", 6, function() -- 1523
					return ShowConsole() -- 1524
				end) -- 1523
			end -- 1521
		end -- 1514
	end) -- 1311
end -- 1299
do -- 1527
	local MaxWidth <const> = 960 -- 1528
	local toolOpen = false -- 1530
	local filterText = nil -- 1531
	allEntries.anyEntryMatched = false -- 1532
	allEntries.match = function(name) -- 1533
		local res = not filterText or name:lower():match(filterText) -- 1534
		if res then -- 1535
			allEntries.anyEntryMatched = true -- 1535
		end -- 1535
		return res -- 1536
	end -- 1533
	allEntries.thinSep = function() -- 1538
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1538
			return ImGui.SeparatorText("") -- 1538
		end) -- 1538
	end -- 1538
	entryWindow = threadLoop(function() -- 1539
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1540
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1541
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1542
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1543
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1544
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1545
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1546
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1547
		local connected = syncWebIDEControl() -- 1548
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1550
			if not allEntries.pendingPackagePath then -- 1551
				local path = App:takeReceivedFile() -- 1552
				if path ~= "" then -- 1553
					allEntries.pendingPackagePath = path -- 1553
				end -- 1553
			end -- 1551
			if allEntries.pendingPackagePath then -- 1554
				allEntries.mobileControl.pendingUIMode = true -- 1554
			end -- 1554
		end -- 1550
		if (allEntries.mobileControl.pendingUIMode ~= nil) then -- 1556
			local nextMode = allEntries.mobileControl.pendingUIMode -- 1557
			allEntries.mobileControl.pendingUIMode = nil -- 1558
			applyUIMode(nextMode) -- 1559
		end -- 1556
		if mobileMode and not connected then -- 1560
			if allEntries.importReveal and feedHost and feedHost.visible then -- 1561
				local _list_0 = getMobileFeedEntries() -- 1562
				for _index_0 = 1, #_list_0 do -- 1562
					local entry = _list_0[_index_0] -- 1562
					if entry.fileName == allEntries.importFocusedFile then -- 1563
						feedHost:emit("RestoreFeedEntry", entry) -- 1564
						allEntries.importReveal = false -- 1565
						break -- 1566
					end -- 1563
				end -- 1562
			end -- 1561
			if isInEntry and not feedHost then -- 1567
				applyUIMode(true) -- 1567
			end -- 1567
			return -- 1568
		end -- 1560
		if App.fpsLimited ~= config.fpsLimited then -- 1569
			config.fpsLimited = App.fpsLimited -- 1570
		end -- 1569
		if App.targetFPS ~= config.targetFPS then -- 1571
			config.targetFPS = App.targetFPS -- 1572
		end -- 1571
		if View.vsync ~= config.vsync then -- 1573
			config.vsync = View.vsync -- 1574
		end -- 1573
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1575
			config.fixedFPS = Director.scheduler.fixedFPS -- 1576
		end -- 1575
		if Director.profilerSending ~= config.webProfiler then -- 1577
			config.webProfiler = Director.profilerSending -- 1578
		end -- 1577
		if urlClicked then -- 1579
			local _, result = coroutine.resume(urlClicked) -- 1580
			if result then -- 1581
				coroutine.close(urlClicked) -- 1582
				urlClicked = nil -- 1583
			end -- 1581
		end -- 1579
		if not isInEntry then -- 1584
			return -- 1584
		end -- 1584
		local zh = useChinese -- 1585
		local themeColor = App.themeColor -- 1586
		if connected then -- 1587
			local width, height -- 1588
			do -- 1588
				local _obj_0 = App.visualSize -- 1588
				width, height = _obj_0.width, _obj_0.height -- 1588
			end -- 1588
			SetNextWindowBgAlpha(0.5) -- 1589
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1590
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1591
				Separator() -- 1592
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1593
				if iconTex then -- 1594
					Image(icon, Vec2(24, 24)) -- 1595
					SameLine() -- 1596
				end -- 1594
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1597
				TextColored(descColor, slogon) -- 1598
				return Separator() -- 1599
			end) -- 1591
			return -- 1600
		end -- 1587
		if not showEntry then -- 1601
			return -- 1601
		end -- 1601
		local fullWidth, height -- 1603
		do -- 1603
			local _obj_0 = App.visualSize -- 1603
			fullWidth, height = _obj_0.width, _obj_0.height -- 1603
		end -- 1603
		local width = math.min(MaxWidth, fullWidth) -- 1604
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1605
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1606
		SetNextWindowPos(Vec2.zero) -- 1607
		SetNextWindowBgAlpha(0) -- 1608
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1609
		do -- 1610
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1611
				return Begin("Dora Dev", windowFlags, function() -- 1612
					Dummy(Vec2(fullWidth - 20, 0)) -- 1613
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1614
					SameLine() -- 1615
					if Button(zh and "Go 模式" or "Go Mode") then -- 1616
						setUIMode("mobile") -- 1617
					end -- 1616
					if fullWidth >= 540 then -- 1618
						SameLine() -- 1619
						Dummy(Vec2(fullWidth - 540, 0)) -- 1620
						SameLine() -- 1621
						SetNextItemWidth(zh and -95 or -140) -- 1622
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1623
							"AutoSelectAll" -- 1623
						}) then -- 1623
							config.filter = filterBuf.text -- 1624
							allEntries.importFocusedFile = nil -- 1625
							allEntries.importReveal = false -- 1626
						end -- 1623
						SameLine() -- 1627
						if Button(zh and '下载' or 'Download') then -- 1628
							ImGui.OpenPopup("project-download") -- 1628
						end -- 1628
						ImGui.BeginPopup("project-download", function() -- 1629
							if ImGui.Selectable(zh and "从 Git 仓库导入…" or "Import Git repository…") then -- 1630
								emit("RepositoryImport", nil) -- 1631
							end -- 1630
							if ImGui.Selectable(zh and "浏览资源目录…" or "Browse resource catalog…") then -- 1632
								allClear() -- 1633
								return enterDemoEntry({ -- 1635
									entryName = "ResourceDownloader", -- 1635
									fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1636
								}) -- 1634
							end -- 1632
						end) -- 1629
					end -- 1618
					return Separator() -- 1637
				end) -- 1612
			end) -- 1611
		end -- 1610
		allEntries.anyEntryMatched = false -- 1639
		SetNextWindowPos(Vec2(0, 50)) -- 1640
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1641
		local scrollbarSize <const> = 25 -- 1643
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1644
		do -- 1645
			return PushStyleColor("WindowBg", transparant, function() -- 1646
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1647
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1648
						return PushStyleVar("Alpha", 1, function() -- 1649
							return Begin("Content", windowFlags, function() -- 1650
								local DemoViewWidth <const> = 220 -- 1651
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1652
								if filterText then -- 1653
									filterText = filterText:lower() -- 1653
								end -- 1653
								if App.platform == "Emscripten" then -- 1654
									Dora.globals.webProjects.draw(zh, themeColor) -- 1655
									allEntries.anyEntryMatched = true -- 1656
								end -- 1654
								if #gamesInDev > 0 then -- 1657
									if App.platform == "Windows" then -- 1658
										if windowsExport.busy then -- 1659
											ImGui.TextDisabled(zh and "正在导出 Windows 游戏…" or "Exporting Windows game…") -- 1659
										end -- 1659
										if windowsExport.message then -- 1660
											TextWrapped(windowsExport.message) -- 1660
										end -- 1660
									end -- 1658
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1661
									Columns(columns, false) -- 1662
									local realViewWidth = GetColumnWidth() - 50 -- 1663
									for _index_0 = 1, #gamesInDev do -- 1664
										local game = gamesInDev[_index_0] -- 1664
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1665
										local displayName -- 1674
										if repo then -- 1674
											if zh then -- 1675
												displayName = repo.title.zh -- 1675
											else -- 1675
												displayName = repo.title.en -- 1675
											end -- 1675
										end -- 1674
										if displayName == nil then -- 1676
											displayName = gameName -- 1676
										end -- 1676
										if allEntries.match(displayName) or allEntries.importFocusedFile == fileName then -- 1677
											allEntries.anyEntryMatched = true -- 1678
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1679
											SameLine() -- 1680
											if allEntries.importFocusedFile == fileName then -- 1681
												PushStyleColor("Text", themeColor, function() -- 1682
													return TextWrapped(displayName) -- 1682
												end) -- 1682
											else -- 1684
												TextWrapped(displayName) -- 1684
											end -- 1681
											if allEntries.importFocusedFile == fileName and allEntries.importReveal then -- 1685
												ImGui.SetScrollHereY(0.5) -- 1686
												allEntries.importReveal = false -- 1687
											end -- 1685
											if columns > 1 then -- 1688
												if bannerFile and bannerTex then -- 1689
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1690
													local displayWidth <const> = realViewWidth -- 1691
													texHeight = displayWidth * texHeight / texWidth -- 1692
													texWidth = displayWidth -- 1693
													Dummy(Vec2.zero) -- 1694
													SameLine() -- 1695
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1696
												end -- 1689
												if game.needsBuild then -- 1697
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1698
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1699
													enterDemoEntry(game) -- 1700
												end -- 1697
											else -- 1702
												if bannerFile and bannerTex then -- 1702
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1703
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1704
													local sizing = 0.8 -- 1705
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1706
													texWidth = displayWidth * sizing -- 1707
													if texWidth > 500 then -- 1708
														sizing = 0.6 -- 1709
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1710
														texWidth = displayWidth * sizing -- 1711
													end -- 1708
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1712
													Dummy(Vec2(padding, 0)) -- 1713
													SameLine() -- 1714
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1715
												end -- 1702
												if game.needsBuild then -- 1716
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1717
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1718
													enterDemoEntry(game) -- 1719
												end -- 1716
											end -- 1688
											if App.platform == "Windows" and not windowsExport.busy and not game.needsBuild then -- 1720
												if Button(tostring(zh and "导出 Windows ZIP" or "Export Windows ZIP") .. "##" .. tostring(fileName), Vec2(-1, 30)) then -- 1721
													allEntries.exportWindowsGame(game, displayName) -- 1722
												end -- 1721
											end -- 1720
											if #tests == 0 and #examples == 0 then -- 1723
												allEntries.thinSep() -- 1724
											end -- 1723
											NextColumn() -- 1725
										end -- 1677
										local showSep = false -- 1726
										if #examples > 0 then -- 1727
											local showExample = false -- 1728
											for _index_1 = 1, #examples do -- 1729
												local _des_0 = examples[_index_1] -- 1729
												local entryName = _des_0.entryName -- 1729
												if allEntries.match(entryName) then -- 1730
													showExample = true -- 1730
													break -- 1730
												end -- 1730
											end -- 1729
											if showExample then -- 1731
												showSep = true -- 1732
												Columns(1, false) -- 1733
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1734
												SameLine() -- 1735
												local opened -- 1736
												if (filterText ~= nil) then -- 1736
													opened = showExample -- 1736
												else -- 1736
													opened = false -- 1736
												end -- 1736
												if game.exampleOpen == nil then -- 1737
													game.exampleOpen = opened -- 1737
												end -- 1737
												SetNextItemOpen(game.exampleOpen) -- 1738
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1739
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1740
														Columns(maxColumns, false) -- 1741
														for _index_1 = 1, #examples do -- 1742
															local example = examples[_index_1] -- 1742
															local entryName = example.entryName -- 1743
															if not allEntries.match(entryName) then -- 1744
																goto _continue_0 -- 1744
															end -- 1744
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1745
																if Button(entryName, Vec2(-1, 40)) then -- 1746
																	enterDemoEntry(example) -- 1747
																end -- 1746
																return NextColumn() -- 1748
															end) -- 1745
															opened = true -- 1749
															::_continue_0:: -- 1743
														end -- 1742
													end) -- 1740
												end) -- 1739
												game.exampleOpen = opened -- 1750
											end -- 1731
										end -- 1727
										if #tests > 0 then -- 1751
											local showTest = false -- 1752
											for _index_1 = 1, #tests do -- 1753
												local _des_0 = tests[_index_1] -- 1753
												local entryName = _des_0.entryName -- 1753
												if allEntries.match(entryName) then -- 1754
													showTest = true -- 1754
													break -- 1754
												end -- 1754
											end -- 1753
											if showTest then -- 1755
												showSep = true -- 1756
												Columns(1, false) -- 1757
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1758
												SameLine() -- 1759
												local opened -- 1760
												if (filterText ~= nil) then -- 1760
													opened = showTest -- 1760
												else -- 1760
													opened = false -- 1760
												end -- 1760
												if game.testOpen == nil then -- 1761
													game.testOpen = opened -- 1761
												end -- 1761
												SetNextItemOpen(game.testOpen) -- 1762
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1763
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1764
														Columns(maxColumns, false) -- 1765
														for _index_1 = 1, #tests do -- 1766
															local test = tests[_index_1] -- 1766
															local entryName = test.entryName -- 1767
															if not allEntries.match(entryName) then -- 1768
																goto _continue_0 -- 1768
															end -- 1768
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1769
																if Button(entryName, Vec2(-1, 40)) then -- 1770
																	enterDemoEntry(test) -- 1771
																end -- 1770
																return NextColumn() -- 1772
															end) -- 1769
															opened = true -- 1773
															::_continue_0:: -- 1767
														end -- 1766
													end) -- 1764
												end) -- 1763
												game.testOpen = opened -- 1774
											end -- 1755
										end -- 1751
										if showSep then -- 1775
											Columns(1, false) -- 1776
											allEntries.thinSep() -- 1777
											Columns(columns, false) -- 1778
										end -- 1775
									end -- 1664
								end -- 1657
								if #doraTools > 0 then -- 1779
									local showTool = false -- 1780
									for _index_0 = 1, #doraTools do -- 1781
										local _des_0 = doraTools[_index_0] -- 1781
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1781
										local displayName -- 1782
										if repo then -- 1782
											if zh then -- 1783
												displayName = repo.title.zh -- 1783
											else -- 1783
												displayName = repo.title.en -- 1783
											end -- 1783
										end -- 1782
										if displayName == nil then -- 1784
											displayName = entryName -- 1784
										end -- 1784
										if allEntries.match(displayName) then -- 1785
											showTool = true -- 1785
											break -- 1785
										end -- 1785
									end -- 1781
									if not showTool then -- 1786
										goto endEntry -- 1786
									end -- 1786
									Columns(1, false) -- 1787
									TextColored(themeColor, "Dora SSR:") -- 1788
									SameLine() -- 1789
									Text(zh and "开发支持" or "Development Support") -- 1790
									Separator() -- 1791
									if #doraTools > 0 then -- 1792
										local opened -- 1793
										if (filterText ~= nil) then -- 1793
											opened = showTool -- 1793
										else -- 1793
											opened = false -- 1793
										end -- 1793
										SetNextItemOpen(toolOpen) -- 1794
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1795
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1796
												Columns(maxColumns, false) -- 1797
												for _index_0 = 1, #doraTools do -- 1798
													local tool = doraTools[_index_0] -- 1798
													local entryName, repo = tool.entryName, tool.repo -- 1799
													local displayName -- 1800
													if repo then -- 1800
														if zh then -- 1801
															displayName = repo.title.zh -- 1801
														else -- 1801
															displayName = repo.title.en -- 1801
														end -- 1801
													end -- 1800
													if displayName == nil then -- 1802
														displayName = entryName -- 1802
													end -- 1802
													if not allEntries.match(displayName) then -- 1803
														goto _continue_0 -- 1803
													end -- 1803
													if Button(displayName, Vec2(-1, 40)) then -- 1804
														enterDemoEntry(tool) -- 1805
													end -- 1804
													NextColumn() -- 1806
													::_continue_0:: -- 1799
												end -- 1798
												Columns(1, false) -- 1807
												opened = true -- 1808
											end) -- 1796
										end) -- 1795
										toolOpen = opened -- 1809
									end -- 1792
								end -- 1779
								::endEntry:: -- 1810
								if not allEntries.anyEntryMatched then -- 1811
									SetNextWindowBgAlpha(0) -- 1812
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1813
									Begin("Entries Not Found", displayWindowFlags, function() -- 1814
										Separator() -- 1815
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1816
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1817
										return Separator() -- 1818
									end) -- 1814
								end -- 1811
								Columns(1, false) -- 1819
								Dummy(Vec2(100, 80)) -- 1820
								return ScrollWhenDraggingOnVoid() -- 1821
							end) -- 1650
						end) -- 1649
					end) -- 1648
				end) -- 1647
			end) -- 1646
		end -- 1645
	end) -- 1539
end -- 1527
if not (App.platform == "Emscripten") then -- 1826
	local sceneModuleCache = moduleCache -- 1827
	moduleCache = { } -- 1828
	webStatus = oldRequire("Script.Dev.WebServer") -- 1829
	moduleCache = sceneModuleCache -- 1830
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1831
		thread(function() -- 1832
			wait(function() -- 1833
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1833
			end) -- 1833
			if App.webIDEEnabled then -- 1834
				return emit("AppWebView", "/ide/show", true) -- 1834
			end -- 1834
		end) -- 1832
	end -- 1831
end -- 1826
local _anon_func_10 = function(saved) -- 1857
	local _val_0 = saved.kind -- 1857
	return "local" == _val_0 or "discover" == _val_0 -- 1857
end -- 1857
local _anon_func_11 = function(saved) -- 1861
	local _val_0 = saved.activeTab -- 1861
	return "local" == _val_0 or "discover" == _val_0 -- 1861
end -- 1861
startMobileUI = function() -- 1836
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1837
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1838
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1839
	local getMobileFeedResources -- 1840
	do -- 1840
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1840
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1840
	end -- 1840
	local loadCachedCatalog -- 1841
	do -- 1841
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1841
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1841
	end -- 1841
	local getResourceInstallPath, getInstalledCatalogResource -- 1842
	do -- 1842
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1842
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1842
	end -- 1842
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1843
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1844
	local feedOptions = nil -- 1845
	local mobileLaunchErrors = { } -- 1846
	local withMobileLaunchErrors -- 1847
	withMobileLaunchErrors = function(items) -- 1847
		for _index_0 = 1, #items do -- 1848
			local item = items[_index_0] -- 1848
			item.launchError = mobileLaunchErrors[item.id] -- 1849
		end -- 1848
		return items -- 1850
	end -- 1847
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1851
	local loadRememberedMobileFeedState -- 1852
	loadRememberedMobileFeedState = function() -- 1852
		local raw = rememberedMobileFeedData -- 1853
		if not (type(raw) == "string" and raw ~= "") then -- 1854
			return -- 1854
		end -- 1854
		local ok, saved = pcall(json.decode, raw) -- 1855
		if not (ok and type(saved) == "table") then -- 1856
			return -- 1856
		end -- 1856
		if type(saved.id) == "string" and _anon_func_10(saved) then -- 1857
			local state = { -- 1858
				activeTab = saved.kind -- 1858
			} -- 1858
			state[saved.kind] = saved -- 1859
			return state -- 1860
		end -- 1857
		local state = { -- 1861
			activeTab = _anon_func_11(saved) and saved.activeTab or "local" -- 1861
		} -- 1861
		local _list_0 = { -- 1862
			"local", -- 1862
			"discover" -- 1862
		} -- 1862
		for _index_0 = 1, #_list_0 do -- 1862
			local kind = _list_0[_index_0] -- 1862
			local entry = saved[kind] -- 1863
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1864
				state[kind] = entry -- 1864
			end -- 1864
		end -- 1862
		return state -- 1865
	end -- 1852
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1866
		activeTab = "local" -- 1866
	} -- 1866
	local rememberMobileFeedEntry -- 1867
	rememberMobileFeedEntry = function(entry) -- 1867
		rememberedMobileFeedState.activeTab = entry.kind -- 1868
		rememberedMobileFeedState[entry.kind] = { -- 1870
			id = entry.id, -- 1870
			kind = entry.kind, -- 1871
			workDir = entry.workDir, -- 1872
			fileName = entry.fileName -- 1873
		} -- 1869
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1875
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1876
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1877
			rememberedMobileFeedData -- 1877
		}) -- 1877
	end -- 1867
	local restartMobileFeed -- 1878
	restartMobileFeed = function(entry) -- 1878
		if feedHost then -- 1879
			feedHost:removeFromParent(true) -- 1879
		end -- 1879
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1880
		local initialEntries = { } -- 1881
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1882
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1883
		feedOptions.initialEntries = initialEntries -- 1884
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1885
	end -- 1878
	local startMobilePlay -- 1886
	startMobilePlay = function(entry) -- 1886
		if HttpServer.wsConnectionCount > 0 then -- 1887
			return -- 1887
		end -- 1887
		if entry.needsBuild then -- 1888
			mobileLaunchErrors[entry.id] = useChinese and "请先在 IDE 中编译项目" or "Build the project in the IDE first" -- 1889
			restartMobileFeed(entry) -- 1890
			return -- 1891
		end -- 1888
		local originFeed = feedHost -- 1892
		if remixHost then -- 1893
			remixHost:removeFromParent(true) -- 1893
		end -- 1893
		remixHost = nil -- 1894
		mobileLaunchErrors[entry.id] = nil -- 1895
		entry.launchError = nil -- 1896
		local playActive = true -- 1897
		local playHost = nil -- 1898
		local restoreMobileFeed -- 1899
		restoreMobileFeed = function() -- 1899
			if not playActive then -- 1900
				return -- 1900
			end -- 1900
			playActive = false -- 1901
			if playHost and playHost.parent then -- 1903
				playHost:removeFromParent(true) -- 1903
			end -- 1903
			playHost = nil -- 1904
			allClear() -- 1905
			isInEntry = true -- 1906
			currentEntry = nil -- 1907
			return restartMobileFeed(entry) -- 1908
		end -- 1899
		playHost = trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1910
			onExit = function() -- 1910
				return restoreMobileFeed() -- 1910
			end, -- 1910
			onRuntimeError = function() -- 1911
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1912
				return restoreMobileFeed() -- 1913
			end -- 1911
		})) -- 1909
		return thread(function() -- 1915
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1919
			if not playActive then -- 1920
				return -- 1920
			end -- 1920
			if success then -- 1921
				if originFeed and originFeed.parent then -- 1922
					originFeed.visible = false -- 1922
				end -- 1922
				return -- 1923
			end -- 1921
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1924
			return restoreMobileFeed() -- 1925
		end) -- 1915
	end -- 1886
	feedOptions = { -- 1927
		takeReceivedFile = function() -- 1927
			if allEntries.pendingPackagePath then -- 1928
				local path = allEntries.pendingPackagePath -- 1929
				allEntries.pendingPackagePath = nil -- 1930
				return path -- 1931
			end -- 1928
			return App:takeReceivedFile() -- 1932
		end, -- 1927
		onSwitchMode = function() -- 1933
			if HttpServer.wsConnectionCount == 0 then -- 1933
				allEntries.mobileControl.pendingUIMode = false -- 1933
			end -- 1933
		end, -- 1933
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1934
		getLocalEntries = function(importedProjectPath) -- 1935
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1936
			feedOptions.dirtyProjectPath = nil -- 1937
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1938
			local cached = loadCachedCatalog() -- 1939
			if cached.success and cached.snapshot then -- 1940
				for _index_0 = 1, #items do -- 1941
					local entry = items[_index_0] -- 1941
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1942
					if resource then -- 1943
						entry.resource = resource -- 1944
						entry.catalogCommit = cached.snapshot.commit -- 1945
					end -- 1943
				end -- 1941
			end -- 1940
			return items -- 1946
		end, -- 1935
		syncDiscover = function(onProgress, onDone, force) -- 1947
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1947
		end, -- 1947
		getDiscoverEntries = function() -- 1948
			local cached = loadCachedCatalog() -- 1949
			if not (cached.success and cached.snapshot) then -- 1950
				return { } -- 1950
			end -- 1950
			local items = { } -- 1951
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1952
			for _index_0 = 1, #_list_0 do -- 1952
				local resource = _list_0[_index_0] -- 1952
				local installed = lifecycle.isMobileResourceReady(resource) -- 1953
				local installPath = getResourceInstallPath(resource.id) -- 1954
				items[#items + 1] = { -- 1956
					id = resource.id, -- 1956
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1957
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1958
					kind = "discover", -- 1959
					bannerFile = resource.bannerPath, -- 1960
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1961
					sourceUrl = resource.versions[1].sources[1].url, -- 1962
					workDir = installed and installPath or nil, -- 1963
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1964
					installed = installed, -- 1965
					resource = resource, -- 1966
					catalogCommit = cached.snapshot.commit, -- 1967
					launchError = mobileLaunchErrors[resource.id] -- 1968
				} -- 1955
			end -- 1952
			return items -- 1970
		end, -- 1948
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1971
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1972
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1973
			end), repairIncomplete, isCanceled) -- 1972
		end, -- 1971
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1975
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1976
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1977
			end), isCanceled) -- 1976
		end, -- 1975
		createProject = function(name, language) -- 1979
			local result = projectCreate.createMobileProject(name, language) -- 1980
			if not result.success then -- 1981
				return result -- 1981
			end -- 1981
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1982
			for _index_0 = 1, #_list_0 do -- 1982
				local entry = _list_0[_index_0] -- 1982
				if entry.workDir == result.workDir then -- 1983
					return { -- 1984
						success = true, -- 1984
						entry = entry -- 1984
					} -- 1984
				end -- 1983
			end -- 1982
			return { -- 1985
				success = false, -- 1985
				error = "created-project-not-found" -- 1985
			} -- 1985
		end, -- 1979
		onPlay = function(entry) -- 1986
			return startMobilePlay(entry) -- 1986
		end, -- 1986
		onRemix = function(entry) -- 1987
			if HttpServer.wsConnectionCount > 0 then -- 1988
				return -- 1988
			end -- 1988
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1989
			local originFeed = feedHost -- 1990
			feedHost.visible = false -- 1991
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1993
				entry = entry, -- 1993
				onProjectChanged = function(current) -- 1994
					feedOptions.dirtyProjectPath = current.workDir -- 1994
				end, -- 1994
				onBack = function() -- 1995
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1996
						originFeed:emit("RestoreFeedEntry", entry) -- 1997
						originFeed.visible = true -- 1998
					end -- 1996
				end, -- 1995
				onPlay = function(current) -- 1999
					return startMobilePlay(current) -- 1999
				end -- 1999
			})) -- 1992
		end -- 1987
	} -- 1926
	return restartMobileFeed() -- 2002
end -- 1836
if mobileMode then -- 2004
	applyUIMode(true) -- 2004
end -- 2004
return _module_0 -- 1
