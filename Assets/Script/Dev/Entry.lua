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
local _anon_func_0 = function(Content, Path, file, require, type) -- 526
	local scriptPath = Path:getPath(file) -- 519
	Content:insertSearchPath(1, scriptPath) -- 520
	scriptPath = Path(scriptPath, "Script") -- 521
	if Content:exist(scriptPath) then -- 522
		Content:insertSearchPath(1, scriptPath) -- 523
	end -- 522
	local result = require(file) -- 524
	if "function" == type(result) then -- 525
		result() -- 525
	end -- 525
	return nil -- 526
end -- 519
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 558
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 555
	label.alignment = "Left" -- 556
	label.textWidth = width - fontSize -- 557
	label.text = err -- 558
	return label -- 555
end -- 555
local enterEntryAsync -- 507
enterEntryAsync = function(entry) -- 507
	isInEntry = false -- 508
	App.idled = false -- 509
	currentEntry = entry -- 510
	local name, file = entry[1], entry[2] -- 511
	if cppTestSet[entry] then -- 512
		if App:runTest(name) then -- 513
			return true -- 514
		else -- 516
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 516
		end -- 513
	end -- 512
	sleep() -- 517
	return xpcall(_anon_func_0, function(msg) -- 526
		local err = debug.traceback(msg) -- 528
		allClear() -- 529
		print(err) -- 530
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 531
		local viewWidth, viewHeight -- 532
		do -- 532
			local _obj_0 = View.size -- 532
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 532
		end -- 532
		local width, height = viewWidth - 20, viewHeight - 20 -- 533
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 534
		Director.ui:addChild((function() -- 535
			local root = AlignNode() -- 535
			do -- 536
				local _obj_0 = App.bufferSize -- 536
				width, height = _obj_0.width, _obj_0.height -- 536
			end -- 536
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 537
			root:gslot("AppSizeChanged", function() -- 538
				do -- 539
					local _obj_0 = App.bufferSize -- 539
					width, height = _obj_0.width, _obj_0.height -- 539
				end -- 539
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 540
			end) -- 538
			root:addChild((function() -- 541
				local _with_0 = ScrollArea({ -- 542
					width = width, -- 542
					height = height, -- 543
					paddingX = 0, -- 544
					paddingY = 50, -- 545
					viewWidth = height, -- 546
					viewHeight = height -- 547
				}) -- 541
				root:slot("AlignLayout", function(w, h) -- 549
					_with_0.position = Vec2(w / 2, h / 2) -- 550
					w = w - 20 -- 551
					h = h - 20 -- 552
					_with_0.view.children.first.textWidth = w - fontSize -- 553
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 554
				end) -- 549
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 555
				return _with_0 -- 541
			end)()) -- 541
			return root -- 535
		end)()) -- 535
		return err -- 559
	end, Content, Path, file, require, type) -- 559
end -- 507
_module_0["enterEntryAsync"] = enterEntryAsync -- 559
local enterDemoEntry -- 561
enterDemoEntry = function(entry) -- 561
	return thread(function() -- 561
		return enterEntryAsync(entry) -- 561
	end) -- 561
end -- 561
local reloadCurrentEntry -- 563
reloadCurrentEntry = function() -- 563
	if currentEntry then -- 564
		allClear() -- 565
		return enterDemoEntry(currentEntry) -- 566
	end -- 564
end -- 563
Director.clearColor = Color(0xff1a1a1a) -- 568
local waitForWebStart = true -- 570
thread(function() -- 571
	sleep(2) -- 572
	waitForWebStart = false -- 573
end) -- 571
local reloadDevEntry -- 575
reloadDevEntry = function() -- 575
	return thread(function() -- 575
		waitForWebStart = true -- 576
		doClean() -- 577
		allClear() -- 578
		_G.require = oldRequire -- 579
		Dora.require = oldRequire -- 580
		package.loaded["Script.Dev.Entry"] = nil -- 581
		return Director.systemScheduler:schedule(function() -- 582
			Routine:clear() -- 583
			oldRequire("Script.Dev.Entry") -- 584
			return true -- 585
		end) -- 585
	end) -- 585
end -- 575
local isOSSLicenseExist = Content:exist("LICENSES") -- 587
local ossLicenses = nil -- 588
local ossLicenseOpen = false -- 589
local extraOperations -- 591
extraOperations = function() -- 591
	local zh = useChinese and isChineseSupported -- 592
	if isOSSLicenseExist then -- 593
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 594
			if not ossLicenses then -- 595
				ossLicenses = { } -- 596
				local licenseText = Content:load("LICENSES") -- 597
				ossLicenseOpen = (licenseText ~= nil) -- 598
				if ossLicenseOpen then -- 598
					licenseText = licenseText:gsub("\r\n", "\n") -- 599
					for license in GSplit(licenseText, "\n--------\n", true) do -- 600
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 601
						if name then -- 601
							ossLicenses[#ossLicenses + 1] = { -- 602
								name, -- 602
								text -- 602
							} -- 602
						end -- 601
					end -- 602
				end -- 598
			else -- 604
				ossLicenseOpen = true -- 604
			end -- 595
		end -- 594
		if ossLicenseOpen then -- 605
			local width, height, themeColor -- 606
			do -- 606
				local _obj_0 = App -- 606
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 606
			end -- 606
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 607
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 608
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 609
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 612
					"NoSavedSettings" -- 612
				}, function() -- 613
					for _index_0 = 1, #ossLicenses do -- 613
						local _des_0 = ossLicenses[_index_0] -- 613
						local firstLine, text = _des_0[1], _des_0[2] -- 613
						local name, license = firstLine:match("(.+): (.+)") -- 614
						TextColored(themeColor, name) -- 615
						SameLine() -- 616
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 617
							return TextWrapped(text) -- 617
						end) -- 617
					end -- 617
				end) -- 609
			end) -- 609
		end -- 605
	end -- 593
	if not App.debugging then -- 619
		return -- 619
	end -- 619
	return TreeNode(zh and "开发操作" or "Development", function() -- 620
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 621
			OpenPopup("build") -- 621
		end -- 621
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 622
			return BeginPopup("build", function() -- 622
				if Selectable(zh and "编译" or "Compile") then -- 623
					doCompile(false) -- 623
				end -- 623
				Separator() -- 624
				if Selectable(zh and "压缩" or "Minify") then -- 625
					doCompile(true) -- 625
				end -- 625
				Separator() -- 626
				if Selectable(zh and "清理" or "Clean") then -- 627
					return doClean() -- 627
				end -- 627
			end) -- 627
		end) -- 622
		if isInEntry then -- 628
			if waitForWebStart then -- 629
				BeginDisabled(function() -- 630
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 630
				end) -- 630
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 631
				reloadDevEntry() -- 632
			end -- 629
		end -- 628
		do -- 633
			local changed -- 633
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 633
			if changed then -- 633
				View.scale = scaleContent and screenScale or 1 -- 634
			end -- 633
		end -- 633
		local changed -- 635
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 635
		if changed then -- 635
			config.engineDev = engineDev and 1 or 0 -- 636
		end -- 635
	end) -- 620
end -- 591
local transparant = Color(0x0) -- 638
local windowFlags = { -- 640
	"NoTitleBar", -- 640
	"NoResize", -- 641
	"NoMove", -- 642
	"NoCollapse", -- 643
	"NoSavedSettings", -- 644
	"NoBringToFrontOnFocus" -- 645
} -- 639
local initFooter = true -- 646
local _anon_func_2 = function(allEntries, currentIndex) -- 682
	if currentIndex > 1 then -- 682
		return allEntries[currentIndex - 1] -- 683
	else -- 685
		return allEntries[#allEntries] -- 685
	end -- 682
end -- 682
local _anon_func_3 = function(allEntries, currentIndex) -- 689
	if currentIndex < #allEntries then -- 689
		return allEntries[currentIndex + 1] -- 690
	else -- 692
		return allEntries[1] -- 692
	end -- 689
end -- 689
footerWindow = threadLoop(function() -- 647
	local zh = useChinese and isChineseSupported -- 648
	if HttpServer.wsConnectionCount > 0 then -- 649
		return -- 650
	end -- 649
	if Keyboard:isKeyDown("Escape") then -- 651
		allClear() -- 652
		App:shutdown() -- 653
	end -- 651
	do -- 654
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 655
		if ctrl and Keyboard:isKeyDown("Q") then -- 656
			stop() -- 657
		end -- 656
		if ctrl and Keyboard:isKeyDown("Z") then -- 658
			reloadCurrentEntry() -- 659
		end -- 658
		if ctrl and Keyboard:isKeyDown(",") then -- 660
			if showFooter then -- 661
				showStats = not showStats -- 661
			else -- 661
				showStats = true -- 661
			end -- 661
			showFooter = true -- 662
			config.showFooter = showFooter and 1 or 0 -- 663
			config.showStats = showStats and 1 or 0 -- 664
		end -- 660
		if ctrl and Keyboard:isKeyDown(".") then -- 665
			if showFooter then -- 666
				showConsole = not showConsole -- 666
			else -- 666
				showConsole = true -- 666
			end -- 666
			showFooter = true -- 667
			config.showFooter = showFooter and 1 or 0 -- 668
			config.showConsole = showConsole and 1 or 0 -- 669
		end -- 665
		if ctrl and Keyboard:isKeyDown("/") then -- 670
			showFooter = not showFooter -- 671
			config.showFooter = showFooter and 1 or 0 -- 672
		end -- 670
		local left = ctrl and Keyboard:isKeyDown("Left") -- 673
		local right = ctrl and Keyboard:isKeyDown("Right") -- 674
		local currentIndex = nil -- 675
		for i, entry in ipairs(allEntries) do -- 676
			if currentEntry == entry then -- 677
				currentIndex = i -- 678
			end -- 677
		end -- 678
		if left then -- 679
			allClear() -- 680
			if currentIndex == nil then -- 681
				currentIndex = #allEntries + 1 -- 681
			end -- 681
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 682
		end -- 679
		if right then -- 686
			allClear() -- 687
			if currentIndex == nil then -- 688
				currentIndex = 0 -- 688
			end -- 688
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 689
		end -- 686
	end -- 692
	if not showEntry then -- 693
		return -- 693
	end -- 693
	local width, height -- 695
	do -- 695
		local _obj_0 = App.visualSize -- 695
		width, height = _obj_0.width, _obj_0.height -- 695
	end -- 695
	SetNextWindowSize(Vec2(50, 50)) -- 696
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 697
	PushStyleColor("WindowBg", transparant, function() -- 698
		return Begin("Show", windowFlags, function() -- 698
			if isInEntry or width >= 540 then -- 699
				local changed -- 700
				changed, showFooter = Checkbox("##dev", showFooter) -- 700
				if changed then -- 700
					config.showFooter = showFooter and 1 or 0 -- 701
				end -- 700
			end -- 699
		end) -- 701
	end) -- 698
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 703
		reloadDevEntry() -- 707
	end -- 703
	if initFooter then -- 708
		initFooter = false -- 709
	else -- 711
		if not showFooter then -- 711
			return -- 711
		end -- 711
	end -- 708
	SetNextWindowSize(Vec2(width, 50)) -- 713
	SetNextWindowPos(Vec2(0, height - 50)) -- 714
	SetNextWindowBgAlpha(0.35) -- 715
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 716
		return Begin("Footer", windowFlags, function() -- 716
			Dummy(Vec2(width - 20, 0)) -- 717
			do -- 718
				local changed -- 718
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 718
				if changed then -- 718
					config.showStats = showStats and 1 or 0 -- 719
				end -- 718
			end -- 718
			SameLine() -- 720
			do -- 721
				local changed -- 721
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 721
				if changed then -- 721
					config.showConsole = showConsole and 1 or 0 -- 722
				end -- 721
			end -- 721
			if not isInEntry then -- 723
				SameLine() -- 724
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 725
					allClear() -- 726
					isInEntry = true -- 727
					currentEntry = nil -- 728
				end -- 725
				local currentIndex = nil -- 729
				for i, entry in ipairs(allEntries) do -- 730
					if currentEntry == entry then -- 731
						currentIndex = i -- 732
					end -- 731
				end -- 732
				if currentIndex then -- 733
					if currentIndex > 1 then -- 734
						SameLine() -- 735
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 736
							allClear() -- 737
							enterDemoEntry(allEntries[currentIndex - 1]) -- 738
						end -- 736
					end -- 734
					if currentIndex < #allEntries then -- 739
						SameLine() -- 740
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 741
							allClear() -- 742
							enterDemoEntry(allEntries[currentIndex + 1]) -- 743
						end -- 741
					end -- 739
				end -- 733
				SameLine() -- 744
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 745
					reloadCurrentEntry() -- 746
				end -- 745
			end -- 723
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 747
				if showStats then -- 748
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 749
					showStats = ShowStats(showStats, extraOperations) -- 750
					config.showStats = showStats and 1 or 0 -- 751
				end -- 748
				if showConsole then -- 752
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 753
					showConsole = ShowConsole(showConsole) -- 754
					config.showConsole = showConsole and 1 or 0 -- 755
				end -- 752
			end) -- 755
		end) -- 755
	end) -- 755
end) -- 647
local MaxWidth <const> = 800 -- 757
local displayWindowFlags = { -- 760
	"NoDecoration", -- 760
	"NoSavedSettings", -- 761
	"NoFocusOnAppearing", -- 762
	"NoNav", -- 763
	"NoMove", -- 764
	"NoScrollWithMouse", -- 765
	"AlwaysAutoResize", -- 766
	"NoBringToFrontOnFocus" -- 767
} -- 759
local webStatus = nil -- 769
local descColor = Color(0xffa1a1a1) -- 770
local gameOpen = #gamesInDev == 0 -- 771
local exampleOpen = false -- 772
local testOpen = false -- 773
local filterText = nil -- 774
local anyEntryMatched = false -- 775
local match -- 776
match = function(name) -- 776
	local res = not filterText or name:lower():match(filterText) -- 777
	if res then -- 778
		anyEntryMatched = true -- 778
	end -- 778
	return res -- 779
end -- 776
entryWindow = threadLoop(function() -- 781
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 782
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 783
	end -- 782
	if App.targetFPS ~= config.targetFPS then -- 784
		config.targetFPS = App.targetFPS -- 785
	end -- 784
	if View.vsync ~= (config.vsync == 1) then -- 786
		config.vsync = View.vsync and 1 or 0 -- 787
	end -- 786
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 788
		config.fixedFPS = Director.scheduler.fixedFPS -- 789
	end -- 788
	if not showEntry then -- 790
		return -- 790
	end -- 790
	if not isInEntry then -- 791
		return -- 791
	end -- 791
	local zh = useChinese and isChineseSupported -- 792
	if HttpServer.wsConnectionCount > 0 then -- 793
		local themeColor = App.themeColor -- 794
		local width, height -- 795
		do -- 795
			local _obj_0 = App.visualSize -- 795
			width, height = _obj_0.width, _obj_0.height -- 795
		end -- 795
		SetNextWindowBgAlpha(0.5) -- 796
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 797
		Begin("Web IDE Connected", displayWindowFlags, function() -- 798
			Separator() -- 799
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 800
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 801
			TextColored(descColor, slogon) -- 802
			return Separator() -- 803
		end) -- 798
		return -- 804
	end -- 793
	local themeColor = App.themeColor -- 806
	local fullWidth, height -- 807
	do -- 807
		local _obj_0 = App.visualSize -- 807
		fullWidth, height = _obj_0.width, _obj_0.height -- 807
	end -- 807
	SetNextWindowBgAlpha(0.85) -- 809
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 810
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 811
		return Begin("Web IDE", displayWindowFlags, function() -- 812
			Separator() -- 813
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 814
			local url -- 815
			do -- 815
				local _exp_0 -- 815
				if webStatus ~= nil then -- 815
					_exp_0 = webStatus.url -- 815
				end -- 815
				if _exp_0 ~= nil then -- 815
					url = _exp_0 -- 815
				else -- 815
					url = zh and '不可用' or 'not available' -- 815
				end -- 815
			end -- 815
			TextColored(descColor, url) -- 816
			return Separator() -- 817
		end) -- 817
	end) -- 811
	local width = math.min(MaxWidth, fullWidth) -- 819
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 820
	local maxColumns = math.max(math.floor(width / 200), 1) -- 821
	SetNextWindowPos(Vec2.zero) -- 822
	SetNextWindowBgAlpha(0) -- 823
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 824
		return Begin("Dora Dev", displayWindowFlags, function() -- 825
			Dummy(Vec2(fullWidth - 20, 0)) -- 826
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 827
			SameLine() -- 828
			if fullWidth >= 320 then -- 829
				Dummy(Vec2(fullWidth - 320, 0)) -- 830
				SameLine() -- 831
				SetNextItemWidth(-50) -- 832
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 833
					"AutoSelectAll" -- 833
				}) then -- 833
					config.filter = filterBuf:toString() -- 834
				end -- 833
			end -- 829
			Separator() -- 835
			return Dummy(Vec2(fullWidth - 20, 0)) -- 836
		end) -- 836
	end) -- 824
	anyEntryMatched = false -- 838
	SetNextWindowPos(Vec2(0, 50)) -- 839
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 840
	return PushStyleColor("WindowBg", transparant, function() -- 841
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 841
			return Begin("Content", windowFlags, function() -- 842
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 843
				if filterText then -- 844
					filterText = filterText:lower() -- 844
				end -- 844
				if #gamesInDev > 0 then -- 845
					for _index_0 = 1, #gamesInDev do -- 846
						local game = gamesInDev[_index_0] -- 846
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 847
						local showSep = false -- 848
						if match(gameName) then -- 849
							Columns(1, false) -- 850
							TextColored(themeColor, zh and "项目：" or "Project:") -- 851
							SameLine() -- 852
							Text(gameName) -- 853
							Separator() -- 854
							if bannerFile then -- 855
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 856
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 857
								local sizing <const> = 0.8 -- 858
								texHeight = displayWidth * sizing * texHeight / texWidth -- 859
								texWidth = displayWidth * sizing -- 860
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 861
								Dummy(Vec2(padding, 0)) -- 862
								SameLine() -- 863
								PushID(fileName, function() -- 864
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 865
										return enterDemoEntry(game) -- 866
									end -- 865
								end) -- 864
							else -- 868
								PushID(fileName, function() -- 868
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 869
										return enterDemoEntry(game) -- 870
									end -- 869
								end) -- 868
							end -- 855
							NextColumn() -- 871
							showSep = true -- 872
						end -- 849
						if #examples > 0 then -- 873
							local showExample = false -- 874
							for _index_1 = 1, #examples do -- 875
								local example = examples[_index_1] -- 875
								if match(example[1]) then -- 876
									showExample = true -- 877
									break -- 878
								end -- 876
							end -- 878
							if showExample then -- 879
								Columns(1, false) -- 880
								TextColored(themeColor, zh and "示例：" or "Example:") -- 881
								SameLine() -- 882
								Text(gameName) -- 883
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 884
									Columns(maxColumns, false) -- 885
									for _index_1 = 1, #examples do -- 886
										local example = examples[_index_1] -- 886
										if not match(example[1]) then -- 887
											goto _continue_0 -- 887
										end -- 887
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 888
											if Button(example[1], Vec2(-1, 40)) then -- 889
												enterDemoEntry(example) -- 890
											end -- 889
											return NextColumn() -- 891
										end) -- 888
										showSep = true -- 892
										::_continue_0:: -- 887
									end -- 892
								end) -- 884
							end -- 879
						end -- 873
						if #tests > 0 then -- 893
							local showTest = false -- 894
							for _index_1 = 1, #tests do -- 895
								local test = tests[_index_1] -- 895
								if match(test[1]) then -- 896
									showTest = true -- 897
									break -- 898
								end -- 896
							end -- 898
							if showTest then -- 899
								Columns(1, false) -- 900
								TextColored(themeColor, zh and "测试：" or "Test:") -- 901
								SameLine() -- 902
								Text(gameName) -- 903
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 904
									Columns(maxColumns, false) -- 905
									for _index_1 = 1, #tests do -- 906
										local test = tests[_index_1] -- 906
										if not match(test[1]) then -- 907
											goto _continue_0 -- 907
										end -- 907
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 908
											if Button(test[1], Vec2(-1, 40)) then -- 909
												enterDemoEntry(test) -- 910
											end -- 909
											return NextColumn() -- 911
										end) -- 908
										showSep = true -- 912
										::_continue_0:: -- 907
									end -- 912
								end) -- 904
							end -- 899
						end -- 893
						if showSep then -- 913
							Columns(1, false) -- 914
							Separator() -- 915
						end -- 913
					end -- 915
				end -- 845
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 916
					local showGame = false -- 917
					for _index_0 = 1, #games do -- 918
						local _des_0 = games[_index_0] -- 918
						local name = _des_0[1] -- 918
						if match(name) then -- 919
							showGame = true -- 919
						end -- 919
					end -- 919
					local showExample = false -- 920
					for _index_0 = 1, #doraExamples do -- 921
						local _des_0 = doraExamples[_index_0] -- 921
						local name = _des_0[1] -- 921
						if match(name) then -- 922
							showExample = true -- 922
						end -- 922
					end -- 922
					local showTest = false -- 923
					for _index_0 = 1, #doraTests do -- 924
						local _des_0 = doraTests[_index_0] -- 924
						local name = _des_0[1] -- 924
						if match(name) then -- 925
							showTest = true -- 925
						end -- 925
					end -- 925
					for _index_0 = 1, #cppTests do -- 926
						local _des_0 = cppTests[_index_0] -- 926
						local name = _des_0[1] -- 926
						if match(name) then -- 927
							showTest = true -- 927
						end -- 927
					end -- 927
					if not (showGame or showExample or showTest) then -- 928
						goto endEntry -- 928
					end -- 928
					Columns(1, false) -- 929
					TextColored(themeColor, "Dora SSR:") -- 930
					SameLine() -- 931
					Text(zh and "开发示例" or "Development Showcase") -- 932
					Separator() -- 933
					local demoViewWith <const> = 400 -- 934
					if #games > 0 and showGame then -- 935
						local opened -- 936
						if (filterText ~= nil) then -- 936
							opened = showGame -- 936
						else -- 936
							opened = false -- 936
						end -- 936
						SetNextItemOpen(gameOpen) -- 937
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 938
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 939
							Columns(columns, false) -- 940
							for _index_0 = 1, #games do -- 941
								local game = games[_index_0] -- 941
								if not match(game[1]) then -- 942
									goto _continue_0 -- 942
								end -- 942
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 943
								if columns > 1 then -- 944
									if bannerFile then -- 945
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 946
										local displayWidth <const> = demoViewWith - 40 -- 947
										texHeight = displayWidth * texHeight / texWidth -- 948
										texWidth = displayWidth -- 949
										Text(gameName) -- 950
										PushID(fileName, function() -- 951
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 952
												return enterDemoEntry(game) -- 953
											end -- 952
										end) -- 951
									else -- 955
										PushID(fileName, function() -- 955
											if Button(gameName, Vec2(-1, 40)) then -- 956
												return enterDemoEntry(game) -- 957
											end -- 956
										end) -- 955
									end -- 945
								else -- 959
									if bannerFile then -- 959
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 960
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 961
										local sizing = 0.8 -- 962
										texHeight = displayWidth * sizing * texHeight / texWidth -- 963
										texWidth = displayWidth * sizing -- 964
										if texWidth > 500 then -- 965
											sizing = 0.6 -- 966
											texHeight = displayWidth * sizing * texHeight / texWidth -- 967
											texWidth = displayWidth * sizing -- 968
										end -- 965
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 969
										Dummy(Vec2(padding, 0)) -- 970
										SameLine() -- 971
										Text(gameName) -- 972
										Dummy(Vec2(padding, 0)) -- 973
										SameLine() -- 974
										PushID(fileName, function() -- 975
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 976
												return enterDemoEntry(game) -- 977
											end -- 976
										end) -- 975
									else -- 979
										PushID(fileName, function() -- 979
											if Button(gameName, Vec2(-1, 40)) then -- 980
												return enterDemoEntry(game) -- 981
											end -- 980
										end) -- 979
									end -- 959
								end -- 944
								NextColumn() -- 982
								::_continue_0:: -- 942
							end -- 982
							Columns(1, false) -- 983
							opened = true -- 984
						end) -- 938
						gameOpen = opened -- 985
					end -- 935
					if #doraExamples > 0 and showExample then -- 986
						local opened -- 987
						if (filterText ~= nil) then -- 987
							opened = showExample -- 987
						else -- 987
							opened = false -- 987
						end -- 987
						SetNextItemOpen(exampleOpen) -- 988
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 989
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 990
								Columns(maxColumns, false) -- 991
								for _index_0 = 1, #doraExamples do -- 992
									local example = doraExamples[_index_0] -- 992
									if not match(example[1]) then -- 993
										goto _continue_0 -- 993
									end -- 993
									if Button(example[1], Vec2(-1, 40)) then -- 994
										enterDemoEntry(example) -- 995
									end -- 994
									NextColumn() -- 996
									::_continue_0:: -- 993
								end -- 996
								Columns(1, false) -- 997
								opened = true -- 998
							end) -- 990
						end) -- 989
						exampleOpen = opened -- 999
					end -- 986
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1000
						local opened -- 1001
						if (filterText ~= nil) then -- 1001
							opened = showTest -- 1001
						else -- 1001
							opened = false -- 1001
						end -- 1001
						SetNextItemOpen(testOpen) -- 1002
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1003
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1004
								Columns(maxColumns, false) -- 1005
								for _index_0 = 1, #doraTests do -- 1006
									local test = doraTests[_index_0] -- 1006
									if not match(test[1]) then -- 1007
										goto _continue_0 -- 1007
									end -- 1007
									if Button(test[1], Vec2(-1, 40)) then -- 1008
										enterDemoEntry(test) -- 1009
									end -- 1008
									NextColumn() -- 1010
									::_continue_0:: -- 1007
								end -- 1010
								for _index_0 = 1, #cppTests do -- 1011
									local test = cppTests[_index_0] -- 1011
									if not match(test[1]) then -- 1012
										goto _continue_1 -- 1012
									end -- 1012
									if Button(test[1], Vec2(-1, 40)) then -- 1013
										enterDemoEntry(test) -- 1014
									end -- 1013
									NextColumn() -- 1015
									::_continue_1:: -- 1012
								end -- 1015
								opened = true -- 1016
							end) -- 1004
						end) -- 1003
						testOpen = opened -- 1017
					end -- 1000
				end -- 916
				::endEntry:: -- 1018
				if not anyEntryMatched then -- 1019
					SetNextWindowBgAlpha(0) -- 1020
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1021
					Begin("Entries Not Found", displayWindowFlags, function() -- 1022
						Separator() -- 1023
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1024
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1025
						return Separator() -- 1026
					end) -- 1022
				end -- 1019
				Columns(1, false) -- 1027
				Dummy(Vec2(100, 80)) -- 1028
				return ScrollWhenDraggingOnVoid() -- 1029
			end) -- 1029
		end) -- 1029
	end) -- 1029
end) -- 781
webStatus = require("Script.Dev.WebServer") -- 1031
return _module_0 -- 1031
