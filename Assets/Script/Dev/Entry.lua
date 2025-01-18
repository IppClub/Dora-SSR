-- [yue]: Dev/Entry.yue
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath") -- 47
config:load() -- 73
if not config.writablePath then -- 75
	config.writablePath = Content.appPath -- 76
end -- 75
if (config.fpsLimited ~= nil) then -- 78
	App.fpsLimited = config.fpsLimited -- 79
else -- 81
	config.fpsLimited = App.fpsLimited -- 81
end -- 78
if (config.targetFPS ~= nil) then -- 83
	App.targetFPS = config.targetFPS -- 84
else -- 86
	config.targetFPS = App.targetFPS -- 86
end -- 83
if (config.vsync ~= nil) then -- 88
	View.vsync = config.vsync -- 89
else -- 91
	config.vsync = View.vsync -- 91
end -- 88
if (config.fixedFPS ~= nil) then -- 93
	Director.scheduler.fixedFPS = config.fixedFPS -- 94
else -- 96
	config.fixedFPS = Director.scheduler.fixedFPS -- 96
end -- 93
local showEntry = true -- 98
local isDesktop = false -- 100
if (function() -- 101
	local _val_0 = App.platform -- 101
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 101
end)() then -- 101
	isDesktop = true -- 102
	if config.fullScreen then -- 103
		App.fullScreen = true -- 104
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 105
		local size = Size(config.winWidth, config.winHeight) -- 106
		if App.winSize ~= size then -- 107
			App.winSize = size -- 108
			showEntry = false -- 109
			thread(function() -- 110
				sleep() -- 111
				sleep() -- 112
				showEntry = true -- 113
			end) -- 110
		end -- 107
		local winX, winY -- 114
		do -- 114
			local _obj_0 = App.winPosition -- 114
			winX, winY = _obj_0.x, _obj_0.y -- 114
		end -- 114
		if (config.winX ~= nil) then -- 115
			winX = config.winX -- 116
		else -- 118
			config.winX = -1 -- 118
		end -- 115
		if (config.winY ~= nil) then -- 119
			winY = config.winY -- 120
		else -- 122
			config.winY = -1 -- 122
		end -- 119
		App.winPosition = Vec2(winX, winY) -- 123
	end -- 103
	if (config.alwaysOnTop ~= nil) then -- 124
		App.alwaysOnTop = config.alwaysOnTop -- 125
	else -- 127
		config.alwaysOnTop = true -- 127
	end -- 124
end -- 101
if (config.themeColor ~= nil) then -- 129
	App.themeColor = Color(config.themeColor) -- 130
else -- 132
	config.themeColor = App.themeColor:toARGB() -- 132
end -- 129
if not (config.locale ~= nil) then -- 134
	config.locale = App.locale -- 135
end -- 134
local showStats = false -- 137
if (config.showStats ~= nil) then -- 138
	showStats = config.showStats -- 139
else -- 141
	config.showStats = showStats -- 141
end -- 138
local showConsole = false -- 143
if (config.showConsole ~= nil) then -- 144
	showConsole = config.showConsole -- 145
else -- 147
	config.showConsole = showConsole -- 147
end -- 144
local showFooter = true -- 149
if (config.showFooter ~= nil) then -- 150
	showFooter = config.showFooter -- 151
else -- 153
	config.showFooter = showFooter -- 153
end -- 150
local filterBuf = Buffer(20) -- 155
if (config.filter ~= nil) then -- 156
	filterBuf.text = config.filter -- 157
else -- 159
	config.filter = "" -- 159
end -- 156
local engineDev = false -- 161
if (config.engineDev ~= nil) then -- 162
	engineDev = config.engineDev -- 163
else -- 165
	config.engineDev = engineDev -- 165
end -- 162
if (config.webProfiler ~= nil) then -- 167
	Director.profilerSending = config.webProfiler -- 168
else -- 170
	config.webProfiler = true -- 170
	Director.profilerSending = true -- 171
end -- 167
if not (config.drawerWidth ~= nil) then -- 173
	config.drawerWidth = 200 -- 174
end -- 173
_module_0.getConfig = function() -- 176
	return config -- 176
end -- 176
_module_0.getEngineDev = function() -- 177
	if not App.debugging then -- 178
		return false -- 178
	end -- 178
	return config.engineDev -- 179
end -- 177
local updateCheck -- 181
updateCheck = function() -- 181
	return thread(function() -- 181
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 182
		if res then -- 182
			local data = json.load(res) -- 183
			if data then -- 183
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 184
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 185
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 186
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 187
				if na < a then -- 188
					goto not_new_version -- 189
				end -- 188
				if na == a then -- 190
					if nb < b then -- 191
						goto not_new_version -- 192
					end -- 191
					if nb == b then -- 193
						if nc < c then -- 194
							goto not_new_version -- 195
						end -- 194
						if nc == c then -- 196
							goto not_new_version -- 197
						end -- 196
					end -- 193
				end -- 190
				config.updateNotification = true -- 198
				::not_new_version:: -- 199
				config.lastUpdateCheck = os.time() -- 200
			end -- 183
		end -- 182
	end) -- 200
end -- 181
if (config.lastUpdateCheck ~= nil) then -- 202
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 203
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 204
		updateCheck() -- 205
	end -- 204
else -- 207
	updateCheck() -- 207
end -- 202
local Set, Struct, LintYueGlobals, GSplit -- 209
do -- 209
	local _obj_0 = require("Utils") -- 209
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 209
end -- 209
local yueext = yue.options.extension -- 210
local isChineseSupported = IsFontLoaded() -- 212
if not isChineseSupported then -- 213
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 214
		isChineseSupported = true -- 215
	end) -- 214
end -- 213
local building = false -- 217
local getAllFiles -- 219
getAllFiles = function(path, exts, recursive) -- 219
	if recursive == nil then -- 219
		recursive = true -- 219
	end -- 219
	local filters = Set(exts) -- 220
	local files -- 221
	if recursive then -- 221
		files = Content:getAllFiles(path) -- 222
	else -- 224
		files = Content:getFiles(path) -- 224
	end -- 221
	local _accum_0 = { } -- 225
	local _len_0 = 1 -- 225
	for _index_0 = 1, #files do -- 225
		local file = files[_index_0] -- 225
		if not filters[Path:getExt(file)] then -- 226
			goto _continue_0 -- 226
		end -- 226
		_accum_0[_len_0] = file -- 227
		_len_0 = _len_0 + 1 -- 227
		::_continue_0:: -- 226
	end -- 227
	return _accum_0 -- 227
end -- 219
_module_0["getAllFiles"] = getAllFiles -- 227
local getFileEntries -- 229
getFileEntries = function(path, recursive, excludeFiles) -- 229
	if recursive == nil then -- 229
		recursive = true -- 229
	end -- 229
	if excludeFiles == nil then -- 229
		excludeFiles = nil -- 229
	end -- 229
	local entries = { } -- 230
	local excludes -- 231
	if excludeFiles then -- 231
		excludes = Set(excludeFiles) -- 232
	end -- 231
	local _list_0 = getAllFiles(path, { -- 233
		"lua", -- 233
		"xml", -- 233
		yueext, -- 233
		"tl" -- 233
	}, recursive) -- 233
	for _index_0 = 1, #_list_0 do -- 233
		local file = _list_0[_index_0] -- 233
		local entryName = Path:getName(file) -- 234
		if excludes and excludes[entryName] then -- 235
			goto _continue_0 -- 236
		end -- 235
		local entryAdded = false -- 237
		for _index_1 = 1, #entries do -- 238
			local _des_0 = entries[_index_1] -- 238
			local ename = _des_0[1] -- 238
			if entryName == ename then -- 239
				entryAdded = true -- 240
				break -- 241
			end -- 239
		end -- 241
		if entryAdded then -- 242
			goto _continue_0 -- 242
		end -- 242
		local fileName = Path:replaceExt(file, "") -- 243
		fileName = Path(path, fileName) -- 244
		local entry = { -- 245
			entryName, -- 245
			fileName -- 245
		} -- 245
		entries[#entries + 1] = entry -- 246
		::_continue_0:: -- 234
	end -- 246
	table.sort(entries, function(a, b) -- 247
		return a[1] < b[1] -- 247
	end) -- 247
	return entries -- 248
end -- 229
local getProjectEntries -- 250
getProjectEntries = function(path) -- 250
	local entries = { } -- 251
	local _list_0 = Content:getDirs(path) -- 252
	for _index_0 = 1, #_list_0 do -- 252
		local dir = _list_0[_index_0] -- 252
		if dir:match("^%.") then -- 253
			goto _continue_0 -- 253
		end -- 253
		local _list_1 = getAllFiles(Path(path, dir), { -- 254
			"lua", -- 254
			"xml", -- 254
			yueext, -- 254
			"tl", -- 254
			"wasm" -- 254
		}) -- 254
		for _index_1 = 1, #_list_1 do -- 254
			local file = _list_1[_index_1] -- 254
			if "init" == Path:getName(file):lower() then -- 255
				local fileName = Path:replaceExt(file, "") -- 256
				fileName = Path(path, dir, fileName) -- 257
				local entryName = Path:getName(Path:getPath(fileName)) -- 258
				local entryAdded = false -- 259
				for _index_2 = 1, #entries do -- 260
					local _des_0 = entries[_index_2] -- 260
					local ename = _des_0[1] -- 260
					if entryName == ename then -- 261
						entryAdded = true -- 262
						break -- 263
					end -- 261
				end -- 263
				if entryAdded then -- 264
					goto _continue_1 -- 264
				end -- 264
				local examples = { } -- 265
				local tests = { } -- 266
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 267
				if Content:exist(examplePath) then -- 268
					local _list_2 = getFileEntries(examplePath) -- 269
					for _index_2 = 1, #_list_2 do -- 269
						local _des_0 = _list_2[_index_2] -- 269
						local name, ePath = _des_0[1], _des_0[2] -- 269
						local entry = { -- 270
							name, -- 270
							Path(path, dir, Path:getPath(file), ePath) -- 270
						} -- 270
						examples[#examples + 1] = entry -- 271
					end -- 271
				end -- 268
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 272
				if Content:exist(testPath) then -- 273
					local _list_2 = getFileEntries(testPath) -- 274
					for _index_2 = 1, #_list_2 do -- 274
						local _des_0 = _list_2[_index_2] -- 274
						local name, tPath = _des_0[1], _des_0[2] -- 274
						local entry = { -- 275
							name, -- 275
							Path(path, dir, Path:getPath(file), tPath) -- 275
						} -- 275
						tests[#tests + 1] = entry -- 276
					end -- 276
				end -- 273
				local entry = { -- 277
					entryName, -- 277
					fileName, -- 277
					examples, -- 277
					tests -- 277
				} -- 277
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 278
				if not Content:exist(bannerFile) then -- 279
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 280
					if not Content:exist(bannerFile) then -- 281
						bannerFile = nil -- 281
					end -- 281
				end -- 279
				if bannerFile then -- 282
					thread(function() -- 282
						if Cache:loadAsync(bannerFile) then -- 283
							local bannerTex = Texture2D(bannerFile) -- 284
							if bannerTex then -- 285
								entry[#entry + 1] = bannerFile -- 286
								entry[#entry + 1] = bannerTex -- 287
							end -- 285
						end -- 283
					end) -- 282
				end -- 282
				entries[#entries + 1] = entry -- 288
			end -- 255
			::_continue_1:: -- 255
		end -- 288
		::_continue_0:: -- 253
	end -- 288
	table.sort(entries, function(a, b) -- 289
		return a[1] < b[1] -- 289
	end) -- 289
	return entries -- 290
end -- 250
local gamesInDev, games -- 292
local doraTools, doraExamples, doraTests -- 293
local cppTests, cppTestSet -- 294
local allEntries -- 295
local _anon_func_0 = function(App) -- 303
	if not App.debugging then -- 303
		return { -- 303
			"ImGui" -- 303
		} -- 303
	end -- 303
end -- 303
local updateEntries -- 297
updateEntries = function() -- 297
	gamesInDev = getProjectEntries(Content.writablePath) -- 298
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 299
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 301
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 302
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test"), true, _anon_func_0(App)) -- 303
	cppTests = { } -- 305
	local _list_0 = App.testNames -- 306
	for _index_0 = 1, #_list_0 do -- 306
		local name = _list_0[_index_0] -- 306
		local entry = { -- 307
			name -- 307
		} -- 307
		cppTests[#cppTests + 1] = entry -- 308
	end -- 308
	cppTestSet = Set(cppTests) -- 309
	allEntries = { } -- 311
	for _index_0 = 1, #gamesInDev do -- 312
		local game = gamesInDev[_index_0] -- 312
		allEntries[#allEntries + 1] = game -- 313
		local examples, tests = game[3], game[4] -- 314
		for _index_1 = 1, #examples do -- 315
			local example = examples[_index_1] -- 315
			allEntries[#allEntries + 1] = example -- 316
		end -- 316
		for _index_1 = 1, #tests do -- 317
			local test = tests[_index_1] -- 317
			allEntries[#allEntries + 1] = test -- 318
		end -- 318
	end -- 318
	for _index_0 = 1, #games do -- 319
		local game = games[_index_0] -- 319
		allEntries[#allEntries + 1] = game -- 320
		local examples, tests = game[3], game[4] -- 321
		for _index_1 = 1, #examples do -- 322
			local example = examples[_index_1] -- 322
			doraExamples[#doraExamples + 1] = example -- 323
		end -- 323
		for _index_1 = 1, #tests do -- 324
			local test = tests[_index_1] -- 324
			doraTests[#doraTests + 1] = test -- 325
		end -- 325
	end -- 325
	local _list_1 = { -- 327
		doraExamples, -- 327
		doraTests, -- 328
		cppTests -- 329
	} -- 326
	for _index_0 = 1, #_list_1 do -- 330
		local group = _list_1[_index_0] -- 326
		for _index_1 = 1, #group do -- 331
			local entry = group[_index_1] -- 331
			allEntries[#allEntries + 1] = entry -- 332
		end -- 332
	end -- 332
end -- 297
updateEntries() -- 334
local doCompile -- 336
doCompile = function(minify) -- 336
	if building then -- 337
		return -- 337
	end -- 337
	building = true -- 338
	local startTime = App.runningTime -- 339
	local luaFiles = { } -- 340
	local yueFiles = { } -- 341
	local xmlFiles = { } -- 342
	local tlFiles = { } -- 343
	local writablePath = Content.writablePath -- 344
	local buildPaths = { -- 346
		{ -- 347
			Path(Content.assetPath), -- 347
			Path(writablePath, ".build"), -- 348
			"" -- 349
		} -- 346
	} -- 345
	for _index_0 = 1, #gamesInDev do -- 352
		local _des_0 = gamesInDev[_index_0] -- 352
		local entryFile = _des_0[2] -- 352
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 353
		buildPaths[#buildPaths + 1] = { -- 355
			Path(writablePath, gamePath), -- 355
			Path(writablePath, ".build", gamePath), -- 356
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 357
			gamePath -- 358
		} -- 354
	end -- 358
	for _index_0 = 1, #buildPaths do -- 359
		local _des_0 = buildPaths[_index_0] -- 359
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 359
		if not Content:exist(inputPath) then -- 360
			goto _continue_0 -- 360
		end -- 360
		local _list_0 = getAllFiles(inputPath, { -- 362
			"lua" -- 362
		}) -- 362
		for _index_1 = 1, #_list_0 do -- 362
			local file = _list_0[_index_1] -- 362
			luaFiles[#luaFiles + 1] = { -- 364
				file, -- 364
				Path(inputPath, file), -- 365
				Path(outputPath, file), -- 366
				gamePath -- 367
			} -- 363
		end -- 367
		local _list_1 = getAllFiles(inputPath, { -- 369
			yueext -- 369
		}) -- 369
		for _index_1 = 1, #_list_1 do -- 369
			local file = _list_1[_index_1] -- 369
			yueFiles[#yueFiles + 1] = { -- 371
				file, -- 371
				Path(inputPath, file), -- 372
				Path(outputPath, Path:replaceExt(file, "lua")), -- 373
				searchPath, -- 374
				gamePath -- 375
			} -- 370
		end -- 375
		local _list_2 = getAllFiles(inputPath, { -- 377
			"xml" -- 377
		}) -- 377
		for _index_1 = 1, #_list_2 do -- 377
			local file = _list_2[_index_1] -- 377
			xmlFiles[#xmlFiles + 1] = { -- 379
				file, -- 379
				Path(inputPath, file), -- 380
				Path(outputPath, Path:replaceExt(file, "lua")), -- 381
				gamePath -- 382
			} -- 378
		end -- 382
		local _list_3 = getAllFiles(inputPath, { -- 384
			"tl" -- 384
		}) -- 384
		for _index_1 = 1, #_list_3 do -- 384
			local file = _list_3[_index_1] -- 384
			if not file:match(".*%.d%.tl$") then -- 385
				tlFiles[#tlFiles + 1] = { -- 387
					file, -- 387
					Path(inputPath, file), -- 388
					Path(outputPath, Path:replaceExt(file, "lua")), -- 389
					searchPath, -- 390
					gamePath -- 391
				} -- 386
			end -- 385
		end -- 391
		::_continue_0:: -- 360
	end -- 391
	local paths -- 393
	do -- 393
		local _tbl_0 = { } -- 393
		local _list_0 = { -- 394
			luaFiles, -- 394
			yueFiles, -- 394
			xmlFiles, -- 394
			tlFiles -- 394
		} -- 394
		for _index_0 = 1, #_list_0 do -- 394
			local files = _list_0[_index_0] -- 394
			for _index_1 = 1, #files do -- 395
				local file = files[_index_1] -- 395
				_tbl_0[Path:getPath(file[3])] = true -- 393
			end -- 393
		end -- 393
		paths = _tbl_0 -- 393
	end -- 395
	for path in pairs(paths) do -- 397
		Content:mkdir(path) -- 397
	end -- 397
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 399
	local fileCount = 0 -- 400
	local errors = { } -- 401
	for _index_0 = 1, #yueFiles do -- 402
		local _des_0 = yueFiles[_index_0] -- 402
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 402
		local filename -- 403
		if gamePath then -- 403
			filename = Path(gamePath, file) -- 403
		else -- 403
			filename = file -- 403
		end -- 403
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 404
			if not codes then -- 405
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 406
				return -- 407
			end -- 405
			local success, result = LintYueGlobals(codes, globals) -- 408
			if success then -- 409
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 410
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 411
				codes = codes:gsub("^\n*", "") -- 412
				if not (result == "") then -- 413
					result = result .. "\n" -- 413
				end -- 413
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 414
			else -- 416
				local yueCodes = Content:load(input) -- 416
				if yueCodes then -- 416
					local globalErrors = { } -- 417
					for _index_1 = 1, #result do -- 418
						local _des_1 = result[_index_1] -- 418
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 418
						local countLine = 1 -- 419
						local code = "" -- 420
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 421
							if countLine == line then -- 422
								code = lineCode -- 423
								break -- 424
							end -- 422
							countLine = countLine + 1 -- 425
						end -- 425
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 426
					end -- 426
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 427
				else -- 429
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 429
				end -- 416
			end -- 409
		end, function(success) -- 404
			if success then -- 430
				print("Yue compiled: " .. tostring(filename)) -- 430
			end -- 430
			fileCount = fileCount + 1 -- 431
		end) -- 404
	end -- 431
	thread(function() -- 433
		for _index_0 = 1, #xmlFiles do -- 434
			local _des_0 = xmlFiles[_index_0] -- 434
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 434
			local filename -- 435
			if gamePath then -- 435
				filename = Path(gamePath, file) -- 435
			else -- 435
				filename = file -- 435
			end -- 435
			local sourceCodes = Content:loadAsync(input) -- 436
			local codes, err = xml.tolua(sourceCodes) -- 437
			if not codes then -- 438
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 439
			else -- 441
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 441
				print("Xml compiled: " .. tostring(filename)) -- 442
			end -- 438
			fileCount = fileCount + 1 -- 443
		end -- 443
	end) -- 433
	thread(function() -- 445
		for _index_0 = 1, #tlFiles do -- 446
			local _des_0 = tlFiles[_index_0] -- 446
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 446
			local filename -- 447
			if gamePath then -- 447
				filename = Path(gamePath, file) -- 447
			else -- 447
				filename = file -- 447
			end -- 447
			local sourceCodes = Content:loadAsync(input) -- 448
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 449
			if not codes then -- 450
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 451
			else -- 453
				Content:saveAsync(output, codes) -- 453
				print("Teal compiled: " .. tostring(filename)) -- 454
			end -- 450
			fileCount = fileCount + 1 -- 455
		end -- 455
	end) -- 445
	return thread(function() -- 457
		wait(function() -- 458
			return fileCount == totalFiles -- 458
		end) -- 458
		if minify then -- 459
			local _list_0 = { -- 460
				yueFiles, -- 460
				xmlFiles, -- 460
				tlFiles -- 460
			} -- 460
			for _index_0 = 1, #_list_0 do -- 460
				local files = _list_0[_index_0] -- 460
				for _index_1 = 1, #files do -- 460
					local file = files[_index_1] -- 460
					local output = Path:replaceExt(file[3], "lua") -- 461
					luaFiles[#luaFiles + 1] = { -- 463
						Path:replaceExt(file[1], "lua"), -- 463
						output, -- 464
						output -- 465
					} -- 462
				end -- 465
			end -- 465
			local FormatMini -- 467
			do -- 467
				local _obj_0 = require("luaminify") -- 467
				FormatMini = _obj_0.FormatMini -- 467
			end -- 467
			for _index_0 = 1, #luaFiles do -- 468
				local _des_0 = luaFiles[_index_0] -- 468
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 468
				if Content:exist(input) then -- 469
					local sourceCodes = Content:loadAsync(input) -- 470
					local res, err = FormatMini(sourceCodes) -- 471
					if res then -- 472
						Content:saveAsync(output, res) -- 473
						print("Minify: " .. tostring(file)) -- 474
					else -- 476
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 476
					end -- 472
				else -- 478
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 478
				end -- 469
			end -- 478
			package.loaded["luaminify.FormatMini"] = nil -- 479
			package.loaded["luaminify.ParseLua"] = nil -- 480
			package.loaded["luaminify.Scope"] = nil -- 481
			package.loaded["luaminify.Util"] = nil -- 482
		end -- 459
		local errorMessage = table.concat(errors, "\n") -- 483
		if errorMessage ~= "" then -- 484
			print("\n" .. errorMessage) -- 484
		end -- 484
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 485
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 486
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 487
		Content:clearPathCache() -- 488
		teal.clear() -- 489
		yue.clear() -- 490
		building = false -- 491
	end) -- 491
end -- 336
local doClean -- 493
doClean = function() -- 493
	if building then -- 494
		return -- 494
	end -- 494
	local writablePath = Content.writablePath -- 495
	local targetDir = Path(writablePath, ".build") -- 496
	Content:clearPathCache() -- 497
	if Content:remove(targetDir) then -- 498
		return print("Cleaned: " .. tostring(targetDir)) -- 499
	end -- 498
end -- 493
local screenScale = 2.0 -- 501
local scaleContent = false -- 502
local isInEntry = true -- 503
local currentEntry = nil -- 504
local footerWindow = nil -- 506
local entryWindow = nil -- 507
local testingThread = nil -- 508
local setupEventHandlers = nil -- 510
local allClear -- 512
allClear = function() -- 512
	local _list_0 = Routine -- 513
	for _index_0 = 1, #_list_0 do -- 513
		local routine = _list_0[_index_0] -- 513
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 515
			goto _continue_0 -- 516
		else -- 518
			Routine:remove(routine) -- 518
		end -- 518
		::_continue_0:: -- 514
	end -- 518
	for _index_0 = 1, #moduleCache do -- 519
		local module = moduleCache[_index_0] -- 519
		package.loaded[module] = nil -- 520
	end -- 520
	moduleCache = { } -- 521
	Director:cleanup() -- 522
	Cache:unload() -- 523
	Entity:clear() -- 524
	Platformer.Data:clear() -- 525
	Platformer.UnitAction:clear() -- 526
	Audio:stopStream(0.5) -- 527
	Struct:clear() -- 528
	View.postEffect = nil -- 529
	View.scale = scaleContent and screenScale or 1 -- 530
	Director.clearColor = Color(0xff1a1a1a) -- 531
	teal.clear() -- 532
	yue.clear() -- 533
	for _, item in pairs(ubox()) do -- 534
		local node = tolua.cast(item, "Node") -- 535
		if node then -- 535
			node:cleanup() -- 535
		end -- 535
	end -- 535
	collectgarbage() -- 536
	collectgarbage() -- 537
	setupEventHandlers() -- 538
	Content.searchPaths = searchPaths -- 539
	App.idled = true -- 540
	return Wasm:clear() -- 541
end -- 512
_module_0["allClear"] = allClear -- 541
local clearTempFiles -- 543
clearTempFiles = function() -- 543
	local writablePath = Content.writablePath -- 544
	Content:remove(Path(writablePath, ".upload")) -- 545
	return Content:remove(Path(writablePath, ".download")) -- 546
end -- 543
local waitForWebStart = true -- 548
thread(function() -- 549
	sleep(2) -- 550
	waitForWebStart = false -- 551
end) -- 549
local reloadDevEntry -- 553
reloadDevEntry = function() -- 553
	return thread(function() -- 553
		waitForWebStart = true -- 554
		doClean() -- 555
		allClear() -- 556
		_G.require = oldRequire -- 557
		Dora.require = oldRequire -- 558
		package.loaded["Script.Dev.Entry"] = nil -- 559
		return Director.systemScheduler:schedule(function() -- 560
			Routine:clear() -- 561
			oldRequire("Script.Dev.Entry") -- 562
			return true -- 563
		end) -- 563
	end) -- 563
end -- 553
local setWorkspace -- 565
setWorkspace = function(path) -- 565
	Content.writablePath = path -- 566
	config.writablePath = Content.writablePath -- 567
	return thread(function() -- 568
		sleep() -- 569
		return reloadDevEntry() -- 570
	end) -- 570
end -- 565
local _anon_func_1 = function(App, _with_0) -- 585
	local _val_0 = App.platform -- 585
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 585
end -- 585
setupEventHandlers = function() -- 572
	local _with_0 = Director.postNode -- 573
	_with_0:onAppEvent(function(eventType) -- 574
		if eventType == "Quit" then -- 574
			allClear() -- 575
			return clearTempFiles() -- 576
		end -- 574
	end) -- 574
	_with_0:onAppChange(function(settingName) -- 577
		if "Theme" == settingName then -- 578
			config.themeColor = App.themeColor:toARGB() -- 579
		elseif "Locale" == settingName then -- 580
			config.locale = App.locale -- 581
			updateLocale() -- 582
			return teal.clear(true) -- 583
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 584
			if _anon_func_1(App, _with_0) then -- 585
				if "FullScreen" == settingName then -- 587
					config.fullScreen = App.fullScreen -- 587
				elseif "Position" == settingName then -- 588
					local _obj_0 = App.winPosition -- 588
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 588
				elseif "Size" == settingName then -- 589
					local width, height -- 590
					do -- 590
						local _obj_0 = App.winSize -- 590
						width, height = _obj_0.width, _obj_0.height -- 590
					end -- 590
					config.winWidth = width -- 591
					config.winHeight = height -- 592
				end -- 592
			end -- 585
		end -- 592
	end) -- 577
	_with_0:onAppWS(function(eventType) -- 593
		if eventType == "Close" then -- 593
			if HttpServer.wsConnectionCount == 0 then -- 594
				return updateEntries() -- 595
			end -- 594
		end -- 593
	end) -- 593
	return _with_0 -- 573
end -- 572
setupEventHandlers() -- 597
clearTempFiles() -- 598
local stop -- 600
stop = function() -- 600
	if isInEntry then -- 601
		return false -- 601
	end -- 601
	allClear() -- 602
	isInEntry = true -- 603
	currentEntry = nil -- 604
	return true -- 605
end -- 600
_module_0["stop"] = stop -- 605
local _anon_func_2 = function(Content, Path, file, require, type) -- 627
	local scriptPath = Path:getPath(file) -- 620
	Content:insertSearchPath(1, scriptPath) -- 621
	scriptPath = Path(scriptPath, "Script") -- 622
	if Content:exist(scriptPath) then -- 623
		Content:insertSearchPath(1, scriptPath) -- 624
	end -- 623
	local result = require(file) -- 625
	if "function" == type(result) then -- 626
		result() -- 626
	end -- 626
	return nil -- 627
end -- 620
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 659
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 656
	label.alignment = "Left" -- 657
	label.textWidth = width - fontSize -- 658
	label.text = err -- 659
	return label -- 656
end -- 656
local enterEntryAsync -- 607
enterEntryAsync = function(entry) -- 607
	isInEntry = false -- 608
	App.idled = false -- 609
	emit(Profiler.EventName, "ClearLoader") -- 610
	currentEntry = entry -- 611
	local name, file = entry[1], entry[2] -- 612
	if cppTestSet[entry] then -- 613
		if App:runTest(name) then -- 614
			return true -- 615
		else -- 617
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 617
		end -- 614
	end -- 613
	sleep() -- 618
	return xpcall(_anon_func_2, function(msg) -- 660
		local err = debug.traceback(msg) -- 629
		Log("Error", err) -- 630
		allClear() -- 631
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 632
		local viewWidth, viewHeight -- 633
		do -- 633
			local _obj_0 = View.size -- 633
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 633
		end -- 633
		local width, height = viewWidth - 20, viewHeight - 20 -- 634
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 635
		Director.ui:addChild((function() -- 636
			local root = AlignNode() -- 636
			do -- 637
				local _obj_0 = App.bufferSize -- 637
				width, height = _obj_0.width, _obj_0.height -- 637
			end -- 637
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 638
			root:onAppChange(function(settingName) -- 639
				if settingName == "Size" then -- 639
					do -- 640
						local _obj_0 = App.bufferSize -- 640
						width, height = _obj_0.width, _obj_0.height -- 640
					end -- 640
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 641
				end -- 639
			end) -- 639
			root:addChild((function() -- 642
				local _with_0 = ScrollArea({ -- 643
					width = width, -- 643
					height = height, -- 644
					paddingX = 0, -- 645
					paddingY = 50, -- 646
					viewWidth = height, -- 647
					viewHeight = height -- 648
				}) -- 642
				root:onAlignLayout(function(w, h) -- 650
					_with_0.position = Vec2(w / 2, h / 2) -- 651
					w = w - 20 -- 652
					h = h - 20 -- 653
					_with_0.view.children.first.textWidth = w - fontSize -- 654
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 655
				end) -- 650
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 656
				return _with_0 -- 642
			end)()) -- 642
			return root -- 636
		end)()) -- 636
		return err -- 660
	end, Content, Path, file, require, type) -- 660
end -- 607
_module_0["enterEntryAsync"] = enterEntryAsync -- 660
local enterDemoEntry -- 662
enterDemoEntry = function(entry) -- 662
	return thread(function() -- 662
		return enterEntryAsync(entry) -- 662
	end) -- 662
end -- 662
local reloadCurrentEntry -- 664
reloadCurrentEntry = function() -- 664
	if currentEntry then -- 665
		allClear() -- 666
		return enterDemoEntry(currentEntry) -- 667
	end -- 665
end -- 664
Director.clearColor = Color(0xff1a1a1a) -- 669
local isOSSLicenseExist = Content:exist("LICENSES") -- 671
local ossLicenses = nil -- 672
local ossLicenseOpen = false -- 673
local _anon_func_4 = function(App) -- 677
	local _val_0 = App.platform -- 677
	return not ("Android" == _val_0 or "iOS" == _val_0) -- 677
end -- 677
local extraOperations -- 675
extraOperations = function() -- 675
	local zh = useChinese and isChineseSupported -- 676
	if _anon_func_4(App) then -- 677
		local themeColor = App.themeColor -- 678
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 679
		do -- 680
			local changed -- 680
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 680
			if changed then -- 680
				App.alwaysOnTop = alwaysOnTop -- 681
				config.alwaysOnTop = alwaysOnTop -- 682
			end -- 680
		end -- 680
		SeparatorText(zh and "工作目录" or "Workspace") -- 683
		PushTextWrapPos(400, function() -- 684
			return TextColored(themeColor, writablePath) -- 685
		end) -- 684
		if Button(zh and "改变目录" or "Set Folder") then -- 686
			App:openFileDialog(true, function(path) -- 687
				if path ~= "" then -- 688
					return setWorkspace(path) -- 688
				end -- 688
			end) -- 687
		end -- 686
		SameLine() -- 689
		if Button(zh and "使用默认" or "Use Default") then -- 690
			setWorkspace(Content.appPath) -- 691
		end -- 690
		Separator() -- 692
	end -- 677
	if isOSSLicenseExist then -- 693
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 694
			if not ossLicenses then -- 695
				ossLicenses = { } -- 696
				local licenseText = Content:load("LICENSES") -- 697
				ossLicenseOpen = (licenseText ~= nil) -- 698
				if ossLicenseOpen then -- 698
					licenseText = licenseText:gsub("\r\n", "\n") -- 699
					for license in GSplit(licenseText, "\n--------\n", true) do -- 700
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 701
						if name then -- 701
							ossLicenses[#ossLicenses + 1] = { -- 702
								name, -- 702
								text -- 702
							} -- 702
						end -- 701
					end -- 702
				end -- 698
			else -- 704
				ossLicenseOpen = true -- 704
			end -- 695
		end -- 694
		if ossLicenseOpen then -- 705
			local width, height, themeColor -- 706
			do -- 706
				local _obj_0 = App -- 706
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 706
			end -- 706
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 707
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 708
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 709
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 712
					"NoSavedSettings" -- 712
				}, function() -- 713
					for _index_0 = 1, #ossLicenses do -- 713
						local _des_0 = ossLicenses[_index_0] -- 713
						local firstLine, text = _des_0[1], _des_0[2] -- 713
						local name, license = firstLine:match("(.+): (.+)") -- 714
						TextColored(themeColor, name) -- 715
						SameLine() -- 716
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 717
							return TextWrapped(text) -- 717
						end) -- 717
					end -- 717
				end) -- 709
			end) -- 709
		end -- 705
	end -- 693
	if not App.debugging then -- 719
		return -- 719
	end -- 719
	return TreeNode(zh and "开发操作" or "Development", function() -- 720
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 721
			OpenPopup("build") -- 721
		end -- 721
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 722
			return BeginPopup("build", function() -- 722
				if Selectable(zh and "编译" or "Compile") then -- 723
					doCompile(false) -- 723
				end -- 723
				Separator() -- 724
				if Selectable(zh and "压缩" or "Minify") then -- 725
					doCompile(true) -- 725
				end -- 725
				Separator() -- 726
				if Selectable(zh and "清理" or "Clean") then -- 727
					return doClean() -- 727
				end -- 727
			end) -- 727
		end) -- 722
		if isInEntry then -- 728
			if waitForWebStart then -- 729
				BeginDisabled(function() -- 730
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 730
				end) -- 730
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 731
				reloadDevEntry() -- 732
			end -- 729
		end -- 728
		do -- 733
			local changed -- 733
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 733
			if changed then -- 733
				View.scale = scaleContent and screenScale or 1 -- 734
			end -- 733
		end -- 733
		do -- 735
			local changed -- 735
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 735
			if changed then -- 735
				config.engineDev = engineDev -- 736
			end -- 735
		end -- 735
		if Button(zh and "开始自动测试" or "Test automatically") then -- 737
			testingThread = thread(function() -- 738
				local _ <close> = setmetatable({ }, { -- 739
					__close = function() -- 739
						allClear() -- 740
						testingThread = nil -- 741
						isInEntry = true -- 742
						currentEntry = nil -- 743
						return print("Testing done!") -- 744
					end -- 739
				}) -- 739
				for _, entry in ipairs(allEntries) do -- 745
					allClear() -- 746
					print("Start " .. tostring(entry[1])) -- 747
					enterDemoEntry(entry) -- 748
					sleep(2) -- 749
					print("Stop " .. tostring(entry[1])) -- 750
				end -- 750
			end) -- 738
		end -- 737
	end) -- 720
end -- 675
local transparant = Color(0x0) -- 752
local windowFlags = { -- 753
	"NoTitleBar", -- 753
	"NoResize", -- 753
	"NoMove", -- 753
	"NoCollapse", -- 753
	"NoSavedSettings", -- 753
	"NoBringToFrontOnFocus" -- 753
} -- 753
local initFooter = true -- 761
local _anon_func_5 = function(allEntries, currentIndex) -- 797
	if currentIndex > 1 then -- 797
		return allEntries[currentIndex - 1] -- 798
	else -- 800
		return allEntries[#allEntries] -- 800
	end -- 797
end -- 797
local _anon_func_6 = function(allEntries, currentIndex) -- 804
	if currentIndex < #allEntries then -- 804
		return allEntries[currentIndex + 1] -- 805
	else -- 807
		return allEntries[1] -- 807
	end -- 804
end -- 804
footerWindow = threadLoop(function() -- 762
	local zh = useChinese and isChineseSupported -- 763
	if HttpServer.wsConnectionCount > 0 then -- 764
		return -- 765
	end -- 764
	if Keyboard:isKeyDown("Escape") then -- 766
		allClear() -- 767
		App:shutdown() -- 768
	end -- 766
	do -- 769
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 770
		if ctrl and Keyboard:isKeyDown("Q") then -- 771
			stop() -- 772
		end -- 771
		if ctrl and Keyboard:isKeyDown("Z") then -- 773
			reloadCurrentEntry() -- 774
		end -- 773
		if ctrl and Keyboard:isKeyDown(",") then -- 775
			if showFooter then -- 776
				showStats = not showStats -- 776
			else -- 776
				showStats = true -- 776
			end -- 776
			showFooter = true -- 777
			config.showFooter = showFooter -- 778
			config.showStats = showStats -- 779
		end -- 775
		if ctrl and Keyboard:isKeyDown(".") then -- 780
			if showFooter then -- 781
				showConsole = not showConsole -- 781
			else -- 781
				showConsole = true -- 781
			end -- 781
			showFooter = true -- 782
			config.showFooter = showFooter -- 783
			config.showConsole = showConsole -- 784
		end -- 780
		if ctrl and Keyboard:isKeyDown("/") then -- 785
			showFooter = not showFooter -- 786
			config.showFooter = showFooter -- 787
		end -- 785
		local left = ctrl and Keyboard:isKeyDown("Left") -- 788
		local right = ctrl and Keyboard:isKeyDown("Right") -- 789
		local currentIndex = nil -- 790
		for i, entry in ipairs(allEntries) do -- 791
			if currentEntry == entry then -- 792
				currentIndex = i -- 793
			end -- 792
		end -- 793
		if left then -- 794
			allClear() -- 795
			if currentIndex == nil then -- 796
				currentIndex = #allEntries + 1 -- 796
			end -- 796
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 797
		end -- 794
		if right then -- 801
			allClear() -- 802
			if currentIndex == nil then -- 803
				currentIndex = 0 -- 803
			end -- 803
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 804
		end -- 801
	end -- 807
	if not showEntry then -- 808
		return -- 808
	end -- 808
	local width, height -- 810
	do -- 810
		local _obj_0 = App.visualSize -- 810
		width, height = _obj_0.width, _obj_0.height -- 810
	end -- 810
	SetNextWindowSize(Vec2(50, 50)) -- 811
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 812
	PushStyleColor("WindowBg", transparant, function() -- 813
		return Begin("Show", windowFlags, function() -- 813
			if isInEntry or width >= 540 then -- 814
				local changed -- 815
				changed, showFooter = Checkbox("##dev", showFooter) -- 815
				if changed then -- 815
					config.showFooter = showFooter -- 816
				end -- 815
			end -- 814
		end) -- 816
	end) -- 813
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 818
		reloadDevEntry() -- 822
	end -- 818
	if initFooter then -- 823
		initFooter = false -- 824
	else -- 826
		if not showFooter then -- 826
			return -- 826
		end -- 826
	end -- 823
	SetNextWindowSize(Vec2(width, 50)) -- 828
	SetNextWindowPos(Vec2(0, height - 50)) -- 829
	SetNextWindowBgAlpha(0.35) -- 830
	do -- 831
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 832
			return Begin("Footer", windowFlags, function() -- 833
				Dummy(Vec2(width - 20, 0)) -- 834
				do -- 835
					local changed -- 835
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 835
					if changed then -- 835
						config.showStats = showStats -- 836
					end -- 835
				end -- 835
				SameLine() -- 837
				do -- 838
					local changed -- 838
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 838
					if changed then -- 838
						config.showConsole = showConsole -- 839
					end -- 838
				end -- 838
				if config.updateNotification then -- 840
					SameLine() -- 841
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 842
						config.updateNotification = false -- 843
						allClear() -- 844
						enterDemoEntry({ -- 845
							"SelfUpdater", -- 845
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 845
						}) -- 845
					end -- 842
				end -- 840
				if not isInEntry then -- 846
					SameLine() -- 847
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 848
					local currentIndex = nil -- 849
					for i, entry in ipairs(allEntries) do -- 850
						if currentEntry == entry then -- 851
							currentIndex = i -- 852
						end -- 851
					end -- 852
					if currentIndex then -- 853
						if currentIndex > 1 then -- 854
							SameLine() -- 855
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 856
								allClear() -- 857
								enterDemoEntry(allEntries[currentIndex - 1]) -- 858
							end -- 856
						end -- 854
						if currentIndex < #allEntries then -- 859
							SameLine() -- 860
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 861
								allClear() -- 862
								enterDemoEntry(allEntries[currentIndex + 1]) -- 863
							end -- 861
						end -- 859
					end -- 853
					SameLine() -- 864
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 865
						reloadCurrentEntry() -- 866
					end -- 865
					if back then -- 867
						allClear() -- 868
						isInEntry = true -- 869
						currentEntry = nil -- 870
					end -- 867
				end -- 846
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 871
					if showStats then -- 872
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 873
						showStats = ShowStats(showStats, extraOperations) -- 874
						config.showStats = showStats -- 875
					end -- 872
					if showConsole then -- 876
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 877
						showConsole = ShowConsole(showConsole) -- 878
						config.showConsole = showConsole -- 879
					end -- 876
				end) -- 871
			end) -- 833
		end) -- 832
	end -- 879
end) -- 762
local MaxWidth <const> = 800 -- 881
local displayWindowFlags = { -- 883
	"NoDecoration", -- 883
	"NoSavedSettings", -- 883
	"NoFocusOnAppearing", -- 883
	"NoNav", -- 883
	"NoMove", -- 883
	"NoScrollWithMouse", -- 883
	"AlwaysAutoResize", -- 883
	"NoBringToFrontOnFocus" -- 883
} -- 883
local webStatus = nil -- 894
local descColor = Color(0xffa1a1a1) -- 895
local gameOpen = #gamesInDev == 0 -- 896
local toolOpen = false -- 897
local exampleOpen = false -- 898
local testOpen = false -- 899
local filterText = nil -- 900
local anyEntryMatched = false -- 901
local urlClicked = nil -- 902
local match -- 903
match = function(name) -- 903
	local res = not filterText or name:lower():match(filterText) -- 904
	if res then -- 905
		anyEntryMatched = true -- 905
	end -- 905
	return res -- 906
end -- 903
local iconTex = nil -- 907
thread(function() -- 908
	if Cache:loadAsync("Image/icon_s.png") then -- 908
		iconTex = Texture2D("Image/icon_s.png") -- 909
	end -- 908
end) -- 908
entryWindow = threadLoop(function() -- 911
	if App.fpsLimited ~= config.fpsLimited then -- 912
		config.fpsLimited = App.fpsLimited -- 913
	end -- 912
	if App.targetFPS ~= config.targetFPS then -- 914
		config.targetFPS = App.targetFPS -- 915
	end -- 914
	if View.vsync ~= config.vsync then -- 916
		config.vsync = View.vsync -- 917
	end -- 916
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 918
		config.fixedFPS = Director.scheduler.fixedFPS -- 919
	end -- 918
	if Director.profilerSending ~= config.webProfiler then -- 920
		config.webProfiler = Director.profilerSending -- 921
	end -- 920
	if urlClicked then -- 922
		local _, result = coroutine.resume(urlClicked) -- 923
		if result then -- 924
			coroutine.close(urlClicked) -- 925
			urlClicked = nil -- 926
		end -- 924
	end -- 922
	if not showEntry then -- 927
		return -- 927
	end -- 927
	if not isInEntry then -- 928
		return -- 928
	end -- 928
	local zh = useChinese and isChineseSupported -- 929
	if HttpServer.wsConnectionCount > 0 then -- 930
		local themeColor = App.themeColor -- 931
		local width, height -- 932
		do -- 932
			local _obj_0 = App.visualSize -- 932
			width, height = _obj_0.width, _obj_0.height -- 932
		end -- 932
		SetNextWindowBgAlpha(0.5) -- 933
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 934
		Begin("Web IDE Connected", displayWindowFlags, function() -- 935
			Separator() -- 936
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 937
			if iconTex then -- 938
				Image("Image/icon_s.png", Vec2(24, 24)) -- 939
				SameLine() -- 940
			end -- 938
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 941
			TextColored(descColor, slogon) -- 942
			return Separator() -- 943
		end) -- 935
		return -- 944
	end -- 930
	local themeColor = App.themeColor -- 946
	local fullWidth, height -- 947
	do -- 947
		local _obj_0 = App.visualSize -- 947
		fullWidth, height = _obj_0.width, _obj_0.height -- 947
	end -- 947
	SetNextWindowBgAlpha(0.85) -- 949
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 950
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 951
		return Begin("Web IDE", displayWindowFlags, function() -- 952
			Separator() -- 953
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 954
			SameLine() -- 955
			TextDisabled('(?)') -- 956
			if IsItemHovered() then -- 957
				BeginTooltip(function() -- 958
					return PushTextWrapPos(280, function() -- 959
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 960
					end) -- 960
				end) -- 958
			end -- 957
			do -- 961
				local url -- 961
				if webStatus ~= nil then -- 961
					url = webStatus.url -- 961
				end -- 961
				if url then -- 961
					if isDesktop and not config.fullScreen then -- 962
						if urlClicked then -- 963
							BeginDisabled(function() -- 964
								return Button(url) -- 964
							end) -- 964
						elseif Button(url) then -- 965
							urlClicked = once(function() -- 966
								return sleep(5) -- 966
							end) -- 966
							App:openURL("http://localhost:8866") -- 967
						end -- 963
					else -- 969
						TextColored(descColor, url) -- 969
					end -- 962
				else -- 971
					TextColored(descColor, zh and '不可用' or 'not available') -- 971
				end -- 961
			end -- 961
			return Separator() -- 972
		end) -- 972
	end) -- 951
	local width = math.min(MaxWidth, fullWidth) -- 974
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 975
	local maxColumns = math.max(math.floor(width / 200), 1) -- 976
	SetNextWindowPos(Vec2.zero) -- 977
	SetNextWindowBgAlpha(0) -- 978
	do -- 979
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 980
			return Begin("Dora Dev", displayWindowFlags, function() -- 981
				Dummy(Vec2(fullWidth - 20, 0)) -- 982
				if iconTex then -- 983
					Image("Image/icon_s.png", Vec2(24, 24)) -- 984
					SameLine() -- 985
				end -- 983
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 986
				if fullWidth >= 320 then -- 987
					SameLine() -- 988
					Dummy(Vec2(fullWidth - 320, 0)) -- 989
					SameLine() -- 990
					SetNextItemWidth(-30) -- 991
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 992
						"AutoSelectAll" -- 992
					}) then -- 992
						config.filter = filterBuf.text -- 993
					end -- 992
				end -- 987
				Separator() -- 994
				return Dummy(Vec2(fullWidth - 20, 0)) -- 995
			end) -- 981
		end) -- 980
	end -- 995
	anyEntryMatched = false -- 997
	SetNextWindowPos(Vec2(0, 50)) -- 998
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 999
	do -- 1000
		return PushStyleColor("WindowBg", transparant, function() -- 1001
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1002
				return Begin("Content", windowFlags, function() -- 1003
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 1004
					if filterText then -- 1005
						filterText = filterText:lower() -- 1005
					end -- 1005
					if #gamesInDev > 0 then -- 1006
						for _index_0 = 1, #gamesInDev do -- 1007
							local game = gamesInDev[_index_0] -- 1007
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1008
							local showSep = false -- 1009
							if match(gameName) then -- 1010
								Columns(1, false) -- 1011
								TextColored(themeColor, zh and "项目：" or "Project:") -- 1012
								SameLine() -- 1013
								Text(gameName) -- 1014
								Separator() -- 1015
								if bannerFile then -- 1016
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1017
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1018
									local sizing <const> = 0.8 -- 1019
									texHeight = displayWidth * sizing * texHeight / texWidth -- 1020
									texWidth = displayWidth * sizing -- 1021
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1022
									Dummy(Vec2(padding, 0)) -- 1023
									SameLine() -- 1024
									PushID(fileName, function() -- 1025
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1026
											return enterDemoEntry(game) -- 1027
										end -- 1026
									end) -- 1025
								else -- 1029
									PushID(fileName, function() -- 1029
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 1030
											return enterDemoEntry(game) -- 1031
										end -- 1030
									end) -- 1029
								end -- 1016
								NextColumn() -- 1032
								showSep = true -- 1033
							end -- 1010
							if #examples > 0 then -- 1034
								local showExample = false -- 1035
								for _index_1 = 1, #examples do -- 1036
									local example = examples[_index_1] -- 1036
									if match(example[1]) then -- 1037
										showExample = true -- 1038
										break -- 1039
									end -- 1037
								end -- 1039
								if showExample then -- 1040
									Columns(1, false) -- 1041
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1042
									SameLine() -- 1043
									Text(gameName) -- 1044
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1045
										Columns(maxColumns, false) -- 1046
										for _index_1 = 1, #examples do -- 1047
											local example = examples[_index_1] -- 1047
											if not match(example[1]) then -- 1048
												goto _continue_0 -- 1048
											end -- 1048
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1049
												if Button(example[1], Vec2(-1, 40)) then -- 1050
													enterDemoEntry(example) -- 1051
												end -- 1050
												return NextColumn() -- 1052
											end) -- 1049
											showSep = true -- 1053
											::_continue_0:: -- 1048
										end -- 1053
									end) -- 1045
								end -- 1040
							end -- 1034
							if #tests > 0 then -- 1054
								local showTest = false -- 1055
								for _index_1 = 1, #tests do -- 1056
									local test = tests[_index_1] -- 1056
									if match(test[1]) then -- 1057
										showTest = true -- 1058
										break -- 1059
									end -- 1057
								end -- 1059
								if showTest then -- 1060
									Columns(1, false) -- 1061
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1062
									SameLine() -- 1063
									Text(gameName) -- 1064
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1065
										Columns(maxColumns, false) -- 1066
										for _index_1 = 1, #tests do -- 1067
											local test = tests[_index_1] -- 1067
											if not match(test[1]) then -- 1068
												goto _continue_0 -- 1068
											end -- 1068
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1069
												if Button(test[1], Vec2(-1, 40)) then -- 1070
													enterDemoEntry(test) -- 1071
												end -- 1070
												return NextColumn() -- 1072
											end) -- 1069
											showSep = true -- 1073
											::_continue_0:: -- 1068
										end -- 1073
									end) -- 1065
								end -- 1060
							end -- 1054
							if showSep then -- 1074
								Columns(1, false) -- 1075
								Separator() -- 1076
							end -- 1074
						end -- 1076
					end -- 1006
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1077
						local showGame = false -- 1078
						for _index_0 = 1, #games do -- 1079
							local _des_0 = games[_index_0] -- 1079
							local name = _des_0[1] -- 1079
							if match(name) then -- 1080
								showGame = true -- 1080
							end -- 1080
						end -- 1080
						local showTool = false -- 1081
						for _index_0 = 1, #doraTools do -- 1082
							local _des_0 = doraTools[_index_0] -- 1082
							local name = _des_0[1] -- 1082
							if match(name) then -- 1083
								showTool = true -- 1083
							end -- 1083
						end -- 1083
						local showExample = false -- 1084
						for _index_0 = 1, #doraExamples do -- 1085
							local _des_0 = doraExamples[_index_0] -- 1085
							local name = _des_0[1] -- 1085
							if match(name) then -- 1086
								showExample = true -- 1086
							end -- 1086
						end -- 1086
						local showTest = false -- 1087
						for _index_0 = 1, #doraTests do -- 1088
							local _des_0 = doraTests[_index_0] -- 1088
							local name = _des_0[1] -- 1088
							if match(name) then -- 1089
								showTest = true -- 1089
							end -- 1089
						end -- 1089
						for _index_0 = 1, #cppTests do -- 1090
							local _des_0 = cppTests[_index_0] -- 1090
							local name = _des_0[1] -- 1090
							if match(name) then -- 1091
								showTest = true -- 1091
							end -- 1091
						end -- 1091
						if not (showGame or showTool or showExample or showTest) then -- 1092
							goto endEntry -- 1092
						end -- 1092
						Columns(1, false) -- 1093
						TextColored(themeColor, "Dora SSR:") -- 1094
						SameLine() -- 1095
						Text(zh and "开发示例" or "Development Showcase") -- 1096
						Separator() -- 1097
						local demoViewWith <const> = 400 -- 1098
						if #games > 0 and showGame then -- 1099
							local opened -- 1100
							if (filterText ~= nil) then -- 1100
								opened = showGame -- 1100
							else -- 1100
								opened = false -- 1100
							end -- 1100
							SetNextItemOpen(gameOpen) -- 1101
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1102
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1103
								Columns(columns, false) -- 1104
								for _index_0 = 1, #games do -- 1105
									local game = games[_index_0] -- 1105
									if not match(game[1]) then -- 1106
										goto _continue_0 -- 1106
									end -- 1106
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1107
									if columns > 1 then -- 1108
										if bannerFile then -- 1109
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1110
											local displayWidth <const> = demoViewWith - 40 -- 1111
											texHeight = displayWidth * texHeight / texWidth -- 1112
											texWidth = displayWidth -- 1113
											Text(gameName) -- 1114
											PushID(fileName, function() -- 1115
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1116
													return enterDemoEntry(game) -- 1117
												end -- 1116
											end) -- 1115
										else -- 1119
											PushID(fileName, function() -- 1119
												if Button(gameName, Vec2(-1, 40)) then -- 1120
													return enterDemoEntry(game) -- 1121
												end -- 1120
											end) -- 1119
										end -- 1109
									else -- 1123
										if bannerFile then -- 1123
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1124
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1125
											local sizing = 0.8 -- 1126
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1127
											texWidth = displayWidth * sizing -- 1128
											if texWidth > 500 then -- 1129
												sizing = 0.6 -- 1130
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1131
												texWidth = displayWidth * sizing -- 1132
											end -- 1129
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1133
											Dummy(Vec2(padding, 0)) -- 1134
											SameLine() -- 1135
											Text(gameName) -- 1136
											Dummy(Vec2(padding, 0)) -- 1137
											SameLine() -- 1138
											PushID(fileName, function() -- 1139
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1140
													return enterDemoEntry(game) -- 1141
												end -- 1140
											end) -- 1139
										else -- 1143
											PushID(fileName, function() -- 1143
												if Button(gameName, Vec2(-1, 40)) then -- 1144
													return enterDemoEntry(game) -- 1145
												end -- 1144
											end) -- 1143
										end -- 1123
									end -- 1108
									NextColumn() -- 1146
									::_continue_0:: -- 1106
								end -- 1146
								Columns(1, false) -- 1147
								opened = true -- 1148
							end) -- 1102
							gameOpen = opened -- 1149
						end -- 1099
						if #doraTools > 0 and showTool then -- 1150
							local opened -- 1151
							if (filterText ~= nil) then -- 1151
								opened = showTool -- 1151
							else -- 1151
								opened = false -- 1151
							end -- 1151
							SetNextItemOpen(toolOpen) -- 1152
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1153
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1154
									Columns(maxColumns, false) -- 1155
									for _index_0 = 1, #doraTools do -- 1156
										local example = doraTools[_index_0] -- 1156
										if not match(example[1]) then -- 1157
											goto _continue_0 -- 1157
										end -- 1157
										if Button(example[1], Vec2(-1, 40)) then -- 1158
											enterDemoEntry(example) -- 1159
										end -- 1158
										NextColumn() -- 1160
										::_continue_0:: -- 1157
									end -- 1160
									Columns(1, false) -- 1161
									opened = true -- 1162
								end) -- 1154
							end) -- 1153
							toolOpen = opened -- 1163
						end -- 1150
						if #doraExamples > 0 and showExample then -- 1164
							local opened -- 1165
							if (filterText ~= nil) then -- 1165
								opened = showExample -- 1165
							else -- 1165
								opened = false -- 1165
							end -- 1165
							SetNextItemOpen(exampleOpen) -- 1166
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1167
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1168
									Columns(maxColumns, false) -- 1169
									for _index_0 = 1, #doraExamples do -- 1170
										local example = doraExamples[_index_0] -- 1170
										if not match(example[1]) then -- 1171
											goto _continue_0 -- 1171
										end -- 1171
										if Button(example[1], Vec2(-1, 40)) then -- 1172
											enterDemoEntry(example) -- 1173
										end -- 1172
										NextColumn() -- 1174
										::_continue_0:: -- 1171
									end -- 1174
									Columns(1, false) -- 1175
									opened = true -- 1176
								end) -- 1168
							end) -- 1167
							exampleOpen = opened -- 1177
						end -- 1164
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1178
							local opened -- 1179
							if (filterText ~= nil) then -- 1179
								opened = showTest -- 1179
							else -- 1179
								opened = false -- 1179
							end -- 1179
							SetNextItemOpen(testOpen) -- 1180
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1181
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1182
									Columns(maxColumns, false) -- 1183
									for _index_0 = 1, #doraTests do -- 1184
										local test = doraTests[_index_0] -- 1184
										if not match(test[1]) then -- 1185
											goto _continue_0 -- 1185
										end -- 1185
										if Button(test[1], Vec2(-1, 40)) then -- 1186
											enterDemoEntry(test) -- 1187
										end -- 1186
										NextColumn() -- 1188
										::_continue_0:: -- 1185
									end -- 1188
									for _index_0 = 1, #cppTests do -- 1189
										local test = cppTests[_index_0] -- 1189
										if not match(test[1]) then -- 1190
											goto _continue_1 -- 1190
										end -- 1190
										if Button(test[1], Vec2(-1, 40)) then -- 1191
											enterDemoEntry(test) -- 1192
										end -- 1191
										NextColumn() -- 1193
										::_continue_1:: -- 1190
									end -- 1193
									opened = true -- 1194
								end) -- 1182
							end) -- 1181
							testOpen = opened -- 1195
						end -- 1178
					end -- 1077
					::endEntry:: -- 1196
					if not anyEntryMatched then -- 1197
						SetNextWindowBgAlpha(0) -- 1198
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1199
						Begin("Entries Not Found", displayWindowFlags, function() -- 1200
							Separator() -- 1201
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1202
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1203
							return Separator() -- 1204
						end) -- 1200
					end -- 1197
					Columns(1, false) -- 1205
					Dummy(Vec2(100, 80)) -- 1206
					return ScrollWhenDraggingOnVoid() -- 1207
				end) -- 1003
			end) -- 1002
		end) -- 1001
	end -- 1207
end) -- 911
webStatus = require("Script.Dev.WebServer") -- 1209
return _module_0 -- 1209
