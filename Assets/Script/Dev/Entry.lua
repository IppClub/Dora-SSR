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
if (function() -- 85
	local _val_0 = App.platform -- 85
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 85
end)() then -- 85
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 86
		App.winSize = Size.zero -- 87
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 88
		local size = Size(config.winWidth, config.winHeight) -- 89
		if App.winSize ~= size then -- 90
			App.winSize = size -- 91
			showEntry = false -- 92
			thread(function() -- 93
				sleep() -- 94
				sleep() -- 95
				showEntry = true -- 96
			end) -- 93
		end -- 90
		local winX, winY -- 97
		do -- 97
			local _obj_0 = App.winPosition -- 97
			winX, winY = _obj_0.x, _obj_0.y -- 97
		end -- 97
		if (config.winX ~= nil) then -- 98
			winX = config.winX -- 99
		else -- 101
			config.winX = 0 -- 101
		end -- 98
		if (config.winY ~= nil) then -- 102
			winY = config.winY -- 103
		else -- 105
			config.winY = 0 -- 105
		end -- 102
		App.winPosition = Vec2(winX, winY) -- 106
	end -- 86
end -- 85
if (config.themeColor ~= nil) then -- 108
	App.themeColor = Color(config.themeColor) -- 109
else -- 111
	config.themeColor = App.themeColor:toARGB() -- 111
end -- 108
if not (config.locale ~= nil) then -- 113
	config.locale = App.locale -- 114
end -- 113
local showStats = false -- 116
if (config.showStats ~= nil) then -- 117
	showStats = config.showStats > 0 -- 118
else -- 120
	config.showStats = showStats and 1 or 0 -- 120
end -- 117
local showConsole = true -- 122
if (config.showConsole ~= nil) then -- 123
	showConsole = config.showConsole > 0 -- 124
else -- 126
	config.showConsole = showConsole and 1 or 0 -- 126
end -- 123
local showFooter = true -- 128
if (config.showFooter ~= nil) then -- 129
	showFooter = config.showFooter > 0 -- 130
else -- 132
	config.showFooter = showFooter and 1 or 0 -- 132
end -- 129
local filterBuf = Buffer(20) -- 134
if (config.filter ~= nil) then -- 135
	filterBuf:setString(config.filter) -- 136
else -- 138
	config.filter = "" -- 138
end -- 135
local engineDev = false -- 140
if (config.engineDev ~= nil) then -- 141
	engineDev = config.engineDev > 0 -- 142
else -- 144
	config.engineDev = engineDev and 1 or 0 -- 144
end -- 141
if config.webProfiler == nil then -- 146
	config.webProfiler = 1 -- 147
end -- 146
_module_0.getConfig = function() -- 149
	return config -- 149
end -- 149
_module_0.getEngineDev = function() -- 150
	if not App.debugging then -- 151
		return false -- 151
	end -- 151
	return config.engineDev > 0 -- 152
end -- 150
local Set, Struct, LintYueGlobals, GSplit -- 154
do -- 154
	local _obj_0 = require("Utils") -- 154
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 154
end -- 154
local yueext = yue.options.extension -- 155
local isChineseSupported = IsFontLoaded() -- 157
if not isChineseSupported then -- 158
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 159
		isChineseSupported = true -- 160
	end) -- 159
end -- 158
local building = false -- 162
local getAllFiles -- 164
getAllFiles = function(path, exts) -- 164
	local filters = Set(exts) -- 165
	local _accum_0 = { } -- 166
	local _len_0 = 1 -- 166
	local _list_0 = Content:getAllFiles(path) -- 166
	for _index_0 = 1, #_list_0 do -- 166
		local file = _list_0[_index_0] -- 166
		if not filters[Path:getExt(file)] then -- 167
			goto _continue_0 -- 167
		end -- 167
		_accum_0[_len_0] = file -- 168
		_len_0 = _len_0 + 1 -- 168
		::_continue_0:: -- 167
	end -- 168
	return _accum_0 -- 168
end -- 164
local getFileEntries -- 170
getFileEntries = function(path) -- 170
	local entries = { } -- 171
	local _list_0 = getAllFiles(path, { -- 172
		"lua", -- 172
		"xml", -- 172
		yueext, -- 172
		"tl" -- 172
	}) -- 172
	for _index_0 = 1, #_list_0 do -- 172
		local file = _list_0[_index_0] -- 172
		local entryName = Path:getName(file) -- 173
		local entryAdded = false -- 174
		for _index_1 = 1, #entries do -- 175
			local _des_0 = entries[_index_1] -- 175
			local ename = _des_0[1] -- 175
			if entryName == ename then -- 176
				entryAdded = true -- 177
				break -- 178
			end -- 176
		end -- 178
		if entryAdded then -- 179
			goto _continue_0 -- 179
		end -- 179
		local fileName = Path:replaceExt(file, "") -- 180
		fileName = Path(path, fileName) -- 181
		local entry = { -- 182
			entryName, -- 182
			fileName -- 182
		} -- 182
		entries[#entries + 1] = entry -- 183
		::_continue_0:: -- 173
	end -- 183
	table.sort(entries, function(a, b) -- 184
		return a[1] < b[1] -- 184
	end) -- 184
	return entries -- 185
end -- 170
local getProjectEntries -- 187
getProjectEntries = function(path) -- 187
	local entries = { } -- 188
	local _list_0 = Content:getDirs(path) -- 189
	for _index_0 = 1, #_list_0 do -- 189
		local dir = _list_0[_index_0] -- 189
		if dir:match("^%.") then -- 190
			goto _continue_0 -- 190
		end -- 190
		local _list_1 = getAllFiles(Path(path, dir), { -- 191
			"lua", -- 191
			"xml", -- 191
			yueext, -- 191
			"tl", -- 191
			"wasm" -- 191
		}) -- 191
		for _index_1 = 1, #_list_1 do -- 191
			local file = _list_1[_index_1] -- 191
			if "init" == Path:getName(file):lower() then -- 192
				local fileName = Path:replaceExt(file, "") -- 193
				fileName = Path(path, dir, fileName) -- 194
				local entryName = Path:getName(Path:getPath(fileName)) -- 195
				local entryAdded = false -- 196
				for _index_2 = 1, #entries do -- 197
					local _des_0 = entries[_index_2] -- 197
					local ename = _des_0[1] -- 197
					if entryName == ename then -- 198
						entryAdded = true -- 199
						break -- 200
					end -- 198
				end -- 200
				if entryAdded then -- 201
					goto _continue_1 -- 201
				end -- 201
				local examples = { } -- 202
				local tests = { } -- 203
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 204
				if Content:exist(examplePath) then -- 205
					local _list_2 = getFileEntries(examplePath) -- 206
					for _index_2 = 1, #_list_2 do -- 206
						local _des_0 = _list_2[_index_2] -- 206
						local name, ePath = _des_0[1], _des_0[2] -- 206
						local entry = { -- 207
							name, -- 207
							Path(path, dir, Path:getPath(file), ePath) -- 207
						} -- 207
						examples[#examples + 1] = entry -- 208
					end -- 208
				end -- 205
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 209
				if Content:exist(testPath) then -- 210
					local _list_2 = getFileEntries(testPath) -- 211
					for _index_2 = 1, #_list_2 do -- 211
						local _des_0 = _list_2[_index_2] -- 211
						local name, tPath = _des_0[1], _des_0[2] -- 211
						local entry = { -- 212
							name, -- 212
							Path(path, dir, Path:getPath(file), tPath) -- 212
						} -- 212
						tests[#tests + 1] = entry -- 213
					end -- 213
				end -- 210
				local entry = { -- 214
					entryName, -- 214
					fileName, -- 214
					examples, -- 214
					tests -- 214
				} -- 214
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 215
				if not Content:exist(bannerFile) then -- 216
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 217
					if not Content:exist(bannerFile) then -- 218
						bannerFile = nil -- 218
					end -- 218
				end -- 216
				if bannerFile then -- 219
					thread(function() -- 219
						Cache:loadAsync(bannerFile) -- 220
						local bannerTex = Texture2D(bannerFile) -- 221
						if bannerTex then -- 222
							entry[#entry + 1] = bannerFile -- 223
							entry[#entry + 1] = bannerTex -- 224
						end -- 222
					end) -- 219
				end -- 219
				entries[#entries + 1] = entry -- 225
			end -- 192
			::_continue_1:: -- 192
		end -- 225
		::_continue_0:: -- 190
	end -- 225
	table.sort(entries, function(a, b) -- 226
		return a[1] < b[1] -- 226
	end) -- 226
	return entries -- 227
end -- 187
local gamesInDev, games -- 229
local doraExamples, doraTests -- 230
local cppTests, cppTestSet -- 231
local allEntries -- 232
local updateEntries -- 234
updateEntries = function() -- 234
	gamesInDev = getProjectEntries(Content.writablePath) -- 235
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 236
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 238
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 239
	cppTests = { } -- 241
	local _list_0 = App.testNames -- 242
	for _index_0 = 1, #_list_0 do -- 242
		local name = _list_0[_index_0] -- 242
		local entry = { -- 243
			name -- 243
		} -- 243
		cppTests[#cppTests + 1] = entry -- 244
	end -- 244
	cppTestSet = Set(cppTests) -- 245
	allEntries = { } -- 247
	for _index_0 = 1, #gamesInDev do -- 248
		local game = gamesInDev[_index_0] -- 248
		allEntries[#allEntries + 1] = game -- 249
		local examples, tests = game[3], game[4] -- 250
		for _index_1 = 1, #examples do -- 251
			local example = examples[_index_1] -- 251
			allEntries[#allEntries + 1] = example -- 252
		end -- 252
		for _index_1 = 1, #tests do -- 253
			local test = tests[_index_1] -- 253
			allEntries[#allEntries + 1] = test -- 254
		end -- 254
	end -- 254
	for _index_0 = 1, #games do -- 255
		local game = games[_index_0] -- 255
		allEntries[#allEntries + 1] = game -- 256
		local examples, tests = game[3], game[4] -- 257
		for _index_1 = 1, #examples do -- 258
			local example = examples[_index_1] -- 258
			doraExamples[#doraExamples + 1] = example -- 259
		end -- 259
		for _index_1 = 1, #tests do -- 260
			local test = tests[_index_1] -- 260
			doraTests[#doraTests + 1] = test -- 261
		end -- 261
	end -- 261
	local _list_1 = { -- 263
		doraExamples, -- 263
		doraTests, -- 264
		cppTests -- 265
	} -- 262
	for _index_0 = 1, #_list_1 do -- 266
		local group = _list_1[_index_0] -- 262
		for _index_1 = 1, #group do -- 267
			local entry = group[_index_1] -- 267
			allEntries[#allEntries + 1] = entry -- 268
		end -- 268
	end -- 268
end -- 234
updateEntries() -- 270
local doCompile -- 272
doCompile = function(minify) -- 272
	if building then -- 273
		return -- 273
	end -- 273
	building = true -- 274
	local startTime = App.runningTime -- 275
	local luaFiles = { } -- 276
	local yueFiles = { } -- 277
	local xmlFiles = { } -- 278
	local tlFiles = { } -- 279
	local writablePath = Content.writablePath -- 280
	local buildPaths = { -- 282
		{ -- 283
			Path(Content.assetPath), -- 283
			Path(writablePath, ".build"), -- 284
			"" -- 285
		} -- 282
	} -- 281
	for _index_0 = 1, #gamesInDev do -- 288
		local _des_0 = gamesInDev[_index_0] -- 288
		local entryFile = _des_0[2] -- 288
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 289
		buildPaths[#buildPaths + 1] = { -- 291
			Path(writablePath, gamePath), -- 291
			Path(writablePath, ".build", gamePath), -- 292
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 293
			gamePath -- 294
		} -- 290
	end -- 294
	for _index_0 = 1, #buildPaths do -- 295
		local _des_0 = buildPaths[_index_0] -- 295
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 295
		if not Content:exist(inputPath) then -- 296
			goto _continue_0 -- 296
		end -- 296
		local _list_0 = getAllFiles(inputPath, { -- 298
			"lua" -- 298
		}) -- 298
		for _index_1 = 1, #_list_0 do -- 298
			local file = _list_0[_index_1] -- 298
			luaFiles[#luaFiles + 1] = { -- 300
				file, -- 300
				Path(inputPath, file), -- 301
				Path(outputPath, file), -- 302
				gamePath -- 303
			} -- 299
		end -- 303
		local _list_1 = getAllFiles(inputPath, { -- 305
			yueext -- 305
		}) -- 305
		for _index_1 = 1, #_list_1 do -- 305
			local file = _list_1[_index_1] -- 305
			yueFiles[#yueFiles + 1] = { -- 307
				file, -- 307
				Path(inputPath, file), -- 308
				Path(outputPath, Path:replaceExt(file, "lua")), -- 309
				searchPath, -- 310
				gamePath -- 311
			} -- 306
		end -- 311
		local _list_2 = getAllFiles(inputPath, { -- 313
			"xml" -- 313
		}) -- 313
		for _index_1 = 1, #_list_2 do -- 313
			local file = _list_2[_index_1] -- 313
			xmlFiles[#xmlFiles + 1] = { -- 315
				file, -- 315
				Path(inputPath, file), -- 316
				Path(outputPath, Path:replaceExt(file, "lua")), -- 317
				gamePath -- 318
			} -- 314
		end -- 318
		local _list_3 = getAllFiles(inputPath, { -- 320
			"tl" -- 320
		}) -- 320
		for _index_1 = 1, #_list_3 do -- 320
			local file = _list_3[_index_1] -- 320
			if not file:match(".*%.d%.tl$") then -- 321
				tlFiles[#tlFiles + 1] = { -- 323
					file, -- 323
					Path(inputPath, file), -- 324
					Path(outputPath, Path:replaceExt(file, "lua")), -- 325
					searchPath, -- 326
					gamePath -- 327
				} -- 322
			end -- 321
		end -- 327
		::_continue_0:: -- 296
	end -- 327
	local paths -- 329
	do -- 329
		local _tbl_0 = { } -- 329
		local _list_0 = { -- 330
			luaFiles, -- 330
			yueFiles, -- 330
			xmlFiles, -- 330
			tlFiles -- 330
		} -- 330
		for _index_0 = 1, #_list_0 do -- 330
			local files = _list_0[_index_0] -- 330
			for _index_1 = 1, #files do -- 331
				local file = files[_index_1] -- 331
				_tbl_0[Path:getPath(file[3])] = true -- 329
			end -- 329
		end -- 329
		paths = _tbl_0 -- 329
	end -- 331
	for path in pairs(paths) do -- 333
		Content:mkdir(path) -- 333
	end -- 333
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 335
	local fileCount = 0 -- 336
	local errors = { } -- 337
	for _index_0 = 1, #yueFiles do -- 338
		local _des_0 = yueFiles[_index_0] -- 338
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 338
		local filename -- 339
		if gamePath then -- 339
			filename = Path(gamePath, file) -- 339
		else -- 339
			filename = file -- 339
		end -- 339
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 340
			if not codes then -- 341
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 342
				return -- 343
			end -- 341
			local success, result = LintYueGlobals(codes, globals) -- 344
			if success then -- 345
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 346
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 347
				codes = codes:gsub("^\n*", "") -- 348
				if not (result == "") then -- 349
					result = result .. "\n" -- 349
				end -- 349
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 350
			else -- 352
				local yueCodes = Content:load(input) -- 352
				if yueCodes then -- 352
					local globalErrors = { } -- 353
					for _index_1 = 1, #result do -- 354
						local _des_1 = result[_index_1] -- 354
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 354
						local countLine = 1 -- 355
						local code = "" -- 356
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 357
							if countLine == line then -- 358
								code = lineCode -- 359
								break -- 360
							end -- 358
							countLine = countLine + 1 -- 361
						end -- 361
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 362
					end -- 362
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 363
				else -- 365
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 365
				end -- 352
			end -- 345
		end, function(success) -- 340
			if success then -- 366
				print("Yue compiled: " .. tostring(filename)) -- 366
			end -- 366
			fileCount = fileCount + 1 -- 367
		end) -- 340
	end -- 367
	thread(function() -- 369
		for _index_0 = 1, #xmlFiles do -- 370
			local _des_0 = xmlFiles[_index_0] -- 370
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 370
			local filename -- 371
			if gamePath then -- 371
				filename = Path(gamePath, file) -- 371
			else -- 371
				filename = file -- 371
			end -- 371
			local sourceCodes = Content:loadAsync(input) -- 372
			local codes, err = xml.tolua(sourceCodes) -- 373
			if not codes then -- 374
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 375
			else -- 377
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 377
				print("Xml compiled: " .. tostring(filename)) -- 378
			end -- 374
			fileCount = fileCount + 1 -- 379
		end -- 379
	end) -- 369
	thread(function() -- 381
		for _index_0 = 1, #tlFiles do -- 382
			local _des_0 = tlFiles[_index_0] -- 382
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 382
			local filename -- 383
			if gamePath then -- 383
				filename = Path(gamePath, file) -- 383
			else -- 383
				filename = file -- 383
			end -- 383
			local sourceCodes = Content:loadAsync(input) -- 384
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 385
			if not codes then -- 386
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 387
			else -- 389
				Content:saveAsync(output, codes) -- 389
				print("Teal compiled: " .. tostring(filename)) -- 390
			end -- 386
			fileCount = fileCount + 1 -- 391
		end -- 391
	end) -- 381
	return thread(function() -- 393
		wait(function() -- 394
			return fileCount == totalFiles -- 394
		end) -- 394
		if minify then -- 395
			local _list_0 = { -- 396
				yueFiles, -- 396
				xmlFiles, -- 396
				tlFiles -- 396
			} -- 396
			for _index_0 = 1, #_list_0 do -- 396
				local files = _list_0[_index_0] -- 396
				for _index_1 = 1, #files do -- 396
					local file = files[_index_1] -- 396
					local output = Path:replaceExt(file[3], "lua") -- 397
					luaFiles[#luaFiles + 1] = { -- 399
						Path:replaceExt(file[1], "lua"), -- 399
						output, -- 400
						output -- 401
					} -- 398
				end -- 401
			end -- 401
			local FormatMini -- 403
			do -- 403
				local _obj_0 = require("luaminify") -- 403
				FormatMini = _obj_0.FormatMini -- 403
			end -- 403
			for _index_0 = 1, #luaFiles do -- 404
				local _des_0 = luaFiles[_index_0] -- 404
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 404
				if Content:exist(input) then -- 405
					local sourceCodes = Content:loadAsync(input) -- 406
					local res, err = FormatMini(sourceCodes) -- 407
					if res then -- 408
						Content:saveAsync(output, res) -- 409
						print("Minify: " .. tostring(file)) -- 410
					else -- 412
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 412
					end -- 408
				else -- 414
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 414
				end -- 405
			end -- 414
			package.loaded["luaminify.FormatMini"] = nil -- 415
			package.loaded["luaminify.ParseLua"] = nil -- 416
			package.loaded["luaminify.Scope"] = nil -- 417
			package.loaded["luaminify.Util"] = nil -- 418
		end -- 395
		local errorMessage = table.concat(errors, "\n") -- 419
		if errorMessage ~= "" then -- 420
			print("\n" .. errorMessage) -- 420
		end -- 420
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 421
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 422
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 423
		Content:clearPathCache() -- 424
		teal.clear() -- 425
		yue.clear() -- 426
		building = false -- 427
	end) -- 427
end -- 272
local doClean -- 429
doClean = function() -- 429
	if building then -- 430
		return -- 430
	end -- 430
	local writablePath = Content.writablePath -- 431
	local targetDir = Path(writablePath, ".build") -- 432
	Content:clearPathCache() -- 433
	if Content:remove(targetDir) then -- 434
		print("Cleaned: " .. tostring(targetDir)) -- 435
	end -- 434
	Content:remove(Path(writablePath, ".upload")) -- 436
	return Content:remove(Path(writablePath, ".download")) -- 437
end -- 429
local screenScale = 2.0 -- 439
local scaleContent = false -- 440
local isInEntry = true -- 441
local currentEntry = nil -- 442
local footerWindow = nil -- 444
local entryWindow = nil -- 445
local setupEventHandlers = nil -- 447
local allClear -- 449
allClear = function() -- 449
	local _list_0 = Routine -- 450
	for _index_0 = 1, #_list_0 do -- 450
		local routine = _list_0[_index_0] -- 450
		if footerWindow == routine or entryWindow == routine then -- 452
			goto _continue_0 -- 453
		else -- 455
			Routine:remove(routine) -- 455
		end -- 455
		::_continue_0:: -- 451
	end -- 455
	for _index_0 = 1, #moduleCache do -- 456
		local module = moduleCache[_index_0] -- 456
		package.loaded[module] = nil -- 457
	end -- 457
	moduleCache = { } -- 458
	Director:cleanup() -- 459
	Cache:unload() -- 460
	Entity:clear() -- 461
	Platformer.Data:clear() -- 462
	Platformer.UnitAction:clear() -- 463
	Audio:stopStream(0.5) -- 464
	Struct:clear() -- 465
	View.postEffect = nil -- 466
	View.scale = scaleContent and screenScale or 1 -- 467
	Director.clearColor = Color(0xff1a1a1a) -- 468
	teal.clear() -- 469
	yue.clear() -- 470
	for _, item in pairs(ubox()) do -- 471
		local node = tolua.cast(item, "Node") -- 472
		if node then -- 472
			node:cleanup() -- 472
		end -- 472
	end -- 472
	collectgarbage() -- 473
	collectgarbage() -- 474
	setupEventHandlers() -- 475
	Content.searchPaths = searchPaths -- 476
	App.idled = true -- 477
	return Wasm:clear() -- 478
end -- 449
_module_0["allClear"] = allClear -- 478
setupEventHandlers = function() -- 480
	local _with_0 = Director.postNode -- 481
	_with_0:gslot("AppQuit", allClear) -- 482
	_with_0:gslot("AppTheme", function(argb) -- 483
		config.themeColor = argb -- 484
	end) -- 483
	_with_0:gslot("AppLocale", function(locale) -- 485
		config.locale = locale -- 486
		updateLocale() -- 487
		return teal.clear(true) -- 488
	end) -- 485
	_with_0:gslot("AppWSClose", function() -- 489
		if HttpServer.wsConnectionCount == 0 then -- 490
			return updateEntries() -- 491
		end -- 490
	end) -- 489
	local _exp_0 = App.platform -- 492
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 492
		_with_0:gslot("AppSizeChanged", function() -- 493
			local width, height -- 494
			do -- 494
				local _obj_0 = App.winSize -- 494
				width, height = _obj_0.width, _obj_0.height -- 494
			end -- 494
			config.winWidth = width -- 495
			config.winHeight = height -- 496
		end) -- 493
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 497
			config.fullScreen = fullScreen and 1 or 0 -- 498
		end) -- 497
		_with_0:gslot("AppMoved", function() -- 499
			local _obj_0 = App.winPosition -- 500
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 500
		end) -- 499
	end -- 500
	return _with_0 -- 481
end -- 480
setupEventHandlers() -- 502
local stop -- 504
stop = function() -- 504
	if isInEntry then -- 505
		return false -- 505
	end -- 505
	allClear() -- 506
	isInEntry = true -- 507
	currentEntry = nil -- 508
	return true -- 509
end -- 504
_module_0["stop"] = stop -- 509
local _anon_func_0 = function(Content, Path, file, require, type) -- 531
	local scriptPath = Path:getPath(file) -- 524
	Content:insertSearchPath(1, scriptPath) -- 525
	scriptPath = Path(scriptPath, "Script") -- 526
	if Content:exist(scriptPath) then -- 527
		Content:insertSearchPath(1, scriptPath) -- 528
	end -- 527
	local result = require(file) -- 529
	if "function" == type(result) then -- 530
		result() -- 530
	end -- 530
	return nil -- 531
end -- 524
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 563
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 560
	label.alignment = "Left" -- 561
	label.textWidth = width - fontSize -- 562
	label.text = err -- 563
	return label -- 560
end -- 560
local enterEntryAsync -- 511
enterEntryAsync = function(entry) -- 511
	isInEntry = false -- 512
	App.idled = false -- 513
	emit(Profiler.EventName, "ClearLoader") -- 514
	currentEntry = entry -- 515
	local name, file = entry[1], entry[2] -- 516
	if cppTestSet[entry] then -- 517
		if App:runTest(name) then -- 518
			return true -- 519
		else -- 521
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 521
		end -- 518
	end -- 517
	sleep() -- 522
	return xpcall(_anon_func_0, function(msg) -- 531
		local err = debug.traceback(msg) -- 533
		allClear() -- 534
		print(err) -- 535
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 536
		local viewWidth, viewHeight -- 537
		do -- 537
			local _obj_0 = View.size -- 537
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 537
		end -- 537
		local width, height = viewWidth - 20, viewHeight - 20 -- 538
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 539
		Director.ui:addChild((function() -- 540
			local root = AlignNode() -- 540
			do -- 541
				local _obj_0 = App.bufferSize -- 541
				width, height = _obj_0.width, _obj_0.height -- 541
			end -- 541
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 542
			root:gslot("AppSizeChanged", function() -- 543
				do -- 544
					local _obj_0 = App.bufferSize -- 544
					width, height = _obj_0.width, _obj_0.height -- 544
				end -- 544
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 545
			end) -- 543
			root:addChild((function() -- 546
				local _with_0 = ScrollArea({ -- 547
					width = width, -- 547
					height = height, -- 548
					paddingX = 0, -- 549
					paddingY = 50, -- 550
					viewWidth = height, -- 551
					viewHeight = height -- 552
				}) -- 546
				root:slot("AlignLayout", function(w, h) -- 554
					_with_0.position = Vec2(w / 2, h / 2) -- 555
					w = w - 20 -- 556
					h = h - 20 -- 557
					_with_0.view.children.first.textWidth = w - fontSize -- 558
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 559
				end) -- 554
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 560
				return _with_0 -- 546
			end)()) -- 546
			return root -- 540
		end)()) -- 540
		return err -- 564
	end, Content, Path, file, require, type) -- 564
end -- 511
_module_0["enterEntryAsync"] = enterEntryAsync -- 564
local enterDemoEntry -- 566
enterDemoEntry = function(entry) -- 566
	return thread(function() -- 566
		return enterEntryAsync(entry) -- 566
	end) -- 566
end -- 566
local reloadCurrentEntry -- 568
reloadCurrentEntry = function() -- 568
	if currentEntry then -- 569
		allClear() -- 570
		return enterDemoEntry(currentEntry) -- 571
	end -- 569
end -- 568
Director.clearColor = Color(0xff1a1a1a) -- 573
local waitForWebStart = true -- 575
thread(function() -- 576
	sleep(2) -- 577
	waitForWebStart = false -- 578
end) -- 576
local reloadDevEntry -- 580
reloadDevEntry = function() -- 580
	return thread(function() -- 580
		waitForWebStart = true -- 581
		doClean() -- 582
		allClear() -- 583
		_G.require = oldRequire -- 584
		Dora.require = oldRequire -- 585
		package.loaded["Script.Dev.Entry"] = nil -- 586
		return Director.systemScheduler:schedule(function() -- 587
			Routine:clear() -- 588
			oldRequire("Script.Dev.Entry") -- 589
			return true -- 590
		end) -- 590
	end) -- 590
end -- 580
local isOSSLicenseExist = Content:exist("LICENSES") -- 592
local ossLicenses = nil -- 593
local ossLicenseOpen = false -- 594
local extraOperations -- 596
extraOperations = function() -- 596
	local zh = useChinese and isChineseSupported -- 597
	if isOSSLicenseExist then -- 598
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 599
			if not ossLicenses then -- 600
				ossLicenses = { } -- 601
				local licenseText = Content:load("LICENSES") -- 602
				ossLicenseOpen = (licenseText ~= nil) -- 603
				if ossLicenseOpen then -- 603
					licenseText = licenseText:gsub("\r\n", "\n") -- 604
					for license in GSplit(licenseText, "\n--------\n", true) do -- 605
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 606
						if name then -- 606
							ossLicenses[#ossLicenses + 1] = { -- 607
								name, -- 607
								text -- 607
							} -- 607
						end -- 606
					end -- 607
				end -- 603
			else -- 609
				ossLicenseOpen = true -- 609
			end -- 600
		end -- 599
		if ossLicenseOpen then -- 610
			local width, height, themeColor -- 611
			do -- 611
				local _obj_0 = App -- 611
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 611
			end -- 611
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 612
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 613
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 614
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 617
					"NoSavedSettings" -- 617
				}, function() -- 618
					for _index_0 = 1, #ossLicenses do -- 618
						local _des_0 = ossLicenses[_index_0] -- 618
						local firstLine, text = _des_0[1], _des_0[2] -- 618
						local name, license = firstLine:match("(.+): (.+)") -- 619
						TextColored(themeColor, name) -- 620
						SameLine() -- 621
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 622
							return TextWrapped(text) -- 622
						end) -- 622
					end -- 622
				end) -- 614
			end) -- 614
		end -- 610
	end -- 598
	if not App.debugging then -- 624
		return -- 624
	end -- 624
	return TreeNode(zh and "开发操作" or "Development", function() -- 625
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 626
			OpenPopup("build") -- 626
		end -- 626
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 627
			return BeginPopup("build", function() -- 627
				if Selectable(zh and "编译" or "Compile") then -- 628
					doCompile(false) -- 628
				end -- 628
				Separator() -- 629
				if Selectable(zh and "压缩" or "Minify") then -- 630
					doCompile(true) -- 630
				end -- 630
				Separator() -- 631
				if Selectable(zh and "清理" or "Clean") then -- 632
					return doClean() -- 632
				end -- 632
			end) -- 632
		end) -- 627
		if isInEntry then -- 633
			if waitForWebStart then -- 634
				BeginDisabled(function() -- 635
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 635
				end) -- 635
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 636
				reloadDevEntry() -- 637
			end -- 634
		end -- 633
		do -- 638
			local changed -- 638
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 638
			if changed then -- 638
				View.scale = scaleContent and screenScale or 1 -- 639
			end -- 638
		end -- 638
		local changed -- 640
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 640
		if changed then -- 640
			config.engineDev = engineDev and 1 or 0 -- 641
		end -- 640
	end) -- 625
end -- 596
local transparant = Color(0x0) -- 643
local windowFlags = { -- 645
	"NoTitleBar", -- 645
	"NoResize", -- 646
	"NoMove", -- 647
	"NoCollapse", -- 648
	"NoSavedSettings", -- 649
	"NoBringToFrontOnFocus" -- 650
} -- 644
local initFooter = true -- 651
local _anon_func_2 = function(allEntries, currentIndex) -- 687
	if currentIndex > 1 then -- 687
		return allEntries[currentIndex - 1] -- 688
	else -- 690
		return allEntries[#allEntries] -- 690
	end -- 687
end -- 687
local _anon_func_3 = function(allEntries, currentIndex) -- 694
	if currentIndex < #allEntries then -- 694
		return allEntries[currentIndex + 1] -- 695
	else -- 697
		return allEntries[1] -- 697
	end -- 694
end -- 694
footerWindow = threadLoop(function() -- 652
	local zh = useChinese and isChineseSupported -- 653
	if HttpServer.wsConnectionCount > 0 then -- 654
		return -- 655
	end -- 654
	if Keyboard:isKeyDown("Escape") then -- 656
		allClear() -- 657
		App:shutdown() -- 658
	end -- 656
	do -- 659
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 660
		if ctrl and Keyboard:isKeyDown("Q") then -- 661
			stop() -- 662
		end -- 661
		if ctrl and Keyboard:isKeyDown("Z") then -- 663
			reloadCurrentEntry() -- 664
		end -- 663
		if ctrl and Keyboard:isKeyDown(",") then -- 665
			if showFooter then -- 666
				showStats = not showStats -- 666
			else -- 666
				showStats = true -- 666
			end -- 666
			showFooter = true -- 667
			config.showFooter = showFooter and 1 or 0 -- 668
			config.showStats = showStats and 1 or 0 -- 669
		end -- 665
		if ctrl and Keyboard:isKeyDown(".") then -- 670
			if showFooter then -- 671
				showConsole = not showConsole -- 671
			else -- 671
				showConsole = true -- 671
			end -- 671
			showFooter = true -- 672
			config.showFooter = showFooter and 1 or 0 -- 673
			config.showConsole = showConsole and 1 or 0 -- 674
		end -- 670
		if ctrl and Keyboard:isKeyDown("/") then -- 675
			showFooter = not showFooter -- 676
			config.showFooter = showFooter and 1 or 0 -- 677
		end -- 675
		local left = ctrl and Keyboard:isKeyDown("Left") -- 678
		local right = ctrl and Keyboard:isKeyDown("Right") -- 679
		local currentIndex = nil -- 680
		for i, entry in ipairs(allEntries) do -- 681
			if currentEntry == entry then -- 682
				currentIndex = i -- 683
			end -- 682
		end -- 683
		if left then -- 684
			allClear() -- 685
			if currentIndex == nil then -- 686
				currentIndex = #allEntries + 1 -- 686
			end -- 686
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 687
		end -- 684
		if right then -- 691
			allClear() -- 692
			if currentIndex == nil then -- 693
				currentIndex = 0 -- 693
			end -- 693
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 694
		end -- 691
	end -- 697
	if not showEntry then -- 698
		return -- 698
	end -- 698
	local width, height -- 700
	do -- 700
		local _obj_0 = App.visualSize -- 700
		width, height = _obj_0.width, _obj_0.height -- 700
	end -- 700
	SetNextWindowSize(Vec2(50, 50)) -- 701
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 702
	PushStyleColor("WindowBg", transparant, function() -- 703
		return Begin("Show", windowFlags, function() -- 703
			if isInEntry or width >= 540 then -- 704
				local changed -- 705
				changed, showFooter = Checkbox("##dev", showFooter) -- 705
				if changed then -- 705
					config.showFooter = showFooter and 1 or 0 -- 706
				end -- 705
			end -- 704
		end) -- 706
	end) -- 703
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 708
		reloadDevEntry() -- 712
	end -- 708
	if initFooter then -- 713
		initFooter = false -- 714
	else -- 716
		if not showFooter then -- 716
			return -- 716
		end -- 716
	end -- 713
	SetNextWindowSize(Vec2(width, 50)) -- 718
	SetNextWindowPos(Vec2(0, height - 50)) -- 719
	SetNextWindowBgAlpha(0.35) -- 720
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 721
		return Begin("Footer", windowFlags, function() -- 721
			Dummy(Vec2(width - 20, 0)) -- 722
			do -- 723
				local changed -- 723
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 723
				if changed then -- 723
					config.showStats = showStats and 1 or 0 -- 724
				end -- 723
			end -- 723
			SameLine() -- 725
			do -- 726
				local changed -- 726
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 726
				if changed then -- 726
					config.showConsole = showConsole and 1 or 0 -- 727
				end -- 726
			end -- 726
			if not isInEntry then -- 728
				SameLine() -- 729
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 730
					allClear() -- 731
					isInEntry = true -- 732
					currentEntry = nil -- 733
				end -- 730
				local currentIndex = nil -- 734
				for i, entry in ipairs(allEntries) do -- 735
					if currentEntry == entry then -- 736
						currentIndex = i -- 737
					end -- 736
				end -- 737
				if currentIndex then -- 738
					if currentIndex > 1 then -- 739
						SameLine() -- 740
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 741
							allClear() -- 742
							enterDemoEntry(allEntries[currentIndex - 1]) -- 743
						end -- 741
					end -- 739
					if currentIndex < #allEntries then -- 744
						SameLine() -- 745
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 746
							allClear() -- 747
							enterDemoEntry(allEntries[currentIndex + 1]) -- 748
						end -- 746
					end -- 744
				end -- 738
				SameLine() -- 749
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 750
					reloadCurrentEntry() -- 751
				end -- 750
			end -- 728
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 752
				if showStats then -- 753
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 754
					showStats = ShowStats(showStats, extraOperations) -- 755
					config.showStats = showStats and 1 or 0 -- 756
				end -- 753
				if showConsole then -- 757
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 758
					showConsole = ShowConsole(showConsole) -- 759
					config.showConsole = showConsole and 1 or 0 -- 760
				end -- 757
			end) -- 760
		end) -- 760
	end) -- 760
end) -- 652
local MaxWidth <const> = 800 -- 762
local displayWindowFlags = { -- 765
	"NoDecoration", -- 765
	"NoSavedSettings", -- 766
	"NoFocusOnAppearing", -- 767
	"NoNav", -- 768
	"NoMove", -- 769
	"NoScrollWithMouse", -- 770
	"AlwaysAutoResize", -- 771
	"NoBringToFrontOnFocus" -- 772
} -- 764
local webStatus = nil -- 774
local descColor = Color(0xffa1a1a1) -- 775
local gameOpen = #gamesInDev == 0 -- 776
local exampleOpen = false -- 777
local testOpen = false -- 778
local filterText = nil -- 779
local anyEntryMatched = false -- 780
local match -- 781
match = function(name) -- 781
	local res = not filterText or name:lower():match(filterText) -- 782
	if res then -- 783
		anyEntryMatched = true -- 783
	end -- 783
	return res -- 784
end -- 781
entryWindow = threadLoop(function() -- 786
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 787
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 788
	end -- 787
	if App.targetFPS ~= config.targetFPS then -- 789
		config.targetFPS = App.targetFPS -- 790
	end -- 789
	if View.vsync ~= (config.vsync == 1) then -- 791
		config.vsync = View.vsync and 1 or 0 -- 792
	end -- 791
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 793
		config.fixedFPS = Director.scheduler.fixedFPS -- 794
	end -- 793
	if Director.profilerSending ~= (config.webProfiler == 1) then -- 795
		config.webProfiler = Director.profilerSending and 1 or 0 -- 796
	end -- 795
	if not showEntry then -- 797
		return -- 797
	end -- 797
	if not isInEntry then -- 798
		return -- 798
	end -- 798
	local zh = useChinese and isChineseSupported -- 799
	if HttpServer.wsConnectionCount > 0 then -- 800
		local themeColor = App.themeColor -- 801
		local width, height -- 802
		do -- 802
			local _obj_0 = App.visualSize -- 802
			width, height = _obj_0.width, _obj_0.height -- 802
		end -- 802
		SetNextWindowBgAlpha(0.5) -- 803
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 804
		Begin("Web IDE Connected", displayWindowFlags, function() -- 805
			Separator() -- 806
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 807
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 808
			TextColored(descColor, slogon) -- 809
			return Separator() -- 810
		end) -- 805
		return -- 811
	end -- 800
	local themeColor = App.themeColor -- 813
	local fullWidth, height -- 814
	do -- 814
		local _obj_0 = App.visualSize -- 814
		fullWidth, height = _obj_0.width, _obj_0.height -- 814
	end -- 814
	SetNextWindowBgAlpha(0.85) -- 816
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 817
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 818
		return Begin("Web IDE", displayWindowFlags, function() -- 819
			Separator() -- 820
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 821
			local url -- 822
			do -- 822
				local _exp_0 -- 822
				if webStatus ~= nil then -- 822
					_exp_0 = webStatus.url -- 822
				end -- 822
				if _exp_0 ~= nil then -- 822
					url = _exp_0 -- 822
				else -- 822
					url = zh and '不可用' or 'not available' -- 822
				end -- 822
			end -- 822
			TextColored(descColor, url) -- 823
			return Separator() -- 824
		end) -- 824
	end) -- 818
	local width = math.min(MaxWidth, fullWidth) -- 826
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 827
	local maxColumns = math.max(math.floor(width / 200), 1) -- 828
	SetNextWindowPos(Vec2.zero) -- 829
	SetNextWindowBgAlpha(0) -- 830
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 831
		return Begin("Dora Dev", displayWindowFlags, function() -- 832
			Dummy(Vec2(fullWidth - 20, 0)) -- 833
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 834
			SameLine() -- 835
			if fullWidth >= 320 then -- 836
				Dummy(Vec2(fullWidth - 320, 0)) -- 837
				SameLine() -- 838
				SetNextItemWidth(-50) -- 839
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 840
					"AutoSelectAll" -- 840
				}) then -- 840
					config.filter = filterBuf:toString() -- 841
				end -- 840
			end -- 836
			Separator() -- 842
			return Dummy(Vec2(fullWidth - 20, 0)) -- 843
		end) -- 843
	end) -- 831
	anyEntryMatched = false -- 845
	SetNextWindowPos(Vec2(0, 50)) -- 846
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 847
	return PushStyleColor("WindowBg", transparant, function() -- 848
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 848
			return Begin("Content", windowFlags, function() -- 849
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 850
				if filterText then -- 851
					filterText = filterText:lower() -- 851
				end -- 851
				if #gamesInDev > 0 then -- 852
					for _index_0 = 1, #gamesInDev do -- 853
						local game = gamesInDev[_index_0] -- 853
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 854
						local showSep = false -- 855
						if match(gameName) then -- 856
							Columns(1, false) -- 857
							TextColored(themeColor, zh and "项目：" or "Project:") -- 858
							SameLine() -- 859
							Text(gameName) -- 860
							Separator() -- 861
							if bannerFile then -- 862
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 863
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 864
								local sizing <const> = 0.8 -- 865
								texHeight = displayWidth * sizing * texHeight / texWidth -- 866
								texWidth = displayWidth * sizing -- 867
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 868
								Dummy(Vec2(padding, 0)) -- 869
								SameLine() -- 870
								PushID(fileName, function() -- 871
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 872
										return enterDemoEntry(game) -- 873
									end -- 872
								end) -- 871
							else -- 875
								PushID(fileName, function() -- 875
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 876
										return enterDemoEntry(game) -- 877
									end -- 876
								end) -- 875
							end -- 862
							NextColumn() -- 878
							showSep = true -- 879
						end -- 856
						if #examples > 0 then -- 880
							local showExample = false -- 881
							for _index_1 = 1, #examples do -- 882
								local example = examples[_index_1] -- 882
								if match(example[1]) then -- 883
									showExample = true -- 884
									break -- 885
								end -- 883
							end -- 885
							if showExample then -- 886
								Columns(1, false) -- 887
								TextColored(themeColor, zh and "示例：" or "Example:") -- 888
								SameLine() -- 889
								Text(gameName) -- 890
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 891
									Columns(maxColumns, false) -- 892
									for _index_1 = 1, #examples do -- 893
										local example = examples[_index_1] -- 893
										if not match(example[1]) then -- 894
											goto _continue_0 -- 894
										end -- 894
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 895
											if Button(example[1], Vec2(-1, 40)) then -- 896
												enterDemoEntry(example) -- 897
											end -- 896
											return NextColumn() -- 898
										end) -- 895
										showSep = true -- 899
										::_continue_0:: -- 894
									end -- 899
								end) -- 891
							end -- 886
						end -- 880
						if #tests > 0 then -- 900
							local showTest = false -- 901
							for _index_1 = 1, #tests do -- 902
								local test = tests[_index_1] -- 902
								if match(test[1]) then -- 903
									showTest = true -- 904
									break -- 905
								end -- 903
							end -- 905
							if showTest then -- 906
								Columns(1, false) -- 907
								TextColored(themeColor, zh and "测试：" or "Test:") -- 908
								SameLine() -- 909
								Text(gameName) -- 910
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 911
									Columns(maxColumns, false) -- 912
									for _index_1 = 1, #tests do -- 913
										local test = tests[_index_1] -- 913
										if not match(test[1]) then -- 914
											goto _continue_0 -- 914
										end -- 914
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 915
											if Button(test[1], Vec2(-1, 40)) then -- 916
												enterDemoEntry(test) -- 917
											end -- 916
											return NextColumn() -- 918
										end) -- 915
										showSep = true -- 919
										::_continue_0:: -- 914
									end -- 919
								end) -- 911
							end -- 906
						end -- 900
						if showSep then -- 920
							Columns(1, false) -- 921
							Separator() -- 922
						end -- 920
					end -- 922
				end -- 852
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 923
					local showGame = false -- 924
					for _index_0 = 1, #games do -- 925
						local _des_0 = games[_index_0] -- 925
						local name = _des_0[1] -- 925
						if match(name) then -- 926
							showGame = true -- 926
						end -- 926
					end -- 926
					local showExample = false -- 927
					for _index_0 = 1, #doraExamples do -- 928
						local _des_0 = doraExamples[_index_0] -- 928
						local name = _des_0[1] -- 928
						if match(name) then -- 929
							showExample = true -- 929
						end -- 929
					end -- 929
					local showTest = false -- 930
					for _index_0 = 1, #doraTests do -- 931
						local _des_0 = doraTests[_index_0] -- 931
						local name = _des_0[1] -- 931
						if match(name) then -- 932
							showTest = true -- 932
						end -- 932
					end -- 932
					for _index_0 = 1, #cppTests do -- 933
						local _des_0 = cppTests[_index_0] -- 933
						local name = _des_0[1] -- 933
						if match(name) then -- 934
							showTest = true -- 934
						end -- 934
					end -- 934
					if not (showGame or showExample or showTest) then -- 935
						goto endEntry -- 935
					end -- 935
					Columns(1, false) -- 936
					TextColored(themeColor, "Dora SSR:") -- 937
					SameLine() -- 938
					Text(zh and "开发示例" or "Development Showcase") -- 939
					Separator() -- 940
					local demoViewWith <const> = 400 -- 941
					if #games > 0 and showGame then -- 942
						local opened -- 943
						if (filterText ~= nil) then -- 943
							opened = showGame -- 943
						else -- 943
							opened = false -- 943
						end -- 943
						SetNextItemOpen(gameOpen) -- 944
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 945
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 946
							Columns(columns, false) -- 947
							for _index_0 = 1, #games do -- 948
								local game = games[_index_0] -- 948
								if not match(game[1]) then -- 949
									goto _continue_0 -- 949
								end -- 949
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 950
								if columns > 1 then -- 951
									if bannerFile then -- 952
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 953
										local displayWidth <const> = demoViewWith - 40 -- 954
										texHeight = displayWidth * texHeight / texWidth -- 955
										texWidth = displayWidth -- 956
										Text(gameName) -- 957
										PushID(fileName, function() -- 958
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 959
												return enterDemoEntry(game) -- 960
											end -- 959
										end) -- 958
									else -- 962
										PushID(fileName, function() -- 962
											if Button(gameName, Vec2(-1, 40)) then -- 963
												return enterDemoEntry(game) -- 964
											end -- 963
										end) -- 962
									end -- 952
								else -- 966
									if bannerFile then -- 966
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 967
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 968
										local sizing = 0.8 -- 969
										texHeight = displayWidth * sizing * texHeight / texWidth -- 970
										texWidth = displayWidth * sizing -- 971
										if texWidth > 500 then -- 972
											sizing = 0.6 -- 973
											texHeight = displayWidth * sizing * texHeight / texWidth -- 974
											texWidth = displayWidth * sizing -- 975
										end -- 972
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 976
										Dummy(Vec2(padding, 0)) -- 977
										SameLine() -- 978
										Text(gameName) -- 979
										Dummy(Vec2(padding, 0)) -- 980
										SameLine() -- 981
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
									end -- 966
								end -- 951
								NextColumn() -- 989
								::_continue_0:: -- 949
							end -- 989
							Columns(1, false) -- 990
							opened = true -- 991
						end) -- 945
						gameOpen = opened -- 992
					end -- 942
					if #doraExamples > 0 and showExample then -- 993
						local opened -- 994
						if (filterText ~= nil) then -- 994
							opened = showExample -- 994
						else -- 994
							opened = false -- 994
						end -- 994
						SetNextItemOpen(exampleOpen) -- 995
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 996
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 997
								Columns(maxColumns, false) -- 998
								for _index_0 = 1, #doraExamples do -- 999
									local example = doraExamples[_index_0] -- 999
									if not match(example[1]) then -- 1000
										goto _continue_0 -- 1000
									end -- 1000
									if Button(example[1], Vec2(-1, 40)) then -- 1001
										enterDemoEntry(example) -- 1002
									end -- 1001
									NextColumn() -- 1003
									::_continue_0:: -- 1000
								end -- 1003
								Columns(1, false) -- 1004
								opened = true -- 1005
							end) -- 997
						end) -- 996
						exampleOpen = opened -- 1006
					end -- 993
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1007
						local opened -- 1008
						if (filterText ~= nil) then -- 1008
							opened = showTest -- 1008
						else -- 1008
							opened = false -- 1008
						end -- 1008
						SetNextItemOpen(testOpen) -- 1009
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1010
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1011
								Columns(maxColumns, false) -- 1012
								for _index_0 = 1, #doraTests do -- 1013
									local test = doraTests[_index_0] -- 1013
									if not match(test[1]) then -- 1014
										goto _continue_0 -- 1014
									end -- 1014
									if Button(test[1], Vec2(-1, 40)) then -- 1015
										enterDemoEntry(test) -- 1016
									end -- 1015
									NextColumn() -- 1017
									::_continue_0:: -- 1014
								end -- 1017
								for _index_0 = 1, #cppTests do -- 1018
									local test = cppTests[_index_0] -- 1018
									if not match(test[1]) then -- 1019
										goto _continue_1 -- 1019
									end -- 1019
									if Button(test[1], Vec2(-1, 40)) then -- 1020
										enterDemoEntry(test) -- 1021
									end -- 1020
									NextColumn() -- 1022
									::_continue_1:: -- 1019
								end -- 1022
								opened = true -- 1023
							end) -- 1011
						end) -- 1010
						testOpen = opened -- 1024
					end -- 1007
				end -- 923
				::endEntry:: -- 1025
				if not anyEntryMatched then -- 1026
					SetNextWindowBgAlpha(0) -- 1027
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1028
					Begin("Entries Not Found", displayWindowFlags, function() -- 1029
						Separator() -- 1030
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1031
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1032
						return Separator() -- 1033
					end) -- 1029
				end -- 1026
				Columns(1, false) -- 1034
				Dummy(Vec2(100, 80)) -- 1035
				return ScrollWhenDraggingOnVoid() -- 1036
			end) -- 1036
		end) -- 1036
	end) -- 1036
end) -- 786
webStatus = require("Script.Dev.WebServer") -- 1038
return _module_0 -- 1038
