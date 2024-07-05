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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler") -- 41
config:load() -- 62
if (config.fpsLimited ~= nil) then -- 63
	App.fpsLimited = config.fpsLimited == 1 -- 64
else -- 66
	config.fpsLimited = App.fpsLimited and 1 or 0 -- 66
end -- 63
if (config.targetFPS ~= nil) then -- 68
	App.targetFPS = config.targetFPS -- 69
else -- 71
	config.targetFPS = App.targetFPS -- 71
end -- 68
if (config.vsync ~= nil) then -- 73
	View.vsync = config.vsync == 1 -- 74
else -- 76
	config.vsync = View.vsync and 1 or 0 -- 76
end -- 73
if (config.fixedFPS ~= nil) then -- 78
	Director.scheduler.fixedFPS = config.fixedFPS -- 79
else -- 81
	config.fixedFPS = Director.scheduler.fixedFPS -- 81
end -- 78
local showEntry = true -- 83
local isDesktop = false -- 85
if (function() -- 86
	local _val_0 = App.platform -- 86
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 86
end)() then -- 86
	isDesktop = true -- 87
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 88
		App.winSize = Size.zero -- 89
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 90
		local size = Size(config.winWidth, config.winHeight) -- 91
		if App.winSize ~= size then -- 92
			App.winSize = size -- 93
			showEntry = false -- 94
			thread(function() -- 95
				sleep() -- 96
				sleep() -- 97
				showEntry = true -- 98
			end) -- 95
		end -- 92
		local winX, winY -- 99
		do -- 99
			local _obj_0 = App.winPosition -- 99
			winX, winY = _obj_0.x, _obj_0.y -- 99
		end -- 99
		if (config.winX ~= nil) then -- 100
			winX = config.winX -- 101
		else -- 103
			config.winX = 0 -- 103
		end -- 100
		if (config.winY ~= nil) then -- 104
			winY = config.winY -- 105
		else -- 107
			config.winY = 0 -- 107
		end -- 104
		App.winPosition = Vec2(winX, winY) -- 108
	end -- 88
end -- 86
if (config.themeColor ~= nil) then -- 110
	App.themeColor = Color(config.themeColor) -- 111
else -- 113
	config.themeColor = App.themeColor:toARGB() -- 113
end -- 110
if not (config.locale ~= nil) then -- 115
	config.locale = App.locale -- 116
end -- 115
local showStats = false -- 118
if (config.showStats ~= nil) then -- 119
	showStats = config.showStats > 0 -- 120
else -- 122
	config.showStats = showStats and 1 or 0 -- 122
end -- 119
local showConsole = true -- 124
if (config.showConsole ~= nil) then -- 125
	showConsole = config.showConsole > 0 -- 126
else -- 128
	config.showConsole = showConsole and 1 or 0 -- 128
end -- 125
local showFooter = true -- 130
if (config.showFooter ~= nil) then -- 131
	showFooter = config.showFooter > 0 -- 132
else -- 134
	config.showFooter = showFooter and 1 or 0 -- 134
end -- 131
local filterBuf = Buffer(20) -- 136
if (config.filter ~= nil) then -- 137
	filterBuf:setString(config.filter) -- 138
else -- 140
	config.filter = "" -- 140
end -- 137
local engineDev = false -- 142
if (config.engineDev ~= nil) then -- 143
	engineDev = config.engineDev > 0 -- 144
else -- 146
	config.engineDev = engineDev and 1 or 0 -- 146
end -- 143
if (config.webProfiler ~= nil) then -- 148
	Director.profilerSending = config.webProfiler > 0 -- 149
else -- 151
	config.webProfiler = 1 -- 151
	Director.profilerSending = true -- 152
end -- 148
_module_0.getConfig = function() -- 154
	return config -- 154
end -- 154
_module_0.getEngineDev = function() -- 155
	if not App.debugging then -- 156
		return false -- 156
	end -- 156
	return config.engineDev > 0 -- 157
end -- 155
local Set, Struct, LintYueGlobals, GSplit -- 159
do -- 159
	local _obj_0 = require("Utils") -- 159
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 159
end -- 159
local yueext = yue.options.extension -- 160
local isChineseSupported = IsFontLoaded() -- 162
if not isChineseSupported then -- 163
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 164
		isChineseSupported = true -- 165
	end) -- 164
end -- 163
local building = false -- 167
local getAllFiles -- 169
getAllFiles = function(path, exts) -- 169
	local filters = Set(exts) -- 170
	local _accum_0 = { } -- 171
	local _len_0 = 1 -- 171
	local _list_0 = Content:getAllFiles(path) -- 171
	for _index_0 = 1, #_list_0 do -- 171
		local file = _list_0[_index_0] -- 171
		if not filters[Path:getExt(file)] then -- 172
			goto _continue_0 -- 172
		end -- 172
		_accum_0[_len_0] = file -- 173
		_len_0 = _len_0 + 1 -- 173
		::_continue_0:: -- 172
	end -- 173
	return _accum_0 -- 173
end -- 169
local getFileEntries -- 175
getFileEntries = function(path) -- 175
	local entries = { } -- 176
	local _list_0 = getAllFiles(path, { -- 177
		"lua", -- 177
		"xml", -- 177
		yueext, -- 177
		"tl" -- 177
	}) -- 177
	for _index_0 = 1, #_list_0 do -- 177
		local file = _list_0[_index_0] -- 177
		local entryName = Path:getName(file) -- 178
		local entryAdded = false -- 179
		for _index_1 = 1, #entries do -- 180
			local _des_0 = entries[_index_1] -- 180
			local ename = _des_0[1] -- 180
			if entryName == ename then -- 181
				entryAdded = true -- 182
				break -- 183
			end -- 181
		end -- 183
		if entryAdded then -- 184
			goto _continue_0 -- 184
		end -- 184
		local fileName = Path:replaceExt(file, "") -- 185
		fileName = Path(path, fileName) -- 186
		local entry = { -- 187
			entryName, -- 187
			fileName -- 187
		} -- 187
		entries[#entries + 1] = entry -- 188
		::_continue_0:: -- 178
	end -- 188
	table.sort(entries, function(a, b) -- 189
		return a[1] < b[1] -- 189
	end) -- 189
	return entries -- 190
end -- 175
local getProjectEntries -- 192
getProjectEntries = function(path) -- 192
	local entries = { } -- 193
	local _list_0 = Content:getDirs(path) -- 194
	for _index_0 = 1, #_list_0 do -- 194
		local dir = _list_0[_index_0] -- 194
		if dir:match("^%.") then -- 195
			goto _continue_0 -- 195
		end -- 195
		local _list_1 = getAllFiles(Path(path, dir), { -- 196
			"lua", -- 196
			"xml", -- 196
			yueext, -- 196
			"tl", -- 196
			"wasm" -- 196
		}) -- 196
		for _index_1 = 1, #_list_1 do -- 196
			local file = _list_1[_index_1] -- 196
			if "init" == Path:getName(file):lower() then -- 197
				local fileName = Path:replaceExt(file, "") -- 198
				fileName = Path(path, dir, fileName) -- 199
				local entryName = Path:getName(Path:getPath(fileName)) -- 200
				local entryAdded = false -- 201
				for _index_2 = 1, #entries do -- 202
					local _des_0 = entries[_index_2] -- 202
					local ename = _des_0[1] -- 202
					if entryName == ename then -- 203
						entryAdded = true -- 204
						break -- 205
					end -- 203
				end -- 205
				if entryAdded then -- 206
					goto _continue_1 -- 206
				end -- 206
				local examples = { } -- 207
				local tests = { } -- 208
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 209
				if Content:exist(examplePath) then -- 210
					local _list_2 = getFileEntries(examplePath) -- 211
					for _index_2 = 1, #_list_2 do -- 211
						local _des_0 = _list_2[_index_2] -- 211
						local name, ePath = _des_0[1], _des_0[2] -- 211
						local entry = { -- 212
							name, -- 212
							Path(path, dir, Path:getPath(file), ePath) -- 212
						} -- 212
						examples[#examples + 1] = entry -- 213
					end -- 213
				end -- 210
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 214
				if Content:exist(testPath) then -- 215
					local _list_2 = getFileEntries(testPath) -- 216
					for _index_2 = 1, #_list_2 do -- 216
						local _des_0 = _list_2[_index_2] -- 216
						local name, tPath = _des_0[1], _des_0[2] -- 216
						local entry = { -- 217
							name, -- 217
							Path(path, dir, Path:getPath(file), tPath) -- 217
						} -- 217
						tests[#tests + 1] = entry -- 218
					end -- 218
				end -- 215
				local entry = { -- 219
					entryName, -- 219
					fileName, -- 219
					examples, -- 219
					tests -- 219
				} -- 219
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 220
				if not Content:exist(bannerFile) then -- 221
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 222
					if not Content:exist(bannerFile) then -- 223
						bannerFile = nil -- 223
					end -- 223
				end -- 221
				if bannerFile then -- 224
					thread(function() -- 224
						Cache:loadAsync(bannerFile) -- 225
						local bannerTex = Texture2D(bannerFile) -- 226
						if bannerTex then -- 227
							entry[#entry + 1] = bannerFile -- 228
							entry[#entry + 1] = bannerTex -- 229
						end -- 227
					end) -- 224
				end -- 224
				entries[#entries + 1] = entry -- 230
			end -- 197
			::_continue_1:: -- 197
		end -- 230
		::_continue_0:: -- 195
	end -- 230
	table.sort(entries, function(a, b) -- 231
		return a[1] < b[1] -- 231
	end) -- 231
	return entries -- 232
end -- 192
local gamesInDev, games -- 234
local doraExamples, doraTests -- 235
local cppTests, cppTestSet -- 236
local allEntries -- 237
local updateEntries -- 239
updateEntries = function() -- 239
	gamesInDev = getProjectEntries(Content.writablePath) -- 240
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 241
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 243
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 244
	cppTests = { } -- 246
	local _list_0 = App.testNames -- 247
	for _index_0 = 1, #_list_0 do -- 247
		local name = _list_0[_index_0] -- 247
		local entry = { -- 248
			name -- 248
		} -- 248
		cppTests[#cppTests + 1] = entry -- 249
	end -- 249
	cppTestSet = Set(cppTests) -- 250
	allEntries = { } -- 252
	for _index_0 = 1, #gamesInDev do -- 253
		local game = gamesInDev[_index_0] -- 253
		allEntries[#allEntries + 1] = game -- 254
		local examples, tests = game[3], game[4] -- 255
		for _index_1 = 1, #examples do -- 256
			local example = examples[_index_1] -- 256
			allEntries[#allEntries + 1] = example -- 257
		end -- 257
		for _index_1 = 1, #tests do -- 258
			local test = tests[_index_1] -- 258
			allEntries[#allEntries + 1] = test -- 259
		end -- 259
	end -- 259
	for _index_0 = 1, #games do -- 260
		local game = games[_index_0] -- 260
		allEntries[#allEntries + 1] = game -- 261
		local examples, tests = game[3], game[4] -- 262
		for _index_1 = 1, #examples do -- 263
			local example = examples[_index_1] -- 263
			doraExamples[#doraExamples + 1] = example -- 264
		end -- 264
		for _index_1 = 1, #tests do -- 265
			local test = tests[_index_1] -- 265
			doraTests[#doraTests + 1] = test -- 266
		end -- 266
	end -- 266
	local _list_1 = { -- 268
		doraExamples, -- 268
		doraTests, -- 269
		cppTests -- 270
	} -- 267
	for _index_0 = 1, #_list_1 do -- 271
		local group = _list_1[_index_0] -- 267
		for _index_1 = 1, #group do -- 272
			local entry = group[_index_1] -- 272
			allEntries[#allEntries + 1] = entry -- 273
		end -- 273
	end -- 273
end -- 239
updateEntries() -- 275
local doCompile -- 277
doCompile = function(minify) -- 277
	if building then -- 278
		return -- 278
	end -- 278
	building = true -- 279
	local startTime = App.runningTime -- 280
	local luaFiles = { } -- 281
	local yueFiles = { } -- 282
	local xmlFiles = { } -- 283
	local tlFiles = { } -- 284
	local writablePath = Content.writablePath -- 285
	local buildPaths = { -- 287
		{ -- 288
			Path(Content.assetPath), -- 288
			Path(writablePath, ".build"), -- 289
			"" -- 290
		} -- 287
	} -- 286
	for _index_0 = 1, #gamesInDev do -- 293
		local _des_0 = gamesInDev[_index_0] -- 293
		local entryFile = _des_0[2] -- 293
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 294
		buildPaths[#buildPaths + 1] = { -- 296
			Path(writablePath, gamePath), -- 296
			Path(writablePath, ".build", gamePath), -- 297
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 298
			gamePath -- 299
		} -- 295
	end -- 299
	for _index_0 = 1, #buildPaths do -- 300
		local _des_0 = buildPaths[_index_0] -- 300
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 300
		if not Content:exist(inputPath) then -- 301
			goto _continue_0 -- 301
		end -- 301
		local _list_0 = getAllFiles(inputPath, { -- 303
			"lua" -- 303
		}) -- 303
		for _index_1 = 1, #_list_0 do -- 303
			local file = _list_0[_index_1] -- 303
			luaFiles[#luaFiles + 1] = { -- 305
				file, -- 305
				Path(inputPath, file), -- 306
				Path(outputPath, file), -- 307
				gamePath -- 308
			} -- 304
		end -- 308
		local _list_1 = getAllFiles(inputPath, { -- 310
			yueext -- 310
		}) -- 310
		for _index_1 = 1, #_list_1 do -- 310
			local file = _list_1[_index_1] -- 310
			yueFiles[#yueFiles + 1] = { -- 312
				file, -- 312
				Path(inputPath, file), -- 313
				Path(outputPath, Path:replaceExt(file, "lua")), -- 314
				searchPath, -- 315
				gamePath -- 316
			} -- 311
		end -- 316
		local _list_2 = getAllFiles(inputPath, { -- 318
			"xml" -- 318
		}) -- 318
		for _index_1 = 1, #_list_2 do -- 318
			local file = _list_2[_index_1] -- 318
			xmlFiles[#xmlFiles + 1] = { -- 320
				file, -- 320
				Path(inputPath, file), -- 321
				Path(outputPath, Path:replaceExt(file, "lua")), -- 322
				gamePath -- 323
			} -- 319
		end -- 323
		local _list_3 = getAllFiles(inputPath, { -- 325
			"tl" -- 325
		}) -- 325
		for _index_1 = 1, #_list_3 do -- 325
			local file = _list_3[_index_1] -- 325
			if not file:match(".*%.d%.tl$") then -- 326
				tlFiles[#tlFiles + 1] = { -- 328
					file, -- 328
					Path(inputPath, file), -- 329
					Path(outputPath, Path:replaceExt(file, "lua")), -- 330
					searchPath, -- 331
					gamePath -- 332
				} -- 327
			end -- 326
		end -- 332
		::_continue_0:: -- 301
	end -- 332
	local paths -- 334
	do -- 334
		local _tbl_0 = { } -- 334
		local _list_0 = { -- 335
			luaFiles, -- 335
			yueFiles, -- 335
			xmlFiles, -- 335
			tlFiles -- 335
		} -- 335
		for _index_0 = 1, #_list_0 do -- 335
			local files = _list_0[_index_0] -- 335
			for _index_1 = 1, #files do -- 336
				local file = files[_index_1] -- 336
				_tbl_0[Path:getPath(file[3])] = true -- 334
			end -- 334
		end -- 334
		paths = _tbl_0 -- 334
	end -- 336
	for path in pairs(paths) do -- 338
		Content:mkdir(path) -- 338
	end -- 338
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 340
	local fileCount = 0 -- 341
	local errors = { } -- 342
	for _index_0 = 1, #yueFiles do -- 343
		local _des_0 = yueFiles[_index_0] -- 343
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 343
		local filename -- 344
		if gamePath then -- 344
			filename = Path(gamePath, file) -- 344
		else -- 344
			filename = file -- 344
		end -- 344
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 345
			if not codes then -- 346
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 347
				return -- 348
			end -- 346
			local success, result = LintYueGlobals(codes, globals) -- 349
			if success then -- 350
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 351
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 352
				codes = codes:gsub("^\n*", "") -- 353
				if not (result == "") then -- 354
					result = result .. "\n" -- 354
				end -- 354
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 355
			else -- 357
				local yueCodes = Content:load(input) -- 357
				if yueCodes then -- 357
					local globalErrors = { } -- 358
					for _index_1 = 1, #result do -- 359
						local _des_1 = result[_index_1] -- 359
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 359
						local countLine = 1 -- 360
						local code = "" -- 361
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 362
							if countLine == line then -- 363
								code = lineCode -- 364
								break -- 365
							end -- 363
							countLine = countLine + 1 -- 366
						end -- 366
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 367
					end -- 367
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 368
				else -- 370
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 370
				end -- 357
			end -- 350
		end, function(success) -- 345
			if success then -- 371
				print("Yue compiled: " .. tostring(filename)) -- 371
			end -- 371
			fileCount = fileCount + 1 -- 372
		end) -- 345
	end -- 372
	thread(function() -- 374
		for _index_0 = 1, #xmlFiles do -- 375
			local _des_0 = xmlFiles[_index_0] -- 375
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 375
			local filename -- 376
			if gamePath then -- 376
				filename = Path(gamePath, file) -- 376
			else -- 376
				filename = file -- 376
			end -- 376
			local sourceCodes = Content:loadAsync(input) -- 377
			local codes, err = xml.tolua(sourceCodes) -- 378
			if not codes then -- 379
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 380
			else -- 382
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 382
				print("Xml compiled: " .. tostring(filename)) -- 383
			end -- 379
			fileCount = fileCount + 1 -- 384
		end -- 384
	end) -- 374
	thread(function() -- 386
		for _index_0 = 1, #tlFiles do -- 387
			local _des_0 = tlFiles[_index_0] -- 387
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 387
			local filename -- 388
			if gamePath then -- 388
				filename = Path(gamePath, file) -- 388
			else -- 388
				filename = file -- 388
			end -- 388
			local sourceCodes = Content:loadAsync(input) -- 389
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 390
			if not codes then -- 391
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 392
			else -- 394
				Content:saveAsync(output, codes) -- 394
				print("Teal compiled: " .. tostring(filename)) -- 395
			end -- 391
			fileCount = fileCount + 1 -- 396
		end -- 396
	end) -- 386
	return thread(function() -- 398
		wait(function() -- 399
			return fileCount == totalFiles -- 399
		end) -- 399
		if minify then -- 400
			local _list_0 = { -- 401
				yueFiles, -- 401
				xmlFiles, -- 401
				tlFiles -- 401
			} -- 401
			for _index_0 = 1, #_list_0 do -- 401
				local files = _list_0[_index_0] -- 401
				for _index_1 = 1, #files do -- 401
					local file = files[_index_1] -- 401
					local output = Path:replaceExt(file[3], "lua") -- 402
					luaFiles[#luaFiles + 1] = { -- 404
						Path:replaceExt(file[1], "lua"), -- 404
						output, -- 405
						output -- 406
					} -- 403
				end -- 406
			end -- 406
			local FormatMini -- 408
			do -- 408
				local _obj_0 = require("luaminify") -- 408
				FormatMini = _obj_0.FormatMini -- 408
			end -- 408
			for _index_0 = 1, #luaFiles do -- 409
				local _des_0 = luaFiles[_index_0] -- 409
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 409
				if Content:exist(input) then -- 410
					local sourceCodes = Content:loadAsync(input) -- 411
					local res, err = FormatMini(sourceCodes) -- 412
					if res then -- 413
						Content:saveAsync(output, res) -- 414
						print("Minify: " .. tostring(file)) -- 415
					else -- 417
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 417
					end -- 413
				else -- 419
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 419
				end -- 410
			end -- 419
			package.loaded["luaminify.FormatMini"] = nil -- 420
			package.loaded["luaminify.ParseLua"] = nil -- 421
			package.loaded["luaminify.Scope"] = nil -- 422
			package.loaded["luaminify.Util"] = nil -- 423
		end -- 400
		local errorMessage = table.concat(errors, "\n") -- 424
		if errorMessage ~= "" then -- 425
			print("\n" .. errorMessage) -- 425
		end -- 425
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 426
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 427
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 428
		Content:clearPathCache() -- 429
		teal.clear() -- 430
		yue.clear() -- 431
		building = false -- 432
	end) -- 432
end -- 277
local doClean -- 434
doClean = function() -- 434
	if building then -- 435
		return -- 435
	end -- 435
	local writablePath = Content.writablePath -- 436
	local targetDir = Path(writablePath, ".build") -- 437
	Content:clearPathCache() -- 438
	if Content:remove(targetDir) then -- 439
		print("Cleaned: " .. tostring(targetDir)) -- 440
	end -- 439
	Content:remove(Path(writablePath, ".upload")) -- 441
	return Content:remove(Path(writablePath, ".download")) -- 442
end -- 434
local screenScale = 2.0 -- 444
local scaleContent = false -- 445
local isInEntry = true -- 446
local currentEntry = nil -- 447
local footerWindow = nil -- 449
local entryWindow = nil -- 450
local setupEventHandlers = nil -- 452
local allClear -- 454
allClear = function() -- 454
	local _list_0 = Routine -- 455
	for _index_0 = 1, #_list_0 do -- 455
		local routine = _list_0[_index_0] -- 455
		if footerWindow == routine or entryWindow == routine then -- 457
			goto _continue_0 -- 458
		else -- 460
			Routine:remove(routine) -- 460
		end -- 460
		::_continue_0:: -- 456
	end -- 460
	for _index_0 = 1, #moduleCache do -- 461
		local module = moduleCache[_index_0] -- 461
		package.loaded[module] = nil -- 462
	end -- 462
	moduleCache = { } -- 463
	Director:cleanup() -- 464
	Cache:unload() -- 465
	Entity:clear() -- 466
	Platformer.Data:clear() -- 467
	Platformer.UnitAction:clear() -- 468
	Audio:stopStream(0.5) -- 469
	Struct:clear() -- 470
	View.postEffect = nil -- 471
	View.scale = scaleContent and screenScale or 1 -- 472
	Director.clearColor = Color(0xff1a1a1a) -- 473
	teal.clear() -- 474
	yue.clear() -- 475
	for _, item in pairs(ubox()) do -- 476
		local node = tolua.cast(item, "Node") -- 477
		if node then -- 477
			node:cleanup() -- 477
		end -- 477
	end -- 477
	collectgarbage() -- 478
	collectgarbage() -- 479
	setupEventHandlers() -- 480
	Content.searchPaths = searchPaths -- 481
	App.idled = true -- 482
	return Wasm:clear() -- 483
end -- 454
_module_0["allClear"] = allClear -- 483
setupEventHandlers = function() -- 485
	local _with_0 = Director.postNode -- 486
	_with_0:gslot("AppQuit", allClear) -- 487
	_with_0:gslot("AppTheme", function(argb) -- 488
		config.themeColor = argb -- 489
	end) -- 488
	_with_0:gslot("AppLocale", function(locale) -- 490
		config.locale = locale -- 491
		updateLocale() -- 492
		return teal.clear(true) -- 493
	end) -- 490
	_with_0:gslot("AppWSClose", function() -- 494
		if HttpServer.wsConnectionCount == 0 then -- 495
			return updateEntries() -- 496
		end -- 495
	end) -- 494
	local _exp_0 = App.platform -- 497
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 497
		_with_0:gslot("AppSizeChanged", function() -- 498
			local width, height -- 499
			do -- 499
				local _obj_0 = App.winSize -- 499
				width, height = _obj_0.width, _obj_0.height -- 499
			end -- 499
			config.winWidth = width -- 500
			config.winHeight = height -- 501
		end) -- 498
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 502
			config.fullScreen = fullScreen and 1 or 0 -- 503
		end) -- 502
		_with_0:gslot("AppMoved", function() -- 504
			local _obj_0 = App.winPosition -- 505
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 505
		end) -- 504
	end -- 505
	return _with_0 -- 486
end -- 485
setupEventHandlers() -- 507
local stop -- 509
stop = function() -- 509
	if isInEntry then -- 510
		return false -- 510
	end -- 510
	allClear() -- 511
	isInEntry = true -- 512
	currentEntry = nil -- 513
	return true -- 514
end -- 509
_module_0["stop"] = stop -- 514
local _anon_func_0 = function(Content, Path, file, require, type) -- 536
	local scriptPath = Path:getPath(file) -- 529
	Content:insertSearchPath(1, scriptPath) -- 530
	scriptPath = Path(scriptPath, "Script") -- 531
	if Content:exist(scriptPath) then -- 532
		Content:insertSearchPath(1, scriptPath) -- 533
	end -- 532
	local result = require(file) -- 534
	if "function" == type(result) then -- 535
		result() -- 535
	end -- 535
	return nil -- 536
end -- 529
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 568
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 565
	label.alignment = "Left" -- 566
	label.textWidth = width - fontSize -- 567
	label.text = err -- 568
	return label -- 565
end -- 565
local enterEntryAsync -- 516
enterEntryAsync = function(entry) -- 516
	isInEntry = false -- 517
	App.idled = false -- 518
	emit(Profiler.EventName, "ClearLoader") -- 519
	currentEntry = entry -- 520
	local name, file = entry[1], entry[2] -- 521
	if cppTestSet[entry] then -- 522
		if App:runTest(name) then -- 523
			return true -- 524
		else -- 526
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 526
		end -- 523
	end -- 522
	sleep() -- 527
	return xpcall(_anon_func_0, function(msg) -- 536
		local err = debug.traceback(msg) -- 538
		allClear() -- 539
		print(err) -- 540
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 541
		local viewWidth, viewHeight -- 542
		do -- 542
			local _obj_0 = View.size -- 542
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 542
		end -- 542
		local width, height = viewWidth - 20, viewHeight - 20 -- 543
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 544
		Director.ui:addChild((function() -- 545
			local root = AlignNode() -- 545
			do -- 546
				local _obj_0 = App.bufferSize -- 546
				width, height = _obj_0.width, _obj_0.height -- 546
			end -- 546
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 547
			root:gslot("AppSizeChanged", function() -- 548
				do -- 549
					local _obj_0 = App.bufferSize -- 549
					width, height = _obj_0.width, _obj_0.height -- 549
				end -- 549
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 550
			end) -- 548
			root:addChild((function() -- 551
				local _with_0 = ScrollArea({ -- 552
					width = width, -- 552
					height = height, -- 553
					paddingX = 0, -- 554
					paddingY = 50, -- 555
					viewWidth = height, -- 556
					viewHeight = height -- 557
				}) -- 551
				root:slot("AlignLayout", function(w, h) -- 559
					_with_0.position = Vec2(w / 2, h / 2) -- 560
					w = w - 20 -- 561
					h = h - 20 -- 562
					_with_0.view.children.first.textWidth = w - fontSize -- 563
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 564
				end) -- 559
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 565
				return _with_0 -- 551
			end)()) -- 551
			return root -- 545
		end)()) -- 545
		return err -- 569
	end, Content, Path, file, require, type) -- 569
end -- 516
_module_0["enterEntryAsync"] = enterEntryAsync -- 569
local enterDemoEntry -- 571
enterDemoEntry = function(entry) -- 571
	return thread(function() -- 571
		return enterEntryAsync(entry) -- 571
	end) -- 571
end -- 571
local reloadCurrentEntry -- 573
reloadCurrentEntry = function() -- 573
	if currentEntry then -- 574
		allClear() -- 575
		return enterDemoEntry(currentEntry) -- 576
	end -- 574
end -- 573
Director.clearColor = Color(0xff1a1a1a) -- 578
local waitForWebStart = true -- 580
thread(function() -- 581
	sleep(2) -- 582
	waitForWebStart = false -- 583
end) -- 581
local reloadDevEntry -- 585
reloadDevEntry = function() -- 585
	return thread(function() -- 585
		waitForWebStart = true -- 586
		doClean() -- 587
		allClear() -- 588
		_G.require = oldRequire -- 589
		Dora.require = oldRequire -- 590
		package.loaded["Script.Dev.Entry"] = nil -- 591
		return Director.systemScheduler:schedule(function() -- 592
			Routine:clear() -- 593
			oldRequire("Script.Dev.Entry") -- 594
			return true -- 595
		end) -- 595
	end) -- 595
end -- 585
local isOSSLicenseExist = Content:exist("LICENSES") -- 597
local ossLicenses = nil -- 598
local ossLicenseOpen = false -- 599
local extraOperations -- 601
extraOperations = function() -- 601
	local zh = useChinese and isChineseSupported -- 602
	if isOSSLicenseExist then -- 603
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 604
			if not ossLicenses then -- 605
				ossLicenses = { } -- 606
				local licenseText = Content:load("LICENSES") -- 607
				ossLicenseOpen = (licenseText ~= nil) -- 608
				if ossLicenseOpen then -- 608
					licenseText = licenseText:gsub("\r\n", "\n") -- 609
					for license in GSplit(licenseText, "\n--------\n", true) do -- 610
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 611
						if name then -- 611
							ossLicenses[#ossLicenses + 1] = { -- 612
								name, -- 612
								text -- 612
							} -- 612
						end -- 611
					end -- 612
				end -- 608
			else -- 614
				ossLicenseOpen = true -- 614
			end -- 605
		end -- 604
		if ossLicenseOpen then -- 615
			local width, height, themeColor -- 616
			do -- 616
				local _obj_0 = App -- 616
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 616
			end -- 616
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 617
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 618
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 619
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 622
					"NoSavedSettings" -- 622
				}, function() -- 623
					for _index_0 = 1, #ossLicenses do -- 623
						local _des_0 = ossLicenses[_index_0] -- 623
						local firstLine, text = _des_0[1], _des_0[2] -- 623
						local name, license = firstLine:match("(.+): (.+)") -- 624
						TextColored(themeColor, name) -- 625
						SameLine() -- 626
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 627
							return TextWrapped(text) -- 627
						end) -- 627
					end -- 627
				end) -- 619
			end) -- 619
		end -- 615
	end -- 603
	if not App.debugging then -- 629
		return -- 629
	end -- 629
	return TreeNode(zh and "开发操作" or "Development", function() -- 630
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 631
			OpenPopup("build") -- 631
		end -- 631
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 632
			return BeginPopup("build", function() -- 632
				if Selectable(zh and "编译" or "Compile") then -- 633
					doCompile(false) -- 633
				end -- 633
				Separator() -- 634
				if Selectable(zh and "压缩" or "Minify") then -- 635
					doCompile(true) -- 635
				end -- 635
				Separator() -- 636
				if Selectable(zh and "清理" or "Clean") then -- 637
					return doClean() -- 637
				end -- 637
			end) -- 637
		end) -- 632
		if isInEntry then -- 638
			if waitForWebStart then -- 639
				BeginDisabled(function() -- 640
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 640
				end) -- 640
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 641
				reloadDevEntry() -- 642
			end -- 639
		end -- 638
		do -- 643
			local changed -- 643
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 643
			if changed then -- 643
				View.scale = scaleContent and screenScale or 1 -- 644
			end -- 643
		end -- 643
		local changed -- 645
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 645
		if changed then -- 645
			config.engineDev = engineDev and 1 or 0 -- 646
		end -- 645
	end) -- 630
end -- 601
local transparant = Color(0x0) -- 648
local windowFlags = { -- 650
	"NoTitleBar", -- 650
	"NoResize", -- 651
	"NoMove", -- 652
	"NoCollapse", -- 653
	"NoSavedSettings", -- 654
	"NoBringToFrontOnFocus" -- 655
} -- 649
local initFooter = true -- 656
local _anon_func_2 = function(allEntries, currentIndex) -- 692
	if currentIndex > 1 then -- 692
		return allEntries[currentIndex - 1] -- 693
	else -- 695
		return allEntries[#allEntries] -- 695
	end -- 692
end -- 692
local _anon_func_3 = function(allEntries, currentIndex) -- 699
	if currentIndex < #allEntries then -- 699
		return allEntries[currentIndex + 1] -- 700
	else -- 702
		return allEntries[1] -- 702
	end -- 699
end -- 699
footerWindow = threadLoop(function() -- 657
	local zh = useChinese and isChineseSupported -- 658
	if HttpServer.wsConnectionCount > 0 then -- 659
		return -- 660
	end -- 659
	if Keyboard:isKeyDown("Escape") then -- 661
		allClear() -- 662
		App:shutdown() -- 663
	end -- 661
	do -- 664
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 665
		if ctrl and Keyboard:isKeyDown("Q") then -- 666
			stop() -- 667
		end -- 666
		if ctrl and Keyboard:isKeyDown("Z") then -- 668
			reloadCurrentEntry() -- 669
		end -- 668
		if ctrl and Keyboard:isKeyDown(",") then -- 670
			if showFooter then -- 671
				showStats = not showStats -- 671
			else -- 671
				showStats = true -- 671
			end -- 671
			showFooter = true -- 672
			config.showFooter = showFooter and 1 or 0 -- 673
			config.showStats = showStats and 1 or 0 -- 674
		end -- 670
		if ctrl and Keyboard:isKeyDown(".") then -- 675
			if showFooter then -- 676
				showConsole = not showConsole -- 676
			else -- 676
				showConsole = true -- 676
			end -- 676
			showFooter = true -- 677
			config.showFooter = showFooter and 1 or 0 -- 678
			config.showConsole = showConsole and 1 or 0 -- 679
		end -- 675
		if ctrl and Keyboard:isKeyDown("/") then -- 680
			showFooter = not showFooter -- 681
			config.showFooter = showFooter and 1 or 0 -- 682
		end -- 680
		local left = ctrl and Keyboard:isKeyDown("Left") -- 683
		local right = ctrl and Keyboard:isKeyDown("Right") -- 684
		local currentIndex = nil -- 685
		for i, entry in ipairs(allEntries) do -- 686
			if currentEntry == entry then -- 687
				currentIndex = i -- 688
			end -- 687
		end -- 688
		if left then -- 689
			allClear() -- 690
			if currentIndex == nil then -- 691
				currentIndex = #allEntries + 1 -- 691
			end -- 691
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 692
		end -- 689
		if right then -- 696
			allClear() -- 697
			if currentIndex == nil then -- 698
				currentIndex = 0 -- 698
			end -- 698
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 699
		end -- 696
	end -- 702
	if not showEntry then -- 703
		return -- 703
	end -- 703
	local width, height -- 705
	do -- 705
		local _obj_0 = App.visualSize -- 705
		width, height = _obj_0.width, _obj_0.height -- 705
	end -- 705
	SetNextWindowSize(Vec2(50, 50)) -- 706
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 707
	PushStyleColor("WindowBg", transparant, function() -- 708
		return Begin("Show", windowFlags, function() -- 708
			if isInEntry or width >= 540 then -- 709
				local changed -- 710
				changed, showFooter = Checkbox("##dev", showFooter) -- 710
				if changed then -- 710
					config.showFooter = showFooter and 1 or 0 -- 711
				end -- 710
			end -- 709
		end) -- 711
	end) -- 708
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 713
		reloadDevEntry() -- 717
	end -- 713
	if initFooter then -- 718
		initFooter = false -- 719
	else -- 721
		if not showFooter then -- 721
			return -- 721
		end -- 721
	end -- 718
	SetNextWindowSize(Vec2(width, 50)) -- 723
	SetNextWindowPos(Vec2(0, height - 50)) -- 724
	SetNextWindowBgAlpha(0.35) -- 725
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 726
		return Begin("Footer", windowFlags, function() -- 726
			Dummy(Vec2(width - 20, 0)) -- 727
			do -- 728
				local changed -- 728
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 728
				if changed then -- 728
					config.showStats = showStats and 1 or 0 -- 729
				end -- 728
			end -- 728
			SameLine() -- 730
			do -- 731
				local changed -- 731
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 731
				if changed then -- 731
					config.showConsole = showConsole and 1 or 0 -- 732
				end -- 731
			end -- 731
			if not isInEntry then -- 733
				SameLine() -- 734
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 735
					allClear() -- 736
					isInEntry = true -- 737
					currentEntry = nil -- 738
				end -- 735
				local currentIndex = nil -- 739
				for i, entry in ipairs(allEntries) do -- 740
					if currentEntry == entry then -- 741
						currentIndex = i -- 742
					end -- 741
				end -- 742
				if currentIndex then -- 743
					if currentIndex > 1 then -- 744
						SameLine() -- 745
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 746
							allClear() -- 747
							enterDemoEntry(allEntries[currentIndex - 1]) -- 748
						end -- 746
					end -- 744
					if currentIndex < #allEntries then -- 749
						SameLine() -- 750
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 751
							allClear() -- 752
							enterDemoEntry(allEntries[currentIndex + 1]) -- 753
						end -- 751
					end -- 749
				end -- 743
				SameLine() -- 754
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 755
					reloadCurrentEntry() -- 756
				end -- 755
			end -- 733
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 757
				if showStats then -- 758
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 759
					showStats = ShowStats(showStats, extraOperations) -- 760
					config.showStats = showStats and 1 or 0 -- 761
				end -- 758
				if showConsole then -- 762
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 763
					showConsole = ShowConsole(showConsole) -- 764
					config.showConsole = showConsole and 1 or 0 -- 765
				end -- 762
			end) -- 765
		end) -- 765
	end) -- 765
end) -- 657
local MaxWidth <const> = 800 -- 767
local displayWindowFlags = { -- 770
	"NoDecoration", -- 770
	"NoSavedSettings", -- 771
	"NoFocusOnAppearing", -- 772
	"NoNav", -- 773
	"NoMove", -- 774
	"NoScrollWithMouse", -- 775
	"AlwaysAutoResize", -- 776
	"NoBringToFrontOnFocus" -- 777
} -- 769
local webStatus = nil -- 779
local descColor = Color(0xffa1a1a1) -- 780
local gameOpen = #gamesInDev == 0 -- 781
local exampleOpen = false -- 782
local testOpen = false -- 783
local filterText = nil -- 784
local anyEntryMatched = false -- 785
local urlClicked = nil -- 786
local match -- 787
match = function(name) -- 787
	local res = not filterText or name:lower():match(filterText) -- 788
	if res then -- 789
		anyEntryMatched = true -- 789
	end -- 789
	return res -- 790
end -- 787
entryWindow = threadLoop(function() -- 792
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 793
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 794
	end -- 793
	if App.targetFPS ~= config.targetFPS then -- 795
		config.targetFPS = App.targetFPS -- 796
	end -- 795
	if View.vsync ~= (config.vsync == 1) then -- 797
		config.vsync = View.vsync and 1 or 0 -- 798
	end -- 797
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 799
		config.fixedFPS = Director.scheduler.fixedFPS -- 800
	end -- 799
	if Director.profilerSending ~= (config.webProfiler == 1) then -- 801
		config.webProfiler = Director.profilerSending and 1 or 0 -- 802
	end -- 801
	if urlClicked then -- 803
		local _, result = coroutine.resume(urlClicked) -- 804
		if result then -- 805
			coroutine.close(urlClicked) -- 806
			urlClicked = nil -- 807
		end -- 805
	end -- 803
	if not showEntry then -- 808
		return -- 808
	end -- 808
	if not isInEntry then -- 809
		return -- 809
	end -- 809
	local zh = useChinese and isChineseSupported -- 810
	if HttpServer.wsConnectionCount > 0 then -- 811
		local themeColor = App.themeColor -- 812
		local width, height -- 813
		do -- 813
			local _obj_0 = App.visualSize -- 813
			width, height = _obj_0.width, _obj_0.height -- 813
		end -- 813
		SetNextWindowBgAlpha(0.5) -- 814
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 815
		Begin("Web IDE Connected", displayWindowFlags, function() -- 816
			Separator() -- 817
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 818
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 819
			TextColored(descColor, slogon) -- 820
			return Separator() -- 821
		end) -- 816
		return -- 822
	end -- 811
	local themeColor = App.themeColor -- 824
	local fullWidth, height -- 825
	do -- 825
		local _obj_0 = App.visualSize -- 825
		fullWidth, height = _obj_0.width, _obj_0.height -- 825
	end -- 825
	SetNextWindowBgAlpha(0.85) -- 827
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 828
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 829
		return Begin("Web IDE", displayWindowFlags, function() -- 830
			Separator() -- 831
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 832
			do -- 833
				local url -- 833
				if webStatus ~= nil then -- 833
					url = webStatus.url -- 833
				end -- 833
				if url then -- 833
					if isDesktop then -- 834
						if urlClicked then -- 835
							BeginDisabled(function() -- 836
								return Button(url) -- 836
							end) -- 836
						elseif Button(url) then -- 837
							urlClicked = once(function() -- 838
								return sleep(5) -- 838
							end) -- 838
							App:openURL(url) -- 839
						end -- 835
					else -- 841
						TextColored(descColor, url) -- 841
					end -- 834
				else -- 843
					TextColored(descColor, zh and '不可用' or 'not available') -- 843
				end -- 833
			end -- 833
			return Separator() -- 844
		end) -- 844
	end) -- 829
	local width = math.min(MaxWidth, fullWidth) -- 846
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 847
	local maxColumns = math.max(math.floor(width / 200), 1) -- 848
	SetNextWindowPos(Vec2.zero) -- 849
	SetNextWindowBgAlpha(0) -- 850
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 851
		return Begin("Dora Dev", displayWindowFlags, function() -- 852
			Dummy(Vec2(fullWidth - 20, 0)) -- 853
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 854
			SameLine() -- 855
			if fullWidth >= 320 then -- 856
				Dummy(Vec2(fullWidth - 320, 0)) -- 857
				SameLine() -- 858
				SetNextItemWidth(-50) -- 859
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 860
					"AutoSelectAll" -- 860
				}) then -- 860
					config.filter = filterBuf:toString() -- 861
				end -- 860
			end -- 856
			Separator() -- 862
			return Dummy(Vec2(fullWidth - 20, 0)) -- 863
		end) -- 863
	end) -- 851
	anyEntryMatched = false -- 865
	SetNextWindowPos(Vec2(0, 50)) -- 866
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 867
	return PushStyleColor("WindowBg", transparant, function() -- 868
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 868
			return Begin("Content", windowFlags, function() -- 869
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 870
				if filterText then -- 871
					filterText = filterText:lower() -- 871
				end -- 871
				if #gamesInDev > 0 then -- 872
					for _index_0 = 1, #gamesInDev do -- 873
						local game = gamesInDev[_index_0] -- 873
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 874
						local showSep = false -- 875
						if match(gameName) then -- 876
							Columns(1, false) -- 877
							TextColored(themeColor, zh and "项目：" or "Project:") -- 878
							SameLine() -- 879
							Text(gameName) -- 880
							Separator() -- 881
							if bannerFile then -- 882
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 883
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 884
								local sizing <const> = 0.8 -- 885
								texHeight = displayWidth * sizing * texHeight / texWidth -- 886
								texWidth = displayWidth * sizing -- 887
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 888
								Dummy(Vec2(padding, 0)) -- 889
								SameLine() -- 890
								PushID(fileName, function() -- 891
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 892
										return enterDemoEntry(game) -- 893
									end -- 892
								end) -- 891
							else -- 895
								PushID(fileName, function() -- 895
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 896
										return enterDemoEntry(game) -- 897
									end -- 896
								end) -- 895
							end -- 882
							NextColumn() -- 898
							showSep = true -- 899
						end -- 876
						if #examples > 0 then -- 900
							local showExample = false -- 901
							for _index_1 = 1, #examples do -- 902
								local example = examples[_index_1] -- 902
								if match(example[1]) then -- 903
									showExample = true -- 904
									break -- 905
								end -- 903
							end -- 905
							if showExample then -- 906
								Columns(1, false) -- 907
								TextColored(themeColor, zh and "示例：" or "Example:") -- 908
								SameLine() -- 909
								Text(gameName) -- 910
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 911
									Columns(maxColumns, false) -- 912
									for _index_1 = 1, #examples do -- 913
										local example = examples[_index_1] -- 913
										if not match(example[1]) then -- 914
											goto _continue_0 -- 914
										end -- 914
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 915
											if Button(example[1], Vec2(-1, 40)) then -- 916
												enterDemoEntry(example) -- 917
											end -- 916
											return NextColumn() -- 918
										end) -- 915
										showSep = true -- 919
										::_continue_0:: -- 914
									end -- 919
								end) -- 911
							end -- 906
						end -- 900
						if #tests > 0 then -- 920
							local showTest = false -- 921
							for _index_1 = 1, #tests do -- 922
								local test = tests[_index_1] -- 922
								if match(test[1]) then -- 923
									showTest = true -- 924
									break -- 925
								end -- 923
							end -- 925
							if showTest then -- 926
								Columns(1, false) -- 927
								TextColored(themeColor, zh and "测试：" or "Test:") -- 928
								SameLine() -- 929
								Text(gameName) -- 930
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 931
									Columns(maxColumns, false) -- 932
									for _index_1 = 1, #tests do -- 933
										local test = tests[_index_1] -- 933
										if not match(test[1]) then -- 934
											goto _continue_0 -- 934
										end -- 934
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 935
											if Button(test[1], Vec2(-1, 40)) then -- 936
												enterDemoEntry(test) -- 937
											end -- 936
											return NextColumn() -- 938
										end) -- 935
										showSep = true -- 939
										::_continue_0:: -- 934
									end -- 939
								end) -- 931
							end -- 926
						end -- 920
						if showSep then -- 940
							Columns(1, false) -- 941
							Separator() -- 942
						end -- 940
					end -- 942
				end -- 872
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 943
					local showGame = false -- 944
					for _index_0 = 1, #games do -- 945
						local _des_0 = games[_index_0] -- 945
						local name = _des_0[1] -- 945
						if match(name) then -- 946
							showGame = true -- 946
						end -- 946
					end -- 946
					local showExample = false -- 947
					for _index_0 = 1, #doraExamples do -- 948
						local _des_0 = doraExamples[_index_0] -- 948
						local name = _des_0[1] -- 948
						if match(name) then -- 949
							showExample = true -- 949
						end -- 949
					end -- 949
					local showTest = false -- 950
					for _index_0 = 1, #doraTests do -- 951
						local _des_0 = doraTests[_index_0] -- 951
						local name = _des_0[1] -- 951
						if match(name) then -- 952
							showTest = true -- 952
						end -- 952
					end -- 952
					for _index_0 = 1, #cppTests do -- 953
						local _des_0 = cppTests[_index_0] -- 953
						local name = _des_0[1] -- 953
						if match(name) then -- 954
							showTest = true -- 954
						end -- 954
					end -- 954
					if not (showGame or showExample or showTest) then -- 955
						goto endEntry -- 955
					end -- 955
					Columns(1, false) -- 956
					TextColored(themeColor, "Dora SSR:") -- 957
					SameLine() -- 958
					Text(zh and "开发示例" or "Development Showcase") -- 959
					Separator() -- 960
					local demoViewWith <const> = 400 -- 961
					if #games > 0 and showGame then -- 962
						local opened -- 963
						if (filterText ~= nil) then -- 963
							opened = showGame -- 963
						else -- 963
							opened = false -- 963
						end -- 963
						SetNextItemOpen(gameOpen) -- 964
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 965
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 966
							Columns(columns, false) -- 967
							for _index_0 = 1, #games do -- 968
								local game = games[_index_0] -- 968
								if not match(game[1]) then -- 969
									goto _continue_0 -- 969
								end -- 969
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 970
								if columns > 1 then -- 971
									if bannerFile then -- 972
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 973
										local displayWidth <const> = demoViewWith - 40 -- 974
										texHeight = displayWidth * texHeight / texWidth -- 975
										texWidth = displayWidth -- 976
										Text(gameName) -- 977
										PushID(fileName, function() -- 978
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 979
												return enterDemoEntry(game) -- 980
											end -- 979
										end) -- 978
									else -- 982
										PushID(fileName, function() -- 982
											if Button(gameName, Vec2(-1, 40)) then -- 983
												return enterDemoEntry(game) -- 984
											end -- 983
										end) -- 982
									end -- 972
								else -- 986
									if bannerFile then -- 986
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 987
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 988
										local sizing = 0.8 -- 989
										texHeight = displayWidth * sizing * texHeight / texWidth -- 990
										texWidth = displayWidth * sizing -- 991
										if texWidth > 500 then -- 992
											sizing = 0.6 -- 993
											texHeight = displayWidth * sizing * texHeight / texWidth -- 994
											texWidth = displayWidth * sizing -- 995
										end -- 992
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 996
										Dummy(Vec2(padding, 0)) -- 997
										SameLine() -- 998
										Text(gameName) -- 999
										Dummy(Vec2(padding, 0)) -- 1000
										SameLine() -- 1001
										PushID(fileName, function() -- 1002
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1003
												return enterDemoEntry(game) -- 1004
											end -- 1003
										end) -- 1002
									else -- 1006
										PushID(fileName, function() -- 1006
											if Button(gameName, Vec2(-1, 40)) then -- 1007
												return enterDemoEntry(game) -- 1008
											end -- 1007
										end) -- 1006
									end -- 986
								end -- 971
								NextColumn() -- 1009
								::_continue_0:: -- 969
							end -- 1009
							Columns(1, false) -- 1010
							opened = true -- 1011
						end) -- 965
						gameOpen = opened -- 1012
					end -- 962
					if #doraExamples > 0 and showExample then -- 1013
						local opened -- 1014
						if (filterText ~= nil) then -- 1014
							opened = showExample -- 1014
						else -- 1014
							opened = false -- 1014
						end -- 1014
						SetNextItemOpen(exampleOpen) -- 1015
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1016
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1017
								Columns(maxColumns, false) -- 1018
								for _index_0 = 1, #doraExamples do -- 1019
									local example = doraExamples[_index_0] -- 1019
									if not match(example[1]) then -- 1020
										goto _continue_0 -- 1020
									end -- 1020
									if Button(example[1], Vec2(-1, 40)) then -- 1021
										enterDemoEntry(example) -- 1022
									end -- 1021
									NextColumn() -- 1023
									::_continue_0:: -- 1020
								end -- 1023
								Columns(1, false) -- 1024
								opened = true -- 1025
							end) -- 1017
						end) -- 1016
						exampleOpen = opened -- 1026
					end -- 1013
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1027
						local opened -- 1028
						if (filterText ~= nil) then -- 1028
							opened = showTest -- 1028
						else -- 1028
							opened = false -- 1028
						end -- 1028
						SetNextItemOpen(testOpen) -- 1029
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1030
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1031
								Columns(maxColumns, false) -- 1032
								for _index_0 = 1, #doraTests do -- 1033
									local test = doraTests[_index_0] -- 1033
									if not match(test[1]) then -- 1034
										goto _continue_0 -- 1034
									end -- 1034
									if Button(test[1], Vec2(-1, 40)) then -- 1035
										enterDemoEntry(test) -- 1036
									end -- 1035
									NextColumn() -- 1037
									::_continue_0:: -- 1034
								end -- 1037
								for _index_0 = 1, #cppTests do -- 1038
									local test = cppTests[_index_0] -- 1038
									if not match(test[1]) then -- 1039
										goto _continue_1 -- 1039
									end -- 1039
									if Button(test[1], Vec2(-1, 40)) then -- 1040
										enterDemoEntry(test) -- 1041
									end -- 1040
									NextColumn() -- 1042
									::_continue_1:: -- 1039
								end -- 1042
								opened = true -- 1043
							end) -- 1031
						end) -- 1030
						testOpen = opened -- 1044
					end -- 1027
				end -- 943
				::endEntry:: -- 1045
				if not anyEntryMatched then -- 1046
					SetNextWindowBgAlpha(0) -- 1047
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1048
					Begin("Entries Not Found", displayWindowFlags, function() -- 1049
						Separator() -- 1050
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1051
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1052
						return Separator() -- 1053
					end) -- 1049
				end -- 1046
				Columns(1, false) -- 1054
				Dummy(Vec2(100, 80)) -- 1055
				return ScrollWhenDraggingOnVoid() -- 1056
			end) -- 1056
		end) -- 1056
	end) -- 1056
end) -- 792
webStatus = require("Script.Dev.WebServer") -- 1058
return _module_0 -- 1058
