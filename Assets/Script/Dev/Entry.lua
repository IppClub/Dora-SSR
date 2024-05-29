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
local HttpServer = Dora.HttpServer -- 1
local Routine = Dora.Routine -- 1
local Entity = Dora.Entity -- 1
local Platformer = Dora.Platformer -- 1
local Audio = Dora.Audio -- 1
local ubox = Dora.ubox -- 1
local tolua = Dora.tolua -- 1
local collectgarbage = _G.collectgarbage -- 1
local Wasm = Dora.Wasm -- 1
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
local type -- 11
type = _G.type -- 11
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
local setupEventHandlers -- 443
setupEventHandlers = function() -- 443
	local _with_0 = Director.postNode -- 444
	_with_0:gslot("AppTheme", function(argb) -- 445
		config.themeColor = argb -- 446
	end) -- 445
	_with_0:gslot("AppLocale", function(locale) -- 447
		config.locale = locale -- 448
		updateLocale() -- 449
		return teal.clear(true) -- 450
	end) -- 447
	_with_0:gslot("AppWSClose", function() -- 451
		if HttpServer.wsConnectionCount == 0 then -- 452
			return updateEntries() -- 453
		end -- 452
	end) -- 451
	local _exp_0 = App.platform -- 454
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 454
		_with_0:gslot("AppSizeChanged", function() -- 455
			local width, height -- 456
			do -- 456
				local _obj_0 = App.winSize -- 456
				width, height = _obj_0.width, _obj_0.height -- 456
			end -- 456
			config.winWidth = width -- 457
			config.winHeight = height -- 458
		end) -- 455
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 459
			config.fullScreen = fullScreen and 1 or 0 -- 460
		end) -- 459
		_with_0:gslot("AppMoved", function() -- 461
			local _obj_0 = App.winPosition -- 462
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 462
		end) -- 461
	end -- 462
	return _with_0 -- 444
end -- 443
setupEventHandlers() -- 464
local allClear -- 466
allClear = function() -- 466
	local _list_0 = Routine -- 467
	for _index_0 = 1, #_list_0 do -- 467
		local routine = _list_0[_index_0] -- 467
		if footerWindow == routine or entryWindow == routine then -- 469
			goto _continue_0 -- 470
		else -- 472
			Routine:remove(routine) -- 472
		end -- 472
		::_continue_0:: -- 468
	end -- 472
	for _index_0 = 1, #moduleCache do -- 473
		local module = moduleCache[_index_0] -- 473
		package.loaded[module] = nil -- 474
	end -- 474
	moduleCache = { } -- 475
	Director:cleanup() -- 476
	Cache:unload() -- 477
	Entity:clear() -- 478
	Platformer.Data:clear() -- 479
	Platformer.UnitAction:clear() -- 480
	Audio:stopStream(0.2) -- 481
	Struct:clear() -- 482
	View.postEffect = nil -- 483
	View.scale = scaleContent and screenScale or 1 -- 484
	Director.clearColor = Color(0xff1a1a1a) -- 485
	teal.clear() -- 486
	yue.clear() -- 487
	for _, item in pairs(ubox()) do -- 488
		local node = tolua.cast(item, "Node") -- 489
		if node then -- 489
			node:cleanup() -- 489
		end -- 489
	end -- 489
	collectgarbage() -- 490
	collectgarbage() -- 491
	setupEventHandlers() -- 492
	Content.searchPaths = searchPaths -- 493
	App.idled = true -- 494
	return Wasm:clear() -- 495
end -- 466
_module_0["allClear"] = allClear -- 495
local stop -- 497
stop = function() -- 497
	if isInEntry then -- 498
		return false -- 498
	end -- 498
	allClear() -- 499
	isInEntry = true -- 500
	currentEntry = nil -- 501
	return true -- 502
end -- 497
_module_0["stop"] = stop -- 502
local _anon_func_0 = function(Content, Path, file, require, type) -- 523
	local scriptPath = Path:getPath(file) -- 516
	Content:insertSearchPath(1, scriptPath) -- 517
	scriptPath = Path(scriptPath, "Script") -- 518
	if Content:exist(scriptPath) then -- 519
		Content:insertSearchPath(1, scriptPath) -- 520
	end -- 519
	local result = require(file) -- 521
	if "function" == type(result) then -- 522
		result() -- 522
	end -- 522
	return nil -- 523
end -- 516
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 555
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 552
	label.alignment = "Left" -- 553
	label.textWidth = width - fontSize -- 554
	label.text = err -- 555
	return label -- 552
end -- 552
local enterEntryAsync -- 504
enterEntryAsync = function(entry) -- 504
	isInEntry = false -- 505
	App.idled = false -- 506
	currentEntry = entry -- 507
	local name, file = entry[1], entry[2] -- 508
	if cppTestSet[entry] then -- 509
		if App:runTest(name) then -- 510
			return true -- 511
		else -- 513
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 513
		end -- 510
	end -- 509
	sleep() -- 514
	return xpcall(_anon_func_0, function(msg) -- 523
		local err = debug.traceback(msg) -- 525
		allClear() -- 526
		print(err) -- 527
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 528
		local viewWidth, viewHeight -- 529
		do -- 529
			local _obj_0 = View.size -- 529
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 529
		end -- 529
		local width, height = viewWidth - 20, viewHeight - 20 -- 530
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 531
		Director.ui:addChild((function() -- 532
			local root = AlignNode() -- 532
			do -- 533
				local _obj_0 = App.bufferSize -- 533
				width, height = _obj_0.width, _obj_0.height -- 533
			end -- 533
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 534
			root:gslot("AppSizeChanged", function() -- 535
				do -- 536
					local _obj_0 = App.bufferSize -- 536
					width, height = _obj_0.width, _obj_0.height -- 536
				end -- 536
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 537
			end) -- 535
			root:addChild((function() -- 538
				local _with_0 = ScrollArea({ -- 539
					width = width, -- 539
					height = height, -- 540
					paddingX = 0, -- 541
					paddingY = 50, -- 542
					viewWidth = height, -- 543
					viewHeight = height -- 544
				}) -- 538
				root:slot("AlignLayout", function(w, h) -- 546
					_with_0.position = Vec2(w / 2, h / 2) -- 547
					w = w - 20 -- 548
					h = h - 20 -- 549
					_with_0.view.children.first.textWidth = w - fontSize -- 550
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 551
				end) -- 546
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 552
				return _with_0 -- 538
			end)()) -- 538
			return root -- 532
		end)()) -- 532
		return err -- 556
	end, Content, Path, file, require, type) -- 556
end -- 504
_module_0["enterEntryAsync"] = enterEntryAsync -- 556
local enterDemoEntry -- 558
enterDemoEntry = function(entry) -- 558
	return thread(function() -- 558
		return enterEntryAsync(entry) -- 558
	end) -- 558
end -- 558
local reloadCurrentEntry -- 560
reloadCurrentEntry = function() -- 560
	if currentEntry then -- 561
		allClear() -- 562
		return enterDemoEntry(currentEntry) -- 563
	end -- 561
end -- 560
Director.clearColor = Color(0xff1a1a1a) -- 565
local waitForWebStart = true -- 567
thread(function() -- 568
	sleep(2) -- 569
	waitForWebStart = false -- 570
end) -- 568
local reloadDevEntry -- 572
reloadDevEntry = function() -- 572
	return thread(function() -- 572
		waitForWebStart = true -- 573
		doClean() -- 574
		allClear() -- 575
		_G.require = oldRequire -- 576
		Dora.require = oldRequire -- 577
		package.loaded["Script.Dev.Entry"] = nil -- 578
		return Director.systemScheduler:schedule(function() -- 579
			Routine:clear() -- 580
			oldRequire("Script.Dev.Entry") -- 581
			return true -- 582
		end) -- 582
	end) -- 582
end -- 572
local isOSSLicenseExist = Content:exist("LICENSES") -- 584
local ossLicenses = nil -- 585
local ossLicenseOpen = false -- 586
local extraOperations -- 588
extraOperations = function() -- 588
	local zh = useChinese and isChineseSupported -- 589
	if isOSSLicenseExist then -- 590
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 591
			if not ossLicenses then -- 592
				ossLicenses = { } -- 593
				local licenseText = Content:load("LICENSES") -- 594
				ossLicenseOpen = (licenseText ~= nil) -- 595
				if ossLicenseOpen then -- 595
					licenseText = licenseText:gsub("\r\n", "\n") -- 596
					for license in GSplit(licenseText, "\n--------\n", true) do -- 597
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 598
						if name then -- 598
							ossLicenses[#ossLicenses + 1] = { -- 599
								name, -- 599
								text -- 599
							} -- 599
						end -- 598
					end -- 599
				end -- 595
			else -- 601
				ossLicenseOpen = true -- 601
			end -- 592
		end -- 591
		if ossLicenseOpen then -- 602
			local width, height, themeColor -- 603
			do -- 603
				local _obj_0 = App -- 603
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 603
			end -- 603
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 604
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 605
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 606
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 609
					"NoSavedSettings" -- 609
				}, function() -- 610
					for _index_0 = 1, #ossLicenses do -- 610
						local _des_0 = ossLicenses[_index_0] -- 610
						local firstLine, text = _des_0[1], _des_0[2] -- 610
						local name, license = firstLine:match("(.+): (.+)") -- 611
						TextColored(themeColor, name) -- 612
						SameLine() -- 613
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 614
							return TextWrapped(text) -- 614
						end) -- 614
					end -- 614
				end) -- 606
			end) -- 606
		end -- 602
	end -- 590
	if not App.debugging then -- 616
		return -- 616
	end -- 616
	return TreeNode(zh and "开发操作" or "Development", function() -- 617
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 618
			OpenPopup("build") -- 618
		end -- 618
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 619
			return BeginPopup("build", function() -- 619
				if Selectable(zh and "编译" or "Compile") then -- 620
					doCompile(false) -- 620
				end -- 620
				Separator() -- 621
				if Selectable(zh and "压缩" or "Minify") then -- 622
					doCompile(true) -- 622
				end -- 622
				Separator() -- 623
				if Selectable(zh and "清理" or "Clean") then -- 624
					return doClean() -- 624
				end -- 624
			end) -- 624
		end) -- 619
		if isInEntry then -- 625
			if waitForWebStart then -- 626
				BeginDisabled(function() -- 627
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 627
				end) -- 627
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 628
				reloadDevEntry() -- 629
			end -- 626
		end -- 625
		do -- 630
			local changed -- 630
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 630
			if changed then -- 630
				View.scale = scaleContent and screenScale or 1 -- 631
			end -- 630
		end -- 630
		local changed -- 632
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 632
		if changed then -- 632
			config.engineDev = engineDev and 1 or 0 -- 633
		end -- 632
	end) -- 617
end -- 588
local transparant = Color(0x0) -- 635
local windowFlags = { -- 637
	"NoTitleBar", -- 637
	"NoResize", -- 638
	"NoMove", -- 639
	"NoCollapse", -- 640
	"NoSavedSettings", -- 641
	"NoBringToFrontOnFocus" -- 642
} -- 636
local initFooter = true -- 643
local _anon_func_2 = function(allEntries, currentIndex) -- 677
	if currentIndex > 1 then -- 677
		return allEntries[currentIndex - 1] -- 678
	else -- 680
		return allEntries[#allEntries] -- 680
	end -- 677
end -- 677
local _anon_func_3 = function(allEntries, currentIndex) -- 684
	if currentIndex < #allEntries then -- 684
		return allEntries[currentIndex + 1] -- 685
	else -- 687
		return allEntries[1] -- 687
	end -- 684
end -- 684
footerWindow = threadLoop(function() -- 644
	local zh = useChinese and isChineseSupported -- 645
	if HttpServer.wsConnectionCount > 0 then -- 646
		return -- 647
	end -- 646
	if Keyboard:isKeyDown("Escape") then -- 648
		App:shutdown() -- 648
	end -- 648
	do -- 649
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 650
		if ctrl and Keyboard:isKeyDown("Q") then -- 651
			stop() -- 652
		end -- 651
		if ctrl and Keyboard:isKeyDown("Z") then -- 653
			reloadCurrentEntry() -- 654
		end -- 653
		if ctrl and Keyboard:isKeyDown(",") then -- 655
			if showFooter then -- 656
				showStats = not showStats -- 656
			else -- 656
				showStats = true -- 656
			end -- 656
			showFooter = true -- 657
			config.showFooter = showFooter and 1 or 0 -- 658
			config.showStats = showStats and 1 or 0 -- 659
		end -- 655
		if ctrl and Keyboard:isKeyDown(".") then -- 660
			if showFooter then -- 661
				showConsole = not showConsole -- 661
			else -- 661
				showConsole = true -- 661
			end -- 661
			showFooter = true -- 662
			config.showFooter = showFooter and 1 or 0 -- 663
			config.showConsole = showConsole and 1 or 0 -- 664
		end -- 660
		if ctrl and Keyboard:isKeyDown("/") then -- 665
			showFooter = not showFooter -- 666
			config.showFooter = showFooter and 1 or 0 -- 667
		end -- 665
		local left = ctrl and Keyboard:isKeyDown("Left") -- 668
		local right = ctrl and Keyboard:isKeyDown("Right") -- 669
		local currentIndex = nil -- 670
		for i, entry in ipairs(allEntries) do -- 671
			if currentEntry == entry then -- 672
				currentIndex = i -- 673
			end -- 672
		end -- 673
		if left then -- 674
			allClear() -- 675
			if currentIndex == nil then -- 676
				currentIndex = #allEntries + 1 -- 676
			end -- 676
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 677
		end -- 674
		if right then -- 681
			allClear() -- 682
			if currentIndex == nil then -- 683
				currentIndex = 0 -- 683
			end -- 683
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 684
		end -- 681
	end -- 687
	if not showEntry then -- 688
		return -- 688
	end -- 688
	local width, height -- 690
	do -- 690
		local _obj_0 = App.visualSize -- 690
		width, height = _obj_0.width, _obj_0.height -- 690
	end -- 690
	SetNextWindowSize(Vec2(50, 50)) -- 691
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 692
	PushStyleColor("WindowBg", transparant, function() -- 693
		return Begin("Show", windowFlags, function() -- 693
			if isInEntry or width >= 540 then -- 694
				local changed -- 695
				changed, showFooter = Checkbox("##dev", showFooter) -- 695
				if changed then -- 695
					config.showFooter = showFooter and 1 or 0 -- 696
				end -- 695
			end -- 694
		end) -- 696
	end) -- 693
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 698
		reloadDevEntry() -- 702
	end -- 698
	if initFooter then -- 703
		initFooter = false -- 704
	else -- 706
		if not showFooter then -- 706
			return -- 706
		end -- 706
	end -- 703
	SetNextWindowSize(Vec2(width, 50)) -- 708
	SetNextWindowPos(Vec2(0, height - 50)) -- 709
	SetNextWindowBgAlpha(0.35) -- 710
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 711
		return Begin("Footer", windowFlags, function() -- 711
			Dummy(Vec2(width - 20, 0)) -- 712
			do -- 713
				local changed -- 713
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 713
				if changed then -- 713
					config.showStats = showStats and 1 or 0 -- 714
				end -- 713
			end -- 713
			SameLine() -- 715
			do -- 716
				local changed -- 716
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 716
				if changed then -- 716
					config.showConsole = showConsole and 1 or 0 -- 717
				end -- 716
			end -- 716
			if not isInEntry then -- 718
				SameLine() -- 719
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 720
					allClear() -- 721
					isInEntry = true -- 722
					currentEntry = nil -- 723
				end -- 720
				local currentIndex = nil -- 724
				for i, entry in ipairs(allEntries) do -- 725
					if currentEntry == entry then -- 726
						currentIndex = i -- 727
					end -- 726
				end -- 727
				if currentIndex then -- 728
					if currentIndex > 1 then -- 729
						SameLine() -- 730
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 731
							allClear() -- 732
							enterDemoEntry(allEntries[currentIndex - 1]) -- 733
						end -- 731
					end -- 729
					if currentIndex < #allEntries then -- 734
						SameLine() -- 735
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 736
							allClear() -- 737
							enterDemoEntry(allEntries[currentIndex + 1]) -- 738
						end -- 736
					end -- 734
				end -- 728
				SameLine() -- 739
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 740
					reloadCurrentEntry() -- 741
				end -- 740
			end -- 718
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 742
				if showStats then -- 743
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 744
					showStats = ShowStats(showStats, extraOperations) -- 745
					config.showStats = showStats and 1 or 0 -- 746
				end -- 743
				if showConsole then -- 747
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 748
					showConsole = ShowConsole(showConsole) -- 749
					config.showConsole = showConsole and 1 or 0 -- 750
				end -- 747
			end) -- 750
		end) -- 750
	end) -- 750
end) -- 644
local MaxWidth <const> = 800 -- 752
local displayWindowFlags = { -- 755
	"NoDecoration", -- 755
	"NoSavedSettings", -- 756
	"NoFocusOnAppearing", -- 757
	"NoNav", -- 758
	"NoMove", -- 759
	"NoScrollWithMouse", -- 760
	"AlwaysAutoResize", -- 761
	"NoBringToFrontOnFocus" -- 762
} -- 754
local webStatus = nil -- 764
local descColor = Color(0xffa1a1a1) -- 765
local gameOpen = #gamesInDev == 0 -- 766
local exampleOpen = false -- 767
local testOpen = false -- 768
local filterText = nil -- 769
local anyEntryMatched = false -- 770
local match -- 771
match = function(name) -- 771
	local res = not filterText or name:lower():match(filterText) -- 772
	if res then -- 773
		anyEntryMatched = true -- 773
	end -- 773
	return res -- 774
end -- 771
entryWindow = threadLoop(function() -- 776
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 777
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 778
	end -- 777
	if App.targetFPS ~= config.targetFPS then -- 779
		config.targetFPS = App.targetFPS -- 780
	end -- 779
	if View.vsync ~= (config.vsync == 1) then -- 781
		config.vsync = View.vsync and 1 or 0 -- 782
	end -- 781
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 783
		config.fixedFPS = Director.scheduler.fixedFPS -- 784
	end -- 783
	if not showEntry then -- 785
		return -- 785
	end -- 785
	if not isInEntry then -- 786
		return -- 786
	end -- 786
	local zh = useChinese and isChineseSupported -- 787
	if HttpServer.wsConnectionCount > 0 then -- 788
		local themeColor = App.themeColor -- 789
		local width, height -- 790
		do -- 790
			local _obj_0 = App.visualSize -- 790
			width, height = _obj_0.width, _obj_0.height -- 790
		end -- 790
		SetNextWindowBgAlpha(0.5) -- 791
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 792
		Begin("Web IDE Connected", displayWindowFlags, function() -- 793
			Separator() -- 794
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 795
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 796
			TextColored(descColor, slogon) -- 797
			return Separator() -- 798
		end) -- 793
		return -- 799
	end -- 788
	local themeColor = App.themeColor -- 801
	local fullWidth, height -- 802
	do -- 802
		local _obj_0 = App.visualSize -- 802
		fullWidth, height = _obj_0.width, _obj_0.height -- 802
	end -- 802
	SetNextWindowBgAlpha(0.85) -- 804
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 805
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 806
		return Begin("Web IDE", displayWindowFlags, function() -- 807
			Separator() -- 808
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 809
			local url -- 810
			do -- 810
				local _exp_0 -- 810
				if webStatus ~= nil then -- 810
					_exp_0 = webStatus.url -- 810
				end -- 810
				if _exp_0 ~= nil then -- 810
					url = _exp_0 -- 810
				else -- 810
					url = zh and '不可用' or 'not available' -- 810
				end -- 810
			end -- 810
			TextColored(descColor, url) -- 811
			return Separator() -- 812
		end) -- 812
	end) -- 806
	local width = math.min(MaxWidth, fullWidth) -- 814
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 815
	local maxColumns = math.max(math.floor(width / 200), 1) -- 816
	SetNextWindowPos(Vec2.zero) -- 817
	SetNextWindowBgAlpha(0) -- 818
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 819
		return Begin("Dora Dev", displayWindowFlags, function() -- 820
			Dummy(Vec2(fullWidth - 20, 0)) -- 821
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 822
			SameLine() -- 823
			if fullWidth >= 320 then -- 824
				Dummy(Vec2(fullWidth - 320, 0)) -- 825
				SameLine() -- 826
				SetNextItemWidth(-50) -- 827
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 828
					"AutoSelectAll" -- 828
				}) then -- 828
					config.filter = filterBuf:toString() -- 829
				end -- 828
			end -- 824
			Separator() -- 830
			return Dummy(Vec2(fullWidth - 20, 0)) -- 831
		end) -- 831
	end) -- 819
	anyEntryMatched = false -- 833
	SetNextWindowPos(Vec2(0, 50)) -- 834
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 835
	return PushStyleColor("WindowBg", transparant, function() -- 836
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 836
			return Begin("Content", windowFlags, function() -- 837
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 838
				if filterText then -- 839
					filterText = filterText:lower() -- 839
				end -- 839
				if #gamesInDev > 0 then -- 840
					for _index_0 = 1, #gamesInDev do -- 841
						local game = gamesInDev[_index_0] -- 841
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 842
						local showSep = false -- 843
						if match(gameName) then -- 844
							Columns(1, false) -- 845
							TextColored(themeColor, zh and "项目：" or "Project:") -- 846
							SameLine() -- 847
							Text(gameName) -- 848
							Separator() -- 849
							if bannerFile then -- 850
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 851
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 852
								local sizing <const> = 0.8 -- 853
								texHeight = displayWidth * sizing * texHeight / texWidth -- 854
								texWidth = displayWidth * sizing -- 855
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 856
								Dummy(Vec2(padding, 0)) -- 857
								SameLine() -- 858
								PushID(fileName, function() -- 859
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 860
										return enterDemoEntry(game) -- 861
									end -- 860
								end) -- 859
							else -- 863
								PushID(fileName, function() -- 863
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 864
										return enterDemoEntry(game) -- 865
									end -- 864
								end) -- 863
							end -- 850
							NextColumn() -- 866
							showSep = true -- 867
						end -- 844
						if #examples > 0 then -- 868
							local showExample = false -- 869
							for _index_1 = 1, #examples do -- 870
								local example = examples[_index_1] -- 870
								if match(example[1]) then -- 871
									showExample = true -- 872
									break -- 873
								end -- 871
							end -- 873
							if showExample then -- 874
								Columns(1, false) -- 875
								TextColored(themeColor, zh and "示例：" or "Example:") -- 876
								SameLine() -- 877
								Text(gameName) -- 878
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 879
									Columns(maxColumns, false) -- 880
									for _index_1 = 1, #examples do -- 881
										local example = examples[_index_1] -- 881
										if not match(example[1]) then -- 882
											goto _continue_0 -- 882
										end -- 882
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 883
											if Button(example[1], Vec2(-1, 40)) then -- 884
												enterDemoEntry(example) -- 885
											end -- 884
											return NextColumn() -- 886
										end) -- 883
										showSep = true -- 887
										::_continue_0:: -- 882
									end -- 887
								end) -- 879
							end -- 874
						end -- 868
						if #tests > 0 then -- 888
							local showTest = false -- 889
							for _index_1 = 1, #tests do -- 890
								local test = tests[_index_1] -- 890
								if match(test[1]) then -- 891
									showTest = true -- 892
									break -- 893
								end -- 891
							end -- 893
							if showTest then -- 894
								Columns(1, false) -- 895
								TextColored(themeColor, zh and "测试：" or "Test:") -- 896
								SameLine() -- 897
								Text(gameName) -- 898
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 899
									Columns(maxColumns, false) -- 900
									for _index_1 = 1, #tests do -- 901
										local test = tests[_index_1] -- 901
										if not match(test[1]) then -- 902
											goto _continue_0 -- 902
										end -- 902
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 903
											if Button(test[1], Vec2(-1, 40)) then -- 904
												enterDemoEntry(test) -- 905
											end -- 904
											return NextColumn() -- 906
										end) -- 903
										showSep = true -- 907
										::_continue_0:: -- 902
									end -- 907
								end) -- 899
							end -- 894
						end -- 888
						if showSep then -- 908
							Columns(1, false) -- 909
							Separator() -- 910
						end -- 908
					end -- 910
				end -- 840
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 911
					local showGame = false -- 912
					for _index_0 = 1, #games do -- 913
						local _des_0 = games[_index_0] -- 913
						local name = _des_0[1] -- 913
						if match(name) then -- 914
							showGame = true -- 914
						end -- 914
					end -- 914
					local showExample = false -- 915
					for _index_0 = 1, #doraExamples do -- 916
						local _des_0 = doraExamples[_index_0] -- 916
						local name = _des_0[1] -- 916
						if match(name) then -- 917
							showExample = true -- 917
						end -- 917
					end -- 917
					local showTest = false -- 918
					for _index_0 = 1, #doraTests do -- 919
						local _des_0 = doraTests[_index_0] -- 919
						local name = _des_0[1] -- 919
						if match(name) then -- 920
							showTest = true -- 920
						end -- 920
					end -- 920
					for _index_0 = 1, #cppTests do -- 921
						local _des_0 = cppTests[_index_0] -- 921
						local name = _des_0[1] -- 921
						if match(name) then -- 922
							showTest = true -- 922
						end -- 922
					end -- 922
					if not (showGame or showExample or showTest) then -- 923
						goto endEntry -- 923
					end -- 923
					Columns(1, false) -- 924
					TextColored(themeColor, "Dora SSR:") -- 925
					SameLine() -- 926
					Text(zh and "开发示例" or "Development Showcase") -- 927
					Separator() -- 928
					local demoViewWith <const> = 400 -- 929
					if #games > 0 and showGame then -- 930
						local opened -- 931
						if (filterText ~= nil) then -- 931
							opened = showGame -- 931
						else -- 931
							opened = false -- 931
						end -- 931
						SetNextItemOpen(gameOpen) -- 932
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 933
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 934
							Columns(columns, false) -- 935
							for _index_0 = 1, #games do -- 936
								local game = games[_index_0] -- 936
								if not match(game[1]) then -- 937
									goto _continue_0 -- 937
								end -- 937
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 938
								if columns > 1 then -- 939
									if bannerFile then -- 940
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 941
										local displayWidth <const> = demoViewWith - 40 -- 942
										texHeight = displayWidth * texHeight / texWidth -- 943
										texWidth = displayWidth -- 944
										Text(gameName) -- 945
										PushID(fileName, function() -- 946
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 947
												return enterDemoEntry(game) -- 948
											end -- 947
										end) -- 946
									else -- 950
										PushID(fileName, function() -- 950
											if Button(gameName, Vec2(-1, 40)) then -- 951
												return enterDemoEntry(game) -- 952
											end -- 951
										end) -- 950
									end -- 940
								else -- 954
									if bannerFile then -- 954
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 955
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 956
										local sizing = 0.8 -- 957
										texHeight = displayWidth * sizing * texHeight / texWidth -- 958
										texWidth = displayWidth * sizing -- 959
										if texWidth > 500 then -- 960
											sizing = 0.6 -- 961
											texHeight = displayWidth * sizing * texHeight / texWidth -- 962
											texWidth = displayWidth * sizing -- 963
										end -- 960
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 964
										Dummy(Vec2(padding, 0)) -- 965
										SameLine() -- 966
										Text(gameName) -- 967
										Dummy(Vec2(padding, 0)) -- 968
										SameLine() -- 969
										PushID(fileName, function() -- 970
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 971
												return enterDemoEntry(game) -- 972
											end -- 971
										end) -- 970
									else -- 974
										PushID(fileName, function() -- 974
											if Button(gameName, Vec2(-1, 40)) then -- 975
												return enterDemoEntry(game) -- 976
											end -- 975
										end) -- 974
									end -- 954
								end -- 939
								NextColumn() -- 977
								::_continue_0:: -- 937
							end -- 977
							Columns(1, false) -- 978
							opened = true -- 979
						end) -- 933
						gameOpen = opened -- 980
					end -- 930
					if #doraExamples > 0 and showExample then -- 981
						local opened -- 982
						if (filterText ~= nil) then -- 982
							opened = showExample -- 982
						else -- 982
							opened = false -- 982
						end -- 982
						SetNextItemOpen(exampleOpen) -- 983
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 984
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 985
								Columns(maxColumns, false) -- 986
								for _index_0 = 1, #doraExamples do -- 987
									local example = doraExamples[_index_0] -- 987
									if not match(example[1]) then -- 988
										goto _continue_0 -- 988
									end -- 988
									if Button(example[1], Vec2(-1, 40)) then -- 989
										enterDemoEntry(example) -- 990
									end -- 989
									NextColumn() -- 991
									::_continue_0:: -- 988
								end -- 991
								Columns(1, false) -- 992
								opened = true -- 993
							end) -- 985
						end) -- 984
						exampleOpen = opened -- 994
					end -- 981
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 995
						local opened -- 996
						if (filterText ~= nil) then -- 996
							opened = showTest -- 996
						else -- 996
							opened = false -- 996
						end -- 996
						SetNextItemOpen(testOpen) -- 997
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 998
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 999
								Columns(maxColumns, false) -- 1000
								for _index_0 = 1, #doraTests do -- 1001
									local test = doraTests[_index_0] -- 1001
									if not match(test[1]) then -- 1002
										goto _continue_0 -- 1002
									end -- 1002
									if Button(test[1], Vec2(-1, 40)) then -- 1003
										enterDemoEntry(test) -- 1004
									end -- 1003
									NextColumn() -- 1005
									::_continue_0:: -- 1002
								end -- 1005
								for _index_0 = 1, #cppTests do -- 1006
									local test = cppTests[_index_0] -- 1006
									if not match(test[1]) then -- 1007
										goto _continue_1 -- 1007
									end -- 1007
									if Button(test[1], Vec2(-1, 40)) then -- 1008
										enterDemoEntry(test) -- 1009
									end -- 1008
									NextColumn() -- 1010
									::_continue_1:: -- 1007
								end -- 1010
								opened = true -- 1011
							end) -- 999
						end) -- 998
						testOpen = opened -- 1012
					end -- 995
				end -- 911
				::endEntry:: -- 1013
				if not anyEntryMatched then -- 1014
					SetNextWindowBgAlpha(0) -- 1015
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1016
					Begin("Entries Not Found", displayWindowFlags, function() -- 1017
						Separator() -- 1018
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1019
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1020
						return Separator() -- 1021
					end) -- 1017
				end -- 1014
				Columns(1, false) -- 1022
				Dummy(Vec2(100, 80)) -- 1023
				return ScrollWhenDraggingOnVoid() -- 1024
			end) -- 1024
		end) -- 1024
	end) -- 1024
end) -- 776
webStatus = require("Script.Dev.WebServer") -- 1026
return _module_0 -- 1026
