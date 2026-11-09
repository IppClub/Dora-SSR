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
local sleep <const> = sleep -- 11
local once <const> = once -- 11
local emit <const> = emit -- 11
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
local updateCheck -- 231
updateCheck = function() -- 231
	return thread(function() -- 231
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 232
		if res then -- 232
			local data = json.decode(res) -- 233
			if data then -- 233
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 234
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 235
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 236
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 237
				if na < a then -- 238
					goto not_new_version -- 239
				end -- 238
				if na == a then -- 240
					if nb < b then -- 241
						goto not_new_version -- 242
					end -- 241
					if nb == b then -- 243
						if nc < c then -- 244
							goto not_new_version -- 245
						end -- 244
						if nc == c then -- 246
							goto not_new_version -- 247
						end -- 246
					end -- 243
				end -- 240
				config.updateNotification = true -- 248
				::not_new_version:: -- 249
				config.lastUpdateCheck = os.time() -- 250
			end -- 233
		end -- 232
	end) -- 231
end -- 231
if (config.lastUpdateCheck ~= nil) then -- 252
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 253
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 254
		updateCheck() -- 255
	end -- 254
else -- 257
	updateCheck() -- 257
end -- 252
local Set, Struct, LintYueGlobals -- 259
do -- 259
	local _obj_0 = require("Utils") -- 259
	Set, Struct, LintYueGlobals = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals -- 259
end -- 259
local yueext = yue.options.extension -- 260
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 262
local building = false -- 264
local getAllFiles -- 266
getAllFiles = function(path, exts, recursive) -- 266
	if recursive == nil then -- 266
		recursive = true -- 266
	end -- 266
	local filters = Set(exts) -- 267
	local files -- 268
	if recursive then -- 268
		files = Content:getAllFiles(path) -- 269
	else -- 271
		files = Content:getFiles(path) -- 271
	end -- 268
	local _accum_0 = { } -- 272
	local _len_0 = 1 -- 272
	for _index_0 = 1, #files do -- 272
		local file = files[_index_0] -- 272
		if not filters[Path:getExt(file)] then -- 273
			goto _continue_0 -- 273
		end -- 273
		_accum_0[_len_0] = file -- 274
		_len_0 = _len_0 + 1 -- 273
		::_continue_0:: -- 273
	end -- 272
	return _accum_0 -- 272
end -- 266
_module_0["getAllFiles"] = getAllFiles -- 266
local getFileEntries -- 276
getFileEntries = function(path, recursive, excludeFiles) -- 276
	if recursive == nil then -- 276
		recursive = true -- 276
	end -- 276
	if excludeFiles == nil then -- 276
		excludeFiles = nil -- 276
	end -- 276
	local entries = { } -- 277
	local excludes -- 278
	if excludeFiles then -- 278
		excludes = Set(excludeFiles) -- 279
	end -- 278
	local _list_0 = getAllFiles(path, { -- 280
		"lua", -- 280
		"xml", -- 280
		yueext, -- 280
		"tl" -- 280
	}, recursive) -- 280
	for _index_0 = 1, #_list_0 do -- 280
		local file = _list_0[_index_0] -- 280
		local entryName = Path:getName(file) -- 281
		if excludes and excludes[entryName] then -- 282
			goto _continue_0 -- 283
		end -- 282
		local fileName = Path:replaceExt(file, "") -- 284
		fileName = Path(path, fileName) -- 285
		local entryAdded -- 286
		for _index_1 = 1, #entries do -- 286
			local _des_0 = entries[_index_1] -- 286
			local ename, efile = _des_0.entryName, _des_0.fileName -- 286
			if entryName == ename and efile == fileName then -- 287
				entryAdded = true -- 287
				break -- 287
			end -- 287
		end -- 286
		if entryAdded then -- 288
			goto _continue_0 -- 288
		end -- 288
		local entry = { -- 289
			entryName = entryName, -- 289
			fileName = fileName -- 289
		} -- 289
		entries[#entries + 1] = entry -- 290
		::_continue_0:: -- 281
	end -- 280
	table.sort(entries, function(a, b) -- 291
		return a.entryName < b.entryName -- 291
	end) -- 291
	return entries -- 292
end -- 276
local allEntries = { -- 294
	dirty = { }, -- 294
	hasDirty = false, -- 294
	runId = 0 -- 294
} -- 294
allEntries.scanDir = function(path, dir, noPreview) -- 296
	if noPreview == nil then -- 296
		noPreview = false -- 296
	end -- 296
	local entries = { } -- 297
	if not dir:match("^%.") then -- 298
		local _list_0 = getAllFiles(Path(path, dir), { -- 299
			"lua", -- 299
			"xml", -- 299
			yueext, -- 299
			"tl", -- 299
			"wasm" -- 299
		}) -- 299
		for _index_0 = 1, #_list_0 do -- 299
			local file = _list_0[_index_0] -- 299
			if "init" == Path:getName(file):lower() then -- 300
				local fileName = Path:replaceExt(file, "") -- 301
				fileName = Path(path, dir, fileName) -- 302
				local projectPath = Path:getPath(fileName) -- 303
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 304
				local repo = nil -- 305
				if Content:exist(repoFile) then -- 306
					local str = Content:load(repoFile) -- 307
					if str then -- 307
						repo = json.decode(str) -- 308
					end -- 307
				end -- 306
				local entryName = Path:getName(projectPath) -- 309
				local entryAdded -- 310
				for _index_1 = 1, #entries do -- 310
					local _des_0 = entries[_index_1] -- 310
					local ename, efile = _des_0.entryName, _des_0.fileName -- 310
					if entryName == ename and efile == fileName then -- 311
						entryAdded = true -- 311
						break -- 311
					end -- 311
				end -- 310
				if entryAdded then -- 312
					goto _continue_0 -- 312
				end -- 312
				local examples = { } -- 313
				local tests = { } -- 314
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 315
				if Content:exist(examplePath) then -- 316
					local _list_1 = getFileEntries(examplePath) -- 317
					for _index_1 = 1, #_list_1 do -- 317
						local _des_0 = _list_1[_index_1] -- 317
						local name, ePath = _des_0.entryName, _des_0.fileName -- 317
						local entry = { -- 319
							entryName = name, -- 319
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 320
							workDir = projectPath -- 321
						} -- 318
						examples[#examples + 1] = entry -- 323
					end -- 317
				end -- 316
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 324
				if Content:exist(testPath) then -- 325
					local _list_1 = getFileEntries(testPath) -- 326
					for _index_1 = 1, #_list_1 do -- 326
						local _des_0 = _list_1[_index_1] -- 326
						local name, tPath = _des_0.entryName, _des_0.fileName -- 326
						local entry = { -- 328
							entryName = name, -- 328
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 329
							workDir = projectPath -- 330
						} -- 327
						tests[#tests + 1] = entry -- 332
					end -- 326
				end -- 325
				local entry = { -- 333
					entryName = entryName, -- 333
					fileName = fileName, -- 333
					projectPath = projectPath, -- 333
					examples = examples, -- 333
					tests = tests, -- 333
					repo = repo -- 333
				} -- 333
				local bannerFile -- 334
				do -- 334
					local _val_0 -- 334
					repeat -- 334
						if noPreview then -- 335
							_val_0 = nil -- 335
							break -- 335
						end -- 335
						if not config.showPreview then -- 336
							_val_0 = nil -- 336
							break -- 336
						end -- 336
						local f = Path(projectPath, ".dora", "banner.jpg") -- 337
						if Content:exist(f) then -- 338
							_val_0 = f -- 338
							break -- 338
						end -- 338
						f = Path(projectPath, ".dora", "banner.png") -- 339
						if Content:exist(f) then -- 340
							_val_0 = f -- 340
							break -- 340
						end -- 340
						f = Path(projectPath, "Image", "banner.jpg") -- 341
						if Content:exist(f) then -- 342
							_val_0 = f -- 342
							break -- 342
						end -- 342
						f = Path(projectPath, "Image", "banner.png") -- 343
						if Content:exist(f) then -- 344
							_val_0 = f -- 344
							break -- 344
						end -- 344
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 345
						if Content:exist(f) then -- 346
							_val_0 = f -- 346
							break -- 346
						end -- 346
					until true -- 334
					bannerFile = _val_0 -- 334
				end -- 334
				if bannerFile then -- 348
					entry.bannerFile = bannerFile -- 351
					thread(function() -- 352
						if Cache:loadAsync(bannerFile) then -- 353
							local bannerTex = Texture2D(bannerFile) -- 354
							if bannerTex then -- 354
								entry.bannerTex = bannerTex -- 355
							end -- 354
						end -- 353
					end) -- 352
				end -- 348
				entries[#entries + 1] = entry -- 356
			end -- 300
			::_continue_0:: -- 300
		end -- 299
	end -- 298
	return entries -- 357
end -- 296
local getProjectEntries -- 359
getProjectEntries = function(path, noPreview) -- 359
	if noPreview == nil then -- 359
		noPreview = false -- 359
	end -- 359
	local entries = { } -- 360
	local _list_0 = Content:getDirs(path) -- 361
	for _index_0 = 1, #_list_0 do -- 361
		local dir = _list_0[_index_0] -- 361
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 362
		for _index_1 = 1, #_list_1 do -- 362
			local entry = _list_1[_index_1] -- 362
			entries[#entries + 1] = entry -- 363
		end -- 362
	end -- 361
	table.sort(entries, function(a, b) -- 364
		return a.entryName < b.entryName -- 364
	end) -- 364
	return entries -- 365
end -- 359
_module_0["getProjectEntries"] = getProjectEntries -- 359
local gamesInDev -- 367
local doraTools -- 368
local isToolEntry -- 370
isToolEntry = function(entry) -- 370
	do -- 371
		local _type_0 = type(entry) -- 371
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 371
		if _tab_0 then -- 371
			local categories -- 371
			do -- 371
				local _obj_0 = entry.repo -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					categories = _obj_0.categories -- 371
				end -- 371
			end -- 371
			if categories ~= nil then -- 371
				for _index_0 = 1, #categories do -- 372
					local category = categories[_index_0] -- 372
					if "string" == type(category) and category:lower() == "tool" then -- 373
						return true -- 374
					end -- 373
				end -- 372
			end -- 371
		end -- 371
	end -- 371
	return false -- 370
end -- 370
local getEntryTitle -- 376
getEntryTitle = function(entry) -- 376
	local title -- 377
	do -- 377
		local repo = entry.repo -- 377
		if repo then -- 377
			if repo.title and "table" == type(repo.title) then -- 378
				if useChinese then -- 379
					title = repo.title.zh -- 379
				else -- 379
					title = repo.title.en -- 379
				end -- 379
			end -- 378
		end -- 377
	end -- 377
	if title ~= nil then -- 380
		return title -- 380
	else -- 380
		return entry.entryName -- 380
	end -- 380
end -- 376
allEntries.rebuildEntries = function() -- 382
	gamesInDev = { } -- 383
	do -- 384
		local _accum_0 = { } -- 384
		local _len_0 = 1 -- 384
		local _list_0 = allEntries.builtinTools -- 384
		for _index_0 = 1, #_list_0 do -- 384
			local tool = _list_0[_index_0] -- 384
			_accum_0[_len_0] = tool -- 384
			_len_0 = _len_0 + 1 -- 384
		end -- 384
		doraTools = _accum_0 -- 384
	end -- 384
	local _list_0 = allEntries.projectEntries -- 385
	for _index_0 = 1, #_list_0 do -- 385
		local entry = _list_0[_index_0] -- 385
		if isToolEntry(entry) then -- 386
			entry.kind = "tool" -- 387
			doraTools[#doraTools + 1] = entry -- 388
		else -- 390
			entry.kind = "game" -- 390
			gamesInDev[#gamesInDev + 1] = entry -- 391
		end -- 386
	end -- 385
	for i = #allEntries, 1, -1 do -- 392
		allEntries[i] = nil -- 393
	end -- 392
	for _index_0 = 1, #gamesInDev do -- 394
		local game = gamesInDev[_index_0] -- 394
		allEntries[#allEntries + 1] = game -- 395
		local examples, tests = game.examples, game.tests -- 396
		for _index_1 = 1, #examples do -- 397
			local example = examples[_index_1] -- 397
			allEntries[#allEntries + 1] = example -- 398
		end -- 397
		for _index_1 = 1, #tests do -- 399
			local test = tests[_index_1] -- 399
			allEntries[#allEntries + 1] = test -- 400
		end -- 399
	end -- 394
end -- 382
local updateEntries -- 402
updateEntries = function() -- 402
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 403
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 404
	local _list_0 = allEntries.builtinTools -- 405
	for _index_0 = 1, #_list_0 do -- 405
		local tool = _list_0[_index_0] -- 405
		tool.kind = "tool" -- 406
		tool.builtin = true -- 407
	end -- 405
	return allEntries.rebuildEntries() -- 408
end -- 402
allEntries.refreshDirtyProjects = function() -- 410
	if not allEntries.hasDirty then -- 411
		return -- 411
	end -- 411
	local dirty = allEntries.dirty -- 412
	allEntries.dirty = { } -- 413
	allEntries.hasDirty = false -- 414
	for projectPath in pairs(dirty) do -- 415
		do -- 416
			local _accum_0 = { } -- 416
			local _len_0 = 1 -- 416
			local _list_0 = allEntries.projectEntries -- 416
			for _index_0 = 1, #_list_0 do -- 416
				local entry = _list_0[_index_0] -- 416
				if entry.projectPath ~= projectPath then -- 416
					_accum_0[_len_0] = entry -- 416
					_len_0 = _len_0 + 1 -- 416
				end -- 416
			end -- 416
			allEntries.projectEntries = _accum_0 -- 416
		end -- 416
		local parentPath = Path:getPath(projectPath) -- 417
		local dir = Path:getFilename(projectPath) -- 418
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 419
		for _index_0 = 1, #_list_0 do -- 419
			local entry = _list_0[_index_0] -- 419
			if entry.projectPath == projectPath then -- 420
				do -- 421
					local _obj_0 = allEntries.projectEntries -- 421
					_obj_0[#_obj_0 + 1] = entry -- 421
				end -- 421
				break -- 422
			end -- 420
		end -- 419
	end -- 415
	table.sort(allEntries.projectEntries, function(a, b) -- 423
		return a.entryName < b.entryName -- 423
	end) -- 423
	return allEntries.rebuildEntries() -- 424
end -- 410
updateEntries() -- 426
local getLaunchEntries -- 428
getLaunchEntries = function(refresh) -- 428
	if refresh == nil then -- 428
		refresh = false -- 428
	end -- 428
	if refresh then -- 429
		updateEntries() -- 429
	end -- 429
	local toInfo -- 430
	toInfo = function(entry, kind) -- 430
		local file = entry.fileName -- 431
		local asProj = not entry.builtin -- 432
		return { -- 434
			name = getEntryTitle(entry), -- 434
			file = file, -- 435
			kind = kind, -- 436
			asProj = asProj -- 437
		} -- 433
	end -- 430
	local games -- 439
	do -- 439
		local _accum_0 = { } -- 439
		local _len_0 = 1 -- 439
		for _index_0 = 1, #gamesInDev do -- 439
			local game = gamesInDev[_index_0] -- 439
			_accum_0[_len_0] = toInfo(game, "game") -- 439
			_len_0 = _len_0 + 1 -- 439
		end -- 439
		games = _accum_0 -- 439
	end -- 439
	local tools -- 440
	do -- 440
		local _accum_0 = { } -- 440
		local _len_0 = 1 -- 440
		for _index_0 = 1, #doraTools do -- 440
			local tool = doraTools[_index_0] -- 440
			_accum_0[_len_0] = toInfo(tool, "tool") -- 440
			_len_0 = _len_0 + 1 -- 440
		end -- 440
		tools = _accum_0 -- 440
	end -- 440
	return { -- 441
		games = games, -- 441
		tools = tools -- 441
	} -- 441
end -- 428
_module_0["getLaunchEntries"] = getLaunchEntries -- 428
local _anon_func_1 = function(entry, useChinese) -- 458
	local _obj_0 = entry.repo -- 458
	if _obj_0 ~= nil then -- 458
		local _obj_1 = _obj_0.description -- 458
		if _obj_1 ~= nil then -- 458
			return _obj_1[useChinese and "zh" or "en"] -- 458
		end -- 458
		return nil -- 458
	end -- 458
	return nil -- 458
end -- 458
local getMobileFeedEntries -- 443
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 443
	if refresh == nil then -- 443
		refresh = false -- 443
	end -- 443
	if dirtyProjectPath == nil then -- 443
		dirtyProjectPath = nil -- 443
	end -- 443
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 444
		allEntries.dirty[dirtyProjectPath] = true -- 445
		allEntries.hasDirty = true -- 446
	end -- 444
	if refresh then -- 447
		allEntries.dirty = { } -- 448
		allEntries.hasDirty = false -- 449
		updateEntries() -- 450
	else -- 452
		allEntries.refreshDirtyProjects() -- 452
	end -- 447
	local items = { } -- 453
	for _index_0 = 1, #gamesInDev do -- 454
		local entry = gamesInDev[_index_0] -- 454
		items[#items + 1] = { -- 456
			id = entry.entryName, -- 456
			title = getEntryTitle(entry), -- 457
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 458
			fileName = entry.fileName, -- 459
			workDir = Path:getPath(entry.fileName), -- 460
			bannerFile = entry.bannerFile, -- 461
			kind = "local" -- 462
		} -- 455
	end -- 454
	return items -- 464
end -- 443
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 443
local doCompile -- 466
doCompile = function(minify) -- 466
	if building then -- 467
		return -- 467
	end -- 467
	building = true -- 468
	local startTime = App.runningTime -- 469
	local luaFiles = { } -- 470
	local yueFiles = { } -- 471
	local xmlFiles = { } -- 472
	local tlFiles = { } -- 473
	local writablePath = Content.writablePath -- 474
	local buildPaths = { -- 476
		{ -- 477
			Content.assetPath, -- 477
			Path(writablePath, ".build"), -- 478
			"" -- 479
		} -- 476
	} -- 475
	for _index_0 = 1, #gamesInDev do -- 482
		local _des_0 = gamesInDev[_index_0] -- 482
		local fileName = _des_0.fileName -- 482
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 483
		buildPaths[#buildPaths + 1] = { -- 485
			Path(writablePath, gamePath), -- 485
			Path(writablePath, ".build", gamePath), -- 486
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 487
			gamePath -- 488
		} -- 484
	end -- 482
	for _index_0 = 1, #buildPaths do -- 489
		local _des_0 = buildPaths[_index_0] -- 489
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 489
		if not Content:exist(inputPath) then -- 490
			goto _continue_0 -- 490
		end -- 490
		local _list_0 = getAllFiles(inputPath, { -- 492
			"lua" -- 492
		}) -- 492
		for _index_1 = 1, #_list_0 do -- 492
			local file = _list_0[_index_1] -- 492
			luaFiles[#luaFiles + 1] = { -- 494
				file, -- 494
				Path(inputPath, file), -- 495
				Path(outputPath, file), -- 496
				gamePath -- 497
			} -- 493
		end -- 492
		local _list_1 = getAllFiles(inputPath, { -- 499
			yueext -- 499
		}) -- 499
		for _index_1 = 1, #_list_1 do -- 499
			local file = _list_1[_index_1] -- 499
			yueFiles[#yueFiles + 1] = { -- 501
				file, -- 501
				Path(inputPath, file), -- 502
				Path(outputPath, Path:replaceExt(file, "lua")), -- 503
				searchPath, -- 504
				gamePath -- 505
			} -- 500
		end -- 499
		local _list_2 = getAllFiles(inputPath, { -- 507
			"xml" -- 507
		}) -- 507
		for _index_1 = 1, #_list_2 do -- 507
			local file = _list_2[_index_1] -- 507
			xmlFiles[#xmlFiles + 1] = { -- 509
				file, -- 509
				Path(inputPath, file), -- 510
				Path(outputPath, Path:replaceExt(file, "lua")), -- 511
				gamePath -- 512
			} -- 508
		end -- 507
		local _list_3 = getAllFiles(inputPath, { -- 514
			"tl" -- 514
		}) -- 514
		for _index_1 = 1, #_list_3 do -- 514
			local file = _list_3[_index_1] -- 514
			if not file:match(".*%.d%.tl$") then -- 515
				tlFiles[#tlFiles + 1] = { -- 517
					file, -- 517
					Path(inputPath, file), -- 518
					Path(outputPath, Path:replaceExt(file, "lua")), -- 519
					searchPath, -- 520
					gamePath -- 521
				} -- 516
			end -- 515
		end -- 514
		::_continue_0:: -- 490
	end -- 489
	local paths -- 523
	do -- 523
		local _tbl_0 = { } -- 523
		local _list_0 = { -- 524
			luaFiles, -- 524
			yueFiles, -- 524
			xmlFiles, -- 524
			tlFiles -- 524
		} -- 524
		for _index_0 = 1, #_list_0 do -- 524
			local files = _list_0[_index_0] -- 524
			for _index_1 = 1, #files do -- 525
				local file = files[_index_1] -- 525
				_tbl_0[Path:getPath(file[3])] = true -- 523
			end -- 523
		end -- 523
		paths = _tbl_0 -- 523
	end -- 523
	for path in pairs(paths) do -- 527
		Content:mkdir(path) -- 527
	end -- 527
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 529
	local fileCount = 0 -- 530
	local errors = { } -- 531
	for _index_0 = 1, #yueFiles do -- 532
		local _des_0 = yueFiles[_index_0] -- 532
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 532
		local filename -- 533
		if gamePath then -- 533
			filename = Path(gamePath, file) -- 533
		else -- 533
			filename = file -- 533
		end -- 533
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 534
			if not codes then -- 535
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 536
				return -- 537
			end -- 535
			local success, result = LintYueGlobals(codes, globals) -- 538
			local yueCodes -- 539
			if not success then -- 540
				yueCodes = Content:load(input) -- 541
				if yueCodes then -- 541
					local CheckTIC80Code -- 542
					do -- 542
						local _obj_0 = require("Utils") -- 542
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 542
					end -- 542
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 543
					if isTIC80 then -- 544
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 545
					end -- 544
				end -- 541
			end -- 540
			if success then -- 546
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 547
			else -- 549
				if yueCodes then -- 549
					local globalErrors = { } -- 550
					for _index_1 = 1, #result do -- 551
						local _des_1 = result[_index_1] -- 551
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 551
						local countLine = 1 -- 552
						local code = "" -- 553
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 554
							if countLine == line then -- 555
								code = lineCode -- 556
								break -- 557
							end -- 555
							countLine = countLine + 1 -- 558
						end -- 554
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 559
					end -- 551
					if #globalErrors > 0 then -- 560
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 560
					end -- 560
				else -- 562
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 562
				end -- 549
				if #errors == 0 then -- 563
					return codes -- 563
				end -- 563
			end -- 546
		end, function(success) -- 534
			if success then -- 564
				print("Yue compiled: " .. tostring(filename)) -- 564
			end -- 564
			fileCount = fileCount + 1 -- 565
		end) -- 534
	end -- 532
	thread(function() -- 567
		for _index_0 = 1, #xmlFiles do -- 568
			local _des_0 = xmlFiles[_index_0] -- 568
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 568
			local filename -- 569
			if gamePath then -- 569
				filename = Path(gamePath, file) -- 569
			else -- 569
				filename = file -- 569
			end -- 569
			local sourceCodes = Content:loadAsync(input) -- 570
			local codes, err = xml.tolua(sourceCodes) -- 571
			if not codes then -- 572
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 573
			else -- 575
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 575
				print("Xml compiled: " .. tostring(filename)) -- 576
			end -- 572
			fileCount = fileCount + 1 -- 577
		end -- 568
	end) -- 567
	thread(function() -- 579
		for _index_0 = 1, #tlFiles do -- 580
			local _des_0 = tlFiles[_index_0] -- 580
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 580
			local filename -- 581
			if gamePath then -- 581
				filename = Path(gamePath, file) -- 581
			else -- 581
				filename = file -- 581
			end -- 581
			local sourceCodes = Content:loadAsync(input) -- 582
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 583
			if not codes then -- 584
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 585
			else -- 587
				Content:saveAsync(output, codes) -- 587
				print("Teal compiled: " .. tostring(filename)) -- 588
			end -- 584
			fileCount = fileCount + 1 -- 589
		end -- 580
	end) -- 579
	return thread(function() -- 591
		wait(function() -- 592
			return fileCount == totalFiles -- 592
		end) -- 592
		if minify then -- 593
			local _list_0 = { -- 594
				yueFiles, -- 594
				xmlFiles, -- 594
				tlFiles -- 594
			} -- 594
			for _index_0 = 1, #_list_0 do -- 594
				local files = _list_0[_index_0] -- 594
				for _index_1 = 1, #files do -- 594
					local file = files[_index_1] -- 594
					local output = Path:replaceExt(file[3], "lua") -- 595
					luaFiles[#luaFiles + 1] = { -- 597
						Path:replaceExt(file[1], "lua"), -- 597
						output, -- 598
						output -- 599
					} -- 596
				end -- 594
			end -- 594
			local FormatMini -- 601
			do -- 601
				local _obj_0 = require("luaminify") -- 601
				FormatMini = _obj_0.FormatMini -- 601
			end -- 601
			for _index_0 = 1, #luaFiles do -- 602
				local _des_0 = luaFiles[_index_0] -- 602
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 602
				if Content:exist(input) then -- 603
					local sourceCodes = Content:loadAsync(input) -- 604
					local res, err = FormatMini(sourceCodes) -- 605
					if res then -- 606
						Content:saveAsync(output, res) -- 607
						print("Minify: " .. tostring(file)) -- 608
					else -- 610
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 610
					end -- 606
				else -- 612
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 612
				end -- 603
			end -- 602
			package.loaded["luaminify.FormatMini"] = nil -- 613
			package.loaded["luaminify.ParseLua"] = nil -- 614
			package.loaded["luaminify.Scope"] = nil -- 615
			package.loaded["luaminify.Util"] = nil -- 616
		end -- 593
		local errorMessage = table.concat(errors, "\n") -- 617
		if errorMessage ~= "" then -- 618
			print(errorMessage) -- 618
		end -- 618
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 619
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 620
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 621
		Content:clearPathCache() -- 622
		teal.clear() -- 623
		yue.clear() -- 624
		building = false -- 625
	end) -- 591
end -- 466
local doClean -- 627
doClean = function() -- 627
	if building then -- 628
		return -- 628
	end -- 628
	local writablePath = Content.writablePath -- 629
	local targetDir = Path(writablePath, ".build") -- 630
	Content:clearPathCache() -- 631
	if Content:remove(targetDir) then -- 632
		return print("Cleaned: " .. tostring(targetDir)) -- 633
	end -- 632
end -- 627
local screenScale = 2.0 -- 635
local scaleContent = false -- 636
local isInEntry = true -- 637
local currentEntry = nil -- 638
local footerWindow = nil -- 640
local entryWindow = nil -- 641
local testingThread = nil -- 642
local mobileMode = config.mobileFeed -- 643
local pendingUIMode = nil -- 644
local feedHost = nil -- 645
local remixHost = nil -- 646
local startMobileUI = nil -- 647
local webControlled = false -- 648
local mobileHosts = { } -- 649
local suspendedMobileHosts = { } -- 650
local trackMobileHost -- 652
trackMobileHost = function(host) -- 652
	do -- 653
		local _accum_0 = { } -- 653
		local _len_0 = 1 -- 653
		for _index_0 = 1, #mobileHosts do -- 653
			local item = mobileHosts[_index_0] -- 653
			if item.parent then -- 653
				_accum_0[_len_0] = item -- 653
				_len_0 = _len_0 + 1 -- 653
			end -- 653
		end -- 653
		mobileHosts = _accum_0 -- 653
	end -- 653
	mobileHosts[#mobileHosts + 1] = host -- 654
	return host -- 655
end -- 652
local clearMobileUI -- 657
clearMobileUI = function() -- 657
	for _index_0 = 1, #mobileHosts do -- 658
		local host = mobileHosts[_index_0] -- 658
		if host.parent then -- 659
			host:removeFromParent(true) -- 659
		end -- 659
	end -- 658
	mobileHosts = { } -- 660
	suspendedMobileHosts = { } -- 661
	feedHost = nil -- 662
	remixHost = nil -- 663
end -- 657
local syncWebIDEControl -- 665
syncWebIDEControl = function() -- 665
	local connected = HttpServer.wsConnectionCount > 0 -- 666
	if connected then -- 667
		pendingUIMode = nil -- 668
		for _index_0 = 1, #mobileHosts do -- 669
			local host = mobileHosts[_index_0] -- 669
			if not host.parent then -- 670
				goto _continue_0 -- 670
			end -- 670
			if not (suspendedMobileHosts[host] ~= nil) then -- 671
				suspendedMobileHosts[host] = host.visible -- 672
				host:emit("SuspendLocalUI") -- 673
			end -- 671
			host.visible = false -- 674
			::_continue_0:: -- 670
		end -- 669
	elseif webControlled then -- 675
		for host, visible in pairs(suspendedMobileHosts) do -- 676
			if host.parent then -- 677
				host.visible = visible -- 678
				host:emit("ResumeLocalUI") -- 679
			end -- 677
		end -- 676
		suspendedMobileHosts = { } -- 680
	end -- 667
	webControlled = connected -- 681
	return connected -- 682
end -- 665
local getUIMode -- 684
getUIMode = function() -- 684
	return mobileMode and "mobile" or "traditional" -- 684
end -- 684
_module_0["getUIMode"] = getUIMode -- 684
local setUIMode -- 685
setUIMode = function(mode) -- 685
	if not (("mobile" == mode or "traditional" == mode)) then -- 686
		return false -- 686
	end -- 686
	if HttpServer.wsConnectionCount > 0 then -- 687
		return false -- 687
	end -- 687
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 688
		return false -- 688
	end -- 688
	local wantsMobile = mode == "mobile" -- 689
	if wantsMobile == mobileMode then -- 690
		return true -- 690
	end -- 690
	if mobileMode then -- 691
		if not (feedHost and feedHost.visible) then -- 692
			return false -- 692
		end -- 692
		feedHost:emit("SwitchUIMode") -- 694
		return pendingUIMode == false -- 695
	end -- 691
	pendingUIMode = true -- 696
	return true -- 697
end -- 685
_module_0["setUIMode"] = setUIMode -- 685
local applyUIMode -- 699
applyUIMode = function(enabled) -- 699
	if HttpServer.wsConnectionCount > 0 then -- 701
		return false -- 701
	end -- 701
	if enabled then -- 702
		local ok, err = pcall(startMobileUI) -- 703
		if not ok then -- 704
			if feedHost then -- 705
				feedHost:removeFromParent(true) -- 705
			end -- 705
			feedHost = nil -- 706
			mobileMode = false -- 707
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 708
			return false -- 709
		end -- 704
	else -- 711
		clearMobileUI() -- 711
		updateEntries() -- 712
	end -- 702
	mobileMode = enabled -- 713
	config.mobileFeed = enabled -- 714
	return true -- 715
end -- 699
local setupEventHandlers = nil -- 717
local allClear -- 719
allClear = function() -- 719
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 721
		clearMobileUI() -- 721
	end -- 721
	local systemNodes = { } -- 724
	local preserveSystemNode -- 725
	preserveSystemNode = function(node) -- 725
		if systemNodes[node] then -- 726
			return -- 726
		end -- 726
		systemNodes[node] = true -- 727
		do -- 728
			local clip = tolua.cast(node, "ClipNode") -- 728
			if clip then -- 728
				if clip.stencil then -- 729
					preserveSystemNode(clip.stencil) -- 729
				end -- 729
			end -- 728
		end -- 728
		return node:eachChild(function(child) -- 730
			preserveSystemNode(child) -- 731
			return false -- 732
		end) -- 730
	end -- 725
	for _index_0 = 1, #Routine do -- 733
		local routine = Routine[_index_0] -- 733
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 735
			goto _continue_0 -- 736
		else -- 738
			Routine:remove(routine) -- 738
		end -- 734
		::_continue_0:: -- 734
	end -- 733
	for _index_0 = 1, #moduleCache do -- 739
		local module = moduleCache[_index_0] -- 739
		package.loaded[module] = nil -- 740
	end -- 739
	moduleCache = { } -- 741
	Director:cleanup() -- 742
	Entity:clear() -- 743
	Platformer.Data:clear() -- 744
	Platformer.UnitAction:clear() -- 745
	Audio:stopAll(0.2) -- 746
	Struct:clear() -- 747
	View.nearPlaneDistance = 0.1 -- 750
	View.farPlaneDistance = 10000 -- 751
	View.fieldOfView = 45 -- 752
	View.postEffect = nil -- 753
	View.scale = scaleContent and screenScale or 1 -- 754
	Director.clearColor = Color(0xff1a1a1a) -- 755
	teal.clear() -- 756
	yue.clear() -- 757
	preserveSystemNode(Director.systemUI) -- 760
	for _, item in pairs(ubox()) do -- 761
		local node = tolua.cast(item, "Node") -- 762
		if node then -- 762
			if not systemNodes[node] then -- 763
				node:cleanup() -- 763
			end -- 763
		end -- 762
	end -- 761
	collectgarbage() -- 764
	collectgarbage() -- 765
	Wasm:clear() -- 766
	thread(function() -- 767
		sleep() -- 768
		return Cache:removeUnused() -- 769
	end) -- 767
	setupEventHandlers() -- 770
	Content.searchPaths = searchPaths -- 771
	App.idled = true -- 772
end -- 719
_module_0["allClear"] = allClear -- 719
local clearTempFiles -- 774
clearTempFiles = function() -- 774
	local writablePath = Content.writablePath -- 775
	local uploadPath = Path(writablePath, ".upload") -- 776
	if Content:exist(uploadPath) then -- 777
		local _list_0 = Content:getDirs(uploadPath) -- 779
		for _index_0 = 1, #_list_0 do -- 779
			local dir = _list_0[_index_0] -- 779
			if dir ~= "resume" then -- 780
				Content:remove(Path(uploadPath, dir)) -- 780
			end -- 780
		end -- 779
		local _list_1 = Content:getFiles(uploadPath) -- 781
		for _index_0 = 1, #_list_1 do -- 781
			local file = _list_1[_index_0] -- 781
			Content:remove(Path(uploadPath, file)) -- 782
		end -- 781
	end -- 777
	if Content:exist(Path(writablePath, ".download")) then -- 783
		return Content:remove(Path(writablePath, ".download")) -- 783
	end -- 783
end -- 774
local waitForWebStart = true -- 785
thread(function() -- 786
	sleep(2) -- 787
	waitForWebStart = false -- 788
end) -- 786
local reloadDevEntry -- 790
reloadDevEntry = function() -- 790
	return thread(function() -- 790
		waitForWebStart = true -- 791
		doClean() -- 792
		allClear() -- 793
		_G.require = oldRequire -- 794
		Dora.require = oldRequire -- 795
		package.loaded["Script.Dev.Entry"] = nil -- 796
		package.loaded["Script.Dev.WebServer"] = nil -- 797
		return Director.systemScheduler:schedule(function() -- 798
			Routine:clear() -- 799
			oldRequire("Script.Dev.Entry") -- 800
			return true -- 801
		end) -- 798
	end) -- 790
end -- 790
local setWorkspace -- 803
setWorkspace = function(path) -- 803
	clearTempFiles() -- 804
	Content.writablePath = path -- 805
	config.writablePath = Content.writablePath -- 806
	return thread(function() -- 807
		sleep() -- 808
		return reloadDevEntry() -- 809
	end) -- 807
end -- 803
_module_0["setWorkspace"] = setWorkspace -- 803
local quit = false -- 811
local activeSearchId = 0 -- 813
local handleSearchFiles -- 815
handleSearchFiles = function(payload) -- 815
	if not payload then -- 816
		return -- 816
	end -- 816
	local id = payload.id -- 817
	if id == nil then -- 818
		return -- 818
	end -- 818
	activeSearchId = id -- 819
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 820
	if path == nil then -- 821
		path = "" -- 821
	end -- 821
	if exts == nil then -- 822
		exts = { } -- 822
	end -- 822
	if globs == nil then -- 823
		globs = { } -- 823
	end -- 823
	if extensionLevels == nil then -- 824
		extensionLevels = { } -- 824
	end -- 824
	if pattern == nil then -- 825
		pattern = "" -- 825
	end -- 825
	if pattern == "" then -- 827
		return -- 827
	end -- 827
	local useRegex = payload.useRegex == true -- 828
	local caseSensitive = payload.caseSensitive == true -- 829
	local includeContent = payload.includeContent ~= false -- 830
	local contentWindow = payload.contentWindow or 0 -- 831
	return Director.systemScheduler:schedule(once(function() -- 832
		local stopped = false -- 833
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 834
			if activeSearchId ~= id then -- 835
				stopped = true -- 836
				return true -- 837
			end -- 835
			emit("AppWS", "Send", json.encode({ -- 839
				name = "SearchFilesResult", -- 839
				id = id, -- 839
				result = result -- 839
			})) -- 838
			return false -- 841
		end) -- 834
		return emit("AppWS", "Send", json.encode({ -- 843
			name = "SearchFilesDone", -- 843
			id = id, -- 843
			stopped = stopped -- 843
		})) -- 842
	end)) -- 832
end -- 815
local stop -- 846
stop = function() -- 846
	if isInEntry then -- 847
		return false -- 847
	end -- 847
	allClear() -- 848
	isInEntry = true -- 849
	currentEntry = nil -- 850
	return true -- 851
end -- 846
_module_0["stop"] = stop -- 846
local getCurrentEntryStatus -- 853
getCurrentEntryStatus = function() -- 853
	local entry = currentEntry -- 854
	if not (entry and not isInEntry) then -- 855
		return { -- 855
			success = true, -- 855
			running = false, -- 855
			runId = allEntries.runId -- 855
		} -- 855
	end -- 855
	local status = { -- 857
		success = true, -- 857
		running = true, -- 858
		kind = entry.runKind or "file", -- 859
		runId = allEntries.runId, -- 860
		entryName = entry.entryName, -- 861
		fileName = entry.fileName -- 862
	} -- 856
	if entry.workDir then -- 863
		status.workDir = entry.workDir -- 863
	end -- 863
	if entry.projectRoot then -- 864
		status.projectRoot = entry.projectRoot -- 864
	end -- 864
	return status -- 865
end -- 853
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 853
local _anon_func_2 = function(_with_0) -- 884
	local _val_0 = App.platform -- 884
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 884
end -- 884
setupEventHandlers = function() -- 867
	local _with_0 = Director.postNode -- 868
	_with_0:onAppEvent(function(eventType) -- 869
		if "Quit" == eventType then -- 870
			quit = true -- 871
			allClear() -- 872
			return clearTempFiles() -- 873
		elseif "Shutdown" == eventType then -- 874
			return stop() -- 875
		end -- 869
	end) -- 869
	_with_0:onAppChange(function(settingName) -- 876
		if "Theme" == settingName then -- 877
			config.themeColor = App.themeColor:toARGB() -- 878
		elseif "Locale" == settingName then -- 879
			config.locale = App.locale -- 880
			updateLocale() -- 881
			return teal.clear(true) -- 882
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 883
			if _anon_func_2(_with_0) then -- 884
				if "FullScreen" == settingName then -- 886
					config.fullScreen = App.fullScreen -- 886
				elseif "Position" == settingName then -- 887
					local _obj_0 = App.winPosition -- 887
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 887
				elseif "Size" == settingName then -- 888
					local width, height -- 889
					do -- 889
						local _obj_0 = App.winSize -- 889
						width, height = _obj_0.width, _obj_0.height -- 889
					end -- 889
					config.winWidth = width -- 890
					config.winHeight = height -- 891
				end -- 885
			end -- 884
		end -- 876
	end) -- 876
	_with_0:onAppWS(function(event) -- 892
		if event.type == "Close" then -- 893
			if HttpServer.wsConnectionCount == 0 then -- 894
				updateEntries() -- 895
			end -- 894
			return -- 896
		end -- 893
		if not (event.type == "Receive") then -- 897
			return -- 897
		end -- 897
		local data = json.decode(event.msg) -- 898
		if not data then -- 899
			return -- 899
		end -- 899
		local _exp_0 = data.name -- 900
		if "SearchFiles" == _exp_0 then -- 901
			return handleSearchFiles(data) -- 902
		elseif "SearchFilesStop" == _exp_0 then -- 903
			if data.id == nil or data.id == activeSearchId then -- 904
				activeSearchId = 0 -- 905
			end -- 904
		end -- 900
	end) -- 892
	_with_0:slot("UpdateEntries", function() -- 906
		return updateEntries() -- 906
	end) -- 906
	return _with_0 -- 868
end -- 867
setupEventHandlers() -- 908
clearTempFiles() -- 909
local downloadFile -- 911
downloadFile = function(url, target) -- 911
	return Director.systemScheduler:schedule(once(function() -- 911
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 912
			if quit then -- 913
				return true -- 913
			end -- 913
			emit("AppWS", "Send", json.encode({ -- 915
				name = "Download", -- 915
				url = url, -- 915
				status = "downloading", -- 915
				progress = current / total -- 916
			})) -- 914
			return false -- 912
		end) -- 912
		return emit("AppWS", "Send", json.encode(success and { -- 919
			name = "Download", -- 919
			url = url, -- 919
			status = "completed", -- 919
			progress = 1.0 -- 920
		} or { -- 922
			name = "Download", -- 922
			url = url, -- 922
			status = "failed", -- 922
			progress = 0.0 -- 923
		})) -- 918
	end)) -- 911
end -- 911
_module_0["downloadFile"] = downloadFile -- 911
local _anon_func_3 = function(file, require, workDir) -- 935
	if workDir == nil then -- 935
		workDir = Path:getPath(file) -- 935
	end -- 935
	Content:insertSearchPath(1, workDir) -- 936
	local scriptPath = Path(workDir, "Script") -- 937
	if Content:exist(scriptPath) then -- 938
		Content:insertSearchPath(1, scriptPath) -- 939
	end -- 938
	local result = require(file) -- 940
	if "function" == type(result) then -- 941
		result() -- 941
	end -- 941
	return nil -- 942
end -- 935
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 971
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 971
	label.alignment = "Left" -- 972
	label.textWidth = width - fontSize -- 973
	label.text = err -- 974
	return label -- 971
end -- 971
local enterEntryAsync -- 926
enterEntryAsync = function(entry) -- 926
	allEntries.runId = allEntries.runId + 1 -- 927
	isInEntry = false -- 928
	App.idled = false -- 929
	emit(Profiler.EventName, "ClearLoader") -- 930
	currentEntry = entry -- 931
	local file, workDir = entry.fileName, entry.workDir -- 932
	sleep() -- 933
	return xpcall(_anon_func_3, function(msg) -- 942
		local err = debug.traceback(msg) -- 944
		Log("Error", err) -- 945
		allClear() -- 946
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 947
		local viewWidth, viewHeight -- 948
		do -- 948
			local _obj_0 = View.size -- 948
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 948
		end -- 948
		local width, height = viewWidth - 20, viewHeight - 20 -- 949
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 950
		Director.ui:addChild((function() -- 951
			local root = AlignNode() -- 951
			do -- 952
				local _obj_0 = App.bufferSize -- 952
				width, height = _obj_0.width, _obj_0.height -- 952
			end -- 952
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 953
			root:onAppChange(function(settingName) -- 954
				if settingName == "Size" then -- 954
					do -- 955
						local _obj_0 = App.bufferSize -- 955
						width, height = _obj_0.width, _obj_0.height -- 955
					end -- 955
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 956
				end -- 954
			end) -- 954
			root:addChild((function() -- 957
				local _with_0 = ScrollArea({ -- 958
					width = width, -- 958
					height = height, -- 959
					paddingX = 0, -- 960
					paddingY = 50, -- 961
					viewWidth = height, -- 962
					viewHeight = height -- 963
				}) -- 957
				root:onAlignLayout(function(w, h) -- 965
					_with_0.position = Vec2(w / 2, h / 2) -- 966
					w = w - 20 -- 967
					h = h - 20 -- 968
					_with_0.view.children.first.textWidth = w - fontSize -- 969
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 970
				end) -- 965
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 971
				return _with_0 -- 957
			end)()) -- 957
			return root -- 951
		end)()) -- 951
		return err -- 975
	end, file, require, workDir) -- 934
end -- 926
_module_0["enterEntryAsync"] = enterEntryAsync -- 926
local enterDemoEntry -- 977
enterDemoEntry = function(entry) -- 977
	return thread(function() -- 977
		return enterEntryAsync(entry) -- 977
	end) -- 977
end -- 977
local reloadCurrentEntry -- 979
reloadCurrentEntry = function() -- 979
	if currentEntry then -- 980
		allClear() -- 981
		return enterDemoEntry(currentEntry) -- 982
	end -- 980
end -- 979
Director.clearColor = Color(0xff1a1a1a) -- 984
local descColor = Color(0xffa1a1a1) -- 985
local extraOperations -- 988
do -- 988
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 989
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 990
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 991
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 992
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 993
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 994
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 995
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 996
	local isOSSLicenseExist = Content:exist("LICENSES") -- 997
	local ossLicenses = nil -- 998
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 999
	local failedSetFolder = false -- 1000
	local statusFlags = { -- 1001
		"NoResize", -- 1001
		"NoMove", -- 1001
		"NoCollapse", -- 1001
		"AlwaysAutoResize", -- 1001
		"NoSavedSettings" -- 1001
	} -- 1001
	extraOperations = function() -- 1008
		local zh = useChinese -- 1009
		if isDesktop then -- 1010
			local alwaysOnTop = config.alwaysOnTop -- 1011
			do -- 1012
				local changed -- 1012
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1012
				if changed then -- 1012
					App.alwaysOnTop = alwaysOnTop -- 1013
					config.alwaysOnTop = alwaysOnTop -- 1014
				end -- 1012
			end -- 1012
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1015
			do -- 1016
				local changed -- 1016
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1016
				if changed then -- 1016
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1017
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1018
				end -- 1016
			end -- 1016
			SameLine() -- 1019
			TextColored(descColor, "(?)") -- 1020
			if IsItemHovered() then -- 1021
				BeginTooltip(function() -- 1022
					return PushTextWrapPos(360, function() -- 1023
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1024
					end) -- 1023
				end) -- 1022
			end -- 1021
		end -- 1010
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1039
		do -- 1043
			local changed -- 1043
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1043
			if changed then -- 1043
				config.showPreview = showPreview -- 1044
				updateEntries() -- 1045
				if not showPreview then -- 1046
					thread(function() -- 1047
						collectgarbage() -- 1048
						return Cache:removeUnused("Texture") -- 1049
					end) -- 1047
				end -- 1046
			end -- 1043
		end -- 1043
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1050
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1051
			if changed then -- 1051
				config.webIDEEnabled = webIDEEnabled -- 1052
				App.webIDEEnabled = webIDEEnabled -- 1053
			end -- 1051
		end -- 1050
		do -- 1054
			local themeColor = App.themeColor -- 1055
			local writablePath = config.writablePath -- 1056
			SeparatorText(zh and "工作目录" or "Workspace") -- 1057
			PushTextWrapPos(400, function() -- 1058
				return TextColored(themeColor, writablePath) -- 1059
			end) -- 1058
			if not isDesktop then -- 1060
				goto skipSetting -- 1060
			end -- 1060
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1061
			if Button(zh and "改变目录" or "Set Folder") then -- 1062
				App:openFileDialog(true, function(path) -- 1063
					if path == "" then -- 1064
						return -- 1064
					end -- 1064
					local relPath = Path:getRelative(Content.assetPath, path) -- 1065
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1066
						return setWorkspace(path) -- 1067
					else -- 1069
						failedSetFolder = true -- 1069
					end -- 1066
				end) -- 1063
			end -- 1062
			if failedSetFolder then -- 1070
				failedSetFolder = false -- 1071
				OpenPopup(popupName) -- 1072
			end -- 1070
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1073
			BeginPopupModal(popupName, statusFlags, function() -- 1074
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1075
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1076
					return CloseCurrentPopup() -- 1077
				end -- 1076
			end) -- 1074
			SameLine() -- 1078
			if Button(zh and "使用默认" or "Use Default") then -- 1079
				setWorkspace(Content.appPath) -- 1080
			end -- 1079
			Separator() -- 1081
			::skipSetting:: -- 1082
		end -- 1054
		renderAgentStorage(zh) -- 1083
		if isOSSLicenseExist then -- 1084
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1085
				if not ossLicenses then -- 1086
					local licenseText = Content:load("LICENSES") -- 1087
					if licenseText then -- 1087
						local GSplit -- 1088
						do -- 1088
							local _obj_0 = require("Utils") -- 1088
							GSplit = _obj_0.GSplit -- 1088
						end -- 1088
						ossLicenses = { } -- 1089
						licenseText = licenseText:gsub("\r\n", "\n") -- 1090
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1091
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1092
							if name then -- 1092
								ossLicenses[#ossLicenses + 1] = { -- 1093
									name, -- 1093
									text -- 1093
								} -- 1093
							end -- 1092
						end -- 1091
					end -- 1087
				end -- 1086
				if ossLicenses then -- 1094
					OpenPopup(ossLicensePopup) -- 1094
				end -- 1094
			end -- 1085
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1095
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1096
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1097
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1098
				return BeginPopupModal(ossLicensePopup, true, { -- 1101
					"NoSavedSettings" -- 1101
				}, function() -- 1102
					for _index_0 = 1, #ossLicenses do -- 1103
						local _des_0 = ossLicenses[_index_0] -- 1103
						local firstLine, text = _des_0[1], _des_0[2] -- 1103
						local name, license = firstLine:match("(.+): (.+)") -- 1105
						if name then -- 1105
							TextColored(themeColor, name) -- 1106
							SameLine() -- 1107
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1108
								return TextWrapped(text) -- 1108
							end) -- 1108
						end -- 1105
					end -- 1103
				end) -- 1098
			end) -- 1098
		end -- 1084
		if not App.debugging then -- 1111
			return -- 1111
		end -- 1111
		return TreeNode(zh and "开发操作" or "Development", function() -- 1112
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1113
				OpenPopup("build") -- 1113
			end -- 1113
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1114
				return BeginPopup("build", function() -- 1114
					if Selectable(zh and "编译" or "Compile") then -- 1115
						doCompile(false) -- 1115
					end -- 1115
					Separator() -- 1116
					if Selectable(zh and "压缩" or "Minify") then -- 1117
						doCompile(true) -- 1117
					end -- 1117
					Separator() -- 1118
					if Selectable(zh and "清理" or "Clean") then -- 1119
						return doClean() -- 1119
					end -- 1119
				end) -- 1114
			end) -- 1114
			if isInEntry then -- 1120
				if waitForWebStart then -- 1121
					BeginDisabled(function() -- 1122
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1122
					end) -- 1122
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1123
					reloadDevEntry() -- 1124
				end -- 1121
			end -- 1120
			do -- 1125
				local changed -- 1125
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1125
				if changed then -- 1125
					View.scale = scaleContent and screenScale or 1 -- 1126
				end -- 1125
			end -- 1125
			do -- 1127
				local changed -- 1127
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1127
				if changed then -- 1127
					config.engineDev = engineDev -- 1128
				end -- 1127
			end -- 1127
			do -- 1129
				local changed -- 1129
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1129
				if changed then -- 1129
					config.webIDETourCompleted = webIDETourCompleted -- 1130
				end -- 1129
			end -- 1129
			if testingThread then -- 1131
				return BeginDisabled(function() -- 1132
					return Button(zh and "开始自动测试" or "Test automatically") -- 1132
				end) -- 1132
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1133
				testingThread = thread(function() -- 1134
					local _ <close> = setmetatable({ }, { -- 1135
						__close = function() -- 1135
							allClear() -- 1136
							testingThread = nil -- 1137
							isInEntry = true -- 1138
							currentEntry = nil -- 1139
							return print("Testing done!") -- 1140
						end -- 1135
					}) -- 1135
					for _, entry in ipairs(allEntries) do -- 1141
						allClear() -- 1142
						print("Start " .. tostring(entry.entryName)) -- 1143
						enterDemoEntry(entry) -- 1144
						sleep(2) -- 1145
						print("Stop " .. tostring(entry.entryName)) -- 1146
					end -- 1141
				end) -- 1134
			end -- 1131
		end) -- 1112
	end -- 1008
end -- 988
local icon = Path("Script", "Dev", "icon_s.png") -- 1148
local iconTex = nil -- 1149
thread(function() -- 1150
	if Cache:loadAsync(icon) then -- 1150
		iconTex = Texture2D(icon) -- 1150
	end -- 1150
end) -- 1150
local webStatus = nil -- 1152
local urlClicked = nil -- 1153
local authCode = string.format("%06d", math.random(0, 999999)) -- 1155
local authCodeTTL = 30.0 -- 1157
_module_0.getAuthCode = function() -- 1158
	return authCode -- 1158
end -- 1158
_module_0.invalidateAuthCode = function() -- 1159
	authCode = string.format("%06d", math.random(0, 999999)) -- 1160
	authCodeTTL = 30.0 -- 1161
end -- 1159
local AuthSession -- 1163
do -- 1163
	local pending = nil -- 1164
	local session = nil -- 1165
	AuthSession = { -- 1167
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1167
			pending = { -- 1169
				sessionId = sessionId, -- 1169
				confirmCode = confirmCode, -- 1170
				expiresAt = expiresAt, -- 1171
				ttl = ttl, -- 1172
				approved = false -- 1173
			} -- 1168
		end, -- 1167
		getPending = function() -- 1175
			return pending -- 1175
		end, -- 1175
		approvePending = function(sessionId) -- 1177
			if pending and pending.sessionId == sessionId then -- 1178
				pending.approved = true -- 1179
				return true -- 1180
			end -- 1178
			return false -- 1181
		end, -- 1177
		clearPending = function() -- 1183
			pending = nil -- 1183
		end, -- 1183
		setSession = function(sessionId, sessionSecret) -- 1185
			session = { -- 1187
				sessionId = sessionId, -- 1187
				sessionSecret = sessionSecret -- 1188
			} -- 1186
		end, -- 1185
		getSession = function() -- 1190
			return session -- 1190
		end -- 1190
	} -- 1166
end -- 1163
_module_0["AuthSession"] = AuthSession -- 1163
local transparant = Color(0x0) -- 1193
local windowFlags = { -- 1194
	"NoTitleBar", -- 1194
	"NoResize", -- 1194
	"NoMove", -- 1194
	"NoCollapse", -- 1194
	"NoSavedSettings", -- 1194
	"NoFocusOnAppearing", -- 1194
	"NoBringToFrontOnFocus" -- 1194
} -- 1194
local statusFlags = { -- 1203
	"NoTitleBar", -- 1203
	"NoResize", -- 1203
	"NoMove", -- 1203
	"NoCollapse", -- 1203
	"AlwaysAutoResize", -- 1203
	"NoSavedSettings" -- 1203
} -- 1203
local displayWindowFlags = { -- 1211
	"NoDecoration", -- 1211
	"NoSavedSettings", -- 1211
	"NoMove", -- 1211
	"NoScrollWithMouse", -- 1211
	"AlwaysAutoResize", -- 1211
	"NoFocusOnAppearing" -- 1211
} -- 1211
local _anon_func_5 = function(allEntries, currentIndex) -- 1284
	if currentIndex > 1 then -- 1284
		return allEntries[currentIndex - 1] -- 1285
	else -- 1287
		return allEntries[#allEntries] -- 1287
	end -- 1284
end -- 1284
local _anon_func_6 = function(allEntries, currentIndex) -- 1291
	if currentIndex < #allEntries then -- 1291
		return allEntries[currentIndex + 1] -- 1292
	else -- 1294
		return allEntries[1] -- 1294
	end -- 1291
end -- 1291
do -- 1220
	local gamepadInputWindowFlags = { -- 1221
		"NoDecoration", -- 1221
		"NoSavedSettings", -- 1221
		"NoMove", -- 1221
		"NoScrollbar", -- 1221
		"NoScrollWithMouse", -- 1221
		"NoFocusOnAppearing", -- 1221
		"NoBringToFrontOnFocus" -- 1221
	} -- 1221
	local initFooter = true -- 1230
	local gamepadInputFocused = false -- 1231
	footerWindow = threadLoop(function() -- 1232
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1233
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1234
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1235
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1236
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1237
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1238
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1239
		if mobileMode then -- 1240
			return -- 1240
		end -- 1240
		local zh = useChinese -- 1241
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1242
		if authCodeTTL <= 0 then -- 1243
			authCodeTTL = 30.0 -- 1244
			authCode = string.format("%06d", math.random(0, 999999)) -- 1245
		end -- 1243
		if HttpServer.wsConnectionCount > 0 then -- 1246
			return -- 1247
		end -- 1246
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1248
			if App.platform == "Emscripten" then -- 1249
				stop() -- 1251
			else -- 1253
				allClear() -- 1253
				App.devMode = false -- 1254
				App:shutdown() -- 1255
			end -- 1249
		end -- 1248
		do -- 1256
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1257
			if ctrl and Keyboard:isKeyDown("Q") then -- 1258
				stop() -- 1259
			end -- 1258
			if ctrl and Keyboard:isKeyDown("Z") then -- 1260
				reloadCurrentEntry() -- 1261
			end -- 1260
			if ctrl and Keyboard:isKeyDown(",") then -- 1262
				if showFooter then -- 1263
					showStats = not showStats -- 1263
				else -- 1263
					showStats = true -- 1263
				end -- 1263
				showFooter = true -- 1264
				config.showFooter = showFooter -- 1265
				config.showStats = showStats -- 1266
			end -- 1262
			if ctrl and Keyboard:isKeyDown(".") then -- 1267
				if showFooter then -- 1268
					showConsole = not showConsole -- 1268
				else -- 1268
					showConsole = true -- 1268
				end -- 1268
				showFooter = true -- 1269
				config.showFooter = showFooter -- 1270
				config.showConsole = showConsole -- 1271
			end -- 1267
			if ctrl and Keyboard:isKeyDown("/") then -- 1272
				showFooter = not showFooter -- 1273
				config.showFooter = showFooter -- 1274
			end -- 1272
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1275
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1276
			local currentIndex = nil -- 1277
			for i, entry in ipairs(allEntries) do -- 1278
				if currentEntry == entry then -- 1279
					currentIndex = i -- 1280
				end -- 1279
			end -- 1278
			if left then -- 1281
				allClear() -- 1282
				if currentIndex == nil then -- 1283
					currentIndex = #allEntries + 1 -- 1283
				end -- 1283
				enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1284
			end -- 1281
			if right then -- 1288
				allClear() -- 1289
				if currentIndex == nil then -- 1290
					currentIndex = 0 -- 1290
				end -- 1290
				enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1291
			end -- 1288
		end -- 1256
		if not showEntry then -- 1295
			return -- 1295
		end -- 1295
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1297
			reloadDevEntry() -- 1301
		end -- 1297
		if initFooter then -- 1302
			initFooter = false -- 1303
		end -- 1302
		local width, height -- 1305
		do -- 1305
			local _obj_0 = App.visualSize -- 1305
			width, height = _obj_0.width, _obj_0.height -- 1305
		end -- 1305
		if isInEntry then -- 1306
			gamepadInputFocused = false -- 1307
		else -- 1309
			SetNextWindowBgAlpha(0.0) -- 1309
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1310
			SetNextWindowPos(Vec2.zero, "Always") -- 1311
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1312
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1313
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1314
						if not gamepadInputFocused then -- 1315
							SetWindowFocus("DoraGamepadInput") -- 1316
							gamepadInputFocused = true -- 1317
						end -- 1315
					end) -- 1314
				end) -- 1313
			end) -- 1312
		end -- 1306
		if isInEntry or showFooter then -- 1319
			SetNextWindowSize(Vec2(width, 50)) -- 1320
			SetNextWindowPos(Vec2(0, height - 50)) -- 1321
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1322
				return PushStyleVar("WindowRounding", 0, function() -- 1323
					return Begin("Footer", windowFlags, function() -- 1324
						Separator() -- 1325
						if iconTex then -- 1326
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1327
								showStats = not showStats -- 1328
								config.showStats = showStats -- 1329
							end -- 1327
							SameLine() -- 1330
							if Button(">_", Vec2(30, 30)) then -- 1331
								showConsole = not showConsole -- 1332
								config.showConsole = showConsole -- 1333
							end -- 1331
						end -- 1326
						if isInEntry and config.updateNotification then -- 1334
							SameLine() -- 1335
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1336
								allClear() -- 1337
								config.updateNotification = false -- 1338
								enterDemoEntry({ -- 1340
									entryName = "SelfUpdater", -- 1340
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1341
								}) -- 1339
							end -- 1336
						end -- 1334
						if not isInEntry then -- 1342
							SameLine() -- 1343
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1344
							local currentIndex = nil -- 1345
							for i, entry in ipairs(allEntries) do -- 1346
								if currentEntry == entry then -- 1347
									currentIndex = i -- 1348
								end -- 1347
							end -- 1346
							if currentIndex then -- 1349
								if currentIndex > 1 then -- 1350
									SameLine() -- 1351
									if Button("<<", Vec2(30, 30)) then -- 1352
										allClear() -- 1353
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1354
									end -- 1352
								end -- 1350
								if currentIndex < #allEntries then -- 1355
									SameLine() -- 1356
									if Button(">>", Vec2(30, 30)) then -- 1357
										allClear() -- 1358
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1359
									end -- 1357
								end -- 1355
							end -- 1349
							SameLine() -- 1360
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1361
								reloadCurrentEntry() -- 1362
							end -- 1361
							if back then -- 1363
								allClear() -- 1364
								isInEntry = true -- 1365
								currentEntry = nil -- 1366
							end -- 1363
						end -- 1342
					end) -- 1324
				end) -- 1323
			end) -- 1322
		end -- 1319
		if isInEntry then -- 1368
			local showURL = true -- 1369
			local webIDEWidth -- 1370
			do -- 1370
				local base -- 1371
				if config.updateNotification then -- 1371
					base = 460 -- 1371
				else -- 1371
					base = 360 -- 1371
				end -- 1371
				local extra = 35 -- 1372
				webIDEWidth = base + extra -- 1373
			end -- 1370
			if width < webIDEWidth then -- 1374
				showURL = false -- 1374
			end -- 1374
			SetNextWindowBgAlpha(0.0) -- 1375
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1376
			Begin("Web IDE", displayWindowFlags, function() -- 1377
				local pending = AuthSession.getPending() -- 1378
				local hovered = false -- 1379
				if not pending and showURL then -- 1380
					do -- 1381
						local url -- 1381
						if webStatus ~= nil then -- 1381
							url = webStatus.url -- 1381
						end -- 1381
						if url then -- 1381
							if isDesktop and not config.fullScreen then -- 1382
								if urlClicked then -- 1383
									BeginDisabled(function() -- 1384
										return Button(url) -- 1384
									end) -- 1384
								elseif Button(url) then -- 1385
									urlClicked = once(function() -- 1386
										return sleep(5) -- 1386
									end) -- 1386
									App:openURL("http://localhost:8866") -- 1387
								end -- 1383
							else -- 1389
								TextColored(descColor, url) -- 1389
							end -- 1382
						else -- 1391
							TextColored(descColor, zh and '不可用' or 'not available') -- 1391
						end -- 1381
					end -- 1381
					hovered = IsItemHovered() -- 1392
				else -- 1394
					TextColored(descColor, "(?)") -- 1394
					hovered = IsItemHovered() -- 1395
				end -- 1380
				SameLine() -- 1396
				local themeColor = App.themeColor -- 1397
				if pending then -- 1398
					if not pending.approved then -- 1399
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1400
						local ttl = pending.ttl or 1 -- 1401
						PushStyleColor("Text", themeColor, function() -- 1402
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1403
							hovered = hovered or IsItemHovered() -- 1404
						end) -- 1402
						SameLine() -- 1405
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1406
							AuthSession.approvePending(pending.sessionId) -- 1407
						end -- 1406
						if hovered then -- 1408
							return BeginTooltip(function() -- 1409
								return PushTextWrapPos(280, function() -- 1410
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1411
								end) -- 1410
							end) -- 1409
						end -- 1408
					end -- 1399
				else -- 1413
					PushStyleColor("Text", themeColor, function() -- 1413
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1414
						hovered = hovered or IsItemHovered() -- 1415
					end) -- 1413
					if hovered then -- 1416
						return BeginTooltip(function() -- 1417
							return PushTextWrapPos(280, function() -- 1418
								local url -- 1419
								if webStatus ~= nil then -- 1419
									url = webStatus.url -- 1419
								end -- 1419
								if url then -- 1419
									local address -- 1420
									if showURL then -- 1420
										address = "Web IDE" -- 1420
									else -- 1420
										address = url -- 1420
									end -- 1420
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1421
								else -- 1423
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1423
								end -- 1419
							end) -- 1418
						end) -- 1417
					end -- 1416
				end -- 1398
			end) -- 1377
		end -- 1368
		if not isInEntry then -- 1424
			SetNextWindowSize(Vec2(50, 50)) -- 1425
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1426
			PushStyleColor("WindowBg", transparant, function() -- 1427
				return Begin("Show", displayWindowFlags, function() -- 1427
					if width >= 370 then -- 1428
						local changed -- 1429
						changed, showFooter = Checkbox("##dev", showFooter) -- 1429
						if changed then -- 1429
							config.showFooter = showFooter -- 1430
						end -- 1429
					end -- 1428
				end) -- 1427
			end) -- 1427
		end -- 1424
		if isInEntry or showFooter then -- 1432
			if showStats then -- 1433
				PushStyleVar("WindowRounding", 0, function() -- 1434
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1435
					SetNextWindowSize(Vec2(0, height - 50)) -- 1436
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1437
					config.showStats = showStats -- 1438
				end) -- 1434
			end -- 1433
			if showConsole then -- 1439
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1440
				return PushStyleVar("WindowRounding", 6, function() -- 1441
					return ShowConsole() -- 1442
				end) -- 1441
			end -- 1439
		end -- 1432
	end) -- 1232
end -- 1220
do -- 1445
	local MaxWidth <const> = 960 -- 1446
	local toolOpen = false -- 1448
	local filterText = nil -- 1449
	allEntries.anyEntryMatched = false -- 1450
	allEntries.match = function(name) -- 1451
		local res = not filterText or name:lower():match(filterText) -- 1452
		if res then -- 1453
			allEntries.anyEntryMatched = true -- 1453
		end -- 1453
		return res -- 1454
	end -- 1451
	allEntries.thinSep = function() -- 1456
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1456
			return ImGui.SeparatorText("") -- 1456
		end) -- 1456
	end -- 1456
	entryWindow = threadLoop(function() -- 1457
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1458
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1459
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1460
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1461
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1462
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1463
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1464
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1465
		local connected = syncWebIDEControl() -- 1466
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1468
			if not allEntries.pendingPackagePath then -- 1469
				local path = App:takeReceivedFile() -- 1470
				if path ~= "" then -- 1471
					allEntries.pendingPackagePath = path -- 1471
				end -- 1471
			end -- 1469
			if allEntries.pendingPackagePath then -- 1472
				pendingUIMode = true -- 1472
			end -- 1472
		end -- 1468
		if (pendingUIMode ~= nil) then -- 1474
			local nextMode = pendingUIMode -- 1475
			pendingUIMode = nil -- 1476
			applyUIMode(nextMode) -- 1477
		end -- 1474
		if mobileMode and not connected then -- 1478
			if isInEntry and not feedHost then -- 1479
				applyUIMode(true) -- 1479
			end -- 1479
			return -- 1480
		end -- 1478
		if App.fpsLimited ~= config.fpsLimited then -- 1481
			config.fpsLimited = App.fpsLimited -- 1482
		end -- 1481
		if App.targetFPS ~= config.targetFPS then -- 1483
			config.targetFPS = App.targetFPS -- 1484
		end -- 1483
		if View.vsync ~= config.vsync then -- 1485
			config.vsync = View.vsync -- 1486
		end -- 1485
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1487
			config.fixedFPS = Director.scheduler.fixedFPS -- 1488
		end -- 1487
		if Director.profilerSending ~= config.webProfiler then -- 1489
			config.webProfiler = Director.profilerSending -- 1490
		end -- 1489
		if urlClicked then -- 1491
			local _, result = coroutine.resume(urlClicked) -- 1492
			if result then -- 1493
				coroutine.close(urlClicked) -- 1494
				urlClicked = nil -- 1495
			end -- 1493
		end -- 1491
		if not isInEntry then -- 1496
			return -- 1496
		end -- 1496
		local zh = useChinese -- 1497
		local themeColor = App.themeColor -- 1498
		if connected then -- 1499
			local width, height -- 1500
			do -- 1500
				local _obj_0 = App.visualSize -- 1500
				width, height = _obj_0.width, _obj_0.height -- 1500
			end -- 1500
			SetNextWindowBgAlpha(0.5) -- 1501
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1502
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1503
				Separator() -- 1504
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1505
				if iconTex then -- 1506
					Image(icon, Vec2(24, 24)) -- 1507
					SameLine() -- 1508
				end -- 1506
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1509
				TextColored(descColor, slogon) -- 1510
				return Separator() -- 1511
			end) -- 1503
			return -- 1512
		end -- 1499
		if not showEntry then -- 1513
			return -- 1513
		end -- 1513
		local fullWidth, height -- 1515
		do -- 1515
			local _obj_0 = App.visualSize -- 1515
			fullWidth, height = _obj_0.width, _obj_0.height -- 1515
		end -- 1515
		local width = math.min(MaxWidth, fullWidth) -- 1516
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1517
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1518
		SetNextWindowPos(Vec2.zero) -- 1519
		SetNextWindowBgAlpha(0) -- 1520
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1521
		do -- 1522
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1523
				return Begin("Dora Dev", windowFlags, function() -- 1524
					Dummy(Vec2(fullWidth - 20, 0)) -- 1525
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1526
					SameLine() -- 1527
					if Button(zh and "Go 模式" or "Go Mode") then -- 1528
						setUIMode("mobile") -- 1529
					end -- 1528
					if fullWidth >= 540 then -- 1530
						SameLine() -- 1531
						Dummy(Vec2(fullWidth - 540, 0)) -- 1532
						SameLine() -- 1533
						SetNextItemWidth(zh and -95 or -140) -- 1534
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1535
							"AutoSelectAll" -- 1535
						}) then -- 1535
							config.filter = filterBuf.text -- 1536
						end -- 1535
						SameLine() -- 1537
						if Button(zh and '下载' or 'Download') then -- 1538
							allClear() -- 1539
							enterDemoEntry({ -- 1541
								entryName = "ResourceDownloader", -- 1541
								fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1542
							}) -- 1540
						end -- 1538
					end -- 1530
					return Separator() -- 1543
				end) -- 1524
			end) -- 1523
		end -- 1522
		allEntries.anyEntryMatched = false -- 1545
		SetNextWindowPos(Vec2(0, 50)) -- 1546
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1547
		local scrollbarSize <const> = 25 -- 1549
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1550
		do -- 1551
			return PushStyleColor("WindowBg", transparant, function() -- 1552
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1553
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1554
						return PushStyleVar("Alpha", 1, function() -- 1555
							return Begin("Content", windowFlags, function() -- 1556
								local DemoViewWidth <const> = 220 -- 1557
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1558
								if filterText then -- 1559
									filterText = filterText:lower() -- 1559
								end -- 1559
								if App.platform == "Emscripten" then -- 1560
									Dora.globals.webProjects.draw(zh, themeColor) -- 1561
									allEntries.anyEntryMatched = true -- 1562
								end -- 1560
								if #gamesInDev > 0 then -- 1563
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1564
									Columns(columns, false) -- 1565
									local realViewWidth = GetColumnWidth() - 50 -- 1566
									for _index_0 = 1, #gamesInDev do -- 1567
										local game = gamesInDev[_index_0] -- 1567
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1568
										local displayName -- 1577
										if repo then -- 1577
											if zh then -- 1578
												displayName = repo.title.zh -- 1578
											else -- 1578
												displayName = repo.title.en -- 1578
											end -- 1578
										end -- 1577
										if displayName == nil then -- 1579
											displayName = gameName -- 1579
										end -- 1579
										if allEntries.match(displayName) then -- 1580
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1581
											SameLine() -- 1582
											TextWrapped(displayName) -- 1583
											if columns > 1 then -- 1584
												if bannerFile and bannerTex then -- 1585
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1586
													local displayWidth <const> = realViewWidth -- 1587
													texHeight = displayWidth * texHeight / texWidth -- 1588
													texWidth = displayWidth -- 1589
													Dummy(Vec2.zero) -- 1590
													SameLine() -- 1591
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1592
												end -- 1585
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1593
													enterDemoEntry(game) -- 1594
												end -- 1593
											else -- 1596
												if bannerFile and bannerTex then -- 1596
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1597
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1598
													local sizing = 0.8 -- 1599
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1600
													texWidth = displayWidth * sizing -- 1601
													if texWidth > 500 then -- 1602
														sizing = 0.6 -- 1603
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1604
														texWidth = displayWidth * sizing -- 1605
													end -- 1602
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1606
													Dummy(Vec2(padding, 0)) -- 1607
													SameLine() -- 1608
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1609
												end -- 1596
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1610
													enterDemoEntry(game) -- 1611
												end -- 1610
											end -- 1584
											if #tests == 0 and #examples == 0 then -- 1612
												allEntries.thinSep() -- 1613
											end -- 1612
											NextColumn() -- 1614
										end -- 1580
										local showSep = false -- 1615
										if #examples > 0 then -- 1616
											local showExample = false -- 1617
											for _index_1 = 1, #examples do -- 1618
												local _des_0 = examples[_index_1] -- 1618
												local entryName = _des_0.entryName -- 1618
												if allEntries.match(entryName) then -- 1619
													showExample = true -- 1619
													break -- 1619
												end -- 1619
											end -- 1618
											if showExample then -- 1620
												showSep = true -- 1621
												Columns(1, false) -- 1622
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1623
												SameLine() -- 1624
												local opened -- 1625
												if (filterText ~= nil) then -- 1625
													opened = showExample -- 1625
												else -- 1625
													opened = false -- 1625
												end -- 1625
												if game.exampleOpen == nil then -- 1626
													game.exampleOpen = opened -- 1626
												end -- 1626
												SetNextItemOpen(game.exampleOpen) -- 1627
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1628
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1629
														Columns(maxColumns, false) -- 1630
														for _index_1 = 1, #examples do -- 1631
															local example = examples[_index_1] -- 1631
															local entryName = example.entryName -- 1632
															if not allEntries.match(entryName) then -- 1633
																goto _continue_0 -- 1633
															end -- 1633
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1634
																if Button(entryName, Vec2(-1, 40)) then -- 1635
																	enterDemoEntry(example) -- 1636
																end -- 1635
																return NextColumn() -- 1637
															end) -- 1634
															opened = true -- 1638
															::_continue_0:: -- 1632
														end -- 1631
													end) -- 1629
												end) -- 1628
												game.exampleOpen = opened -- 1639
											end -- 1620
										end -- 1616
										if #tests > 0 then -- 1640
											local showTest = false -- 1641
											for _index_1 = 1, #tests do -- 1642
												local _des_0 = tests[_index_1] -- 1642
												local entryName = _des_0.entryName -- 1642
												if allEntries.match(entryName) then -- 1643
													showTest = true -- 1643
													break -- 1643
												end -- 1643
											end -- 1642
											if showTest then -- 1644
												showSep = true -- 1645
												Columns(1, false) -- 1646
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1647
												SameLine() -- 1648
												local opened -- 1649
												if (filterText ~= nil) then -- 1649
													opened = showTest -- 1649
												else -- 1649
													opened = false -- 1649
												end -- 1649
												if game.testOpen == nil then -- 1650
													game.testOpen = opened -- 1650
												end -- 1650
												SetNextItemOpen(game.testOpen) -- 1651
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1652
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1653
														Columns(maxColumns, false) -- 1654
														for _index_1 = 1, #tests do -- 1655
															local test = tests[_index_1] -- 1655
															local entryName = test.entryName -- 1656
															if not allEntries.match(entryName) then -- 1657
																goto _continue_0 -- 1657
															end -- 1657
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1658
																if Button(entryName, Vec2(-1, 40)) then -- 1659
																	enterDemoEntry(test) -- 1660
																end -- 1659
																return NextColumn() -- 1661
															end) -- 1658
															opened = true -- 1662
															::_continue_0:: -- 1656
														end -- 1655
													end) -- 1653
												end) -- 1652
												game.testOpen = opened -- 1663
											end -- 1644
										end -- 1640
										if showSep then -- 1664
											Columns(1, false) -- 1665
											allEntries.thinSep() -- 1666
											Columns(columns, false) -- 1667
										end -- 1664
									end -- 1567
								end -- 1563
								if #doraTools > 0 then -- 1668
									local showTool = false -- 1669
									for _index_0 = 1, #doraTools do -- 1670
										local _des_0 = doraTools[_index_0] -- 1670
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1670
										local displayName -- 1671
										if repo then -- 1671
											if zh then -- 1672
												displayName = repo.title.zh -- 1672
											else -- 1672
												displayName = repo.title.en -- 1672
											end -- 1672
										end -- 1671
										if displayName == nil then -- 1673
											displayName = entryName -- 1673
										end -- 1673
										if allEntries.match(displayName) then -- 1674
											showTool = true -- 1674
											break -- 1674
										end -- 1674
									end -- 1670
									if not showTool then -- 1675
										goto endEntry -- 1675
									end -- 1675
									Columns(1, false) -- 1676
									TextColored(themeColor, "Dora SSR:") -- 1677
									SameLine() -- 1678
									Text(zh and "开发支持" or "Development Support") -- 1679
									Separator() -- 1680
									if #doraTools > 0 then -- 1681
										local opened -- 1682
										if (filterText ~= nil) then -- 1682
											opened = showTool -- 1682
										else -- 1682
											opened = false -- 1682
										end -- 1682
										SetNextItemOpen(toolOpen) -- 1683
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1684
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1685
												Columns(maxColumns, false) -- 1686
												for _index_0 = 1, #doraTools do -- 1687
													local tool = doraTools[_index_0] -- 1687
													local entryName, repo = tool.entryName, tool.repo -- 1688
													local displayName -- 1689
													if repo then -- 1689
														if zh then -- 1690
															displayName = repo.title.zh -- 1690
														else -- 1690
															displayName = repo.title.en -- 1690
														end -- 1690
													end -- 1689
													if displayName == nil then -- 1691
														displayName = entryName -- 1691
													end -- 1691
													if not allEntries.match(displayName) then -- 1692
														goto _continue_0 -- 1692
													end -- 1692
													if Button(displayName, Vec2(-1, 40)) then -- 1693
														enterDemoEntry(tool) -- 1694
													end -- 1693
													NextColumn() -- 1695
													::_continue_0:: -- 1688
												end -- 1687
												Columns(1, false) -- 1696
												opened = true -- 1697
											end) -- 1685
										end) -- 1684
										toolOpen = opened -- 1698
									end -- 1681
								end -- 1668
								::endEntry:: -- 1699
								if not allEntries.anyEntryMatched then -- 1700
									SetNextWindowBgAlpha(0) -- 1701
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1702
									Begin("Entries Not Found", displayWindowFlags, function() -- 1703
										Separator() -- 1704
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1705
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1706
										return Separator() -- 1707
									end) -- 1703
								end -- 1700
								Columns(1, false) -- 1708
								Dummy(Vec2(100, 80)) -- 1709
								return ScrollWhenDraggingOnVoid() -- 1710
							end) -- 1556
						end) -- 1555
					end) -- 1554
				end) -- 1553
			end) -- 1552
		end -- 1551
	end) -- 1457
end -- 1445
if not (App.platform == "Emscripten") then -- 1715
	local sceneModuleCache = moduleCache -- 1716
	moduleCache = { } -- 1717
	webStatus = oldRequire("Script.Dev.WebServer") -- 1718
	moduleCache = sceneModuleCache -- 1719
end -- 1715
local _anon_func_7 = function(saved) -- 1742
	local _val_0 = saved.kind -- 1742
	return "local" == _val_0 or "discover" == _val_0 -- 1742
end -- 1742
local _anon_func_8 = function(saved) -- 1746
	local _val_0 = saved.activeTab -- 1746
	return "local" == _val_0 or "discover" == _val_0 -- 1746
end -- 1746
startMobileUI = function() -- 1721
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1722
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1723
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1724
	local getMobileFeedResources -- 1725
	do -- 1725
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1725
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1725
	end -- 1725
	local loadCachedCatalog -- 1726
	do -- 1726
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1726
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1726
	end -- 1726
	local getResourceInstallPath, getInstalledCatalogResource -- 1727
	do -- 1727
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1727
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1727
	end -- 1727
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1728
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1729
	local feedOptions = nil -- 1730
	local mobileLaunchErrors = { } -- 1731
	local withMobileLaunchErrors -- 1732
	withMobileLaunchErrors = function(items) -- 1732
		for _index_0 = 1, #items do -- 1733
			local item = items[_index_0] -- 1733
			item.launchError = mobileLaunchErrors[item.id] -- 1734
		end -- 1733
		return items -- 1735
	end -- 1732
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1736
	local loadRememberedMobileFeedState -- 1737
	loadRememberedMobileFeedState = function() -- 1737
		local raw = rememberedMobileFeedData -- 1738
		if not (type(raw) == "string" and raw ~= "") then -- 1739
			return -- 1739
		end -- 1739
		local ok, saved = pcall(json.decode, raw) -- 1740
		if not (ok and type(saved) == "table") then -- 1741
			return -- 1741
		end -- 1741
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1742
			local state = { -- 1743
				activeTab = saved.kind -- 1743
			} -- 1743
			state[saved.kind] = saved -- 1744
			return state -- 1745
		end -- 1742
		local state = { -- 1746
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1746
		} -- 1746
		local _list_0 = { -- 1747
			"local", -- 1747
			"discover" -- 1747
		} -- 1747
		for _index_0 = 1, #_list_0 do -- 1747
			local kind = _list_0[_index_0] -- 1747
			local entry = saved[kind] -- 1748
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1749
				state[kind] = entry -- 1749
			end -- 1749
		end -- 1747
		return state -- 1750
	end -- 1737
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1751
		activeTab = "local" -- 1751
	} -- 1751
	local rememberMobileFeedEntry -- 1752
	rememberMobileFeedEntry = function(entry) -- 1752
		rememberedMobileFeedState.activeTab = entry.kind -- 1753
		rememberedMobileFeedState[entry.kind] = { -- 1755
			id = entry.id, -- 1755
			kind = entry.kind, -- 1756
			workDir = entry.workDir, -- 1757
			fileName = entry.fileName -- 1758
		} -- 1754
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1760
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1761
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1762
			rememberedMobileFeedData -- 1762
		}) -- 1762
	end -- 1752
	local restartMobileFeed -- 1763
	restartMobileFeed = function(entry) -- 1763
		if feedHost then -- 1764
			feedHost:removeFromParent(true) -- 1764
		end -- 1764
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1765
		local initialEntries = { } -- 1766
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1767
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1768
		feedOptions.initialEntries = initialEntries -- 1769
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1770
	end -- 1763
	local startMobilePlay -- 1771
	startMobilePlay = function(entry) -- 1771
		if HttpServer.wsConnectionCount > 0 then -- 1772
			return -- 1772
		end -- 1772
		local originFeed = feedHost -- 1773
		if remixHost then -- 1774
			remixHost:removeFromParent(true) -- 1774
		end -- 1774
		remixHost = nil -- 1775
		mobileLaunchErrors[entry.id] = nil -- 1776
		entry.launchError = nil -- 1777
		local playActive = true -- 1778
		local restoreMobileFeed -- 1779
		restoreMobileFeed = function() -- 1779
			if not playActive then -- 1780
				return -- 1780
			end -- 1780
			playActive = false -- 1781
			allClear() -- 1782
			isInEntry = true -- 1783
			currentEntry = nil -- 1784
			return restartMobileFeed(entry) -- 1785
		end -- 1779
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1787
			onExit = function() -- 1787
				return restoreMobileFeed() -- 1787
			end, -- 1787
			onRuntimeError = function() -- 1788
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1789
				return restoreMobileFeed() -- 1790
			end -- 1788
		})) -- 1786
		return thread(function() -- 1792
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1796
			if not playActive then -- 1797
				return -- 1797
			end -- 1797
			if success then -- 1798
				if originFeed and originFeed.parent then -- 1799
					originFeed.visible = false -- 1799
				end -- 1799
				return -- 1800
			end -- 1798
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1801
			return restoreMobileFeed() -- 1802
		end) -- 1792
	end -- 1771
	feedOptions = { -- 1804
		takeReceivedFile = function() -- 1804
			if allEntries.pendingPackagePath then -- 1805
				local path = allEntries.pendingPackagePath -- 1806
				allEntries.pendingPackagePath = nil -- 1807
				return path -- 1808
			end -- 1805
			return App:takeReceivedFile() -- 1809
		end, -- 1804
		onSwitchMode = function() -- 1810
			if HttpServer.wsConnectionCount == 0 then -- 1810
				pendingUIMode = false -- 1810
			end -- 1810
		end, -- 1810
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1811
		getLocalEntries = function(importedProjectPath) -- 1812
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1813
			feedOptions.dirtyProjectPath = nil -- 1814
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1815
			local cached = loadCachedCatalog() -- 1816
			if cached.success and cached.snapshot then -- 1817
				for _index_0 = 1, #items do -- 1818
					local entry = items[_index_0] -- 1818
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1819
					if resource then -- 1820
						entry.resource = resource -- 1821
						entry.catalogCommit = cached.snapshot.commit -- 1822
					end -- 1820
				end -- 1818
			end -- 1817
			return items -- 1823
		end, -- 1812
		syncDiscover = function(onProgress, onDone, force) -- 1824
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1824
		end, -- 1824
		getDiscoverEntries = function() -- 1825
			local cached = loadCachedCatalog() -- 1826
			if not (cached.success and cached.snapshot) then -- 1827
				return { } -- 1827
			end -- 1827
			local items = { } -- 1828
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1829
			for _index_0 = 1, #_list_0 do -- 1829
				local resource = _list_0[_index_0] -- 1829
				local installed = lifecycle.isMobileResourceReady(resource) -- 1830
				local installPath = getResourceInstallPath(resource.id) -- 1831
				items[#items + 1] = { -- 1833
					id = resource.id, -- 1833
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1834
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1835
					kind = "discover", -- 1836
					bannerFile = resource.bannerPath, -- 1837
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1838
					sourceUrl = resource.versions[1].sources[1].url, -- 1839
					workDir = installed and installPath or nil, -- 1840
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1841
					installed = installed, -- 1842
					resource = resource, -- 1843
					catalogCommit = cached.snapshot.commit, -- 1844
					launchError = mobileLaunchErrors[resource.id] -- 1845
				} -- 1832
			end -- 1829
			return items -- 1847
		end, -- 1825
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1848
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1849
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1850
			end), repairIncomplete, isCanceled) -- 1849
		end, -- 1848
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1852
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1853
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1854
			end), isCanceled) -- 1853
		end, -- 1852
		createProject = function(name, language) -- 1856
			local result = projectCreate.createMobileProject(name, language) -- 1857
			if not result.success then -- 1858
				return result -- 1858
			end -- 1858
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1859
			for _index_0 = 1, #_list_0 do -- 1859
				local entry = _list_0[_index_0] -- 1859
				if entry.workDir == result.workDir then -- 1860
					return { -- 1861
						success = true, -- 1861
						entry = entry -- 1861
					} -- 1861
				end -- 1860
			end -- 1859
			return { -- 1862
				success = false, -- 1862
				error = "created-project-not-found" -- 1862
			} -- 1862
		end, -- 1856
		onPlay = function(entry) -- 1863
			return startMobilePlay(entry) -- 1863
		end, -- 1863
		onRemix = function(entry) -- 1864
			if HttpServer.wsConnectionCount > 0 then -- 1865
				return -- 1865
			end -- 1865
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1866
			local originFeed = feedHost -- 1867
			feedHost.visible = false -- 1868
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1870
				entry = entry, -- 1870
				onProjectChanged = function(current) -- 1871
					feedOptions.dirtyProjectPath = current.workDir -- 1871
				end, -- 1871
				onBack = function() -- 1872
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1873
						originFeed:emit("RestoreFeedEntry", entry) -- 1874
						originFeed.visible = true -- 1875
					end -- 1873
				end, -- 1872
				onPlay = function(current) -- 1876
					return startMobilePlay(current) -- 1876
				end -- 1876
			})) -- 1869
		end -- 1864
	} -- 1803
	return restartMobileFeed() -- 1879
end -- 1721
if mobileMode then -- 1881
	applyUIMode(true) -- 1881
end -- 1881
return _module_0 -- 1
