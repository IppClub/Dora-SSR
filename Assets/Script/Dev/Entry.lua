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
local pendingUIMode = nil -- 664
local feedHost = nil -- 665
local remixHost = nil -- 666
local startMobileUI = nil -- 667
local webControlled = false -- 668
local mobileHosts = { } -- 669
local suspendedMobileHosts = { } -- 670
local trackMobileHost -- 672
trackMobileHost = function(host) -- 672
	do -- 673
		local _accum_0 = { } -- 673
		local _len_0 = 1 -- 673
		for _index_0 = 1, #mobileHosts do -- 673
			local item = mobileHosts[_index_0] -- 673
			if item.parent then -- 673
				_accum_0[_len_0] = item -- 673
				_len_0 = _len_0 + 1 -- 673
			end -- 673
		end -- 673
		mobileHosts = _accum_0 -- 673
	end -- 673
	mobileHosts[#mobileHosts + 1] = host -- 674
	return host -- 675
end -- 672
local clearMobileUI -- 677
clearMobileUI = function() -- 677
	for _index_0 = 1, #mobileHosts do -- 678
		local host = mobileHosts[_index_0] -- 678
		if host.parent then -- 679
			host:removeFromParent(true) -- 679
		end -- 679
	end -- 678
	mobileHosts = { } -- 680
	suspendedMobileHosts = { } -- 681
	feedHost = nil -- 682
	remixHost = nil -- 683
end -- 677
local syncWebIDEControl -- 685
syncWebIDEControl = function() -- 685
	local connected = HttpServer.wsConnectionCount > 0 -- 686
	if connected then -- 687
		pendingUIMode = nil -- 688
		for _index_0 = 1, #mobileHosts do -- 689
			local host = mobileHosts[_index_0] -- 689
			if not host.parent then -- 690
				goto _continue_0 -- 690
			end -- 690
			if not (suspendedMobileHosts[host] ~= nil) then -- 691
				suspendedMobileHosts[host] = host.visible -- 692
				host:emit("SuspendLocalUI") -- 693
			end -- 691
			host.visible = false -- 694
			::_continue_0:: -- 690
		end -- 689
	elseif webControlled then -- 695
		for host, visible in pairs(suspendedMobileHosts) do -- 696
			if host.parent then -- 697
				host.visible = visible -- 698
				host:emit("ResumeLocalUI") -- 699
			end -- 697
		end -- 696
		suspendedMobileHosts = { } -- 700
	end -- 687
	webControlled = connected -- 701
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
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 708
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
		return pendingUIMode == false -- 715
	end -- 711
	pendingUIMode = true -- 716
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
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 742
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
local _anon_func_3 = function(_with_0) -- 905
	local _val_0 = App.platform -- 905
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 905
end -- 905
local _anon_func_4 = function(_with_0) -- 939
	local _val_0 = App.platform -- 939
	return "Windows" == _val_0 or "macOS" == _val_0 or "Android" == _val_0 -- 939
end -- 939
setupEventHandlers = function() -- 888
	local _with_0 = Director.postNode -- 889
	_with_0:onAppEvent(function(eventType) -- 890
		if "Quit" == eventType then -- 891
			quit = true -- 892
			allClear() -- 893
			return clearTempFiles() -- 894
		elseif "Shutdown" == eventType then -- 895
			return stop() -- 896
		end -- 890
	end) -- 890
	_with_0:onAppChange(function(settingName) -- 897
		if "Theme" == settingName then -- 898
			config.themeColor = App.themeColor:toARGB() -- 899
		elseif "Locale" == settingName then -- 900
			config.locale = App.locale -- 901
			updateLocale() -- 902
			return teal.clear(true) -- 903
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 904
			if _anon_func_3(_with_0) then -- 905
				if "FullScreen" == settingName then -- 907
					config.fullScreen = App.fullScreen -- 907
				elseif "Position" == settingName then -- 908
					local _obj_0 = App.winPosition -- 908
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 908
				elseif "Size" == settingName then -- 909
					local width, height -- 910
					do -- 910
						local _obj_0 = App.winSize -- 910
						width, height = _obj_0.width, _obj_0.height -- 910
					end -- 910
					config.winWidth = width -- 911
					config.winHeight = height -- 912
				end -- 906
			end -- 905
		end -- 897
	end) -- 897
	_with_0:onAppWS(function(event) -- 913
		if event.type == "Close" then -- 914
			if HttpServer.wsConnectionCount == 0 then -- 915
				updateEntries() -- 916
			end -- 915
			return -- 917
		end -- 914
		if not (event.type == "Receive") then -- 918
			return -- 918
		end -- 918
		local data = json.decode(event.msg) -- 919
		if not data then -- 920
			return -- 920
		end -- 920
		local _exp_0 = data.name -- 921
		if "SearchFiles" == _exp_0 then -- 922
			return handleSearchFiles(data) -- 923
		elseif "SearchFilesStop" == _exp_0 then -- 924
			if data.id == nil or data.id == activeSearchId then -- 925
				activeSearchId = 0 -- 926
			end -- 925
		end -- 921
	end) -- 913
	_with_0:slot("UpdateEntries", function() -- 927
		return updateEntries() -- 927
	end) -- 927
	_with_0:gslot("RepositoryImport", function(repository) -- 928
		return Director.systemScheduler:schedule(once(function() -- 929
			if not (currentEntry and currentEntry.entryName == "RepositoryImporter") then -- 930
				local importIDE = oldRequire("Dev.ImportIDE") -- 931
				allEntries.importRestoreIDE = importIDE.getNativeState() == "visible" -- 932
			end -- 930
			if mobileMode then -- 935
				clearMobileUI() -- 935
			end -- 935
			allClear() -- 936
			if _anon_func_4(_with_0) and App.webIDEEnabled then -- 939
				emit("AppWebView", "/ide/hide", false) -- 939
			end -- 939
			return enterEntryAsync({ -- 941
				entryName = "RepositoryImporter", -- 941
				fileName = Path(Content.assetPath, "Script", "Tools", "RepositoryImporter"), -- 942
				runKind = "tool", -- 943
				argument = repository -- 944
			}) -- 940
		end)) -- 929
	end) -- 928
	_with_0:gslot("RepositoryImported", function() -- 946
		return updateEntries() -- 946
	end) -- 946
	_with_0:gslot("RepositoryImportDone", function() -- 947
		return Director.systemScheduler:schedule(once(function() -- 948
			stop() -- 949
			if allEntries.importRestoreIDE then -- 950
				allEntries.importRestoreIDE = false -- 951
				return emit("AppWebView", "/ide/show", true) -- 952
			end -- 950
		end)) -- 948
	end) -- 947
	_with_0:gslot("RepositoryImportReveal", function(file) -- 953
		return Director.systemScheduler:schedule(once(function() -- 954
			stop() -- 955
			updateEntries() -- 956
			allEntries.importFocusedFile = Path:replaceExt(file, "") -- 957
			allEntries.importReveal = true -- 958
		end)) -- 954
	end) -- 953
	return _with_0 -- 889
end -- 888
setupEventHandlers() -- 961
clearTempFiles() -- 962
local downloadFile -- 964
downloadFile = function(url, target) -- 964
	return Director.systemScheduler:schedule(once(function() -- 964
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 965
			if quit then -- 966
				return true -- 966
			end -- 966
			emit("AppWS", "Send", json.encode({ -- 968
				name = "Download", -- 968
				url = url, -- 968
				status = "downloading", -- 968
				progress = current / total -- 969
			})) -- 967
			return false -- 965
		end) -- 965
		return emit("AppWS", "Send", json.encode(success and { -- 972
			name = "Download", -- 972
			url = url, -- 972
			status = "completed", -- 972
			progress = 1.0 -- 973
		} or { -- 975
			name = "Download", -- 975
			url = url, -- 975
			status = "failed", -- 975
			progress = 0.0 -- 976
		})) -- 971
	end)) -- 964
end -- 964
_module_0["downloadFile"] = downloadFile -- 964
local _anon_func_5 = function(entry, file, require, workDir) -- 990
	if workDir == nil then -- 990
		workDir = Path:getPath(file) -- 990
	end -- 990
	Content:insertSearchPath(1, workDir) -- 991
	local scriptPath = Path(workDir, "Script") -- 992
	if Content:exist(scriptPath) then -- 993
		Content:insertSearchPath(1, scriptPath) -- 994
	end -- 993
	local result = require(file) -- 995
	if "function" == type(result) then -- 996
		result(entry.argument) -- 996
	end -- 996
	return nil -- 997
end -- 990
local _anon_func_6 = function(_with_0, err, fontSize, width) -- 1026
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 1026
	label.alignment = "Left" -- 1027
	label.textWidth = width - fontSize -- 1028
	label.text = err -- 1029
	return label -- 1026
end -- 1026
enterEntryAsync = function(entry) -- 979
	allEntries.runId = allEntries.runId + 1 -- 980
	local launchRunId = allEntries.runId -- 981
	isInEntry = false -- 982
	App.idled = false -- 983
	emit(Profiler.EventName, "ClearLoader") -- 984
	currentEntry = entry -- 985
	local file, workDir = entry.fileName, entry.workDir -- 986
	sleep() -- 987
	if launchRunId ~= allEntries.runId or isInEntry or currentEntry ~= entry then -- 988
		return false, "superseded" -- 988
	end -- 988
	return xpcall(_anon_func_5, function(msg) -- 997
		local err = debug.traceback(msg) -- 999
		Log("Error", err) -- 1000
		allClear() -- 1001
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 1002
		local viewWidth, viewHeight -- 1003
		do -- 1003
			local _obj_0 = View.size -- 1003
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 1003
		end -- 1003
		local width, height = viewWidth - 20, viewHeight - 20 -- 1004
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 1005
		Director.ui:addChild((function() -- 1006
			local root = AlignNode() -- 1006
			do -- 1007
				local _obj_0 = App.bufferSize -- 1007
				width, height = _obj_0.width, _obj_0.height -- 1007
			end -- 1007
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1008
			root:onAppChange(function(settingName) -- 1009
				if settingName == "Size" then -- 1009
					do -- 1010
						local _obj_0 = App.bufferSize -- 1010
						width, height = _obj_0.width, _obj_0.height -- 1010
					end -- 1010
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 1011
				end -- 1009
			end) -- 1009
			root:addChild((function() -- 1012
				local _with_0 = ScrollArea({ -- 1013
					width = width, -- 1013
					height = height, -- 1014
					paddingX = 0, -- 1015
					paddingY = 50, -- 1016
					viewWidth = height, -- 1017
					viewHeight = height -- 1018
				}) -- 1012
				root:onAlignLayout(function(w, h) -- 1020
					_with_0.position = Vec2(w / 2, h / 2) -- 1021
					w = w - 20 -- 1022
					h = h - 20 -- 1023
					_with_0.view.children.first.textWidth = w - fontSize -- 1024
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 1025
				end) -- 1020
				_with_0.view:addChild(_anon_func_6(_with_0, err, fontSize, width)) -- 1026
				return _with_0 -- 1012
			end)()) -- 1012
			return root -- 1006
		end)()) -- 1006
		return err -- 1030
	end, entry, file, require, workDir) -- 989
end -- 979
_module_0["enterEntryAsync"] = enterEntryAsync -- 979
local enterDemoEntry -- 1032
enterDemoEntry = function(entry) -- 1032
	return thread(function() -- 1032
		return enterEntryAsync(entry) -- 1032
	end) -- 1032
end -- 1032
local reloadCurrentEntry -- 1034
reloadCurrentEntry = function() -- 1034
	if currentEntry then -- 1035
		allClear() -- 1036
		return enterDemoEntry(currentEntry) -- 1037
	end -- 1035
end -- 1034
Director.clearColor = Color(0xff1a1a1a) -- 1039
local descColor = Color(0xffa1a1a1) -- 1040
local extraOperations -- 1043
do -- 1043
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 1044
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 1045
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 1046
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 1047
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 1048
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1049
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1050
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1051
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1052
	local ossLicenses = nil -- 1053
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1054
	local failedSetFolder = false -- 1055
	local statusFlags = { -- 1056
		"NoResize", -- 1056
		"NoMove", -- 1056
		"NoCollapse", -- 1056
		"AlwaysAutoResize", -- 1056
		"NoSavedSettings" -- 1056
	} -- 1056
	extraOperations = function() -- 1063
		local zh = useChinese -- 1064
		if isDesktop then -- 1065
			local alwaysOnTop = config.alwaysOnTop -- 1066
			do -- 1067
				local changed -- 1067
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1067
				if changed then -- 1067
					App.alwaysOnTop = alwaysOnTop -- 1068
					config.alwaysOnTop = alwaysOnTop -- 1069
				end -- 1067
			end -- 1067
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1070
			do -- 1071
				local changed -- 1071
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1071
				if changed then -- 1071
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1072
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1073
				end -- 1071
			end -- 1071
			SameLine() -- 1074
			TextColored(descColor, "(?)") -- 1075
			if IsItemHovered() then -- 1076
				BeginTooltip(function() -- 1077
					return PushTextWrapPos(360, function() -- 1078
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1079
					end) -- 1078
				end) -- 1077
			end -- 1076
		end -- 1065
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1094
		do -- 1098
			local changed -- 1098
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1098
			if changed then -- 1098
				config.showPreview = showPreview -- 1099
				updateEntries() -- 1100
				if not showPreview then -- 1101
					thread(function() -- 1102
						collectgarbage() -- 1103
						return Cache:removeUnused("Texture") -- 1104
					end) -- 1102
				end -- 1101
			end -- 1098
		end -- 1098
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1105
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1106
			if changed then -- 1106
				config.webIDEEnabled = webIDEEnabled -- 1107
				App.webIDEEnabled = webIDEEnabled -- 1108
			end -- 1106
		end -- 1105
		do -- 1109
			local themeColor = App.themeColor -- 1110
			local writablePath = config.writablePath -- 1111
			SeparatorText(zh and "工作目录" or "Workspace") -- 1112
			PushTextWrapPos(400, function() -- 1113
				return TextColored(themeColor, writablePath) -- 1114
			end) -- 1113
			if not isDesktop then -- 1115
				goto skipSetting -- 1115
			end -- 1115
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1116
			if Button(zh and "改变目录" or "Set Folder") then -- 1117
				App:openFileDialog(true, function(path) -- 1118
					if path == "" then -- 1119
						return -- 1119
					end -- 1119
					local relPath = Path:getRelative(Content.assetPath, path) -- 1120
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1121
						return setWorkspace(path) -- 1122
					else -- 1124
						failedSetFolder = true -- 1124
					end -- 1121
				end) -- 1118
			end -- 1117
			if failedSetFolder then -- 1125
				failedSetFolder = false -- 1126
				OpenPopup(popupName) -- 1127
			end -- 1125
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1128
			BeginPopupModal(popupName, statusFlags, function() -- 1129
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1130
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1131
					return CloseCurrentPopup() -- 1132
				end -- 1131
			end) -- 1129
			SameLine() -- 1133
			if Button(zh and "使用默认" or "Use Default") then -- 1134
				setWorkspace(Content.appPath) -- 1135
			end -- 1134
			Separator() -- 1136
			::skipSetting:: -- 1137
		end -- 1109
		renderAgentStorage(zh) -- 1138
		if isOSSLicenseExist then -- 1139
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1140
				if not ossLicenses then -- 1141
					local licenseText = Content:load("LICENSES") -- 1142
					if licenseText then -- 1142
						local GSplit -- 1143
						do -- 1143
							local _obj_0 = require("Utils") -- 1143
							GSplit = _obj_0.GSplit -- 1143
						end -- 1143
						ossLicenses = { } -- 1144
						licenseText = licenseText:gsub("\r\n", "\n") -- 1145
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1146
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1147
							if name then -- 1147
								ossLicenses[#ossLicenses + 1] = { -- 1148
									name, -- 1148
									text -- 1148
								} -- 1148
							end -- 1147
						end -- 1146
					end -- 1142
				end -- 1141
				if ossLicenses then -- 1149
					OpenPopup(ossLicensePopup) -- 1149
				end -- 1149
			end -- 1140
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1150
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1151
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1152
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1153
				return BeginPopupModal(ossLicensePopup, true, { -- 1156
					"NoSavedSettings" -- 1156
				}, function() -- 1157
					for _index_0 = 1, #ossLicenses do -- 1158
						local _des_0 = ossLicenses[_index_0] -- 1158
						local firstLine, text = _des_0[1], _des_0[2] -- 1158
						local name, license = firstLine:match("(.+): (.+)") -- 1160
						if name then -- 1160
							TextColored(themeColor, name) -- 1161
							SameLine() -- 1162
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1163
								return TextWrapped(text) -- 1163
							end) -- 1163
						end -- 1160
					end -- 1158
				end) -- 1153
			end) -- 1153
		end -- 1139
		if not App.debugging then -- 1166
			return -- 1166
		end -- 1166
		return TreeNode(zh and "开发操作" or "Development", function() -- 1167
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1168
				OpenPopup("build") -- 1168
			end -- 1168
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1169
				return BeginPopup("build", function() -- 1169
					if Selectable(zh and "编译" or "Compile") then -- 1170
						doCompile(false) -- 1170
					end -- 1170
					Separator() -- 1171
					if Selectable(zh and "压缩" or "Minify") then -- 1172
						doCompile(true) -- 1172
					end -- 1172
					Separator() -- 1173
					if Selectable(zh and "清理" or "Clean") then -- 1174
						return doClean() -- 1174
					end -- 1174
				end) -- 1169
			end) -- 1169
			if isInEntry then -- 1175
				if waitForWebStart then -- 1176
					BeginDisabled(function() -- 1177
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1177
					end) -- 1177
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1178
					reloadDevEntry() -- 1179
				end -- 1176
			end -- 1175
			do -- 1180
				local changed -- 1180
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1180
				if changed then -- 1180
					View.scale = scaleContent and screenScale or 1 -- 1181
				end -- 1180
			end -- 1180
			do -- 1182
				local changed -- 1182
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1182
				if changed then -- 1182
					config.engineDev = engineDev -- 1183
				end -- 1182
			end -- 1182
			do -- 1184
				local changed -- 1184
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1184
				if changed then -- 1184
					config.webIDETourCompleted = webIDETourCompleted -- 1185
				end -- 1184
			end -- 1184
			if testingThread then -- 1186
				return BeginDisabled(function() -- 1187
					return Button(zh and "开始自动测试" or "Test automatically") -- 1187
				end) -- 1187
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1188
				testingThread = thread(function() -- 1189
					local _ <close> = setmetatable({ }, { -- 1190
						__close = function() -- 1190
							allClear() -- 1191
							testingThread = nil -- 1192
							isInEntry = true -- 1193
							currentEntry = nil -- 1194
							return print("Testing done!") -- 1195
						end -- 1190
					}) -- 1190
					for _, entry in ipairs(allEntries) do -- 1196
						allClear() -- 1197
						print("Start " .. tostring(entry.entryName)) -- 1198
						enterDemoEntry(entry) -- 1199
						sleep(2) -- 1200
						print("Stop " .. tostring(entry.entryName)) -- 1201
					end -- 1196
				end) -- 1189
			end -- 1186
		end) -- 1167
	end -- 1063
end -- 1043
local icon = Path("Script", "Dev", "icon_s.png") -- 1203
local iconTex = nil -- 1204
thread(function() -- 1205
	if Cache:loadAsync(icon) then -- 1205
		iconTex = Texture2D(icon) -- 1205
	end -- 1205
end) -- 1205
local webStatus = nil -- 1207
local urlClicked = nil -- 1208
local authCode = string.format("%06d", math.random(0, 999999)) -- 1210
local authCodeTTL = 30.0 -- 1212
_module_0.getAuthCode = function() -- 1213
	return authCode -- 1213
end -- 1213
_module_0.invalidateAuthCode = function() -- 1214
	authCode = string.format("%06d", math.random(0, 999999)) -- 1215
	authCodeTTL = 30.0 -- 1216
end -- 1214
local AuthSession -- 1218
do -- 1218
	local pending = nil -- 1219
	local session = nil -- 1220
	AuthSession = { -- 1222
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1222
			pending = { -- 1224
				sessionId = sessionId, -- 1224
				confirmCode = confirmCode, -- 1225
				expiresAt = expiresAt, -- 1226
				ttl = ttl, -- 1227
				approved = false -- 1228
			} -- 1223
		end, -- 1222
		getPending = function() -- 1230
			return pending -- 1230
		end, -- 1230
		approvePending = function(sessionId) -- 1232
			if pending and pending.sessionId == sessionId then -- 1233
				pending.approved = true -- 1234
				return true -- 1235
			end -- 1233
			return false -- 1236
		end, -- 1232
		clearPending = function() -- 1238
			pending = nil -- 1238
		end, -- 1238
		setSession = function(sessionId, sessionSecret) -- 1240
			session = { -- 1242
				sessionId = sessionId, -- 1242
				sessionSecret = sessionSecret -- 1243
			} -- 1241
		end, -- 1240
		getSession = function() -- 1245
			return session -- 1245
		end -- 1245
	} -- 1221
end -- 1218
_module_0["AuthSession"] = AuthSession -- 1218
local transparant = Color(0x0) -- 1248
local windowFlags = { -- 1249
	"NoTitleBar", -- 1249
	"NoResize", -- 1249
	"NoMove", -- 1249
	"NoCollapse", -- 1249
	"NoSavedSettings", -- 1249
	"NoFocusOnAppearing", -- 1249
	"NoBringToFrontOnFocus" -- 1249
} -- 1249
local statusFlags = { -- 1258
	"NoTitleBar", -- 1258
	"NoResize", -- 1258
	"NoMove", -- 1258
	"NoCollapse", -- 1258
	"AlwaysAutoResize", -- 1258
	"NoSavedSettings" -- 1258
} -- 1258
local displayWindowFlags = { -- 1266
	"NoDecoration", -- 1266
	"NoSavedSettings", -- 1266
	"NoMove", -- 1266
	"NoScrollWithMouse", -- 1266
	"AlwaysAutoResize", -- 1266
	"NoFocusOnAppearing" -- 1266
} -- 1266
local _anon_func_7 = function(allEntries, currentIndex) -- 1339
	if currentIndex > 1 then -- 1339
		return allEntries[currentIndex - 1] -- 1340
	else -- 1342
		return allEntries[#allEntries] -- 1342
	end -- 1339
end -- 1339
local _anon_func_8 = function(allEntries, currentIndex) -- 1346
	if currentIndex < #allEntries then -- 1346
		return allEntries[currentIndex + 1] -- 1347
	else -- 1349
		return allEntries[1] -- 1349
	end -- 1346
end -- 1346
do -- 1275
	local gamepadInputWindowFlags = { -- 1276
		"NoDecoration", -- 1276
		"NoSavedSettings", -- 1276
		"NoMove", -- 1276
		"NoScrollbar", -- 1276
		"NoScrollWithMouse", -- 1276
		"NoFocusOnAppearing", -- 1276
		"NoBringToFrontOnFocus" -- 1276
	} -- 1276
	local initFooter = true -- 1285
	local gamepadInputFocused = false -- 1286
	footerWindow = threadLoop(function() -- 1287
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1288
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1289
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1290
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1291
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1292
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1293
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1294
		if mobileMode then -- 1295
			return -- 1295
		end -- 1295
		local zh = useChinese -- 1296
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1297
		if authCodeTTL <= 0 then -- 1298
			authCodeTTL = 30.0 -- 1299
			authCode = string.format("%06d", math.random(0, 999999)) -- 1300
		end -- 1298
		if HttpServer.wsConnectionCount > 0 then -- 1301
			return -- 1302
		end -- 1301
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1303
			if App.platform == "Emscripten" then -- 1304
				stop() -- 1306
			else -- 1308
				allClear() -- 1308
				App.devMode = false -- 1309
				App:shutdown() -- 1310
			end -- 1304
		end -- 1303
		do -- 1311
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1312
			if ctrl and Keyboard:isKeyDown("Q") then -- 1313
				stop() -- 1314
			end -- 1313
			if ctrl and Keyboard:isKeyDown("Z") then -- 1315
				reloadCurrentEntry() -- 1316
			end -- 1315
			if ctrl and Keyboard:isKeyDown(",") then -- 1317
				if showFooter then -- 1318
					showStats = not showStats -- 1318
				else -- 1318
					showStats = true -- 1318
				end -- 1318
				showFooter = true -- 1319
				config.showFooter = showFooter -- 1320
				config.showStats = showStats -- 1321
			end -- 1317
			if ctrl and Keyboard:isKeyDown(".") then -- 1322
				if showFooter then -- 1323
					showConsole = not showConsole -- 1323
				else -- 1323
					showConsole = true -- 1323
				end -- 1323
				showFooter = true -- 1324
				config.showFooter = showFooter -- 1325
				config.showConsole = showConsole -- 1326
			end -- 1322
			if ctrl and Keyboard:isKeyDown("/") then -- 1327
				showFooter = not showFooter -- 1328
				config.showFooter = showFooter -- 1329
			end -- 1327
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1330
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1331
			local currentIndex = nil -- 1332
			for i, entry in ipairs(allEntries) do -- 1333
				if currentEntry == entry then -- 1334
					currentIndex = i -- 1335
				end -- 1334
			end -- 1333
			if left then -- 1336
				allClear() -- 1337
				if currentIndex == nil then -- 1338
					currentIndex = #allEntries + 1 -- 1338
				end -- 1338
				enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 1339
			end -- 1336
			if right then -- 1343
				allClear() -- 1344
				if currentIndex == nil then -- 1345
					currentIndex = 0 -- 1345
				end -- 1345
				enterDemoEntry(_anon_func_8(allEntries, currentIndex)) -- 1346
			end -- 1343
		end -- 1311
		if not showEntry then -- 1350
			return -- 1350
		end -- 1350
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1352
			reloadDevEntry() -- 1356
		end -- 1352
		if initFooter then -- 1357
			initFooter = false -- 1358
		end -- 1357
		local width, height -- 1360
		do -- 1360
			local _obj_0 = App.visualSize -- 1360
			width, height = _obj_0.width, _obj_0.height -- 1360
		end -- 1360
		if isInEntry then -- 1361
			gamepadInputFocused = false -- 1362
		else -- 1364
			SetNextWindowBgAlpha(0.0) -- 1364
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1365
			SetNextWindowPos(Vec2.zero, "Always") -- 1366
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1367
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1368
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1369
						if not gamepadInputFocused then -- 1370
							SetWindowFocus("DoraGamepadInput") -- 1371
							gamepadInputFocused = true -- 1372
						end -- 1370
					end) -- 1369
				end) -- 1368
			end) -- 1367
		end -- 1361
		if isInEntry or showFooter then -- 1374
			SetNextWindowSize(Vec2(width, 50)) -- 1375
			SetNextWindowPos(Vec2(0, height - 50)) -- 1376
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1377
				return PushStyleVar("WindowRounding", 0, function() -- 1378
					return Begin("Footer", windowFlags, function() -- 1379
						Separator() -- 1380
						if iconTex then -- 1381
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1382
								showStats = not showStats -- 1383
								config.showStats = showStats -- 1384
							end -- 1382
							SameLine() -- 1385
							if Button(">_", Vec2(30, 30)) then -- 1386
								showConsole = not showConsole -- 1387
								config.showConsole = showConsole -- 1388
							end -- 1386
						end -- 1381
						if isInEntry and updateState.available then -- 1389
							SameLine() -- 1390
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1391
								allClear() -- 1392
								enterDemoEntry({ -- 1394
									entryName = "SelfUpdater", -- 1394
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1395
								}) -- 1393
							end -- 1391
						end -- 1389
						if not isInEntry then -- 1396
							SameLine() -- 1397
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1398
							local currentIndex = nil -- 1399
							for i, entry in ipairs(allEntries) do -- 1400
								if currentEntry == entry then -- 1401
									currentIndex = i -- 1402
								end -- 1401
							end -- 1400
							if currentIndex then -- 1403
								if currentIndex > 1 then -- 1404
									SameLine() -- 1405
									if Button("<<", Vec2(30, 30)) then -- 1406
										allClear() -- 1407
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1408
									end -- 1406
								end -- 1404
								if currentIndex < #allEntries then -- 1409
									SameLine() -- 1410
									if Button(">>", Vec2(30, 30)) then -- 1411
										allClear() -- 1412
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1413
									end -- 1411
								end -- 1409
							end -- 1403
							SameLine() -- 1414
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1415
								reloadCurrentEntry() -- 1416
							end -- 1415
							if back then -- 1417
								allClear() -- 1418
								isInEntry = true -- 1419
								currentEntry = nil -- 1420
							end -- 1417
						end -- 1396
					end) -- 1379
				end) -- 1378
			end) -- 1377
		end -- 1374
		if isInEntry then -- 1422
			local showURL = true -- 1423
			local webIDEWidth -- 1424
			do -- 1424
				local base -- 1425
				if updateState.available then -- 1425
					base = 460 -- 1425
				else -- 1425
					base = 360 -- 1425
				end -- 1425
				local extra = 35 -- 1426
				webIDEWidth = base + extra -- 1427
			end -- 1424
			if width < webIDEWidth then -- 1428
				showURL = false -- 1428
			end -- 1428
			SetNextWindowBgAlpha(0.0) -- 1429
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1430
			Begin("Web IDE", displayWindowFlags, function() -- 1431
				local pending = AuthSession.getPending() -- 1432
				local hovered = false -- 1433
				if not pending and showURL then -- 1434
					do -- 1435
						local url -- 1435
						if webStatus ~= nil then -- 1435
							url = webStatus.url -- 1435
						end -- 1435
						if url then -- 1435
							if isDesktop and not config.fullScreen then -- 1436
								if urlClicked then -- 1437
									BeginDisabled(function() -- 1438
										return Button(url) -- 1438
									end) -- 1438
								elseif Button(url) then -- 1439
									urlClicked = once(function() -- 1440
										return sleep(5) -- 1440
									end) -- 1440
									App:openURL("http://localhost:8866") -- 1441
								end -- 1437
							else -- 1443
								TextColored(descColor, url) -- 1443
							end -- 1436
						else -- 1445
							TextColored(descColor, zh and '不可用' or 'not available') -- 1445
						end -- 1435
					end -- 1435
					hovered = IsItemHovered() -- 1446
				else -- 1448
					TextColored(descColor, "(?)") -- 1448
					hovered = IsItemHovered() -- 1449
				end -- 1434
				SameLine() -- 1450
				local themeColor = App.themeColor -- 1451
				if pending then -- 1452
					if not pending.approved then -- 1453
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1454
						local ttl = pending.ttl or 1 -- 1455
						PushStyleColor("Text", themeColor, function() -- 1456
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1457
							hovered = hovered or IsItemHovered() -- 1458
						end) -- 1456
						SameLine() -- 1459
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1460
							AuthSession.approvePending(pending.sessionId) -- 1461
						end -- 1460
						if hovered then -- 1462
							return BeginTooltip(function() -- 1463
								return PushTextWrapPos(280, function() -- 1464
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1465
								end) -- 1464
							end) -- 1463
						end -- 1462
					end -- 1453
				else -- 1467
					PushStyleColor("Text", themeColor, function() -- 1467
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1468
						hovered = hovered or IsItemHovered() -- 1469
					end) -- 1467
					if hovered then -- 1470
						return BeginTooltip(function() -- 1471
							return PushTextWrapPos(280, function() -- 1472
								local url -- 1473
								if webStatus ~= nil then -- 1473
									url = webStatus.url -- 1473
								end -- 1473
								if url then -- 1473
									local address -- 1474
									if showURL then -- 1474
										address = "Web IDE" -- 1474
									else -- 1474
										address = url -- 1474
									end -- 1474
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1475
								else -- 1477
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1477
								end -- 1473
							end) -- 1472
						end) -- 1471
					end -- 1470
				end -- 1452
			end) -- 1431
		end -- 1422
		if not isInEntry then -- 1478
			SetNextWindowSize(Vec2(50, 50)) -- 1479
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1480
			PushStyleColor("WindowBg", transparant, function() -- 1481
				return Begin("Show", displayWindowFlags, function() -- 1481
					if width >= 370 then -- 1482
						local changed -- 1483
						changed, showFooter = Checkbox("##dev", showFooter) -- 1483
						if changed then -- 1483
							config.showFooter = showFooter -- 1484
						end -- 1483
					end -- 1482
				end) -- 1481
			end) -- 1481
		end -- 1478
		if isInEntry or showFooter then -- 1486
			if showStats then -- 1487
				PushStyleVar("WindowRounding", 0, function() -- 1488
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1489
					SetNextWindowSize(Vec2(0, height - 50)) -- 1490
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1491
					config.showStats = showStats -- 1492
				end) -- 1488
			end -- 1487
			if showConsole then -- 1493
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1494
				return PushStyleVar("WindowRounding", 6, function() -- 1495
					return ShowConsole() -- 1496
				end) -- 1495
			end -- 1493
		end -- 1486
	end) -- 1287
end -- 1275
do -- 1499
	local MaxWidth <const> = 960 -- 1500
	local toolOpen = false -- 1502
	local filterText = nil -- 1503
	allEntries.anyEntryMatched = false -- 1504
	allEntries.match = function(name) -- 1505
		local res = not filterText or name:lower():match(filterText) -- 1506
		if res then -- 1507
			allEntries.anyEntryMatched = true -- 1507
		end -- 1507
		return res -- 1508
	end -- 1505
	allEntries.thinSep = function() -- 1510
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1510
			return ImGui.SeparatorText("") -- 1510
		end) -- 1510
	end -- 1510
	entryWindow = threadLoop(function() -- 1511
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1512
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1513
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1514
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1515
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1516
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1517
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1518
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1519
		local connected = syncWebIDEControl() -- 1520
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1522
			if not allEntries.pendingPackagePath then -- 1523
				local path = App:takeReceivedFile() -- 1524
				if path ~= "" then -- 1525
					allEntries.pendingPackagePath = path -- 1525
				end -- 1525
			end -- 1523
			if allEntries.pendingPackagePath then -- 1526
				pendingUIMode = true -- 1526
			end -- 1526
		end -- 1522
		if (pendingUIMode ~= nil) then -- 1528
			local nextMode = pendingUIMode -- 1529
			pendingUIMode = nil -- 1530
			applyUIMode(nextMode) -- 1531
		end -- 1528
		if mobileMode and not connected then -- 1532
			if allEntries.importReveal and feedHost and feedHost.visible then -- 1533
				local _list_0 = getMobileFeedEntries() -- 1534
				for _index_0 = 1, #_list_0 do -- 1534
					local entry = _list_0[_index_0] -- 1534
					if entry.fileName == allEntries.importFocusedFile then -- 1535
						feedHost:emit("RestoreFeedEntry", entry) -- 1536
						allEntries.importReveal = false -- 1537
						break -- 1538
					end -- 1535
				end -- 1534
			end -- 1533
			if isInEntry and not feedHost then -- 1539
				applyUIMode(true) -- 1539
			end -- 1539
			return -- 1540
		end -- 1532
		if App.fpsLimited ~= config.fpsLimited then -- 1541
			config.fpsLimited = App.fpsLimited -- 1542
		end -- 1541
		if App.targetFPS ~= config.targetFPS then -- 1543
			config.targetFPS = App.targetFPS -- 1544
		end -- 1543
		if View.vsync ~= config.vsync then -- 1545
			config.vsync = View.vsync -- 1546
		end -- 1545
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1547
			config.fixedFPS = Director.scheduler.fixedFPS -- 1548
		end -- 1547
		if Director.profilerSending ~= config.webProfiler then -- 1549
			config.webProfiler = Director.profilerSending -- 1550
		end -- 1549
		if urlClicked then -- 1551
			local _, result = coroutine.resume(urlClicked) -- 1552
			if result then -- 1553
				coroutine.close(urlClicked) -- 1554
				urlClicked = nil -- 1555
			end -- 1553
		end -- 1551
		if not isInEntry then -- 1556
			return -- 1556
		end -- 1556
		local zh = useChinese -- 1557
		local themeColor = App.themeColor -- 1558
		if connected then -- 1559
			local width, height -- 1560
			do -- 1560
				local _obj_0 = App.visualSize -- 1560
				width, height = _obj_0.width, _obj_0.height -- 1560
			end -- 1560
			SetNextWindowBgAlpha(0.5) -- 1561
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1562
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1563
				Separator() -- 1564
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1565
				if iconTex then -- 1566
					Image(icon, Vec2(24, 24)) -- 1567
					SameLine() -- 1568
				end -- 1566
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1569
				TextColored(descColor, slogon) -- 1570
				return Separator() -- 1571
			end) -- 1563
			return -- 1572
		end -- 1559
		if not showEntry then -- 1573
			return -- 1573
		end -- 1573
		local fullWidth, height -- 1575
		do -- 1575
			local _obj_0 = App.visualSize -- 1575
			fullWidth, height = _obj_0.width, _obj_0.height -- 1575
		end -- 1575
		local width = math.min(MaxWidth, fullWidth) -- 1576
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1577
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1578
		SetNextWindowPos(Vec2.zero) -- 1579
		SetNextWindowBgAlpha(0) -- 1580
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1581
		do -- 1582
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1583
				return Begin("Dora Dev", windowFlags, function() -- 1584
					Dummy(Vec2(fullWidth - 20, 0)) -- 1585
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1586
					SameLine() -- 1587
					if Button(zh and "Go 模式" or "Go Mode") then -- 1588
						setUIMode("mobile") -- 1589
					end -- 1588
					if fullWidth >= 540 then -- 1590
						SameLine() -- 1591
						Dummy(Vec2(fullWidth - 540, 0)) -- 1592
						SameLine() -- 1593
						SetNextItemWidth(zh and -95 or -140) -- 1594
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1595
							"AutoSelectAll" -- 1595
						}) then -- 1595
							config.filter = filterBuf.text -- 1596
							allEntries.importFocusedFile = nil -- 1597
							allEntries.importReveal = false -- 1598
						end -- 1595
						SameLine() -- 1599
						if Button(zh and '下载' or 'Download') then -- 1600
							ImGui.OpenPopup("project-download") -- 1600
						end -- 1600
						ImGui.BeginPopup("project-download", function() -- 1601
							if ImGui.Selectable(zh and "从 Git 仓库导入…" or "Import Git repository…") then -- 1602
								emit("RepositoryImport", nil) -- 1603
							end -- 1602
							if ImGui.Selectable(zh and "浏览资源目录…" or "Browse resource catalog…") then -- 1604
								allClear() -- 1605
								return enterDemoEntry({ -- 1607
									entryName = "ResourceDownloader", -- 1607
									fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1608
								}) -- 1606
							end -- 1604
						end) -- 1601
					end -- 1590
					return Separator() -- 1609
				end) -- 1584
			end) -- 1583
		end -- 1582
		allEntries.anyEntryMatched = false -- 1611
		SetNextWindowPos(Vec2(0, 50)) -- 1612
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1613
		local scrollbarSize <const> = 25 -- 1615
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1616
		do -- 1617
			return PushStyleColor("WindowBg", transparant, function() -- 1618
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1619
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1620
						return PushStyleVar("Alpha", 1, function() -- 1621
							return Begin("Content", windowFlags, function() -- 1622
								local DemoViewWidth <const> = 220 -- 1623
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1624
								if filterText then -- 1625
									filterText = filterText:lower() -- 1625
								end -- 1625
								if App.platform == "Emscripten" then -- 1626
									Dora.globals.webProjects.draw(zh, themeColor) -- 1627
									allEntries.anyEntryMatched = true -- 1628
								end -- 1626
								if #gamesInDev > 0 then -- 1629
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1630
									Columns(columns, false) -- 1631
									local realViewWidth = GetColumnWidth() - 50 -- 1632
									for _index_0 = 1, #gamesInDev do -- 1633
										local game = gamesInDev[_index_0] -- 1633
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1634
										local displayName -- 1643
										if repo then -- 1643
											if zh then -- 1644
												displayName = repo.title.zh -- 1644
											else -- 1644
												displayName = repo.title.en -- 1644
											end -- 1644
										end -- 1643
										if displayName == nil then -- 1645
											displayName = gameName -- 1645
										end -- 1645
										if allEntries.match(displayName) or allEntries.importFocusedFile == fileName then -- 1646
											allEntries.anyEntryMatched = true -- 1647
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1648
											SameLine() -- 1649
											if allEntries.importFocusedFile == fileName then -- 1650
												PushStyleColor("Text", themeColor, function() -- 1651
													return TextWrapped(displayName) -- 1651
												end) -- 1651
											else -- 1653
												TextWrapped(displayName) -- 1653
											end -- 1650
											if allEntries.importFocusedFile == fileName and allEntries.importReveal then -- 1654
												ImGui.SetScrollHereY(0.5) -- 1655
												allEntries.importReveal = false -- 1656
											end -- 1654
											if columns > 1 then -- 1657
												if bannerFile and bannerTex then -- 1658
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1659
													local displayWidth <const> = realViewWidth -- 1660
													texHeight = displayWidth * texHeight / texWidth -- 1661
													texWidth = displayWidth -- 1662
													Dummy(Vec2.zero) -- 1663
													SameLine() -- 1664
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1665
												end -- 1658
												if game.needsBuild then -- 1666
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1667
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1668
													enterDemoEntry(game) -- 1669
												end -- 1666
											else -- 1671
												if bannerFile and bannerTex then -- 1671
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1672
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1673
													local sizing = 0.8 -- 1674
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1675
													texWidth = displayWidth * sizing -- 1676
													if texWidth > 500 then -- 1677
														sizing = 0.6 -- 1678
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1679
														texWidth = displayWidth * sizing -- 1680
													end -- 1677
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1681
													Dummy(Vec2(padding, 0)) -- 1682
													SameLine() -- 1683
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1684
												end -- 1671
												if game.needsBuild then -- 1685
													ImGui.TextDisabled(zh and "请先在 IDE 中编译项目" or "Build in the IDE first") -- 1686
												elseif Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1687
													enterDemoEntry(game) -- 1688
												end -- 1685
											end -- 1657
											if #tests == 0 and #examples == 0 then -- 1689
												allEntries.thinSep() -- 1690
											end -- 1689
											NextColumn() -- 1691
										end -- 1646
										local showSep = false -- 1692
										if #examples > 0 then -- 1693
											local showExample = false -- 1694
											for _index_1 = 1, #examples do -- 1695
												local _des_0 = examples[_index_1] -- 1695
												local entryName = _des_0.entryName -- 1695
												if allEntries.match(entryName) then -- 1696
													showExample = true -- 1696
													break -- 1696
												end -- 1696
											end -- 1695
											if showExample then -- 1697
												showSep = true -- 1698
												Columns(1, false) -- 1699
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1700
												SameLine() -- 1701
												local opened -- 1702
												if (filterText ~= nil) then -- 1702
													opened = showExample -- 1702
												else -- 1702
													opened = false -- 1702
												end -- 1702
												if game.exampleOpen == nil then -- 1703
													game.exampleOpen = opened -- 1703
												end -- 1703
												SetNextItemOpen(game.exampleOpen) -- 1704
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1705
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1706
														Columns(maxColumns, false) -- 1707
														for _index_1 = 1, #examples do -- 1708
															local example = examples[_index_1] -- 1708
															local entryName = example.entryName -- 1709
															if not allEntries.match(entryName) then -- 1710
																goto _continue_0 -- 1710
															end -- 1710
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1711
																if Button(entryName, Vec2(-1, 40)) then -- 1712
																	enterDemoEntry(example) -- 1713
																end -- 1712
																return NextColumn() -- 1714
															end) -- 1711
															opened = true -- 1715
															::_continue_0:: -- 1709
														end -- 1708
													end) -- 1706
												end) -- 1705
												game.exampleOpen = opened -- 1716
											end -- 1697
										end -- 1693
										if #tests > 0 then -- 1717
											local showTest = false -- 1718
											for _index_1 = 1, #tests do -- 1719
												local _des_0 = tests[_index_1] -- 1719
												local entryName = _des_0.entryName -- 1719
												if allEntries.match(entryName) then -- 1720
													showTest = true -- 1720
													break -- 1720
												end -- 1720
											end -- 1719
											if showTest then -- 1721
												showSep = true -- 1722
												Columns(1, false) -- 1723
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1724
												SameLine() -- 1725
												local opened -- 1726
												if (filterText ~= nil) then -- 1726
													opened = showTest -- 1726
												else -- 1726
													opened = false -- 1726
												end -- 1726
												if game.testOpen == nil then -- 1727
													game.testOpen = opened -- 1727
												end -- 1727
												SetNextItemOpen(game.testOpen) -- 1728
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1729
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1730
														Columns(maxColumns, false) -- 1731
														for _index_1 = 1, #tests do -- 1732
															local test = tests[_index_1] -- 1732
															local entryName = test.entryName -- 1733
															if not allEntries.match(entryName) then -- 1734
																goto _continue_0 -- 1734
															end -- 1734
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1735
																if Button(entryName, Vec2(-1, 40)) then -- 1736
																	enterDemoEntry(test) -- 1737
																end -- 1736
																return NextColumn() -- 1738
															end) -- 1735
															opened = true -- 1739
															::_continue_0:: -- 1733
														end -- 1732
													end) -- 1730
												end) -- 1729
												game.testOpen = opened -- 1740
											end -- 1721
										end -- 1717
										if showSep then -- 1741
											Columns(1, false) -- 1742
											allEntries.thinSep() -- 1743
											Columns(columns, false) -- 1744
										end -- 1741
									end -- 1633
								end -- 1629
								if #doraTools > 0 then -- 1745
									local showTool = false -- 1746
									for _index_0 = 1, #doraTools do -- 1747
										local _des_0 = doraTools[_index_0] -- 1747
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1747
										local displayName -- 1748
										if repo then -- 1748
											if zh then -- 1749
												displayName = repo.title.zh -- 1749
											else -- 1749
												displayName = repo.title.en -- 1749
											end -- 1749
										end -- 1748
										if displayName == nil then -- 1750
											displayName = entryName -- 1750
										end -- 1750
										if allEntries.match(displayName) then -- 1751
											showTool = true -- 1751
											break -- 1751
										end -- 1751
									end -- 1747
									if not showTool then -- 1752
										goto endEntry -- 1752
									end -- 1752
									Columns(1, false) -- 1753
									TextColored(themeColor, "Dora SSR:") -- 1754
									SameLine() -- 1755
									Text(zh and "开发支持" or "Development Support") -- 1756
									Separator() -- 1757
									if #doraTools > 0 then -- 1758
										local opened -- 1759
										if (filterText ~= nil) then -- 1759
											opened = showTool -- 1759
										else -- 1759
											opened = false -- 1759
										end -- 1759
										SetNextItemOpen(toolOpen) -- 1760
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1761
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1762
												Columns(maxColumns, false) -- 1763
												for _index_0 = 1, #doraTools do -- 1764
													local tool = doraTools[_index_0] -- 1764
													local entryName, repo = tool.entryName, tool.repo -- 1765
													local displayName -- 1766
													if repo then -- 1766
														if zh then -- 1767
															displayName = repo.title.zh -- 1767
														else -- 1767
															displayName = repo.title.en -- 1767
														end -- 1767
													end -- 1766
													if displayName == nil then -- 1768
														displayName = entryName -- 1768
													end -- 1768
													if not allEntries.match(displayName) then -- 1769
														goto _continue_0 -- 1769
													end -- 1769
													if Button(displayName, Vec2(-1, 40)) then -- 1770
														enterDemoEntry(tool) -- 1771
													end -- 1770
													NextColumn() -- 1772
													::_continue_0:: -- 1765
												end -- 1764
												Columns(1, false) -- 1773
												opened = true -- 1774
											end) -- 1762
										end) -- 1761
										toolOpen = opened -- 1775
									end -- 1758
								end -- 1745
								::endEntry:: -- 1776
								if not allEntries.anyEntryMatched then -- 1777
									SetNextWindowBgAlpha(0) -- 1778
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1779
									Begin("Entries Not Found", displayWindowFlags, function() -- 1780
										Separator() -- 1781
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1782
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1783
										return Separator() -- 1784
									end) -- 1780
								end -- 1777
								Columns(1, false) -- 1785
								Dummy(Vec2(100, 80)) -- 1786
								return ScrollWhenDraggingOnVoid() -- 1787
							end) -- 1622
						end) -- 1621
					end) -- 1620
				end) -- 1619
			end) -- 1618
		end -- 1617
	end) -- 1511
end -- 1499
if not (App.platform == "Emscripten") then -- 1792
	local sceneModuleCache = moduleCache -- 1793
	moduleCache = { } -- 1794
	webStatus = oldRequire("Script.Dev.WebServer") -- 1795
	moduleCache = sceneModuleCache -- 1796
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1797
		thread(function() -- 1798
			wait(function() -- 1799
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1799
			end) -- 1799
			if App.webIDEEnabled then -- 1800
				return emit("AppWebView", "/ide/show", true) -- 1800
			end -- 1800
		end) -- 1798
	end -- 1797
end -- 1792
local _anon_func_9 = function(saved) -- 1823
	local _val_0 = saved.kind -- 1823
	return "local" == _val_0 or "discover" == _val_0 -- 1823
end -- 1823
local _anon_func_10 = function(saved) -- 1827
	local _val_0 = saved.activeTab -- 1827
	return "local" == _val_0 or "discover" == _val_0 -- 1827
end -- 1827
startMobileUI = function() -- 1802
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1803
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1804
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1805
	local getMobileFeedResources -- 1806
	do -- 1806
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1806
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1806
	end -- 1806
	local loadCachedCatalog -- 1807
	do -- 1807
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1807
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1807
	end -- 1807
	local getResourceInstallPath, getInstalledCatalogResource -- 1808
	do -- 1808
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1808
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1808
	end -- 1808
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1809
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1810
	local feedOptions = nil -- 1811
	local mobileLaunchErrors = { } -- 1812
	local withMobileLaunchErrors -- 1813
	withMobileLaunchErrors = function(items) -- 1813
		for _index_0 = 1, #items do -- 1814
			local item = items[_index_0] -- 1814
			item.launchError = mobileLaunchErrors[item.id] -- 1815
		end -- 1814
		return items -- 1816
	end -- 1813
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1817
	local loadRememberedMobileFeedState -- 1818
	loadRememberedMobileFeedState = function() -- 1818
		local raw = rememberedMobileFeedData -- 1819
		if not (type(raw) == "string" and raw ~= "") then -- 1820
			return -- 1820
		end -- 1820
		local ok, saved = pcall(json.decode, raw) -- 1821
		if not (ok and type(saved) == "table") then -- 1822
			return -- 1822
		end -- 1822
		if type(saved.id) == "string" and _anon_func_9(saved) then -- 1823
			local state = { -- 1824
				activeTab = saved.kind -- 1824
			} -- 1824
			state[saved.kind] = saved -- 1825
			return state -- 1826
		end -- 1823
		local state = { -- 1827
			activeTab = _anon_func_10(saved) and saved.activeTab or "local" -- 1827
		} -- 1827
		local _list_0 = { -- 1828
			"local", -- 1828
			"discover" -- 1828
		} -- 1828
		for _index_0 = 1, #_list_0 do -- 1828
			local kind = _list_0[_index_0] -- 1828
			local entry = saved[kind] -- 1829
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1830
				state[kind] = entry -- 1830
			end -- 1830
		end -- 1828
		return state -- 1831
	end -- 1818
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1832
		activeTab = "local" -- 1832
	} -- 1832
	local rememberMobileFeedEntry -- 1833
	rememberMobileFeedEntry = function(entry) -- 1833
		rememberedMobileFeedState.activeTab = entry.kind -- 1834
		rememberedMobileFeedState[entry.kind] = { -- 1836
			id = entry.id, -- 1836
			kind = entry.kind, -- 1837
			workDir = entry.workDir, -- 1838
			fileName = entry.fileName -- 1839
		} -- 1835
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1841
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1842
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1843
			rememberedMobileFeedData -- 1843
		}) -- 1843
	end -- 1833
	local restartMobileFeed -- 1844
	restartMobileFeed = function(entry) -- 1844
		if feedHost then -- 1845
			feedHost:removeFromParent(true) -- 1845
		end -- 1845
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1846
		local initialEntries = { } -- 1847
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1848
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1849
		feedOptions.initialEntries = initialEntries -- 1850
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1851
	end -- 1844
	local startMobilePlay -- 1852
	startMobilePlay = function(entry) -- 1852
		if HttpServer.wsConnectionCount > 0 then -- 1853
			return -- 1853
		end -- 1853
		if entry.needsBuild then -- 1854
			mobileLaunchErrors[entry.id] = useChinese and "请先在 IDE 中编译项目" or "Build the project in the IDE first" -- 1855
			restartMobileFeed(entry) -- 1856
			return -- 1857
		end -- 1854
		local originFeed = feedHost -- 1858
		if remixHost then -- 1859
			remixHost:removeFromParent(true) -- 1859
		end -- 1859
		remixHost = nil -- 1860
		mobileLaunchErrors[entry.id] = nil -- 1861
		entry.launchError = nil -- 1862
		local playActive = true -- 1863
		local restoreMobileFeed -- 1864
		restoreMobileFeed = function() -- 1864
			if not playActive then -- 1865
				return -- 1865
			end -- 1865
			playActive = false -- 1866
			allClear() -- 1867
			isInEntry = true -- 1868
			currentEntry = nil -- 1869
			return restartMobileFeed(entry) -- 1870
		end -- 1864
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1872
			onExit = function() -- 1872
				return restoreMobileFeed() -- 1872
			end, -- 1872
			onRuntimeError = function() -- 1873
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1874
				return restoreMobileFeed() -- 1875
			end -- 1873
		})) -- 1871
		return thread(function() -- 1877
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1881
			if not playActive then -- 1882
				return -- 1882
			end -- 1882
			if success then -- 1883
				if originFeed and originFeed.parent then -- 1884
					originFeed.visible = false -- 1884
				end -- 1884
				return -- 1885
			end -- 1883
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1886
			return restoreMobileFeed() -- 1887
		end) -- 1877
	end -- 1852
	feedOptions = { -- 1889
		takeReceivedFile = function() -- 1889
			if allEntries.pendingPackagePath then -- 1890
				local path = allEntries.pendingPackagePath -- 1891
				allEntries.pendingPackagePath = nil -- 1892
				return path -- 1893
			end -- 1890
			return App:takeReceivedFile() -- 1894
		end, -- 1889
		onSwitchMode = function() -- 1895
			if HttpServer.wsConnectionCount == 0 then -- 1895
				pendingUIMode = false -- 1895
			end -- 1895
		end, -- 1895
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1896
		getLocalEntries = function(importedProjectPath) -- 1897
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1898
			feedOptions.dirtyProjectPath = nil -- 1899
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1900
			local cached = loadCachedCatalog() -- 1901
			if cached.success and cached.snapshot then -- 1902
				for _index_0 = 1, #items do -- 1903
					local entry = items[_index_0] -- 1903
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1904
					if resource then -- 1905
						entry.resource = resource -- 1906
						entry.catalogCommit = cached.snapshot.commit -- 1907
					end -- 1905
				end -- 1903
			end -- 1902
			return items -- 1908
		end, -- 1897
		syncDiscover = function(onProgress, onDone, force) -- 1909
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1909
		end, -- 1909
		getDiscoverEntries = function() -- 1910
			local cached = loadCachedCatalog() -- 1911
			if not (cached.success and cached.snapshot) then -- 1912
				return { } -- 1912
			end -- 1912
			local items = { } -- 1913
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1914
			for _index_0 = 1, #_list_0 do -- 1914
				local resource = _list_0[_index_0] -- 1914
				local installed = lifecycle.isMobileResourceReady(resource) -- 1915
				local installPath = getResourceInstallPath(resource.id) -- 1916
				items[#items + 1] = { -- 1918
					id = resource.id, -- 1918
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1919
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1920
					kind = "discover", -- 1921
					bannerFile = resource.bannerPath, -- 1922
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1923
					sourceUrl = resource.versions[1].sources[1].url, -- 1924
					workDir = installed and installPath or nil, -- 1925
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1926
					installed = installed, -- 1927
					resource = resource, -- 1928
					catalogCommit = cached.snapshot.commit, -- 1929
					launchError = mobileLaunchErrors[resource.id] -- 1930
				} -- 1917
			end -- 1914
			return items -- 1932
		end, -- 1910
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1933
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1934
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1935
			end), repairIncomplete, isCanceled) -- 1934
		end, -- 1933
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1937
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1938
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1939
			end), isCanceled) -- 1938
		end, -- 1937
		createProject = function(name, language) -- 1941
			local result = projectCreate.createMobileProject(name, language) -- 1942
			if not result.success then -- 1943
				return result -- 1943
			end -- 1943
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1944
			for _index_0 = 1, #_list_0 do -- 1944
				local entry = _list_0[_index_0] -- 1944
				if entry.workDir == result.workDir then -- 1945
					return { -- 1946
						success = true, -- 1946
						entry = entry -- 1946
					} -- 1946
				end -- 1945
			end -- 1944
			return { -- 1947
				success = false, -- 1947
				error = "created-project-not-found" -- 1947
			} -- 1947
		end, -- 1941
		onPlay = function(entry) -- 1948
			return startMobilePlay(entry) -- 1948
		end, -- 1948
		onRemix = function(entry) -- 1949
			if HttpServer.wsConnectionCount > 0 then -- 1950
				return -- 1950
			end -- 1950
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1951
			local originFeed = feedHost -- 1952
			feedHost.visible = false -- 1953
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1955
				entry = entry, -- 1955
				onProjectChanged = function(current) -- 1956
					feedOptions.dirtyProjectPath = current.workDir -- 1956
				end, -- 1956
				onBack = function() -- 1957
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1958
						originFeed:emit("RestoreFeedEntry", entry) -- 1959
						originFeed.visible = true -- 1960
					end -- 1958
				end, -- 1957
				onPlay = function(current) -- 1961
					return startMobilePlay(current) -- 1961
				end -- 1961
			})) -- 1954
		end -- 1949
	} -- 1888
	return restartMobileFeed() -- 1964
end -- 1802
if mobileMode then -- 1966
	applyUIMode(true) -- 1966
end -- 1966
return _module_0 -- 1
