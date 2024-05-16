-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
local package = _G.package -- 1
local Content = Dora.Content -- 1
local Path = Dora.Path -- 1
local DB = Dora.DB -- 1
local type = _G.type -- 1
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
App.idled = true -- 11
local moduleCache = { } -- 13
local oldRequire = _G.require -- 14
local require -- 15
require = function(path) -- 15
	local loaded = package.loaded[path] -- 16
	if loaded == nil then -- 17
		moduleCache[#moduleCache + 1] = path -- 18
		return oldRequire(path) -- 19
	end -- 17
	return loaded -- 20
end -- 15
_G.require = require -- 21
Dora.require = require -- 22
local searchPaths = Content.searchPaths -- 24
local useChinese = (App.locale:match("^zh") ~= nil) -- 26
local updateLocale -- 27
updateLocale = function() -- 27
	useChinese = (App.locale:match("^zh") ~= nil) -- 28
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 29
	Content.searchPaths = searchPaths -- 30
end -- 27
if DB:exist("Config") then -- 32
	local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 33
	local _type_0 = type(_exp_0) -- 34
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 34
	if _tab_0 then -- 34
		local locale -- 34
		do -- 34
			local _obj_0 = _exp_0[1] -- 34
			local _type_1 = type(_obj_0) -- 34
			if "table" == _type_1 or "userdata" == _type_1 then -- 34
				locale = _obj_0[1] -- 34
			end -- 36
		end -- 36
		if locale ~= nil then -- 34
			if App.locale ~= locale then -- 34
				App.locale = locale -- 35
				updateLocale() -- 36
			end -- 34
		end -- 34
	end -- 36
end -- 32
local Config = require("Config") -- 38
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter") -- 39
config:load() -- 58
if (config.fpsLimited ~= nil) then -- 59
	App.fpsLimited = config.fpsLimited == 1 -- 60
else -- 62
	config.fpsLimited = App.fpsLimited and 1 or 0 -- 62
end -- 59
if (config.targetFPS ~= nil) then -- 64
	App.targetFPS = config.targetFPS -- 65
else -- 67
	config.targetFPS = App.targetFPS -- 67
end -- 64
if (config.vsync ~= nil) then -- 69
	View.vsync = config.vsync == 1 -- 70
else -- 72
	config.vsync = View.vsync and 1 or 0 -- 72
end -- 69
if (config.fixedFPS ~= nil) then -- 74
	Director.scheduler.fixedFPS = config.fixedFPS -- 75
else -- 77
	config.fixedFPS = Director.scheduler.fixedFPS -- 77
end -- 74
local showEntry = true -- 79
if (function() -- 81
	local _val_0 = App.platform -- 81
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 81
end)() then -- 81
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 82
		App.winSize = Size.zero -- 83
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 84
		local size = Size(config.winWidth, config.winHeight) -- 85
		if App.winSize ~= size then -- 86
			App.winSize = size -- 87
			showEntry = false -- 88
			thread(function() -- 89
				sleep() -- 90
				sleep() -- 91
				showEntry = true -- 92
			end) -- 89
		end -- 86
		local winX, winY -- 93
		do -- 93
			local _obj_0 = App.winPosition -- 93
			winX, winY = _obj_0.x, _obj_0.y -- 93
		end -- 93
		if (config.winX ~= nil) then -- 94
			winX = config.winX -- 95
		else -- 97
			config.winX = 0 -- 97
		end -- 94
		if (config.winY ~= nil) then -- 98
			winY = config.winY -- 99
		else -- 101
			config.winY = 0 -- 101
		end -- 98
		App.winPosition = Vec2(winX, winY) -- 102
	end -- 82
end -- 81
if (config.themeColor ~= nil) then -- 104
	App.themeColor = Color(config.themeColor) -- 105
else -- 107
	config.themeColor = App.themeColor:toARGB() -- 107
end -- 104
if not (config.locale ~= nil) then -- 109
	config.locale = App.locale -- 110
end -- 109
local showStats = false -- 112
if (config.showStats ~= nil) then -- 113
	showStats = config.showStats > 0 -- 114
else -- 116
	config.showStats = showStats and 1 or 0 -- 116
end -- 113
local showConsole = true -- 118
if (config.showConsole ~= nil) then -- 119
	showConsole = config.showConsole > 0 -- 120
else -- 122
	config.showConsole = showConsole and 1 or 0 -- 122
end -- 119
local showFooter = true -- 124
if (config.showFooter ~= nil) then -- 125
	showFooter = config.showFooter > 0 -- 126
else -- 128
	config.showFooter = showFooter and 1 or 0 -- 128
end -- 125
local filterBuf = Buffer(20) -- 130
if (config.filter ~= nil) then -- 131
	filterBuf:setString(config.filter) -- 132
else -- 134
	config.filter = "" -- 134
end -- 131
_module_0.getConfig = function() -- 136
	return config -- 136
end -- 136
local Set, Struct, LintYueGlobals, GSplit -- 138
do -- 138
	local _obj_0 = require("Utils") -- 138
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 138
end -- 138
local yueext = yue.options.extension -- 139
local isChineseSupported = IsFontLoaded() -- 141
if not isChineseSupported then -- 142
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 143
		isChineseSupported = true -- 144
	end) -- 143
end -- 142
local building = false -- 146
local getAllFiles -- 148
getAllFiles = function(path, exts) -- 148
	local filters = Set(exts) -- 149
	local _accum_0 = { } -- 150
	local _len_0 = 1 -- 150
	local _list_0 = Content:getAllFiles(path) -- 150
	for _index_0 = 1, #_list_0 do -- 150
		local file = _list_0[_index_0] -- 150
		if not filters[Path:getExt(file)] then -- 151
			goto _continue_0 -- 151
		end -- 151
		_accum_0[_len_0] = file -- 152
		_len_0 = _len_0 + 1 -- 152
		::_continue_0:: -- 151
	end -- 152
	return _accum_0 -- 152
end -- 148
local getFileEntries -- 154
getFileEntries = function(path) -- 154
	local entries = { } -- 155
	local _list_0 = getAllFiles(path, { -- 156
		"lua", -- 156
		"xml", -- 156
		yueext, -- 156
		"tl" -- 156
	}) -- 156
	for _index_0 = 1, #_list_0 do -- 156
		local file = _list_0[_index_0] -- 156
		local entryName = Path:getName(file) -- 157
		local entryAdded = false -- 158
		for _index_1 = 1, #entries do -- 159
			local _des_0 = entries[_index_1] -- 159
			local ename = _des_0[1] -- 159
			if entryName == ename then -- 160
				entryAdded = true -- 161
				break -- 162
			end -- 160
		end -- 162
		if entryAdded then -- 163
			goto _continue_0 -- 163
		end -- 163
		local fileName = Path:replaceExt(file, "") -- 164
		fileName = Path(path, fileName) -- 165
		local entry = { -- 166
			entryName, -- 166
			fileName -- 166
		} -- 166
		entries[#entries + 1] = entry -- 167
		::_continue_0:: -- 157
	end -- 167
	table.sort(entries, function(a, b) -- 168
		return a[1] < b[1] -- 168
	end) -- 168
	return entries -- 169
end -- 154
local getProjectEntries -- 171
getProjectEntries = function(path) -- 171
	local entries = { } -- 172
	local _list_0 = Content:getDirs(path) -- 173
	for _index_0 = 1, #_list_0 do -- 173
		local dir = _list_0[_index_0] -- 173
		if dir:match("^%.") then -- 174
			goto _continue_0 -- 174
		end -- 174
		local _list_1 = getAllFiles(Path(path, dir), { -- 175
			"lua", -- 175
			"xml", -- 175
			yueext, -- 175
			"tl", -- 175
			"wasm" -- 175
		}) -- 175
		for _index_1 = 1, #_list_1 do -- 175
			local file = _list_1[_index_1] -- 175
			if "init" == Path:getName(file):lower() then -- 176
				local fileName = Path:replaceExt(file, "") -- 177
				fileName = Path(path, dir, fileName) -- 178
				local entryName = Path:getName(Path:getPath(fileName)) -- 179
				local entryAdded = false -- 180
				for _index_2 = 1, #entries do -- 181
					local _des_0 = entries[_index_2] -- 181
					local ename = _des_0[1] -- 181
					if entryName == ename then -- 182
						entryAdded = true -- 183
						break -- 184
					end -- 182
				end -- 184
				if entryAdded then -- 185
					goto _continue_1 -- 185
				end -- 185
				local examples = { } -- 186
				local tests = { } -- 187
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 188
				if Content:exist(examplePath) then -- 189
					local _list_2 = getFileEntries(examplePath) -- 190
					for _index_2 = 1, #_list_2 do -- 190
						local _des_0 = _list_2[_index_2] -- 190
						local name, ePath = _des_0[1], _des_0[2] -- 190
						local entry = { -- 191
							name, -- 191
							Path(path, dir, Path:getPath(file), ePath) -- 191
						} -- 191
						examples[#examples + 1] = entry -- 192
					end -- 192
				end -- 189
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 193
				if Content:exist(testPath) then -- 194
					local _list_2 = getFileEntries(testPath) -- 195
					for _index_2 = 1, #_list_2 do -- 195
						local _des_0 = _list_2[_index_2] -- 195
						local name, tPath = _des_0[1], _des_0[2] -- 195
						local entry = { -- 196
							name, -- 196
							Path(path, dir, Path:getPath(file), tPath) -- 196
						} -- 196
						tests[#tests + 1] = entry -- 197
					end -- 197
				end -- 194
				local entry = { -- 198
					entryName, -- 198
					fileName, -- 198
					examples, -- 198
					tests -- 198
				} -- 198
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 199
				if not Content:exist(bannerFile) then -- 200
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 201
					if not Content:exist(bannerFile) then -- 202
						bannerFile = nil -- 202
					end -- 202
				end -- 200
				if bannerFile then -- 203
					thread(function() -- 203
						Cache:loadAsync(bannerFile) -- 204
						local bannerTex = Texture2D(bannerFile) -- 205
						if bannerTex then -- 206
							entry[#entry + 1] = bannerFile -- 207
							entry[#entry + 1] = bannerTex -- 208
						end -- 206
					end) -- 203
				end -- 203
				entries[#entries + 1] = entry -- 209
			end -- 176
			::_continue_1:: -- 176
		end -- 209
		::_continue_0:: -- 174
	end -- 209
	table.sort(entries, function(a, b) -- 210
		return a[1] < b[1] -- 210
	end) -- 210
	return entries -- 211
end -- 171
local gamesInDev, games -- 213
local doraExamples, doraTests -- 214
local cppTests, cppTestSet -- 215
local allEntries -- 216
local updateEntries -- 218
updateEntries = function() -- 218
	gamesInDev = getProjectEntries(Content.writablePath) -- 219
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 220
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 222
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 223
	cppTests = { } -- 225
	local _list_0 = App.testNames -- 226
	for _index_0 = 1, #_list_0 do -- 226
		local name = _list_0[_index_0] -- 226
		local entry = { -- 227
			name -- 227
		} -- 227
		cppTests[#cppTests + 1] = entry -- 228
	end -- 228
	cppTestSet = Set(cppTests) -- 229
	allEntries = { } -- 231
	for _index_0 = 1, #gamesInDev do -- 232
		local game = gamesInDev[_index_0] -- 232
		allEntries[#allEntries + 1] = game -- 233
		local examples, tests = game[3], game[4] -- 234
		for _index_1 = 1, #examples do -- 235
			local example = examples[_index_1] -- 235
			allEntries[#allEntries + 1] = example -- 236
		end -- 236
		for _index_1 = 1, #tests do -- 237
			local test = tests[_index_1] -- 237
			allEntries[#allEntries + 1] = test -- 238
		end -- 238
	end -- 238
	for _index_0 = 1, #games do -- 239
		local game = games[_index_0] -- 239
		allEntries[#allEntries + 1] = game -- 240
		local examples, tests = game[3], game[4] -- 241
		for _index_1 = 1, #examples do -- 242
			local example = examples[_index_1] -- 242
			doraExamples[#doraExamples + 1] = example -- 243
		end -- 243
		for _index_1 = 1, #tests do -- 244
			local test = tests[_index_1] -- 244
			doraTests[#doraTests + 1] = test -- 245
		end -- 245
	end -- 245
	local _list_1 = { -- 247
		doraExamples, -- 247
		doraTests, -- 248
		cppTests -- 249
	} -- 246
	for _index_0 = 1, #_list_1 do -- 250
		local group = _list_1[_index_0] -- 246
		for _index_1 = 1, #group do -- 251
			local entry = group[_index_1] -- 251
			allEntries[#allEntries + 1] = entry -- 252
		end -- 252
	end -- 252
end -- 218
updateEntries() -- 254
local doCompile -- 256
doCompile = function(minify) -- 256
	if building then -- 257
		return -- 257
	end -- 257
	building = true -- 258
	local startTime = App.runningTime -- 259
	local luaFiles = { } -- 260
	local yueFiles = { } -- 261
	local xmlFiles = { } -- 262
	local tlFiles = { } -- 263
	local writablePath = Content.writablePath -- 264
	local buildPaths = { -- 266
		{ -- 267
			Path(Content.assetPath), -- 267
			Path(writablePath, ".build"), -- 268
			"" -- 269
		} -- 266
	} -- 265
	for _index_0 = 1, #gamesInDev do -- 272
		local _des_0 = gamesInDev[_index_0] -- 272
		local entryFile = _des_0[2] -- 272
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 273
		buildPaths[#buildPaths + 1] = { -- 275
			Path(writablePath, gamePath), -- 275
			Path(writablePath, ".build", gamePath), -- 276
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 277
			gamePath -- 278
		} -- 274
	end -- 278
	for _index_0 = 1, #buildPaths do -- 279
		local _des_0 = buildPaths[_index_0] -- 279
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 279
		if not Content:exist(inputPath) then -- 280
			goto _continue_0 -- 280
		end -- 280
		local _list_0 = getAllFiles(inputPath, { -- 282
			"lua" -- 282
		}) -- 282
		for _index_1 = 1, #_list_0 do -- 282
			local file = _list_0[_index_1] -- 282
			luaFiles[#luaFiles + 1] = { -- 284
				file, -- 284
				Path(inputPath, file), -- 285
				Path(outputPath, file), -- 286
				gamePath -- 287
			} -- 283
		end -- 287
		local _list_1 = getAllFiles(inputPath, { -- 289
			yueext -- 289
		}) -- 289
		for _index_1 = 1, #_list_1 do -- 289
			local file = _list_1[_index_1] -- 289
			yueFiles[#yueFiles + 1] = { -- 291
				file, -- 291
				Path(inputPath, file), -- 292
				Path(outputPath, Path:replaceExt(file, "lua")), -- 293
				searchPath, -- 294
				gamePath -- 295
			} -- 290
		end -- 295
		local _list_2 = getAllFiles(inputPath, { -- 297
			"xml" -- 297
		}) -- 297
		for _index_1 = 1, #_list_2 do -- 297
			local file = _list_2[_index_1] -- 297
			xmlFiles[#xmlFiles + 1] = { -- 299
				file, -- 299
				Path(inputPath, file), -- 300
				Path(outputPath, Path:replaceExt(file, "lua")), -- 301
				gamePath -- 302
			} -- 298
		end -- 302
		local _list_3 = getAllFiles(inputPath, { -- 304
			"tl" -- 304
		}) -- 304
		for _index_1 = 1, #_list_3 do -- 304
			local file = _list_3[_index_1] -- 304
			if not file:match(".*%.d%.tl$") then -- 305
				tlFiles[#tlFiles + 1] = { -- 307
					file, -- 307
					Path(inputPath, file), -- 308
					Path(outputPath, Path:replaceExt(file, "lua")), -- 309
					searchPath, -- 310
					gamePath -- 311
				} -- 306
			end -- 305
		end -- 311
		::_continue_0:: -- 280
	end -- 311
	local paths -- 313
	do -- 313
		local _tbl_0 = { } -- 313
		local _list_0 = { -- 314
			luaFiles, -- 314
			yueFiles, -- 314
			xmlFiles, -- 314
			tlFiles -- 314
		} -- 314
		for _index_0 = 1, #_list_0 do -- 314
			local files = _list_0[_index_0] -- 314
			for _index_1 = 1, #files do -- 315
				local file = files[_index_1] -- 315
				_tbl_0[Path:getPath(file[3])] = true -- 313
			end -- 313
		end -- 313
		paths = _tbl_0 -- 313
	end -- 315
	for path in pairs(paths) do -- 317
		Content:mkdir(path) -- 317
	end -- 317
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 319
	local fileCount = 0 -- 320
	local errors = { } -- 321
	for _index_0 = 1, #yueFiles do -- 322
		local _des_0 = yueFiles[_index_0] -- 322
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 322
		local filename -- 323
		if gamePath then -- 323
			filename = Path(gamePath, file) -- 323
		else -- 323
			filename = file -- 323
		end -- 323
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 324
			if not codes then -- 325
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 326
				return -- 327
			end -- 325
			local success, result = LintYueGlobals(codes, globals) -- 328
			if success then -- 329
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 330
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 331
				codes = codes:gsub("^\n*", "") -- 332
				if not (result == "") then -- 333
					result = result .. "\n" -- 333
				end -- 333
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 334
			else -- 336
				local yueCodes = Content:load(input) -- 336
				if yueCodes then -- 336
					local globalErrors = { } -- 337
					for _index_1 = 1, #result do -- 338
						local _des_1 = result[_index_1] -- 338
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 338
						local countLine = 1 -- 339
						local code = "" -- 340
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 341
							if countLine == line then -- 342
								code = lineCode -- 343
								break -- 344
							end -- 342
							countLine = countLine + 1 -- 345
						end -- 345
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 346
					end -- 346
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 347
				else -- 349
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 349
				end -- 336
			end -- 329
		end, function(success) -- 324
			if success then -- 350
				print("Yue compiled: " .. tostring(filename)) -- 350
			end -- 350
			fileCount = fileCount + 1 -- 351
		end) -- 324
	end -- 351
	thread(function() -- 353
		for _index_0 = 1, #xmlFiles do -- 354
			local _des_0 = xmlFiles[_index_0] -- 354
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 354
			local filename -- 355
			if gamePath then -- 355
				filename = Path(gamePath, file) -- 355
			else -- 355
				filename = file -- 355
			end -- 355
			local sourceCodes = Content:loadAsync(input) -- 356
			local codes, err = xml.tolua(sourceCodes) -- 357
			if not codes then -- 358
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 359
			else -- 361
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 361
				print("Xml compiled: " .. tostring(filename)) -- 362
			end -- 358
			fileCount = fileCount + 1 -- 363
		end -- 363
	end) -- 353
	thread(function() -- 365
		for _index_0 = 1, #tlFiles do -- 366
			local _des_0 = tlFiles[_index_0] -- 366
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 366
			local filename -- 367
			if gamePath then -- 367
				filename = Path(gamePath, file) -- 367
			else -- 367
				filename = file -- 367
			end -- 367
			local sourceCodes = Content:loadAsync(input) -- 368
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 369
			if not codes then -- 370
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 371
			else -- 373
				Content:saveAsync(output, codes) -- 373
				print("Teal compiled: " .. tostring(filename)) -- 374
			end -- 370
			fileCount = fileCount + 1 -- 375
		end -- 375
	end) -- 365
	return thread(function() -- 377
		wait(function() -- 378
			return fileCount == totalFiles -- 378
		end) -- 378
		if minify then -- 379
			local _list_0 = { -- 380
				yueFiles, -- 380
				xmlFiles, -- 380
				tlFiles -- 380
			} -- 380
			for _index_0 = 1, #_list_0 do -- 380
				local files = _list_0[_index_0] -- 380
				for _index_1 = 1, #files do -- 380
					local file = files[_index_1] -- 380
					local output = Path:replaceExt(file[3], "lua") -- 381
					luaFiles[#luaFiles + 1] = { -- 383
						Path:replaceExt(file[1], "lua"), -- 383
						output, -- 384
						output -- 385
					} -- 382
				end -- 385
			end -- 385
			local FormatMini -- 387
			do -- 387
				local _obj_0 = require("luaminify") -- 387
				FormatMini = _obj_0.FormatMini -- 387
			end -- 387
			for _index_0 = 1, #luaFiles do -- 388
				local _des_0 = luaFiles[_index_0] -- 388
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 388
				if Content:exist(input) then -- 389
					local sourceCodes = Content:loadAsync(input) -- 390
					local res, err = FormatMini(sourceCodes) -- 391
					if res then -- 392
						Content:saveAsync(output, res) -- 393
						print("Minify: " .. tostring(file)) -- 394
					else -- 396
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 396
					end -- 392
				else -- 398
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 398
				end -- 389
			end -- 398
			package.loaded["luaminify.FormatMini"] = nil -- 399
			package.loaded["luaminify.ParseLua"] = nil -- 400
			package.loaded["luaminify.Scope"] = nil -- 401
			package.loaded["luaminify.Util"] = nil -- 402
		end -- 379
		local errorMessage = table.concat(errors, "\n") -- 403
		if errorMessage ~= "" then -- 404
			print("\n" .. errorMessage) -- 404
		end -- 404
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 405
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 406
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 407
		Content:clearPathCache() -- 408
		teal.clear() -- 409
		yue.clear() -- 410
		building = false -- 411
	end) -- 411
end -- 256
local doClean -- 413
doClean = function() -- 413
	if building then -- 414
		return -- 414
	end -- 414
	local writablePath = Content.writablePath -- 415
	local targetDir = Path(writablePath, ".build") -- 416
	Content:clearPathCache() -- 417
	if Content:remove(targetDir) then -- 418
		print("Cleaned: " .. tostring(targetDir)) -- 419
	end -- 418
	Content:remove(Path(writablePath, ".upload")) -- 420
	return Content:remove(Path(writablePath, ".download")) -- 421
end -- 413
local screenScale = 2.0 -- 423
local scaleContent = false -- 424
local isInEntry = true -- 425
local currentEntry = nil -- 426
local footerWindow = nil -- 428
local entryWindow = nil -- 429
local setupEventHandlers -- 431
setupEventHandlers = function() -- 431
	local _with_0 = Director.postNode -- 432
	_with_0:gslot("AppTheme", function(argb) -- 433
		config.themeColor = argb -- 434
	end) -- 433
	_with_0:gslot("AppLocale", function(locale) -- 435
		config.locale = locale -- 436
		updateLocale() -- 437
		return teal.clear(true) -- 438
	end) -- 435
	_with_0:gslot("AppWSClose", function() -- 439
		if HttpServer.wsConnectionCount == 0 then -- 440
			return updateEntries() -- 441
		end -- 440
	end) -- 439
	local _exp_0 = App.platform -- 442
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 442
		_with_0:gslot("AppSizeChanged", function() -- 443
			local width, height -- 444
			do -- 444
				local _obj_0 = App.winSize -- 444
				width, height = _obj_0.width, _obj_0.height -- 444
			end -- 444
			config.winWidth = width -- 445
			config.winHeight = height -- 446
		end) -- 443
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 447
			config.fullScreen = fullScreen and 1 or 0 -- 448
		end) -- 447
		_with_0:gslot("AppMoved", function() -- 449
			local _obj_0 = App.winPosition -- 450
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 450
		end) -- 449
	end -- 450
	return _with_0 -- 432
end -- 431
setupEventHandlers() -- 452
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
	Audio:stopStream(0.2) -- 469
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
local stop -- 485
stop = function() -- 485
	if isInEntry then -- 486
		return false -- 486
	end -- 486
	allClear() -- 487
	isInEntry = true -- 488
	currentEntry = nil -- 489
	return true -- 490
end -- 485
_module_0["stop"] = stop -- 490
local _anon_func_0 = function(Content, Path, file, require, type) -- 511
	local scriptPath = Path:getPath(file) -- 504
	Content:insertSearchPath(1, scriptPath) -- 505
	scriptPath = Path(scriptPath, "Script") -- 506
	if Content:exist(scriptPath) then -- 507
		Content:insertSearchPath(1, scriptPath) -- 508
	end -- 507
	local result = require(file) -- 509
	if "function" == type(result) then -- 510
		result() -- 510
	end -- 510
	return nil -- 511
end -- 504
local _anon_func_1 = function(Label, err, fontSize, scroll, width) -- 541
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 538
	label.alignment = "Left" -- 539
	label.textWidth = width - fontSize -- 540
	label.text = err -- 541
	return label -- 538
end -- 538
local enterEntryAsync -- 492
enterEntryAsync = function(entry) -- 492
	isInEntry = false -- 493
	App.idled = false -- 494
	currentEntry = entry -- 495
	local name, file = entry[1], entry[2] -- 496
	if cppTestSet[entry] then -- 497
		if App:runTest(name) then -- 498
			return true -- 499
		else -- 501
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 501
		end -- 498
	end -- 497
	sleep() -- 502
	return xpcall(_anon_func_0, function(msg) -- 511
		local err = debug.traceback(msg) -- 513
		allClear() -- 514
		print(err) -- 515
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 516
		local AlignNode = require("UI.Control.Basic.AlignNode") -- 517
		local LineRect = require("UI.View.Shape.LineRect") -- 518
		local viewWidth, viewHeight -- 519
		do -- 519
			local _obj_0 = View.size -- 519
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 519
		end -- 519
		local width, height = viewWidth - 20, viewHeight - 20 -- 520
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 521
		do -- 522
			local _with_0 = AlignNode({ -- 522
				isRoot = true, -- 522
				inUI = false -- 522
			}) -- 522
			_with_0:addChild((function() -- 523
				local root = AlignNode({ -- 523
					alignWidth = "w", -- 523
					alignHeight = "h" -- 523
				}) -- 523
				root:addChild((function() -- 524
					local scroll = ScrollArea({ -- 525
						width = width, -- 525
						height = height, -- 526
						paddingX = 0, -- 527
						paddingY = 50, -- 528
						viewWidth = height, -- 529
						viewHeight = height -- 530
					}) -- 524
					scroll:slot("AlignLayout", function(w, h) -- 532
						scroll.position = Vec2(w / 2, h / 2) -- 533
						w = w - 20 -- 534
						h = h - 20 -- 535
						scroll.view.children.first.textWidth = w - fontSize -- 536
						return scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 537
					end) -- 532
					scroll.view:addChild(_anon_func_1(Label, err, fontSize, scroll, width)) -- 538
					return scroll -- 524
				end)()) -- 524
				return root -- 523
			end)()) -- 523
			_with_0:alignLayout() -- 542
		end -- 522
		return err -- 543
	end, Content, Path, file, require, type) -- 543
end -- 492
_module_0["enterEntryAsync"] = enterEntryAsync -- 543
local enterDemoEntry -- 545
enterDemoEntry = function(entry) -- 545
	return thread(function() -- 545
		return enterEntryAsync(entry) -- 545
	end) -- 545
end -- 545
local reloadCurrentEntry -- 547
reloadCurrentEntry = function() -- 547
	if currentEntry then -- 548
		allClear() -- 549
		return enterDemoEntry(currentEntry) -- 550
	end -- 548
end -- 547
Director.clearColor = Color(0xff1a1a1a) -- 552
local waitForWebStart = true -- 554
thread(function() -- 555
	sleep(2) -- 556
	waitForWebStart = false -- 557
end) -- 555
local reloadDevEntry -- 559
reloadDevEntry = function() -- 559
	return thread(function() -- 559
		waitForWebStart = true -- 560
		doClean() -- 561
		allClear() -- 562
		_G.require = oldRequire -- 563
		Dora.require = oldRequire -- 564
		package.loaded["Script.Dev.Entry"] = nil -- 565
		return Director.systemScheduler:schedule(function() -- 566
			Routine:clear() -- 567
			oldRequire("Script.Dev.Entry") -- 568
			return true -- 569
		end) -- 569
	end) -- 569
end -- 559
local isOSSLicenseExist = Content:exist("LICENSES") -- 571
local ossLicenses = nil -- 572
local ossLicenseOpen = false -- 573
local extraOperations -- 575
extraOperations = function() -- 575
	local zh = useChinese and isChineseSupported -- 576
	if isOSSLicenseExist then -- 577
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 578
			if not ossLicenses then -- 579
				ossLicenses = { } -- 580
				local licenseText = Content:load("LICENSES") -- 581
				ossLicenseOpen = (licenseText ~= nil) -- 582
				if ossLicenseOpen then -- 582
					licenseText = licenseText:gsub("\r\n", "\n") -- 583
					for license in GSplit(licenseText, "\n--------\n", true) do -- 584
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 585
						if name then -- 585
							ossLicenses[#ossLicenses + 1] = { -- 586
								name, -- 586
								text -- 586
							} -- 586
						end -- 585
					end -- 586
				end -- 582
			else -- 588
				ossLicenseOpen = true -- 588
			end -- 579
		end -- 578
		if ossLicenseOpen then -- 589
			local width, height, themeColor -- 590
			do -- 590
				local _obj_0 = App -- 590
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 590
			end -- 590
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 591
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 592
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 593
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 596
					"NoSavedSettings" -- 596
				}, function() -- 597
					for _index_0 = 1, #ossLicenses do -- 597
						local _des_0 = ossLicenses[_index_0] -- 597
						local firstLine, text = _des_0[1], _des_0[2] -- 597
						local name, license = firstLine:match("(.+): (.+)") -- 598
						TextColored(themeColor, name) -- 599
						SameLine() -- 600
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 601
							return TextWrapped(text) -- 601
						end) -- 601
					end -- 601
				end) -- 593
			end) -- 593
		end -- 589
	end -- 577
	return TreeNode(zh and "开发操作" or "Development", function() -- 603
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 604
			OpenPopup("build") -- 604
		end -- 604
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 605
			return BeginPopup("build", function() -- 605
				if Selectable(zh and "编译" or "Compile") then -- 606
					doCompile(false) -- 606
				end -- 606
				Separator() -- 607
				if Selectable(zh and "压缩" or "Minify") then -- 608
					doCompile(true) -- 608
				end -- 608
				Separator() -- 609
				if Selectable(zh and "清理" or "Clean") then -- 610
					return doClean() -- 610
				end -- 610
			end) -- 610
		end) -- 605
		if isInEntry then -- 611
			if waitForWebStart then -- 612
				BeginDisabled(function() -- 613
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 613
				end) -- 613
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 614
				reloadDevEntry() -- 615
			end -- 612
		end -- 611
		local changed -- 616
		changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 616
		if changed then -- 616
			View.scale = scaleContent and screenScale or 1 -- 617
		end -- 616
	end) -- 603
end -- 575
local transparant = Color(0x0) -- 619
local windowFlags = { -- 621
	"NoTitleBar", -- 621
	"NoResize", -- 622
	"NoMove", -- 623
	"NoCollapse", -- 624
	"NoSavedSettings", -- 625
	"NoBringToFrontOnFocus" -- 626
} -- 620
local initFooter = true -- 627
local _anon_func_2 = function(allEntries, currentIndex) -- 661
	if currentIndex > 1 then -- 661
		return allEntries[currentIndex - 1] -- 662
	else -- 664
		return allEntries[#allEntries] -- 664
	end -- 661
end -- 661
local _anon_func_3 = function(allEntries, currentIndex) -- 668
	if currentIndex < #allEntries then -- 668
		return allEntries[currentIndex + 1] -- 669
	else -- 671
		return allEntries[1] -- 671
	end -- 668
end -- 668
footerWindow = threadLoop(function() -- 628
	local zh = useChinese and isChineseSupported -- 629
	if HttpServer.wsConnectionCount > 0 then -- 630
		return -- 631
	end -- 630
	if Keyboard:isKeyDown("Escape") then -- 632
		App:shutdown() -- 632
	end -- 632
	do -- 633
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 634
		if ctrl and Keyboard:isKeyDown("Q") then -- 635
			stop() -- 636
		end -- 635
		if ctrl and Keyboard:isKeyDown("Z") then -- 637
			reloadCurrentEntry() -- 638
		end -- 637
		if ctrl and Keyboard:isKeyDown(",") then -- 639
			if showFooter then -- 640
				showStats = not showStats -- 640
			else -- 640
				showStats = true -- 640
			end -- 640
			showFooter = true -- 641
			config.showFooter = showFooter and 1 or 0 -- 642
			config.showStats = showStats and 1 or 0 -- 643
		end -- 639
		if ctrl and Keyboard:isKeyDown(".") then -- 644
			if showFooter then -- 645
				showConsole = not showConsole -- 645
			else -- 645
				showConsole = true -- 645
			end -- 645
			showFooter = true -- 646
			config.showFooter = showFooter and 1 or 0 -- 647
			config.showConsole = showConsole and 1 or 0 -- 648
		end -- 644
		if ctrl and Keyboard:isKeyDown("/") then -- 649
			showFooter = not showFooter -- 650
			config.showFooter = showFooter and 1 or 0 -- 651
		end -- 649
		local left = ctrl and Keyboard:isKeyDown("Left") -- 652
		local right = ctrl and Keyboard:isKeyDown("Right") -- 653
		local currentIndex = nil -- 654
		for i, entry in ipairs(allEntries) do -- 655
			if currentEntry == entry then -- 656
				currentIndex = i -- 657
			end -- 656
		end -- 657
		if left then -- 658
			allClear() -- 659
			if currentIndex == nil then -- 660
				currentIndex = #allEntries + 1 -- 660
			end -- 660
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 661
		end -- 658
		if right then -- 665
			allClear() -- 666
			if currentIndex == nil then -- 667
				currentIndex = 0 -- 667
			end -- 667
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 668
		end -- 665
	end -- 671
	if not showEntry then -- 672
		return -- 672
	end -- 672
	local width, height -- 674
	do -- 674
		local _obj_0 = App.visualSize -- 674
		width, height = _obj_0.width, _obj_0.height -- 674
	end -- 674
	SetNextWindowSize(Vec2(50, 50)) -- 675
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 676
	PushStyleColor("WindowBg", transparant, function() -- 677
		return Begin("Show", windowFlags, function() -- 677
			if isInEntry or width >= 540 then -- 678
				local changed -- 679
				changed, showFooter = Checkbox("##dev", showFooter) -- 679
				if changed then -- 679
					config.showFooter = showFooter and 1 or 0 -- 680
				end -- 679
			end -- 678
		end) -- 680
	end) -- 677
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 682
		reloadDevEntry() -- 686
	end -- 682
	if initFooter then -- 687
		initFooter = false -- 688
	else -- 690
		if not showFooter then -- 690
			return -- 690
		end -- 690
	end -- 687
	SetNextWindowSize(Vec2(width, 50)) -- 692
	SetNextWindowPos(Vec2(0, height - 50)) -- 693
	SetNextWindowBgAlpha(0.35) -- 694
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 695
		return Begin("Footer", windowFlags, function() -- 695
			Dummy(Vec2(width - 20, 0)) -- 696
			do -- 697
				local changed -- 697
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 697
				if changed then -- 697
					config.showStats = showStats and 1 or 0 -- 698
				end -- 697
			end -- 697
			SameLine() -- 699
			do -- 700
				local changed -- 700
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 700
				if changed then -- 700
					config.showConsole = showConsole and 1 or 0 -- 701
				end -- 700
			end -- 700
			if not isInEntry then -- 702
				SameLine() -- 703
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 704
					allClear() -- 705
					isInEntry = true -- 706
					currentEntry = nil -- 707
				end -- 704
				local currentIndex = nil -- 708
				for i, entry in ipairs(allEntries) do -- 709
					if currentEntry == entry then -- 710
						currentIndex = i -- 711
					end -- 710
				end -- 711
				if currentIndex then -- 712
					if currentIndex > 1 then -- 713
						SameLine() -- 714
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 715
							allClear() -- 716
							enterDemoEntry(allEntries[currentIndex - 1]) -- 717
						end -- 715
					end -- 713
					if currentIndex < #allEntries then -- 718
						SameLine() -- 719
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 720
							allClear() -- 721
							enterDemoEntry(allEntries[currentIndex + 1]) -- 722
						end -- 720
					end -- 718
				end -- 712
				SameLine() -- 723
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 724
					reloadCurrentEntry() -- 725
				end -- 724
			end -- 702
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 726
				if showStats then -- 727
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 728
					showStats = ShowStats(showStats, extraOperations) -- 729
					config.showStats = showStats and 1 or 0 -- 730
				end -- 727
				if showConsole then -- 731
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 732
					showConsole = ShowConsole(showConsole) -- 733
					config.showConsole = showConsole and 1 or 0 -- 734
				end -- 731
			end) -- 734
		end) -- 734
	end) -- 734
end) -- 628
local MaxWidth <const> = 800 -- 736
local displayWindowFlags = { -- 739
	"NoDecoration", -- 739
	"NoSavedSettings", -- 740
	"NoFocusOnAppearing", -- 741
	"NoNav", -- 742
	"NoMove", -- 743
	"NoScrollWithMouse", -- 744
	"AlwaysAutoResize", -- 745
	"NoBringToFrontOnFocus" -- 746
} -- 738
local webStatus = nil -- 748
local descColor = Color(0xffa1a1a1) -- 749
local gameOpen = #gamesInDev == 0 -- 750
local exampleOpen = false -- 751
local testOpen = false -- 752
local filterText = nil -- 753
local anyEntryMatched = false -- 754
local match -- 755
match = function(name) -- 755
	local res = not filterText or name:lower():match(filterText) -- 756
	if res then -- 757
		anyEntryMatched = true -- 757
	end -- 757
	return res -- 758
end -- 755
entryWindow = threadLoop(function() -- 760
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 761
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 762
	end -- 761
	if App.targetFPS ~= config.targetFPS then -- 763
		config.targetFPS = App.targetFPS -- 764
	end -- 763
	if View.vsync ~= (config.vsync == 1) then -- 765
		config.vsync = View.vsync and 1 or 0 -- 766
	end -- 765
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 767
		config.fixedFPS = Director.scheduler.fixedFPS -- 768
	end -- 767
	if not showEntry then -- 769
		return -- 769
	end -- 769
	if not isInEntry then -- 770
		return -- 770
	end -- 770
	local zh = useChinese and isChineseSupported -- 771
	if HttpServer.wsConnectionCount > 0 then -- 772
		local themeColor = App.themeColor -- 773
		local width, height -- 774
		do -- 774
			local _obj_0 = App.visualSize -- 774
			width, height = _obj_0.width, _obj_0.height -- 774
		end -- 774
		SetNextWindowBgAlpha(0.5) -- 775
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 776
		Begin("Web IDE Connected", displayWindowFlags, function() -- 777
			Separator() -- 778
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 779
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 780
			TextColored(descColor, slogon) -- 781
			return Separator() -- 782
		end) -- 777
		return -- 783
	end -- 772
	local themeColor = App.themeColor -- 785
	local fullWidth, height -- 786
	do -- 786
		local _obj_0 = App.visualSize -- 786
		fullWidth, height = _obj_0.width, _obj_0.height -- 786
	end -- 786
	SetNextWindowBgAlpha(0.85) -- 788
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 789
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 790
		return Begin("Web IDE", displayWindowFlags, function() -- 791
			Separator() -- 792
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 793
			local url -- 794
			do -- 794
				local _exp_0 -- 794
				if webStatus ~= nil then -- 794
					_exp_0 = webStatus.url -- 794
				end -- 794
				if _exp_0 ~= nil then -- 794
					url = _exp_0 -- 794
				else -- 794
					url = zh and '不可用' or 'not available' -- 794
				end -- 794
			end -- 794
			TextColored(descColor, url) -- 795
			return Separator() -- 796
		end) -- 796
	end) -- 790
	local width = math.min(MaxWidth, fullWidth) -- 798
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 799
	local maxColumns = math.max(math.floor(width / 200), 1) -- 800
	SetNextWindowPos(Vec2.zero) -- 801
	SetNextWindowBgAlpha(0) -- 802
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 803
		return Begin("Dora Dev", displayWindowFlags, function() -- 804
			Dummy(Vec2(fullWidth - 20, 0)) -- 805
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 806
			SameLine() -- 807
			if fullWidth >= 320 then -- 808
				Dummy(Vec2(fullWidth - 320, 0)) -- 809
				SameLine() -- 810
				SetNextItemWidth(-50) -- 811
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 812
					"AutoSelectAll" -- 812
				}) then -- 812
					config.filter = filterBuf:toString() -- 813
				end -- 812
			end -- 808
			Separator() -- 814
			return Dummy(Vec2(fullWidth - 20, 0)) -- 815
		end) -- 815
	end) -- 803
	anyEntryMatched = false -- 817
	SetNextWindowPos(Vec2(0, 50)) -- 818
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 819
	return PushStyleColor("WindowBg", transparant, function() -- 820
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 820
			return Begin("Content", windowFlags, function() -- 821
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 822
				if filterText then -- 823
					filterText = filterText:lower() -- 823
				end -- 823
				if #gamesInDev > 0 then -- 824
					for _index_0 = 1, #gamesInDev do -- 825
						local game = gamesInDev[_index_0] -- 825
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 826
						local showSep = false -- 827
						if match(gameName) then -- 828
							Columns(1, false) -- 829
							TextColored(themeColor, zh and "项目：" or "Project:") -- 830
							SameLine() -- 831
							Text(gameName) -- 832
							Separator() -- 833
							if bannerFile then -- 834
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 835
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 836
								local sizing <const> = 0.8 -- 837
								texHeight = displayWidth * sizing * texHeight / texWidth -- 838
								texWidth = displayWidth * sizing -- 839
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 840
								Dummy(Vec2(padding, 0)) -- 841
								SameLine() -- 842
								PushID(fileName, function() -- 843
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 844
										return enterDemoEntry(game) -- 845
									end -- 844
								end) -- 843
							else -- 847
								PushID(fileName, function() -- 847
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 848
										return enterDemoEntry(game) -- 849
									end -- 848
								end) -- 847
							end -- 834
							NextColumn() -- 850
							showSep = true -- 851
						end -- 828
						if #examples > 0 then -- 852
							local showExample = false -- 853
							for _index_1 = 1, #examples do -- 854
								local example = examples[_index_1] -- 854
								if match(example[1]) then -- 855
									showExample = true -- 856
									break -- 857
								end -- 855
							end -- 857
							if showExample then -- 858
								Columns(1, false) -- 859
								TextColored(themeColor, zh and "示例：" or "Example:") -- 860
								SameLine() -- 861
								Text(gameName) -- 862
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 863
									Columns(maxColumns, false) -- 864
									for _index_1 = 1, #examples do -- 865
										local example = examples[_index_1] -- 865
										if not match(example[1]) then -- 866
											goto _continue_0 -- 866
										end -- 866
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 867
											if Button(example[1], Vec2(-1, 40)) then -- 868
												enterDemoEntry(example) -- 869
											end -- 868
											return NextColumn() -- 870
										end) -- 867
										showSep = true -- 871
										::_continue_0:: -- 866
									end -- 871
								end) -- 863
							end -- 858
						end -- 852
						if #tests > 0 then -- 872
							local showTest = false -- 873
							for _index_1 = 1, #tests do -- 874
								local test = tests[_index_1] -- 874
								if match(test[1]) then -- 875
									showTest = true -- 876
									break -- 877
								end -- 875
							end -- 877
							if showTest then -- 878
								Columns(1, false) -- 879
								TextColored(themeColor, zh and "测试：" or "Test:") -- 880
								SameLine() -- 881
								Text(gameName) -- 882
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 883
									Columns(maxColumns, false) -- 884
									for _index_1 = 1, #tests do -- 885
										local test = tests[_index_1] -- 885
										if not match(test[1]) then -- 886
											goto _continue_0 -- 886
										end -- 886
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 887
											if Button(test[1], Vec2(-1, 40)) then -- 888
												enterDemoEntry(test) -- 889
											end -- 888
											return NextColumn() -- 890
										end) -- 887
										showSep = true -- 891
										::_continue_0:: -- 886
									end -- 891
								end) -- 883
							end -- 878
						end -- 872
						if showSep then -- 892
							Columns(1, false) -- 893
							Separator() -- 894
						end -- 892
					end -- 894
				end -- 824
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 895
					local showGame = false -- 896
					for _index_0 = 1, #games do -- 897
						local _des_0 = games[_index_0] -- 897
						local name = _des_0[1] -- 897
						if match(name) then -- 898
							showGame = true -- 898
						end -- 898
					end -- 898
					local showExample = false -- 899
					for _index_0 = 1, #doraExamples do -- 900
						local _des_0 = doraExamples[_index_0] -- 900
						local name = _des_0[1] -- 900
						if match(name) then -- 901
							showExample = true -- 901
						end -- 901
					end -- 901
					local showTest = false -- 902
					for _index_0 = 1, #doraTests do -- 903
						local _des_0 = doraTests[_index_0] -- 903
						local name = _des_0[1] -- 903
						if match(name) then -- 904
							showTest = true -- 904
						end -- 904
					end -- 904
					for _index_0 = 1, #cppTests do -- 905
						local _des_0 = cppTests[_index_0] -- 905
						local name = _des_0[1] -- 905
						if match(name) then -- 906
							showTest = true -- 906
						end -- 906
					end -- 906
					if not (showGame or showExample or showTest) then -- 907
						goto endEntry -- 907
					end -- 907
					Columns(1, false) -- 908
					TextColored(themeColor, "Dora SSR:") -- 909
					SameLine() -- 910
					Text(zh and "开发示例" or "Development Showcase") -- 911
					Separator() -- 912
					local demoViewWith <const> = 400 -- 913
					if #games > 0 and showGame then -- 914
						local opened -- 915
						if (filterText ~= nil) then -- 915
							opened = showGame -- 915
						else -- 915
							opened = false -- 915
						end -- 915
						SetNextItemOpen(gameOpen) -- 916
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 917
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 918
							Columns(columns, false) -- 919
							for _index_0 = 1, #games do -- 920
								local game = games[_index_0] -- 920
								if not match(game[1]) then -- 921
									goto _continue_0 -- 921
								end -- 921
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 922
								if columns > 1 then -- 923
									if bannerFile then -- 924
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 925
										local displayWidth <const> = demoViewWith - 40 -- 926
										texHeight = displayWidth * texHeight / texWidth -- 927
										texWidth = displayWidth -- 928
										Text(gameName) -- 929
										PushID(fileName, function() -- 930
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 931
												return enterDemoEntry(game) -- 932
											end -- 931
										end) -- 930
									else -- 934
										PushID(fileName, function() -- 934
											if Button(gameName, Vec2(-1, 40)) then -- 935
												return enterDemoEntry(game) -- 936
											end -- 935
										end) -- 934
									end -- 924
								else -- 938
									if bannerFile then -- 938
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 939
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 940
										local sizing = 0.8 -- 941
										texHeight = displayWidth * sizing * texHeight / texWidth -- 942
										texWidth = displayWidth * sizing -- 943
										if texWidth > 500 then -- 944
											sizing = 0.6 -- 945
											texHeight = displayWidth * sizing * texHeight / texWidth -- 946
											texWidth = displayWidth * sizing -- 947
										end -- 944
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 948
										Dummy(Vec2(padding, 0)) -- 949
										SameLine() -- 950
										Text(gameName) -- 951
										Dummy(Vec2(padding, 0)) -- 952
										SameLine() -- 953
										PushID(fileName, function() -- 954
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 955
												return enterDemoEntry(game) -- 956
											end -- 955
										end) -- 954
									else -- 958
										PushID(fileName, function() -- 958
											if Button(gameName, Vec2(-1, 40)) then -- 959
												return enterDemoEntry(game) -- 960
											end -- 959
										end) -- 958
									end -- 938
								end -- 923
								NextColumn() -- 961
								::_continue_0:: -- 921
							end -- 961
							Columns(1, false) -- 962
							opened = true -- 963
						end) -- 917
						gameOpen = opened -- 964
					end -- 914
					if #doraExamples > 0 and showExample then -- 965
						local opened -- 966
						if (filterText ~= nil) then -- 966
							opened = showExample -- 966
						else -- 966
							opened = false -- 966
						end -- 966
						SetNextItemOpen(exampleOpen) -- 967
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 968
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 969
								Columns(maxColumns, false) -- 970
								for _index_0 = 1, #doraExamples do -- 971
									local example = doraExamples[_index_0] -- 971
									if not match(example[1]) then -- 972
										goto _continue_0 -- 972
									end -- 972
									if Button(example[1], Vec2(-1, 40)) then -- 973
										enterDemoEntry(example) -- 974
									end -- 973
									NextColumn() -- 975
									::_continue_0:: -- 972
								end -- 975
								Columns(1, false) -- 976
								opened = true -- 977
							end) -- 969
						end) -- 968
						exampleOpen = opened -- 978
					end -- 965
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 979
						local opened -- 980
						if (filterText ~= nil) then -- 980
							opened = showTest -- 980
						else -- 980
							opened = false -- 980
						end -- 980
						SetNextItemOpen(testOpen) -- 981
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 982
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 983
								Columns(maxColumns, false) -- 984
								for _index_0 = 1, #doraTests do -- 985
									local test = doraTests[_index_0] -- 985
									if not match(test[1]) then -- 986
										goto _continue_0 -- 986
									end -- 986
									if Button(test[1], Vec2(-1, 40)) then -- 987
										enterDemoEntry(test) -- 988
									end -- 987
									NextColumn() -- 989
									::_continue_0:: -- 986
								end -- 989
								for _index_0 = 1, #cppTests do -- 990
									local test = cppTests[_index_0] -- 990
									if not match(test[1]) then -- 991
										goto _continue_1 -- 991
									end -- 991
									if Button(test[1], Vec2(-1, 40)) then -- 992
										enterDemoEntry(test) -- 993
									end -- 992
									NextColumn() -- 994
									::_continue_1:: -- 991
								end -- 994
								opened = true -- 995
							end) -- 983
						end) -- 982
						testOpen = opened -- 996
					end -- 979
				end -- 895
				::endEntry:: -- 997
				if not anyEntryMatched then -- 998
					SetNextWindowBgAlpha(0) -- 999
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1000
					Begin("Entries Not Found", displayWindowFlags, function() -- 1001
						Separator() -- 1002
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1003
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1004
						return Separator() -- 1005
					end) -- 1001
				end -- 998
				Columns(1, false) -- 1006
				Dummy(Vec2(100, 80)) -- 1007
				return ScrollWhenDraggingOnVoid() -- 1008
			end) -- 1008
		end) -- 1008
	end) -- 1008
end) -- 760
webStatus = require("WebServer") -- 1010
return _module_0 -- 1010
