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
local math = _G.math -- 1
local AlignNode = Dora.AlignNode -- 1
local Label = Dora.Label -- 1
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
local Checkbox = _module_0.Checkbox -- 1
local threadLoop = Dora.threadLoop -- 1
local Keyboard = Dora.Keyboard -- 1
local ipairs = _G.ipairs -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local PushStyleColor = _module_0.PushStyleColor -- 1
local SetNextWindowBgAlpha = _module_0.SetNextWindowBgAlpha -- 1
local Dummy = _module_0.Dummy -- 1
local ShowStats = _module_0.ShowStats -- 1
local coroutine = _G.coroutine -- 1
local once = Dora.once -- 1
local SetNextItemWidth = _module_0.SetNextItemWidth -- 1
local InputText = _module_0.InputText -- 1
local Columns = _module_0.Columns -- 1
local Text = _module_0.Text -- 1
local PushID = _module_0.PushID -- 1
local ImageButton = _module_0.ImageButton -- 1
local NextColumn = _module_0.NextColumn -- 1
local SetNextItemOpen = _module_0.SetNextItemOpen -- 1
local ScrollWhenDraggingOnVoid = _module_0.ScrollWhenDraggingOnVoid -- 1
local _module_0 = { } -- 1
local Content, Path -- 10
do -- 10
	local _obj_0 = Dora -- 10
	Content, Path = _obj_0.Content, _obj_0.Path -- 10
end -- 10
local type <const> = type -- 11
App.idled = true -- 13
ShowConsole(false, true) -- 14
local moduleCache = { } -- 16
local oldRequire = _G.require -- 17
local require -- 18
require = function(path) -- 18
	local loaded = package.loaded[path] -- 19
	if loaded == nil then -- 20
		moduleCache[#moduleCache + 1] = path -- 21
		return oldRequire(path) -- 22
	end -- 20
	return loaded -- 23
end -- 18
_G.require = require -- 24
Dora.require = require -- 25
local searchPaths = Content.searchPaths -- 27
local useChinese = (App.locale:match("^zh") ~= nil) -- 29
local updateLocale -- 30
updateLocale = function() -- 30
	useChinese = (App.locale:match("^zh") ~= nil) -- 31
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 32
	Content.searchPaths = searchPaths -- 33
end -- 30
if DB:exist("Config") then -- 35
	local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 36
	local _type_0 = type(_exp_0) -- 37
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 37
	if _tab_0 then -- 37
		local locale -- 37
		do -- 37
			local _obj_0 = _exp_0[1] -- 37
			local _type_1 = type(_obj_0) -- 37
			if "table" == _type_1 or "userdata" == _type_1 then -- 37
				locale = _obj_0[1] -- 37
			end -- 39
		end -- 39
		if locale ~= nil then -- 37
			if App.locale ~= locale then -- 37
				App.locale = locale -- 38
				updateLocale() -- 39
			end -- 37
		end -- 37
	end -- 39
end -- 35
local Config = require("Config") -- 41
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth") -- 42
config:load() -- 64
if (config.fpsLimited ~= nil) then -- 65
	App.fpsLimited = config.fpsLimited -- 66
else -- 68
	config.fpsLimited = App.fpsLimited -- 68
end -- 65
if (config.targetFPS ~= nil) then -- 70
	App.targetFPS = config.targetFPS -- 71
else -- 73
	config.targetFPS = App.targetFPS -- 73
end -- 70
if (config.vsync ~= nil) then -- 75
	View.vsync = config.vsync -- 76
else -- 78
	config.vsync = View.vsync -- 78
end -- 75
if (config.fixedFPS ~= nil) then -- 80
	Director.scheduler.fixedFPS = config.fixedFPS -- 81
else -- 83
	config.fixedFPS = Director.scheduler.fixedFPS -- 83
end -- 80
local showEntry = true -- 85
local isDesktop = false -- 87
if (function() -- 88
	local _val_0 = App.platform -- 88
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 88
end)() then -- 88
	isDesktop = true -- 89
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 90
		App.winSize = Size.zero -- 91
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 92
		local size = Size(config.winWidth, config.winHeight) -- 93
		if App.winSize ~= size then -- 94
			App.winSize = size -- 95
			showEntry = false -- 96
			thread(function() -- 97
				sleep() -- 98
				sleep() -- 99
				showEntry = true -- 100
			end) -- 97
		end -- 94
		local winX, winY -- 101
		do -- 101
			local _obj_0 = App.winPosition -- 101
			winX, winY = _obj_0.x, _obj_0.y -- 101
		end -- 101
		if (config.winX ~= nil) then -- 102
			winX = config.winX -- 103
		else -- 105
			config.winX = 0 -- 105
		end -- 102
		if (config.winY ~= nil) then -- 106
			winY = config.winY -- 107
		else -- 109
			config.winY = 0 -- 109
		end -- 106
		App.winPosition = Vec2(winX, winY) -- 110
	end -- 90
end -- 88
if (config.themeColor ~= nil) then -- 112
	App.themeColor = Color(config.themeColor) -- 113
else -- 115
	config.themeColor = App.themeColor:toARGB() -- 115
end -- 112
if not (config.locale ~= nil) then -- 117
	config.locale = App.locale -- 118
end -- 117
local showStats = false -- 120
if (config.showStats ~= nil) then -- 121
	showStats = config.showStats -- 122
else -- 124
	config.showStats = showStats -- 124
end -- 121
local showConsole = true -- 126
if (config.showConsole ~= nil) then -- 127
	showConsole = config.showConsole -- 128
else -- 130
	config.showConsole = showConsole -- 130
end -- 127
local showFooter = true -- 132
if (config.showFooter ~= nil) then -- 133
	showFooter = config.showFooter -- 134
else -- 136
	config.showFooter = showFooter -- 136
end -- 133
local filterBuf = Buffer(20) -- 138
if (config.filter ~= nil) then -- 139
	filterBuf.text = config.filter -- 140
else -- 142
	config.filter = "" -- 142
end -- 139
local engineDev = false -- 144
if (config.engineDev ~= nil) then -- 145
	engineDev = config.engineDev -- 146
else -- 148
	config.engineDev = engineDev -- 148
end -- 145
if (config.webProfiler ~= nil) then -- 150
	Director.profilerSending = config.webProfiler -- 151
else -- 153
	config.webProfiler = true -- 153
	Director.profilerSending = true -- 154
end -- 150
if not (config.drawerWidth ~= nil) then -- 156
	config.drawerWidth = 200 -- 157
end -- 156
_module_0.getConfig = function() -- 159
	return config -- 159
end -- 159
_module_0.getEngineDev = function() -- 160
	if not App.debugging then -- 161
		return false -- 161
	end -- 161
	return config.engineDev -- 162
end -- 160
local Set, Struct, LintYueGlobals, GSplit -- 164
do -- 164
	local _obj_0 = require("Utils") -- 164
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 164
end -- 164
local yueext = yue.options.extension -- 165
local isChineseSupported = IsFontLoaded() -- 167
if not isChineseSupported then -- 168
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 169
		isChineseSupported = true -- 170
	end) -- 169
end -- 168
local building = false -- 172
local getAllFiles -- 174
getAllFiles = function(path, exts, recursive) -- 174
	if recursive == nil then -- 174
		recursive = true -- 174
	end -- 174
	local filters = Set(exts) -- 175
	local files -- 176
	if recursive then -- 176
		files = Content:getAllFiles(path) -- 177
	else -- 179
		files = Content:getFiles(path) -- 179
	end -- 176
	local _accum_0 = { } -- 180
	local _len_0 = 1 -- 180
	for _index_0 = 1, #files do -- 180
		local file = files[_index_0] -- 180
		if not filters[Path:getExt(file)] then -- 181
			goto _continue_0 -- 181
		end -- 181
		_accum_0[_len_0] = file -- 182
		_len_0 = _len_0 + 1 -- 182
		::_continue_0:: -- 181
	end -- 182
	return _accum_0 -- 182
end -- 174
local getFileEntries -- 184
getFileEntries = function(path, recursive) -- 184
	if recursive == nil then -- 184
		recursive = true -- 184
	end -- 184
	local entries = { } -- 185
	local _list_0 = getAllFiles(path, { -- 186
		"lua", -- 186
		"xml", -- 186
		yueext, -- 186
		"tl" -- 186
	}, recursive) -- 186
	for _index_0 = 1, #_list_0 do -- 186
		local file = _list_0[_index_0] -- 186
		local entryName = Path:getName(file) -- 187
		local entryAdded = false -- 188
		for _index_1 = 1, #entries do -- 189
			local _des_0 = entries[_index_1] -- 189
			local ename = _des_0[1] -- 189
			if entryName == ename then -- 190
				entryAdded = true -- 191
				break -- 192
			end -- 190
		end -- 192
		if entryAdded then -- 193
			goto _continue_0 -- 193
		end -- 193
		local fileName = Path:replaceExt(file, "") -- 194
		fileName = Path(path, fileName) -- 195
		local entry = { -- 196
			entryName, -- 196
			fileName -- 196
		} -- 196
		entries[#entries + 1] = entry -- 197
		::_continue_0:: -- 187
	end -- 197
	table.sort(entries, function(a, b) -- 198
		return a[1] < b[1] -- 198
	end) -- 198
	return entries -- 199
end -- 184
local getProjectEntries -- 201
getProjectEntries = function(path) -- 201
	local entries = { } -- 202
	local _list_0 = Content:getDirs(path) -- 203
	for _index_0 = 1, #_list_0 do -- 203
		local dir = _list_0[_index_0] -- 203
		if dir:match("^%.") then -- 204
			goto _continue_0 -- 204
		end -- 204
		local _list_1 = getAllFiles(Path(path, dir), { -- 205
			"lua", -- 205
			"xml", -- 205
			yueext, -- 205
			"tl", -- 205
			"wasm" -- 205
		}) -- 205
		for _index_1 = 1, #_list_1 do -- 205
			local file = _list_1[_index_1] -- 205
			if "init" == Path:getName(file):lower() then -- 206
				local fileName = Path:replaceExt(file, "") -- 207
				fileName = Path(path, dir, fileName) -- 208
				local entryName = Path:getName(Path:getPath(fileName)) -- 209
				local entryAdded = false -- 210
				for _index_2 = 1, #entries do -- 211
					local _des_0 = entries[_index_2] -- 211
					local ename = _des_0[1] -- 211
					if entryName == ename then -- 212
						entryAdded = true -- 213
						break -- 214
					end -- 212
				end -- 214
				if entryAdded then -- 215
					goto _continue_1 -- 215
				end -- 215
				local examples = { } -- 216
				local tests = { } -- 217
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 218
				if Content:exist(examplePath) then -- 219
					local _list_2 = getFileEntries(examplePath) -- 220
					for _index_2 = 1, #_list_2 do -- 220
						local _des_0 = _list_2[_index_2] -- 220
						local name, ePath = _des_0[1], _des_0[2] -- 220
						local entry = { -- 221
							name, -- 221
							Path(path, dir, Path:getPath(file), ePath) -- 221
						} -- 221
						examples[#examples + 1] = entry -- 222
					end -- 222
				end -- 219
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 223
				if Content:exist(testPath) then -- 224
					local _list_2 = getFileEntries(testPath) -- 225
					for _index_2 = 1, #_list_2 do -- 225
						local _des_0 = _list_2[_index_2] -- 225
						local name, tPath = _des_0[1], _des_0[2] -- 225
						local entry = { -- 226
							name, -- 226
							Path(path, dir, Path:getPath(file), tPath) -- 226
						} -- 226
						tests[#tests + 1] = entry -- 227
					end -- 227
				end -- 224
				local entry = { -- 228
					entryName, -- 228
					fileName, -- 228
					examples, -- 228
					tests -- 228
				} -- 228
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 229
				if not Content:exist(bannerFile) then -- 230
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 231
					if not Content:exist(bannerFile) then -- 232
						bannerFile = nil -- 232
					end -- 232
				end -- 230
				if bannerFile then -- 233
					thread(function() -- 233
						Cache:loadAsync(bannerFile) -- 234
						local bannerTex = Texture2D(bannerFile) -- 235
						if bannerTex then -- 236
							entry[#entry + 1] = bannerFile -- 237
							entry[#entry + 1] = bannerTex -- 238
						end -- 236
					end) -- 233
				end -- 233
				entries[#entries + 1] = entry -- 239
			end -- 206
			::_continue_1:: -- 206
		end -- 239
		::_continue_0:: -- 204
	end -- 239
	table.sort(entries, function(a, b) -- 240
		return a[1] < b[1] -- 240
	end) -- 240
	return entries -- 241
end -- 201
local gamesInDev, games -- 243
local doraTools, doraExamples, doraTests -- 244
local cppTests, cppTestSet -- 245
local allEntries -- 246
local updateEntries -- 248
updateEntries = function() -- 248
	gamesInDev = getProjectEntries(Content.writablePath) -- 249
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 250
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 252
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 253
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 254
	cppTests = { } -- 256
	local _list_0 = App.testNames -- 257
	for _index_0 = 1, #_list_0 do -- 257
		local name = _list_0[_index_0] -- 257
		local entry = { -- 258
			name -- 258
		} -- 258
		cppTests[#cppTests + 1] = entry -- 259
	end -- 259
	cppTestSet = Set(cppTests) -- 260
	allEntries = { } -- 262
	for _index_0 = 1, #gamesInDev do -- 263
		local game = gamesInDev[_index_0] -- 263
		allEntries[#allEntries + 1] = game -- 264
		local examples, tests = game[3], game[4] -- 265
		for _index_1 = 1, #examples do -- 266
			local example = examples[_index_1] -- 266
			allEntries[#allEntries + 1] = example -- 267
		end -- 267
		for _index_1 = 1, #tests do -- 268
			local test = tests[_index_1] -- 268
			allEntries[#allEntries + 1] = test -- 269
		end -- 269
	end -- 269
	for _index_0 = 1, #games do -- 270
		local game = games[_index_0] -- 270
		allEntries[#allEntries + 1] = game -- 271
		local examples, tests = game[3], game[4] -- 272
		for _index_1 = 1, #examples do -- 273
			local example = examples[_index_1] -- 273
			doraExamples[#doraExamples + 1] = example -- 274
		end -- 274
		for _index_1 = 1, #tests do -- 275
			local test = tests[_index_1] -- 275
			doraTests[#doraTests + 1] = test -- 276
		end -- 276
	end -- 276
	local _list_1 = { -- 278
		doraExamples, -- 278
		doraTests, -- 279
		cppTests -- 280
	} -- 277
	for _index_0 = 1, #_list_1 do -- 281
		local group = _list_1[_index_0] -- 277
		for _index_1 = 1, #group do -- 282
			local entry = group[_index_1] -- 282
			allEntries[#allEntries + 1] = entry -- 283
		end -- 283
	end -- 283
end -- 248
updateEntries() -- 285
local doCompile -- 287
doCompile = function(minify) -- 287
	if building then -- 288
		return -- 288
	end -- 288
	building = true -- 289
	local startTime = App.runningTime -- 290
	local luaFiles = { } -- 291
	local yueFiles = { } -- 292
	local xmlFiles = { } -- 293
	local tlFiles = { } -- 294
	local writablePath = Content.writablePath -- 295
	local buildPaths = { -- 297
		{ -- 298
			Path(Content.assetPath), -- 298
			Path(writablePath, ".build"), -- 299
			"" -- 300
		} -- 297
	} -- 296
	for _index_0 = 1, #gamesInDev do -- 303
		local _des_0 = gamesInDev[_index_0] -- 303
		local entryFile = _des_0[2] -- 303
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 304
		buildPaths[#buildPaths + 1] = { -- 306
			Path(writablePath, gamePath), -- 306
			Path(writablePath, ".build", gamePath), -- 307
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 308
			gamePath -- 309
		} -- 305
	end -- 309
	for _index_0 = 1, #buildPaths do -- 310
		local _des_0 = buildPaths[_index_0] -- 310
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 310
		if not Content:exist(inputPath) then -- 311
			goto _continue_0 -- 311
		end -- 311
		local _list_0 = getAllFiles(inputPath, { -- 313
			"lua" -- 313
		}) -- 313
		for _index_1 = 1, #_list_0 do -- 313
			local file = _list_0[_index_1] -- 313
			luaFiles[#luaFiles + 1] = { -- 315
				file, -- 315
				Path(inputPath, file), -- 316
				Path(outputPath, file), -- 317
				gamePath -- 318
			} -- 314
		end -- 318
		local _list_1 = getAllFiles(inputPath, { -- 320
			yueext -- 320
		}) -- 320
		for _index_1 = 1, #_list_1 do -- 320
			local file = _list_1[_index_1] -- 320
			yueFiles[#yueFiles + 1] = { -- 322
				file, -- 322
				Path(inputPath, file), -- 323
				Path(outputPath, Path:replaceExt(file, "lua")), -- 324
				searchPath, -- 325
				gamePath -- 326
			} -- 321
		end -- 326
		local _list_2 = getAllFiles(inputPath, { -- 328
			"xml" -- 328
		}) -- 328
		for _index_1 = 1, #_list_2 do -- 328
			local file = _list_2[_index_1] -- 328
			xmlFiles[#xmlFiles + 1] = { -- 330
				file, -- 330
				Path(inputPath, file), -- 331
				Path(outputPath, Path:replaceExt(file, "lua")), -- 332
				gamePath -- 333
			} -- 329
		end -- 333
		local _list_3 = getAllFiles(inputPath, { -- 335
			"tl" -- 335
		}) -- 335
		for _index_1 = 1, #_list_3 do -- 335
			local file = _list_3[_index_1] -- 335
			if not file:match(".*%.d%.tl$") then -- 336
				tlFiles[#tlFiles + 1] = { -- 338
					file, -- 338
					Path(inputPath, file), -- 339
					Path(outputPath, Path:replaceExt(file, "lua")), -- 340
					searchPath, -- 341
					gamePath -- 342
				} -- 337
			end -- 336
		end -- 342
		::_continue_0:: -- 311
	end -- 342
	local paths -- 344
	do -- 344
		local _tbl_0 = { } -- 344
		local _list_0 = { -- 345
			luaFiles, -- 345
			yueFiles, -- 345
			xmlFiles, -- 345
			tlFiles -- 345
		} -- 345
		for _index_0 = 1, #_list_0 do -- 345
			local files = _list_0[_index_0] -- 345
			for _index_1 = 1, #files do -- 346
				local file = files[_index_1] -- 346
				_tbl_0[Path:getPath(file[3])] = true -- 344
			end -- 344
		end -- 344
		paths = _tbl_0 -- 344
	end -- 346
	for path in pairs(paths) do -- 348
		Content:mkdir(path) -- 348
	end -- 348
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 350
	local fileCount = 0 -- 351
	local errors = { } -- 352
	for _index_0 = 1, #yueFiles do -- 353
		local _des_0 = yueFiles[_index_0] -- 353
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 353
		local filename -- 354
		if gamePath then -- 354
			filename = Path(gamePath, file) -- 354
		else -- 354
			filename = file -- 354
		end -- 354
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 355
			if not codes then -- 356
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 357
				return -- 358
			end -- 356
			local success, result = LintYueGlobals(codes, globals) -- 359
			if success then -- 360
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 361
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 362
				codes = codes:gsub("^\n*", "") -- 363
				if not (result == "") then -- 364
					result = result .. "\n" -- 364
				end -- 364
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 365
			else -- 367
				local yueCodes = Content:load(input) -- 367
				if yueCodes then -- 367
					local globalErrors = { } -- 368
					for _index_1 = 1, #result do -- 369
						local _des_1 = result[_index_1] -- 369
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 369
						local countLine = 1 -- 370
						local code = "" -- 371
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 372
							if countLine == line then -- 373
								code = lineCode -- 374
								break -- 375
							end -- 373
							countLine = countLine + 1 -- 376
						end -- 376
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 377
					end -- 377
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 378
				else -- 380
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 380
				end -- 367
			end -- 360
		end, function(success) -- 355
			if success then -- 381
				print("Yue compiled: " .. tostring(filename)) -- 381
			end -- 381
			fileCount = fileCount + 1 -- 382
		end) -- 355
	end -- 382
	thread(function() -- 384
		for _index_0 = 1, #xmlFiles do -- 385
			local _des_0 = xmlFiles[_index_0] -- 385
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 385
			local filename -- 386
			if gamePath then -- 386
				filename = Path(gamePath, file) -- 386
			else -- 386
				filename = file -- 386
			end -- 386
			local sourceCodes = Content:loadAsync(input) -- 387
			local codes, err = xml.tolua(sourceCodes) -- 388
			if not codes then -- 389
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 390
			else -- 392
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 392
				print("Xml compiled: " .. tostring(filename)) -- 393
			end -- 389
			fileCount = fileCount + 1 -- 394
		end -- 394
	end) -- 384
	thread(function() -- 396
		for _index_0 = 1, #tlFiles do -- 397
			local _des_0 = tlFiles[_index_0] -- 397
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 397
			local filename -- 398
			if gamePath then -- 398
				filename = Path(gamePath, file) -- 398
			else -- 398
				filename = file -- 398
			end -- 398
			local sourceCodes = Content:loadAsync(input) -- 399
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 400
			if not codes then -- 401
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 402
			else -- 404
				Content:saveAsync(output, codes) -- 404
				print("Teal compiled: " .. tostring(filename)) -- 405
			end -- 401
			fileCount = fileCount + 1 -- 406
		end -- 406
	end) -- 396
	return thread(function() -- 408
		wait(function() -- 409
			return fileCount == totalFiles -- 409
		end) -- 409
		if minify then -- 410
			local _list_0 = { -- 411
				yueFiles, -- 411
				xmlFiles, -- 411
				tlFiles -- 411
			} -- 411
			for _index_0 = 1, #_list_0 do -- 411
				local files = _list_0[_index_0] -- 411
				for _index_1 = 1, #files do -- 411
					local file = files[_index_1] -- 411
					local output = Path:replaceExt(file[3], "lua") -- 412
					luaFiles[#luaFiles + 1] = { -- 414
						Path:replaceExt(file[1], "lua"), -- 414
						output, -- 415
						output -- 416
					} -- 413
				end -- 416
			end -- 416
			local FormatMini -- 418
			do -- 418
				local _obj_0 = require("luaminify") -- 418
				FormatMini = _obj_0.FormatMini -- 418
			end -- 418
			for _index_0 = 1, #luaFiles do -- 419
				local _des_0 = luaFiles[_index_0] -- 419
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 419
				if Content:exist(input) then -- 420
					local sourceCodes = Content:loadAsync(input) -- 421
					local res, err = FormatMini(sourceCodes) -- 422
					if res then -- 423
						Content:saveAsync(output, res) -- 424
						print("Minify: " .. tostring(file)) -- 425
					else -- 427
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 427
					end -- 423
				else -- 429
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 429
				end -- 420
			end -- 429
			package.loaded["luaminify.FormatMini"] = nil -- 430
			package.loaded["luaminify.ParseLua"] = nil -- 431
			package.loaded["luaminify.Scope"] = nil -- 432
			package.loaded["luaminify.Util"] = nil -- 433
		end -- 410
		local errorMessage = table.concat(errors, "\n") -- 434
		if errorMessage ~= "" then -- 435
			print("\n" .. errorMessage) -- 435
		end -- 435
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 436
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 437
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 438
		Content:clearPathCache() -- 439
		teal.clear() -- 440
		yue.clear() -- 441
		building = false -- 442
	end) -- 442
end -- 287
local doClean -- 444
doClean = function() -- 444
	if building then -- 445
		return -- 445
	end -- 445
	local writablePath = Content.writablePath -- 446
	local targetDir = Path(writablePath, ".build") -- 447
	Content:clearPathCache() -- 448
	if Content:remove(targetDir) then -- 449
		print("Cleaned: " .. tostring(targetDir)) -- 450
	end -- 449
	Content:remove(Path(writablePath, ".upload")) -- 451
	return Content:remove(Path(writablePath, ".download")) -- 452
end -- 444
local screenScale = 2.0 -- 454
local scaleContent = false -- 455
local isInEntry = true -- 456
local currentEntry = nil -- 457
local footerWindow = nil -- 459
local entryWindow = nil -- 460
local setupEventHandlers = nil -- 462
local allClear -- 464
allClear = function() -- 464
	local _list_0 = Routine -- 465
	for _index_0 = 1, #_list_0 do -- 465
		local routine = _list_0[_index_0] -- 465
		if footerWindow == routine or entryWindow == routine then -- 467
			goto _continue_0 -- 468
		else -- 470
			Routine:remove(routine) -- 470
		end -- 470
		::_continue_0:: -- 466
	end -- 470
	for _index_0 = 1, #moduleCache do -- 471
		local module = moduleCache[_index_0] -- 471
		package.loaded[module] = nil -- 472
	end -- 472
	moduleCache = { } -- 473
	Director:cleanup() -- 474
	Cache:unload() -- 475
	Entity:clear() -- 476
	Platformer.Data:clear() -- 477
	Platformer.UnitAction:clear() -- 478
	Audio:stopStream(0.5) -- 479
	Struct:clear() -- 480
	View.postEffect = nil -- 481
	View.scale = scaleContent and screenScale or 1 -- 482
	Director.clearColor = Color(0xff1a1a1a) -- 483
	teal.clear() -- 484
	yue.clear() -- 485
	for _, item in pairs(ubox()) do -- 486
		local node = tolua.cast(item, "Node") -- 487
		if node then -- 487
			node:cleanup() -- 487
		end -- 487
	end -- 487
	collectgarbage() -- 488
	collectgarbage() -- 489
	setupEventHandlers() -- 490
	Content.searchPaths = searchPaths -- 491
	App.idled = true -- 492
	return Wasm:clear() -- 493
end -- 464
_module_0["allClear"] = allClear -- 493
setupEventHandlers = function() -- 495
	local _with_0 = Director.postNode -- 496
	_with_0:gslot("AppQuit", allClear) -- 497
	_with_0:gslot("AppTheme", function(argb) -- 498
		config.themeColor = argb -- 499
	end) -- 498
	_with_0:gslot("AppLocale", function(locale) -- 500
		config.locale = locale -- 501
		updateLocale() -- 502
		return teal.clear(true) -- 503
	end) -- 500
	_with_0:gslot("AppWSClose", function() -- 504
		if HttpServer.wsConnectionCount == 0 then -- 505
			return updateEntries() -- 506
		end -- 505
	end) -- 504
	local _exp_0 = App.platform -- 507
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 507
		_with_0:gslot("AppSizeChanged", function() -- 508
			local width, height -- 509
			do -- 509
				local _obj_0 = App.winSize -- 509
				width, height = _obj_0.width, _obj_0.height -- 509
			end -- 509
			config.winWidth = width -- 510
			config.winHeight = height -- 511
		end) -- 508
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 512
			config.fullScreen = fullScreen -- 513
		end) -- 512
		_with_0:gslot("AppMoved", function() -- 514
			local _obj_0 = App.winPosition -- 515
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 515
		end) -- 514
	end -- 515
	return _with_0 -- 496
end -- 495
setupEventHandlers() -- 517
local stop -- 519
stop = function() -- 519
	if isInEntry then -- 520
		return false -- 520
	end -- 520
	allClear() -- 521
	isInEntry = true -- 522
	currentEntry = nil -- 523
	return true -- 524
end -- 519
_module_0["stop"] = stop -- 524
local _anon_func_0 = function(Content, Path, file, require, type) -- 546
	local scriptPath = Path:getPath(file) -- 539
	Content:insertSearchPath(1, scriptPath) -- 540
	scriptPath = Path(scriptPath, "Script") -- 541
	if Content:exist(scriptPath) then -- 542
		Content:insertSearchPath(1, scriptPath) -- 543
	end -- 542
	local result = require(file) -- 544
	if "function" == type(result) then -- 545
		result() -- 545
	end -- 545
	return nil -- 546
end -- 539
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 578
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 575
	label.alignment = "Left" -- 576
	label.textWidth = width - fontSize -- 577
	label.text = err -- 578
	return label -- 575
end -- 575
local enterEntryAsync -- 526
enterEntryAsync = function(entry) -- 526
	isInEntry = false -- 527
	App.idled = false -- 528
	emit(Profiler.EventName, "ClearLoader") -- 529
	currentEntry = entry -- 530
	local name, file = entry[1], entry[2] -- 531
	if cppTestSet[entry] then -- 532
		if App:runTest(name) then -- 533
			return true -- 534
		else -- 536
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 536
		end -- 533
	end -- 532
	sleep() -- 537
	return xpcall(_anon_func_0, function(msg) -- 546
		local err = debug.traceback(msg) -- 548
		allClear() -- 549
		print(err) -- 550
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 551
		local viewWidth, viewHeight -- 552
		do -- 552
			local _obj_0 = View.size -- 552
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 552
		end -- 552
		local width, height = viewWidth - 20, viewHeight - 20 -- 553
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 554
		Director.ui:addChild((function() -- 555
			local root = AlignNode() -- 555
			do -- 556
				local _obj_0 = App.bufferSize -- 556
				width, height = _obj_0.width, _obj_0.height -- 556
			end -- 556
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 557
			root:gslot("AppSizeChanged", function() -- 558
				do -- 559
					local _obj_0 = App.bufferSize -- 559
					width, height = _obj_0.width, _obj_0.height -- 559
				end -- 559
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 560
			end) -- 558
			root:addChild((function() -- 561
				local _with_0 = ScrollArea({ -- 562
					width = width, -- 562
					height = height, -- 563
					paddingX = 0, -- 564
					paddingY = 50, -- 565
					viewWidth = height, -- 566
					viewHeight = height -- 567
				}) -- 561
				root:slot("AlignLayout", function(w, h) -- 569
					_with_0.position = Vec2(w / 2, h / 2) -- 570
					w = w - 20 -- 571
					h = h - 20 -- 572
					_with_0.view.children.first.textWidth = w - fontSize -- 573
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 574
				end) -- 569
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 575
				return _with_0 -- 561
			end)()) -- 561
			return root -- 555
		end)()) -- 555
		return err -- 579
	end, Content, Path, file, require, type) -- 579
end -- 526
_module_0["enterEntryAsync"] = enterEntryAsync -- 579
local enterDemoEntry -- 581
enterDemoEntry = function(entry) -- 581
	return thread(function() -- 581
		return enterEntryAsync(entry) -- 581
	end) -- 581
end -- 581
local reloadCurrentEntry -- 583
reloadCurrentEntry = function() -- 583
	if currentEntry then -- 584
		allClear() -- 585
		return enterDemoEntry(currentEntry) -- 586
	end -- 584
end -- 583
Director.clearColor = Color(0xff1a1a1a) -- 588
local waitForWebStart = true -- 590
thread(function() -- 591
	sleep(2) -- 592
	waitForWebStart = false -- 593
end) -- 591
local reloadDevEntry -- 595
reloadDevEntry = function() -- 595
	return thread(function() -- 595
		waitForWebStart = true -- 596
		doClean() -- 597
		allClear() -- 598
		_G.require = oldRequire -- 599
		Dora.require = oldRequire -- 600
		package.loaded["Script.Dev.Entry"] = nil -- 601
		return Director.systemScheduler:schedule(function() -- 602
			Routine:clear() -- 603
			oldRequire("Script.Dev.Entry") -- 604
			return true -- 605
		end) -- 605
	end) -- 605
end -- 595
local isOSSLicenseExist = Content:exist("LICENSES") -- 607
local ossLicenses = nil -- 608
local ossLicenseOpen = false -- 609
local extraOperations -- 611
extraOperations = function() -- 611
	local zh = useChinese and isChineseSupported -- 612
	if isOSSLicenseExist then -- 613
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 614
			if not ossLicenses then -- 615
				ossLicenses = { } -- 616
				local licenseText = Content:load("LICENSES") -- 617
				ossLicenseOpen = (licenseText ~= nil) -- 618
				if ossLicenseOpen then -- 618
					licenseText = licenseText:gsub("\r\n", "\n") -- 619
					for license in GSplit(licenseText, "\n--------\n", true) do -- 620
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 621
						if name then -- 621
							ossLicenses[#ossLicenses + 1] = { -- 622
								name, -- 622
								text -- 622
							} -- 622
						end -- 621
					end -- 622
				end -- 618
			else -- 624
				ossLicenseOpen = true -- 624
			end -- 615
		end -- 614
		if ossLicenseOpen then -- 625
			local width, height, themeColor -- 626
			do -- 626
				local _obj_0 = App -- 626
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 626
			end -- 626
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 627
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 628
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 629
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 632
					"NoSavedSettings" -- 632
				}, function() -- 633
					for _index_0 = 1, #ossLicenses do -- 633
						local _des_0 = ossLicenses[_index_0] -- 633
						local firstLine, text = _des_0[1], _des_0[2] -- 633
						local name, license = firstLine:match("(.+): (.+)") -- 634
						TextColored(themeColor, name) -- 635
						SameLine() -- 636
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 637
							return TextWrapped(text) -- 637
						end) -- 637
					end -- 637
				end) -- 629
			end) -- 629
		end -- 625
	end -- 613
	if not App.debugging then -- 639
		return -- 639
	end -- 639
	return TreeNode(zh and "开发操作" or "Development", function() -- 640
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 641
			OpenPopup("build") -- 641
		end -- 641
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 642
			return BeginPopup("build", function() -- 642
				if Selectable(zh and "编译" or "Compile") then -- 643
					doCompile(false) -- 643
				end -- 643
				Separator() -- 644
				if Selectable(zh and "压缩" or "Minify") then -- 645
					doCompile(true) -- 645
				end -- 645
				Separator() -- 646
				if Selectable(zh and "清理" or "Clean") then -- 647
					return doClean() -- 647
				end -- 647
			end) -- 647
		end) -- 642
		if isInEntry then -- 648
			if waitForWebStart then -- 649
				BeginDisabled(function() -- 650
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 650
				end) -- 650
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 651
				reloadDevEntry() -- 652
			end -- 649
		end -- 648
		do -- 653
			local changed -- 653
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 653
			if changed then -- 653
				View.scale = scaleContent and screenScale or 1 -- 654
			end -- 653
		end -- 653
		local changed -- 655
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 655
		if changed then -- 655
			config.engineDev = engineDev -- 656
		end -- 655
	end) -- 640
end -- 611
local transparant = Color(0x0) -- 658
local windowFlags = { -- 660
	"NoTitleBar", -- 660
	"NoResize", -- 661
	"NoMove", -- 662
	"NoCollapse", -- 663
	"NoSavedSettings", -- 664
	"NoBringToFrontOnFocus" -- 665
} -- 659
local initFooter = true -- 666
local _anon_func_2 = function(allEntries, currentIndex) -- 702
	if currentIndex > 1 then -- 702
		return allEntries[currentIndex - 1] -- 703
	else -- 705
		return allEntries[#allEntries] -- 705
	end -- 702
end -- 702
local _anon_func_3 = function(allEntries, currentIndex) -- 709
	if currentIndex < #allEntries then -- 709
		return allEntries[currentIndex + 1] -- 710
	else -- 712
		return allEntries[1] -- 712
	end -- 709
end -- 709
footerWindow = threadLoop(function() -- 667
	local zh = useChinese and isChineseSupported -- 668
	if HttpServer.wsConnectionCount > 0 then -- 669
		return -- 670
	end -- 669
	if Keyboard:isKeyDown("Escape") then -- 671
		allClear() -- 672
		App:shutdown() -- 673
	end -- 671
	do -- 674
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 675
		if ctrl and Keyboard:isKeyDown("Q") then -- 676
			stop() -- 677
		end -- 676
		if ctrl and Keyboard:isKeyDown("Z") then -- 678
			reloadCurrentEntry() -- 679
		end -- 678
		if ctrl and Keyboard:isKeyDown(",") then -- 680
			if showFooter then -- 681
				showStats = not showStats -- 681
			else -- 681
				showStats = true -- 681
			end -- 681
			showFooter = true -- 682
			config.showFooter = showFooter -- 683
			config.showStats = showStats -- 684
		end -- 680
		if ctrl and Keyboard:isKeyDown(".") then -- 685
			if showFooter then -- 686
				showConsole = not showConsole -- 686
			else -- 686
				showConsole = true -- 686
			end -- 686
			showFooter = true -- 687
			config.showFooter = showFooter -- 688
			config.showConsole = showConsole -- 689
		end -- 685
		if ctrl and Keyboard:isKeyDown("/") then -- 690
			showFooter = not showFooter -- 691
			config.showFooter = showFooter -- 692
		end -- 690
		local left = ctrl and Keyboard:isKeyDown("Left") -- 693
		local right = ctrl and Keyboard:isKeyDown("Right") -- 694
		local currentIndex = nil -- 695
		for i, entry in ipairs(allEntries) do -- 696
			if currentEntry == entry then -- 697
				currentIndex = i -- 698
			end -- 697
		end -- 698
		if left then -- 699
			allClear() -- 700
			if currentIndex == nil then -- 701
				currentIndex = #allEntries + 1 -- 701
			end -- 701
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 702
		end -- 699
		if right then -- 706
			allClear() -- 707
			if currentIndex == nil then -- 708
				currentIndex = 0 -- 708
			end -- 708
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 709
		end -- 706
	end -- 712
	if not showEntry then -- 713
		return -- 713
	end -- 713
	local width, height -- 715
	do -- 715
		local _obj_0 = App.visualSize -- 715
		width, height = _obj_0.width, _obj_0.height -- 715
	end -- 715
	SetNextWindowSize(Vec2(50, 50)) -- 716
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 717
	PushStyleColor("WindowBg", transparant, function() -- 718
		return Begin("Show", windowFlags, function() -- 718
			if isInEntry or width >= 540 then -- 719
				local changed -- 720
				changed, showFooter = Checkbox("##dev", showFooter) -- 720
				if changed then -- 720
					config.showFooter = showFooter -- 721
				end -- 720
			end -- 719
		end) -- 721
	end) -- 718
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 723
		reloadDevEntry() -- 727
	end -- 723
	if initFooter then -- 728
		initFooter = false -- 729
	else -- 731
		if not showFooter then -- 731
			return -- 731
		end -- 731
	end -- 728
	SetNextWindowSize(Vec2(width, 50)) -- 733
	SetNextWindowPos(Vec2(0, height - 50)) -- 734
	SetNextWindowBgAlpha(0.35) -- 735
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 736
		return Begin("Footer", windowFlags, function() -- 736
			Dummy(Vec2(width - 20, 0)) -- 737
			do -- 738
				local changed -- 738
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 738
				if changed then -- 738
					config.showStats = showStats -- 739
				end -- 738
			end -- 738
			SameLine() -- 740
			do -- 741
				local changed -- 741
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 741
				if changed then -- 741
					config.showConsole = showConsole -- 742
				end -- 741
			end -- 741
			if not isInEntry then -- 743
				SameLine() -- 744
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 745
					allClear() -- 746
					isInEntry = true -- 747
					currentEntry = nil -- 748
				end -- 745
				local currentIndex = nil -- 749
				for i, entry in ipairs(allEntries) do -- 750
					if currentEntry == entry then -- 751
						currentIndex = i -- 752
					end -- 751
				end -- 752
				if currentIndex then -- 753
					if currentIndex > 1 then -- 754
						SameLine() -- 755
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 756
							allClear() -- 757
							enterDemoEntry(allEntries[currentIndex - 1]) -- 758
						end -- 756
					end -- 754
					if currentIndex < #allEntries then -- 759
						SameLine() -- 760
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 761
							allClear() -- 762
							enterDemoEntry(allEntries[currentIndex + 1]) -- 763
						end -- 761
					end -- 759
				end -- 753
				SameLine() -- 764
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 765
					reloadCurrentEntry() -- 766
				end -- 765
			end -- 743
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 767
				if showStats then -- 768
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 769
					showStats = ShowStats(showStats, extraOperations) -- 770
					config.showStats = showStats -- 771
				end -- 768
				if showConsole then -- 772
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 773
					showConsole = ShowConsole(showConsole) -- 774
					config.showConsole = showConsole -- 775
				end -- 772
			end) -- 775
		end) -- 775
	end) -- 775
end) -- 667
local MaxWidth <const> = 800 -- 777
local displayWindowFlags = { -- 780
	"NoDecoration", -- 780
	"NoSavedSettings", -- 781
	"NoFocusOnAppearing", -- 782
	"NoNav", -- 783
	"NoMove", -- 784
	"NoScrollWithMouse", -- 785
	"AlwaysAutoResize", -- 786
	"NoBringToFrontOnFocus" -- 787
} -- 779
local webStatus = nil -- 789
local descColor = Color(0xffa1a1a1) -- 790
local gameOpen = #gamesInDev == 0 -- 791
local exampleOpen = false -- 792
local testOpen = false -- 793
local filterText = nil -- 794
local anyEntryMatched = false -- 795
local urlClicked = nil -- 796
local match -- 797
match = function(name) -- 797
	local res = not filterText or name:lower():match(filterText) -- 798
	if res then -- 799
		anyEntryMatched = true -- 799
	end -- 799
	return res -- 800
end -- 797
entryWindow = threadLoop(function() -- 802
	if App.fpsLimited ~= config.fpsLimited then -- 803
		config.fpsLimited = App.fpsLimited -- 804
	end -- 803
	if App.targetFPS ~= config.targetFPS then -- 805
		config.targetFPS = App.targetFPS -- 806
	end -- 805
	if View.vsync ~= config.vsync then -- 807
		config.vsync = View.vsync -- 808
	end -- 807
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 809
		config.fixedFPS = Director.scheduler.fixedFPS -- 810
	end -- 809
	if Director.profilerSending ~= config.webProfiler then -- 811
		config.webProfiler = Director.profilerSending -- 812
	end -- 811
	if urlClicked then -- 813
		local _, result = coroutine.resume(urlClicked) -- 814
		if result then -- 815
			coroutine.close(urlClicked) -- 816
			urlClicked = nil -- 817
		end -- 815
	end -- 813
	if not showEntry then -- 818
		return -- 818
	end -- 818
	if not isInEntry then -- 819
		return -- 819
	end -- 819
	local zh = useChinese and isChineseSupported -- 820
	if HttpServer.wsConnectionCount > 0 then -- 821
		local themeColor = App.themeColor -- 822
		local width, height -- 823
		do -- 823
			local _obj_0 = App.visualSize -- 823
			width, height = _obj_0.width, _obj_0.height -- 823
		end -- 823
		SetNextWindowBgAlpha(0.5) -- 824
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 825
		Begin("Web IDE Connected", displayWindowFlags, function() -- 826
			Separator() -- 827
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 828
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 829
			TextColored(descColor, slogon) -- 830
			return Separator() -- 831
		end) -- 826
		return -- 832
	end -- 821
	local themeColor = App.themeColor -- 834
	local fullWidth, height -- 835
	do -- 835
		local _obj_0 = App.visualSize -- 835
		fullWidth, height = _obj_0.width, _obj_0.height -- 835
	end -- 835
	SetNextWindowBgAlpha(0.85) -- 837
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 838
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 839
		return Begin("Web IDE", displayWindowFlags, function() -- 840
			Separator() -- 841
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 842
			do -- 843
				local url -- 843
				if webStatus ~= nil then -- 843
					url = webStatus.url -- 843
				end -- 843
				if url then -- 843
					if isDesktop then -- 844
						if urlClicked then -- 845
							BeginDisabled(function() -- 846
								return Button(url) -- 846
							end) -- 846
						elseif Button(url) then -- 847
							urlClicked = once(function() -- 848
								return sleep(5) -- 848
							end) -- 848
							App:openURL(url) -- 849
						end -- 845
					else -- 851
						TextColored(descColor, url) -- 851
					end -- 844
				else -- 853
					TextColored(descColor, zh and '不可用' or 'not available') -- 853
				end -- 843
			end -- 843
			return Separator() -- 854
		end) -- 854
	end) -- 839
	local width = math.min(MaxWidth, fullWidth) -- 856
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 857
	local maxColumns = math.max(math.floor(width / 200), 1) -- 858
	SetNextWindowPos(Vec2.zero) -- 859
	SetNextWindowBgAlpha(0) -- 860
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 861
		return Begin("Dora Dev", displayWindowFlags, function() -- 862
			Dummy(Vec2(fullWidth - 20, 0)) -- 863
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 864
			SameLine() -- 865
			if fullWidth >= 320 then -- 866
				Dummy(Vec2(fullWidth - 320, 0)) -- 867
				SameLine() -- 868
				SetNextItemWidth(-50) -- 869
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 870
					"AutoSelectAll" -- 870
				}) then -- 870
					config.filter = filterBuf.text -- 871
				end -- 870
			end -- 866
			Separator() -- 872
			return Dummy(Vec2(fullWidth - 20, 0)) -- 873
		end) -- 873
	end) -- 861
	anyEntryMatched = false -- 875
	SetNextWindowPos(Vec2(0, 50)) -- 876
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 877
	return PushStyleColor("WindowBg", transparant, function() -- 878
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 878
			return Begin("Content", windowFlags, function() -- 879
				filterText = filterBuf.text:match("[^%%%.%[]+") -- 880
				if filterText then -- 881
					filterText = filterText:lower() -- 881
				end -- 881
				if #gamesInDev > 0 then -- 882
					for _index_0 = 1, #gamesInDev do -- 883
						local game = gamesInDev[_index_0] -- 883
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 884
						local showSep = false -- 885
						if match(gameName) then -- 886
							Columns(1, false) -- 887
							TextColored(themeColor, zh and "项目：" or "Project:") -- 888
							SameLine() -- 889
							Text(gameName) -- 890
							Separator() -- 891
							if bannerFile then -- 892
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 893
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 894
								local sizing <const> = 0.8 -- 895
								texHeight = displayWidth * sizing * texHeight / texWidth -- 896
								texWidth = displayWidth * sizing -- 897
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 898
								Dummy(Vec2(padding, 0)) -- 899
								SameLine() -- 900
								PushID(fileName, function() -- 901
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 902
										return enterDemoEntry(game) -- 903
									end -- 902
								end) -- 901
							else -- 905
								PushID(fileName, function() -- 905
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 906
										return enterDemoEntry(game) -- 907
									end -- 906
								end) -- 905
							end -- 892
							NextColumn() -- 908
							showSep = true -- 909
						end -- 886
						if #examples > 0 then -- 910
							local showExample = false -- 911
							for _index_1 = 1, #examples do -- 912
								local example = examples[_index_1] -- 912
								if match(example[1]) then -- 913
									showExample = true -- 914
									break -- 915
								end -- 913
							end -- 915
							if showExample then -- 916
								Columns(1, false) -- 917
								TextColored(themeColor, zh and "示例：" or "Example:") -- 918
								SameLine() -- 919
								Text(gameName) -- 920
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 921
									Columns(maxColumns, false) -- 922
									for _index_1 = 1, #examples do -- 923
										local example = examples[_index_1] -- 923
										if not match(example[1]) then -- 924
											goto _continue_0 -- 924
										end -- 924
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 925
											if Button(example[1], Vec2(-1, 40)) then -- 926
												enterDemoEntry(example) -- 927
											end -- 926
											return NextColumn() -- 928
										end) -- 925
										showSep = true -- 929
										::_continue_0:: -- 924
									end -- 929
								end) -- 921
							end -- 916
						end -- 910
						if #tests > 0 then -- 930
							local showTest = false -- 931
							for _index_1 = 1, #tests do -- 932
								local test = tests[_index_1] -- 932
								if match(test[1]) then -- 933
									showTest = true -- 934
									break -- 935
								end -- 933
							end -- 935
							if showTest then -- 936
								Columns(1, false) -- 937
								TextColored(themeColor, zh and "测试：" or "Test:") -- 938
								SameLine() -- 939
								Text(gameName) -- 940
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 941
									Columns(maxColumns, false) -- 942
									for _index_1 = 1, #tests do -- 943
										local test = tests[_index_1] -- 943
										if not match(test[1]) then -- 944
											goto _continue_0 -- 944
										end -- 944
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 945
											if Button(test[1], Vec2(-1, 40)) then -- 946
												enterDemoEntry(test) -- 947
											end -- 946
											return NextColumn() -- 948
										end) -- 945
										showSep = true -- 949
										::_continue_0:: -- 944
									end -- 949
								end) -- 941
							end -- 936
						end -- 930
						if showSep then -- 950
							Columns(1, false) -- 951
							Separator() -- 952
						end -- 950
					end -- 952
				end -- 882
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 953
					local showGame = false -- 954
					for _index_0 = 1, #games do -- 955
						local _des_0 = games[_index_0] -- 955
						local name = _des_0[1] -- 955
						if match(name) then -- 956
							showGame = true -- 956
						end -- 956
					end -- 956
					local showTool = false -- 957
					for _index_0 = 1, #doraExamples do -- 958
						local _des_0 = doraExamples[_index_0] -- 958
						local name = _des_0[1] -- 958
						if match(name) then -- 959
							showTool = true -- 959
						end -- 959
					end -- 959
					local showExample = false -- 960
					for _index_0 = 1, #doraExamples do -- 961
						local _des_0 = doraExamples[_index_0] -- 961
						local name = _des_0[1] -- 961
						if match(name) then -- 962
							showExample = true -- 962
						end -- 962
					end -- 962
					local showTest = false -- 963
					for _index_0 = 1, #doraTests do -- 964
						local _des_0 = doraTests[_index_0] -- 964
						local name = _des_0[1] -- 964
						if match(name) then -- 965
							showTest = true -- 965
						end -- 965
					end -- 965
					for _index_0 = 1, #cppTests do -- 966
						local _des_0 = cppTests[_index_0] -- 966
						local name = _des_0[1] -- 966
						if match(name) then -- 967
							showTest = true -- 967
						end -- 967
					end -- 967
					if not (showGame or showTool or showExample or showTest) then -- 968
						goto endEntry -- 968
					end -- 968
					Columns(1, false) -- 969
					TextColored(themeColor, "Dora SSR:") -- 970
					SameLine() -- 971
					Text(zh and "开发示例" or "Development Showcase") -- 972
					Separator() -- 973
					local demoViewWith <const> = 400 -- 974
					if #games > 0 and showGame then -- 975
						local opened -- 976
						if (filterText ~= nil) then -- 976
							opened = showGame -- 976
						else -- 976
							opened = false -- 976
						end -- 976
						SetNextItemOpen(gameOpen) -- 977
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 978
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 979
							Columns(columns, false) -- 980
							for _index_0 = 1, #games do -- 981
								local game = games[_index_0] -- 981
								if not match(game[1]) then -- 982
									goto _continue_0 -- 982
								end -- 982
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 983
								if columns > 1 then -- 984
									if bannerFile then -- 985
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 986
										local displayWidth <const> = demoViewWith - 40 -- 987
										texHeight = displayWidth * texHeight / texWidth -- 988
										texWidth = displayWidth -- 989
										Text(gameName) -- 990
										PushID(fileName, function() -- 991
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 992
												return enterDemoEntry(game) -- 993
											end -- 992
										end) -- 991
									else -- 995
										PushID(fileName, function() -- 995
											if Button(gameName, Vec2(-1, 40)) then -- 996
												return enterDemoEntry(game) -- 997
											end -- 996
										end) -- 995
									end -- 985
								else -- 999
									if bannerFile then -- 999
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1000
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1001
										local sizing = 0.8 -- 1002
										texHeight = displayWidth * sizing * texHeight / texWidth -- 1003
										texWidth = displayWidth * sizing -- 1004
										if texWidth > 500 then -- 1005
											sizing = 0.6 -- 1006
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1007
											texWidth = displayWidth * sizing -- 1008
										end -- 1005
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1009
										Dummy(Vec2(padding, 0)) -- 1010
										SameLine() -- 1011
										Text(gameName) -- 1012
										Dummy(Vec2(padding, 0)) -- 1013
										SameLine() -- 1014
										PushID(fileName, function() -- 1015
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1016
												return enterDemoEntry(game) -- 1017
											end -- 1016
										end) -- 1015
									else -- 1019
										PushID(fileName, function() -- 1019
											if Button(gameName, Vec2(-1, 40)) then -- 1020
												return enterDemoEntry(game) -- 1021
											end -- 1020
										end) -- 1019
									end -- 999
								end -- 984
								NextColumn() -- 1022
								::_continue_0:: -- 982
							end -- 1022
							Columns(1, false) -- 1023
							opened = true -- 1024
						end) -- 978
						gameOpen = opened -- 1025
					end -- 975
					if #doraTools > 0 and showTool then -- 1026
						local opened -- 1027
						if (filterText ~= nil) then -- 1027
							opened = showTool -- 1027
						else -- 1027
							opened = false -- 1027
						end -- 1027
						SetNextItemOpen(exampleOpen) -- 1028
						TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1029
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1030
								Columns(maxColumns, false) -- 1031
								for _index_0 = 1, #doraTools do -- 1032
									local example = doraTools[_index_0] -- 1032
									if not match(example[1]) then -- 1033
										goto _continue_0 -- 1033
									end -- 1033
									if Button(example[1], Vec2(-1, 40)) then -- 1034
										enterDemoEntry(example) -- 1035
									end -- 1034
									NextColumn() -- 1036
									::_continue_0:: -- 1033
								end -- 1036
								Columns(1, false) -- 1037
								opened = true -- 1038
							end) -- 1030
						end) -- 1029
						exampleOpen = opened -- 1039
					end -- 1026
					if #doraExamples > 0 and showExample then -- 1040
						local opened -- 1041
						if (filterText ~= nil) then -- 1041
							opened = showExample -- 1041
						else -- 1041
							opened = false -- 1041
						end -- 1041
						SetNextItemOpen(exampleOpen) -- 1042
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1043
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1044
								Columns(maxColumns, false) -- 1045
								for _index_0 = 1, #doraExamples do -- 1046
									local example = doraExamples[_index_0] -- 1046
									if not match(example[1]) then -- 1047
										goto _continue_0 -- 1047
									end -- 1047
									if Button(example[1], Vec2(-1, 40)) then -- 1048
										enterDemoEntry(example) -- 1049
									end -- 1048
									NextColumn() -- 1050
									::_continue_0:: -- 1047
								end -- 1050
								Columns(1, false) -- 1051
								opened = true -- 1052
							end) -- 1044
						end) -- 1043
						exampleOpen = opened -- 1053
					end -- 1040
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1054
						local opened -- 1055
						if (filterText ~= nil) then -- 1055
							opened = showTest -- 1055
						else -- 1055
							opened = false -- 1055
						end -- 1055
						SetNextItemOpen(testOpen) -- 1056
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1057
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1058
								Columns(maxColumns, false) -- 1059
								for _index_0 = 1, #doraTests do -- 1060
									local test = doraTests[_index_0] -- 1060
									if not match(test[1]) then -- 1061
										goto _continue_0 -- 1061
									end -- 1061
									if Button(test[1], Vec2(-1, 40)) then -- 1062
										enterDemoEntry(test) -- 1063
									end -- 1062
									NextColumn() -- 1064
									::_continue_0:: -- 1061
								end -- 1064
								for _index_0 = 1, #cppTests do -- 1065
									local test = cppTests[_index_0] -- 1065
									if not match(test[1]) then -- 1066
										goto _continue_1 -- 1066
									end -- 1066
									if Button(test[1], Vec2(-1, 40)) then -- 1067
										enterDemoEntry(test) -- 1068
									end -- 1067
									NextColumn() -- 1069
									::_continue_1:: -- 1066
								end -- 1069
								opened = true -- 1070
							end) -- 1058
						end) -- 1057
						testOpen = opened -- 1071
					end -- 1054
				end -- 953
				::endEntry:: -- 1072
				if not anyEntryMatched then -- 1073
					SetNextWindowBgAlpha(0) -- 1074
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1075
					Begin("Entries Not Found", displayWindowFlags, function() -- 1076
						Separator() -- 1077
						TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1078
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1079
						return Separator() -- 1080
					end) -- 1076
				end -- 1073
				Columns(1, false) -- 1081
				Dummy(Vec2(100, 80)) -- 1082
				return ScrollWhenDraggingOnVoid() -- 1083
			end) -- 1083
		end) -- 1083
	end) -- 1083
end) -- 802
webStatus = require("Script.Dev.WebServer") -- 1085
return _module_0 -- 1085
