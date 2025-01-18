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
			App.winSize = Size(640, 480) -- 189
		end -- 188
	end -- 186
end -- 185
local updateCheck -- 191
updateCheck = function() -- 191
	return thread(function() -- 191
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 192
		if res then -- 192
			local data = json.load(res) -- 193
			if data then -- 193
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 194
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 195
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 196
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 197
				if na < a then -- 198
					goto not_new_version -- 199
				end -- 198
				if na == a then -- 200
					if nb < b then -- 201
						goto not_new_version -- 202
					end -- 201
					if nb == b then -- 203
						if nc < c then -- 204
							goto not_new_version -- 205
						end -- 204
						if nc == c then -- 206
							goto not_new_version -- 207
						end -- 206
					end -- 203
				end -- 200
				config.updateNotification = true -- 208
				::not_new_version:: -- 209
				config.lastUpdateCheck = os.time() -- 210
			end -- 193
		end -- 192
	end) -- 210
end -- 191
if (config.lastUpdateCheck ~= nil) then -- 212
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 213
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 214
		updateCheck() -- 215
	end -- 214
else -- 217
	updateCheck() -- 217
end -- 212
local Set, Struct, LintYueGlobals, GSplit -- 219
do -- 219
	local _obj_0 = require("Utils") -- 219
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 219
end -- 219
local yueext = yue.options.extension -- 220
local isChineseSupported = IsFontLoaded() -- 222
if not isChineseSupported then -- 223
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 224
		isChineseSupported = true -- 225
	end) -- 224
end -- 223
local building = false -- 227
local getAllFiles -- 229
getAllFiles = function(path, exts, recursive) -- 229
	if recursive == nil then -- 229
		recursive = true -- 229
	end -- 229
	local filters = Set(exts) -- 230
	local files -- 231
	if recursive then -- 231
		files = Content:getAllFiles(path) -- 232
	else -- 234
		files = Content:getFiles(path) -- 234
	end -- 231
	local _accum_0 = { } -- 235
	local _len_0 = 1 -- 235
	for _index_0 = 1, #files do -- 235
		local file = files[_index_0] -- 235
		if not filters[Path:getExt(file)] then -- 236
			goto _continue_0 -- 236
		end -- 236
		_accum_0[_len_0] = file -- 237
		_len_0 = _len_0 + 1 -- 237
		::_continue_0:: -- 236
	end -- 237
	return _accum_0 -- 237
end -- 229
_module_0["getAllFiles"] = getAllFiles -- 237
local getFileEntries -- 239
getFileEntries = function(path, recursive, excludeFiles) -- 239
	if recursive == nil then -- 239
		recursive = true -- 239
	end -- 239
	if excludeFiles == nil then -- 239
		excludeFiles = nil -- 239
	end -- 239
	local entries = { } -- 240
	local excludes -- 241
	if excludeFiles then -- 241
		excludes = Set(excludeFiles) -- 242
	end -- 241
	local _list_0 = getAllFiles(path, { -- 243
		"lua", -- 243
		"xml", -- 243
		yueext, -- 243
		"tl" -- 243
	}, recursive) -- 243
	for _index_0 = 1, #_list_0 do -- 243
		local file = _list_0[_index_0] -- 243
		local entryName = Path:getName(file) -- 244
		if excludes and excludes[entryName] then -- 245
			goto _continue_0 -- 246
		end -- 245
		local entryAdded = false -- 247
		for _index_1 = 1, #entries do -- 248
			local _des_0 = entries[_index_1] -- 248
			local ename = _des_0[1] -- 248
			if entryName == ename then -- 249
				entryAdded = true -- 250
				break -- 251
			end -- 249
		end -- 251
		if entryAdded then -- 252
			goto _continue_0 -- 252
		end -- 252
		local fileName = Path:replaceExt(file, "") -- 253
		fileName = Path(path, fileName) -- 254
		local entry = { -- 255
			entryName, -- 255
			fileName -- 255
		} -- 255
		entries[#entries + 1] = entry -- 256
		::_continue_0:: -- 244
	end -- 256
	table.sort(entries, function(a, b) -- 257
		return a[1] < b[1] -- 257
	end) -- 257
	return entries -- 258
end -- 239
local getProjectEntries -- 260
getProjectEntries = function(path) -- 260
	local entries = { } -- 261
	local _list_0 = Content:getDirs(path) -- 262
	for _index_0 = 1, #_list_0 do -- 262
		local dir = _list_0[_index_0] -- 262
		if dir:match("^%.") then -- 263
			goto _continue_0 -- 263
		end -- 263
		local _list_1 = getAllFiles(Path(path, dir), { -- 264
			"lua", -- 264
			"xml", -- 264
			yueext, -- 264
			"tl", -- 264
			"wasm" -- 264
		}) -- 264
		for _index_1 = 1, #_list_1 do -- 264
			local file = _list_1[_index_1] -- 264
			if "init" == Path:getName(file):lower() then -- 265
				local fileName = Path:replaceExt(file, "") -- 266
				fileName = Path(path, dir, fileName) -- 267
				local entryName = Path:getName(Path:getPath(fileName)) -- 268
				local entryAdded = false -- 269
				for _index_2 = 1, #entries do -- 270
					local _des_0 = entries[_index_2] -- 270
					local ename = _des_0[1] -- 270
					if entryName == ename then -- 271
						entryAdded = true -- 272
						break -- 273
					end -- 271
				end -- 273
				if entryAdded then -- 274
					goto _continue_1 -- 274
				end -- 274
				local examples = { } -- 275
				local tests = { } -- 276
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 277
				if Content:exist(examplePath) then -- 278
					local _list_2 = getFileEntries(examplePath) -- 279
					for _index_2 = 1, #_list_2 do -- 279
						local _des_0 = _list_2[_index_2] -- 279
						local name, ePath = _des_0[1], _des_0[2] -- 279
						local entry = { -- 280
							name, -- 280
							Path(path, dir, Path:getPath(file), ePath) -- 280
						} -- 280
						examples[#examples + 1] = entry -- 281
					end -- 281
				end -- 278
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 282
				if Content:exist(testPath) then -- 283
					local _list_2 = getFileEntries(testPath) -- 284
					for _index_2 = 1, #_list_2 do -- 284
						local _des_0 = _list_2[_index_2] -- 284
						local name, tPath = _des_0[1], _des_0[2] -- 284
						local entry = { -- 285
							name, -- 285
							Path(path, dir, Path:getPath(file), tPath) -- 285
						} -- 285
						tests[#tests + 1] = entry -- 286
					end -- 286
				end -- 283
				local entry = { -- 287
					entryName, -- 287
					fileName, -- 287
					examples, -- 287
					tests -- 287
				} -- 287
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 288
				if not Content:exist(bannerFile) then -- 289
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 290
					if not Content:exist(bannerFile) then -- 291
						bannerFile = nil -- 291
					end -- 291
				end -- 289
				if bannerFile then -- 292
					thread(function() -- 292
						if Cache:loadAsync(bannerFile) then -- 293
							local bannerTex = Texture2D(bannerFile) -- 294
							if bannerTex then -- 295
								entry[#entry + 1] = bannerFile -- 296
								entry[#entry + 1] = bannerTex -- 297
							end -- 295
						end -- 293
					end) -- 292
				end -- 292
				entries[#entries + 1] = entry -- 298
			end -- 265
			::_continue_1:: -- 265
		end -- 298
		::_continue_0:: -- 263
	end -- 298
	table.sort(entries, function(a, b) -- 299
		return a[1] < b[1] -- 299
	end) -- 299
	return entries -- 300
end -- 260
local gamesInDev, games -- 302
local doraTools, doraExamples, doraTests -- 303
local cppTests, cppTestSet -- 304
local allEntries -- 305
local _anon_func_1 = function(App) -- 313
	if not App.debugging then -- 313
		return { -- 313
			"ImGui" -- 313
		} -- 313
	end -- 313
end -- 313
local updateEntries -- 307
updateEntries = function() -- 307
	gamesInDev = getProjectEntries(Content.writablePath) -- 308
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 309
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 311
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 312
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test"), true, _anon_func_1(App)) -- 313
	cppTests = { } -- 315
	local _list_0 = App.testNames -- 316
	for _index_0 = 1, #_list_0 do -- 316
		local name = _list_0[_index_0] -- 316
		local entry = { -- 317
			name -- 317
		} -- 317
		cppTests[#cppTests + 1] = entry -- 318
	end -- 318
	cppTestSet = Set(cppTests) -- 319
	allEntries = { } -- 321
	for _index_0 = 1, #gamesInDev do -- 322
		local game = gamesInDev[_index_0] -- 322
		allEntries[#allEntries + 1] = game -- 323
		local examples, tests = game[3], game[4] -- 324
		for _index_1 = 1, #examples do -- 325
			local example = examples[_index_1] -- 325
			allEntries[#allEntries + 1] = example -- 326
		end -- 326
		for _index_1 = 1, #tests do -- 327
			local test = tests[_index_1] -- 327
			allEntries[#allEntries + 1] = test -- 328
		end -- 328
	end -- 328
	for _index_0 = 1, #games do -- 329
		local game = games[_index_0] -- 329
		allEntries[#allEntries + 1] = game -- 330
		local examples, tests = game[3], game[4] -- 331
		for _index_1 = 1, #examples do -- 332
			local example = examples[_index_1] -- 332
			doraExamples[#doraExamples + 1] = example -- 333
		end -- 333
		for _index_1 = 1, #tests do -- 334
			local test = tests[_index_1] -- 334
			doraTests[#doraTests + 1] = test -- 335
		end -- 335
	end -- 335
	local _list_1 = { -- 337
		doraExamples, -- 337
		doraTests, -- 338
		cppTests -- 339
	} -- 336
	for _index_0 = 1, #_list_1 do -- 340
		local group = _list_1[_index_0] -- 336
		for _index_1 = 1, #group do -- 341
			local entry = group[_index_1] -- 341
			allEntries[#allEntries + 1] = entry -- 342
		end -- 342
	end -- 342
end -- 307
updateEntries() -- 344
local doCompile -- 346
doCompile = function(minify) -- 346
	if building then -- 347
		return -- 347
	end -- 347
	building = true -- 348
	local startTime = App.runningTime -- 349
	local luaFiles = { } -- 350
	local yueFiles = { } -- 351
	local xmlFiles = { } -- 352
	local tlFiles = { } -- 353
	local writablePath = Content.writablePath -- 354
	local buildPaths = { -- 356
		{ -- 357
			Path(Content.assetPath), -- 357
			Path(writablePath, ".build"), -- 358
			"" -- 359
		} -- 356
	} -- 355
	for _index_0 = 1, #gamesInDev do -- 362
		local _des_0 = gamesInDev[_index_0] -- 362
		local entryFile = _des_0[2] -- 362
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 363
		buildPaths[#buildPaths + 1] = { -- 365
			Path(writablePath, gamePath), -- 365
			Path(writablePath, ".build", gamePath), -- 366
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 367
			gamePath -- 368
		} -- 364
	end -- 368
	for _index_0 = 1, #buildPaths do -- 369
		local _des_0 = buildPaths[_index_0] -- 369
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 369
		if not Content:exist(inputPath) then -- 370
			goto _continue_0 -- 370
		end -- 370
		local _list_0 = getAllFiles(inputPath, { -- 372
			"lua" -- 372
		}) -- 372
		for _index_1 = 1, #_list_0 do -- 372
			local file = _list_0[_index_1] -- 372
			luaFiles[#luaFiles + 1] = { -- 374
				file, -- 374
				Path(inputPath, file), -- 375
				Path(outputPath, file), -- 376
				gamePath -- 377
			} -- 373
		end -- 377
		local _list_1 = getAllFiles(inputPath, { -- 379
			yueext -- 379
		}) -- 379
		for _index_1 = 1, #_list_1 do -- 379
			local file = _list_1[_index_1] -- 379
			yueFiles[#yueFiles + 1] = { -- 381
				file, -- 381
				Path(inputPath, file), -- 382
				Path(outputPath, Path:replaceExt(file, "lua")), -- 383
				searchPath, -- 384
				gamePath -- 385
			} -- 380
		end -- 385
		local _list_2 = getAllFiles(inputPath, { -- 387
			"xml" -- 387
		}) -- 387
		for _index_1 = 1, #_list_2 do -- 387
			local file = _list_2[_index_1] -- 387
			xmlFiles[#xmlFiles + 1] = { -- 389
				file, -- 389
				Path(inputPath, file), -- 390
				Path(outputPath, Path:replaceExt(file, "lua")), -- 391
				gamePath -- 392
			} -- 388
		end -- 392
		local _list_3 = getAllFiles(inputPath, { -- 394
			"tl" -- 394
		}) -- 394
		for _index_1 = 1, #_list_3 do -- 394
			local file = _list_3[_index_1] -- 394
			if not file:match(".*%.d%.tl$") then -- 395
				tlFiles[#tlFiles + 1] = { -- 397
					file, -- 397
					Path(inputPath, file), -- 398
					Path(outputPath, Path:replaceExt(file, "lua")), -- 399
					searchPath, -- 400
					gamePath -- 401
				} -- 396
			end -- 395
		end -- 401
		::_continue_0:: -- 370
	end -- 401
	local paths -- 403
	do -- 403
		local _tbl_0 = { } -- 403
		local _list_0 = { -- 404
			luaFiles, -- 404
			yueFiles, -- 404
			xmlFiles, -- 404
			tlFiles -- 404
		} -- 404
		for _index_0 = 1, #_list_0 do -- 404
			local files = _list_0[_index_0] -- 404
			for _index_1 = 1, #files do -- 405
				local file = files[_index_1] -- 405
				_tbl_0[Path:getPath(file[3])] = true -- 403
			end -- 403
		end -- 403
		paths = _tbl_0 -- 403
	end -- 405
	for path in pairs(paths) do -- 407
		Content:mkdir(path) -- 407
	end -- 407
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 409
	local fileCount = 0 -- 410
	local errors = { } -- 411
	for _index_0 = 1, #yueFiles do -- 412
		local _des_0 = yueFiles[_index_0] -- 412
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 412
		local filename -- 413
		if gamePath then -- 413
			filename = Path(gamePath, file) -- 413
		else -- 413
			filename = file -- 413
		end -- 413
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 414
			if not codes then -- 415
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 416
				return -- 417
			end -- 415
			local success, result = LintYueGlobals(codes, globals) -- 418
			if success then -- 419
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 420
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 421
				codes = codes:gsub("^\n*", "") -- 422
				if not (result == "") then -- 423
					result = result .. "\n" -- 423
				end -- 423
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 424
			else -- 426
				local yueCodes = Content:load(input) -- 426
				if yueCodes then -- 426
					local globalErrors = { } -- 427
					for _index_1 = 1, #result do -- 428
						local _des_1 = result[_index_1] -- 428
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 428
						local countLine = 1 -- 429
						local code = "" -- 430
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 431
							if countLine == line then -- 432
								code = lineCode -- 433
								break -- 434
							end -- 432
							countLine = countLine + 1 -- 435
						end -- 435
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 436
					end -- 436
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 437
				else -- 439
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 439
				end -- 426
			end -- 419
		end, function(success) -- 414
			if success then -- 440
				print("Yue compiled: " .. tostring(filename)) -- 440
			end -- 440
			fileCount = fileCount + 1 -- 441
		end) -- 414
	end -- 441
	thread(function() -- 443
		for _index_0 = 1, #xmlFiles do -- 444
			local _des_0 = xmlFiles[_index_0] -- 444
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 444
			local filename -- 445
			if gamePath then -- 445
				filename = Path(gamePath, file) -- 445
			else -- 445
				filename = file -- 445
			end -- 445
			local sourceCodes = Content:loadAsync(input) -- 446
			local codes, err = xml.tolua(sourceCodes) -- 447
			if not codes then -- 448
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 449
			else -- 451
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 451
				print("Xml compiled: " .. tostring(filename)) -- 452
			end -- 448
			fileCount = fileCount + 1 -- 453
		end -- 453
	end) -- 443
	thread(function() -- 455
		for _index_0 = 1, #tlFiles do -- 456
			local _des_0 = tlFiles[_index_0] -- 456
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 456
			local filename -- 457
			if gamePath then -- 457
				filename = Path(gamePath, file) -- 457
			else -- 457
				filename = file -- 457
			end -- 457
			local sourceCodes = Content:loadAsync(input) -- 458
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 459
			if not codes then -- 460
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 461
			else -- 463
				Content:saveAsync(output, codes) -- 463
				print("Teal compiled: " .. tostring(filename)) -- 464
			end -- 460
			fileCount = fileCount + 1 -- 465
		end -- 465
	end) -- 455
	return thread(function() -- 467
		wait(function() -- 468
			return fileCount == totalFiles -- 468
		end) -- 468
		if minify then -- 469
			local _list_0 = { -- 470
				yueFiles, -- 470
				xmlFiles, -- 470
				tlFiles -- 470
			} -- 470
			for _index_0 = 1, #_list_0 do -- 470
				local files = _list_0[_index_0] -- 470
				for _index_1 = 1, #files do -- 470
					local file = files[_index_1] -- 470
					local output = Path:replaceExt(file[3], "lua") -- 471
					luaFiles[#luaFiles + 1] = { -- 473
						Path:replaceExt(file[1], "lua"), -- 473
						output, -- 474
						output -- 475
					} -- 472
				end -- 475
			end -- 475
			local FormatMini -- 477
			do -- 477
				local _obj_0 = require("luaminify") -- 477
				FormatMini = _obj_0.FormatMini -- 477
			end -- 477
			for _index_0 = 1, #luaFiles do -- 478
				local _des_0 = luaFiles[_index_0] -- 478
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 478
				if Content:exist(input) then -- 479
					local sourceCodes = Content:loadAsync(input) -- 480
					local res, err = FormatMini(sourceCodes) -- 481
					if res then -- 482
						Content:saveAsync(output, res) -- 483
						print("Minify: " .. tostring(file)) -- 484
					else -- 486
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 486
					end -- 482
				else -- 488
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 488
				end -- 479
			end -- 488
			package.loaded["luaminify.FormatMini"] = nil -- 489
			package.loaded["luaminify.ParseLua"] = nil -- 490
			package.loaded["luaminify.Scope"] = nil -- 491
			package.loaded["luaminify.Util"] = nil -- 492
		end -- 469
		local errorMessage = table.concat(errors, "\n") -- 493
		if errorMessage ~= "" then -- 494
			print("\n" .. errorMessage) -- 494
		end -- 494
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 495
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 496
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 497
		Content:clearPathCache() -- 498
		teal.clear() -- 499
		yue.clear() -- 500
		building = false -- 501
	end) -- 501
end -- 346
local doClean -- 503
doClean = function() -- 503
	if building then -- 504
		return -- 504
	end -- 504
	local writablePath = Content.writablePath -- 505
	local targetDir = Path(writablePath, ".build") -- 506
	Content:clearPathCache() -- 507
	if Content:remove(targetDir) then -- 508
		return print("Cleaned: " .. tostring(targetDir)) -- 509
	end -- 508
end -- 503
local screenScale = 2.0 -- 511
local scaleContent = false -- 512
local isInEntry = true -- 513
local currentEntry = nil -- 514
local footerWindow = nil -- 516
local entryWindow = nil -- 517
local testingThread = nil -- 518
local setupEventHandlers = nil -- 520
local allClear -- 522
allClear = function() -- 522
	local _list_0 = Routine -- 523
	for _index_0 = 1, #_list_0 do -- 523
		local routine = _list_0[_index_0] -- 523
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 525
			goto _continue_0 -- 526
		else -- 528
			Routine:remove(routine) -- 528
		end -- 528
		::_continue_0:: -- 524
	end -- 528
	for _index_0 = 1, #moduleCache do -- 529
		local module = moduleCache[_index_0] -- 529
		package.loaded[module] = nil -- 530
	end -- 530
	moduleCache = { } -- 531
	Director:cleanup() -- 532
	Cache:unload() -- 533
	Entity:clear() -- 534
	Platformer.Data:clear() -- 535
	Platformer.UnitAction:clear() -- 536
	Audio:stopStream(0.5) -- 537
	Struct:clear() -- 538
	View.postEffect = nil -- 539
	View.scale = scaleContent and screenScale or 1 -- 540
	Director.clearColor = Color(0xff1a1a1a) -- 541
	teal.clear() -- 542
	yue.clear() -- 543
	for _, item in pairs(ubox()) do -- 544
		local node = tolua.cast(item, "Node") -- 545
		if node then -- 545
			node:cleanup() -- 545
		end -- 545
	end -- 545
	collectgarbage() -- 546
	collectgarbage() -- 547
	setupEventHandlers() -- 548
	Content.searchPaths = searchPaths -- 549
	App.idled = true -- 550
	return Wasm:clear() -- 551
end -- 522
_module_0["allClear"] = allClear -- 551
local clearTempFiles -- 553
clearTempFiles = function() -- 553
	local writablePath = Content.writablePath -- 554
	Content:remove(Path(writablePath, ".upload")) -- 555
	return Content:remove(Path(writablePath, ".download")) -- 556
end -- 553
local waitForWebStart = true -- 558
thread(function() -- 559
	sleep(2) -- 560
	waitForWebStart = false -- 561
end) -- 559
local reloadDevEntry -- 563
reloadDevEntry = function() -- 563
	return thread(function() -- 563
		waitForWebStart = true -- 564
		doClean() -- 565
		allClear() -- 566
		_G.require = oldRequire -- 567
		Dora.require = oldRequire -- 568
		package.loaded["Script.Dev.Entry"] = nil -- 569
		return Director.systemScheduler:schedule(function() -- 570
			Routine:clear() -- 571
			oldRequire("Script.Dev.Entry") -- 572
			return true -- 573
		end) -- 573
	end) -- 573
end -- 563
local setWorkspace -- 575
setWorkspace = function(path) -- 575
	Content.writablePath = path -- 576
	config.writablePath = Content.writablePath -- 577
	return thread(function() -- 578
		sleep() -- 579
		return reloadDevEntry() -- 580
	end) -- 580
end -- 575
local _anon_func_2 = function(App, _with_0) -- 595
	local _val_0 = App.platform -- 595
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 595
end -- 595
setupEventHandlers = function() -- 582
	local _with_0 = Director.postNode -- 583
	_with_0:onAppEvent(function(eventType) -- 584
		if eventType == "Quit" then -- 584
			allClear() -- 585
			return clearTempFiles() -- 586
		end -- 584
	end) -- 584
	_with_0:onAppChange(function(settingName) -- 587
		if "Theme" == settingName then -- 588
			config.themeColor = App.themeColor:toARGB() -- 589
		elseif "Locale" == settingName then -- 590
			config.locale = App.locale -- 591
			updateLocale() -- 592
			return teal.clear(true) -- 593
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 594
			if _anon_func_2(App, _with_0) then -- 595
				if "FullScreen" == settingName then -- 597
					config.fullScreen = App.fullScreen -- 597
				elseif "Position" == settingName then -- 598
					local _obj_0 = App.winPosition -- 598
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 598
				elseif "Size" == settingName then -- 599
					local width, height -- 600
					do -- 600
						local _obj_0 = App.winSize -- 600
						width, height = _obj_0.width, _obj_0.height -- 600
					end -- 600
					config.winWidth = width -- 601
					config.winHeight = height -- 602
				end -- 602
			end -- 595
		end -- 602
	end) -- 587
	_with_0:onAppWS(function(eventType) -- 603
		if eventType == "Close" then -- 603
			if HttpServer.wsConnectionCount == 0 then -- 604
				return updateEntries() -- 605
			end -- 604
		end -- 603
	end) -- 603
	return _with_0 -- 583
end -- 582
setupEventHandlers() -- 607
clearTempFiles() -- 608
local stop -- 610
stop = function() -- 610
	if isInEntry then -- 611
		return false -- 611
	end -- 611
	allClear() -- 612
	isInEntry = true -- 613
	currentEntry = nil -- 614
	return true -- 615
end -- 610
_module_0["stop"] = stop -- 615
local _anon_func_3 = function(Content, Path, file, require, type) -- 637
	local scriptPath = Path:getPath(file) -- 630
	Content:insertSearchPath(1, scriptPath) -- 631
	scriptPath = Path(scriptPath, "Script") -- 632
	if Content:exist(scriptPath) then -- 633
		Content:insertSearchPath(1, scriptPath) -- 634
	end -- 633
	local result = require(file) -- 635
	if "function" == type(result) then -- 636
		result() -- 636
	end -- 636
	return nil -- 637
end -- 630
local _anon_func_4 = function(Label, _with_0, err, fontSize, width) -- 669
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 666
	label.alignment = "Left" -- 667
	label.textWidth = width - fontSize -- 668
	label.text = err -- 669
	return label -- 666
end -- 666
local enterEntryAsync -- 617
enterEntryAsync = function(entry) -- 617
	isInEntry = false -- 618
	App.idled = false -- 619
	emit(Profiler.EventName, "ClearLoader") -- 620
	currentEntry = entry -- 621
	local name, file = entry[1], entry[2] -- 622
	if cppTestSet[entry] then -- 623
		if App:runTest(name) then -- 624
			return true -- 625
		else -- 627
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 627
		end -- 624
	end -- 623
	sleep() -- 628
	return xpcall(_anon_func_3, function(msg) -- 670
		local err = debug.traceback(msg) -- 639
		Log("Error", err) -- 640
		allClear() -- 641
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 642
		local viewWidth, viewHeight -- 643
		do -- 643
			local _obj_0 = View.size -- 643
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 643
		end -- 643
		local width, height = viewWidth - 20, viewHeight - 20 -- 644
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 645
		Director.ui:addChild((function() -- 646
			local root = AlignNode() -- 646
			do -- 647
				local _obj_0 = App.bufferSize -- 647
				width, height = _obj_0.width, _obj_0.height -- 647
			end -- 647
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 648
			root:onAppChange(function(settingName) -- 649
				if settingName == "Size" then -- 649
					do -- 650
						local _obj_0 = App.bufferSize -- 650
						width, height = _obj_0.width, _obj_0.height -- 650
					end -- 650
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 651
				end -- 649
			end) -- 649
			root:addChild((function() -- 652
				local _with_0 = ScrollArea({ -- 653
					width = width, -- 653
					height = height, -- 654
					paddingX = 0, -- 655
					paddingY = 50, -- 656
					viewWidth = height, -- 657
					viewHeight = height -- 658
				}) -- 652
				root:onAlignLayout(function(w, h) -- 660
					_with_0.position = Vec2(w / 2, h / 2) -- 661
					w = w - 20 -- 662
					h = h - 20 -- 663
					_with_0.view.children.first.textWidth = w - fontSize -- 664
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 665
				end) -- 660
				_with_0.view:addChild(_anon_func_4(Label, _with_0, err, fontSize, width)) -- 666
				return _with_0 -- 652
			end)()) -- 652
			return root -- 646
		end)()) -- 646
		return err -- 670
	end, Content, Path, file, require, type) -- 670
end -- 617
_module_0["enterEntryAsync"] = enterEntryAsync -- 670
local enterDemoEntry -- 672
enterDemoEntry = function(entry) -- 672
	return thread(function() -- 672
		return enterEntryAsync(entry) -- 672
	end) -- 672
end -- 672
local reloadCurrentEntry -- 674
reloadCurrentEntry = function() -- 674
	if currentEntry then -- 675
		allClear() -- 676
		return enterDemoEntry(currentEntry) -- 677
	end -- 675
end -- 674
Director.clearColor = Color(0xff1a1a1a) -- 679
local isOSSLicenseExist = Content:exist("LICENSES") -- 681
local ossLicenses = nil -- 682
local ossLicenseOpen = false -- 683
local _anon_func_5 = function(App) -- 687
	local _val_0 = App.platform -- 687
	return not ("Android" == _val_0 or "iOS" == _val_0) -- 687
end -- 687
local extraOperations -- 685
extraOperations = function() -- 685
	local zh = useChinese and isChineseSupported -- 686
	if _anon_func_5(App) then -- 687
		local themeColor = App.themeColor -- 688
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 689
		do -- 690
			local changed -- 690
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 690
			if changed then -- 690
				App.alwaysOnTop = alwaysOnTop -- 691
				config.alwaysOnTop = alwaysOnTop -- 692
			end -- 690
		end -- 690
		SeparatorText(zh and "工作目录" or "Workspace") -- 693
		PushTextWrapPos(400, function() -- 694
			return TextColored(themeColor, writablePath) -- 695
		end) -- 694
		if Button(zh and "改变目录" or "Set Folder") then -- 696
			App:openFileDialog(true, function(path) -- 697
				if path ~= "" then -- 698
					return setWorkspace(path) -- 698
				end -- 698
			end) -- 697
		end -- 696
		SameLine() -- 699
		if Button(zh and "使用默认" or "Use Default") then -- 700
			setWorkspace(Content.appPath) -- 701
		end -- 700
		Separator() -- 702
	end -- 687
	if isOSSLicenseExist then -- 703
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 704
			if not ossLicenses then -- 705
				ossLicenses = { } -- 706
				local licenseText = Content:load("LICENSES") -- 707
				ossLicenseOpen = (licenseText ~= nil) -- 708
				if ossLicenseOpen then -- 708
					licenseText = licenseText:gsub("\r\n", "\n") -- 709
					for license in GSplit(licenseText, "\n--------\n", true) do -- 710
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 711
						if name then -- 711
							ossLicenses[#ossLicenses + 1] = { -- 712
								name, -- 712
								text -- 712
							} -- 712
						end -- 711
					end -- 712
				end -- 708
			else -- 714
				ossLicenseOpen = true -- 714
			end -- 705
		end -- 704
		if ossLicenseOpen then -- 715
			local width, height, themeColor -- 716
			do -- 716
				local _obj_0 = App -- 716
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 716
			end -- 716
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 717
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 718
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 719
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 722
					"NoSavedSettings" -- 722
				}, function() -- 723
					for _index_0 = 1, #ossLicenses do -- 723
						local _des_0 = ossLicenses[_index_0] -- 723
						local firstLine, text = _des_0[1], _des_0[2] -- 723
						local name, license = firstLine:match("(.+): (.+)") -- 724
						TextColored(themeColor, name) -- 725
						SameLine() -- 726
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 727
							return TextWrapped(text) -- 727
						end) -- 727
					end -- 727
				end) -- 719
			end) -- 719
		end -- 715
	end -- 703
	if not App.debugging then -- 729
		return -- 729
	end -- 729
	return TreeNode(zh and "开发操作" or "Development", function() -- 730
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 731
			OpenPopup("build") -- 731
		end -- 731
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 732
			return BeginPopup("build", function() -- 732
				if Selectable(zh and "编译" or "Compile") then -- 733
					doCompile(false) -- 733
				end -- 733
				Separator() -- 734
				if Selectable(zh and "压缩" or "Minify") then -- 735
					doCompile(true) -- 735
				end -- 735
				Separator() -- 736
				if Selectable(zh and "清理" or "Clean") then -- 737
					return doClean() -- 737
				end -- 737
			end) -- 737
		end) -- 732
		if isInEntry then -- 738
			if waitForWebStart then -- 739
				BeginDisabled(function() -- 740
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 740
				end) -- 740
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 741
				reloadDevEntry() -- 742
			end -- 739
		end -- 738
		do -- 743
			local changed -- 743
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 743
			if changed then -- 743
				View.scale = scaleContent and screenScale or 1 -- 744
			end -- 743
		end -- 743
		do -- 745
			local changed -- 745
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 745
			if changed then -- 745
				config.engineDev = engineDev -- 746
			end -- 745
		end -- 745
		if Button(zh and "开始自动测试" or "Test automatically") then -- 747
			testingThread = thread(function() -- 748
				local _ <close> = setmetatable({ }, { -- 749
					__close = function() -- 749
						allClear() -- 750
						testingThread = nil -- 751
						isInEntry = true -- 752
						currentEntry = nil -- 753
						return print("Testing done!") -- 754
					end -- 749
				}) -- 749
				for _, entry in ipairs(allEntries) do -- 755
					allClear() -- 756
					print("Start " .. tostring(entry[1])) -- 757
					enterDemoEntry(entry) -- 758
					sleep(2) -- 759
					print("Stop " .. tostring(entry[1])) -- 760
				end -- 760
			end) -- 748
		end -- 747
	end) -- 730
end -- 685
local transparant = Color(0x0) -- 762
local windowFlags = { -- 763
	"NoTitleBar", -- 763
	"NoResize", -- 763
	"NoMove", -- 763
	"NoCollapse", -- 763
	"NoSavedSettings", -- 763
	"NoBringToFrontOnFocus" -- 763
} -- 763
local initFooter = true -- 771
local _anon_func_6 = function(allEntries, currentIndex) -- 807
	if currentIndex > 1 then -- 807
		return allEntries[currentIndex - 1] -- 808
	else -- 810
		return allEntries[#allEntries] -- 810
	end -- 807
end -- 807
local _anon_func_7 = function(allEntries, currentIndex) -- 814
	if currentIndex < #allEntries then -- 814
		return allEntries[currentIndex + 1] -- 815
	else -- 817
		return allEntries[1] -- 817
	end -- 814
end -- 814
footerWindow = threadLoop(function() -- 772
	local zh = useChinese and isChineseSupported -- 773
	if HttpServer.wsConnectionCount > 0 then -- 774
		return -- 775
	end -- 774
	if Keyboard:isKeyDown("Escape") then -- 776
		allClear() -- 777
		App:shutdown() -- 778
	end -- 776
	do -- 779
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 780
		if ctrl and Keyboard:isKeyDown("Q") then -- 781
			stop() -- 782
		end -- 781
		if ctrl and Keyboard:isKeyDown("Z") then -- 783
			reloadCurrentEntry() -- 784
		end -- 783
		if ctrl and Keyboard:isKeyDown(",") then -- 785
			if showFooter then -- 786
				showStats = not showStats -- 786
			else -- 786
				showStats = true -- 786
			end -- 786
			showFooter = true -- 787
			config.showFooter = showFooter -- 788
			config.showStats = showStats -- 789
		end -- 785
		if ctrl and Keyboard:isKeyDown(".") then -- 790
			if showFooter then -- 791
				showConsole = not showConsole -- 791
			else -- 791
				showConsole = true -- 791
			end -- 791
			showFooter = true -- 792
			config.showFooter = showFooter -- 793
			config.showConsole = showConsole -- 794
		end -- 790
		if ctrl and Keyboard:isKeyDown("/") then -- 795
			showFooter = not showFooter -- 796
			config.showFooter = showFooter -- 797
		end -- 795
		local left = ctrl and Keyboard:isKeyDown("Left") -- 798
		local right = ctrl and Keyboard:isKeyDown("Right") -- 799
		local currentIndex = nil -- 800
		for i, entry in ipairs(allEntries) do -- 801
			if currentEntry == entry then -- 802
				currentIndex = i -- 803
			end -- 802
		end -- 803
		if left then -- 804
			allClear() -- 805
			if currentIndex == nil then -- 806
				currentIndex = #allEntries + 1 -- 806
			end -- 806
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 807
		end -- 804
		if right then -- 811
			allClear() -- 812
			if currentIndex == nil then -- 813
				currentIndex = 0 -- 813
			end -- 813
			enterDemoEntry(_anon_func_7(allEntries, currentIndex)) -- 814
		end -- 811
	end -- 817
	if not showEntry then -- 818
		return -- 818
	end -- 818
	local width, height -- 820
	do -- 820
		local _obj_0 = App.visualSize -- 820
		width, height = _obj_0.width, _obj_0.height -- 820
	end -- 820
	SetNextWindowSize(Vec2(50, 50)) -- 821
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 822
	PushStyleColor("WindowBg", transparant, function() -- 823
		return Begin("Show", windowFlags, function() -- 823
			if isInEntry or width >= 540 then -- 824
				local changed -- 825
				changed, showFooter = Checkbox("##dev", showFooter) -- 825
				if changed then -- 825
					config.showFooter = showFooter -- 826
				end -- 825
			end -- 824
		end) -- 826
	end) -- 823
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 828
		reloadDevEntry() -- 832
	end -- 828
	if initFooter then -- 833
		initFooter = false -- 834
	else -- 836
		if not showFooter then -- 836
			return -- 836
		end -- 836
	end -- 833
	SetNextWindowSize(Vec2(width, 50)) -- 838
	SetNextWindowPos(Vec2(0, height - 50)) -- 839
	SetNextWindowBgAlpha(0.35) -- 840
	do -- 841
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 842
			return Begin("Footer", windowFlags, function() -- 843
				Dummy(Vec2(width - 20, 0)) -- 844
				do -- 845
					local changed -- 845
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 845
					if changed then -- 845
						config.showStats = showStats -- 846
					end -- 845
				end -- 845
				SameLine() -- 847
				do -- 848
					local changed -- 848
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 848
					if changed then -- 848
						config.showConsole = showConsole -- 849
					end -- 848
				end -- 848
				if config.updateNotification then -- 850
					SameLine() -- 851
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 852
						config.updateNotification = false -- 853
						allClear() -- 854
						enterDemoEntry({ -- 855
							"SelfUpdater", -- 855
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 855
						}) -- 855
					end -- 852
				end -- 850
				if not isInEntry then -- 856
					SameLine() -- 857
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 858
					local currentIndex = nil -- 859
					for i, entry in ipairs(allEntries) do -- 860
						if currentEntry == entry then -- 861
							currentIndex = i -- 862
						end -- 861
					end -- 862
					if currentIndex then -- 863
						if currentIndex > 1 then -- 864
							SameLine() -- 865
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 866
								allClear() -- 867
								enterDemoEntry(allEntries[currentIndex - 1]) -- 868
							end -- 866
						end -- 864
						if currentIndex < #allEntries then -- 869
							SameLine() -- 870
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 871
								allClear() -- 872
								enterDemoEntry(allEntries[currentIndex + 1]) -- 873
							end -- 871
						end -- 869
					end -- 863
					SameLine() -- 874
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 875
						reloadCurrentEntry() -- 876
					end -- 875
					if back then -- 877
						allClear() -- 878
						isInEntry = true -- 879
						currentEntry = nil -- 880
					end -- 877
				end -- 856
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 881
					if showStats then -- 882
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 883
						showStats = ShowStats(showStats, extraOperations) -- 884
						config.showStats = showStats -- 885
					end -- 882
					if showConsole then -- 886
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 887
						showConsole = ShowConsole(showConsole) -- 888
						config.showConsole = showConsole -- 889
					end -- 886
				end) -- 881
			end) -- 843
		end) -- 842
	end -- 889
end) -- 772
local MaxWidth <const> = 800 -- 891
local displayWindowFlags = { -- 893
	"NoDecoration", -- 893
	"NoSavedSettings", -- 893
	"NoFocusOnAppearing", -- 893
	"NoNav", -- 893
	"NoMove", -- 893
	"NoScrollWithMouse", -- 893
	"AlwaysAutoResize", -- 893
	"NoBringToFrontOnFocus" -- 893
} -- 893
local webStatus = nil -- 904
local descColor = Color(0xffa1a1a1) -- 905
local gameOpen = #gamesInDev == 0 -- 906
local toolOpen = false -- 907
local exampleOpen = false -- 908
local testOpen = false -- 909
local filterText = nil -- 910
local anyEntryMatched = false -- 911
local urlClicked = nil -- 912
local match -- 913
match = function(name) -- 913
	local res = not filterText or name:lower():match(filterText) -- 914
	if res then -- 915
		anyEntryMatched = true -- 915
	end -- 915
	return res -- 916
end -- 913
local iconTex = nil -- 917
thread(function() -- 918
	if Cache:loadAsync("Image/icon_s.png") then -- 918
		iconTex = Texture2D("Image/icon_s.png") -- 919
	end -- 918
end) -- 918
entryWindow = threadLoop(function() -- 921
	if App.fpsLimited ~= config.fpsLimited then -- 922
		config.fpsLimited = App.fpsLimited -- 923
	end -- 922
	if App.targetFPS ~= config.targetFPS then -- 924
		config.targetFPS = App.targetFPS -- 925
	end -- 924
	if View.vsync ~= config.vsync then -- 926
		config.vsync = View.vsync -- 927
	end -- 926
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 928
		config.fixedFPS = Director.scheduler.fixedFPS -- 929
	end -- 928
	if Director.profilerSending ~= config.webProfiler then -- 930
		config.webProfiler = Director.profilerSending -- 931
	end -- 930
	if urlClicked then -- 932
		local _, result = coroutine.resume(urlClicked) -- 933
		if result then -- 934
			coroutine.close(urlClicked) -- 935
			urlClicked = nil -- 936
		end -- 934
	end -- 932
	if not showEntry then -- 937
		return -- 937
	end -- 937
	if not isInEntry then -- 938
		return -- 938
	end -- 938
	local zh = useChinese and isChineseSupported -- 939
	if HttpServer.wsConnectionCount > 0 then -- 940
		local themeColor = App.themeColor -- 941
		local width, height -- 942
		do -- 942
			local _obj_0 = App.visualSize -- 942
			width, height = _obj_0.width, _obj_0.height -- 942
		end -- 942
		SetNextWindowBgAlpha(0.5) -- 943
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 944
		Begin("Web IDE Connected", displayWindowFlags, function() -- 945
			Separator() -- 946
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 947
			if iconTex then -- 948
				Image("Image/icon_s.png", Vec2(24, 24)) -- 949
				SameLine() -- 950
			end -- 948
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 951
			TextColored(descColor, slogon) -- 952
			return Separator() -- 953
		end) -- 945
		return -- 954
	end -- 940
	local themeColor = App.themeColor -- 956
	local fullWidth, height -- 957
	do -- 957
		local _obj_0 = App.visualSize -- 957
		fullWidth, height = _obj_0.width, _obj_0.height -- 957
	end -- 957
	SetNextWindowBgAlpha(0.85) -- 959
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 960
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 961
		return Begin("Web IDE", displayWindowFlags, function() -- 962
			Separator() -- 963
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 964
			SameLine() -- 965
			TextDisabled('(?)') -- 966
			if IsItemHovered() then -- 967
				BeginTooltip(function() -- 968
					return PushTextWrapPos(280, function() -- 969
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 970
					end) -- 970
				end) -- 968
			end -- 967
			do -- 971
				local url -- 971
				if webStatus ~= nil then -- 971
					url = webStatus.url -- 971
				end -- 971
				if url then -- 971
					if isDesktop and not config.fullScreen then -- 972
						if urlClicked then -- 973
							BeginDisabled(function() -- 974
								return Button(url) -- 974
							end) -- 974
						elseif Button(url) then -- 975
							urlClicked = once(function() -- 976
								return sleep(5) -- 976
							end) -- 976
							App:openURL("http://localhost:8866") -- 977
						end -- 973
					else -- 979
						TextColored(descColor, url) -- 979
					end -- 972
				else -- 981
					TextColored(descColor, zh and '不可用' or 'not available') -- 981
				end -- 971
			end -- 971
			return Separator() -- 982
		end) -- 982
	end) -- 961
	local width = math.min(MaxWidth, fullWidth) -- 984
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 985
	local maxColumns = math.max(math.floor(width / 200), 1) -- 986
	SetNextWindowPos(Vec2.zero) -- 987
	SetNextWindowBgAlpha(0) -- 988
	do -- 989
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 990
			return Begin("Dora Dev", displayWindowFlags, function() -- 991
				Dummy(Vec2(fullWidth - 20, 0)) -- 992
				if iconTex then -- 993
					Image("Image/icon_s.png", Vec2(24, 24)) -- 994
					SameLine() -- 995
				end -- 993
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 996
				if fullWidth >= 320 then -- 997
					SameLine() -- 998
					Dummy(Vec2(fullWidth - 320, 0)) -- 999
					SameLine() -- 1000
					SetNextItemWidth(-30) -- 1001
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1002
						"AutoSelectAll" -- 1002
					}) then -- 1002
						config.filter = filterBuf.text -- 1003
					end -- 1002
				end -- 997
				Separator() -- 1004
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1005
			end) -- 991
		end) -- 990
	end -- 1005
	anyEntryMatched = false -- 1007
	SetNextWindowPos(Vec2(0, 50)) -- 1008
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1009
	do -- 1010
		return PushStyleColor("WindowBg", transparant, function() -- 1011
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1012
				return Begin("Content", windowFlags, function() -- 1013
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 1014
					if filterText then -- 1015
						filterText = filterText:lower() -- 1015
					end -- 1015
					if #gamesInDev > 0 then -- 1016
						for _index_0 = 1, #gamesInDev do -- 1017
							local game = gamesInDev[_index_0] -- 1017
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1018
							local showSep = false -- 1019
							if match(gameName) then -- 1020
								Columns(1, false) -- 1021
								TextColored(themeColor, zh and "项目：" or "Project:") -- 1022
								SameLine() -- 1023
								Text(gameName) -- 1024
								Separator() -- 1025
								if bannerFile then -- 1026
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1027
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1028
									local sizing <const> = 0.8 -- 1029
									texHeight = displayWidth * sizing * texHeight / texWidth -- 1030
									texWidth = displayWidth * sizing -- 1031
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1032
									Dummy(Vec2(padding, 0)) -- 1033
									SameLine() -- 1034
									PushID(fileName, function() -- 1035
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1036
											return enterDemoEntry(game) -- 1037
										end -- 1036
									end) -- 1035
								else -- 1039
									PushID(fileName, function() -- 1039
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 1040
											return enterDemoEntry(game) -- 1041
										end -- 1040
									end) -- 1039
								end -- 1026
								NextColumn() -- 1042
								showSep = true -- 1043
							end -- 1020
							if #examples > 0 then -- 1044
								local showExample = false -- 1045
								for _index_1 = 1, #examples do -- 1046
									local example = examples[_index_1] -- 1046
									if match(example[1]) then -- 1047
										showExample = true -- 1048
										break -- 1049
									end -- 1047
								end -- 1049
								if showExample then -- 1050
									Columns(1, false) -- 1051
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1052
									SameLine() -- 1053
									Text(gameName) -- 1054
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1055
										Columns(maxColumns, false) -- 1056
										for _index_1 = 1, #examples do -- 1057
											local example = examples[_index_1] -- 1057
											if not match(example[1]) then -- 1058
												goto _continue_0 -- 1058
											end -- 1058
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1059
												if Button(example[1], Vec2(-1, 40)) then -- 1060
													enterDemoEntry(example) -- 1061
												end -- 1060
												return NextColumn() -- 1062
											end) -- 1059
											showSep = true -- 1063
											::_continue_0:: -- 1058
										end -- 1063
									end) -- 1055
								end -- 1050
							end -- 1044
							if #tests > 0 then -- 1064
								local showTest = false -- 1065
								for _index_1 = 1, #tests do -- 1066
									local test = tests[_index_1] -- 1066
									if match(test[1]) then -- 1067
										showTest = true -- 1068
										break -- 1069
									end -- 1067
								end -- 1069
								if showTest then -- 1070
									Columns(1, false) -- 1071
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1072
									SameLine() -- 1073
									Text(gameName) -- 1074
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1075
										Columns(maxColumns, false) -- 1076
										for _index_1 = 1, #tests do -- 1077
											local test = tests[_index_1] -- 1077
											if not match(test[1]) then -- 1078
												goto _continue_0 -- 1078
											end -- 1078
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1079
												if Button(test[1], Vec2(-1, 40)) then -- 1080
													enterDemoEntry(test) -- 1081
												end -- 1080
												return NextColumn() -- 1082
											end) -- 1079
											showSep = true -- 1083
											::_continue_0:: -- 1078
										end -- 1083
									end) -- 1075
								end -- 1070
							end -- 1064
							if showSep then -- 1084
								Columns(1, false) -- 1085
								Separator() -- 1086
							end -- 1084
						end -- 1086
					end -- 1016
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1087
						local showGame = false -- 1088
						for _index_0 = 1, #games do -- 1089
							local _des_0 = games[_index_0] -- 1089
							local name = _des_0[1] -- 1089
							if match(name) then -- 1090
								showGame = true -- 1090
							end -- 1090
						end -- 1090
						local showTool = false -- 1091
						for _index_0 = 1, #doraTools do -- 1092
							local _des_0 = doraTools[_index_0] -- 1092
							local name = _des_0[1] -- 1092
							if match(name) then -- 1093
								showTool = true -- 1093
							end -- 1093
						end -- 1093
						local showExample = false -- 1094
						for _index_0 = 1, #doraExamples do -- 1095
							local _des_0 = doraExamples[_index_0] -- 1095
							local name = _des_0[1] -- 1095
							if match(name) then -- 1096
								showExample = true -- 1096
							end -- 1096
						end -- 1096
						local showTest = false -- 1097
						for _index_0 = 1, #doraTests do -- 1098
							local _des_0 = doraTests[_index_0] -- 1098
							local name = _des_0[1] -- 1098
							if match(name) then -- 1099
								showTest = true -- 1099
							end -- 1099
						end -- 1099
						for _index_0 = 1, #cppTests do -- 1100
							local _des_0 = cppTests[_index_0] -- 1100
							local name = _des_0[1] -- 1100
							if match(name) then -- 1101
								showTest = true -- 1101
							end -- 1101
						end -- 1101
						if not (showGame or showTool or showExample or showTest) then -- 1102
							goto endEntry -- 1102
						end -- 1102
						Columns(1, false) -- 1103
						TextColored(themeColor, "Dora SSR:") -- 1104
						SameLine() -- 1105
						Text(zh and "开发示例" or "Development Showcase") -- 1106
						Separator() -- 1107
						local demoViewWith <const> = 400 -- 1108
						if #games > 0 and showGame then -- 1109
							local opened -- 1110
							if (filterText ~= nil) then -- 1110
								opened = showGame -- 1110
							else -- 1110
								opened = false -- 1110
							end -- 1110
							SetNextItemOpen(gameOpen) -- 1111
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1112
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1113
								Columns(columns, false) -- 1114
								for _index_0 = 1, #games do -- 1115
									local game = games[_index_0] -- 1115
									if not match(game[1]) then -- 1116
										goto _continue_0 -- 1116
									end -- 1116
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1117
									if columns > 1 then -- 1118
										if bannerFile then -- 1119
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1120
											local displayWidth <const> = demoViewWith - 40 -- 1121
											texHeight = displayWidth * texHeight / texWidth -- 1122
											texWidth = displayWidth -- 1123
											Text(gameName) -- 1124
											PushID(fileName, function() -- 1125
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1126
													return enterDemoEntry(game) -- 1127
												end -- 1126
											end) -- 1125
										else -- 1129
											PushID(fileName, function() -- 1129
												if Button(gameName, Vec2(-1, 40)) then -- 1130
													return enterDemoEntry(game) -- 1131
												end -- 1130
											end) -- 1129
										end -- 1119
									else -- 1133
										if bannerFile then -- 1133
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1134
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1135
											local sizing = 0.8 -- 1136
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1137
											texWidth = displayWidth * sizing -- 1138
											if texWidth > 500 then -- 1139
												sizing = 0.6 -- 1140
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1141
												texWidth = displayWidth * sizing -- 1142
											end -- 1139
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1143
											Dummy(Vec2(padding, 0)) -- 1144
											SameLine() -- 1145
											Text(gameName) -- 1146
											Dummy(Vec2(padding, 0)) -- 1147
											SameLine() -- 1148
											PushID(fileName, function() -- 1149
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1150
													return enterDemoEntry(game) -- 1151
												end -- 1150
											end) -- 1149
										else -- 1153
											PushID(fileName, function() -- 1153
												if Button(gameName, Vec2(-1, 40)) then -- 1154
													return enterDemoEntry(game) -- 1155
												end -- 1154
											end) -- 1153
										end -- 1133
									end -- 1118
									NextColumn() -- 1156
									::_continue_0:: -- 1116
								end -- 1156
								Columns(1, false) -- 1157
								opened = true -- 1158
							end) -- 1112
							gameOpen = opened -- 1159
						end -- 1109
						if #doraTools > 0 and showTool then -- 1160
							local opened -- 1161
							if (filterText ~= nil) then -- 1161
								opened = showTool -- 1161
							else -- 1161
								opened = false -- 1161
							end -- 1161
							SetNextItemOpen(toolOpen) -- 1162
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1163
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1164
									Columns(maxColumns, false) -- 1165
									for _index_0 = 1, #doraTools do -- 1166
										local example = doraTools[_index_0] -- 1166
										if not match(example[1]) then -- 1167
											goto _continue_0 -- 1167
										end -- 1167
										if Button(example[1], Vec2(-1, 40)) then -- 1168
											enterDemoEntry(example) -- 1169
										end -- 1168
										NextColumn() -- 1170
										::_continue_0:: -- 1167
									end -- 1170
									Columns(1, false) -- 1171
									opened = true -- 1172
								end) -- 1164
							end) -- 1163
							toolOpen = opened -- 1173
						end -- 1160
						if #doraExamples > 0 and showExample then -- 1174
							local opened -- 1175
							if (filterText ~= nil) then -- 1175
								opened = showExample -- 1175
							else -- 1175
								opened = false -- 1175
							end -- 1175
							SetNextItemOpen(exampleOpen) -- 1176
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1177
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1178
									Columns(maxColumns, false) -- 1179
									for _index_0 = 1, #doraExamples do -- 1180
										local example = doraExamples[_index_0] -- 1180
										if not match(example[1]) then -- 1181
											goto _continue_0 -- 1181
										end -- 1181
										if Button(example[1], Vec2(-1, 40)) then -- 1182
											enterDemoEntry(example) -- 1183
										end -- 1182
										NextColumn() -- 1184
										::_continue_0:: -- 1181
									end -- 1184
									Columns(1, false) -- 1185
									opened = true -- 1186
								end) -- 1178
							end) -- 1177
							exampleOpen = opened -- 1187
						end -- 1174
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1188
							local opened -- 1189
							if (filterText ~= nil) then -- 1189
								opened = showTest -- 1189
							else -- 1189
								opened = false -- 1189
							end -- 1189
							SetNextItemOpen(testOpen) -- 1190
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1191
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1192
									Columns(maxColumns, false) -- 1193
									for _index_0 = 1, #doraTests do -- 1194
										local test = doraTests[_index_0] -- 1194
										if not match(test[1]) then -- 1195
											goto _continue_0 -- 1195
										end -- 1195
										if Button(test[1], Vec2(-1, 40)) then -- 1196
											enterDemoEntry(test) -- 1197
										end -- 1196
										NextColumn() -- 1198
										::_continue_0:: -- 1195
									end -- 1198
									for _index_0 = 1, #cppTests do -- 1199
										local test = cppTests[_index_0] -- 1199
										if not match(test[1]) then -- 1200
											goto _continue_1 -- 1200
										end -- 1200
										if Button(test[1], Vec2(-1, 40)) then -- 1201
											enterDemoEntry(test) -- 1202
										end -- 1201
										NextColumn() -- 1203
										::_continue_1:: -- 1200
									end -- 1203
									opened = true -- 1204
								end) -- 1192
							end) -- 1191
							testOpen = opened -- 1205
						end -- 1188
					end -- 1087
					::endEntry:: -- 1206
					if not anyEntryMatched then -- 1207
						SetNextWindowBgAlpha(0) -- 1208
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1209
						Begin("Entries Not Found", displayWindowFlags, function() -- 1210
							Separator() -- 1211
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1212
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1213
							return Separator() -- 1214
						end) -- 1210
					end -- 1207
					Columns(1, false) -- 1215
					Dummy(Vec2(100, 80)) -- 1216
					return ScrollWhenDraggingOnVoid() -- 1217
				end) -- 1013
			end) -- 1012
		end) -- 1011
	end -- 1217
end) -- 921
webStatus = require("Script.Dev.WebServer") -- 1219
return _module_0 -- 1219
