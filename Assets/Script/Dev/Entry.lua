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
App.idled = true -- 3
local moduleCache = { } -- 5
local oldRequire = _G.require -- 6
local require -- 7
require = function(path) -- 7
	local loaded = package.loaded[path] -- 8
	if loaded == nil then -- 9
		moduleCache[#moduleCache + 1] = path -- 10
		return oldRequire(path) -- 11
	end -- 9
	return loaded -- 12
end -- 7
_G.require = require -- 13
dora.require = require -- 14
local searchPaths = Content.searchPaths -- 16
local useChinese = (App.locale:match("^zh") ~= nil) -- 18
local updateLocale -- 19
updateLocale = function() -- 19
	useChinese = (App.locale:match("^zh") ~= nil) -- 20
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 21
	Content.searchPaths = searchPaths -- 22
end -- 19
if DB:exist("Config") then -- 24
	local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 25
	local _type_0 = type(_exp_0) -- 26
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 26
	if _tab_0 then -- 26
		local locale -- 26
		do -- 26
			local _obj_0 = _exp_0[1] -- 26
			local _type_1 = type(_obj_0) -- 26
			if "table" == _type_1 or "userdata" == _type_1 then -- 26
				locale = _obj_0[1] -- 26
			end -- 28
		end -- 28
		if locale ~= nil then -- 26
			if App.locale ~= locale then -- 26
				App.locale = locale -- 27
				updateLocale() -- 28
			end -- 26
		end -- 26
	end -- 28
end -- 24
local Config = require("Config") -- 30
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter") -- 31
config:load() -- 50
if (config.fpsLimited ~= nil) then -- 51
	App.fpsLimited = config.fpsLimited == 1 -- 52
else -- 54
	config.fpsLimited = App.fpsLimited and 1 or 0 -- 54
end -- 51
if (config.targetFPS ~= nil) then -- 56
	App.targetFPS = config.targetFPS -- 57
else -- 59
	config.targetFPS = App.targetFPS -- 59
end -- 56
if (config.vsync ~= nil) then -- 61
	View.vsync = config.vsync == 1 -- 62
else -- 64
	config.vsync = View.vsync and 1 or 0 -- 64
end -- 61
if (config.fixedFPS ~= nil) then -- 66
	Director.scheduler.fixedFPS = config.fixedFPS -- 67
else -- 69
	config.fixedFPS = Director.scheduler.fixedFPS -- 69
end -- 66
local showEntry = true -- 71
if (function() -- 73
	local _val_0 = App.platform -- 73
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 73
end)() then -- 73
	if (config.fullScreen ~= nil) and config.fullScreen == 1 then -- 74
		App.winSize = Size.zero -- 75
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 76
		local size = Size(config.winWidth, config.winHeight) -- 77
		if App.winSize ~= size then -- 78
			App.winSize = size -- 79
			showEntry = false -- 80
			thread(function() -- 81
				sleep() -- 82
				sleep() -- 83
				showEntry = true -- 84
			end) -- 81
		end -- 78
		local winX, winY -- 85
		do -- 85
			local _obj_0 = App.winPosition -- 85
			winX, winY = _obj_0.x, _obj_0.y -- 85
		end -- 85
		if (config.winX ~= nil) then -- 86
			winX = config.winX -- 87
		else -- 89
			config.winX = 0 -- 89
		end -- 86
		if (config.winY ~= nil) then -- 90
			winY = config.winY -- 91
		else -- 93
			config.winY = 0 -- 93
		end -- 90
		App.winPosition = Vec2(winX, winY) -- 94
	end -- 74
end -- 73
if (config.themeColor ~= nil) then -- 96
	App.themeColor = Color(config.themeColor) -- 97
else -- 99
	config.themeColor = App.themeColor:toARGB() -- 99
end -- 96
if not (config.locale ~= nil) then -- 101
	config.locale = App.locale -- 102
end -- 101
local showStats = false -- 104
if (config.showStats ~= nil) then -- 105
	showStats = config.showStats > 0 -- 106
else -- 108
	config.showStats = showStats and 1 or 0 -- 108
end -- 105
local showConsole = true -- 110
if (config.showConsole ~= nil) then -- 111
	showConsole = config.showConsole > 0 -- 112
else -- 114
	config.showConsole = showConsole and 1 or 0 -- 114
end -- 111
local showFooter = true -- 116
if (config.showFooter ~= nil) then -- 117
	showFooter = config.showFooter > 0 -- 118
else -- 120
	config.showFooter = showFooter and 1 or 0 -- 120
end -- 117
local filterBuf = Buffer(20) -- 122
if (config.filter ~= nil) then -- 123
	filterBuf:setString(config.filter) -- 124
else -- 126
	config.filter = "" -- 126
end -- 123
_module_0.getConfig = function() -- 128
	return config -- 128
end -- 128
local Set, Struct, LintYueGlobals, GSplit -- 130
do -- 130
	local _obj_0 = require("Utils") -- 130
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 130
end -- 130
local yueext = yue.options.extension -- 131
local isChineseSupported = IsFontLoaded() -- 133
if not isChineseSupported then -- 134
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 135
		isChineseSupported = true -- 136
	end) -- 135
end -- 134
local building = false -- 138
local getAllFiles -- 140
getAllFiles = function(path, exts) -- 140
	local filters = Set(exts) -- 141
	local _accum_0 = { } -- 142
	local _len_0 = 1 -- 142
	local _list_0 = Content:getAllFiles(path) -- 142
	for _index_0 = 1, #_list_0 do -- 142
		local file = _list_0[_index_0] -- 142
		if not filters[Path:getExt(file)] then -- 143
			goto _continue_0 -- 143
		end -- 143
		_accum_0[_len_0] = file -- 144
		_len_0 = _len_0 + 1 -- 144
		::_continue_0:: -- 143
	end -- 144
	return _accum_0 -- 144
end -- 140
local getFileEntries -- 146
getFileEntries = function(path) -- 146
	local entries = { } -- 147
	local _list_0 = getAllFiles(path, { -- 148
		"lua", -- 148
		"xml", -- 148
		yueext, -- 148
		"tl" -- 148
	}) -- 148
	for _index_0 = 1, #_list_0 do -- 148
		local file = _list_0[_index_0] -- 148
		local entryName = Path:getName(file) -- 149
		local entryAdded = false -- 150
		for _index_1 = 1, #entries do -- 151
			local _des_0 = entries[_index_1] -- 151
			local ename = _des_0[1] -- 151
			if entryName == ename then -- 152
				entryAdded = true -- 153
				break -- 154
			end -- 152
		end -- 154
		if entryAdded then -- 155
			goto _continue_0 -- 155
		end -- 155
		local fileName = Path:replaceExt(file, "") -- 156
		fileName = Path(Path:getName(path), fileName) -- 157
		local entry = { -- 158
			entryName, -- 158
			fileName -- 158
		} -- 158
		entries[#entries + 1] = entry -- 159
		::_continue_0:: -- 149
	end -- 159
	table.sort(entries, function(a, b) -- 160
		return a[1] < b[1] -- 160
	end) -- 160
	return entries -- 161
end -- 146
local getProjectEntries -- 163
getProjectEntries = function(path) -- 163
	local entries = { } -- 164
	local _list_0 = Content:getDirs(path) -- 165
	for _index_0 = 1, #_list_0 do -- 165
		local dir = _list_0[_index_0] -- 165
		if dir:match("^%.") then -- 166
			goto _continue_0 -- 166
		end -- 166
		local _list_1 = getAllFiles(Path(path, dir), { -- 167
			"lua", -- 167
			"xml", -- 167
			yueext, -- 167
			"tl", -- 167
			"wasm" -- 167
		}) -- 167
		for _index_1 = 1, #_list_1 do -- 167
			local file = _list_1[_index_1] -- 167
			if "init" == Path:getName(file):lower() then -- 168
				local fileName = Path:replaceExt(file, "") -- 169
				fileName = Path(dir, fileName) -- 170
				local entryName = Path:getName(Path:getPath(fileName)) -- 171
				local entryAdded = false -- 172
				for _index_2 = 1, #entries do -- 173
					local _des_0 = entries[_index_2] -- 173
					local ename = _des_0[1] -- 173
					if entryName == ename then -- 174
						entryAdded = true -- 175
						break -- 176
					end -- 174
				end -- 176
				if entryAdded then -- 177
					goto _continue_1 -- 177
				end -- 177
				local examples = { } -- 178
				local tests = { } -- 179
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 180
				if Content:exist(examplePath) then -- 181
					local _list_2 = getFileEntries(examplePath) -- 182
					for _index_2 = 1, #_list_2 do -- 182
						local _des_0 = _list_2[_index_2] -- 182
						local name, ePath = _des_0[1], _des_0[2] -- 182
						local entry = { -- 183
							name, -- 183
							Path(dir, Path:getPath(file), ePath) -- 183
						} -- 183
						examples[#examples + 1] = entry -- 184
					end -- 184
				end -- 181
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 185
				if Content:exist(testPath) then -- 186
					local _list_2 = getFileEntries(testPath) -- 187
					for _index_2 = 1, #_list_2 do -- 187
						local _des_0 = _list_2[_index_2] -- 187
						local name, tPath = _des_0[1], _des_0[2] -- 187
						local entry = { -- 188
							name, -- 188
							Path(dir, Path:getPath(file), tPath) -- 188
						} -- 188
						tests[#tests + 1] = entry -- 189
					end -- 189
				end -- 186
				local entry = { -- 190
					entryName, -- 190
					fileName, -- 190
					examples, -- 190
					tests -- 190
				} -- 190
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 191
				if not Content:exist(bannerFile) then -- 192
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 193
					if not Content:exist(bannerFile) then -- 194
						bannerFile = nil -- 194
					end -- 194
				end -- 192
				if bannerFile then -- 195
					thread(function() -- 195
						Cache:loadAsync(bannerFile) -- 196
						local bannerTex = Texture2D(bannerFile) -- 197
						if bannerTex then -- 198
							entry[#entry + 1] = bannerFile -- 199
							entry[#entry + 1] = bannerTex -- 200
						end -- 198
					end) -- 195
				end -- 195
				entries[#entries + 1] = entry -- 201
			end -- 168
			::_continue_1:: -- 168
		end -- 201
		::_continue_0:: -- 166
	end -- 201
	table.sort(entries, function(a, b) -- 202
		return a[1] < b[1] -- 202
	end) -- 202
	return entries -- 203
end -- 163
local gamesInDev, games -- 205
local doraExamples, doraTests -- 206
local cppTests, cppTestSet -- 207
local allEntries -- 208
local updateEntries -- 210
updateEntries = function() -- 210
	gamesInDev = getProjectEntries(Content.writablePath) -- 211
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 212
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 214
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 215
	cppTests = { } -- 217
	local _list_0 = App.testNames -- 218
	for _index_0 = 1, #_list_0 do -- 218
		local name = _list_0[_index_0] -- 218
		local entry = { -- 219
			name -- 219
		} -- 219
		cppTests[#cppTests + 1] = entry -- 220
	end -- 220
	cppTestSet = Set(cppTests) -- 221
	allEntries = { } -- 223
	for _index_0 = 1, #gamesInDev do -- 224
		local game = gamesInDev[_index_0] -- 224
		allEntries[#allEntries + 1] = game -- 225
		local examples, tests = game[3], game[4] -- 226
		for _index_1 = 1, #examples do -- 227
			local example = examples[_index_1] -- 227
			allEntries[#allEntries + 1] = example -- 228
		end -- 228
		for _index_1 = 1, #tests do -- 229
			local test = tests[_index_1] -- 229
			allEntries[#allEntries + 1] = test -- 230
		end -- 230
	end -- 230
	for _index_0 = 1, #games do -- 231
		local game = games[_index_0] -- 231
		allEntries[#allEntries + 1] = game -- 232
		local examples, tests = game[3], game[4] -- 233
		for _index_1 = 1, #examples do -- 234
			local example = examples[_index_1] -- 234
			doraExamples[#doraExamples + 1] = example -- 235
		end -- 235
		for _index_1 = 1, #tests do -- 236
			local test = tests[_index_1] -- 236
			doraTests[#doraTests + 1] = test -- 237
		end -- 237
	end -- 237
	local _list_1 = { -- 239
		doraExamples, -- 239
		doraTests, -- 240
		cppTests -- 241
	} -- 238
	for _index_0 = 1, #_list_1 do -- 242
		local group = _list_1[_index_0] -- 238
		for _index_1 = 1, #group do -- 243
			local entry = group[_index_1] -- 243
			allEntries[#allEntries + 1] = entry -- 244
		end -- 244
	end -- 244
end -- 210
updateEntries() -- 246
local doCompile -- 248
doCompile = function(minify) -- 248
	if building then -- 249
		return -- 249
	end -- 249
	building = true -- 250
	local startTime = App.runningTime -- 251
	local luaFiles = { } -- 252
	local yueFiles = { } -- 253
	local xmlFiles = { } -- 254
	local tlFiles = { } -- 255
	local writablePath = Content.writablePath -- 256
	local buildPaths = { -- 258
		{ -- 259
			Path(Content.assetPath), -- 259
			Path(writablePath, ".build"), -- 260
			"" -- 261
		} -- 258
	} -- 257
	for _index_0 = 1, #gamesInDev do -- 264
		local _des_0 = gamesInDev[_index_0] -- 264
		local name, entryFile = _des_0[1], _des_0[2] -- 264
		local gamePath = Path:getPath(entryFile) -- 265
		buildPaths[#buildPaths + 1] = { -- 267
			Path(writablePath, gamePath), -- 267
			Path(writablePath, ".build", gamePath), -- 268
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 269
			gamePath -- 270
		} -- 266
	end -- 270
	for _index_0 = 1, #buildPaths do -- 271
		local _des_0 = buildPaths[_index_0] -- 271
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 271
		if not Content:exist(inputPath) then -- 272
			goto _continue_0 -- 272
		end -- 272
		local _list_0 = getAllFiles(inputPath, { -- 274
			"lua" -- 274
		}) -- 274
		for _index_1 = 1, #_list_0 do -- 274
			local file = _list_0[_index_1] -- 274
			luaFiles[#luaFiles + 1] = { -- 276
				file, -- 276
				Path(inputPath, file), -- 277
				Path(outputPath, file), -- 278
				gamePath -- 279
			} -- 275
		end -- 279
		local _list_1 = getAllFiles(inputPath, { -- 281
			yueext -- 281
		}) -- 281
		for _index_1 = 1, #_list_1 do -- 281
			local file = _list_1[_index_1] -- 281
			yueFiles[#yueFiles + 1] = { -- 283
				file, -- 283
				Path(inputPath, file), -- 284
				Path(outputPath, Path:replaceExt(file, "lua")), -- 285
				searchPath, -- 286
				gamePath -- 287
			} -- 282
		end -- 287
		local _list_2 = getAllFiles(inputPath, { -- 289
			"xml" -- 289
		}) -- 289
		for _index_1 = 1, #_list_2 do -- 289
			local file = _list_2[_index_1] -- 289
			xmlFiles[#xmlFiles + 1] = { -- 291
				file, -- 291
				Path(inputPath, file), -- 292
				Path(outputPath, Path:replaceExt(file, "lua")), -- 293
				gamePath -- 294
			} -- 290
		end -- 294
		local _list_3 = getAllFiles(inputPath, { -- 296
			"tl" -- 296
		}) -- 296
		for _index_1 = 1, #_list_3 do -- 296
			local file = _list_3[_index_1] -- 296
			if not file:match(".*%.d%.tl$") then -- 297
				tlFiles[#tlFiles + 1] = { -- 299
					file, -- 299
					Path(inputPath, file), -- 300
					Path(outputPath, Path:replaceExt(file, "lua")), -- 301
					searchPath, -- 302
					gamePath -- 303
				} -- 298
			end -- 297
		end -- 303
		::_continue_0:: -- 272
	end -- 303
	local paths -- 305
	do -- 305
		local _tbl_0 = { } -- 305
		local _list_0 = { -- 306
			luaFiles, -- 306
			yueFiles, -- 306
			xmlFiles, -- 306
			tlFiles -- 306
		} -- 306
		for _index_0 = 1, #_list_0 do -- 306
			local files = _list_0[_index_0] -- 306
			for _index_1 = 1, #files do -- 307
				local file = files[_index_1] -- 307
				_tbl_0[Path:getPath(file[3])] = true -- 305
			end -- 305
		end -- 305
		paths = _tbl_0 -- 305
	end -- 307
	for path in pairs(paths) do -- 309
		Content:mkdir(path) -- 309
	end -- 309
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 311
	local fileCount = 0 -- 312
	local errors = { } -- 313
	for _index_0 = 1, #yueFiles do -- 314
		local _des_0 = yueFiles[_index_0] -- 314
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 314
		local filename -- 315
		if gamePath then -- 315
			filename = Path(gamePath, file) -- 315
		else -- 315
			filename = file -- 315
		end -- 315
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 316
			if not codes then -- 317
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 318
				return -- 319
			end -- 317
			local success, result = LintYueGlobals(codes, globals) -- 320
			if success then -- 321
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 322
				codes = codes:gsub("^\n*", "") -- 323
				if not (result == "") then -- 324
					result = result .. "\n" -- 324
				end -- 324
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 325
			else -- 327
				local yueCodes = Content:load(input) -- 327
				if yueCodes then -- 327
					local globalErrors = { } -- 328
					for _index_1 = 1, #result do -- 329
						local _des_1 = result[_index_1] -- 329
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 329
						local countLine = 1 -- 330
						local code = "" -- 331
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 332
							if countLine == line then -- 333
								code = lineCode -- 334
								break -- 335
							end -- 333
							countLine = countLine + 1 -- 336
						end -- 336
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 337
					end -- 337
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 338
				else -- 340
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 340
				end -- 327
			end -- 321
		end, function(success) -- 316
			if success then -- 341
				print("Yue compiled: " .. tostring(filename)) -- 341
			end -- 341
			fileCount = fileCount + 1 -- 342
		end) -- 316
	end -- 342
	thread(function() -- 344
		for _index_0 = 1, #xmlFiles do -- 345
			local _des_0 = xmlFiles[_index_0] -- 345
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 345
			local filename -- 346
			if gamePath then -- 346
				filename = Path(gamePath, file) -- 346
			else -- 346
				filename = file -- 346
			end -- 346
			local sourceCodes = Content:loadAsync(input) -- 347
			local codes, err = xml.tolua(sourceCodes) -- 348
			if not codes then -- 349
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 350
			else -- 352
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 352
				print("Xml compiled: " .. tostring(filename)) -- 353
			end -- 349
			fileCount = fileCount + 1 -- 354
		end -- 354
	end) -- 344
	thread(function() -- 356
		for _index_0 = 1, #tlFiles do -- 357
			local _des_0 = tlFiles[_index_0] -- 357
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 357
			local filename -- 358
			if gamePath then -- 358
				filename = Path(gamePath, file) -- 358
			else -- 358
				filename = file -- 358
			end -- 358
			local sourceCodes = Content:loadAsync(input) -- 359
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 360
			if not codes then -- 361
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 362
			else -- 364
				Content:saveAsync(output, codes) -- 364
				print("Teal compiled: " .. tostring(filename)) -- 365
			end -- 361
			fileCount = fileCount + 1 -- 366
		end -- 366
	end) -- 356
	return thread(function() -- 368
		wait(function() -- 369
			return fileCount == totalFiles -- 369
		end) -- 369
		if minify then -- 370
			local _list_0 = { -- 371
				yueFiles, -- 371
				xmlFiles, -- 371
				tlFiles -- 371
			} -- 371
			for _index_0 = 1, #_list_0 do -- 371
				local files = _list_0[_index_0] -- 371
				for _index_1 = 1, #files do -- 371
					local file = files[_index_1] -- 371
					local output = Path:replaceExt(file[3], "lua") -- 372
					luaFiles[#luaFiles + 1] = { -- 374
						Path:replaceExt(file[1], "lua"), -- 374
						output, -- 375
						output -- 376
					} -- 373
				end -- 376
			end -- 376
			local FormatMini -- 378
			do -- 378
				local _obj_0 = require("luaminify") -- 378
				FormatMini = _obj_0.FormatMini -- 378
			end -- 378
			for _index_0 = 1, #luaFiles do -- 379
				local _des_0 = luaFiles[_index_0] -- 379
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 379
				if Content:exist(input) then -- 380
					local sourceCodes = Content:loadAsync(input) -- 381
					local res, err = FormatMini(sourceCodes) -- 382
					if res then -- 383
						Content:saveAsync(output, res) -- 384
						print("Minify: " .. tostring(file)) -- 385
					else -- 387
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 387
					end -- 383
				else -- 389
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 389
				end -- 380
			end -- 389
			package.loaded["luaminify.FormatMini"] = nil -- 390
			package.loaded["luaminify.ParseLua"] = nil -- 391
			package.loaded["luaminify.Scope"] = nil -- 392
			package.loaded["luaminify.Util"] = nil -- 393
		end -- 370
		local errorMessage = table.concat(errors, "\n") -- 394
		if errorMessage ~= "" then -- 395
			print("\n" .. errorMessage) -- 395
		end -- 395
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 396
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 397
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 398
		Content:clearPathCache() -- 399
		teal.clear() -- 400
		yue.clear() -- 401
		building = false -- 402
	end) -- 402
end -- 248
local doClean -- 404
doClean = function() -- 404
	if building then -- 405
		return -- 405
	end -- 405
	local writablePath = Content.writablePath -- 406
	local targetDir = Path(writablePath, ".build") -- 407
	Content:clearPathCache() -- 408
	if Content:remove(targetDir) then -- 409
		print("Cleaned: " .. tostring(targetDir)) -- 410
	end -- 409
	Content:remove(Path(writablePath, ".upload")) -- 411
	return Content:remove(Path(writablePath, ".download")) -- 412
end -- 404
local screenScale = 2.0 -- 414
local scaleContent = false -- 415
local isInEntry = true -- 416
local currentEntry = nil -- 417
local footerWindow = nil -- 419
local entryWindow = nil -- 420
local setupEventHandlers -- 422
setupEventHandlers = function() -- 422
	local _with_0 = Director.postNode -- 423
	_with_0:gslot("AppTheme", function(argb) -- 424
		config.themeColor = argb -- 425
	end) -- 424
	_with_0:gslot("AppLocale", function(locale) -- 426
		config.locale = locale -- 427
		updateLocale() -- 428
		return teal.clear(true) -- 429
	end) -- 426
	_with_0:gslot("AppWSClose", function() -- 430
		if HttpServer.wsConnectionCount == 0 then -- 431
			return updateEntries() -- 432
		end -- 431
	end) -- 430
	local _exp_0 = App.platform -- 433
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 433
		_with_0:gslot("AppSizeChanged", function() -- 434
			local width, height -- 435
			do -- 435
				local _obj_0 = App.winSize -- 435
				width, height = _obj_0.width, _obj_0.height -- 435
			end -- 435
			config.winWidth = width -- 436
			config.winHeight = height -- 437
		end) -- 434
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 438
			config.fullScreen = fullScreen and 1 or 0 -- 439
		end) -- 438
		_with_0:gslot("AppMoved", function() -- 440
			do -- 441
				local _obj_0 = App.winPosition -- 441
				config.winX, config.winY = _obj_0.x, _obj_0.y -- 441
			end -- 441
		end) -- 440
	end -- 441
	return _with_0 -- 423
end -- 422
setupEventHandlers() -- 443
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
	Audio:stopStream(0.2) -- 460
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
local stop -- 476
stop = function() -- 476
	if isInEntry then -- 477
		return false -- 477
	end -- 477
	allClear() -- 478
	isInEntry = true -- 479
	currentEntry = nil -- 480
	return true -- 481
end -- 476
_module_0["stop"] = stop -- 481
local _anon_func_0 = function(Content, Path, file, require, type) -- 502
	do -- 495
		local scriptPath = Path:getPath(file) -- 495
		Content:insertSearchPath(1, scriptPath) -- 496
		scriptPath = Path(scriptPath, "Script") -- 497
		if Content:exist(scriptPath) then -- 498
			Content:insertSearchPath(1, scriptPath) -- 499
		end -- 498
		local result = require(file) -- 500
		if "function" == type(result) then -- 501
			result() -- 501
		end -- 501
		return nil -- 502
	end -- 502
end -- 495
local _anon_func_1 = function(Label, err, fontSize, scroll, width) -- 532
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 529
	label.alignment = "Left" -- 530
	label.textWidth = width - fontSize -- 531
	label.text = err -- 532
	return label -- 529
end -- 529
local enterEntryAsync -- 483
enterEntryAsync = function(entry) -- 483
	isInEntry = false -- 484
	App.idled = false -- 485
	currentEntry = entry -- 486
	local name, file = entry[1], entry[2] -- 487
	if cppTestSet[entry] then -- 488
		if App:runTest(name) then -- 489
			return true -- 490
		else -- 492
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 492
		end -- 489
	end -- 488
	sleep() -- 493
	return xpcall(_anon_func_0, function(msg) -- 502
		local err = debug.traceback(msg) -- 504
		allClear() -- 505
		print(err) -- 506
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 507
		local AlignNode = require("UI.Control.Basic.AlignNode") -- 508
		local LineRect = require("UI.View.Shape.LineRect") -- 509
		local viewWidth, viewHeight -- 510
		do -- 510
			local _obj_0 = View.size -- 510
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 510
		end -- 510
		local width, height = viewWidth - 20, viewHeight - 20 -- 511
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 512
		do -- 513
			local _with_0 = AlignNode({ -- 513
				isRoot = true, -- 513
				inUI = false -- 513
			}) -- 513
			_with_0:addChild((function() -- 514
				local root = AlignNode({ -- 514
					alignWidth = "w", -- 514
					alignHeight = "h" -- 514
				}) -- 514
				root:addChild((function() -- 515
					local scroll = ScrollArea({ -- 516
						width = width, -- 516
						height = height, -- 517
						paddingX = 0, -- 518
						paddingY = 50, -- 519
						viewWidth = height, -- 520
						viewHeight = height -- 521
					}) -- 515
					scroll:slot("AlignLayout", function(w, h) -- 523
						scroll.position = Vec2(w / 2, h / 2) -- 524
						w = w - 20 -- 525
						h = h - 20 -- 526
						scroll.view.children.first.textWidth = w - fontSize -- 527
						return scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 528
					end) -- 523
					scroll.view:addChild(_anon_func_1(Label, err, fontSize, scroll, width)) -- 529
					return scroll -- 515
				end)()) -- 515
				return root -- 514
			end)()) -- 514
			_with_0:alignLayout() -- 533
		end -- 513
		return err -- 534
	end, Content, Path, file, require, type) -- 534
end -- 483
_module_0["enterEntryAsync"] = enterEntryAsync -- 534
local enterDemoEntry -- 536
enterDemoEntry = function(entry) -- 536
	return thread(function() -- 536
		return enterEntryAsync(entry) -- 536
	end) -- 536
end -- 536
local reloadCurrentEntry -- 538
reloadCurrentEntry = function() -- 538
	if currentEntry then -- 539
		allClear() -- 540
		return enterDemoEntry(currentEntry) -- 541
	end -- 539
end -- 538
Director.clearColor = Color(0xff1a1a1a) -- 543
local waitForWebStart = true -- 545
thread(function() -- 546
	sleep(2) -- 547
	waitForWebStart = false -- 548
end) -- 546
local reloadDevEntry -- 550
reloadDevEntry = function() -- 550
	return thread(function() -- 550
		waitForWebStart = true -- 551
		doClean() -- 552
		allClear() -- 553
		_G.require = oldRequire -- 554
		dora.require = oldRequire -- 555
		package.loaded["Dev.Entry"] = nil -- 556
		return Director.systemScheduler:schedule(function() -- 557
			Routine:clear() -- 558
			oldRequire("Dev.Entry") -- 559
			return true -- 560
		end) -- 560
	end) -- 560
end -- 550
local isOSSLicenseExist = Content:exist("LICENSES") -- 562
local ossLicenses = nil -- 563
local ossLicenseOpen = false -- 564
local extraOperations -- 566
extraOperations = function() -- 566
	local zh = useChinese and isChineseSupported -- 567
	if isOSSLicenseExist then -- 568
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 569
			if not ossLicenses then -- 570
				ossLicenses = { } -- 571
				local licenseText = Content:load("LICENSES") -- 572
				ossLicenseOpen = (licenseText ~= nil) -- 573
				if ossLicenseOpen then -- 573
					licenseText = licenseText:gsub("\r\n", "\n") -- 574
					for license in GSplit(licenseText, "\n--------\n", true) do -- 575
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 576
						if name then -- 576
							ossLicenses[#ossLicenses + 1] = { -- 577
								name, -- 577
								text -- 577
							} -- 577
						end -- 576
					end -- 577
				end -- 573
			else -- 579
				ossLicenseOpen = true -- 579
			end -- 570
		end -- 569
		if ossLicenseOpen then -- 580
			local width, height, themeColor -- 581
			do -- 581
				local _obj_0 = App -- 581
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 581
			end -- 581
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 582
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 583
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 584
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 587
					"NoSavedSettings" -- 587
				}, function() -- 588
					for _index_0 = 1, #ossLicenses do -- 588
						local _des_0 = ossLicenses[_index_0] -- 588
						local firstLine, text = _des_0[1], _des_0[2] -- 588
						local name, license = firstLine:match("(.+): (.+)") -- 589
						TextColored(themeColor, name) -- 590
						SameLine() -- 591
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 592
							return TextWrapped(text) -- 592
						end) -- 592
					end -- 592
				end) -- 584
			end) -- 584
		end -- 580
	end -- 568
	return TreeNode(zh and "开发操作" or "Development", function() -- 594
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 595
			OpenPopup("build") -- 595
		end -- 595
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 596
			return BeginPopup("build", function() -- 596
				if Selectable(zh and "编译" or "Compile") then -- 597
					doCompile(false) -- 597
				end -- 597
				Separator() -- 598
				if Selectable(zh and "压缩" or "Minify") then -- 599
					doCompile(true) -- 599
				end -- 599
				Separator() -- 600
				if Selectable(zh and "清理" or "Clean") then -- 601
					return doClean() -- 601
				end -- 601
			end) -- 601
		end) -- 596
		if isInEntry then -- 602
			if waitForWebStart then -- 603
				BeginDisabled(function() -- 604
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 604
				end) -- 604
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 605
				reloadDevEntry() -- 606
			end -- 603
		end -- 602
		local changed -- 607
		changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 607
		if changed then -- 607
			View.scale = scaleContent and screenScale or 1 -- 608
		end -- 607
	end) -- 594
end -- 566
local transparant = Color(0x0) -- 610
local windowFlags = { -- 612
	"NoTitleBar", -- 612
	"NoResize", -- 613
	"NoMove", -- 614
	"NoCollapse", -- 615
	"NoSavedSettings", -- 616
	"NoBringToFrontOnFocus" -- 617
} -- 611
local initFooter = true -- 618
local _anon_func_2 = function(allEntries, currentIndex) -- 652
	if currentIndex > 1 then -- 652
		return allEntries[currentIndex - 1] -- 653
	else -- 655
		return allEntries[#allEntries] -- 655
	end -- 652
end -- 652
local _anon_func_3 = function(allEntries, currentIndex) -- 659
	if currentIndex < #allEntries then -- 659
		return allEntries[currentIndex + 1] -- 660
	else -- 662
		return allEntries[1] -- 662
	end -- 659
end -- 659
footerWindow = threadLoop(function() -- 619
	local zh = useChinese and isChineseSupported -- 620
	if HttpServer.wsConnectionCount > 0 then -- 621
		return -- 622
	end -- 621
	if Keyboard:isKeyDown("Escape") then -- 623
		App:shutdown() -- 623
	end -- 623
	do -- 624
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 625
		if ctrl and Keyboard:isKeyDown("Q") then -- 626
			stop() -- 627
		end -- 626
		if ctrl and Keyboard:isKeyDown("Z") then -- 628
			reloadCurrentEntry() -- 629
		end -- 628
		if ctrl and Keyboard:isKeyDown(",") then -- 630
			if showFooter then -- 631
				showStats = not showStats -- 631
			else -- 631
				showStats = true -- 631
			end -- 631
			showFooter = true -- 632
			config.showFooter = showFooter and 1 or 0 -- 633
			config.showStats = showStats and 1 or 0 -- 634
		end -- 630
		if ctrl and Keyboard:isKeyDown(".") then -- 635
			if showFooter then -- 636
				showConsole = not showConsole -- 636
			else -- 636
				showConsole = true -- 636
			end -- 636
			showFooter = true -- 637
			config.showFooter = showFooter and 1 or 0 -- 638
			config.showConsole = showConsole and 1 or 0 -- 639
		end -- 635
		if ctrl and Keyboard:isKeyDown("/") then -- 640
			showFooter = not showFooter -- 641
			config.showFooter = showFooter and 1 or 0 -- 642
		end -- 640
		local left = ctrl and Keyboard:isKeyDown("Left") -- 643
		local right = ctrl and Keyboard:isKeyDown("Right") -- 644
		local currentIndex = nil -- 645
		for i, entry in ipairs(allEntries) do -- 646
			if currentEntry == entry then -- 647
				currentIndex = i -- 648
			end -- 647
		end -- 648
		if left then -- 649
			allClear() -- 650
			if currentIndex == nil then -- 651
				currentIndex = #allEntries + 1 -- 651
			end -- 651
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 652
		end -- 649
		if right then -- 656
			allClear() -- 657
			if currentIndex == nil then -- 658
				currentIndex = 0 -- 658
			end -- 658
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 659
		end -- 656
	end -- 662
	if not showEntry then -- 663
		return -- 663
	end -- 663
	local width, height -- 665
	do -- 665
		local _obj_0 = App.visualSize -- 665
		width, height = _obj_0.width, _obj_0.height -- 665
	end -- 665
	SetNextWindowSize(Vec2(50, 50)) -- 666
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 667
	PushStyleColor("WindowBg", transparant, function() -- 668
		return Begin("Show", windowFlags, function() -- 668
			if isInEntry or width >= 540 then -- 669
				local changed -- 670
				changed, showFooter = Checkbox("##dev", showFooter) -- 670
				if changed then -- 670
					config.showFooter = showFooter and 1 or 0 -- 671
				end -- 670
			end -- 669
		end) -- 671
	end) -- 668
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 673
		reloadDevEntry() -- 677
	end -- 673
	if initFooter then -- 678
		initFooter = false -- 679
	else -- 681
		if not showFooter then -- 681
			return -- 681
		end -- 681
	end -- 678
	SetNextWindowSize(Vec2(width, 50)) -- 683
	SetNextWindowPos(Vec2(0, height - 50)) -- 684
	SetNextWindowBgAlpha(0.35) -- 685
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 686
		return Begin("Footer", windowFlags, function() -- 686
			Dummy(Vec2(width - 20, 0)) -- 687
			do -- 688
				local changed -- 688
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 688
				if changed then -- 688
					config.showStats = showStats and 1 or 0 -- 689
				end -- 688
			end -- 688
			SameLine() -- 690
			do -- 691
				local changed -- 691
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 691
				if changed then -- 691
					config.showConsole = showConsole and 1 or 0 -- 692
				end -- 691
			end -- 691
			if not isInEntry then -- 693
				SameLine() -- 694
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 695
					allClear() -- 696
					isInEntry = true -- 697
					currentEntry = nil -- 698
				end -- 695
				local currentIndex = nil -- 699
				for i, entry in ipairs(allEntries) do -- 700
					if currentEntry == entry then -- 701
						currentIndex = i -- 702
					end -- 701
				end -- 702
				if currentIndex then -- 703
					if currentIndex > 1 then -- 704
						SameLine() -- 705
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 706
							allClear() -- 707
							enterDemoEntry(allEntries[currentIndex - 1]) -- 708
						end -- 706
					end -- 704
					if currentIndex < #allEntries then -- 709
						SameLine() -- 710
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 711
							allClear() -- 712
							enterDemoEntry(allEntries[currentIndex + 1]) -- 713
						end -- 711
					end -- 709
				end -- 703
				SameLine() -- 714
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 715
					reloadCurrentEntry() -- 716
				end -- 715
			end -- 693
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 717
				if showStats then -- 718
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 719
					showStats = ShowStats(showStats, extraOperations) -- 720
					config.showStats = showStats and 1 or 0 -- 721
				end -- 718
				if showConsole then -- 722
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 723
					showConsole = ShowConsole(showConsole) -- 724
					config.showConsole = showConsole and 1 or 0 -- 725
				end -- 722
			end) -- 725
		end) -- 725
	end) -- 725
end) -- 619
local MaxWidth <const> = 800 -- 727
local displayWindowFlags = { -- 730
	"NoDecoration", -- 730
	"NoSavedSettings", -- 731
	"NoFocusOnAppearing", -- 732
	"NoNav", -- 733
	"NoMove", -- 734
	"NoScrollWithMouse", -- 735
	"AlwaysAutoResize", -- 736
	"NoBringToFrontOnFocus" -- 737
} -- 729
local webStatus = nil -- 739
local descColor = Color(0xffa1a1a1) -- 740
local gameOpen = #gamesInDev == 0 -- 741
local exampleOpen = false -- 742
local testOpen = false -- 743
local filterText = nil -- 744
local anyEntryMatched = false -- 745
local match -- 746
match = function(name) -- 746
	local res = not filterText or name:lower():match(filterText) -- 747
	if res then -- 748
		anyEntryMatched = true -- 748
	end -- 748
	return res -- 749
end -- 746
entryWindow = threadLoop(function() -- 751
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 752
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 753
	end -- 752
	if App.targetFPS ~= config.targetFPS then -- 754
		config.targetFPS = App.targetFPS -- 755
	end -- 754
	if View.vsync ~= (config.vsync == 1) then -- 756
		config.vsync = View.vsync and 1 or 0 -- 757
	end -- 756
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 758
		config.fixedFPS = Director.scheduler.fixedFPS -- 759
	end -- 758
	if not showEntry then -- 760
		return -- 760
	end -- 760
	if not isInEntry then -- 761
		return -- 761
	end -- 761
	local zh = useChinese and isChineseSupported -- 762
	if HttpServer.wsConnectionCount > 0 then -- 763
		local themeColor = App.themeColor -- 764
		local width, height -- 765
		do -- 765
			local _obj_0 = App.visualSize -- 765
			width, height = _obj_0.width, _obj_0.height -- 765
		end -- 765
		SetNextWindowBgAlpha(0.5) -- 766
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 767
		Begin("Web IDE Connected", displayWindowFlags, function() -- 768
			Separator() -- 769
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 770
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 771
			TextColored(descColor, slogon) -- 772
			return Separator() -- 773
		end) -- 768
		return -- 774
	end -- 763
	local themeColor = App.themeColor -- 776
	local fullWidth, height -- 777
	do -- 777
		local _obj_0 = App.visualSize -- 777
		fullWidth, height = _obj_0.width, _obj_0.height -- 777
	end -- 777
	SetNextWindowBgAlpha(0.85) -- 779
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 780
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 781
		return Begin("Web IDE", displayWindowFlags, function() -- 782
			Separator() -- 783
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 784
			local url -- 785
			do -- 785
				local _exp_0 -- 785
				if webStatus ~= nil then -- 785
					_exp_0 = webStatus.url -- 785
				end -- 785
				if _exp_0 ~= nil then -- 785
					url = _exp_0 -- 785
				else -- 785
					url = zh and '不可用' or 'not available' -- 785
				end -- 785
			end -- 785
			TextColored(descColor, url) -- 786
			return Separator() -- 787
		end) -- 787
	end) -- 781
	local width = math.min(MaxWidth, fullWidth) -- 789
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 790
	local maxColumns = math.max(math.floor(width / 200), 1) -- 791
	SetNextWindowPos(Vec2.zero) -- 792
	SetNextWindowBgAlpha(0) -- 793
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 794
		return Begin("Dora Dev", displayWindowFlags, function() -- 795
			Dummy(Vec2(fullWidth - 20, 0)) -- 796
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 797
			SameLine() -- 798
			if fullWidth >= 320 then -- 799
				Dummy(Vec2(fullWidth - 320, 0)) -- 800
				SameLine() -- 801
				SetNextItemWidth(-50) -- 802
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 803
					"AutoSelectAll" -- 803
				}) then -- 803
					config.filter = filterBuf:toString() -- 804
				end -- 803
			end -- 799
			Separator() -- 805
			return Dummy(Vec2(fullWidth - 20, 0)) -- 806
		end) -- 806
	end) -- 794
	anyEntryMatched = false -- 808
	SetNextWindowPos(Vec2(0, 50)) -- 809
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 810
	return PushStyleColor("WindowBg", transparant, function() -- 811
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 811
			return Begin("Content", windowFlags, function() -- 812
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 813
				if filterText then -- 814
					filterText = filterText:lower() -- 814
				end -- 814
				if #gamesInDev > 0 then -- 815
					for _index_0 = 1, #gamesInDev do -- 816
						local game = gamesInDev[_index_0] -- 816
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 817
						local showSep = false -- 818
						if match(gameName) then -- 819
							Columns(1, false) -- 820
							TextColored(themeColor, zh and "项目：" or "Project:") -- 821
							SameLine() -- 822
							Text(gameName) -- 823
							Separator() -- 824
							if bannerFile then -- 825
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 826
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 827
								local sizing <const> = 0.8 -- 828
								texHeight = displayWidth * sizing * texHeight / texWidth -- 829
								texWidth = displayWidth * sizing -- 830
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 831
								Dummy(Vec2(padding, 0)) -- 832
								SameLine() -- 833
								PushID(fileName, function() -- 834
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 835
										return enterDemoEntry(game) -- 836
									end -- 835
								end) -- 834
							else -- 838
								PushID(fileName, function() -- 838
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 839
										return enterDemoEntry(game) -- 840
									end -- 839
								end) -- 838
							end -- 825
							NextColumn() -- 841
							showSep = true -- 842
						end -- 819
						if #examples > 0 then -- 843
							local showExample = false -- 844
							for _index_1 = 1, #examples do -- 845
								local example = examples[_index_1] -- 845
								if match(example[1]) then -- 846
									showExample = true -- 847
									break -- 848
								end -- 846
							end -- 848
							if showExample then -- 849
								Columns(1, false) -- 850
								TextColored(themeColor, zh and "示例：" or "Example:") -- 851
								SameLine() -- 852
								Text(gameName) -- 853
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 854
									Columns(maxColumns, false) -- 855
									for _index_1 = 1, #examples do -- 856
										local example = examples[_index_1] -- 856
										if not match(example[1]) then -- 857
											goto _continue_0 -- 857
										end -- 857
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 858
											if Button(example[1], Vec2(-1, 40)) then -- 859
												enterDemoEntry(example) -- 860
											end -- 859
											return NextColumn() -- 861
										end) -- 858
										showSep = true -- 862
										::_continue_0:: -- 857
									end -- 862
								end) -- 854
							end -- 849
						end -- 843
						if #tests > 0 then -- 863
							local showTest = false -- 864
							for _index_1 = 1, #tests do -- 865
								local test = tests[_index_1] -- 865
								if match(test[1]) then -- 866
									showTest = true -- 867
									break -- 868
								end -- 866
							end -- 868
							if showTest then -- 869
								Columns(1, false) -- 870
								TextColored(themeColor, zh and "测试：" or "Test:") -- 871
								SameLine() -- 872
								Text(gameName) -- 873
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 874
									Columns(maxColumns, false) -- 875
									for _index_1 = 1, #tests do -- 876
										local test = tests[_index_1] -- 876
										if not match(test[1]) then -- 877
											goto _continue_0 -- 877
										end -- 877
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 878
											if Button(test[1], Vec2(-1, 40)) then -- 879
												enterDemoEntry(test) -- 880
											end -- 879
											return NextColumn() -- 881
										end) -- 878
										showSep = true -- 882
										::_continue_0:: -- 877
									end -- 882
								end) -- 874
							end -- 869
						end -- 863
						if showSep then -- 883
							Columns(1, false) -- 884
							Separator() -- 885
						end -- 883
					end -- 885
				end -- 815
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 886
					local showGame = false -- 887
					for _index_0 = 1, #games do -- 888
						local _des_0 = games[_index_0] -- 888
						local name = _des_0[1] -- 888
						if match(name) then -- 889
							showGame = true -- 889
						end -- 889
					end -- 889
					local showExample = false -- 890
					for _index_0 = 1, #doraExamples do -- 891
						local _des_0 = doraExamples[_index_0] -- 891
						local name = _des_0[1] -- 891
						if match(name) then -- 892
							showExample = true -- 892
						end -- 892
					end -- 892
					local showTest = false -- 893
					for _index_0 = 1, #doraTests do -- 894
						local _des_0 = doraTests[_index_0] -- 894
						local name = _des_0[1] -- 894
						if match(name) then -- 895
							showTest = true -- 895
						end -- 895
					end -- 895
					for _index_0 = 1, #cppTests do -- 896
						local _des_0 = cppTests[_index_0] -- 896
						local name = _des_0[1] -- 896
						if match(name) then -- 897
							showTest = true -- 897
						end -- 897
					end -- 897
					if not (showGame or showExample or showTest) then -- 898
						goto endEntry -- 898
					end -- 898
					Columns(1, false) -- 899
					TextColored(themeColor, "Dora SSR:") -- 900
					SameLine() -- 901
					Text(zh and "开发示例" or "Development Showcase") -- 902
					Separator() -- 903
					local demoViewWith <const> = 400 -- 904
					if #games > 0 and showGame then -- 905
						local opened -- 906
						if (filterText ~= nil) then -- 906
							opened = showGame -- 906
						else -- 906
							opened = false -- 906
						end -- 906
						SetNextItemOpen(gameOpen) -- 907
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 908
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 909
							Columns(columns, false) -- 910
							for _index_0 = 1, #games do -- 911
								local game = games[_index_0] -- 911
								if not match(game[1]) then -- 912
									goto _continue_0 -- 912
								end -- 912
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 913
								if columns > 1 then -- 914
									if bannerFile then -- 915
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 916
										local displayWidth <const> = demoViewWith - 40 -- 917
										texHeight = displayWidth * texHeight / texWidth -- 918
										texWidth = displayWidth -- 919
										Text(gameName) -- 920
										PushID(fileName, function() -- 921
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 922
												return enterDemoEntry(game) -- 923
											end -- 922
										end) -- 921
									else -- 925
										PushID(fileName, function() -- 925
											if Button(gameName, Vec2(-1, 40)) then -- 926
												return enterDemoEntry(game) -- 927
											end -- 926
										end) -- 925
									end -- 915
								else -- 929
									if bannerFile then -- 929
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 930
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 931
										local sizing = 0.8 -- 932
										texHeight = displayWidth * sizing * texHeight / texWidth -- 933
										texWidth = displayWidth * sizing -- 934
										if texWidth > 500 then -- 935
											sizing = 0.6 -- 936
											texHeight = displayWidth * sizing * texHeight / texWidth -- 937
											texWidth = displayWidth * sizing -- 938
										end -- 935
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 939
										Dummy(Vec2(padding, 0)) -- 940
										SameLine() -- 941
										Text(gameName) -- 942
										Dummy(Vec2(padding, 0)) -- 943
										SameLine() -- 944
										PushID(fileName, function() -- 945
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 946
												return enterDemoEntry(game) -- 947
											end -- 946
										end) -- 945
									else -- 949
										PushID(fileName, function() -- 949
											if Button(gameName, Vec2(-1, 40)) then -- 950
												return enterDemoEntry(game) -- 951
											end -- 950
										end) -- 949
									end -- 929
								end -- 914
								NextColumn() -- 952
								::_continue_0:: -- 912
							end -- 952
							Columns(1, false) -- 953
							opened = true -- 954
						end) -- 908
						gameOpen = opened -- 955
					end -- 905
					if #doraExamples > 0 and showExample then -- 956
						local opened -- 957
						if (filterText ~= nil) then -- 957
							opened = showExample -- 957
						else -- 957
							opened = false -- 957
						end -- 957
						SetNextItemOpen(exampleOpen) -- 958
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 959
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 960
								Columns(maxColumns, false) -- 961
								for _index_0 = 1, #doraExamples do -- 962
									local example = doraExamples[_index_0] -- 962
									if not match(example[1]) then -- 963
										goto _continue_0 -- 963
									end -- 963
									if Button(example[1], Vec2(-1, 40)) then -- 964
										enterDemoEntry(example) -- 965
									end -- 964
									NextColumn() -- 966
									::_continue_0:: -- 963
								end -- 966
								Columns(1, false) -- 967
								opened = true -- 968
							end) -- 960
						end) -- 959
						exampleOpen = opened -- 969
					end -- 956
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 970
						local opened -- 971
						if (filterText ~= nil) then -- 971
							opened = showTest -- 971
						else -- 971
							opened = false -- 971
						end -- 971
						SetNextItemOpen(testOpen) -- 972
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 973
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 974
								Columns(maxColumns, false) -- 975
								for _index_0 = 1, #doraTests do -- 976
									local test = doraTests[_index_0] -- 976
									if not match(test[1]) then -- 977
										goto _continue_0 -- 977
									end -- 977
									if Button(test[1], Vec2(-1, 40)) then -- 978
										enterDemoEntry(test) -- 979
									end -- 978
									NextColumn() -- 980
									::_continue_0:: -- 977
								end -- 980
								for _index_0 = 1, #cppTests do -- 981
									local test = cppTests[_index_0] -- 981
									if not match(test[1]) then -- 982
										goto _continue_1 -- 982
									end -- 982
									if Button(test[1], Vec2(-1, 40)) then -- 983
										enterDemoEntry(test) -- 984
									end -- 983
									NextColumn() -- 985
									::_continue_1:: -- 982
								end -- 985
								opened = true -- 986
							end) -- 974
						end) -- 973
						testOpen = opened -- 987
					end -- 970
				end -- 886
				::endEntry:: -- 988
				if not anyEntryMatched then -- 989
					SetNextWindowBgAlpha(0) -- 990
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 991
					Begin("Entries Not Found", displayWindowFlags, function() -- 992
						Separator() -- 993
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 994
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 995
						return Separator() -- 996
					end) -- 992
				end -- 989
				Columns(1, false) -- 997
				Dummy(Vec2(100, 80)) -- 998
				return ScrollWhenDraggingOnVoid() -- 999
			end) -- 999
		end) -- 999
	end) -- 999
end) -- 751
webStatus = require("WebServer") -- 1001
return _module_0 -- 1001
