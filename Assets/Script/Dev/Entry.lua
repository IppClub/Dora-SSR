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
end -- 148
_module_0.getConfig = function() -- 153
	return config -- 153
end -- 153
_module_0.getEngineDev = function() -- 154
	if not App.debugging then -- 155
		return false -- 155
	end -- 155
	return config.engineDev > 0 -- 156
end -- 154
local Set, Struct, LintYueGlobals, GSplit -- 158
do -- 158
	local _obj_0 = require("Utils") -- 158
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 158
end -- 158
local yueext = yue.options.extension -- 159
local isChineseSupported = IsFontLoaded() -- 161
if not isChineseSupported then -- 162
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 163
		isChineseSupported = true -- 164
	end) -- 163
end -- 162
local building = false -- 166
local getAllFiles -- 168
getAllFiles = function(path, exts) -- 168
	local filters = Set(exts) -- 169
	local _accum_0 = { } -- 170
	local _len_0 = 1 -- 170
	local _list_0 = Content:getAllFiles(path) -- 170
	for _index_0 = 1, #_list_0 do -- 170
		local file = _list_0[_index_0] -- 170
		if not filters[Path:getExt(file)] then -- 171
			goto _continue_0 -- 171
		end -- 171
		_accum_0[_len_0] = file -- 172
		_len_0 = _len_0 + 1 -- 172
		::_continue_0:: -- 171
	end -- 172
	return _accum_0 -- 172
end -- 168
local getFileEntries -- 174
getFileEntries = function(path) -- 174
	local entries = { } -- 175
	local _list_0 = getAllFiles(path, { -- 176
		"lua", -- 176
		"xml", -- 176
		yueext, -- 176
		"tl" -- 176
	}) -- 176
	for _index_0 = 1, #_list_0 do -- 176
		local file = _list_0[_index_0] -- 176
		local entryName = Path:getName(file) -- 177
		local entryAdded = false -- 178
		for _index_1 = 1, #entries do -- 179
			local _des_0 = entries[_index_1] -- 179
			local ename = _des_0[1] -- 179
			if entryName == ename then -- 180
				entryAdded = true -- 181
				break -- 182
			end -- 180
		end -- 182
		if entryAdded then -- 183
			goto _continue_0 -- 183
		end -- 183
		local fileName = Path:replaceExt(file, "") -- 184
		fileName = Path(path, fileName) -- 185
		local entry = { -- 186
			entryName, -- 186
			fileName -- 186
		} -- 186
		entries[#entries + 1] = entry -- 187
		::_continue_0:: -- 177
	end -- 187
	table.sort(entries, function(a, b) -- 188
		return a[1] < b[1] -- 188
	end) -- 188
	return entries -- 189
end -- 174
local getProjectEntries -- 191
getProjectEntries = function(path) -- 191
	local entries = { } -- 192
	local _list_0 = Content:getDirs(path) -- 193
	for _index_0 = 1, #_list_0 do -- 193
		local dir = _list_0[_index_0] -- 193
		if dir:match("^%.") then -- 194
			goto _continue_0 -- 194
		end -- 194
		local _list_1 = getAllFiles(Path(path, dir), { -- 195
			"lua", -- 195
			"xml", -- 195
			yueext, -- 195
			"tl", -- 195
			"wasm" -- 195
		}) -- 195
		for _index_1 = 1, #_list_1 do -- 195
			local file = _list_1[_index_1] -- 195
			if "init" == Path:getName(file):lower() then -- 196
				local fileName = Path:replaceExt(file, "") -- 197
				fileName = Path(path, dir, fileName) -- 198
				local entryName = Path:getName(Path:getPath(fileName)) -- 199
				local entryAdded = false -- 200
				for _index_2 = 1, #entries do -- 201
					local _des_0 = entries[_index_2] -- 201
					local ename = _des_0[1] -- 201
					if entryName == ename then -- 202
						entryAdded = true -- 203
						break -- 204
					end -- 202
				end -- 204
				if entryAdded then -- 205
					goto _continue_1 -- 205
				end -- 205
				local examples = { } -- 206
				local tests = { } -- 207
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 208
				if Content:exist(examplePath) then -- 209
					local _list_2 = getFileEntries(examplePath) -- 210
					for _index_2 = 1, #_list_2 do -- 210
						local _des_0 = _list_2[_index_2] -- 210
						local name, ePath = _des_0[1], _des_0[2] -- 210
						local entry = { -- 211
							name, -- 211
							Path(path, dir, Path:getPath(file), ePath) -- 211
						} -- 211
						examples[#examples + 1] = entry -- 212
					end -- 212
				end -- 209
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 213
				if Content:exist(testPath) then -- 214
					local _list_2 = getFileEntries(testPath) -- 215
					for _index_2 = 1, #_list_2 do -- 215
						local _des_0 = _list_2[_index_2] -- 215
						local name, tPath = _des_0[1], _des_0[2] -- 215
						local entry = { -- 216
							name, -- 216
							Path(path, dir, Path:getPath(file), tPath) -- 216
						} -- 216
						tests[#tests + 1] = entry -- 217
					end -- 217
				end -- 214
				local entry = { -- 218
					entryName, -- 218
					fileName, -- 218
					examples, -- 218
					tests -- 218
				} -- 218
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 219
				if not Content:exist(bannerFile) then -- 220
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 221
					if not Content:exist(bannerFile) then -- 222
						bannerFile = nil -- 222
					end -- 222
				end -- 220
				if bannerFile then -- 223
					thread(function() -- 223
						Cache:loadAsync(bannerFile) -- 224
						local bannerTex = Texture2D(bannerFile) -- 225
						if bannerTex then -- 226
							entry[#entry + 1] = bannerFile -- 227
							entry[#entry + 1] = bannerTex -- 228
						end -- 226
					end) -- 223
				end -- 223
				entries[#entries + 1] = entry -- 229
			end -- 196
			::_continue_1:: -- 196
		end -- 229
		::_continue_0:: -- 194
	end -- 229
	table.sort(entries, function(a, b) -- 230
		return a[1] < b[1] -- 230
	end) -- 230
	return entries -- 231
end -- 191
local gamesInDev, games -- 233
local doraExamples, doraTests -- 234
local cppTests, cppTestSet -- 235
local allEntries -- 236
local updateEntries -- 238
updateEntries = function() -- 238
	gamesInDev = getProjectEntries(Content.writablePath) -- 239
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 240
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 242
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 243
	cppTests = { } -- 245
	local _list_0 = App.testNames -- 246
	for _index_0 = 1, #_list_0 do -- 246
		local name = _list_0[_index_0] -- 246
		local entry = { -- 247
			name -- 247
		} -- 247
		cppTests[#cppTests + 1] = entry -- 248
	end -- 248
	cppTestSet = Set(cppTests) -- 249
	allEntries = { } -- 251
	for _index_0 = 1, #gamesInDev do -- 252
		local game = gamesInDev[_index_0] -- 252
		allEntries[#allEntries + 1] = game -- 253
		local examples, tests = game[3], game[4] -- 254
		for _index_1 = 1, #examples do -- 255
			local example = examples[_index_1] -- 255
			allEntries[#allEntries + 1] = example -- 256
		end -- 256
		for _index_1 = 1, #tests do -- 257
			local test = tests[_index_1] -- 257
			allEntries[#allEntries + 1] = test -- 258
		end -- 258
	end -- 258
	for _index_0 = 1, #games do -- 259
		local game = games[_index_0] -- 259
		allEntries[#allEntries + 1] = game -- 260
		local examples, tests = game[3], game[4] -- 261
		for _index_1 = 1, #examples do -- 262
			local example = examples[_index_1] -- 262
			doraExamples[#doraExamples + 1] = example -- 263
		end -- 263
		for _index_1 = 1, #tests do -- 264
			local test = tests[_index_1] -- 264
			doraTests[#doraTests + 1] = test -- 265
		end -- 265
	end -- 265
	local _list_1 = { -- 267
		doraExamples, -- 267
		doraTests, -- 268
		cppTests -- 269
	} -- 266
	for _index_0 = 1, #_list_1 do -- 270
		local group = _list_1[_index_0] -- 266
		for _index_1 = 1, #group do -- 271
			local entry = group[_index_1] -- 271
			allEntries[#allEntries + 1] = entry -- 272
		end -- 272
	end -- 272
end -- 238
updateEntries() -- 274
local doCompile -- 276
doCompile = function(minify) -- 276
	if building then -- 277
		return -- 277
	end -- 277
	building = true -- 278
	local startTime = App.runningTime -- 279
	local luaFiles = { } -- 280
	local yueFiles = { } -- 281
	local xmlFiles = { } -- 282
	local tlFiles = { } -- 283
	local writablePath = Content.writablePath -- 284
	local buildPaths = { -- 286
		{ -- 287
			Path(Content.assetPath), -- 287
			Path(writablePath, ".build"), -- 288
			"" -- 289
		} -- 286
	} -- 285
	for _index_0 = 1, #gamesInDev do -- 292
		local _des_0 = gamesInDev[_index_0] -- 292
		local entryFile = _des_0[2] -- 292
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 293
		buildPaths[#buildPaths + 1] = { -- 295
			Path(writablePath, gamePath), -- 295
			Path(writablePath, ".build", gamePath), -- 296
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 297
			gamePath -- 298
		} -- 294
	end -- 298
	for _index_0 = 1, #buildPaths do -- 299
		local _des_0 = buildPaths[_index_0] -- 299
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 299
		if not Content:exist(inputPath) then -- 300
			goto _continue_0 -- 300
		end -- 300
		local _list_0 = getAllFiles(inputPath, { -- 302
			"lua" -- 302
		}) -- 302
		for _index_1 = 1, #_list_0 do -- 302
			local file = _list_0[_index_1] -- 302
			luaFiles[#luaFiles + 1] = { -- 304
				file, -- 304
				Path(inputPath, file), -- 305
				Path(outputPath, file), -- 306
				gamePath -- 307
			} -- 303
		end -- 307
		local _list_1 = getAllFiles(inputPath, { -- 309
			yueext -- 309
		}) -- 309
		for _index_1 = 1, #_list_1 do -- 309
			local file = _list_1[_index_1] -- 309
			yueFiles[#yueFiles + 1] = { -- 311
				file, -- 311
				Path(inputPath, file), -- 312
				Path(outputPath, Path:replaceExt(file, "lua")), -- 313
				searchPath, -- 314
				gamePath -- 315
			} -- 310
		end -- 315
		local _list_2 = getAllFiles(inputPath, { -- 317
			"xml" -- 317
		}) -- 317
		for _index_1 = 1, #_list_2 do -- 317
			local file = _list_2[_index_1] -- 317
			xmlFiles[#xmlFiles + 1] = { -- 319
				file, -- 319
				Path(inputPath, file), -- 320
				Path(outputPath, Path:replaceExt(file, "lua")), -- 321
				gamePath -- 322
			} -- 318
		end -- 322
		local _list_3 = getAllFiles(inputPath, { -- 324
			"tl" -- 324
		}) -- 324
		for _index_1 = 1, #_list_3 do -- 324
			local file = _list_3[_index_1] -- 324
			if not file:match(".*%.d%.tl$") then -- 325
				tlFiles[#tlFiles + 1] = { -- 327
					file, -- 327
					Path(inputPath, file), -- 328
					Path(outputPath, Path:replaceExt(file, "lua")), -- 329
					searchPath, -- 330
					gamePath -- 331
				} -- 326
			end -- 325
		end -- 331
		::_continue_0:: -- 300
	end -- 331
	local paths -- 333
	do -- 333
		local _tbl_0 = { } -- 333
		local _list_0 = { -- 334
			luaFiles, -- 334
			yueFiles, -- 334
			xmlFiles, -- 334
			tlFiles -- 334
		} -- 334
		for _index_0 = 1, #_list_0 do -- 334
			local files = _list_0[_index_0] -- 334
			for _index_1 = 1, #files do -- 335
				local file = files[_index_1] -- 335
				_tbl_0[Path:getPath(file[3])] = true -- 333
			end -- 333
		end -- 333
		paths = _tbl_0 -- 333
	end -- 335
	for path in pairs(paths) do -- 337
		Content:mkdir(path) -- 337
	end -- 337
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 339
	local fileCount = 0 -- 340
	local errors = { } -- 341
	for _index_0 = 1, #yueFiles do -- 342
		local _des_0 = yueFiles[_index_0] -- 342
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 342
		local filename -- 343
		if gamePath then -- 343
			filename = Path(gamePath, file) -- 343
		else -- 343
			filename = file -- 343
		end -- 343
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 344
			if not codes then -- 345
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 346
				return -- 347
			end -- 345
			local success, result = LintYueGlobals(codes, globals) -- 348
			if success then -- 349
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 350
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 351
				codes = codes:gsub("^\n*", "") -- 352
				if not (result == "") then -- 353
					result = result .. "\n" -- 353
				end -- 353
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 354
			else -- 356
				local yueCodes = Content:load(input) -- 356
				if yueCodes then -- 356
					local globalErrors = { } -- 357
					for _index_1 = 1, #result do -- 358
						local _des_1 = result[_index_1] -- 358
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 358
						local countLine = 1 -- 359
						local code = "" -- 360
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 361
							if countLine == line then -- 362
								code = lineCode -- 363
								break -- 364
							end -- 362
							countLine = countLine + 1 -- 365
						end -- 365
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 366
					end -- 366
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 367
				else -- 369
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 369
				end -- 356
			end -- 349
		end, function(success) -- 344
			if success then -- 370
				print("Yue compiled: " .. tostring(filename)) -- 370
			end -- 370
			fileCount = fileCount + 1 -- 371
		end) -- 344
	end -- 371
	thread(function() -- 373
		for _index_0 = 1, #xmlFiles do -- 374
			local _des_0 = xmlFiles[_index_0] -- 374
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 374
			local filename -- 375
			if gamePath then -- 375
				filename = Path(gamePath, file) -- 375
			else -- 375
				filename = file -- 375
			end -- 375
			local sourceCodes = Content:loadAsync(input) -- 376
			local codes, err = xml.tolua(sourceCodes) -- 377
			if not codes then -- 378
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 379
			else -- 381
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 381
				print("Xml compiled: " .. tostring(filename)) -- 382
			end -- 378
			fileCount = fileCount + 1 -- 383
		end -- 383
	end) -- 373
	thread(function() -- 385
		for _index_0 = 1, #tlFiles do -- 386
			local _des_0 = tlFiles[_index_0] -- 386
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 386
			local filename -- 387
			if gamePath then -- 387
				filename = Path(gamePath, file) -- 387
			else -- 387
				filename = file -- 387
			end -- 387
			local sourceCodes = Content:loadAsync(input) -- 388
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 389
			if not codes then -- 390
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 391
			else -- 393
				Content:saveAsync(output, codes) -- 393
				print("Teal compiled: " .. tostring(filename)) -- 394
			end -- 390
			fileCount = fileCount + 1 -- 395
		end -- 395
	end) -- 385
	return thread(function() -- 397
		wait(function() -- 398
			return fileCount == totalFiles -- 398
		end) -- 398
		if minify then -- 399
			local _list_0 = { -- 400
				yueFiles, -- 400
				xmlFiles, -- 400
				tlFiles -- 400
			} -- 400
			for _index_0 = 1, #_list_0 do -- 400
				local files = _list_0[_index_0] -- 400
				for _index_1 = 1, #files do -- 400
					local file = files[_index_1] -- 400
					local output = Path:replaceExt(file[3], "lua") -- 401
					luaFiles[#luaFiles + 1] = { -- 403
						Path:replaceExt(file[1], "lua"), -- 403
						output, -- 404
						output -- 405
					} -- 402
				end -- 405
			end -- 405
			local FormatMini -- 407
			do -- 407
				local _obj_0 = require("luaminify") -- 407
				FormatMini = _obj_0.FormatMini -- 407
			end -- 407
			for _index_0 = 1, #luaFiles do -- 408
				local _des_0 = luaFiles[_index_0] -- 408
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 408
				if Content:exist(input) then -- 409
					local sourceCodes = Content:loadAsync(input) -- 410
					local res, err = FormatMini(sourceCodes) -- 411
					if res then -- 412
						Content:saveAsync(output, res) -- 413
						print("Minify: " .. tostring(file)) -- 414
					else -- 416
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 416
					end -- 412
				else -- 418
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 418
				end -- 409
			end -- 418
			package.loaded["luaminify.FormatMini"] = nil -- 419
			package.loaded["luaminify.ParseLua"] = nil -- 420
			package.loaded["luaminify.Scope"] = nil -- 421
			package.loaded["luaminify.Util"] = nil -- 422
		end -- 399
		local errorMessage = table.concat(errors, "\n") -- 423
		if errorMessage ~= "" then -- 424
			print("\n" .. errorMessage) -- 424
		end -- 424
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 425
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 426
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 427
		Content:clearPathCache() -- 428
		teal.clear() -- 429
		yue.clear() -- 430
		building = false -- 431
	end) -- 431
end -- 276
local doClean -- 433
doClean = function() -- 433
	if building then -- 434
		return -- 434
	end -- 434
	local writablePath = Content.writablePath -- 435
	local targetDir = Path(writablePath, ".build") -- 436
	Content:clearPathCache() -- 437
	if Content:remove(targetDir) then -- 438
		print("Cleaned: " .. tostring(targetDir)) -- 439
	end -- 438
	Content:remove(Path(writablePath, ".upload")) -- 440
	return Content:remove(Path(writablePath, ".download")) -- 441
end -- 433
local screenScale = 2.0 -- 443
local scaleContent = false -- 444
local isInEntry = true -- 445
local currentEntry = nil -- 446
local footerWindow = nil -- 448
local entryWindow = nil -- 449
local setupEventHandlers = nil -- 451
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
	Audio:stopStream(0.5) -- 468
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
setupEventHandlers = function() -- 484
	local _with_0 = Director.postNode -- 485
	_with_0:gslot("AppQuit", allClear) -- 486
	_with_0:gslot("AppTheme", function(argb) -- 487
		config.themeColor = argb -- 488
	end) -- 487
	_with_0:gslot("AppLocale", function(locale) -- 489
		config.locale = locale -- 490
		updateLocale() -- 491
		return teal.clear(true) -- 492
	end) -- 489
	_with_0:gslot("AppWSClose", function() -- 493
		if HttpServer.wsConnectionCount == 0 then -- 494
			return updateEntries() -- 495
		end -- 494
	end) -- 493
	local _exp_0 = App.platform -- 496
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 496
		_with_0:gslot("AppSizeChanged", function() -- 497
			local width, height -- 498
			do -- 498
				local _obj_0 = App.winSize -- 498
				width, height = _obj_0.width, _obj_0.height -- 498
			end -- 498
			config.winWidth = width -- 499
			config.winHeight = height -- 500
		end) -- 497
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 501
			config.fullScreen = fullScreen and 1 or 0 -- 502
		end) -- 501
		_with_0:gslot("AppMoved", function() -- 503
			local _obj_0 = App.winPosition -- 504
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 504
		end) -- 503
	end -- 504
	return _with_0 -- 485
end -- 484
setupEventHandlers() -- 506
local stop -- 508
stop = function() -- 508
	if isInEntry then -- 509
		return false -- 509
	end -- 509
	allClear() -- 510
	isInEntry = true -- 511
	currentEntry = nil -- 512
	return true -- 513
end -- 508
_module_0["stop"] = stop -- 513
local _anon_func_0 = function(Content, Path, file, require, type) -- 535
	local scriptPath = Path:getPath(file) -- 528
	Content:insertSearchPath(1, scriptPath) -- 529
	scriptPath = Path(scriptPath, "Script") -- 530
	if Content:exist(scriptPath) then -- 531
		Content:insertSearchPath(1, scriptPath) -- 532
	end -- 531
	local result = require(file) -- 533
	if "function" == type(result) then -- 534
		result() -- 534
	end -- 534
	return nil -- 535
end -- 528
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 567
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 564
	label.alignment = "Left" -- 565
	label.textWidth = width - fontSize -- 566
	label.text = err -- 567
	return label -- 564
end -- 564
local enterEntryAsync -- 515
enterEntryAsync = function(entry) -- 515
	isInEntry = false -- 516
	App.idled = false -- 517
	emit(Profiler.EventName, "ClearLoader") -- 518
	currentEntry = entry -- 519
	local name, file = entry[1], entry[2] -- 520
	if cppTestSet[entry] then -- 521
		if App:runTest(name) then -- 522
			return true -- 523
		else -- 525
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 525
		end -- 522
	end -- 521
	sleep() -- 526
	return xpcall(_anon_func_0, function(msg) -- 535
		local err = debug.traceback(msg) -- 537
		allClear() -- 538
		print(err) -- 539
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 540
		local viewWidth, viewHeight -- 541
		do -- 541
			local _obj_0 = View.size -- 541
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 541
		end -- 541
		local width, height = viewWidth - 20, viewHeight - 20 -- 542
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 543
		Director.ui:addChild((function() -- 544
			local root = AlignNode() -- 544
			do -- 545
				local _obj_0 = App.bufferSize -- 545
				width, height = _obj_0.width, _obj_0.height -- 545
			end -- 545
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 546
			root:gslot("AppSizeChanged", function() -- 547
				do -- 548
					local _obj_0 = App.bufferSize -- 548
					width, height = _obj_0.width, _obj_0.height -- 548
				end -- 548
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 549
			end) -- 547
			root:addChild((function() -- 550
				local _with_0 = ScrollArea({ -- 551
					width = width, -- 551
					height = height, -- 552
					paddingX = 0, -- 553
					paddingY = 50, -- 554
					viewWidth = height, -- 555
					viewHeight = height -- 556
				}) -- 550
				root:slot("AlignLayout", function(w, h) -- 558
					_with_0.position = Vec2(w / 2, h / 2) -- 559
					w = w - 20 -- 560
					h = h - 20 -- 561
					_with_0.view.children.first.textWidth = w - fontSize -- 562
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 563
				end) -- 558
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 564
				return _with_0 -- 550
			end)()) -- 550
			return root -- 544
		end)()) -- 544
		return err -- 568
	end, Content, Path, file, require, type) -- 568
end -- 515
_module_0["enterEntryAsync"] = enterEntryAsync -- 568
local enterDemoEntry -- 570
enterDemoEntry = function(entry) -- 570
	return thread(function() -- 570
		return enterEntryAsync(entry) -- 570
	end) -- 570
end -- 570
local reloadCurrentEntry -- 572
reloadCurrentEntry = function() -- 572
	if currentEntry then -- 573
		allClear() -- 574
		return enterDemoEntry(currentEntry) -- 575
	end -- 573
end -- 572
Director.clearColor = Color(0xff1a1a1a) -- 577
local waitForWebStart = true -- 579
thread(function() -- 580
	sleep(2) -- 581
	waitForWebStart = false -- 582
end) -- 580
local reloadDevEntry -- 584
reloadDevEntry = function() -- 584
	return thread(function() -- 584
		waitForWebStart = true -- 585
		doClean() -- 586
		allClear() -- 587
		_G.require = oldRequire -- 588
		Dora.require = oldRequire -- 589
		package.loaded["Script.Dev.Entry"] = nil -- 590
		return Director.systemScheduler:schedule(function() -- 591
			Routine:clear() -- 592
			oldRequire("Script.Dev.Entry") -- 593
			return true -- 594
		end) -- 594
	end) -- 594
end -- 584
local isOSSLicenseExist = Content:exist("LICENSES") -- 596
local ossLicenses = nil -- 597
local ossLicenseOpen = false -- 598
local extraOperations -- 600
extraOperations = function() -- 600
	local zh = useChinese and isChineseSupported -- 601
	if isOSSLicenseExist then -- 602
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 603
			if not ossLicenses then -- 604
				ossLicenses = { } -- 605
				local licenseText = Content:load("LICENSES") -- 606
				ossLicenseOpen = (licenseText ~= nil) -- 607
				if ossLicenseOpen then -- 607
					licenseText = licenseText:gsub("\r\n", "\n") -- 608
					for license in GSplit(licenseText, "\n--------\n", true) do -- 609
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 610
						if name then -- 610
							ossLicenses[#ossLicenses + 1] = { -- 611
								name, -- 611
								text -- 611
							} -- 611
						end -- 610
					end -- 611
				end -- 607
			else -- 613
				ossLicenseOpen = true -- 613
			end -- 604
		end -- 603
		if ossLicenseOpen then -- 614
			local width, height, themeColor -- 615
			do -- 615
				local _obj_0 = App -- 615
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 615
			end -- 615
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 616
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 617
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 618
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 621
					"NoSavedSettings" -- 621
				}, function() -- 622
					for _index_0 = 1, #ossLicenses do -- 622
						local _des_0 = ossLicenses[_index_0] -- 622
						local firstLine, text = _des_0[1], _des_0[2] -- 622
						local name, license = firstLine:match("(.+): (.+)") -- 623
						TextColored(themeColor, name) -- 624
						SameLine() -- 625
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 626
							return TextWrapped(text) -- 626
						end) -- 626
					end -- 626
				end) -- 618
			end) -- 618
		end -- 614
	end -- 602
	if not App.debugging then -- 628
		return -- 628
	end -- 628
	return TreeNode(zh and "开发操作" or "Development", function() -- 629
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 630
			OpenPopup("build") -- 630
		end -- 630
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 631
			return BeginPopup("build", function() -- 631
				if Selectable(zh and "编译" or "Compile") then -- 632
					doCompile(false) -- 632
				end -- 632
				Separator() -- 633
				if Selectable(zh and "压缩" or "Minify") then -- 634
					doCompile(true) -- 634
				end -- 634
				Separator() -- 635
				if Selectable(zh and "清理" or "Clean") then -- 636
					return doClean() -- 636
				end -- 636
			end) -- 636
		end) -- 631
		if isInEntry then -- 637
			if waitForWebStart then -- 638
				BeginDisabled(function() -- 639
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 639
				end) -- 639
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 640
				reloadDevEntry() -- 641
			end -- 638
		end -- 637
		do -- 642
			local changed -- 642
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 642
			if changed then -- 642
				View.scale = scaleContent and screenScale or 1 -- 643
			end -- 642
		end -- 642
		local changed -- 644
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 644
		if changed then -- 644
			config.engineDev = engineDev and 1 or 0 -- 645
		end -- 644
	end) -- 629
end -- 600
local transparant = Color(0x0) -- 647
local windowFlags = { -- 649
	"NoTitleBar", -- 649
	"NoResize", -- 650
	"NoMove", -- 651
	"NoCollapse", -- 652
	"NoSavedSettings", -- 653
	"NoBringToFrontOnFocus" -- 654
} -- 648
local initFooter = true -- 655
local _anon_func_2 = function(allEntries, currentIndex) -- 691
	if currentIndex > 1 then -- 691
		return allEntries[currentIndex - 1] -- 692
	else -- 694
		return allEntries[#allEntries] -- 694
	end -- 691
end -- 691
local _anon_func_3 = function(allEntries, currentIndex) -- 698
	if currentIndex < #allEntries then -- 698
		return allEntries[currentIndex + 1] -- 699
	else -- 701
		return allEntries[1] -- 701
	end -- 698
end -- 698
footerWindow = threadLoop(function() -- 656
	local zh = useChinese and isChineseSupported -- 657
	if HttpServer.wsConnectionCount > 0 then -- 658
		return -- 659
	end -- 658
	if Keyboard:isKeyDown("Escape") then -- 660
		allClear() -- 661
		App:shutdown() -- 662
	end -- 660
	do -- 663
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 664
		if ctrl and Keyboard:isKeyDown("Q") then -- 665
			stop() -- 666
		end -- 665
		if ctrl and Keyboard:isKeyDown("Z") then -- 667
			reloadCurrentEntry() -- 668
		end -- 667
		if ctrl and Keyboard:isKeyDown(",") then -- 669
			if showFooter then -- 670
				showStats = not showStats -- 670
			else -- 670
				showStats = true -- 670
			end -- 670
			showFooter = true -- 671
			config.showFooter = showFooter and 1 or 0 -- 672
			config.showStats = showStats and 1 or 0 -- 673
		end -- 669
		if ctrl and Keyboard:isKeyDown(".") then -- 674
			if showFooter then -- 675
				showConsole = not showConsole -- 675
			else -- 675
				showConsole = true -- 675
			end -- 675
			showFooter = true -- 676
			config.showFooter = showFooter and 1 or 0 -- 677
			config.showConsole = showConsole and 1 or 0 -- 678
		end -- 674
		if ctrl and Keyboard:isKeyDown("/") then -- 679
			showFooter = not showFooter -- 680
			config.showFooter = showFooter and 1 or 0 -- 681
		end -- 679
		local left = ctrl and Keyboard:isKeyDown("Left") -- 682
		local right = ctrl and Keyboard:isKeyDown("Right") -- 683
		local currentIndex = nil -- 684
		for i, entry in ipairs(allEntries) do -- 685
			if currentEntry == entry then -- 686
				currentIndex = i -- 687
			end -- 686
		end -- 687
		if left then -- 688
			allClear() -- 689
			if currentIndex == nil then -- 690
				currentIndex = #allEntries + 1 -- 690
			end -- 690
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 691
		end -- 688
		if right then -- 695
			allClear() -- 696
			if currentIndex == nil then -- 697
				currentIndex = 0 -- 697
			end -- 697
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 698
		end -- 695
	end -- 701
	if not showEntry then -- 702
		return -- 702
	end -- 702
	local width, height -- 704
	do -- 704
		local _obj_0 = App.visualSize -- 704
		width, height = _obj_0.width, _obj_0.height -- 704
	end -- 704
	SetNextWindowSize(Vec2(50, 50)) -- 705
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 706
	PushStyleColor("WindowBg", transparant, function() -- 707
		return Begin("Show", windowFlags, function() -- 707
			if isInEntry or width >= 540 then -- 708
				local changed -- 709
				changed, showFooter = Checkbox("##dev", showFooter) -- 709
				if changed then -- 709
					config.showFooter = showFooter and 1 or 0 -- 710
				end -- 709
			end -- 708
		end) -- 710
	end) -- 707
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 712
		reloadDevEntry() -- 716
	end -- 712
	if initFooter then -- 717
		initFooter = false -- 718
	else -- 720
		if not showFooter then -- 720
			return -- 720
		end -- 720
	end -- 717
	SetNextWindowSize(Vec2(width, 50)) -- 722
	SetNextWindowPos(Vec2(0, height - 50)) -- 723
	SetNextWindowBgAlpha(0.35) -- 724
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 725
		return Begin("Footer", windowFlags, function() -- 725
			Dummy(Vec2(width - 20, 0)) -- 726
			do -- 727
				local changed -- 727
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 727
				if changed then -- 727
					config.showStats = showStats and 1 or 0 -- 728
				end -- 727
			end -- 727
			SameLine() -- 729
			do -- 730
				local changed -- 730
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 730
				if changed then -- 730
					config.showConsole = showConsole and 1 or 0 -- 731
				end -- 730
			end -- 730
			if not isInEntry then -- 732
				SameLine() -- 733
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 734
					allClear() -- 735
					isInEntry = true -- 736
					currentEntry = nil -- 737
				end -- 734
				local currentIndex = nil -- 738
				for i, entry in ipairs(allEntries) do -- 739
					if currentEntry == entry then -- 740
						currentIndex = i -- 741
					end -- 740
				end -- 741
				if currentIndex then -- 742
					if currentIndex > 1 then -- 743
						SameLine() -- 744
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 745
							allClear() -- 746
							enterDemoEntry(allEntries[currentIndex - 1]) -- 747
						end -- 745
					end -- 743
					if currentIndex < #allEntries then -- 748
						SameLine() -- 749
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 750
							allClear() -- 751
							enterDemoEntry(allEntries[currentIndex + 1]) -- 752
						end -- 750
					end -- 748
				end -- 742
				SameLine() -- 753
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 754
					reloadCurrentEntry() -- 755
				end -- 754
			end -- 732
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 756
				if showStats then -- 757
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 758
					showStats = ShowStats(showStats, extraOperations) -- 759
					config.showStats = showStats and 1 or 0 -- 760
				end -- 757
				if showConsole then -- 761
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 762
					showConsole = ShowConsole(showConsole) -- 763
					config.showConsole = showConsole and 1 or 0 -- 764
				end -- 761
			end) -- 764
		end) -- 764
	end) -- 764
end) -- 656
local MaxWidth <const> = 800 -- 766
local displayWindowFlags = { -- 769
	"NoDecoration", -- 769
	"NoSavedSettings", -- 770
	"NoFocusOnAppearing", -- 771
	"NoNav", -- 772
	"NoMove", -- 773
	"NoScrollWithMouse", -- 774
	"AlwaysAutoResize", -- 775
	"NoBringToFrontOnFocus" -- 776
} -- 768
local webStatus = nil -- 778
local descColor = Color(0xffa1a1a1) -- 779
local gameOpen = #gamesInDev == 0 -- 780
local exampleOpen = false -- 781
local testOpen = false -- 782
local filterText = nil -- 783
local anyEntryMatched = false -- 784
local urlClicked = nil -- 785
local match -- 786
match = function(name) -- 786
	local res = not filterText or name:lower():match(filterText) -- 787
	if res then -- 788
		anyEntryMatched = true -- 788
	end -- 788
	return res -- 789
end -- 786
entryWindow = threadLoop(function() -- 791
	if App.fpsLimited ~= (config.fpsLimited == 1) then -- 792
		config.fpsLimited = App.fpsLimited and 1 or 0 -- 793
	end -- 792
	if App.targetFPS ~= config.targetFPS then -- 794
		config.targetFPS = App.targetFPS -- 795
	end -- 794
	if View.vsync ~= (config.vsync == 1) then -- 796
		config.vsync = View.vsync and 1 or 0 -- 797
	end -- 796
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 798
		config.fixedFPS = Director.scheduler.fixedFPS -- 799
	end -- 798
	if Director.profilerSending ~= (config.webProfiler == 1) then -- 800
		config.webProfiler = Director.profilerSending and 1 or 0 -- 801
	end -- 800
	if urlClicked then -- 802
		local _, result = coroutine.resume(urlClicked) -- 803
		if result then -- 804
			coroutine.close(urlClicked) -- 805
			urlClicked = nil -- 806
		end -- 804
	end -- 802
	if not showEntry then -- 807
		return -- 807
	end -- 807
	if not isInEntry then -- 808
		return -- 808
	end -- 808
	local zh = useChinese and isChineseSupported -- 809
	if HttpServer.wsConnectionCount > 0 then -- 810
		local themeColor = App.themeColor -- 811
		local width, height -- 812
		do -- 812
			local _obj_0 = App.visualSize -- 812
			width, height = _obj_0.width, _obj_0.height -- 812
		end -- 812
		SetNextWindowBgAlpha(0.5) -- 813
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 814
		Begin("Web IDE Connected", displayWindowFlags, function() -- 815
			Separator() -- 816
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 817
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 818
			TextColored(descColor, slogon) -- 819
			return Separator() -- 820
		end) -- 815
		return -- 821
	end -- 810
	local themeColor = App.themeColor -- 823
	local fullWidth, height -- 824
	do -- 824
		local _obj_0 = App.visualSize -- 824
		fullWidth, height = _obj_0.width, _obj_0.height -- 824
	end -- 824
	SetNextWindowBgAlpha(0.85) -- 826
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 827
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 828
		return Begin("Web IDE", displayWindowFlags, function() -- 829
			Separator() -- 830
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 831
			do -- 832
				local url -- 832
				if webStatus ~= nil then -- 832
					url = webStatus.url -- 832
				end -- 832
				if url then -- 832
					if isDesktop then -- 833
						if urlClicked then -- 834
							BeginDisabled(function() -- 835
								return Button(url) -- 835
							end) -- 835
						elseif Button(url) then -- 836
							urlClicked = once(function() -- 837
								return sleep(5) -- 837
							end) -- 837
							App:openURL(url) -- 838
						end -- 834
					else -- 840
						TextColored(descColor, url) -- 840
					end -- 833
				else -- 842
					TextColored(descColor, zh and '不可用' or 'not available') -- 842
				end -- 832
			end -- 832
			return Separator() -- 843
		end) -- 843
	end) -- 828
	local width = math.min(MaxWidth, fullWidth) -- 845
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 846
	local maxColumns = math.max(math.floor(width / 200), 1) -- 847
	SetNextWindowPos(Vec2.zero) -- 848
	SetNextWindowBgAlpha(0) -- 849
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 850
		return Begin("Dora Dev", displayWindowFlags, function() -- 851
			Dummy(Vec2(fullWidth - 20, 0)) -- 852
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 853
			SameLine() -- 854
			if fullWidth >= 320 then -- 855
				Dummy(Vec2(fullWidth - 320, 0)) -- 856
				SameLine() -- 857
				SetNextItemWidth(-50) -- 858
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 859
					"AutoSelectAll" -- 859
				}) then -- 859
					config.filter = filterBuf:toString() -- 860
				end -- 859
			end -- 855
			Separator() -- 861
			return Dummy(Vec2(fullWidth - 20, 0)) -- 862
		end) -- 862
	end) -- 850
	anyEntryMatched = false -- 864
	SetNextWindowPos(Vec2(0, 50)) -- 865
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 866
	return PushStyleColor("WindowBg", transparant, function() -- 867
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 867
			return Begin("Content", windowFlags, function() -- 868
				filterText = filterBuf:toString():match("[^%%%.%[]+") -- 869
				if filterText then -- 870
					filterText = filterText:lower() -- 870
				end -- 870
				if #gamesInDev > 0 then -- 871
					for _index_0 = 1, #gamesInDev do -- 872
						local game = gamesInDev[_index_0] -- 872
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 873
						local showSep = false -- 874
						if match(gameName) then -- 875
							Columns(1, false) -- 876
							TextColored(themeColor, zh and "项目：" or "Project:") -- 877
							SameLine() -- 878
							Text(gameName) -- 879
							Separator() -- 880
							if bannerFile then -- 881
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 882
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 883
								local sizing <const> = 0.8 -- 884
								texHeight = displayWidth * sizing * texHeight / texWidth -- 885
								texWidth = displayWidth * sizing -- 886
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 887
								Dummy(Vec2(padding, 0)) -- 888
								SameLine() -- 889
								PushID(fileName, function() -- 890
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 891
										return enterDemoEntry(game) -- 892
									end -- 891
								end) -- 890
							else -- 894
								PushID(fileName, function() -- 894
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 895
										return enterDemoEntry(game) -- 896
									end -- 895
								end) -- 894
							end -- 881
							NextColumn() -- 897
							showSep = true -- 898
						end -- 875
						if #examples > 0 then -- 899
							local showExample = false -- 900
							for _index_1 = 1, #examples do -- 901
								local example = examples[_index_1] -- 901
								if match(example[1]) then -- 902
									showExample = true -- 903
									break -- 904
								end -- 902
							end -- 904
							if showExample then -- 905
								Columns(1, false) -- 906
								TextColored(themeColor, zh and "示例：" or "Example:") -- 907
								SameLine() -- 908
								Text(gameName) -- 909
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 910
									Columns(maxColumns, false) -- 911
									for _index_1 = 1, #examples do -- 912
										local example = examples[_index_1] -- 912
										if not match(example[1]) then -- 913
											goto _continue_0 -- 913
										end -- 913
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 914
											if Button(example[1], Vec2(-1, 40)) then -- 915
												enterDemoEntry(example) -- 916
											end -- 915
											return NextColumn() -- 917
										end) -- 914
										showSep = true -- 918
										::_continue_0:: -- 913
									end -- 918
								end) -- 910
							end -- 905
						end -- 899
						if #tests > 0 then -- 919
							local showTest = false -- 920
							for _index_1 = 1, #tests do -- 921
								local test = tests[_index_1] -- 921
								if match(test[1]) then -- 922
									showTest = true -- 923
									break -- 924
								end -- 922
							end -- 924
							if showTest then -- 925
								Columns(1, false) -- 926
								TextColored(themeColor, zh and "测试：" or "Test:") -- 927
								SameLine() -- 928
								Text(gameName) -- 929
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 930
									Columns(maxColumns, false) -- 931
									for _index_1 = 1, #tests do -- 932
										local test = tests[_index_1] -- 932
										if not match(test[1]) then -- 933
											goto _continue_0 -- 933
										end -- 933
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 934
											if Button(test[1], Vec2(-1, 40)) then -- 935
												enterDemoEntry(test) -- 936
											end -- 935
											return NextColumn() -- 937
										end) -- 934
										showSep = true -- 938
										::_continue_0:: -- 933
									end -- 938
								end) -- 930
							end -- 925
						end -- 919
						if showSep then -- 939
							Columns(1, false) -- 940
							Separator() -- 941
						end -- 939
					end -- 941
				end -- 871
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 942
					local showGame = false -- 943
					for _index_0 = 1, #games do -- 944
						local _des_0 = games[_index_0] -- 944
						local name = _des_0[1] -- 944
						if match(name) then -- 945
							showGame = true -- 945
						end -- 945
					end -- 945
					local showExample = false -- 946
					for _index_0 = 1, #doraExamples do -- 947
						local _des_0 = doraExamples[_index_0] -- 947
						local name = _des_0[1] -- 947
						if match(name) then -- 948
							showExample = true -- 948
						end -- 948
					end -- 948
					local showTest = false -- 949
					for _index_0 = 1, #doraTests do -- 950
						local _des_0 = doraTests[_index_0] -- 950
						local name = _des_0[1] -- 950
						if match(name) then -- 951
							showTest = true -- 951
						end -- 951
					end -- 951
					for _index_0 = 1, #cppTests do -- 952
						local _des_0 = cppTests[_index_0] -- 952
						local name = _des_0[1] -- 952
						if match(name) then -- 953
							showTest = true -- 953
						end -- 953
					end -- 953
					if not (showGame or showExample or showTest) then -- 954
						goto endEntry -- 954
					end -- 954
					Columns(1, false) -- 955
					TextColored(themeColor, "Dora SSR:") -- 956
					SameLine() -- 957
					Text(zh and "开发示例" or "Development Showcase") -- 958
					Separator() -- 959
					local demoViewWith <const> = 400 -- 960
					if #games > 0 and showGame then -- 961
						local opened -- 962
						if (filterText ~= nil) then -- 962
							opened = showGame -- 962
						else -- 962
							opened = false -- 962
						end -- 962
						SetNextItemOpen(gameOpen) -- 963
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 964
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 965
							Columns(columns, false) -- 966
							for _index_0 = 1, #games do -- 967
								local game = games[_index_0] -- 967
								if not match(game[1]) then -- 968
									goto _continue_0 -- 968
								end -- 968
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 969
								if columns > 1 then -- 970
									if bannerFile then -- 971
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 972
										local displayWidth <const> = demoViewWith - 40 -- 973
										texHeight = displayWidth * texHeight / texWidth -- 974
										texWidth = displayWidth -- 975
										Text(gameName) -- 976
										PushID(fileName, function() -- 977
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 978
												return enterDemoEntry(game) -- 979
											end -- 978
										end) -- 977
									else -- 981
										PushID(fileName, function() -- 981
											if Button(gameName, Vec2(-1, 40)) then -- 982
												return enterDemoEntry(game) -- 983
											end -- 982
										end) -- 981
									end -- 971
								else -- 985
									if bannerFile then -- 985
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 986
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 987
										local sizing = 0.8 -- 988
										texHeight = displayWidth * sizing * texHeight / texWidth -- 989
										texWidth = displayWidth * sizing -- 990
										if texWidth > 500 then -- 991
											sizing = 0.6 -- 992
											texHeight = displayWidth * sizing * texHeight / texWidth -- 993
											texWidth = displayWidth * sizing -- 994
										end -- 991
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 995
										Dummy(Vec2(padding, 0)) -- 996
										SameLine() -- 997
										Text(gameName) -- 998
										Dummy(Vec2(padding, 0)) -- 999
										SameLine() -- 1000
										PushID(fileName, function() -- 1001
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1002
												return enterDemoEntry(game) -- 1003
											end -- 1002
										end) -- 1001
									else -- 1005
										PushID(fileName, function() -- 1005
											if Button(gameName, Vec2(-1, 40)) then -- 1006
												return enterDemoEntry(game) -- 1007
											end -- 1006
										end) -- 1005
									end -- 985
								end -- 970
								NextColumn() -- 1008
								::_continue_0:: -- 968
							end -- 1008
							Columns(1, false) -- 1009
							opened = true -- 1010
						end) -- 964
						gameOpen = opened -- 1011
					end -- 961
					if #doraExamples > 0 and showExample then -- 1012
						local opened -- 1013
						if (filterText ~= nil) then -- 1013
							opened = showExample -- 1013
						else -- 1013
							opened = false -- 1013
						end -- 1013
						SetNextItemOpen(exampleOpen) -- 1014
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1015
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1016
								Columns(maxColumns, false) -- 1017
								for _index_0 = 1, #doraExamples do -- 1018
									local example = doraExamples[_index_0] -- 1018
									if not match(example[1]) then -- 1019
										goto _continue_0 -- 1019
									end -- 1019
									if Button(example[1], Vec2(-1, 40)) then -- 1020
										enterDemoEntry(example) -- 1021
									end -- 1020
									NextColumn() -- 1022
									::_continue_0:: -- 1019
								end -- 1022
								Columns(1, false) -- 1023
								opened = true -- 1024
							end) -- 1016
						end) -- 1015
						exampleOpen = opened -- 1025
					end -- 1012
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1026
						local opened -- 1027
						if (filterText ~= nil) then -- 1027
							opened = showTest -- 1027
						else -- 1027
							opened = false -- 1027
						end -- 1027
						SetNextItemOpen(testOpen) -- 1028
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1029
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1030
								Columns(maxColumns, false) -- 1031
								for _index_0 = 1, #doraTests do -- 1032
									local test = doraTests[_index_0] -- 1032
									if not match(test[1]) then -- 1033
										goto _continue_0 -- 1033
									end -- 1033
									if Button(test[1], Vec2(-1, 40)) then -- 1034
										enterDemoEntry(test) -- 1035
									end -- 1034
									NextColumn() -- 1036
									::_continue_0:: -- 1033
								end -- 1036
								for _index_0 = 1, #cppTests do -- 1037
									local test = cppTests[_index_0] -- 1037
									if not match(test[1]) then -- 1038
										goto _continue_1 -- 1038
									end -- 1038
									if Button(test[1], Vec2(-1, 40)) then -- 1039
										enterDemoEntry(test) -- 1040
									end -- 1039
									NextColumn() -- 1041
									::_continue_1:: -- 1038
								end -- 1041
								opened = true -- 1042
							end) -- 1030
						end) -- 1029
						testOpen = opened -- 1043
					end -- 1026
				end -- 942
				::endEntry:: -- 1044
				if not anyEntryMatched then -- 1045
					SetNextWindowBgAlpha(0) -- 1046
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1047
					Begin("Entries Not Found", displayWindowFlags, function() -- 1048
						Separator() -- 1049
						TextColored(themeColor, zh and "多萝西：" or "Dora:") -- 1050
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1051
						return Separator() -- 1052
					end) -- 1048
				end -- 1045
				Columns(1, false) -- 1053
				Dummy(Vec2(100, 80)) -- 1054
				return ScrollWhenDraggingOnVoid() -- 1055
			end) -- 1055
		end) -- 1055
	end) -- 1055
end) -- 791
webStatus = require("Script.Dev.WebServer") -- 1057
return _module_0 -- 1057
