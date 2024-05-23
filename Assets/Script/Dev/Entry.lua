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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter") -- 41
config:load() -- 60
if (config.fpsLimited ~= nil) then -- 61
	App.fpsLimited = config.fpsLimited == 1 -- 62
else -- 64
	config.fpsLimited = App.fpsLimited and 1 or 0 -- 64
end -- 61
if (config.targetFPS ~= nil) then -- 66
	App.targetFPS = config.targetFPS -- 67
else -- 69
	config.targetFPS = App.targetFPS -- 69
end -- 66
if (config.vsync ~= nil) then -- 71
	View.vsync = config.vsync == 1 -- 72
else -- 74
	config.vsync = View.vsync and 1 or 0 -- 74
end -- 71
if (config.fixedFPS ~= nil) then -- 76
	Director.scheduler.fixedFPS = config.fixedFPS -- 77
else -- 79
	config.fixedFPS = Director.scheduler.fixedFPS -- 79
end -- 76
local showEntry = true -- 81
if (function() -- 83
	local _val_0 = App.platform -- 83
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 83
end)() then -- 83
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 84
		App.winSize = Size.zero -- 85
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 86
		local size = Size(config.winWidth, config.winHeight) -- 87
		if App.winSize ~= size then -- 88
			App.winSize = size -- 89
			showEntry = false -- 90
			thread(function() -- 91
				sleep() -- 92
				sleep() -- 93
				showEntry = true -- 94
			end) -- 91
		end -- 88
		local winX, winY -- 95
		do -- 95
			local _obj_0 = App.winPosition -- 95
			winX, winY = _obj_0.x, _obj_0.y -- 95
		end -- 95
		if (config.winX ~= nil) then -- 96
			winX = config.winX -- 97
		else -- 99
			config.winX = 0 -- 99
		end -- 96
		if (config.winY ~= nil) then -- 100
			winY = config.winY -- 101
		else -- 103
			config.winY = 0 -- 103
		end -- 100
		App.winPosition = Vec2(winX, winY) -- 104
	end -- 84
end -- 83
if (config.themeColor ~= nil) then -- 106
	App.themeColor = Color(config.themeColor) -- 107
else -- 109
	config.themeColor = App.themeColor:toARGB() -- 109
end -- 106
if not (config.locale ~= nil) then -- 111
	config.locale = App.locale -- 112
end -- 111
local showStats = false -- 114
if (config.showStats ~= nil) then -- 115
	showStats = config.showStats > 0 -- 116
else -- 118
	config.showStats = showStats and 1 or 0 -- 118
end -- 115
local showConsole = true -- 120
if (config.showConsole ~= nil) then -- 121
	showConsole = config.showConsole > 0 -- 122
else -- 124
	config.showConsole = showConsole and 1 or 0 -- 124
end -- 121
local showFooter = true -- 126
if (config.showFooter ~= nil) then -- 127
	showFooter = config.showFooter > 0 -- 128
else -- 130
	config.showFooter = showFooter and 1 or 0 -- 130
end -- 127
local filterBuf = Buffer(20) -- 132
if (config.filter ~= nil) then -- 133
	filterBuf:setString(config.filter) -- 134
else -- 136
	config.filter = "" -- 136
end -- 133
_module_0.getConfig = function() -- 138
	return config -- 138
end -- 138
local Set, Struct, LintYueGlobals, GSplit -- 140
do -- 140
	local _obj_0 = require("Utils") -- 140
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 140
end -- 140
local yueext = yue.options.extension -- 141
local isChineseSupported = IsFontLoaded() -- 143
if not isChineseSupported then -- 144
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 145
		isChineseSupported = true -- 146
	end) -- 145
end -- 144
local building = false -- 148
local getAllFiles -- 150
getAllFiles = function(path, exts) -- 150
	local filters = Set(exts) -- 151
	local _accum_0 = { } -- 152
	local _len_0 = 1 -- 152
	local _list_0 = Content:getAllFiles(path) -- 152
	for _index_0 = 1, #_list_0 do -- 152
		local file = _list_0[_index_0] -- 152
		if not filters[Path:getExt(file)] then -- 153
			goto _continue_0 -- 153
		end -- 153
		_accum_0[_len_0] = file -- 154
		_len_0 = _len_0 + 1 -- 154
		::_continue_0:: -- 153
	end -- 154
	return _accum_0 -- 154
end -- 150
local getFileEntries -- 156
getFileEntries = function(path) -- 156
	local entries = { } -- 157
	local _list_0 = getAllFiles(path, { -- 158
		"lua", -- 158
		"xml", -- 158
		yueext, -- 158
		"tl" -- 158
	}) -- 158
	for _index_0 = 1, #_list_0 do -- 158
		local file = _list_0[_index_0] -- 158
		local entryName = Path:getName(file) -- 159
		local entryAdded = false -- 160
		for _index_1 = 1, #entries do -- 161
			local _des_0 = entries[_index_1] -- 161
			local ename = _des_0[1] -- 161
			if entryName == ename then -- 162
				entryAdded = true -- 163
				break -- 164
			end -- 162
		end -- 164
		if entryAdded then -- 165
			goto _continue_0 -- 165
		end -- 165
		local fileName = Path:replaceExt(file, "") -- 166
		fileName = Path(path, fileName) -- 167
		local entry = { -- 168
			entryName, -- 168
			fileName -- 168
		} -- 168
		entries[#entries + 1] = entry -- 169
		::_continue_0:: -- 159
	end -- 169
	table.sort(entries, function(a, b) -- 170
		return a[1] < b[1] -- 170
	end) -- 170
	return entries -- 171
end -- 156
local getProjectEntries -- 173
getProjectEntries = function(path) -- 173
	local entries = { } -- 174
	local _list_0 = Content:getDirs(path) -- 175
	for _index_0 = 1, #_list_0 do -- 175
		local dir = _list_0[_index_0] -- 175
		if dir:match("^%.") then -- 176
			goto _continue_0 -- 176
		end -- 176
		local _list_1 = getAllFiles(Path(path, dir), { -- 177
			"lua", -- 177
			"xml", -- 177
			yueext, -- 177
			"tl", -- 177
			"wasm" -- 177
		}) -- 177
		for _index_1 = 1, #_list_1 do -- 177
			local file = _list_1[_index_1] -- 177
			if "init" == Path:getName(file):lower() then -- 178
				local fileName = Path:replaceExt(file, "") -- 179
				fileName = Path(path, dir, fileName) -- 180
				local entryName = Path:getName(Path:getPath(fileName)) -- 181
				local entryAdded = false -- 182
				for _index_2 = 1, #entries do -- 183
					local _des_0 = entries[_index_2] -- 183
					local ename = _des_0[1] -- 183
					if entryName == ename then -- 184
						entryAdded = true -- 185
						break -- 186
					end -- 184
				end -- 186
				if entryAdded then -- 187
					goto _continue_1 -- 187
				end -- 187
				local examples = { } -- 188
				local tests = { } -- 189
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 190
				if Content:exist(examplePath) then -- 191
					local _list_2 = getFileEntries(examplePath) -- 192
					for _index_2 = 1, #_list_2 do -- 192
						local _des_0 = _list_2[_index_2] -- 192
						local name, ePath = _des_0[1], _des_0[2] -- 192
						local entry = { -- 193
							name, -- 193
							Path(path, dir, Path:getPath(file), ePath) -- 193
						} -- 193
						examples[#examples + 1] = entry -- 194
					end -- 194
				end -- 191
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 195
				if Content:exist(testPath) then -- 196
					local _list_2 = getFileEntries(testPath) -- 197
					for _index_2 = 1, #_list_2 do -- 197
						local _des_0 = _list_2[_index_2] -- 197
						local name, tPath = _des_0[1], _des_0[2] -- 197
						local entry = { -- 198
							name, -- 198
							Path(path, dir, Path:getPath(file), tPath) -- 198
						} -- 198
						tests[#tests + 1] = entry -- 199
					end -- 199
				end -- 196
				local entry = { -- 200
					entryName, -- 200
					fileName, -- 200
					examples, -- 200
					tests -- 200
				} -- 200
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 201
				if not Content:exist(bannerFile) then -- 202
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 203
					if not Content:exist(bannerFile) then -- 204
						bannerFile = nil -- 204
					end -- 204
				end -- 202
				if bannerFile then -- 205
					thread(function() -- 205
						Cache:loadAsync(bannerFile) -- 206
						local bannerTex = Texture2D(bannerFile) -- 207
						if bannerTex then -- 208
							entry[#entry + 1] = bannerFile -- 209
							entry[#entry + 1] = bannerTex -- 210
						end -- 208
					end) -- 205
				end -- 205
				entries[#entries + 1] = entry -- 211
			end -- 178
			::_continue_1:: -- 178
		end -- 211
		::_continue_0:: -- 176
	end -- 211
	table.sort(entries, function(a, b) -- 212
		return a[1] < b[1] -- 212
	end) -- 212
	return entries -- 213
end -- 173
local gamesInDev, games -- 215
local doraExamples, doraTests -- 216
local cppTests, cppTestSet -- 217
local allEntries -- 218
local updateEntries -- 220
updateEntries = function() -- 220
	gamesInDev = getProjectEntries(Content.writablePath) -- 221
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 222
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 224
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 225
	cppTests = { } -- 227
	local _list_0 = App.testNames -- 228
	for _index_0 = 1, #_list_0 do -- 228
		local name = _list_0[_index_0] -- 228
		local entry = { -- 229
			name -- 229
		} -- 229
		cppTests[#cppTests + 1] = entry -- 230
	end -- 230
	cppTestSet = Set(cppTests) -- 231
	allEntries = { } -- 233
	for _index_0 = 1, #gamesInDev do -- 234
		local game = gamesInDev[_index_0] -- 234
		allEntries[#allEntries + 1] = game -- 235
		local examples, tests = game[3], game[4] -- 236
		for _index_1 = 1, #examples do -- 237
			local example = examples[_index_1] -- 237
			allEntries[#allEntries + 1] = example -- 238
		end -- 238
		for _index_1 = 1, #tests do -- 239
			local test = tests[_index_1] -- 239
			allEntries[#allEntries + 1] = test -- 240
		end -- 240
	end -- 240
	for _index_0 = 1, #games do -- 241
		local game = games[_index_0] -- 241
		allEntries[#allEntries + 1] = game -- 242
		local examples, tests = game[3], game[4] -- 243
		for _index_1 = 1, #examples do -- 244
			local example = examples[_index_1] -- 244
			doraExamples[#doraExamples + 1] = example -- 245
		end -- 245
		for _index_1 = 1, #tests do -- 246
			local test = tests[_index_1] -- 246
			doraTests[#doraTests + 1] = test -- 247
		end -- 247
	end -- 247
	local _list_1 = { -- 249
		doraExamples, -- 249
		doraTests, -- 250
		cppTests -- 251
	} -- 248
	for _index_0 = 1, #_list_1 do -- 252
		local group = _list_1[_index_0] -- 248
		for _index_1 = 1, #group do -- 253
			local entry = group[_index_1] -- 253
			allEntries[#allEntries + 1] = entry -- 254
		end -- 254
	end -- 254
end -- 220
updateEntries() -- 256
local doCompile -- 258
doCompile = function(minify) -- 258
	if building then -- 259
		return -- 259
	end -- 259
	building = true -- 260
	local startTime = App.runningTime -- 261
	local luaFiles = { } -- 262
	local yueFiles = { } -- 263
	local xmlFiles = { } -- 264
	local tlFiles = { } -- 265
	local writablePath = Content.writablePath -- 266
	local buildPaths = { -- 268
		{ -- 269
			Path(Content.assetPath), -- 269
			Path(writablePath, ".build"), -- 270
			"" -- 271
		} -- 268
	} -- 267
	for _index_0 = 1, #gamesInDev do -- 274
		local _des_0 = gamesInDev[_index_0] -- 274
		local entryFile = _des_0[2] -- 274
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 275
		buildPaths[#buildPaths + 1] = { -- 277
			Path(writablePath, gamePath), -- 277
			Path(writablePath, ".build", gamePath), -- 278
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 279
			gamePath -- 280
		} -- 276
	end -- 280
	for _index_0 = 1, #buildPaths do -- 281
		local _des_0 = buildPaths[_index_0] -- 281
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 281
		if not Content:exist(inputPath) then -- 282
			goto _continue_0 -- 282
		end -- 282
		local _list_0 = getAllFiles(inputPath, { -- 284
			"lua" -- 284
		}) -- 284
		for _index_1 = 1, #_list_0 do -- 284
			local file = _list_0[_index_1] -- 284
			luaFiles[#luaFiles + 1] = { -- 286
				file, -- 286
				Path(inputPath, file), -- 287
				Path(outputPath, file), -- 288
				gamePath -- 289
			} -- 285
		end -- 289
		local _list_1 = getAllFiles(inputPath, { -- 291
			yueext -- 291
		}) -- 291
		for _index_1 = 1, #_list_1 do -- 291
			local file = _list_1[_index_1] -- 291
			yueFiles[#yueFiles + 1] = { -- 293
				file, -- 293
				Path(inputPath, file), -- 294
				Path(outputPath, Path:replaceExt(file, "lua")), -- 295
				searchPath, -- 296
				gamePath -- 297
			} -- 292
		end -- 297
		local _list_2 = getAllFiles(inputPath, { -- 299
			"xml" -- 299
		}) -- 299
		for _index_1 = 1, #_list_2 do -- 299
			local file = _list_2[_index_1] -- 299
			xmlFiles[#xmlFiles + 1] = { -- 301
				file, -- 301
				Path(inputPath, file), -- 302
				Path(outputPath, Path:replaceExt(file, "lua")), -- 303
				gamePath -- 304
			} -- 300
		end -- 304
		local _list_3 = getAllFiles(inputPath, { -- 306
			"tl" -- 306
		}) -- 306
		for _index_1 = 1, #_list_3 do -- 306
			local file = _list_3[_index_1] -- 306
			if not file:match(".*%.d%.tl$") then -- 307
				tlFiles[#tlFiles + 1] = { -- 309
					file, -- 309
					Path(inputPath, file), -- 310
					Path(outputPath, Path:replaceExt(file, "lua")), -- 311
					searchPath, -- 312
					gamePath -- 313
				} -- 308
			end -- 307
		end -- 313
		::_continue_0:: -- 282
	end -- 313
	local paths -- 315
	do -- 315
		local _tbl_0 = { } -- 315
		local _list_0 = { -- 316
			luaFiles, -- 316
			yueFiles, -- 316
			xmlFiles, -- 316
			tlFiles -- 316
		} -- 316
		for _index_0 = 1, #_list_0 do -- 316
			local files = _list_0[_index_0] -- 316
			for _index_1 = 1, #files do -- 317
				local file = files[_index_1] -- 317
				_tbl_0[Path:getPath(file[3])] = true -- 315
			end -- 315
		end -- 315
		paths = _tbl_0 -- 315
	end -- 317
	for path in pairs(paths) do -- 319
		Content:mkdir(path) -- 319
	end -- 319
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 321
	local fileCount = 0 -- 322
	local errors = { } -- 323
	for _index_0 = 1, #yueFiles do -- 324
		local _des_0 = yueFiles[_index_0] -- 324
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 324
		local filename -- 325
		if gamePath then -- 325
			filename = Path(gamePath, file) -- 325
		else -- 325
			filename = file -- 325
		end -- 325
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 326
			if not codes then -- 327
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 328
				return -- 329
			end -- 327
			local success, result = LintYueGlobals(codes, globals) -- 330
			if success then -- 331
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 332
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 333
				codes = codes:gsub("^\n*", "") -- 334
				if not (result == "") then -- 335
					result = result .. "\n" -- 335
				end -- 335
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 336
			else -- 338
				local yueCodes = Content:load(input) -- 338
				if yueCodes then -- 338
					local globalErrors = { } -- 339
					for _index_1 = 1, #result do -- 340
						local _des_1 = result[_index_1] -- 340
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 340
						local countLine = 1 -- 341
						local code = "" -- 342
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 343
							if countLine == line then -- 344
								code = lineCode -- 345
								break -- 346
							end -- 344
							countLine = countLine + 1 -- 347
						end -- 347
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 348
					end -- 348
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 349
				else -- 351
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 351
				end -- 338
			end -- 331
		end, function(success) -- 326
			if success then -- 352
				print("Yue compiled: " .. tostring(filename)) -- 352
			end -- 352
			fileCount = fileCount + 1 -- 353
		end) -- 326
	end -- 353
	thread(function() -- 355
		for _index_0 = 1, #xmlFiles do -- 356
			local _des_0 = xmlFiles[_index_0] -- 356
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 356
			local filename -- 357
			if gamePath then -- 357
				filename = Path(gamePath, file) -- 357
			else -- 357
				filename = file -- 357
			end -- 357
			local sourceCodes = Content:loadAsync(input) -- 358
			local codes, err = xml.tolua(sourceCodes) -- 359
			if not codes then -- 360
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 361
			else -- 363
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 363
				print("Xml compiled: " .. tostring(filename)) -- 364
			end -- 360
			fileCount = fileCount + 1 -- 365
		end -- 365
	end) -- 355
	thread(function() -- 367
		for _index_0 = 1, #tlFiles do -- 368
			local _des_0 = tlFiles[_index_0] -- 368
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 368
			local filename -- 369
			if gamePath then -- 369
				filename = Path(gamePath, file) -- 369
			else -- 369
				filename = file -- 369
			end -- 369
			local sourceCodes = Content:loadAsync(input) -- 370
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 371
			if not codes then -- 372
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 373
			else -- 375
				Content:saveAsync(output, codes) -- 375
				print("Teal compiled: " .. tostring(filename)) -- 376
			end -- 372
			fileCount = fileCount + 1 -- 377
		end -- 377
	end) -- 367
	return thread(function() -- 379
		wait(function() -- 380
			return fileCount == totalFiles -- 380
		end) -- 380
		if minify then -- 381
			local _list_0 = { -- 382
				yueFiles, -- 382
				xmlFiles, -- 382
				tlFiles -- 382
			} -- 382
			for _index_0 = 1, #_list_0 do -- 382
				local files = _list_0[_index_0] -- 382
				for _index_1 = 1, #files do -- 382
					local file = files[_index_1] -- 382
					local output = Path:replaceExt(file[3], "lua") -- 383
					luaFiles[#luaFiles + 1] = { -- 385
						Path:replaceExt(file[1], "lua"), -- 385
						output, -- 386
						output -- 387
					} -- 384
				end -- 387
			end -- 387
			local FormatMini -- 389
			do -- 389
				local _obj_0 = require("luaminify") -- 389
				FormatMini = _obj_0.FormatMini -- 389
			end -- 389
			for _index_0 = 1, #luaFiles do -- 390
				local _des_0 = luaFiles[_index_0] -- 390
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 390
				if Content:exist(input) then -- 391
					local sourceCodes = Content:loadAsync(input) -- 392
					local res, err = FormatMini(sourceCodes) -- 393
					if res then -- 394
						Content:saveAsync(output, res) -- 395
						print("Minify: " .. tostring(file)) -- 396
					else -- 398
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 398
					end -- 394
				else -- 400
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 400
				end -- 391
			end -- 400
			package.loaded["luaminify.FormatMini"] = nil -- 401
			package.loaded["luaminify.ParseLua"] = nil -- 402
			package.loaded["luaminify.Scope"] = nil -- 403
			package.loaded["luaminify.Util"] = nil -- 404
		end -- 381
		local errorMessage = table.concat(errors, "\n") -- 405
		if errorMessage ~= "" then -- 406
			print("\n" .. errorMessage) -- 406
		end -- 406
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 407
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 408
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 409
		Content:clearPathCache() -- 410
		teal.clear() -- 411
		yue.clear() -- 412
		building = false -- 413
	end) -- 413
end -- 258
local doClean -- 415
doClean = function() -- 415
	if building then -- 416
		return -- 416
	end -- 416
	local writablePath = Content.writablePath -- 417
	local targetDir = Path(writablePath, ".build") -- 418
	Content:clearPathCache() -- 419
	if Content:remove(targetDir) then -- 420
		print("Cleaned: " .. tostring(targetDir)) -- 421
	end -- 420
	Content:remove(Path(writablePath, ".upload")) -- 422
	return Content:remove(Path(writablePath, ".download")) -- 423
end -- 415
local screenScale = 2.0 -- 425
local scaleContent = false -- 426
local isInEntry = true -- 427
local currentEntry = nil -- 428
local footerWindow = nil -- 430
local entryWindow = nil -- 431
local setupEventHandlers -- 433
setupEventHandlers = function() -- 433
	local _with_0 = Director.postNode -- 434
	_with_0:gslot("AppTheme", function(argb) -- 435
		config.themeColor = argb -- 436
	end) -- 435
	_with_0:gslot("AppLocale", function(locale) -- 437
		config.locale = locale -- 438
		updateLocale() -- 439
		return teal.clear(true) -- 440
	end) -- 437
	_with_0:gslot("AppWSClose", function() -- 441
		if HttpServer.wsConnectionCount == 0 then -- 442
			return updateEntries() -- 443
		end -- 442
	end) -- 441
	local _exp_0 = App.platform -- 444
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 444
		_with_0:gslot("AppSizeChanged", function() -- 445
			local width, height -- 446
			do -- 446
				local _obj_0 = App.winSize -- 446
				width, height = _obj_0.width, _obj_0.height -- 446
			end -- 446
			config.winWidth = width -- 447
			config.winHeight = height -- 448
		end) -- 445
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 449
			config.fullScreen = fullScreen and 1 or 0 -- 450
		end) -- 449
		_with_0:gslot("AppMoved", function() -- 451
			local _obj_0 = App.winPosition -- 452
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 452
		end) -- 451
	end -- 452
	return _with_0 -- 434
end -- 433
setupEventHandlers() -- 454
local allClear -- 456
allClear = function() -- 456
	local _list_0 = Routine -- 457
	for _index_0 = 1, #_list_0 do -- 457
		local routine = _list_0[_index_0] -- 457
		if footerWindow == routine or entryWindow == routine then -- 459
			goto _continue_0 -- 460
		else -- 462
			Routine:remove(routine) -- 462
		end -- 462
		::_continue_0:: -- 458
	end -- 462
	for _index_0 = 1, #moduleCache do -- 463
		local module = moduleCache[_index_0] -- 463
		package.loaded[module] = nil -- 464
	end -- 464
	moduleCache = { } -- 465
	Director:cleanup() -- 466
	Cache:unload() -- 467
	Entity:clear() -- 468
	Platformer.Data:clear() -- 469
	Platformer.UnitAction:clear() -- 470
	Audio:stopStream(0.2) -- 471
	Struct:clear() -- 472
	View.postEffect = nil -- 473
	View.scale = scaleContent and screenScale or 1 -- 474
	Director.clearColor = Color(0xff1a1a1a) -- 475
	teal.clear() -- 476
	yue.clear() -- 477
	for _, item in pairs(ubox()) do -- 478
		local node = tolua.cast(item, "Node") -- 479
		if node then -- 479
			node:cleanup() -- 479
		end -- 479
	end -- 479
	collectgarbage() -- 480
	collectgarbage() -- 481
	setupEventHandlers() -- 482
	Content.searchPaths = searchPaths -- 483
	App.idled = true -- 484
	return Wasm:clear() -- 485
end -- 456
_module_0["allClear"] = allClear -- 485
local stop -- 487
stop = function() -- 487
	if isInEntry then -- 488
		return false -- 488
	end -- 488
	allClear() -- 489
	isInEntry = true -- 490
	currentEntry = nil -- 491
	return true -- 492
end -- 487
_module_0["stop"] = stop -- 492
local _anon_func_0 = function(Content, Path, file, require, type) -- 513
	local scriptPath = Path:getPath(file) -- 506
	Content:insertSearchPath(1, scriptPath) -- 507
	scriptPath = Path(scriptPath, "Script") -- 508
	if Content:exist(scriptPath) then -- 509
		Content:insertSearchPath(1, scriptPath) -- 510
	end -- 509
	local result = require(file) -- 511
	if "function" == type(result) then -- 512
		result() -- 512
	end -- 512
	return nil -- 513
end -- 506
local _anon_func_1 = function(Label, err, fontSize, scroll, width) -- 546
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 543
	label.alignment = "Left" -- 544
	label.textWidth = width - fontSize -- 545
	label.text = err -- 546
	return label -- 543
end -- 543
local enterEntryAsync -- 494
enterEntryAsync = function(entry) -- 494
	isInEntry = false -- 495
	App.idled = false -- 496
	currentEntry = entry -- 497
	local name, file = entry[1], entry[2] -- 498
	if cppTestSet[entry] then -- 499
		if App:runTest(name) then -- 500
			return true -- 501
		else -- 503
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 503
		end -- 500
	end -- 499
	sleep() -- 504
	return xpcall(_anon_func_0, function(msg) -- 513
		local err = debug.traceback(msg) -- 515
		allClear() -- 516
		print(err) -- 517
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 518
		local LineRect = require("UI.View.Shape.LineRect") -- 519
		local viewWidth, viewHeight -- 520
		do -- 520
			local _obj_0 = View.size -- 520
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 520
		end -- 520
		local width, height = viewWidth - 20, viewHeight - 20 -- 521
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 522
		Director.ui:addChild((function() -- 523
			local root = AlignNode() -- 523
			do -- 524
				local _obj_0 = App.bufferSize -- 524
				width, height = _obj_0.width, _obj_0.height -- 524
			end -- 524
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 525
			root:gslot("AppSizeChanged", function() -- 526
				do -- 527
					local _obj_0 = App.bufferSize -- 527
					width, height = _obj_0.width, _obj_0.height -- 527
				end -- 527
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 528
			end) -- 526
			root:addChild((function() -- 529
				local scroll = ScrollArea({ -- 530
					width = width, -- 530
					height = height, -- 531
					paddingX = 0, -- 532
					paddingY = 50, -- 533
					viewWidth = height, -- 534
					viewHeight = height -- 535
				}) -- 529
				root:slot("AlignLayout", function(w, h) -- 537
					scroll.position = Vec2(w / 2, h / 2) -- 538
					w = w - 20 -- 539
					h = h - 20 -- 540
					scroll.view.children.first.textWidth = w - fontSize -- 541
					return scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 542
				end) -- 537
				scroll.view:addChild(_anon_func_1(Label, err, fontSize, scroll, width)) -- 543
				return scroll -- 529
			end)()) -- 529
			return root -- 523
		end)()) -- 523
		return err -- 547
	end, Content, Path, file, require, type) -- 547
end -- 494
_module_0["enterEntryAsync"] = enterEntryAsync -- 547
local enterDemoEntry -- 549
enterDemoEntry = function(entry) -- 549
	return thread(function() -- 549
		return enterEntryAsync(entry) -- 549
	end) -- 549
end -- 549
local reloadCurrentEntry -- 551
reloadCurrentEntry = function() -- 551
	if currentEntry then -- 552
		allClear() -- 553
		return enterDemoEntry(currentEntry) -- 554
	end -- 552
end -- 551
Director.clearColor = Color(0xff1a1a1a) -- 556
local waitForWebStart = true -- 558
thread(function() -- 559
	sleep(2) -- 560
	waitForWebStart = false -- 561
end) -- 559
local reloadDevEntry -- 563
reloadDevEntry = function() -- 563
	return thread(function() -- 563
		waitForWebStart = true -- 564
		doClean() -- 565
		allClear() -- 566
		_G.require = oldRequire -- 567
		Dora.require = oldRequire -- 568
		package.loaded["Script.Dev.Entry"] = nil -- 569
		return Director.systemScheduler:schedule(function() -- 570
			Routine:clear() -- 571
			oldRequire("Script.Dev.Entry") -- 572
			return true -- 573
		end) -- 573
	end) -- 573
end -- 563
local isOSSLicenseExist = Content:exist("LICENSES") -- 575
local ossLicenses = nil -- 576
local ossLicenseOpen = false -- 577
local extraOperations -- 579
extraOperations = function() -- 579
	local zh = useChinese and isChineseSupported -- 580
	if isOSSLicenseExist then -- 581
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 582
			if not ossLicenses then -- 583
				ossLicenses = { } -- 584
				local licenseText = Content:load("LICENSES") -- 585
				ossLicenseOpen = (licenseText ~= nil) -- 586
				if ossLicenseOpen then -- 586
					licenseText = licenseText:gsub("\r\n", "\n") -- 587
					for license in GSplit(licenseText, "\n--------\n", true) do -- 588
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 589
						if name then -- 589
							ossLicenses[#ossLicenses + 1] = { -- 590
								name, -- 590
								text -- 590
							} -- 590
						end -- 589
					end -- 590
				end -- 586
			else -- 592
				ossLicenseOpen = true -- 592
			end -- 583
		end -- 582
		if ossLicenseOpen then -- 593
			local width, height, themeColor -- 594
			do -- 594
				local _obj_0 = App -- 594
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 594
			end -- 594
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 595
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 596
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 597
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 600
					"NoSavedSettings" -- 600
				}, function() -- 601
					for _index_0 = 1, #ossLicenses do -- 601
						local _des_0 = ossLicenses[_index_0] -- 601
						local firstLine, text = _des_0[1], _des_0[2] -- 601
						local name, license = firstLine:match("(.+): (.+)") -- 602
						TextColored(themeColor, name) -- 603
						SameLine() -- 604
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 605
							return TextWrapped(text) -- 605
						end) -- 605
					end -- 605
				end) -- 597
			end) -- 597
		end -- 593
	end -- 581
	return TreeNode(zh and "开发操作" or "Development", function() -- 607
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 608
			OpenPopup("build") -- 608
		end -- 608
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 609
			return BeginPopup("build", function() -- 609
				if Selectable(zh and "编译" or "Compile") then -- 610
					doCompile(false) -- 610
				end -- 610
				Separator() -- 611
				if Selectable(zh and "压缩" or "Minify") then -- 612
					doCompile(true) -- 612
				end -- 612
				Separator() -- 613
				if Selectable(zh and "清理" or "Clean") then -- 614
					return doClean() -- 614
				end -- 614
			end) -- 614
		end) -- 609
		if isInEntry then -- 615
			if waitForWebStart then -- 616
				BeginDisabled(function() -- 617
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 617
				end) -- 617
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 618
				reloadDevEntry() -- 619
			end -- 616
		end -- 615
		local changed -- 620
		changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 620
		if changed then -- 620
			View.scale = scaleContent and screenScale or 1 -- 621
		end -- 620
	end) -- 607
end -- 579
local transparant = Color(0x0) -- 623
local windowFlags = { -- 625
	"NoTitleBar", -- 625
	"NoResize", -- 626
	"NoMove", -- 627
	"NoCollapse", -- 628
	"NoSavedSettings", -- 629
	"NoBringToFrontOnFocus" -- 630
} -- 624
local initFooter = true -- 631
local _anon_func_2 = function(allEntries, currentIndex) -- 665
	if currentIndex > 1 then -- 665
		return allEntries[currentIndex - 1] -- 666
	else -- 668
		return allEntries[#allEntries] -- 668
	end -- 665
end -- 665
local _anon_func_3 = function(allEntries, currentIndex) -- 672
	if currentIndex < #allEntries then -- 672
		return allEntries[currentIndex + 1] -- 673
	else -- 675
		return allEntries[1] -- 675
	end -- 672
end -- 672
footerWindow = threadLoop(function() -- 632
	local zh = useChinese and isChineseSupported -- 633
	if HttpServer.wsConnectionCount > 0 then -- 634
		return -- 635
	end -- 634
	if Keyboard:isKeyDown("Escape") then -- 636
		App:shutdown() -- 636
	end -- 636
	do -- 637
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 638
		if ctrl and Keyboard:isKeyDown("Q") then -- 639
			stop() -- 640
		end -- 639
		if ctrl and Keyboard:isKeyDown("Z") then -- 641
			reloadCurrentEntry() -- 642
		end -- 641
		if ctrl and Keyboard:isKeyDown(",") then -- 643
			if showFooter then -- 644
				showStats = not showStats -- 644
			else -- 644
				showStats = true -- 644
			end -- 644
			showFooter = true -- 645
			config.showFooter = showFooter and 1 or 0 -- 646
			config.showStats = showStats and 1 or 0 -- 647
		end -- 643
		if ctrl and Keyboard:isKeyDown(".") then -- 648
			if showFooter then -- 649
				showConsole = not showConsole -- 649
			else -- 649
				showConsole = true -- 649
			end -- 649
			showFooter = true -- 650
			config.showFooter = showFooter and 1 or 0 -- 651
			config.showConsole = showConsole and 1 or 0 -- 652
		end -- 648
		if ctrl and Keyboard:isKeyDown("/") then -- 653
			showFooter = not showFooter -- 654
			config.showFooter = showFooter and 1 or 0 -- 655
		end -- 653
		local left = ctrl and Keyboard:isKeyDown("Left") -- 656
		local right = ctrl and Keyboard:isKeyDown("Right") -- 657
		local currentIndex = nil -- 658
		for i, entry in ipairs(allEntries) do -- 659
			if currentEntry == entry then -- 660
				currentIndex = i -- 661
			end -- 660
		end -- 661
		if left then -- 662
			allClear() -- 663
			if currentIndex == nil then -- 664
				currentIndex = #allEntries + 1 -- 664
			end -- 664
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 665
		end -- 662
		if right then -- 669
			allClear() -- 670
			if currentIndex == nil then -- 671
				currentIndex = 0 -- 671
			end -- 671
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 672
		end -- 669
	end -- 675
	if not showEntry then -- 676
		return -- 676
	end -- 676
	local width, height -- 678
	do -- 678
		local _obj_0 = App.visualSize -- 678
		width, height = _obj_0.width, _obj_0.height -- 678
	end -- 678
	SetNextWindowSize(Vec2(50, 50)) -- 679
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 680
	PushStyleColor("WindowBg", transparant, function() -- 681
		return Begin("Show", windowFlags, function() -- 681
			if isInEntry or width >= 540 then -- 682
				local changed -- 683
				changed, showFooter = Checkbox("##dev", showFooter) -- 683
				if changed then -- 683
					config.showFooter = showFooter and 1 or 0 -- 684
				end -- 683
			end -- 682
		end) -- 684
	end) -- 681
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 686
		reloadDevEntry() -- 690
	end -- 686
	if initFooter then -- 691
		initFooter = false -- 692
	else -- 694
		if not showFooter then -- 694
			return -- 694
		end -- 694
	end -- 691
	SetNextWindowSize(Vec2(width, 50)) -- 696
	SetNextWindowPos(Vec2(0, height - 50)) -- 697
	SetNextWindowBgAlpha(0.35) -- 698
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 699
		return Begin("Footer", windowFlags, function() -- 699
			Dummy(Vec2(width - 20, 0)) -- 700
			do -- 701
				local changed -- 701
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 701
				if changed then -- 701
					config.showStats = showStats and 1 or 0 -- 702
				end -- 701
			end -- 701
			SameLine() -- 703
			do -- 704
				local changed -- 704
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 704
				if changed then -- 704
					config.showConsole = showConsole and 1 or 0 -- 705
				end -- 704
			end -- 704
			if not isInEntry then -- 706
				SameLine() -- 707
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 708
					allClear() -- 709
					isInEntry = true -- 710
					currentEntry = nil -- 711
				end -- 708
				local currentIndex = nil -- 712
				for i, entry in ipairs(allEntries) do -- 713
					if currentEntry == entry then -- 714
						currentIndex = i -- 715
					end -- 714
				end -- 715
				if currentIndex then -- 716
					if currentIndex > 1 then -- 717
						SameLine() -- 718
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 719
							allClear() -- 720
							enterDemoEntry(allEntries[currentIndex - 1]) -- 721
						end -- 719
					end -- 717
					if currentIndex < #allEntries then -- 722
						SameLine() -- 723
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 724
							allClear() -- 725
							enterDemoEntry(allEntries[currentIndex + 1]) -- 726
						end -- 724
					end -- 722
				end -- 716
				SameLine() -- 727
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 728
					reloadCurrentEntry() -- 729
				end -- 728
			end -- 706
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 730
				if showStats then -- 731
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 732
					showStats = ShowStats(showStats, extraOperations) -- 733
					config.showStats = showStats and 1 or 0 -- 734
				end -- 731
				if showConsole then -- 735
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 736
					showConsole = ShowConsole(showConsole) -- 737
					config.showConsole = showConsole and 1 or 0 -- 738
				end -- 735
			end) -- 738
		end) -- 738
	end) -- 738
end) -- 632
local MaxWidth <const> = 800 -- 740
local displayWindowFlags = { -- 743
	"NoDecoration", -- 743
	"NoSavedSettings", -- 744
	"NoFocusOnAppearing", -- 745
	"NoNav", -- 746
	"NoMove", -- 747
	"NoScrollWithMouse", -- 748
	"AlwaysAutoResize", -- 749
	"NoBringToFrontOnFocus" -- 750
} -- 742
local webStatus = nil -- 752
local descColor = Color(0xffa1a1a1) -- 753
local gameOpen = #gamesInDev == 0 -- 754
local exampleOpen = false -- 755
local testOpen = false -- 756
local filterText = nil -- 757
local anyEntryMatched = false -- 758
local match -- 759
match = function(name) -- 759
	local res = not filterText or name:lower():match(filterText) -- 760
	if res then -- 761
		anyEntryMatched = true -- 761
	end -- 761
	return res -- 762
end -- 759
entryWindow = threadLoop(function() -- 764
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 765
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 766
	end -- 765
	if App.targetFPS ~= config.targetFPS then -- 767
		config.targetFPS = App.targetFPS -- 768
	end -- 767
	if View.vsync ~= (config.vsync == 1) then -- 769
		config.vsync = View.vsync and 1 or 0 -- 770
	end -- 769
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 771
		config.fixedFPS = Director.scheduler.fixedFPS -- 772
	end -- 771
	if not showEntry then -- 773
		return -- 773
	end -- 773
	if not isInEntry then -- 774
		return -- 774
	end -- 774
	local zh = useChinese and isChineseSupported -- 775
	if HttpServer.wsConnectionCount > 0 then -- 776
		local themeColor = App.themeColor -- 777
		local width, height -- 778
		do -- 778
			local _obj_0 = App.visualSize -- 778
			width, height = _obj_0.width, _obj_0.height -- 778
		end -- 778
		SetNextWindowBgAlpha(0.5) -- 779
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 780
		Begin("Web IDE Connected", displayWindowFlags, function() -- 781
			Separator() -- 782
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 783
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 784
			TextColored(descColor, slogon) -- 785
			return Separator() -- 786
		end) -- 781
		return -- 787
	end -- 776
	local themeColor = App.themeColor -- 789
	local fullWidth, height -- 790
	do -- 790
		local _obj_0 = App.visualSize -- 790
		fullWidth, height = _obj_0.width, _obj_0.height -- 790
	end -- 790
	SetNextWindowBgAlpha(0.85) -- 792
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 793
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 794
		return Begin("Web IDE", displayWindowFlags, function() -- 795
			Separator() -- 796
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 797
			local url -- 798
			do -- 798
				local _exp_0 -- 798
				if webStatus ~= nil then -- 798
					_exp_0 = webStatus.url -- 798
				end -- 798
				if _exp_0 ~= nil then -- 798
					url = _exp_0 -- 798
				else -- 798
					url = zh and '不可用' or 'not available' -- 798
				end -- 798
			end -- 798
			TextColored(descColor, url) -- 799
			return Separator() -- 800
		end) -- 800
	end) -- 794
	local width = math.min(MaxWidth, fullWidth) -- 802
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 803
	local maxColumns = math.max(math.floor(width / 200), 1) -- 804
	SetNextWindowPos(Vec2.zero) -- 805
	SetNextWindowBgAlpha(0) -- 806
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 807
		return Begin("Dora Dev", displayWindowFlags, function() -- 808
			Dummy(Vec2(fullWidth - 20, 0)) -- 809
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 810
			SameLine() -- 811
			if fullWidth >= 320 then -- 812
				Dummy(Vec2(fullWidth - 320, 0)) -- 813
				SameLine() -- 814
				SetNextItemWidth(-50) -- 815
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 816
					"AutoSelectAll" -- 816
				}) then -- 816
					config.filter = filterBuf:toString() -- 817
				end -- 816
			end -- 812
			Separator() -- 818
			return Dummy(Vec2(fullWidth - 20, 0)) -- 819
		end) -- 819
	end) -- 807
	anyEntryMatched = false -- 821
	SetNextWindowPos(Vec2(0, 50)) -- 822
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 823
	return PushStyleColor("WindowBg", transparant, function() -- 824
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 824
			return Begin("Content", windowFlags, function() -- 825
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 826
				if filterText then -- 827
					filterText = filterText:lower() -- 827
				end -- 827
				if #gamesInDev > 0 then -- 828
					for _index_0 = 1, #gamesInDev do -- 829
						local game = gamesInDev[_index_0] -- 829
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 830
						local showSep = false -- 831
						if match(gameName) then -- 832
							Columns(1, false) -- 833
							TextColored(themeColor, zh and "项目：" or "Project:") -- 834
							SameLine() -- 835
							Text(gameName) -- 836
							Separator() -- 837
							if bannerFile then -- 838
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 839
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 840
								local sizing <const> = 0.8 -- 841
								texHeight = displayWidth * sizing * texHeight / texWidth -- 842
								texWidth = displayWidth * sizing -- 843
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 844
								Dummy(Vec2(padding, 0)) -- 845
								SameLine() -- 846
								PushID(fileName, function() -- 847
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 848
										return enterDemoEntry(game) -- 849
									end -- 848
								end) -- 847
							else -- 851
								PushID(fileName, function() -- 851
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 852
										return enterDemoEntry(game) -- 853
									end -- 852
								end) -- 851
							end -- 838
							NextColumn() -- 854
							showSep = true -- 855
						end -- 832
						if #examples > 0 then -- 856
							local showExample = false -- 857
							for _index_1 = 1, #examples do -- 858
								local example = examples[_index_1] -- 858
								if match(example[1]) then -- 859
									showExample = true -- 860
									break -- 861
								end -- 859
							end -- 861
							if showExample then -- 862
								Columns(1, false) -- 863
								TextColored(themeColor, zh and "示例：" or "Example:") -- 864
								SameLine() -- 865
								Text(gameName) -- 866
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 867
									Columns(maxColumns, false) -- 868
									for _index_1 = 1, #examples do -- 869
										local example = examples[_index_1] -- 869
										if not match(example[1]) then -- 870
											goto _continue_0 -- 870
										end -- 870
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 871
											if Button(example[1], Vec2(-1, 40)) then -- 872
												enterDemoEntry(example) -- 873
											end -- 872
											return NextColumn() -- 874
										end) -- 871
										showSep = true -- 875
										::_continue_0:: -- 870
									end -- 875
								end) -- 867
							end -- 862
						end -- 856
						if #tests > 0 then -- 876
							local showTest = false -- 877
							for _index_1 = 1, #tests do -- 878
								local test = tests[_index_1] -- 878
								if match(test[1]) then -- 879
									showTest = true -- 880
									break -- 881
								end -- 879
							end -- 881
							if showTest then -- 882
								Columns(1, false) -- 883
								TextColored(themeColor, zh and "测试：" or "Test:") -- 884
								SameLine() -- 885
								Text(gameName) -- 886
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 887
									Columns(maxColumns, false) -- 888
									for _index_1 = 1, #tests do -- 889
										local test = tests[_index_1] -- 889
										if not match(test[1]) then -- 890
											goto _continue_0 -- 890
										end -- 890
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 891
											if Button(test[1], Vec2(-1, 40)) then -- 892
												enterDemoEntry(test) -- 893
											end -- 892
											return NextColumn() -- 894
										end) -- 891
										showSep = true -- 895
										::_continue_0:: -- 890
									end -- 895
								end) -- 887
							end -- 882
						end -- 876
						if showSep then -- 896
							Columns(1, false) -- 897
							Separator() -- 898
						end -- 896
					end -- 898
				end -- 828
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 899
					local showGame = false -- 900
					for _index_0 = 1, #games do -- 901
						local _des_0 = games[_index_0] -- 901
						local name = _des_0[1] -- 901
						if match(name) then -- 902
							showGame = true -- 902
						end -- 902
					end -- 902
					local showExample = false -- 903
					for _index_0 = 1, #doraExamples do -- 904
						local _des_0 = doraExamples[_index_0] -- 904
						local name = _des_0[1] -- 904
						if match(name) then -- 905
							showExample = true -- 905
						end -- 905
					end -- 905
					local showTest = false -- 906
					for _index_0 = 1, #doraTests do -- 907
						local _des_0 = doraTests[_index_0] -- 907
						local name = _des_0[1] -- 907
						if match(name) then -- 908
							showTest = true -- 908
						end -- 908
					end -- 908
					for _index_0 = 1, #cppTests do -- 909
						local _des_0 = cppTests[_index_0] -- 909
						local name = _des_0[1] -- 909
						if match(name) then -- 910
							showTest = true -- 910
						end -- 910
					end -- 910
					if not (showGame or showExample or showTest) then -- 911
						goto endEntry -- 911
					end -- 911
					Columns(1, false) -- 912
					TextColored(themeColor, "Dora SSR:") -- 913
					SameLine() -- 914
					Text(zh and "开发示例" or "Development Showcase") -- 915
					Separator() -- 916
					local demoViewWith <const> = 400 -- 917
					if #games > 0 and showGame then -- 918
						local opened -- 919
						if (filterText ~= nil) then -- 919
							opened = showGame -- 919
						else -- 919
							opened = false -- 919
						end -- 919
						SetNextItemOpen(gameOpen) -- 920
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 921
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 922
							Columns(columns, false) -- 923
							for _index_0 = 1, #games do -- 924
								local game = games[_index_0] -- 924
								if not match(game[1]) then -- 925
									goto _continue_0 -- 925
								end -- 925
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 926
								if columns > 1 then -- 927
									if bannerFile then -- 928
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 929
										local displayWidth <const> = demoViewWith - 40 -- 930
										texHeight = displayWidth * texHeight / texWidth -- 931
										texWidth = displayWidth -- 932
										Text(gameName) -- 933
										PushID(fileName, function() -- 934
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 935
												return enterDemoEntry(game) -- 936
											end -- 935
										end) -- 934
									else -- 938
										PushID(fileName, function() -- 938
											if Button(gameName, Vec2(-1, 40)) then -- 939
												return enterDemoEntry(game) -- 940
											end -- 939
										end) -- 938
									end -- 928
								else -- 942
									if bannerFile then -- 942
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 943
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 944
										local sizing = 0.8 -- 945
										texHeight = displayWidth * sizing * texHeight / texWidth -- 946
										texWidth = displayWidth * sizing -- 947
										if texWidth > 500 then -- 948
											sizing = 0.6 -- 949
											texHeight = displayWidth * sizing * texHeight / texWidth -- 950
											texWidth = displayWidth * sizing -- 951
										end -- 948
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 952
										Dummy(Vec2(padding, 0)) -- 953
										SameLine() -- 954
										Text(gameName) -- 955
										Dummy(Vec2(padding, 0)) -- 956
										SameLine() -- 957
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
									end -- 942
								end -- 927
								NextColumn() -- 965
								::_continue_0:: -- 925
							end -- 965
							Columns(1, false) -- 966
							opened = true -- 967
						end) -- 921
						gameOpen = opened -- 968
					end -- 918
					if #doraExamples > 0 and showExample then -- 969
						local opened -- 970
						if (filterText ~= nil) then -- 970
							opened = showExample -- 970
						else -- 970
							opened = false -- 970
						end -- 970
						SetNextItemOpen(exampleOpen) -- 971
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 972
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 973
								Columns(maxColumns, false) -- 974
								for _index_0 = 1, #doraExamples do -- 975
									local example = doraExamples[_index_0] -- 975
									if not match(example[1]) then -- 976
										goto _continue_0 -- 976
									end -- 976
									if Button(example[1], Vec2(-1, 40)) then -- 977
										enterDemoEntry(example) -- 978
									end -- 977
									NextColumn() -- 979
									::_continue_0:: -- 976
								end -- 979
								Columns(1, false) -- 980
								opened = true -- 981
							end) -- 973
						end) -- 972
						exampleOpen = opened -- 982
					end -- 969
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 983
						local opened -- 984
						if (filterText ~= nil) then -- 984
							opened = showTest -- 984
						else -- 984
							opened = false -- 984
						end -- 984
						SetNextItemOpen(testOpen) -- 985
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 986
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 987
								Columns(maxColumns, false) -- 988
								for _index_0 = 1, #doraTests do -- 989
									local test = doraTests[_index_0] -- 989
									if not match(test[1]) then -- 990
										goto _continue_0 -- 990
									end -- 990
									if Button(test[1], Vec2(-1, 40)) then -- 991
										enterDemoEntry(test) -- 992
									end -- 991
									NextColumn() -- 993
									::_continue_0:: -- 990
								end -- 993
								for _index_0 = 1, #cppTests do -- 994
									local test = cppTests[_index_0] -- 994
									if not match(test[1]) then -- 995
										goto _continue_1 -- 995
									end -- 995
									if Button(test[1], Vec2(-1, 40)) then -- 996
										enterDemoEntry(test) -- 997
									end -- 996
									NextColumn() -- 998
									::_continue_1:: -- 995
								end -- 998
								opened = true -- 999
							end) -- 987
						end) -- 986
						testOpen = opened -- 1000
					end -- 983
				end -- 899
				::endEntry:: -- 1001
				if not anyEntryMatched then -- 1002
					SetNextWindowBgAlpha(0) -- 1003
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1004
					Begin("Entries Not Found", displayWindowFlags, function() -- 1005
						Separator() -- 1006
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1007
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1008
						return Separator() -- 1009
					end) -- 1005
				end -- 1002
				Columns(1, false) -- 1010
				Dummy(Vec2(100, 80)) -- 1011
				return ScrollWhenDraggingOnVoid() -- 1012
			end) -- 1012
		end) -- 1012
	end) -- 1012
end) -- 764
webStatus = require("WebServer") -- 1014
return _module_0 -- 1014
