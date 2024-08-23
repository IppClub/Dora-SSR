-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local ShowConsole = _module_0.ShowConsole -- 1
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
local coroutine = _G.coroutine -- 1
local Image = _module_0.Image -- 1
local TextDisabled = _module_0.TextDisabled -- 1
local IsItemHovered = _module_0.IsItemHovered -- 1
local BeginTooltip = _module_0.BeginTooltip -- 1
local PushTextWrapPos = _module_0.PushTextWrapPos -- 1
local Text = _module_0.Text -- 1
local once = Dora.once -- 1
local SetNextItemWidth = _module_0.SetNextItemWidth -- 1
local InputText = _module_0.InputText -- 1
local Columns = _module_0.Columns -- 1
local PushID = _module_0.PushID -- 1
local ImageButton = _module_0.ImageButton -- 1
local NextColumn = _module_0.NextColumn -- 1
local SetNextItemOpen = _module_0.SetNextItemOpen -- 1
local ScrollWhenDraggingOnVoid = _module_0.ScrollWhenDraggingOnVoid -- 1
local _module_0 = { } -- 1
local Content, Path -- 11
do -- 11
	local _obj_0 = Dora -- 11
	Content, Path = _obj_0.Content, _obj_0.Path -- 11
end -- 11
local type <const> = type -- 12
App.idled = true -- 14
ShowConsole(false, true) -- 15
local moduleCache = { } -- 17
local oldRequire = _G.require -- 18
local require -- 19
require = function(path) -- 19
	local loaded = package.loaded[path] -- 20
	if loaded == nil then -- 21
		moduleCache[#moduleCache + 1] = path -- 22
		return oldRequire(path) -- 23
	end -- 21
	return loaded -- 24
end -- 19
_G.require = require -- 25
Dora.require = require -- 26
local searchPaths = Content.searchPaths -- 28
local useChinese = (App.locale:match("^zh") ~= nil) -- 30
local updateLocale -- 31
updateLocale = function() -- 31
	useChinese = (App.locale:match("^zh") ~= nil) -- 32
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 33
	Content.searchPaths = searchPaths -- 34
end -- 31
if DB:exist("Config") then -- 36
	local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 37
	local _type_0 = type(_exp_0) -- 38
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 38
	if _tab_0 then -- 38
		local locale -- 38
		do -- 38
			local _obj_0 = _exp_0[1] -- 38
			local _type_1 = type(_obj_0) -- 38
			if "table" == _type_1 or "userdata" == _type_1 then -- 38
				locale = _obj_0[1] -- 38
			end -- 40
		end -- 40
		if locale ~= nil then -- 38
			if App.locale ~= locale then -- 38
				App.locale = locale -- 39
				updateLocale() -- 40
			end -- 38
		end -- 38
	end -- 40
end -- 36
local Config = require("Config") -- 42
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth") -- 43
config:load() -- 65
if (config.fpsLimited ~= nil) then -- 66
	App.fpsLimited = config.fpsLimited -- 67
else -- 69
	config.fpsLimited = App.fpsLimited -- 69
end -- 66
if (config.targetFPS ~= nil) then -- 71
	App.targetFPS = config.targetFPS -- 72
else -- 74
	config.targetFPS = App.targetFPS -- 74
end -- 71
if (config.vsync ~= nil) then -- 76
	View.vsync = config.vsync -- 77
else -- 79
	config.vsync = View.vsync -- 79
end -- 76
if (config.fixedFPS ~= nil) then -- 81
	Director.scheduler.fixedFPS = config.fixedFPS -- 82
else -- 84
	config.fixedFPS = Director.scheduler.fixedFPS -- 84
end -- 81
local showEntry = true -- 86
local isDesktop = false -- 88
if (function() -- 89
	local _val_0 = App.platform -- 89
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 89
end)() then -- 89
	isDesktop = true -- 90
	if config.fullScreen then -- 91
		App.winSize = Size.zero -- 92
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 93
		local size = Size(config.winWidth, config.winHeight) -- 94
		if App.winSize ~= size then -- 95
			App.winSize = size -- 96
			showEntry = false -- 97
			thread(function() -- 98
				sleep() -- 99
				sleep() -- 100
				showEntry = true -- 101
			end) -- 98
		end -- 95
		local winX, winY -- 102
		do -- 102
			local _obj_0 = App.winPosition -- 102
			winX, winY = _obj_0.x, _obj_0.y -- 102
		end -- 102
		if (config.winX ~= nil) then -- 103
			winX = config.winX -- 104
		else -- 106
			config.winX = 0 -- 106
		end -- 103
		if (config.winY ~= nil) then -- 107
			winY = config.winY -- 108
		else -- 110
			config.winY = 0 -- 110
		end -- 107
		App.winPosition = Vec2(winX, winY) -- 111
	end -- 91
end -- 89
if (config.themeColor ~= nil) then -- 113
	App.themeColor = Color(config.themeColor) -- 114
else -- 116
	config.themeColor = App.themeColor:toARGB() -- 116
end -- 113
if not (config.locale ~= nil) then -- 118
	config.locale = App.locale -- 119
end -- 118
local showStats = false -- 121
if (config.showStats ~= nil) then -- 122
	showStats = config.showStats -- 123
else -- 125
	config.showStats = showStats -- 125
end -- 122
local showConsole = true -- 127
if (config.showConsole ~= nil) then -- 128
	showConsole = config.showConsole -- 129
else -- 131
	config.showConsole = showConsole -- 131
end -- 128
local showFooter = true -- 133
if (config.showFooter ~= nil) then -- 134
	showFooter = config.showFooter -- 135
else -- 137
	config.showFooter = showFooter -- 137
end -- 134
local filterBuf = Buffer(20) -- 139
if (config.filter ~= nil) then -- 140
	filterBuf.text = config.filter -- 141
else -- 143
	config.filter = "" -- 143
end -- 140
local engineDev = false -- 145
if (config.engineDev ~= nil) then -- 146
	engineDev = config.engineDev -- 147
else -- 149
	config.engineDev = engineDev -- 149
end -- 146
if (config.webProfiler ~= nil) then -- 151
	Director.profilerSending = config.webProfiler -- 152
else -- 154
	config.webProfiler = true -- 154
	Director.profilerSending = true -- 155
end -- 151
if not (config.drawerWidth ~= nil) then -- 157
	config.drawerWidth = 200 -- 158
end -- 157
_module_0.getConfig = function() -- 160
	return config -- 160
end -- 160
_module_0.getEngineDev = function() -- 161
	if not App.debugging then -- 162
		return false -- 162
	end -- 162
	return config.engineDev -- 163
end -- 161
local Set, Struct, LintYueGlobals, GSplit -- 165
do -- 165
	local _obj_0 = require("Utils") -- 165
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 165
end -- 165
local yueext = yue.options.extension -- 166
local isChineseSupported = IsFontLoaded() -- 168
if not isChineseSupported then -- 169
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 170
		isChineseSupported = true -- 171
	end) -- 170
end -- 169
local building = false -- 173
local getAllFiles -- 175
getAllFiles = function(path, exts, recursive) -- 175
	if recursive == nil then -- 175
		recursive = true -- 175
	end -- 175
	local filters = Set(exts) -- 176
	local files -- 177
	if recursive then -- 177
		files = Content:getAllFiles(path) -- 178
	else -- 180
		files = Content:getFiles(path) -- 180
	end -- 177
	local _accum_0 = { } -- 181
	local _len_0 = 1 -- 181
	for _index_0 = 1, #files do -- 181
		local file = files[_index_0] -- 181
		if not filters[Path:getExt(file)] then -- 182
			goto _continue_0 -- 182
		end -- 182
		_accum_0[_len_0] = file -- 183
		_len_0 = _len_0 + 1 -- 183
		::_continue_0:: -- 182
	end -- 183
	return _accum_0 -- 183
end -- 175
local getFileEntries -- 185
getFileEntries = function(path, recursive) -- 185
	if recursive == nil then -- 185
		recursive = true -- 185
	end -- 185
	local entries = { } -- 186
	local _list_0 = getAllFiles(path, { -- 187
		"lua", -- 187
		"xml", -- 187
		yueext, -- 187
		"tl" -- 187
	}, recursive) -- 187
	for _index_0 = 1, #_list_0 do -- 187
		local file = _list_0[_index_0] -- 187
		local entryName = Path:getName(file) -- 188
		local entryAdded = false -- 189
		for _index_1 = 1, #entries do -- 190
			local _des_0 = entries[_index_1] -- 190
			local ename = _des_0[1] -- 190
			if entryName == ename then -- 191
				entryAdded = true -- 192
				break -- 193
			end -- 191
		end -- 193
		if entryAdded then -- 194
			goto _continue_0 -- 194
		end -- 194
		local fileName = Path:replaceExt(file, "") -- 195
		fileName = Path(path, fileName) -- 196
		local entry = { -- 197
			entryName, -- 197
			fileName -- 197
		} -- 197
		entries[#entries + 1] = entry -- 198
		::_continue_0:: -- 188
	end -- 198
	table.sort(entries, function(a, b) -- 199
		return a[1] < b[1] -- 199
	end) -- 199
	return entries -- 200
end -- 185
local getProjectEntries -- 202
getProjectEntries = function(path) -- 202
	local entries = { } -- 203
	local _list_0 = Content:getDirs(path) -- 204
	for _index_0 = 1, #_list_0 do -- 204
		local dir = _list_0[_index_0] -- 204
		if dir:match("^%.") then -- 205
			goto _continue_0 -- 205
		end -- 205
		local _list_1 = getAllFiles(Path(path, dir), { -- 206
			"lua", -- 206
			"xml", -- 206
			yueext, -- 206
			"tl", -- 206
			"wasm" -- 206
		}) -- 206
		for _index_1 = 1, #_list_1 do -- 206
			local file = _list_1[_index_1] -- 206
			if "init" == Path:getName(file):lower() then -- 207
				local fileName = Path:replaceExt(file, "") -- 208
				fileName = Path(path, dir, fileName) -- 209
				local entryName = Path:getName(Path:getPath(fileName)) -- 210
				local entryAdded = false -- 211
				for _index_2 = 1, #entries do -- 212
					local _des_0 = entries[_index_2] -- 212
					local ename = _des_0[1] -- 212
					if entryName == ename then -- 213
						entryAdded = true -- 214
						break -- 215
					end -- 213
				end -- 215
				if entryAdded then -- 216
					goto _continue_1 -- 216
				end -- 216
				local examples = { } -- 217
				local tests = { } -- 218
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 219
				if Content:exist(examplePath) then -- 220
					local _list_2 = getFileEntries(examplePath) -- 221
					for _index_2 = 1, #_list_2 do -- 221
						local _des_0 = _list_2[_index_2] -- 221
						local name, ePath = _des_0[1], _des_0[2] -- 221
						local entry = { -- 222
							name, -- 222
							Path(path, dir, Path:getPath(file), ePath) -- 222
						} -- 222
						examples[#examples + 1] = entry -- 223
					end -- 223
				end -- 220
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 224
				if Content:exist(testPath) then -- 225
					local _list_2 = getFileEntries(testPath) -- 226
					for _index_2 = 1, #_list_2 do -- 226
						local _des_0 = _list_2[_index_2] -- 226
						local name, tPath = _des_0[1], _des_0[2] -- 226
						local entry = { -- 227
							name, -- 227
							Path(path, dir, Path:getPath(file), tPath) -- 227
						} -- 227
						tests[#tests + 1] = entry -- 228
					end -- 228
				end -- 225
				local entry = { -- 229
					entryName, -- 229
					fileName, -- 229
					examples, -- 229
					tests -- 229
				} -- 229
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 230
				if not Content:exist(bannerFile) then -- 231
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 232
					if not Content:exist(bannerFile) then -- 233
						bannerFile = nil -- 233
					end -- 233
				end -- 231
				if bannerFile then -- 234
					thread(function() -- 234
						if Cache:loadAsync(bannerFile) then -- 235
							local bannerTex = Texture2D(bannerFile) -- 236
							if bannerTex then -- 237
								entry[#entry + 1] = bannerFile -- 238
								entry[#entry + 1] = bannerTex -- 239
							end -- 237
						end -- 235
					end) -- 234
				end -- 234
				entries[#entries + 1] = entry -- 240
			end -- 207
			::_continue_1:: -- 207
		end -- 240
		::_continue_0:: -- 205
	end -- 240
	table.sort(entries, function(a, b) -- 241
		return a[1] < b[1] -- 241
	end) -- 241
	return entries -- 242
end -- 202
local gamesInDev, games -- 244
local doraTools, doraExamples, doraTests -- 245
local cppTests, cppTestSet -- 246
local allEntries -- 247
local updateEntries -- 249
updateEntries = function() -- 249
	gamesInDev = getProjectEntries(Content.writablePath) -- 250
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 251
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 253
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 254
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 255
	cppTests = { } -- 257
	local _list_0 = App.testNames -- 258
	for _index_0 = 1, #_list_0 do -- 258
		local name = _list_0[_index_0] -- 258
		local entry = { -- 259
			name -- 259
		} -- 259
		cppTests[#cppTests + 1] = entry -- 260
	end -- 260
	cppTestSet = Set(cppTests) -- 261
	allEntries = { } -- 263
	for _index_0 = 1, #gamesInDev do -- 264
		local game = gamesInDev[_index_0] -- 264
		allEntries[#allEntries + 1] = game -- 265
		local examples, tests = game[3], game[4] -- 266
		for _index_1 = 1, #examples do -- 267
			local example = examples[_index_1] -- 267
			allEntries[#allEntries + 1] = example -- 268
		end -- 268
		for _index_1 = 1, #tests do -- 269
			local test = tests[_index_1] -- 269
			allEntries[#allEntries + 1] = test -- 270
		end -- 270
	end -- 270
	for _index_0 = 1, #games do -- 271
		local game = games[_index_0] -- 271
		allEntries[#allEntries + 1] = game -- 272
		local examples, tests = game[3], game[4] -- 273
		for _index_1 = 1, #examples do -- 274
			local example = examples[_index_1] -- 274
			doraExamples[#doraExamples + 1] = example -- 275
		end -- 275
		for _index_1 = 1, #tests do -- 276
			local test = tests[_index_1] -- 276
			doraTests[#doraTests + 1] = test -- 277
		end -- 277
	end -- 277
	local _list_1 = { -- 279
		doraExamples, -- 279
		doraTests, -- 280
		cppTests -- 281
	} -- 278
	for _index_0 = 1, #_list_1 do -- 282
		local group = _list_1[_index_0] -- 278
		for _index_1 = 1, #group do -- 283
			local entry = group[_index_1] -- 283
			allEntries[#allEntries + 1] = entry -- 284
		end -- 284
	end -- 284
end -- 249
updateEntries() -- 286
local doCompile -- 288
doCompile = function(minify) -- 288
	if building then -- 289
		return -- 289
	end -- 289
	building = true -- 290
	local startTime = App.runningTime -- 291
	local luaFiles = { } -- 292
	local yueFiles = { } -- 293
	local xmlFiles = { } -- 294
	local tlFiles = { } -- 295
	local writablePath = Content.writablePath -- 296
	local buildPaths = { -- 298
		{ -- 299
			Path(Content.assetPath), -- 299
			Path(writablePath, ".build"), -- 300
			"" -- 301
		} -- 298
	} -- 297
	for _index_0 = 1, #gamesInDev do -- 304
		local _des_0 = gamesInDev[_index_0] -- 304
		local entryFile = _des_0[2] -- 304
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 305
		buildPaths[#buildPaths + 1] = { -- 307
			Path(writablePath, gamePath), -- 307
			Path(writablePath, ".build", gamePath), -- 308
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 309
			gamePath -- 310
		} -- 306
	end -- 310
	for _index_0 = 1, #buildPaths do -- 311
		local _des_0 = buildPaths[_index_0] -- 311
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 311
		if not Content:exist(inputPath) then -- 312
			goto _continue_0 -- 312
		end -- 312
		local _list_0 = getAllFiles(inputPath, { -- 314
			"lua" -- 314
		}) -- 314
		for _index_1 = 1, #_list_0 do -- 314
			local file = _list_0[_index_1] -- 314
			luaFiles[#luaFiles + 1] = { -- 316
				file, -- 316
				Path(inputPath, file), -- 317
				Path(outputPath, file), -- 318
				gamePath -- 319
			} -- 315
		end -- 319
		local _list_1 = getAllFiles(inputPath, { -- 321
			yueext -- 321
		}) -- 321
		for _index_1 = 1, #_list_1 do -- 321
			local file = _list_1[_index_1] -- 321
			yueFiles[#yueFiles + 1] = { -- 323
				file, -- 323
				Path(inputPath, file), -- 324
				Path(outputPath, Path:replaceExt(file, "lua")), -- 325
				searchPath, -- 326
				gamePath -- 327
			} -- 322
		end -- 327
		local _list_2 = getAllFiles(inputPath, { -- 329
			"xml" -- 329
		}) -- 329
		for _index_1 = 1, #_list_2 do -- 329
			local file = _list_2[_index_1] -- 329
			xmlFiles[#xmlFiles + 1] = { -- 331
				file, -- 331
				Path(inputPath, file), -- 332
				Path(outputPath, Path:replaceExt(file, "lua")), -- 333
				gamePath -- 334
			} -- 330
		end -- 334
		local _list_3 = getAllFiles(inputPath, { -- 336
			"tl" -- 336
		}) -- 336
		for _index_1 = 1, #_list_3 do -- 336
			local file = _list_3[_index_1] -- 336
			if not file:match(".*%.d%.tl$") then -- 337
				tlFiles[#tlFiles + 1] = { -- 339
					file, -- 339
					Path(inputPath, file), -- 340
					Path(outputPath, Path:replaceExt(file, "lua")), -- 341
					searchPath, -- 342
					gamePath -- 343
				} -- 338
			end -- 337
		end -- 343
		::_continue_0:: -- 312
	end -- 343
	local paths -- 345
	do -- 345
		local _tbl_0 = { } -- 345
		local _list_0 = { -- 346
			luaFiles, -- 346
			yueFiles, -- 346
			xmlFiles, -- 346
			tlFiles -- 346
		} -- 346
		for _index_0 = 1, #_list_0 do -- 346
			local files = _list_0[_index_0] -- 346
			for _index_1 = 1, #files do -- 347
				local file = files[_index_1] -- 347
				_tbl_0[Path:getPath(file[3])] = true -- 345
			end -- 345
		end -- 345
		paths = _tbl_0 -- 345
	end -- 347
	for path in pairs(paths) do -- 349
		Content:mkdir(path) -- 349
	end -- 349
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 351
	local fileCount = 0 -- 352
	local errors = { } -- 353
	for _index_0 = 1, #yueFiles do -- 354
		local _des_0 = yueFiles[_index_0] -- 354
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 354
		local filename -- 355
		if gamePath then -- 355
			filename = Path(gamePath, file) -- 355
		else -- 355
			filename = file -- 355
		end -- 355
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 356
			if not codes then -- 357
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 358
				return -- 359
			end -- 357
			local success, result = LintYueGlobals(codes, globals) -- 360
			if success then -- 361
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 362
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 363
				codes = codes:gsub("^\n*", "") -- 364
				if not (result == "") then -- 365
					result = result .. "\n" -- 365
				end -- 365
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 366
			else -- 368
				local yueCodes = Content:load(input) -- 368
				if yueCodes then -- 368
					local globalErrors = { } -- 369
					for _index_1 = 1, #result do -- 370
						local _des_1 = result[_index_1] -- 370
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 370
						local countLine = 1 -- 371
						local code = "" -- 372
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 373
							if countLine == line then -- 374
								code = lineCode -- 375
								break -- 376
							end -- 374
							countLine = countLine + 1 -- 377
						end -- 377
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 378
					end -- 378
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 379
				else -- 381
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 381
				end -- 368
			end -- 361
		end, function(success) -- 356
			if success then -- 382
				print("Yue compiled: " .. tostring(filename)) -- 382
			end -- 382
			fileCount = fileCount + 1 -- 383
		end) -- 356
	end -- 383
	thread(function() -- 385
		for _index_0 = 1, #xmlFiles do -- 386
			local _des_0 = xmlFiles[_index_0] -- 386
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 386
			local filename -- 387
			if gamePath then -- 387
				filename = Path(gamePath, file) -- 387
			else -- 387
				filename = file -- 387
			end -- 387
			local sourceCodes = Content:loadAsync(input) -- 388
			local codes, err = xml.tolua(sourceCodes) -- 389
			if not codes then -- 390
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 391
			else -- 393
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 393
				print("Xml compiled: " .. tostring(filename)) -- 394
			end -- 390
			fileCount = fileCount + 1 -- 395
		end -- 395
	end) -- 385
	thread(function() -- 397
		for _index_0 = 1, #tlFiles do -- 398
			local _des_0 = tlFiles[_index_0] -- 398
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 398
			local filename -- 399
			if gamePath then -- 399
				filename = Path(gamePath, file) -- 399
			else -- 399
				filename = file -- 399
			end -- 399
			local sourceCodes = Content:loadAsync(input) -- 400
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 401
			if not codes then -- 402
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 403
			else -- 405
				Content:saveAsync(output, codes) -- 405
				print("Teal compiled: " .. tostring(filename)) -- 406
			end -- 402
			fileCount = fileCount + 1 -- 407
		end -- 407
	end) -- 397
	return thread(function() -- 409
		wait(function() -- 410
			return fileCount == totalFiles -- 410
		end) -- 410
		if minify then -- 411
			local _list_0 = { -- 412
				yueFiles, -- 412
				xmlFiles, -- 412
				tlFiles -- 412
			} -- 412
			for _index_0 = 1, #_list_0 do -- 412
				local files = _list_0[_index_0] -- 412
				for _index_1 = 1, #files do -- 412
					local file = files[_index_1] -- 412
					local output = Path:replaceExt(file[3], "lua") -- 413
					luaFiles[#luaFiles + 1] = { -- 415
						Path:replaceExt(file[1], "lua"), -- 415
						output, -- 416
						output -- 417
					} -- 414
				end -- 417
			end -- 417
			local FormatMini -- 419
			do -- 419
				local _obj_0 = require("luaminify") -- 419
				FormatMini = _obj_0.FormatMini -- 419
			end -- 419
			for _index_0 = 1, #luaFiles do -- 420
				local _des_0 = luaFiles[_index_0] -- 420
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 420
				if Content:exist(input) then -- 421
					local sourceCodes = Content:loadAsync(input) -- 422
					local res, err = FormatMini(sourceCodes) -- 423
					if res then -- 424
						Content:saveAsync(output, res) -- 425
						print("Minify: " .. tostring(file)) -- 426
					else -- 428
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 428
					end -- 424
				else -- 430
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 430
				end -- 421
			end -- 430
			package.loaded["luaminify.FormatMini"] = nil -- 431
			package.loaded["luaminify.ParseLua"] = nil -- 432
			package.loaded["luaminify.Scope"] = nil -- 433
			package.loaded["luaminify.Util"] = nil -- 434
		end -- 411
		local errorMessage = table.concat(errors, "\n") -- 435
		if errorMessage ~= "" then -- 436
			print("\n" .. errorMessage) -- 436
		end -- 436
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 437
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 438
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 439
		Content:clearPathCache() -- 440
		teal.clear() -- 441
		yue.clear() -- 442
		building = false -- 443
	end) -- 443
end -- 288
local doClean -- 445
doClean = function() -- 445
	if building then -- 446
		return -- 446
	end -- 446
	local writablePath = Content.writablePath -- 447
	local targetDir = Path(writablePath, ".build") -- 448
	Content:clearPathCache() -- 449
	if Content:remove(targetDir) then -- 450
		print("Cleaned: " .. tostring(targetDir)) -- 451
	end -- 450
	Content:remove(Path(writablePath, ".upload")) -- 452
	return Content:remove(Path(writablePath, ".download")) -- 453
end -- 445
local screenScale = 2.0 -- 455
local scaleContent = false -- 456
local isInEntry = true -- 457
local currentEntry = nil -- 458
local footerWindow = nil -- 460
local entryWindow = nil -- 461
local setupEventHandlers = nil -- 463
local allClear -- 465
allClear = function() -- 465
	local _list_0 = Routine -- 466
	for _index_0 = 1, #_list_0 do -- 466
		local routine = _list_0[_index_0] -- 466
		if footerWindow == routine or entryWindow == routine then -- 468
			goto _continue_0 -- 469
		else -- 471
			Routine:remove(routine) -- 471
		end -- 471
		::_continue_0:: -- 467
	end -- 471
	for _index_0 = 1, #moduleCache do -- 472
		local module = moduleCache[_index_0] -- 472
		package.loaded[module] = nil -- 473
	end -- 473
	moduleCache = { } -- 474
	Director:cleanup() -- 475
	Cache:unload() -- 476
	Entity:clear() -- 477
	Platformer.Data:clear() -- 478
	Platformer.UnitAction:clear() -- 479
	Audio:stopStream(0.5) -- 480
	Struct:clear() -- 481
	View.postEffect = nil -- 482
	View.scale = scaleContent and screenScale or 1 -- 483
	Director.clearColor = Color(0xff1a1a1a) -- 484
	teal.clear() -- 485
	yue.clear() -- 486
	for _, item in pairs(ubox()) do -- 487
		local node = tolua.cast(item, "Node") -- 488
		if node then -- 488
			node:cleanup() -- 488
		end -- 488
	end -- 488
	collectgarbage() -- 489
	collectgarbage() -- 490
	setupEventHandlers() -- 491
	Content.searchPaths = searchPaths -- 492
	App.idled = true -- 493
	return Wasm:clear() -- 494
end -- 465
_module_0["allClear"] = allClear -- 494
setupEventHandlers = function() -- 496
	local _with_0 = Director.postNode -- 497
	_with_0:gslot("AppQuit", allClear) -- 498
	_with_0:gslot("AppTheme", function(argb) -- 499
		config.themeColor = argb -- 500
	end) -- 499
	_with_0:gslot("AppLocale", function(locale) -- 501
		config.locale = locale -- 502
		updateLocale() -- 503
		return teal.clear(true) -- 504
	end) -- 501
	_with_0:gslot("AppWSClose", function() -- 505
		if HttpServer.wsConnectionCount == 0 then -- 506
			return updateEntries() -- 507
		end -- 506
	end) -- 505
	local _exp_0 = App.platform -- 508
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 508
		_with_0:gslot("AppSizeChanged", function() -- 509
			local width, height -- 510
			do -- 510
				local _obj_0 = App.winSize -- 510
				width, height = _obj_0.width, _obj_0.height -- 510
			end -- 510
			config.winWidth = width -- 511
			config.winHeight = height -- 512
		end) -- 509
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 513
			config.fullScreen = fullScreen -- 514
		end) -- 513
		_with_0:gslot("AppMoved", function() -- 515
			local _obj_0 = App.winPosition -- 516
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 516
		end) -- 515
	end -- 516
	return _with_0 -- 497
end -- 496
setupEventHandlers() -- 518
local stop -- 520
stop = function() -- 520
	if isInEntry then -- 521
		return false -- 521
	end -- 521
	allClear() -- 522
	isInEntry = true -- 523
	currentEntry = nil -- 524
	return true -- 525
end -- 520
_module_0["stop"] = stop -- 525
local _anon_func_0 = function(Content, Path, file, require, type) -- 547
	local scriptPath = Path:getPath(file) -- 540
	Content:insertSearchPath(1, scriptPath) -- 541
	scriptPath = Path(scriptPath, "Script") -- 542
	if Content:exist(scriptPath) then -- 543
		Content:insertSearchPath(1, scriptPath) -- 544
	end -- 543
	local result = require(file) -- 545
	if "function" == type(result) then -- 546
		result() -- 546
	end -- 546
	return nil -- 547
end -- 540
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 579
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 576
	label.alignment = "Left" -- 577
	label.textWidth = width - fontSize -- 578
	label.text = err -- 579
	return label -- 576
end -- 576
local enterEntryAsync -- 527
enterEntryAsync = function(entry) -- 527
	isInEntry = false -- 528
	App.idled = false -- 529
	emit(Profiler.EventName, "ClearLoader") -- 530
	currentEntry = entry -- 531
	local name, file = entry[1], entry[2] -- 532
	if cppTestSet[entry] then -- 533
		if App:runTest(name) then -- 534
			return true -- 535
		else -- 537
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 537
		end -- 534
	end -- 533
	sleep() -- 538
	return xpcall(_anon_func_0, function(msg) -- 547
		local err = debug.traceback(msg) -- 549
		allClear() -- 550
		print(err) -- 551
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 552
		local viewWidth, viewHeight -- 553
		do -- 553
			local _obj_0 = View.size -- 553
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 553
		end -- 553
		local width, height = viewWidth - 20, viewHeight - 20 -- 554
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 555
		Director.ui:addChild((function() -- 556
			local root = AlignNode() -- 556
			do -- 557
				local _obj_0 = App.bufferSize -- 557
				width, height = _obj_0.width, _obj_0.height -- 557
			end -- 557
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 558
			root:gslot("AppSizeChanged", function() -- 559
				do -- 560
					local _obj_0 = App.bufferSize -- 560
					width, height = _obj_0.width, _obj_0.height -- 560
				end -- 560
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 561
			end) -- 559
			root:addChild((function() -- 562
				local _with_0 = ScrollArea({ -- 563
					width = width, -- 563
					height = height, -- 564
					paddingX = 0, -- 565
					paddingY = 50, -- 566
					viewWidth = height, -- 567
					viewHeight = height -- 568
				}) -- 562
				root:slot("AlignLayout", function(w, h) -- 570
					_with_0.position = Vec2(w / 2, h / 2) -- 571
					w = w - 20 -- 572
					h = h - 20 -- 573
					_with_0.view.children.first.textWidth = w - fontSize -- 574
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 575
				end) -- 570
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 576
				return _with_0 -- 562
			end)()) -- 562
			return root -- 556
		end)()) -- 556
		return err -- 580
	end, Content, Path, file, require, type) -- 580
end -- 527
_module_0["enterEntryAsync"] = enterEntryAsync -- 580
local enterDemoEntry -- 582
enterDemoEntry = function(entry) -- 582
	return thread(function() -- 582
		return enterEntryAsync(entry) -- 582
	end) -- 582
end -- 582
local reloadCurrentEntry -- 584
reloadCurrentEntry = function() -- 584
	if currentEntry then -- 585
		allClear() -- 586
		return enterDemoEntry(currentEntry) -- 587
	end -- 585
end -- 584
Director.clearColor = Color(0xff1a1a1a) -- 589
local waitForWebStart = true -- 591
thread(function() -- 592
	sleep(2) -- 593
	waitForWebStart = false -- 594
end) -- 592
local reloadDevEntry -- 596
reloadDevEntry = function() -- 596
	return thread(function() -- 596
		waitForWebStart = true -- 597
		doClean() -- 598
		allClear() -- 599
		_G.require = oldRequire -- 600
		Dora.require = oldRequire -- 601
		package.loaded["Script.Dev.Entry"] = nil -- 602
		return Director.systemScheduler:schedule(function() -- 603
			Routine:clear() -- 604
			oldRequire("Script.Dev.Entry") -- 605
			return true -- 606
		end) -- 606
	end) -- 606
end -- 596
local isOSSLicenseExist = Content:exist("LICENSES") -- 608
local ossLicenses = nil -- 609
local ossLicenseOpen = false -- 610
local extraOperations -- 612
extraOperations = function() -- 612
	local zh = useChinese and isChineseSupported -- 613
	if isOSSLicenseExist then -- 614
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 615
			if not ossLicenses then -- 616
				ossLicenses = { } -- 617
				local licenseText = Content:load("LICENSES") -- 618
				ossLicenseOpen = (licenseText ~= nil) -- 619
				if ossLicenseOpen then -- 619
					licenseText = licenseText:gsub("\r\n", "\n") -- 620
					for license in GSplit(licenseText, "\n--------\n", true) do -- 621
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 622
						if name then -- 622
							ossLicenses[#ossLicenses + 1] = { -- 623
								name, -- 623
								text -- 623
							} -- 623
						end -- 622
					end -- 623
				end -- 619
			else -- 625
				ossLicenseOpen = true -- 625
			end -- 616
		end -- 615
		if ossLicenseOpen then -- 626
			local width, height, themeColor -- 627
			do -- 627
				local _obj_0 = App -- 627
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 627
			end -- 627
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 628
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 629
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 630
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 633
					"NoSavedSettings" -- 633
				}, function() -- 634
					for _index_0 = 1, #ossLicenses do -- 634
						local _des_0 = ossLicenses[_index_0] -- 634
						local firstLine, text = _des_0[1], _des_0[2] -- 634
						local name, license = firstLine:match("(.+): (.+)") -- 635
						TextColored(themeColor, name) -- 636
						SameLine() -- 637
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 638
							return TextWrapped(text) -- 638
						end) -- 638
					end -- 638
				end) -- 630
			end) -- 630
		end -- 626
	end -- 614
	if not App.debugging then -- 640
		return -- 640
	end -- 640
	return TreeNode(zh and "开发操作" or "Development", function() -- 641
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 642
			OpenPopup("build") -- 642
		end -- 642
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 643
			return BeginPopup("build", function() -- 643
				if Selectable(zh and "编译" or "Compile") then -- 644
					doCompile(false) -- 644
				end -- 644
				Separator() -- 645
				if Selectable(zh and "压缩" or "Minify") then -- 646
					doCompile(true) -- 646
				end -- 646
				Separator() -- 647
				if Selectable(zh and "清理" or "Clean") then -- 648
					return doClean() -- 648
				end -- 648
			end) -- 648
		end) -- 643
		if isInEntry then -- 649
			if waitForWebStart then -- 650
				BeginDisabled(function() -- 651
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 651
				end) -- 651
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 652
				reloadDevEntry() -- 653
			end -- 650
		end -- 649
		do -- 654
			local changed -- 654
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 654
			if changed then -- 654
				View.scale = scaleContent and screenScale or 1 -- 655
			end -- 654
		end -- 654
		local changed -- 656
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 656
		if changed then -- 656
			config.engineDev = engineDev -- 657
		end -- 656
	end) -- 641
end -- 612
local transparant = Color(0x0) -- 659
local windowFlags = { -- 660
	"NoTitleBar", -- 660
	"NoResize", -- 660
	"NoMove", -- 660
	"NoCollapse", -- 660
	"NoSavedSettings", -- 660
	"NoBringToFrontOnFocus" -- 660
} -- 660
local initFooter = true -- 668
local _anon_func_2 = function(allEntries, currentIndex) -- 704
	if currentIndex > 1 then -- 704
		return allEntries[currentIndex - 1] -- 705
	else -- 707
		return allEntries[#allEntries] -- 707
	end -- 704
end -- 704
local _anon_func_3 = function(allEntries, currentIndex) -- 711
	if currentIndex < #allEntries then -- 711
		return allEntries[currentIndex + 1] -- 712
	else -- 714
		return allEntries[1] -- 714
	end -- 711
end -- 711
footerWindow = threadLoop(function() -- 669
	local zh = useChinese and isChineseSupported -- 670
	if HttpServer.wsConnectionCount > 0 then -- 671
		return -- 672
	end -- 671
	if Keyboard:isKeyDown("Escape") then -- 673
		allClear() -- 674
		App:shutdown() -- 675
	end -- 673
	do -- 676
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 677
		if ctrl and Keyboard:isKeyDown("Q") then -- 678
			stop() -- 679
		end -- 678
		if ctrl and Keyboard:isKeyDown("Z") then -- 680
			reloadCurrentEntry() -- 681
		end -- 680
		if ctrl and Keyboard:isKeyDown(",") then -- 682
			if showFooter then -- 683
				showStats = not showStats -- 683
			else -- 683
				showStats = true -- 683
			end -- 683
			showFooter = true -- 684
			config.showFooter = showFooter -- 685
			config.showStats = showStats -- 686
		end -- 682
		if ctrl and Keyboard:isKeyDown(".") then -- 687
			if showFooter then -- 688
				showConsole = not showConsole -- 688
			else -- 688
				showConsole = true -- 688
			end -- 688
			showFooter = true -- 689
			config.showFooter = showFooter -- 690
			config.showConsole = showConsole -- 691
		end -- 687
		if ctrl and Keyboard:isKeyDown("/") then -- 692
			showFooter = not showFooter -- 693
			config.showFooter = showFooter -- 694
		end -- 692
		local left = ctrl and Keyboard:isKeyDown("Left") -- 695
		local right = ctrl and Keyboard:isKeyDown("Right") -- 696
		local currentIndex = nil -- 697
		for i, entry in ipairs(allEntries) do -- 698
			if currentEntry == entry then -- 699
				currentIndex = i -- 700
			end -- 699
		end -- 700
		if left then -- 701
			allClear() -- 702
			if currentIndex == nil then -- 703
				currentIndex = #allEntries + 1 -- 703
			end -- 703
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 704
		end -- 701
		if right then -- 708
			allClear() -- 709
			if currentIndex == nil then -- 710
				currentIndex = 0 -- 710
			end -- 710
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 711
		end -- 708
	end -- 714
	if not showEntry then -- 715
		return -- 715
	end -- 715
	local width, height -- 717
	do -- 717
		local _obj_0 = App.visualSize -- 717
		width, height = _obj_0.width, _obj_0.height -- 717
	end -- 717
	SetNextWindowSize(Vec2(50, 50)) -- 718
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 719
	PushStyleColor("WindowBg", transparant, function() -- 720
		return Begin("Show", windowFlags, function() -- 720
			if isInEntry or width >= 540 then -- 721
				local changed -- 722
				changed, showFooter = Checkbox("##dev", showFooter) -- 722
				if changed then -- 722
					config.showFooter = showFooter -- 723
				end -- 722
			end -- 721
		end) -- 723
	end) -- 720
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 725
		reloadDevEntry() -- 729
	end -- 725
	if initFooter then -- 730
		initFooter = false -- 731
	else -- 733
		if not showFooter then -- 733
			return -- 733
		end -- 733
	end -- 730
	SetNextWindowSize(Vec2(width, 50)) -- 735
	SetNextWindowPos(Vec2(0, height - 50)) -- 736
	SetNextWindowBgAlpha(0.35) -- 737
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 738
		return Begin("Footer", windowFlags, function() -- 738
			Dummy(Vec2(width - 20, 0)) -- 739
			do -- 740
				local changed -- 740
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 740
				if changed then -- 740
					config.showStats = showStats -- 741
				end -- 740
			end -- 740
			SameLine() -- 742
			do -- 743
				local changed -- 743
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 743
				if changed then -- 743
					config.showConsole = showConsole -- 744
				end -- 743
			end -- 743
			if not isInEntry then -- 745
				SameLine() -- 746
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 747
					allClear() -- 748
					isInEntry = true -- 749
					currentEntry = nil -- 750
				end -- 747
				local currentIndex = nil -- 751
				for i, entry in ipairs(allEntries) do -- 752
					if currentEntry == entry then -- 753
						currentIndex = i -- 754
					end -- 753
				end -- 754
				if currentIndex then -- 755
					if currentIndex > 1 then -- 756
						SameLine() -- 757
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 758
							allClear() -- 759
							enterDemoEntry(allEntries[currentIndex - 1]) -- 760
						end -- 758
					end -- 756
					if currentIndex < #allEntries then -- 761
						SameLine() -- 762
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 763
							allClear() -- 764
							enterDemoEntry(allEntries[currentIndex + 1]) -- 765
						end -- 763
					end -- 761
				end -- 755
				SameLine() -- 766
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 767
					reloadCurrentEntry() -- 768
				end -- 767
			end -- 745
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 769
				if showStats then -- 770
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 771
					showStats = ShowStats(showStats, extraOperations) -- 772
					config.showStats = showStats -- 773
				end -- 770
				if showConsole then -- 774
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 775
					showConsole = ShowConsole(showConsole) -- 776
					config.showConsole = showConsole -- 777
				end -- 774
			end) -- 777
		end) -- 777
	end) -- 777
end) -- 669
local MaxWidth <const> = 800 -- 779
local displayWindowFlags = { -- 781
	"NoDecoration", -- 781
	"NoSavedSettings", -- 781
	"NoFocusOnAppearing", -- 781
	"NoNav", -- 781
	"NoMove", -- 781
	"NoScrollWithMouse", -- 781
	"AlwaysAutoResize", -- 781
	"NoBringToFrontOnFocus" -- 781
} -- 781
local webStatus = nil -- 792
local descColor = Color(0xffa1a1a1) -- 793
local gameOpen = #gamesInDev == 0 -- 794
local toolOpen = false -- 795
local exampleOpen = false -- 796
local testOpen = false -- 797
local filterText = nil -- 798
local anyEntryMatched = false -- 799
local urlClicked = nil -- 800
local match -- 801
match = function(name) -- 801
	local res = not filterText or name:lower():match(filterText) -- 802
	if res then -- 803
		anyEntryMatched = true -- 803
	end -- 803
	return res -- 804
end -- 801
local iconTex = nil -- 805
thread(function() -- 806
	if Cache:loadAsync("Image/icon_s.png") then -- 807
		iconTex = Texture2D("Image/icon_s.png") -- 808
	end -- 807
end) -- 806
entryWindow = threadLoop(function() -- 810
	if App.fpsLimited ~= config.fpsLimited then -- 811
		config.fpsLimited = App.fpsLimited -- 812
	end -- 811
	if App.targetFPS ~= config.targetFPS then -- 813
		config.targetFPS = App.targetFPS -- 814
	end -- 813
	if View.vsync ~= config.vsync then -- 815
		config.vsync = View.vsync -- 816
	end -- 815
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 817
		config.fixedFPS = Director.scheduler.fixedFPS -- 818
	end -- 817
	if Director.profilerSending ~= config.webProfiler then -- 819
		config.webProfiler = Director.profilerSending -- 820
	end -- 819
	if urlClicked then -- 821
		local _, result = coroutine.resume(urlClicked) -- 822
		if result then -- 823
			coroutine.close(urlClicked) -- 824
			urlClicked = nil -- 825
		end -- 823
	end -- 821
	if not showEntry then -- 826
		return -- 826
	end -- 826
	if not isInEntry then -- 827
		return -- 827
	end -- 827
	local zh = useChinese and isChineseSupported -- 828
	if HttpServer.wsConnectionCount > 0 then -- 829
		local themeColor = App.themeColor -- 830
		local width, height -- 831
		do -- 831
			local _obj_0 = App.visualSize -- 831
			width, height = _obj_0.width, _obj_0.height -- 831
		end -- 831
		SetNextWindowBgAlpha(0.5) -- 832
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 833
		Begin("Web IDE Connected", displayWindowFlags, function() -- 834
			Separator() -- 835
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 836
			if iconTex then -- 837
				Image("Image/icon_s.png", Vec2(24, 24)) -- 838
				SameLine() -- 839
			end -- 837
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 840
			TextColored(descColor, slogon) -- 841
			return Separator() -- 842
		end) -- 834
		return -- 843
	end -- 829
	local themeColor = App.themeColor -- 845
	local fullWidth, height -- 846
	do -- 846
		local _obj_0 = App.visualSize -- 846
		fullWidth, height = _obj_0.width, _obj_0.height -- 846
	end -- 846
	SetNextWindowBgAlpha(0.85) -- 848
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 849
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 850
		return Begin("Web IDE", displayWindowFlags, function() -- 851
			Separator() -- 852
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 853
			SameLine() -- 854
			TextDisabled('(?)') -- 855
			if IsItemHovered() then -- 856
				BeginTooltip(function() -- 857
					return PushTextWrapPos(280, function() -- 858
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 859
					end) -- 859
				end) -- 857
			end -- 856
			do -- 860
				local url -- 860
				if webStatus ~= nil then -- 860
					url = webStatus.url -- 860
				end -- 860
				if url then -- 860
					if isDesktop and not config.fullScreen then -- 861
						if urlClicked then -- 862
							BeginDisabled(function() -- 863
								return Button(url) -- 863
							end) -- 863
						elseif Button(url) then -- 864
							urlClicked = once(function() -- 865
								return sleep(5) -- 865
							end) -- 865
							App:openURL("http://localhost:8866") -- 866
						end -- 862
					else -- 868
						TextColored(descColor, url) -- 868
					end -- 861
				else -- 870
					TextColored(descColor, zh and '不可用' or 'not available') -- 870
				end -- 860
			end -- 860
			return Separator() -- 871
		end) -- 871
	end) -- 850
	local width = math.min(MaxWidth, fullWidth) -- 873
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 874
	local maxColumns = math.max(math.floor(width / 200), 1) -- 875
	SetNextWindowPos(Vec2.zero) -- 876
	SetNextWindowBgAlpha(0) -- 877
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 878
		return Begin("Dora Dev", displayWindowFlags, function() -- 879
			Dummy(Vec2(fullWidth - 20, 0)) -- 880
			if iconTex then -- 881
				Image("Image/icon_s.png", Vec2(24, 24)) -- 882
				SameLine() -- 883
			end -- 881
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 884
			SameLine() -- 885
			if fullWidth >= 320 then -- 886
				Dummy(Vec2(fullWidth - 320, 0)) -- 887
				SameLine() -- 888
				SetNextItemWidth(-50) -- 889
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 890
					"AutoSelectAll" -- 890
				}) then -- 890
					config.filter = filterBuf.text -- 891
				end -- 890
			end -- 886
			Separator() -- 892
			return Dummy(Vec2(fullWidth - 20, 0)) -- 893
		end) -- 893
	end) -- 878
	anyEntryMatched = false -- 895
	SetNextWindowPos(Vec2(0, 50)) -- 896
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 897
	return PushStyleColor("WindowBg", transparant, function() -- 898
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 898
			return Begin("Content", windowFlags, function() -- 899
				filterText = filterBuf.text:match("[^%%%.%[]+") -- 900
				if filterText then -- 901
					filterText = filterText:lower() -- 901
				end -- 901
				if #gamesInDev > 0 then -- 902
					for _index_0 = 1, #gamesInDev do -- 903
						local game = gamesInDev[_index_0] -- 903
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 904
						local showSep = false -- 905
						if match(gameName) then -- 906
							Columns(1, false) -- 907
							TextColored(themeColor, zh and "项目：" or "Project:") -- 908
							SameLine() -- 909
							Text(gameName) -- 910
							Separator() -- 911
							if bannerFile then -- 912
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 913
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 914
								local sizing <const> = 0.8 -- 915
								texHeight = displayWidth * sizing * texHeight / texWidth -- 916
								texWidth = displayWidth * sizing -- 917
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 918
								Dummy(Vec2(padding, 0)) -- 919
								SameLine() -- 920
								PushID(fileName, function() -- 921
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 922
										return enterDemoEntry(game) -- 923
									end -- 922
								end) -- 921
							else -- 925
								PushID(fileName, function() -- 925
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 926
										return enterDemoEntry(game) -- 927
									end -- 926
								end) -- 925
							end -- 912
							NextColumn() -- 928
							showSep = true -- 929
						end -- 906
						if #examples > 0 then -- 930
							local showExample = false -- 931
							for _index_1 = 1, #examples do -- 932
								local example = examples[_index_1] -- 932
								if match(example[1]) then -- 933
									showExample = true -- 934
									break -- 935
								end -- 933
							end -- 935
							if showExample then -- 936
								Columns(1, false) -- 937
								TextColored(themeColor, zh and "示例：" or "Example:") -- 938
								SameLine() -- 939
								Text(gameName) -- 940
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 941
									Columns(maxColumns, false) -- 942
									for _index_1 = 1, #examples do -- 943
										local example = examples[_index_1] -- 943
										if not match(example[1]) then -- 944
											goto _continue_0 -- 944
										end -- 944
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 945
											if Button(example[1], Vec2(-1, 40)) then -- 946
												enterDemoEntry(example) -- 947
											end -- 946
											return NextColumn() -- 948
										end) -- 945
										showSep = true -- 949
										::_continue_0:: -- 944
									end -- 949
								end) -- 941
							end -- 936
						end -- 930
						if #tests > 0 then -- 950
							local showTest = false -- 951
							for _index_1 = 1, #tests do -- 952
								local test = tests[_index_1] -- 952
								if match(test[1]) then -- 953
									showTest = true -- 954
									break -- 955
								end -- 953
							end -- 955
							if showTest then -- 956
								Columns(1, false) -- 957
								TextColored(themeColor, zh and "测试：" or "Test:") -- 958
								SameLine() -- 959
								Text(gameName) -- 960
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 961
									Columns(maxColumns, false) -- 962
									for _index_1 = 1, #tests do -- 963
										local test = tests[_index_1] -- 963
										if not match(test[1]) then -- 964
											goto _continue_0 -- 964
										end -- 964
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 965
											if Button(test[1], Vec2(-1, 40)) then -- 966
												enterDemoEntry(test) -- 967
											end -- 966
											return NextColumn() -- 968
										end) -- 965
										showSep = true -- 969
										::_continue_0:: -- 964
									end -- 969
								end) -- 961
							end -- 956
						end -- 950
						if showSep then -- 970
							Columns(1, false) -- 971
							Separator() -- 972
						end -- 970
					end -- 972
				end -- 902
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 973
					local showGame = false -- 974
					for _index_0 = 1, #games do -- 975
						local _des_0 = games[_index_0] -- 975
						local name = _des_0[1] -- 975
						if match(name) then -- 976
							showGame = true -- 976
						end -- 976
					end -- 976
					local showTool = false -- 977
					for _index_0 = 1, #doraTools do -- 978
						local _des_0 = doraTools[_index_0] -- 978
						local name = _des_0[1] -- 978
						if match(name) then -- 979
							showTool = true -- 979
						end -- 979
					end -- 979
					local showExample = false -- 980
					for _index_0 = 1, #doraExamples do -- 981
						local _des_0 = doraExamples[_index_0] -- 981
						local name = _des_0[1] -- 981
						if match(name) then -- 982
							showExample = true -- 982
						end -- 982
					end -- 982
					local showTest = false -- 983
					for _index_0 = 1, #doraTests do -- 984
						local _des_0 = doraTests[_index_0] -- 984
						local name = _des_0[1] -- 984
						if match(name) then -- 985
							showTest = true -- 985
						end -- 985
					end -- 985
					for _index_0 = 1, #cppTests do -- 986
						local _des_0 = cppTests[_index_0] -- 986
						local name = _des_0[1] -- 986
						if match(name) then -- 987
							showTest = true -- 987
						end -- 987
					end -- 987
					if not (showGame or showTool or showExample or showTest) then -- 988
						goto endEntry -- 988
					end -- 988
					Columns(1, false) -- 989
					TextColored(themeColor, "Dora SSR:") -- 990
					SameLine() -- 991
					Text(zh and "开发示例" or "Development Showcase") -- 992
					Separator() -- 993
					local demoViewWith <const> = 400 -- 994
					if #games > 0 and showGame then -- 995
						local opened -- 996
						if (filterText ~= nil) then -- 996
							opened = showGame -- 996
						else -- 996
							opened = false -- 996
						end -- 996
						SetNextItemOpen(gameOpen) -- 997
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 998
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 999
							Columns(columns, false) -- 1000
							for _index_0 = 1, #games do -- 1001
								local game = games[_index_0] -- 1001
								if not match(game[1]) then -- 1002
									goto _continue_0 -- 1002
								end -- 1002
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1003
								if columns > 1 then -- 1004
									if bannerFile then -- 1005
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1006
										local displayWidth <const> = demoViewWith - 40 -- 1007
										texHeight = displayWidth * texHeight / texWidth -- 1008
										texWidth = displayWidth -- 1009
										Text(gameName) -- 1010
										PushID(fileName, function() -- 1011
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1012
												return enterDemoEntry(game) -- 1013
											end -- 1012
										end) -- 1011
									else -- 1015
										PushID(fileName, function() -- 1015
											if Button(gameName, Vec2(-1, 40)) then -- 1016
												return enterDemoEntry(game) -- 1017
											end -- 1016
										end) -- 1015
									end -- 1005
								else -- 1019
									if bannerFile then -- 1019
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1020
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1021
										local sizing = 0.8 -- 1022
										texHeight = displayWidth * sizing * texHeight / texWidth -- 1023
										texWidth = displayWidth * sizing -- 1024
										if texWidth > 500 then -- 1025
											sizing = 0.6 -- 1026
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1027
											texWidth = displayWidth * sizing -- 1028
										end -- 1025
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1029
										Dummy(Vec2(padding, 0)) -- 1030
										SameLine() -- 1031
										Text(gameName) -- 1032
										Dummy(Vec2(padding, 0)) -- 1033
										SameLine() -- 1034
										PushID(fileName, function() -- 1035
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1036
												return enterDemoEntry(game) -- 1037
											end -- 1036
										end) -- 1035
									else -- 1039
										PushID(fileName, function() -- 1039
											if Button(gameName, Vec2(-1, 40)) then -- 1040
												return enterDemoEntry(game) -- 1041
											end -- 1040
										end) -- 1039
									end -- 1019
								end -- 1004
								NextColumn() -- 1042
								::_continue_0:: -- 1002
							end -- 1042
							Columns(1, false) -- 1043
							opened = true -- 1044
						end) -- 998
						gameOpen = opened -- 1045
					end -- 995
					if #doraTools > 0 and showTool then -- 1046
						local opened -- 1047
						if (filterText ~= nil) then -- 1047
							opened = showTool -- 1047
						else -- 1047
							opened = false -- 1047
						end -- 1047
						SetNextItemOpen(toolOpen) -- 1048
						TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1049
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1050
								Columns(maxColumns, false) -- 1051
								for _index_0 = 1, #doraTools do -- 1052
									local example = doraTools[_index_0] -- 1052
									if not match(example[1]) then -- 1053
										goto _continue_0 -- 1053
									end -- 1053
									if Button(example[1], Vec2(-1, 40)) then -- 1054
										enterDemoEntry(example) -- 1055
									end -- 1054
									NextColumn() -- 1056
									::_continue_0:: -- 1053
								end -- 1056
								Columns(1, false) -- 1057
								opened = true -- 1058
							end) -- 1050
						end) -- 1049
						toolOpen = opened -- 1059
					end -- 1046
					if #doraExamples > 0 and showExample then -- 1060
						local opened -- 1061
						if (filterText ~= nil) then -- 1061
							opened = showExample -- 1061
						else -- 1061
							opened = false -- 1061
						end -- 1061
						SetNextItemOpen(exampleOpen) -- 1062
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1063
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1064
								Columns(maxColumns, false) -- 1065
								for _index_0 = 1, #doraExamples do -- 1066
									local example = doraExamples[_index_0] -- 1066
									if not match(example[1]) then -- 1067
										goto _continue_0 -- 1067
									end -- 1067
									if Button(example[1], Vec2(-1, 40)) then -- 1068
										enterDemoEntry(example) -- 1069
									end -- 1068
									NextColumn() -- 1070
									::_continue_0:: -- 1067
								end -- 1070
								Columns(1, false) -- 1071
								opened = true -- 1072
							end) -- 1064
						end) -- 1063
						exampleOpen = opened -- 1073
					end -- 1060
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1074
						local opened -- 1075
						if (filterText ~= nil) then -- 1075
							opened = showTest -- 1075
						else -- 1075
							opened = false -- 1075
						end -- 1075
						SetNextItemOpen(testOpen) -- 1076
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1077
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1078
								Columns(maxColumns, false) -- 1079
								for _index_0 = 1, #doraTests do -- 1080
									local test = doraTests[_index_0] -- 1080
									if not match(test[1]) then -- 1081
										goto _continue_0 -- 1081
									end -- 1081
									if Button(test[1], Vec2(-1, 40)) then -- 1082
										enterDemoEntry(test) -- 1083
									end -- 1082
									NextColumn() -- 1084
									::_continue_0:: -- 1081
								end -- 1084
								for _index_0 = 1, #cppTests do -- 1085
									local test = cppTests[_index_0] -- 1085
									if not match(test[1]) then -- 1086
										goto _continue_1 -- 1086
									end -- 1086
									if Button(test[1], Vec2(-1, 40)) then -- 1087
										enterDemoEntry(test) -- 1088
									end -- 1087
									NextColumn() -- 1089
									::_continue_1:: -- 1086
								end -- 1089
								opened = true -- 1090
							end) -- 1078
						end) -- 1077
						testOpen = opened -- 1091
					end -- 1074
				end -- 973
				::endEntry:: -- 1092
				if not anyEntryMatched then -- 1093
					SetNextWindowBgAlpha(0) -- 1094
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1095
					Begin("Entries Not Found", displayWindowFlags, function() -- 1096
						Separator() -- 1097
						TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1098
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1099
						return Separator() -- 1100
					end) -- 1096
				end -- 1093
				Columns(1, false) -- 1101
				Dummy(Vec2(100, 80)) -- 1102
				return ScrollWhenDraggingOnVoid() -- 1103
			end) -- 1103
		end) -- 1103
	end) -- 1103
end) -- 810
webStatus = require("Script.Dev.WebServer") -- 1105
return _module_0 -- 1105
