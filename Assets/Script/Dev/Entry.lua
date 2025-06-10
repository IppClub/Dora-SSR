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
		local fileName = Path:replaceExt(file, "") -- 251
		fileName = Path(path, fileName) -- 252
		local entryAdded -- 253
		do -- 253
			local _accum_0 -- 253
			for _index_1 = 1, #entries do -- 253
				local _des_0 = entries[_index_1] -- 253
				local ename, efile = _des_0[1], _des_0[2] -- 253
				if entryName == ename and efile == fileName then -- 254
					_accum_0 = true -- 254
					break -- 254
				end -- 254
			end -- 254
			entryAdded = _accum_0 -- 253
		end -- 254
		if entryAdded then -- 255
			goto _continue_0 -- 255
		end -- 255
		local entry = { -- 256
			entryName, -- 256
			fileName -- 256
		} -- 256
		entries[#entries + 1] = entry -- 257
		::_continue_0:: -- 248
	end -- 257
	table.sort(entries, function(a, b) -- 258
		return a[1] < b[1] -- 258
	end) -- 258
	return entries -- 259
end -- 243
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
				local entryAdded -- 270
				do -- 270
					local _accum_0 -- 270
					for _index_2 = 1, #entries do -- 270
						local _des_0 = entries[_index_2] -- 270
						local ename, efile = _des_0[1], _des_0[2] -- 270
						if entryName == ename and efile == fileName then -- 271
							_accum_0 = true -- 271
							break -- 271
						end -- 271
					end -- 271
					entryAdded = _accum_0 -- 270
				end -- 271
				if entryAdded then -- 272
					goto _continue_1 -- 272
				end -- 272
				local examples = { } -- 273
				local tests = { } -- 274
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 275
				if Content:exist(examplePath) then -- 276
					local _list_2 = getFileEntries(examplePath) -- 277
					for _index_2 = 1, #_list_2 do -- 277
						local _des_0 = _list_2[_index_2] -- 277
						local name, ePath = _des_0[1], _des_0[2] -- 277
						local entry = { -- 278
							name, -- 278
							Path(path, dir, Path:getPath(file), ePath) -- 278
						} -- 278
						examples[#examples + 1] = entry -- 279
					end -- 279
				end -- 276
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 280
				if Content:exist(testPath) then -- 281
					local _list_2 = getFileEntries(testPath) -- 282
					for _index_2 = 1, #_list_2 do -- 282
						local _des_0 = _list_2[_index_2] -- 282
						local name, tPath = _des_0[1], _des_0[2] -- 282
						local entry = { -- 283
							name, -- 283
							Path(path, dir, Path:getPath(file), tPath) -- 283
						} -- 283
						tests[#tests + 1] = entry -- 284
					end -- 284
				end -- 281
				local entry = { -- 285
					entryName, -- 285
					fileName, -- 285
					examples, -- 285
					tests -- 285
				} -- 285
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 286
				if not Content:exist(bannerFile) then -- 287
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 288
					if not Content:exist(bannerFile) then -- 289
						bannerFile = nil -- 289
					end -- 289
				end -- 287
				if bannerFile then -- 290
					thread(function() -- 290
						if Cache:loadAsync(bannerFile) then -- 291
							local bannerTex = Texture2D(bannerFile) -- 292
							if bannerTex then -- 293
								entry[#entry + 1] = bannerFile -- 294
								entry[#entry + 1] = bannerTex -- 295
							end -- 293
						end -- 291
					end) -- 290
				end -- 290
				entries[#entries + 1] = entry -- 296
			end -- 266
			::_continue_1:: -- 266
		end -- 296
		::_continue_0:: -- 264
	end -- 296
	table.sort(entries, function(a, b) -- 297
		return a[1] < b[1] -- 297
	end) -- 297
	return entries -- 298
end -- 261
local gamesInDev, games -- 300
local doraTools, doraExamples, doraTests -- 301
local cppTests, cppTestSet -- 302
local allEntries -- 303
local _anon_func_1 = function(App) -- 311
	if not App.debugging then -- 311
		return { -- 311
			"ImGui" -- 311
		} -- 311
	end -- 311
end -- 311
local updateEntries -- 305
updateEntries = function() -- 305
	gamesInDev = getProjectEntries(Content.writablePath) -- 306
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 307
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 309
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 310
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test"), true, _anon_func_1(App)) -- 311
	cppTests = { } -- 313
	local _list_0 = App.testNames -- 314
	for _index_0 = 1, #_list_0 do -- 314
		local name = _list_0[_index_0] -- 314
		local entry = { -- 315
			name -- 315
		} -- 315
		cppTests[#cppTests + 1] = entry -- 316
	end -- 316
	cppTestSet = Set(cppTests) -- 317
	allEntries = { } -- 319
	for _index_0 = 1, #gamesInDev do -- 320
		local game = gamesInDev[_index_0] -- 320
		allEntries[#allEntries + 1] = game -- 321
		local examples, tests = game[3], game[4] -- 322
		for _index_1 = 1, #examples do -- 323
			local example = examples[_index_1] -- 323
			allEntries[#allEntries + 1] = example -- 324
		end -- 324
		for _index_1 = 1, #tests do -- 325
			local test = tests[_index_1] -- 325
			allEntries[#allEntries + 1] = test -- 326
		end -- 326
	end -- 326
	for _index_0 = 1, #games do -- 327
		local game = games[_index_0] -- 327
		allEntries[#allEntries + 1] = game -- 328
		local examples, tests = game[3], game[4] -- 329
		for _index_1 = 1, #examples do -- 330
			local example = examples[_index_1] -- 330
			doraExamples[#doraExamples + 1] = example -- 331
		end -- 331
		for _index_1 = 1, #tests do -- 332
			local test = tests[_index_1] -- 332
			doraTests[#doraTests + 1] = test -- 333
		end -- 333
	end -- 333
	local _list_1 = { -- 335
		doraExamples, -- 335
		doraTests, -- 336
		cppTests -- 337
	} -- 334
	for _index_0 = 1, #_list_1 do -- 338
		local group = _list_1[_index_0] -- 334
		for _index_1 = 1, #group do -- 339
			local entry = group[_index_1] -- 339
			allEntries[#allEntries + 1] = entry -- 340
		end -- 340
	end -- 340
end -- 305
updateEntries() -- 342
local doCompile -- 344
doCompile = function(minify) -- 344
	if building then -- 345
		return -- 345
	end -- 345
	building = true -- 346
	local startTime = App.runningTime -- 347
	local luaFiles = { } -- 348
	local yueFiles = { } -- 349
	local xmlFiles = { } -- 350
	local tlFiles = { } -- 351
	local writablePath = Content.writablePath -- 352
	local buildPaths = { -- 354
		{ -- 355
			Content.assetPath, -- 355
			Path(writablePath, ".build"), -- 356
			"" -- 357
		} -- 354
	} -- 353
	for _index_0 = 1, #gamesInDev do -- 360
		local _des_0 = gamesInDev[_index_0] -- 360
		local entryFile = _des_0[2] -- 360
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 361
		buildPaths[#buildPaths + 1] = { -- 363
			Path(writablePath, gamePath), -- 363
			Path(writablePath, ".build", gamePath), -- 364
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 365
			gamePath -- 366
		} -- 362
	end -- 366
	for _index_0 = 1, #buildPaths do -- 367
		local _des_0 = buildPaths[_index_0] -- 367
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 367
		if not Content:exist(inputPath) then -- 368
			goto _continue_0 -- 368
		end -- 368
		local _list_0 = getAllFiles(inputPath, { -- 370
			"lua" -- 370
		}) -- 370
		for _index_1 = 1, #_list_0 do -- 370
			local file = _list_0[_index_1] -- 370
			luaFiles[#luaFiles + 1] = { -- 372
				file, -- 372
				Path(inputPath, file), -- 373
				Path(outputPath, file), -- 374
				gamePath -- 375
			} -- 371
		end -- 375
		local _list_1 = getAllFiles(inputPath, { -- 377
			yueext -- 377
		}) -- 377
		for _index_1 = 1, #_list_1 do -- 377
			local file = _list_1[_index_1] -- 377
			yueFiles[#yueFiles + 1] = { -- 379
				file, -- 379
				Path(inputPath, file), -- 380
				Path(outputPath, Path:replaceExt(file, "lua")), -- 381
				searchPath, -- 382
				gamePath -- 383
			} -- 378
		end -- 383
		local _list_2 = getAllFiles(inputPath, { -- 385
			"xml" -- 385
		}) -- 385
		for _index_1 = 1, #_list_2 do -- 385
			local file = _list_2[_index_1] -- 385
			xmlFiles[#xmlFiles + 1] = { -- 387
				file, -- 387
				Path(inputPath, file), -- 388
				Path(outputPath, Path:replaceExt(file, "lua")), -- 389
				gamePath -- 390
			} -- 386
		end -- 390
		local _list_3 = getAllFiles(inputPath, { -- 392
			"tl" -- 392
		}) -- 392
		for _index_1 = 1, #_list_3 do -- 392
			local file = _list_3[_index_1] -- 392
			if not file:match(".*%.d%.tl$") then -- 393
				tlFiles[#tlFiles + 1] = { -- 395
					file, -- 395
					Path(inputPath, file), -- 396
					Path(outputPath, Path:replaceExt(file, "lua")), -- 397
					searchPath, -- 398
					gamePath -- 399
				} -- 394
			end -- 393
		end -- 399
		::_continue_0:: -- 368
	end -- 399
	local paths -- 401
	do -- 401
		local _tbl_0 = { } -- 401
		local _list_0 = { -- 402
			luaFiles, -- 402
			yueFiles, -- 402
			xmlFiles, -- 402
			tlFiles -- 402
		} -- 402
		for _index_0 = 1, #_list_0 do -- 402
			local files = _list_0[_index_0] -- 402
			for _index_1 = 1, #files do -- 403
				local file = files[_index_1] -- 403
				_tbl_0[Path:getPath(file[3])] = true -- 401
			end -- 401
		end -- 401
		paths = _tbl_0 -- 401
	end -- 403
	for path in pairs(paths) do -- 405
		Content:mkdir(path) -- 405
	end -- 405
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 407
	local fileCount = 0 -- 408
	local errors = { } -- 409
	for _index_0 = 1, #yueFiles do -- 410
		local _des_0 = yueFiles[_index_0] -- 410
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 410
		local filename -- 411
		if gamePath then -- 411
			filename = Path(gamePath, file) -- 411
		else -- 411
			filename = file -- 411
		end -- 411
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 412
			if not codes then -- 413
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 414
				return -- 415
			end -- 413
			local success, result = LintYueGlobals(codes, globals) -- 416
			if success then -- 417
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 418
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 419
				codes = codes:gsub("^\n*", "") -- 420
				if not (result == "") then -- 421
					result = result .. "\n" -- 421
				end -- 421
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 422
			else -- 424
				local yueCodes = Content:load(input) -- 424
				if yueCodes then -- 424
					local globalErrors = { } -- 425
					for _index_1 = 1, #result do -- 426
						local _des_1 = result[_index_1] -- 426
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 426
						local countLine = 1 -- 427
						local code = "" -- 428
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 429
							if countLine == line then -- 430
								code = lineCode -- 431
								break -- 432
							end -- 430
							countLine = countLine + 1 -- 433
						end -- 433
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 434
					end -- 434
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 435
				else -- 437
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 437
				end -- 424
			end -- 417
		end, function(success) -- 412
			if success then -- 438
				print("Yue compiled: " .. tostring(filename)) -- 438
			end -- 438
			fileCount = fileCount + 1 -- 439
		end) -- 412
	end -- 439
	thread(function() -- 441
		for _index_0 = 1, #xmlFiles do -- 442
			local _des_0 = xmlFiles[_index_0] -- 442
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 442
			local filename -- 443
			if gamePath then -- 443
				filename = Path(gamePath, file) -- 443
			else -- 443
				filename = file -- 443
			end -- 443
			local sourceCodes = Content:loadAsync(input) -- 444
			local codes, err = xml.tolua(sourceCodes) -- 445
			if not codes then -- 446
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 447
			else -- 449
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 449
				print("Xml compiled: " .. tostring(filename)) -- 450
			end -- 446
			fileCount = fileCount + 1 -- 451
		end -- 451
	end) -- 441
	thread(function() -- 453
		for _index_0 = 1, #tlFiles do -- 454
			local _des_0 = tlFiles[_index_0] -- 454
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 454
			local filename -- 455
			if gamePath then -- 455
				filename = Path(gamePath, file) -- 455
			else -- 455
				filename = file -- 455
			end -- 455
			local sourceCodes = Content:loadAsync(input) -- 456
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 457
			if not codes then -- 458
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 459
			else -- 461
				Content:saveAsync(output, codes) -- 461
				print("Teal compiled: " .. tostring(filename)) -- 462
			end -- 458
			fileCount = fileCount + 1 -- 463
		end -- 463
	end) -- 453
	return thread(function() -- 465
		wait(function() -- 466
			return fileCount == totalFiles -- 466
		end) -- 466
		if minify then -- 467
			local _list_0 = { -- 468
				yueFiles, -- 468
				xmlFiles, -- 468
				tlFiles -- 468
			} -- 468
			for _index_0 = 1, #_list_0 do -- 468
				local files = _list_0[_index_0] -- 468
				for _index_1 = 1, #files do -- 468
					local file = files[_index_1] -- 468
					local output = Path:replaceExt(file[3], "lua") -- 469
					luaFiles[#luaFiles + 1] = { -- 471
						Path:replaceExt(file[1], "lua"), -- 471
						output, -- 472
						output -- 473
					} -- 470
				end -- 473
			end -- 473
			local FormatMini -- 475
			do -- 475
				local _obj_0 = require("luaminify") -- 475
				FormatMini = _obj_0.FormatMini -- 475
			end -- 475
			for _index_0 = 1, #luaFiles do -- 476
				local _des_0 = luaFiles[_index_0] -- 476
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 476
				if Content:exist(input) then -- 477
					local sourceCodes = Content:loadAsync(input) -- 478
					local res, err = FormatMini(sourceCodes) -- 479
					if res then -- 480
						Content:saveAsync(output, res) -- 481
						print("Minify: " .. tostring(file)) -- 482
					else -- 484
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 484
					end -- 480
				else -- 486
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 486
				end -- 477
			end -- 486
			package.loaded["luaminify.FormatMini"] = nil -- 487
			package.loaded["luaminify.ParseLua"] = nil -- 488
			package.loaded["luaminify.Scope"] = nil -- 489
			package.loaded["luaminify.Util"] = nil -- 490
		end -- 467
		local errorMessage = table.concat(errors, "\n") -- 491
		if errorMessage ~= "" then -- 492
			print(errorMessage) -- 492
		end -- 492
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 493
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 494
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 495
		Content:clearPathCache() -- 496
		teal.clear() -- 497
		yue.clear() -- 498
		building = false -- 499
	end) -- 499
end -- 344
local doClean -- 501
doClean = function() -- 501
	if building then -- 502
		return -- 502
	end -- 502
	local writablePath = Content.writablePath -- 503
	local targetDir = Path(writablePath, ".build") -- 504
	Content:clearPathCache() -- 505
	if Content:remove(targetDir) then -- 506
		return print("Cleaned: " .. tostring(targetDir)) -- 507
	end -- 506
end -- 501
local screenScale = 2.0 -- 509
local scaleContent = false -- 510
local isInEntry = true -- 511
local currentEntry = nil -- 512
local footerWindow = nil -- 514
local entryWindow = nil -- 515
local testingThread = nil -- 516
local setupEventHandlers = nil -- 518
local allClear -- 520
allClear = function() -- 520
	local _list_0 = Routine -- 521
	for _index_0 = 1, #_list_0 do -- 521
		local routine = _list_0[_index_0] -- 521
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 523
			goto _continue_0 -- 524
		else -- 526
			Routine:remove(routine) -- 526
		end -- 526
		::_continue_0:: -- 522
	end -- 526
	for _index_0 = 1, #moduleCache do -- 527
		local module = moduleCache[_index_0] -- 527
		package.loaded[module] = nil -- 528
	end -- 528
	moduleCache = { } -- 529
	Director:cleanup() -- 530
	Cache:unload() -- 531
	Entity:clear() -- 532
	Platformer.Data:clear() -- 533
	Platformer.UnitAction:clear() -- 534
	Audio:stopStream(0.5) -- 535
	Struct:clear() -- 536
	View.postEffect = nil -- 537
	View.scale = scaleContent and screenScale or 1 -- 538
	Director.clearColor = Color(0xff1a1a1a) -- 539
	teal.clear() -- 540
	yue.clear() -- 541
	for _, item in pairs(ubox()) do -- 542
		local node = tolua.cast(item, "Node") -- 543
		if node then -- 543
			node:cleanup() -- 543
		end -- 543
	end -- 543
	collectgarbage() -- 544
	collectgarbage() -- 545
	setupEventHandlers() -- 546
	Content.searchPaths = searchPaths -- 547
	App.idled = true -- 548
	return Wasm:clear() -- 549
end -- 520
_module_0["allClear"] = allClear -- 549
local clearTempFiles -- 551
clearTempFiles = function() -- 551
	local writablePath = Content.writablePath -- 552
	Content:remove(Path(writablePath, ".upload")) -- 553
	return Content:remove(Path(writablePath, ".download")) -- 554
end -- 551
local waitForWebStart = true -- 556
thread(function() -- 557
	sleep(2) -- 558
	waitForWebStart = false -- 559
end) -- 557
local reloadDevEntry -- 561
reloadDevEntry = function() -- 561
	return thread(function() -- 561
		waitForWebStart = true -- 562
		doClean() -- 563
		allClear() -- 564
		_G.require = oldRequire -- 565
		Dora.require = oldRequire -- 566
		package.loaded["Script.Dev.Entry"] = nil -- 567
		return Director.systemScheduler:schedule(function() -- 568
			Routine:clear() -- 569
			oldRequire("Script.Dev.Entry") -- 570
			return true -- 571
		end) -- 571
	end) -- 571
end -- 561
local setWorkspace -- 573
setWorkspace = function(path) -- 573
	Content.writablePath = path -- 574
	config.writablePath = Content.writablePath -- 575
	return thread(function() -- 576
		sleep() -- 577
		return reloadDevEntry() -- 578
	end) -- 578
end -- 573
local _anon_func_2 = function(App, _with_0) -- 593
	local _val_0 = App.platform -- 593
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 593
end -- 593
setupEventHandlers = function() -- 580
	local _with_0 = Director.postNode -- 581
	_with_0:onAppEvent(function(eventType) -- 582
		if eventType == "Quit" then -- 582
			allClear() -- 583
			return clearTempFiles() -- 584
		end -- 582
	end) -- 582
	_with_0:onAppChange(function(settingName) -- 585
		if "Theme" == settingName then -- 586
			config.themeColor = App.themeColor:toARGB() -- 587
		elseif "Locale" == settingName then -- 588
			config.locale = App.locale -- 589
			updateLocale() -- 590
			return teal.clear(true) -- 591
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 592
			if _anon_func_2(App, _with_0) then -- 593
				if "FullScreen" == settingName then -- 595
					config.fullScreen = App.fullScreen -- 595
				elseif "Position" == settingName then -- 596
					local _obj_0 = App.winPosition -- 596
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 596
				elseif "Size" == settingName then -- 597
					local width, height -- 598
					do -- 598
						local _obj_0 = App.winSize -- 598
						width, height = _obj_0.width, _obj_0.height -- 598
					end -- 598
					config.winWidth = width -- 599
					config.winHeight = height -- 600
				end -- 600
			end -- 593
		end -- 600
	end) -- 585
	_with_0:onAppWS(function(eventType) -- 601
		if eventType == "Close" then -- 601
			if HttpServer.wsConnectionCount == 0 then -- 602
				return updateEntries() -- 603
			end -- 602
		end -- 601
	end) -- 601
	_with_0:slot("UpdateEntries", function() -- 604
		return updateEntries() -- 604
	end) -- 604
	return _with_0 -- 581
end -- 580
setupEventHandlers() -- 606
clearTempFiles() -- 607
local stop -- 609
stop = function() -- 609
	if isInEntry then -- 610
		return false -- 610
	end -- 610
	allClear() -- 611
	isInEntry = true -- 612
	currentEntry = nil -- 613
	return true -- 614
end -- 609
_module_0["stop"] = stop -- 614
local _anon_func_3 = function(Content, Path, file, require, type) -- 636
	local scriptPath = Path:getPath(file) -- 629
	Content:insertSearchPath(1, scriptPath) -- 630
	scriptPath = Path(scriptPath, "Script") -- 631
	if Content:exist(scriptPath) then -- 632
		Content:insertSearchPath(1, scriptPath) -- 633
	end -- 632
	local result = require(file) -- 634
	if "function" == type(result) then -- 635
		result() -- 635
	end -- 635
	return nil -- 636
end -- 629
local _anon_func_4 = function(Label, _with_0, err, fontSize, width) -- 668
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 665
	label.alignment = "Left" -- 666
	label.textWidth = width - fontSize -- 667
	label.text = err -- 668
	return label -- 665
end -- 665
local enterEntryAsync -- 616
enterEntryAsync = function(entry) -- 616
	isInEntry = false -- 617
	App.idled = false -- 618
	emit(Profiler.EventName, "ClearLoader") -- 619
	currentEntry = entry -- 620
	local name, file = entry[1], entry[2] -- 621
	if cppTestSet[entry] then -- 622
		if App:runTest(name) then -- 623
			return true -- 624
		else -- 626
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 626
		end -- 623
	end -- 622
	sleep() -- 627
	return xpcall(_anon_func_3, function(msg) -- 669
		local err = debug.traceback(msg) -- 638
		Log("Error", err) -- 639
		allClear() -- 640
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 641
		local viewWidth, viewHeight -- 642
		do -- 642
			local _obj_0 = View.size -- 642
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 642
		end -- 642
		local width, height = viewWidth - 20, viewHeight - 20 -- 643
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 644
		Director.ui:addChild((function() -- 645
			local root = AlignNode() -- 645
			do -- 646
				local _obj_0 = App.bufferSize -- 646
				width, height = _obj_0.width, _obj_0.height -- 646
			end -- 646
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 647
			root:onAppChange(function(settingName) -- 648
				if settingName == "Size" then -- 648
					do -- 649
						local _obj_0 = App.bufferSize -- 649
						width, height = _obj_0.width, _obj_0.height -- 649
					end -- 649
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 650
				end -- 648
			end) -- 648
			root:addChild((function() -- 651
				local _with_0 = ScrollArea({ -- 652
					width = width, -- 652
					height = height, -- 653
					paddingX = 0, -- 654
					paddingY = 50, -- 655
					viewWidth = height, -- 656
					viewHeight = height -- 657
				}) -- 651
				root:onAlignLayout(function(w, h) -- 659
					_with_0.position = Vec2(w / 2, h / 2) -- 660
					w = w - 20 -- 661
					h = h - 20 -- 662
					_with_0.view.children.first.textWidth = w - fontSize -- 663
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 664
				end) -- 659
				_with_0.view:addChild(_anon_func_4(Label, _with_0, err, fontSize, width)) -- 665
				return _with_0 -- 651
			end)()) -- 651
			return root -- 645
		end)()) -- 645
		return err -- 669
	end, Content, Path, file, require, type) -- 669
end -- 616
_module_0["enterEntryAsync"] = enterEntryAsync -- 669
local enterDemoEntry -- 671
enterDemoEntry = function(entry) -- 671
	return thread(function() -- 671
		return enterEntryAsync(entry) -- 671
	end) -- 671
end -- 671
local reloadCurrentEntry -- 673
reloadCurrentEntry = function() -- 673
	if currentEntry then -- 674
		allClear() -- 675
		return enterDemoEntry(currentEntry) -- 676
	end -- 674
end -- 673
Director.clearColor = Color(0xff1a1a1a) -- 678
local isOSSLicenseExist = Content:exist("LICENSES") -- 680
local ossLicenses = nil -- 681
local ossLicenseOpen = false -- 682
local extraOperations -- 684
extraOperations = function() -- 684
	local zh = useChinese and isChineseSupported -- 685
	if isDesktop then -- 686
		local themeColor = App.themeColor -- 687
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 688
		do -- 689
			local changed -- 689
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 689
			if changed then -- 689
				App.alwaysOnTop = alwaysOnTop -- 690
				config.alwaysOnTop = alwaysOnTop -- 691
			end -- 689
		end -- 689
		SeparatorText(zh and "工作目录" or "Workspace") -- 692
		PushTextWrapPos(400, function() -- 693
			return TextColored(themeColor, writablePath) -- 694
		end) -- 693
		if Button(zh and "改变目录" or "Set Folder") then -- 695
			App:openFileDialog(true, function(path) -- 696
				if path ~= "" then -- 697
					return setWorkspace(path) -- 697
				end -- 697
			end) -- 696
		end -- 695
		SameLine() -- 698
		if Button(zh and "使用默认" or "Use Default") then -- 699
			setWorkspace(Content.appPath) -- 700
		end -- 699
		Separator() -- 701
	end -- 686
	if isOSSLicenseExist then -- 702
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 703
			if not ossLicenses then -- 704
				ossLicenses = { } -- 705
				local licenseText = Content:load("LICENSES") -- 706
				ossLicenseOpen = (licenseText ~= nil) -- 707
				if ossLicenseOpen then -- 707
					licenseText = licenseText:gsub("\r\n", "\n") -- 708
					for license in GSplit(licenseText, "\n--------\n", true) do -- 709
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 710
						if name then -- 710
							ossLicenses[#ossLicenses + 1] = { -- 711
								name, -- 711
								text -- 711
							} -- 711
						end -- 710
					end -- 711
				end -- 707
			else -- 713
				ossLicenseOpen = true -- 713
			end -- 704
		end -- 703
		if ossLicenseOpen then -- 714
			local width, height, themeColor -- 715
			do -- 715
				local _obj_0 = App -- 715
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 715
			end -- 715
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 716
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 717
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 718
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 721
					"NoSavedSettings" -- 721
				}, function() -- 722
					for _index_0 = 1, #ossLicenses do -- 722
						local _des_0 = ossLicenses[_index_0] -- 722
						local firstLine, text = _des_0[1], _des_0[2] -- 722
						local name, license = firstLine:match("(.+): (.+)") -- 723
						TextColored(themeColor, name) -- 724
						SameLine() -- 725
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 726
							return TextWrapped(text) -- 726
						end) -- 726
					end -- 726
				end) -- 718
			end) -- 718
		end -- 714
	end -- 702
	if not App.debugging then -- 728
		return -- 728
	end -- 728
	return TreeNode(zh and "开发操作" or "Development", function() -- 729
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 730
			OpenPopup("build") -- 730
		end -- 730
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 731
			return BeginPopup("build", function() -- 731
				if Selectable(zh and "编译" or "Compile") then -- 732
					doCompile(false) -- 732
				end -- 732
				Separator() -- 733
				if Selectable(zh and "压缩" or "Minify") then -- 734
					doCompile(true) -- 734
				end -- 734
				Separator() -- 735
				if Selectable(zh and "清理" or "Clean") then -- 736
					return doClean() -- 736
				end -- 736
			end) -- 736
		end) -- 731
		if isInEntry then -- 737
			if waitForWebStart then -- 738
				BeginDisabled(function() -- 739
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 739
				end) -- 739
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 740
				reloadDevEntry() -- 741
			end -- 738
		end -- 737
		do -- 742
			local changed -- 742
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 742
			if changed then -- 742
				View.scale = scaleContent and screenScale or 1 -- 743
			end -- 742
		end -- 742
		do -- 744
			local changed -- 744
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 744
			if changed then -- 744
				config.engineDev = engineDev -- 745
			end -- 744
		end -- 744
		if Button(zh and "开始自动测试" or "Test automatically") then -- 746
			testingThread = thread(function() -- 747
				local _ <close> = setmetatable({ }, { -- 748
					__close = function() -- 748
						allClear() -- 749
						testingThread = nil -- 750
						isInEntry = true -- 751
						currentEntry = nil -- 752
						return print("Testing done!") -- 753
					end -- 748
				}) -- 748
				for _, entry in ipairs(allEntries) do -- 754
					allClear() -- 755
					print("Start " .. tostring(entry[1])) -- 756
					enterDemoEntry(entry) -- 757
					sleep(2) -- 758
					print("Stop " .. tostring(entry[1])) -- 759
				end -- 759
			end) -- 747
		end -- 746
	end) -- 729
end -- 684
local transparant = Color(0x0) -- 761
local windowFlags = { -- 762
	"NoTitleBar", -- 762
	"NoResize", -- 762
	"NoMove", -- 762
	"NoCollapse", -- 762
	"NoSavedSettings", -- 762
	"NoBringToFrontOnFocus" -- 762
} -- 762
local initFooter = true -- 770
local _anon_func_5 = function(allEntries, currentIndex) -- 806
	if currentIndex > 1 then -- 806
		return allEntries[currentIndex - 1] -- 807
	else -- 809
		return allEntries[#allEntries] -- 809
	end -- 806
end -- 806
local _anon_func_6 = function(allEntries, currentIndex) -- 813
	if currentIndex < #allEntries then -- 813
		return allEntries[currentIndex + 1] -- 814
	else -- 816
		return allEntries[1] -- 816
	end -- 813
end -- 813
footerWindow = threadLoop(function() -- 771
	local zh = useChinese and isChineseSupported -- 772
	if HttpServer.wsConnectionCount > 0 then -- 773
		return -- 774
	end -- 773
	if Keyboard:isKeyDown("Escape") then -- 775
		allClear() -- 776
		App:shutdown() -- 777
	end -- 775
	do -- 778
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 779
		if ctrl and Keyboard:isKeyDown("Q") then -- 780
			stop() -- 781
		end -- 780
		if ctrl and Keyboard:isKeyDown("Z") then -- 782
			reloadCurrentEntry() -- 783
		end -- 782
		if ctrl and Keyboard:isKeyDown(",") then -- 784
			if showFooter then -- 785
				showStats = not showStats -- 785
			else -- 785
				showStats = true -- 785
			end -- 785
			showFooter = true -- 786
			config.showFooter = showFooter -- 787
			config.showStats = showStats -- 788
		end -- 784
		if ctrl and Keyboard:isKeyDown(".") then -- 789
			if showFooter then -- 790
				showConsole = not showConsole -- 790
			else -- 790
				showConsole = true -- 790
			end -- 790
			showFooter = true -- 791
			config.showFooter = showFooter -- 792
			config.showConsole = showConsole -- 793
		end -- 789
		if ctrl and Keyboard:isKeyDown("/") then -- 794
			showFooter = not showFooter -- 795
			config.showFooter = showFooter -- 796
		end -- 794
		local left = ctrl and Keyboard:isKeyDown("Left") -- 797
		local right = ctrl and Keyboard:isKeyDown("Right") -- 798
		local currentIndex = nil -- 799
		for i, entry in ipairs(allEntries) do -- 800
			if currentEntry == entry then -- 801
				currentIndex = i -- 802
			end -- 801
		end -- 802
		if left then -- 803
			allClear() -- 804
			if currentIndex == nil then -- 805
				currentIndex = #allEntries + 1 -- 805
			end -- 805
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 806
		end -- 803
		if right then -- 810
			allClear() -- 811
			if currentIndex == nil then -- 812
				currentIndex = 0 -- 812
			end -- 812
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 813
		end -- 810
	end -- 816
	if not showEntry then -- 817
		return -- 817
	end -- 817
	local width, height -- 819
	do -- 819
		local _obj_0 = App.visualSize -- 819
		width, height = _obj_0.width, _obj_0.height -- 819
	end -- 819
	SetNextWindowSize(Vec2(50, 50)) -- 820
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 821
	PushStyleColor("WindowBg", transparant, function() -- 822
		return Begin("Show", windowFlags, function() -- 822
			if isInEntry or width >= 540 then -- 823
				local changed -- 824
				changed, showFooter = Checkbox("##dev", showFooter) -- 824
				if changed then -- 824
					config.showFooter = showFooter -- 825
				end -- 824
			end -- 823
		end) -- 825
	end) -- 822
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 827
		reloadDevEntry() -- 831
	end -- 827
	if initFooter then -- 832
		initFooter = false -- 833
	else -- 835
		if not showFooter then -- 835
			return -- 835
		end -- 835
	end -- 832
	SetNextWindowSize(Vec2(width, 50)) -- 837
	SetNextWindowPos(Vec2(0, height - 50)) -- 838
	SetNextWindowBgAlpha(0.35) -- 839
	do -- 840
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 841
			return Begin("Footer", windowFlags, function() -- 842
				Dummy(Vec2(width - 20, 0)) -- 843
				do -- 844
					local changed -- 844
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 844
					if changed then -- 844
						config.showStats = showStats -- 845
					end -- 844
				end -- 844
				SameLine() -- 846
				do -- 847
					local changed -- 847
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 847
					if changed then -- 847
						config.showConsole = showConsole -- 848
					end -- 847
				end -- 847
				if config.updateNotification then -- 849
					SameLine() -- 850
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 851
						allClear() -- 852
						config.updateNotification = false -- 853
						enterDemoEntry({ -- 855
							"SelfUpdater", -- 855
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 856
						}) -- 854
					end -- 851
				end -- 849
				if not isInEntry then -- 858
					SameLine() -- 859
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 860
					local currentIndex = nil -- 861
					for i, entry in ipairs(allEntries) do -- 862
						if currentEntry == entry then -- 863
							currentIndex = i -- 864
						end -- 863
					end -- 864
					if currentIndex then -- 865
						if currentIndex > 1 then -- 866
							SameLine() -- 867
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 868
								allClear() -- 869
								enterDemoEntry(allEntries[currentIndex - 1]) -- 870
							end -- 868
						end -- 866
						if currentIndex < #allEntries then -- 871
							SameLine() -- 872
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 873
								allClear() -- 874
								enterDemoEntry(allEntries[currentIndex + 1]) -- 875
							end -- 873
						end -- 871
					end -- 865
					SameLine() -- 876
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 877
						reloadCurrentEntry() -- 878
					end -- 877
					if back then -- 879
						allClear() -- 880
						isInEntry = true -- 881
						currentEntry = nil -- 882
					end -- 879
				end -- 858
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 883
					if showStats then -- 884
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 885
						showStats = ShowStats(showStats, extraOperations) -- 886
						config.showStats = showStats -- 887
					end -- 884
					if showConsole then -- 888
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 889
						showConsole = ShowConsole(showConsole) -- 890
						config.showConsole = showConsole -- 891
					end -- 888
				end) -- 883
			end) -- 842
		end) -- 841
	end -- 891
end) -- 771
local MaxWidth <const> = 800 -- 893
local displayWindowFlags = { -- 895
	"NoDecoration", -- 895
	"NoSavedSettings", -- 895
	"NoFocusOnAppearing", -- 895
	"NoNav", -- 895
	"NoMove", -- 895
	"NoScrollWithMouse", -- 895
	"AlwaysAutoResize", -- 895
	"NoBringToFrontOnFocus" -- 895
} -- 895
local webStatus = nil -- 906
local descColor = Color(0xffa1a1a1) -- 907
local gameOpen = #gamesInDev == 0 -- 908
local toolOpen = false -- 909
local exampleOpen = false -- 910
local testOpen = false -- 911
local filterText = nil -- 912
local anyEntryMatched = false -- 913
local urlClicked = nil -- 914
local match -- 915
match = function(name) -- 915
	local res = not filterText or name:lower():match(filterText) -- 916
	if res then -- 917
		anyEntryMatched = true -- 917
	end -- 917
	return res -- 918
end -- 915
local iconTex = nil -- 919
thread(function() -- 920
	if Cache:loadAsync("Image/icon_s.png") then -- 920
		iconTex = Texture2D("Image/icon_s.png") -- 921
	end -- 920
end) -- 920
entryWindow = threadLoop(function() -- 923
	if App.fpsLimited ~= config.fpsLimited then -- 924
		config.fpsLimited = App.fpsLimited -- 925
	end -- 924
	if App.targetFPS ~= config.targetFPS then -- 926
		config.targetFPS = App.targetFPS -- 927
	end -- 926
	if View.vsync ~= config.vsync then -- 928
		config.vsync = View.vsync -- 929
	end -- 928
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 930
		config.fixedFPS = Director.scheduler.fixedFPS -- 931
	end -- 930
	if Director.profilerSending ~= config.webProfiler then -- 932
		config.webProfiler = Director.profilerSending -- 933
	end -- 932
	if urlClicked then -- 934
		local _, result = coroutine.resume(urlClicked) -- 935
		if result then -- 936
			coroutine.close(urlClicked) -- 937
			urlClicked = nil -- 938
		end -- 936
	end -- 934
	if not showEntry then -- 939
		return -- 939
	end -- 939
	if not isInEntry then -- 940
		return -- 940
	end -- 940
	local zh = useChinese and isChineseSupported -- 941
	if HttpServer.wsConnectionCount > 0 then -- 942
		local themeColor = App.themeColor -- 943
		local width, height -- 944
		do -- 944
			local _obj_0 = App.visualSize -- 944
			width, height = _obj_0.width, _obj_0.height -- 944
		end -- 944
		SetNextWindowBgAlpha(0.5) -- 945
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 946
		Begin("Web IDE Connected", displayWindowFlags, function() -- 947
			Separator() -- 948
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 949
			if iconTex then -- 950
				Image("Image/icon_s.png", Vec2(24, 24)) -- 951
				SameLine() -- 952
			end -- 950
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 953
			TextColored(descColor, slogon) -- 954
			return Separator() -- 955
		end) -- 947
		return -- 956
	end -- 942
	local themeColor = App.themeColor -- 958
	local fullWidth, height -- 959
	do -- 959
		local _obj_0 = App.visualSize -- 959
		fullWidth, height = _obj_0.width, _obj_0.height -- 959
	end -- 959
	SetNextWindowBgAlpha(0.85) -- 961
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 962
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 963
		return Begin("Web IDE", displayWindowFlags, function() -- 964
			Separator() -- 965
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 966
			SameLine() -- 967
			TextDisabled('(?)') -- 968
			if IsItemHovered() then -- 969
				BeginTooltip(function() -- 970
					return PushTextWrapPos(280, function() -- 971
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 972
					end) -- 972
				end) -- 970
			end -- 969
			do -- 973
				local url -- 973
				if webStatus ~= nil then -- 973
					url = webStatus.url -- 973
				end -- 973
				if url then -- 973
					if isDesktop and not config.fullScreen then -- 974
						if urlClicked then -- 975
							BeginDisabled(function() -- 976
								return Button(url) -- 976
							end) -- 976
						elseif Button(url) then -- 977
							urlClicked = once(function() -- 978
								return sleep(5) -- 978
							end) -- 978
							App:openURL("http://localhost:8866") -- 979
						end -- 975
					else -- 981
						TextColored(descColor, url) -- 981
					end -- 974
				else -- 983
					TextColored(descColor, zh and '不可用' or 'not available') -- 983
				end -- 973
			end -- 973
			return Separator() -- 984
		end) -- 984
	end) -- 963
	local width = math.min(MaxWidth, fullWidth) -- 986
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 987
	local maxColumns = math.max(math.floor(width / 200), 1) -- 988
	SetNextWindowPos(Vec2.zero) -- 989
	SetNextWindowBgAlpha(0) -- 990
	do -- 991
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 992
			return Begin("Dora Dev", displayWindowFlags, function() -- 993
				Dummy(Vec2(fullWidth - 20, 0)) -- 994
				if iconTex then -- 995
					Image("Image/icon_s.png", Vec2(24, 24)) -- 996
					SameLine() -- 997
				end -- 995
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 998
				if fullWidth >= 400 then -- 999
					SameLine() -- 1000
					Dummy(Vec2(fullWidth - 400, 0)) -- 1001
					SameLine() -- 1002
					SetNextItemWidth(zh and -90 or -140) -- 1003
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1004
						"AutoSelectAll" -- 1004
					}) then -- 1004
						config.filter = filterBuf.text -- 1005
					end -- 1004
					SameLine() -- 1006
					if Button(zh and '下载' or 'Download') then -- 1007
						allClear() -- 1008
						enterDemoEntry({ -- 1010
							"ResourceDownloader", -- 1010
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1011
						}) -- 1009
					end -- 1007
				end -- 999
				Separator() -- 1013
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1014
			end) -- 993
		end) -- 992
	end -- 1014
	anyEntryMatched = false -- 1016
	SetNextWindowPos(Vec2(0, 50)) -- 1017
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1018
	do -- 1019
		return PushStyleColor("WindowBg", transparant, function() -- 1020
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1021
				return Begin("Content", windowFlags, function() -- 1022
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 1023
					if filterText then -- 1024
						filterText = filterText:lower() -- 1024
					end -- 1024
					if #gamesInDev > 0 then -- 1025
						for _index_0 = 1, #gamesInDev do -- 1026
							local game = gamesInDev[_index_0] -- 1026
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1027
							local showSep = false -- 1028
							if match(gameName) then -- 1029
								Columns(1, false) -- 1030
								TextColored(themeColor, zh and "项目：" or "Project:") -- 1031
								SameLine() -- 1032
								Text(gameName) -- 1033
								Separator() -- 1034
								if bannerFile then -- 1035
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1036
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1037
									local sizing <const> = 0.8 -- 1038
									texHeight = displayWidth * sizing * texHeight / texWidth -- 1039
									texWidth = displayWidth * sizing -- 1040
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1041
									Dummy(Vec2(padding, 0)) -- 1042
									SameLine() -- 1043
									PushID(fileName, function() -- 1044
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1045
											return enterDemoEntry(game) -- 1046
										end -- 1045
									end) -- 1044
								else -- 1048
									PushID(fileName, function() -- 1048
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 1049
											return enterDemoEntry(game) -- 1050
										end -- 1049
									end) -- 1048
								end -- 1035
								NextColumn() -- 1051
								showSep = true -- 1052
							end -- 1029
							if #examples > 0 then -- 1053
								local showExample = false -- 1054
								for _index_1 = 1, #examples do -- 1055
									local example = examples[_index_1] -- 1055
									if match(example[1]) then -- 1056
										showExample = true -- 1057
										break -- 1058
									end -- 1056
								end -- 1058
								if showExample then -- 1059
									Columns(1, false) -- 1060
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1061
									SameLine() -- 1062
									Text(gameName) -- 1063
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1064
										Columns(maxColumns, false) -- 1065
										for _index_1 = 1, #examples do -- 1066
											local example = examples[_index_1] -- 1066
											if not match(example[1]) then -- 1067
												goto _continue_0 -- 1067
											end -- 1067
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1068
												if Button(example[1], Vec2(-1, 40)) then -- 1069
													enterDemoEntry(example) -- 1070
												end -- 1069
												return NextColumn() -- 1071
											end) -- 1068
											showSep = true -- 1072
											::_continue_0:: -- 1067
										end -- 1072
									end) -- 1064
								end -- 1059
							end -- 1053
							if #tests > 0 then -- 1073
								local showTest = false -- 1074
								for _index_1 = 1, #tests do -- 1075
									local test = tests[_index_1] -- 1075
									if match(test[1]) then -- 1076
										showTest = true -- 1077
										break -- 1078
									end -- 1076
								end -- 1078
								if showTest then -- 1079
									Columns(1, false) -- 1080
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1081
									SameLine() -- 1082
									Text(gameName) -- 1083
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1084
										Columns(maxColumns, false) -- 1085
										for _index_1 = 1, #tests do -- 1086
											local test = tests[_index_1] -- 1086
											if not match(test[1]) then -- 1087
												goto _continue_0 -- 1087
											end -- 1087
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1088
												if Button(test[1], Vec2(-1, 40)) then -- 1089
													enterDemoEntry(test) -- 1090
												end -- 1089
												return NextColumn() -- 1091
											end) -- 1088
											showSep = true -- 1092
											::_continue_0:: -- 1087
										end -- 1092
									end) -- 1084
								end -- 1079
							end -- 1073
							if showSep then -- 1093
								Columns(1, false) -- 1094
								Separator() -- 1095
							end -- 1093
						end -- 1095
					end -- 1025
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1096
						local showGame = false -- 1097
						for _index_0 = 1, #games do -- 1098
							local _des_0 = games[_index_0] -- 1098
							local name = _des_0[1] -- 1098
							if match(name) then -- 1099
								showGame = true -- 1099
							end -- 1099
						end -- 1099
						local showTool = false -- 1100
						for _index_0 = 1, #doraTools do -- 1101
							local _des_0 = doraTools[_index_0] -- 1101
							local name = _des_0[1] -- 1101
							if match(name) then -- 1102
								showTool = true -- 1102
							end -- 1102
						end -- 1102
						local showExample = false -- 1103
						for _index_0 = 1, #doraExamples do -- 1104
							local _des_0 = doraExamples[_index_0] -- 1104
							local name = _des_0[1] -- 1104
							if match(name) then -- 1105
								showExample = true -- 1105
							end -- 1105
						end -- 1105
						local showTest = false -- 1106
						for _index_0 = 1, #doraTests do -- 1107
							local _des_0 = doraTests[_index_0] -- 1107
							local name = _des_0[1] -- 1107
							if match(name) then -- 1108
								showTest = true -- 1108
							end -- 1108
						end -- 1108
						for _index_0 = 1, #cppTests do -- 1109
							local _des_0 = cppTests[_index_0] -- 1109
							local name = _des_0[1] -- 1109
							if match(name) then -- 1110
								showTest = true -- 1110
							end -- 1110
						end -- 1110
						if not (showGame or showTool or showExample or showTest) then -- 1111
							goto endEntry -- 1111
						end -- 1111
						Columns(1, false) -- 1112
						TextColored(themeColor, "Dora SSR:") -- 1113
						SameLine() -- 1114
						Text(zh and "开发示例" or "Development Showcase") -- 1115
						Separator() -- 1116
						local demoViewWith <const> = 400 -- 1117
						if #games > 0 and showGame then -- 1118
							local opened -- 1119
							if (filterText ~= nil) then -- 1119
								opened = showGame -- 1119
							else -- 1119
								opened = false -- 1119
							end -- 1119
							SetNextItemOpen(gameOpen) -- 1120
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1121
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1122
								Columns(columns, false) -- 1123
								for _index_0 = 1, #games do -- 1124
									local game = games[_index_0] -- 1124
									if not match(game[1]) then -- 1125
										goto _continue_0 -- 1125
									end -- 1125
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1126
									if columns > 1 then -- 1127
										if bannerFile then -- 1128
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1129
											local displayWidth <const> = demoViewWith - 40 -- 1130
											texHeight = displayWidth * texHeight / texWidth -- 1131
											texWidth = displayWidth -- 1132
											Text(gameName) -- 1133
											PushID(fileName, function() -- 1134
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1135
													return enterDemoEntry(game) -- 1136
												end -- 1135
											end) -- 1134
										else -- 1138
											PushID(fileName, function() -- 1138
												if Button(gameName, Vec2(-1, 40)) then -- 1139
													return enterDemoEntry(game) -- 1140
												end -- 1139
											end) -- 1138
										end -- 1128
									else -- 1142
										if bannerFile then -- 1142
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1143
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1144
											local sizing = 0.8 -- 1145
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1146
											texWidth = displayWidth * sizing -- 1147
											if texWidth > 500 then -- 1148
												sizing = 0.6 -- 1149
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1150
												texWidth = displayWidth * sizing -- 1151
											end -- 1148
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1152
											Dummy(Vec2(padding, 0)) -- 1153
											SameLine() -- 1154
											Text(gameName) -- 1155
											Dummy(Vec2(padding, 0)) -- 1156
											SameLine() -- 1157
											PushID(fileName, function() -- 1158
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1159
													return enterDemoEntry(game) -- 1160
												end -- 1159
											end) -- 1158
										else -- 1162
											PushID(fileName, function() -- 1162
												if Button(gameName, Vec2(-1, 40)) then -- 1163
													return enterDemoEntry(game) -- 1164
												end -- 1163
											end) -- 1162
										end -- 1142
									end -- 1127
									NextColumn() -- 1165
									::_continue_0:: -- 1125
								end -- 1165
								Columns(1, false) -- 1166
								opened = true -- 1167
							end) -- 1121
							gameOpen = opened -- 1168
						end -- 1118
						if #doraTools > 0 and showTool then -- 1169
							local opened -- 1170
							if (filterText ~= nil) then -- 1170
								opened = showTool -- 1170
							else -- 1170
								opened = false -- 1170
							end -- 1170
							SetNextItemOpen(toolOpen) -- 1171
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1172
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1173
									Columns(maxColumns, false) -- 1174
									for _index_0 = 1, #doraTools do -- 1175
										local example = doraTools[_index_0] -- 1175
										if not match(example[1]) then -- 1176
											goto _continue_0 -- 1176
										end -- 1176
										if Button(example[1], Vec2(-1, 40)) then -- 1177
											enterDemoEntry(example) -- 1178
										end -- 1177
										NextColumn() -- 1179
										::_continue_0:: -- 1176
									end -- 1179
									Columns(1, false) -- 1180
									opened = true -- 1181
								end) -- 1173
							end) -- 1172
							toolOpen = opened -- 1182
						end -- 1169
						if #doraExamples > 0 and showExample then -- 1183
							local opened -- 1184
							if (filterText ~= nil) then -- 1184
								opened = showExample -- 1184
							else -- 1184
								opened = false -- 1184
							end -- 1184
							SetNextItemOpen(exampleOpen) -- 1185
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1186
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1187
									Columns(maxColumns, false) -- 1188
									for _index_0 = 1, #doraExamples do -- 1189
										local example = doraExamples[_index_0] -- 1189
										if not match(example[1]) then -- 1190
											goto _continue_0 -- 1190
										end -- 1190
										if Button(example[1], Vec2(-1, 40)) then -- 1191
											enterDemoEntry(example) -- 1192
										end -- 1191
										NextColumn() -- 1193
										::_continue_0:: -- 1190
									end -- 1193
									Columns(1, false) -- 1194
									opened = true -- 1195
								end) -- 1187
							end) -- 1186
							exampleOpen = opened -- 1196
						end -- 1183
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1197
							local opened -- 1198
							if (filterText ~= nil) then -- 1198
								opened = showTest -- 1198
							else -- 1198
								opened = false -- 1198
							end -- 1198
							SetNextItemOpen(testOpen) -- 1199
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1200
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1201
									Columns(maxColumns, false) -- 1202
									for _index_0 = 1, #doraTests do -- 1203
										local test = doraTests[_index_0] -- 1203
										if not match(test[1]) then -- 1204
											goto _continue_0 -- 1204
										end -- 1204
										if Button(test[1], Vec2(-1, 40)) then -- 1205
											enterDemoEntry(test) -- 1206
										end -- 1205
										NextColumn() -- 1207
										::_continue_0:: -- 1204
									end -- 1207
									for _index_0 = 1, #cppTests do -- 1208
										local test = cppTests[_index_0] -- 1208
										if not match(test[1]) then -- 1209
											goto _continue_1 -- 1209
										end -- 1209
										if Button(test[1], Vec2(-1, 40)) then -- 1210
											enterDemoEntry(test) -- 1211
										end -- 1210
										NextColumn() -- 1212
										::_continue_1:: -- 1209
									end -- 1212
									opened = true -- 1213
								end) -- 1201
							end) -- 1200
							testOpen = opened -- 1214
						end -- 1197
					end -- 1096
					::endEntry:: -- 1215
					if not anyEntryMatched then -- 1216
						SetNextWindowBgAlpha(0) -- 1217
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1218
						Begin("Entries Not Found", displayWindowFlags, function() -- 1219
							Separator() -- 1220
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1221
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1222
							return Separator() -- 1223
						end) -- 1219
					end -- 1216
					Columns(1, false) -- 1224
					Dummy(Vec2(100, 80)) -- 1225
					return ScrollWhenDraggingOnVoid() -- 1226
				end) -- 1022
			end) -- 1021
		end) -- 1020
	end -- 1226
end) -- 923
webStatus = require("Script.Dev.WebServer") -- 1228
return _module_0 -- 1228
