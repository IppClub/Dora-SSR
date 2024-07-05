-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
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
local _module_0 = Dora.ImGui -- 1
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
local ShowConsole = _module_0.ShowConsole -- 1
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
local moduleCache = { } -- 15
local oldRequire = _G.require -- 16
local require -- 17
require = function(path) -- 17
	local loaded = package.loaded[path] -- 18
	if loaded == nil then -- 19
		moduleCache[#moduleCache + 1] = path -- 20
		return oldRequire(path) -- 21
	end -- 19
	return loaded -- 22
end -- 17
_G.require = require -- 23
Dora.require = require -- 24
local searchPaths = Content.searchPaths -- 26
local useChinese = (App.locale:match("^zh") ~= nil) -- 28
local updateLocale -- 29
updateLocale = function() -- 29
	useChinese = (App.locale:match("^zh") ~= nil) -- 30
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 31
	Content.searchPaths = searchPaths -- 32
end -- 29
if DB:exist("Config") then -- 34
	local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 35
	local _type_0 = type(_exp_0) -- 36
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 36
	if _tab_0 then -- 36
		local locale -- 36
		do -- 36
			local _obj_0 = _exp_0[1] -- 36
			local _type_1 = type(_obj_0) -- 36
			if "table" == _type_1 or "userdata" == _type_1 then -- 36
				locale = _obj_0[1] -- 36
			end -- 38
		end -- 38
		if locale ~= nil then -- 36
			if App.locale ~= locale then -- 36
				App.locale = locale -- 37
				updateLocale() -- 38
			end -- 36
		end -- 36
	end -- 38
end -- 34
local Config = require("Config") -- 40
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth") -- 41
config:load() -- 63
if (config.fpsLimited ~= nil) then -- 64
	App.fpsLimited = config.fpsLimited == 1 -- 65
else -- 67
	config.fpsLimited = App.fpsLimited and 1 or 0 -- 67
end -- 64
if (config.targetFPS ~= nil) then -- 69
	App.targetFPS = config.targetFPS -- 70
else -- 72
	config.targetFPS = App.targetFPS -- 72
end -- 69
if (config.vsync ~= nil) then -- 74
	View.vsync = config.vsync == 1 -- 75
else -- 77
	config.vsync = View.vsync and 1 or 0 -- 77
end -- 74
if (config.fixedFPS ~= nil) then -- 79
	Director.scheduler.fixedFPS = config.fixedFPS -- 80
else -- 82
	config.fixedFPS = Director.scheduler.fixedFPS -- 82
end -- 79
local showEntry = true -- 84
local isDesktop = false -- 86
if (function() -- 87
	local _val_0 = App.platform -- 87
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 87
end)() then -- 87
	isDesktop = true -- 88
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 89
		App.winSize = Size.zero -- 90
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 91
		local size = Size(config.winWidth, config.winHeight) -- 92
		if App.winSize ~= size then -- 93
			App.winSize = size -- 94
			showEntry = false -- 95
			thread(function() -- 96
				sleep() -- 97
				sleep() -- 98
				showEntry = true -- 99
			end) -- 96
		end -- 93
		local winX, winY -- 100
		do -- 100
			local _obj_0 = App.winPosition -- 100
			winX, winY = _obj_0.x, _obj_0.y -- 100
		end -- 100
		if (config.winX ~= nil) then -- 101
			winX = config.winX -- 102
		else -- 104
			config.winX = 0 -- 104
		end -- 101
		if (config.winY ~= nil) then -- 105
			winY = config.winY -- 106
		else -- 108
			config.winY = 0 -- 108
		end -- 105
		App.winPosition = Vec2(winX, winY) -- 109
	end -- 89
end -- 87
if (config.themeColor ~= nil) then -- 111
	App.themeColor = Color(config.themeColor) -- 112
else -- 114
	config.themeColor = App.themeColor:toARGB() -- 114
end -- 111
if not (config.locale ~= nil) then -- 116
	config.locale = App.locale -- 117
end -- 116
local showStats = false -- 119
if (config.showStats ~= nil) then -- 120
	showStats = config.showStats > 0 -- 121
else -- 123
	config.showStats = showStats and 1 or 0 -- 123
end -- 120
local showConsole = true -- 125
if (config.showConsole ~= nil) then -- 126
	showConsole = config.showConsole > 0 -- 127
else -- 129
	config.showConsole = showConsole and 1 or 0 -- 129
end -- 126
local showFooter = true -- 131
if (config.showFooter ~= nil) then -- 132
	showFooter = config.showFooter > 0 -- 133
else -- 135
	config.showFooter = showFooter and 1 or 0 -- 135
end -- 132
local filterBuf = Buffer(20) -- 137
if (config.filter ~= nil) then -- 138
	filterBuf:setString(config.filter) -- 139
else -- 141
	config.filter = "" -- 141
end -- 138
local engineDev = false -- 143
if (config.engineDev ~= nil) then -- 144
	engineDev = config.engineDev > 0 -- 145
else -- 147
	config.engineDev = engineDev and 1 or 0 -- 147
end -- 144
if (config.webProfiler ~= nil) then -- 149
	Director.profilerSending = config.webProfiler > 0 -- 150
else -- 152
	config.webProfiler = 1 -- 152
	Director.profilerSending = true -- 153
end -- 149
if not (config.drawerWidth ~= nil) then -- 155
	config.drawerWidth = 200 -- 156
end -- 155
_module_0.getConfig = function() -- 158
	return config -- 158
end -- 158
_module_0.getEngineDev = function() -- 159
	if not App.debugging then -- 160
		return false -- 160
	end -- 160
	return config.engineDev > 0 -- 161
end -- 159
local Set, Struct, LintYueGlobals, GSplit -- 163
do -- 163
	local _obj_0 = require("Utils") -- 163
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 163
end -- 163
local yueext = yue.options.extension -- 164
local isChineseSupported = IsFontLoaded() -- 166
if not isChineseSupported then -- 167
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 168
		isChineseSupported = true -- 169
	end) -- 168
end -- 167
local building = false -- 171
local getAllFiles -- 173
getAllFiles = function(path, exts) -- 173
	local filters = Set(exts) -- 174
	local _accum_0 = { } -- 175
	local _len_0 = 1 -- 175
	local _list_0 = Content:getAllFiles(path) -- 175
	for _index_0 = 1, #_list_0 do -- 175
		local file = _list_0[_index_0] -- 175
		if not filters[Path:getExt(file)] then -- 176
			goto _continue_0 -- 176
		end -- 176
		_accum_0[_len_0] = file -- 177
		_len_0 = _len_0 + 1 -- 177
		::_continue_0:: -- 176
	end -- 177
	return _accum_0 -- 177
end -- 173
local getFileEntries -- 179
getFileEntries = function(path) -- 179
	local entries = { } -- 180
	local _list_0 = getAllFiles(path, { -- 181
		"lua", -- 181
		"xml", -- 181
		yueext, -- 181
		"tl" -- 181
	}) -- 181
	for _index_0 = 1, #_list_0 do -- 181
		local file = _list_0[_index_0] -- 181
		local entryName = Path:getName(file) -- 182
		local entryAdded = false -- 183
		for _index_1 = 1, #entries do -- 184
			local _des_0 = entries[_index_1] -- 184
			local ename = _des_0[1] -- 184
			if entryName == ename then -- 185
				entryAdded = true -- 186
				break -- 187
			end -- 185
		end -- 187
		if entryAdded then -- 188
			goto _continue_0 -- 188
		end -- 188
		local fileName = Path:replaceExt(file, "") -- 189
		fileName = Path(path, fileName) -- 190
		local entry = { -- 191
			entryName, -- 191
			fileName -- 191
		} -- 191
		entries[#entries + 1] = entry -- 192
		::_continue_0:: -- 182
	end -- 192
	table.sort(entries, function(a, b) -- 193
		return a[1] < b[1] -- 193
	end) -- 193
	return entries -- 194
end -- 179
local getProjectEntries -- 196
getProjectEntries = function(path) -- 196
	local entries = { } -- 197
	local _list_0 = Content:getDirs(path) -- 198
	for _index_0 = 1, #_list_0 do -- 198
		local dir = _list_0[_index_0] -- 198
		if dir:match("^%.") then -- 199
			goto _continue_0 -- 199
		end -- 199
		local _list_1 = getAllFiles(Path(path, dir), { -- 200
			"lua", -- 200
			"xml", -- 200
			yueext, -- 200
			"tl", -- 200
			"wasm" -- 200
		}) -- 200
		for _index_1 = 1, #_list_1 do -- 200
			local file = _list_1[_index_1] -- 200
			if "init" == Path:getName(file):lower() then -- 201
				local fileName = Path:replaceExt(file, "") -- 202
				fileName = Path(path, dir, fileName) -- 203
				local entryName = Path:getName(Path:getPath(fileName)) -- 204
				local entryAdded = false -- 205
				for _index_2 = 1, #entries do -- 206
					local _des_0 = entries[_index_2] -- 206
					local ename = _des_0[1] -- 206
					if entryName == ename then -- 207
						entryAdded = true -- 208
						break -- 209
					end -- 207
				end -- 209
				if entryAdded then -- 210
					goto _continue_1 -- 210
				end -- 210
				local examples = { } -- 211
				local tests = { } -- 212
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 213
				if Content:exist(examplePath) then -- 214
					local _list_2 = getFileEntries(examplePath) -- 215
					for _index_2 = 1, #_list_2 do -- 215
						local _des_0 = _list_2[_index_2] -- 215
						local name, ePath = _des_0[1], _des_0[2] -- 215
						local entry = { -- 216
							name, -- 216
							Path(path, dir, Path:getPath(file), ePath) -- 216
						} -- 216
						examples[#examples + 1] = entry -- 217
					end -- 217
				end -- 214
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 218
				if Content:exist(testPath) then -- 219
					local _list_2 = getFileEntries(testPath) -- 220
					for _index_2 = 1, #_list_2 do -- 220
						local _des_0 = _list_2[_index_2] -- 220
						local name, tPath = _des_0[1], _des_0[2] -- 220
						local entry = { -- 221
							name, -- 221
							Path(path, dir, Path:getPath(file), tPath) -- 221
						} -- 221
						tests[#tests + 1] = entry -- 222
					end -- 222
				end -- 219
				local entry = { -- 223
					entryName, -- 223
					fileName, -- 223
					examples, -- 223
					tests -- 223
				} -- 223
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 224
				if not Content:exist(bannerFile) then -- 225
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 226
					if not Content:exist(bannerFile) then -- 227
						bannerFile = nil -- 227
					end -- 227
				end -- 225
				if bannerFile then -- 228
					thread(function() -- 228
						Cache:loadAsync(bannerFile) -- 229
						local bannerTex = Texture2D(bannerFile) -- 230
						if bannerTex then -- 231
							entry[#entry + 1] = bannerFile -- 232
							entry[#entry + 1] = bannerTex -- 233
						end -- 231
					end) -- 228
				end -- 228
				entries[#entries + 1] = entry -- 234
			end -- 201
			::_continue_1:: -- 201
		end -- 234
		::_continue_0:: -- 199
	end -- 234
	table.sort(entries, function(a, b) -- 235
		return a[1] < b[1] -- 235
	end) -- 235
	return entries -- 236
end -- 196
local gamesInDev, games -- 238
local doraExamples, doraTests -- 239
local cppTests, cppTestSet -- 240
local allEntries -- 241
local updateEntries -- 243
updateEntries = function() -- 243
	gamesInDev = getProjectEntries(Content.writablePath) -- 244
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 245
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 247
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 248
	cppTests = { } -- 250
	local _list_0 = App.testNames -- 251
	for _index_0 = 1, #_list_0 do -- 251
		local name = _list_0[_index_0] -- 251
		local entry = { -- 252
			name -- 252
		} -- 252
		cppTests[#cppTests + 1] = entry -- 253
	end -- 253
	cppTestSet = Set(cppTests) -- 254
	allEntries = { } -- 256
	for _index_0 = 1, #gamesInDev do -- 257
		local game = gamesInDev[_index_0] -- 257
		allEntries[#allEntries + 1] = game -- 258
		local examples, tests = game[3], game[4] -- 259
		for _index_1 = 1, #examples do -- 260
			local example = examples[_index_1] -- 260
			allEntries[#allEntries + 1] = example -- 261
		end -- 261
		for _index_1 = 1, #tests do -- 262
			local test = tests[_index_1] -- 262
			allEntries[#allEntries + 1] = test -- 263
		end -- 263
	end -- 263
	for _index_0 = 1, #games do -- 264
		local game = games[_index_0] -- 264
		allEntries[#allEntries + 1] = game -- 265
		local examples, tests = game[3], game[4] -- 266
		for _index_1 = 1, #examples do -- 267
			local example = examples[_index_1] -- 267
			doraExamples[#doraExamples + 1] = example -- 268
		end -- 268
		for _index_1 = 1, #tests do -- 269
			local test = tests[_index_1] -- 269
			doraTests[#doraTests + 1] = test -- 270
		end -- 270
	end -- 270
	local _list_1 = { -- 272
		doraExamples, -- 272
		doraTests, -- 273
		cppTests -- 274
	} -- 271
	for _index_0 = 1, #_list_1 do -- 275
		local group = _list_1[_index_0] -- 271
		for _index_1 = 1, #group do -- 276
			local entry = group[_index_1] -- 276
			allEntries[#allEntries + 1] = entry -- 277
		end -- 277
	end -- 277
end -- 243
updateEntries() -- 279
local doCompile -- 281
doCompile = function(minify) -- 281
	if building then -- 282
		return -- 282
	end -- 282
	building = true -- 283
	local startTime = App.runningTime -- 284
	local luaFiles = { } -- 285
	local yueFiles = { } -- 286
	local xmlFiles = { } -- 287
	local tlFiles = { } -- 288
	local writablePath = Content.writablePath -- 289
	local buildPaths = { -- 291
		{ -- 292
			Path(Content.assetPath), -- 292
			Path(writablePath, ".build"), -- 293
			"" -- 294
		} -- 291
	} -- 290
	for _index_0 = 1, #gamesInDev do -- 297
		local _des_0 = gamesInDev[_index_0] -- 297
		local entryFile = _des_0[2] -- 297
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 298
		buildPaths[#buildPaths + 1] = { -- 300
			Path(writablePath, gamePath), -- 300
			Path(writablePath, ".build", gamePath), -- 301
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 302
			gamePath -- 303
		} -- 299
	end -- 303
	for _index_0 = 1, #buildPaths do -- 304
		local _des_0 = buildPaths[_index_0] -- 304
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 304
		if not Content:exist(inputPath) then -- 305
			goto _continue_0 -- 305
		end -- 305
		local _list_0 = getAllFiles(inputPath, { -- 307
			"lua" -- 307
		}) -- 307
		for _index_1 = 1, #_list_0 do -- 307
			local file = _list_0[_index_1] -- 307
			luaFiles[#luaFiles + 1] = { -- 309
				file, -- 309
				Path(inputPath, file), -- 310
				Path(outputPath, file), -- 311
				gamePath -- 312
			} -- 308
		end -- 312
		local _list_1 = getAllFiles(inputPath, { -- 314
			yueext -- 314
		}) -- 314
		for _index_1 = 1, #_list_1 do -- 314
			local file = _list_1[_index_1] -- 314
			yueFiles[#yueFiles + 1] = { -- 316
				file, -- 316
				Path(inputPath, file), -- 317
				Path(outputPath, Path:replaceExt(file, "lua")), -- 318
				searchPath, -- 319
				gamePath -- 320
			} -- 315
		end -- 320
		local _list_2 = getAllFiles(inputPath, { -- 322
			"xml" -- 322
		}) -- 322
		for _index_1 = 1, #_list_2 do -- 322
			local file = _list_2[_index_1] -- 322
			xmlFiles[#xmlFiles + 1] = { -- 324
				file, -- 324
				Path(inputPath, file), -- 325
				Path(outputPath, Path:replaceExt(file, "lua")), -- 326
				gamePath -- 327
			} -- 323
		end -- 327
		local _list_3 = getAllFiles(inputPath, { -- 329
			"tl" -- 329
		}) -- 329
		for _index_1 = 1, #_list_3 do -- 329
			local file = _list_3[_index_1] -- 329
			if not file:match(".*%.d%.tl$") then -- 330
				tlFiles[#tlFiles + 1] = { -- 332
					file, -- 332
					Path(inputPath, file), -- 333
					Path(outputPath, Path:replaceExt(file, "lua")), -- 334
					searchPath, -- 335
					gamePath -- 336
				} -- 331
			end -- 330
		end -- 336
		::_continue_0:: -- 305
	end -- 336
	local paths -- 338
	do -- 338
		local _tbl_0 = { } -- 338
		local _list_0 = { -- 339
			luaFiles, -- 339
			yueFiles, -- 339
			xmlFiles, -- 339
			tlFiles -- 339
		} -- 339
		for _index_0 = 1, #_list_0 do -- 339
			local files = _list_0[_index_0] -- 339
			for _index_1 = 1, #files do -- 340
				local file = files[_index_1] -- 340
				_tbl_0[Path:getPath(file[3])] = true -- 338
			end -- 338
		end -- 338
		paths = _tbl_0 -- 338
	end -- 340
	for path in pairs(paths) do -- 342
		Content:mkdir(path) -- 342
	end -- 342
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 344
	local fileCount = 0 -- 345
	local errors = { } -- 346
	for _index_0 = 1, #yueFiles do -- 347
		local _des_0 = yueFiles[_index_0] -- 347
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 347
		local filename -- 348
		if gamePath then -- 348
			filename = Path(gamePath, file) -- 348
		else -- 348
			filename = file -- 348
		end -- 348
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 349
			if not codes then -- 350
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 351
				return -- 352
			end -- 350
			local success, result = LintYueGlobals(codes, globals) -- 353
			if success then -- 354
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 355
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 356
				codes = codes:gsub("^\n*", "") -- 357
				if not (result == "") then -- 358
					result = result .. "\n" -- 358
				end -- 358
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 359
			else -- 361
				local yueCodes = Content:load(input) -- 361
				if yueCodes then -- 361
					local globalErrors = { } -- 362
					for _index_1 = 1, #result do -- 363
						local _des_1 = result[_index_1] -- 363
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 363
						local countLine = 1 -- 364
						local code = "" -- 365
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 366
							if countLine == line then -- 367
								code = lineCode -- 368
								break -- 369
							end -- 367
							countLine = countLine + 1 -- 370
						end -- 370
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 371
					end -- 371
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 372
				else -- 374
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 374
				end -- 361
			end -- 354
		end, function(success) -- 349
			if success then -- 375
				print("Yue compiled: " .. tostring(filename)) -- 375
			end -- 375
			fileCount = fileCount + 1 -- 376
		end) -- 349
	end -- 376
	thread(function() -- 378
		for _index_0 = 1, #xmlFiles do -- 379
			local _des_0 = xmlFiles[_index_0] -- 379
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 379
			local filename -- 380
			if gamePath then -- 380
				filename = Path(gamePath, file) -- 380
			else -- 380
				filename = file -- 380
			end -- 380
			local sourceCodes = Content:loadAsync(input) -- 381
			local codes, err = xml.tolua(sourceCodes) -- 382
			if not codes then -- 383
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 384
			else -- 386
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 386
				print("Xml compiled: " .. tostring(filename)) -- 387
			end -- 383
			fileCount = fileCount + 1 -- 388
		end -- 388
	end) -- 378
	thread(function() -- 390
		for _index_0 = 1, #tlFiles do -- 391
			local _des_0 = tlFiles[_index_0] -- 391
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 391
			local filename -- 392
			if gamePath then -- 392
				filename = Path(gamePath, file) -- 392
			else -- 392
				filename = file -- 392
			end -- 392
			local sourceCodes = Content:loadAsync(input) -- 393
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 394
			if not codes then -- 395
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 396
			else -- 398
				Content:saveAsync(output, codes) -- 398
				print("Teal compiled: " .. tostring(filename)) -- 399
			end -- 395
			fileCount = fileCount + 1 -- 400
		end -- 400
	end) -- 390
	return thread(function() -- 402
		wait(function() -- 403
			return fileCount == totalFiles -- 403
		end) -- 403
		if minify then -- 404
			local _list_0 = { -- 405
				yueFiles, -- 405
				xmlFiles, -- 405
				tlFiles -- 405
			} -- 405
			for _index_0 = 1, #_list_0 do -- 405
				local files = _list_0[_index_0] -- 405
				for _index_1 = 1, #files do -- 405
					local file = files[_index_1] -- 405
					local output = Path:replaceExt(file[3], "lua") -- 406
					luaFiles[#luaFiles + 1] = { -- 408
						Path:replaceExt(file[1], "lua"), -- 408
						output, -- 409
						output -- 410
					} -- 407
				end -- 410
			end -- 410
			local FormatMini -- 412
			do -- 412
				local _obj_0 = require("luaminify") -- 412
				FormatMini = _obj_0.FormatMini -- 412
			end -- 412
			for _index_0 = 1, #luaFiles do -- 413
				local _des_0 = luaFiles[_index_0] -- 413
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 413
				if Content:exist(input) then -- 414
					local sourceCodes = Content:loadAsync(input) -- 415
					local res, err = FormatMini(sourceCodes) -- 416
					if res then -- 417
						Content:saveAsync(output, res) -- 418
						print("Minify: " .. tostring(file)) -- 419
					else -- 421
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 421
					end -- 417
				else -- 423
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 423
				end -- 414
			end -- 423
			package.loaded["luaminify.FormatMini"] = nil -- 424
			package.loaded["luaminify.ParseLua"] = nil -- 425
			package.loaded["luaminify.Scope"] = nil -- 426
			package.loaded["luaminify.Util"] = nil -- 427
		end -- 404
		local errorMessage = table.concat(errors, "\n") -- 428
		if errorMessage ~= "" then -- 429
			print("\n" .. errorMessage) -- 429
		end -- 429
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 430
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 431
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 432
		Content:clearPathCache() -- 433
		teal.clear() -- 434
		yue.clear() -- 435
		building = false -- 436
	end) -- 436
end -- 281
local doClean -- 438
doClean = function() -- 438
	if building then -- 439
		return -- 439
	end -- 439
	local writablePath = Content.writablePath -- 440
	local targetDir = Path(writablePath, ".build") -- 441
	Content:clearPathCache() -- 442
	if Content:remove(targetDir) then -- 443
		print("Cleaned: " .. tostring(targetDir)) -- 444
	end -- 443
	Content:remove(Path(writablePath, ".upload")) -- 445
	return Content:remove(Path(writablePath, ".download")) -- 446
end -- 438
local screenScale = 2.0 -- 448
local scaleContent = false -- 449
local isInEntry = true -- 450
local currentEntry = nil -- 451
local footerWindow = nil -- 453
local entryWindow = nil -- 454
local setupEventHandlers = nil -- 456
local allClear -- 458
allClear = function() -- 458
	local _list_0 = Routine -- 459
	for _index_0 = 1, #_list_0 do -- 459
		local routine = _list_0[_index_0] -- 459
		if footerWindow == routine or entryWindow == routine then -- 461
			goto _continue_0 -- 462
		else -- 464
			Routine:remove(routine) -- 464
		end -- 464
		::_continue_0:: -- 460
	end -- 464
	for _index_0 = 1, #moduleCache do -- 465
		local module = moduleCache[_index_0] -- 465
		package.loaded[module] = nil -- 466
	end -- 466
	moduleCache = { } -- 467
	Director:cleanup() -- 468
	Cache:unload() -- 469
	Entity:clear() -- 470
	Platformer.Data:clear() -- 471
	Platformer.UnitAction:clear() -- 472
	Audio:stopStream(0.5) -- 473
	Struct:clear() -- 474
	View.postEffect = nil -- 475
	View.scale = scaleContent and screenScale or 1 -- 476
	Director.clearColor = Color(0xff1a1a1a) -- 477
	teal.clear() -- 478
	yue.clear() -- 479
	for _, item in pairs(ubox()) do -- 480
		local node = tolua.cast(item, "Node") -- 481
		if node then -- 481
			node:cleanup() -- 481
		end -- 481
	end -- 481
	collectgarbage() -- 482
	collectgarbage() -- 483
	setupEventHandlers() -- 484
	Content.searchPaths = searchPaths -- 485
	App.idled = true -- 486
	return Wasm:clear() -- 487
end -- 458
_module_0["allClear"] = allClear -- 487
setupEventHandlers = function() -- 489
	local _with_0 = Director.postNode -- 490
	_with_0:gslot("AppQuit", allClear) -- 491
	_with_0:gslot("AppTheme", function(argb) -- 492
		config.themeColor = argb -- 493
	end) -- 492
	_with_0:gslot("AppLocale", function(locale) -- 494
		config.locale = locale -- 495
		updateLocale() -- 496
		return teal.clear(true) -- 497
	end) -- 494
	_with_0:gslot("AppWSClose", function() -- 498
		if HttpServer.wsConnectionCount == 0 then -- 499
			return updateEntries() -- 500
		end -- 499
	end) -- 498
	local _exp_0 = App.platform -- 501
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 501
		_with_0:gslot("AppSizeChanged", function() -- 502
			local width, height -- 503
			do -- 503
				local _obj_0 = App.winSize -- 503
				width, height = _obj_0.width, _obj_0.height -- 503
			end -- 503
			config.winWidth = width -- 504
			config.winHeight = height -- 505
		end) -- 502
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 506
			config.fullScreen = fullScreen and 1 or 0 -- 507
		end) -- 506
		_with_0:gslot("AppMoved", function() -- 508
			local _obj_0 = App.winPosition -- 509
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 509
		end) -- 508
	end -- 509
	return _with_0 -- 490
end -- 489
setupEventHandlers() -- 511
local stop -- 513
stop = function() -- 513
	if isInEntry then -- 514
		return false -- 514
	end -- 514
	allClear() -- 515
	isInEntry = true -- 516
	currentEntry = nil -- 517
	return true -- 518
end -- 513
_module_0["stop"] = stop -- 518
local _anon_func_0 = function(Content, Path, file, require, type) -- 540
	local scriptPath = Path:getPath(file) -- 533
	Content:insertSearchPath(1, scriptPath) -- 534
	scriptPath = Path(scriptPath, "Script") -- 535
	if Content:exist(scriptPath) then -- 536
		Content:insertSearchPath(1, scriptPath) -- 537
	end -- 536
	local result = require(file) -- 538
	if "function" == type(result) then -- 539
		result() -- 539
	end -- 539
	return nil -- 540
end -- 533
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 572
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 569
	label.alignment = "Left" -- 570
	label.textWidth = width - fontSize -- 571
	label.text = err -- 572
	return label -- 569
end -- 569
local enterEntryAsync -- 520
enterEntryAsync = function(entry) -- 520
	isInEntry = false -- 521
	App.idled = false -- 522
	emit(Profiler.EventName, "ClearLoader") -- 523
	currentEntry = entry -- 524
	local name, file = entry[1], entry[2] -- 525
	if cppTestSet[entry] then -- 526
		if App:runTest(name) then -- 527
			return true -- 528
		else -- 530
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 530
		end -- 527
	end -- 526
	sleep() -- 531
	return xpcall(_anon_func_0, function(msg) -- 540
		local err = debug.traceback(msg) -- 542
		allClear() -- 543
		print(err) -- 544
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 545
		local viewWidth, viewHeight -- 546
		do -- 546
			local _obj_0 = View.size -- 546
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 546
		end -- 546
		local width, height = viewWidth - 20, viewHeight - 20 -- 547
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 548
		Director.ui:addChild((function() -- 549
			local root = AlignNode() -- 549
			do -- 550
				local _obj_0 = App.bufferSize -- 550
				width, height = _obj_0.width, _obj_0.height -- 550
			end -- 550
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 551
			root:gslot("AppSizeChanged", function() -- 552
				do -- 553
					local _obj_0 = App.bufferSize -- 553
					width, height = _obj_0.width, _obj_0.height -- 553
				end -- 553
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 554
			end) -- 552
			root:addChild((function() -- 555
				local _with_0 = ScrollArea({ -- 556
					width = width, -- 556
					height = height, -- 557
					paddingX = 0, -- 558
					paddingY = 50, -- 559
					viewWidth = height, -- 560
					viewHeight = height -- 561
				}) -- 555
				root:slot("AlignLayout", function(w, h) -- 563
					_with_0.position = Vec2(w / 2, h / 2) -- 564
					w = w - 20 -- 565
					h = h - 20 -- 566
					_with_0.view.children.first.textWidth = w - fontSize -- 567
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 568
				end) -- 563
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 569
				return _with_0 -- 555
			end)()) -- 555
			return root -- 549
		end)()) -- 549
		return err -- 573
	end, Content, Path, file, require, type) -- 573
end -- 520
_module_0["enterEntryAsync"] = enterEntryAsync -- 573
local enterDemoEntry -- 575
enterDemoEntry = function(entry) -- 575
	return thread(function() -- 575
		return enterEntryAsync(entry) -- 575
	end) -- 575
end -- 575
local reloadCurrentEntry -- 577
reloadCurrentEntry = function() -- 577
	if currentEntry then -- 578
		allClear() -- 579
		return enterDemoEntry(currentEntry) -- 580
	end -- 578
end -- 577
Director.clearColor = Color(0xff1a1a1a) -- 582
local waitForWebStart = true -- 584
thread(function() -- 585
	sleep(2) -- 586
	waitForWebStart = false -- 587
end) -- 585
local reloadDevEntry -- 589
reloadDevEntry = function() -- 589
	return thread(function() -- 589
		waitForWebStart = true -- 590
		doClean() -- 591
		allClear() -- 592
		_G.require = oldRequire -- 593
		Dora.require = oldRequire -- 594
		package.loaded["Script.Dev.Entry"] = nil -- 595
		return Director.systemScheduler:schedule(function() -- 596
			Routine:clear() -- 597
			oldRequire("Script.Dev.Entry") -- 598
			return true -- 599
		end) -- 599
	end) -- 599
end -- 589
local isOSSLicenseExist = Content:exist("LICENSES") -- 601
local ossLicenses = nil -- 602
local ossLicenseOpen = false -- 603
local extraOperations -- 605
extraOperations = function() -- 605
	local zh = useChinese and isChineseSupported -- 606
	if isOSSLicenseExist then -- 607
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 608
			if not ossLicenses then -- 609
				ossLicenses = { } -- 610
				local licenseText = Content:load("LICENSES") -- 611
				ossLicenseOpen = (licenseText ~= nil) -- 612
				if ossLicenseOpen then -- 612
					licenseText = licenseText:gsub("\r\n", "\n") -- 613
					for license in GSplit(licenseText, "\n--------\n", true) do -- 614
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 615
						if name then -- 615
							ossLicenses[#ossLicenses + 1] = { -- 616
								name, -- 616
								text -- 616
							} -- 616
						end -- 615
					end -- 616
				end -- 612
			else -- 618
				ossLicenseOpen = true -- 618
			end -- 609
		end -- 608
		if ossLicenseOpen then -- 619
			local width, height, themeColor -- 620
			do -- 620
				local _obj_0 = App -- 620
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 620
			end -- 620
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 621
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 622
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 623
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 626
					"NoSavedSettings" -- 626
				}, function() -- 627
					for _index_0 = 1, #ossLicenses do -- 627
						local _des_0 = ossLicenses[_index_0] -- 627
						local firstLine, text = _des_0[1], _des_0[2] -- 627
						local name, license = firstLine:match("(.+): (.+)") -- 628
						TextColored(themeColor, name) -- 629
						SameLine() -- 630
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 631
							return TextWrapped(text) -- 631
						end) -- 631
					end -- 631
				end) -- 623
			end) -- 623
		end -- 619
	end -- 607
	if not App.debugging then -- 633
		return -- 633
	end -- 633
	return TreeNode(zh and "开发操作" or "Development", function() -- 634
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 635
			OpenPopup("build") -- 635
		end -- 635
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 636
			return BeginPopup("build", function() -- 636
				if Selectable(zh and "编译" or "Compile") then -- 637
					doCompile(false) -- 637
				end -- 637
				Separator() -- 638
				if Selectable(zh and "压缩" or "Minify") then -- 639
					doCompile(true) -- 639
				end -- 639
				Separator() -- 640
				if Selectable(zh and "清理" or "Clean") then -- 641
					return doClean() -- 641
				end -- 641
			end) -- 641
		end) -- 636
		if isInEntry then -- 642
			if waitForWebStart then -- 643
				BeginDisabled(function() -- 644
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 644
				end) -- 644
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 645
				reloadDevEntry() -- 646
			end -- 643
		end -- 642
		do -- 647
			local changed -- 647
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 647
			if changed then -- 647
				View.scale = scaleContent and screenScale or 1 -- 648
			end -- 647
		end -- 647
		local changed -- 649
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 649
		if changed then -- 649
			config.engineDev = engineDev and 1 or 0 -- 650
		end -- 649
	end) -- 634
end -- 605
local transparant = Color(0x0) -- 652
local windowFlags = { -- 654
	"NoTitleBar", -- 654
	"NoResize", -- 655
	"NoMove", -- 656
	"NoCollapse", -- 657
	"NoSavedSettings", -- 658
	"NoBringToFrontOnFocus" -- 659
} -- 653
local initFooter = true -- 660
local _anon_func_2 = function(allEntries, currentIndex) -- 696
	if currentIndex > 1 then -- 696
		return allEntries[currentIndex - 1] -- 697
	else -- 699
		return allEntries[#allEntries] -- 699
	end -- 696
end -- 696
local _anon_func_3 = function(allEntries, currentIndex) -- 703
	if currentIndex < #allEntries then -- 703
		return allEntries[currentIndex + 1] -- 704
	else -- 706
		return allEntries[1] -- 706
	end -- 703
end -- 703
footerWindow = threadLoop(function() -- 661
	local zh = useChinese and isChineseSupported -- 662
	if HttpServer.wsConnectionCount > 0 then -- 663
		return -- 664
	end -- 663
	if Keyboard:isKeyDown("Escape") then -- 665
		allClear() -- 666
		App:shutdown() -- 667
	end -- 665
	do -- 668
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 669
		if ctrl and Keyboard:isKeyDown("Q") then -- 670
			stop() -- 671
		end -- 670
		if ctrl and Keyboard:isKeyDown("Z") then -- 672
			reloadCurrentEntry() -- 673
		end -- 672
		if ctrl and Keyboard:isKeyDown(",") then -- 674
			if showFooter then -- 675
				showStats = not showStats -- 675
			else -- 675
				showStats = true -- 675
			end -- 675
			showFooter = true -- 676
			config.showFooter = showFooter and 1 or 0 -- 677
			config.showStats = showStats and 1 or 0 -- 678
		end -- 674
		if ctrl and Keyboard:isKeyDown(".") then -- 679
			if showFooter then -- 680
				showConsole = not showConsole -- 680
			else -- 680
				showConsole = true -- 680
			end -- 680
			showFooter = true -- 681
			config.showFooter = showFooter and 1 or 0 -- 682
			config.showConsole = showConsole and 1 or 0 -- 683
		end -- 679
		if ctrl and Keyboard:isKeyDown("/") then -- 684
			showFooter = not showFooter -- 685
			config.showFooter = showFooter and 1 or 0 -- 686
		end -- 684
		local left = ctrl and Keyboard:isKeyDown("Left") -- 687
		local right = ctrl and Keyboard:isKeyDown("Right") -- 688
		local currentIndex = nil -- 689
		for i, entry in ipairs(allEntries) do -- 690
			if currentEntry == entry then -- 691
				currentIndex = i -- 692
			end -- 691
		end -- 692
		if left then -- 693
			allClear() -- 694
			if currentIndex == nil then -- 695
				currentIndex = #allEntries + 1 -- 695
			end -- 695
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 696
		end -- 693
		if right then -- 700
			allClear() -- 701
			if currentIndex == nil then -- 702
				currentIndex = 0 -- 702
			end -- 702
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 703
		end -- 700
	end -- 706
	if not showEntry then -- 707
		return -- 707
	end -- 707
	local width, height -- 709
	do -- 709
		local _obj_0 = App.visualSize -- 709
		width, height = _obj_0.width, _obj_0.height -- 709
	end -- 709
	SetNextWindowSize(Vec2(50, 50)) -- 710
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 711
	PushStyleColor("WindowBg", transparant, function() -- 712
		return Begin("Show", windowFlags, function() -- 712
			if isInEntry or width >= 540 then -- 713
				local changed -- 714
				changed, showFooter = Checkbox("##dev", showFooter) -- 714
				if changed then -- 714
					config.showFooter = showFooter and 1 or 0 -- 715
				end -- 714
			end -- 713
		end) -- 715
	end) -- 712
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 717
		reloadDevEntry() -- 721
	end -- 717
	if initFooter then -- 722
		initFooter = false -- 723
	else -- 725
		if not showFooter then -- 725
			return -- 725
		end -- 725
	end -- 722
	SetNextWindowSize(Vec2(width, 50)) -- 727
	SetNextWindowPos(Vec2(0, height - 50)) -- 728
	SetNextWindowBgAlpha(0.35) -- 729
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 730
		return Begin("Footer", windowFlags, function() -- 730
			Dummy(Vec2(width - 20, 0)) -- 731
			do -- 732
				local changed -- 732
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 732
				if changed then -- 732
					config.showStats = showStats and 1 or 0 -- 733
				end -- 732
			end -- 732
			SameLine() -- 734
			do -- 735
				local changed -- 735
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 735
				if changed then -- 735
					config.showConsole = showConsole and 1 or 0 -- 736
				end -- 735
			end -- 735
			if not isInEntry then -- 737
				SameLine() -- 738
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 739
					allClear() -- 740
					isInEntry = true -- 741
					currentEntry = nil -- 742
				end -- 739
				local currentIndex = nil -- 743
				for i, entry in ipairs(allEntries) do -- 744
					if currentEntry == entry then -- 745
						currentIndex = i -- 746
					end -- 745
				end -- 746
				if currentIndex then -- 747
					if currentIndex > 1 then -- 748
						SameLine() -- 749
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 750
							allClear() -- 751
							enterDemoEntry(allEntries[currentIndex - 1]) -- 752
						end -- 750
					end -- 748
					if currentIndex < #allEntries then -- 753
						SameLine() -- 754
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 755
							allClear() -- 756
							enterDemoEntry(allEntries[currentIndex + 1]) -- 757
						end -- 755
					end -- 753
				end -- 747
				SameLine() -- 758
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 759
					reloadCurrentEntry() -- 760
				end -- 759
			end -- 737
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 761
				if showStats then -- 762
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 763
					showStats = ShowStats(showStats, extraOperations) -- 764
					config.showStats = showStats and 1 or 0 -- 765
				end -- 762
				if showConsole then -- 766
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 767
					showConsole = ShowConsole(showConsole) -- 768
					config.showConsole = showConsole and 1 or 0 -- 769
				end -- 766
			end) -- 769
		end) -- 769
	end) -- 769
end) -- 661
local MaxWidth <const> = 800 -- 771
local displayWindowFlags = { -- 774
	"NoDecoration", -- 774
	"NoSavedSettings", -- 775
	"NoFocusOnAppearing", -- 776
	"NoNav", -- 777
	"NoMove", -- 778
	"NoScrollWithMouse", -- 779
	"AlwaysAutoResize", -- 780
	"NoBringToFrontOnFocus" -- 781
} -- 773
local webStatus = nil -- 783
local descColor = Color(0xffa1a1a1) -- 784
local gameOpen = #gamesInDev == 0 -- 785
local exampleOpen = false -- 786
local testOpen = false -- 787
local filterText = nil -- 788
local anyEntryMatched = false -- 789
local urlClicked = nil -- 790
local match -- 791
match = function(name) -- 791
	local res = not filterText or name:lower():match(filterText) -- 792
	if res then -- 793
		anyEntryMatched = true -- 793
	end -- 793
	return res -- 794
end -- 791
entryWindow = threadLoop(function() -- 796
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 797
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 798
	end -- 797
	if App.targetFPS ~= config.targetFPS then -- 799
		config.targetFPS = App.targetFPS -- 800
	end -- 799
	if View.vsync ~= (config.vsync == 1) then -- 801
		config.vsync = View.vsync and 1 or 0 -- 802
	end -- 801
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 803
		config.fixedFPS = Director.scheduler.fixedFPS -- 804
	end -- 803
	if Director.profilerSending ~= (config.webProfiler == 1) then -- 805
		config.webProfiler = Director.profilerSending and 1 or 0 -- 806
	end -- 805
	if urlClicked then -- 807
		local _, result = coroutine.resume(urlClicked) -- 808
		if result then -- 809
			coroutine.close(urlClicked) -- 810
			urlClicked = nil -- 811
		end -- 809
	end -- 807
	if not showEntry then -- 812
		return -- 812
	end -- 812
	if not isInEntry then -- 813
		return -- 813
	end -- 813
	local zh = useChinese and isChineseSupported -- 814
	if HttpServer.wsConnectionCount > 0 then -- 815
		local themeColor = App.themeColor -- 816
		local width, height -- 817
		do -- 817
			local _obj_0 = App.visualSize -- 817
			width, height = _obj_0.width, _obj_0.height -- 817
		end -- 817
		SetNextWindowBgAlpha(0.5) -- 818
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 819
		Begin("Web IDE Connected", displayWindowFlags, function() -- 820
			Separator() -- 821
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 822
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 823
			TextColored(descColor, slogon) -- 824
			return Separator() -- 825
		end) -- 820
		return -- 826
	end -- 815
	local themeColor = App.themeColor -- 828
	local fullWidth, height -- 829
	do -- 829
		local _obj_0 = App.visualSize -- 829
		fullWidth, height = _obj_0.width, _obj_0.height -- 829
	end -- 829
	SetNextWindowBgAlpha(0.85) -- 831
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 832
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 833
		return Begin("Web IDE", displayWindowFlags, function() -- 834
			Separator() -- 835
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 836
			do -- 837
				local url -- 837
				if webStatus ~= nil then -- 837
					url = webStatus.url -- 837
				end -- 837
				if url then -- 837
					if isDesktop then -- 838
						if urlClicked then -- 839
							BeginDisabled(function() -- 840
								return Button(url) -- 840
							end) -- 840
						elseif Button(url) then -- 841
							urlClicked = once(function() -- 842
								return sleep(5) -- 842
							end) -- 842
							App:openURL(url) -- 843
						end -- 839
					else -- 845
						TextColored(descColor, url) -- 845
					end -- 838
				else -- 847
					TextColored(descColor, zh and '不可用' or 'not available') -- 847
				end -- 837
			end -- 837
			return Separator() -- 848
		end) -- 848
	end) -- 833
	local width = math.min(MaxWidth, fullWidth) -- 850
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 851
	local maxColumns = math.max(math.floor(width / 200), 1) -- 852
	SetNextWindowPos(Vec2.zero) -- 853
	SetNextWindowBgAlpha(0) -- 854
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 855
		return Begin("Dora Dev", displayWindowFlags, function() -- 856
			Dummy(Vec2(fullWidth - 20, 0)) -- 857
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 858
			SameLine() -- 859
			if fullWidth >= 320 then -- 860
				Dummy(Vec2(fullWidth - 320, 0)) -- 861
				SameLine() -- 862
				SetNextItemWidth(-50) -- 863
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 864
					"AutoSelectAll" -- 864
				}) then -- 864
					config.filter = filterBuf:toString() -- 865
				end -- 864
			end -- 860
			Separator() -- 866
			return Dummy(Vec2(fullWidth - 20, 0)) -- 867
		end) -- 867
	end) -- 855
	anyEntryMatched = false -- 869
	SetNextWindowPos(Vec2(0, 50)) -- 870
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 871
	return PushStyleColor("WindowBg", transparant, function() -- 872
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 872
			return Begin("Content", windowFlags, function() -- 873
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 874
				if filterText then -- 875
					filterText = filterText:lower() -- 875
				end -- 875
				if #gamesInDev > 0 then -- 876
					for _index_0 = 1, #gamesInDev do -- 877
						local game = gamesInDev[_index_0] -- 877
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 878
						local showSep = false -- 879
						if match(gameName) then -- 880
							Columns(1, false) -- 881
							TextColored(themeColor, zh and "项目：" or "Project:") -- 882
							SameLine() -- 883
							Text(gameName) -- 884
							Separator() -- 885
							if bannerFile then -- 886
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 887
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 888
								local sizing <const> = 0.8 -- 889
								texHeight = displayWidth * sizing * texHeight / texWidth -- 890
								texWidth = displayWidth * sizing -- 891
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 892
								Dummy(Vec2(padding, 0)) -- 893
								SameLine() -- 894
								PushID(fileName, function() -- 895
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 896
										return enterDemoEntry(game) -- 897
									end -- 896
								end) -- 895
							else -- 899
								PushID(fileName, function() -- 899
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 900
										return enterDemoEntry(game) -- 901
									end -- 900
								end) -- 899
							end -- 886
							NextColumn() -- 902
							showSep = true -- 903
						end -- 880
						if #examples > 0 then -- 904
							local showExample = false -- 905
							for _index_1 = 1, #examples do -- 906
								local example = examples[_index_1] -- 906
								if match(example[1]) then -- 907
									showExample = true -- 908
									break -- 909
								end -- 907
							end -- 909
							if showExample then -- 910
								Columns(1, false) -- 911
								TextColored(themeColor, zh and "示例：" or "Example:") -- 912
								SameLine() -- 913
								Text(gameName) -- 914
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 915
									Columns(maxColumns, false) -- 916
									for _index_1 = 1, #examples do -- 917
										local example = examples[_index_1] -- 917
										if not match(example[1]) then -- 918
											goto _continue_0 -- 918
										end -- 918
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 919
											if Button(example[1], Vec2(-1, 40)) then -- 920
												enterDemoEntry(example) -- 921
											end -- 920
											return NextColumn() -- 922
										end) -- 919
										showSep = true -- 923
										::_continue_0:: -- 918
									end -- 923
								end) -- 915
							end -- 910
						end -- 904
						if #tests > 0 then -- 924
							local showTest = false -- 925
							for _index_1 = 1, #tests do -- 926
								local test = tests[_index_1] -- 926
								if match(test[1]) then -- 927
									showTest = true -- 928
									break -- 929
								end -- 927
							end -- 929
							if showTest then -- 930
								Columns(1, false) -- 931
								TextColored(themeColor, zh and "测试：" or "Test:") -- 932
								SameLine() -- 933
								Text(gameName) -- 934
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 935
									Columns(maxColumns, false) -- 936
									for _index_1 = 1, #tests do -- 937
										local test = tests[_index_1] -- 937
										if not match(test[1]) then -- 938
											goto _continue_0 -- 938
										end -- 938
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 939
											if Button(test[1], Vec2(-1, 40)) then -- 940
												enterDemoEntry(test) -- 941
											end -- 940
											return NextColumn() -- 942
										end) -- 939
										showSep = true -- 943
										::_continue_0:: -- 938
									end -- 943
								end) -- 935
							end -- 930
						end -- 924
						if showSep then -- 944
							Columns(1, false) -- 945
							Separator() -- 946
						end -- 944
					end -- 946
				end -- 876
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 947
					local showGame = false -- 948
					for _index_0 = 1, #games do -- 949
						local _des_0 = games[_index_0] -- 949
						local name = _des_0[1] -- 949
						if match(name) then -- 950
							showGame = true -- 950
						end -- 950
					end -- 950
					local showExample = false -- 951
					for _index_0 = 1, #doraExamples do -- 952
						local _des_0 = doraExamples[_index_0] -- 952
						local name = _des_0[1] -- 952
						if match(name) then -- 953
							showExample = true -- 953
						end -- 953
					end -- 953
					local showTest = false -- 954
					for _index_0 = 1, #doraTests do -- 955
						local _des_0 = doraTests[_index_0] -- 955
						local name = _des_0[1] -- 955
						if match(name) then -- 956
							showTest = true -- 956
						end -- 956
					end -- 956
					for _index_0 = 1, #cppTests do -- 957
						local _des_0 = cppTests[_index_0] -- 957
						local name = _des_0[1] -- 957
						if match(name) then -- 958
							showTest = true -- 958
						end -- 958
					end -- 958
					if not (showGame or showExample or showTest) then -- 959
						goto endEntry -- 959
					end -- 959
					Columns(1, false) -- 960
					TextColored(themeColor, "Dora SSR:") -- 961
					SameLine() -- 962
					Text(zh and "开发示例" or "Development Showcase") -- 963
					Separator() -- 964
					local demoViewWith <const> = 400 -- 965
					if #games > 0 and showGame then -- 966
						local opened -- 967
						if (filterText ~= nil) then -- 967
							opened = showGame -- 967
						else -- 967
							opened = false -- 967
						end -- 967
						SetNextItemOpen(gameOpen) -- 968
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 969
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 970
							Columns(columns, false) -- 971
							for _index_0 = 1, #games do -- 972
								local game = games[_index_0] -- 972
								if not match(game[1]) then -- 973
									goto _continue_0 -- 973
								end -- 973
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 974
								if columns > 1 then -- 975
									if bannerFile then -- 976
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 977
										local displayWidth <const> = demoViewWith - 40 -- 978
										texHeight = displayWidth * texHeight / texWidth -- 979
										texWidth = displayWidth -- 980
										Text(gameName) -- 981
										PushID(fileName, function() -- 982
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 983
												return enterDemoEntry(game) -- 984
											end -- 983
										end) -- 982
									else -- 986
										PushID(fileName, function() -- 986
											if Button(gameName, Vec2(-1, 40)) then -- 987
												return enterDemoEntry(game) -- 988
											end -- 987
										end) -- 986
									end -- 976
								else -- 990
									if bannerFile then -- 990
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 991
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 992
										local sizing = 0.8 -- 993
										texHeight = displayWidth * sizing * texHeight / texWidth -- 994
										texWidth = displayWidth * sizing -- 995
										if texWidth > 500 then -- 996
											sizing = 0.6 -- 997
											texHeight = displayWidth * sizing * texHeight / texWidth -- 998
											texWidth = displayWidth * sizing -- 999
										end -- 996
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1000
										Dummy(Vec2(padding, 0)) -- 1001
										SameLine() -- 1002
										Text(gameName) -- 1003
										Dummy(Vec2(padding, 0)) -- 1004
										SameLine() -- 1005
										PushID(fileName, function() -- 1006
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1007
												return enterDemoEntry(game) -- 1008
											end -- 1007
										end) -- 1006
									else -- 1010
										PushID(fileName, function() -- 1010
											if Button(gameName, Vec2(-1, 40)) then -- 1011
												return enterDemoEntry(game) -- 1012
											end -- 1011
										end) -- 1010
									end -- 990
								end -- 975
								NextColumn() -- 1013
								::_continue_0:: -- 973
							end -- 1013
							Columns(1, false) -- 1014
							opened = true -- 1015
						end) -- 969
						gameOpen = opened -- 1016
					end -- 966
					if #doraExamples > 0 and showExample then -- 1017
						local opened -- 1018
						if (filterText ~= nil) then -- 1018
							opened = showExample -- 1018
						else -- 1018
							opened = false -- 1018
						end -- 1018
						SetNextItemOpen(exampleOpen) -- 1019
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1020
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1021
								Columns(maxColumns, false) -- 1022
								for _index_0 = 1, #doraExamples do -- 1023
									local example = doraExamples[_index_0] -- 1023
									if not match(example[1]) then -- 1024
										goto _continue_0 -- 1024
									end -- 1024
									if Button(example[1], Vec2(-1, 40)) then -- 1025
										enterDemoEntry(example) -- 1026
									end -- 1025
									NextColumn() -- 1027
									::_continue_0:: -- 1024
								end -- 1027
								Columns(1, false) -- 1028
								opened = true -- 1029
							end) -- 1021
						end) -- 1020
						exampleOpen = opened -- 1030
					end -- 1017
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1031
						local opened -- 1032
						if (filterText ~= nil) then -- 1032
							opened = showTest -- 1032
						else -- 1032
							opened = false -- 1032
						end -- 1032
						SetNextItemOpen(testOpen) -- 1033
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1034
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1035
								Columns(maxColumns, false) -- 1036
								for _index_0 = 1, #doraTests do -- 1037
									local test = doraTests[_index_0] -- 1037
									if not match(test[1]) then -- 1038
										goto _continue_0 -- 1038
									end -- 1038
									if Button(test[1], Vec2(-1, 40)) then -- 1039
										enterDemoEntry(test) -- 1040
									end -- 1039
									NextColumn() -- 1041
									::_continue_0:: -- 1038
								end -- 1041
								for _index_0 = 1, #cppTests do -- 1042
									local test = cppTests[_index_0] -- 1042
									if not match(test[1]) then -- 1043
										goto _continue_1 -- 1043
									end -- 1043
									if Button(test[1], Vec2(-1, 40)) then -- 1044
										enterDemoEntry(test) -- 1045
									end -- 1044
									NextColumn() -- 1046
									::_continue_1:: -- 1043
								end -- 1046
								opened = true -- 1047
							end) -- 1035
						end) -- 1034
						testOpen = opened -- 1048
					end -- 1031
				end -- 947
				::endEntry:: -- 1049
				if not anyEntryMatched then -- 1050
					SetNextWindowBgAlpha(0) -- 1051
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1052
					Begin("Entries Not Found", displayWindowFlags, function() -- 1053
						Separator() -- 1054
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1055
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1056
						return Separator() -- 1057
					end) -- 1053
				end -- 1050
				Columns(1, false) -- 1058
				Dummy(Vec2(100, 80)) -- 1059
				return ScrollWhenDraggingOnVoid() -- 1060
			end) -- 1060
		end) -- 1060
	end) -- 1060
end) -- 796
webStatus = require("Script.Dev.WebServer") -- 1062
return _module_0 -- 1062
