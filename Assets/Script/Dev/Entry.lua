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
local isDesktop -- 36
do -- 36
	local _val_0 = App.platform -- 36
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 36
end -- 36
if DB:exist("Config") then -- 38
	do -- 39
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 39
		local _type_0 = type(_exp_0) -- 40
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 40
		if _tab_0 then -- 40
			local locale -- 40
			do -- 40
				local _obj_0 = _exp_0[1] -- 40
				local _type_1 = type(_obj_0) -- 40
				if "table" == _type_1 or "userdata" == _type_1 then -- 40
					locale = _obj_0[1] -- 40
				end -- 42
			end -- 42
			if locale ~= nil then -- 40
				if App.locale ~= locale then -- 40
					App.locale = locale -- 41
					updateLocale() -- 42
				end -- 40
			end -- 40
		end -- 42
	end -- 42
	if isDesktop then -- 43
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 44
		local _type_0 = type(_exp_0) -- 45
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 45
		if _tab_0 then -- 45
			local writablePath -- 45
			do -- 45
				local _obj_0 = _exp_0[1] -- 45
				local _type_1 = type(_obj_0) -- 45
				if "table" == _type_1 or "userdata" == _type_1 then -- 45
					writablePath = _obj_0[1] -- 45
				end -- 46
			end -- 46
			if writablePath ~= nil then -- 45
				Content.writablePath = writablePath -- 46
			end -- 45
		end -- 46
	end -- 43
end -- 38
local Config = require("Config") -- 48
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected") -- 50
config:load() -- 77
if not (config.writablePath ~= nil) then -- 79
	config.writablePath = Content.appPath -- 80
end -- 79
if not (config.webIDEConnected ~= nil) then -- 82
	config.webIDEConnected = false -- 83
end -- 82
if (config.fpsLimited ~= nil) then -- 85
	App.fpsLimited = config.fpsLimited -- 86
else -- 88
	config.fpsLimited = App.fpsLimited -- 88
end -- 85
if (config.targetFPS ~= nil) then -- 90
	App.targetFPS = config.targetFPS -- 91
else -- 93
	config.targetFPS = App.targetFPS -- 93
end -- 90
if (config.vsync ~= nil) then -- 95
	View.vsync = config.vsync -- 96
else -- 98
	config.vsync = View.vsync -- 98
end -- 95
if (config.fixedFPS ~= nil) then -- 100
	Director.scheduler.fixedFPS = config.fixedFPS -- 101
else -- 103
	config.fixedFPS = Director.scheduler.fixedFPS -- 103
end -- 100
local showEntry = true -- 105
isDesktop = false -- 107
if (function() -- 108
	local _val_0 = App.platform -- 108
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 108
end)() then -- 108
	isDesktop = true -- 109
	if config.fullScreen then -- 110
		App.fullScreen = true -- 111
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 112
		local size = Size(config.winWidth, config.winHeight) -- 113
		if App.winSize ~= size then -- 114
			App.winSize = size -- 115
			showEntry = false -- 116
			thread(function() -- 117
				sleep() -- 118
				sleep() -- 119
				showEntry = true -- 120
			end) -- 117
		end -- 114
		local winX, winY -- 121
		do -- 121
			local _obj_0 = App.winPosition -- 121
			winX, winY = _obj_0.x, _obj_0.y -- 121
		end -- 121
		if (config.winX ~= nil) then -- 122
			winX = config.winX -- 123
		else -- 125
			config.winX = -1 -- 125
		end -- 122
		if (config.winY ~= nil) then -- 126
			winY = config.winY -- 127
		else -- 129
			config.winY = -1 -- 129
		end -- 126
		App.winPosition = Vec2(winX, winY) -- 130
	end -- 110
	if (config.alwaysOnTop ~= nil) then -- 131
		App.alwaysOnTop = config.alwaysOnTop -- 132
	else -- 134
		config.alwaysOnTop = true -- 134
	end -- 131
end -- 108
if (config.themeColor ~= nil) then -- 136
	App.themeColor = Color(config.themeColor) -- 137
else -- 139
	config.themeColor = App.themeColor:toARGB() -- 139
end -- 136
if not (config.locale ~= nil) then -- 141
	config.locale = App.locale -- 142
end -- 141
local showStats = false -- 144
if (config.showStats ~= nil) then -- 145
	showStats = config.showStats -- 146
else -- 148
	config.showStats = showStats -- 148
end -- 145
local showConsole = false -- 150
if (config.showConsole ~= nil) then -- 151
	showConsole = config.showConsole -- 152
else -- 154
	config.showConsole = showConsole -- 154
end -- 151
local showFooter = true -- 156
if (config.showFooter ~= nil) then -- 157
	showFooter = config.showFooter -- 158
else -- 160
	config.showFooter = showFooter -- 160
end -- 157
local filterBuf = Buffer(20) -- 162
if (config.filter ~= nil) then -- 163
	filterBuf.text = config.filter -- 164
else -- 166
	config.filter = "" -- 166
end -- 163
local engineDev = false -- 168
if (config.engineDev ~= nil) then -- 169
	engineDev = config.engineDev -- 170
else -- 172
	config.engineDev = engineDev -- 172
end -- 169
if (config.webProfiler ~= nil) then -- 174
	Director.profilerSending = config.webProfiler -- 175
else -- 177
	config.webProfiler = true -- 177
	Director.profilerSending = true -- 178
end -- 174
if not (config.drawerWidth ~= nil) then -- 180
	config.drawerWidth = 200 -- 181
end -- 180
_module_0.getConfig = function() -- 183
	return config -- 183
end -- 183
_module_0.getEngineDev = function() -- 184
	if not App.debugging then -- 185
		return false -- 185
	end -- 185
	return config.engineDev -- 186
end -- 184
local _anon_func_0 = function(App) -- 191
	local _val_0 = App.platform -- 191
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 191
end -- 191
_module_0.connectWebIDE = function() -- 188
	if not config.webIDEConnected then -- 189
		config.webIDEConnected = true -- 190
		if _anon_func_0(App) then -- 191
			local ratio = App.winSize.width / App.visualSize.width -- 192
			App.winSize = Size(640 * ratio, 480 * ratio) -- 193
		end -- 191
	end -- 189
end -- 188
local updateCheck -- 195
updateCheck = function() -- 195
	return thread(function() -- 195
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 196
		if res then -- 196
			local data = json.load(res) -- 197
			if data then -- 197
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 198
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 199
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 200
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 201
				if na < a then -- 202
					goto not_new_version -- 203
				end -- 202
				if na == a then -- 204
					if nb < b then -- 205
						goto not_new_version -- 206
					end -- 205
					if nb == b then -- 207
						if nc < c then -- 208
							goto not_new_version -- 209
						end -- 208
						if nc == c then -- 210
							goto not_new_version -- 211
						end -- 210
					end -- 207
				end -- 204
				config.updateNotification = true -- 212
				::not_new_version:: -- 213
				config.lastUpdateCheck = os.time() -- 214
			end -- 197
		end -- 196
	end) -- 214
end -- 195
if (config.lastUpdateCheck ~= nil) then -- 216
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 217
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 218
		updateCheck() -- 219
	end -- 218
else -- 221
	updateCheck() -- 221
end -- 216
local Set, Struct, LintYueGlobals, GSplit -- 223
do -- 223
	local _obj_0 = require("Utils") -- 223
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 223
end -- 223
local yueext = yue.options.extension -- 224
local isChineseSupported = IsFontLoaded() -- 226
if not isChineseSupported then -- 227
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 228
		isChineseSupported = true -- 229
	end) -- 228
end -- 227
local building = false -- 231
local getAllFiles -- 233
getAllFiles = function(path, exts, recursive) -- 233
	if recursive == nil then -- 233
		recursive = true -- 233
	end -- 233
	local filters = Set(exts) -- 234
	local files -- 235
	if recursive then -- 235
		files = Content:getAllFiles(path) -- 236
	else -- 238
		files = Content:getFiles(path) -- 238
	end -- 235
	local _accum_0 = { } -- 239
	local _len_0 = 1 -- 239
	for _index_0 = 1, #files do -- 239
		local file = files[_index_0] -- 239
		if not filters[Path:getExt(file)] then -- 240
			goto _continue_0 -- 240
		end -- 240
		_accum_0[_len_0] = file -- 241
		_len_0 = _len_0 + 1 -- 240
		::_continue_0:: -- 240
	end -- 241
	return _accum_0 -- 241
end -- 233
_module_0["getAllFiles"] = getAllFiles -- 241
local getFileEntries -- 243
getFileEntries = function(path, recursive, excludeFiles) -- 243
	if recursive == nil then -- 243
		recursive = true -- 243
	end -- 243
	if excludeFiles == nil then -- 243
		excludeFiles = nil -- 243
	end -- 243
	local entries = { } -- 244
	local excludes -- 245
	if excludeFiles then -- 245
		excludes = Set(excludeFiles) -- 246
	end -- 245
	local _list_0 = getAllFiles(path, { -- 247
		"lua", -- 247
		"xml", -- 247
		yueext, -- 247
		"tl" -- 247
	}, recursive) -- 247
	for _index_0 = 1, #_list_0 do -- 247
		local file = _list_0[_index_0] -- 247
		local entryName = Path:getName(file) -- 248
		if excludes and excludes[entryName] then -- 249
			goto _continue_0 -- 250
		end -- 249
		local entryAdded = false -- 251
		for _index_1 = 1, #entries do -- 252
			local _des_0 = entries[_index_1] -- 252
			local ename = _des_0[1] -- 252
			if entryName == ename then -- 253
				entryAdded = true -- 254
				break -- 255
			end -- 253
		end -- 255
		if entryAdded then -- 256
			goto _continue_0 -- 256
		end -- 256
		local fileName = Path:replaceExt(file, "") -- 257
		fileName = Path(path, fileName) -- 258
		local entry = { -- 259
			entryName, -- 259
			fileName -- 259
		} -- 259
		entries[#entries + 1] = entry -- 260
		::_continue_0:: -- 248
	end -- 260
	table.sort(entries, function(a, b) -- 261
		return a[1] < b[1] -- 261
	end) -- 261
	return entries -- 262
end -- 243
local getProjectEntries -- 264
getProjectEntries = function(path) -- 264
	local entries = { } -- 265
	local _list_0 = Content:getDirs(path) -- 266
	for _index_0 = 1, #_list_0 do -- 266
		local dir = _list_0[_index_0] -- 266
		if dir:match("^%.") then -- 267
			goto _continue_0 -- 267
		end -- 267
		local _list_1 = getAllFiles(Path(path, dir), { -- 268
			"lua", -- 268
			"xml", -- 268
			yueext, -- 268
			"tl", -- 268
			"wasm" -- 268
		}) -- 268
		for _index_1 = 1, #_list_1 do -- 268
			local file = _list_1[_index_1] -- 268
			if "init" == Path:getName(file):lower() then -- 269
				local fileName = Path:replaceExt(file, "") -- 270
				fileName = Path(path, dir, fileName) -- 271
				local entryName = Path:getName(Path:getPath(fileName)) -- 272
				local entryAdded = false -- 273
				for _index_2 = 1, #entries do -- 274
					local _des_0 = entries[_index_2] -- 274
					local ename = _des_0[1] -- 274
					if entryName == ename then -- 275
						entryAdded = true -- 276
						break -- 277
					end -- 275
				end -- 277
				if entryAdded then -- 278
					goto _continue_1 -- 278
				end -- 278
				local examples = { } -- 279
				local tests = { } -- 280
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 281
				if Content:exist(examplePath) then -- 282
					local _list_2 = getFileEntries(examplePath) -- 283
					for _index_2 = 1, #_list_2 do -- 283
						local _des_0 = _list_2[_index_2] -- 283
						local name, ePath = _des_0[1], _des_0[2] -- 283
						local entry = { -- 284
							name, -- 284
							Path(path, dir, Path:getPath(file), ePath) -- 284
						} -- 284
						examples[#examples + 1] = entry -- 285
					end -- 285
				end -- 282
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 286
				if Content:exist(testPath) then -- 287
					local _list_2 = getFileEntries(testPath) -- 288
					for _index_2 = 1, #_list_2 do -- 288
						local _des_0 = _list_2[_index_2] -- 288
						local name, tPath = _des_0[1], _des_0[2] -- 288
						local entry = { -- 289
							name, -- 289
							Path(path, dir, Path:getPath(file), tPath) -- 289
						} -- 289
						tests[#tests + 1] = entry -- 290
					end -- 290
				end -- 287
				local entry = { -- 291
					entryName, -- 291
					fileName, -- 291
					examples, -- 291
					tests -- 291
				} -- 291
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 292
				if not Content:exist(bannerFile) then -- 293
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 294
					if not Content:exist(bannerFile) then -- 295
						bannerFile = nil -- 295
					end -- 295
				end -- 293
				if bannerFile then -- 296
					thread(function() -- 296
						if Cache:loadAsync(bannerFile) then -- 297
							local bannerTex = Texture2D(bannerFile) -- 298
							if bannerTex then -- 299
								entry[#entry + 1] = bannerFile -- 300
								entry[#entry + 1] = bannerTex -- 301
							end -- 299
						end -- 297
					end) -- 296
				end -- 296
				entries[#entries + 1] = entry -- 302
			end -- 269
			::_continue_1:: -- 269
		end -- 302
		::_continue_0:: -- 267
	end -- 302
	table.sort(entries, function(a, b) -- 303
		return a[1] < b[1] -- 303
	end) -- 303
	return entries -- 304
end -- 264
local gamesInDev, games -- 306
local doraTools, doraExamples, doraTests -- 307
local cppTests, cppTestSet -- 308
local allEntries -- 309
local _anon_func_1 = function(App) -- 317
	if not App.debugging then -- 317
		return { -- 317
			"ImGui" -- 317
		} -- 317
	end -- 317
end -- 317
local updateEntries -- 311
updateEntries = function() -- 311
	gamesInDev = getProjectEntries(Content.writablePath) -- 312
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 313
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 315
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 316
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test"), true, _anon_func_1(App)) -- 317
	cppTests = { } -- 319
	local _list_0 = App.testNames -- 320
	for _index_0 = 1, #_list_0 do -- 320
		local name = _list_0[_index_0] -- 320
		local entry = { -- 321
			name -- 321
		} -- 321
		cppTests[#cppTests + 1] = entry -- 322
	end -- 322
	cppTestSet = Set(cppTests) -- 323
	allEntries = { } -- 325
	for _index_0 = 1, #gamesInDev do -- 326
		local game = gamesInDev[_index_0] -- 326
		allEntries[#allEntries + 1] = game -- 327
		local examples, tests = game[3], game[4] -- 328
		for _index_1 = 1, #examples do -- 329
			local example = examples[_index_1] -- 329
			allEntries[#allEntries + 1] = example -- 330
		end -- 330
		for _index_1 = 1, #tests do -- 331
			local test = tests[_index_1] -- 331
			allEntries[#allEntries + 1] = test -- 332
		end -- 332
	end -- 332
	for _index_0 = 1, #games do -- 333
		local game = games[_index_0] -- 333
		allEntries[#allEntries + 1] = game -- 334
		local examples, tests = game[3], game[4] -- 335
		for _index_1 = 1, #examples do -- 336
			local example = examples[_index_1] -- 336
			doraExamples[#doraExamples + 1] = example -- 337
		end -- 337
		for _index_1 = 1, #tests do -- 338
			local test = tests[_index_1] -- 338
			doraTests[#doraTests + 1] = test -- 339
		end -- 339
	end -- 339
	local _list_1 = { -- 341
		doraExamples, -- 341
		doraTests, -- 342
		cppTests -- 343
	} -- 340
	for _index_0 = 1, #_list_1 do -- 344
		local group = _list_1[_index_0] -- 340
		for _index_1 = 1, #group do -- 345
			local entry = group[_index_1] -- 345
			allEntries[#allEntries + 1] = entry -- 346
		end -- 346
	end -- 346
end -- 311
updateEntries() -- 348
local doCompile -- 350
doCompile = function(minify) -- 350
	if building then -- 351
		return -- 351
	end -- 351
	building = true -- 352
	local startTime = App.runningTime -- 353
	local luaFiles = { } -- 354
	local yueFiles = { } -- 355
	local xmlFiles = { } -- 356
	local tlFiles = { } -- 357
	local writablePath = Content.writablePath -- 358
	local buildPaths = { -- 360
		{ -- 361
			Content.assetPath, -- 361
			Path(writablePath, ".build"), -- 362
			"" -- 363
		} -- 360
	} -- 359
	for _index_0 = 1, #gamesInDev do -- 366
		local _des_0 = gamesInDev[_index_0] -- 366
		local entryFile = _des_0[2] -- 366
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 367
		buildPaths[#buildPaths + 1] = { -- 369
			Path(writablePath, gamePath), -- 369
			Path(writablePath, ".build", gamePath), -- 370
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 371
			gamePath -- 372
		} -- 368
	end -- 372
	for _index_0 = 1, #buildPaths do -- 373
		local _des_0 = buildPaths[_index_0] -- 373
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 373
		if not Content:exist(inputPath) then -- 374
			goto _continue_0 -- 374
		end -- 374
		local _list_0 = getAllFiles(inputPath, { -- 376
			"lua" -- 376
		}) -- 376
		for _index_1 = 1, #_list_0 do -- 376
			local file = _list_0[_index_1] -- 376
			luaFiles[#luaFiles + 1] = { -- 378
				file, -- 378
				Path(inputPath, file), -- 379
				Path(outputPath, file), -- 380
				gamePath -- 381
			} -- 377
		end -- 381
		local _list_1 = getAllFiles(inputPath, { -- 383
			yueext -- 383
		}) -- 383
		for _index_1 = 1, #_list_1 do -- 383
			local file = _list_1[_index_1] -- 383
			yueFiles[#yueFiles + 1] = { -- 385
				file, -- 385
				Path(inputPath, file), -- 386
				Path(outputPath, Path:replaceExt(file, "lua")), -- 387
				searchPath, -- 388
				gamePath -- 389
			} -- 384
		end -- 389
		local _list_2 = getAllFiles(inputPath, { -- 391
			"xml" -- 391
		}) -- 391
		for _index_1 = 1, #_list_2 do -- 391
			local file = _list_2[_index_1] -- 391
			xmlFiles[#xmlFiles + 1] = { -- 393
				file, -- 393
				Path(inputPath, file), -- 394
				Path(outputPath, Path:replaceExt(file, "lua")), -- 395
				gamePath -- 396
			} -- 392
		end -- 396
		local _list_3 = getAllFiles(inputPath, { -- 398
			"tl" -- 398
		}) -- 398
		for _index_1 = 1, #_list_3 do -- 398
			local file = _list_3[_index_1] -- 398
			if not file:match(".*%.d%.tl$") then -- 399
				tlFiles[#tlFiles + 1] = { -- 401
					file, -- 401
					Path(inputPath, file), -- 402
					Path(outputPath, Path:replaceExt(file, "lua")), -- 403
					searchPath, -- 404
					gamePath -- 405
				} -- 400
			end -- 399
		end -- 405
		::_continue_0:: -- 374
	end -- 405
	local paths -- 407
	do -- 407
		local _tbl_0 = { } -- 407
		local _list_0 = { -- 408
			luaFiles, -- 408
			yueFiles, -- 408
			xmlFiles, -- 408
			tlFiles -- 408
		} -- 408
		for _index_0 = 1, #_list_0 do -- 408
			local files = _list_0[_index_0] -- 408
			for _index_1 = 1, #files do -- 409
				local file = files[_index_1] -- 409
				_tbl_0[Path:getPath(file[3])] = true -- 407
			end -- 407
		end -- 407
		paths = _tbl_0 -- 407
	end -- 409
	for path in pairs(paths) do -- 411
		Content:mkdir(path) -- 411
	end -- 411
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 413
	local fileCount = 0 -- 414
	local errors = { } -- 415
	for _index_0 = 1, #yueFiles do -- 416
		local _des_0 = yueFiles[_index_0] -- 416
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 416
		local filename -- 417
		if gamePath then -- 417
			filename = Path(gamePath, file) -- 417
		else -- 417
			filename = file -- 417
		end -- 417
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 418
			if not codes then -- 419
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 420
				return -- 421
			end -- 419
			local success, result = LintYueGlobals(codes, globals) -- 422
			if success then -- 423
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 424
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 425
				codes = codes:gsub("^\n*", "") -- 426
				if not (result == "") then -- 427
					result = result .. "\n" -- 427
				end -- 427
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 428
			else -- 430
				local yueCodes = Content:load(input) -- 430
				if yueCodes then -- 430
					local globalErrors = { } -- 431
					for _index_1 = 1, #result do -- 432
						local _des_1 = result[_index_1] -- 432
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 432
						local countLine = 1 -- 433
						local code = "" -- 434
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 435
							if countLine == line then -- 436
								code = lineCode -- 437
								break -- 438
							end -- 436
							countLine = countLine + 1 -- 439
						end -- 439
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 440
					end -- 440
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 441
				else -- 443
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 443
				end -- 430
			end -- 423
		end, function(success) -- 418
			if success then -- 444
				print("Yue compiled: " .. tostring(filename)) -- 444
			end -- 444
			fileCount = fileCount + 1 -- 445
		end) -- 418
	end -- 445
	thread(function() -- 447
		for _index_0 = 1, #xmlFiles do -- 448
			local _des_0 = xmlFiles[_index_0] -- 448
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 448
			local filename -- 449
			if gamePath then -- 449
				filename = Path(gamePath, file) -- 449
			else -- 449
				filename = file -- 449
			end -- 449
			local sourceCodes = Content:loadAsync(input) -- 450
			local codes, err = xml.tolua(sourceCodes) -- 451
			if not codes then -- 452
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 453
			else -- 455
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 455
				print("Xml compiled: " .. tostring(filename)) -- 456
			end -- 452
			fileCount = fileCount + 1 -- 457
		end -- 457
	end) -- 447
	thread(function() -- 459
		for _index_0 = 1, #tlFiles do -- 460
			local _des_0 = tlFiles[_index_0] -- 460
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 460
			local filename -- 461
			if gamePath then -- 461
				filename = Path(gamePath, file) -- 461
			else -- 461
				filename = file -- 461
			end -- 461
			local sourceCodes = Content:loadAsync(input) -- 462
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 463
			if not codes then -- 464
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 465
			else -- 467
				Content:saveAsync(output, codes) -- 467
				print("Teal compiled: " .. tostring(filename)) -- 468
			end -- 464
			fileCount = fileCount + 1 -- 469
		end -- 469
	end) -- 459
	return thread(function() -- 471
		wait(function() -- 472
			return fileCount == totalFiles -- 472
		end) -- 472
		if minify then -- 473
			local _list_0 = { -- 474
				yueFiles, -- 474
				xmlFiles, -- 474
				tlFiles -- 474
			} -- 474
			for _index_0 = 1, #_list_0 do -- 474
				local files = _list_0[_index_0] -- 474
				for _index_1 = 1, #files do -- 474
					local file = files[_index_1] -- 474
					local output = Path:replaceExt(file[3], "lua") -- 475
					luaFiles[#luaFiles + 1] = { -- 477
						Path:replaceExt(file[1], "lua"), -- 477
						output, -- 478
						output -- 479
					} -- 476
				end -- 479
			end -- 479
			local FormatMini -- 481
			do -- 481
				local _obj_0 = require("luaminify") -- 481
				FormatMini = _obj_0.FormatMini -- 481
			end -- 481
			for _index_0 = 1, #luaFiles do -- 482
				local _des_0 = luaFiles[_index_0] -- 482
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 482
				if Content:exist(input) then -- 483
					local sourceCodes = Content:loadAsync(input) -- 484
					local res, err = FormatMini(sourceCodes) -- 485
					if res then -- 486
						Content:saveAsync(output, res) -- 487
						print("Minify: " .. tostring(file)) -- 488
					else -- 490
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 490
					end -- 486
				else -- 492
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 492
				end -- 483
			end -- 492
			package.loaded["luaminify.FormatMini"] = nil -- 493
			package.loaded["luaminify.ParseLua"] = nil -- 494
			package.loaded["luaminify.Scope"] = nil -- 495
			package.loaded["luaminify.Util"] = nil -- 496
		end -- 473
		local errorMessage = table.concat(errors, "\n") -- 497
		if errorMessage ~= "" then -- 498
			print(errorMessage) -- 498
		end -- 498
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 499
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 500
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 501
		Content:clearPathCache() -- 502
		teal.clear() -- 503
		yue.clear() -- 504
		building = false -- 505
	end) -- 505
end -- 350
local doClean -- 507
doClean = function() -- 507
	if building then -- 508
		return -- 508
	end -- 508
	local writablePath = Content.writablePath -- 509
	local targetDir = Path(writablePath, ".build") -- 510
	Content:clearPathCache() -- 511
	if Content:remove(targetDir) then -- 512
		return print("Cleaned: " .. tostring(targetDir)) -- 513
	end -- 512
end -- 507
local screenScale = 2.0 -- 515
local scaleContent = false -- 516
local isInEntry = true -- 517
local currentEntry = nil -- 518
local footerWindow = nil -- 520
local entryWindow = nil -- 521
local testingThread = nil -- 522
local setupEventHandlers = nil -- 524
local allClear -- 526
allClear = function() -- 526
	local _list_0 = Routine -- 527
	for _index_0 = 1, #_list_0 do -- 527
		local routine = _list_0[_index_0] -- 527
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 529
			goto _continue_0 -- 530
		else -- 532
			Routine:remove(routine) -- 532
		end -- 532
		::_continue_0:: -- 528
	end -- 532
	for _index_0 = 1, #moduleCache do -- 533
		local module = moduleCache[_index_0] -- 533
		package.loaded[module] = nil -- 534
	end -- 534
	moduleCache = { } -- 535
	Director:cleanup() -- 536
	Cache:unload() -- 537
	Entity:clear() -- 538
	Platformer.Data:clear() -- 539
	Platformer.UnitAction:clear() -- 540
	Audio:stopStream(0.5) -- 541
	Struct:clear() -- 542
	View.postEffect = nil -- 543
	View.scale = scaleContent and screenScale or 1 -- 544
	Director.clearColor = Color(0xff1a1a1a) -- 545
	teal.clear() -- 546
	yue.clear() -- 547
	for _, item in pairs(ubox()) do -- 548
		local node = tolua.cast(item, "Node") -- 549
		if node then -- 549
			node:cleanup() -- 549
		end -- 549
	end -- 549
	collectgarbage() -- 550
	collectgarbage() -- 551
	setupEventHandlers() -- 552
	Content.searchPaths = searchPaths -- 553
	App.idled = true -- 554
	return Wasm:clear() -- 555
end -- 526
_module_0["allClear"] = allClear -- 555
local clearTempFiles -- 557
clearTempFiles = function() -- 557
	local writablePath = Content.writablePath -- 558
	Content:remove(Path(writablePath, ".upload")) -- 559
	return Content:remove(Path(writablePath, ".download")) -- 560
end -- 557
local waitForWebStart = true -- 562
thread(function() -- 563
	sleep(2) -- 564
	waitForWebStart = false -- 565
end) -- 563
local reloadDevEntry -- 567
reloadDevEntry = function() -- 567
	return thread(function() -- 567
		waitForWebStart = true -- 568
		doClean() -- 569
		allClear() -- 570
		_G.require = oldRequire -- 571
		Dora.require = oldRequire -- 572
		package.loaded["Script.Dev.Entry"] = nil -- 573
		return Director.systemScheduler:schedule(function() -- 574
			Routine:clear() -- 575
			oldRequire("Script.Dev.Entry") -- 576
			return true -- 577
		end) -- 577
	end) -- 577
end -- 567
local setWorkspace -- 579
setWorkspace = function(path) -- 579
	Content.writablePath = path -- 580
	config.writablePath = Content.writablePath -- 581
	return thread(function() -- 582
		sleep() -- 583
		return reloadDevEntry() -- 584
	end) -- 584
end -- 579
local _anon_func_2 = function(App, _with_0) -- 599
	local _val_0 = App.platform -- 599
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 599
end -- 599
setupEventHandlers = function() -- 586
	local _with_0 = Director.postNode -- 587
	_with_0:onAppEvent(function(eventType) -- 588
		if eventType == "Quit" then -- 588
			allClear() -- 589
			return clearTempFiles() -- 590
		end -- 588
	end) -- 588
	_with_0:onAppChange(function(settingName) -- 591
		if "Theme" == settingName then -- 592
			config.themeColor = App.themeColor:toARGB() -- 593
		elseif "Locale" == settingName then -- 594
			config.locale = App.locale -- 595
			updateLocale() -- 596
			return teal.clear(true) -- 597
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 598
			if _anon_func_2(App, _with_0) then -- 599
				if "FullScreen" == settingName then -- 601
					config.fullScreen = App.fullScreen -- 601
				elseif "Position" == settingName then -- 602
					local _obj_0 = App.winPosition -- 602
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 602
				elseif "Size" == settingName then -- 603
					local width, height -- 604
					do -- 604
						local _obj_0 = App.winSize -- 604
						width, height = _obj_0.width, _obj_0.height -- 604
					end -- 604
					config.winWidth = width -- 605
					config.winHeight = height -- 606
				end -- 606
			end -- 599
		end -- 606
	end) -- 591
	_with_0:onAppWS(function(eventType) -- 607
		if eventType == "Close" then -- 607
			if HttpServer.wsConnectionCount == 0 then -- 608
				return updateEntries() -- 609
			end -- 608
		end -- 607
	end) -- 607
	return _with_0 -- 587
end -- 586
setupEventHandlers() -- 611
clearTempFiles() -- 612
local stop -- 614
stop = function() -- 614
	if isInEntry then -- 615
		return false -- 615
	end -- 615
	allClear() -- 616
	isInEntry = true -- 617
	currentEntry = nil -- 618
	return true -- 619
end -- 614
_module_0["stop"] = stop -- 619
local _anon_func_3 = function(Content, Path, file, require, type) -- 641
	local scriptPath = Path:getPath(file) -- 634
	Content:insertSearchPath(1, scriptPath) -- 635
	scriptPath = Path(scriptPath, "Script") -- 636
	if Content:exist(scriptPath) then -- 637
		Content:insertSearchPath(1, scriptPath) -- 638
	end -- 637
	local result = require(file) -- 639
	if "function" == type(result) then -- 640
		result() -- 640
	end -- 640
	return nil -- 641
end -- 634
local _anon_func_4 = function(Label, _with_0, err, fontSize, width) -- 673
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 670
	label.alignment = "Left" -- 671
	label.textWidth = width - fontSize -- 672
	label.text = err -- 673
	return label -- 670
end -- 670
local enterEntryAsync -- 621
enterEntryAsync = function(entry) -- 621
	isInEntry = false -- 622
	App.idled = false -- 623
	emit(Profiler.EventName, "ClearLoader") -- 624
	currentEntry = entry -- 625
	local name, file = entry[1], entry[2] -- 626
	if cppTestSet[entry] then -- 627
		if App:runTest(name) then -- 628
			return true -- 629
		else -- 631
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 631
		end -- 628
	end -- 627
	sleep() -- 632
	return xpcall(_anon_func_3, function(msg) -- 674
		local err = debug.traceback(msg) -- 643
		Log("Error", err) -- 644
		allClear() -- 645
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 646
		local viewWidth, viewHeight -- 647
		do -- 647
			local _obj_0 = View.size -- 647
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 647
		end -- 647
		local width, height = viewWidth - 20, viewHeight - 20 -- 648
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 649
		Director.ui:addChild((function() -- 650
			local root = AlignNode() -- 650
			do -- 651
				local _obj_0 = App.bufferSize -- 651
				width, height = _obj_0.width, _obj_0.height -- 651
			end -- 651
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 652
			root:onAppChange(function(settingName) -- 653
				if settingName == "Size" then -- 653
					do -- 654
						local _obj_0 = App.bufferSize -- 654
						width, height = _obj_0.width, _obj_0.height -- 654
					end -- 654
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 655
				end -- 653
			end) -- 653
			root:addChild((function() -- 656
				local _with_0 = ScrollArea({ -- 657
					width = width, -- 657
					height = height, -- 658
					paddingX = 0, -- 659
					paddingY = 50, -- 660
					viewWidth = height, -- 661
					viewHeight = height -- 662
				}) -- 656
				root:onAlignLayout(function(w, h) -- 664
					_with_0.position = Vec2(w / 2, h / 2) -- 665
					w = w - 20 -- 666
					h = h - 20 -- 667
					_with_0.view.children.first.textWidth = w - fontSize -- 668
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 669
				end) -- 664
				_with_0.view:addChild(_anon_func_4(Label, _with_0, err, fontSize, width)) -- 670
				return _with_0 -- 656
			end)()) -- 656
			return root -- 650
		end)()) -- 650
		return err -- 674
	end, Content, Path, file, require, type) -- 674
end -- 621
_module_0["enterEntryAsync"] = enterEntryAsync -- 674
local enterDemoEntry -- 676
enterDemoEntry = function(entry) -- 676
	return thread(function() -- 676
		return enterEntryAsync(entry) -- 676
	end) -- 676
end -- 676
local reloadCurrentEntry -- 678
reloadCurrentEntry = function() -- 678
	if currentEntry then -- 679
		allClear() -- 680
		return enterDemoEntry(currentEntry) -- 681
	end -- 679
end -- 678
Director.clearColor = Color(0xff1a1a1a) -- 683
local isOSSLicenseExist = Content:exist("LICENSES") -- 685
local ossLicenses = nil -- 686
local ossLicenseOpen = false -- 687
local extraOperations -- 689
extraOperations = function() -- 689
	local zh = useChinese and isChineseSupported -- 690
	if isDesktop then -- 691
		local themeColor = App.themeColor -- 692
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 693
		do -- 694
			local changed -- 694
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 694
			if changed then -- 694
				App.alwaysOnTop = alwaysOnTop -- 695
				config.alwaysOnTop = alwaysOnTop -- 696
			end -- 694
		end -- 694
		SeparatorText(zh and "工作目录" or "Workspace") -- 697
		PushTextWrapPos(400, function() -- 698
			return TextColored(themeColor, writablePath) -- 699
		end) -- 698
		if Button(zh and "改变目录" or "Set Folder") then -- 700
			App:openFileDialog(true, function(path) -- 701
				if path ~= "" then -- 702
					return setWorkspace(path) -- 702
				end -- 702
			end) -- 701
		end -- 700
		SameLine() -- 703
		if Button(zh and "使用默认" or "Use Default") then -- 704
			setWorkspace(Content.appPath) -- 705
		end -- 704
		Separator() -- 706
	end -- 691
	if isOSSLicenseExist then -- 707
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 708
			if not ossLicenses then -- 709
				ossLicenses = { } -- 710
				local licenseText = Content:load("LICENSES") -- 711
				ossLicenseOpen = (licenseText ~= nil) -- 712
				if ossLicenseOpen then -- 712
					licenseText = licenseText:gsub("\r\n", "\n") -- 713
					for license in GSplit(licenseText, "\n--------\n", true) do -- 714
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 715
						if name then -- 715
							ossLicenses[#ossLicenses + 1] = { -- 716
								name, -- 716
								text -- 716
							} -- 716
						end -- 715
					end -- 716
				end -- 712
			else -- 718
				ossLicenseOpen = true -- 718
			end -- 709
		end -- 708
		if ossLicenseOpen then -- 719
			local width, height, themeColor -- 720
			do -- 720
				local _obj_0 = App -- 720
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 720
			end -- 720
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 721
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 722
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 723
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 726
					"NoSavedSettings" -- 726
				}, function() -- 727
					for _index_0 = 1, #ossLicenses do -- 727
						local _des_0 = ossLicenses[_index_0] -- 727
						local firstLine, text = _des_0[1], _des_0[2] -- 727
						local name, license = firstLine:match("(.+): (.+)") -- 728
						TextColored(themeColor, name) -- 729
						SameLine() -- 730
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 731
							return TextWrapped(text) -- 731
						end) -- 731
					end -- 731
				end) -- 723
			end) -- 723
		end -- 719
	end -- 707
	if not App.debugging then -- 733
		return -- 733
	end -- 733
	return TreeNode(zh and "开发操作" or "Development", function() -- 734
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 735
			OpenPopup("build") -- 735
		end -- 735
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 736
			return BeginPopup("build", function() -- 736
				if Selectable(zh and "编译" or "Compile") then -- 737
					doCompile(false) -- 737
				end -- 737
				Separator() -- 738
				if Selectable(zh and "压缩" or "Minify") then -- 739
					doCompile(true) -- 739
				end -- 739
				Separator() -- 740
				if Selectable(zh and "清理" or "Clean") then -- 741
					return doClean() -- 741
				end -- 741
			end) -- 741
		end) -- 736
		if isInEntry then -- 742
			if waitForWebStart then -- 743
				BeginDisabled(function() -- 744
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 744
				end) -- 744
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 745
				reloadDevEntry() -- 746
			end -- 743
		end -- 742
		do -- 747
			local changed -- 747
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 747
			if changed then -- 747
				View.scale = scaleContent and screenScale or 1 -- 748
			end -- 747
		end -- 747
		do -- 749
			local changed -- 749
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 749
			if changed then -- 749
				config.engineDev = engineDev -- 750
			end -- 749
		end -- 749
		if Button(zh and "开始自动测试" or "Test automatically") then -- 751
			testingThread = thread(function() -- 752
				local _ <close> = setmetatable({ }, { -- 753
					__close = function() -- 753
						allClear() -- 754
						testingThread = nil -- 755
						isInEntry = true -- 756
						currentEntry = nil -- 757
						return print("Testing done!") -- 758
					end -- 753
				}) -- 753
				for _, entry in ipairs(allEntries) do -- 759
					allClear() -- 760
					print("Start " .. tostring(entry[1])) -- 761
					enterDemoEntry(entry) -- 762
					sleep(2) -- 763
					print("Stop " .. tostring(entry[1])) -- 764
				end -- 764
			end) -- 752
		end -- 751
	end) -- 734
end -- 689
local transparant = Color(0x0) -- 766
local windowFlags = { -- 767
	"NoTitleBar", -- 767
	"NoResize", -- 767
	"NoMove", -- 767
	"NoCollapse", -- 767
	"NoSavedSettings", -- 767
	"NoBringToFrontOnFocus" -- 767
} -- 767
local initFooter = true -- 775
local _anon_func_5 = function(allEntries, currentIndex) -- 811
	if currentIndex > 1 then -- 811
		return allEntries[currentIndex - 1] -- 812
	else -- 814
		return allEntries[#allEntries] -- 814
	end -- 811
end -- 811
local _anon_func_6 = function(allEntries, currentIndex) -- 818
	if currentIndex < #allEntries then -- 818
		return allEntries[currentIndex + 1] -- 819
	else -- 821
		return allEntries[1] -- 821
	end -- 818
end -- 818
footerWindow = threadLoop(function() -- 776
	local zh = useChinese and isChineseSupported -- 777
	if HttpServer.wsConnectionCount > 0 then -- 778
		return -- 779
	end -- 778
	if Keyboard:isKeyDown("Escape") then -- 780
		allClear() -- 781
		App:shutdown() -- 782
	end -- 780
	do -- 783
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 784
		if ctrl and Keyboard:isKeyDown("Q") then -- 785
			stop() -- 786
		end -- 785
		if ctrl and Keyboard:isKeyDown("Z") then -- 787
			reloadCurrentEntry() -- 788
		end -- 787
		if ctrl and Keyboard:isKeyDown(",") then -- 789
			if showFooter then -- 790
				showStats = not showStats -- 790
			else -- 790
				showStats = true -- 790
			end -- 790
			showFooter = true -- 791
			config.showFooter = showFooter -- 792
			config.showStats = showStats -- 793
		end -- 789
		if ctrl and Keyboard:isKeyDown(".") then -- 794
			if showFooter then -- 795
				showConsole = not showConsole -- 795
			else -- 795
				showConsole = true -- 795
			end -- 795
			showFooter = true -- 796
			config.showFooter = showFooter -- 797
			config.showConsole = showConsole -- 798
		end -- 794
		if ctrl and Keyboard:isKeyDown("/") then -- 799
			showFooter = not showFooter -- 800
			config.showFooter = showFooter -- 801
		end -- 799
		local left = ctrl and Keyboard:isKeyDown("Left") -- 802
		local right = ctrl and Keyboard:isKeyDown("Right") -- 803
		local currentIndex = nil -- 804
		for i, entry in ipairs(allEntries) do -- 805
			if currentEntry == entry then -- 806
				currentIndex = i -- 807
			end -- 806
		end -- 807
		if left then -- 808
			allClear() -- 809
			if currentIndex == nil then -- 810
				currentIndex = #allEntries + 1 -- 810
			end -- 810
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 811
		end -- 808
		if right then -- 815
			allClear() -- 816
			if currentIndex == nil then -- 817
				currentIndex = 0 -- 817
			end -- 817
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 818
		end -- 815
	end -- 821
	if not showEntry then -- 822
		return -- 822
	end -- 822
	local width, height -- 824
	do -- 824
		local _obj_0 = App.visualSize -- 824
		width, height = _obj_0.width, _obj_0.height -- 824
	end -- 824
	SetNextWindowSize(Vec2(50, 50)) -- 825
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 826
	PushStyleColor("WindowBg", transparant, function() -- 827
		return Begin("Show", windowFlags, function() -- 827
			if isInEntry or width >= 540 then -- 828
				local changed -- 829
				changed, showFooter = Checkbox("##dev", showFooter) -- 829
				if changed then -- 829
					config.showFooter = showFooter -- 830
				end -- 829
			end -- 828
		end) -- 830
	end) -- 827
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 832
		reloadDevEntry() -- 836
	end -- 832
	if initFooter then -- 837
		initFooter = false -- 838
	else -- 840
		if not showFooter then -- 840
			return -- 840
		end -- 840
	end -- 837
	SetNextWindowSize(Vec2(width, 50)) -- 842
	SetNextWindowPos(Vec2(0, height - 50)) -- 843
	SetNextWindowBgAlpha(0.35) -- 844
	do -- 845
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 846
			return Begin("Footer", windowFlags, function() -- 847
				Dummy(Vec2(width - 20, 0)) -- 848
				do -- 849
					local changed -- 849
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 849
					if changed then -- 849
						config.showStats = showStats -- 850
					end -- 849
				end -- 849
				SameLine() -- 851
				do -- 852
					local changed -- 852
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 852
					if changed then -- 852
						config.showConsole = showConsole -- 853
					end -- 852
				end -- 852
				if config.updateNotification then -- 854
					SameLine() -- 855
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 856
						allClear() -- 857
						config.updateNotification = false -- 858
						enterDemoEntry({ -- 859
							"SelfUpdater", -- 859
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 859
						}) -- 859
					end -- 856
				end -- 854
				if not isInEntry then -- 860
					SameLine() -- 861
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 862
					local currentIndex = nil -- 863
					for i, entry in ipairs(allEntries) do -- 864
						if currentEntry == entry then -- 865
							currentIndex = i -- 866
						end -- 865
					end -- 866
					if currentIndex then -- 867
						if currentIndex > 1 then -- 868
							SameLine() -- 869
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 870
								allClear() -- 871
								enterDemoEntry(allEntries[currentIndex - 1]) -- 872
							end -- 870
						end -- 868
						if currentIndex < #allEntries then -- 873
							SameLine() -- 874
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 875
								allClear() -- 876
								enterDemoEntry(allEntries[currentIndex + 1]) -- 877
							end -- 875
						end -- 873
					end -- 867
					SameLine() -- 878
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 879
						reloadCurrentEntry() -- 880
					end -- 879
					if back then -- 881
						allClear() -- 882
						isInEntry = true -- 883
						currentEntry = nil -- 884
					end -- 881
				end -- 860
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 885
					if showStats then -- 886
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 887
						showStats = ShowStats(showStats, extraOperations) -- 888
						config.showStats = showStats -- 889
					end -- 886
					if showConsole then -- 890
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 891
						showConsole = ShowConsole(showConsole) -- 892
						config.showConsole = showConsole -- 893
					end -- 890
				end) -- 885
			end) -- 847
		end) -- 846
	end -- 893
end) -- 776
local MaxWidth <const> = 800 -- 895
local displayWindowFlags = { -- 897
	"NoDecoration", -- 897
	"NoSavedSettings", -- 897
	"NoFocusOnAppearing", -- 897
	"NoNav", -- 897
	"NoMove", -- 897
	"NoScrollWithMouse", -- 897
	"AlwaysAutoResize", -- 897
	"NoBringToFrontOnFocus" -- 897
} -- 897
local webStatus = nil -- 908
local descColor = Color(0xffa1a1a1) -- 909
local gameOpen = #gamesInDev == 0 -- 910
local toolOpen = false -- 911
local exampleOpen = false -- 912
local testOpen = false -- 913
local filterText = nil -- 914
local anyEntryMatched = false -- 915
local urlClicked = nil -- 916
local match -- 917
match = function(name) -- 917
	local res = not filterText or name:lower():match(filterText) -- 918
	if res then -- 919
		anyEntryMatched = true -- 919
	end -- 919
	return res -- 920
end -- 917
local iconTex = nil -- 921
thread(function() -- 922
	if Cache:loadAsync("Image/icon_s.png") then -- 922
		iconTex = Texture2D("Image/icon_s.png") -- 923
	end -- 922
end) -- 922
entryWindow = threadLoop(function() -- 925
	if App.fpsLimited ~= config.fpsLimited then -- 926
		config.fpsLimited = App.fpsLimited -- 927
	end -- 926
	if App.targetFPS ~= config.targetFPS then -- 928
		config.targetFPS = App.targetFPS -- 929
	end -- 928
	if View.vsync ~= config.vsync then -- 930
		config.vsync = View.vsync -- 931
	end -- 930
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 932
		config.fixedFPS = Director.scheduler.fixedFPS -- 933
	end -- 932
	if Director.profilerSending ~= config.webProfiler then -- 934
		config.webProfiler = Director.profilerSending -- 935
	end -- 934
	if urlClicked then -- 936
		local _, result = coroutine.resume(urlClicked) -- 937
		if result then -- 938
			coroutine.close(urlClicked) -- 939
			urlClicked = nil -- 940
		end -- 938
	end -- 936
	if not showEntry then -- 941
		return -- 941
	end -- 941
	if not isInEntry then -- 942
		return -- 942
	end -- 942
	local zh = useChinese and isChineseSupported -- 943
	if HttpServer.wsConnectionCount > 0 then -- 944
		local themeColor = App.themeColor -- 945
		local width, height -- 946
		do -- 946
			local _obj_0 = App.visualSize -- 946
			width, height = _obj_0.width, _obj_0.height -- 946
		end -- 946
		SetNextWindowBgAlpha(0.5) -- 947
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 948
		Begin("Web IDE Connected", displayWindowFlags, function() -- 949
			Separator() -- 950
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 951
			if iconTex then -- 952
				Image("Image/icon_s.png", Vec2(24, 24)) -- 953
				SameLine() -- 954
			end -- 952
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 955
			TextColored(descColor, slogon) -- 956
			return Separator() -- 957
		end) -- 949
		return -- 958
	end -- 944
	local themeColor = App.themeColor -- 960
	local fullWidth, height -- 961
	do -- 961
		local _obj_0 = App.visualSize -- 961
		fullWidth, height = _obj_0.width, _obj_0.height -- 961
	end -- 961
	SetNextWindowBgAlpha(0.85) -- 963
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 964
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 965
		return Begin("Web IDE", displayWindowFlags, function() -- 966
			Separator() -- 967
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 968
			SameLine() -- 969
			TextDisabled('(?)') -- 970
			if IsItemHovered() then -- 971
				BeginTooltip(function() -- 972
					return PushTextWrapPos(280, function() -- 973
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 974
					end) -- 974
				end) -- 972
			end -- 971
			do -- 975
				local url -- 975
				if webStatus ~= nil then -- 975
					url = webStatus.url -- 975
				end -- 975
				if url then -- 975
					if isDesktop and not config.fullScreen then -- 976
						if urlClicked then -- 977
							BeginDisabled(function() -- 978
								return Button(url) -- 978
							end) -- 978
						elseif Button(url) then -- 979
							urlClicked = once(function() -- 980
								return sleep(5) -- 980
							end) -- 980
							App:openURL("http://localhost:8866") -- 981
						end -- 977
					else -- 983
						TextColored(descColor, url) -- 983
					end -- 976
				else -- 985
					TextColored(descColor, zh and '不可用' or 'not available') -- 985
				end -- 975
			end -- 975
			return Separator() -- 986
		end) -- 986
	end) -- 965
	local width = math.min(MaxWidth, fullWidth) -- 988
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 989
	local maxColumns = math.max(math.floor(width / 200), 1) -- 990
	SetNextWindowPos(Vec2.zero) -- 991
	SetNextWindowBgAlpha(0) -- 992
	do -- 993
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 994
			return Begin("Dora Dev", displayWindowFlags, function() -- 995
				Dummy(Vec2(fullWidth - 20, 0)) -- 996
				if iconTex then -- 997
					Image("Image/icon_s.png", Vec2(24, 24)) -- 998
					SameLine() -- 999
				end -- 997
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 1000
				if fullWidth >= 320 then -- 1001
					SameLine() -- 1002
					Dummy(Vec2(fullWidth - 320, 0)) -- 1003
					SameLine() -- 1004
					SetNextItemWidth(-30) -- 1005
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1006
						"AutoSelectAll" -- 1006
					}) then -- 1006
						config.filter = filterBuf.text -- 1007
					end -- 1006
				end -- 1001
				Separator() -- 1008
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1009
			end) -- 995
		end) -- 994
	end -- 1009
	anyEntryMatched = false -- 1011
	SetNextWindowPos(Vec2(0, 50)) -- 1012
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1013
	do -- 1014
		return PushStyleColor("WindowBg", transparant, function() -- 1015
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1016
				return Begin("Content", windowFlags, function() -- 1017
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 1018
					if filterText then -- 1019
						filterText = filterText:lower() -- 1019
					end -- 1019
					if #gamesInDev > 0 then -- 1020
						for _index_0 = 1, #gamesInDev do -- 1021
							local game = gamesInDev[_index_0] -- 1021
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1022
							local showSep = false -- 1023
							if match(gameName) then -- 1024
								Columns(1, false) -- 1025
								TextColored(themeColor, zh and "项目：" or "Project:") -- 1026
								SameLine() -- 1027
								Text(gameName) -- 1028
								Separator() -- 1029
								if bannerFile then -- 1030
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1031
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1032
									local sizing <const> = 0.8 -- 1033
									texHeight = displayWidth * sizing * texHeight / texWidth -- 1034
									texWidth = displayWidth * sizing -- 1035
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1036
									Dummy(Vec2(padding, 0)) -- 1037
									SameLine() -- 1038
									PushID(fileName, function() -- 1039
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1040
											return enterDemoEntry(game) -- 1041
										end -- 1040
									end) -- 1039
								else -- 1043
									PushID(fileName, function() -- 1043
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 1044
											return enterDemoEntry(game) -- 1045
										end -- 1044
									end) -- 1043
								end -- 1030
								NextColumn() -- 1046
								showSep = true -- 1047
							end -- 1024
							if #examples > 0 then -- 1048
								local showExample = false -- 1049
								for _index_1 = 1, #examples do -- 1050
									local example = examples[_index_1] -- 1050
									if match(example[1]) then -- 1051
										showExample = true -- 1052
										break -- 1053
									end -- 1051
								end -- 1053
								if showExample then -- 1054
									Columns(1, false) -- 1055
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1056
									SameLine() -- 1057
									Text(gameName) -- 1058
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1059
										Columns(maxColumns, false) -- 1060
										for _index_1 = 1, #examples do -- 1061
											local example = examples[_index_1] -- 1061
											if not match(example[1]) then -- 1062
												goto _continue_0 -- 1062
											end -- 1062
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1063
												if Button(example[1], Vec2(-1, 40)) then -- 1064
													enterDemoEntry(example) -- 1065
												end -- 1064
												return NextColumn() -- 1066
											end) -- 1063
											showSep = true -- 1067
											::_continue_0:: -- 1062
										end -- 1067
									end) -- 1059
								end -- 1054
							end -- 1048
							if #tests > 0 then -- 1068
								local showTest = false -- 1069
								for _index_1 = 1, #tests do -- 1070
									local test = tests[_index_1] -- 1070
									if match(test[1]) then -- 1071
										showTest = true -- 1072
										break -- 1073
									end -- 1071
								end -- 1073
								if showTest then -- 1074
									Columns(1, false) -- 1075
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1076
									SameLine() -- 1077
									Text(gameName) -- 1078
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1079
										Columns(maxColumns, false) -- 1080
										for _index_1 = 1, #tests do -- 1081
											local test = tests[_index_1] -- 1081
											if not match(test[1]) then -- 1082
												goto _continue_0 -- 1082
											end -- 1082
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1083
												if Button(test[1], Vec2(-1, 40)) then -- 1084
													enterDemoEntry(test) -- 1085
												end -- 1084
												return NextColumn() -- 1086
											end) -- 1083
											showSep = true -- 1087
											::_continue_0:: -- 1082
										end -- 1087
									end) -- 1079
								end -- 1074
							end -- 1068
							if showSep then -- 1088
								Columns(1, false) -- 1089
								Separator() -- 1090
							end -- 1088
						end -- 1090
					end -- 1020
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1091
						local showGame = false -- 1092
						for _index_0 = 1, #games do -- 1093
							local _des_0 = games[_index_0] -- 1093
							local name = _des_0[1] -- 1093
							if match(name) then -- 1094
								showGame = true -- 1094
							end -- 1094
						end -- 1094
						local showTool = false -- 1095
						for _index_0 = 1, #doraTools do -- 1096
							local _des_0 = doraTools[_index_0] -- 1096
							local name = _des_0[1] -- 1096
							if match(name) then -- 1097
								showTool = true -- 1097
							end -- 1097
						end -- 1097
						local showExample = false -- 1098
						for _index_0 = 1, #doraExamples do -- 1099
							local _des_0 = doraExamples[_index_0] -- 1099
							local name = _des_0[1] -- 1099
							if match(name) then -- 1100
								showExample = true -- 1100
							end -- 1100
						end -- 1100
						local showTest = false -- 1101
						for _index_0 = 1, #doraTests do -- 1102
							local _des_0 = doraTests[_index_0] -- 1102
							local name = _des_0[1] -- 1102
							if match(name) then -- 1103
								showTest = true -- 1103
							end -- 1103
						end -- 1103
						for _index_0 = 1, #cppTests do -- 1104
							local _des_0 = cppTests[_index_0] -- 1104
							local name = _des_0[1] -- 1104
							if match(name) then -- 1105
								showTest = true -- 1105
							end -- 1105
						end -- 1105
						if not (showGame or showTool or showExample or showTest) then -- 1106
							goto endEntry -- 1106
						end -- 1106
						Columns(1, false) -- 1107
						TextColored(themeColor, "Dora SSR:") -- 1108
						SameLine() -- 1109
						Text(zh and "开发示例" or "Development Showcase") -- 1110
						Separator() -- 1111
						local demoViewWith <const> = 400 -- 1112
						if #games > 0 and showGame then -- 1113
							local opened -- 1114
							if (filterText ~= nil) then -- 1114
								opened = showGame -- 1114
							else -- 1114
								opened = false -- 1114
							end -- 1114
							SetNextItemOpen(gameOpen) -- 1115
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1116
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1117
								Columns(columns, false) -- 1118
								for _index_0 = 1, #games do -- 1119
									local game = games[_index_0] -- 1119
									if not match(game[1]) then -- 1120
										goto _continue_0 -- 1120
									end -- 1120
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1121
									if columns > 1 then -- 1122
										if bannerFile then -- 1123
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1124
											local displayWidth <const> = demoViewWith - 40 -- 1125
											texHeight = displayWidth * texHeight / texWidth -- 1126
											texWidth = displayWidth -- 1127
											Text(gameName) -- 1128
											PushID(fileName, function() -- 1129
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1130
													return enterDemoEntry(game) -- 1131
												end -- 1130
											end) -- 1129
										else -- 1133
											PushID(fileName, function() -- 1133
												if Button(gameName, Vec2(-1, 40)) then -- 1134
													return enterDemoEntry(game) -- 1135
												end -- 1134
											end) -- 1133
										end -- 1123
									else -- 1137
										if bannerFile then -- 1137
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1138
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1139
											local sizing = 0.8 -- 1140
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1141
											texWidth = displayWidth * sizing -- 1142
											if texWidth > 500 then -- 1143
												sizing = 0.6 -- 1144
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1145
												texWidth = displayWidth * sizing -- 1146
											end -- 1143
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1147
											Dummy(Vec2(padding, 0)) -- 1148
											SameLine() -- 1149
											Text(gameName) -- 1150
											Dummy(Vec2(padding, 0)) -- 1151
											SameLine() -- 1152
											PushID(fileName, function() -- 1153
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1154
													return enterDemoEntry(game) -- 1155
												end -- 1154
											end) -- 1153
										else -- 1157
											PushID(fileName, function() -- 1157
												if Button(gameName, Vec2(-1, 40)) then -- 1158
													return enterDemoEntry(game) -- 1159
												end -- 1158
											end) -- 1157
										end -- 1137
									end -- 1122
									NextColumn() -- 1160
									::_continue_0:: -- 1120
								end -- 1160
								Columns(1, false) -- 1161
								opened = true -- 1162
							end) -- 1116
							gameOpen = opened -- 1163
						end -- 1113
						if #doraTools > 0 and showTool then -- 1164
							local opened -- 1165
							if (filterText ~= nil) then -- 1165
								opened = showTool -- 1165
							else -- 1165
								opened = false -- 1165
							end -- 1165
							SetNextItemOpen(toolOpen) -- 1166
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1167
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1168
									Columns(maxColumns, false) -- 1169
									for _index_0 = 1, #doraTools do -- 1170
										local example = doraTools[_index_0] -- 1170
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
							toolOpen = opened -- 1177
						end -- 1164
						if #doraExamples > 0 and showExample then -- 1178
							local opened -- 1179
							if (filterText ~= nil) then -- 1179
								opened = showExample -- 1179
							else -- 1179
								opened = false -- 1179
							end -- 1179
							SetNextItemOpen(exampleOpen) -- 1180
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1181
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1182
									Columns(maxColumns, false) -- 1183
									for _index_0 = 1, #doraExamples do -- 1184
										local example = doraExamples[_index_0] -- 1184
										if not match(example[1]) then -- 1185
											goto _continue_0 -- 1185
										end -- 1185
										if Button(example[1], Vec2(-1, 40)) then -- 1186
											enterDemoEntry(example) -- 1187
										end -- 1186
										NextColumn() -- 1188
										::_continue_0:: -- 1185
									end -- 1188
									Columns(1, false) -- 1189
									opened = true -- 1190
								end) -- 1182
							end) -- 1181
							exampleOpen = opened -- 1191
						end -- 1178
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1192
							local opened -- 1193
							if (filterText ~= nil) then -- 1193
								opened = showTest -- 1193
							else -- 1193
								opened = false -- 1193
							end -- 1193
							SetNextItemOpen(testOpen) -- 1194
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1195
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1196
									Columns(maxColumns, false) -- 1197
									for _index_0 = 1, #doraTests do -- 1198
										local test = doraTests[_index_0] -- 1198
										if not match(test[1]) then -- 1199
											goto _continue_0 -- 1199
										end -- 1199
										if Button(test[1], Vec2(-1, 40)) then -- 1200
											enterDemoEntry(test) -- 1201
										end -- 1200
										NextColumn() -- 1202
										::_continue_0:: -- 1199
									end -- 1202
									for _index_0 = 1, #cppTests do -- 1203
										local test = cppTests[_index_0] -- 1203
										if not match(test[1]) then -- 1204
											goto _continue_1 -- 1204
										end -- 1204
										if Button(test[1], Vec2(-1, 40)) then -- 1205
											enterDemoEntry(test) -- 1206
										end -- 1205
										NextColumn() -- 1207
										::_continue_1:: -- 1204
									end -- 1207
									opened = true -- 1208
								end) -- 1196
							end) -- 1195
							testOpen = opened -- 1209
						end -- 1192
					end -- 1091
					::endEntry:: -- 1210
					if not anyEntryMatched then -- 1211
						SetNextWindowBgAlpha(0) -- 1212
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1213
						Begin("Entries Not Found", displayWindowFlags, function() -- 1214
							Separator() -- 1215
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1216
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1217
							return Separator() -- 1218
						end) -- 1214
					end -- 1211
					Columns(1, false) -- 1219
					Dummy(Vec2(100, 80)) -- 1220
					return ScrollWhenDraggingOnVoid() -- 1221
				end) -- 1017
			end) -- 1016
		end) -- 1015
	end -- 1221
end) -- 925
webStatus = require("Script.Dev.WebServer") -- 1223
return _module_0 -- 1223
