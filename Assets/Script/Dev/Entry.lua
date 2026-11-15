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
local isToolEntry -- 387
isToolEntry = function(entry) -- 387
	do -- 388
		local _type_0 = type(entry) -- 388
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 388
		if _tab_0 then -- 388
			local categories -- 388
			do -- 388
				local _obj_0 = entry.repo -- 388
				local _type_1 = type(_obj_0) -- 388
				if "table" == _type_1 or "userdata" == _type_1 then -- 388
					categories = _obj_0.categories -- 388
				end -- 388
			end -- 388
			if categories ~= nil then -- 388
				for _index_0 = 1, #categories do -- 389
					local category = categories[_index_0] -- 389
					if "string" == type(category) and category:lower() == "tool" then -- 390
						return true -- 391
					end -- 390
				end -- 389
			end -- 388
		end -- 388
	end -- 388
	return false -- 387
end -- 387
local getEntryTitle -- 393
getEntryTitle = function(entry) -- 393
	local title -- 394
	do -- 394
		local repo = entry.repo -- 394
		if repo then -- 394
			if repo.title and "table" == type(repo.title) then -- 395
				if useChinese then -- 396
					title = repo.title.zh -- 396
				else -- 396
					title = repo.title.en -- 396
				end -- 396
			end -- 395
		end -- 394
	end -- 394
	if title ~= nil then -- 397
		return title -- 397
	else -- 397
		return entry.entryName -- 397
	end -- 397
end -- 393
allEntries.rebuildEntries = function() -- 399
	gamesInDev = { } -- 400
	do -- 401
		local _accum_0 = { } -- 401
		local _len_0 = 1 -- 401
		local _list_0 = allEntries.builtinTools -- 401
		for _index_0 = 1, #_list_0 do -- 401
			local tool = _list_0[_index_0] -- 401
			_accum_0[_len_0] = tool -- 401
			_len_0 = _len_0 + 1 -- 401
		end -- 401
		doraTools = _accum_0 -- 401
	end -- 401
	local _list_0 = allEntries.projectEntries -- 402
	for _index_0 = 1, #_list_0 do -- 402
		local entry = _list_0[_index_0] -- 402
		if isToolEntry(entry) then -- 403
			entry.kind = "tool" -- 404
			doraTools[#doraTools + 1] = entry -- 405
		else -- 407
			entry.kind = "game" -- 407
			gamesInDev[#gamesInDev + 1] = entry -- 408
		end -- 403
	end -- 402
	for i = #allEntries, 1, -1 do -- 409
		allEntries[i] = nil -- 410
	end -- 409
	for _index_0 = 1, #gamesInDev do -- 411
		local game = gamesInDev[_index_0] -- 411
		allEntries[#allEntries + 1] = game -- 412
		local examples, tests = game.examples, game.tests -- 413
		for _index_1 = 1, #examples do -- 414
			local example = examples[_index_1] -- 414
			allEntries[#allEntries + 1] = example -- 415
		end -- 414
		for _index_1 = 1, #tests do -- 416
			local test = tests[_index_1] -- 416
			allEntries[#allEntries + 1] = test -- 417
		end -- 416
	end -- 411
end -- 399
local updateEntries -- 419
updateEntries = function() -- 419
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 420
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 421
	local _list_0 = allEntries.builtinTools -- 422
	for _index_0 = 1, #_list_0 do -- 422
		local tool = _list_0[_index_0] -- 422
		tool.kind = "tool" -- 423
		tool.builtin = true -- 424
		if tool.entryName == "RepositoryImporter" then -- 425
			tool.repo = { -- 426
				title = { -- 426
					en = "Import repository", -- 426
					zh = "从仓库导入" -- 426
				} -- 426
			} -- 426
		end -- 425
	end -- 422
	return allEntries.rebuildEntries() -- 427
end -- 419
allEntries.refreshDirtyProjects = function() -- 429
	if not allEntries.hasDirty then -- 430
		return -- 430
	end -- 430
	local dirty = allEntries.dirty -- 431
	allEntries.dirty = { } -- 432
	allEntries.hasDirty = false -- 433
	for projectPath in pairs(dirty) do -- 434
		do -- 435
			local _accum_0 = { } -- 435
			local _len_0 = 1 -- 435
			local _list_0 = allEntries.projectEntries -- 435
			for _index_0 = 1, #_list_0 do -- 435
				local entry = _list_0[_index_0] -- 435
				if entry.projectPath ~= projectPath then -- 435
					_accum_0[_len_0] = entry -- 435
					_len_0 = _len_0 + 1 -- 435
				end -- 435
			end -- 435
			allEntries.projectEntries = _accum_0 -- 435
		end -- 435
		local parentPath = Path:getPath(projectPath) -- 436
		local dir = Path:getFilename(projectPath) -- 437
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 438
		for _index_0 = 1, #_list_0 do -- 438
			local entry = _list_0[_index_0] -- 438
			if entry.projectPath == projectPath then -- 439
				do -- 440
					local _obj_0 = allEntries.projectEntries -- 440
					_obj_0[#_obj_0 + 1] = entry -- 440
				end -- 440
				break -- 441
			end -- 439
		end -- 438
	end -- 434
	table.sort(allEntries.projectEntries, function(a, b) -- 442
		return a.entryName < b.entryName -- 442
	end) -- 442
	return allEntries.rebuildEntries() -- 443
end -- 429
updateEntries() -- 445
local getLaunchEntries -- 447
getLaunchEntries = function(refresh) -- 447
	if refresh == nil then -- 447
		refresh = false -- 447
	end -- 447
	if refresh then -- 448
		updateEntries() -- 448
	end -- 448
	local toInfo -- 449
	toInfo = function(entry, kind) -- 449
		local file = entry.fileName -- 450
		local asProj = not entry.builtin -- 451
		return { -- 453
			name = getEntryTitle(entry), -- 453
			file = file, -- 454
			kind = kind, -- 455
			asProj = asProj -- 456
		} -- 452
	end -- 449
	local games -- 458
	do -- 458
		local _accum_0 = { } -- 458
		local _len_0 = 1 -- 458
		for _index_0 = 1, #gamesInDev do -- 458
			local game = gamesInDev[_index_0] -- 458
			_accum_0[_len_0] = toInfo(game, "game") -- 458
			_len_0 = _len_0 + 1 -- 458
		end -- 458
		games = _accum_0 -- 458
	end -- 458
	local tools -- 459
	do -- 459
		local _accum_0 = { } -- 459
		local _len_0 = 1 -- 459
		for _index_0 = 1, #doraTools do -- 459
			local tool = doraTools[_index_0] -- 459
			_accum_0[_len_0] = toInfo(tool, "tool") -- 459
			_len_0 = _len_0 + 1 -- 459
		end -- 459
		tools = _accum_0 -- 459
	end -- 459
	return { -- 460
		games = games, -- 460
		tools = tools -- 460
	} -- 460
end -- 447
_module_0["getLaunchEntries"] = getLaunchEntries -- 447
local _anon_func_2 = function(entry, useChinese) -- 477
	local _obj_0 = entry.repo -- 477
	if _obj_0 ~= nil then -- 477
		local _obj_1 = _obj_0.description -- 477
		if _obj_1 ~= nil then -- 477
			return _obj_1[useChinese and "zh" or "en"] -- 477
		end -- 477
		return nil -- 477
	end -- 477
	return nil -- 477
end -- 477
local getMobileFeedEntries -- 462
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 462
	if refresh == nil then -- 462
		refresh = false -- 462
	end -- 462
	if dirtyProjectPath == nil then -- 462
		dirtyProjectPath = nil -- 462
	end -- 462
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 463
		allEntries.dirty[dirtyProjectPath] = true -- 464
		allEntries.hasDirty = true -- 465
	end -- 463
	if refresh then -- 466
		allEntries.dirty = { } -- 467
		allEntries.hasDirty = false -- 468
		updateEntries() -- 469
	else -- 471
		allEntries.refreshDirtyProjects() -- 471
	end -- 466
	local items = { } -- 472
	for _index_0 = 1, #gamesInDev do -- 473
		local entry = gamesInDev[_index_0] -- 473
		items[#items + 1] = { -- 475
			id = entry.entryName, -- 475
			title = getEntryTitle(entry), -- 476
			description = _anon_func_2(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 477
			fileName = entry.fileName, -- 478
			workDir = Path:getPath(entry.fileName), -- 479
			bannerFile = entry.bannerFile, -- 480
			needsBuild = entry.needsBuild, -- 481
			kind = "local" -- 482
		} -- 474
	end -- 473
	return items -- 484
end -- 462
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 462
local doCompile -- 486
doCompile = function(minify) -- 486
	if building then -- 487
		return -- 487
	end -- 487
	building = true -- 488
	local startTime = App.runningTime -- 489
	local luaFiles = { } -- 490
	local yueFiles = { } -- 491
	local xmlFiles = { } -- 492
	local tlFiles = { } -- 493
	local writablePath = Content.writablePath -- 494
	local buildPaths = { -- 496
		{ -- 497
			Content.assetPath, -- 497
			Path(writablePath, ".build"), -- 498
			"" -- 499
		} -- 496
	} -- 495
	for _index_0 = 1, #gamesInDev do -- 502
		local _des_0 = gamesInDev[_index_0] -- 502
		local fileName = _des_0.fileName -- 502
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 503
		buildPaths[#buildPaths + 1] = { -- 505
			Path(writablePath, gamePath), -- 505
			Path(writablePath, ".build", gamePath), -- 506
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 507
			gamePath -- 508
		} -- 504
	end -- 502
	for _index_0 = 1, #buildPaths do -- 509
		local _des_0 = buildPaths[_index_0] -- 509
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 509
		if not Content:exist(inputPath) then -- 510
			goto _continue_0 -- 510
		end -- 510
		local _list_0 = getAllFiles(inputPath, { -- 512
			"lua" -- 512
		}) -- 512
		for _index_1 = 1, #_list_0 do -- 512
			local file = _list_0[_index_1] -- 512
			luaFiles[#luaFiles + 1] = { -- 514
				file, -- 514
				Path(inputPath, file), -- 515
				Path(outputPath, file), -- 516
				gamePath -- 517
			} -- 513
		end -- 512
		local _list_1 = getAllFiles(inputPath, { -- 519
			yueext -- 519
		}) -- 519
		for _index_1 = 1, #_list_1 do -- 519
			local file = _list_1[_index_1] -- 519
			yueFiles[#yueFiles + 1] = { -- 521
				file, -- 521
				Path(inputPath, file), -- 522
				Path(outputPath, Path:replaceExt(file, "lua")), -- 523
				searchPath, -- 524
				gamePath -- 525
			} -- 520
		end -- 519
		local _list_2 = getAllFiles(inputPath, { -- 527
			"xml" -- 527
		}) -- 527
		for _index_1 = 1, #_list_2 do -- 527
			local file = _list_2[_index_1] -- 527
			xmlFiles[#xmlFiles + 1] = { -- 529
				file, -- 529
				Path(inputPath, file), -- 530
				Path(outputPath, Path:replaceExt(file, "lua")), -- 531
				gamePath -- 532
			} -- 528
		end -- 527
		local _list_3 = getAllFiles(inputPath, { -- 534
			"tl" -- 534
		}) -- 534
		for _index_1 = 1, #_list_3 do -- 534
			local file = _list_3[_index_1] -- 534
			if not file:match(".*%.d%.tl$") then -- 535
				tlFiles[#tlFiles + 1] = { -- 537
					file, -- 537
					Path(inputPath, file), -- 538
					Path(outputPath, Path:replaceExt(file, "lua")), -- 539
					searchPath, -- 540
					gamePath -- 541
				} -- 536
			end -- 535
		end -- 534
		::_continue_0:: -- 510
	end -- 509
	local paths -- 543
	do -- 543
		local _tbl_0 = { } -- 543
		local _list_0 = { -- 544
			luaFiles, -- 544
			yueFiles, -- 544
			xmlFiles, -- 544
			tlFiles -- 544
		} -- 544
		for _index_0 = 1, #_list_0 do -- 544
			local files = _list_0[_index_0] -- 544
			for _index_1 = 1, #files do -- 545
				local file = files[_index_1] -- 545
				_tbl_0[Path:getPath(file[3])] = true -- 543
			end -- 543
		end -- 543
		paths = _tbl_0 -- 543
	end -- 543
	for path in pairs(paths) do -- 547
		Content:mkdir(path) -- 547
	end -- 547
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 549
	local fileCount = 0 -- 550
	local errors = { } -- 551
	for _index_0 = 1, #yueFiles do -- 552
		local _des_0 = yueFiles[_index_0] -- 552
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 552
		local filename -- 553
		if gamePath then -- 553
			filename = Path(gamePath, file) -- 553
		else -- 553
			filename = file -- 553
		end -- 553
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 554
			if not codes then -- 555
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 556
				return -- 557
			end -- 555
			local success, result = LintYueGlobals(codes, globals) -- 558
			local yueCodes -- 559
			if not success then -- 560
				yueCodes = Content:load(input) -- 561
				if yueCodes then -- 561
					local CheckTIC80Code -- 562
					do -- 562
						local _obj_0 = require("Utils") -- 562
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 562
					end -- 562
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 563
					if isTIC80 then -- 564
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 565
					end -- 564
				end -- 561
			end -- 560
			if success then -- 566
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 567
			else -- 569
				if yueCodes then -- 569
					local globalErrors = { } -- 570
					for _index_1 = 1, #result do -- 571
						local _des_1 = result[_index_1] -- 571
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 571
						local countLine = 1 -- 572
						local code = "" -- 573
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 574
							if countLine == line then -- 575
								code = lineCode -- 576
								break -- 577
							end -- 575
							countLine = countLine + 1 -- 578
						end -- 574
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 579
					end -- 571
					if #globalErrors > 0 then -- 580
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 580
					end -- 580
				else -- 582
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 582
				end -- 569
				if #errors == 0 then -- 583
					return codes -- 583
				end -- 583
			end -- 566
		end, function(success) -- 554
			if success then -- 584
				print("Yue compiled: " .. tostring(filename)) -- 584
			end -- 584
			fileCount = fileCount + 1 -- 585
		end) -- 554
	end -- 552
	thread(function() -- 587
		for _index_0 = 1, #xmlFiles do -- 588
			local _des_0 = xmlFiles[_index_0] -- 588
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 588
			local filename -- 589
			if gamePath then -- 589
				filename = Path(gamePath, file) -- 589
			else -- 589
				filename = file -- 589
			end -- 589
			local sourceCodes = Content:loadAsync(input) -- 590
			local codes, err = xml.tolua(sourceCodes) -- 591
			if not codes then -- 592
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 593
			else -- 595
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 595
				print("Xml compiled: " .. tostring(filename)) -- 596
			end -- 592
			fileCount = fileCount + 1 -- 597
		end -- 588
	end) -- 587
	thread(function() -- 599
		for _index_0 = 1, #tlFiles do -- 600
			local _des_0 = tlFiles[_index_0] -- 600
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 600
			local filename -- 601
			if gamePath then -- 601
				filename = Path(gamePath, file) -- 601
			else -- 601
				filename = file -- 601
			end -- 601
			local sourceCodes = Content:loadAsync(input) -- 602
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 603
			if not codes then -- 604
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 605
			else -- 607
				Content:saveAsync(output, codes) -- 607
				print("Teal compiled: " .. tostring(filename)) -- 608
			end -- 604
			fileCount = fileCount + 1 -- 609
		end -- 600
	end) -- 599
	return thread(function() -- 611
		wait(function() -- 612
			return fileCount == totalFiles -- 612
		end) -- 612
		if minify then -- 613
			local _list_0 = { -- 614
				yueFiles, -- 614
				xmlFiles, -- 614
				tlFiles -- 614
			} -- 614
			for _index_0 = 1, #_list_0 do -- 614
				local files = _list_0[_index_0] -- 614
				for _index_1 = 1, #files do -- 614
					local file = files[_index_1] -- 614
					local output = Path:replaceExt(file[3], "lua") -- 615
					luaFiles[#luaFiles + 1] = { -- 617
						Path:replaceExt(file[1], "lua"), -- 617
						output, -- 618
						output -- 619
					} -- 616
				end -- 614
			end -- 614
			local FormatMini -- 621
			do -- 621
				local _obj_0 = require("luaminify") -- 621
				FormatMini = _obj_0.FormatMini -- 621
			end -- 621
			for _index_0 = 1, #luaFiles do -- 622
				local _des_0 = luaFiles[_index_0] -- 622
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 622
				if Content:exist(input) then -- 623
					local sourceCodes = Content:loadAsync(input) -- 624
					local res, err = FormatMini(sourceCodes) -- 625
					if res then -- 626
						Content:saveAsync(output, res) -- 627
						print("Minify: " .. tostring(file)) -- 628
					else -- 630
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 630
					end -- 626
				else -- 632
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 632
				end -- 623
			end -- 622
			package.loaded["luaminify.FormatMini"] = nil -- 633
			package.loaded["luaminify.ParseLua"] = nil -- 634
			package.loaded["luaminify.Scope"] = nil -- 635
			package.loaded["luaminify.Util"] = nil -- 636
		end -- 613
		local errorMessage = table.concat(errors, "\n") -- 637
		if errorMessage ~= "" then -- 638
			print(errorMessage) -- 638
		end -- 638
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 639
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 640
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 641
		Content:clearPathCache() -- 642
		teal.clear() -- 643
		yue.clear() -- 644
		building = false -- 645
	end) -- 611
end -- 486
local doClean -- 647
doClean = function() -- 647
	if building then -- 648
		return -- 648
	end -- 648
	local writablePath = Content.writablePath -- 649
	local targetDir = Path(writablePath, ".build") -- 650
	Content:clearPathCache() -- 651
	if Content:remove(targetDir) then -- 652
		return print("Cleaned: " .. tostring(targetDir)) -- 653
	end -- 652
end -- 647
local screenScale = 2.0 -- 655
local scaleContent = false -- 656
local isInEntry = true -- 657
local currentEntry = nil -- 658
local footerWindow = nil -- 660
local entryWindow = nil -- 661
local testingThread = nil -- 662
local mobileMode = config.mobileFeed -- 663
allEntries.mobileControl = { } -- 664
local feedHost = nil -- 665
local remixHost = nil -- 666
local startMobileUI = nil -- 667
allEntries.mobileControl.webControlled = false -- 668
allEntries.mobileControl.mobileHosts = { } -- 669
allEntries.mobileControl.suspendedMobileHosts = { } -- 670
local trackMobileHost -- 672
trackMobileHost = function(host) -- 672
	do -- 673
		local _accum_0 = { } -- 673
		local _len_0 = 1 -- 673
		local _list_0 = allEntries.mobileControl.mobileHosts -- 673
		for _index_0 = 1, #_list_0 do -- 673
			local item = _list_0[_index_0] -- 673
			if item.parent then -- 673
				_accum_0[_len_0] = item -- 673
				_len_0 = _len_0 + 1 -- 673
			end -- 673
		end -- 673
		allEntries.mobileControl.mobileHosts = _accum_0 -- 673
	end -- 673
	do -- 674
		local _obj_0 = allEntries.mobileControl.mobileHosts -- 674
		_obj_0[#_obj_0 + 1] = host -- 674
	end -- 674
	return host -- 675
end -- 672
local clearMobileUI -- 677
clearMobileUI = function() -- 677
	local _list_0 = allEntries.mobileControl.mobileHosts -- 678
	for _index_0 = 1, #_list_0 do -- 678
		local host = _list_0[_index_0] -- 678
		if host.parent then -- 679
			host:removeFromParent(true) -- 679
		end -- 679
	end -- 678
	allEntries.mobileControl.mobileHosts = { } -- 680
	allEntries.mobileControl.suspendedMobileHosts = { } -- 681
	feedHost = nil -- 682
	remixHost = nil -- 683
end -- 677
local syncWebIDEControl -- 685
syncWebIDEControl = function() -- 685
	local connected = HttpServer.wsConnectionCount > 0 -- 686
	if connected then -- 687
		allEntries.mobileControl.pendingUIMode = nil -- 688
		local _list_0 = allEntries.mobileControl.mobileHosts -- 689
		for _index_0 = 1, #_list_0 do -- 689
			local host = _list_0[_index_0] -- 689
			if not host.parent then -- 690
				goto _continue_0 -- 690
			end -- 690
			if not (allEntries.mobileControl.suspendedMobileHosts[host] ~= nil) then -- 691
				allEntries.mobileControl.suspendedMobileHosts[host] = host.visible -- 692
				host:emit("SuspendLocalUI") -- 693
			end -- 691
			host.visible = false -- 694
			::_continue_0:: -- 690
		end -- 689
	elseif allEntries.mobileControl.webControlled then -- 695
		for host, visible in pairs(allEntries.mobileControl.suspendedMobileHosts) do -- 696
			if host.parent then -- 697
				host.visible = visible -- 698
				host:emit("ResumeLocalUI") -- 699
			end -- 697
		end -- 696
		allEntries.mobileControl.suspendedMobileHosts = { } -- 700
	end -- 687
	allEntries.mobileControl.webControlled = connected -- 701
	return connected -- 702
end -- 685
local getUIMode -- 704
getUIMode = function() -- 704
	return mobileMode and "mobile" or "traditional" -- 704
end -- 704
_module_0["getUIMode"] = getUIMode -- 704
local setUIMode -- 705
setUIMode = function(mode) -- 705
	if not (("mobile" == mode or "traditional" == mode)) then -- 706
		return false -- 706
	end -- 706
	if HttpServer.wsConnectionCount > 0 then -- 707
		return false -- 707
	end -- 707
	if (allEntries.mobileControl.pendingUIMode ~= nil) or not isInEntry or testingThread then -- 708
		return false -- 708
	end -- 708
	local wantsMobile = mode == "mobile" -- 709
	if wantsMobile == mobileMode then -- 710
		return true -- 710
	end -- 710
	if mobileMode then -- 711
		if not (feedHost and feedHost.visible) then -- 712
			return false -- 712
		end -- 712
		feedHost:emit("SwitchUIMode") -- 714
		return allEntries.mobileControl.pendingUIMode == false -- 715
	end -- 711
	allEntries.mobileControl.pendingUIMode = true -- 716
	return true -- 717
end -- 705
_module_0["setUIMode"] = setUIMode -- 705
local applyUIMode -- 719
applyUIMode = function(enabled) -- 719
	if HttpServer.wsConnectionCount > 0 then -- 721
		return false -- 721
	end -- 721
	if enabled then -- 722
		local ok, err = pcall(startMobileUI) -- 723
		if not ok then -- 724
			if feedHost then -- 725
				feedHost:removeFromParent(true) -- 725
			end -- 725
			feedHost = nil -- 726
			mobileMode = false -- 727
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 728
			return false -- 729
		end -- 724
	else -- 731
		clearMobileUI() -- 731
		updateEntries() -- 732
	end -- 722
	mobileMode = enabled -- 733
	config.mobileFeed = enabled -- 734
	return true -- 735
end -- 719
local setupEventHandlers = nil -- 737
local enterEntryAsync = nil -- 738
local allClear -- 740
allClear = function() -- 740
	if allEntries.mobileControl.webControlled or HttpServer.wsConnectionCount > 0 then -- 742
		clearMobileUI() -- 742
	end -- 742
	local systemNodes = { } -- 745
	local preserveSystemNode -- 746
	preserveSystemNode = function(node) -- 746
		if systemNodes[node] then -- 747
			return -- 747
		end -- 747
		systemNodes[node] = true -- 748
		do -- 749
			local clip = tolua.cast(node, "ClipNode") -- 749
			if clip then -- 749
				if clip.stencil then -- 750
					preserveSystemNode(clip.stencil) -- 750
				end -- 750
			end -- 749
		end -- 749
		return node:eachChild(function(child) -- 751
			preserveSystemNode(child) -- 752
			return false -- 753
		end) -- 751
	end -- 746
	for _index_0 = 1, #Routine do -- 754
		local routine = Routine[_index_0] -- 754
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 756
			goto _continue_0 -- 757
		else -- 759
			Routine:remove(routine) -- 759
		end -- 755
		::_continue_0:: -- 755
	end -- 754
	for _index_0 = 1, #moduleCache do -- 760
		local module = moduleCache[_index_0] -- 760
		package.loaded[module] = nil -- 761
	end -- 760
	moduleCache = { } -- 762
	Director:cleanup() -- 763
	Entity:clear() -- 764
	Platformer.Data:clear() -- 765
	Platformer.UnitAction:clear() -- 766
	Audio:stopAll(0.2) -- 767
	Struct:clear() -- 768
	View.nearPlaneDistance = 0.1 -- 771
	View.farPlaneDistance = 10000 -- 772
	View.fieldOfView = 45 -- 773
	View.postEffect = nil -- 774
	View.scale = scaleContent and screenScale or 1 -- 775
	Director.clearColor = Color(0xff1a1a1a) -- 776
	teal.clear() -- 777
	yue.clear() -- 778
	preserveSystemNode(Director.systemUI) -- 781
	for _, item in pairs(ubox()) do -- 782
		local node = tolua.cast(item, "Node") -- 783
		if node then -- 783
			if not systemNodes[node] then -- 784
				node:cleanup() -- 784
			end -- 784
		end -- 783
	end -- 782
	collectgarbage() -- 785
	collectgarbage() -- 786
	Wasm:clear() -- 787
	thread(function() -- 788
		sleep() -- 789
		return Cache:removeUnused() -- 790
	end) -- 788
	setupEventHandlers() -- 791
	Content.searchPaths = searchPaths -- 792
	App.idled = true -- 793
end -- 740
_module_0["allClear"] = allClear -- 740
local clearTempFiles -- 795
clearTempFiles = function() -- 795
	local writablePath = Content.writablePath -- 796
	local uploadPath = Path(writablePath, ".upload") -- 797
	if Content:exist(uploadPath) then -- 798
		local _list_0 = Content:getDirs(uploadPath) -- 800
		for _index_0 = 1, #_list_0 do -- 800
			local dir = _list_0[_index_0] -- 800
			if dir ~= "resume" then -- 801
				Content:remove(Path(uploadPath, dir)) -- 801
			end -- 801
		end -- 800
		local _list_1 = Content:getFiles(uploadPath) -- 802
		for _index_0 = 1, #_list_1 do -- 802
			local file = _list_1[_index_0] -- 802
			Content:remove(Path(uploadPath, file)) -- 803
		end -- 802
	end -- 798
	if Content:exist(Path(writablePath, ".download")) then -- 804
		return Content:remove(Path(writablePath, ".download")) -- 804
	end -- 804
end -- 795
local waitForWebStart = true -- 806
thread(function() -- 807
	sleep(2) -- 808
	waitForWebStart = false -- 809
end) -- 807
local reloadDevEntry -- 811
reloadDevEntry = function() -- 811
	return thread(function() -- 811
		waitForWebStart = true -- 812
		doClean() -- 813
		allClear() -- 814
		_G.require = oldRequire -- 815
		Dora.require = oldRequire -- 816
		package.loaded["Script.Dev.Entry"] = nil -- 817
		package.loaded["Script.Dev.WebServer"] = nil -- 818
		return Director.systemScheduler:schedule(function() -- 819
			Routine:clear() -- 820
			oldRequire("Script.Dev.Entry") -- 821
			return true -- 822
		end) -- 819
	end) -- 811
end -- 811
local setWorkspace -- 824
setWorkspace = function(path) -- 824
	clearTempFiles() -- 825
	Content.writablePath = path -- 826
	config.writablePath = Content.writablePath -- 827
	return thread(function() -- 828
		sleep() -- 829
		return reloadDevEntry() -- 830
	end) -- 828
end -- 824
_module_0["setWorkspace"] = setWorkspace -- 824
local quit = false -- 832
local activeSearchId = 0 -- 834
local handleSearchFiles -- 836
handleSearchFiles = function(payload) -- 836
	if not payload then -- 837
		return -- 837
	end -- 837
	local id = payload.id -- 838
	if id == nil then -- 839
		return -- 839
	end -- 839
	activeSearchId = id -- 840
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 841
	if path == nil then -- 842
		path = "" -- 842
	end -- 842
	if exts == nil then -- 843
		exts = { } -- 843
	end -- 843
	if globs == nil then -- 844
		globs = { } -- 844
	end -- 844
	if extensionLevels == nil then -- 845
		extensionLevels = { } -- 845
	end -- 845
	if pattern == nil then -- 846
		pattern = "" -- 846
	end -- 846
	if pattern == "" then -- 848
		return -- 848
	end -- 848
	local useRegex = payload.useRegex == true -- 849
	local caseSensitive = payload.caseSensitive == true -- 850
	local includeContent = payload.includeContent ~= false -- 851
	local contentWindow = payload.contentWindow or 0 -- 852
	return Director.systemScheduler:schedule(once(function() -- 853
		local stopped = false -- 854
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 855
			if activeSearchId ~= id then -- 856
				stopped = true -- 857
				return true -- 858
			end -- 856
			emit("AppWS", "Send", json.encode({ -- 860
				name = "SearchFilesResult", -- 860
				id = id, -- 860
				result = result -- 860
			})) -- 859
			return false -- 862
		end) -- 855
		return emit("AppWS", "Send", json.encode({ -- 864
			name = "SearchFilesDone", -- 864
			id = id, -- 864
			stopped = stopped -- 864
		})) -- 863
	end)) -- 853
end -- 836
local stop -- 867
stop = function() -- 867
	if isInEntry then -- 868
		return false -- 868
	end -- 868
	allClear() -- 869
	isInEntry = true -- 870
	currentEntry = nil -- 871
	return true -- 872
end -- 867
_module_0["stop"] = stop -- 867
local getCurrentEntryStatus -- 874
getCurrentEntryStatus = function() -- 874
	local entry = currentEntry -- 875
	if not (entry and not isInEntry) then -- 876
		return { -- 876
			success = true, -- 876
			running = false, -- 876
			runId = allEntries.runId -- 876
		} -- 876
	end -- 876
	local status = { -- 878
		success = true, -- 878
		running = true, -- 879
		kind = entry.runKind or "file", -- 880
		runId = allEntries.runId, -- 881
		entryName = entry.entryName, -- 882
		fileName = entry.fileName -- 883
	} -- 877
	if entry.workDir then -- 884
		status.workDir = entry.workDir -- 884
	end -- 884
	if entry.projectRoot then -- 885
		status.projectRoot = entry.projectRoot -- 885
	end -- 885
	return status -- 886
end -- 874
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 874
local _anon_func_3 = function(_with_0) -- 910
	local _val_0 = App.platform -- 910
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 910
end -- 910
local _anon_func_4 = function(_with_0) -- 944
	local _val_0 = App.platform -- 944
	return "Windows" == _val_0 or "macOS" == _val_0 or "Android" == _val_0 -- 944
end -- 944
setupEventHandlers = function() -- 888
	local _with_0 = Director.postNode -- 889
	if App.platform == "Windows" then -- 890
		_with_0:gslot("AppURLHandlerState", function(state) -- 891
			allEntries.urlHandlerState = state -- 892
			if state == "missing" then -- 893
				return emit("AppURLHandler", "register") -- 893
			end -- 893
		end) -- 891
		emit("AppURLHandler", "query") -- 894
	end -- 890
	_with_0:onAppEvent(function(eventType) -- 895
		if "Quit" == eventType then -- 896
			quit = true -- 897
			allClear() -- 898
			return clearTempFiles() -- 899
		elseif "Shutdown" == eventType then -- 900
			return stop() -- 901
		end -- 895
	end) -- 895
	_with_0:onAppChange(function(settingName) -- 902
		if "Theme" == settingName then -- 903
			config.themeColor = App.themeColor:toARGB() -- 904
		elseif "Locale" == settingName then -- 905
			config.locale = App.locale -- 906
			updateLocale() -- 907
			return teal.clear(true) -- 908
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 909
			if _anon_func_3(_with_0) then -- 910
				if "FullScreen" == settingName then -- 912
					config.fullScreen = App.fullScreen -- 912
				elseif "Position" == settingName then -- 913
					local _obj_0 = App.winPosition -- 913
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 913
				elseif "Size" == settingName then -- 914
					local width, height -- 915
					do -- 915
						local _obj_0 = App.winSize -- 915
						width, height = _obj_0.width, _obj_0.height -- 915
					end -- 915
					config.winWidth = width -- 916
					config.winHeight = height -- 917
				end -- 911
			end -- 910
		end -- 902
	end) -- 902
	_with_0:onAppWS(function(event) -- 918
		if event.type == "Close" then -- 919
			if HttpServer.wsConnectionCount == 0 then -- 920
				updateEntries() -- 921
			end -- 920
			return -- 922
		end -- 919
		if not (event.type == "Receive") then -- 923
			return -- 923
		end -- 923
		local data = json.decode(event.msg) -- 924
		if not data then -- 925
			return -- 925
		end -- 925
		local _exp_0 = data.name -- 926
		if "SearchFiles" == _exp_0 then -- 927
			return handleSearchFiles(data) -- 928
		elseif "SearchFilesStop" == _exp_0 then -- 929
			if data.id == nil or data.id == activeSearchId then -- 930
				activeSearchId = 0 -- 931
			end -- 930
		end -- 926
	end) -- 918
	_with_0:slot("UpdateEntries", function() -- 932
		return updateEntries() -- 932
	end) -- 932
	_with_0:gslot("RepositoryImport", function(repository) -- 933
		return Director.systemScheduler:schedule(once(function() -- 934
			if not (currentEntry and currentEntry.entryName == "RepositoryImporter") then -- 935
				local importIDE = oldRequire("Dev.ImportIDE") -- 936
				allEntries.importRestoreIDE = importIDE.getNativeState() == "visible" -- 937
			end -- 935
			if mobileMode then -- 940
				clearMobileUI() -- 940
			end -- 940
			allClear() -- 941
			if _anon_func_4(_with_0) and App.webIDEEnabled then -- 944
				emit("AppWebView", "/ide/hide", false) -- 944
			end -- 944
			return enterEntryAsync({ -- 946
				entryName = "RepositoryImporter", -- 946
				fileName = Path(Content.assetPath, "Script", "Tools", "RepositoryImporter"), -- 947
				runKind = "tool", -- 948
				argument = repository -- 949
			}) -- 945
		end)) -- 934
	end) -- 933
	_with_0:gslot("RepositoryImported", function() -- 951
		return updateEntries() -- 951
	end) -- 951
	_with_0:gslot("RepositoryImportDone", function() -- 952
		return Director.systemScheduler:schedule(once(function() -- 953
			stop() -- 954
			if allEntries.importRestoreIDE then -- 955
				allEntries.importRestoreIDE = false -- 956
				return emit("AppWebView", "/ide/show", true) -- 957
			end -- 955
		end)) -- 953
	end) -- 952
	_with_0:gslot("RepositoryImportReveal", function(file) -- 958
		return Director.systemScheduler:schedule(once(function() -- 959
			stop() -- 960
			updateEntries() -- 961
			allEntries.importFocusedFile = Path:replaceExt(file, "") -- 962
			allEntries.importReveal = true -- 963
		end)) -- 959
	end) -- 958
	return _with_0 -- 889
end -- 888
setupEventHandlers() -- 966
clearTempFiles() -- 967
local downloadFile -- 969
downloadFile = function(url, target) -- 969
	return Director.systemScheduler:schedule(once(function() -- 969
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 970
			if quit then -- 971
				return true -- 971
			end -- 971
			emit("AppWS", "Send", json.encode({ -- 973
				name = "Download", -- 973
				url = url, -- 973
				status = "downloading", -- 973
				progress = current / total -- 974
			})) -- 972
			return false -- 970
		end) -- 970
		return emit("AppWS", "Send", json.encode(success and { -- 977
			name = "Download", -- 977
			url = url, -- 977
			status = "completed", -- 977
			progress = 1.0 -- 978
		} or { -- 980
			name = "Download", -- 980
			url = url, -- 980
			status = "failed", -- 980
			progress = 0.0 -- 981
		})) -- 976
	end)) -- 969
end -- 969
_module_0["downloadFile"] = downloadFile -- 969
local _anon_func_5 = function(entry, file, require, workDir) -- 995
	if workDir == nil then -- 995
		workDir = Path:getPath(file) -- 995
	end -- 995
	Content:insertSearchPath(1, workDir) -- 996
	local scriptPath = Path(workDir, "Script") -- 997
	if Content:exist(scriptPath) then -- 998
		Content:insertSearchPath(1, scriptPath) -- 999
	end -- 998
	local result = require(file) -- 1000
	if "function" == type(result) then -- 1001
		result(entry.argument) -- 1001
	end -- 1001
	return nil -- 1002
end -- 995
local _anon_func_6 = function(_with_0, err, fontSize, width) -- 1031
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 1031
	label.alignment = "Left" -- 1032
	label.textWidth = width - fontSize -- 1033
	label.text = err -- 1034
	return label -- 1031
end -- 1031
enterEntryAsync = function(entry) -- 984
	allEntries.runId = allEntries.runId + 1 -- 985
	local launchRunId = allEntries.runId -- 986
	isInEntry = false -- 987
	App.idled = false -- 988
	emit(Profiler.EventName, "ClearLoader") -- 989
	currentEntry = entry -- 990
	local file, workDir = entry.fileName, entry.workDir -- 991
	sleep() -- 992
	if launchRunId ~= allEntries.runId or isInEntry or currentEntry ~= entry then -- 993
		return false, "superseded" -- 993
	end -- 993
	return xpcall(_anon_func_5, function(msg) -- 1002
		local err = debug.traceback(msg) -- 1004
		Log("Error", err) -- 1005
		allClear() -- 1006
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 1007
		local viewWidth, viewHeight -- 1008
		do -- 1008
			local _obj_0 = View.size -- 1008
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 1008
		end -- 1008
		local width, height = viewWidth - 20, viewHeight - 20 -- 1009
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 1010
		Director.ui:addChild((function() -- 1011
			local root = AlignNode() -- 1011
			do -- 1012
				local _obj_0 = App.bufferSize -- 1012
				width, height = _obj_0.width, _obj_0.height -- 1012
			end -- 1012
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1013
			root:onAppChange(function(settingName) -- 1014
				if settingName == "Size" then -- 1014
					do -- 1015
						local _obj_0 = App.bufferSize -- 1015
						width, height = _obj_0.width, _obj_0.height -- 1015
					end -- 1015
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1016
				end -- 1014
			end) -- 1014
			root:addChild((function() -- 1017
				local _with_0 = ScrollArea({ -- 1018
					width = width, -- 1018
					height = height, -- 1019
					paddingX = 0, -- 1020
					paddingY = 50, -- 1021
					viewWidth = height, -- 1022
					viewHeight = height -- 1023
				}) -- 1017
				root:onAlignLayout(function(w, h) -- 1025
					_with_0.position = Vec2(w / 2, h / 2) -- 1026
					w = w - 20 -- 1027
					h = h - 20 -- 1028
					_with_0.view.children.first.textWidth = w - fontSize -- 1029
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 1030
				end) -- 1025
				_with_0.view:addChild(_anon_func_6(_with_0, err, fontSize, width)) -- 1031
				return _with_0 -- 1017
			end)()) -- 1017
			return root -- 1011
		end)()) -- 1011
		return err -- 1035
	end, entry, file, require, workDir) -- 994
end -- 984
_module_0["enterEntryAsync"] = enterEntryAsync -- 984
local enterDemoEntry -- 1037
enterDemoEntry = function(entry) -- 1037
	return thread(function() -- 1037
		return enterEntryAsync(entry) -- 1037
	end) -- 1037
end -- 1037
local reloadCurrentEntry -- 1039
reloadCurrentEntry = function() -- 1039
	if currentEntry then -- 1040
		allClear() -- 1041
		return enterDemoEntry(currentEntry) -- 1042
	end -- 1040
end -- 1039
Director.clearColor = Color(0xff1a1a1a) -- 1044
local descColor = Color(0xffa1a1a1) -- 1045
local extraOperations -- 1048
do -- 1048
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 1049
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 1050
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 1051
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 1052
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1053
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1054
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1055
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1056
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1057
	local ossLicenses = nil -- 1058
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1059
	local failedSetFolder = false -- 1060
	local statusFlags = { -- 1061
		"NoResize", -- 1061
		"NoMove", -- 1061
		"NoCollapse", -- 1061
		"AlwaysAutoResize", -- 1061
		"NoSavedSettings" -- 1061
	} -- 1061
	extraOperations = function() -- 1068
		local zh = useChinese -- 1069
		if isDesktop then -- 1070
			local alwaysOnTop = config.alwaysOnTop -- 1071
			do -- 1072
				local changed -- 1072
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1072
				if changed then -- 1072
					App.alwaysOnTop = alwaysOnTop -- 1073
					config.alwaysOnTop = alwaysOnTop -- 1074
				end -- 1072
			end -- 1072
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1075
			do -- 1076
				local changed -- 1076
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1076
				if changed then -- 1076
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1077
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1078
				end -- 1076
			end -- 1076
			SameLine() -- 1079
			TextColored(descColor, "(?)") -- 1080
			if IsItemHovered() then -- 1081
				BeginTooltip(function() -- 1082
					return PushTextWrapPos(360, function() -- 1083
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1084
					end) -- 1083
				end) -- 1082
			end -- 1081
		end -- 1070
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1099
		do -- 1103
			local changed -- 1103
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1103
			if changed then -- 1103
				config.showPreview = showPreview -- 1104
				updateEntries() -- 1105
				if not showPreview then -- 1106
					thread(function() -- 1107
						collectgarbage() -- 1108
						return Cache:removeUnused("Texture") -- 1109
					end) -- 1107
				end -- 1106
			end -- 1103
		end -- 1103
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1110
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1111
			if changed then -- 1111
				config.webIDEEnabled = webIDEEnabled -- 1112
				App.webIDEEnabled = webIDEEnabled -- 1113
			end -- 1111
		end -- 1110
		do -- 1114
			local themeColor = App.themeColor -- 1115
			local writablePath = config.writablePath -- 1116
			SeparatorText(zh and "工作目录" or "Workspace") -- 1117
			PushTextWrapPos(400, function() -- 1118
				return TextColored(themeColor, writablePath) -- 1119
			end) -- 1118
			if not isDesktop then -- 1120
				goto skipSetting -- 1120
			end -- 1120
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1121
			if Button(zh and "改变目录" or "Set Folder") then -- 1122
				App:openFileDialog(true, function(path) -- 1123
					if path == "" then -- 1124
						return -- 1124
					end -- 1124
					local relPath = Path:getRelative(Content.assetPath, path) -- 1125
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1126
						return setWorkspace(path) -- 1127
					else -- 1129
						failedSetFolder = true -- 1129
					end -- 1126
				end) -- 1123
			end -- 1122
			if failedSetFolder then -- 1130
				failedSetFolder = false -- 1131
				OpenPopup(popupName) -- 1132
			end -- 1130
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1133
			BeginPopupModal(popupName, statusFlags, function() -- 1134
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1135
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1136
					return CloseCurrentPopup() -- 1137
				end -- 1136
			end) -- 1134
			SameLine() -- 1138
			if Button(zh and "使用默认" or "Use Default") then -- 1139
				setWorkspace(Content.appPath) -- 1140
			end -- 1139
			Separator() -- 1141
			::skipSetting:: -- 1142
		end -- 1114
		renderAgentStorage(zh) -- 1143
		if isOSSLicenseExist then -- 1144
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1145
				if not ossLicenses then -- 1146
					local licenseText = Content:load("LICENSES") -- 1147
					if licenseText then -- 1147
						local GSplit -- 1148
						do -- 1148
							local _obj_0 = require("Utils") -- 1148
							GSplit = _obj_0.GSplit -- 1148
						end -- 1148
						ossLicenses = { } -- 1149
						licenseText = licenseText:gsub("\r\n", "\n") -- 1150
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1151
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1152
							if name then -- 1152
								ossLicenses[#ossLicenses + 1] = { -- 1153
									name, -- 1153
									text -- 1153
								} -- 1153
							end -- 1152
						end -- 1151
					end -- 1147
				end -- 1146
				if ossLicenses then -- 1154
					OpenPopup(ossLicensePopup) -- 1154
				end -- 1154
			end -- 1145
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1155
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1156
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1157
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1158
				return BeginPopupModal(ossLicensePopup, true, { -- 1161
					"NoSavedSettings" -- 1161
				}, function() -- 1162
					for _index_0 = 1, #ossLicenses do -- 1163
						local _des_0 = ossLicenses[_index_0] -- 1163
						local firstLine, text = _des_0[1], _des_0[2] -- 1163
						local name, license = firstLine:match("(.+): (.+)") -- 1165
						if name then -- 1165
							TextColored(themeColor, name) -- 1166
							SameLine() -- 1167
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1168
								return TextWrapped(text) -- 1168
							end) -- 1168
						end -- 1165
					end -- 1163
				end) -- 1158
			end) -- 1158
		end -- 1144
		if not App.debugging then -- 1171
			return -- 1171
		end -- 1171
		return TreeNode(zh and "开发操作" or "Development", function() -- 1172
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1173
				OpenPopup("build") -- 1173
			end -- 1173
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1174
				return BeginPopup("build", function() -- 1174
					if Selectable(zh and "编译" or "Compile") then -- 1175
						doCompile(false) -- 1175
					end -- 1175
					Separator() -- 1176
					if Selectable(zh and "压缩" or "Minify") then -- 1177
						doCompile(true) -- 1177
					end -- 1177
					Separator() -- 1178
					if Selectable(zh and "清理" or "Clean") then -- 1179
						return doClean() -- 1179
					end -- 1179
				end) -- 1174
			end) -- 1174
			if isInEntry then -- 1180
				if waitForWebStart then -- 1181
					BeginDisabled(function() -- 1182
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1182
					end) -- 1182
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1183
					reloadDevEntry() -- 1184
				end -- 1181
			end -- 1180
			do -- 1185
				local changed -- 1185
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1185
				if changed then -- 1185
					View.scale = scaleContent and screenScale or 1 -- 1186
				end -- 1185
			end -- 1185
			do -- 1187
				local changed -- 1187
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1187
				if changed then -- 1187
					config.engineDev = engineDev -- 1188
				end -- 1187
			end -- 1187
			do -- 1189
				local changed -- 1189
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1189
				if changed then -- 1189
					config.webIDETourCompleted = webIDETourCompleted -- 1190
				end -- 1189
			end -- 1189
			if testingThread then -- 1191
				return BeginDisabled(function() -- 1192
					return Button(zh and "开始自动测试" or "Test automatically") -- 1192
				end) -- 1192
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1193
				testingThread = thread(function() -- 1194
					local _ <close> = setmetatable({ }, { -- 1195
						__close = function() -- 1195
							allClear() -- 1196
							testingThread = nil -- 1197
							isInEntry = true -- 1198
							currentEntry = nil -- 1199
							return print("Testing done!") -- 1200
						end -- 1195
					}) -- 1195
					for _, entry in ipairs(allEntries) do -- 1201
						allClear() -- 1202
						print("Start " .. tostring(entry.entryName)) -- 1203
						enterDemoEntry(entry) -- 1204
						sleep(2) -- 1205
						print("Stop " .. tostring(entry.entryName)) -- 1206
					end -- 1201
				end) -- 1194
			end -- 1191
		end) -- 1172
	end -- 1068
end -- 1048
local icon = Path(Content.assetPath, "Script", "Dev", "icon_s.png") -- 1208
local iconTex = nil -- 1209
Director.systemScheduler:schedule(once(function() -- 1210
	if Cache:loadAsync(icon) then -- 1210
		iconTex = Texture2D(icon) -- 1210
	end -- 1210
end)) -- 1210
local webStatus = nil -- 1212
local urlClicked = nil -- 1213
local authCode = string.format("%06d", math.random(0, 999999)) -- 1215
local authCodeTTL = 30.0 -- 1217
_module_0.getAuthCode = function() -- 1218
	return authCode -- 1218
end -- 1218
_module_0.invalidateAuthCode = function() -- 1219
	authCode = string.format("%06d", math.random(0, 999999)) -- 1220
	authCodeTTL = 30.0 -- 1221
end -- 1219
local AuthSession -- 1223
do -- 1223
	local pending = nil -- 1224
	local session = nil -- 1225
	AuthSession = { -- 1227
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1227
			pending = { -- 1229
				sessionId = sessionId, -- 1229
				confirmCode = confirmCode, -- 1230
				expiresAt = expiresAt, -- 1231
				ttl = ttl, -- 1232
				approved = false -- 1233
			} -- 1228
		end, -- 1227
		getPending = function() -- 1235
			return pending -- 1235
		end, -- 1235
		approvePending = function(sessionId) -- 1237
			if pending and pending.sessionId == sessionId then -- 1238
				pending.approved = true -- 1239
				return true -- 1240
			end -- 1238
			return false -- 1241
		end, -- 1237
		clearPending = function() -- 1243
			pending = nil -- 1243
		end, -- 1243
		setSession = function(sessionId, sessionSecret) -- 1245
			session = { -- 1247
				sessionId = sessionId, -- 1247
				sessionSecret = sessionSecret -- 1248
			} -- 1246
		end, -- 1245
		getSession = function() -- 1250
			return session -- 1250
		end -- 1250
	} -- 1226
end -- 1223
_module_0["AuthSession"] = AuthSession -- 1223
local transparant = Color(0x0) -- 1253
local windowFlags = { -- 1254
	"NoTitleBar", -- 1254
	"NoResize", -- 1254
	"NoMove", -- 1254
	"NoCollapse", -- 1254
	"NoSavedSettings", -- 1254
	"NoFocusOnAppearing", -- 1254
	"NoBringToFrontOnFocus" -- 1254
} -- 1254
local statusFlags = { -- 1263
	"NoTitleBar", -- 1263
	"NoResize", -- 1263
	"NoMove", -- 1263
	"NoCollapse", -- 1263
	"AlwaysAutoResize", -- 1263
	"NoSavedSettings" -- 1263
} -- 1263
local displayWindowFlags = { -- 1271
	"NoDecoration", -- 1271
	"NoSavedSettings", -- 1271
	"NoMove", -- 1271
	"NoScrollWithMouse", -- 1271
	"AlwaysAutoResize", -- 1271
	"NoFocusOnAppearing" -- 1271
} -- 1271
local _anon_func_7 = function(allEntries, currentIndex) -- 1344
	if currentIndex > 1 then -- 1344
		return allEntries[currentIndex - 1] -- 1345
	else -- 1347
		return allEntries[#allEntries] -- 1347
	end -- 1344
end -- 1344
local _anon_func_8 = function(allEntries, currentIndex) -- 1351
	if currentIndex < #allEntries then -- 1351
		return allEntries[currentIndex + 1] -- 1352
	else -- 1354
		return allEntries[1] -- 1354
	end -- 1351
end -- 1351
local _anon_func_9 = function(allEntries) -- 1394
	local _val_0 = allEntries.urlHandlerState -- 1394
	return "other" == _val_0 or "error" == _val_0 -- 1394
end -- 1394
do -- 1280
	local gamepadInputWindowFlags = { -- 1281
		"NoDecoration", -- 1281
		"NoSavedSettings", -- 1281
		"NoMove", -- 1281
		"NoScrollbar", -- 1281
		"NoScrollWithMouse", -- 1281
		"NoFocusOnAppearing", -- 1281
		"NoBringToFrontOnFocus" -- 1281
	} -- 1281
	local initFooter = true -- 1290
	local gamepadInputFocused = false -- 1291
	footerWindow = threadLoop(function() -- 1292
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1293
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1294
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1295
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1296
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1297
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1298
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1299
		if mobileMode then -- 1300
			return -- 1300
		end -- 1300
		local zh = useChinese -- 1301
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1302
		if authCodeTTL <= 0 then -- 1303
			authCodeTTL = 30.0 -- 1304
			authCode = string.format("%06d", math.random(0, 999999)) -- 1305
		end -- 1303
		if HttpServer.wsConnectionCount > 0 then -- 1306
			return -- 1307
		end -- 1306
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1308
			if App.platform == "Emscripten" then -- 1309
				stop() -- 1311
			else -- 1313
				allClear() -- 1313
				App.devMode = false -- 1314
				App:shutdown() -- 1315
			end -- 1309
		end -- 1308
		do -- 1316
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1317
			if ctrl and Keyboard:isKeyDown("Q") then -- 1318
				stop() -- 1319
			end -- 1318
			if ctrl and Keyboard:isKeyDown("Z") then -- 1320
				reloadCurrentEntry() -- 1321
			end -- 1320
			if ctrl and Keyboard:isKeyDown(",") then -- 1322
				if showFooter then -- 1323
					showStats = not showStats -- 1323
				else -- 1323
					showStats = true -- 1323
				end -- 1323
				showFooter = true -- 1324
				config.showFooter = showFooter -- 1325
				config.showStats = showStats -- 1326
			end -- 1322
			if ctrl and Keyboard:isKeyDown(".") then -- 1327
				if showFooter then -- 1328
					showConsole = not showConsole -- 1328
				else -- 1328
					showConsole = true -- 1328
				end -- 1328
				showFooter = true -- 1329
				config.showFooter = showFooter -- 1330
				config.showConsole = showConsole -- 1331
			end -- 1327
			if ctrl and Keyboard:isKeyDown("/") then -- 1332
				showFooter = not showFooter -- 1333
				config.showFooter = showFooter -- 1334
			end -- 1332
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1335
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1336
			local currentIndex = nil -- 1337
			for i, entry in ipairs(allEntries) do -- 1338
				if currentEntry == entry then -- 1339
					currentIndex = i -- 1340
				end -- 1339
			end -- 1338
			if left then -- 1341
				allClear() -- 1342
				if currentIndex == nil then -- 1343
					currentIndex = #allEntries + 1 -- 1343
				end -- 1343
				enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 1344
			end -- 1341
			if right then -- 1348
				allClear() -- 1349
				if currentIndex == nil then -- 1350
					currentIndex = 0 -- 1350
				end -- 1350
				enterDemoEntry(_anon_func_8(allEntries, currentIndex)) -- 1351
			end -- 1348
		end -- 1316
		if not showEntry then -- 1355
			return -- 1355
		end -- 1355
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1357
			reloadDevEntry() -- 1361
		end -- 1357
		if initFooter then -- 1362
			initFooter = false -- 1363
		end -- 1362
		local width, height -- 1365
		do -- 1365
			local _obj_0 = App.visualSize -- 1365
			width, height = _obj_0.width, _obj_0.height -- 1365
		end -- 1365
		if isInEntry then -- 1366
			gamepadInputFocused = false -- 1367
		else -- 1369
			SetNextWindowBgAlpha(0.0) -- 1369
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1370
			SetNextWindowPos(Vec2.zero, "Always") -- 1371
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1372
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1373
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1374
						if not gamepadInputFocused then -- 1375
							SetWindowFocus("DoraGamepadInput") -- 1376
							gamepadInputFocused = true -- 1377
						end -- 1375
					end) -- 1374
				end) -- 1373
			end) -- 1372
		end -- 1366
		if isInEntry or showFooter then -- 1379
			SetNextWindowSize(Vec2(width, 50)) -- 1380
			SetNextWindowPos(Vec2(0, height - 50)) -- 1381
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1382
				return PushStyleVar("WindowRounding", 0, function() -- 1383
					return Begin("Footer", windowFlags, function() -- 1384
						Separator() -- 1385
						if iconTex then -- 1386
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1387
								showStats = not showStats -- 1388
								config.showStats = showStats -- 1389
							end -- 1387
							SameLine() -- 1390
						end -- 1386
						if Button(">_", Vec2(30, 30)) then -- 1391
							showConsole = not showConsole -- 1392
							config.showConsole = showConsole -- 1393
						end -- 1391
						if App.platform == "Windows" and _anon_func_9(allEntries) then -- 1394
							SameLine() -- 1395
							if Button(zh and "注册浏览器链接" or "Register browser links") then -- 1396
								emit("AppURLHandler", "register") -- 1397
							end -- 1396
						end -- 1394
						if isInEntry and updateState.available then -- 1398
							SameLine() -- 1399
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1400
								allClear() -- 1401
								enterDemoEntry({ -- 1403
									entryName = "SelfUpdater", -- 1403
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1404
								}) -- 1402
							end -- 1400
						end -- 1398
						if not isInEntry then -- 1405
							SameLine() -- 1406
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1407
							local currentIndex = nil -- 1408
							for i, entry in ipairs(allEntries) do -- 1409
								if currentEntry == entry then -- 1410
									currentIndex = i -- 1411
								end -- 1410
							end -- 1409
							if currentIndex then -- 1412
								if currentIndex > 1 then -- 1413
									SameLine() -- 1414
									if Button("<<", Vec2(30, 30)) then -- 1415
										allClear() -- 1416
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1417
									end -- 1415
								end -- 1413
								if currentIndex < #allEntries then -- 1418
									SameLine() -- 1419
									if Button(">>", Vec2(30, 30)) then -- 1420
										allClear() -- 1421
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1422
									end -- 1420
								end -- 1418
							end -- 1412
							SameLine() -- 1423
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1424
								reloadCurrentEntry() -- 1425
							end -- 1424
							if back then -- 1426
								allClear() -- 1427
								isInEntry = true -- 1428
								currentEntry = nil -- 1429
							end -- 1426
						end -- 1405
					end) -- 1384
				end) -- 1383
			end) -- 1382
		end -- 1379
		if isInEntry then -- 1431
			local showURL = true -- 1432
			local webIDEWidth -- 1433
			do -- 1433
				local base -- 1434
				if updateState.available then -- 1434
					base = 460 -- 1434
				else -- 1434
					base = 360 -- 1434
				end -- 1434
				local extra = 35 -- 1435
				webIDEWidth = base + extra -- 1436
			end -- 1433
			if width < webIDEWidth then -- 1437
				showURL = false -- 1437
			end -- 1437
			SetNextWindowBgAlpha(0.0) -- 1438
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1439
			Begin("Web IDE", displayWindowFlags, function() -- 1440
				local pending = AuthSession.getPending() -- 1441
				local hovered = false -- 1442
				if not pending and showURL then -- 1443
					do -- 1444
						local url -- 1444
						if webStatus ~= nil then -- 1444
							url = webStatus.url -- 1444
						end -- 1444
						if url then -- 1444
							if isDesktop and not config.fullScreen then -- 1445
								if urlClicked then -- 1446
									BeginDisabled(function() -- 1447
										return Button(url) -- 1447
									end) -- 1447
								elseif Button(url) then -- 1448
									urlClicked = once(function() -- 1449
										return sleep(5) -- 1449
									end) -- 1449
									App:openURL("http://localhost:8866") -- 1450
								end -- 1446
							else -- 1452
								TextColored(descColor, url) -- 1452
							end -- 1445
						else -- 1454
							TextColored(descColor, zh and '不可用' or 'not available') -- 1454
						end -- 1444
					end -- 1444
					hovered = IsItemHovered() -- 1455
				else -- 1457
					TextColored(descColor, "(?)") -- 1457
					hovered = IsItemHovered() -- 1458
				end -- 1443
				SameLine() -- 1459
				local themeColor = App.themeColor -- 1460
				if pending then -- 1461
					if not pending.approved then -- 1462
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1463
						local ttl = pending.ttl or 1 -- 1464
						PushStyleColor("Text", themeColor, function() -- 1465
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1466
							hovered = hovered or IsItemHovered() -- 1467
						end) -- 1465
						SameLine() -- 1468
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1469
							AuthSession.approvePending(pending.sessionId) -- 1470
						end -- 1469
						if hovered then -- 1471
							return BeginTooltip(function() -- 1472
								return PushTextWrapPos(280, function() -- 1473
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1474
								end) -- 1473
							end) -- 1472
						end -- 1471
					end -- 1462
				else -- 1476
					PushStyleColor("Text", themeColor, function() -- 1476
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1477
						hovered = hovered or IsItemHovered() -- 1478
					end) -- 1476
					if hovered then -- 1479
						return BeginTooltip(function() -- 1480
							return PushTextWrapPos(280, function() -- 1481
								local url -- 1482
								if webStatus ~= nil then -- 1482
									url = webStatus.url -- 1482
								end -- 1482
								if url then -- 1482
									local address -- 1483
									if showURL then -- 1483
										address = "Web IDE" -- 1483
									else -- 1483
										address = url -- 1483
									end -- 1483
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1484
								else -- 1486
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1486
								end -- 1482
							end) -- 1481
						end) -- 1480
					end -- 1479
				end -- 1461
			end) -- 1440
		end -- 1431
		if not isInEntry then -- 1487
			SetNextWindowSize(Vec2(50, 50)) -- 1488
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1489
			PushStyleColor("WindowBg", transparant, function() -- 1490
				return Begin("Show", displayWindowFlags, function() -- 1490
					if width >= 370 then -- 1491
						local changed -- 1492
						changed, showFooter = Checkbox("##dev", showFooter) -- 1492
						if changed then -- 1492
							config.showFooter = showFooter -- 1493
						end -- 1492
					end -- 1491
				end) -- 1490
			end) -- 1490
		end -- 1487
		if isInEntry or showFooter then -- 1495
			if showStats then -- 1496
				PushStyleVar("WindowRounding", 0, function() -- 1497
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1498
					SetNextWindowSize(Vec2(0, height - 50)) -- 1499
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1500
					config.showStats = showStats -- 1501
				end) -- 1497
			end -- 1496
			if showConsole then -- 1502
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1503
				return PushStyleVar("WindowRounding", 6, function() -- 1504
					return ShowConsole() -- 1505
				end) -- 1504
			end -- 1502
		end -- 1495
	end) -- 1292
end -- 1280
do -- 1508
	local MaxWidth <const> = 960 -- 1509
	local toolOpen = false -- 1511
	local filterText = nil -- 1512
	allEntries.anyEntryMatched = false -- 1513
	allEntries.match = function(name) -- 1514
		local res = not filterText or name:lower():match(filterText) -- 1515
		if res then -- 1516
			allEntries.anyEntryMatched = true -- 1516
		end -- 1516
		return res -- 1517
	end -- 1514
	allEntries.thinSep = function() -- 1519
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1519
			return ImGui.SeparatorText("") -- 1519
		end) -- 1519
	end -- 1519
	entryWindow = threadLoop(function() -- 1520
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1521
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1522
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1523
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1524
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1525
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1526
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1527
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1528
		local connected = syncWebIDEControl() -- 1529
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1531
			if not allEntries.pendingPackagePath then -- 1532
				local path = App:takeReceivedFile() -- 1533
				if path ~= "" then -- 1534
					allEntries.pendingPackagePath = path -- 1534
				end -- 1534
			end -- 1532
			if allEntries.pendingPackagePath then -- 1535
				allEntries.mobileControl.pendingUIMode = true -- 1535
			end -- 1535
		end -- 1531
		if (allEntries.mobileControl.pendingUIMode ~= nil) then -- 1537
			local nextMode = allEntries.mobileControl.pendingUIMode -- 1538
			allEntries.mobileControl.pendingUIMode = nil -- 1539
			applyUIMode(nextMode) -- 1540
		end -- 1537
		if mobileMode and not connected then -- 1541
			if allEntries.importReveal and feedHost and feedHost.visible then -- 1542
				local _list_0 = getMobileFeedEntries() -- 1543
				for _index_0 = 1, #_list_0 do -- 1543
					local entry = _list_0[_index_0] -- 1543
					if entry.fileName == allEntries.importFocusedFile then -- 1544
						feedHost:emit("RestoreFeedEntry", entry) -- 1545
						allEntries.importReveal = false -- 1546
						break -- 1547
					end -- 1544
				end -- 1543
			end -- 1542
			if isInEntry and not feedHost then -- 1548
				applyUIMode(true) -- 1548
			end -- 1548
			return -- 1549
		end -- 1541
		if App.fpsLimited ~= config.fpsLimited then -- 1550
			config.fpsLimited = App.fpsLimited -- 1551
		end -- 1550
		if App.targetFPS ~= config.targetFPS then -- 1552
			config.targetFPS = App.targetFPS -- 1553
		end -- 1552
		if View.vsync ~= config.vsync then -- 1554
			config.vsync = View.vsync -- 1555
		end -- 1554
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1556
			config.fixedFPS = Director.scheduler.fixedFPS -- 1557
		end -- 1556
		if Director.profilerSending ~= config.webProfiler then -- 1558
			config.webProfiler = Director.profilerSending -- 1559
		end -- 1558
		if urlClicked then -- 1560
			local _, result = coroutine.resume(urlClicked) -- 1561
			if result then -- 1562
				coroutine.close(urlClicked) -- 1563
				urlClicked = nil -- 1564
			end -- 1562
		end -- 1560
		if not isInEntry then -- 1565
			return -- 1565
		end -- 1565
		local zh = useChinese -- 1566
		local themeColor = App.themeColor -- 1567
		if connected then -- 1568
			local width, height -- 1569
			do -- 1569
				local _obj_0 = App.visualSize -- 1569
				width, height = _obj_0.width, _obj_0.height -- 1569
			end -- 1569
			SetNextWindowBgAlpha(0.5) -- 1570
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1571
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1572
				Separator() -- 1573
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1574
				if iconTex then -- 1575
					Image(icon, Vec2(24, 24)) -- 1576
					SameLine() -- 1577
				end -- 1575
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1578
				TextColored(descColor, slogon) -- 1579
				return Separator() -- 1580
			end) -- 1572
			return -- 1581
		end -- 1568
		if not showEntry then -- 1582
			return -- 1582
		end -- 1582
		local fullWidth, height -- 1584
		do -- 1584
			local _obj_0 = App.visualSize -- 1584
			fullWidth, height = _obj_0.width, _obj_0.height -- 1584
		end -- 1584
		local width = math.min(MaxWidth, fullWidth) -- 1585
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1586
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1587
		SetNextWindowPos(Vec2.zero) -- 1588
		SetNextWindowBgAlpha(0) -- 1589
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1590
		do -- 1591
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1592
				return Begin("Dora Dev", windowFlags, function() -- 1593
					Dummy(Vec2(fullWidth - 20, 0)) -- 1594
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1595
					SameLine() -- 1596
					if Button(zh and "Go 模式" or "Go Mode") then -- 1597
						setUIMode("mobile") -- 1598
					end -- 1597
					if fullWidth >= 540 then -- 1599
						SameLine() -- 1600
						Dummy(Vec2(fullWidth - 540, 0)) -- 1601
						SameLine() -- 1602
						SetNextItemWidth(zh and -95 or -140) -- 1603
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1604
							"AutoSelectAll" -- 1604
						}) then -- 1604
							config.filter = filterBuf.text -- 1605
							allEntries.importFocusedFile = nil -- 1606
							allEntries.importReveal = false -- 1607
						end -- 1604
						SameLine() -- 1608
						if Button(zh and '下载' or 'Download') then -- 1609
							ImGui.OpenPopup("project-download") -- 1609
						end -- 1609
						ImGui.BeginPopup("project-download", function() -- 1610
							if ImGui.Selectable(zh and "从 Git 仓库导入…" or "Import Git repository…") then -- 1611
								emit("RepositoryImport", nil) -- 1612
							end -- 1611
							if ImGui.Selectable(zh and "浏览资源目录…" or "Browse resource catalog…") then -- 1613
								allClear() -- 1614
								return enterDemoEntry({ -- 1616
									entryName = "ResourceDownloader", -- 1616
									fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1617
								}) -- 1615
							end -- 1613
						end) -- 1610
					end -- 1599
					return Separator() -- 1618
				end) -- 1593
			end) -- 1592
		end -- 1591
		allEntries.anyEntryMatched = false -- 1620
		SetNextWindowPos(Vec2(0, 50)) -- 1621
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1622
		local scrollbarSize <const> = 25 -- 1624
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1625
		do -- 1626
			return PushStyleColor("WindowBg", transparant, function() -- 1627
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1628
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1629
						return PushStyleVar("Alpha", 1, function() -- 1630
							return Begin("Content", windowFlags, function() -- 1631
								local DemoViewWidth <const> = 220 -- 1632
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1633
								if filterText then -- 1634
									filterText = filterText:lower() -- 1634
								end -- 1634
								if App.platform == "Emscripten" then -- 1635
									Dora.globals.webProjects.draw(zh, themeColor) -- 1636
									allEntries.anyEntryMatched = true -- 1637
								end -- 1635
								if #gamesInDev > 0 then -- 1638
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1639
									Columns(columns, false) -- 1640
									local realViewWidth = GetColumnWidth() - 50 -- 1641
									for _index_0 = 1, #gamesInDev do -- 1642
										local game = gamesInDev[_index_0] -- 1642
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1643
										local displayName -- 1652
										if repo then -- 1652
											if zh then -- 1653
												displayName = repo.title.zh -- 1653
											else -- 1653
												displayName = repo.title.en -- 1653
											end -- 1653
										end -- 1652
										if displayName == nil then -- 1654
											displayName = gameName -- 1654
										end -- 1654
										if allEntries.match(displayName) or allEntries.importFocusedFile == fileName then -- 1655
											allEntries.anyEntryMatched = true -- 1656
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1657
											SameLine() -- 1658
											if allEntries.importFocusedFile == fileName then -- 1659
												PushStyleColor("Text", themeColor, function() -- 1660
													return TextWrapped(displayName) -- 1660
												end) -- 1660
											else -- 1662
												TextWrapped(displayName) -- 1662
											end -- 1659
											if allEntries.importFocusedFile == fileName and allEntries.importReveal then -- 1663
												ImGui.SetScrollHereY(0.5) -- 1664
												allEntries.importReveal = false -- 1665
											end -- 1663
											if columns > 1 then -- 1666
												if bannerFile and bannerTex then -- 1667
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1668
													local displayWidth <const> = realViewWidth -- 1669
													texHeight = displayWidth * texHeight / texWidth -- 1670
													texWidth = displayWidth -- 1671
													Dummy(Vec2.zero) -- 1672
													SameLine() -- 1673
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1674
												end -- 1667
												if game.needsBuild then -- 1675
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1676
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1677
													enterDemoEntry(game) -- 1678
												end -- 1675
											else -- 1680
												if bannerFile and bannerTex then -- 1680
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1681
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1682
													local sizing = 0.8 -- 1683
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1684
													texWidth = displayWidth * sizing -- 1685
													if texWidth > 500 then -- 1686
														sizing = 0.6 -- 1687
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1688
														texWidth = displayWidth * sizing -- 1689
													end -- 1686
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1690
													Dummy(Vec2(padding, 0)) -- 1691
													SameLine() -- 1692
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1693
												end -- 1680
												if game.needsBuild then -- 1694
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1695
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1696
													enterDemoEntry(game) -- 1697
												end -- 1694
											end -- 1666
											if #tests == 0 and #examples == 0 then -- 1698
												allEntries.thinSep() -- 1699
											end -- 1698
											NextColumn() -- 1700
										end -- 1655
										local showSep = false -- 1701
										if #examples > 0 then -- 1702
											local showExample = false -- 1703
											for _index_1 = 1, #examples do -- 1704
												local _des_0 = examples[_index_1] -- 1704
												local entryName = _des_0.entryName -- 1704
												if allEntries.match(entryName) then -- 1705
													showExample = true -- 1705
													break -- 1705
												end -- 1705
											end -- 1704
											if showExample then -- 1706
												showSep = true -- 1707
												Columns(1, false) -- 1708
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1709
												SameLine() -- 1710
												local opened -- 1711
												if (filterText ~= nil) then -- 1711
													opened = showExample -- 1711
												else -- 1711
													opened = false -- 1711
												end -- 1711
												if game.exampleOpen == nil then -- 1712
													game.exampleOpen = opened -- 1712
												end -- 1712
												SetNextItemOpen(game.exampleOpen) -- 1713
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1714
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1715
														Columns(maxColumns, false) -- 1716
														for _index_1 = 1, #examples do -- 1717
															local example = examples[_index_1] -- 1717
															local entryName = example.entryName -- 1718
															if not allEntries.match(entryName) then -- 1719
																goto _continue_0 -- 1719
															end -- 1719
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1720
																if Button(entryName, Vec2(-1, 40)) then -- 1721
																	enterDemoEntry(example) -- 1722
																end -- 1721
																return NextColumn() -- 1723
															end) -- 1720
															opened = true -- 1724
															::_continue_0:: -- 1718
														end -- 1717
													end) -- 1715
												end) -- 1714
												game.exampleOpen = opened -- 1725
											end -- 1706
										end -- 1702
										if #tests > 0 then -- 1726
											local showTest = false -- 1727
											for _index_1 = 1, #tests do -- 1728
												local _des_0 = tests[_index_1] -- 1728
												local entryName = _des_0.entryName -- 1728
												if allEntries.match(entryName) then -- 1729
													showTest = true -- 1729
													break -- 1729
												end -- 1729
											end -- 1728
											if showTest then -- 1730
												showSep = true -- 1731
												Columns(1, false) -- 1732
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1733
												SameLine() -- 1734
												local opened -- 1735
												if (filterText ~= nil) then -- 1735
													opened = showTest -- 1735
												else -- 1735
													opened = false -- 1735
												end -- 1735
												if game.testOpen == nil then -- 1736
													game.testOpen = opened -- 1736
												end -- 1736
												SetNextItemOpen(game.testOpen) -- 1737
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1738
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1739
														Columns(maxColumns, false) -- 1740
														for _index_1 = 1, #tests do -- 1741
															local test = tests[_index_1] -- 1741
															local entryName = test.entryName -- 1742
															if not allEntries.match(entryName) then -- 1743
																goto _continue_0 -- 1743
															end -- 1743
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1744
																if Button(entryName, Vec2(-1, 40)) then -- 1745
																	enterDemoEntry(test) -- 1746
																end -- 1745
																return NextColumn() -- 1747
															end) -- 1744
															opened = true -- 1748
															::_continue_0:: -- 1742
														end -- 1741
													end) -- 1739
												end) -- 1738
												game.testOpen = opened -- 1749
											end -- 1730
										end -- 1726
										if showSep then -- 1750
											Columns(1, false) -- 1751
											allEntries.thinSep() -- 1752
											Columns(columns, false) -- 1753
										end -- 1750
									end -- 1642
								end -- 1638
								if #doraTools > 0 then -- 1754
									local showTool = false -- 1755
									for _index_0 = 1, #doraTools do -- 1756
										local _des_0 = doraTools[_index_0] -- 1756
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1756
										local displayName -- 1757
										if repo then -- 1757
											if zh then -- 1758
												displayName = repo.title.zh -- 1758
											else -- 1758
												displayName = repo.title.en -- 1758
											end -- 1758
										end -- 1757
										if displayName == nil then -- 1759
											displayName = entryName -- 1759
										end -- 1759
										if allEntries.match(displayName) then -- 1760
											showTool = true -- 1760
											break -- 1760
										end -- 1760
									end -- 1756
									if not showTool then -- 1761
										goto endEntry -- 1761
									end -- 1761
									Columns(1, false) -- 1762
									TextColored(themeColor, "Dora SSR:") -- 1763
									SameLine() -- 1764
									Text(zh and "开发支持" or "Development Support") -- 1765
									Separator() -- 1766
									if #doraTools > 0 then -- 1767
										local opened -- 1768
										if (filterText ~= nil) then -- 1768
											opened = showTool -- 1768
										else -- 1768
											opened = false -- 1768
										end -- 1768
										SetNextItemOpen(toolOpen) -- 1769
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1770
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1771
												Columns(maxColumns, false) -- 1772
												for _index_0 = 1, #doraTools do -- 1773
													local tool = doraTools[_index_0] -- 1773
													local entryName, repo = tool.entryName, tool.repo -- 1774
													local displayName -- 1775
													if repo then -- 1775
														if zh then -- 1776
															displayName = repo.title.zh -- 1776
														else -- 1776
															displayName = repo.title.en -- 1776
														end -- 1776
													end -- 1775
													if displayName == nil then -- 1777
														displayName = entryName -- 1777
													end -- 1777
													if not allEntries.match(displayName) then -- 1778
														goto _continue_0 -- 1778
													end -- 1778
													if Button(displayName, Vec2(-1, 40)) then -- 1779
														enterDemoEntry(tool) -- 1780
													end -- 1779
													NextColumn() -- 1781
													::_continue_0:: -- 1774
												end -- 1773
												Columns(1, false) -- 1782
												opened = true -- 1783
											end) -- 1771
										end) -- 1770
										toolOpen = opened -- 1784
									end -- 1767
								end -- 1754
								::endEntry:: -- 1785
								if not allEntries.anyEntryMatched then -- 1786
									SetNextWindowBgAlpha(0) -- 1787
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1788
									Begin("Entries Not Found", displayWindowFlags, function() -- 1789
										Separator() -- 1790
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1791
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1792
										return Separator() -- 1793
									end) -- 1789
								end -- 1786
								Columns(1, false) -- 1794
								Dummy(Vec2(100, 80)) -- 1795
								return ScrollWhenDraggingOnVoid() -- 1796
							end) -- 1631
						end) -- 1630
					end) -- 1629
				end) -- 1628
			end) -- 1627
		end -- 1626
	end) -- 1520
end -- 1508
if not (App.platform == "Emscripten") then -- 1801
	local sceneModuleCache = moduleCache -- 1802
	moduleCache = { } -- 1803
	webStatus = oldRequire("Script.Dev.WebServer") -- 1804
	moduleCache = sceneModuleCache -- 1805
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1806
		thread(function() -- 1807
			wait(function() -- 1808
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1808
			end) -- 1808
			if App.webIDEEnabled then -- 1809
				return emit("AppWebView", "/ide/show", true) -- 1809
			end -- 1809
		end) -- 1807
	end -- 1806
end -- 1801
local _anon_func_10 = function(saved) -- 1832
	local _val_0 = saved.kind -- 1832
	return "local" == _val_0 or "discover" == _val_0 -- 1832
end -- 1832
local _anon_func_11 = function(saved) -- 1836
	local _val_0 = saved.activeTab -- 1836
	return "local" == _val_0 or "discover" == _val_0 -- 1836
end -- 1836
startMobileUI = function() -- 1811
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1812
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1813
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1814
	local getMobileFeedResources -- 1815
	do -- 1815
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1815
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1815
	end -- 1815
	local loadCachedCatalog -- 1816
	do -- 1816
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1816
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1816
	end -- 1816
	local getResourceInstallPath, getInstalledCatalogResource -- 1817
	do -- 1817
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1817
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1817
	end -- 1817
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1818
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1819
	local feedOptions = nil -- 1820
	local mobileLaunchErrors = { } -- 1821
	local withMobileLaunchErrors -- 1822
	withMobileLaunchErrors = function(items) -- 1822
		for _index_0 = 1, #items do -- 1823
			local item = items[_index_0] -- 1823
			item.launchError = mobileLaunchErrors[item.id] -- 1824
		end -- 1823
		return items -- 1825
	end -- 1822
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1826
	local loadRememberedMobileFeedState -- 1827
	loadRememberedMobileFeedState = function() -- 1827
		local raw = rememberedMobileFeedData -- 1828
		if not (type(raw) == "string" and raw ~= "") then -- 1829
			return -- 1829
		end -- 1829
		local ok, saved = pcall(json.decode, raw) -- 1830
		if not (ok and type(saved) == "table") then -- 1831
			return -- 1831
		end -- 1831
		if type(saved.id) == "string" and _anon_func_10(saved) then -- 1832
			local state = { -- 1833
				activeTab = saved.kind -- 1833
			} -- 1833
			state[saved.kind] = saved -- 1834
			return state -- 1835
		end -- 1832
		local state = { -- 1836
			activeTab = _anon_func_11(saved) and saved.activeTab or "local" -- 1836
		} -- 1836
		local _list_0 = { -- 1837
			"local", -- 1837
			"discover" -- 1837
		} -- 1837
		for _index_0 = 1, #_list_0 do -- 1837
			local kind = _list_0[_index_0] -- 1837
			local entry = saved[kind] -- 1838
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1839
				state[kind] = entry -- 1839
			end -- 1839
		end -- 1837
		return state -- 1840
	end -- 1827
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1841
		activeTab = "local" -- 1841
	} -- 1841
	local rememberMobileFeedEntry -- 1842
	rememberMobileFeedEntry = function(entry) -- 1842
		rememberedMobileFeedState.activeTab = entry.kind -- 1843
		rememberedMobileFeedState[entry.kind] = { -- 1845
			id = entry.id, -- 1845
			kind = entry.kind, -- 1846
			workDir = entry.workDir, -- 1847
			fileName = entry.fileName -- 1848
		} -- 1844
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1850
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1851
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1852
			rememberedMobileFeedData -- 1852
		}) -- 1852
	end -- 1842
	local restartMobileFeed -- 1853
	restartMobileFeed = function(entry) -- 1853
		if feedHost then -- 1854
			feedHost:removeFromParent(true) -- 1854
		end -- 1854
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1855
		local initialEntries = { } -- 1856
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1857
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1858
		feedOptions.initialEntries = initialEntries -- 1859
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1860
	end -- 1853
	local startMobilePlay -- 1861
	startMobilePlay = function(entry) -- 1861
		if HttpServer.wsConnectionCount > 0 then -- 1862
			return -- 1862
		end -- 1862
		if entry.needsBuild then -- 1863
			mobileLaunchErrors[entry.id] = useChinese and "请先在 IDE 中编译项目" or "Build the project in the IDE first" -- 1864
			restartMobileFeed(entry) -- 1865
			return -- 1866
		end -- 1863
		local originFeed = feedHost -- 1867
		if remixHost then -- 1868
			remixHost:removeFromParent(true) -- 1868
		end -- 1868
		remixHost = nil -- 1869
		mobileLaunchErrors[entry.id] = nil -- 1870
		entry.launchError = nil -- 1871
		local playActive = true -- 1872
		local playHost = nil -- 1873
		local restoreMobileFeed -- 1874
		restoreMobileFeed = function() -- 1874
			if not playActive then -- 1875
				return -- 1875
			end -- 1875
			playActive = false -- 1876
			if playHost and playHost.parent then -- 1878
				playHost:removeFromParent(true) -- 1878
			end -- 1878
			playHost = nil -- 1879
			allClear() -- 1880
			isInEntry = true -- 1881
			currentEntry = nil -- 1882
			return restartMobileFeed(entry) -- 1883
		end -- 1874
		playHost = trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1885
			onExit = function() -- 1885
				return restoreMobileFeed() -- 1885
			end, -- 1885
			onRuntimeError = function() -- 1886
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1887
				return restoreMobileFeed() -- 1888
			end -- 1886
		})) -- 1884
		return thread(function() -- 1890
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1894
			if not playActive then -- 1895
				return -- 1895
			end -- 1895
			if success then -- 1896
				if originFeed and originFeed.parent then -- 1897
					originFeed.visible = false -- 1897
				end -- 1897
				return -- 1898
			end -- 1896
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1899
			return restoreMobileFeed() -- 1900
		end) -- 1890
	end -- 1861
	feedOptions = { -- 1902
		takeReceivedFile = function() -- 1902
			if allEntries.pendingPackagePath then -- 1903
				local path = allEntries.pendingPackagePath -- 1904
				allEntries.pendingPackagePath = nil -- 1905
				return path -- 1906
			end -- 1903
			return App:takeReceivedFile() -- 1907
		end, -- 1902
		onSwitchMode = function() -- 1908
			if HttpServer.wsConnectionCount == 0 then -- 1908
				allEntries.mobileControl.pendingUIMode = false -- 1908
			end -- 1908
		end, -- 1908
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1909
		getLocalEntries = function(importedProjectPath) -- 1910
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1911
			feedOptions.dirtyProjectPath = nil -- 1912
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1913
			local cached = loadCachedCatalog() -- 1914
			if cached.success and cached.snapshot then -- 1915
				for _index_0 = 1, #items do -- 1916
					local entry = items[_index_0] -- 1916
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1917
					if resource then -- 1918
						entry.resource = resource -- 1919
						entry.catalogCommit = cached.snapshot.commit -- 1920
					end -- 1918
				end -- 1916
			end -- 1915
			return items -- 1921
		end, -- 1910
		syncDiscover = function(onProgress, onDone, force) -- 1922
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1922
		end, -- 1922
		getDiscoverEntries = function() -- 1923
			local cached = loadCachedCatalog() -- 1924
			if not (cached.success and cached.snapshot) then -- 1925
				return { } -- 1925
			end -- 1925
			local items = { } -- 1926
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1927
			for _index_0 = 1, #_list_0 do -- 1927
				local resource = _list_0[_index_0] -- 1927
				local installed = lifecycle.isMobileResourceReady(resource) -- 1928
				local installPath = getResourceInstallPath(resource.id) -- 1929
				items[#items + 1] = { -- 1931
					id = resource.id, -- 1931
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1932
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1933
					kind = "discover", -- 1934
					bannerFile = resource.bannerPath, -- 1935
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1936
					sourceUrl = resource.versions[1].sources[1].url, -- 1937
					workDir = installed and installPath or nil, -- 1938
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1939
					installed = installed, -- 1940
					resource = resource, -- 1941
					catalogCommit = cached.snapshot.commit, -- 1942
					launchError = mobileLaunchErrors[resource.id] -- 1943
				} -- 1930
			end -- 1927
			return items -- 1945
		end, -- 1923
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1946
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1947
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1948
			end), repairIncomplete, isCanceled) -- 1947
		end, -- 1946
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1950
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1951
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1952
			end), isCanceled) -- 1951
		end, -- 1950
		createProject = function(name, language) -- 1954
			local result = projectCreate.createMobileProject(name, language) -- 1955
			if not result.success then -- 1956
				return result -- 1956
			end -- 1956
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1957
			for _index_0 = 1, #_list_0 do -- 1957
				local entry = _list_0[_index_0] -- 1957
				if entry.workDir == result.workDir then -- 1958
					return { -- 1959
						success = true, -- 1959
						entry = entry -- 1959
					} -- 1959
				end -- 1958
			end -- 1957
			return { -- 1960
				success = false, -- 1960
				error = "created-project-not-found" -- 1960
			} -- 1960
		end, -- 1954
		onPlay = function(entry) -- 1961
			return startMobilePlay(entry) -- 1961
		end, -- 1961
		onRemix = function(entry) -- 1962
			if HttpServer.wsConnectionCount > 0 then -- 1963
				return -- 1963
			end -- 1963
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1964
			local originFeed = feedHost -- 1965
			feedHost.visible = false -- 1966
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1968
				entry = entry, -- 1968
				onProjectChanged = function(current) -- 1969
					feedOptions.dirtyProjectPath = current.workDir -- 1969
				end, -- 1969
				onBack = function() -- 1970
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1971
						originFeed:emit("RestoreFeedEntry", entry) -- 1972
						originFeed.visible = true -- 1973
					end -- 1971
				end, -- 1970
				onPlay = function(current) -- 1974
					return startMobilePlay(current) -- 1974
				end -- 1974
			})) -- 1967
		end -- 1962
	} -- 1901
	return restartMobileFeed() -- 1977
end -- 1811
if mobileMode then -- 1979
	applyUIMode(true) -- 1979
end -- 1979
return _module_0 -- 1
