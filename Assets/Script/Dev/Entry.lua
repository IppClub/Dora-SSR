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
	filterBuf:setString(config.filter) -- 140
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
getAllFiles = function(path, exts) -- 174
	local filters = Set(exts) -- 175
	local _accum_0 = { } -- 176
	local _len_0 = 1 -- 176
	local _list_0 = Content:getAllFiles(path) -- 176
	for _index_0 = 1, #_list_0 do -- 176
		local file = _list_0[_index_0] -- 176
		if not filters[Path:getExt(file)] then -- 177
			goto _continue_0 -- 177
		end -- 177
		_accum_0[_len_0] = file -- 178
		_len_0 = _len_0 + 1 -- 178
		::_continue_0:: -- 177
	end -- 178
	return _accum_0 -- 178
end -- 174
local getFileEntries -- 180
getFileEntries = function(path) -- 180
	local entries = { } -- 181
	local _list_0 = getAllFiles(path, { -- 182
		"lua", -- 182
		"xml", -- 182
		yueext, -- 182
		"tl" -- 182
	}) -- 182
	for _index_0 = 1, #_list_0 do -- 182
		local file = _list_0[_index_0] -- 182
		local entryName = Path:getName(file) -- 183
		local entryAdded = false -- 184
		for _index_1 = 1, #entries do -- 185
			local _des_0 = entries[_index_1] -- 185
			local ename = _des_0[1] -- 185
			if entryName == ename then -- 186
				entryAdded = true -- 187
				break -- 188
			end -- 186
		end -- 188
		if entryAdded then -- 189
			goto _continue_0 -- 189
		end -- 189
		local fileName = Path:replaceExt(file, "") -- 190
		fileName = Path(path, fileName) -- 191
		local entry = { -- 192
			entryName, -- 192
			fileName -- 192
		} -- 192
		entries[#entries + 1] = entry -- 193
		::_continue_0:: -- 183
	end -- 193
	table.sort(entries, function(a, b) -- 194
		return a[1] < b[1] -- 194
	end) -- 194
	return entries -- 195
end -- 180
local getProjectEntries -- 197
getProjectEntries = function(path) -- 197
	local entries = { } -- 198
	local _list_0 = Content:getDirs(path) -- 199
	for _index_0 = 1, #_list_0 do -- 199
		local dir = _list_0[_index_0] -- 199
		if dir:match("^%.") then -- 200
			goto _continue_0 -- 200
		end -- 200
		local _list_1 = getAllFiles(Path(path, dir), { -- 201
			"lua", -- 201
			"xml", -- 201
			yueext, -- 201
			"tl", -- 201
			"wasm" -- 201
		}) -- 201
		for _index_1 = 1, #_list_1 do -- 201
			local file = _list_1[_index_1] -- 201
			if "init" == Path:getName(file):lower() then -- 202
				local fileName = Path:replaceExt(file, "") -- 203
				fileName = Path(path, dir, fileName) -- 204
				local entryName = Path:getName(Path:getPath(fileName)) -- 205
				local entryAdded = false -- 206
				for _index_2 = 1, #entries do -- 207
					local _des_0 = entries[_index_2] -- 207
					local ename = _des_0[1] -- 207
					if entryName == ename then -- 208
						entryAdded = true -- 209
						break -- 210
					end -- 208
				end -- 210
				if entryAdded then -- 211
					goto _continue_1 -- 211
				end -- 211
				local examples = { } -- 212
				local tests = { } -- 213
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 214
				if Content:exist(examplePath) then -- 215
					local _list_2 = getFileEntries(examplePath) -- 216
					for _index_2 = 1, #_list_2 do -- 216
						local _des_0 = _list_2[_index_2] -- 216
						local name, ePath = _des_0[1], _des_0[2] -- 216
						local entry = { -- 217
							name, -- 217
							Path(path, dir, Path:getPath(file), ePath) -- 217
						} -- 217
						examples[#examples + 1] = entry -- 218
					end -- 218
				end -- 215
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 219
				if Content:exist(testPath) then -- 220
					local _list_2 = getFileEntries(testPath) -- 221
					for _index_2 = 1, #_list_2 do -- 221
						local _des_0 = _list_2[_index_2] -- 221
						local name, tPath = _des_0[1], _des_0[2] -- 221
						local entry = { -- 222
							name, -- 222
							Path(path, dir, Path:getPath(file), tPath) -- 222
						} -- 222
						tests[#tests + 1] = entry -- 223
					end -- 223
				end -- 220
				local entry = { -- 224
					entryName, -- 224
					fileName, -- 224
					examples, -- 224
					tests -- 224
				} -- 224
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 225
				if not Content:exist(bannerFile) then -- 226
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 227
					if not Content:exist(bannerFile) then -- 228
						bannerFile = nil -- 228
					end -- 228
				end -- 226
				if bannerFile then -- 229
					thread(function() -- 229
						Cache:loadAsync(bannerFile) -- 230
						local bannerTex = Texture2D(bannerFile) -- 231
						if bannerTex then -- 232
							entry[#entry + 1] = bannerFile -- 233
							entry[#entry + 1] = bannerTex -- 234
						end -- 232
					end) -- 229
				end -- 229
				entries[#entries + 1] = entry -- 235
			end -- 202
			::_continue_1:: -- 202
		end -- 235
		::_continue_0:: -- 200
	end -- 235
	table.sort(entries, function(a, b) -- 236
		return a[1] < b[1] -- 236
	end) -- 236
	return entries -- 237
end -- 197
local gamesInDev, games -- 239
local doraExamples, doraTests -- 240
local cppTests, cppTestSet -- 241
local allEntries -- 242
local updateEntries -- 244
updateEntries = function() -- 244
	gamesInDev = getProjectEntries(Content.writablePath) -- 245
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 246
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 248
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 249
	cppTests = { } -- 251
	local _list_0 = App.testNames -- 252
	for _index_0 = 1, #_list_0 do -- 252
		local name = _list_0[_index_0] -- 252
		local entry = { -- 253
			name -- 253
		} -- 253
		cppTests[#cppTests + 1] = entry -- 254
	end -- 254
	cppTestSet = Set(cppTests) -- 255
	allEntries = { } -- 257
	for _index_0 = 1, #gamesInDev do -- 258
		local game = gamesInDev[_index_0] -- 258
		allEntries[#allEntries + 1] = game -- 259
		local examples, tests = game[3], game[4] -- 260
		for _index_1 = 1, #examples do -- 261
			local example = examples[_index_1] -- 261
			allEntries[#allEntries + 1] = example -- 262
		end -- 262
		for _index_1 = 1, #tests do -- 263
			local test = tests[_index_1] -- 263
			allEntries[#allEntries + 1] = test -- 264
		end -- 264
	end -- 264
	for _index_0 = 1, #games do -- 265
		local game = games[_index_0] -- 265
		allEntries[#allEntries + 1] = game -- 266
		local examples, tests = game[3], game[4] -- 267
		for _index_1 = 1, #examples do -- 268
			local example = examples[_index_1] -- 268
			doraExamples[#doraExamples + 1] = example -- 269
		end -- 269
		for _index_1 = 1, #tests do -- 270
			local test = tests[_index_1] -- 270
			doraTests[#doraTests + 1] = test -- 271
		end -- 271
	end -- 271
	local _list_1 = { -- 273
		doraExamples, -- 273
		doraTests, -- 274
		cppTests -- 275
	} -- 272
	for _index_0 = 1, #_list_1 do -- 276
		local group = _list_1[_index_0] -- 272
		for _index_1 = 1, #group do -- 277
			local entry = group[_index_1] -- 277
			allEntries[#allEntries + 1] = entry -- 278
		end -- 278
	end -- 278
end -- 244
updateEntries() -- 280
local doCompile -- 282
doCompile = function(minify) -- 282
	if building then -- 283
		return -- 283
	end -- 283
	building = true -- 284
	local startTime = App.runningTime -- 285
	local luaFiles = { } -- 286
	local yueFiles = { } -- 287
	local xmlFiles = { } -- 288
	local tlFiles = { } -- 289
	local writablePath = Content.writablePath -- 290
	local buildPaths = { -- 292
		{ -- 293
			Path(Content.assetPath), -- 293
			Path(writablePath, ".build"), -- 294
			"" -- 295
		} -- 292
	} -- 291
	for _index_0 = 1, #gamesInDev do -- 298
		local _des_0 = gamesInDev[_index_0] -- 298
		local entryFile = _des_0[2] -- 298
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 299
		buildPaths[#buildPaths + 1] = { -- 301
			Path(writablePath, gamePath), -- 301
			Path(writablePath, ".build", gamePath), -- 302
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 303
			gamePath -- 304
		} -- 300
	end -- 304
	for _index_0 = 1, #buildPaths do -- 305
		local _des_0 = buildPaths[_index_0] -- 305
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 305
		if not Content:exist(inputPath) then -- 306
			goto _continue_0 -- 306
		end -- 306
		local _list_0 = getAllFiles(inputPath, { -- 308
			"lua" -- 308
		}) -- 308
		for _index_1 = 1, #_list_0 do -- 308
			local file = _list_0[_index_1] -- 308
			luaFiles[#luaFiles + 1] = { -- 310
				file, -- 310
				Path(inputPath, file), -- 311
				Path(outputPath, file), -- 312
				gamePath -- 313
			} -- 309
		end -- 313
		local _list_1 = getAllFiles(inputPath, { -- 315
			yueext -- 315
		}) -- 315
		for _index_1 = 1, #_list_1 do -- 315
			local file = _list_1[_index_1] -- 315
			yueFiles[#yueFiles + 1] = { -- 317
				file, -- 317
				Path(inputPath, file), -- 318
				Path(outputPath, Path:replaceExt(file, "lua")), -- 319
				searchPath, -- 320
				gamePath -- 321
			} -- 316
		end -- 321
		local _list_2 = getAllFiles(inputPath, { -- 323
			"xml" -- 323
		}) -- 323
		for _index_1 = 1, #_list_2 do -- 323
			local file = _list_2[_index_1] -- 323
			xmlFiles[#xmlFiles + 1] = { -- 325
				file, -- 325
				Path(inputPath, file), -- 326
				Path(outputPath, Path:replaceExt(file, "lua")), -- 327
				gamePath -- 328
			} -- 324
		end -- 328
		local _list_3 = getAllFiles(inputPath, { -- 330
			"tl" -- 330
		}) -- 330
		for _index_1 = 1, #_list_3 do -- 330
			local file = _list_3[_index_1] -- 330
			if not file:match(".*%.d%.tl$") then -- 331
				tlFiles[#tlFiles + 1] = { -- 333
					file, -- 333
					Path(inputPath, file), -- 334
					Path(outputPath, Path:replaceExt(file, "lua")), -- 335
					searchPath, -- 336
					gamePath -- 337
				} -- 332
			end -- 331
		end -- 337
		::_continue_0:: -- 306
	end -- 337
	local paths -- 339
	do -- 339
		local _tbl_0 = { } -- 339
		local _list_0 = { -- 340
			luaFiles, -- 340
			yueFiles, -- 340
			xmlFiles, -- 340
			tlFiles -- 340
		} -- 340
		for _index_0 = 1, #_list_0 do -- 340
			local files = _list_0[_index_0] -- 340
			for _index_1 = 1, #files do -- 341
				local file = files[_index_1] -- 341
				_tbl_0[Path:getPath(file[3])] = true -- 339
			end -- 339
		end -- 339
		paths = _tbl_0 -- 339
	end -- 341
	for path in pairs(paths) do -- 343
		Content:mkdir(path) -- 343
	end -- 343
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 345
	local fileCount = 0 -- 346
	local errors = { } -- 347
	for _index_0 = 1, #yueFiles do -- 348
		local _des_0 = yueFiles[_index_0] -- 348
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 348
		local filename -- 349
		if gamePath then -- 349
			filename = Path(gamePath, file) -- 349
		else -- 349
			filename = file -- 349
		end -- 349
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 350
			if not codes then -- 351
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 352
				return -- 353
			end -- 351
			local success, result = LintYueGlobals(codes, globals) -- 354
			if success then -- 355
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 356
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 357
				codes = codes:gsub("^\n*", "") -- 358
				if not (result == "") then -- 359
					result = result .. "\n" -- 359
				end -- 359
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 360
			else -- 362
				local yueCodes = Content:load(input) -- 362
				if yueCodes then -- 362
					local globalErrors = { } -- 363
					for _index_1 = 1, #result do -- 364
						local _des_1 = result[_index_1] -- 364
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 364
						local countLine = 1 -- 365
						local code = "" -- 366
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 367
							if countLine == line then -- 368
								code = lineCode -- 369
								break -- 370
							end -- 368
							countLine = countLine + 1 -- 371
						end -- 371
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 372
					end -- 372
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 373
				else -- 375
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 375
				end -- 362
			end -- 355
		end, function(success) -- 350
			if success then -- 376
				print("Yue compiled: " .. tostring(filename)) -- 376
			end -- 376
			fileCount = fileCount + 1 -- 377
		end) -- 350
	end -- 377
	thread(function() -- 379
		for _index_0 = 1, #xmlFiles do -- 380
			local _des_0 = xmlFiles[_index_0] -- 380
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 380
			local filename -- 381
			if gamePath then -- 381
				filename = Path(gamePath, file) -- 381
			else -- 381
				filename = file -- 381
			end -- 381
			local sourceCodes = Content:loadAsync(input) -- 382
			local codes, err = xml.tolua(sourceCodes) -- 383
			if not codes then -- 384
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 385
			else -- 387
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 387
				print("Xml compiled: " .. tostring(filename)) -- 388
			end -- 384
			fileCount = fileCount + 1 -- 389
		end -- 389
	end) -- 379
	thread(function() -- 391
		for _index_0 = 1, #tlFiles do -- 392
			local _des_0 = tlFiles[_index_0] -- 392
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 392
			local filename -- 393
			if gamePath then -- 393
				filename = Path(gamePath, file) -- 393
			else -- 393
				filename = file -- 393
			end -- 393
			local sourceCodes = Content:loadAsync(input) -- 394
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 395
			if not codes then -- 396
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 397
			else -- 399
				Content:saveAsync(output, codes) -- 399
				print("Teal compiled: " .. tostring(filename)) -- 400
			end -- 396
			fileCount = fileCount + 1 -- 401
		end -- 401
	end) -- 391
	return thread(function() -- 403
		wait(function() -- 404
			return fileCount == totalFiles -- 404
		end) -- 404
		if minify then -- 405
			local _list_0 = { -- 406
				yueFiles, -- 406
				xmlFiles, -- 406
				tlFiles -- 406
			} -- 406
			for _index_0 = 1, #_list_0 do -- 406
				local files = _list_0[_index_0] -- 406
				for _index_1 = 1, #files do -- 406
					local file = files[_index_1] -- 406
					local output = Path:replaceExt(file[3], "lua") -- 407
					luaFiles[#luaFiles + 1] = { -- 409
						Path:replaceExt(file[1], "lua"), -- 409
						output, -- 410
						output -- 411
					} -- 408
				end -- 411
			end -- 411
			local FormatMini -- 413
			do -- 413
				local _obj_0 = require("luaminify") -- 413
				FormatMini = _obj_0.FormatMini -- 413
			end -- 413
			for _index_0 = 1, #luaFiles do -- 414
				local _des_0 = luaFiles[_index_0] -- 414
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 414
				if Content:exist(input) then -- 415
					local sourceCodes = Content:loadAsync(input) -- 416
					local res, err = FormatMini(sourceCodes) -- 417
					if res then -- 418
						Content:saveAsync(output, res) -- 419
						print("Minify: " .. tostring(file)) -- 420
					else -- 422
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 422
					end -- 418
				else -- 424
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 424
				end -- 415
			end -- 424
			package.loaded["luaminify.FormatMini"] = nil -- 425
			package.loaded["luaminify.ParseLua"] = nil -- 426
			package.loaded["luaminify.Scope"] = nil -- 427
			package.loaded["luaminify.Util"] = nil -- 428
		end -- 405
		local errorMessage = table.concat(errors, "\n") -- 429
		if errorMessage ~= "" then -- 430
			print("\n" .. errorMessage) -- 430
		end -- 430
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 431
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 432
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 433
		Content:clearPathCache() -- 434
		teal.clear() -- 435
		yue.clear() -- 436
		building = false -- 437
	end) -- 437
end -- 282
local doClean -- 439
doClean = function() -- 439
	if building then -- 440
		return -- 440
	end -- 440
	local writablePath = Content.writablePath -- 441
	local targetDir = Path(writablePath, ".build") -- 442
	Content:clearPathCache() -- 443
	if Content:remove(targetDir) then -- 444
		print("Cleaned: " .. tostring(targetDir)) -- 445
	end -- 444
	Content:remove(Path(writablePath, ".upload")) -- 446
	return Content:remove(Path(writablePath, ".download")) -- 447
end -- 439
local screenScale = 2.0 -- 449
local scaleContent = false -- 450
local isInEntry = true -- 451
local currentEntry = nil -- 452
local footerWindow = nil -- 454
local entryWindow = nil -- 455
local setupEventHandlers = nil -- 457
local allClear -- 459
allClear = function() -- 459
	local _list_0 = Routine -- 460
	for _index_0 = 1, #_list_0 do -- 460
		local routine = _list_0[_index_0] -- 460
		if footerWindow == routine or entryWindow == routine then -- 462
			goto _continue_0 -- 463
		else -- 465
			Routine:remove(routine) -- 465
		end -- 465
		::_continue_0:: -- 461
	end -- 465
	for _index_0 = 1, #moduleCache do -- 466
		local module = moduleCache[_index_0] -- 466
		package.loaded[module] = nil -- 467
	end -- 467
	moduleCache = { } -- 468
	Director:cleanup() -- 469
	Cache:unload() -- 470
	Entity:clear() -- 471
	Platformer.Data:clear() -- 472
	Platformer.UnitAction:clear() -- 473
	Audio:stopStream(0.5) -- 474
	Struct:clear() -- 475
	View.postEffect = nil -- 476
	View.scale = scaleContent and screenScale or 1 -- 477
	Director.clearColor = Color(0xff1a1a1a) -- 478
	teal.clear() -- 479
	yue.clear() -- 480
	for _, item in pairs(ubox()) do -- 481
		local node = tolua.cast(item, "Node") -- 482
		if node then -- 482
			node:cleanup() -- 482
		end -- 482
	end -- 482
	collectgarbage() -- 483
	collectgarbage() -- 484
	setupEventHandlers() -- 485
	Content.searchPaths = searchPaths -- 486
	App.idled = true -- 487
	return Wasm:clear() -- 488
end -- 459
_module_0["allClear"] = allClear -- 488
setupEventHandlers = function() -- 490
	local _with_0 = Director.postNode -- 491
	_with_0:gslot("AppQuit", allClear) -- 492
	_with_0:gslot("AppTheme", function(argb) -- 493
		config.themeColor = argb -- 494
	end) -- 493
	_with_0:gslot("AppLocale", function(locale) -- 495
		config.locale = locale -- 496
		updateLocale() -- 497
		return teal.clear(true) -- 498
	end) -- 495
	_with_0:gslot("AppWSClose", function() -- 499
		if HttpServer.wsConnectionCount == 0 then -- 500
			return updateEntries() -- 501
		end -- 500
	end) -- 499
	local _exp_0 = App.platform -- 502
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 502
		_with_0:gslot("AppSizeChanged", function() -- 503
			local width, height -- 504
			do -- 504
				local _obj_0 = App.winSize -- 504
				width, height = _obj_0.width, _obj_0.height -- 504
			end -- 504
			config.winWidth = width -- 505
			config.winHeight = height -- 506
		end) -- 503
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 507
			config.fullScreen = fullScreen -- 508
		end) -- 507
		_with_0:gslot("AppMoved", function() -- 509
			local _obj_0 = App.winPosition -- 510
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 510
		end) -- 509
	end -- 510
	return _with_0 -- 491
end -- 490
setupEventHandlers() -- 512
local stop -- 514
stop = function() -- 514
	if isInEntry then -- 515
		return false -- 515
	end -- 515
	allClear() -- 516
	isInEntry = true -- 517
	currentEntry = nil -- 518
	return true -- 519
end -- 514
_module_0["stop"] = stop -- 519
local _anon_func_0 = function(Content, Path, file, require, type) -- 541
	local scriptPath = Path:getPath(file) -- 534
	Content:insertSearchPath(1, scriptPath) -- 535
	scriptPath = Path(scriptPath, "Script") -- 536
	if Content:exist(scriptPath) then -- 537
		Content:insertSearchPath(1, scriptPath) -- 538
	end -- 537
	local result = require(file) -- 539
	if "function" == type(result) then -- 540
		result() -- 540
	end -- 540
	return nil -- 541
end -- 534
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 573
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 570
	label.alignment = "Left" -- 571
	label.textWidth = width - fontSize -- 572
	label.text = err -- 573
	return label -- 570
end -- 570
local enterEntryAsync -- 521
enterEntryAsync = function(entry) -- 521
	isInEntry = false -- 522
	App.idled = false -- 523
	emit(Profiler.EventName, "ClearLoader") -- 524
	currentEntry = entry -- 525
	local name, file = entry[1], entry[2] -- 526
	if cppTestSet[entry] then -- 527
		if App:runTest(name) then -- 528
			return true -- 529
		else -- 531
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 531
		end -- 528
	end -- 527
	sleep() -- 532
	return xpcall(_anon_func_0, function(msg) -- 541
		local err = debug.traceback(msg) -- 543
		allClear() -- 544
		print(err) -- 545
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 546
		local viewWidth, viewHeight -- 547
		do -- 547
			local _obj_0 = View.size -- 547
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 547
		end -- 547
		local width, height = viewWidth - 20, viewHeight - 20 -- 548
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 549
		Director.ui:addChild((function() -- 550
			local root = AlignNode() -- 550
			do -- 551
				local _obj_0 = App.bufferSize -- 551
				width, height = _obj_0.width, _obj_0.height -- 551
			end -- 551
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 552
			root:gslot("AppSizeChanged", function() -- 553
				do -- 554
					local _obj_0 = App.bufferSize -- 554
					width, height = _obj_0.width, _obj_0.height -- 554
				end -- 554
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 555
			end) -- 553
			root:addChild((function() -- 556
				local _with_0 = ScrollArea({ -- 557
					width = width, -- 557
					height = height, -- 558
					paddingX = 0, -- 559
					paddingY = 50, -- 560
					viewWidth = height, -- 561
					viewHeight = height -- 562
				}) -- 556
				root:slot("AlignLayout", function(w, h) -- 564
					_with_0.position = Vec2(w / 2, h / 2) -- 565
					w = w - 20 -- 566
					h = h - 20 -- 567
					_with_0.view.children.first.textWidth = w - fontSize -- 568
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 569
				end) -- 564
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 570
				return _with_0 -- 556
			end)()) -- 556
			return root -- 550
		end)()) -- 550
		return err -- 574
	end, Content, Path, file, require, type) -- 574
end -- 521
_module_0["enterEntryAsync"] = enterEntryAsync -- 574
local enterDemoEntry -- 576
enterDemoEntry = function(entry) -- 576
	return thread(function() -- 576
		return enterEntryAsync(entry) -- 576
	end) -- 576
end -- 576
local reloadCurrentEntry -- 578
reloadCurrentEntry = function() -- 578
	if currentEntry then -- 579
		allClear() -- 580
		return enterDemoEntry(currentEntry) -- 581
	end -- 579
end -- 578
Director.clearColor = Color(0xff1a1a1a) -- 583
local waitForWebStart = true -- 585
thread(function() -- 586
	sleep(2) -- 587
	waitForWebStart = false -- 588
end) -- 586
local reloadDevEntry -- 590
reloadDevEntry = function() -- 590
	return thread(function() -- 590
		waitForWebStart = true -- 591
		doClean() -- 592
		allClear() -- 593
		_G.require = oldRequire -- 594
		Dora.require = oldRequire -- 595
		package.loaded["Script.Dev.Entry"] = nil -- 596
		return Director.systemScheduler:schedule(function() -- 597
			Routine:clear() -- 598
			oldRequire("Script.Dev.Entry") -- 599
			return true -- 600
		end) -- 600
	end) -- 600
end -- 590
local isOSSLicenseExist = Content:exist("LICENSES") -- 602
local ossLicenses = nil -- 603
local ossLicenseOpen = false -- 604
local extraOperations -- 606
extraOperations = function() -- 606
	local zh = useChinese and isChineseSupported -- 607
	if isOSSLicenseExist then -- 608
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 609
			if not ossLicenses then -- 610
				ossLicenses = { } -- 611
				local licenseText = Content:load("LICENSES") -- 612
				ossLicenseOpen = (licenseText ~= nil) -- 613
				if ossLicenseOpen then -- 613
					licenseText = licenseText:gsub("\r\n", "\n") -- 614
					for license in GSplit(licenseText, "\n--------\n", true) do -- 615
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 616
						if name then -- 616
							ossLicenses[#ossLicenses + 1] = { -- 617
								name, -- 617
								text -- 617
							} -- 617
						end -- 616
					end -- 617
				end -- 613
			else -- 619
				ossLicenseOpen = true -- 619
			end -- 610
		end -- 609
		if ossLicenseOpen then -- 620
			local width, height, themeColor -- 621
			do -- 621
				local _obj_0 = App -- 621
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 621
			end -- 621
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 622
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 623
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 624
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 627
					"NoSavedSettings" -- 627
				}, function() -- 628
					for _index_0 = 1, #ossLicenses do -- 628
						local _des_0 = ossLicenses[_index_0] -- 628
						local firstLine, text = _des_0[1], _des_0[2] -- 628
						local name, license = firstLine:match("(.+): (.+)") -- 629
						TextColored(themeColor, name) -- 630
						SameLine() -- 631
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 632
							return TextWrapped(text) -- 632
						end) -- 632
					end -- 632
				end) -- 624
			end) -- 624
		end -- 620
	end -- 608
	if not App.debugging then -- 634
		return -- 634
	end -- 634
	return TreeNode(zh and "开发操作" or "Development", function() -- 635
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 636
			OpenPopup("build") -- 636
		end -- 636
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 637
			return BeginPopup("build", function() -- 637
				if Selectable(zh and "编译" or "Compile") then -- 638
					doCompile(false) -- 638
				end -- 638
				Separator() -- 639
				if Selectable(zh and "压缩" or "Minify") then -- 640
					doCompile(true) -- 640
				end -- 640
				Separator() -- 641
				if Selectable(zh and "清理" or "Clean") then -- 642
					return doClean() -- 642
				end -- 642
			end) -- 642
		end) -- 637
		if isInEntry then -- 643
			if waitForWebStart then -- 644
				BeginDisabled(function() -- 645
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 645
				end) -- 645
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 646
				reloadDevEntry() -- 647
			end -- 644
		end -- 643
		do -- 648
			local changed -- 648
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 648
			if changed then -- 648
				View.scale = scaleContent and screenScale or 1 -- 649
			end -- 648
		end -- 648
		local changed -- 650
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 650
		if changed then -- 650
			config.engineDev = engineDev -- 651
		end -- 650
	end) -- 635
end -- 606
local transparant = Color(0x0) -- 653
local windowFlags = { -- 655
	"NoTitleBar", -- 655
	"NoResize", -- 656
	"NoMove", -- 657
	"NoCollapse", -- 658
	"NoSavedSettings", -- 659
	"NoBringToFrontOnFocus" -- 660
} -- 654
local initFooter = true -- 661
local _anon_func_2 = function(allEntries, currentIndex) -- 697
	if currentIndex > 1 then -- 697
		return allEntries[currentIndex - 1] -- 698
	else -- 700
		return allEntries[#allEntries] -- 700
	end -- 697
end -- 697
local _anon_func_3 = function(allEntries, currentIndex) -- 704
	if currentIndex < #allEntries then -- 704
		return allEntries[currentIndex + 1] -- 705
	else -- 707
		return allEntries[1] -- 707
	end -- 704
end -- 704
footerWindow = threadLoop(function() -- 662
	local zh = useChinese and isChineseSupported -- 663
	if HttpServer.wsConnectionCount > 0 then -- 664
		return -- 665
	end -- 664
	if Keyboard:isKeyDown("Escape") then -- 666
		allClear() -- 667
		App:shutdown() -- 668
	end -- 666
	do -- 669
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 670
		if ctrl and Keyboard:isKeyDown("Q") then -- 671
			stop() -- 672
		end -- 671
		if ctrl and Keyboard:isKeyDown("Z") then -- 673
			reloadCurrentEntry() -- 674
		end -- 673
		if ctrl and Keyboard:isKeyDown(",") then -- 675
			if showFooter then -- 676
				showStats = not showStats -- 676
			else -- 676
				showStats = true -- 676
			end -- 676
			showFooter = true -- 677
			config.showFooter = showFooter -- 678
			config.showStats = showStats -- 679
		end -- 675
		if ctrl and Keyboard:isKeyDown(".") then -- 680
			if showFooter then -- 681
				showConsole = not showConsole -- 681
			else -- 681
				showConsole = true -- 681
			end -- 681
			showFooter = true -- 682
			config.showFooter = showFooter -- 683
			config.showConsole = showConsole -- 684
		end -- 680
		if ctrl and Keyboard:isKeyDown("/") then -- 685
			showFooter = not showFooter -- 686
			config.showFooter = showFooter -- 687
		end -- 685
		local left = ctrl and Keyboard:isKeyDown("Left") -- 688
		local right = ctrl and Keyboard:isKeyDown("Right") -- 689
		local currentIndex = nil -- 690
		for i, entry in ipairs(allEntries) do -- 691
			if currentEntry == entry then -- 692
				currentIndex = i -- 693
			end -- 692
		end -- 693
		if left then -- 694
			allClear() -- 695
			if currentIndex == nil then -- 696
				currentIndex = #allEntries + 1 -- 696
			end -- 696
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 697
		end -- 694
		if right then -- 701
			allClear() -- 702
			if currentIndex == nil then -- 703
				currentIndex = 0 -- 703
			end -- 703
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 704
		end -- 701
	end -- 707
	if not showEntry then -- 708
		return -- 708
	end -- 708
	local width, height -- 710
	do -- 710
		local _obj_0 = App.visualSize -- 710
		width, height = _obj_0.width, _obj_0.height -- 710
	end -- 710
	SetNextWindowSize(Vec2(50, 50)) -- 711
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 712
	PushStyleColor("WindowBg", transparant, function() -- 713
		return Begin("Show", windowFlags, function() -- 713
			if isInEntry or width >= 540 then -- 714
				local changed -- 715
				changed, showFooter = Checkbox("##dev", showFooter) -- 715
				if changed then -- 715
					config.showFooter = showFooter -- 716
				end -- 715
			end -- 714
		end) -- 716
	end) -- 713
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 718
		reloadDevEntry() -- 722
	end -- 718
	if initFooter then -- 723
		initFooter = false -- 724
	else -- 726
		if not showFooter then -- 726
			return -- 726
		end -- 726
	end -- 723
	SetNextWindowSize(Vec2(width, 50)) -- 728
	SetNextWindowPos(Vec2(0, height - 50)) -- 729
	SetNextWindowBgAlpha(0.35) -- 730
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 731
		return Begin("Footer", windowFlags, function() -- 731
			Dummy(Vec2(width - 20, 0)) -- 732
			do -- 733
				local changed -- 733
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 733
				if changed then -- 733
					config.showStats = showStats -- 734
				end -- 733
			end -- 733
			SameLine() -- 735
			do -- 736
				local changed -- 736
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 736
				if changed then -- 736
					config.showConsole = showConsole -- 737
				end -- 736
			end -- 736
			if not isInEntry then -- 738
				SameLine() -- 739
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 740
					allClear() -- 741
					isInEntry = true -- 742
					currentEntry = nil -- 743
				end -- 740
				local currentIndex = nil -- 744
				for i, entry in ipairs(allEntries) do -- 745
					if currentEntry == entry then -- 746
						currentIndex = i -- 747
					end -- 746
				end -- 747
				if currentIndex then -- 748
					if currentIndex > 1 then -- 749
						SameLine() -- 750
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 751
							allClear() -- 752
							enterDemoEntry(allEntries[currentIndex - 1]) -- 753
						end -- 751
					end -- 749
					if currentIndex < #allEntries then -- 754
						SameLine() -- 755
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 756
							allClear() -- 757
							enterDemoEntry(allEntries[currentIndex + 1]) -- 758
						end -- 756
					end -- 754
				end -- 748
				SameLine() -- 759
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 760
					reloadCurrentEntry() -- 761
				end -- 760
			end -- 738
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 762
				if showStats then -- 763
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 764
					showStats = ShowStats(showStats, extraOperations) -- 765
					config.showStats = showStats -- 766
				end -- 763
				if showConsole then -- 767
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 768
					showConsole = ShowConsole(showConsole) -- 769
					config.showConsole = showConsole -- 770
				end -- 767
			end) -- 770
		end) -- 770
	end) -- 770
end) -- 662
local MaxWidth <const> = 800 -- 772
local displayWindowFlags = { -- 775
	"NoDecoration", -- 775
	"NoSavedSettings", -- 776
	"NoFocusOnAppearing", -- 777
	"NoNav", -- 778
	"NoMove", -- 779
	"NoScrollWithMouse", -- 780
	"AlwaysAutoResize", -- 781
	"NoBringToFrontOnFocus" -- 782
} -- 774
local webStatus = nil -- 784
local descColor = Color(0xffa1a1a1) -- 785
local gameOpen = #gamesInDev == 0 -- 786
local exampleOpen = false -- 787
local testOpen = false -- 788
local filterText = nil -- 789
local anyEntryMatched = false -- 790
local urlClicked = nil -- 791
local match -- 792
match = function(name) -- 792
	local res = not filterText or name:lower():match(filterText) -- 793
	if res then -- 794
		anyEntryMatched = true -- 794
	end -- 794
	return res -- 795
end -- 792
entryWindow = threadLoop(function() -- 797
	if App.fpsLimited ~= config.fpsLimited then -- 798
		config.fpsLimited = App.fpsLimited -- 799
	end -- 798
	if App.targetFPS ~= config.targetFPS then -- 800
		config.targetFPS = App.targetFPS -- 801
	end -- 800
	if View.vsync ~= config.vsync then -- 802
		config.vsync = View.vsync -- 803
	end -- 802
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 804
		config.fixedFPS = Director.scheduler.fixedFPS -- 805
	end -- 804
	if Director.profilerSending ~= config.webProfiler then -- 806
		config.webProfiler = Director.profilerSending -- 807
	end -- 806
	if urlClicked then -- 808
		local _, result = coroutine.resume(urlClicked) -- 809
		if result then -- 810
			coroutine.close(urlClicked) -- 811
			urlClicked = nil -- 812
		end -- 810
	end -- 808
	if not showEntry then -- 813
		return -- 813
	end -- 813
	if not isInEntry then -- 814
		return -- 814
	end -- 814
	local zh = useChinese and isChineseSupported -- 815
	if HttpServer.wsConnectionCount > 0 then -- 816
		local themeColor = App.themeColor -- 817
		local width, height -- 818
		do -- 818
			local _obj_0 = App.visualSize -- 818
			width, height = _obj_0.width, _obj_0.height -- 818
		end -- 818
		SetNextWindowBgAlpha(0.5) -- 819
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 820
		Begin("Web IDE Connected", displayWindowFlags, function() -- 821
			Separator() -- 822
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 823
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 824
			TextColored(descColor, slogon) -- 825
			return Separator() -- 826
		end) -- 821
		return -- 827
	end -- 816
	local themeColor = App.themeColor -- 829
	local fullWidth, height -- 830
	do -- 830
		local _obj_0 = App.visualSize -- 830
		fullWidth, height = _obj_0.width, _obj_0.height -- 830
	end -- 830
	SetNextWindowBgAlpha(0.85) -- 832
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 833
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 834
		return Begin("Web IDE", displayWindowFlags, function() -- 835
			Separator() -- 836
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 837
			do -- 838
				local url -- 838
				if webStatus ~= nil then -- 838
					url = webStatus.url -- 838
				end -- 838
				if url then -- 838
					if isDesktop then -- 839
						if urlClicked then -- 840
							BeginDisabled(function() -- 841
								return Button(url) -- 841
							end) -- 841
						elseif Button(url) then -- 842
							urlClicked = once(function() -- 843
								return sleep(5) -- 843
							end) -- 843
							App:openURL(url) -- 844
						end -- 840
					else -- 846
						TextColored(descColor, url) -- 846
					end -- 839
				else -- 848
					TextColored(descColor, zh and '不可用' or 'not available') -- 848
				end -- 838
			end -- 838
			return Separator() -- 849
		end) -- 849
	end) -- 834
	local width = math.min(MaxWidth, fullWidth) -- 851
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 852
	local maxColumns = math.max(math.floor(width / 200), 1) -- 853
	SetNextWindowPos(Vec2.zero) -- 854
	SetNextWindowBgAlpha(0) -- 855
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 856
		return Begin("Dora Dev", displayWindowFlags, function() -- 857
			Dummy(Vec2(fullWidth - 20, 0)) -- 858
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 859
			SameLine() -- 860
			if fullWidth >= 320 then -- 861
				Dummy(Vec2(fullWidth - 320, 0)) -- 862
				SameLine() -- 863
				SetNextItemWidth(-50) -- 864
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 865
					"AutoSelectAll" -- 865
				}) then -- 865
					config.filter = filterBuf:toString() -- 866
				end -- 865
			end -- 861
			Separator() -- 867
			return Dummy(Vec2(fullWidth - 20, 0)) -- 868
		end) -- 868
	end) -- 856
	anyEntryMatched = false -- 870
	SetNextWindowPos(Vec2(0, 50)) -- 871
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 872
	return PushStyleColor("WindowBg", transparant, function() -- 873
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 873
			return Begin("Content", windowFlags, function() -- 874
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 875
				if filterText then -- 876
					filterText = filterText:lower() -- 876
				end -- 876
				if #gamesInDev > 0 then -- 877
					for _index_0 = 1, #gamesInDev do -- 878
						local game = gamesInDev[_index_0] -- 878
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 879
						local showSep = false -- 880
						if match(gameName) then -- 881
							Columns(1, false) -- 882
							TextColored(themeColor, zh and "项目：" or "Project:") -- 883
							SameLine() -- 884
							Text(gameName) -- 885
							Separator() -- 886
							if bannerFile then -- 887
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 888
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 889
								local sizing <const> = 0.8 -- 890
								texHeight = displayWidth * sizing * texHeight / texWidth -- 891
								texWidth = displayWidth * sizing -- 892
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 893
								Dummy(Vec2(padding, 0)) -- 894
								SameLine() -- 895
								PushID(fileName, function() -- 896
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 897
										return enterDemoEntry(game) -- 898
									end -- 897
								end) -- 896
							else -- 900
								PushID(fileName, function() -- 900
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 901
										return enterDemoEntry(game) -- 902
									end -- 901
								end) -- 900
							end -- 887
							NextColumn() -- 903
							showSep = true -- 904
						end -- 881
						if #examples > 0 then -- 905
							local showExample = false -- 906
							for _index_1 = 1, #examples do -- 907
								local example = examples[_index_1] -- 907
								if match(example[1]) then -- 908
									showExample = true -- 909
									break -- 910
								end -- 908
							end -- 910
							if showExample then -- 911
								Columns(1, false) -- 912
								TextColored(themeColor, zh and "示例：" or "Example:") -- 913
								SameLine() -- 914
								Text(gameName) -- 915
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 916
									Columns(maxColumns, false) -- 917
									for _index_1 = 1, #examples do -- 918
										local example = examples[_index_1] -- 918
										if not match(example[1]) then -- 919
											goto _continue_0 -- 919
										end -- 919
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 920
											if Button(example[1], Vec2(-1, 40)) then -- 921
												enterDemoEntry(example) -- 922
											end -- 921
											return NextColumn() -- 923
										end) -- 920
										showSep = true -- 924
										::_continue_0:: -- 919
									end -- 924
								end) -- 916
							end -- 911
						end -- 905
						if #tests > 0 then -- 925
							local showTest = false -- 926
							for _index_1 = 1, #tests do -- 927
								local test = tests[_index_1] -- 927
								if match(test[1]) then -- 928
									showTest = true -- 929
									break -- 930
								end -- 928
							end -- 930
							if showTest then -- 931
								Columns(1, false) -- 932
								TextColored(themeColor, zh and "测试：" or "Test:") -- 933
								SameLine() -- 934
								Text(gameName) -- 935
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 936
									Columns(maxColumns, false) -- 937
									for _index_1 = 1, #tests do -- 938
										local test = tests[_index_1] -- 938
										if not match(test[1]) then -- 939
											goto _continue_0 -- 939
										end -- 939
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 940
											if Button(test[1], Vec2(-1, 40)) then -- 941
												enterDemoEntry(test) -- 942
											end -- 941
											return NextColumn() -- 943
										end) -- 940
										showSep = true -- 944
										::_continue_0:: -- 939
									end -- 944
								end) -- 936
							end -- 931
						end -- 925
						if showSep then -- 945
							Columns(1, false) -- 946
							Separator() -- 947
						end -- 945
					end -- 947
				end -- 877
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 948
					local showGame = false -- 949
					for _index_0 = 1, #games do -- 950
						local _des_0 = games[_index_0] -- 950
						local name = _des_0[1] -- 950
						if match(name) then -- 951
							showGame = true -- 951
						end -- 951
					end -- 951
					local showExample = false -- 952
					for _index_0 = 1, #doraExamples do -- 953
						local _des_0 = doraExamples[_index_0] -- 953
						local name = _des_0[1] -- 953
						if match(name) then -- 954
							showExample = true -- 954
						end -- 954
					end -- 954
					local showTest = false -- 955
					for _index_0 = 1, #doraTests do -- 956
						local _des_0 = doraTests[_index_0] -- 956
						local name = _des_0[1] -- 956
						if match(name) then -- 957
							showTest = true -- 957
						end -- 957
					end -- 957
					for _index_0 = 1, #cppTests do -- 958
						local _des_0 = cppTests[_index_0] -- 958
						local name = _des_0[1] -- 958
						if match(name) then -- 959
							showTest = true -- 959
						end -- 959
					end -- 959
					if not (showGame or showExample or showTest) then -- 960
						goto endEntry -- 960
					end -- 960
					Columns(1, false) -- 961
					TextColored(themeColor, "Dora SSR:") -- 962
					SameLine() -- 963
					Text(zh and "开发示例" or "Development Showcase") -- 964
					Separator() -- 965
					local demoViewWith <const> = 400 -- 966
					if #games > 0 and showGame then -- 967
						local opened -- 968
						if (filterText ~= nil) then -- 968
							opened = showGame -- 968
						else -- 968
							opened = false -- 968
						end -- 968
						SetNextItemOpen(gameOpen) -- 969
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 970
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 971
							Columns(columns, false) -- 972
							for _index_0 = 1, #games do -- 973
								local game = games[_index_0] -- 973
								if not match(game[1]) then -- 974
									goto _continue_0 -- 974
								end -- 974
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 975
								if columns > 1 then -- 976
									if bannerFile then -- 977
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 978
										local displayWidth <const> = demoViewWith - 40 -- 979
										texHeight = displayWidth * texHeight / texWidth -- 980
										texWidth = displayWidth -- 981
										Text(gameName) -- 982
										PushID(fileName, function() -- 983
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 984
												return enterDemoEntry(game) -- 985
											end -- 984
										end) -- 983
									else -- 987
										PushID(fileName, function() -- 987
											if Button(gameName, Vec2(-1, 40)) then -- 988
												return enterDemoEntry(game) -- 989
											end -- 988
										end) -- 987
									end -- 977
								else -- 991
									if bannerFile then -- 991
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 992
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 993
										local sizing = 0.8 -- 994
										texHeight = displayWidth * sizing * texHeight / texWidth -- 995
										texWidth = displayWidth * sizing -- 996
										if texWidth > 500 then -- 997
											sizing = 0.6 -- 998
											texHeight = displayWidth * sizing * texHeight / texWidth -- 999
											texWidth = displayWidth * sizing -- 1000
										end -- 997
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1001
										Dummy(Vec2(padding, 0)) -- 1002
										SameLine() -- 1003
										Text(gameName) -- 1004
										Dummy(Vec2(padding, 0)) -- 1005
										SameLine() -- 1006
										PushID(fileName, function() -- 1007
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1008
												return enterDemoEntry(game) -- 1009
											end -- 1008
										end) -- 1007
									else -- 1011
										PushID(fileName, function() -- 1011
											if Button(gameName, Vec2(-1, 40)) then -- 1012
												return enterDemoEntry(game) -- 1013
											end -- 1012
										end) -- 1011
									end -- 991
								end -- 976
								NextColumn() -- 1014
								::_continue_0:: -- 974
							end -- 1014
							Columns(1, false) -- 1015
							opened = true -- 1016
						end) -- 970
						gameOpen = opened -- 1017
					end -- 967
					if #doraExamples > 0 and showExample then -- 1018
						local opened -- 1019
						if (filterText ~= nil) then -- 1019
							opened = showExample -- 1019
						else -- 1019
							opened = false -- 1019
						end -- 1019
						SetNextItemOpen(exampleOpen) -- 1020
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1021
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1022
								Columns(maxColumns, false) -- 1023
								for _index_0 = 1, #doraExamples do -- 1024
									local example = doraExamples[_index_0] -- 1024
									if not match(example[1]) then -- 1025
										goto _continue_0 -- 1025
									end -- 1025
									if Button(example[1], Vec2(-1, 40)) then -- 1026
										enterDemoEntry(example) -- 1027
									end -- 1026
									NextColumn() -- 1028
									::_continue_0:: -- 1025
								end -- 1028
								Columns(1, false) -- 1029
								opened = true -- 1030
							end) -- 1022
						end) -- 1021
						exampleOpen = opened -- 1031
					end -- 1018
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1032
						local opened -- 1033
						if (filterText ~= nil) then -- 1033
							opened = showTest -- 1033
						else -- 1033
							opened = false -- 1033
						end -- 1033
						SetNextItemOpen(testOpen) -- 1034
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1035
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1036
								Columns(maxColumns, false) -- 1037
								for _index_0 = 1, #doraTests do -- 1038
									local test = doraTests[_index_0] -- 1038
									if not match(test[1]) then -- 1039
										goto _continue_0 -- 1039
									end -- 1039
									if Button(test[1], Vec2(-1, 40)) then -- 1040
										enterDemoEntry(test) -- 1041
									end -- 1040
									NextColumn() -- 1042
									::_continue_0:: -- 1039
								end -- 1042
								for _index_0 = 1, #cppTests do -- 1043
									local test = cppTests[_index_0] -- 1043
									if not match(test[1]) then -- 1044
										goto _continue_1 -- 1044
									end -- 1044
									if Button(test[1], Vec2(-1, 40)) then -- 1045
										enterDemoEntry(test) -- 1046
									end -- 1045
									NextColumn() -- 1047
									::_continue_1:: -- 1044
								end -- 1047
								opened = true -- 1048
							end) -- 1036
						end) -- 1035
						testOpen = opened -- 1049
					end -- 1032
				end -- 948
				::endEntry:: -- 1050
				if not anyEntryMatched then -- 1051
					SetNextWindowBgAlpha(0) -- 1052
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1053
					Begin("Entries Not Found", displayWindowFlags, function() -- 1054
						Separator() -- 1055
						TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1056
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1057
						return Separator() -- 1058
					end) -- 1054
				end -- 1051
				Columns(1, false) -- 1059
				Dummy(Vec2(100, 80)) -- 1060
				return ScrollWhenDraggingOnVoid() -- 1061
			end) -- 1061
		end) -- 1061
	end) -- 1061
end) -- 797
webStatus = require("Script.Dev.WebServer") -- 1063
return _module_0 -- 1063
