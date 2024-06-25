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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev") -- 41
config:load() -- 61
if (config.fpsLimited ~= nil) then -- 62
	App.fpsLimited = config.fpsLimited == 1 -- 63
else -- 65
	config.fpsLimited = App.fpsLimited and 1 or 0 -- 65
end -- 62
if (config.targetFPS ~= nil) then -- 67
	App.targetFPS = config.targetFPS -- 68
else -- 70
	config.targetFPS = App.targetFPS -- 70
end -- 67
if (config.vsync ~= nil) then -- 72
	View.vsync = config.vsync == 1 -- 73
else -- 75
	config.vsync = View.vsync and 1 or 0 -- 75
end -- 72
if (config.fixedFPS ~= nil) then -- 77
	Director.scheduler.fixedFPS = config.fixedFPS -- 78
else -- 80
	config.fixedFPS = Director.scheduler.fixedFPS -- 80
end -- 77
local showEntry = true -- 82
if (function() -- 84
	local _val_0 = App.platform -- 84
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 84
end)() then -- 84
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 85
		App.winSize = Size.zero -- 86
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 87
		local size = Size(config.winWidth, config.winHeight) -- 88
		if App.winSize ~= size then -- 89
			App.winSize = size -- 90
			showEntry = false -- 91
			thread(function() -- 92
				sleep() -- 93
				sleep() -- 94
				showEntry = true -- 95
			end) -- 92
		end -- 89
		local winX, winY -- 96
		do -- 96
			local _obj_0 = App.winPosition -- 96
			winX, winY = _obj_0.x, _obj_0.y -- 96
		end -- 96
		if (config.winX ~= nil) then -- 97
			winX = config.winX -- 98
		else -- 100
			config.winX = 0 -- 100
		end -- 97
		if (config.winY ~= nil) then -- 101
			winY = config.winY -- 102
		else -- 104
			config.winY = 0 -- 104
		end -- 101
		App.winPosition = Vec2(winX, winY) -- 105
	end -- 85
end -- 84
if (config.themeColor ~= nil) then -- 107
	App.themeColor = Color(config.themeColor) -- 108
else -- 110
	config.themeColor = App.themeColor:toARGB() -- 110
end -- 107
if not (config.locale ~= nil) then -- 112
	config.locale = App.locale -- 113
end -- 112
local showStats = false -- 115
if (config.showStats ~= nil) then -- 116
	showStats = config.showStats > 0 -- 117
else -- 119
	config.showStats = showStats and 1 or 0 -- 119
end -- 116
local showConsole = true -- 121
if (config.showConsole ~= nil) then -- 122
	showConsole = config.showConsole > 0 -- 123
else -- 125
	config.showConsole = showConsole and 1 or 0 -- 125
end -- 122
local showFooter = true -- 127
if (config.showFooter ~= nil) then -- 128
	showFooter = config.showFooter > 0 -- 129
else -- 131
	config.showFooter = showFooter and 1 or 0 -- 131
end -- 128
local filterBuf = Buffer(20) -- 133
if (config.filter ~= nil) then -- 134
	filterBuf:setString(config.filter) -- 135
else -- 137
	config.filter = "" -- 137
end -- 134
local engineDev = false -- 139
if (config.engineDev ~= nil) then -- 140
	engineDev = config.engineDev > 0 -- 141
else -- 143
	config.engineDev = engineDev and 1 or 0 -- 143
end -- 140
_module_0.getConfig = function() -- 145
	return config -- 145
end -- 145
_module_0.getEngineDev = function() -- 146
	if not App.debugging then -- 147
		return false -- 147
	end -- 147
	return config.engineDev > 0 -- 148
end -- 146
local Set, Struct, LintYueGlobals, GSplit -- 150
do -- 150
	local _obj_0 = require("Utils") -- 150
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 150
end -- 150
local yueext = yue.options.extension -- 151
local isChineseSupported = IsFontLoaded() -- 153
if not isChineseSupported then -- 154
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 155
		isChineseSupported = true -- 156
	end) -- 155
end -- 154
local building = false -- 158
local getAllFiles -- 160
getAllFiles = function(path, exts) -- 160
	local filters = Set(exts) -- 161
	local _accum_0 = { } -- 162
	local _len_0 = 1 -- 162
	local _list_0 = Content:getAllFiles(path) -- 162
	for _index_0 = 1, #_list_0 do -- 162
		local file = _list_0[_index_0] -- 162
		if not filters[Path:getExt(file)] then -- 163
			goto _continue_0 -- 163
		end -- 163
		_accum_0[_len_0] = file -- 164
		_len_0 = _len_0 + 1 -- 164
		::_continue_0:: -- 163
	end -- 164
	return _accum_0 -- 164
end -- 160
local getFileEntries -- 166
getFileEntries = function(path) -- 166
	local entries = { } -- 167
	local _list_0 = getAllFiles(path, { -- 168
		"lua", -- 168
		"xml", -- 168
		yueext, -- 168
		"tl" -- 168
	}) -- 168
	for _index_0 = 1, #_list_0 do -- 168
		local file = _list_0[_index_0] -- 168
		local entryName = Path:getName(file) -- 169
		local entryAdded = false -- 170
		for _index_1 = 1, #entries do -- 171
			local _des_0 = entries[_index_1] -- 171
			local ename = _des_0[1] -- 171
			if entryName == ename then -- 172
				entryAdded = true -- 173
				break -- 174
			end -- 172
		end -- 174
		if entryAdded then -- 175
			goto _continue_0 -- 175
		end -- 175
		local fileName = Path:replaceExt(file, "") -- 176
		fileName = Path(path, fileName) -- 177
		local entry = { -- 178
			entryName, -- 178
			fileName -- 178
		} -- 178
		entries[#entries + 1] = entry -- 179
		::_continue_0:: -- 169
	end -- 179
	table.sort(entries, function(a, b) -- 180
		return a[1] < b[1] -- 180
	end) -- 180
	return entries -- 181
end -- 166
local getProjectEntries -- 183
getProjectEntries = function(path) -- 183
	local entries = { } -- 184
	local _list_0 = Content:getDirs(path) -- 185
	for _index_0 = 1, #_list_0 do -- 185
		local dir = _list_0[_index_0] -- 185
		if dir:match("^%.") then -- 186
			goto _continue_0 -- 186
		end -- 186
		local _list_1 = getAllFiles(Path(path, dir), { -- 187
			"lua", -- 187
			"xml", -- 187
			yueext, -- 187
			"tl", -- 187
			"wasm" -- 187
		}) -- 187
		for _index_1 = 1, #_list_1 do -- 187
			local file = _list_1[_index_1] -- 187
			if "init" == Path:getName(file):lower() then -- 188
				local fileName = Path:replaceExt(file, "") -- 189
				fileName = Path(path, dir, fileName) -- 190
				local entryName = Path:getName(Path:getPath(fileName)) -- 191
				local entryAdded = false -- 192
				for _index_2 = 1, #entries do -- 193
					local _des_0 = entries[_index_2] -- 193
					local ename = _des_0[1] -- 193
					if entryName == ename then -- 194
						entryAdded = true -- 195
						break -- 196
					end -- 194
				end -- 196
				if entryAdded then -- 197
					goto _continue_1 -- 197
				end -- 197
				local examples = { } -- 198
				local tests = { } -- 199
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 200
				if Content:exist(examplePath) then -- 201
					local _list_2 = getFileEntries(examplePath) -- 202
					for _index_2 = 1, #_list_2 do -- 202
						local _des_0 = _list_2[_index_2] -- 202
						local name, ePath = _des_0[1], _des_0[2] -- 202
						local entry = { -- 203
							name, -- 203
							Path(path, dir, Path:getPath(file), ePath) -- 203
						} -- 203
						examples[#examples + 1] = entry -- 204
					end -- 204
				end -- 201
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 205
				if Content:exist(testPath) then -- 206
					local _list_2 = getFileEntries(testPath) -- 207
					for _index_2 = 1, #_list_2 do -- 207
						local _des_0 = _list_2[_index_2] -- 207
						local name, tPath = _des_0[1], _des_0[2] -- 207
						local entry = { -- 208
							name, -- 208
							Path(path, dir, Path:getPath(file), tPath) -- 208
						} -- 208
						tests[#tests + 1] = entry -- 209
					end -- 209
				end -- 206
				local entry = { -- 210
					entryName, -- 210
					fileName, -- 210
					examples, -- 210
					tests -- 210
				} -- 210
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 211
				if not Content:exist(bannerFile) then -- 212
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 213
					if not Content:exist(bannerFile) then -- 214
						bannerFile = nil -- 214
					end -- 214
				end -- 212
				if bannerFile then -- 215
					thread(function() -- 215
						Cache:loadAsync(bannerFile) -- 216
						local bannerTex = Texture2D(bannerFile) -- 217
						if bannerTex then -- 218
							entry[#entry + 1] = bannerFile -- 219
							entry[#entry + 1] = bannerTex -- 220
						end -- 218
					end) -- 215
				end -- 215
				entries[#entries + 1] = entry -- 221
			end -- 188
			::_continue_1:: -- 188
		end -- 221
		::_continue_0:: -- 186
	end -- 221
	table.sort(entries, function(a, b) -- 222
		return a[1] < b[1] -- 222
	end) -- 222
	return entries -- 223
end -- 183
local gamesInDev, games -- 225
local doraExamples, doraTests -- 226
local cppTests, cppTestSet -- 227
local allEntries -- 228
local updateEntries -- 230
updateEntries = function() -- 230
	gamesInDev = getProjectEntries(Content.writablePath) -- 231
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 232
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 234
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 235
	cppTests = { } -- 237
	local _list_0 = App.testNames -- 238
	for _index_0 = 1, #_list_0 do -- 238
		local name = _list_0[_index_0] -- 238
		local entry = { -- 239
			name -- 239
		} -- 239
		cppTests[#cppTests + 1] = entry -- 240
	end -- 240
	cppTestSet = Set(cppTests) -- 241
	allEntries = { } -- 243
	for _index_0 = 1, #gamesInDev do -- 244
		local game = gamesInDev[_index_0] -- 244
		allEntries[#allEntries + 1] = game -- 245
		local examples, tests = game[3], game[4] -- 246
		for _index_1 = 1, #examples do -- 247
			local example = examples[_index_1] -- 247
			allEntries[#allEntries + 1] = example -- 248
		end -- 248
		for _index_1 = 1, #tests do -- 249
			local test = tests[_index_1] -- 249
			allEntries[#allEntries + 1] = test -- 250
		end -- 250
	end -- 250
	for _index_0 = 1, #games do -- 251
		local game = games[_index_0] -- 251
		allEntries[#allEntries + 1] = game -- 252
		local examples, tests = game[3], game[4] -- 253
		for _index_1 = 1, #examples do -- 254
			local example = examples[_index_1] -- 254
			doraExamples[#doraExamples + 1] = example -- 255
		end -- 255
		for _index_1 = 1, #tests do -- 256
			local test = tests[_index_1] -- 256
			doraTests[#doraTests + 1] = test -- 257
		end -- 257
	end -- 257
	local _list_1 = { -- 259
		doraExamples, -- 259
		doraTests, -- 260
		cppTests -- 261
	} -- 258
	for _index_0 = 1, #_list_1 do -- 262
		local group = _list_1[_index_0] -- 258
		for _index_1 = 1, #group do -- 263
			local entry = group[_index_1] -- 263
			allEntries[#allEntries + 1] = entry -- 264
		end -- 264
	end -- 264
end -- 230
updateEntries() -- 266
local doCompile -- 268
doCompile = function(minify) -- 268
	if building then -- 269
		return -- 269
	end -- 269
	building = true -- 270
	local startTime = App.runningTime -- 271
	local luaFiles = { } -- 272
	local yueFiles = { } -- 273
	local xmlFiles = { } -- 274
	local tlFiles = { } -- 275
	local writablePath = Content.writablePath -- 276
	local buildPaths = { -- 278
		{ -- 279
			Path(Content.assetPath), -- 279
			Path(writablePath, ".build"), -- 280
			"" -- 281
		} -- 278
	} -- 277
	for _index_0 = 1, #gamesInDev do -- 284
		local _des_0 = gamesInDev[_index_0] -- 284
		local entryFile = _des_0[2] -- 284
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 285
		buildPaths[#buildPaths + 1] = { -- 287
			Path(writablePath, gamePath), -- 287
			Path(writablePath, ".build", gamePath), -- 288
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 289
			gamePath -- 290
		} -- 286
	end -- 290
	for _index_0 = 1, #buildPaths do -- 291
		local _des_0 = buildPaths[_index_0] -- 291
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 291
		if not Content:exist(inputPath) then -- 292
			goto _continue_0 -- 292
		end -- 292
		local _list_0 = getAllFiles(inputPath, { -- 294
			"lua" -- 294
		}) -- 294
		for _index_1 = 1, #_list_0 do -- 294
			local file = _list_0[_index_1] -- 294
			luaFiles[#luaFiles + 1] = { -- 296
				file, -- 296
				Path(inputPath, file), -- 297
				Path(outputPath, file), -- 298
				gamePath -- 299
			} -- 295
		end -- 299
		local _list_1 = getAllFiles(inputPath, { -- 301
			yueext -- 301
		}) -- 301
		for _index_1 = 1, #_list_1 do -- 301
			local file = _list_1[_index_1] -- 301
			yueFiles[#yueFiles + 1] = { -- 303
				file, -- 303
				Path(inputPath, file), -- 304
				Path(outputPath, Path:replaceExt(file, "lua")), -- 305
				searchPath, -- 306
				gamePath -- 307
			} -- 302
		end -- 307
		local _list_2 = getAllFiles(inputPath, { -- 309
			"xml" -- 309
		}) -- 309
		for _index_1 = 1, #_list_2 do -- 309
			local file = _list_2[_index_1] -- 309
			xmlFiles[#xmlFiles + 1] = { -- 311
				file, -- 311
				Path(inputPath, file), -- 312
				Path(outputPath, Path:replaceExt(file, "lua")), -- 313
				gamePath -- 314
			} -- 310
		end -- 314
		local _list_3 = getAllFiles(inputPath, { -- 316
			"tl" -- 316
		}) -- 316
		for _index_1 = 1, #_list_3 do -- 316
			local file = _list_3[_index_1] -- 316
			if not file:match(".*%.d%.tl$") then -- 317
				tlFiles[#tlFiles + 1] = { -- 319
					file, -- 319
					Path(inputPath, file), -- 320
					Path(outputPath, Path:replaceExt(file, "lua")), -- 321
					searchPath, -- 322
					gamePath -- 323
				} -- 318
			end -- 317
		end -- 323
		::_continue_0:: -- 292
	end -- 323
	local paths -- 325
	do -- 325
		local _tbl_0 = { } -- 325
		local _list_0 = { -- 326
			luaFiles, -- 326
			yueFiles, -- 326
			xmlFiles, -- 326
			tlFiles -- 326
		} -- 326
		for _index_0 = 1, #_list_0 do -- 326
			local files = _list_0[_index_0] -- 326
			for _index_1 = 1, #files do -- 327
				local file = files[_index_1] -- 327
				_tbl_0[Path:getPath(file[3])] = true -- 325
			end -- 325
		end -- 325
		paths = _tbl_0 -- 325
	end -- 327
	for path in pairs(paths) do -- 329
		Content:mkdir(path) -- 329
	end -- 329
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 331
	local fileCount = 0 -- 332
	local errors = { } -- 333
	for _index_0 = 1, #yueFiles do -- 334
		local _des_0 = yueFiles[_index_0] -- 334
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 334
		local filename -- 335
		if gamePath then -- 335
			filename = Path(gamePath, file) -- 335
		else -- 335
			filename = file -- 335
		end -- 335
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 336
			if not codes then -- 337
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 338
				return -- 339
			end -- 337
			local success, result = LintYueGlobals(codes, globals) -- 340
			if success then -- 341
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 342
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 343
				codes = codes:gsub("^\n*", "") -- 344
				if not (result == "") then -- 345
					result = result .. "\n" -- 345
				end -- 345
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 346
			else -- 348
				local yueCodes = Content:load(input) -- 348
				if yueCodes then -- 348
					local globalErrors = { } -- 349
					for _index_1 = 1, #result do -- 350
						local _des_1 = result[_index_1] -- 350
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 350
						local countLine = 1 -- 351
						local code = "" -- 352
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 353
							if countLine == line then -- 354
								code = lineCode -- 355
								break -- 356
							end -- 354
							countLine = countLine + 1 -- 357
						end -- 357
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 358
					end -- 358
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 359
				else -- 361
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 361
				end -- 348
			end -- 341
		end, function(success) -- 336
			if success then -- 362
				print("Yue compiled: " .. tostring(filename)) -- 362
			end -- 362
			fileCount = fileCount + 1 -- 363
		end) -- 336
	end -- 363
	thread(function() -- 365
		for _index_0 = 1, #xmlFiles do -- 366
			local _des_0 = xmlFiles[_index_0] -- 366
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 366
			local filename -- 367
			if gamePath then -- 367
				filename = Path(gamePath, file) -- 367
			else -- 367
				filename = file -- 367
			end -- 367
			local sourceCodes = Content:loadAsync(input) -- 368
			local codes, err = xml.tolua(sourceCodes) -- 369
			if not codes then -- 370
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 371
			else -- 373
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 373
				print("Xml compiled: " .. tostring(filename)) -- 374
			end -- 370
			fileCount = fileCount + 1 -- 375
		end -- 375
	end) -- 365
	thread(function() -- 377
		for _index_0 = 1, #tlFiles do -- 378
			local _des_0 = tlFiles[_index_0] -- 378
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 378
			local filename -- 379
			if gamePath then -- 379
				filename = Path(gamePath, file) -- 379
			else -- 379
				filename = file -- 379
			end -- 379
			local sourceCodes = Content:loadAsync(input) -- 380
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 381
			if not codes then -- 382
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 383
			else -- 385
				Content:saveAsync(output, codes) -- 385
				print("Teal compiled: " .. tostring(filename)) -- 386
			end -- 382
			fileCount = fileCount + 1 -- 387
		end -- 387
	end) -- 377
	return thread(function() -- 389
		wait(function() -- 390
			return fileCount == totalFiles -- 390
		end) -- 390
		if minify then -- 391
			local _list_0 = { -- 392
				yueFiles, -- 392
				xmlFiles, -- 392
				tlFiles -- 392
			} -- 392
			for _index_0 = 1, #_list_0 do -- 392
				local files = _list_0[_index_0] -- 392
				for _index_1 = 1, #files do -- 392
					local file = files[_index_1] -- 392
					local output = Path:replaceExt(file[3], "lua") -- 393
					luaFiles[#luaFiles + 1] = { -- 395
						Path:replaceExt(file[1], "lua"), -- 395
						output, -- 396
						output -- 397
					} -- 394
				end -- 397
			end -- 397
			local FormatMini -- 399
			do -- 399
				local _obj_0 = require("luaminify") -- 399
				FormatMini = _obj_0.FormatMini -- 399
			end -- 399
			for _index_0 = 1, #luaFiles do -- 400
				local _des_0 = luaFiles[_index_0] -- 400
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 400
				if Content:exist(input) then -- 401
					local sourceCodes = Content:loadAsync(input) -- 402
					local res, err = FormatMini(sourceCodes) -- 403
					if res then -- 404
						Content:saveAsync(output, res) -- 405
						print("Minify: " .. tostring(file)) -- 406
					else -- 408
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 408
					end -- 404
				else -- 410
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 410
				end -- 401
			end -- 410
			package.loaded["luaminify.FormatMini"] = nil -- 411
			package.loaded["luaminify.ParseLua"] = nil -- 412
			package.loaded["luaminify.Scope"] = nil -- 413
			package.loaded["luaminify.Util"] = nil -- 414
		end -- 391
		local errorMessage = table.concat(errors, "\n") -- 415
		if errorMessage ~= "" then -- 416
			print("\n" .. errorMessage) -- 416
		end -- 416
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 417
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 418
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 419
		Content:clearPathCache() -- 420
		teal.clear() -- 421
		yue.clear() -- 422
		building = false -- 423
	end) -- 423
end -- 268
local doClean -- 425
doClean = function() -- 425
	if building then -- 426
		return -- 426
	end -- 426
	local writablePath = Content.writablePath -- 427
	local targetDir = Path(writablePath, ".build") -- 428
	Content:clearPathCache() -- 429
	if Content:remove(targetDir) then -- 430
		print("Cleaned: " .. tostring(targetDir)) -- 431
	end -- 430
	Content:remove(Path(writablePath, ".upload")) -- 432
	return Content:remove(Path(writablePath, ".download")) -- 433
end -- 425
local screenScale = 2.0 -- 435
local scaleContent = false -- 436
local isInEntry = true -- 437
local currentEntry = nil -- 438
local footerWindow = nil -- 440
local entryWindow = nil -- 441
local setupEventHandlers = nil -- 443
local allClear -- 445
allClear = function() -- 445
	local _list_0 = Routine -- 446
	for _index_0 = 1, #_list_0 do -- 446
		local routine = _list_0[_index_0] -- 446
		if footerWindow == routine or entryWindow == routine then -- 448
			goto _continue_0 -- 449
		else -- 451
			Routine:remove(routine) -- 451
		end -- 451
		::_continue_0:: -- 447
	end -- 451
	for _index_0 = 1, #moduleCache do -- 452
		local module = moduleCache[_index_0] -- 452
		package.loaded[module] = nil -- 453
	end -- 453
	moduleCache = { } -- 454
	Director:cleanup() -- 455
	Cache:unload() -- 456
	Entity:clear() -- 457
	Platformer.Data:clear() -- 458
	Platformer.UnitAction:clear() -- 459
	Audio:stopStream(0.5) -- 460
	Struct:clear() -- 461
	View.postEffect = nil -- 462
	View.scale = scaleContent and screenScale or 1 -- 463
	Director.clearColor = Color(0xff1a1a1a) -- 464
	teal.clear() -- 465
	yue.clear() -- 466
	for _, item in pairs(ubox()) do -- 467
		local node = tolua.cast(item, "Node") -- 468
		if node then -- 468
			node:cleanup() -- 468
		end -- 468
	end -- 468
	collectgarbage() -- 469
	collectgarbage() -- 470
	setupEventHandlers() -- 471
	Content.searchPaths = searchPaths -- 472
	App.idled = true -- 473
	return Wasm:clear() -- 474
end -- 445
_module_0["allClear"] = allClear -- 474
setupEventHandlers = function() -- 476
	local _with_0 = Director.postNode -- 477
	_with_0:gslot("AppQuit", allClear) -- 478
	_with_0:gslot("AppTheme", function(argb) -- 479
		config.themeColor = argb -- 480
	end) -- 479
	_with_0:gslot("AppLocale", function(locale) -- 481
		config.locale = locale -- 482
		updateLocale() -- 483
		return teal.clear(true) -- 484
	end) -- 481
	_with_0:gslot("AppWSClose", function() -- 485
		if HttpServer.wsConnectionCount == 0 then -- 486
			return updateEntries() -- 487
		end -- 486
	end) -- 485
	local _exp_0 = App.platform -- 488
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 488
		_with_0:gslot("AppSizeChanged", function() -- 489
			local width, height -- 490
			do -- 490
				local _obj_0 = App.winSize -- 490
				width, height = _obj_0.width, _obj_0.height -- 490
			end -- 490
			config.winWidth = width -- 491
			config.winHeight = height -- 492
		end) -- 489
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 493
			config.fullScreen = fullScreen and 1 or 0 -- 494
		end) -- 493
		_with_0:gslot("AppMoved", function() -- 495
			local _obj_0 = App.winPosition -- 496
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 496
		end) -- 495
	end -- 496
	return _with_0 -- 477
end -- 476
setupEventHandlers() -- 498
local stop -- 500
stop = function() -- 500
	if isInEntry then -- 501
		return false -- 501
	end -- 501
	allClear() -- 502
	isInEntry = true -- 503
	currentEntry = nil -- 504
	return true -- 505
end -- 500
_module_0["stop"] = stop -- 505
local _anon_func_0 = function(Content, Path, file, require, type) -- 527
	local scriptPath = Path:getPath(file) -- 520
	Content:insertSearchPath(1, scriptPath) -- 521
	scriptPath = Path(scriptPath, "Script") -- 522
	if Content:exist(scriptPath) then -- 523
		Content:insertSearchPath(1, scriptPath) -- 524
	end -- 523
	local result = require(file) -- 525
	if "function" == type(result) then -- 526
		result() -- 526
	end -- 526
	return nil -- 527
end -- 520
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 559
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 556
	label.alignment = "Left" -- 557
	label.textWidth = width - fontSize -- 558
	label.text = err -- 559
	return label -- 556
end -- 556
local enterEntryAsync -- 507
enterEntryAsync = function(entry) -- 507
	isInEntry = false -- 508
	App.idled = false -- 509
	emit(Profiler.EventName, "ClearLoader") -- 510
	currentEntry = entry -- 511
	local name, file = entry[1], entry[2] -- 512
	if cppTestSet[entry] then -- 513
		if App:runTest(name) then -- 514
			return true -- 515
		else -- 517
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 517
		end -- 514
	end -- 513
	sleep() -- 518
	return xpcall(_anon_func_0, function(msg) -- 527
		local err = debug.traceback(msg) -- 529
		allClear() -- 530
		print(err) -- 531
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 532
		local viewWidth, viewHeight -- 533
		do -- 533
			local _obj_0 = View.size -- 533
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 533
		end -- 533
		local width, height = viewWidth - 20, viewHeight - 20 -- 534
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 535
		Director.ui:addChild((function() -- 536
			local root = AlignNode() -- 536
			do -- 537
				local _obj_0 = App.bufferSize -- 537
				width, height = _obj_0.width, _obj_0.height -- 537
			end -- 537
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 538
			root:gslot("AppSizeChanged", function() -- 539
				do -- 540
					local _obj_0 = App.bufferSize -- 540
					width, height = _obj_0.width, _obj_0.height -- 540
				end -- 540
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 541
			end) -- 539
			root:addChild((function() -- 542
				local _with_0 = ScrollArea({ -- 543
					width = width, -- 543
					height = height, -- 544
					paddingX = 0, -- 545
					paddingY = 50, -- 546
					viewWidth = height, -- 547
					viewHeight = height -- 548
				}) -- 542
				root:slot("AlignLayout", function(w, h) -- 550
					_with_0.position = Vec2(w / 2, h / 2) -- 551
					w = w - 20 -- 552
					h = h - 20 -- 553
					_with_0.view.children.first.textWidth = w - fontSize -- 554
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 555
				end) -- 550
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 556
				return _with_0 -- 542
			end)()) -- 542
			return root -- 536
		end)()) -- 536
		return err -- 560
	end, Content, Path, file, require, type) -- 560
end -- 507
_module_0["enterEntryAsync"] = enterEntryAsync -- 560
local enterDemoEntry -- 562
enterDemoEntry = function(entry) -- 562
	return thread(function() -- 562
		return enterEntryAsync(entry) -- 562
	end) -- 562
end -- 562
local reloadCurrentEntry -- 564
reloadCurrentEntry = function() -- 564
	if currentEntry then -- 565
		allClear() -- 566
		return enterDemoEntry(currentEntry) -- 567
	end -- 565
end -- 564
Director.clearColor = Color(0xff1a1a1a) -- 569
local waitForWebStart = true -- 571
thread(function() -- 572
	sleep(2) -- 573
	waitForWebStart = false -- 574
end) -- 572
local reloadDevEntry -- 576
reloadDevEntry = function() -- 576
	return thread(function() -- 576
		waitForWebStart = true -- 577
		doClean() -- 578
		allClear() -- 579
		_G.require = oldRequire -- 580
		Dora.require = oldRequire -- 581
		package.loaded["Script.Dev.Entry"] = nil -- 582
		return Director.systemScheduler:schedule(function() -- 583
			Routine:clear() -- 584
			oldRequire("Script.Dev.Entry") -- 585
			return true -- 586
		end) -- 586
	end) -- 586
end -- 576
local isOSSLicenseExist = Content:exist("LICENSES") -- 588
local ossLicenses = nil -- 589
local ossLicenseOpen = false -- 590
local extraOperations -- 592
extraOperations = function() -- 592
	local zh = useChinese and isChineseSupported -- 593
	if isOSSLicenseExist then -- 594
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 595
			if not ossLicenses then -- 596
				ossLicenses = { } -- 597
				local licenseText = Content:load("LICENSES") -- 598
				ossLicenseOpen = (licenseText ~= nil) -- 599
				if ossLicenseOpen then -- 599
					licenseText = licenseText:gsub("\r\n", "\n") -- 600
					for license in GSplit(licenseText, "\n--------\n", true) do -- 601
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 602
						if name then -- 602
							ossLicenses[#ossLicenses + 1] = { -- 603
								name, -- 603
								text -- 603
							} -- 603
						end -- 602
					end -- 603
				end -- 599
			else -- 605
				ossLicenseOpen = true -- 605
			end -- 596
		end -- 595
		if ossLicenseOpen then -- 606
			local width, height, themeColor -- 607
			do -- 607
				local _obj_0 = App -- 607
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 607
			end -- 607
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 608
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 609
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 610
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 613
					"NoSavedSettings" -- 613
				}, function() -- 614
					for _index_0 = 1, #ossLicenses do -- 614
						local _des_0 = ossLicenses[_index_0] -- 614
						local firstLine, text = _des_0[1], _des_0[2] -- 614
						local name, license = firstLine:match("(.+): (.+)") -- 615
						TextColored(themeColor, name) -- 616
						SameLine() -- 617
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 618
							return TextWrapped(text) -- 618
						end) -- 618
					end -- 618
				end) -- 610
			end) -- 610
		end -- 606
	end -- 594
	if not App.debugging then -- 620
		return -- 620
	end -- 620
	return TreeNode(zh and "开发操作" or "Development", function() -- 621
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 622
			OpenPopup("build") -- 622
		end -- 622
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 623
			return BeginPopup("build", function() -- 623
				if Selectable(zh and "编译" or "Compile") then -- 624
					doCompile(false) -- 624
				end -- 624
				Separator() -- 625
				if Selectable(zh and "压缩" or "Minify") then -- 626
					doCompile(true) -- 626
				end -- 626
				Separator() -- 627
				if Selectable(zh and "清理" or "Clean") then -- 628
					return doClean() -- 628
				end -- 628
			end) -- 628
		end) -- 623
		if isInEntry then -- 629
			if waitForWebStart then -- 630
				BeginDisabled(function() -- 631
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 631
				end) -- 631
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 632
				reloadDevEntry() -- 633
			end -- 630
		end -- 629
		do -- 634
			local changed -- 634
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 634
			if changed then -- 634
				View.scale = scaleContent and screenScale or 1 -- 635
			end -- 634
		end -- 634
		local changed -- 636
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 636
		if changed then -- 636
			config.engineDev = engineDev and 1 or 0 -- 637
		end -- 636
	end) -- 621
end -- 592
local transparant = Color(0x0) -- 639
local windowFlags = { -- 641
	"NoTitleBar", -- 641
	"NoResize", -- 642
	"NoMove", -- 643
	"NoCollapse", -- 644
	"NoSavedSettings", -- 645
	"NoBringToFrontOnFocus" -- 646
} -- 640
local initFooter = true -- 647
local _anon_func_2 = function(allEntries, currentIndex) -- 683
	if currentIndex > 1 then -- 683
		return allEntries[currentIndex - 1] -- 684
	else -- 686
		return allEntries[#allEntries] -- 686
	end -- 683
end -- 683
local _anon_func_3 = function(allEntries, currentIndex) -- 690
	if currentIndex < #allEntries then -- 690
		return allEntries[currentIndex + 1] -- 691
	else -- 693
		return allEntries[1] -- 693
	end -- 690
end -- 690
footerWindow = threadLoop(function() -- 648
	local zh = useChinese and isChineseSupported -- 649
	if HttpServer.wsConnectionCount > 0 then -- 650
		return -- 651
	end -- 650
	if Keyboard:isKeyDown("Escape") then -- 652
		allClear() -- 653
		App:shutdown() -- 654
	end -- 652
	do -- 655
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 656
		if ctrl and Keyboard:isKeyDown("Q") then -- 657
			stop() -- 658
		end -- 657
		if ctrl and Keyboard:isKeyDown("Z") then -- 659
			reloadCurrentEntry() -- 660
		end -- 659
		if ctrl and Keyboard:isKeyDown(",") then -- 661
			if showFooter then -- 662
				showStats = not showStats -- 662
			else -- 662
				showStats = true -- 662
			end -- 662
			showFooter = true -- 663
			config.showFooter = showFooter and 1 or 0 -- 664
			config.showStats = showStats and 1 or 0 -- 665
		end -- 661
		if ctrl and Keyboard:isKeyDown(".") then -- 666
			if showFooter then -- 667
				showConsole = not showConsole -- 667
			else -- 667
				showConsole = true -- 667
			end -- 667
			showFooter = true -- 668
			config.showFooter = showFooter and 1 or 0 -- 669
			config.showConsole = showConsole and 1 or 0 -- 670
		end -- 666
		if ctrl and Keyboard:isKeyDown("/") then -- 671
			showFooter = not showFooter -- 672
			config.showFooter = showFooter and 1 or 0 -- 673
		end -- 671
		local left = ctrl and Keyboard:isKeyDown("Left") -- 674
		local right = ctrl and Keyboard:isKeyDown("Right") -- 675
		local currentIndex = nil -- 676
		for i, entry in ipairs(allEntries) do -- 677
			if currentEntry == entry then -- 678
				currentIndex = i -- 679
			end -- 678
		end -- 679
		if left then -- 680
			allClear() -- 681
			if currentIndex == nil then -- 682
				currentIndex = #allEntries + 1 -- 682
			end -- 682
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 683
		end -- 680
		if right then -- 687
			allClear() -- 688
			if currentIndex == nil then -- 689
				currentIndex = 0 -- 689
			end -- 689
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 690
		end -- 687
	end -- 693
	if not showEntry then -- 694
		return -- 694
	end -- 694
	local width, height -- 696
	do -- 696
		local _obj_0 = App.visualSize -- 696
		width, height = _obj_0.width, _obj_0.height -- 696
	end -- 696
	SetNextWindowSize(Vec2(50, 50)) -- 697
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 698
	PushStyleColor("WindowBg", transparant, function() -- 699
		return Begin("Show", windowFlags, function() -- 699
			if isInEntry or width >= 540 then -- 700
				local changed -- 701
				changed, showFooter = Checkbox("##dev", showFooter) -- 701
				if changed then -- 701
					config.showFooter = showFooter and 1 or 0 -- 702
				end -- 701
			end -- 700
		end) -- 702
	end) -- 699
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 704
		reloadDevEntry() -- 708
	end -- 704
	if initFooter then -- 709
		initFooter = false -- 710
	else -- 712
		if not showFooter then -- 712
			return -- 712
		end -- 712
	end -- 709
	SetNextWindowSize(Vec2(width, 50)) -- 714
	SetNextWindowPos(Vec2(0, height - 50)) -- 715
	SetNextWindowBgAlpha(0.35) -- 716
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 717
		return Begin("Footer", windowFlags, function() -- 717
			Dummy(Vec2(width - 20, 0)) -- 718
			do -- 719
				local changed -- 719
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 719
				if changed then -- 719
					config.showStats = showStats and 1 or 0 -- 720
				end -- 719
			end -- 719
			SameLine() -- 721
			do -- 722
				local changed -- 722
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 722
				if changed then -- 722
					config.showConsole = showConsole and 1 or 0 -- 723
				end -- 722
			end -- 722
			if not isInEntry then -- 724
				SameLine() -- 725
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 726
					allClear() -- 727
					isInEntry = true -- 728
					currentEntry = nil -- 729
				end -- 726
				local currentIndex = nil -- 730
				for i, entry in ipairs(allEntries) do -- 731
					if currentEntry == entry then -- 732
						currentIndex = i -- 733
					end -- 732
				end -- 733
				if currentIndex then -- 734
					if currentIndex > 1 then -- 735
						SameLine() -- 736
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 737
							allClear() -- 738
							enterDemoEntry(allEntries[currentIndex - 1]) -- 739
						end -- 737
					end -- 735
					if currentIndex < #allEntries then -- 740
						SameLine() -- 741
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 742
							allClear() -- 743
							enterDemoEntry(allEntries[currentIndex + 1]) -- 744
						end -- 742
					end -- 740
				end -- 734
				SameLine() -- 745
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 746
					reloadCurrentEntry() -- 747
				end -- 746
			end -- 724
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 748
				if showStats then -- 749
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 750
					showStats = ShowStats(showStats, extraOperations) -- 751
					config.showStats = showStats and 1 or 0 -- 752
				end -- 749
				if showConsole then -- 753
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 754
					showConsole = ShowConsole(showConsole) -- 755
					config.showConsole = showConsole and 1 or 0 -- 756
				end -- 753
			end) -- 756
		end) -- 756
	end) -- 756
end) -- 648
local MaxWidth <const> = 800 -- 758
local displayWindowFlags = { -- 761
	"NoDecoration", -- 761
	"NoSavedSettings", -- 762
	"NoFocusOnAppearing", -- 763
	"NoNav", -- 764
	"NoMove", -- 765
	"NoScrollWithMouse", -- 766
	"AlwaysAutoResize", -- 767
	"NoBringToFrontOnFocus" -- 768
} -- 760
local webStatus = nil -- 770
local descColor = Color(0xffa1a1a1) -- 771
local gameOpen = #gamesInDev == 0 -- 772
local exampleOpen = false -- 773
local testOpen = false -- 774
local filterText = nil -- 775
local anyEntryMatched = false -- 776
local match -- 777
match = function(name) -- 777
	local res = not filterText or name:lower():match(filterText) -- 778
	if res then -- 779
		anyEntryMatched = true -- 779
	end -- 779
	return res -- 780
end -- 777
entryWindow = threadLoop(function() -- 782
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 783
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 784
	end -- 783
	if App.targetFPS ~= config.targetFPS then -- 785
		config.targetFPS = App.targetFPS -- 786
	end -- 785
	if View.vsync ~= (config.vsync == 1) then -- 787
		config.vsync = View.vsync and 1 or 0 -- 788
	end -- 787
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 789
		config.fixedFPS = Director.scheduler.fixedFPS -- 790
	end -- 789
	if not showEntry then -- 791
		return -- 791
	end -- 791
	if not isInEntry then -- 792
		return -- 792
	end -- 792
	local zh = useChinese and isChineseSupported -- 793
	if HttpServer.wsConnectionCount > 0 then -- 794
		local themeColor = App.themeColor -- 795
		local width, height -- 796
		do -- 796
			local _obj_0 = App.visualSize -- 796
			width, height = _obj_0.width, _obj_0.height -- 796
		end -- 796
		SetNextWindowBgAlpha(0.5) -- 797
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 798
		Begin("Web IDE Connected", displayWindowFlags, function() -- 799
			Separator() -- 800
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 801
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 802
			TextColored(descColor, slogon) -- 803
			return Separator() -- 804
		end) -- 799
		return -- 805
	end -- 794
	local themeColor = App.themeColor -- 807
	local fullWidth, height -- 808
	do -- 808
		local _obj_0 = App.visualSize -- 808
		fullWidth, height = _obj_0.width, _obj_0.height -- 808
	end -- 808
	SetNextWindowBgAlpha(0.85) -- 810
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 811
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 812
		return Begin("Web IDE", displayWindowFlags, function() -- 813
			Separator() -- 814
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 815
			local url -- 816
			do -- 816
				local _exp_0 -- 816
				if webStatus ~= nil then -- 816
					_exp_0 = webStatus.url -- 816
				end -- 816
				if _exp_0 ~= nil then -- 816
					url = _exp_0 -- 816
				else -- 816
					url = zh and '不可用' or 'not available' -- 816
				end -- 816
			end -- 816
			TextColored(descColor, url) -- 817
			return Separator() -- 818
		end) -- 818
	end) -- 812
	local width = math.min(MaxWidth, fullWidth) -- 820
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 821
	local maxColumns = math.max(math.floor(width / 200), 1) -- 822
	SetNextWindowPos(Vec2.zero) -- 823
	SetNextWindowBgAlpha(0) -- 824
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 825
		return Begin("Dora Dev", displayWindowFlags, function() -- 826
			Dummy(Vec2(fullWidth - 20, 0)) -- 827
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 828
			SameLine() -- 829
			if fullWidth >= 320 then -- 830
				Dummy(Vec2(fullWidth - 320, 0)) -- 831
				SameLine() -- 832
				SetNextItemWidth(-50) -- 833
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 834
					"AutoSelectAll" -- 834
				}) then -- 834
					config.filter = filterBuf:toString() -- 835
				end -- 834
			end -- 830
			Separator() -- 836
			return Dummy(Vec2(fullWidth - 20, 0)) -- 837
		end) -- 837
	end) -- 825
	anyEntryMatched = false -- 839
	SetNextWindowPos(Vec2(0, 50)) -- 840
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 841
	return PushStyleColor("WindowBg", transparant, function() -- 842
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 842
			return Begin("Content", windowFlags, function() -- 843
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 844
				if filterText then -- 845
					filterText = filterText:lower() -- 845
				end -- 845
				if #gamesInDev > 0 then -- 846
					for _index_0 = 1, #gamesInDev do -- 847
						local game = gamesInDev[_index_0] -- 847
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 848
						local showSep = false -- 849
						if match(gameName) then -- 850
							Columns(1, false) -- 851
							TextColored(themeColor, zh and "项目：" or "Project:") -- 852
							SameLine() -- 853
							Text(gameName) -- 854
							Separator() -- 855
							if bannerFile then -- 856
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 857
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 858
								local sizing <const> = 0.8 -- 859
								texHeight = displayWidth * sizing * texHeight / texWidth -- 860
								texWidth = displayWidth * sizing -- 861
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 862
								Dummy(Vec2(padding, 0)) -- 863
								SameLine() -- 864
								PushID(fileName, function() -- 865
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 866
										return enterDemoEntry(game) -- 867
									end -- 866
								end) -- 865
							else -- 869
								PushID(fileName, function() -- 869
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 870
										return enterDemoEntry(game) -- 871
									end -- 870
								end) -- 869
							end -- 856
							NextColumn() -- 872
							showSep = true -- 873
						end -- 850
						if #examples > 0 then -- 874
							local showExample = false -- 875
							for _index_1 = 1, #examples do -- 876
								local example = examples[_index_1] -- 876
								if match(example[1]) then -- 877
									showExample = true -- 878
									break -- 879
								end -- 877
							end -- 879
							if showExample then -- 880
								Columns(1, false) -- 881
								TextColored(themeColor, zh and "示例：" or "Example:") -- 882
								SameLine() -- 883
								Text(gameName) -- 884
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 885
									Columns(maxColumns, false) -- 886
									for _index_1 = 1, #examples do -- 887
										local example = examples[_index_1] -- 887
										if not match(example[1]) then -- 888
											goto _continue_0 -- 888
										end -- 888
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 889
											if Button(example[1], Vec2(-1, 40)) then -- 890
												enterDemoEntry(example) -- 891
											end -- 890
											return NextColumn() -- 892
										end) -- 889
										showSep = true -- 893
										::_continue_0:: -- 888
									end -- 893
								end) -- 885
							end -- 880
						end -- 874
						if #tests > 0 then -- 894
							local showTest = false -- 895
							for _index_1 = 1, #tests do -- 896
								local test = tests[_index_1] -- 896
								if match(test[1]) then -- 897
									showTest = true -- 898
									break -- 899
								end -- 897
							end -- 899
							if showTest then -- 900
								Columns(1, false) -- 901
								TextColored(themeColor, zh and "测试：" or "Test:") -- 902
								SameLine() -- 903
								Text(gameName) -- 904
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 905
									Columns(maxColumns, false) -- 906
									for _index_1 = 1, #tests do -- 907
										local test = tests[_index_1] -- 907
										if not match(test[1]) then -- 908
											goto _continue_0 -- 908
										end -- 908
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 909
											if Button(test[1], Vec2(-1, 40)) then -- 910
												enterDemoEntry(test) -- 911
											end -- 910
											return NextColumn() -- 912
										end) -- 909
										showSep = true -- 913
										::_continue_0:: -- 908
									end -- 913
								end) -- 905
							end -- 900
						end -- 894
						if showSep then -- 914
							Columns(1, false) -- 915
							Separator() -- 916
						end -- 914
					end -- 916
				end -- 846
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 917
					local showGame = false -- 918
					for _index_0 = 1, #games do -- 919
						local _des_0 = games[_index_0] -- 919
						local name = _des_0[1] -- 919
						if match(name) then -- 920
							showGame = true -- 920
						end -- 920
					end -- 920
					local showExample = false -- 921
					for _index_0 = 1, #doraExamples do -- 922
						local _des_0 = doraExamples[_index_0] -- 922
						local name = _des_0[1] -- 922
						if match(name) then -- 923
							showExample = true -- 923
						end -- 923
					end -- 923
					local showTest = false -- 924
					for _index_0 = 1, #doraTests do -- 925
						local _des_0 = doraTests[_index_0] -- 925
						local name = _des_0[1] -- 925
						if match(name) then -- 926
							showTest = true -- 926
						end -- 926
					end -- 926
					for _index_0 = 1, #cppTests do -- 927
						local _des_0 = cppTests[_index_0] -- 927
						local name = _des_0[1] -- 927
						if match(name) then -- 928
							showTest = true -- 928
						end -- 928
					end -- 928
					if not (showGame or showExample or showTest) then -- 929
						goto endEntry -- 929
					end -- 929
					Columns(1, false) -- 930
					TextColored(themeColor, "Dora SSR:") -- 931
					SameLine() -- 932
					Text(zh and "开发示例" or "Development Showcase") -- 933
					Separator() -- 934
					local demoViewWith <const> = 400 -- 935
					if #games > 0 and showGame then -- 936
						local opened -- 937
						if (filterText ~= nil) then -- 937
							opened = showGame -- 937
						else -- 937
							opened = false -- 937
						end -- 937
						SetNextItemOpen(gameOpen) -- 938
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 939
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 940
							Columns(columns, false) -- 941
							for _index_0 = 1, #games do -- 942
								local game = games[_index_0] -- 942
								if not match(game[1]) then -- 943
									goto _continue_0 -- 943
								end -- 943
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 944
								if columns > 1 then -- 945
									if bannerFile then -- 946
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 947
										local displayWidth <const> = demoViewWith - 40 -- 948
										texHeight = displayWidth * texHeight / texWidth -- 949
										texWidth = displayWidth -- 950
										Text(gameName) -- 951
										PushID(fileName, function() -- 952
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 953
												return enterDemoEntry(game) -- 954
											end -- 953
										end) -- 952
									else -- 956
										PushID(fileName, function() -- 956
											if Button(gameName, Vec2(-1, 40)) then -- 957
												return enterDemoEntry(game) -- 958
											end -- 957
										end) -- 956
									end -- 946
								else -- 960
									if bannerFile then -- 960
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 961
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 962
										local sizing = 0.8 -- 963
										texHeight = displayWidth * sizing * texHeight / texWidth -- 964
										texWidth = displayWidth * sizing -- 965
										if texWidth > 500 then -- 966
											sizing = 0.6 -- 967
											texHeight = displayWidth * sizing * texHeight / texWidth -- 968
											texWidth = displayWidth * sizing -- 969
										end -- 966
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 970
										Dummy(Vec2(padding, 0)) -- 971
										SameLine() -- 972
										Text(gameName) -- 973
										Dummy(Vec2(padding, 0)) -- 974
										SameLine() -- 975
										PushID(fileName, function() -- 976
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 977
												return enterDemoEntry(game) -- 978
											end -- 977
										end) -- 976
									else -- 980
										PushID(fileName, function() -- 980
											if Button(gameName, Vec2(-1, 40)) then -- 981
												return enterDemoEntry(game) -- 982
											end -- 981
										end) -- 980
									end -- 960
								end -- 945
								NextColumn() -- 983
								::_continue_0:: -- 943
							end -- 983
							Columns(1, false) -- 984
							opened = true -- 985
						end) -- 939
						gameOpen = opened -- 986
					end -- 936
					if #doraExamples > 0 and showExample then -- 987
						local opened -- 988
						if (filterText ~= nil) then -- 988
							opened = showExample -- 988
						else -- 988
							opened = false -- 988
						end -- 988
						SetNextItemOpen(exampleOpen) -- 989
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 990
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 991
								Columns(maxColumns, false) -- 992
								for _index_0 = 1, #doraExamples do -- 993
									local example = doraExamples[_index_0] -- 993
									if not match(example[1]) then -- 994
										goto _continue_0 -- 994
									end -- 994
									if Button(example[1], Vec2(-1, 40)) then -- 995
										enterDemoEntry(example) -- 996
									end -- 995
									NextColumn() -- 997
									::_continue_0:: -- 994
								end -- 997
								Columns(1, false) -- 998
								opened = true -- 999
							end) -- 991
						end) -- 990
						exampleOpen = opened -- 1000
					end -- 987
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1001
						local opened -- 1002
						if (filterText ~= nil) then -- 1002
							opened = showTest -- 1002
						else -- 1002
							opened = false -- 1002
						end -- 1002
						SetNextItemOpen(testOpen) -- 1003
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1004
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1005
								Columns(maxColumns, false) -- 1006
								for _index_0 = 1, #doraTests do -- 1007
									local test = doraTests[_index_0] -- 1007
									if not match(test[1]) then -- 1008
										goto _continue_0 -- 1008
									end -- 1008
									if Button(test[1], Vec2(-1, 40)) then -- 1009
										enterDemoEntry(test) -- 1010
									end -- 1009
									NextColumn() -- 1011
									::_continue_0:: -- 1008
								end -- 1011
								for _index_0 = 1, #cppTests do -- 1012
									local test = cppTests[_index_0] -- 1012
									if not match(test[1]) then -- 1013
										goto _continue_1 -- 1013
									end -- 1013
									if Button(test[1], Vec2(-1, 40)) then -- 1014
										enterDemoEntry(test) -- 1015
									end -- 1014
									NextColumn() -- 1016
									::_continue_1:: -- 1013
								end -- 1016
								opened = true -- 1017
							end) -- 1005
						end) -- 1004
						testOpen = opened -- 1018
					end -- 1001
				end -- 917
				::endEntry:: -- 1019
				if not anyEntryMatched then -- 1020
					SetNextWindowBgAlpha(0) -- 1021
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1022
					Begin("Entries Not Found", displayWindowFlags, function() -- 1023
						Separator() -- 1024
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1025
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1026
						return Separator() -- 1027
					end) -- 1023
				end -- 1020
				Columns(1, false) -- 1028
				Dummy(Vec2(100, 80)) -- 1029
				return ScrollWhenDraggingOnVoid() -- 1030
			end) -- 1030
		end) -- 1030
	end) -- 1030
end) -- 782
webStatus = require("Script.Dev.WebServer") -- 1032
return _module_0 -- 1032
