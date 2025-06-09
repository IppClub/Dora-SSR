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
	return _with_0 -- 581
end -- 580
setupEventHandlers() -- 605
clearTempFiles() -- 606
local stop -- 608
stop = function() -- 608
	if isInEntry then -- 609
		return false -- 609
	end -- 609
	allClear() -- 610
	isInEntry = true -- 611
	currentEntry = nil -- 612
	return true -- 613
end -- 608
_module_0["stop"] = stop -- 613
local _anon_func_3 = function(Content, Path, file, require, type) -- 635
	local scriptPath = Path:getPath(file) -- 628
	Content:insertSearchPath(1, scriptPath) -- 629
	scriptPath = Path(scriptPath, "Script") -- 630
	if Content:exist(scriptPath) then -- 631
		Content:insertSearchPath(1, scriptPath) -- 632
	end -- 631
	local result = require(file) -- 633
	if "function" == type(result) then -- 634
		result() -- 634
	end -- 634
	return nil -- 635
end -- 628
local _anon_func_4 = function(Label, _with_0, err, fontSize, width) -- 667
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 664
	label.alignment = "Left" -- 665
	label.textWidth = width - fontSize -- 666
	label.text = err -- 667
	return label -- 664
end -- 664
local enterEntryAsync -- 615
enterEntryAsync = function(entry) -- 615
	isInEntry = false -- 616
	App.idled = false -- 617
	emit(Profiler.EventName, "ClearLoader") -- 618
	currentEntry = entry -- 619
	local name, file = entry[1], entry[2] -- 620
	if cppTestSet[entry] then -- 621
		if App:runTest(name) then -- 622
			return true -- 623
		else -- 625
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 625
		end -- 622
	end -- 621
	sleep() -- 626
	return xpcall(_anon_func_3, function(msg) -- 668
		local err = debug.traceback(msg) -- 637
		Log("Error", err) -- 638
		allClear() -- 639
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 640
		local viewWidth, viewHeight -- 641
		do -- 641
			local _obj_0 = View.size -- 641
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 641
		end -- 641
		local width, height = viewWidth - 20, viewHeight - 20 -- 642
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 643
		Director.ui:addChild((function() -- 644
			local root = AlignNode() -- 644
			do -- 645
				local _obj_0 = App.bufferSize -- 645
				width, height = _obj_0.width, _obj_0.height -- 645
			end -- 645
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 646
			root:onAppChange(function(settingName) -- 647
				if settingName == "Size" then -- 647
					do -- 648
						local _obj_0 = App.bufferSize -- 648
						width, height = _obj_0.width, _obj_0.height -- 648
					end -- 648
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 649
				end -- 647
			end) -- 647
			root:addChild((function() -- 650
				local _with_0 = ScrollArea({ -- 651
					width = width, -- 651
					height = height, -- 652
					paddingX = 0, -- 653
					paddingY = 50, -- 654
					viewWidth = height, -- 655
					viewHeight = height -- 656
				}) -- 650
				root:onAlignLayout(function(w, h) -- 658
					_with_0.position = Vec2(w / 2, h / 2) -- 659
					w = w - 20 -- 660
					h = h - 20 -- 661
					_with_0.view.children.first.textWidth = w - fontSize -- 662
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 663
				end) -- 658
				_with_0.view:addChild(_anon_func_4(Label, _with_0, err, fontSize, width)) -- 664
				return _with_0 -- 650
			end)()) -- 650
			return root -- 644
		end)()) -- 644
		return err -- 668
	end, Content, Path, file, require, type) -- 668
end -- 615
_module_0["enterEntryAsync"] = enterEntryAsync -- 668
local enterDemoEntry -- 670
enterDemoEntry = function(entry) -- 670
	return thread(function() -- 670
		return enterEntryAsync(entry) -- 670
	end) -- 670
end -- 670
local reloadCurrentEntry -- 672
reloadCurrentEntry = function() -- 672
	if currentEntry then -- 673
		allClear() -- 674
		return enterDemoEntry(currentEntry) -- 675
	end -- 673
end -- 672
Director.clearColor = Color(0xff1a1a1a) -- 677
local isOSSLicenseExist = Content:exist("LICENSES") -- 679
local ossLicenses = nil -- 680
local ossLicenseOpen = false -- 681
local extraOperations -- 683
extraOperations = function() -- 683
	local zh = useChinese and isChineseSupported -- 684
	if isDesktop then -- 685
		local themeColor = App.themeColor -- 686
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 687
		do -- 688
			local changed -- 688
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 688
			if changed then -- 688
				App.alwaysOnTop = alwaysOnTop -- 689
				config.alwaysOnTop = alwaysOnTop -- 690
			end -- 688
		end -- 688
		SeparatorText(zh and "工作目录" or "Workspace") -- 691
		PushTextWrapPos(400, function() -- 692
			return TextColored(themeColor, writablePath) -- 693
		end) -- 692
		if Button(zh and "改变目录" or "Set Folder") then -- 694
			App:openFileDialog(true, function(path) -- 695
				if path ~= "" then -- 696
					return setWorkspace(path) -- 696
				end -- 696
			end) -- 695
		end -- 694
		SameLine() -- 697
		if Button(zh and "使用默认" or "Use Default") then -- 698
			setWorkspace(Content.appPath) -- 699
		end -- 698
		Separator() -- 700
	end -- 685
	if isOSSLicenseExist then -- 701
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 702
			if not ossLicenses then -- 703
				ossLicenses = { } -- 704
				local licenseText = Content:load("LICENSES") -- 705
				ossLicenseOpen = (licenseText ~= nil) -- 706
				if ossLicenseOpen then -- 706
					licenseText = licenseText:gsub("\r\n", "\n") -- 707
					for license in GSplit(licenseText, "\n--------\n", true) do -- 708
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 709
						if name then -- 709
							ossLicenses[#ossLicenses + 1] = { -- 710
								name, -- 710
								text -- 710
							} -- 710
						end -- 709
					end -- 710
				end -- 706
			else -- 712
				ossLicenseOpen = true -- 712
			end -- 703
		end -- 702
		if ossLicenseOpen then -- 713
			local width, height, themeColor -- 714
			do -- 714
				local _obj_0 = App -- 714
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 714
			end -- 714
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 715
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 716
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 717
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 720
					"NoSavedSettings" -- 720
				}, function() -- 721
					for _index_0 = 1, #ossLicenses do -- 721
						local _des_0 = ossLicenses[_index_0] -- 721
						local firstLine, text = _des_0[1], _des_0[2] -- 721
						local name, license = firstLine:match("(.+): (.+)") -- 722
						TextColored(themeColor, name) -- 723
						SameLine() -- 724
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 725
							return TextWrapped(text) -- 725
						end) -- 725
					end -- 725
				end) -- 717
			end) -- 717
		end -- 713
	end -- 701
	if not App.debugging then -- 727
		return -- 727
	end -- 727
	return TreeNode(zh and "开发操作" or "Development", function() -- 728
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 729
			OpenPopup("build") -- 729
		end -- 729
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 730
			return BeginPopup("build", function() -- 730
				if Selectable(zh and "编译" or "Compile") then -- 731
					doCompile(false) -- 731
				end -- 731
				Separator() -- 732
				if Selectable(zh and "压缩" or "Minify") then -- 733
					doCompile(true) -- 733
				end -- 733
				Separator() -- 734
				if Selectable(zh and "清理" or "Clean") then -- 735
					return doClean() -- 735
				end -- 735
			end) -- 735
		end) -- 730
		if isInEntry then -- 736
			if waitForWebStart then -- 737
				BeginDisabled(function() -- 738
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 738
				end) -- 738
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 739
				reloadDevEntry() -- 740
			end -- 737
		end -- 736
		do -- 741
			local changed -- 741
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 741
			if changed then -- 741
				View.scale = scaleContent and screenScale or 1 -- 742
			end -- 741
		end -- 741
		do -- 743
			local changed -- 743
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 743
			if changed then -- 743
				config.engineDev = engineDev -- 744
			end -- 743
		end -- 743
		if Button(zh and "开始自动测试" or "Test automatically") then -- 745
			testingThread = thread(function() -- 746
				local _ <close> = setmetatable({ }, { -- 747
					__close = function() -- 747
						allClear() -- 748
						testingThread = nil -- 749
						isInEntry = true -- 750
						currentEntry = nil -- 751
						return print("Testing done!") -- 752
					end -- 747
				}) -- 747
				for _, entry in ipairs(allEntries) do -- 753
					allClear() -- 754
					print("Start " .. tostring(entry[1])) -- 755
					enterDemoEntry(entry) -- 756
					sleep(2) -- 757
					print("Stop " .. tostring(entry[1])) -- 758
				end -- 758
			end) -- 746
		end -- 745
	end) -- 728
end -- 683
local transparant = Color(0x0) -- 760
local windowFlags = { -- 761
	"NoTitleBar", -- 761
	"NoResize", -- 761
	"NoMove", -- 761
	"NoCollapse", -- 761
	"NoSavedSettings", -- 761
	"NoBringToFrontOnFocus" -- 761
} -- 761
local initFooter = true -- 769
local _anon_func_5 = function(allEntries, currentIndex) -- 805
	if currentIndex > 1 then -- 805
		return allEntries[currentIndex - 1] -- 806
	else -- 808
		return allEntries[#allEntries] -- 808
	end -- 805
end -- 805
local _anon_func_6 = function(allEntries, currentIndex) -- 812
	if currentIndex < #allEntries then -- 812
		return allEntries[currentIndex + 1] -- 813
	else -- 815
		return allEntries[1] -- 815
	end -- 812
end -- 812
footerWindow = threadLoop(function() -- 770
	local zh = useChinese and isChineseSupported -- 771
	if HttpServer.wsConnectionCount > 0 then -- 772
		return -- 773
	end -- 772
	if Keyboard:isKeyDown("Escape") then -- 774
		allClear() -- 775
		App:shutdown() -- 776
	end -- 774
	do -- 777
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 778
		if ctrl and Keyboard:isKeyDown("Q") then -- 779
			stop() -- 780
		end -- 779
		if ctrl and Keyboard:isKeyDown("Z") then -- 781
			reloadCurrentEntry() -- 782
		end -- 781
		if ctrl and Keyboard:isKeyDown(",") then -- 783
			if showFooter then -- 784
				showStats = not showStats -- 784
			else -- 784
				showStats = true -- 784
			end -- 784
			showFooter = true -- 785
			config.showFooter = showFooter -- 786
			config.showStats = showStats -- 787
		end -- 783
		if ctrl and Keyboard:isKeyDown(".") then -- 788
			if showFooter then -- 789
				showConsole = not showConsole -- 789
			else -- 789
				showConsole = true -- 789
			end -- 789
			showFooter = true -- 790
			config.showFooter = showFooter -- 791
			config.showConsole = showConsole -- 792
		end -- 788
		if ctrl and Keyboard:isKeyDown("/") then -- 793
			showFooter = not showFooter -- 794
			config.showFooter = showFooter -- 795
		end -- 793
		local left = ctrl and Keyboard:isKeyDown("Left") -- 796
		local right = ctrl and Keyboard:isKeyDown("Right") -- 797
		local currentIndex = nil -- 798
		for i, entry in ipairs(allEntries) do -- 799
			if currentEntry == entry then -- 800
				currentIndex = i -- 801
			end -- 800
		end -- 801
		if left then -- 802
			allClear() -- 803
			if currentIndex == nil then -- 804
				currentIndex = #allEntries + 1 -- 804
			end -- 804
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 805
		end -- 802
		if right then -- 809
			allClear() -- 810
			if currentIndex == nil then -- 811
				currentIndex = 0 -- 811
			end -- 811
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 812
		end -- 809
	end -- 815
	if not showEntry then -- 816
		return -- 816
	end -- 816
	local width, height -- 818
	do -- 818
		local _obj_0 = App.visualSize -- 818
		width, height = _obj_0.width, _obj_0.height -- 818
	end -- 818
	SetNextWindowSize(Vec2(50, 50)) -- 819
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 820
	PushStyleColor("WindowBg", transparant, function() -- 821
		return Begin("Show", windowFlags, function() -- 821
			if isInEntry or width >= 540 then -- 822
				local changed -- 823
				changed, showFooter = Checkbox("##dev", showFooter) -- 823
				if changed then -- 823
					config.showFooter = showFooter -- 824
				end -- 823
			end -- 822
		end) -- 824
	end) -- 821
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 826
		reloadDevEntry() -- 830
	end -- 826
	if initFooter then -- 831
		initFooter = false -- 832
	else -- 834
		if not showFooter then -- 834
			return -- 834
		end -- 834
	end -- 831
	SetNextWindowSize(Vec2(width, 50)) -- 836
	SetNextWindowPos(Vec2(0, height - 50)) -- 837
	SetNextWindowBgAlpha(0.35) -- 838
	do -- 839
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 840
			return Begin("Footer", windowFlags, function() -- 841
				Dummy(Vec2(width - 20, 0)) -- 842
				do -- 843
					local changed -- 843
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 843
					if changed then -- 843
						config.showStats = showStats -- 844
					end -- 843
				end -- 843
				SameLine() -- 845
				do -- 846
					local changed -- 846
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 846
					if changed then -- 846
						config.showConsole = showConsole -- 847
					end -- 846
				end -- 846
				if config.updateNotification then -- 848
					SameLine() -- 849
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 850
						allClear() -- 851
						config.updateNotification = false -- 852
						enterDemoEntry({ -- 854
							"SelfUpdater", -- 854
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 855
						}) -- 853
					end -- 850
				end -- 848
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
			end) -- 841
		end) -- 840
	end -- 890
end) -- 770
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
				if fullWidth >= 400 then -- 998
					SameLine() -- 999
					Dummy(Vec2(fullWidth - 400, 0)) -- 1000
					SameLine() -- 1001
					SetNextItemWidth(zh and -90 or -140) -- 1002
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1003
						"AutoSelectAll" -- 1003
					}) then -- 1003
						config.filter = filterBuf.text -- 1004
					end -- 1003
					SameLine() -- 1005
					if Button(zh and '下载' or 'Download') then -- 1006
						allClear() -- 1007
						enterDemoEntry({ -- 1009
							"ResourceDownloader", -- 1009
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1010
						}) -- 1008
					end -- 1006
				end -- 998
				Separator() -- 1012
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1013
			end) -- 992
		end) -- 991
	end -- 1013
	anyEntryMatched = false -- 1015
	SetNextWindowPos(Vec2(0, 50)) -- 1016
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1017
	do -- 1018
		return PushStyleColor("WindowBg", transparant, function() -- 1019
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1020
				return Begin("Content", windowFlags, function() -- 1021
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 1022
					if filterText then -- 1023
						filterText = filterText:lower() -- 1023
					end -- 1023
					if #gamesInDev > 0 then -- 1024
						for _index_0 = 1, #gamesInDev do -- 1025
							local game = gamesInDev[_index_0] -- 1025
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1026
							local showSep = false -- 1027
							if match(gameName) then -- 1028
								Columns(1, false) -- 1029
								TextColored(themeColor, zh and "项目：" or "Project:") -- 1030
								SameLine() -- 1031
								Text(gameName) -- 1032
								Separator() -- 1033
								if bannerFile then -- 1034
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1035
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1036
									local sizing <const> = 0.8 -- 1037
									texHeight = displayWidth * sizing * texHeight / texWidth -- 1038
									texWidth = displayWidth * sizing -- 1039
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1040
									Dummy(Vec2(padding, 0)) -- 1041
									SameLine() -- 1042
									PushID(fileName, function() -- 1043
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1044
											return enterDemoEntry(game) -- 1045
										end -- 1044
									end) -- 1043
								else -- 1047
									PushID(fileName, function() -- 1047
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 1048
											return enterDemoEntry(game) -- 1049
										end -- 1048
									end) -- 1047
								end -- 1034
								NextColumn() -- 1050
								showSep = true -- 1051
							end -- 1028
							if #examples > 0 then -- 1052
								local showExample = false -- 1053
								for _index_1 = 1, #examples do -- 1054
									local example = examples[_index_1] -- 1054
									if match(example[1]) then -- 1055
										showExample = true -- 1056
										break -- 1057
									end -- 1055
								end -- 1057
								if showExample then -- 1058
									Columns(1, false) -- 1059
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1060
									SameLine() -- 1061
									Text(gameName) -- 1062
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1063
										Columns(maxColumns, false) -- 1064
										for _index_1 = 1, #examples do -- 1065
											local example = examples[_index_1] -- 1065
											if not match(example[1]) then -- 1066
												goto _continue_0 -- 1066
											end -- 1066
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1067
												if Button(example[1], Vec2(-1, 40)) then -- 1068
													enterDemoEntry(example) -- 1069
												end -- 1068
												return NextColumn() -- 1070
											end) -- 1067
											showSep = true -- 1071
											::_continue_0:: -- 1066
										end -- 1071
									end) -- 1063
								end -- 1058
							end -- 1052
							if #tests > 0 then -- 1072
								local showTest = false -- 1073
								for _index_1 = 1, #tests do -- 1074
									local test = tests[_index_1] -- 1074
									if match(test[1]) then -- 1075
										showTest = true -- 1076
										break -- 1077
									end -- 1075
								end -- 1077
								if showTest then -- 1078
									Columns(1, false) -- 1079
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1080
									SameLine() -- 1081
									Text(gameName) -- 1082
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1083
										Columns(maxColumns, false) -- 1084
										for _index_1 = 1, #tests do -- 1085
											local test = tests[_index_1] -- 1085
											if not match(test[1]) then -- 1086
												goto _continue_0 -- 1086
											end -- 1086
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1087
												if Button(test[1], Vec2(-1, 40)) then -- 1088
													enterDemoEntry(test) -- 1089
												end -- 1088
												return NextColumn() -- 1090
											end) -- 1087
											showSep = true -- 1091
											::_continue_0:: -- 1086
										end -- 1091
									end) -- 1083
								end -- 1078
							end -- 1072
							if showSep then -- 1092
								Columns(1, false) -- 1093
								Separator() -- 1094
							end -- 1092
						end -- 1094
					end -- 1024
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1095
						local showGame = false -- 1096
						for _index_0 = 1, #games do -- 1097
							local _des_0 = games[_index_0] -- 1097
							local name = _des_0[1] -- 1097
							if match(name) then -- 1098
								showGame = true -- 1098
							end -- 1098
						end -- 1098
						local showTool = false -- 1099
						for _index_0 = 1, #doraTools do -- 1100
							local _des_0 = doraTools[_index_0] -- 1100
							local name = _des_0[1] -- 1100
							if match(name) then -- 1101
								showTool = true -- 1101
							end -- 1101
						end -- 1101
						local showExample = false -- 1102
						for _index_0 = 1, #doraExamples do -- 1103
							local _des_0 = doraExamples[_index_0] -- 1103
							local name = _des_0[1] -- 1103
							if match(name) then -- 1104
								showExample = true -- 1104
							end -- 1104
						end -- 1104
						local showTest = false -- 1105
						for _index_0 = 1, #doraTests do -- 1106
							local _des_0 = doraTests[_index_0] -- 1106
							local name = _des_0[1] -- 1106
							if match(name) then -- 1107
								showTest = true -- 1107
							end -- 1107
						end -- 1107
						for _index_0 = 1, #cppTests do -- 1108
							local _des_0 = cppTests[_index_0] -- 1108
							local name = _des_0[1] -- 1108
							if match(name) then -- 1109
								showTest = true -- 1109
							end -- 1109
						end -- 1109
						if not (showGame or showTool or showExample or showTest) then -- 1110
							goto endEntry -- 1110
						end -- 1110
						Columns(1, false) -- 1111
						TextColored(themeColor, "Dora SSR:") -- 1112
						SameLine() -- 1113
						Text(zh and "开发示例" or "Development Showcase") -- 1114
						Separator() -- 1115
						local demoViewWith <const> = 400 -- 1116
						if #games > 0 and showGame then -- 1117
							local opened -- 1118
							if (filterText ~= nil) then -- 1118
								opened = showGame -- 1118
							else -- 1118
								opened = false -- 1118
							end -- 1118
							SetNextItemOpen(gameOpen) -- 1119
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1120
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1121
								Columns(columns, false) -- 1122
								for _index_0 = 1, #games do -- 1123
									local game = games[_index_0] -- 1123
									if not match(game[1]) then -- 1124
										goto _continue_0 -- 1124
									end -- 1124
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1125
									if columns > 1 then -- 1126
										if bannerFile then -- 1127
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1128
											local displayWidth <const> = demoViewWith - 40 -- 1129
											texHeight = displayWidth * texHeight / texWidth -- 1130
											texWidth = displayWidth -- 1131
											Text(gameName) -- 1132
											PushID(fileName, function() -- 1133
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1134
													return enterDemoEntry(game) -- 1135
												end -- 1134
											end) -- 1133
										else -- 1137
											PushID(fileName, function() -- 1137
												if Button(gameName, Vec2(-1, 40)) then -- 1138
													return enterDemoEntry(game) -- 1139
												end -- 1138
											end) -- 1137
										end -- 1127
									else -- 1141
										if bannerFile then -- 1141
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1142
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1143
											local sizing = 0.8 -- 1144
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1145
											texWidth = displayWidth * sizing -- 1146
											if texWidth > 500 then -- 1147
												sizing = 0.6 -- 1148
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1149
												texWidth = displayWidth * sizing -- 1150
											end -- 1147
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1151
											Dummy(Vec2(padding, 0)) -- 1152
											SameLine() -- 1153
											Text(gameName) -- 1154
											Dummy(Vec2(padding, 0)) -- 1155
											SameLine() -- 1156
											PushID(fileName, function() -- 1157
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1158
													return enterDemoEntry(game) -- 1159
												end -- 1158
											end) -- 1157
										else -- 1161
											PushID(fileName, function() -- 1161
												if Button(gameName, Vec2(-1, 40)) then -- 1162
													return enterDemoEntry(game) -- 1163
												end -- 1162
											end) -- 1161
										end -- 1141
									end -- 1126
									NextColumn() -- 1164
									::_continue_0:: -- 1124
								end -- 1164
								Columns(1, false) -- 1165
								opened = true -- 1166
							end) -- 1120
							gameOpen = opened -- 1167
						end -- 1117
						if #doraTools > 0 and showTool then -- 1168
							local opened -- 1169
							if (filterText ~= nil) then -- 1169
								opened = showTool -- 1169
							else -- 1169
								opened = false -- 1169
							end -- 1169
							SetNextItemOpen(toolOpen) -- 1170
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1171
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1172
									Columns(maxColumns, false) -- 1173
									for _index_0 = 1, #doraTools do -- 1174
										local example = doraTools[_index_0] -- 1174
										if not match(example[1]) then -- 1175
											goto _continue_0 -- 1175
										end -- 1175
										if Button(example[1], Vec2(-1, 40)) then -- 1176
											enterDemoEntry(example) -- 1177
										end -- 1176
										NextColumn() -- 1178
										::_continue_0:: -- 1175
									end -- 1178
									Columns(1, false) -- 1179
									opened = true -- 1180
								end) -- 1172
							end) -- 1171
							toolOpen = opened -- 1181
						end -- 1168
						if #doraExamples > 0 and showExample then -- 1182
							local opened -- 1183
							if (filterText ~= nil) then -- 1183
								opened = showExample -- 1183
							else -- 1183
								opened = false -- 1183
							end -- 1183
							SetNextItemOpen(exampleOpen) -- 1184
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1185
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1186
									Columns(maxColumns, false) -- 1187
									for _index_0 = 1, #doraExamples do -- 1188
										local example = doraExamples[_index_0] -- 1188
										if not match(example[1]) then -- 1189
											goto _continue_0 -- 1189
										end -- 1189
										if Button(example[1], Vec2(-1, 40)) then -- 1190
											enterDemoEntry(example) -- 1191
										end -- 1190
										NextColumn() -- 1192
										::_continue_0:: -- 1189
									end -- 1192
									Columns(1, false) -- 1193
									opened = true -- 1194
								end) -- 1186
							end) -- 1185
							exampleOpen = opened -- 1195
						end -- 1182
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1196
							local opened -- 1197
							if (filterText ~= nil) then -- 1197
								opened = showTest -- 1197
							else -- 1197
								opened = false -- 1197
							end -- 1197
							SetNextItemOpen(testOpen) -- 1198
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1199
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1200
									Columns(maxColumns, false) -- 1201
									for _index_0 = 1, #doraTests do -- 1202
										local test = doraTests[_index_0] -- 1202
										if not match(test[1]) then -- 1203
											goto _continue_0 -- 1203
										end -- 1203
										if Button(test[1], Vec2(-1, 40)) then -- 1204
											enterDemoEntry(test) -- 1205
										end -- 1204
										NextColumn() -- 1206
										::_continue_0:: -- 1203
									end -- 1206
									for _index_0 = 1, #cppTests do -- 1207
										local test = cppTests[_index_0] -- 1207
										if not match(test[1]) then -- 1208
											goto _continue_1 -- 1208
										end -- 1208
										if Button(test[1], Vec2(-1, 40)) then -- 1209
											enterDemoEntry(test) -- 1210
										end -- 1209
										NextColumn() -- 1211
										::_continue_1:: -- 1208
									end -- 1211
									opened = true -- 1212
								end) -- 1200
							end) -- 1199
							testOpen = opened -- 1213
						end -- 1196
					end -- 1095
					::endEntry:: -- 1214
					if not anyEntryMatched then -- 1215
						SetNextWindowBgAlpha(0) -- 1216
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1217
						Begin("Entries Not Found", displayWindowFlags, function() -- 1218
							Separator() -- 1219
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1220
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1221
							return Separator() -- 1222
						end) -- 1218
					end -- 1215
					Columns(1, false) -- 1223
					Dummy(Vec2(100, 80)) -- 1224
					return ScrollWhenDraggingOnVoid() -- 1225
				end) -- 1021
			end) -- 1020
		end) -- 1019
	end -- 1225
end) -- 922
webStatus = require("Script.Dev.WebServer") -- 1227
return _module_0 -- 1227
