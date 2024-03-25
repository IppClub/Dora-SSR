-- [yue]: Script/Dev/Entry.yue
local App = dora.App -- 1
local package = _G.package -- 1
local Content = dora.Content -- 1
local Path = dora.Path -- 1
local DB = dora.DB -- 1
local type = _G.type -- 1
local View = dora.View -- 1
local Director = dora.Director -- 1
local Size = dora.Size -- 1
local thread = dora.thread -- 1
local sleep = dora.sleep -- 1
local Vec2 = dora.Vec2 -- 1
local Color = dora.Color -- 1
local Buffer = dora.Buffer -- 1
local yue = dora.yue -- 1
local _module_0 = dora.ImGui -- 1
local IsFontLoaded = _module_0.IsFontLoaded -- 1
local LoadFontTTF = _module_0.LoadFontTTF -- 1
local table = _G.table -- 1
local Cache = dora.Cache -- 1
local Texture2D = dora.Texture2D -- 1
local pairs = _G.pairs -- 1
local tostring = _G.tostring -- 1
local string = _G.string -- 1
local print = _G.print -- 1
local xml = dora.xml -- 1
local teal = dora.teal -- 1
local wait = dora.wait -- 1
local HttpServer = dora.HttpServer -- 1
local Routine = dora.Routine -- 1
local Entity = dora.Entity -- 1
local Platformer = dora.Platformer -- 1
local Audio = dora.Audio -- 1
local ubox = dora.ubox -- 1
local tolua = dora.tolua -- 1
local collectgarbage = _G.collectgarbage -- 1
local Wasm = dora.Wasm -- 1
local xpcall = _G.xpcall -- 1
local debug = _G.debug -- 1
local math = _G.math -- 1
local Label = dora.Label -- 1
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
local threadLoop = dora.threadLoop -- 1
local Keyboard = dora.Keyboard -- 1
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
dora.require = require -- 22
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
		fileName = Path(Path:getName(path), fileName) -- 165
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
				fileName = Path(dir, fileName) -- 178
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
							Path(dir, Path:getPath(file), ePath) -- 191
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
							Path(dir, Path:getPath(file), tPath) -- 196
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
		local name, entryFile = _des_0[1], _des_0[2] -- 272
		local gamePath = Path:getPath(entryFile) -- 273
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
				codes = codes:gsub("^\n*", "") -- 331
				if not (result == "") then -- 332
					result = result .. "\n" -- 332
				end -- 332
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 333
			else -- 335
				local yueCodes = Content:load(input) -- 335
				if yueCodes then -- 335
					local globalErrors = { } -- 336
					for _index_1 = 1, #result do -- 337
						local _des_1 = result[_index_1] -- 337
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 337
						local countLine = 1 -- 338
						local code = "" -- 339
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 340
							if countLine == line then -- 341
								code = lineCode -- 342
								break -- 343
							end -- 341
							countLine = countLine + 1 -- 344
						end -- 344
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 345
					end -- 345
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 346
				else -- 348
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 348
				end -- 335
			end -- 329
		end, function(success) -- 324
			if success then -- 349
				print("Yue compiled: " .. tostring(filename)) -- 349
			end -- 349
			fileCount = fileCount + 1 -- 350
		end) -- 324
	end -- 350
	thread(function() -- 352
		for _index_0 = 1, #xmlFiles do -- 353
			local _des_0 = xmlFiles[_index_0] -- 353
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 353
			local filename -- 354
			if gamePath then -- 354
				filename = Path(gamePath, file) -- 354
			else -- 354
				filename = file -- 354
			end -- 354
			local sourceCodes = Content:loadAsync(input) -- 355
			local codes, err = xml.tolua(sourceCodes) -- 356
			if not codes then -- 357
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 358
			else -- 360
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 360
				print("Xml compiled: " .. tostring(filename)) -- 361
			end -- 357
			fileCount = fileCount + 1 -- 362
		end -- 362
	end) -- 352
	thread(function() -- 364
		for _index_0 = 1, #tlFiles do -- 365
			local _des_0 = tlFiles[_index_0] -- 365
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 365
			local filename -- 366
			if gamePath then -- 366
				filename = Path(gamePath, file) -- 366
			else -- 366
				filename = file -- 366
			end -- 366
			local sourceCodes = Content:loadAsync(input) -- 367
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 368
			if not codes then -- 369
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 370
			else -- 372
				Content:saveAsync(output, codes) -- 372
				print("Teal compiled: " .. tostring(filename)) -- 373
			end -- 369
			fileCount = fileCount + 1 -- 374
		end -- 374
	end) -- 364
	return thread(function() -- 376
		wait(function() -- 377
			return fileCount == totalFiles -- 377
		end) -- 377
		if minify then -- 378
			local _list_0 = { -- 379
				yueFiles, -- 379
				xmlFiles, -- 379
				tlFiles -- 379
			} -- 379
			for _index_0 = 1, #_list_0 do -- 379
				local files = _list_0[_index_0] -- 379
				for _index_1 = 1, #files do -- 379
					local file = files[_index_1] -- 379
					local output = Path:replaceExt(file[3], "lua") -- 380
					luaFiles[#luaFiles + 1] = { -- 382
						Path:replaceExt(file[1], "lua"), -- 382
						output, -- 383
						output -- 384
					} -- 381
				end -- 384
			end -- 384
			local FormatMini -- 386
			do -- 386
				local _obj_0 = require("luaminify") -- 386
				FormatMini = _obj_0.FormatMini -- 386
			end -- 386
			for _index_0 = 1, #luaFiles do -- 387
				local _des_0 = luaFiles[_index_0] -- 387
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 387
				if Content:exist(input) then -- 388
					local sourceCodes = Content:loadAsync(input) -- 389
					local res, err = FormatMini(sourceCodes) -- 390
					if res then -- 391
						Content:saveAsync(output, res) -- 392
						print("Minify: " .. tostring(file)) -- 393
					else -- 395
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 395
					end -- 391
				else -- 397
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 397
				end -- 388
			end -- 397
			package.loaded["luaminify.FormatMini"] = nil -- 398
			package.loaded["luaminify.ParseLua"] = nil -- 399
			package.loaded["luaminify.Scope"] = nil -- 400
			package.loaded["luaminify.Util"] = nil -- 401
		end -- 378
		local errorMessage = table.concat(errors, "\n") -- 402
		if errorMessage ~= "" then -- 403
			print("\n" .. errorMessage) -- 403
		end -- 403
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 404
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 405
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 406
		Content:clearPathCache() -- 407
		teal.clear() -- 408
		yue.clear() -- 409
		building = false -- 410
	end) -- 410
end -- 256
local doClean -- 412
doClean = function() -- 412
	if building then -- 413
		return -- 413
	end -- 413
	local writablePath = Content.writablePath -- 414
	local targetDir = Path(writablePath, ".build") -- 415
	Content:clearPathCache() -- 416
	if Content:remove(targetDir) then -- 417
		print("Cleaned: " .. tostring(targetDir)) -- 418
	end -- 417
	Content:remove(Path(writablePath, ".upload")) -- 419
	return Content:remove(Path(writablePath, ".download")) -- 420
end -- 412
local screenScale = 2.0 -- 422
local scaleContent = false -- 423
local isInEntry = true -- 424
local currentEntry = nil -- 425
local footerWindow = nil -- 427
local entryWindow = nil -- 428
local setupEventHandlers -- 430
setupEventHandlers = function() -- 430
	local _with_0 = Director.postNode -- 431
	_with_0:gslot("AppTheme", function(argb) -- 432
		config.themeColor = argb -- 433
	end) -- 432
	_with_0:gslot("AppLocale", function(locale) -- 434
		config.locale = locale -- 435
		updateLocale() -- 436
		return teal.clear(true) -- 437
	end) -- 434
	_with_0:gslot("AppWSClose", function() -- 438
		if HttpServer.wsConnectionCount == 0 then -- 439
			return updateEntries() -- 440
		end -- 439
	end) -- 438
	local _exp_0 = App.platform -- 441
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 441
		_with_0:gslot("AppSizeChanged", function() -- 442
			local width, height -- 443
			do -- 443
				local _obj_0 = App.winSize -- 443
				width, height = _obj_0.width, _obj_0.height -- 443
			end -- 443
			config.winWidth = width -- 444
			config.winHeight = height -- 445
		end) -- 442
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 446
			config.fullScreen = fullScreen and 1 or 0 -- 447
		end) -- 446
		_with_0:gslot("AppMoved", function() -- 448
			local _obj_0 = App.winPosition -- 449
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 449
		end) -- 448
	end -- 449
	return _with_0 -- 431
end -- 430
setupEventHandlers() -- 451
local allClear -- 453
allClear = function() -- 453
	local _list_0 = Routine -- 454
	for _index_0 = 1, #_list_0 do -- 454
		local routine = _list_0[_index_0] -- 454
		if footerWindow == routine or entryWindow == routine then -- 456
			goto _continue_0 -- 457
		else -- 459
			Routine:remove(routine) -- 459
		end -- 459
		::_continue_0:: -- 455
	end -- 459
	for _index_0 = 1, #moduleCache do -- 460
		local module = moduleCache[_index_0] -- 460
		package.loaded[module] = nil -- 461
	end -- 461
	moduleCache = { } -- 462
	Director:cleanup() -- 463
	Cache:unload() -- 464
	Entity:clear() -- 465
	Platformer.Data:clear() -- 466
	Platformer.UnitAction:clear() -- 467
	Audio:stopStream(0.2) -- 468
	Struct:clear() -- 469
	View.postEffect = nil -- 470
	View.scale = scaleContent and screenScale or 1 -- 471
	Director.clearColor = Color(0xff1a1a1a) -- 472
	teal.clear() -- 473
	yue.clear() -- 474
	for _, item in pairs(ubox()) do -- 475
		local node = tolua.cast(item, "Node") -- 476
		if node then -- 476
			node:cleanup() -- 476
		end -- 476
	end -- 476
	collectgarbage() -- 477
	collectgarbage() -- 478
	setupEventHandlers() -- 479
	Content.searchPaths = searchPaths -- 480
	App.idled = true -- 481
	return Wasm:clear() -- 482
end -- 453
_module_0["allClear"] = allClear -- 482
local stop -- 484
stop = function() -- 484
	if isInEntry then -- 485
		return false -- 485
	end -- 485
	allClear() -- 486
	isInEntry = true -- 487
	currentEntry = nil -- 488
	return true -- 489
end -- 484
_module_0["stop"] = stop -- 489
local _anon_func_0 = function(Content, Path, file, require, type) -- 510
	local scriptPath = Path:getPath(file) -- 503
	Content:insertSearchPath(1, scriptPath) -- 504
	scriptPath = Path(scriptPath, "Script") -- 505
	if Content:exist(scriptPath) then -- 506
		Content:insertSearchPath(1, scriptPath) -- 507
	end -- 506
	local result = require(file) -- 508
	if "function" == type(result) then -- 509
		result() -- 509
	end -- 509
	return nil -- 510
end -- 503
local _anon_func_1 = function(Label, err, fontSize, scroll, width) -- 540
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 537
	label.alignment = "Left" -- 538
	label.textWidth = width - fontSize -- 539
	label.text = err -- 540
	return label -- 537
end -- 537
local enterEntryAsync -- 491
enterEntryAsync = function(entry) -- 491
	isInEntry = false -- 492
	App.idled = false -- 493
	currentEntry = entry -- 494
	local name, file = entry[1], entry[2] -- 495
	if cppTestSet[entry] then -- 496
		if App:runTest(name) then -- 497
			return true -- 498
		else -- 500
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 500
		end -- 497
	end -- 496
	sleep() -- 501
	return xpcall(_anon_func_0, function(msg) -- 510
		local err = debug.traceback(msg) -- 512
		allClear() -- 513
		print(err) -- 514
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 515
		local AlignNode = require("UI.Control.Basic.AlignNode") -- 516
		local LineRect = require("UI.View.Shape.LineRect") -- 517
		local viewWidth, viewHeight -- 518
		do -- 518
			local _obj_0 = View.size -- 518
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 518
		end -- 518
		local width, height = viewWidth - 20, viewHeight - 20 -- 519
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 520
		do -- 521
			local _with_0 = AlignNode({ -- 521
				isRoot = true, -- 521
				inUI = false -- 521
			}) -- 521
			_with_0:addChild((function() -- 522
				local root = AlignNode({ -- 522
					alignWidth = "w", -- 522
					alignHeight = "h" -- 522
				}) -- 522
				root:addChild((function() -- 523
					local scroll = ScrollArea({ -- 524
						width = width, -- 524
						height = height, -- 525
						paddingX = 0, -- 526
						paddingY = 50, -- 527
						viewWidth = height, -- 528
						viewHeight = height -- 529
					}) -- 523
					scroll:slot("AlignLayout", function(w, h) -- 531
						scroll.position = Vec2(w / 2, h / 2) -- 532
						w = w - 20 -- 533
						h = h - 20 -- 534
						scroll.view.children.first.textWidth = w - fontSize -- 535
						return scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 536
					end) -- 531
					scroll.view:addChild(_anon_func_1(Label, err, fontSize, scroll, width)) -- 537
					return scroll -- 523
				end)()) -- 523
				return root -- 522
			end)()) -- 522
			_with_0:alignLayout() -- 541
		end -- 521
		return err -- 542
	end, Content, Path, file, require, type) -- 542
end -- 491
_module_0["enterEntryAsync"] = enterEntryAsync -- 542
local enterDemoEntry -- 544
enterDemoEntry = function(entry) -- 544
	return thread(function() -- 544
		return enterEntryAsync(entry) -- 544
	end) -- 544
end -- 544
local reloadCurrentEntry -- 546
reloadCurrentEntry = function() -- 546
	if currentEntry then -- 547
		allClear() -- 548
		return enterDemoEntry(currentEntry) -- 549
	end -- 547
end -- 546
Director.clearColor = Color(0xff1a1a1a) -- 551
local waitForWebStart = true -- 553
thread(function() -- 554
	sleep(2) -- 555
	waitForWebStart = false -- 556
end) -- 554
local reloadDevEntry -- 558
reloadDevEntry = function() -- 558
	return thread(function() -- 558
		waitForWebStart = true -- 559
		doClean() -- 560
		allClear() -- 561
		_G.require = oldRequire -- 562
		dora.require = oldRequire -- 563
		package.loaded["Dev.Entry"] = nil -- 564
		return Director.systemScheduler:schedule(function() -- 565
			Routine:clear() -- 566
			oldRequire("Dev.Entry") -- 567
			return true -- 568
		end) -- 568
	end) -- 568
end -- 558
local isOSSLicenseExist = Content:exist("LICENSES") -- 570
local ossLicenses = nil -- 571
local ossLicenseOpen = false -- 572
local extraOperations -- 574
extraOperations = function() -- 574
	local zh = useChinese and isChineseSupported -- 575
	if isOSSLicenseExist then -- 576
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 577
			if not ossLicenses then -- 578
				ossLicenses = { } -- 579
				local licenseText = Content:load("LICENSES") -- 580
				ossLicenseOpen = (licenseText ~= nil) -- 581
				if ossLicenseOpen then -- 581
					licenseText = licenseText:gsub("\r\n", "\n") -- 582
					for license in GSplit(licenseText, "\n--------\n", true) do -- 583
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 584
						if name then -- 584
							ossLicenses[#ossLicenses + 1] = { -- 585
								name, -- 585
								text -- 585
							} -- 585
						end -- 584
					end -- 585
				end -- 581
			else -- 587
				ossLicenseOpen = true -- 587
			end -- 578
		end -- 577
		if ossLicenseOpen then -- 588
			local width, height, themeColor -- 589
			do -- 589
				local _obj_0 = App -- 589
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 589
			end -- 589
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 590
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 591
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 592
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 595
					"NoSavedSettings" -- 595
				}, function() -- 596
					for _index_0 = 1, #ossLicenses do -- 596
						local _des_0 = ossLicenses[_index_0] -- 596
						local firstLine, text = _des_0[1], _des_0[2] -- 596
						local name, license = firstLine:match("(.+): (.+)") -- 597
						TextColored(themeColor, name) -- 598
						SameLine() -- 599
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 600
							return TextWrapped(text) -- 600
						end) -- 600
					end -- 600
				end) -- 592
			end) -- 592
		end -- 588
	end -- 576
	return TreeNode(zh and "开发操作" or "Development", function() -- 602
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 603
			OpenPopup("build") -- 603
		end -- 603
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 604
			return BeginPopup("build", function() -- 604
				if Selectable(zh and "编译" or "Compile") then -- 605
					doCompile(false) -- 605
				end -- 605
				Separator() -- 606
				if Selectable(zh and "压缩" or "Minify") then -- 607
					doCompile(true) -- 607
				end -- 607
				Separator() -- 608
				if Selectable(zh and "清理" or "Clean") then -- 609
					return doClean() -- 609
				end -- 609
			end) -- 609
		end) -- 604
		if isInEntry then -- 610
			if waitForWebStart then -- 611
				BeginDisabled(function() -- 612
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 612
				end) -- 612
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 613
				reloadDevEntry() -- 614
			end -- 611
		end -- 610
		local changed -- 615
		changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 615
		if changed then -- 615
			View.scale = scaleContent and screenScale or 1 -- 616
		end -- 615
	end) -- 602
end -- 574
local transparant = Color(0x0) -- 618
local windowFlags = { -- 620
	"NoTitleBar", -- 620
	"NoResize", -- 621
	"NoMove", -- 622
	"NoCollapse", -- 623
	"NoSavedSettings", -- 624
	"NoBringToFrontOnFocus" -- 625
} -- 619
local initFooter = true -- 626
local _anon_func_2 = function(allEntries, currentIndex) -- 660
	if currentIndex > 1 then -- 660
		return allEntries[currentIndex - 1] -- 661
	else -- 663
		return allEntries[#allEntries] -- 663
	end -- 660
end -- 660
local _anon_func_3 = function(allEntries, currentIndex) -- 667
	if currentIndex < #allEntries then -- 667
		return allEntries[currentIndex + 1] -- 668
	else -- 670
		return allEntries[1] -- 670
	end -- 667
end -- 667
footerWindow = threadLoop(function() -- 627
	local zh = useChinese and isChineseSupported -- 628
	if HttpServer.wsConnectionCount > 0 then -- 629
		return -- 630
	end -- 629
	if Keyboard:isKeyDown("Escape") then -- 631
		App:shutdown() -- 631
	end -- 631
	do -- 632
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 633
		if ctrl and Keyboard:isKeyDown("Q") then -- 634
			stop() -- 635
		end -- 634
		if ctrl and Keyboard:isKeyDown("Z") then -- 636
			reloadCurrentEntry() -- 637
		end -- 636
		if ctrl and Keyboard:isKeyDown(",") then -- 638
			if showFooter then -- 639
				showStats = not showStats -- 639
			else -- 639
				showStats = true -- 639
			end -- 639
			showFooter = true -- 640
			config.showFooter = showFooter and 1 or 0 -- 641
			config.showStats = showStats and 1 or 0 -- 642
		end -- 638
		if ctrl and Keyboard:isKeyDown(".") then -- 643
			if showFooter then -- 644
				showConsole = not showConsole -- 644
			else -- 644
				showConsole = true -- 644
			end -- 644
			showFooter = true -- 645
			config.showFooter = showFooter and 1 or 0 -- 646
			config.showConsole = showConsole and 1 or 0 -- 647
		end -- 643
		if ctrl and Keyboard:isKeyDown("/") then -- 648
			showFooter = not showFooter -- 649
			config.showFooter = showFooter and 1 or 0 -- 650
		end -- 648
		local left = ctrl and Keyboard:isKeyDown("Left") -- 651
		local right = ctrl and Keyboard:isKeyDown("Right") -- 652
		local currentIndex = nil -- 653
		for i, entry in ipairs(allEntries) do -- 654
			if currentEntry == entry then -- 655
				currentIndex = i -- 656
			end -- 655
		end -- 656
		if left then -- 657
			allClear() -- 658
			if currentIndex == nil then -- 659
				currentIndex = #allEntries + 1 -- 659
			end -- 659
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 660
		end -- 657
		if right then -- 664
			allClear() -- 665
			if currentIndex == nil then -- 666
				currentIndex = 0 -- 666
			end -- 666
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 667
		end -- 664
	end -- 670
	if not showEntry then -- 671
		return -- 671
	end -- 671
	local width, height -- 673
	do -- 673
		local _obj_0 = App.visualSize -- 673
		width, height = _obj_0.width, _obj_0.height -- 673
	end -- 673
	SetNextWindowSize(Vec2(50, 50)) -- 674
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 675
	PushStyleColor("WindowBg", transparant, function() -- 676
		return Begin("Show", windowFlags, function() -- 676
			if isInEntry or width >= 540 then -- 677
				local changed -- 678
				changed, showFooter = Checkbox("##dev", showFooter) -- 678
				if changed then -- 678
					config.showFooter = showFooter and 1 or 0 -- 679
				end -- 678
			end -- 677
		end) -- 679
	end) -- 676
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 681
		reloadDevEntry() -- 685
	end -- 681
	if initFooter then -- 686
		initFooter = false -- 687
	else -- 689
		if not showFooter then -- 689
			return -- 689
		end -- 689
	end -- 686
	SetNextWindowSize(Vec2(width, 50)) -- 691
	SetNextWindowPos(Vec2(0, height - 50)) -- 692
	SetNextWindowBgAlpha(0.35) -- 693
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 694
		return Begin("Footer", windowFlags, function() -- 694
			Dummy(Vec2(width - 20, 0)) -- 695
			do -- 696
				local changed -- 696
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 696
				if changed then -- 696
					config.showStats = showStats and 1 or 0 -- 697
				end -- 696
			end -- 696
			SameLine() -- 698
			do -- 699
				local changed -- 699
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 699
				if changed then -- 699
					config.showConsole = showConsole and 1 or 0 -- 700
				end -- 699
			end -- 699
			if not isInEntry then -- 701
				SameLine() -- 702
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 703
					allClear() -- 704
					isInEntry = true -- 705
					currentEntry = nil -- 706
				end -- 703
				local currentIndex = nil -- 707
				for i, entry in ipairs(allEntries) do -- 708
					if currentEntry == entry then -- 709
						currentIndex = i -- 710
					end -- 709
				end -- 710
				if currentIndex then -- 711
					if currentIndex > 1 then -- 712
						SameLine() -- 713
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 714
							allClear() -- 715
							enterDemoEntry(allEntries[currentIndex - 1]) -- 716
						end -- 714
					end -- 712
					if currentIndex < #allEntries then -- 717
						SameLine() -- 718
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 719
							allClear() -- 720
							enterDemoEntry(allEntries[currentIndex + 1]) -- 721
						end -- 719
					end -- 717
				end -- 711
				SameLine() -- 722
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 723
					reloadCurrentEntry() -- 724
				end -- 723
			end -- 701
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 725
				if showStats then -- 726
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 727
					showStats = ShowStats(showStats, extraOperations) -- 728
					config.showStats = showStats and 1 or 0 -- 729
				end -- 726
				if showConsole then -- 730
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 731
					showConsole = ShowConsole(showConsole) -- 732
					config.showConsole = showConsole and 1 or 0 -- 733
				end -- 730
			end) -- 733
		end) -- 733
	end) -- 733
end) -- 627
local MaxWidth <const> = 800 -- 735
local displayWindowFlags = { -- 738
	"NoDecoration", -- 738
	"NoSavedSettings", -- 739
	"NoFocusOnAppearing", -- 740
	"NoNav", -- 741
	"NoMove", -- 742
	"NoScrollWithMouse", -- 743
	"AlwaysAutoResize", -- 744
	"NoBringToFrontOnFocus" -- 745
} -- 737
local webStatus = nil -- 747
local descColor = Color(0xffa1a1a1) -- 748
local gameOpen = #gamesInDev == 0 -- 749
local exampleOpen = false -- 750
local testOpen = false -- 751
local filterText = nil -- 752
local anyEntryMatched = false -- 753
local match -- 754
match = function(name) -- 754
	local res = not filterText or name:lower():match(filterText) -- 755
	if res then -- 756
		anyEntryMatched = true -- 756
	end -- 756
	return res -- 757
end -- 754
entryWindow = threadLoop(function() -- 759
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 760
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 761
	end -- 760
	if App.targetFPS ~= config.targetFPS then -- 762
		config.targetFPS = App.targetFPS -- 763
	end -- 762
	if View.vsync ~= (config.vsync == 1) then -- 764
		config.vsync = View.vsync and 1 or 0 -- 765
	end -- 764
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 766
		config.fixedFPS = Director.scheduler.fixedFPS -- 767
	end -- 766
	if not showEntry then -- 768
		return -- 768
	end -- 768
	if not isInEntry then -- 769
		return -- 769
	end -- 769
	local zh = useChinese and isChineseSupported -- 770
	if HttpServer.wsConnectionCount > 0 then -- 771
		local themeColor = App.themeColor -- 772
		local width, height -- 773
		do -- 773
			local _obj_0 = App.visualSize -- 773
			width, height = _obj_0.width, _obj_0.height -- 773
		end -- 773
		SetNextWindowBgAlpha(0.5) -- 774
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 775
		Begin("Web IDE Connected", displayWindowFlags, function() -- 776
			Separator() -- 777
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 778
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 779
			TextColored(descColor, slogon) -- 780
			return Separator() -- 781
		end) -- 776
		return -- 782
	end -- 771
	local themeColor = App.themeColor -- 784
	local fullWidth, height -- 785
	do -- 785
		local _obj_0 = App.visualSize -- 785
		fullWidth, height = _obj_0.width, _obj_0.height -- 785
	end -- 785
	SetNextWindowBgAlpha(0.85) -- 787
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 788
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 789
		return Begin("Web IDE", displayWindowFlags, function() -- 790
			Separator() -- 791
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 792
			local url -- 793
			do -- 793
				local _exp_0 -- 793
				if webStatus ~= nil then -- 793
					_exp_0 = webStatus.url -- 793
				end -- 793
				if _exp_0 ~= nil then -- 793
					url = _exp_0 -- 793
				else -- 793
					url = zh and '不可用' or 'not available' -- 793
				end -- 793
			end -- 793
			TextColored(descColor, url) -- 794
			return Separator() -- 795
		end) -- 795
	end) -- 789
	local width = math.min(MaxWidth, fullWidth) -- 797
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 798
	local maxColumns = math.max(math.floor(width / 200), 1) -- 799
	SetNextWindowPos(Vec2.zero) -- 800
	SetNextWindowBgAlpha(0) -- 801
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 802
		return Begin("Dora Dev", displayWindowFlags, function() -- 803
			Dummy(Vec2(fullWidth - 20, 0)) -- 804
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 805
			SameLine() -- 806
			if fullWidth >= 320 then -- 807
				Dummy(Vec2(fullWidth - 320, 0)) -- 808
				SameLine() -- 809
				SetNextItemWidth(-50) -- 810
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 811
					"AutoSelectAll" -- 811
				}) then -- 811
					config.filter = filterBuf:toString() -- 812
				end -- 811
			end -- 807
			Separator() -- 813
			return Dummy(Vec2(fullWidth - 20, 0)) -- 814
		end) -- 814
	end) -- 802
	anyEntryMatched = false -- 816
	SetNextWindowPos(Vec2(0, 50)) -- 817
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 818
	return PushStyleColor("WindowBg", transparant, function() -- 819
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 819
			return Begin("Content", windowFlags, function() -- 820
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 821
				if filterText then -- 822
					filterText = filterText:lower() -- 822
				end -- 822
				if #gamesInDev > 0 then -- 823
					for _index_0 = 1, #gamesInDev do -- 824
						local game = gamesInDev[_index_0] -- 824
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 825
						local showSep = false -- 826
						if match(gameName) then -- 827
							Columns(1, false) -- 828
							TextColored(themeColor, zh and "项目：" or "Project:") -- 829
							SameLine() -- 830
							Text(gameName) -- 831
							Separator() -- 832
							if bannerFile then -- 833
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 834
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 835
								local sizing <const> = 0.8 -- 836
								texHeight = displayWidth * sizing * texHeight / texWidth -- 837
								texWidth = displayWidth * sizing -- 838
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 839
								Dummy(Vec2(padding, 0)) -- 840
								SameLine() -- 841
								PushID(fileName, function() -- 842
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 843
										return enterDemoEntry(game) -- 844
									end -- 843
								end) -- 842
							else -- 846
								PushID(fileName, function() -- 846
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 847
										return enterDemoEntry(game) -- 848
									end -- 847
								end) -- 846
							end -- 833
							NextColumn() -- 849
							showSep = true -- 850
						end -- 827
						if #examples > 0 then -- 851
							local showExample = false -- 852
							for _index_1 = 1, #examples do -- 853
								local example = examples[_index_1] -- 853
								if match(example[1]) then -- 854
									showExample = true -- 855
									break -- 856
								end -- 854
							end -- 856
							if showExample then -- 857
								Columns(1, false) -- 858
								TextColored(themeColor, zh and "示例：" or "Example:") -- 859
								SameLine() -- 860
								Text(gameName) -- 861
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 862
									Columns(maxColumns, false) -- 863
									for _index_1 = 1, #examples do -- 864
										local example = examples[_index_1] -- 864
										if not match(example[1]) then -- 865
											goto _continue_0 -- 865
										end -- 865
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 866
											if Button(example[1], Vec2(-1, 40)) then -- 867
												enterDemoEntry(example) -- 868
											end -- 867
											return NextColumn() -- 869
										end) -- 866
										showSep = true -- 870
										::_continue_0:: -- 865
									end -- 870
								end) -- 862
							end -- 857
						end -- 851
						if #tests > 0 then -- 871
							local showTest = false -- 872
							for _index_1 = 1, #tests do -- 873
								local test = tests[_index_1] -- 873
								if match(test[1]) then -- 874
									showTest = true -- 875
									break -- 876
								end -- 874
							end -- 876
							if showTest then -- 877
								Columns(1, false) -- 878
								TextColored(themeColor, zh and "测试：" or "Test:") -- 879
								SameLine() -- 880
								Text(gameName) -- 881
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 882
									Columns(maxColumns, false) -- 883
									for _index_1 = 1, #tests do -- 884
										local test = tests[_index_1] -- 884
										if not match(test[1]) then -- 885
											goto _continue_0 -- 885
										end -- 885
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 886
											if Button(test[1], Vec2(-1, 40)) then -- 887
												enterDemoEntry(test) -- 888
											end -- 887
											return NextColumn() -- 889
										end) -- 886
										showSep = true -- 890
										::_continue_0:: -- 885
									end -- 890
								end) -- 882
							end -- 877
						end -- 871
						if showSep then -- 891
							Columns(1, false) -- 892
							Separator() -- 893
						end -- 891
					end -- 893
				end -- 823
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 894
					local showGame = false -- 895
					for _index_0 = 1, #games do -- 896
						local _des_0 = games[_index_0] -- 896
						local name = _des_0[1] -- 896
						if match(name) then -- 897
							showGame = true -- 897
						end -- 897
					end -- 897
					local showExample = false -- 898
					for _index_0 = 1, #doraExamples do -- 899
						local _des_0 = doraExamples[_index_0] -- 899
						local name = _des_0[1] -- 899
						if match(name) then -- 900
							showExample = true -- 900
						end -- 900
					end -- 900
					local showTest = false -- 901
					for _index_0 = 1, #doraTests do -- 902
						local _des_0 = doraTests[_index_0] -- 902
						local name = _des_0[1] -- 902
						if match(name) then -- 903
							showTest = true -- 903
						end -- 903
					end -- 903
					for _index_0 = 1, #cppTests do -- 904
						local _des_0 = cppTests[_index_0] -- 904
						local name = _des_0[1] -- 904
						if match(name) then -- 905
							showTest = true -- 905
						end -- 905
					end -- 905
					if not (showGame or showExample or showTest) then -- 906
						goto endEntry -- 906
					end -- 906
					Columns(1, false) -- 907
					TextColored(themeColor, "Dora SSR:") -- 908
					SameLine() -- 909
					Text(zh and "开发示例" or "Development Showcase") -- 910
					Separator() -- 911
					local demoViewWith <const> = 400 -- 912
					if #games > 0 and showGame then -- 913
						local opened -- 914
						if (filterText ~= nil) then -- 914
							opened = showGame -- 914
						else -- 914
							opened = false -- 914
						end -- 914
						SetNextItemOpen(gameOpen) -- 915
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 916
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 917
							Columns(columns, false) -- 918
							for _index_0 = 1, #games do -- 919
								local game = games[_index_0] -- 919
								if not match(game[1]) then -- 920
									goto _continue_0 -- 920
								end -- 920
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 921
								if columns > 1 then -- 922
									if bannerFile then -- 923
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 924
										local displayWidth <const> = demoViewWith - 40 -- 925
										texHeight = displayWidth * texHeight / texWidth -- 926
										texWidth = displayWidth -- 927
										Text(gameName) -- 928
										PushID(fileName, function() -- 929
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 930
												return enterDemoEntry(game) -- 931
											end -- 930
										end) -- 929
									else -- 933
										PushID(fileName, function() -- 933
											if Button(gameName, Vec2(-1, 40)) then -- 934
												return enterDemoEntry(game) -- 935
											end -- 934
										end) -- 933
									end -- 923
								else -- 937
									if bannerFile then -- 937
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 938
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 939
										local sizing = 0.8 -- 940
										texHeight = displayWidth * sizing * texHeight / texWidth -- 941
										texWidth = displayWidth * sizing -- 942
										if texWidth > 500 then -- 943
											sizing = 0.6 -- 944
											texHeight = displayWidth * sizing * texHeight / texWidth -- 945
											texWidth = displayWidth * sizing -- 946
										end -- 943
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 947
										Dummy(Vec2(padding, 0)) -- 948
										SameLine() -- 949
										Text(gameName) -- 950
										Dummy(Vec2(padding, 0)) -- 951
										SameLine() -- 952
										PushID(fileName, function() -- 953
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 954
												return enterDemoEntry(game) -- 955
											end -- 954
										end) -- 953
									else -- 957
										PushID(fileName, function() -- 957
											if Button(gameName, Vec2(-1, 40)) then -- 958
												return enterDemoEntry(game) -- 959
											end -- 958
										end) -- 957
									end -- 937
								end -- 922
								NextColumn() -- 960
								::_continue_0:: -- 920
							end -- 960
							Columns(1, false) -- 961
							opened = true -- 962
						end) -- 916
						gameOpen = opened -- 963
					end -- 913
					if #doraExamples > 0 and showExample then -- 964
						local opened -- 965
						if (filterText ~= nil) then -- 965
							opened = showExample -- 965
						else -- 965
							opened = false -- 965
						end -- 965
						SetNextItemOpen(exampleOpen) -- 966
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 967
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 968
								Columns(maxColumns, false) -- 969
								for _index_0 = 1, #doraExamples do -- 970
									local example = doraExamples[_index_0] -- 970
									if not match(example[1]) then -- 971
										goto _continue_0 -- 971
									end -- 971
									if Button(example[1], Vec2(-1, 40)) then -- 972
										enterDemoEntry(example) -- 973
									end -- 972
									NextColumn() -- 974
									::_continue_0:: -- 971
								end -- 974
								Columns(1, false) -- 975
								opened = true -- 976
							end) -- 968
						end) -- 967
						exampleOpen = opened -- 977
					end -- 964
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 978
						local opened -- 979
						if (filterText ~= nil) then -- 979
							opened = showTest -- 979
						else -- 979
							opened = false -- 979
						end -- 979
						SetNextItemOpen(testOpen) -- 980
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 981
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 982
								Columns(maxColumns, false) -- 983
								for _index_0 = 1, #doraTests do -- 984
									local test = doraTests[_index_0] -- 984
									if not match(test[1]) then -- 985
										goto _continue_0 -- 985
									end -- 985
									if Button(test[1], Vec2(-1, 40)) then -- 986
										enterDemoEntry(test) -- 987
									end -- 986
									NextColumn() -- 988
									::_continue_0:: -- 985
								end -- 988
								for _index_0 = 1, #cppTests do -- 989
									local test = cppTests[_index_0] -- 989
									if not match(test[1]) then -- 990
										goto _continue_1 -- 990
									end -- 990
									if Button(test[1], Vec2(-1, 40)) then -- 991
										enterDemoEntry(test) -- 992
									end -- 991
									NextColumn() -- 993
									::_continue_1:: -- 990
								end -- 993
								opened = true -- 994
							end) -- 982
						end) -- 981
						testOpen = opened -- 995
					end -- 978
				end -- 894
				::endEntry:: -- 996
				if not anyEntryMatched then -- 997
					SetNextWindowBgAlpha(0) -- 998
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 999
					Begin("Entries Not Found", displayWindowFlags, function() -- 1000
						Separator() -- 1001
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1002
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1003
						return Separator() -- 1004
					end) -- 1000
				end -- 997
				Columns(1, false) -- 1005
				Dummy(Vec2(100, 80)) -- 1006
				return ScrollWhenDraggingOnVoid() -- 1007
			end) -- 1007
		end) -- 1007
	end) -- 1007
end) -- 759
webStatus = require("WebServer") -- 1009
return _module_0 -- 1009
