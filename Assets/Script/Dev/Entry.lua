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
local updateSceneCache = moduleCache -- 234
moduleCache = { } -- 235
local updater = oldRequire("Tools.SelfUpdater.Service") -- 236
moduleCache = updateSceneCache -- 237
local updateState = updater.getState() -- 239
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
_module_0.getUpdateState = function() -- 254
	return updateState -- 254
end -- 254
local checkForUpdates -- 255
checkForUpdates = function(manual, source) -- 255
	if manual == nil then -- 255
		manual = true -- 255
	end -- 255
	if source == nil then -- 255
		source = nil -- 255
	end -- 255
	if not manual then -- 256
		if App.platform == "Emscripten" then -- 257
			return false -- 257
		end -- 257
		if (config.lastUpdateCheck ~= nil) and os.difftime(os.time(), config.lastUpdateCheck) < 7 * 24 * 60 * 60 then -- 258
			return false -- 259
		end -- 258
	end -- 256
	return updater.checkForUpdates(source) -- 260
end -- 255
_module_0["checkForUpdates"] = checkForUpdates -- 255
thread(function() -- 261
	sleep(2) -- 262
	return checkForUpdates(false) -- 263
end) -- 261
local Set, Struct, LintYueGlobals -- 265
do -- 265
	local _obj_0 = require("Utils") -- 265
	Set, Struct, LintYueGlobals = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals -- 265
end -- 265
local yueext = yue.options.extension -- 266
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 268
local building = false -- 270
local getAllFiles -- 272
getAllFiles = function(path, exts, recursive) -- 272
	if recursive == nil then -- 272
		recursive = true -- 272
	end -- 272
	local filters = Set(exts) -- 273
	local files -- 274
	if recursive then -- 274
		files = Content:getAllFiles(path) -- 275
	else -- 277
		files = Content:getFiles(path) -- 277
	end -- 274
	local _accum_0 = { } -- 278
	local _len_0 = 1 -- 278
	for _index_0 = 1, #files do -- 278
		local file = files[_index_0] -- 278
		if not filters[Path:getExt(file)] then -- 279
			goto _continue_0 -- 279
		end -- 279
		_accum_0[_len_0] = file -- 280
		_len_0 = _len_0 + 1 -- 279
		::_continue_0:: -- 279
	end -- 278
	return _accum_0 -- 278
end -- 272
_module_0["getAllFiles"] = getAllFiles -- 272
local getFileEntries -- 282
getFileEntries = function(path, recursive, excludeFiles) -- 282
	if recursive == nil then -- 282
		recursive = true -- 282
	end -- 282
	if excludeFiles == nil then -- 282
		excludeFiles = nil -- 282
	end -- 282
	local entries = { } -- 283
	local excludes -- 284
	if excludeFiles then -- 284
		excludes = Set(excludeFiles) -- 285
	end -- 284
	local _list_0 = getAllFiles(path, { -- 286
		"lua", -- 286
		"xml", -- 286
		yueext, -- 286
		"tl" -- 286
	}, recursive) -- 286
	for _index_0 = 1, #_list_0 do -- 286
		local file = _list_0[_index_0] -- 286
		local entryName = Path:getName(file) -- 287
		if excludes and excludes[entryName] then -- 288
			goto _continue_0 -- 289
		end -- 288
		local fileName = Path:replaceExt(file, "") -- 290
		fileName = Path(path, fileName) -- 291
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
		local entry = { -- 295
			entryName = entryName, -- 295
			fileName = fileName -- 295
		} -- 295
		entries[#entries + 1] = entry -- 296
		::_continue_0:: -- 287
	end -- 286
	table.sort(entries, function(a, b) -- 297
		return a.entryName < b.entryName -- 297
	end) -- 297
	return entries -- 298
end -- 282
local allEntries = { -- 300
	dirty = { }, -- 300
	hasDirty = false, -- 300
	runId = 0 -- 300
} -- 300
allEntries.scanDir = function(path, dir, noPreview) -- 302
	if noPreview == nil then -- 302
		noPreview = false -- 302
	end -- 302
	local entries = { } -- 303
	if not dir:match("^%.") then -- 304
		local _list_0 = getAllFiles(Path(path, dir), { -- 305
			"lua", -- 305
			"xml", -- 305
			yueext, -- 305
			"tl", -- 305
			"wasm" -- 305
		}) -- 305
		for _index_0 = 1, #_list_0 do -- 305
			local file = _list_0[_index_0] -- 305
			if "init" == Path:getName(file):lower() then -- 306
				local fileName = Path:replaceExt(file, "") -- 307
				fileName = Path(path, dir, fileName) -- 308
				local projectPath = Path:getPath(fileName) -- 309
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 310
				local repo = nil -- 311
				if Content:exist(repoFile) then -- 312
					local str = Content:load(repoFile) -- 313
					if str then -- 313
						repo = json.decode(str) -- 314
					end -- 313
				end -- 312
				local entryName = Path:getName(projectPath) -- 315
				local entryAdded -- 316
				for _index_1 = 1, #entries do -- 316
					local _des_0 = entries[_index_1] -- 316
					local ename, efile = _des_0.entryName, _des_0.fileName -- 316
					if entryName == ename and efile == fileName then -- 317
						entryAdded = true -- 317
						break -- 317
					end -- 317
				end -- 316
				if entryAdded then -- 318
					goto _continue_0 -- 318
				end -- 318
				local examples = { } -- 319
				local tests = { } -- 320
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 321
				if Content:exist(examplePath) then -- 322
					local _list_1 = getFileEntries(examplePath) -- 323
					for _index_1 = 1, #_list_1 do -- 323
						local _des_0 = _list_1[_index_1] -- 323
						local name, ePath = _des_0.entryName, _des_0.fileName -- 323
						local entry = { -- 325
							entryName = name, -- 325
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 326
							workDir = projectPath -- 327
						} -- 324
						examples[#examples + 1] = entry -- 329
					end -- 323
				end -- 322
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 330
				if Content:exist(testPath) then -- 331
					local _list_1 = getFileEntries(testPath) -- 332
					for _index_1 = 1, #_list_1 do -- 332
						local _des_0 = _list_1[_index_1] -- 332
						local name, tPath = _des_0.entryName, _des_0.fileName -- 332
						local entry = { -- 334
							entryName = name, -- 334
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 335
							workDir = projectPath -- 336
						} -- 333
						tests[#tests + 1] = entry -- 338
					end -- 332
				end -- 331
				local entry = { -- 339
					entryName = entryName, -- 339
					fileName = fileName, -- 339
					projectPath = projectPath, -- 339
					examples = examples, -- 339
					tests = tests, -- 339
					repo = repo -- 339
				} -- 339
				local bannerFile -- 340
				do -- 340
					local _val_0 -- 340
					repeat -- 340
						if noPreview then -- 341
							_val_0 = nil -- 341
							break -- 341
						end -- 341
						if not config.showPreview then -- 342
							_val_0 = nil -- 342
							break -- 342
						end -- 342
						local f = Path(projectPath, ".dora", "banner.jpg") -- 343
						if Content:exist(f) then -- 344
							_val_0 = f -- 344
							break -- 344
						end -- 344
						f = Path(projectPath, ".dora", "banner.png") -- 345
						if Content:exist(f) then -- 346
							_val_0 = f -- 346
							break -- 346
						end -- 346
						f = Path(projectPath, "Image", "banner.jpg") -- 347
						if Content:exist(f) then -- 348
							_val_0 = f -- 348
							break -- 348
						end -- 348
						f = Path(projectPath, "Image", "banner.png") -- 349
						if Content:exist(f) then -- 350
							_val_0 = f -- 350
							break -- 350
						end -- 350
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 351
						if Content:exist(f) then -- 352
							_val_0 = f -- 352
							break -- 352
						end -- 352
					until true -- 340
					bannerFile = _val_0 -- 340
				end -- 340
				if bannerFile then -- 354
					entry.bannerFile = bannerFile -- 357
					thread(function() -- 358
						if Cache:loadAsync(bannerFile) then -- 359
							local bannerTex = Texture2D(bannerFile) -- 360
							if bannerTex then -- 360
								entry.bannerTex = bannerTex -- 361
							end -- 360
						end -- 359
					end) -- 358
				end -- 354
				entries[#entries + 1] = entry -- 362
			end -- 306
			::_continue_0:: -- 306
		end -- 305
	end -- 304
	return entries -- 363
end -- 302
local getProjectEntries -- 365
getProjectEntries = function(path, noPreview) -- 365
	if noPreview == nil then -- 365
		noPreview = false -- 365
	end -- 365
	local entries = { } -- 366
	local _list_0 = Content:getDirs(path) -- 367
	for _index_0 = 1, #_list_0 do -- 367
		local dir = _list_0[_index_0] -- 367
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 368
		for _index_1 = 1, #_list_1 do -- 368
			local entry = _list_1[_index_1] -- 368
			entries[#entries + 1] = entry -- 369
		end -- 368
	end -- 367
	table.sort(entries, function(a, b) -- 370
		return a.entryName < b.entryName -- 370
	end) -- 370
	return entries -- 371
end -- 365
_module_0["getProjectEntries"] = getProjectEntries -- 365
local gamesInDev -- 373
local doraTools -- 374
local isToolEntry -- 376
isToolEntry = function(entry) -- 376
	do -- 377
		local _type_0 = type(entry) -- 377
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 377
		if _tab_0 then -- 377
			local categories -- 377
			do -- 377
				local _obj_0 = entry.repo -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					categories = _obj_0.categories -- 377
				end -- 377
			end -- 377
			if categories ~= nil then -- 377
				for _index_0 = 1, #categories do -- 378
					local category = categories[_index_0] -- 378
					if "string" == type(category) and category:lower() == "tool" then -- 379
						return true -- 380
					end -- 379
				end -- 378
			end -- 377
		end -- 377
	end -- 377
	return false -- 376
end -- 376
local getEntryTitle -- 382
getEntryTitle = function(entry) -- 382
	local title -- 383
	do -- 383
		local repo = entry.repo -- 383
		if repo then -- 383
			if repo.title and "table" == type(repo.title) then -- 384
				if useChinese then -- 385
					title = repo.title.zh -- 385
				else -- 385
					title = repo.title.en -- 385
				end -- 385
			end -- 384
		end -- 383
	end -- 383
	if title ~= nil then -- 386
		return title -- 386
	else -- 386
		return entry.entryName -- 386
	end -- 386
end -- 382
allEntries.rebuildEntries = function() -- 388
	gamesInDev = { } -- 389
	do -- 390
		local _accum_0 = { } -- 390
		local _len_0 = 1 -- 390
		local _list_0 = allEntries.builtinTools -- 390
		for _index_0 = 1, #_list_0 do -- 390
			local tool = _list_0[_index_0] -- 390
			_accum_0[_len_0] = tool -- 390
			_len_0 = _len_0 + 1 -- 390
		end -- 390
		doraTools = _accum_0 -- 390
	end -- 390
	local _list_0 = allEntries.projectEntries -- 391
	for _index_0 = 1, #_list_0 do -- 391
		local entry = _list_0[_index_0] -- 391
		if isToolEntry(entry) then -- 392
			entry.kind = "tool" -- 393
			doraTools[#doraTools + 1] = entry -- 394
		else -- 396
			entry.kind = "game" -- 396
			gamesInDev[#gamesInDev + 1] = entry -- 397
		end -- 392
	end -- 391
	for i = #allEntries, 1, -1 do -- 398
		allEntries[i] = nil -- 399
	end -- 398
	for _index_0 = 1, #gamesInDev do -- 400
		local game = gamesInDev[_index_0] -- 400
		allEntries[#allEntries + 1] = game -- 401
		local examples, tests = game.examples, game.tests -- 402
		for _index_1 = 1, #examples do -- 403
			local example = examples[_index_1] -- 403
			allEntries[#allEntries + 1] = example -- 404
		end -- 403
		for _index_1 = 1, #tests do -- 405
			local test = tests[_index_1] -- 405
			allEntries[#allEntries + 1] = test -- 406
		end -- 405
	end -- 400
end -- 388
local updateEntries -- 408
updateEntries = function() -- 408
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 409
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 410
	local _list_0 = allEntries.builtinTools -- 411
	for _index_0 = 1, #_list_0 do -- 411
		local tool = _list_0[_index_0] -- 411
		tool.kind = "tool" -- 412
		tool.builtin = true -- 413
	end -- 411
	return allEntries.rebuildEntries() -- 414
end -- 408
allEntries.refreshDirtyProjects = function() -- 416
	if not allEntries.hasDirty then -- 417
		return -- 417
	end -- 417
	local dirty = allEntries.dirty -- 418
	allEntries.dirty = { } -- 419
	allEntries.hasDirty = false -- 420
	for projectPath in pairs(dirty) do -- 421
		do -- 422
			local _accum_0 = { } -- 422
			local _len_0 = 1 -- 422
			local _list_0 = allEntries.projectEntries -- 422
			for _index_0 = 1, #_list_0 do -- 422
				local entry = _list_0[_index_0] -- 422
				if entry.projectPath ~= projectPath then -- 422
					_accum_0[_len_0] = entry -- 422
					_len_0 = _len_0 + 1 -- 422
				end -- 422
			end -- 422
			allEntries.projectEntries = _accum_0 -- 422
		end -- 422
		local parentPath = Path:getPath(projectPath) -- 423
		local dir = Path:getFilename(projectPath) -- 424
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 425
		for _index_0 = 1, #_list_0 do -- 425
			local entry = _list_0[_index_0] -- 425
			if entry.projectPath == projectPath then -- 426
				do -- 427
					local _obj_0 = allEntries.projectEntries -- 427
					_obj_0[#_obj_0 + 1] = entry -- 427
				end -- 427
				break -- 428
			end -- 426
		end -- 425
	end -- 421
	table.sort(allEntries.projectEntries, function(a, b) -- 429
		return a.entryName < b.entryName -- 429
	end) -- 429
	return allEntries.rebuildEntries() -- 430
end -- 416
updateEntries() -- 432
local getLaunchEntries -- 434
getLaunchEntries = function(refresh) -- 434
	if refresh == nil then -- 434
		refresh = false -- 434
	end -- 434
	if refresh then -- 435
		updateEntries() -- 435
	end -- 435
	local toInfo -- 436
	toInfo = function(entry, kind) -- 436
		local file = entry.fileName -- 437
		local asProj = not entry.builtin -- 438
		return { -- 440
			name = getEntryTitle(entry), -- 440
			file = file, -- 441
			kind = kind, -- 442
			asProj = asProj -- 443
		} -- 439
	end -- 436
	local games -- 445
	do -- 445
		local _accum_0 = { } -- 445
		local _len_0 = 1 -- 445
		for _index_0 = 1, #gamesInDev do -- 445
			local game = gamesInDev[_index_0] -- 445
			_accum_0[_len_0] = toInfo(game, "game") -- 445
			_len_0 = _len_0 + 1 -- 445
		end -- 445
		games = _accum_0 -- 445
	end -- 445
	local tools -- 446
	do -- 446
		local _accum_0 = { } -- 446
		local _len_0 = 1 -- 446
		for _index_0 = 1, #doraTools do -- 446
			local tool = doraTools[_index_0] -- 446
			_accum_0[_len_0] = toInfo(tool, "tool") -- 446
			_len_0 = _len_0 + 1 -- 446
		end -- 446
		tools = _accum_0 -- 446
	end -- 446
	return { -- 447
		games = games, -- 447
		tools = tools -- 447
	} -- 447
end -- 434
_module_0["getLaunchEntries"] = getLaunchEntries -- 434
local _anon_func_1 = function(entry, useChinese) -- 464
	local _obj_0 = entry.repo -- 464
	if _obj_0 ~= nil then -- 464
		local _obj_1 = _obj_0.description -- 464
		if _obj_1 ~= nil then -- 464
			return _obj_1[useChinese and "zh" or "en"] -- 464
		end -- 464
		return nil -- 464
	end -- 464
	return nil -- 464
end -- 464
local getMobileFeedEntries -- 449
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 449
	if refresh == nil then -- 449
		refresh = false -- 449
	end -- 449
	if dirtyProjectPath == nil then -- 449
		dirtyProjectPath = nil -- 449
	end -- 449
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 450
		allEntries.dirty[dirtyProjectPath] = true -- 451
		allEntries.hasDirty = true -- 452
	end -- 450
	if refresh then -- 453
		allEntries.dirty = { } -- 454
		allEntries.hasDirty = false -- 455
		updateEntries() -- 456
	else -- 458
		allEntries.refreshDirtyProjects() -- 458
	end -- 453
	local items = { } -- 459
	for _index_0 = 1, #gamesInDev do -- 460
		local entry = gamesInDev[_index_0] -- 460
		items[#items + 1] = { -- 462
			id = entry.entryName, -- 462
			title = getEntryTitle(entry), -- 463
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 464
			fileName = entry.fileName, -- 465
			workDir = Path:getPath(entry.fileName), -- 466
			bannerFile = entry.bannerFile, -- 467
			kind = "local" -- 468
		} -- 461
	end -- 460
	return items -- 470
end -- 449
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 449
local doCompile -- 472
doCompile = function(minify) -- 472
	if building then -- 473
		return -- 473
	end -- 473
	building = true -- 474
	local startTime = App.runningTime -- 475
	local luaFiles = { } -- 476
	local yueFiles = { } -- 477
	local xmlFiles = { } -- 478
	local tlFiles = { } -- 479
	local writablePath = Content.writablePath -- 480
	local buildPaths = { -- 482
		{ -- 483
			Content.assetPath, -- 483
			Path(writablePath, ".build"), -- 484
			"" -- 485
		} -- 482
	} -- 481
	for _index_0 = 1, #gamesInDev do -- 488
		local _des_0 = gamesInDev[_index_0] -- 488
		local fileName = _des_0.fileName -- 488
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 489
		buildPaths[#buildPaths + 1] = { -- 491
			Path(writablePath, gamePath), -- 491
			Path(writablePath, ".build", gamePath), -- 492
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 493
			gamePath -- 494
		} -- 490
	end -- 488
	for _index_0 = 1, #buildPaths do -- 495
		local _des_0 = buildPaths[_index_0] -- 495
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 495
		if not Content:exist(inputPath) then -- 496
			goto _continue_0 -- 496
		end -- 496
		local _list_0 = getAllFiles(inputPath, { -- 498
			"lua" -- 498
		}) -- 498
		for _index_1 = 1, #_list_0 do -- 498
			local file = _list_0[_index_1] -- 498
			luaFiles[#luaFiles + 1] = { -- 500
				file, -- 500
				Path(inputPath, file), -- 501
				Path(outputPath, file), -- 502
				gamePath -- 503
			} -- 499
		end -- 498
		local _list_1 = getAllFiles(inputPath, { -- 505
			yueext -- 505
		}) -- 505
		for _index_1 = 1, #_list_1 do -- 505
			local file = _list_1[_index_1] -- 505
			yueFiles[#yueFiles + 1] = { -- 507
				file, -- 507
				Path(inputPath, file), -- 508
				Path(outputPath, Path:replaceExt(file, "lua")), -- 509
				searchPath, -- 510
				gamePath -- 511
			} -- 506
		end -- 505
		local _list_2 = getAllFiles(inputPath, { -- 513
			"xml" -- 513
		}) -- 513
		for _index_1 = 1, #_list_2 do -- 513
			local file = _list_2[_index_1] -- 513
			xmlFiles[#xmlFiles + 1] = { -- 515
				file, -- 515
				Path(inputPath, file), -- 516
				Path(outputPath, Path:replaceExt(file, "lua")), -- 517
				gamePath -- 518
			} -- 514
		end -- 513
		local _list_3 = getAllFiles(inputPath, { -- 520
			"tl" -- 520
		}) -- 520
		for _index_1 = 1, #_list_3 do -- 520
			local file = _list_3[_index_1] -- 520
			if not file:match(".*%.d%.tl$") then -- 521
				tlFiles[#tlFiles + 1] = { -- 523
					file, -- 523
					Path(inputPath, file), -- 524
					Path(outputPath, Path:replaceExt(file, "lua")), -- 525
					searchPath, -- 526
					gamePath -- 527
				} -- 522
			end -- 521
		end -- 520
		::_continue_0:: -- 496
	end -- 495
	local paths -- 529
	do -- 529
		local _tbl_0 = { } -- 529
		local _list_0 = { -- 530
			luaFiles, -- 530
			yueFiles, -- 530
			xmlFiles, -- 530
			tlFiles -- 530
		} -- 530
		for _index_0 = 1, #_list_0 do -- 530
			local files = _list_0[_index_0] -- 530
			for _index_1 = 1, #files do -- 531
				local file = files[_index_1] -- 531
				_tbl_0[Path:getPath(file[3])] = true -- 529
			end -- 529
		end -- 529
		paths = _tbl_0 -- 529
	end -- 529
	for path in pairs(paths) do -- 533
		Content:mkdir(path) -- 533
	end -- 533
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 535
	local fileCount = 0 -- 536
	local errors = { } -- 537
	for _index_0 = 1, #yueFiles do -- 538
		local _des_0 = yueFiles[_index_0] -- 538
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 538
		local filename -- 539
		if gamePath then -- 539
			filename = Path(gamePath, file) -- 539
		else -- 539
			filename = file -- 539
		end -- 539
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 540
			if not codes then -- 541
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 542
				return -- 543
			end -- 541
			local success, result = LintYueGlobals(codes, globals) -- 544
			local yueCodes -- 545
			if not success then -- 546
				yueCodes = Content:load(input) -- 547
				if yueCodes then -- 547
					local CheckTIC80Code -- 548
					do -- 548
						local _obj_0 = require("Utils") -- 548
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 548
					end -- 548
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 549
					if isTIC80 then -- 550
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 551
					end -- 550
				end -- 547
			end -- 546
			if success then -- 552
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 553
			else -- 555
				if yueCodes then -- 555
					local globalErrors = { } -- 556
					for _index_1 = 1, #result do -- 557
						local _des_1 = result[_index_1] -- 557
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 557
						local countLine = 1 -- 558
						local code = "" -- 559
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 560
							if countLine == line then -- 561
								code = lineCode -- 562
								break -- 563
							end -- 561
							countLine = countLine + 1 -- 564
						end -- 560
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 565
					end -- 557
					if #globalErrors > 0 then -- 566
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 566
					end -- 566
				else -- 568
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 568
				end -- 555
				if #errors == 0 then -- 569
					return codes -- 569
				end -- 569
			end -- 552
		end, function(success) -- 540
			if success then -- 570
				print("Yue compiled: " .. tostring(filename)) -- 570
			end -- 570
			fileCount = fileCount + 1 -- 571
		end) -- 540
	end -- 538
	thread(function() -- 573
		for _index_0 = 1, #xmlFiles do -- 574
			local _des_0 = xmlFiles[_index_0] -- 574
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 574
			local filename -- 575
			if gamePath then -- 575
				filename = Path(gamePath, file) -- 575
			else -- 575
				filename = file -- 575
			end -- 575
			local sourceCodes = Content:loadAsync(input) -- 576
			local codes, err = xml.tolua(sourceCodes) -- 577
			if not codes then -- 578
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 579
			else -- 581
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 581
				print("Xml compiled: " .. tostring(filename)) -- 582
			end -- 578
			fileCount = fileCount + 1 -- 583
		end -- 574
	end) -- 573
	thread(function() -- 585
		for _index_0 = 1, #tlFiles do -- 586
			local _des_0 = tlFiles[_index_0] -- 586
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 586
			local filename -- 587
			if gamePath then -- 587
				filename = Path(gamePath, file) -- 587
			else -- 587
				filename = file -- 587
			end -- 587
			local sourceCodes = Content:loadAsync(input) -- 588
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 589
			if not codes then -- 590
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 591
			else -- 593
				Content:saveAsync(output, codes) -- 593
				print("Teal compiled: " .. tostring(filename)) -- 594
			end -- 590
			fileCount = fileCount + 1 -- 595
		end -- 586
	end) -- 585
	return thread(function() -- 597
		wait(function() -- 598
			return fileCount == totalFiles -- 598
		end) -- 598
		if minify then -- 599
			local _list_0 = { -- 600
				yueFiles, -- 600
				xmlFiles, -- 600
				tlFiles -- 600
			} -- 600
			for _index_0 = 1, #_list_0 do -- 600
				local files = _list_0[_index_0] -- 600
				for _index_1 = 1, #files do -- 600
					local file = files[_index_1] -- 600
					local output = Path:replaceExt(file[3], "lua") -- 601
					luaFiles[#luaFiles + 1] = { -- 603
						Path:replaceExt(file[1], "lua"), -- 603
						output, -- 604
						output -- 605
					} -- 602
				end -- 600
			end -- 600
			local FormatMini -- 607
			do -- 607
				local _obj_0 = require("luaminify") -- 607
				FormatMini = _obj_0.FormatMini -- 607
			end -- 607
			for _index_0 = 1, #luaFiles do -- 608
				local _des_0 = luaFiles[_index_0] -- 608
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 608
				if Content:exist(input) then -- 609
					local sourceCodes = Content:loadAsync(input) -- 610
					local res, err = FormatMini(sourceCodes) -- 611
					if res then -- 612
						Content:saveAsync(output, res) -- 613
						print("Minify: " .. tostring(file)) -- 614
					else -- 616
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 616
					end -- 612
				else -- 618
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 618
				end -- 609
			end -- 608
			package.loaded["luaminify.FormatMini"] = nil -- 619
			package.loaded["luaminify.ParseLua"] = nil -- 620
			package.loaded["luaminify.Scope"] = nil -- 621
			package.loaded["luaminify.Util"] = nil -- 622
		end -- 599
		local errorMessage = table.concat(errors, "\n") -- 623
		if errorMessage ~= "" then -- 624
			print(errorMessage) -- 624
		end -- 624
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 625
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 626
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 627
		Content:clearPathCache() -- 628
		teal.clear() -- 629
		yue.clear() -- 630
		building = false -- 631
	end) -- 597
end -- 472
local doClean -- 633
doClean = function() -- 633
	if building then -- 634
		return -- 634
	end -- 634
	local writablePath = Content.writablePath -- 635
	local targetDir = Path(writablePath, ".build") -- 636
	Content:clearPathCache() -- 637
	if Content:remove(targetDir) then -- 638
		return print("Cleaned: " .. tostring(targetDir)) -- 639
	end -- 638
end -- 633
local screenScale = 2.0 -- 641
local scaleContent = false -- 642
local isInEntry = true -- 643
local currentEntry = nil -- 644
local footerWindow = nil -- 646
local entryWindow = nil -- 647
local testingThread = nil -- 648
local mobileMode = config.mobileFeed -- 649
local pendingUIMode = nil -- 650
local feedHost = nil -- 651
local remixHost = nil -- 652
local startMobileUI = nil -- 653
local webControlled = false -- 654
local mobileHosts = { } -- 655
local suspendedMobileHosts = { } -- 656
local trackMobileHost -- 658
trackMobileHost = function(host) -- 658
	do -- 659
		local _accum_0 = { } -- 659
		local _len_0 = 1 -- 659
		for _index_0 = 1, #mobileHosts do -- 659
			local item = mobileHosts[_index_0] -- 659
			if item.parent then -- 659
				_accum_0[_len_0] = item -- 659
				_len_0 = _len_0 + 1 -- 659
			end -- 659
		end -- 659
		mobileHosts = _accum_0 -- 659
	end -- 659
	mobileHosts[#mobileHosts + 1] = host -- 660
	return host -- 661
end -- 658
local clearMobileUI -- 663
clearMobileUI = function() -- 663
	for _index_0 = 1, #mobileHosts do -- 664
		local host = mobileHosts[_index_0] -- 664
		if host.parent then -- 665
			host:removeFromParent(true) -- 665
		end -- 665
	end -- 664
	mobileHosts = { } -- 666
	suspendedMobileHosts = { } -- 667
	feedHost = nil -- 668
	remixHost = nil -- 669
end -- 663
local syncWebIDEControl -- 671
syncWebIDEControl = function() -- 671
	local connected = HttpServer.wsConnectionCount > 0 -- 672
	if connected then -- 673
		pendingUIMode = nil -- 674
		for _index_0 = 1, #mobileHosts do -- 675
			local host = mobileHosts[_index_0] -- 675
			if not host.parent then -- 676
				goto _continue_0 -- 676
			end -- 676
			if not (suspendedMobileHosts[host] ~= nil) then -- 677
				suspendedMobileHosts[host] = host.visible -- 678
				host:emit("SuspendLocalUI") -- 679
			end -- 677
			host.visible = false -- 680
			::_continue_0:: -- 676
		end -- 675
	elseif webControlled then -- 681
		for host, visible in pairs(suspendedMobileHosts) do -- 682
			if host.parent then -- 683
				host.visible = visible -- 684
				host:emit("ResumeLocalUI") -- 685
			end -- 683
		end -- 682
		suspendedMobileHosts = { } -- 686
	end -- 673
	webControlled = connected -- 687
	return connected -- 688
end -- 671
local getUIMode -- 690
getUIMode = function() -- 690
	return mobileMode and "mobile" or "traditional" -- 690
end -- 690
_module_0["getUIMode"] = getUIMode -- 690
local setUIMode -- 691
setUIMode = function(mode) -- 691
	if not (("mobile" == mode or "traditional" == mode)) then -- 692
		return false -- 692
	end -- 692
	if HttpServer.wsConnectionCount > 0 then -- 693
		return false -- 693
	end -- 693
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 694
		return false -- 694
	end -- 694
	local wantsMobile = mode == "mobile" -- 695
	if wantsMobile == mobileMode then -- 696
		return true -- 696
	end -- 696
	if mobileMode then -- 697
		if not (feedHost and feedHost.visible) then -- 698
			return false -- 698
		end -- 698
		feedHost:emit("SwitchUIMode") -- 700
		return pendingUIMode == false -- 701
	end -- 697
	pendingUIMode = true -- 702
	return true -- 703
end -- 691
_module_0["setUIMode"] = setUIMode -- 691
local applyUIMode -- 705
applyUIMode = function(enabled) -- 705
	if HttpServer.wsConnectionCount > 0 then -- 707
		return false -- 707
	end -- 707
	if enabled then -- 708
		local ok, err = pcall(startMobileUI) -- 709
		if not ok then -- 710
			if feedHost then -- 711
				feedHost:removeFromParent(true) -- 711
			end -- 711
			feedHost = nil -- 712
			mobileMode = false -- 713
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 714
			return false -- 715
		end -- 710
	else -- 717
		clearMobileUI() -- 717
		updateEntries() -- 718
	end -- 708
	mobileMode = enabled -- 719
	config.mobileFeed = enabled -- 720
	return true -- 721
end -- 705
local setupEventHandlers = nil -- 723
local allClear -- 725
allClear = function() -- 725
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 727
		clearMobileUI() -- 727
	end -- 727
	local systemNodes = { } -- 730
	local preserveSystemNode -- 731
	preserveSystemNode = function(node) -- 731
		if systemNodes[node] then -- 732
			return -- 732
		end -- 732
		systemNodes[node] = true -- 733
		do -- 734
			local clip = tolua.cast(node, "ClipNode") -- 734
			if clip then -- 734
				if clip.stencil then -- 735
					preserveSystemNode(clip.stencil) -- 735
				end -- 735
			end -- 734
		end -- 734
		return node:eachChild(function(child) -- 736
			preserveSystemNode(child) -- 737
			return false -- 738
		end) -- 736
	end -- 731
	for _index_0 = 1, #Routine do -- 739
		local routine = Routine[_index_0] -- 739
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 741
			goto _continue_0 -- 742
		else -- 744
			Routine:remove(routine) -- 744
		end -- 740
		::_continue_0:: -- 740
	end -- 739
	for _index_0 = 1, #moduleCache do -- 745
		local module = moduleCache[_index_0] -- 745
		package.loaded[module] = nil -- 746
	end -- 745
	moduleCache = { } -- 747
	Director:cleanup() -- 748
	Entity:clear() -- 749
	Platformer.Data:clear() -- 750
	Platformer.UnitAction:clear() -- 751
	Audio:stopAll(0.2) -- 752
	Struct:clear() -- 753
	View.nearPlaneDistance = 0.1 -- 756
	View.farPlaneDistance = 10000 -- 757
	View.fieldOfView = 45 -- 758
	View.postEffect = nil -- 759
	View.scale = scaleContent and screenScale or 1 -- 760
	Director.clearColor = Color(0xff1a1a1a) -- 761
	teal.clear() -- 762
	yue.clear() -- 763
	preserveSystemNode(Director.systemUI) -- 766
	for _, item in pairs(ubox()) do -- 767
		local node = tolua.cast(item, "Node") -- 768
		if node then -- 768
			if not systemNodes[node] then -- 769
				node:cleanup() -- 769
			end -- 769
		end -- 768
	end -- 767
	collectgarbage() -- 770
	collectgarbage() -- 771
	Wasm:clear() -- 772
	thread(function() -- 773
		sleep() -- 774
		return Cache:removeUnused() -- 775
	end) -- 773
	setupEventHandlers() -- 776
	Content.searchPaths = searchPaths -- 777
	App.idled = true -- 778
end -- 725
_module_0["allClear"] = allClear -- 725
local clearTempFiles -- 780
clearTempFiles = function() -- 780
	local writablePath = Content.writablePath -- 781
	local uploadPath = Path(writablePath, ".upload") -- 782
	if Content:exist(uploadPath) then -- 783
		local _list_0 = Content:getDirs(uploadPath) -- 785
		for _index_0 = 1, #_list_0 do -- 785
			local dir = _list_0[_index_0] -- 785
			if dir ~= "resume" then -- 786
				Content:remove(Path(uploadPath, dir)) -- 786
			end -- 786
		end -- 785
		local _list_1 = Content:getFiles(uploadPath) -- 787
		for _index_0 = 1, #_list_1 do -- 787
			local file = _list_1[_index_0] -- 787
			Content:remove(Path(uploadPath, file)) -- 788
		end -- 787
	end -- 783
	if Content:exist(Path(writablePath, ".download")) then -- 789
		return Content:remove(Path(writablePath, ".download")) -- 789
	end -- 789
end -- 780
local waitForWebStart = true -- 791
thread(function() -- 792
	sleep(2) -- 793
	waitForWebStart = false -- 794
end) -- 792
local reloadDevEntry -- 796
reloadDevEntry = function() -- 796
	return thread(function() -- 796
		waitForWebStart = true -- 797
		doClean() -- 798
		allClear() -- 799
		_G.require = oldRequire -- 800
		Dora.require = oldRequire -- 801
		package.loaded["Script.Dev.Entry"] = nil -- 802
		package.loaded["Script.Dev.WebServer"] = nil -- 803
		return Director.systemScheduler:schedule(function() -- 804
			Routine:clear() -- 805
			oldRequire("Script.Dev.Entry") -- 806
			return true -- 807
		end) -- 804
	end) -- 796
end -- 796
local setWorkspace -- 809
setWorkspace = function(path) -- 809
	clearTempFiles() -- 810
	Content.writablePath = path -- 811
	config.writablePath = Content.writablePath -- 812
	return thread(function() -- 813
		sleep() -- 814
		return reloadDevEntry() -- 815
	end) -- 813
end -- 809
_module_0["setWorkspace"] = setWorkspace -- 809
local quit = false -- 817
local activeSearchId = 0 -- 819
local handleSearchFiles -- 821
handleSearchFiles = function(payload) -- 821
	if not payload then -- 822
		return -- 822
	end -- 822
	local id = payload.id -- 823
	if id == nil then -- 824
		return -- 824
	end -- 824
	activeSearchId = id -- 825
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 826
	if path == nil then -- 827
		path = "" -- 827
	end -- 827
	if exts == nil then -- 828
		exts = { } -- 828
	end -- 828
	if globs == nil then -- 829
		globs = { } -- 829
	end -- 829
	if extensionLevels == nil then -- 830
		extensionLevels = { } -- 830
	end -- 830
	if pattern == nil then -- 831
		pattern = "" -- 831
	end -- 831
	if pattern == "" then -- 833
		return -- 833
	end -- 833
	local useRegex = payload.useRegex == true -- 834
	local caseSensitive = payload.caseSensitive == true -- 835
	local includeContent = payload.includeContent ~= false -- 836
	local contentWindow = payload.contentWindow or 0 -- 837
	return Director.systemScheduler:schedule(once(function() -- 838
		local stopped = false -- 839
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 840
			if activeSearchId ~= id then -- 841
				stopped = true -- 842
				return true -- 843
			end -- 841
			emit("AppWS", "Send", json.encode({ -- 845
				name = "SearchFilesResult", -- 845
				id = id, -- 845
				result = result -- 845
			})) -- 844
			return false -- 847
		end) -- 840
		return emit("AppWS", "Send", json.encode({ -- 849
			name = "SearchFilesDone", -- 849
			id = id, -- 849
			stopped = stopped -- 849
		})) -- 848
	end)) -- 838
end -- 821
local stop -- 852
stop = function() -- 852
	if isInEntry then -- 853
		return false -- 853
	end -- 853
	allClear() -- 854
	isInEntry = true -- 855
	currentEntry = nil -- 856
	return true -- 857
end -- 852
_module_0["stop"] = stop -- 852
local getCurrentEntryStatus -- 859
getCurrentEntryStatus = function() -- 859
	local entry = currentEntry -- 860
	if not (entry and not isInEntry) then -- 861
		return { -- 861
			success = true, -- 861
			running = false, -- 861
			runId = allEntries.runId -- 861
		} -- 861
	end -- 861
	local status = { -- 863
		success = true, -- 863
		running = true, -- 864
		kind = entry.runKind or "file", -- 865
		runId = allEntries.runId, -- 866
		entryName = entry.entryName, -- 867
		fileName = entry.fileName -- 868
	} -- 862
	if entry.workDir then -- 869
		status.workDir = entry.workDir -- 869
	end -- 869
	if entry.projectRoot then -- 870
		status.projectRoot = entry.projectRoot -- 870
	end -- 870
	return status -- 871
end -- 859
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 859
local _anon_func_2 = function(_with_0) -- 890
	local _val_0 = App.platform -- 890
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 890
end -- 890
setupEventHandlers = function() -- 873
	local _with_0 = Director.postNode -- 874
	_with_0:onAppEvent(function(eventType) -- 875
		if "Quit" == eventType then -- 876
			quit = true -- 877
			allClear() -- 878
			return clearTempFiles() -- 879
		elseif "Shutdown" == eventType then -- 880
			return stop() -- 881
		end -- 875
	end) -- 875
	_with_0:onAppChange(function(settingName) -- 882
		if "Theme" == settingName then -- 883
			config.themeColor = App.themeColor:toARGB() -- 884
		elseif "Locale" == settingName then -- 885
			config.locale = App.locale -- 886
			updateLocale() -- 887
			return teal.clear(true) -- 888
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 889
			if _anon_func_2(_with_0) then -- 890
				if "FullScreen" == settingName then -- 892
					config.fullScreen = App.fullScreen -- 892
				elseif "Position" == settingName then -- 893
					local _obj_0 = App.winPosition -- 893
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 893
				elseif "Size" == settingName then -- 894
					local width, height -- 895
					do -- 895
						local _obj_0 = App.winSize -- 895
						width, height = _obj_0.width, _obj_0.height -- 895
					end -- 895
					config.winWidth = width -- 896
					config.winHeight = height -- 897
				end -- 891
			end -- 890
		end -- 882
	end) -- 882
	_with_0:onAppWS(function(event) -- 898
		if event.type == "Close" then -- 899
			if HttpServer.wsConnectionCount == 0 then -- 900
				updateEntries() -- 901
			end -- 900
			return -- 902
		end -- 899
		if not (event.type == "Receive") then -- 903
			return -- 903
		end -- 903
		local data = json.decode(event.msg) -- 904
		if not data then -- 905
			return -- 905
		end -- 905
		local _exp_0 = data.name -- 906
		if "SearchFiles" == _exp_0 then -- 907
			return handleSearchFiles(data) -- 908
		elseif "SearchFilesStop" == _exp_0 then -- 909
			if data.id == nil or data.id == activeSearchId then -- 910
				activeSearchId = 0 -- 911
			end -- 910
		end -- 906
	end) -- 898
	_with_0:slot("UpdateEntries", function() -- 912
		return updateEntries() -- 912
	end) -- 912
	return _with_0 -- 874
end -- 873
setupEventHandlers() -- 914
clearTempFiles() -- 915
local downloadFile -- 917
downloadFile = function(url, target) -- 917
	return Director.systemScheduler:schedule(once(function() -- 917
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 918
			if quit then -- 919
				return true -- 919
			end -- 919
			emit("AppWS", "Send", json.encode({ -- 921
				name = "Download", -- 921
				url = url, -- 921
				status = "downloading", -- 921
				progress = current / total -- 922
			})) -- 920
			return false -- 918
		end) -- 918
		return emit("AppWS", "Send", json.encode(success and { -- 925
			name = "Download", -- 925
			url = url, -- 925
			status = "completed", -- 925
			progress = 1.0 -- 926
		} or { -- 928
			name = "Download", -- 928
			url = url, -- 928
			status = "failed", -- 928
			progress = 0.0 -- 929
		})) -- 924
	end)) -- 917
end -- 917
_module_0["downloadFile"] = downloadFile -- 917
local _anon_func_3 = function(file, require, workDir) -- 941
	if workDir == nil then -- 941
		workDir = Path:getPath(file) -- 941
	end -- 941
	Content:insertSearchPath(1, workDir) -- 942
	local scriptPath = Path(workDir, "Script") -- 943
	if Content:exist(scriptPath) then -- 944
		Content:insertSearchPath(1, scriptPath) -- 945
	end -- 944
	local result = require(file) -- 946
	if "function" == type(result) then -- 947
		result() -- 947
	end -- 947
	return nil -- 948
end -- 941
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 977
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 977
	label.alignment = "Left" -- 978
	label.textWidth = width - fontSize -- 979
	label.text = err -- 980
	return label -- 977
end -- 977
local enterEntryAsync -- 932
enterEntryAsync = function(entry) -- 932
	allEntries.runId = allEntries.runId + 1 -- 933
	isInEntry = false -- 934
	App.idled = false -- 935
	emit(Profiler.EventName, "ClearLoader") -- 936
	currentEntry = entry -- 937
	local file, workDir = entry.fileName, entry.workDir -- 938
	sleep() -- 939
	return xpcall(_anon_func_3, function(msg) -- 948
		local err = debug.traceback(msg) -- 950
		Log("Error", err) -- 951
		allClear() -- 952
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 953
		local viewWidth, viewHeight -- 954
		do -- 954
			local _obj_0 = View.size -- 954
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 954
		end -- 954
		local width, height = viewWidth - 20, viewHeight - 20 -- 955
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 956
		Director.ui:addChild((function() -- 957
			local root = AlignNode() -- 957
			do -- 958
				local _obj_0 = App.bufferSize -- 958
				width, height = _obj_0.width, _obj_0.height -- 958
			end -- 958
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 959
			root:onAppChange(function(settingName) -- 960
				if settingName == "Size" then -- 960
					do -- 961
						local _obj_0 = App.bufferSize -- 961
						width, height = _obj_0.width, _obj_0.height -- 961
					end -- 961
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 962
				end -- 960
			end) -- 960
			root:addChild((function() -- 963
				local _with_0 = ScrollArea({ -- 964
					width = width, -- 964
					height = height, -- 965
					paddingX = 0, -- 966
					paddingY = 50, -- 967
					viewWidth = height, -- 968
					viewHeight = height -- 969
				}) -- 963
				root:onAlignLayout(function(w, h) -- 971
					_with_0.position = Vec2(w / 2, h / 2) -- 972
					w = w - 20 -- 973
					h = h - 20 -- 974
					_with_0.view.children.first.textWidth = w - fontSize -- 975
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 976
				end) -- 971
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 977
				return _with_0 -- 963
			end)()) -- 963
			return root -- 957
		end)()) -- 957
		return err -- 981
	end, file, require, workDir) -- 940
end -- 932
_module_0["enterEntryAsync"] = enterEntryAsync -- 932
local enterDemoEntry -- 983
enterDemoEntry = function(entry) -- 983
	return thread(function() -- 983
		return enterEntryAsync(entry) -- 983
	end) -- 983
end -- 983
local reloadCurrentEntry -- 985
reloadCurrentEntry = function() -- 985
	if currentEntry then -- 986
		allClear() -- 987
		return enterDemoEntry(currentEntry) -- 988
	end -- 986
end -- 985
Director.clearColor = Color(0xff1a1a1a) -- 990
local descColor = Color(0xffa1a1a1) -- 991
local extraOperations -- 994
do -- 994
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 995
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 996
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 997
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 998
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 999
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 1000
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1001
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 1002
	local isOSSLicenseExist = Content:exist("LICENSES") -- 1003
	local ossLicenses = nil -- 1004
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 1005
	local failedSetFolder = false -- 1006
	local statusFlags = { -- 1007
		"NoResize", -- 1007
		"NoMove", -- 1007
		"NoCollapse", -- 1007
		"AlwaysAutoResize", -- 1007
		"NoSavedSettings" -- 1007
	} -- 1007
	extraOperations = function() -- 1014
		local zh = useChinese -- 1015
		if isDesktop then -- 1016
			local alwaysOnTop = config.alwaysOnTop -- 1017
			do -- 1018
				local changed -- 1018
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1018
				if changed then -- 1018
					App.alwaysOnTop = alwaysOnTop -- 1019
					config.alwaysOnTop = alwaysOnTop -- 1020
				end -- 1018
			end -- 1018
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1021
			do -- 1022
				local changed -- 1022
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1022
				if changed then -- 1022
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1023
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1024
				end -- 1022
			end -- 1022
			SameLine() -- 1025
			TextColored(descColor, "(?)") -- 1026
			if IsItemHovered() then -- 1027
				BeginTooltip(function() -- 1028
					return PushTextWrapPos(360, function() -- 1029
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1030
					end) -- 1029
				end) -- 1028
			end -- 1027
		end -- 1016
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1045
		do -- 1049
			local changed -- 1049
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1049
			if changed then -- 1049
				config.showPreview = showPreview -- 1050
				updateEntries() -- 1051
				if not showPreview then -- 1052
					thread(function() -- 1053
						collectgarbage() -- 1054
						return Cache:removeUnused("Texture") -- 1055
					end) -- 1053
				end -- 1052
			end -- 1049
		end -- 1049
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1056
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1057
			if changed then -- 1057
				config.webIDEEnabled = webIDEEnabled -- 1058
				App.webIDEEnabled = webIDEEnabled -- 1059
			end -- 1057
		end -- 1056
		do -- 1060
			local themeColor = App.themeColor -- 1061
			local writablePath = config.writablePath -- 1062
			SeparatorText(zh and "工作目录" or "Workspace") -- 1063
			PushTextWrapPos(400, function() -- 1064
				return TextColored(themeColor, writablePath) -- 1065
			end) -- 1064
			if not isDesktop then -- 1066
				goto skipSetting -- 1066
			end -- 1066
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1067
			if Button(zh and "改变目录" or "Set Folder") then -- 1068
				App:openFileDialog(true, function(path) -- 1069
					if path == "" then -- 1070
						return -- 1070
					end -- 1070
					local relPath = Path:getRelative(Content.assetPath, path) -- 1071
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1072
						return setWorkspace(path) -- 1073
					else -- 1075
						failedSetFolder = true -- 1075
					end -- 1072
				end) -- 1069
			end -- 1068
			if failedSetFolder then -- 1076
				failedSetFolder = false -- 1077
				OpenPopup(popupName) -- 1078
			end -- 1076
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1079
			BeginPopupModal(popupName, statusFlags, function() -- 1080
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1081
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1082
					return CloseCurrentPopup() -- 1083
				end -- 1082
			end) -- 1080
			SameLine() -- 1084
			if Button(zh and "使用默认" or "Use Default") then -- 1085
				setWorkspace(Content.appPath) -- 1086
			end -- 1085
			Separator() -- 1087
			::skipSetting:: -- 1088
		end -- 1060
		renderAgentStorage(zh) -- 1089
		if isOSSLicenseExist then -- 1090
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1091
				if not ossLicenses then -- 1092
					local licenseText = Content:load("LICENSES") -- 1093
					if licenseText then -- 1093
						local GSplit -- 1094
						do -- 1094
							local _obj_0 = require("Utils") -- 1094
							GSplit = _obj_0.GSplit -- 1094
						end -- 1094
						ossLicenses = { } -- 1095
						licenseText = licenseText:gsub("\r\n", "\n") -- 1096
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1097
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1098
							if name then -- 1098
								ossLicenses[#ossLicenses + 1] = { -- 1099
									name, -- 1099
									text -- 1099
								} -- 1099
							end -- 1098
						end -- 1097
					end -- 1093
				end -- 1092
				if ossLicenses then -- 1100
					OpenPopup(ossLicensePopup) -- 1100
				end -- 1100
			end -- 1091
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1101
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1102
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1103
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1104
				return BeginPopupModal(ossLicensePopup, true, { -- 1107
					"NoSavedSettings" -- 1107
				}, function() -- 1108
					for _index_0 = 1, #ossLicenses do -- 1109
						local _des_0 = ossLicenses[_index_0] -- 1109
						local firstLine, text = _des_0[1], _des_0[2] -- 1109
						local name, license = firstLine:match("(.+): (.+)") -- 1111
						if name then -- 1111
							TextColored(themeColor, name) -- 1112
							SameLine() -- 1113
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1114
								return TextWrapped(text) -- 1114
							end) -- 1114
						end -- 1111
					end -- 1109
				end) -- 1104
			end) -- 1104
		end -- 1090
		if not App.debugging then -- 1117
			return -- 1117
		end -- 1117
		return TreeNode(zh and "开发操作" or "Development", function() -- 1118
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1119
				OpenPopup("build") -- 1119
			end -- 1119
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1120
				return BeginPopup("build", function() -- 1120
					if Selectable(zh and "编译" or "Compile") then -- 1121
						doCompile(false) -- 1121
					end -- 1121
					Separator() -- 1122
					if Selectable(zh and "压缩" or "Minify") then -- 1123
						doCompile(true) -- 1123
					end -- 1123
					Separator() -- 1124
					if Selectable(zh and "清理" or "Clean") then -- 1125
						return doClean() -- 1125
					end -- 1125
				end) -- 1120
			end) -- 1120
			if isInEntry then -- 1126
				if waitForWebStart then -- 1127
					BeginDisabled(function() -- 1128
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1128
					end) -- 1128
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1129
					reloadDevEntry() -- 1130
				end -- 1127
			end -- 1126
			do -- 1131
				local changed -- 1131
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1131
				if changed then -- 1131
					View.scale = scaleContent and screenScale or 1 -- 1132
				end -- 1131
			end -- 1131
			do -- 1133
				local changed -- 1133
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1133
				if changed then -- 1133
					config.engineDev = engineDev -- 1134
				end -- 1133
			end -- 1133
			do -- 1135
				local changed -- 1135
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1135
				if changed then -- 1135
					config.webIDETourCompleted = webIDETourCompleted -- 1136
				end -- 1135
			end -- 1135
			if testingThread then -- 1137
				return BeginDisabled(function() -- 1138
					return Button(zh and "开始自动测试" or "Test automatically") -- 1138
				end) -- 1138
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1139
				testingThread = thread(function() -- 1140
					local _ <close> = setmetatable({ }, { -- 1141
						__close = function() -- 1141
							allClear() -- 1142
							testingThread = nil -- 1143
							isInEntry = true -- 1144
							currentEntry = nil -- 1145
							return print("Testing done!") -- 1146
						end -- 1141
					}) -- 1141
					for _, entry in ipairs(allEntries) do -- 1147
						allClear() -- 1148
						print("Start " .. tostring(entry.entryName)) -- 1149
						enterDemoEntry(entry) -- 1150
						sleep(2) -- 1151
						print("Stop " .. tostring(entry.entryName)) -- 1152
					end -- 1147
				end) -- 1140
			end -- 1137
		end) -- 1118
	end -- 1014
end -- 994
local icon = Path("Script", "Dev", "icon_s.png") -- 1154
local iconTex = nil -- 1155
thread(function() -- 1156
	if Cache:loadAsync(icon) then -- 1156
		iconTex = Texture2D(icon) -- 1156
	end -- 1156
end) -- 1156
local webStatus = nil -- 1158
local urlClicked = nil -- 1159
local authCode = string.format("%06d", math.random(0, 999999)) -- 1161
local authCodeTTL = 30.0 -- 1163
_module_0.getAuthCode = function() -- 1164
	return authCode -- 1164
end -- 1164
_module_0.invalidateAuthCode = function() -- 1165
	authCode = string.format("%06d", math.random(0, 999999)) -- 1166
	authCodeTTL = 30.0 -- 1167
end -- 1165
local AuthSession -- 1169
do -- 1169
	local pending = nil -- 1170
	local session = nil -- 1171
	AuthSession = { -- 1173
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1173
			pending = { -- 1175
				sessionId = sessionId, -- 1175
				confirmCode = confirmCode, -- 1176
				expiresAt = expiresAt, -- 1177
				ttl = ttl, -- 1178
				approved = false -- 1179
			} -- 1174
		end, -- 1173
		getPending = function() -- 1181
			return pending -- 1181
		end, -- 1181
		approvePending = function(sessionId) -- 1183
			if pending and pending.sessionId == sessionId then -- 1184
				pending.approved = true -- 1185
				return true -- 1186
			end -- 1184
			return false -- 1187
		end, -- 1183
		clearPending = function() -- 1189
			pending = nil -- 1189
		end, -- 1189
		setSession = function(sessionId, sessionSecret) -- 1191
			session = { -- 1193
				sessionId = sessionId, -- 1193
				sessionSecret = sessionSecret -- 1194
			} -- 1192
		end, -- 1191
		getSession = function() -- 1196
			return session -- 1196
		end -- 1196
	} -- 1172
end -- 1169
_module_0["AuthSession"] = AuthSession -- 1169
local transparant = Color(0x0) -- 1199
local windowFlags = { -- 1200
	"NoTitleBar", -- 1200
	"NoResize", -- 1200
	"NoMove", -- 1200
	"NoCollapse", -- 1200
	"NoSavedSettings", -- 1200
	"NoFocusOnAppearing", -- 1200
	"NoBringToFrontOnFocus" -- 1200
} -- 1200
local statusFlags = { -- 1209
	"NoTitleBar", -- 1209
	"NoResize", -- 1209
	"NoMove", -- 1209
	"NoCollapse", -- 1209
	"AlwaysAutoResize", -- 1209
	"NoSavedSettings" -- 1209
} -- 1209
local displayWindowFlags = { -- 1217
	"NoDecoration", -- 1217
	"NoSavedSettings", -- 1217
	"NoMove", -- 1217
	"NoScrollWithMouse", -- 1217
	"AlwaysAutoResize", -- 1217
	"NoFocusOnAppearing" -- 1217
} -- 1217
local _anon_func_5 = function(allEntries, currentIndex) -- 1290
	if currentIndex > 1 then -- 1290
		return allEntries[currentIndex - 1] -- 1291
	else -- 1293
		return allEntries[#allEntries] -- 1293
	end -- 1290
end -- 1290
local _anon_func_6 = function(allEntries, currentIndex) -- 1297
	if currentIndex < #allEntries then -- 1297
		return allEntries[currentIndex + 1] -- 1298
	else -- 1300
		return allEntries[1] -- 1300
	end -- 1297
end -- 1297
do -- 1226
	local gamepadInputWindowFlags = { -- 1227
		"NoDecoration", -- 1227
		"NoSavedSettings", -- 1227
		"NoMove", -- 1227
		"NoScrollbar", -- 1227
		"NoScrollWithMouse", -- 1227
		"NoFocusOnAppearing", -- 1227
		"NoBringToFrontOnFocus" -- 1227
	} -- 1227
	local initFooter = true -- 1236
	local gamepadInputFocused = false -- 1237
	footerWindow = threadLoop(function() -- 1238
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1239
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1240
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1241
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1242
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1243
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1244
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1245
		if mobileMode then -- 1246
			return -- 1246
		end -- 1246
		local zh = useChinese -- 1247
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1248
		if authCodeTTL <= 0 then -- 1249
			authCodeTTL = 30.0 -- 1250
			authCode = string.format("%06d", math.random(0, 999999)) -- 1251
		end -- 1249
		if HttpServer.wsConnectionCount > 0 then -- 1252
			return -- 1253
		end -- 1252
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1254
			if App.platform == "Emscripten" then -- 1255
				stop() -- 1257
			else -- 1259
				allClear() -- 1259
				App.devMode = false -- 1260
				App:shutdown() -- 1261
			end -- 1255
		end -- 1254
		do -- 1262
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1263
			if ctrl and Keyboard:isKeyDown("Q") then -- 1264
				stop() -- 1265
			end -- 1264
			if ctrl and Keyboard:isKeyDown("Z") then -- 1266
				reloadCurrentEntry() -- 1267
			end -- 1266
			if ctrl and Keyboard:isKeyDown(",") then -- 1268
				if showFooter then -- 1269
					showStats = not showStats -- 1269
				else -- 1269
					showStats = true -- 1269
				end -- 1269
				showFooter = true -- 1270
				config.showFooter = showFooter -- 1271
				config.showStats = showStats -- 1272
			end -- 1268
			if ctrl and Keyboard:isKeyDown(".") then -- 1273
				if showFooter then -- 1274
					showConsole = not showConsole -- 1274
				else -- 1274
					showConsole = true -- 1274
				end -- 1274
				showFooter = true -- 1275
				config.showFooter = showFooter -- 1276
				config.showConsole = showConsole -- 1277
			end -- 1273
			if ctrl and Keyboard:isKeyDown("/") then -- 1278
				showFooter = not showFooter -- 1279
				config.showFooter = showFooter -- 1280
			end -- 1278
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1281
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1282
			local currentIndex = nil -- 1283
			for i, entry in ipairs(allEntries) do -- 1284
				if currentEntry == entry then -- 1285
					currentIndex = i -- 1286
				end -- 1285
			end -- 1284
			if left then -- 1287
				allClear() -- 1288
				if currentIndex == nil then -- 1289
					currentIndex = #allEntries + 1 -- 1289
				end -- 1289
				enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1290
			end -- 1287
			if right then -- 1294
				allClear() -- 1295
				if currentIndex == nil then -- 1296
					currentIndex = 0 -- 1296
				end -- 1296
				enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1297
			end -- 1294
		end -- 1262
		if not showEntry then -- 1301
			return -- 1301
		end -- 1301
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1303
			reloadDevEntry() -- 1307
		end -- 1303
		if initFooter then -- 1308
			initFooter = false -- 1309
		end -- 1308
		local width, height -- 1311
		do -- 1311
			local _obj_0 = App.visualSize -- 1311
			width, height = _obj_0.width, _obj_0.height -- 1311
		end -- 1311
		if isInEntry then -- 1312
			gamepadInputFocused = false -- 1313
		else -- 1315
			SetNextWindowBgAlpha(0.0) -- 1315
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1316
			SetNextWindowPos(Vec2.zero, "Always") -- 1317
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1318
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1319
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1320
						if not gamepadInputFocused then -- 1321
							SetWindowFocus("DoraGamepadInput") -- 1322
							gamepadInputFocused = true -- 1323
						end -- 1321
					end) -- 1320
				end) -- 1319
			end) -- 1318
		end -- 1312
		if isInEntry or showFooter then -- 1325
			SetNextWindowSize(Vec2(width, 50)) -- 1326
			SetNextWindowPos(Vec2(0, height - 50)) -- 1327
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1328
				return PushStyleVar("WindowRounding", 0, function() -- 1329
					return Begin("Footer", windowFlags, function() -- 1330
						Separator() -- 1331
						if iconTex then -- 1332
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1333
								showStats = not showStats -- 1334
								config.showStats = showStats -- 1335
							end -- 1333
							SameLine() -- 1336
							if Button(">_", Vec2(30, 30)) then -- 1337
								showConsole = not showConsole -- 1338
								config.showConsole = showConsole -- 1339
							end -- 1337
						end -- 1332
						if isInEntry and updateState.available then -- 1340
							SameLine() -- 1341
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1342
								allClear() -- 1343
								enterDemoEntry({ -- 1345
									entryName = "SelfUpdater", -- 1345
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1346
								}) -- 1344
							end -- 1342
						end -- 1340
						if not isInEntry then -- 1347
							SameLine() -- 1348
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1349
							local currentIndex = nil -- 1350
							for i, entry in ipairs(allEntries) do -- 1351
								if currentEntry == entry then -- 1352
									currentIndex = i -- 1353
								end -- 1352
							end -- 1351
							if currentIndex then -- 1354
								if currentIndex > 1 then -- 1355
									SameLine() -- 1356
									if Button("<<", Vec2(30, 30)) then -- 1357
										allClear() -- 1358
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1359
									end -- 1357
								end -- 1355
								if currentIndex < #allEntries then -- 1360
									SameLine() -- 1361
									if Button(">>", Vec2(30, 30)) then -- 1362
										allClear() -- 1363
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1364
									end -- 1362
								end -- 1360
							end -- 1354
							SameLine() -- 1365
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1366
								reloadCurrentEntry() -- 1367
							end -- 1366
							if back then -- 1368
								allClear() -- 1369
								isInEntry = true -- 1370
								currentEntry = nil -- 1371
							end -- 1368
						end -- 1347
					end) -- 1330
				end) -- 1329
			end) -- 1328
		end -- 1325
		if isInEntry then -- 1373
			local showURL = true -- 1374
			local webIDEWidth -- 1375
			do -- 1375
				local base -- 1376
				if updateState.available then -- 1376
					base = 460 -- 1376
				else -- 1376
					base = 360 -- 1376
				end -- 1376
				local extra = 35 -- 1377
				webIDEWidth = base + extra -- 1378
			end -- 1375
			if width < webIDEWidth then -- 1379
				showURL = false -- 1379
			end -- 1379
			SetNextWindowBgAlpha(0.0) -- 1380
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1381
			Begin("Web IDE", displayWindowFlags, function() -- 1382
				local pending = AuthSession.getPending() -- 1383
				local hovered = false -- 1384
				if not pending and showURL then -- 1385
					do -- 1386
						local url -- 1386
						if webStatus ~= nil then -- 1386
							url = webStatus.url -- 1386
						end -- 1386
						if url then -- 1386
							if isDesktop and not config.fullScreen then -- 1387
								if urlClicked then -- 1388
									BeginDisabled(function() -- 1389
										return Button(url) -- 1389
									end) -- 1389
								elseif Button(url) then -- 1390
									urlClicked = once(function() -- 1391
										return sleep(5) -- 1391
									end) -- 1391
									App:openURL("http://localhost:8866") -- 1392
								end -- 1388
							else -- 1394
								TextColored(descColor, url) -- 1394
							end -- 1387
						else -- 1396
							TextColored(descColor, zh and '不可用' or 'not available') -- 1396
						end -- 1386
					end -- 1386
					hovered = IsItemHovered() -- 1397
				else -- 1399
					TextColored(descColor, "(?)") -- 1399
					hovered = IsItemHovered() -- 1400
				end -- 1385
				SameLine() -- 1401
				local themeColor = App.themeColor -- 1402
				if pending then -- 1403
					if not pending.approved then -- 1404
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1405
						local ttl = pending.ttl or 1 -- 1406
						PushStyleColor("Text", themeColor, function() -- 1407
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1408
							hovered = hovered or IsItemHovered() -- 1409
						end) -- 1407
						SameLine() -- 1410
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1411
							AuthSession.approvePending(pending.sessionId) -- 1412
						end -- 1411
						if hovered then -- 1413
							return BeginTooltip(function() -- 1414
								return PushTextWrapPos(280, function() -- 1415
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1416
								end) -- 1415
							end) -- 1414
						end -- 1413
					end -- 1404
				else -- 1418
					PushStyleColor("Text", themeColor, function() -- 1418
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1419
						hovered = hovered or IsItemHovered() -- 1420
					end) -- 1418
					if hovered then -- 1421
						return BeginTooltip(function() -- 1422
							return PushTextWrapPos(280, function() -- 1423
								local url -- 1424
								if webStatus ~= nil then -- 1424
									url = webStatus.url -- 1424
								end -- 1424
								if url then -- 1424
									local address -- 1425
									if showURL then -- 1425
										address = "Web IDE" -- 1425
									else -- 1425
										address = url -- 1425
									end -- 1425
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1426
								else -- 1428
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1428
								end -- 1424
							end) -- 1423
						end) -- 1422
					end -- 1421
				end -- 1403
			end) -- 1382
		end -- 1373
		if not isInEntry then -- 1429
			SetNextWindowSize(Vec2(50, 50)) -- 1430
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1431
			PushStyleColor("WindowBg", transparant, function() -- 1432
				return Begin("Show", displayWindowFlags, function() -- 1432
					if width >= 370 then -- 1433
						local changed -- 1434
						changed, showFooter = Checkbox("##dev", showFooter) -- 1434
						if changed then -- 1434
							config.showFooter = showFooter -- 1435
						end -- 1434
					end -- 1433
				end) -- 1432
			end) -- 1432
		end -- 1429
		if isInEntry or showFooter then -- 1437
			if showStats then -- 1438
				PushStyleVar("WindowRounding", 0, function() -- 1439
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1440
					SetNextWindowSize(Vec2(0, height - 50)) -- 1441
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1442
					config.showStats = showStats -- 1443
				end) -- 1439
			end -- 1438
			if showConsole then -- 1444
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1445
				return PushStyleVar("WindowRounding", 6, function() -- 1446
					return ShowConsole() -- 1447
				end) -- 1446
			end -- 1444
		end -- 1437
	end) -- 1238
end -- 1226
do -- 1450
	local MaxWidth <const> = 960 -- 1451
	local toolOpen = false -- 1453
	local filterText = nil -- 1454
	allEntries.anyEntryMatched = false -- 1455
	allEntries.match = function(name) -- 1456
		local res = not filterText or name:lower():match(filterText) -- 1457
		if res then -- 1458
			allEntries.anyEntryMatched = true -- 1458
		end -- 1458
		return res -- 1459
	end -- 1456
	allEntries.thinSep = function() -- 1461
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1461
			return ImGui.SeparatorText("") -- 1461
		end) -- 1461
	end -- 1461
	entryWindow = threadLoop(function() -- 1462
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1463
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1464
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1465
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1466
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1467
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1468
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1469
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1470
		local connected = syncWebIDEControl() -- 1471
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1473
			if not allEntries.pendingPackagePath then -- 1474
				local path = App:takeReceivedFile() -- 1475
				if path ~= "" then -- 1476
					allEntries.pendingPackagePath = path -- 1476
				end -- 1476
			end -- 1474
			if allEntries.pendingPackagePath then -- 1477
				pendingUIMode = true -- 1477
			end -- 1477
		end -- 1473
		if (pendingUIMode ~= nil) then -- 1479
			local nextMode = pendingUIMode -- 1480
			pendingUIMode = nil -- 1481
			applyUIMode(nextMode) -- 1482
		end -- 1479
		if mobileMode and not connected then -- 1483
			if isInEntry and not feedHost then -- 1484
				applyUIMode(true) -- 1484
			end -- 1484
			return -- 1485
		end -- 1483
		if App.fpsLimited ~= config.fpsLimited then -- 1486
			config.fpsLimited = App.fpsLimited -- 1487
		end -- 1486
		if App.targetFPS ~= config.targetFPS then -- 1488
			config.targetFPS = App.targetFPS -- 1489
		end -- 1488
		if View.vsync ~= config.vsync then -- 1490
			config.vsync = View.vsync -- 1491
		end -- 1490
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1492
			config.fixedFPS = Director.scheduler.fixedFPS -- 1493
		end -- 1492
		if Director.profilerSending ~= config.webProfiler then -- 1494
			config.webProfiler = Director.profilerSending -- 1495
		end -- 1494
		if urlClicked then -- 1496
			local _, result = coroutine.resume(urlClicked) -- 1497
			if result then -- 1498
				coroutine.close(urlClicked) -- 1499
				urlClicked = nil -- 1500
			end -- 1498
		end -- 1496
		if not isInEntry then -- 1501
			return -- 1501
		end -- 1501
		local zh = useChinese -- 1502
		local themeColor = App.themeColor -- 1503
		if connected then -- 1504
			local width, height -- 1505
			do -- 1505
				local _obj_0 = App.visualSize -- 1505
				width, height = _obj_0.width, _obj_0.height -- 1505
			end -- 1505
			SetNextWindowBgAlpha(0.5) -- 1506
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1507
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1508
				Separator() -- 1509
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1510
				if iconTex then -- 1511
					Image(icon, Vec2(24, 24)) -- 1512
					SameLine() -- 1513
				end -- 1511
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1514
				TextColored(descColor, slogon) -- 1515
				return Separator() -- 1516
			end) -- 1508
			return -- 1517
		end -- 1504
		if not showEntry then -- 1518
			return -- 1518
		end -- 1518
		local fullWidth, height -- 1520
		do -- 1520
			local _obj_0 = App.visualSize -- 1520
			fullWidth, height = _obj_0.width, _obj_0.height -- 1520
		end -- 1520
		local width = math.min(MaxWidth, fullWidth) -- 1521
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1522
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1523
		SetNextWindowPos(Vec2.zero) -- 1524
		SetNextWindowBgAlpha(0) -- 1525
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1526
		do -- 1527
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1528
				return Begin("Dora Dev", windowFlags, function() -- 1529
					Dummy(Vec2(fullWidth - 20, 0)) -- 1530
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1531
					SameLine() -- 1532
					if Button(zh and "Go 模式" or "Go Mode") then -- 1533
						setUIMode("mobile") -- 1534
					end -- 1533
					if fullWidth >= 540 then -- 1535
						SameLine() -- 1536
						Dummy(Vec2(fullWidth - 540, 0)) -- 1537
						SameLine() -- 1538
						SetNextItemWidth(zh and -95 or -140) -- 1539
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1540
							"AutoSelectAll" -- 1540
						}) then -- 1540
							config.filter = filterBuf.text -- 1541
						end -- 1540
						SameLine() -- 1542
						if Button(zh and '下载' or 'Download') then -- 1543
							allClear() -- 1544
							enterDemoEntry({ -- 1546
								entryName = "ResourceDownloader", -- 1546
								fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1547
							}) -- 1545
						end -- 1543
					end -- 1535
					return Separator() -- 1548
				end) -- 1529
			end) -- 1528
		end -- 1527
		allEntries.anyEntryMatched = false -- 1550
		SetNextWindowPos(Vec2(0, 50)) -- 1551
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1552
		local scrollbarSize <const> = 25 -- 1554
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1555
		do -- 1556
			return PushStyleColor("WindowBg", transparant, function() -- 1557
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1558
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1559
						return PushStyleVar("Alpha", 1, function() -- 1560
							return Begin("Content", windowFlags, function() -- 1561
								local DemoViewWidth <const> = 220 -- 1562
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1563
								if filterText then -- 1564
									filterText = filterText:lower() -- 1564
								end -- 1564
								if App.platform == "Emscripten" then -- 1565
									Dora.globals.webProjects.draw(zh, themeColor) -- 1566
									allEntries.anyEntryMatched = true -- 1567
								end -- 1565
								if #gamesInDev > 0 then -- 1568
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1569
									Columns(columns, false) -- 1570
									local realViewWidth = GetColumnWidth() - 50 -- 1571
									for _index_0 = 1, #gamesInDev do -- 1572
										local game = gamesInDev[_index_0] -- 1572
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1573
										local displayName -- 1582
										if repo then -- 1582
											if zh then -- 1583
												displayName = repo.title.zh -- 1583
											else -- 1583
												displayName = repo.title.en -- 1583
											end -- 1583
										end -- 1582
										if displayName == nil then -- 1584
											displayName = gameName -- 1584
										end -- 1584
										if allEntries.match(displayName) then -- 1585
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1586
											SameLine() -- 1587
											TextWrapped(displayName) -- 1588
											if columns > 1 then -- 1589
												if bannerFile and bannerTex then -- 1590
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1591
													local displayWidth <const> = realViewWidth -- 1592
													texHeight = displayWidth * texHeight / texWidth -- 1593
													texWidth = displayWidth -- 1594
													Dummy(Vec2.zero) -- 1595
													SameLine() -- 1596
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1597
												end -- 1590
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1598
													enterDemoEntry(game) -- 1599
												end -- 1598
											else -- 1601
												if bannerFile and bannerTex then -- 1601
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1602
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1603
													local sizing = 0.8 -- 1604
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1605
													texWidth = displayWidth * sizing -- 1606
													if texWidth > 500 then -- 1607
														sizing = 0.6 -- 1608
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1609
														texWidth = displayWidth * sizing -- 1610
													end -- 1607
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1611
													Dummy(Vec2(padding, 0)) -- 1612
													SameLine() -- 1613
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1614
												end -- 1601
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1615
													enterDemoEntry(game) -- 1616
												end -- 1615
											end -- 1589
											if #tests == 0 and #examples == 0 then -- 1617
												allEntries.thinSep() -- 1618
											end -- 1617
											NextColumn() -- 1619
										end -- 1585
										local showSep = false -- 1620
										if #examples > 0 then -- 1621
											local showExample = false -- 1622
											for _index_1 = 1, #examples do -- 1623
												local _des_0 = examples[_index_1] -- 1623
												local entryName = _des_0.entryName -- 1623
												if allEntries.match(entryName) then -- 1624
													showExample = true -- 1624
													break -- 1624
												end -- 1624
											end -- 1623
											if showExample then -- 1625
												showSep = true -- 1626
												Columns(1, false) -- 1627
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1628
												SameLine() -- 1629
												local opened -- 1630
												if (filterText ~= nil) then -- 1630
													opened = showExample -- 1630
												else -- 1630
													opened = false -- 1630
												end -- 1630
												if game.exampleOpen == nil then -- 1631
													game.exampleOpen = opened -- 1631
												end -- 1631
												SetNextItemOpen(game.exampleOpen) -- 1632
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1633
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1634
														Columns(maxColumns, false) -- 1635
														for _index_1 = 1, #examples do -- 1636
															local example = examples[_index_1] -- 1636
															local entryName = example.entryName -- 1637
															if not allEntries.match(entryName) then -- 1638
																goto _continue_0 -- 1638
															end -- 1638
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1639
																if Button(entryName, Vec2(-1, 40)) then -- 1640
																	enterDemoEntry(example) -- 1641
																end -- 1640
																return NextColumn() -- 1642
															end) -- 1639
															opened = true -- 1643
															::_continue_0:: -- 1637
														end -- 1636
													end) -- 1634
												end) -- 1633
												game.exampleOpen = opened -- 1644
											end -- 1625
										end -- 1621
										if #tests > 0 then -- 1645
											local showTest = false -- 1646
											for _index_1 = 1, #tests do -- 1647
												local _des_0 = tests[_index_1] -- 1647
												local entryName = _des_0.entryName -- 1647
												if allEntries.match(entryName) then -- 1648
													showTest = true -- 1648
													break -- 1648
												end -- 1648
											end -- 1647
											if showTest then -- 1649
												showSep = true -- 1650
												Columns(1, false) -- 1651
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1652
												SameLine() -- 1653
												local opened -- 1654
												if (filterText ~= nil) then -- 1654
													opened = showTest -- 1654
												else -- 1654
													opened = false -- 1654
												end -- 1654
												if game.testOpen == nil then -- 1655
													game.testOpen = opened -- 1655
												end -- 1655
												SetNextItemOpen(game.testOpen) -- 1656
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1657
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1658
														Columns(maxColumns, false) -- 1659
														for _index_1 = 1, #tests do -- 1660
															local test = tests[_index_1] -- 1660
															local entryName = test.entryName -- 1661
															if not allEntries.match(entryName) then -- 1662
																goto _continue_0 -- 1662
															end -- 1662
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1663
																if Button(entryName, Vec2(-1, 40)) then -- 1664
																	enterDemoEntry(test) -- 1665
																end -- 1664
																return NextColumn() -- 1666
															end) -- 1663
															opened = true -- 1667
															::_continue_0:: -- 1661
														end -- 1660
													end) -- 1658
												end) -- 1657
												game.testOpen = opened -- 1668
											end -- 1649
										end -- 1645
										if showSep then -- 1669
											Columns(1, false) -- 1670
											allEntries.thinSep() -- 1671
											Columns(columns, false) -- 1672
										end -- 1669
									end -- 1572
								end -- 1568
								if #doraTools > 0 then -- 1673
									local showTool = false -- 1674
									for _index_0 = 1, #doraTools do -- 1675
										local _des_0 = doraTools[_index_0] -- 1675
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1675
										local displayName -- 1676
										if repo then -- 1676
											if zh then -- 1677
												displayName = repo.title.zh -- 1677
											else -- 1677
												displayName = repo.title.en -- 1677
											end -- 1677
										end -- 1676
										if displayName == nil then -- 1678
											displayName = entryName -- 1678
										end -- 1678
										if allEntries.match(displayName) then -- 1679
											showTool = true -- 1679
											break -- 1679
										end -- 1679
									end -- 1675
									if not showTool then -- 1680
										goto endEntry -- 1680
									end -- 1680
									Columns(1, false) -- 1681
									TextColored(themeColor, "Dora SSR:") -- 1682
									SameLine() -- 1683
									Text(zh and "开发支持" or "Development Support") -- 1684
									Separator() -- 1685
									if #doraTools > 0 then -- 1686
										local opened -- 1687
										if (filterText ~= nil) then -- 1687
											opened = showTool -- 1687
										else -- 1687
											opened = false -- 1687
										end -- 1687
										SetNextItemOpen(toolOpen) -- 1688
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1689
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1690
												Columns(maxColumns, false) -- 1691
												for _index_0 = 1, #doraTools do -- 1692
													local tool = doraTools[_index_0] -- 1692
													local entryName, repo = tool.entryName, tool.repo -- 1693
													local displayName -- 1694
													if repo then -- 1694
														if zh then -- 1695
															displayName = repo.title.zh -- 1695
														else -- 1695
															displayName = repo.title.en -- 1695
														end -- 1695
													end -- 1694
													if displayName == nil then -- 1696
														displayName = entryName -- 1696
													end -- 1696
													if not allEntries.match(displayName) then -- 1697
														goto _continue_0 -- 1697
													end -- 1697
													if Button(displayName, Vec2(-1, 40)) then -- 1698
														enterDemoEntry(tool) -- 1699
													end -- 1698
													NextColumn() -- 1700
													::_continue_0:: -- 1693
												end -- 1692
												Columns(1, false) -- 1701
												opened = true -- 1702
											end) -- 1690
										end) -- 1689
										toolOpen = opened -- 1703
									end -- 1686
								end -- 1673
								::endEntry:: -- 1704
								if not allEntries.anyEntryMatched then -- 1705
									SetNextWindowBgAlpha(0) -- 1706
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1707
									Begin("Entries Not Found", displayWindowFlags, function() -- 1708
										Separator() -- 1709
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1710
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1711
										return Separator() -- 1712
									end) -- 1708
								end -- 1705
								Columns(1, false) -- 1713
								Dummy(Vec2(100, 80)) -- 1714
								return ScrollWhenDraggingOnVoid() -- 1715
							end) -- 1561
						end) -- 1560
					end) -- 1559
				end) -- 1558
			end) -- 1557
		end -- 1556
	end) -- 1462
end -- 1450
if not (App.platform == "Emscripten") then -- 1720
	local sceneModuleCache = moduleCache -- 1721
	moduleCache = { } -- 1722
	webStatus = oldRequire("Script.Dev.WebServer") -- 1723
	moduleCache = sceneModuleCache -- 1724
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1725
		thread(function() -- 1726
			wait(function() -- 1727
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1727
			end) -- 1727
			if App.webIDEEnabled then -- 1728
				return emit("AppWebView", "/ide/show", true) -- 1728
			end -- 1728
		end) -- 1726
	end -- 1725
end -- 1720
local _anon_func_7 = function(saved) -- 1751
	local _val_0 = saved.kind -- 1751
	return "local" == _val_0 or "discover" == _val_0 -- 1751
end -- 1751
local _anon_func_8 = function(saved) -- 1755
	local _val_0 = saved.activeTab -- 1755
	return "local" == _val_0 or "discover" == _val_0 -- 1755
end -- 1755
startMobileUI = function() -- 1730
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1731
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1732
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1733
	local getMobileFeedResources -- 1734
	do -- 1734
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1734
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1734
	end -- 1734
	local loadCachedCatalog -- 1735
	do -- 1735
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1735
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1735
	end -- 1735
	local getResourceInstallPath, getInstalledCatalogResource -- 1736
	do -- 1736
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1736
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1736
	end -- 1736
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1737
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1738
	local feedOptions = nil -- 1739
	local mobileLaunchErrors = { } -- 1740
	local withMobileLaunchErrors -- 1741
	withMobileLaunchErrors = function(items) -- 1741
		for _index_0 = 1, #items do -- 1742
			local item = items[_index_0] -- 1742
			item.launchError = mobileLaunchErrors[item.id] -- 1743
		end -- 1742
		return items -- 1744
	end -- 1741
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1745
	local loadRememberedMobileFeedState -- 1746
	loadRememberedMobileFeedState = function() -- 1746
		local raw = rememberedMobileFeedData -- 1747
		if not (type(raw) == "string" and raw ~= "") then -- 1748
			return -- 1748
		end -- 1748
		local ok, saved = pcall(json.decode, raw) -- 1749
		if not (ok and type(saved) == "table") then -- 1750
			return -- 1750
		end -- 1750
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1751
			local state = { -- 1752
				activeTab = saved.kind -- 1752
			} -- 1752
			state[saved.kind] = saved -- 1753
			return state -- 1754
		end -- 1751
		local state = { -- 1755
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1755
		} -- 1755
		local _list_0 = { -- 1756
			"local", -- 1756
			"discover" -- 1756
		} -- 1756
		for _index_0 = 1, #_list_0 do -- 1756
			local kind = _list_0[_index_0] -- 1756
			local entry = saved[kind] -- 1757
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1758
				state[kind] = entry -- 1758
			end -- 1758
		end -- 1756
		return state -- 1759
	end -- 1746
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1760
		activeTab = "local" -- 1760
	} -- 1760
	local rememberMobileFeedEntry -- 1761
	rememberMobileFeedEntry = function(entry) -- 1761
		rememberedMobileFeedState.activeTab = entry.kind -- 1762
		rememberedMobileFeedState[entry.kind] = { -- 1764
			id = entry.id, -- 1764
			kind = entry.kind, -- 1765
			workDir = entry.workDir, -- 1766
			fileName = entry.fileName -- 1767
		} -- 1763
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1769
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1770
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1771
			rememberedMobileFeedData -- 1771
		}) -- 1771
	end -- 1761
	local restartMobileFeed -- 1772
	restartMobileFeed = function(entry) -- 1772
		if feedHost then -- 1773
			feedHost:removeFromParent(true) -- 1773
		end -- 1773
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1774
		local initialEntries = { } -- 1775
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1776
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1777
		feedOptions.initialEntries = initialEntries -- 1778
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1779
	end -- 1772
	local startMobilePlay -- 1780
	startMobilePlay = function(entry) -- 1780
		if HttpServer.wsConnectionCount > 0 then -- 1781
			return -- 1781
		end -- 1781
		local originFeed = feedHost -- 1782
		if remixHost then -- 1783
			remixHost:removeFromParent(true) -- 1783
		end -- 1783
		remixHost = nil -- 1784
		mobileLaunchErrors[entry.id] = nil -- 1785
		entry.launchError = nil -- 1786
		local playActive = true -- 1787
		local restoreMobileFeed -- 1788
		restoreMobileFeed = function() -- 1788
			if not playActive then -- 1789
				return -- 1789
			end -- 1789
			playActive = false -- 1790
			allClear() -- 1791
			isInEntry = true -- 1792
			currentEntry = nil -- 1793
			return restartMobileFeed(entry) -- 1794
		end -- 1788
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1796
			onExit = function() -- 1796
				return restoreMobileFeed() -- 1796
			end, -- 1796
			onRuntimeError = function() -- 1797
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1798
				return restoreMobileFeed() -- 1799
			end -- 1797
		})) -- 1795
		return thread(function() -- 1801
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1805
			if not playActive then -- 1806
				return -- 1806
			end -- 1806
			if success then -- 1807
				if originFeed and originFeed.parent then -- 1808
					originFeed.visible = false -- 1808
				end -- 1808
				return -- 1809
			end -- 1807
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1810
			return restoreMobileFeed() -- 1811
		end) -- 1801
	end -- 1780
	feedOptions = { -- 1813
		takeReceivedFile = function() -- 1813
			if allEntries.pendingPackagePath then -- 1814
				local path = allEntries.pendingPackagePath -- 1815
				allEntries.pendingPackagePath = nil -- 1816
				return path -- 1817
			end -- 1814
			return App:takeReceivedFile() -- 1818
		end, -- 1813
		onSwitchMode = function() -- 1819
			if HttpServer.wsConnectionCount == 0 then -- 1819
				pendingUIMode = false -- 1819
			end -- 1819
		end, -- 1819
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1820
		getLocalEntries = function(importedProjectPath) -- 1821
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1822
			feedOptions.dirtyProjectPath = nil -- 1823
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1824
			local cached = loadCachedCatalog() -- 1825
			if cached.success and cached.snapshot then -- 1826
				for _index_0 = 1, #items do -- 1827
					local entry = items[_index_0] -- 1827
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1828
					if resource then -- 1829
						entry.resource = resource -- 1830
						entry.catalogCommit = cached.snapshot.commit -- 1831
					end -- 1829
				end -- 1827
			end -- 1826
			return items -- 1832
		end, -- 1821
		syncDiscover = function(onProgress, onDone, force) -- 1833
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1833
		end, -- 1833
		getDiscoverEntries = function() -- 1834
			local cached = loadCachedCatalog() -- 1835
			if not (cached.success and cached.snapshot) then -- 1836
				return { } -- 1836
			end -- 1836
			local items = { } -- 1837
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1838
			for _index_0 = 1, #_list_0 do -- 1838
				local resource = _list_0[_index_0] -- 1838
				local installed = lifecycle.isMobileResourceReady(resource) -- 1839
				local installPath = getResourceInstallPath(resource.id) -- 1840
				items[#items + 1] = { -- 1842
					id = resource.id, -- 1842
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1843
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1844
					kind = "discover", -- 1845
					bannerFile = resource.bannerPath, -- 1846
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1847
					sourceUrl = resource.versions[1].sources[1].url, -- 1848
					workDir = installed and installPath or nil, -- 1849
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1850
					installed = installed, -- 1851
					resource = resource, -- 1852
					catalogCommit = cached.snapshot.commit, -- 1853
					launchError = mobileLaunchErrors[resource.id] -- 1854
				} -- 1841
			end -- 1838
			return items -- 1856
		end, -- 1834
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1857
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1858
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1859
			end), repairIncomplete, isCanceled) -- 1858
		end, -- 1857
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1861
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1862
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1863
			end), isCanceled) -- 1862
		end, -- 1861
		createProject = function(name, language) -- 1865
			local result = projectCreate.createMobileProject(name, language) -- 1866
			if not result.success then -- 1867
				return result -- 1867
			end -- 1867
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1868
			for _index_0 = 1, #_list_0 do -- 1868
				local entry = _list_0[_index_0] -- 1868
				if entry.workDir == result.workDir then -- 1869
					return { -- 1870
						success = true, -- 1870
						entry = entry -- 1870
					} -- 1870
				end -- 1869
			end -- 1868
			return { -- 1871
				success = false, -- 1871
				error = "created-project-not-found" -- 1871
			} -- 1871
		end, -- 1865
		onPlay = function(entry) -- 1872
			return startMobilePlay(entry) -- 1872
		end, -- 1872
		onRemix = function(entry) -- 1873
			if HttpServer.wsConnectionCount > 0 then -- 1874
				return -- 1874
			end -- 1874
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1875
			local originFeed = feedHost -- 1876
			feedHost.visible = false -- 1877
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1879
				entry = entry, -- 1879
				onProjectChanged = function(current) -- 1880
					feedOptions.dirtyProjectPath = current.workDir -- 1880
				end, -- 1880
				onBack = function() -- 1881
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1882
						originFeed:emit("RestoreFeedEntry", entry) -- 1883
						originFeed.visible = true -- 1884
					end -- 1882
				end, -- 1881
				onPlay = function(current) -- 1885
					return startMobilePlay(current) -- 1885
				end -- 1885
			})) -- 1878
		end -- 1873
	} -- 1812
	return restartMobileFeed() -- 1888
end -- 1730
if mobileMode then -- 1890
	applyUIMode(true) -- 1890
end -- 1890
return _module_0 -- 1
