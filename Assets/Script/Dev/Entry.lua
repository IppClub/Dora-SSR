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
if (config.webProfiler ~= nil) then -- 146
	Director.profilerSending = config.webProfiler > 0 -- 147
else -- 149
	config.webProfiler = 1 -- 149
end -- 146
_module_0.getConfig = function() -- 151
	return config -- 151
end -- 151
_module_0.getEngineDev = function() -- 152
	if not App.debugging then -- 153
		return false -- 153
	end -- 153
	return config.engineDev > 0 -- 154
end -- 152
local Set, Struct, LintYueGlobals, GSplit -- 156
do -- 156
	local _obj_0 = require("Utils") -- 156
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 156
end -- 156
local yueext = yue.options.extension -- 157
local isChineseSupported = IsFontLoaded() -- 159
if not isChineseSupported then -- 160
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 161
		isChineseSupported = true -- 162
	end) -- 161
end -- 160
local building = false -- 164
local getAllFiles -- 166
getAllFiles = function(path, exts) -- 166
	local filters = Set(exts) -- 167
	local _accum_0 = { } -- 168
	local _len_0 = 1 -- 168
	local _list_0 = Content:getAllFiles(path) -- 168
	for _index_0 = 1, #_list_0 do -- 168
		local file = _list_0[_index_0] -- 168
		if not filters[Path:getExt(file)] then -- 169
			goto _continue_0 -- 169
		end -- 169
		_accum_0[_len_0] = file -- 170
		_len_0 = _len_0 + 1 -- 170
		::_continue_0:: -- 169
	end -- 170
	return _accum_0 -- 170
end -- 166
local getFileEntries -- 172
getFileEntries = function(path) -- 172
	local entries = { } -- 173
	local _list_0 = getAllFiles(path, { -- 174
		"lua", -- 174
		"xml", -- 174
		yueext, -- 174
		"tl" -- 174
	}) -- 174
	for _index_0 = 1, #_list_0 do -- 174
		local file = _list_0[_index_0] -- 174
		local entryName = Path:getName(file) -- 175
		local entryAdded = false -- 176
		for _index_1 = 1, #entries do -- 177
			local _des_0 = entries[_index_1] -- 177
			local ename = _des_0[1] -- 177
			if entryName == ename then -- 178
				entryAdded = true -- 179
				break -- 180
			end -- 178
		end -- 180
		if entryAdded then -- 181
			goto _continue_0 -- 181
		end -- 181
		local fileName = Path:replaceExt(file, "") -- 182
		fileName = Path(path, fileName) -- 183
		local entry = { -- 184
			entryName, -- 184
			fileName -- 184
		} -- 184
		entries[#entries + 1] = entry -- 185
		::_continue_0:: -- 175
	end -- 185
	table.sort(entries, function(a, b) -- 186
		return a[1] < b[1] -- 186
	end) -- 186
	return entries -- 187
end -- 172
local getProjectEntries -- 189
getProjectEntries = function(path) -- 189
	local entries = { } -- 190
	local _list_0 = Content:getDirs(path) -- 191
	for _index_0 = 1, #_list_0 do -- 191
		local dir = _list_0[_index_0] -- 191
		if dir:match("^%.") then -- 192
			goto _continue_0 -- 192
		end -- 192
		local _list_1 = getAllFiles(Path(path, dir), { -- 193
			"lua", -- 193
			"xml", -- 193
			yueext, -- 193
			"tl", -- 193
			"wasm" -- 193
		}) -- 193
		for _index_1 = 1, #_list_1 do -- 193
			local file = _list_1[_index_1] -- 193
			if "init" == Path:getName(file):lower() then -- 194
				local fileName = Path:replaceExt(file, "") -- 195
				fileName = Path(path, dir, fileName) -- 196
				local entryName = Path:getName(Path:getPath(fileName)) -- 197
				local entryAdded = false -- 198
				for _index_2 = 1, #entries do -- 199
					local _des_0 = entries[_index_2] -- 199
					local ename = _des_0[1] -- 199
					if entryName == ename then -- 200
						entryAdded = true -- 201
						break -- 202
					end -- 200
				end -- 202
				if entryAdded then -- 203
					goto _continue_1 -- 203
				end -- 203
				local examples = { } -- 204
				local tests = { } -- 205
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 206
				if Content:exist(examplePath) then -- 207
					local _list_2 = getFileEntries(examplePath) -- 208
					for _index_2 = 1, #_list_2 do -- 208
						local _des_0 = _list_2[_index_2] -- 208
						local name, ePath = _des_0[1], _des_0[2] -- 208
						local entry = { -- 209
							name, -- 209
							Path(path, dir, Path:getPath(file), ePath) -- 209
						} -- 209
						examples[#examples + 1] = entry -- 210
					end -- 210
				end -- 207
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 211
				if Content:exist(testPath) then -- 212
					local _list_2 = getFileEntries(testPath) -- 213
					for _index_2 = 1, #_list_2 do -- 213
						local _des_0 = _list_2[_index_2] -- 213
						local name, tPath = _des_0[1], _des_0[2] -- 213
						local entry = { -- 214
							name, -- 214
							Path(path, dir, Path:getPath(file), tPath) -- 214
						} -- 214
						tests[#tests + 1] = entry -- 215
					end -- 215
				end -- 212
				local entry = { -- 216
					entryName, -- 216
					fileName, -- 216
					examples, -- 216
					tests -- 216
				} -- 216
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 217
				if not Content:exist(bannerFile) then -- 218
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 219
					if not Content:exist(bannerFile) then -- 220
						bannerFile = nil -- 220
					end -- 220
				end -- 218
				if bannerFile then -- 221
					thread(function() -- 221
						Cache:loadAsync(bannerFile) -- 222
						local bannerTex = Texture2D(bannerFile) -- 223
						if bannerTex then -- 224
							entry[#entry + 1] = bannerFile -- 225
							entry[#entry + 1] = bannerTex -- 226
						end -- 224
					end) -- 221
				end -- 221
				entries[#entries + 1] = entry -- 227
			end -- 194
			::_continue_1:: -- 194
		end -- 227
		::_continue_0:: -- 192
	end -- 227
	table.sort(entries, function(a, b) -- 228
		return a[1] < b[1] -- 228
	end) -- 228
	return entries -- 229
end -- 189
local gamesInDev, games -- 231
local doraExamples, doraTests -- 232
local cppTests, cppTestSet -- 233
local allEntries -- 234
local updateEntries -- 236
updateEntries = function() -- 236
	gamesInDev = getProjectEntries(Content.writablePath) -- 237
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 238
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 240
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 241
	cppTests = { } -- 243
	local _list_0 = App.testNames -- 244
	for _index_0 = 1, #_list_0 do -- 244
		local name = _list_0[_index_0] -- 244
		local entry = { -- 245
			name -- 245
		} -- 245
		cppTests[#cppTests + 1] = entry -- 246
	end -- 246
	cppTestSet = Set(cppTests) -- 247
	allEntries = { } -- 249
	for _index_0 = 1, #gamesInDev do -- 250
		local game = gamesInDev[_index_0] -- 250
		allEntries[#allEntries + 1] = game -- 251
		local examples, tests = game[3], game[4] -- 252
		for _index_1 = 1, #examples do -- 253
			local example = examples[_index_1] -- 253
			allEntries[#allEntries + 1] = example -- 254
		end -- 254
		for _index_1 = 1, #tests do -- 255
			local test = tests[_index_1] -- 255
			allEntries[#allEntries + 1] = test -- 256
		end -- 256
	end -- 256
	for _index_0 = 1, #games do -- 257
		local game = games[_index_0] -- 257
		allEntries[#allEntries + 1] = game -- 258
		local examples, tests = game[3], game[4] -- 259
		for _index_1 = 1, #examples do -- 260
			local example = examples[_index_1] -- 260
			doraExamples[#doraExamples + 1] = example -- 261
		end -- 261
		for _index_1 = 1, #tests do -- 262
			local test = tests[_index_1] -- 262
			doraTests[#doraTests + 1] = test -- 263
		end -- 263
	end -- 263
	local _list_1 = { -- 265
		doraExamples, -- 265
		doraTests, -- 266
		cppTests -- 267
	} -- 264
	for _index_0 = 1, #_list_1 do -- 268
		local group = _list_1[_index_0] -- 264
		for _index_1 = 1, #group do -- 269
			local entry = group[_index_1] -- 269
			allEntries[#allEntries + 1] = entry -- 270
		end -- 270
	end -- 270
end -- 236
updateEntries() -- 272
local doCompile -- 274
doCompile = function(minify) -- 274
	if building then -- 275
		return -- 275
	end -- 275
	building = true -- 276
	local startTime = App.runningTime -- 277
	local luaFiles = { } -- 278
	local yueFiles = { } -- 279
	local xmlFiles = { } -- 280
	local tlFiles = { } -- 281
	local writablePath = Content.writablePath -- 282
	local buildPaths = { -- 284
		{ -- 285
			Path(Content.assetPath), -- 285
			Path(writablePath, ".build"), -- 286
			"" -- 287
		} -- 284
	} -- 283
	for _index_0 = 1, #gamesInDev do -- 290
		local _des_0 = gamesInDev[_index_0] -- 290
		local entryFile = _des_0[2] -- 290
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 291
		buildPaths[#buildPaths + 1] = { -- 293
			Path(writablePath, gamePath), -- 293
			Path(writablePath, ".build", gamePath), -- 294
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 295
			gamePath -- 296
		} -- 292
	end -- 296
	for _index_0 = 1, #buildPaths do -- 297
		local _des_0 = buildPaths[_index_0] -- 297
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 297
		if not Content:exist(inputPath) then -- 298
			goto _continue_0 -- 298
		end -- 298
		local _list_0 = getAllFiles(inputPath, { -- 300
			"lua" -- 300
		}) -- 300
		for _index_1 = 1, #_list_0 do -- 300
			local file = _list_0[_index_1] -- 300
			luaFiles[#luaFiles + 1] = { -- 302
				file, -- 302
				Path(inputPath, file), -- 303
				Path(outputPath, file), -- 304
				gamePath -- 305
			} -- 301
		end -- 305
		local _list_1 = getAllFiles(inputPath, { -- 307
			yueext -- 307
		}) -- 307
		for _index_1 = 1, #_list_1 do -- 307
			local file = _list_1[_index_1] -- 307
			yueFiles[#yueFiles + 1] = { -- 309
				file, -- 309
				Path(inputPath, file), -- 310
				Path(outputPath, Path:replaceExt(file, "lua")), -- 311
				searchPath, -- 312
				gamePath -- 313
			} -- 308
		end -- 313
		local _list_2 = getAllFiles(inputPath, { -- 315
			"xml" -- 315
		}) -- 315
		for _index_1 = 1, #_list_2 do -- 315
			local file = _list_2[_index_1] -- 315
			xmlFiles[#xmlFiles + 1] = { -- 317
				file, -- 317
				Path(inputPath, file), -- 318
				Path(outputPath, Path:replaceExt(file, "lua")), -- 319
				gamePath -- 320
			} -- 316
		end -- 320
		local _list_3 = getAllFiles(inputPath, { -- 322
			"tl" -- 322
		}) -- 322
		for _index_1 = 1, #_list_3 do -- 322
			local file = _list_3[_index_1] -- 322
			if not file:match(".*%.d%.tl$") then -- 323
				tlFiles[#tlFiles + 1] = { -- 325
					file, -- 325
					Path(inputPath, file), -- 326
					Path(outputPath, Path:replaceExt(file, "lua")), -- 327
					searchPath, -- 328
					gamePath -- 329
				} -- 324
			end -- 323
		end -- 329
		::_continue_0:: -- 298
	end -- 329
	local paths -- 331
	do -- 331
		local _tbl_0 = { } -- 331
		local _list_0 = { -- 332
			luaFiles, -- 332
			yueFiles, -- 332
			xmlFiles, -- 332
			tlFiles -- 332
		} -- 332
		for _index_0 = 1, #_list_0 do -- 332
			local files = _list_0[_index_0] -- 332
			for _index_1 = 1, #files do -- 333
				local file = files[_index_1] -- 333
				_tbl_0[Path:getPath(file[3])] = true -- 331
			end -- 331
		end -- 331
		paths = _tbl_0 -- 331
	end -- 333
	for path in pairs(paths) do -- 335
		Content:mkdir(path) -- 335
	end -- 335
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 337
	local fileCount = 0 -- 338
	local errors = { } -- 339
	for _index_0 = 1, #yueFiles do -- 340
		local _des_0 = yueFiles[_index_0] -- 340
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 340
		local filename -- 341
		if gamePath then -- 341
			filename = Path(gamePath, file) -- 341
		else -- 341
			filename = file -- 341
		end -- 341
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 342
			if not codes then -- 343
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 344
				return -- 345
			end -- 343
			local success, result = LintYueGlobals(codes, globals) -- 346
			if success then -- 347
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 348
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 349
				codes = codes:gsub("^\n*", "") -- 350
				if not (result == "") then -- 351
					result = result .. "\n" -- 351
				end -- 351
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 352
			else -- 354
				local yueCodes = Content:load(input) -- 354
				if yueCodes then -- 354
					local globalErrors = { } -- 355
					for _index_1 = 1, #result do -- 356
						local _des_1 = result[_index_1] -- 356
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 356
						local countLine = 1 -- 357
						local code = "" -- 358
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 359
							if countLine == line then -- 360
								code = lineCode -- 361
								break -- 362
							end -- 360
							countLine = countLine + 1 -- 363
						end -- 363
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 364
					end -- 364
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 365
				else -- 367
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 367
				end -- 354
			end -- 347
		end, function(success) -- 342
			if success then -- 368
				print("Yue compiled: " .. tostring(filename)) -- 368
			end -- 368
			fileCount = fileCount + 1 -- 369
		end) -- 342
	end -- 369
	thread(function() -- 371
		for _index_0 = 1, #xmlFiles do -- 372
			local _des_0 = xmlFiles[_index_0] -- 372
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 372
			local filename -- 373
			if gamePath then -- 373
				filename = Path(gamePath, file) -- 373
			else -- 373
				filename = file -- 373
			end -- 373
			local sourceCodes = Content:loadAsync(input) -- 374
			local codes, err = xml.tolua(sourceCodes) -- 375
			if not codes then -- 376
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 377
			else -- 379
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 379
				print("Xml compiled: " .. tostring(filename)) -- 380
			end -- 376
			fileCount = fileCount + 1 -- 381
		end -- 381
	end) -- 371
	thread(function() -- 383
		for _index_0 = 1, #tlFiles do -- 384
			local _des_0 = tlFiles[_index_0] -- 384
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 384
			local filename -- 385
			if gamePath then -- 385
				filename = Path(gamePath, file) -- 385
			else -- 385
				filename = file -- 385
			end -- 385
			local sourceCodes = Content:loadAsync(input) -- 386
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 387
			if not codes then -- 388
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 389
			else -- 391
				Content:saveAsync(output, codes) -- 391
				print("Teal compiled: " .. tostring(filename)) -- 392
			end -- 388
			fileCount = fileCount + 1 -- 393
		end -- 393
	end) -- 383
	return thread(function() -- 395
		wait(function() -- 396
			return fileCount == totalFiles -- 396
		end) -- 396
		if minify then -- 397
			local _list_0 = { -- 398
				yueFiles, -- 398
				xmlFiles, -- 398
				tlFiles -- 398
			} -- 398
			for _index_0 = 1, #_list_0 do -- 398
				local files = _list_0[_index_0] -- 398
				for _index_1 = 1, #files do -- 398
					local file = files[_index_1] -- 398
					local output = Path:replaceExt(file[3], "lua") -- 399
					luaFiles[#luaFiles + 1] = { -- 401
						Path:replaceExt(file[1], "lua"), -- 401
						output, -- 402
						output -- 403
					} -- 400
				end -- 403
			end -- 403
			local FormatMini -- 405
			do -- 405
				local _obj_0 = require("luaminify") -- 405
				FormatMini = _obj_0.FormatMini -- 405
			end -- 405
			for _index_0 = 1, #luaFiles do -- 406
				local _des_0 = luaFiles[_index_0] -- 406
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 406
				if Content:exist(input) then -- 407
					local sourceCodes = Content:loadAsync(input) -- 408
					local res, err = FormatMini(sourceCodes) -- 409
					if res then -- 410
						Content:saveAsync(output, res) -- 411
						print("Minify: " .. tostring(file)) -- 412
					else -- 414
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 414
					end -- 410
				else -- 416
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 416
				end -- 407
			end -- 416
			package.loaded["luaminify.FormatMini"] = nil -- 417
			package.loaded["luaminify.ParseLua"] = nil -- 418
			package.loaded["luaminify.Scope"] = nil -- 419
			package.loaded["luaminify.Util"] = nil -- 420
		end -- 397
		local errorMessage = table.concat(errors, "\n") -- 421
		if errorMessage ~= "" then -- 422
			print("\n" .. errorMessage) -- 422
		end -- 422
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 423
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 424
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 425
		Content:clearPathCache() -- 426
		teal.clear() -- 427
		yue.clear() -- 428
		building = false -- 429
	end) -- 429
end -- 274
local doClean -- 431
doClean = function() -- 431
	if building then -- 432
		return -- 432
	end -- 432
	local writablePath = Content.writablePath -- 433
	local targetDir = Path(writablePath, ".build") -- 434
	Content:clearPathCache() -- 435
	if Content:remove(targetDir) then -- 436
		print("Cleaned: " .. tostring(targetDir)) -- 437
	end -- 436
	Content:remove(Path(writablePath, ".upload")) -- 438
	return Content:remove(Path(writablePath, ".download")) -- 439
end -- 431
local screenScale = 2.0 -- 441
local scaleContent = false -- 442
local isInEntry = true -- 443
local currentEntry = nil -- 444
local footerWindow = nil -- 446
local entryWindow = nil -- 447
local setupEventHandlers = nil -- 449
local allClear -- 451
allClear = function() -- 451
	local _list_0 = Routine -- 452
	for _index_0 = 1, #_list_0 do -- 452
		local routine = _list_0[_index_0] -- 452
		if footerWindow == routine or entryWindow == routine then -- 454
			goto _continue_0 -- 455
		else -- 457
			Routine:remove(routine) -- 457
		end -- 457
		::_continue_0:: -- 453
	end -- 457
	for _index_0 = 1, #moduleCache do -- 458
		local module = moduleCache[_index_0] -- 458
		package.loaded[module] = nil -- 459
	end -- 459
	moduleCache = { } -- 460
	Director:cleanup() -- 461
	Cache:unload() -- 462
	Entity:clear() -- 463
	Platformer.Data:clear() -- 464
	Platformer.UnitAction:clear() -- 465
	Audio:stopStream(0.5) -- 466
	Struct:clear() -- 467
	View.postEffect = nil -- 468
	View.scale = scaleContent and screenScale or 1 -- 469
	Director.clearColor = Color(0xff1a1a1a) -- 470
	teal.clear() -- 471
	yue.clear() -- 472
	for _, item in pairs(ubox()) do -- 473
		local node = tolua.cast(item, "Node") -- 474
		if node then -- 474
			node:cleanup() -- 474
		end -- 474
	end -- 474
	collectgarbage() -- 475
	collectgarbage() -- 476
	setupEventHandlers() -- 477
	Content.searchPaths = searchPaths -- 478
	App.idled = true -- 479
	return Wasm:clear() -- 480
end -- 451
_module_0["allClear"] = allClear -- 480
setupEventHandlers = function() -- 482
	local _with_0 = Director.postNode -- 483
	_with_0:gslot("AppQuit", allClear) -- 484
	_with_0:gslot("AppTheme", function(argb) -- 485
		config.themeColor = argb -- 486
	end) -- 485
	_with_0:gslot("AppLocale", function(locale) -- 487
		config.locale = locale -- 488
		updateLocale() -- 489
		return teal.clear(true) -- 490
	end) -- 487
	_with_0:gslot("AppWSClose", function() -- 491
		if HttpServer.wsConnectionCount == 0 then -- 492
			return updateEntries() -- 493
		end -- 492
	end) -- 491
	local _exp_0 = App.platform -- 494
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 494
		_with_0:gslot("AppSizeChanged", function() -- 495
			local width, height -- 496
			do -- 496
				local _obj_0 = App.winSize -- 496
				width, height = _obj_0.width, _obj_0.height -- 496
			end -- 496
			config.winWidth = width -- 497
			config.winHeight = height -- 498
		end) -- 495
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 499
			config.fullScreen = fullScreen and 1 or 0 -- 500
		end) -- 499
		_with_0:gslot("AppMoved", function() -- 501
			local _obj_0 = App.winPosition -- 502
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 502
		end) -- 501
	end -- 502
	return _with_0 -- 483
end -- 482
setupEventHandlers() -- 504
local stop -- 506
stop = function() -- 506
	if isInEntry then -- 507
		return false -- 507
	end -- 507
	allClear() -- 508
	isInEntry = true -- 509
	currentEntry = nil -- 510
	return true -- 511
end -- 506
_module_0["stop"] = stop -- 511
local _anon_func_0 = function(Content, Path, file, require, type) -- 533
	local scriptPath = Path:getPath(file) -- 526
	Content:insertSearchPath(1, scriptPath) -- 527
	scriptPath = Path(scriptPath, "Script") -- 528
	if Content:exist(scriptPath) then -- 529
		Content:insertSearchPath(1, scriptPath) -- 530
	end -- 529
	local result = require(file) -- 531
	if "function" == type(result) then -- 532
		result() -- 532
	end -- 532
	return nil -- 533
end -- 526
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 565
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 562
	label.alignment = "Left" -- 563
	label.textWidth = width - fontSize -- 564
	label.text = err -- 565
	return label -- 562
end -- 562
local enterEntryAsync -- 513
enterEntryAsync = function(entry) -- 513
	isInEntry = false -- 514
	App.idled = false -- 515
	emit(Profiler.EventName, "ClearLoader") -- 516
	currentEntry = entry -- 517
	local name, file = entry[1], entry[2] -- 518
	if cppTestSet[entry] then -- 519
		if App:runTest(name) then -- 520
			return true -- 521
		else -- 523
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 523
		end -- 520
	end -- 519
	sleep() -- 524
	return xpcall(_anon_func_0, function(msg) -- 533
		local err = debug.traceback(msg) -- 535
		allClear() -- 536
		print(err) -- 537
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 538
		local viewWidth, viewHeight -- 539
		do -- 539
			local _obj_0 = View.size -- 539
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 539
		end -- 539
		local width, height = viewWidth - 20, viewHeight - 20 -- 540
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 541
		Director.ui:addChild((function() -- 542
			local root = AlignNode() -- 542
			do -- 543
				local _obj_0 = App.bufferSize -- 543
				width, height = _obj_0.width, _obj_0.height -- 543
			end -- 543
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 544
			root:gslot("AppSizeChanged", function() -- 545
				do -- 546
					local _obj_0 = App.bufferSize -- 546
					width, height = _obj_0.width, _obj_0.height -- 546
				end -- 546
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 547
			end) -- 545
			root:addChild((function() -- 548
				local _with_0 = ScrollArea({ -- 549
					width = width, -- 549
					height = height, -- 550
					paddingX = 0, -- 551
					paddingY = 50, -- 552
					viewWidth = height, -- 553
					viewHeight = height -- 554
				}) -- 548
				root:slot("AlignLayout", function(w, h) -- 556
					_with_0.position = Vec2(w / 2, h / 2) -- 557
					w = w - 20 -- 558
					h = h - 20 -- 559
					_with_0.view.children.first.textWidth = w - fontSize -- 560
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 561
				end) -- 556
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 562
				return _with_0 -- 548
			end)()) -- 548
			return root -- 542
		end)()) -- 542
		return err -- 566
	end, Content, Path, file, require, type) -- 566
end -- 513
_module_0["enterEntryAsync"] = enterEntryAsync -- 566
local enterDemoEntry -- 568
enterDemoEntry = function(entry) -- 568
	return thread(function() -- 568
		return enterEntryAsync(entry) -- 568
	end) -- 568
end -- 568
local reloadCurrentEntry -- 570
reloadCurrentEntry = function() -- 570
	if currentEntry then -- 571
		allClear() -- 572
		return enterDemoEntry(currentEntry) -- 573
	end -- 571
end -- 570
Director.clearColor = Color(0xff1a1a1a) -- 575
local waitForWebStart = true -- 577
thread(function() -- 578
	sleep(2) -- 579
	waitForWebStart = false -- 580
end) -- 578
local reloadDevEntry -- 582
reloadDevEntry = function() -- 582
	return thread(function() -- 582
		waitForWebStart = true -- 583
		doClean() -- 584
		allClear() -- 585
		_G.require = oldRequire -- 586
		Dora.require = oldRequire -- 587
		package.loaded["Script.Dev.Entry"] = nil -- 588
		return Director.systemScheduler:schedule(function() -- 589
			Routine:clear() -- 590
			oldRequire("Script.Dev.Entry") -- 591
			return true -- 592
		end) -- 592
	end) -- 592
end -- 582
local isOSSLicenseExist = Content:exist("LICENSES") -- 594
local ossLicenses = nil -- 595
local ossLicenseOpen = false -- 596
local extraOperations -- 598
extraOperations = function() -- 598
	local zh = useChinese and isChineseSupported -- 599
	if isOSSLicenseExist then -- 600
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 601
			if not ossLicenses then -- 602
				ossLicenses = { } -- 603
				local licenseText = Content:load("LICENSES") -- 604
				ossLicenseOpen = (licenseText ~= nil) -- 605
				if ossLicenseOpen then -- 605
					licenseText = licenseText:gsub("\r\n", "\n") -- 606
					for license in GSplit(licenseText, "\n--------\n", true) do -- 607
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 608
						if name then -- 608
							ossLicenses[#ossLicenses + 1] = { -- 609
								name, -- 609
								text -- 609
							} -- 609
						end -- 608
					end -- 609
				end -- 605
			else -- 611
				ossLicenseOpen = true -- 611
			end -- 602
		end -- 601
		if ossLicenseOpen then -- 612
			local width, height, themeColor -- 613
			do -- 613
				local _obj_0 = App -- 613
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 613
			end -- 613
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 614
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 615
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 616
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 619
					"NoSavedSettings" -- 619
				}, function() -- 620
					for _index_0 = 1, #ossLicenses do -- 620
						local _des_0 = ossLicenses[_index_0] -- 620
						local firstLine, text = _des_0[1], _des_0[2] -- 620
						local name, license = firstLine:match("(.+): (.+)") -- 621
						TextColored(themeColor, name) -- 622
						SameLine() -- 623
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 624
							return TextWrapped(text) -- 624
						end) -- 624
					end -- 624
				end) -- 616
			end) -- 616
		end -- 612
	end -- 600
	if not App.debugging then -- 626
		return -- 626
	end -- 626
	return TreeNode(zh and "开发操作" or "Development", function() -- 627
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 628
			OpenPopup("build") -- 628
		end -- 628
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 629
			return BeginPopup("build", function() -- 629
				if Selectable(zh and "编译" or "Compile") then -- 630
					doCompile(false) -- 630
				end -- 630
				Separator() -- 631
				if Selectable(zh and "压缩" or "Minify") then -- 632
					doCompile(true) -- 632
				end -- 632
				Separator() -- 633
				if Selectable(zh and "清理" or "Clean") then -- 634
					return doClean() -- 634
				end -- 634
			end) -- 634
		end) -- 629
		if isInEntry then -- 635
			if waitForWebStart then -- 636
				BeginDisabled(function() -- 637
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 637
				end) -- 637
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 638
				reloadDevEntry() -- 639
			end -- 636
		end -- 635
		do -- 640
			local changed -- 640
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 640
			if changed then -- 640
				View.scale = scaleContent and screenScale or 1 -- 641
			end -- 640
		end -- 640
		local changed -- 642
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 642
		if changed then -- 642
			config.engineDev = engineDev and 1 or 0 -- 643
		end -- 642
	end) -- 627
end -- 598
local transparant = Color(0x0) -- 645
local windowFlags = { -- 647
	"NoTitleBar", -- 647
	"NoResize", -- 648
	"NoMove", -- 649
	"NoCollapse", -- 650
	"NoSavedSettings", -- 651
	"NoBringToFrontOnFocus" -- 652
} -- 646
local initFooter = true -- 653
local _anon_func_2 = function(allEntries, currentIndex) -- 689
	if currentIndex > 1 then -- 689
		return allEntries[currentIndex - 1] -- 690
	else -- 692
		return allEntries[#allEntries] -- 692
	end -- 689
end -- 689
local _anon_func_3 = function(allEntries, currentIndex) -- 696
	if currentIndex < #allEntries then -- 696
		return allEntries[currentIndex + 1] -- 697
	else -- 699
		return allEntries[1] -- 699
	end -- 696
end -- 696
footerWindow = threadLoop(function() -- 654
	local zh = useChinese and isChineseSupported -- 655
	if HttpServer.wsConnectionCount > 0 then -- 656
		return -- 657
	end -- 656
	if Keyboard:isKeyDown("Escape") then -- 658
		allClear() -- 659
		App:shutdown() -- 660
	end -- 658
	do -- 661
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 662
		if ctrl and Keyboard:isKeyDown("Q") then -- 663
			stop() -- 664
		end -- 663
		if ctrl and Keyboard:isKeyDown("Z") then -- 665
			reloadCurrentEntry() -- 666
		end -- 665
		if ctrl and Keyboard:isKeyDown(",") then -- 667
			if showFooter then -- 668
				showStats = not showStats -- 668
			else -- 668
				showStats = true -- 668
			end -- 668
			showFooter = true -- 669
			config.showFooter = showFooter and 1 or 0 -- 670
			config.showStats = showStats and 1 or 0 -- 671
		end -- 667
		if ctrl and Keyboard:isKeyDown(".") then -- 672
			if showFooter then -- 673
				showConsole = not showConsole -- 673
			else -- 673
				showConsole = true -- 673
			end -- 673
			showFooter = true -- 674
			config.showFooter = showFooter and 1 or 0 -- 675
			config.showConsole = showConsole and 1 or 0 -- 676
		end -- 672
		if ctrl and Keyboard:isKeyDown("/") then -- 677
			showFooter = not showFooter -- 678
			config.showFooter = showFooter and 1 or 0 -- 679
		end -- 677
		local left = ctrl and Keyboard:isKeyDown("Left") -- 680
		local right = ctrl and Keyboard:isKeyDown("Right") -- 681
		local currentIndex = nil -- 682
		for i, entry in ipairs(allEntries) do -- 683
			if currentEntry == entry then -- 684
				currentIndex = i -- 685
			end -- 684
		end -- 685
		if left then -- 686
			allClear() -- 687
			if currentIndex == nil then -- 688
				currentIndex = #allEntries + 1 -- 688
			end -- 688
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 689
		end -- 686
		if right then -- 693
			allClear() -- 694
			if currentIndex == nil then -- 695
				currentIndex = 0 -- 695
			end -- 695
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 696
		end -- 693
	end -- 699
	if not showEntry then -- 700
		return -- 700
	end -- 700
	local width, height -- 702
	do -- 702
		local _obj_0 = App.visualSize -- 702
		width, height = _obj_0.width, _obj_0.height -- 702
	end -- 702
	SetNextWindowSize(Vec2(50, 50)) -- 703
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 704
	PushStyleColor("WindowBg", transparant, function() -- 705
		return Begin("Show", windowFlags, function() -- 705
			if isInEntry or width >= 540 then -- 706
				local changed -- 707
				changed, showFooter = Checkbox("##dev", showFooter) -- 707
				if changed then -- 707
					config.showFooter = showFooter and 1 or 0 -- 708
				end -- 707
			end -- 706
		end) -- 708
	end) -- 705
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 710
		reloadDevEntry() -- 714
	end -- 710
	if initFooter then -- 715
		initFooter = false -- 716
	else -- 718
		if not showFooter then -- 718
			return -- 718
		end -- 718
	end -- 715
	SetNextWindowSize(Vec2(width, 50)) -- 720
	SetNextWindowPos(Vec2(0, height - 50)) -- 721
	SetNextWindowBgAlpha(0.35) -- 722
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 723
		return Begin("Footer", windowFlags, function() -- 723
			Dummy(Vec2(width - 20, 0)) -- 724
			do -- 725
				local changed -- 725
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 725
				if changed then -- 725
					config.showStats = showStats and 1 or 0 -- 726
				end -- 725
			end -- 725
			SameLine() -- 727
			do -- 728
				local changed -- 728
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 728
				if changed then -- 728
					config.showConsole = showConsole and 1 or 0 -- 729
				end -- 728
			end -- 728
			if not isInEntry then -- 730
				SameLine() -- 731
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 732
					allClear() -- 733
					isInEntry = true -- 734
					currentEntry = nil -- 735
				end -- 732
				local currentIndex = nil -- 736
				for i, entry in ipairs(allEntries) do -- 737
					if currentEntry == entry then -- 738
						currentIndex = i -- 739
					end -- 738
				end -- 739
				if currentIndex then -- 740
					if currentIndex > 1 then -- 741
						SameLine() -- 742
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 743
							allClear() -- 744
							enterDemoEntry(allEntries[currentIndex - 1]) -- 745
						end -- 743
					end -- 741
					if currentIndex < #allEntries then -- 746
						SameLine() -- 747
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 748
							allClear() -- 749
							enterDemoEntry(allEntries[currentIndex + 1]) -- 750
						end -- 748
					end -- 746
				end -- 740
				SameLine() -- 751
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 752
					reloadCurrentEntry() -- 753
				end -- 752
			end -- 730
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 754
				if showStats then -- 755
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 756
					showStats = ShowStats(showStats, extraOperations) -- 757
					config.showStats = showStats and 1 or 0 -- 758
				end -- 755
				if showConsole then -- 759
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 760
					showConsole = ShowConsole(showConsole) -- 761
					config.showConsole = showConsole and 1 or 0 -- 762
				end -- 759
			end) -- 762
		end) -- 762
	end) -- 762
end) -- 654
local MaxWidth <const> = 800 -- 764
local displayWindowFlags = { -- 767
	"NoDecoration", -- 767
	"NoSavedSettings", -- 768
	"NoFocusOnAppearing", -- 769
	"NoNav", -- 770
	"NoMove", -- 771
	"NoScrollWithMouse", -- 772
	"AlwaysAutoResize", -- 773
	"NoBringToFrontOnFocus" -- 774
} -- 766
local webStatus = nil -- 776
local descColor = Color(0xffa1a1a1) -- 777
local gameOpen = #gamesInDev == 0 -- 778
local exampleOpen = false -- 779
local testOpen = false -- 780
local filterText = nil -- 781
local anyEntryMatched = false -- 782
local match -- 783
match = function(name) -- 783
	local res = not filterText or name:lower():match(filterText) -- 784
	if res then -- 785
		anyEntryMatched = true -- 785
	end -- 785
	return res -- 786
end -- 783
entryWindow = threadLoop(function() -- 788
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 789
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 790
	end -- 789
	if App.targetFPS ~= config.targetFPS then -- 791
		config.targetFPS = App.targetFPS -- 792
	end -- 791
	if View.vsync ~= (config.vsync == 1) then -- 793
		config.vsync = View.vsync and 1 or 0 -- 794
	end -- 793
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 795
		config.fixedFPS = Director.scheduler.fixedFPS -- 796
	end -- 795
	if Director.profilerSending ~= (config.webProfiler == 1) then -- 797
		config.webProfiler = Director.profilerSending and 1 or 0 -- 798
	end -- 797
	if not showEntry then -- 799
		return -- 799
	end -- 799
	if not isInEntry then -- 800
		return -- 800
	end -- 800
	local zh = useChinese and isChineseSupported -- 801
	if HttpServer.wsConnectionCount > 0 then -- 802
		local themeColor = App.themeColor -- 803
		local width, height -- 804
		do -- 804
			local _obj_0 = App.visualSize -- 804
			width, height = _obj_0.width, _obj_0.height -- 804
		end -- 804
		SetNextWindowBgAlpha(0.5) -- 805
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 806
		Begin("Web IDE Connected", displayWindowFlags, function() -- 807
			Separator() -- 808
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 809
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 810
			TextColored(descColor, slogon) -- 811
			return Separator() -- 812
		end) -- 807
		return -- 813
	end -- 802
	local themeColor = App.themeColor -- 815
	local fullWidth, height -- 816
	do -- 816
		local _obj_0 = App.visualSize -- 816
		fullWidth, height = _obj_0.width, _obj_0.height -- 816
	end -- 816
	SetNextWindowBgAlpha(0.85) -- 818
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 819
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 820
		return Begin("Web IDE", displayWindowFlags, function() -- 821
			Separator() -- 822
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 823
			local url -- 824
			do -- 824
				local _exp_0 -- 824
				if webStatus ~= nil then -- 824
					_exp_0 = webStatus.url -- 824
				end -- 824
				if _exp_0 ~= nil then -- 824
					url = _exp_0 -- 824
				else -- 824
					url = zh and '不可用' or 'not available' -- 824
				end -- 824
			end -- 824
			TextColored(descColor, url) -- 825
			return Separator() -- 826
		end) -- 826
	end) -- 820
	local width = math.min(MaxWidth, fullWidth) -- 828
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 829
	local maxColumns = math.max(math.floor(width / 200), 1) -- 830
	SetNextWindowPos(Vec2.zero) -- 831
	SetNextWindowBgAlpha(0) -- 832
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 833
		return Begin("Dora Dev", displayWindowFlags, function() -- 834
			Dummy(Vec2(fullWidth - 20, 0)) -- 835
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 836
			SameLine() -- 837
			if fullWidth >= 320 then -- 838
				Dummy(Vec2(fullWidth - 320, 0)) -- 839
				SameLine() -- 840
				SetNextItemWidth(-50) -- 841
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 842
					"AutoSelectAll" -- 842
				}) then -- 842
					config.filter = filterBuf:toString() -- 843
				end -- 842
			end -- 838
			Separator() -- 844
			return Dummy(Vec2(fullWidth - 20, 0)) -- 845
		end) -- 845
	end) -- 833
	anyEntryMatched = false -- 847
	SetNextWindowPos(Vec2(0, 50)) -- 848
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 849
	return PushStyleColor("WindowBg", transparant, function() -- 850
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 850
			return Begin("Content", windowFlags, function() -- 851
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 852
				if filterText then -- 853
					filterText = filterText:lower() -- 853
				end -- 853
				if #gamesInDev > 0 then -- 854
					for _index_0 = 1, #gamesInDev do -- 855
						local game = gamesInDev[_index_0] -- 855
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 856
						local showSep = false -- 857
						if match(gameName) then -- 858
							Columns(1, false) -- 859
							TextColored(themeColor, zh and "项目：" or "Project:") -- 860
							SameLine() -- 861
							Text(gameName) -- 862
							Separator() -- 863
							if bannerFile then -- 864
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 865
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 866
								local sizing <const> = 0.8 -- 867
								texHeight = displayWidth * sizing * texHeight / texWidth -- 868
								texWidth = displayWidth * sizing -- 869
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 870
								Dummy(Vec2(padding, 0)) -- 871
								SameLine() -- 872
								PushID(fileName, function() -- 873
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 874
										return enterDemoEntry(game) -- 875
									end -- 874
								end) -- 873
							else -- 877
								PushID(fileName, function() -- 877
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 878
										return enterDemoEntry(game) -- 879
									end -- 878
								end) -- 877
							end -- 864
							NextColumn() -- 880
							showSep = true -- 881
						end -- 858
						if #examples > 0 then -- 882
							local showExample = false -- 883
							for _index_1 = 1, #examples do -- 884
								local example = examples[_index_1] -- 884
								if match(example[1]) then -- 885
									showExample = true -- 886
									break -- 887
								end -- 885
							end -- 887
							if showExample then -- 888
								Columns(1, false) -- 889
								TextColored(themeColor, zh and "示例：" or "Example:") -- 890
								SameLine() -- 891
								Text(gameName) -- 892
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 893
									Columns(maxColumns, false) -- 894
									for _index_1 = 1, #examples do -- 895
										local example = examples[_index_1] -- 895
										if not match(example[1]) then -- 896
											goto _continue_0 -- 896
										end -- 896
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 897
											if Button(example[1], Vec2(-1, 40)) then -- 898
												enterDemoEntry(example) -- 899
											end -- 898
											return NextColumn() -- 900
										end) -- 897
										showSep = true -- 901
										::_continue_0:: -- 896
									end -- 901
								end) -- 893
							end -- 888
						end -- 882
						if #tests > 0 then -- 902
							local showTest = false -- 903
							for _index_1 = 1, #tests do -- 904
								local test = tests[_index_1] -- 904
								if match(test[1]) then -- 905
									showTest = true -- 906
									break -- 907
								end -- 905
							end -- 907
							if showTest then -- 908
								Columns(1, false) -- 909
								TextColored(themeColor, zh and "测试：" or "Test:") -- 910
								SameLine() -- 911
								Text(gameName) -- 912
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 913
									Columns(maxColumns, false) -- 914
									for _index_1 = 1, #tests do -- 915
										local test = tests[_index_1] -- 915
										if not match(test[1]) then -- 916
											goto _continue_0 -- 916
										end -- 916
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 917
											if Button(test[1], Vec2(-1, 40)) then -- 918
												enterDemoEntry(test) -- 919
											end -- 918
											return NextColumn() -- 920
										end) -- 917
										showSep = true -- 921
										::_continue_0:: -- 916
									end -- 921
								end) -- 913
							end -- 908
						end -- 902
						if showSep then -- 922
							Columns(1, false) -- 923
							Separator() -- 924
						end -- 922
					end -- 924
				end -- 854
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 925
					local showGame = false -- 926
					for _index_0 = 1, #games do -- 927
						local _des_0 = games[_index_0] -- 927
						local name = _des_0[1] -- 927
						if match(name) then -- 928
							showGame = true -- 928
						end -- 928
					end -- 928
					local showExample = false -- 929
					for _index_0 = 1, #doraExamples do -- 930
						local _des_0 = doraExamples[_index_0] -- 930
						local name = _des_0[1] -- 930
						if match(name) then -- 931
							showExample = true -- 931
						end -- 931
					end -- 931
					local showTest = false -- 932
					for _index_0 = 1, #doraTests do -- 933
						local _des_0 = doraTests[_index_0] -- 933
						local name = _des_0[1] -- 933
						if match(name) then -- 934
							showTest = true -- 934
						end -- 934
					end -- 934
					for _index_0 = 1, #cppTests do -- 935
						local _des_0 = cppTests[_index_0] -- 935
						local name = _des_0[1] -- 935
						if match(name) then -- 936
							showTest = true -- 936
						end -- 936
					end -- 936
					if not (showGame or showExample or showTest) then -- 937
						goto endEntry -- 937
					end -- 937
					Columns(1, false) -- 938
					TextColored(themeColor, "Dora SSR:") -- 939
					SameLine() -- 940
					Text(zh and "开发示例" or "Development Showcase") -- 941
					Separator() -- 942
					local demoViewWith <const> = 400 -- 943
					if #games > 0 and showGame then -- 944
						local opened -- 945
						if (filterText ~= nil) then -- 945
							opened = showGame -- 945
						else -- 945
							opened = false -- 945
						end -- 945
						SetNextItemOpen(gameOpen) -- 946
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 947
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 948
							Columns(columns, false) -- 949
							for _index_0 = 1, #games do -- 950
								local game = games[_index_0] -- 950
								if not match(game[1]) then -- 951
									goto _continue_0 -- 951
								end -- 951
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 952
								if columns > 1 then -- 953
									if bannerFile then -- 954
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 955
										local displayWidth <const> = demoViewWith - 40 -- 956
										texHeight = displayWidth * texHeight / texWidth -- 957
										texWidth = displayWidth -- 958
										Text(gameName) -- 959
										PushID(fileName, function() -- 960
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 961
												return enterDemoEntry(game) -- 962
											end -- 961
										end) -- 960
									else -- 964
										PushID(fileName, function() -- 964
											if Button(gameName, Vec2(-1, 40)) then -- 965
												return enterDemoEntry(game) -- 966
											end -- 965
										end) -- 964
									end -- 954
								else -- 968
									if bannerFile then -- 968
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 969
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 970
										local sizing = 0.8 -- 971
										texHeight = displayWidth * sizing * texHeight / texWidth -- 972
										texWidth = displayWidth * sizing -- 973
										if texWidth > 500 then -- 974
											sizing = 0.6 -- 975
											texHeight = displayWidth * sizing * texHeight / texWidth -- 976
											texWidth = displayWidth * sizing -- 977
										end -- 974
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 978
										Dummy(Vec2(padding, 0)) -- 979
										SameLine() -- 980
										Text(gameName) -- 981
										Dummy(Vec2(padding, 0)) -- 982
										SameLine() -- 983
										PushID(fileName, function() -- 984
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 985
												return enterDemoEntry(game) -- 986
											end -- 985
										end) -- 984
									else -- 988
										PushID(fileName, function() -- 988
											if Button(gameName, Vec2(-1, 40)) then -- 989
												return enterDemoEntry(game) -- 990
											end -- 989
										end) -- 988
									end -- 968
								end -- 953
								NextColumn() -- 991
								::_continue_0:: -- 951
							end -- 991
							Columns(1, false) -- 992
							opened = true -- 993
						end) -- 947
						gameOpen = opened -- 994
					end -- 944
					if #doraExamples > 0 and showExample then -- 995
						local opened -- 996
						if (filterText ~= nil) then -- 996
							opened = showExample -- 996
						else -- 996
							opened = false -- 996
						end -- 996
						SetNextItemOpen(exampleOpen) -- 997
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 998
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 999
								Columns(maxColumns, false) -- 1000
								for _index_0 = 1, #doraExamples do -- 1001
									local example = doraExamples[_index_0] -- 1001
									if not match(example[1]) then -- 1002
										goto _continue_0 -- 1002
									end -- 1002
									if Button(example[1], Vec2(-1, 40)) then -- 1003
										enterDemoEntry(example) -- 1004
									end -- 1003
									NextColumn() -- 1005
									::_continue_0:: -- 1002
								end -- 1005
								Columns(1, false) -- 1006
								opened = true -- 1007
							end) -- 999
						end) -- 998
						exampleOpen = opened -- 1008
					end -- 995
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1009
						local opened -- 1010
						if (filterText ~= nil) then -- 1010
							opened = showTest -- 1010
						else -- 1010
							opened = false -- 1010
						end -- 1010
						SetNextItemOpen(testOpen) -- 1011
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1012
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1013
								Columns(maxColumns, false) -- 1014
								for _index_0 = 1, #doraTests do -- 1015
									local test = doraTests[_index_0] -- 1015
									if not match(test[1]) then -- 1016
										goto _continue_0 -- 1016
									end -- 1016
									if Button(test[1], Vec2(-1, 40)) then -- 1017
										enterDemoEntry(test) -- 1018
									end -- 1017
									NextColumn() -- 1019
									::_continue_0:: -- 1016
								end -- 1019
								for _index_0 = 1, #cppTests do -- 1020
									local test = cppTests[_index_0] -- 1020
									if not match(test[1]) then -- 1021
										goto _continue_1 -- 1021
									end -- 1021
									if Button(test[1], Vec2(-1, 40)) then -- 1022
										enterDemoEntry(test) -- 1023
									end -- 1022
									NextColumn() -- 1024
									::_continue_1:: -- 1021
								end -- 1024
								opened = true -- 1025
							end) -- 1013
						end) -- 1012
						testOpen = opened -- 1026
					end -- 1009
				end -- 925
				::endEntry:: -- 1027
				if not anyEntryMatched then -- 1028
					SetNextWindowBgAlpha(0) -- 1029
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1030
					Begin("Entries Not Found", displayWindowFlags, function() -- 1031
						Separator() -- 1032
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1033
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1034
						return Separator() -- 1035
					end) -- 1031
				end -- 1028
				Columns(1, false) -- 1036
				Dummy(Vec2(100, 80)) -- 1037
				return ScrollWhenDraggingOnVoid() -- 1038
			end) -- 1038
		end) -- 1038
	end) -- 1038
end) -- 788
webStatus = require("Script.Dev.WebServer") -- 1040
return _module_0 -- 1040
