-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local ShowConsole = _module_0.ShowConsole -- 1
local package = _G.package -- 1
local DB = Dora.DB -- 1
local View = Dora.View -- 1
local Director = Dora.Director -- 1
local Size = Dora.Size -- 1
local thread = Dora.thread -- 1
local sleep = Dora.sleep -- 1
local Vec2 = Dora.Vec2 -- 1
local Color = Dora.Color -- 1
local Buffer = Dora.Buffer -- 1
local HttpClient = Dora.HttpClient -- 1
local json = Dora.json -- 1
local tonumber = _G.tonumber -- 1
local os = _G.os -- 1
local yue = Dora.yue -- 1
local IsFontLoaded = _module_0.IsFontLoaded -- 1
local LoadFontTTF = _module_0.LoadFontTTF -- 1
local table = _G.table -- 1
local Cache = Dora.Cache -- 1
local Texture2D = Dora.Texture2D -- 1
local pairs = _G.pairs -- 1
local tostring = _G.tostring -- 1
local string = _G.string -- 1
local print = _G.print -- 1
local xml = Dora.xml -- 1
local teal = Dora.teal -- 1
local wait = Dora.wait -- 1
local Routine = Dora.Routine -- 1
local Entity = Dora.Entity -- 1
local Platformer = Dora.Platformer -- 1
local Audio = Dora.Audio -- 1
local ubox = Dora.ubox -- 1
local tolua = Dora.tolua -- 1
local collectgarbage = _G.collectgarbage -- 1
local Wasm = Dora.Wasm -- 1
local HttpServer = Dora.HttpServer -- 1
local emit = Dora.emit -- 1
local Profiler = Dora.Profiler -- 1
local xpcall = _G.xpcall -- 1
local debug = _G.debug -- 1
local Log = Dora.Log -- 1
local math = _G.math -- 1
local AlignNode = Dora.AlignNode -- 1
local Label = Dora.Label -- 1
local Checkbox = _module_0.Checkbox -- 1
local SeparatorText = _module_0.SeparatorText -- 1
local PushTextWrapPos = _module_0.PushTextWrapPos -- 1
local TextColored = _module_0.TextColored -- 1
local Button = _module_0.Button -- 1
local SameLine = _module_0.SameLine -- 1
local Separator = _module_0.Separator -- 1
local SetNextWindowPosCenter = _module_0.SetNextWindowPosCenter -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Begin = _module_0.Begin -- 1
local TreeNode = _module_0.TreeNode -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local OpenPopup = _module_0.OpenPopup -- 1
local BeginPopup = _module_0.BeginPopup -- 1
local Selectable = _module_0.Selectable -- 1
local BeginDisabled = _module_0.BeginDisabled -- 1
local setmetatable = _G.setmetatable -- 1
local ipairs = _G.ipairs -- 1
local threadLoop = Dora.threadLoop -- 1
local Keyboard = Dora.Keyboard -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local PushStyleColor = _module_0.PushStyleColor -- 1
local SetNextWindowBgAlpha = _module_0.SetNextWindowBgAlpha -- 1
local Dummy = _module_0.Dummy -- 1
local ImGui = Dora.ImGui -- 1
local ShowStats = _module_0.ShowStats -- 1
local coroutine = _G.coroutine -- 1
local Image = _module_0.Image -- 1
local TextDisabled = _module_0.TextDisabled -- 1
local IsItemHovered = _module_0.IsItemHovered -- 1
local BeginTooltip = _module_0.BeginTooltip -- 1
local Text = _module_0.Text -- 1
local once = Dora.once -- 1
local SetNextItemWidth = _module_0.SetNextItemWidth -- 1
local InputText = _module_0.InputText -- 1
local Columns = _module_0.Columns -- 1
local PushID = _module_0.PushID -- 1
local ImageButton = _module_0.ImageButton -- 1
local NextColumn = _module_0.NextColumn -- 1
local SetNextItemOpen = _module_0.SetNextItemOpen -- 1
local ScrollWhenDraggingOnVoid = _module_0.ScrollWhenDraggingOnVoid -- 1
local _module_0 = { } -- 1
local Content, Path -- 11
do -- 11
	local _obj_0 = Dora -- 11
	Content, Path = _obj_0.Content, _obj_0.Path -- 11
end -- 11
local type <const> = type -- 12
App.idled = true -- 14
ShowConsole(false, true) -- 15
local moduleCache = { } -- 17
local oldRequire = _G.require -- 18
local require -- 19
require = function(path) -- 19
	local loaded = package.loaded[path] -- 20
	if loaded == nil then -- 21
		moduleCache[#moduleCache + 1] = path -- 22
		return oldRequire(path) -- 23
	end -- 21
	return loaded -- 24
end -- 19
_G.require = require -- 25
Dora.require = require -- 26
local searchPaths = Content.searchPaths -- 28
local useChinese = (App.locale:match("^zh") ~= nil) -- 30
local updateLocale -- 31
updateLocale = function() -- 31
	useChinese = (App.locale:match("^zh") ~= nil) -- 32
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 33
	Content.searchPaths = searchPaths -- 34
end -- 31
if DB:exist("Config") then -- 36
	do -- 37
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 37
		local _type_0 = type(_exp_0) -- 38
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 38
		if _tab_0 then -- 38
			local locale -- 38
			do -- 38
				local _obj_0 = _exp_0[1] -- 38
				local _type_1 = type(_obj_0) -- 38
				if "table" == _type_1 or "userdata" == _type_1 then -- 38
					locale = _obj_0[1] -- 38
				end -- 40
			end -- 40
			if locale ~= nil then -- 38
				if App.locale ~= locale then -- 38
					App.locale = locale -- 39
					updateLocale() -- 40
				end -- 38
			end -- 38
		end -- 40
	end -- 40
	local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 41
	local _type_0 = type(_exp_0) -- 42
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 42
	if _tab_0 then -- 42
		local writablePath -- 42
		do -- 42
			local _obj_0 = _exp_0[1] -- 42
			local _type_1 = type(_obj_0) -- 42
			if "table" == _type_1 or "userdata" == _type_1 then -- 42
				writablePath = _obj_0[1] -- 42
			end -- 43
		end -- 43
		if writablePath ~= nil then -- 42
			Content.writablePath = writablePath -- 43
		end -- 42
	end -- 43
end -- 36
local Config = require("Config") -- 45
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected") -- 47
config:load() -- 74
if not (config.writablePath ~= nil) then -- 76
	config.writablePath = Content.appPath -- 77
end -- 76
if not (config.webIDEConnected ~= nil) then -- 79
	config.webIDEConnected = false -- 80
end -- 79
if (config.fpsLimited ~= nil) then -- 82
	App.fpsLimited = config.fpsLimited -- 83
else -- 85
	config.fpsLimited = App.fpsLimited -- 85
end -- 82
if (config.targetFPS ~= nil) then -- 87
	App.targetFPS = config.targetFPS -- 88
else -- 90
	config.targetFPS = App.targetFPS -- 90
end -- 87
if (config.vsync ~= nil) then -- 92
	View.vsync = config.vsync -- 93
else -- 95
	config.vsync = View.vsync -- 95
end -- 92
if (config.fixedFPS ~= nil) then -- 97
	Director.scheduler.fixedFPS = config.fixedFPS -- 98
else -- 100
	config.fixedFPS = Director.scheduler.fixedFPS -- 100
end -- 97
local showEntry = true -- 102
local isDesktop = false -- 104
if (function() -- 105
	local _val_0 = App.platform -- 105
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 105
end)() then -- 105
	isDesktop = true -- 106
	if config.fullScreen then -- 107
		App.fullScreen = true -- 108
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 109
		local size = Size(config.winWidth, config.winHeight) -- 110
		if App.winSize ~= size then -- 111
			App.winSize = size -- 112
			showEntry = false -- 113
			thread(function() -- 114
				sleep() -- 115
				sleep() -- 116
				showEntry = true -- 117
			end) -- 114
		end -- 111
		local winX, winY -- 118
		do -- 118
			local _obj_0 = App.winPosition -- 118
			winX, winY = _obj_0.x, _obj_0.y -- 118
		end -- 118
		if (config.winX ~= nil) then -- 119
			winX = config.winX -- 120
		else -- 122
			config.winX = -1 -- 122
		end -- 119
		if (config.winY ~= nil) then -- 123
			winY = config.winY -- 124
		else -- 126
			config.winY = -1 -- 126
		end -- 123
		App.winPosition = Vec2(winX, winY) -- 127
	end -- 107
	if (config.alwaysOnTop ~= nil) then -- 128
		App.alwaysOnTop = config.alwaysOnTop -- 129
	else -- 131
		config.alwaysOnTop = true -- 131
	end -- 128
end -- 105
if (config.themeColor ~= nil) then -- 133
	App.themeColor = Color(config.themeColor) -- 134
else -- 136
	config.themeColor = App.themeColor:toARGB() -- 136
end -- 133
if not (config.locale ~= nil) then -- 138
	config.locale = App.locale -- 139
end -- 138
local showStats = false -- 141
if (config.showStats ~= nil) then -- 142
	showStats = config.showStats -- 143
else -- 145
	config.showStats = showStats -- 145
end -- 142
local showConsole = false -- 147
if (config.showConsole ~= nil) then -- 148
	showConsole = config.showConsole -- 149
else -- 151
	config.showConsole = showConsole -- 151
end -- 148
local showFooter = true -- 153
if (config.showFooter ~= nil) then -- 154
	showFooter = config.showFooter -- 155
else -- 157
	config.showFooter = showFooter -- 157
end -- 154
local filterBuf = Buffer(20) -- 159
if (config.filter ~= nil) then -- 160
	filterBuf.text = config.filter -- 161
else -- 163
	config.filter = "" -- 163
end -- 160
local engineDev = false -- 165
if (config.engineDev ~= nil) then -- 166
	engineDev = config.engineDev -- 167
else -- 169
	config.engineDev = engineDev -- 169
end -- 166
if (config.webProfiler ~= nil) then -- 171
	Director.profilerSending = config.webProfiler -- 172
else -- 174
	config.webProfiler = true -- 174
	Director.profilerSending = true -- 175
end -- 171
if not (config.drawerWidth ~= nil) then -- 177
	config.drawerWidth = 200 -- 178
end -- 177
_module_0.getConfig = function() -- 180
	return config -- 180
end -- 180
_module_0.getEngineDev = function() -- 181
	if not App.debugging then -- 182
		return false -- 182
	end -- 182
	return config.engineDev -- 183
end -- 181
local _anon_func_0 = function(App) -- 188
	local _val_0 = App.platform -- 188
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 188
end -- 188
_module_0.connectWebIDE = function() -- 185
	if not config.webIDEConnected then -- 186
		config.webIDEConnected = true -- 187
		if _anon_func_0(App) then -- 188
			local ratio = App.winSize.width / App.visualSize.width -- 189
			App.winSize = Size(640 * ratio, 480 * ratio) -- 190
		end -- 188
	end -- 186
end -- 185
local updateCheck -- 192
updateCheck = function() -- 192
	return thread(function() -- 192
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 193
		if res then -- 193
			local data = json.load(res) -- 194
			if data then -- 194
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 195
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 196
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 197
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 198
				if na < a then -- 199
					goto not_new_version -- 200
				end -- 199
				if na == a then -- 201
					if nb < b then -- 202
						goto not_new_version -- 203
					end -- 202
					if nb == b then -- 204
						if nc < c then -- 205
							goto not_new_version -- 206
						end -- 205
						if nc == c then -- 207
							goto not_new_version -- 208
						end -- 207
					end -- 204
				end -- 201
				config.updateNotification = true -- 209
				::not_new_version:: -- 210
				config.lastUpdateCheck = os.time() -- 211
			end -- 194
		end -- 193
	end) -- 211
end -- 192
if (config.lastUpdateCheck ~= nil) then -- 213
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 214
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 215
		updateCheck() -- 216
	end -- 215
else -- 218
	updateCheck() -- 218
end -- 213
local Set, Struct, LintYueGlobals, GSplit -- 220
do -- 220
	local _obj_0 = require("Utils") -- 220
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 220
end -- 220
local yueext = yue.options.extension -- 221
local isChineseSupported = IsFontLoaded() -- 223
if not isChineseSupported then -- 224
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 225
		isChineseSupported = true -- 226
	end) -- 225
end -- 224
local building = false -- 228
local getAllFiles -- 230
getAllFiles = function(path, exts, recursive) -- 230
	if recursive == nil then -- 230
		recursive = true -- 230
	end -- 230
	local filters = Set(exts) -- 231
	local files -- 232
	if recursive then -- 232
		files = Content:getAllFiles(path) -- 233
	else -- 235
		files = Content:getFiles(path) -- 235
	end -- 232
	local _accum_0 = { } -- 236
	local _len_0 = 1 -- 236
	for _index_0 = 1, #files do -- 236
		local file = files[_index_0] -- 236
		if not filters[Path:getExt(file)] then -- 237
			goto _continue_0 -- 237
		end -- 237
		_accum_0[_len_0] = file -- 238
		_len_0 = _len_0 + 1 -- 238
		::_continue_0:: -- 237
	end -- 238
	return _accum_0 -- 238
end -- 230
_module_0["getAllFiles"] = getAllFiles -- 238
local getFileEntries -- 240
getFileEntries = function(path, recursive, excludeFiles) -- 240
	if recursive == nil then -- 240
		recursive = true -- 240
	end -- 240
	if excludeFiles == nil then -- 240
		excludeFiles = nil -- 240
	end -- 240
	local entries = { } -- 241
	local excludes -- 242
	if excludeFiles then -- 242
		excludes = Set(excludeFiles) -- 243
	end -- 242
	local _list_0 = getAllFiles(path, { -- 244
		"lua", -- 244
		"xml", -- 244
		yueext, -- 244
		"tl" -- 244
	}, recursive) -- 244
	for _index_0 = 1, #_list_0 do -- 244
		local file = _list_0[_index_0] -- 244
		local entryName = Path:getName(file) -- 245
		if excludes and excludes[entryName] then -- 246
			goto _continue_0 -- 247
		end -- 246
		local entryAdded = false -- 248
		for _index_1 = 1, #entries do -- 249
			local _des_0 = entries[_index_1] -- 249
			local ename = _des_0[1] -- 249
			if entryName == ename then -- 250
				entryAdded = true -- 251
				break -- 252
			end -- 250
		end -- 252
		if entryAdded then -- 253
			goto _continue_0 -- 253
		end -- 253
		local fileName = Path:replaceExt(file, "") -- 254
		fileName = Path(path, fileName) -- 255
		local entry = { -- 256
			entryName, -- 256
			fileName -- 256
		} -- 256
		entries[#entries + 1] = entry -- 257
		::_continue_0:: -- 245
	end -- 257
	table.sort(entries, function(a, b) -- 258
		return a[1] < b[1] -- 258
	end) -- 258
	return entries -- 259
end -- 240
local getProjectEntries -- 261
getProjectEntries = function(path) -- 261
	local entries = { } -- 262
	local _list_0 = Content:getDirs(path) -- 263
	for _index_0 = 1, #_list_0 do -- 263
		local dir = _list_0[_index_0] -- 263
		if dir:match("^%.") then -- 264
			goto _continue_0 -- 264
		end -- 264
		local _list_1 = getAllFiles(Path(path, dir), { -- 265
			"lua", -- 265
			"xml", -- 265
			yueext, -- 265
			"tl", -- 265
			"wasm" -- 265
		}) -- 265
		for _index_1 = 1, #_list_1 do -- 265
			local file = _list_1[_index_1] -- 265
			if "init" == Path:getName(file):lower() then -- 266
				local fileName = Path:replaceExt(file, "") -- 267
				fileName = Path(path, dir, fileName) -- 268
				local entryName = Path:getName(Path:getPath(fileName)) -- 269
				local entryAdded = false -- 270
				for _index_2 = 1, #entries do -- 271
					local _des_0 = entries[_index_2] -- 271
					local ename = _des_0[1] -- 271
					if entryName == ename then -- 272
						entryAdded = true -- 273
						break -- 274
					end -- 272
				end -- 274
				if entryAdded then -- 275
					goto _continue_1 -- 275
				end -- 275
				local examples = { } -- 276
				local tests = { } -- 277
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 278
				if Content:exist(examplePath) then -- 279
					local _list_2 = getFileEntries(examplePath) -- 280
					for _index_2 = 1, #_list_2 do -- 280
						local _des_0 = _list_2[_index_2] -- 280
						local name, ePath = _des_0[1], _des_0[2] -- 280
						local entry = { -- 281
							name, -- 281
							Path(path, dir, Path:getPath(file), ePath) -- 281
						} -- 281
						examples[#examples + 1] = entry -- 282
					end -- 282
				end -- 279
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 283
				if Content:exist(testPath) then -- 284
					local _list_2 = getFileEntries(testPath) -- 285
					for _index_2 = 1, #_list_2 do -- 285
						local _des_0 = _list_2[_index_2] -- 285
						local name, tPath = _des_0[1], _des_0[2] -- 285
						local entry = { -- 286
							name, -- 286
							Path(path, dir, Path:getPath(file), tPath) -- 286
						} -- 286
						tests[#tests + 1] = entry -- 287
					end -- 287
				end -- 284
				local entry = { -- 288
					entryName, -- 288
					fileName, -- 288
					examples, -- 288
					tests -- 288
				} -- 288
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 289
				if not Content:exist(bannerFile) then -- 290
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 291
					if not Content:exist(bannerFile) then -- 292
						bannerFile = nil -- 292
					end -- 292
				end -- 290
				if bannerFile then -- 293
					thread(function() -- 293
						if Cache:loadAsync(bannerFile) then -- 294
							local bannerTex = Texture2D(bannerFile) -- 295
							if bannerTex then -- 296
								entry[#entry + 1] = bannerFile -- 297
								entry[#entry + 1] = bannerTex -- 298
							end -- 296
						end -- 294
					end) -- 293
				end -- 293
				entries[#entries + 1] = entry -- 299
			end -- 266
			::_continue_1:: -- 266
		end -- 299
		::_continue_0:: -- 264
	end -- 299
	table.sort(entries, function(a, b) -- 300
		return a[1] < b[1] -- 300
	end) -- 300
	return entries -- 301
end -- 261
local gamesInDev, games -- 303
local doraTools, doraExamples, doraTests -- 304
local cppTests, cppTestSet -- 305
local allEntries -- 306
local _anon_func_1 = function(App) -- 314
	if not App.debugging then -- 314
		return { -- 314
			"ImGui" -- 314
		} -- 314
	end -- 314
end -- 314
local updateEntries -- 308
updateEntries = function() -- 308
	gamesInDev = getProjectEntries(Content.writablePath) -- 309
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 310
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 312
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 313
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test"), true, _anon_func_1(App)) -- 314
	cppTests = { } -- 316
	local _list_0 = App.testNames -- 317
	for _index_0 = 1, #_list_0 do -- 317
		local name = _list_0[_index_0] -- 317
		local entry = { -- 318
			name -- 318
		} -- 318
		cppTests[#cppTests + 1] = entry -- 319
	end -- 319
	cppTestSet = Set(cppTests) -- 320
	allEntries = { } -- 322
	for _index_0 = 1, #gamesInDev do -- 323
		local game = gamesInDev[_index_0] -- 323
		allEntries[#allEntries + 1] = game -- 324
		local examples, tests = game[3], game[4] -- 325
		for _index_1 = 1, #examples do -- 326
			local example = examples[_index_1] -- 326
			allEntries[#allEntries + 1] = example -- 327
		end -- 327
		for _index_1 = 1, #tests do -- 328
			local test = tests[_index_1] -- 328
			allEntries[#allEntries + 1] = test -- 329
		end -- 329
	end -- 329
	for _index_0 = 1, #games do -- 330
		local game = games[_index_0] -- 330
		allEntries[#allEntries + 1] = game -- 331
		local examples, tests = game[3], game[4] -- 332
		for _index_1 = 1, #examples do -- 333
			local example = examples[_index_1] -- 333
			doraExamples[#doraExamples + 1] = example -- 334
		end -- 334
		for _index_1 = 1, #tests do -- 335
			local test = tests[_index_1] -- 335
			doraTests[#doraTests + 1] = test -- 336
		end -- 336
	end -- 336
	local _list_1 = { -- 338
		doraExamples, -- 338
		doraTests, -- 339
		cppTests -- 340
	} -- 337
	for _index_0 = 1, #_list_1 do -- 341
		local group = _list_1[_index_0] -- 337
		for _index_1 = 1, #group do -- 342
			local entry = group[_index_1] -- 342
			allEntries[#allEntries + 1] = entry -- 343
		end -- 343
	end -- 343
end -- 308
updateEntries() -- 345
local doCompile -- 347
doCompile = function(minify) -- 347
	if building then -- 348
		return -- 348
	end -- 348
	building = true -- 349
	local startTime = App.runningTime -- 350
	local luaFiles = { } -- 351
	local yueFiles = { } -- 352
	local xmlFiles = { } -- 353
	local tlFiles = { } -- 354
	local writablePath = Content.writablePath -- 355
	local buildPaths = { -- 357
		{ -- 358
			Path(Content.assetPath), -- 358
			Path(writablePath, ".build"), -- 359
			"" -- 360
		} -- 357
	} -- 356
	for _index_0 = 1, #gamesInDev do -- 363
		local _des_0 = gamesInDev[_index_0] -- 363
		local entryFile = _des_0[2] -- 363
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 364
		buildPaths[#buildPaths + 1] = { -- 366
			Path(writablePath, gamePath), -- 366
			Path(writablePath, ".build", gamePath), -- 367
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 368
			gamePath -- 369
		} -- 365
	end -- 369
	for _index_0 = 1, #buildPaths do -- 370
		local _des_0 = buildPaths[_index_0] -- 370
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 370
		if not Content:exist(inputPath) then -- 371
			goto _continue_0 -- 371
		end -- 371
		local _list_0 = getAllFiles(inputPath, { -- 373
			"lua" -- 373
		}) -- 373
		for _index_1 = 1, #_list_0 do -- 373
			local file = _list_0[_index_1] -- 373
			luaFiles[#luaFiles + 1] = { -- 375
				file, -- 375
				Path(inputPath, file), -- 376
				Path(outputPath, file), -- 377
				gamePath -- 378
			} -- 374
		end -- 378
		local _list_1 = getAllFiles(inputPath, { -- 380
			yueext -- 380
		}) -- 380
		for _index_1 = 1, #_list_1 do -- 380
			local file = _list_1[_index_1] -- 380
			yueFiles[#yueFiles + 1] = { -- 382
				file, -- 382
				Path(inputPath, file), -- 383
				Path(outputPath, Path:replaceExt(file, "lua")), -- 384
				searchPath, -- 385
				gamePath -- 386
			} -- 381
		end -- 386
		local _list_2 = getAllFiles(inputPath, { -- 388
			"xml" -- 388
		}) -- 388
		for _index_1 = 1, #_list_2 do -- 388
			local file = _list_2[_index_1] -- 388
			xmlFiles[#xmlFiles + 1] = { -- 390
				file, -- 390
				Path(inputPath, file), -- 391
				Path(outputPath, Path:replaceExt(file, "lua")), -- 392
				gamePath -- 393
			} -- 389
		end -- 393
		local _list_3 = getAllFiles(inputPath, { -- 395
			"tl" -- 395
		}) -- 395
		for _index_1 = 1, #_list_3 do -- 395
			local file = _list_3[_index_1] -- 395
			if not file:match(".*%.d%.tl$") then -- 396
				tlFiles[#tlFiles + 1] = { -- 398
					file, -- 398
					Path(inputPath, file), -- 399
					Path(outputPath, Path:replaceExt(file, "lua")), -- 400
					searchPath, -- 401
					gamePath -- 402
				} -- 397
			end -- 396
		end -- 402
		::_continue_0:: -- 371
	end -- 402
	local paths -- 404
	do -- 404
		local _tbl_0 = { } -- 404
		local _list_0 = { -- 405
			luaFiles, -- 405
			yueFiles, -- 405
			xmlFiles, -- 405
			tlFiles -- 405
		} -- 405
		for _index_0 = 1, #_list_0 do -- 405
			local files = _list_0[_index_0] -- 405
			for _index_1 = 1, #files do -- 406
				local file = files[_index_1] -- 406
				_tbl_0[Path:getPath(file[3])] = true -- 404
			end -- 404
		end -- 404
		paths = _tbl_0 -- 404
	end -- 406
	for path in pairs(paths) do -- 408
		Content:mkdir(path) -- 408
	end -- 408
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 410
	local fileCount = 0 -- 411
	local errors = { } -- 412
	for _index_0 = 1, #yueFiles do -- 413
		local _des_0 = yueFiles[_index_0] -- 413
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 413
		local filename -- 414
		if gamePath then -- 414
			filename = Path(gamePath, file) -- 414
		else -- 414
			filename = file -- 414
		end -- 414
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 415
			if not codes then -- 416
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 417
				return -- 418
			end -- 416
			local success, result = LintYueGlobals(codes, globals) -- 419
			if success then -- 420
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 421
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 422
				codes = codes:gsub("^\n*", "") -- 423
				if not (result == "") then -- 424
					result = result .. "\n" -- 424
				end -- 424
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 425
			else -- 427
				local yueCodes = Content:load(input) -- 427
				if yueCodes then -- 427
					local globalErrors = { } -- 428
					for _index_1 = 1, #result do -- 429
						local _des_1 = result[_index_1] -- 429
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 429
						local countLine = 1 -- 430
						local code = "" -- 431
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 432
							if countLine == line then -- 433
								code = lineCode -- 434
								break -- 435
							end -- 433
							countLine = countLine + 1 -- 436
						end -- 436
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 437
					end -- 437
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 438
				else -- 440
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 440
				end -- 427
			end -- 420
		end, function(success) -- 415
			if success then -- 441
				print("Yue compiled: " .. tostring(filename)) -- 441
			end -- 441
			fileCount = fileCount + 1 -- 442
		end) -- 415
	end -- 442
	thread(function() -- 444
		for _index_0 = 1, #xmlFiles do -- 445
			local _des_0 = xmlFiles[_index_0] -- 445
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 445
			local filename -- 446
			if gamePath then -- 446
				filename = Path(gamePath, file) -- 446
			else -- 446
				filename = file -- 446
			end -- 446
			local sourceCodes = Content:loadAsync(input) -- 447
			local codes, err = xml.tolua(sourceCodes) -- 448
			if not codes then -- 449
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 450
			else -- 452
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 452
				print("Xml compiled: " .. tostring(filename)) -- 453
			end -- 449
			fileCount = fileCount + 1 -- 454
		end -- 454
	end) -- 444
	thread(function() -- 456
		for _index_0 = 1, #tlFiles do -- 457
			local _des_0 = tlFiles[_index_0] -- 457
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 457
			local filename -- 458
			if gamePath then -- 458
				filename = Path(gamePath, file) -- 458
			else -- 458
				filename = file -- 458
			end -- 458
			local sourceCodes = Content:loadAsync(input) -- 459
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 460
			if not codes then -- 461
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 462
			else -- 464
				Content:saveAsync(output, codes) -- 464
				print("Teal compiled: " .. tostring(filename)) -- 465
			end -- 461
			fileCount = fileCount + 1 -- 466
		end -- 466
	end) -- 456
	return thread(function() -- 468
		wait(function() -- 469
			return fileCount == totalFiles -- 469
		end) -- 469
		if minify then -- 470
			local _list_0 = { -- 471
				yueFiles, -- 471
				xmlFiles, -- 471
				tlFiles -- 471
			} -- 471
			for _index_0 = 1, #_list_0 do -- 471
				local files = _list_0[_index_0] -- 471
				for _index_1 = 1, #files do -- 471
					local file = files[_index_1] -- 471
					local output = Path:replaceExt(file[3], "lua") -- 472
					luaFiles[#luaFiles + 1] = { -- 474
						Path:replaceExt(file[1], "lua"), -- 474
						output, -- 475
						output -- 476
					} -- 473
				end -- 476
			end -- 476
			local FormatMini -- 478
			do -- 478
				local _obj_0 = require("luaminify") -- 478
				FormatMini = _obj_0.FormatMini -- 478
			end -- 478
			for _index_0 = 1, #luaFiles do -- 479
				local _des_0 = luaFiles[_index_0] -- 479
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 479
				if Content:exist(input) then -- 480
					local sourceCodes = Content:loadAsync(input) -- 481
					local res, err = FormatMini(sourceCodes) -- 482
					if res then -- 483
						Content:saveAsync(output, res) -- 484
						print("Minify: " .. tostring(file)) -- 485
					else -- 487
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 487
					end -- 483
				else -- 489
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 489
				end -- 480
			end -- 489
			package.loaded["luaminify.FormatMini"] = nil -- 490
			package.loaded["luaminify.ParseLua"] = nil -- 491
			package.loaded["luaminify.Scope"] = nil -- 492
			package.loaded["luaminify.Util"] = nil -- 493
		end -- 470
		local errorMessage = table.concat(errors, "\n") -- 494
		if errorMessage ~= "" then -- 495
			print("\n" .. errorMessage) -- 495
		end -- 495
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 496
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 497
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 498
		Content:clearPathCache() -- 499
		teal.clear() -- 500
		yue.clear() -- 501
		building = false -- 502
	end) -- 502
end -- 347
local doClean -- 504
doClean = function() -- 504
	if building then -- 505
		return -- 505
	end -- 505
	local writablePath = Content.writablePath -- 506
	local targetDir = Path(writablePath, ".build") -- 507
	Content:clearPathCache() -- 508
	if Content:remove(targetDir) then -- 509
		return print("Cleaned: " .. tostring(targetDir)) -- 510
	end -- 509
end -- 504
local screenScale = 2.0 -- 512
local scaleContent = false -- 513
local isInEntry = true -- 514
local currentEntry = nil -- 515
local footerWindow = nil -- 517
local entryWindow = nil -- 518
local testingThread = nil -- 519
local setupEventHandlers = nil -- 521
local allClear -- 523
allClear = function() -- 523
	local _list_0 = Routine -- 524
	for _index_0 = 1, #_list_0 do -- 524
		local routine = _list_0[_index_0] -- 524
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 526
			goto _continue_0 -- 527
		else -- 529
			Routine:remove(routine) -- 529
		end -- 529
		::_continue_0:: -- 525
	end -- 529
	for _index_0 = 1, #moduleCache do -- 530
		local module = moduleCache[_index_0] -- 530
		package.loaded[module] = nil -- 531
	end -- 531
	moduleCache = { } -- 532
	Director:cleanup() -- 533
	Cache:unload() -- 534
	Entity:clear() -- 535
	Platformer.Data:clear() -- 536
	Platformer.UnitAction:clear() -- 537
	Audio:stopStream(0.5) -- 538
	Struct:clear() -- 539
	View.postEffect = nil -- 540
	View.scale = scaleContent and screenScale or 1 -- 541
	Director.clearColor = Color(0xff1a1a1a) -- 542
	teal.clear() -- 543
	yue.clear() -- 544
	for _, item in pairs(ubox()) do -- 545
		local node = tolua.cast(item, "Node") -- 546
		if node then -- 546
			node:cleanup() -- 546
		end -- 546
	end -- 546
	collectgarbage() -- 547
	collectgarbage() -- 548
	setupEventHandlers() -- 549
	Content.searchPaths = searchPaths -- 550
	App.idled = true -- 551
	return Wasm:clear() -- 552
end -- 523
_module_0["allClear"] = allClear -- 552
local clearTempFiles -- 554
clearTempFiles = function() -- 554
	local writablePath = Content.writablePath -- 555
	Content:remove(Path(writablePath, ".upload")) -- 556
	return Content:remove(Path(writablePath, ".download")) -- 557
end -- 554
local waitForWebStart = true -- 559
thread(function() -- 560
	sleep(2) -- 561
	waitForWebStart = false -- 562
end) -- 560
local reloadDevEntry -- 564
reloadDevEntry = function() -- 564
	return thread(function() -- 564
		waitForWebStart = true -- 565
		doClean() -- 566
		allClear() -- 567
		_G.require = oldRequire -- 568
		Dora.require = oldRequire -- 569
		package.loaded["Script.Dev.Entry"] = nil -- 570
		return Director.systemScheduler:schedule(function() -- 571
			Routine:clear() -- 572
			oldRequire("Script.Dev.Entry") -- 573
			return true -- 574
		end) -- 574
	end) -- 574
end -- 564
local setWorkspace -- 576
setWorkspace = function(path) -- 576
	Content.writablePath = path -- 577
	config.writablePath = Content.writablePath -- 578
	return thread(function() -- 579
		sleep() -- 580
		return reloadDevEntry() -- 581
	end) -- 581
end -- 576
local _anon_func_2 = function(App, _with_0) -- 596
	local _val_0 = App.platform -- 596
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 596
end -- 596
setupEventHandlers = function() -- 583
	local _with_0 = Director.postNode -- 584
	_with_0:onAppEvent(function(eventType) -- 585
		if eventType == "Quit" then -- 585
			allClear() -- 586
			return clearTempFiles() -- 587
		end -- 585
	end) -- 585
	_with_0:onAppChange(function(settingName) -- 588
		if "Theme" == settingName then -- 589
			config.themeColor = App.themeColor:toARGB() -- 590
		elseif "Locale" == settingName then -- 591
			config.locale = App.locale -- 592
			updateLocale() -- 593
			return teal.clear(true) -- 594
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 595
			if _anon_func_2(App, _with_0) then -- 596
				if "FullScreen" == settingName then -- 598
					config.fullScreen = App.fullScreen -- 598
				elseif "Position" == settingName then -- 599
					local _obj_0 = App.winPosition -- 599
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 599
				elseif "Size" == settingName then -- 600
					local width, height -- 601
					do -- 601
						local _obj_0 = App.winSize -- 601
						width, height = _obj_0.width, _obj_0.height -- 601
					end -- 601
					config.winWidth = width -- 602
					config.winHeight = height -- 603
				end -- 603
			end -- 596
		end -- 603
	end) -- 588
	_with_0:onAppWS(function(eventType) -- 604
		if eventType == "Close" then -- 604
			if HttpServer.wsConnectionCount == 0 then -- 605
				return updateEntries() -- 606
			end -- 605
		end -- 604
	end) -- 604
	return _with_0 -- 584
end -- 583
setupEventHandlers() -- 608
clearTempFiles() -- 609
local stop -- 611
stop = function() -- 611
	if isInEntry then -- 612
		return false -- 612
	end -- 612
	allClear() -- 613
	isInEntry = true -- 614
	currentEntry = nil -- 615
	return true -- 616
end -- 611
_module_0["stop"] = stop -- 616
local _anon_func_3 = function(Content, Path, file, require, type) -- 638
	local scriptPath = Path:getPath(file) -- 631
	Content:insertSearchPath(1, scriptPath) -- 632
	scriptPath = Path(scriptPath, "Script") -- 633
	if Content:exist(scriptPath) then -- 634
		Content:insertSearchPath(1, scriptPath) -- 635
	end -- 634
	local result = require(file) -- 636
	if "function" == type(result) then -- 637
		result() -- 637
	end -- 637
	return nil -- 638
end -- 631
local _anon_func_4 = function(Label, _with_0, err, fontSize, width) -- 670
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 667
	label.alignment = "Left" -- 668
	label.textWidth = width - fontSize -- 669
	label.text = err -- 670
	return label -- 667
end -- 667
local enterEntryAsync -- 618
enterEntryAsync = function(entry) -- 618
	isInEntry = false -- 619
	App.idled = false -- 620
	emit(Profiler.EventName, "ClearLoader") -- 621
	currentEntry = entry -- 622
	local name, file = entry[1], entry[2] -- 623
	if cppTestSet[entry] then -- 624
		if App:runTest(name) then -- 625
			return true -- 626
		else -- 628
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 628
		end -- 625
	end -- 624
	sleep() -- 629
	return xpcall(_anon_func_3, function(msg) -- 671
		local err = debug.traceback(msg) -- 640
		Log("Error", err) -- 641
		allClear() -- 642
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 643
		local viewWidth, viewHeight -- 644
		do -- 644
			local _obj_0 = View.size -- 644
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 644
		end -- 644
		local width, height = viewWidth - 20, viewHeight - 20 -- 645
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 646
		Director.ui:addChild((function() -- 647
			local root = AlignNode() -- 647
			do -- 648
				local _obj_0 = App.bufferSize -- 648
				width, height = _obj_0.width, _obj_0.height -- 648
			end -- 648
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 649
			root:onAppChange(function(settingName) -- 650
				if settingName == "Size" then -- 650
					do -- 651
						local _obj_0 = App.bufferSize -- 651
						width, height = _obj_0.width, _obj_0.height -- 651
					end -- 651
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 652
				end -- 650
			end) -- 650
			root:addChild((function() -- 653
				local _with_0 = ScrollArea({ -- 654
					width = width, -- 654
					height = height, -- 655
					paddingX = 0, -- 656
					paddingY = 50, -- 657
					viewWidth = height, -- 658
					viewHeight = height -- 659
				}) -- 653
				root:onAlignLayout(function(w, h) -- 661
					_with_0.position = Vec2(w / 2, h / 2) -- 662
					w = w - 20 -- 663
					h = h - 20 -- 664
					_with_0.view.children.first.textWidth = w - fontSize -- 665
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 666
				end) -- 661
				_with_0.view:addChild(_anon_func_4(Label, _with_0, err, fontSize, width)) -- 667
				return _with_0 -- 653
			end)()) -- 653
			return root -- 647
		end)()) -- 647
		return err -- 671
	end, Content, Path, file, require, type) -- 671
end -- 618
_module_0["enterEntryAsync"] = enterEntryAsync -- 671
local enterDemoEntry -- 673
enterDemoEntry = function(entry) -- 673
	return thread(function() -- 673
		return enterEntryAsync(entry) -- 673
	end) -- 673
end -- 673
local reloadCurrentEntry -- 675
reloadCurrentEntry = function() -- 675
	if currentEntry then -- 676
		allClear() -- 677
		return enterDemoEntry(currentEntry) -- 678
	end -- 676
end -- 675
Director.clearColor = Color(0xff1a1a1a) -- 680
local isOSSLicenseExist = Content:exist("LICENSES") -- 682
local ossLicenses = nil -- 683
local ossLicenseOpen = false -- 684
local _anon_func_5 = function(App) -- 688
	local _val_0 = App.platform -- 688
	return not ("Android" == _val_0 or "iOS" == _val_0) -- 688
end -- 688
local extraOperations -- 686
extraOperations = function() -- 686
	local zh = useChinese and isChineseSupported -- 687
	if _anon_func_5(App) then -- 688
		local themeColor = App.themeColor -- 689
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 690
		do -- 691
			local changed -- 691
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 691
			if changed then -- 691
				App.alwaysOnTop = alwaysOnTop -- 692
				config.alwaysOnTop = alwaysOnTop -- 693
			end -- 691
		end -- 691
		SeparatorText(zh and "工作目录" or "Workspace") -- 694
		PushTextWrapPos(400, function() -- 695
			return TextColored(themeColor, writablePath) -- 696
		end) -- 695
		if Button(zh and "改变目录" or "Set Folder") then -- 697
			App:openFileDialog(true, function(path) -- 698
				if path ~= "" then -- 699
					return setWorkspace(path) -- 699
				end -- 699
			end) -- 698
		end -- 697
		SameLine() -- 700
		if Button(zh and "使用默认" or "Use Default") then -- 701
			setWorkspace(Content.appPath) -- 702
		end -- 701
		Separator() -- 703
	end -- 688
	if isOSSLicenseExist then -- 704
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 705
			if not ossLicenses then -- 706
				ossLicenses = { } -- 707
				local licenseText = Content:load("LICENSES") -- 708
				ossLicenseOpen = (licenseText ~= nil) -- 709
				if ossLicenseOpen then -- 709
					licenseText = licenseText:gsub("\r\n", "\n") -- 710
					for license in GSplit(licenseText, "\n--------\n", true) do -- 711
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 712
						if name then -- 712
							ossLicenses[#ossLicenses + 1] = { -- 713
								name, -- 713
								text -- 713
							} -- 713
						end -- 712
					end -- 713
				end -- 709
			else -- 715
				ossLicenseOpen = true -- 715
			end -- 706
		end -- 705
		if ossLicenseOpen then -- 716
			local width, height, themeColor -- 717
			do -- 717
				local _obj_0 = App -- 717
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 717
			end -- 717
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 718
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 719
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 720
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 723
					"NoSavedSettings" -- 723
				}, function() -- 724
					for _index_0 = 1, #ossLicenses do -- 724
						local _des_0 = ossLicenses[_index_0] -- 724
						local firstLine, text = _des_0[1], _des_0[2] -- 724
						local name, license = firstLine:match("(.+): (.+)") -- 725
						TextColored(themeColor, name) -- 726
						SameLine() -- 727
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 728
							return TextWrapped(text) -- 728
						end) -- 728
					end -- 728
				end) -- 720
			end) -- 720
		end -- 716
	end -- 704
	if not App.debugging then -- 730
		return -- 730
	end -- 730
	return TreeNode(zh and "开发操作" or "Development", function() -- 731
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 732
			OpenPopup("build") -- 732
		end -- 732
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 733
			return BeginPopup("build", function() -- 733
				if Selectable(zh and "编译" or "Compile") then -- 734
					doCompile(false) -- 734
				end -- 734
				Separator() -- 735
				if Selectable(zh and "压缩" or "Minify") then -- 736
					doCompile(true) -- 736
				end -- 736
				Separator() -- 737
				if Selectable(zh and "清理" or "Clean") then -- 738
					return doClean() -- 738
				end -- 738
			end) -- 738
		end) -- 733
		if isInEntry then -- 739
			if waitForWebStart then -- 740
				BeginDisabled(function() -- 741
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 741
				end) -- 741
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 742
				reloadDevEntry() -- 743
			end -- 740
		end -- 739
		do -- 744
			local changed -- 744
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 744
			if changed then -- 744
				View.scale = scaleContent and screenScale or 1 -- 745
			end -- 744
		end -- 744
		do -- 746
			local changed -- 746
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 746
			if changed then -- 746
				config.engineDev = engineDev -- 747
			end -- 746
		end -- 746
		if Button(zh and "开始自动测试" or "Test automatically") then -- 748
			testingThread = thread(function() -- 749
				local _ <close> = setmetatable({ }, { -- 750
					__close = function() -- 750
						allClear() -- 751
						testingThread = nil -- 752
						isInEntry = true -- 753
						currentEntry = nil -- 754
						return print("Testing done!") -- 755
					end -- 750
				}) -- 750
				for _, entry in ipairs(allEntries) do -- 756
					allClear() -- 757
					print("Start " .. tostring(entry[1])) -- 758
					enterDemoEntry(entry) -- 759
					sleep(2) -- 760
					print("Stop " .. tostring(entry[1])) -- 761
				end -- 761
			end) -- 749
		end -- 748
	end) -- 731
end -- 686
local transparant = Color(0x0) -- 763
local windowFlags = { -- 764
	"NoTitleBar", -- 764
	"NoResize", -- 764
	"NoMove", -- 764
	"NoCollapse", -- 764
	"NoSavedSettings", -- 764
	"NoBringToFrontOnFocus" -- 764
} -- 764
local initFooter = true -- 772
local _anon_func_6 = function(allEntries, currentIndex) -- 808
	if currentIndex > 1 then -- 808
		return allEntries[currentIndex - 1] -- 809
	else -- 811
		return allEntries[#allEntries] -- 811
	end -- 808
end -- 808
local _anon_func_7 = function(allEntries, currentIndex) -- 815
	if currentIndex < #allEntries then -- 815
		return allEntries[currentIndex + 1] -- 816
	else -- 818
		return allEntries[1] -- 818
	end -- 815
end -- 815
footerWindow = threadLoop(function() -- 773
	local zh = useChinese and isChineseSupported -- 774
	if HttpServer.wsConnectionCount > 0 then -- 775
		return -- 776
	end -- 775
	if Keyboard:isKeyDown("Escape") then -- 777
		allClear() -- 778
		App:shutdown() -- 779
	end -- 777
	do -- 780
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 781
		if ctrl and Keyboard:isKeyDown("Q") then -- 782
			stop() -- 783
		end -- 782
		if ctrl and Keyboard:isKeyDown("Z") then -- 784
			reloadCurrentEntry() -- 785
		end -- 784
		if ctrl and Keyboard:isKeyDown(",") then -- 786
			if showFooter then -- 787
				showStats = not showStats -- 787
			else -- 787
				showStats = true -- 787
			end -- 787
			showFooter = true -- 788
			config.showFooter = showFooter -- 789
			config.showStats = showStats -- 790
		end -- 786
		if ctrl and Keyboard:isKeyDown(".") then -- 791
			if showFooter then -- 792
				showConsole = not showConsole -- 792
			else -- 792
				showConsole = true -- 792
			end -- 792
			showFooter = true -- 793
			config.showFooter = showFooter -- 794
			config.showConsole = showConsole -- 795
		end -- 791
		if ctrl and Keyboard:isKeyDown("/") then -- 796
			showFooter = not showFooter -- 797
			config.showFooter = showFooter -- 798
		end -- 796
		local left = ctrl and Keyboard:isKeyDown("Left") -- 799
		local right = ctrl and Keyboard:isKeyDown("Right") -- 800
		local currentIndex = nil -- 801
		for i, entry in ipairs(allEntries) do -- 802
			if currentEntry == entry then -- 803
				currentIndex = i -- 804
			end -- 803
		end -- 804
		if left then -- 805
			allClear() -- 806
			if currentIndex == nil then -- 807
				currentIndex = #allEntries + 1 -- 807
			end -- 807
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 808
		end -- 805
		if right then -- 812
			allClear() -- 813
			if currentIndex == nil then -- 814
				currentIndex = 0 -- 814
			end -- 814
			enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 815
		end -- 812
	end -- 818
	if not showEntry then -- 819
		return -- 819
	end -- 819
	local width, height -- 821
	do -- 821
		local _obj_0 = App.visualSize -- 821
		width, height = _obj_0.width, _obj_0.height -- 821
	end -- 821
	SetNextWindowSize(Vec2(50, 50)) -- 822
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 823
	PushStyleColor("WindowBg", transparant, function() -- 824
		return Begin("Show", windowFlags, function() -- 824
			if isInEntry or width >= 540 then -- 825
				local changed -- 826
				changed, showFooter = Checkbox("##dev", showFooter) -- 826
				if changed then -- 826
					config.showFooter = showFooter -- 827
				end -- 826
			end -- 825
		end) -- 827
	end) -- 824
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 829
		reloadDevEntry() -- 833
	end -- 829
	if initFooter then -- 834
		initFooter = false -- 835
	else -- 837
		if not showFooter then -- 837
			return -- 837
		end -- 837
	end -- 834
	SetNextWindowSize(Vec2(width, 50)) -- 839
	SetNextWindowPos(Vec2(0, height - 50)) -- 840
	SetNextWindowBgAlpha(0.35) -- 841
	do -- 842
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 843
			return Begin("Footer", windowFlags, function() -- 844
				Dummy(Vec2(width - 20, 0)) -- 845
				do -- 846
					local changed -- 846
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 846
					if changed then -- 846
						config.showStats = showStats -- 847
					end -- 846
				end -- 846
				SameLine() -- 848
				do -- 849
					local changed -- 849
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 849
					if changed then -- 849
						config.showConsole = showConsole -- 850
					end -- 849
				end -- 849
				if config.updateNotification then -- 851
					SameLine() -- 852
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 853
						config.updateNotification = false -- 854
						allClear() -- 855
						enterDemoEntry({ -- 856
							"SelfUpdater", -- 856
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 856
						}) -- 856
					end -- 853
				end -- 851
				if not isInEntry then -- 857
					SameLine() -- 858
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 859
					local currentIndex = nil -- 860
					for i, entry in ipairs(allEntries) do -- 861
						if currentEntry == entry then -- 862
							currentIndex = i -- 863
						end -- 862
					end -- 863
					if currentIndex then -- 864
						if currentIndex > 1 then -- 865
							SameLine() -- 866
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 867
								allClear() -- 868
								enterDemoEntry(allEntries[currentIndex - 1]) -- 869
							end -- 867
						end -- 865
						if currentIndex < #allEntries then -- 870
							SameLine() -- 871
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 872
								allClear() -- 873
								enterDemoEntry(allEntries[currentIndex + 1]) -- 874
							end -- 872
						end -- 870
					end -- 864
					SameLine() -- 875
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 876
						reloadCurrentEntry() -- 877
					end -- 876
					if back then -- 878
						allClear() -- 879
						isInEntry = true -- 880
						currentEntry = nil -- 881
					end -- 878
				end -- 857
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 882
					if showStats then -- 883
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 884
						showStats = ShowStats(showStats, extraOperations) -- 885
						config.showStats = showStats -- 886
					end -- 883
					if showConsole then -- 887
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 888
						showConsole = ShowConsole(showConsole) -- 889
						config.showConsole = showConsole -- 890
					end -- 887
				end) -- 882
			end) -- 844
		end) -- 843
	end -- 890
end) -- 773
local MaxWidth <const> = 800 -- 892
local displayWindowFlags = { -- 894
	"NoDecoration", -- 894
	"NoSavedSettings", -- 894
	"NoFocusOnAppearing", -- 894
	"NoNav", -- 894
	"NoMove", -- 894
	"NoScrollWithMouse", -- 894
	"AlwaysAutoResize", -- 894
	"NoBringToFrontOnFocus" -- 894
} -- 894
local webStatus = nil -- 905
local descColor = Color(0xffa1a1a1) -- 906
local gameOpen = #gamesInDev == 0 -- 907
local toolOpen = false -- 908
local exampleOpen = false -- 909
local testOpen = false -- 910
local filterText = nil -- 911
local anyEntryMatched = false -- 912
local urlClicked = nil -- 913
local match -- 914
match = function(name) -- 914
	local res = not filterText or name:lower():match(filterText) -- 915
	if res then -- 916
		anyEntryMatched = true -- 916
	end -- 916
	return res -- 917
end -- 914
local iconTex = nil -- 918
thread(function() -- 919
	if Cache:loadAsync("Image/icon_s.png") then -- 919
		iconTex = Texture2D("Image/icon_s.png") -- 920
	end -- 919
end) -- 919
entryWindow = threadLoop(function() -- 922
	if App.fpsLimited ~= config.fpsLimited then -- 923
		config.fpsLimited = App.fpsLimited -- 924
	end -- 923
	if App.targetFPS ~= config.targetFPS then -- 925
		config.targetFPS = App.targetFPS -- 926
	end -- 925
	if View.vsync ~= config.vsync then -- 927
		config.vsync = View.vsync -- 928
	end -- 927
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 929
		config.fixedFPS = Director.scheduler.fixedFPS -- 930
	end -- 929
	if Director.profilerSending ~= config.webProfiler then -- 931
		config.webProfiler = Director.profilerSending -- 932
	end -- 931
	if urlClicked then -- 933
		local _, result = coroutine.resume(urlClicked) -- 934
		if result then -- 935
			coroutine.close(urlClicked) -- 936
			urlClicked = nil -- 937
		end -- 935
	end -- 933
	if not showEntry then -- 938
		return -- 938
	end -- 938
	if not isInEntry then -- 939
		return -- 939
	end -- 939
	local zh = useChinese and isChineseSupported -- 940
	if HttpServer.wsConnectionCount > 0 then -- 941
		local themeColor = App.themeColor -- 942
		local width, height -- 943
		do -- 943
			local _obj_0 = App.visualSize -- 943
			width, height = _obj_0.width, _obj_0.height -- 943
		end -- 943
		SetNextWindowBgAlpha(0.5) -- 944
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 945
		Begin("Web IDE Connected", displayWindowFlags, function() -- 946
			Separator() -- 947
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 948
			if iconTex then -- 949
				Image("Image/icon_s.png", Vec2(24, 24)) -- 950
				SameLine() -- 951
			end -- 949
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 952
			TextColored(descColor, slogon) -- 953
			return Separator() -- 954
		end) -- 946
		return -- 955
	end -- 941
	local themeColor = App.themeColor -- 957
	local fullWidth, height -- 958
	do -- 958
		local _obj_0 = App.visualSize -- 958
		fullWidth, height = _obj_0.width, _obj_0.height -- 958
	end -- 958
	SetNextWindowBgAlpha(0.85) -- 960
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 961
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 962
		return Begin("Web IDE", displayWindowFlags, function() -- 963
			Separator() -- 964
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 965
			SameLine() -- 966
			TextDisabled('(?)') -- 967
			if IsItemHovered() then -- 968
				BeginTooltip(function() -- 969
					return PushTextWrapPos(280, function() -- 970
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 971
					end) -- 971
				end) -- 969
			end -- 968
			do -- 972
				local url -- 972
				if webStatus ~= nil then -- 972
					url = webStatus.url -- 972
				end -- 972
				if url then -- 972
					if isDesktop and not config.fullScreen then -- 973
						if urlClicked then -- 974
							BeginDisabled(function() -- 975
								return Button(url) -- 975
							end) -- 975
						elseif Button(url) then -- 976
							urlClicked = once(function() -- 977
								return sleep(5) -- 977
							end) -- 977
							App:openURL("http://localhost:8866") -- 978
						end -- 974
					else -- 980
						TextColored(descColor, url) -- 980
					end -- 973
				else -- 982
					TextColored(descColor, zh and '不可用' or 'not available') -- 982
				end -- 972
			end -- 972
			return Separator() -- 983
		end) -- 983
	end) -- 962
	local width = math.min(MaxWidth, fullWidth) -- 985
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 986
	local maxColumns = math.max(math.floor(width / 200), 1) -- 987
	SetNextWindowPos(Vec2.zero) -- 988
	SetNextWindowBgAlpha(0) -- 989
	do -- 990
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 991
			return Begin("Dora Dev", displayWindowFlags, function() -- 992
				Dummy(Vec2(fullWidth - 20, 0)) -- 993
				if iconTex then -- 994
					Image("Image/icon_s.png", Vec2(24, 24)) -- 995
					SameLine() -- 996
				end -- 994
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 997
				if fullWidth >= 320 then -- 998
					SameLine() -- 999
					Dummy(Vec2(fullWidth - 320, 0)) -- 1000
					SameLine() -- 1001
					SetNextItemWidth(-30) -- 1002
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1003
						"AutoSelectAll" -- 1003
					}) then -- 1003
						config.filter = filterBuf.text -- 1004
					end -- 1003
				end -- 998
				Separator() -- 1005
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1006
			end) -- 992
		end) -- 991
	end -- 1006
	anyEntryMatched = false -- 1008
	SetNextWindowPos(Vec2(0, 50)) -- 1009
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1010
	do -- 1011
		return PushStyleColor("WindowBg", transparant, function() -- 1012
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1013
				return Begin("Content", windowFlags, function() -- 1014
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 1015
					if filterText then -- 1016
						filterText = filterText:lower() -- 1016
					end -- 1016
					if #gamesInDev > 0 then -- 1017
						for _index_0 = 1, #gamesInDev do -- 1018
							local game = gamesInDev[_index_0] -- 1018
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1019
							local showSep = false -- 1020
							if match(gameName) then -- 1021
								Columns(1, false) -- 1022
								TextColored(themeColor, zh and "项目：" or "Project:") -- 1023
								SameLine() -- 1024
								Text(gameName) -- 1025
								Separator() -- 1026
								if bannerFile then -- 1027
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1028
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1029
									local sizing <const> = 0.8 -- 1030
									texHeight = displayWidth * sizing * texHeight / texWidth -- 1031
									texWidth = displayWidth * sizing -- 1032
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1033
									Dummy(Vec2(padding, 0)) -- 1034
									SameLine() -- 1035
									PushID(fileName, function() -- 1036
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1037
											return enterDemoEntry(game) -- 1038
										end -- 1037
									end) -- 1036
								else -- 1040
									PushID(fileName, function() -- 1040
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 1041
											return enterDemoEntry(game) -- 1042
										end -- 1041
									end) -- 1040
								end -- 1027
								NextColumn() -- 1043
								showSep = true -- 1044
							end -- 1021
							if #examples > 0 then -- 1045
								local showExample = false -- 1046
								for _index_1 = 1, #examples do -- 1047
									local example = examples[_index_1] -- 1047
									if match(example[1]) then -- 1048
										showExample = true -- 1049
										break -- 1050
									end -- 1048
								end -- 1050
								if showExample then -- 1051
									Columns(1, false) -- 1052
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1053
									SameLine() -- 1054
									Text(gameName) -- 1055
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1056
										Columns(maxColumns, false) -- 1057
										for _index_1 = 1, #examples do -- 1058
											local example = examples[_index_1] -- 1058
											if not match(example[1]) then -- 1059
												goto _continue_0 -- 1059
											end -- 1059
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1060
												if Button(example[1], Vec2(-1, 40)) then -- 1061
													enterDemoEntry(example) -- 1062
												end -- 1061
												return NextColumn() -- 1063
											end) -- 1060
											showSep = true -- 1064
											::_continue_0:: -- 1059
										end -- 1064
									end) -- 1056
								end -- 1051
							end -- 1045
							if #tests > 0 then -- 1065
								local showTest = false -- 1066
								for _index_1 = 1, #tests do -- 1067
									local test = tests[_index_1] -- 1067
									if match(test[1]) then -- 1068
										showTest = true -- 1069
										break -- 1070
									end -- 1068
								end -- 1070
								if showTest then -- 1071
									Columns(1, false) -- 1072
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1073
									SameLine() -- 1074
									Text(gameName) -- 1075
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1076
										Columns(maxColumns, false) -- 1077
										for _index_1 = 1, #tests do -- 1078
											local test = tests[_index_1] -- 1078
											if not match(test[1]) then -- 1079
												goto _continue_0 -- 1079
											end -- 1079
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1080
												if Button(test[1], Vec2(-1, 40)) then -- 1081
													enterDemoEntry(test) -- 1082
												end -- 1081
												return NextColumn() -- 1083
											end) -- 1080
											showSep = true -- 1084
											::_continue_0:: -- 1079
										end -- 1084
									end) -- 1076
								end -- 1071
							end -- 1065
							if showSep then -- 1085
								Columns(1, false) -- 1086
								Separator() -- 1087
							end -- 1085
						end -- 1087
					end -- 1017
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1088
						local showGame = false -- 1089
						for _index_0 = 1, #games do -- 1090
							local _des_0 = games[_index_0] -- 1090
							local name = _des_0[1] -- 1090
							if match(name) then -- 1091
								showGame = true -- 1091
							end -- 1091
						end -- 1091
						local showTool = false -- 1092
						for _index_0 = 1, #doraTools do -- 1093
							local _des_0 = doraTools[_index_0] -- 1093
							local name = _des_0[1] -- 1093
							if match(name) then -- 1094
								showTool = true -- 1094
							end -- 1094
						end -- 1094
						local showExample = false -- 1095
						for _index_0 = 1, #doraExamples do -- 1096
							local _des_0 = doraExamples[_index_0] -- 1096
							local name = _des_0[1] -- 1096
							if match(name) then -- 1097
								showExample = true -- 1097
							end -- 1097
						end -- 1097
						local showTest = false -- 1098
						for _index_0 = 1, #doraTests do -- 1099
							local _des_0 = doraTests[_index_0] -- 1099
							local name = _des_0[1] -- 1099
							if match(name) then -- 1100
								showTest = true -- 1100
							end -- 1100
						end -- 1100
						for _index_0 = 1, #cppTests do -- 1101
							local _des_0 = cppTests[_index_0] -- 1101
							local name = _des_0[1] -- 1101
							if match(name) then -- 1102
								showTest = true -- 1102
							end -- 1102
						end -- 1102
						if not (showGame or showTool or showExample or showTest) then -- 1103
							goto endEntry -- 1103
						end -- 1103
						Columns(1, false) -- 1104
						TextColored(themeColor, "Dora SSR:") -- 1105
						SameLine() -- 1106
						Text(zh and "开发示例" or "Development Showcase") -- 1107
						Separator() -- 1108
						local demoViewWith <const> = 400 -- 1109
						if #games > 0 and showGame then -- 1110
							local opened -- 1111
							if (filterText ~= nil) then -- 1111
								opened = showGame -- 1111
							else -- 1111
								opened = false -- 1111
							end -- 1111
							SetNextItemOpen(gameOpen) -- 1112
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1113
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1114
								Columns(columns, false) -- 1115
								for _index_0 = 1, #games do -- 1116
									local game = games[_index_0] -- 1116
									if not match(game[1]) then -- 1117
										goto _continue_0 -- 1117
									end -- 1117
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1118
									if columns > 1 then -- 1119
										if bannerFile then -- 1120
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1121
											local displayWidth <const> = demoViewWith - 40 -- 1122
											texHeight = displayWidth * texHeight / texWidth -- 1123
											texWidth = displayWidth -- 1124
											Text(gameName) -- 1125
											PushID(fileName, function() -- 1126
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1127
													return enterDemoEntry(game) -- 1128
												end -- 1127
											end) -- 1126
										else -- 1130
											PushID(fileName, function() -- 1130
												if Button(gameName, Vec2(-1, 40)) then -- 1131
													return enterDemoEntry(game) -- 1132
												end -- 1131
											end) -- 1130
										end -- 1120
									else -- 1134
										if bannerFile then -- 1134
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1135
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1136
											local sizing = 0.8 -- 1137
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1138
											texWidth = displayWidth * sizing -- 1139
											if texWidth > 500 then -- 1140
												sizing = 0.6 -- 1141
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1142
												texWidth = displayWidth * sizing -- 1143
											end -- 1140
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1144
											Dummy(Vec2(padding, 0)) -- 1145
											SameLine() -- 1146
											Text(gameName) -- 1147
											Dummy(Vec2(padding, 0)) -- 1148
											SameLine() -- 1149
											PushID(fileName, function() -- 1150
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1151
													return enterDemoEntry(game) -- 1152
												end -- 1151
											end) -- 1150
										else -- 1154
											PushID(fileName, function() -- 1154
												if Button(gameName, Vec2(-1, 40)) then -- 1155
													return enterDemoEntry(game) -- 1156
												end -- 1155
											end) -- 1154
										end -- 1134
									end -- 1119
									NextColumn() -- 1157
									::_continue_0:: -- 1117
								end -- 1157
								Columns(1, false) -- 1158
								opened = true -- 1159
							end) -- 1113
							gameOpen = opened -- 1160
						end -- 1110
						if #doraTools > 0 and showTool then -- 1161
							local opened -- 1162
							if (filterText ~= nil) then -- 1162
								opened = showTool -- 1162
							else -- 1162
								opened = false -- 1162
							end -- 1162
							SetNextItemOpen(toolOpen) -- 1163
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1164
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1165
									Columns(maxColumns, false) -- 1166
									for _index_0 = 1, #doraTools do -- 1167
										local example = doraTools[_index_0] -- 1167
										if not match(example[1]) then -- 1168
											goto _continue_0 -- 1168
										end -- 1168
										if Button(example[1], Vec2(-1, 40)) then -- 1169
											enterDemoEntry(example) -- 1170
										end -- 1169
										NextColumn() -- 1171
										::_continue_0:: -- 1168
									end -- 1171
									Columns(1, false) -- 1172
									opened = true -- 1173
								end) -- 1165
							end) -- 1164
							toolOpen = opened -- 1174
						end -- 1161
						if #doraExamples > 0 and showExample then -- 1175
							local opened -- 1176
							if (filterText ~= nil) then -- 1176
								opened = showExample -- 1176
							else -- 1176
								opened = false -- 1176
							end -- 1176
							SetNextItemOpen(exampleOpen) -- 1177
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1178
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1179
									Columns(maxColumns, false) -- 1180
									for _index_0 = 1, #doraExamples do -- 1181
										local example = doraExamples[_index_0] -- 1181
										if not match(example[1]) then -- 1182
											goto _continue_0 -- 1182
										end -- 1182
										if Button(example[1], Vec2(-1, 40)) then -- 1183
											enterDemoEntry(example) -- 1184
										end -- 1183
										NextColumn() -- 1185
										::_continue_0:: -- 1182
									end -- 1185
									Columns(1, false) -- 1186
									opened = true -- 1187
								end) -- 1179
							end) -- 1178
							exampleOpen = opened -- 1188
						end -- 1175
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1189
							local opened -- 1190
							if (filterText ~= nil) then -- 1190
								opened = showTest -- 1190
							else -- 1190
								opened = false -- 1190
							end -- 1190
							SetNextItemOpen(testOpen) -- 1191
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1192
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1193
									Columns(maxColumns, false) -- 1194
									for _index_0 = 1, #doraTests do -- 1195
										local test = doraTests[_index_0] -- 1195
										if not match(test[1]) then -- 1196
											goto _continue_0 -- 1196
										end -- 1196
										if Button(test[1], Vec2(-1, 40)) then -- 1197
											enterDemoEntry(test) -- 1198
										end -- 1197
										NextColumn() -- 1199
										::_continue_0:: -- 1196
									end -- 1199
									for _index_0 = 1, #cppTests do -- 1200
										local test = cppTests[_index_0] -- 1200
										if not match(test[1]) then -- 1201
											goto _continue_1 -- 1201
										end -- 1201
										if Button(test[1], Vec2(-1, 40)) then -- 1202
											enterDemoEntry(test) -- 1203
										end -- 1202
										NextColumn() -- 1204
										::_continue_1:: -- 1201
									end -- 1204
									opened = true -- 1205
								end) -- 1193
							end) -- 1192
							testOpen = opened -- 1206
						end -- 1189
					end -- 1088
					::endEntry:: -- 1207
					if not anyEntryMatched then -- 1208
						SetNextWindowBgAlpha(0) -- 1209
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1210
						Begin("Entries Not Found", displayWindowFlags, function() -- 1211
							Separator() -- 1212
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1213
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1214
							return Separator() -- 1215
						end) -- 1211
					end -- 1208
					Columns(1, false) -- 1216
					Dummy(Vec2(100, 80)) -- 1217
					return ScrollWhenDraggingOnVoid() -- 1218
				end) -- 1014
			end) -- 1013
		end) -- 1012
	end -- 1218
end) -- 922
webStatus = require("Script.Dev.WebServer") -- 1220
return _module_0 -- 1220
