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
local Button = _module_0.Button -- 1
local SetNextWindowPosCenter = _module_0.SetNextWindowPosCenter -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Begin = _module_0.Begin -- 1
local TextColored = _module_0.TextColored -- 1
local SameLine = _module_0.SameLine -- 1
local TreeNode = _module_0.TreeNode -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local OpenPopup = _module_0.OpenPopup -- 1
local BeginPopup = _module_0.BeginPopup -- 1
local Selectable = _module_0.Selectable -- 1
local Separator = _module_0.Separator -- 1
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
local PushTextWrapPos = _module_0.PushTextWrapPos -- 1
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
end -- 36
local Config = require("Config") -- 42
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification") -- 43
config:load() -- 68
if (config.fpsLimited ~= nil) then -- 69
	App.fpsLimited = config.fpsLimited -- 70
else -- 72
	config.fpsLimited = App.fpsLimited -- 72
end -- 69
if (config.targetFPS ~= nil) then -- 74
	App.targetFPS = config.targetFPS -- 75
else -- 77
	config.targetFPS = App.targetFPS -- 77
end -- 74
if (config.vsync ~= nil) then -- 79
	View.vsync = config.vsync -- 80
else -- 82
	config.vsync = View.vsync -- 82
end -- 79
if (config.fixedFPS ~= nil) then -- 84
	Director.scheduler.fixedFPS = config.fixedFPS -- 85
else -- 87
	config.fixedFPS = Director.scheduler.fixedFPS -- 87
end -- 84
local showEntry = true -- 89
local isDesktop = false -- 91
if (function() -- 92
	local _val_0 = App.platform -- 92
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 92
end)() then -- 92
	isDesktop = true -- 93
	if config.fullScreen then -- 94
		App.fullScreen = true -- 95
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 96
		local size = Size(config.winWidth, config.winHeight) -- 97
		if App.winSize ~= size then -- 98
			App.winSize = size -- 99
			showEntry = false -- 100
			thread(function() -- 101
				sleep() -- 102
				sleep() -- 103
				showEntry = true -- 104
			end) -- 101
		end -- 98
		local winX, winY -- 105
		do -- 105
			local _obj_0 = App.winPosition -- 105
			winX, winY = _obj_0.x, _obj_0.y -- 105
		end -- 105
		if (config.winX ~= nil) then -- 106
			winX = config.winX -- 107
		else -- 109
			config.winX = 0 -- 109
		end -- 106
		if (config.winY ~= nil) then -- 110
			winY = config.winY -- 111
		else -- 113
			config.winY = 0 -- 113
		end -- 110
		App.winPosition = Vec2(winX, winY) -- 114
	end -- 94
	if (config.alwaysOnTop ~= nil) then -- 115
		App.alwaysOnTop = config.alwaysOnTop -- 116
	else -- 118
		config.alwaysOnTop = true -- 118
	end -- 115
end -- 92
if (config.themeColor ~= nil) then -- 120
	App.themeColor = Color(config.themeColor) -- 121
else -- 123
	config.themeColor = App.themeColor:toARGB() -- 123
end -- 120
if not (config.locale ~= nil) then -- 125
	config.locale = App.locale -- 126
end -- 125
local showStats = false -- 128
if (config.showStats ~= nil) then -- 129
	showStats = config.showStats -- 130
else -- 132
	config.showStats = showStats -- 132
end -- 129
local showConsole = true -- 134
if (config.showConsole ~= nil) then -- 135
	showConsole = config.showConsole -- 136
else -- 138
	config.showConsole = showConsole -- 138
end -- 135
local showFooter = true -- 140
if (config.showFooter ~= nil) then -- 141
	showFooter = config.showFooter -- 142
else -- 144
	config.showFooter = showFooter -- 144
end -- 141
local filterBuf = Buffer(20) -- 146
if (config.filter ~= nil) then -- 147
	filterBuf.text = config.filter -- 148
else -- 150
	config.filter = "" -- 150
end -- 147
local engineDev = false -- 152
if (config.engineDev ~= nil) then -- 153
	engineDev = config.engineDev -- 154
else -- 156
	config.engineDev = engineDev -- 156
end -- 153
if (config.webProfiler ~= nil) then -- 158
	Director.profilerSending = config.webProfiler -- 159
else -- 161
	config.webProfiler = true -- 161
	Director.profilerSending = true -- 162
end -- 158
if not (config.drawerWidth ~= nil) then -- 164
	config.drawerWidth = 200 -- 165
end -- 164
_module_0.getConfig = function() -- 167
	return config -- 167
end -- 167
_module_0.getEngineDev = function() -- 168
	if not App.debugging then -- 169
		return false -- 169
	end -- 169
	return config.engineDev -- 170
end -- 168
local updateCheck -- 172
updateCheck = function() -- 172
	return thread(function() -- 172
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 173
		if res then -- 173
			local data = json.load(res) -- 174
			if data then -- 174
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 175
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 176
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 177
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 178
				if na < a then -- 179
					goto not_new_version -- 180
				end -- 179
				if na == a then -- 181
					if nb < b then -- 182
						goto not_new_version -- 183
					end -- 182
					if nb == b then -- 184
						if nc < c then -- 185
							goto not_new_version -- 186
						end -- 185
						if nc == c then -- 187
							goto not_new_version -- 188
						end -- 187
					end -- 184
				end -- 181
				config.updateNotification = true -- 189
				::not_new_version:: -- 190
				config.lastUpdateCheck = os.time() -- 191
			end -- 174
		end -- 173
	end) -- 191
end -- 172
if (config.lastUpdateCheck ~= nil) then -- 193
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 194
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 195
		updateCheck() -- 196
	end -- 195
else -- 198
	updateCheck() -- 198
end -- 193
local Set, Struct, LintYueGlobals, GSplit -- 200
do -- 200
	local _obj_0 = require("Utils") -- 200
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 200
end -- 200
local yueext = yue.options.extension -- 201
local isChineseSupported = IsFontLoaded() -- 203
if not isChineseSupported then -- 204
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 205
		isChineseSupported = true -- 206
	end) -- 205
end -- 204
local building = false -- 208
local getAllFiles -- 210
getAllFiles = function(path, exts, recursive) -- 210
	if recursive == nil then -- 210
		recursive = true -- 210
	end -- 210
	local filters = Set(exts) -- 211
	local files -- 212
	if recursive then -- 212
		files = Content:getAllFiles(path) -- 213
	else -- 215
		files = Content:getFiles(path) -- 215
	end -- 212
	local _accum_0 = { } -- 216
	local _len_0 = 1 -- 216
	for _index_0 = 1, #files do -- 216
		local file = files[_index_0] -- 216
		if not filters[Path:getExt(file)] then -- 217
			goto _continue_0 -- 217
		end -- 217
		_accum_0[_len_0] = file -- 218
		_len_0 = _len_0 + 1 -- 218
		::_continue_0:: -- 217
	end -- 218
	return _accum_0 -- 218
end -- 210
_module_0["getAllFiles"] = getAllFiles -- 218
local getFileEntries -- 220
getFileEntries = function(path, recursive) -- 220
	if recursive == nil then -- 220
		recursive = true -- 220
	end -- 220
	local entries = { } -- 221
	local _list_0 = getAllFiles(path, { -- 222
		"lua", -- 222
		"xml", -- 222
		yueext, -- 222
		"tl" -- 222
	}, recursive) -- 222
	for _index_0 = 1, #_list_0 do -- 222
		local file = _list_0[_index_0] -- 222
		local entryName = Path:getName(file) -- 223
		local entryAdded = false -- 224
		for _index_1 = 1, #entries do -- 225
			local _des_0 = entries[_index_1] -- 225
			local ename = _des_0[1] -- 225
			if entryName == ename then -- 226
				entryAdded = true -- 227
				break -- 228
			end -- 226
		end -- 228
		if entryAdded then -- 229
			goto _continue_0 -- 229
		end -- 229
		local fileName = Path:replaceExt(file, "") -- 230
		fileName = Path(path, fileName) -- 231
		local entry = { -- 232
			entryName, -- 232
			fileName -- 232
		} -- 232
		entries[#entries + 1] = entry -- 233
		::_continue_0:: -- 223
	end -- 233
	table.sort(entries, function(a, b) -- 234
		return a[1] < b[1] -- 234
	end) -- 234
	return entries -- 235
end -- 220
local getProjectEntries -- 237
getProjectEntries = function(path) -- 237
	local entries = { } -- 238
	local _list_0 = Content:getDirs(path) -- 239
	for _index_0 = 1, #_list_0 do -- 239
		local dir = _list_0[_index_0] -- 239
		if dir:match("^%.") then -- 240
			goto _continue_0 -- 240
		end -- 240
		local _list_1 = getAllFiles(Path(path, dir), { -- 241
			"lua", -- 241
			"xml", -- 241
			yueext, -- 241
			"tl", -- 241
			"wasm" -- 241
		}) -- 241
		for _index_1 = 1, #_list_1 do -- 241
			local file = _list_1[_index_1] -- 241
			if "init" == Path:getName(file):lower() then -- 242
				local fileName = Path:replaceExt(file, "") -- 243
				fileName = Path(path, dir, fileName) -- 244
				local entryName = Path:getName(Path:getPath(fileName)) -- 245
				local entryAdded = false -- 246
				for _index_2 = 1, #entries do -- 247
					local _des_0 = entries[_index_2] -- 247
					local ename = _des_0[1] -- 247
					if entryName == ename then -- 248
						entryAdded = true -- 249
						break -- 250
					end -- 248
				end -- 250
				if entryAdded then -- 251
					goto _continue_1 -- 251
				end -- 251
				local examples = { } -- 252
				local tests = { } -- 253
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 254
				if Content:exist(examplePath) then -- 255
					local _list_2 = getFileEntries(examplePath) -- 256
					for _index_2 = 1, #_list_2 do -- 256
						local _des_0 = _list_2[_index_2] -- 256
						local name, ePath = _des_0[1], _des_0[2] -- 256
						local entry = { -- 257
							name, -- 257
							Path(path, dir, Path:getPath(file), ePath) -- 257
						} -- 257
						examples[#examples + 1] = entry -- 258
					end -- 258
				end -- 255
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 259
				if Content:exist(testPath) then -- 260
					local _list_2 = getFileEntries(testPath) -- 261
					for _index_2 = 1, #_list_2 do -- 261
						local _des_0 = _list_2[_index_2] -- 261
						local name, tPath = _des_0[1], _des_0[2] -- 261
						local entry = { -- 262
							name, -- 262
							Path(path, dir, Path:getPath(file), tPath) -- 262
						} -- 262
						tests[#tests + 1] = entry -- 263
					end -- 263
				end -- 260
				local entry = { -- 264
					entryName, -- 264
					fileName, -- 264
					examples, -- 264
					tests -- 264
				} -- 264
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 265
				if not Content:exist(bannerFile) then -- 266
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 267
					if not Content:exist(bannerFile) then -- 268
						bannerFile = nil -- 268
					end -- 268
				end -- 266
				if bannerFile then -- 269
					thread(function() -- 269
						if Cache:loadAsync(bannerFile) then -- 270
							local bannerTex = Texture2D(bannerFile) -- 271
							if bannerTex then -- 272
								entry[#entry + 1] = bannerFile -- 273
								entry[#entry + 1] = bannerTex -- 274
							end -- 272
						end -- 270
					end) -- 269
				end -- 269
				entries[#entries + 1] = entry -- 275
			end -- 242
			::_continue_1:: -- 242
		end -- 275
		::_continue_0:: -- 240
	end -- 275
	table.sort(entries, function(a, b) -- 276
		return a[1] < b[1] -- 276
	end) -- 276
	return entries -- 277
end -- 237
local gamesInDev, games -- 279
local doraTools, doraExamples, doraTests -- 280
local cppTests, cppTestSet -- 281
local allEntries -- 282
local updateEntries -- 284
updateEntries = function() -- 284
	gamesInDev = getProjectEntries(Content.writablePath) -- 285
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 286
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 288
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 289
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 290
	cppTests = { } -- 292
	local _list_0 = App.testNames -- 293
	for _index_0 = 1, #_list_0 do -- 293
		local name = _list_0[_index_0] -- 293
		local entry = { -- 294
			name -- 294
		} -- 294
		cppTests[#cppTests + 1] = entry -- 295
	end -- 295
	cppTestSet = Set(cppTests) -- 296
	allEntries = { } -- 298
	for _index_0 = 1, #gamesInDev do -- 299
		local game = gamesInDev[_index_0] -- 299
		allEntries[#allEntries + 1] = game -- 300
		local examples, tests = game[3], game[4] -- 301
		for _index_1 = 1, #examples do -- 302
			local example = examples[_index_1] -- 302
			allEntries[#allEntries + 1] = example -- 303
		end -- 303
		for _index_1 = 1, #tests do -- 304
			local test = tests[_index_1] -- 304
			allEntries[#allEntries + 1] = test -- 305
		end -- 305
	end -- 305
	for _index_0 = 1, #games do -- 306
		local game = games[_index_0] -- 306
		allEntries[#allEntries + 1] = game -- 307
		local examples, tests = game[3], game[4] -- 308
		for _index_1 = 1, #examples do -- 309
			local example = examples[_index_1] -- 309
			doraExamples[#doraExamples + 1] = example -- 310
		end -- 310
		for _index_1 = 1, #tests do -- 311
			local test = tests[_index_1] -- 311
			doraTests[#doraTests + 1] = test -- 312
		end -- 312
	end -- 312
	local _list_1 = { -- 314
		doraExamples, -- 314
		doraTests, -- 315
		cppTests -- 316
	} -- 313
	for _index_0 = 1, #_list_1 do -- 317
		local group = _list_1[_index_0] -- 313
		for _index_1 = 1, #group do -- 318
			local entry = group[_index_1] -- 318
			allEntries[#allEntries + 1] = entry -- 319
		end -- 319
	end -- 319
end -- 284
updateEntries() -- 321
local doCompile -- 323
doCompile = function(minify) -- 323
	if building then -- 324
		return -- 324
	end -- 324
	building = true -- 325
	local startTime = App.runningTime -- 326
	local luaFiles = { } -- 327
	local yueFiles = { } -- 328
	local xmlFiles = { } -- 329
	local tlFiles = { } -- 330
	local writablePath = Content.writablePath -- 331
	local buildPaths = { -- 333
		{ -- 334
			Path(Content.assetPath), -- 334
			Path(writablePath, ".build"), -- 335
			"" -- 336
		} -- 333
	} -- 332
	for _index_0 = 1, #gamesInDev do -- 339
		local _des_0 = gamesInDev[_index_0] -- 339
		local entryFile = _des_0[2] -- 339
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 340
		buildPaths[#buildPaths + 1] = { -- 342
			Path(writablePath, gamePath), -- 342
			Path(writablePath, ".build", gamePath), -- 343
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 344
			gamePath -- 345
		} -- 341
	end -- 345
	for _index_0 = 1, #buildPaths do -- 346
		local _des_0 = buildPaths[_index_0] -- 346
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 346
		if not Content:exist(inputPath) then -- 347
			goto _continue_0 -- 347
		end -- 347
		local _list_0 = getAllFiles(inputPath, { -- 349
			"lua" -- 349
		}) -- 349
		for _index_1 = 1, #_list_0 do -- 349
			local file = _list_0[_index_1] -- 349
			luaFiles[#luaFiles + 1] = { -- 351
				file, -- 351
				Path(inputPath, file), -- 352
				Path(outputPath, file), -- 353
				gamePath -- 354
			} -- 350
		end -- 354
		local _list_1 = getAllFiles(inputPath, { -- 356
			yueext -- 356
		}) -- 356
		for _index_1 = 1, #_list_1 do -- 356
			local file = _list_1[_index_1] -- 356
			yueFiles[#yueFiles + 1] = { -- 358
				file, -- 358
				Path(inputPath, file), -- 359
				Path(outputPath, Path:replaceExt(file, "lua")), -- 360
				searchPath, -- 361
				gamePath -- 362
			} -- 357
		end -- 362
		local _list_2 = getAllFiles(inputPath, { -- 364
			"xml" -- 364
		}) -- 364
		for _index_1 = 1, #_list_2 do -- 364
			local file = _list_2[_index_1] -- 364
			xmlFiles[#xmlFiles + 1] = { -- 366
				file, -- 366
				Path(inputPath, file), -- 367
				Path(outputPath, Path:replaceExt(file, "lua")), -- 368
				gamePath -- 369
			} -- 365
		end -- 369
		local _list_3 = getAllFiles(inputPath, { -- 371
			"tl" -- 371
		}) -- 371
		for _index_1 = 1, #_list_3 do -- 371
			local file = _list_3[_index_1] -- 371
			if not file:match(".*%.d%.tl$") then -- 372
				tlFiles[#tlFiles + 1] = { -- 374
					file, -- 374
					Path(inputPath, file), -- 375
					Path(outputPath, Path:replaceExt(file, "lua")), -- 376
					searchPath, -- 377
					gamePath -- 378
				} -- 373
			end -- 372
		end -- 378
		::_continue_0:: -- 347
	end -- 378
	local paths -- 380
	do -- 380
		local _tbl_0 = { } -- 380
		local _list_0 = { -- 381
			luaFiles, -- 381
			yueFiles, -- 381
			xmlFiles, -- 381
			tlFiles -- 381
		} -- 381
		for _index_0 = 1, #_list_0 do -- 381
			local files = _list_0[_index_0] -- 381
			for _index_1 = 1, #files do -- 382
				local file = files[_index_1] -- 382
				_tbl_0[Path:getPath(file[3])] = true -- 380
			end -- 380
		end -- 380
		paths = _tbl_0 -- 380
	end -- 382
	for path in pairs(paths) do -- 384
		Content:mkdir(path) -- 384
	end -- 384
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 386
	local fileCount = 0 -- 387
	local errors = { } -- 388
	for _index_0 = 1, #yueFiles do -- 389
		local _des_0 = yueFiles[_index_0] -- 389
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 389
		local filename -- 390
		if gamePath then -- 390
			filename = Path(gamePath, file) -- 390
		else -- 390
			filename = file -- 390
		end -- 390
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 391
			if not codes then -- 392
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 393
				return -- 394
			end -- 392
			local success, result = LintYueGlobals(codes, globals) -- 395
			if success then -- 396
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 397
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 398
				codes = codes:gsub("^\n*", "") -- 399
				if not (result == "") then -- 400
					result = result .. "\n" -- 400
				end -- 400
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 401
			else -- 403
				local yueCodes = Content:load(input) -- 403
				if yueCodes then -- 403
					local globalErrors = { } -- 404
					for _index_1 = 1, #result do -- 405
						local _des_1 = result[_index_1] -- 405
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 405
						local countLine = 1 -- 406
						local code = "" -- 407
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 408
							if countLine == line then -- 409
								code = lineCode -- 410
								break -- 411
							end -- 409
							countLine = countLine + 1 -- 412
						end -- 412
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 413
					end -- 413
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 414
				else -- 416
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 416
				end -- 403
			end -- 396
		end, function(success) -- 391
			if success then -- 417
				print("Yue compiled: " .. tostring(filename)) -- 417
			end -- 417
			fileCount = fileCount + 1 -- 418
		end) -- 391
	end -- 418
	thread(function() -- 420
		for _index_0 = 1, #xmlFiles do -- 421
			local _des_0 = xmlFiles[_index_0] -- 421
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 421
			local filename -- 422
			if gamePath then -- 422
				filename = Path(gamePath, file) -- 422
			else -- 422
				filename = file -- 422
			end -- 422
			local sourceCodes = Content:loadAsync(input) -- 423
			local codes, err = xml.tolua(sourceCodes) -- 424
			if not codes then -- 425
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 426
			else -- 428
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 428
				print("Xml compiled: " .. tostring(filename)) -- 429
			end -- 425
			fileCount = fileCount + 1 -- 430
		end -- 430
	end) -- 420
	thread(function() -- 432
		for _index_0 = 1, #tlFiles do -- 433
			local _des_0 = tlFiles[_index_0] -- 433
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 433
			local filename -- 434
			if gamePath then -- 434
				filename = Path(gamePath, file) -- 434
			else -- 434
				filename = file -- 434
			end -- 434
			local sourceCodes = Content:loadAsync(input) -- 435
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 436
			if not codes then -- 437
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 438
			else -- 440
				Content:saveAsync(output, codes) -- 440
				print("Teal compiled: " .. tostring(filename)) -- 441
			end -- 437
			fileCount = fileCount + 1 -- 442
		end -- 442
	end) -- 432
	return thread(function() -- 444
		wait(function() -- 445
			return fileCount == totalFiles -- 445
		end) -- 445
		if minify then -- 446
			local _list_0 = { -- 447
				yueFiles, -- 447
				xmlFiles, -- 447
				tlFiles -- 447
			} -- 447
			for _index_0 = 1, #_list_0 do -- 447
				local files = _list_0[_index_0] -- 447
				for _index_1 = 1, #files do -- 447
					local file = files[_index_1] -- 447
					local output = Path:replaceExt(file[3], "lua") -- 448
					luaFiles[#luaFiles + 1] = { -- 450
						Path:replaceExt(file[1], "lua"), -- 450
						output, -- 451
						output -- 452
					} -- 449
				end -- 452
			end -- 452
			local FormatMini -- 454
			do -- 454
				local _obj_0 = require("luaminify") -- 454
				FormatMini = _obj_0.FormatMini -- 454
			end -- 454
			for _index_0 = 1, #luaFiles do -- 455
				local _des_0 = luaFiles[_index_0] -- 455
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 455
				if Content:exist(input) then -- 456
					local sourceCodes = Content:loadAsync(input) -- 457
					local res, err = FormatMini(sourceCodes) -- 458
					if res then -- 459
						Content:saveAsync(output, res) -- 460
						print("Minify: " .. tostring(file)) -- 461
					else -- 463
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 463
					end -- 459
				else -- 465
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 465
				end -- 456
			end -- 465
			package.loaded["luaminify.FormatMini"] = nil -- 466
			package.loaded["luaminify.ParseLua"] = nil -- 467
			package.loaded["luaminify.Scope"] = nil -- 468
			package.loaded["luaminify.Util"] = nil -- 469
		end -- 446
		local errorMessage = table.concat(errors, "\n") -- 470
		if errorMessage ~= "" then -- 471
			print("\n" .. errorMessage) -- 471
		end -- 471
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 472
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 473
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 474
		Content:clearPathCache() -- 475
		teal.clear() -- 476
		yue.clear() -- 477
		building = false -- 478
	end) -- 478
end -- 323
local doClean -- 480
doClean = function() -- 480
	if building then -- 481
		return -- 481
	end -- 481
	local writablePath = Content.writablePath -- 482
	local targetDir = Path(writablePath, ".build") -- 483
	Content:clearPathCache() -- 484
	if Content:remove(targetDir) then -- 485
		return print("Cleaned: " .. tostring(targetDir)) -- 486
	end -- 485
end -- 480
local screenScale = 2.0 -- 488
local scaleContent = false -- 489
local isInEntry = true -- 490
local currentEntry = nil -- 491
local footerWindow = nil -- 493
local entryWindow = nil -- 494
local testingThread = nil -- 495
local setupEventHandlers = nil -- 497
local allClear -- 499
allClear = function() -- 499
	local _list_0 = Routine -- 500
	for _index_0 = 1, #_list_0 do -- 500
		local routine = _list_0[_index_0] -- 500
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 502
			goto _continue_0 -- 503
		else -- 505
			Routine:remove(routine) -- 505
		end -- 505
		::_continue_0:: -- 501
	end -- 505
	for _index_0 = 1, #moduleCache do -- 506
		local module = moduleCache[_index_0] -- 506
		package.loaded[module] = nil -- 507
	end -- 507
	moduleCache = { } -- 508
	Director:cleanup() -- 509
	Cache:unload() -- 510
	Entity:clear() -- 511
	Platformer.Data:clear() -- 512
	Platformer.UnitAction:clear() -- 513
	Audio:stopStream(0.5) -- 514
	Struct:clear() -- 515
	View.postEffect = nil -- 516
	View.scale = scaleContent and screenScale or 1 -- 517
	Director.clearColor = Color(0xff1a1a1a) -- 518
	teal.clear() -- 519
	yue.clear() -- 520
	for _, item in pairs(ubox()) do -- 521
		local node = tolua.cast(item, "Node") -- 522
		if node then -- 522
			node:cleanup() -- 522
		end -- 522
	end -- 522
	collectgarbage() -- 523
	collectgarbage() -- 524
	setupEventHandlers() -- 525
	Content.searchPaths = searchPaths -- 526
	App.idled = true -- 527
	return Wasm:clear() -- 528
end -- 499
_module_0["allClear"] = allClear -- 528
local clearTempFiles -- 530
clearTempFiles = function() -- 530
	local writablePath = Content.writablePath -- 531
	Content:remove(Path(writablePath, ".upload")) -- 532
	return Content:remove(Path(writablePath, ".download")) -- 533
end -- 530
local _anon_func_0 = function(App, _with_0) -- 548
	local _val_0 = App.platform -- 548
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 548
end -- 548
setupEventHandlers = function() -- 535
	local _with_0 = Director.postNode -- 536
	_with_0:onAppEvent(function(eventType) -- 537
		if eventType == "Quit" then -- 537
			allClear() -- 538
			return clearTempFiles() -- 539
		end -- 537
	end) -- 537
	_with_0:onAppChange(function(settingName) -- 540
		if "Theme" == settingName then -- 541
			config.themeColor = App.themeColor:toARGB() -- 542
		elseif "Locale" == settingName then -- 543
			config.locale = App.locale -- 544
			updateLocale() -- 545
			return teal.clear(true) -- 546
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 547
			if _anon_func_0(App, _with_0) then -- 548
				if "FullScreen" == settingName then -- 550
					config.fullScreen = App.fullScreen -- 550
				elseif "Position" == settingName then -- 551
					local _obj_0 = App.winPosition -- 551
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 551
				elseif "Size" == settingName then -- 552
					local width, height -- 553
					do -- 553
						local _obj_0 = App.winSize -- 553
						width, height = _obj_0.width, _obj_0.height -- 553
					end -- 553
					config.winWidth = width -- 554
					config.winHeight = height -- 555
				end -- 555
			end -- 548
		end -- 555
	end) -- 540
	_with_0:onAppWS(function(eventType) -- 556
		if eventType == "Close" then -- 556
			if HttpServer.wsConnectionCount == 0 then -- 557
				return updateEntries() -- 558
			end -- 557
		end -- 556
	end) -- 556
	return _with_0 -- 536
end -- 535
setupEventHandlers() -- 560
clearTempFiles() -- 561
local stop -- 563
stop = function() -- 563
	if isInEntry then -- 564
		return false -- 564
	end -- 564
	allClear() -- 565
	isInEntry = true -- 566
	currentEntry = nil -- 567
	return true -- 568
end -- 563
_module_0["stop"] = stop -- 568
local _anon_func_1 = function(Content, Path, file, require, type) -- 590
	local scriptPath = Path:getPath(file) -- 583
	Content:insertSearchPath(1, scriptPath) -- 584
	scriptPath = Path(scriptPath, "Script") -- 585
	if Content:exist(scriptPath) then -- 586
		Content:insertSearchPath(1, scriptPath) -- 587
	end -- 586
	local result = require(file) -- 588
	if "function" == type(result) then -- 589
		result() -- 589
	end -- 589
	return nil -- 590
end -- 583
local _anon_func_2 = function(Label, _with_0, err, fontSize, width) -- 622
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 619
	label.alignment = "Left" -- 620
	label.textWidth = width - fontSize -- 621
	label.text = err -- 622
	return label -- 619
end -- 619
local enterEntryAsync -- 570
enterEntryAsync = function(entry) -- 570
	isInEntry = false -- 571
	App.idled = false -- 572
	emit(Profiler.EventName, "ClearLoader") -- 573
	currentEntry = entry -- 574
	local name, file = entry[1], entry[2] -- 575
	if cppTestSet[entry] then -- 576
		if App:runTest(name) then -- 577
			return true -- 578
		else -- 580
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 580
		end -- 577
	end -- 576
	sleep() -- 581
	return xpcall(_anon_func_1, function(msg) -- 623
		local err = debug.traceback(msg) -- 592
		Log("Error", err) -- 593
		allClear() -- 594
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 595
		local viewWidth, viewHeight -- 596
		do -- 596
			local _obj_0 = View.size -- 596
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 596
		end -- 596
		local width, height = viewWidth - 20, viewHeight - 20 -- 597
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 598
		Director.ui:addChild((function() -- 599
			local root = AlignNode() -- 599
			do -- 600
				local _obj_0 = App.bufferSize -- 600
				width, height = _obj_0.width, _obj_0.height -- 600
			end -- 600
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 601
			root:onAppChange(function(settingName) -- 602
				if settingName == "Size" then -- 602
					do -- 603
						local _obj_0 = App.bufferSize -- 603
						width, height = _obj_0.width, _obj_0.height -- 603
					end -- 603
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 604
				end -- 602
			end) -- 602
			root:addChild((function() -- 605
				local _with_0 = ScrollArea({ -- 606
					width = width, -- 606
					height = height, -- 607
					paddingX = 0, -- 608
					paddingY = 50, -- 609
					viewWidth = height, -- 610
					viewHeight = height -- 611
				}) -- 605
				root:onAlignLayout(function(w, h) -- 613
					_with_0.position = Vec2(w / 2, h / 2) -- 614
					w = w - 20 -- 615
					h = h - 20 -- 616
					_with_0.view.children.first.textWidth = w - fontSize -- 617
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 618
				end) -- 613
				_with_0.view:addChild(_anon_func_2(Label, _with_0, err, fontSize, width)) -- 619
				return _with_0 -- 605
			end)()) -- 605
			return root -- 599
		end)()) -- 599
		return err -- 623
	end, Content, Path, file, require, type) -- 623
end -- 570
_module_0["enterEntryAsync"] = enterEntryAsync -- 623
local enterDemoEntry -- 625
enterDemoEntry = function(entry) -- 625
	return thread(function() -- 625
		return enterEntryAsync(entry) -- 625
	end) -- 625
end -- 625
local reloadCurrentEntry -- 627
reloadCurrentEntry = function() -- 627
	if currentEntry then -- 628
		allClear() -- 629
		return enterDemoEntry(currentEntry) -- 630
	end -- 628
end -- 627
Director.clearColor = Color(0xff1a1a1a) -- 632
local waitForWebStart = true -- 634
thread(function() -- 635
	sleep(2) -- 636
	waitForWebStart = false -- 637
end) -- 635
local reloadDevEntry -- 639
reloadDevEntry = function() -- 639
	return thread(function() -- 639
		waitForWebStart = true -- 640
		doClean() -- 641
		allClear() -- 642
		_G.require = oldRequire -- 643
		Dora.require = oldRequire -- 644
		package.loaded["Script.Dev.Entry"] = nil -- 645
		return Director.systemScheduler:schedule(function() -- 646
			Routine:clear() -- 647
			oldRequire("Script.Dev.Entry") -- 648
			return true -- 649
		end) -- 649
	end) -- 649
end -- 639
local isOSSLicenseExist = Content:exist("LICENSES") -- 651
local ossLicenses = nil -- 652
local ossLicenseOpen = false -- 653
local _anon_func_3 = function(App) -- 657
	local _val_0 = App.platform -- 657
	return not ("Android" == _val_0 or "iOS" == _val_0) -- 657
end -- 657
local extraOperations -- 655
extraOperations = function() -- 655
	local zh = useChinese and isChineseSupported -- 656
	if _anon_func_3(App) then -- 657
		local alwaysOnTop = config.alwaysOnTop -- 658
		local changed -- 659
		changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 659
		if changed then -- 659
			App.alwaysOnTop = alwaysOnTop -- 660
			config.alwaysOnTop = alwaysOnTop -- 661
		end -- 659
	end -- 657
	if isOSSLicenseExist then -- 662
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 663
			if not ossLicenses then -- 664
				ossLicenses = { } -- 665
				local licenseText = Content:load("LICENSES") -- 666
				ossLicenseOpen = (licenseText ~= nil) -- 667
				if ossLicenseOpen then -- 667
					licenseText = licenseText:gsub("\r\n", "\n") -- 668
					for license in GSplit(licenseText, "\n--------\n", true) do -- 669
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 670
						if name then -- 670
							ossLicenses[#ossLicenses + 1] = { -- 671
								name, -- 671
								text -- 671
							} -- 671
						end -- 670
					end -- 671
				end -- 667
			else -- 673
				ossLicenseOpen = true -- 673
			end -- 664
		end -- 663
		if ossLicenseOpen then -- 674
			local width, height, themeColor -- 675
			do -- 675
				local _obj_0 = App -- 675
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 675
			end -- 675
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 676
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 677
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 678
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 681
					"NoSavedSettings" -- 681
				}, function() -- 682
					for _index_0 = 1, #ossLicenses do -- 682
						local _des_0 = ossLicenses[_index_0] -- 682
						local firstLine, text = _des_0[1], _des_0[2] -- 682
						local name, license = firstLine:match("(.+): (.+)") -- 683
						TextColored(themeColor, name) -- 684
						SameLine() -- 685
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 686
							return TextWrapped(text) -- 686
						end) -- 686
					end -- 686
				end) -- 678
			end) -- 678
		end -- 674
	end -- 662
	if not App.debugging then -- 688
		return -- 688
	end -- 688
	return TreeNode(zh and "开发操作" or "Development", function() -- 689
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 690
			OpenPopup("build") -- 690
		end -- 690
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 691
			return BeginPopup("build", function() -- 691
				if Selectable(zh and "编译" or "Compile") then -- 692
					doCompile(false) -- 692
				end -- 692
				Separator() -- 693
				if Selectable(zh and "压缩" or "Minify") then -- 694
					doCompile(true) -- 694
				end -- 694
				Separator() -- 695
				if Selectable(zh and "清理" or "Clean") then -- 696
					return doClean() -- 696
				end -- 696
			end) -- 696
		end) -- 691
		if isInEntry then -- 697
			if waitForWebStart then -- 698
				BeginDisabled(function() -- 699
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 699
				end) -- 699
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 700
				reloadDevEntry() -- 701
			end -- 698
		end -- 697
		do -- 702
			local changed -- 702
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 702
			if changed then -- 702
				View.scale = scaleContent and screenScale or 1 -- 703
			end -- 702
		end -- 702
		do -- 704
			local changed -- 704
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 704
			if changed then -- 704
				config.engineDev = engineDev -- 705
			end -- 704
		end -- 704
		if Button(zh and "开始自动测试" or "Test automatically") then -- 706
			testingThread = thread(function() -- 707
				local _ <close> = setmetatable({ }, { -- 708
					__close = function() -- 708
						allClear() -- 709
						testingThread = nil -- 710
						isInEntry = true -- 711
						currentEntry = nil -- 712
						return print("Testing done!") -- 713
					end -- 708
				}) -- 708
				for _, entry in ipairs(allEntries) do -- 714
					allClear() -- 715
					print("Start " .. tostring(entry[1])) -- 716
					enterDemoEntry(entry) -- 717
					sleep(2) -- 718
					print("Stop " .. tostring(entry[1])) -- 719
				end -- 719
			end) -- 707
		end -- 706
	end) -- 689
end -- 655
local transparant = Color(0x0) -- 721
local windowFlags = { -- 722
	"NoTitleBar", -- 722
	"NoResize", -- 722
	"NoMove", -- 722
	"NoCollapse", -- 722
	"NoSavedSettings", -- 722
	"NoBringToFrontOnFocus" -- 722
} -- 722
local initFooter = true -- 730
local _anon_func_4 = function(allEntries, currentIndex) -- 766
	if currentIndex > 1 then -- 766
		return allEntries[currentIndex - 1] -- 767
	else -- 769
		return allEntries[#allEntries] -- 769
	end -- 766
end -- 766
local _anon_func_5 = function(allEntries, currentIndex) -- 773
	if currentIndex < #allEntries then -- 773
		return allEntries[currentIndex + 1] -- 774
	else -- 776
		return allEntries[1] -- 776
	end -- 773
end -- 773
footerWindow = threadLoop(function() -- 731
	local zh = useChinese and isChineseSupported -- 732
	if HttpServer.wsConnectionCount > 0 then -- 733
		return -- 734
	end -- 733
	if Keyboard:isKeyDown("Escape") then -- 735
		allClear() -- 736
		App:shutdown() -- 737
	end -- 735
	do -- 738
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 739
		if ctrl and Keyboard:isKeyDown("Q") then -- 740
			stop() -- 741
		end -- 740
		if ctrl and Keyboard:isKeyDown("Z") then -- 742
			reloadCurrentEntry() -- 743
		end -- 742
		if ctrl and Keyboard:isKeyDown(",") then -- 744
			if showFooter then -- 745
				showStats = not showStats -- 745
			else -- 745
				showStats = true -- 745
			end -- 745
			showFooter = true -- 746
			config.showFooter = showFooter -- 747
			config.showStats = showStats -- 748
		end -- 744
		if ctrl and Keyboard:isKeyDown(".") then -- 749
			if showFooter then -- 750
				showConsole = not showConsole -- 750
			else -- 750
				showConsole = true -- 750
			end -- 750
			showFooter = true -- 751
			config.showFooter = showFooter -- 752
			config.showConsole = showConsole -- 753
		end -- 749
		if ctrl and Keyboard:isKeyDown("/") then -- 754
			showFooter = not showFooter -- 755
			config.showFooter = showFooter -- 756
		end -- 754
		local left = ctrl and Keyboard:isKeyDown("Left") -- 757
		local right = ctrl and Keyboard:isKeyDown("Right") -- 758
		local currentIndex = nil -- 759
		for i, entry in ipairs(allEntries) do -- 760
			if currentEntry == entry then -- 761
				currentIndex = i -- 762
			end -- 761
		end -- 762
		if left then -- 763
			allClear() -- 764
			if currentIndex == nil then -- 765
				currentIndex = #allEntries + 1 -- 765
			end -- 765
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 766
		end -- 763
		if right then -- 770
			allClear() -- 771
			if currentIndex == nil then -- 772
				currentIndex = 0 -- 772
			end -- 772
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 773
		end -- 770
	end -- 776
	if not showEntry then -- 777
		return -- 777
	end -- 777
	local width, height -- 779
	do -- 779
		local _obj_0 = App.visualSize -- 779
		width, height = _obj_0.width, _obj_0.height -- 779
	end -- 779
	SetNextWindowSize(Vec2(50, 50)) -- 780
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 781
	PushStyleColor("WindowBg", transparant, function() -- 782
		return Begin("Show", windowFlags, function() -- 782
			if isInEntry or width >= 540 then -- 783
				local changed -- 784
				changed, showFooter = Checkbox("##dev", showFooter) -- 784
				if changed then -- 784
					config.showFooter = showFooter -- 785
				end -- 784
			end -- 783
		end) -- 785
	end) -- 782
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 787
		reloadDevEntry() -- 791
	end -- 787
	if initFooter then -- 792
		initFooter = false -- 793
	else -- 795
		if not showFooter then -- 795
			return -- 795
		end -- 795
	end -- 792
	SetNextWindowSize(Vec2(width, 50)) -- 797
	SetNextWindowPos(Vec2(0, height - 50)) -- 798
	SetNextWindowBgAlpha(0.35) -- 799
	do -- 800
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 801
			return Begin("Footer", windowFlags, function() -- 802
				Dummy(Vec2(width - 20, 0)) -- 803
				do -- 804
					local changed -- 804
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 804
					if changed then -- 804
						config.showStats = showStats -- 805
					end -- 804
				end -- 804
				SameLine() -- 806
				do -- 807
					local changed -- 807
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 807
					if changed then -- 807
						config.showConsole = showConsole -- 808
					end -- 807
				end -- 807
				if config.updateNotification then -- 809
					SameLine() -- 810
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 811
						config.updateNotification = false -- 812
						enterDemoEntry({ -- 813
							"SelfUpdater", -- 813
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 813
						}) -- 813
					end -- 811
				end -- 809
				if not isInEntry then -- 814
					SameLine() -- 815
					if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 816
						allClear() -- 817
						isInEntry = true -- 818
						currentEntry = nil -- 819
					end -- 816
					local currentIndex = nil -- 820
					for i, entry in ipairs(allEntries) do -- 821
						if currentEntry == entry then -- 822
							currentIndex = i -- 823
						end -- 822
					end -- 823
					if currentIndex then -- 824
						if currentIndex > 1 then -- 825
							SameLine() -- 826
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 827
								allClear() -- 828
								enterDemoEntry(allEntries[currentIndex - 1]) -- 829
							end -- 827
						end -- 825
						if currentIndex < #allEntries then -- 830
							SameLine() -- 831
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 832
								allClear() -- 833
								enterDemoEntry(allEntries[currentIndex + 1]) -- 834
							end -- 832
						end -- 830
					end -- 824
					SameLine() -- 835
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 836
						reloadCurrentEntry() -- 837
					end -- 836
				end -- 814
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 838
					if showStats then -- 839
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 840
						showStats = ShowStats(showStats, extraOperations) -- 841
						config.showStats = showStats -- 842
					end -- 839
					if showConsole then -- 843
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 844
						showConsole = ShowConsole(showConsole) -- 845
						config.showConsole = showConsole -- 846
					end -- 843
				end) -- 838
			end) -- 802
		end) -- 801
	end -- 846
end) -- 731
local MaxWidth <const> = 800 -- 848
local displayWindowFlags = { -- 850
	"NoDecoration", -- 850
	"NoSavedSettings", -- 850
	"NoFocusOnAppearing", -- 850
	"NoNav", -- 850
	"NoMove", -- 850
	"NoScrollWithMouse", -- 850
	"AlwaysAutoResize", -- 850
	"NoBringToFrontOnFocus" -- 850
} -- 850
local webStatus = nil -- 861
local descColor = Color(0xffa1a1a1) -- 862
local gameOpen = #gamesInDev == 0 -- 863
local toolOpen = false -- 864
local exampleOpen = false -- 865
local testOpen = false -- 866
local filterText = nil -- 867
local anyEntryMatched = false -- 868
local urlClicked = nil -- 869
local match -- 870
match = function(name) -- 870
	local res = not filterText or name:lower():match(filterText) -- 871
	if res then -- 872
		anyEntryMatched = true -- 872
	end -- 872
	return res -- 873
end -- 870
local iconTex = nil -- 874
thread(function() -- 875
	if Cache:loadAsync("Image/icon_s.png") then -- 875
		iconTex = Texture2D("Image/icon_s.png") -- 876
	end -- 875
end) -- 875
entryWindow = threadLoop(function() -- 878
	if App.fpsLimited ~= config.fpsLimited then -- 879
		config.fpsLimited = App.fpsLimited -- 880
	end -- 879
	if App.targetFPS ~= config.targetFPS then -- 881
		config.targetFPS = App.targetFPS -- 882
	end -- 881
	if View.vsync ~= config.vsync then -- 883
		config.vsync = View.vsync -- 884
	end -- 883
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 885
		config.fixedFPS = Director.scheduler.fixedFPS -- 886
	end -- 885
	if Director.profilerSending ~= config.webProfiler then -- 887
		config.webProfiler = Director.profilerSending -- 888
	end -- 887
	if urlClicked then -- 889
		local _, result = coroutine.resume(urlClicked) -- 890
		if result then -- 891
			coroutine.close(urlClicked) -- 892
			urlClicked = nil -- 893
		end -- 891
	end -- 889
	if not showEntry then -- 894
		return -- 894
	end -- 894
	if not isInEntry then -- 895
		return -- 895
	end -- 895
	local zh = useChinese and isChineseSupported -- 896
	if HttpServer.wsConnectionCount > 0 then -- 897
		local themeColor = App.themeColor -- 898
		local width, height -- 899
		do -- 899
			local _obj_0 = App.visualSize -- 899
			width, height = _obj_0.width, _obj_0.height -- 899
		end -- 899
		SetNextWindowBgAlpha(0.5) -- 900
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 901
		Begin("Web IDE Connected", displayWindowFlags, function() -- 902
			Separator() -- 903
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 904
			if iconTex then -- 905
				Image("Image/icon_s.png", Vec2(24, 24)) -- 906
				SameLine() -- 907
			end -- 905
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 908
			TextColored(descColor, slogon) -- 909
			return Separator() -- 910
		end) -- 902
		return -- 911
	end -- 897
	local themeColor = App.themeColor -- 913
	local fullWidth, height -- 914
	do -- 914
		local _obj_0 = App.visualSize -- 914
		fullWidth, height = _obj_0.width, _obj_0.height -- 914
	end -- 914
	SetNextWindowBgAlpha(0.85) -- 916
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 917
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 918
		return Begin("Web IDE", displayWindowFlags, function() -- 919
			Separator() -- 920
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 921
			SameLine() -- 922
			TextDisabled('(?)') -- 923
			if IsItemHovered() then -- 924
				BeginTooltip(function() -- 925
					return PushTextWrapPos(280, function() -- 926
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 927
					end) -- 927
				end) -- 925
			end -- 924
			do -- 928
				local url -- 928
				if webStatus ~= nil then -- 928
					url = webStatus.url -- 928
				end -- 928
				if url then -- 928
					if isDesktop and not config.fullScreen then -- 929
						if urlClicked then -- 930
							BeginDisabled(function() -- 931
								return Button(url) -- 931
							end) -- 931
						elseif Button(url) then -- 932
							urlClicked = once(function() -- 933
								return sleep(5) -- 933
							end) -- 933
							App:openURL("http://localhost:8866") -- 934
						end -- 930
					else -- 936
						TextColored(descColor, url) -- 936
					end -- 929
				else -- 938
					TextColored(descColor, zh and '不可用' or 'not available') -- 938
				end -- 928
			end -- 928
			return Separator() -- 939
		end) -- 939
	end) -- 918
	local width = math.min(MaxWidth, fullWidth) -- 941
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 942
	local maxColumns = math.max(math.floor(width / 200), 1) -- 943
	SetNextWindowPos(Vec2.zero) -- 944
	SetNextWindowBgAlpha(0) -- 945
	do -- 946
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 947
			return Begin("Dora Dev", displayWindowFlags, function() -- 948
				Dummy(Vec2(fullWidth - 20, 0)) -- 949
				if iconTex then -- 950
					Image("Image/icon_s.png", Vec2(24, 24)) -- 951
					SameLine() -- 952
				end -- 950
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 953
				SameLine() -- 954
				if fullWidth >= 360 then -- 955
					Dummy(Vec2(fullWidth - 360, 0)) -- 956
					SameLine() -- 957
					SetNextItemWidth(-50) -- 958
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 959
						"AutoSelectAll" -- 959
					}) then -- 959
						config.filter = filterBuf.text -- 960
					end -- 959
				end -- 955
				Separator() -- 961
				return Dummy(Vec2(fullWidth - 20, 0)) -- 962
			end) -- 948
		end) -- 947
	end -- 962
	anyEntryMatched = false -- 964
	SetNextWindowPos(Vec2(0, 50)) -- 965
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 966
	do -- 967
		return PushStyleColor("WindowBg", transparant, function() -- 968
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 969
				return Begin("Content", windowFlags, function() -- 970
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 971
					if filterText then -- 972
						filterText = filterText:lower() -- 972
					end -- 972
					if #gamesInDev > 0 then -- 973
						for _index_0 = 1, #gamesInDev do -- 974
							local game = gamesInDev[_index_0] -- 974
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 975
							local showSep = false -- 976
							if match(gameName) then -- 977
								Columns(1, false) -- 978
								TextColored(themeColor, zh and "项目：" or "Project:") -- 979
								SameLine() -- 980
								Text(gameName) -- 981
								Separator() -- 982
								if bannerFile then -- 983
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 984
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 985
									local sizing <const> = 0.8 -- 986
									texHeight = displayWidth * sizing * texHeight / texWidth -- 987
									texWidth = displayWidth * sizing -- 988
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 989
									Dummy(Vec2(padding, 0)) -- 990
									SameLine() -- 991
									PushID(fileName, function() -- 992
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 993
											return enterDemoEntry(game) -- 994
										end -- 993
									end) -- 992
								else -- 996
									PushID(fileName, function() -- 996
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 997
											return enterDemoEntry(game) -- 998
										end -- 997
									end) -- 996
								end -- 983
								NextColumn() -- 999
								showSep = true -- 1000
							end -- 977
							if #examples > 0 then -- 1001
								local showExample = false -- 1002
								for _index_1 = 1, #examples do -- 1003
									local example = examples[_index_1] -- 1003
									if match(example[1]) then -- 1004
										showExample = true -- 1005
										break -- 1006
									end -- 1004
								end -- 1006
								if showExample then -- 1007
									Columns(1, false) -- 1008
									TextColored(themeColor, zh and "示例：" or "Example:") -- 1009
									SameLine() -- 1010
									Text(gameName) -- 1011
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1012
										Columns(maxColumns, false) -- 1013
										for _index_1 = 1, #examples do -- 1014
											local example = examples[_index_1] -- 1014
											if not match(example[1]) then -- 1015
												goto _continue_0 -- 1015
											end -- 1015
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1016
												if Button(example[1], Vec2(-1, 40)) then -- 1017
													enterDemoEntry(example) -- 1018
												end -- 1017
												return NextColumn() -- 1019
											end) -- 1016
											showSep = true -- 1020
											::_continue_0:: -- 1015
										end -- 1020
									end) -- 1012
								end -- 1007
							end -- 1001
							if #tests > 0 then -- 1021
								local showTest = false -- 1022
								for _index_1 = 1, #tests do -- 1023
									local test = tests[_index_1] -- 1023
									if match(test[1]) then -- 1024
										showTest = true -- 1025
										break -- 1026
									end -- 1024
								end -- 1026
								if showTest then -- 1027
									Columns(1, false) -- 1028
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1029
									SameLine() -- 1030
									Text(gameName) -- 1031
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1032
										Columns(maxColumns, false) -- 1033
										for _index_1 = 1, #tests do -- 1034
											local test = tests[_index_1] -- 1034
											if not match(test[1]) then -- 1035
												goto _continue_0 -- 1035
											end -- 1035
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1036
												if Button(test[1], Vec2(-1, 40)) then -- 1037
													enterDemoEntry(test) -- 1038
												end -- 1037
												return NextColumn() -- 1039
											end) -- 1036
											showSep = true -- 1040
											::_continue_0:: -- 1035
										end -- 1040
									end) -- 1032
								end -- 1027
							end -- 1021
							if showSep then -- 1041
								Columns(1, false) -- 1042
								Separator() -- 1043
							end -- 1041
						end -- 1043
					end -- 973
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1044
						local showGame = false -- 1045
						for _index_0 = 1, #games do -- 1046
							local _des_0 = games[_index_0] -- 1046
							local name = _des_0[1] -- 1046
							if match(name) then -- 1047
								showGame = true -- 1047
							end -- 1047
						end -- 1047
						local showTool = false -- 1048
						for _index_0 = 1, #doraTools do -- 1049
							local _des_0 = doraTools[_index_0] -- 1049
							local name = _des_0[1] -- 1049
							if match(name) then -- 1050
								showTool = true -- 1050
							end -- 1050
						end -- 1050
						local showExample = false -- 1051
						for _index_0 = 1, #doraExamples do -- 1052
							local _des_0 = doraExamples[_index_0] -- 1052
							local name = _des_0[1] -- 1052
							if match(name) then -- 1053
								showExample = true -- 1053
							end -- 1053
						end -- 1053
						local showTest = false -- 1054
						for _index_0 = 1, #doraTests do -- 1055
							local _des_0 = doraTests[_index_0] -- 1055
							local name = _des_0[1] -- 1055
							if match(name) then -- 1056
								showTest = true -- 1056
							end -- 1056
						end -- 1056
						for _index_0 = 1, #cppTests do -- 1057
							local _des_0 = cppTests[_index_0] -- 1057
							local name = _des_0[1] -- 1057
							if match(name) then -- 1058
								showTest = true -- 1058
							end -- 1058
						end -- 1058
						if not (showGame or showTool or showExample or showTest) then -- 1059
							goto endEntry -- 1059
						end -- 1059
						Columns(1, false) -- 1060
						TextColored(themeColor, "Dora SSR:") -- 1061
						SameLine() -- 1062
						Text(zh and "开发示例" or "Development Showcase") -- 1063
						Separator() -- 1064
						local demoViewWith <const> = 400 -- 1065
						if #games > 0 and showGame then -- 1066
							local opened -- 1067
							if (filterText ~= nil) then -- 1067
								opened = showGame -- 1067
							else -- 1067
								opened = false -- 1067
							end -- 1067
							SetNextItemOpen(gameOpen) -- 1068
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1069
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1070
								Columns(columns, false) -- 1071
								for _index_0 = 1, #games do -- 1072
									local game = games[_index_0] -- 1072
									if not match(game[1]) then -- 1073
										goto _continue_0 -- 1073
									end -- 1073
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1074
									if columns > 1 then -- 1075
										if bannerFile then -- 1076
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1077
											local displayWidth <const> = demoViewWith - 40 -- 1078
											texHeight = displayWidth * texHeight / texWidth -- 1079
											texWidth = displayWidth -- 1080
											Text(gameName) -- 1081
											PushID(fileName, function() -- 1082
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1083
													return enterDemoEntry(game) -- 1084
												end -- 1083
											end) -- 1082
										else -- 1086
											PushID(fileName, function() -- 1086
												if Button(gameName, Vec2(-1, 40)) then -- 1087
													return enterDemoEntry(game) -- 1088
												end -- 1087
											end) -- 1086
										end -- 1076
									else -- 1090
										if bannerFile then -- 1090
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1091
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1092
											local sizing = 0.8 -- 1093
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1094
											texWidth = displayWidth * sizing -- 1095
											if texWidth > 500 then -- 1096
												sizing = 0.6 -- 1097
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1098
												texWidth = displayWidth * sizing -- 1099
											end -- 1096
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1100
											Dummy(Vec2(padding, 0)) -- 1101
											SameLine() -- 1102
											Text(gameName) -- 1103
											Dummy(Vec2(padding, 0)) -- 1104
											SameLine() -- 1105
											PushID(fileName, function() -- 1106
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1107
													return enterDemoEntry(game) -- 1108
												end -- 1107
											end) -- 1106
										else -- 1110
											PushID(fileName, function() -- 1110
												if Button(gameName, Vec2(-1, 40)) then -- 1111
													return enterDemoEntry(game) -- 1112
												end -- 1111
											end) -- 1110
										end -- 1090
									end -- 1075
									NextColumn() -- 1113
									::_continue_0:: -- 1073
								end -- 1113
								Columns(1, false) -- 1114
								opened = true -- 1115
							end) -- 1069
							gameOpen = opened -- 1116
						end -- 1066
						if #doraTools > 0 and showTool then -- 1117
							local opened -- 1118
							if (filterText ~= nil) then -- 1118
								opened = showTool -- 1118
							else -- 1118
								opened = false -- 1118
							end -- 1118
							SetNextItemOpen(toolOpen) -- 1119
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1120
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1121
									Columns(maxColumns, false) -- 1122
									for _index_0 = 1, #doraTools do -- 1123
										local example = doraTools[_index_0] -- 1123
										if not match(example[1]) then -- 1124
											goto _continue_0 -- 1124
										end -- 1124
										if Button(example[1], Vec2(-1, 40)) then -- 1125
											enterDemoEntry(example) -- 1126
										end -- 1125
										NextColumn() -- 1127
										::_continue_0:: -- 1124
									end -- 1127
									Columns(1, false) -- 1128
									opened = true -- 1129
								end) -- 1121
							end) -- 1120
							toolOpen = opened -- 1130
						end -- 1117
						if #doraExamples > 0 and showExample then -- 1131
							local opened -- 1132
							if (filterText ~= nil) then -- 1132
								opened = showExample -- 1132
							else -- 1132
								opened = false -- 1132
							end -- 1132
							SetNextItemOpen(exampleOpen) -- 1133
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1134
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1135
									Columns(maxColumns, false) -- 1136
									for _index_0 = 1, #doraExamples do -- 1137
										local example = doraExamples[_index_0] -- 1137
										if not match(example[1]) then -- 1138
											goto _continue_0 -- 1138
										end -- 1138
										if Button(example[1], Vec2(-1, 40)) then -- 1139
											enterDemoEntry(example) -- 1140
										end -- 1139
										NextColumn() -- 1141
										::_continue_0:: -- 1138
									end -- 1141
									Columns(1, false) -- 1142
									opened = true -- 1143
								end) -- 1135
							end) -- 1134
							exampleOpen = opened -- 1144
						end -- 1131
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1145
							local opened -- 1146
							if (filterText ~= nil) then -- 1146
								opened = showTest -- 1146
							else -- 1146
								opened = false -- 1146
							end -- 1146
							SetNextItemOpen(testOpen) -- 1147
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1148
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1149
									Columns(maxColumns, false) -- 1150
									for _index_0 = 1, #doraTests do -- 1151
										local test = doraTests[_index_0] -- 1151
										if not match(test[1]) then -- 1152
											goto _continue_0 -- 1152
										end -- 1152
										if Button(test[1], Vec2(-1, 40)) then -- 1153
											enterDemoEntry(test) -- 1154
										end -- 1153
										NextColumn() -- 1155
										::_continue_0:: -- 1152
									end -- 1155
									for _index_0 = 1, #cppTests do -- 1156
										local test = cppTests[_index_0] -- 1156
										if not match(test[1]) then -- 1157
											goto _continue_1 -- 1157
										end -- 1157
										if Button(test[1], Vec2(-1, 40)) then -- 1158
											enterDemoEntry(test) -- 1159
										end -- 1158
										NextColumn() -- 1160
										::_continue_1:: -- 1157
									end -- 1160
									opened = true -- 1161
								end) -- 1149
							end) -- 1148
							testOpen = opened -- 1162
						end -- 1145
					end -- 1044
					::endEntry:: -- 1163
					if not anyEntryMatched then -- 1164
						SetNextWindowBgAlpha(0) -- 1165
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1166
						Begin("Entries Not Found", displayWindowFlags, function() -- 1167
							Separator() -- 1168
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1169
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1170
							return Separator() -- 1171
						end) -- 1167
					end -- 1164
					Columns(1, false) -- 1172
					Dummy(Vec2(100, 80)) -- 1173
					return ScrollWhenDraggingOnVoid() -- 1174
				end) -- 970
			end) -- 969
		end) -- 968
	end -- 1174
end) -- 878
webStatus = require("Script.Dev.WebServer") -- 1176
return _module_0 -- 1176
