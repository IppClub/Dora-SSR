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
local HttpClient = Dora.HttpClient -- 1
local json = Dora.json -- 1
local tonumber = _G.tonumber -- 1
local os = _G.os -- 1
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
local ImGui = Dora.ImGui -- 1
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification") -- 43
config:load() -- 67
if (config.fpsLimited ~= nil) then -- 68
	App.fpsLimited = config.fpsLimited -- 69
else -- 71
	config.fpsLimited = App.fpsLimited -- 71
end -- 68
if (config.targetFPS ~= nil) then -- 73
	App.targetFPS = config.targetFPS -- 74
else -- 76
	config.targetFPS = App.targetFPS -- 76
end -- 73
if (config.vsync ~= nil) then -- 78
	View.vsync = config.vsync -- 79
else -- 81
	config.vsync = View.vsync -- 81
end -- 78
if (config.fixedFPS ~= nil) then -- 83
	Director.scheduler.fixedFPS = config.fixedFPS -- 84
else -- 86
	config.fixedFPS = Director.scheduler.fixedFPS -- 86
end -- 83
local showEntry = true -- 88
local isDesktop = false -- 90
if (function() -- 91
	local _val_0 = App.platform -- 91
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 91
end)() then -- 91
	isDesktop = true -- 92
	if config.fullScreen then -- 93
		App.winSize = Size.zero -- 94
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 95
		local size = Size(config.winWidth, config.winHeight) -- 96
		if App.winSize ~= size then -- 97
			App.winSize = size -- 98
			showEntry = false -- 99
			thread(function() -- 100
				sleep() -- 101
				sleep() -- 102
				showEntry = true -- 103
			end) -- 100
		end -- 97
		local winX, winY -- 104
		do -- 104
			local _obj_0 = App.winPosition -- 104
			winX, winY = _obj_0.x, _obj_0.y -- 104
		end -- 104
		if (config.winX ~= nil) then -- 105
			winX = config.winX -- 106
		else -- 108
			config.winX = 0 -- 108
		end -- 105
		if (config.winY ~= nil) then -- 109
			winY = config.winY -- 110
		else -- 112
			config.winY = 0 -- 112
		end -- 109
		App.winPosition = Vec2(winX, winY) -- 113
	end -- 93
end -- 91
if (config.themeColor ~= nil) then -- 115
	App.themeColor = Color(config.themeColor) -- 116
else -- 118
	config.themeColor = App.themeColor:toARGB() -- 118
end -- 115
if not (config.locale ~= nil) then -- 120
	config.locale = App.locale -- 121
end -- 120
local showStats = false -- 123
if (config.showStats ~= nil) then -- 124
	showStats = config.showStats -- 125
else -- 127
	config.showStats = showStats -- 127
end -- 124
local showConsole = true -- 129
if (config.showConsole ~= nil) then -- 130
	showConsole = config.showConsole -- 131
else -- 133
	config.showConsole = showConsole -- 133
end -- 130
local showFooter = true -- 135
if (config.showFooter ~= nil) then -- 136
	showFooter = config.showFooter -- 137
else -- 139
	config.showFooter = showFooter -- 139
end -- 136
local filterBuf = Buffer(20) -- 141
if (config.filter ~= nil) then -- 142
	filterBuf.text = config.filter -- 143
else -- 145
	config.filter = "" -- 145
end -- 142
local engineDev = false -- 147
if (config.engineDev ~= nil) then -- 148
	engineDev = config.engineDev -- 149
else -- 151
	config.engineDev = engineDev -- 151
end -- 148
if (config.webProfiler ~= nil) then -- 153
	Director.profilerSending = config.webProfiler -- 154
else -- 156
	config.webProfiler = true -- 156
	Director.profilerSending = true -- 157
end -- 153
if not (config.drawerWidth ~= nil) then -- 159
	config.drawerWidth = 200 -- 160
end -- 159
_module_0.getConfig = function() -- 162
	return config -- 162
end -- 162
_module_0.getEngineDev = function() -- 163
	if not App.debugging then -- 164
		return false -- 164
	end -- 164
	return config.engineDev -- 165
end -- 163
local updateCheck -- 167
updateCheck = function() -- 167
	return thread(function() -- 167
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 168
		if res then -- 168
			local data = json.load(res) -- 169
			if data then -- 169
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 170
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 171
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 172
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 173
				if na < a then -- 174
					goto not_new_version -- 175
				end -- 174
				if na == a then -- 176
					if nb < b then -- 177
						goto not_new_version -- 178
					end -- 177
					if nb == b then -- 179
						if nc < c then -- 180
							goto not_new_version -- 181
						end -- 180
						if nc == c then -- 182
							goto not_new_version -- 183
						end -- 182
					end -- 179
				end -- 176
				config.updateNotification = true -- 184
				::not_new_version:: -- 185
				config.lastUpdateCheck = os.time() -- 186
			end -- 169
		end -- 168
	end) -- 186
end -- 167
if (config.lastUpdateCheck ~= nil) then -- 188
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 189
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 190
		updateCheck() -- 191
	end -- 190
else -- 193
	updateCheck() -- 193
end -- 188
local Set, Struct, LintYueGlobals, GSplit -- 195
do -- 195
	local _obj_0 = require("Utils") -- 195
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 195
end -- 195
local yueext = yue.options.extension -- 196
local isChineseSupported = IsFontLoaded() -- 198
if not isChineseSupported then -- 199
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 200
		isChineseSupported = true -- 201
	end) -- 200
end -- 199
local building = false -- 203
local getAllFiles -- 205
getAllFiles = function(path, exts, recursive) -- 205
	if recursive == nil then -- 205
		recursive = true -- 205
	end -- 205
	local filters = Set(exts) -- 206
	local files -- 207
	if recursive then -- 207
		files = Content:getAllFiles(path) -- 208
	else -- 210
		files = Content:getFiles(path) -- 210
	end -- 207
	local _accum_0 = { } -- 211
	local _len_0 = 1 -- 211
	for _index_0 = 1, #files do -- 211
		local file = files[_index_0] -- 211
		if not filters[Path:getExt(file)] then -- 212
			goto _continue_0 -- 212
		end -- 212
		_accum_0[_len_0] = file -- 213
		_len_0 = _len_0 + 1 -- 213
		::_continue_0:: -- 212
	end -- 213
	return _accum_0 -- 213
end -- 205
_module_0["getAllFiles"] = getAllFiles -- 213
local getFileEntries -- 215
getFileEntries = function(path, recursive) -- 215
	if recursive == nil then -- 215
		recursive = true -- 215
	end -- 215
	local entries = { } -- 216
	local _list_0 = getAllFiles(path, { -- 217
		"lua", -- 217
		"xml", -- 217
		yueext, -- 217
		"tl" -- 217
	}, recursive) -- 217
	for _index_0 = 1, #_list_0 do -- 217
		local file = _list_0[_index_0] -- 217
		local entryName = Path:getName(file) -- 218
		local entryAdded = false -- 219
		for _index_1 = 1, #entries do -- 220
			local _des_0 = entries[_index_1] -- 220
			local ename = _des_0[1] -- 220
			if entryName == ename then -- 221
				entryAdded = true -- 222
				break -- 223
			end -- 221
		end -- 223
		if entryAdded then -- 224
			goto _continue_0 -- 224
		end -- 224
		local fileName = Path:replaceExt(file, "") -- 225
		fileName = Path(path, fileName) -- 226
		local entry = { -- 227
			entryName, -- 227
			fileName -- 227
		} -- 227
		entries[#entries + 1] = entry -- 228
		::_continue_0:: -- 218
	end -- 228
	table.sort(entries, function(a, b) -- 229
		return a[1] < b[1] -- 229
	end) -- 229
	return entries -- 230
end -- 215
local getProjectEntries -- 232
getProjectEntries = function(path) -- 232
	local entries = { } -- 233
	local _list_0 = Content:getDirs(path) -- 234
	for _index_0 = 1, #_list_0 do -- 234
		local dir = _list_0[_index_0] -- 234
		if dir:match("^%.") then -- 235
			goto _continue_0 -- 235
		end -- 235
		local _list_1 = getAllFiles(Path(path, dir), { -- 236
			"lua", -- 236
			"xml", -- 236
			yueext, -- 236
			"tl", -- 236
			"wasm" -- 236
		}) -- 236
		for _index_1 = 1, #_list_1 do -- 236
			local file = _list_1[_index_1] -- 236
			if "init" == Path:getName(file):lower() then -- 237
				local fileName = Path:replaceExt(file, "") -- 238
				fileName = Path(path, dir, fileName) -- 239
				local entryName = Path:getName(Path:getPath(fileName)) -- 240
				local entryAdded = false -- 241
				for _index_2 = 1, #entries do -- 242
					local _des_0 = entries[_index_2] -- 242
					local ename = _des_0[1] -- 242
					if entryName == ename then -- 243
						entryAdded = true -- 244
						break -- 245
					end -- 243
				end -- 245
				if entryAdded then -- 246
					goto _continue_1 -- 246
				end -- 246
				local examples = { } -- 247
				local tests = { } -- 248
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 249
				if Content:exist(examplePath) then -- 250
					local _list_2 = getFileEntries(examplePath) -- 251
					for _index_2 = 1, #_list_2 do -- 251
						local _des_0 = _list_2[_index_2] -- 251
						local name, ePath = _des_0[1], _des_0[2] -- 251
						local entry = { -- 252
							name, -- 252
							Path(path, dir, Path:getPath(file), ePath) -- 252
						} -- 252
						examples[#examples + 1] = entry -- 253
					end -- 253
				end -- 250
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 254
				if Content:exist(testPath) then -- 255
					local _list_2 = getFileEntries(testPath) -- 256
					for _index_2 = 1, #_list_2 do -- 256
						local _des_0 = _list_2[_index_2] -- 256
						local name, tPath = _des_0[1], _des_0[2] -- 256
						local entry = { -- 257
							name, -- 257
							Path(path, dir, Path:getPath(file), tPath) -- 257
						} -- 257
						tests[#tests + 1] = entry -- 258
					end -- 258
				end -- 255
				local entry = { -- 259
					entryName, -- 259
					fileName, -- 259
					examples, -- 259
					tests -- 259
				} -- 259
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 260
				if not Content:exist(bannerFile) then -- 261
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 262
					if not Content:exist(bannerFile) then -- 263
						bannerFile = nil -- 263
					end -- 263
				end -- 261
				if bannerFile then -- 264
					thread(function() -- 264
						if Cache:loadAsync(bannerFile) then -- 265
							local bannerTex = Texture2D(bannerFile) -- 266
							if bannerTex then -- 267
								entry[#entry + 1] = bannerFile -- 268
								entry[#entry + 1] = bannerTex -- 269
							end -- 267
						end -- 265
					end) -- 264
				end -- 264
				entries[#entries + 1] = entry -- 270
			end -- 237
			::_continue_1:: -- 237
		end -- 270
		::_continue_0:: -- 235
	end -- 270
	table.sort(entries, function(a, b) -- 271
		return a[1] < b[1] -- 271
	end) -- 271
	return entries -- 272
end -- 232
local gamesInDev, games -- 274
local doraTools, doraExamples, doraTests -- 275
local cppTests, cppTestSet -- 276
local allEntries -- 277
local updateEntries -- 279
updateEntries = function() -- 279
	gamesInDev = getProjectEntries(Content.writablePath) -- 280
	games = getProjectEntries(Path(Content.assetPath, "Script")) -- 281
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 283
	doraExamples = getFileEntries(Path(Content.assetPath, "Script", "Example")) -- 284
	doraTests = getFileEntries(Path(Content.assetPath, "Script", "Test")) -- 285
	cppTests = { } -- 287
	local _list_0 = App.testNames -- 288
	for _index_0 = 1, #_list_0 do -- 288
		local name = _list_0[_index_0] -- 288
		local entry = { -- 289
			name -- 289
		} -- 289
		cppTests[#cppTests + 1] = entry -- 290
	end -- 290
	cppTestSet = Set(cppTests) -- 291
	allEntries = { } -- 293
	for _index_0 = 1, #gamesInDev do -- 294
		local game = gamesInDev[_index_0] -- 294
		allEntries[#allEntries + 1] = game -- 295
		local examples, tests = game[3], game[4] -- 296
		for _index_1 = 1, #examples do -- 297
			local example = examples[_index_1] -- 297
			allEntries[#allEntries + 1] = example -- 298
		end -- 298
		for _index_1 = 1, #tests do -- 299
			local test = tests[_index_1] -- 299
			allEntries[#allEntries + 1] = test -- 300
		end -- 300
	end -- 300
	for _index_0 = 1, #games do -- 301
		local game = games[_index_0] -- 301
		allEntries[#allEntries + 1] = game -- 302
		local examples, tests = game[3], game[4] -- 303
		for _index_1 = 1, #examples do -- 304
			local example = examples[_index_1] -- 304
			doraExamples[#doraExamples + 1] = example -- 305
		end -- 305
		for _index_1 = 1, #tests do -- 306
			local test = tests[_index_1] -- 306
			doraTests[#doraTests + 1] = test -- 307
		end -- 307
	end -- 307
	local _list_1 = { -- 309
		doraExamples, -- 309
		doraTests, -- 310
		cppTests -- 311
	} -- 308
	for _index_0 = 1, #_list_1 do -- 312
		local group = _list_1[_index_0] -- 308
		for _index_1 = 1, #group do -- 313
			local entry = group[_index_1] -- 313
			allEntries[#allEntries + 1] = entry -- 314
		end -- 314
	end -- 314
end -- 279
updateEntries() -- 316
local doCompile -- 318
doCompile = function(minify) -- 318
	if building then -- 319
		return -- 319
	end -- 319
	building = true -- 320
	local startTime = App.runningTime -- 321
	local luaFiles = { } -- 322
	local yueFiles = { } -- 323
	local xmlFiles = { } -- 324
	local tlFiles = { } -- 325
	local writablePath = Content.writablePath -- 326
	local buildPaths = { -- 328
		{ -- 329
			Path(Content.assetPath), -- 329
			Path(writablePath, ".build"), -- 330
			"" -- 331
		} -- 328
	} -- 327
	for _index_0 = 1, #gamesInDev do -- 334
		local _des_0 = gamesInDev[_index_0] -- 334
		local entryFile = _des_0[2] -- 334
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 335
		buildPaths[#buildPaths + 1] = { -- 337
			Path(writablePath, gamePath), -- 337
			Path(writablePath, ".build", gamePath), -- 338
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 339
			gamePath -- 340
		} -- 336
	end -- 340
	for _index_0 = 1, #buildPaths do -- 341
		local _des_0 = buildPaths[_index_0] -- 341
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 341
		if not Content:exist(inputPath) then -- 342
			goto _continue_0 -- 342
		end -- 342
		local _list_0 = getAllFiles(inputPath, { -- 344
			"lua" -- 344
		}) -- 344
		for _index_1 = 1, #_list_0 do -- 344
			local file = _list_0[_index_1] -- 344
			luaFiles[#luaFiles + 1] = { -- 346
				file, -- 346
				Path(inputPath, file), -- 347
				Path(outputPath, file), -- 348
				gamePath -- 349
			} -- 345
		end -- 349
		local _list_1 = getAllFiles(inputPath, { -- 351
			yueext -- 351
		}) -- 351
		for _index_1 = 1, #_list_1 do -- 351
			local file = _list_1[_index_1] -- 351
			yueFiles[#yueFiles + 1] = { -- 353
				file, -- 353
				Path(inputPath, file), -- 354
				Path(outputPath, Path:replaceExt(file, "lua")), -- 355
				searchPath, -- 356
				gamePath -- 357
			} -- 352
		end -- 357
		local _list_2 = getAllFiles(inputPath, { -- 359
			"xml" -- 359
		}) -- 359
		for _index_1 = 1, #_list_2 do -- 359
			local file = _list_2[_index_1] -- 359
			xmlFiles[#xmlFiles + 1] = { -- 361
				file, -- 361
				Path(inputPath, file), -- 362
				Path(outputPath, Path:replaceExt(file, "lua")), -- 363
				gamePath -- 364
			} -- 360
		end -- 364
		local _list_3 = getAllFiles(inputPath, { -- 366
			"tl" -- 366
		}) -- 366
		for _index_1 = 1, #_list_3 do -- 366
			local file = _list_3[_index_1] -- 366
			if not file:match(".*%.d%.tl$") then -- 367
				tlFiles[#tlFiles + 1] = { -- 369
					file, -- 369
					Path(inputPath, file), -- 370
					Path(outputPath, Path:replaceExt(file, "lua")), -- 371
					searchPath, -- 372
					gamePath -- 373
				} -- 368
			end -- 367
		end -- 373
		::_continue_0:: -- 342
	end -- 373
	local paths -- 375
	do -- 375
		local _tbl_0 = { } -- 375
		local _list_0 = { -- 376
			luaFiles, -- 376
			yueFiles, -- 376
			xmlFiles, -- 376
			tlFiles -- 376
		} -- 376
		for _index_0 = 1, #_list_0 do -- 376
			local files = _list_0[_index_0] -- 376
			for _index_1 = 1, #files do -- 377
				local file = files[_index_1] -- 377
				_tbl_0[Path:getPath(file[3])] = true -- 375
			end -- 375
		end -- 375
		paths = _tbl_0 -- 375
	end -- 377
	for path in pairs(paths) do -- 379
		Content:mkdir(path) -- 379
	end -- 379
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 381
	local fileCount = 0 -- 382
	local errors = { } -- 383
	for _index_0 = 1, #yueFiles do -- 384
		local _des_0 = yueFiles[_index_0] -- 384
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 384
		local filename -- 385
		if gamePath then -- 385
			filename = Path(gamePath, file) -- 385
		else -- 385
			filename = file -- 385
		end -- 385
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 386
			if not codes then -- 387
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 388
				return -- 389
			end -- 387
			local success, result = LintYueGlobals(codes, globals) -- 390
			if success then -- 391
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 392
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 393
				codes = codes:gsub("^\n*", "") -- 394
				if not (result == "") then -- 395
					result = result .. "\n" -- 395
				end -- 395
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 396
			else -- 398
				local yueCodes = Content:load(input) -- 398
				if yueCodes then -- 398
					local globalErrors = { } -- 399
					for _index_1 = 1, #result do -- 400
						local _des_1 = result[_index_1] -- 400
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 400
						local countLine = 1 -- 401
						local code = "" -- 402
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 403
							if countLine == line then -- 404
								code = lineCode -- 405
								break -- 406
							end -- 404
							countLine = countLine + 1 -- 407
						end -- 407
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 408
					end -- 408
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 409
				else -- 411
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 411
				end -- 398
			end -- 391
		end, function(success) -- 386
			if success then -- 412
				print("Yue compiled: " .. tostring(filename)) -- 412
			end -- 412
			fileCount = fileCount + 1 -- 413
		end) -- 386
	end -- 413
	thread(function() -- 415
		for _index_0 = 1, #xmlFiles do -- 416
			local _des_0 = xmlFiles[_index_0] -- 416
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 416
			local filename -- 417
			if gamePath then -- 417
				filename = Path(gamePath, file) -- 417
			else -- 417
				filename = file -- 417
			end -- 417
			local sourceCodes = Content:loadAsync(input) -- 418
			local codes, err = xml.tolua(sourceCodes) -- 419
			if not codes then -- 420
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 421
			else -- 423
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 423
				print("Xml compiled: " .. tostring(filename)) -- 424
			end -- 420
			fileCount = fileCount + 1 -- 425
		end -- 425
	end) -- 415
	thread(function() -- 427
		for _index_0 = 1, #tlFiles do -- 428
			local _des_0 = tlFiles[_index_0] -- 428
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 428
			local filename -- 429
			if gamePath then -- 429
				filename = Path(gamePath, file) -- 429
			else -- 429
				filename = file -- 429
			end -- 429
			local sourceCodes = Content:loadAsync(input) -- 430
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 431
			if not codes then -- 432
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 433
			else -- 435
				Content:saveAsync(output, codes) -- 435
				print("Teal compiled: " .. tostring(filename)) -- 436
			end -- 432
			fileCount = fileCount + 1 -- 437
		end -- 437
	end) -- 427
	return thread(function() -- 439
		wait(function() -- 440
			return fileCount == totalFiles -- 440
		end) -- 440
		if minify then -- 441
			local _list_0 = { -- 442
				yueFiles, -- 442
				xmlFiles, -- 442
				tlFiles -- 442
			} -- 442
			for _index_0 = 1, #_list_0 do -- 442
				local files = _list_0[_index_0] -- 442
				for _index_1 = 1, #files do -- 442
					local file = files[_index_1] -- 442
					local output = Path:replaceExt(file[3], "lua") -- 443
					luaFiles[#luaFiles + 1] = { -- 445
						Path:replaceExt(file[1], "lua"), -- 445
						output, -- 446
						output -- 447
					} -- 444
				end -- 447
			end -- 447
			local FormatMini -- 449
			do -- 449
				local _obj_0 = require("luaminify") -- 449
				FormatMini = _obj_0.FormatMini -- 449
			end -- 449
			for _index_0 = 1, #luaFiles do -- 450
				local _des_0 = luaFiles[_index_0] -- 450
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 450
				if Content:exist(input) then -- 451
					local sourceCodes = Content:loadAsync(input) -- 452
					local res, err = FormatMini(sourceCodes) -- 453
					if res then -- 454
						Content:saveAsync(output, res) -- 455
						print("Minify: " .. tostring(file)) -- 456
					else -- 458
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 458
					end -- 454
				else -- 460
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 460
				end -- 451
			end -- 460
			package.loaded["luaminify.FormatMini"] = nil -- 461
			package.loaded["luaminify.ParseLua"] = nil -- 462
			package.loaded["luaminify.Scope"] = nil -- 463
			package.loaded["luaminify.Util"] = nil -- 464
		end -- 441
		local errorMessage = table.concat(errors, "\n") -- 465
		if errorMessage ~= "" then -- 466
			print("\n" .. errorMessage) -- 466
		end -- 466
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 467
		print("\n" .. tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 468
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file fails' or 'files fail') .. " to build.") -- 469
		Content:clearPathCache() -- 470
		teal.clear() -- 471
		yue.clear() -- 472
		building = false -- 473
	end) -- 473
end -- 318
local doClean -- 475
doClean = function() -- 475
	if building then -- 476
		return -- 476
	end -- 476
	local writablePath = Content.writablePath -- 477
	local targetDir = Path(writablePath, ".build") -- 478
	Content:clearPathCache() -- 479
	if Content:remove(targetDir) then -- 480
		return print("Cleaned: " .. tostring(targetDir)) -- 481
	end -- 480
end -- 475
local screenScale = 2.0 -- 483
local scaleContent = false -- 484
local isInEntry = true -- 485
local currentEntry = nil -- 486
local footerWindow = nil -- 488
local entryWindow = nil -- 489
local setupEventHandlers = nil -- 491
local allClear -- 493
allClear = function() -- 493
	local _list_0 = Routine -- 494
	for _index_0 = 1, #_list_0 do -- 494
		local routine = _list_0[_index_0] -- 494
		if footerWindow == routine or entryWindow == routine then -- 496
			goto _continue_0 -- 497
		else -- 499
			Routine:remove(routine) -- 499
		end -- 499
		::_continue_0:: -- 495
	end -- 499
	for _index_0 = 1, #moduleCache do -- 500
		local module = moduleCache[_index_0] -- 500
		package.loaded[module] = nil -- 501
	end -- 501
	moduleCache = { } -- 502
	Director:cleanup() -- 503
	Cache:unload() -- 504
	Entity:clear() -- 505
	Platformer.Data:clear() -- 506
	Platformer.UnitAction:clear() -- 507
	Audio:stopStream(0.5) -- 508
	Struct:clear() -- 509
	View.postEffect = nil -- 510
	View.scale = scaleContent and screenScale or 1 -- 511
	Director.clearColor = Color(0xff1a1a1a) -- 512
	teal.clear() -- 513
	yue.clear() -- 514
	for _, item in pairs(ubox()) do -- 515
		local node = tolua.cast(item, "Node") -- 516
		if node then -- 516
			node:cleanup() -- 516
		end -- 516
	end -- 516
	collectgarbage() -- 517
	collectgarbage() -- 518
	setupEventHandlers() -- 519
	Content.searchPaths = searchPaths -- 520
	App.idled = true -- 521
	return Wasm:clear() -- 522
end -- 493
_module_0["allClear"] = allClear -- 522
local clearTempFiles -- 524
clearTempFiles = function() -- 524
	local writablePath = Content.writablePath -- 525
	Content:remove(Path(writablePath, ".upload")) -- 526
	return Content:remove(Path(writablePath, ".download")) -- 527
end -- 524
setupEventHandlers = function() -- 529
	local _with_0 = Director.postNode -- 530
	_with_0:gslot("AppQuit", function() -- 531
		allClear() -- 532
		return clearTempFiles() -- 533
	end) -- 531
	_with_0:gslot("AppTheme", function(argb) -- 534
		config.themeColor = argb -- 535
	end) -- 534
	_with_0:gslot("AppLocale", function(locale) -- 536
		config.locale = locale -- 537
		updateLocale() -- 538
		return teal.clear(true) -- 539
	end) -- 536
	_with_0:gslot("AppWSClose", function() -- 540
		if HttpServer.wsConnectionCount == 0 then -- 541
			return updateEntries() -- 542
		end -- 541
	end) -- 540
	local _exp_0 = App.platform -- 543
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 543
		_with_0:gslot("AppSizeChanged", function() -- 544
			local width, height -- 545
			do -- 545
				local _obj_0 = App.winSize -- 545
				width, height = _obj_0.width, _obj_0.height -- 545
			end -- 545
			config.winWidth = width -- 546
			config.winHeight = height -- 547
		end) -- 544
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 548
			config.fullScreen = fullScreen -- 549
		end) -- 548
		_with_0:gslot("AppMoved", function() -- 550
			local _obj_0 = App.winPosition -- 551
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 551
		end) -- 550
	end -- 551
	return _with_0 -- 530
end -- 529
setupEventHandlers() -- 553
clearTempFiles() -- 554
local stop -- 556
stop = function() -- 556
	if isInEntry then -- 557
		return false -- 557
	end -- 557
	allClear() -- 558
	isInEntry = true -- 559
	currentEntry = nil -- 560
	return true -- 561
end -- 556
_module_0["stop"] = stop -- 561
local _anon_func_0 = function(Content, Path, file, require, type) -- 583
	local scriptPath = Path:getPath(file) -- 576
	Content:insertSearchPath(1, scriptPath) -- 577
	scriptPath = Path(scriptPath, "Script") -- 578
	if Content:exist(scriptPath) then -- 579
		Content:insertSearchPath(1, scriptPath) -- 580
	end -- 579
	local result = require(file) -- 581
	if "function" == type(result) then -- 582
		result() -- 582
	end -- 582
	return nil -- 583
end -- 576
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 615
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 612
	label.alignment = "Left" -- 613
	label.textWidth = width - fontSize -- 614
	label.text = err -- 615
	return label -- 612
end -- 612
local enterEntryAsync -- 563
enterEntryAsync = function(entry) -- 563
	isInEntry = false -- 564
	App.idled = false -- 565
	emit(Profiler.EventName, "ClearLoader") -- 566
	currentEntry = entry -- 567
	local name, file = entry[1], entry[2] -- 568
	if cppTestSet[entry] then -- 569
		if App:runTest(name) then -- 570
			return true -- 571
		else -- 573
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 573
		end -- 570
	end -- 569
	sleep() -- 574
	return xpcall(_anon_func_0, function(msg) -- 583
		local err = debug.traceback(msg) -- 585
		allClear() -- 586
		print(err) -- 587
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 588
		local viewWidth, viewHeight -- 589
		do -- 589
			local _obj_0 = View.size -- 589
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 589
		end -- 589
		local width, height = viewWidth - 20, viewHeight - 20 -- 590
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 591
		Director.ui:addChild((function() -- 592
			local root = AlignNode() -- 592
			do -- 593
				local _obj_0 = App.bufferSize -- 593
				width, height = _obj_0.width, _obj_0.height -- 593
			end -- 593
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 594
			root:gslot("AppSizeChanged", function() -- 595
				do -- 596
					local _obj_0 = App.bufferSize -- 596
					width, height = _obj_0.width, _obj_0.height -- 596
				end -- 596
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 597
			end) -- 595
			root:addChild((function() -- 598
				local _with_0 = ScrollArea({ -- 599
					width = width, -- 599
					height = height, -- 600
					paddingX = 0, -- 601
					paddingY = 50, -- 602
					viewWidth = height, -- 603
					viewHeight = height -- 604
				}) -- 598
				root:slot("AlignLayout", function(w, h) -- 606
					_with_0.position = Vec2(w / 2, h / 2) -- 607
					w = w - 20 -- 608
					h = h - 20 -- 609
					_with_0.view.children.first.textWidth = w - fontSize -- 610
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 611
				end) -- 606
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 612
				return _with_0 -- 598
			end)()) -- 598
			return root -- 592
		end)()) -- 592
		return err -- 616
	end, Content, Path, file, require, type) -- 616
end -- 563
_module_0["enterEntryAsync"] = enterEntryAsync -- 616
local enterDemoEntry -- 618
enterDemoEntry = function(entry) -- 618
	return thread(function() -- 618
		return enterEntryAsync(entry) -- 618
	end) -- 618
end -- 618
local reloadCurrentEntry -- 620
reloadCurrentEntry = function() -- 620
	if currentEntry then -- 621
		allClear() -- 622
		return enterDemoEntry(currentEntry) -- 623
	end -- 621
end -- 620
Director.clearColor = Color(0xff1a1a1a) -- 625
local waitForWebStart = true -- 627
thread(function() -- 628
	sleep(2) -- 629
	waitForWebStart = false -- 630
end) -- 628
local reloadDevEntry -- 632
reloadDevEntry = function() -- 632
	return thread(function() -- 632
		waitForWebStart = true -- 633
		doClean() -- 634
		allClear() -- 635
		_G.require = oldRequire -- 636
		Dora.require = oldRequire -- 637
		package.loaded["Script.Dev.Entry"] = nil -- 638
		return Director.systemScheduler:schedule(function() -- 639
			Routine:clear() -- 640
			oldRequire("Script.Dev.Entry") -- 641
			return true -- 642
		end) -- 642
	end) -- 642
end -- 632
local isOSSLicenseExist = Content:exist("LICENSES") -- 644
local ossLicenses = nil -- 645
local ossLicenseOpen = false -- 646
local extraOperations -- 648
extraOperations = function() -- 648
	local zh = useChinese and isChineseSupported -- 649
	if isOSSLicenseExist then -- 650
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 651
			if not ossLicenses then -- 652
				ossLicenses = { } -- 653
				local licenseText = Content:load("LICENSES") -- 654
				ossLicenseOpen = (licenseText ~= nil) -- 655
				if ossLicenseOpen then -- 655
					licenseText = licenseText:gsub("\r\n", "\n") -- 656
					for license in GSplit(licenseText, "\n--------\n", true) do -- 657
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 658
						if name then -- 658
							ossLicenses[#ossLicenses + 1] = { -- 659
								name, -- 659
								text -- 659
							} -- 659
						end -- 658
					end -- 659
				end -- 655
			else -- 661
				ossLicenseOpen = true -- 661
			end -- 652
		end -- 651
		if ossLicenseOpen then -- 662
			local width, height, themeColor -- 663
			do -- 663
				local _obj_0 = App -- 663
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 663
			end -- 663
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 664
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 665
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 666
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 669
					"NoSavedSettings" -- 669
				}, function() -- 670
					for _index_0 = 1, #ossLicenses do -- 670
						local _des_0 = ossLicenses[_index_0] -- 670
						local firstLine, text = _des_0[1], _des_0[2] -- 670
						local name, license = firstLine:match("(.+): (.+)") -- 671
						TextColored(themeColor, name) -- 672
						SameLine() -- 673
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 674
							return TextWrapped(text) -- 674
						end) -- 674
					end -- 674
				end) -- 666
			end) -- 666
		end -- 662
	end -- 650
	if not App.debugging then -- 676
		return -- 676
	end -- 676
	return TreeNode(zh and "开发操作" or "Development", function() -- 677
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 678
			OpenPopup("build") -- 678
		end -- 678
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 679
			return BeginPopup("build", function() -- 679
				if Selectable(zh and "编译" or "Compile") then -- 680
					doCompile(false) -- 680
				end -- 680
				Separator() -- 681
				if Selectable(zh and "压缩" or "Minify") then -- 682
					doCompile(true) -- 682
				end -- 682
				Separator() -- 683
				if Selectable(zh and "清理" or "Clean") then -- 684
					return doClean() -- 684
				end -- 684
			end) -- 684
		end) -- 679
		if isInEntry then -- 685
			if waitForWebStart then -- 686
				BeginDisabled(function() -- 687
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 687
				end) -- 687
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 688
				reloadDevEntry() -- 689
			end -- 686
		end -- 685
		do -- 690
			local changed -- 690
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 690
			if changed then -- 690
				View.scale = scaleContent and screenScale or 1 -- 691
			end -- 690
		end -- 690
		local changed -- 692
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 692
		if changed then -- 692
			config.engineDev = engineDev -- 693
		end -- 692
	end) -- 677
end -- 648
local transparant = Color(0x0) -- 695
local windowFlags = { -- 696
	"NoTitleBar", -- 696
	"NoResize", -- 696
	"NoMove", -- 696
	"NoCollapse", -- 696
	"NoSavedSettings", -- 696
	"NoBringToFrontOnFocus" -- 696
} -- 696
local initFooter = true -- 704
local _anon_func_2 = function(allEntries, currentIndex) -- 740
	if currentIndex > 1 then -- 740
		return allEntries[currentIndex - 1] -- 741
	else -- 743
		return allEntries[#allEntries] -- 743
	end -- 740
end -- 740
local _anon_func_3 = function(allEntries, currentIndex) -- 747
	if currentIndex < #allEntries then -- 747
		return allEntries[currentIndex + 1] -- 748
	else -- 750
		return allEntries[1] -- 750
	end -- 747
end -- 747
footerWindow = threadLoop(function() -- 705
	local zh = useChinese and isChineseSupported -- 706
	if HttpServer.wsConnectionCount > 0 then -- 707
		return -- 708
	end -- 707
	if Keyboard:isKeyDown("Escape") then -- 709
		allClear() -- 710
		App:shutdown() -- 711
	end -- 709
	do -- 712
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 713
		if ctrl and Keyboard:isKeyDown("Q") then -- 714
			stop() -- 715
		end -- 714
		if ctrl and Keyboard:isKeyDown("Z") then -- 716
			reloadCurrentEntry() -- 717
		end -- 716
		if ctrl and Keyboard:isKeyDown(",") then -- 718
			if showFooter then -- 719
				showStats = not showStats -- 719
			else -- 719
				showStats = true -- 719
			end -- 719
			showFooter = true -- 720
			config.showFooter = showFooter -- 721
			config.showStats = showStats -- 722
		end -- 718
		if ctrl and Keyboard:isKeyDown(".") then -- 723
			if showFooter then -- 724
				showConsole = not showConsole -- 724
			else -- 724
				showConsole = true -- 724
			end -- 724
			showFooter = true -- 725
			config.showFooter = showFooter -- 726
			config.showConsole = showConsole -- 727
		end -- 723
		if ctrl and Keyboard:isKeyDown("/") then -- 728
			showFooter = not showFooter -- 729
			config.showFooter = showFooter -- 730
		end -- 728
		local left = ctrl and Keyboard:isKeyDown("Left") -- 731
		local right = ctrl and Keyboard:isKeyDown("Right") -- 732
		local currentIndex = nil -- 733
		for i, entry in ipairs(allEntries) do -- 734
			if currentEntry == entry then -- 735
				currentIndex = i -- 736
			end -- 735
		end -- 736
		if left then -- 737
			allClear() -- 738
			if currentIndex == nil then -- 739
				currentIndex = #allEntries + 1 -- 739
			end -- 739
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 740
		end -- 737
		if right then -- 744
			allClear() -- 745
			if currentIndex == nil then -- 746
				currentIndex = 0 -- 746
			end -- 746
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 747
		end -- 744
	end -- 750
	if not showEntry then -- 751
		return -- 751
	end -- 751
	local width, height -- 753
	do -- 753
		local _obj_0 = App.visualSize -- 753
		width, height = _obj_0.width, _obj_0.height -- 753
	end -- 753
	SetNextWindowSize(Vec2(50, 50)) -- 754
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 755
	PushStyleColor("WindowBg", transparant, function() -- 756
		return Begin("Show", windowFlags, function() -- 756
			if isInEntry or width >= 540 then -- 757
				local changed -- 758
				changed, showFooter = Checkbox("##dev", showFooter) -- 758
				if changed then -- 758
					config.showFooter = showFooter -- 759
				end -- 758
			end -- 757
		end) -- 759
	end) -- 756
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 761
		reloadDevEntry() -- 765
	end -- 761
	if initFooter then -- 766
		initFooter = false -- 767
	else -- 769
		if not showFooter then -- 769
			return -- 769
		end -- 769
	end -- 766
	SetNextWindowSize(Vec2(width, 50)) -- 771
	SetNextWindowPos(Vec2(0, height - 50)) -- 772
	SetNextWindowBgAlpha(0.35) -- 773
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 774
		return Begin("Footer", windowFlags, function() -- 774
			Dummy(Vec2(width - 20, 0)) -- 775
			do -- 776
				local changed -- 776
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 776
				if changed then -- 776
					config.showStats = showStats -- 777
				end -- 776
			end -- 776
			SameLine() -- 778
			do -- 779
				local changed -- 779
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 779
				if changed then -- 779
					config.showConsole = showConsole -- 780
				end -- 779
			end -- 779
			if config.updateNotification then -- 781
				SameLine() -- 782
				if ImGui.Button(zh and "更新可用" or "Update Available") then -- 783
					config.updateNotification = false -- 784
					enterDemoEntry({ -- 785
						"SelfUpdater", -- 785
						Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 785
					}) -- 785
				end -- 783
			end -- 781
			if not isInEntry then -- 786
				SameLine() -- 787
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 788
					allClear() -- 789
					isInEntry = true -- 790
					currentEntry = nil -- 791
				end -- 788
				local currentIndex = nil -- 792
				for i, entry in ipairs(allEntries) do -- 793
					if currentEntry == entry then -- 794
						currentIndex = i -- 795
					end -- 794
				end -- 795
				if currentIndex then -- 796
					if currentIndex > 1 then -- 797
						SameLine() -- 798
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 799
							allClear() -- 800
							enterDemoEntry(allEntries[currentIndex - 1]) -- 801
						end -- 799
					end -- 797
					if currentIndex < #allEntries then -- 802
						SameLine() -- 803
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 804
							allClear() -- 805
							enterDemoEntry(allEntries[currentIndex + 1]) -- 806
						end -- 804
					end -- 802
				end -- 796
				SameLine() -- 807
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 808
					reloadCurrentEntry() -- 809
				end -- 808
			end -- 786
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 810
				if showStats then -- 811
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 812
					showStats = ShowStats(showStats, extraOperations) -- 813
					config.showStats = showStats -- 814
				end -- 811
				if showConsole then -- 815
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 816
					showConsole = ShowConsole(showConsole) -- 817
					config.showConsole = showConsole -- 818
				end -- 815
			end) -- 818
		end) -- 818
	end) -- 818
end) -- 705
local MaxWidth <const> = 800 -- 820
local displayWindowFlags = { -- 822
	"NoDecoration", -- 822
	"NoSavedSettings", -- 822
	"NoFocusOnAppearing", -- 822
	"NoNav", -- 822
	"NoMove", -- 822
	"NoScrollWithMouse", -- 822
	"AlwaysAutoResize", -- 822
	"NoBringToFrontOnFocus" -- 822
} -- 822
local webStatus = nil -- 833
local descColor = Color(0xffa1a1a1) -- 834
local gameOpen = #gamesInDev == 0 -- 835
local toolOpen = false -- 836
local exampleOpen = false -- 837
local testOpen = false -- 838
local filterText = nil -- 839
local anyEntryMatched = false -- 840
local urlClicked = nil -- 841
local match -- 842
match = function(name) -- 842
	local res = not filterText or name:lower():match(filterText) -- 843
	if res then -- 844
		anyEntryMatched = true -- 844
	end -- 844
	return res -- 845
end -- 842
local iconTex = nil -- 846
thread(function() -- 847
	if Cache:loadAsync("Image/icon_s.png") then -- 848
		iconTex = Texture2D("Image/icon_s.png") -- 849
	end -- 848
end) -- 847
entryWindow = threadLoop(function() -- 851
	if App.fpsLimited ~= config.fpsLimited then -- 852
		config.fpsLimited = App.fpsLimited -- 853
	end -- 852
	if App.targetFPS ~= config.targetFPS then -- 854
		config.targetFPS = App.targetFPS -- 855
	end -- 854
	if View.vsync ~= config.vsync then -- 856
		config.vsync = View.vsync -- 857
	end -- 856
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 858
		config.fixedFPS = Director.scheduler.fixedFPS -- 859
	end -- 858
	if Director.profilerSending ~= config.webProfiler then -- 860
		config.webProfiler = Director.profilerSending -- 861
	end -- 860
	if urlClicked then -- 862
		local _, result = coroutine.resume(urlClicked) -- 863
		if result then -- 864
			coroutine.close(urlClicked) -- 865
			urlClicked = nil -- 866
		end -- 864
	end -- 862
	if not showEntry then -- 867
		return -- 867
	end -- 867
	if not isInEntry then -- 868
		return -- 868
	end -- 868
	local zh = useChinese and isChineseSupported -- 869
	if HttpServer.wsConnectionCount > 0 then -- 870
		local themeColor = App.themeColor -- 871
		local width, height -- 872
		do -- 872
			local _obj_0 = App.visualSize -- 872
			width, height = _obj_0.width, _obj_0.height -- 872
		end -- 872
		SetNextWindowBgAlpha(0.5) -- 873
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 874
		Begin("Web IDE Connected", displayWindowFlags, function() -- 875
			Separator() -- 876
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 877
			if iconTex then -- 878
				Image("Image/icon_s.png", Vec2(24, 24)) -- 879
				SameLine() -- 880
			end -- 878
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 881
			TextColored(descColor, slogon) -- 882
			return Separator() -- 883
		end) -- 875
		return -- 884
	end -- 870
	local themeColor = App.themeColor -- 886
	local fullWidth, height -- 887
	do -- 887
		local _obj_0 = App.visualSize -- 887
		fullWidth, height = _obj_0.width, _obj_0.height -- 887
	end -- 887
	SetNextWindowBgAlpha(0.85) -- 889
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 890
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 891
		return Begin("Web IDE", displayWindowFlags, function() -- 892
			Separator() -- 893
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 894
			SameLine() -- 895
			TextDisabled('(?)') -- 896
			if IsItemHovered() then -- 897
				BeginTooltip(function() -- 898
					return PushTextWrapPos(280, function() -- 899
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 900
					end) -- 900
				end) -- 898
			end -- 897
			do -- 901
				local url -- 901
				if webStatus ~= nil then -- 901
					url = webStatus.url -- 901
				end -- 901
				if url then -- 901
					if isDesktop and not config.fullScreen then -- 902
						if urlClicked then -- 903
							BeginDisabled(function() -- 904
								return Button(url) -- 904
							end) -- 904
						elseif Button(url) then -- 905
							urlClicked = once(function() -- 906
								return sleep(5) -- 906
							end) -- 906
							App:openURL("http://localhost:8866") -- 907
						end -- 903
					else -- 909
						TextColored(descColor, url) -- 909
					end -- 902
				else -- 911
					TextColored(descColor, zh and '不可用' or 'not available') -- 911
				end -- 901
			end -- 901
			return Separator() -- 912
		end) -- 912
	end) -- 891
	local width = math.min(MaxWidth, fullWidth) -- 914
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 915
	local maxColumns = math.max(math.floor(width / 200), 1) -- 916
	SetNextWindowPos(Vec2.zero) -- 917
	SetNextWindowBgAlpha(0) -- 918
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 919
		return Begin("Dora Dev", displayWindowFlags, function() -- 920
			Dummy(Vec2(fullWidth - 20, 0)) -- 921
			if iconTex then -- 922
				Image("Image/icon_s.png", Vec2(24, 24)) -- 923
				SameLine() -- 924
			end -- 922
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 925
			SameLine() -- 926
			if fullWidth >= 360 then -- 927
				Dummy(Vec2(fullWidth - 360, 0)) -- 928
				SameLine() -- 929
				SetNextItemWidth(-50) -- 930
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 931
					"AutoSelectAll" -- 931
				}) then -- 931
					config.filter = filterBuf.text -- 932
				end -- 931
			end -- 927
			Separator() -- 933
			return Dummy(Vec2(fullWidth - 20, 0)) -- 934
		end) -- 934
	end) -- 919
	anyEntryMatched = false -- 936
	SetNextWindowPos(Vec2(0, 50)) -- 937
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 938
	return PushStyleColor("WindowBg", transparant, function() -- 939
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 939
			return Begin("Content", windowFlags, function() -- 940
				filterText = filterBuf.text:match("[^%%%.%[]+") -- 941
				if filterText then -- 942
					filterText = filterText:lower() -- 942
				end -- 942
				if #gamesInDev > 0 then -- 943
					for _index_0 = 1, #gamesInDev do -- 944
						local game = gamesInDev[_index_0] -- 944
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 945
						local showSep = false -- 946
						if match(gameName) then -- 947
							Columns(1, false) -- 948
							TextColored(themeColor, zh and "项目：" or "Project:") -- 949
							SameLine() -- 950
							Text(gameName) -- 951
							Separator() -- 952
							if bannerFile then -- 953
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 954
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 955
								local sizing <const> = 0.8 -- 956
								texHeight = displayWidth * sizing * texHeight / texWidth -- 957
								texWidth = displayWidth * sizing -- 958
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 959
								Dummy(Vec2(padding, 0)) -- 960
								SameLine() -- 961
								PushID(fileName, function() -- 962
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 963
										return enterDemoEntry(game) -- 964
									end -- 963
								end) -- 962
							else -- 966
								PushID(fileName, function() -- 966
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 967
										return enterDemoEntry(game) -- 968
									end -- 967
								end) -- 966
							end -- 953
							NextColumn() -- 969
							showSep = true -- 970
						end -- 947
						if #examples > 0 then -- 971
							local showExample = false -- 972
							for _index_1 = 1, #examples do -- 973
								local example = examples[_index_1] -- 973
								if match(example[1]) then -- 974
									showExample = true -- 975
									break -- 976
								end -- 974
							end -- 976
							if showExample then -- 977
								Columns(1, false) -- 978
								TextColored(themeColor, zh and "示例：" or "Example:") -- 979
								SameLine() -- 980
								Text(gameName) -- 981
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 982
									Columns(maxColumns, false) -- 983
									for _index_1 = 1, #examples do -- 984
										local example = examples[_index_1] -- 984
										if not match(example[1]) then -- 985
											goto _continue_0 -- 985
										end -- 985
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 986
											if Button(example[1], Vec2(-1, 40)) then -- 987
												enterDemoEntry(example) -- 988
											end -- 987
											return NextColumn() -- 989
										end) -- 986
										showSep = true -- 990
										::_continue_0:: -- 985
									end -- 990
								end) -- 982
							end -- 977
						end -- 971
						if #tests > 0 then -- 991
							local showTest = false -- 992
							for _index_1 = 1, #tests do -- 993
								local test = tests[_index_1] -- 993
								if match(test[1]) then -- 994
									showTest = true -- 995
									break -- 996
								end -- 994
							end -- 996
							if showTest then -- 997
								Columns(1, false) -- 998
								TextColored(themeColor, zh and "测试：" or "Test:") -- 999
								SameLine() -- 1000
								Text(gameName) -- 1001
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1002
									Columns(maxColumns, false) -- 1003
									for _index_1 = 1, #tests do -- 1004
										local test = tests[_index_1] -- 1004
										if not match(test[1]) then -- 1005
											goto _continue_0 -- 1005
										end -- 1005
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1006
											if Button(test[1], Vec2(-1, 40)) then -- 1007
												enterDemoEntry(test) -- 1008
											end -- 1007
											return NextColumn() -- 1009
										end) -- 1006
										showSep = true -- 1010
										::_continue_0:: -- 1005
									end -- 1010
								end) -- 1002
							end -- 997
						end -- 991
						if showSep then -- 1011
							Columns(1, false) -- 1012
							Separator() -- 1013
						end -- 1011
					end -- 1013
				end -- 943
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1014
					local showGame = false -- 1015
					for _index_0 = 1, #games do -- 1016
						local _des_0 = games[_index_0] -- 1016
						local name = _des_0[1] -- 1016
						if match(name) then -- 1017
							showGame = true -- 1017
						end -- 1017
					end -- 1017
					local showTool = false -- 1018
					for _index_0 = 1, #doraTools do -- 1019
						local _des_0 = doraTools[_index_0] -- 1019
						local name = _des_0[1] -- 1019
						if match(name) then -- 1020
							showTool = true -- 1020
						end -- 1020
					end -- 1020
					local showExample = false -- 1021
					for _index_0 = 1, #doraExamples do -- 1022
						local _des_0 = doraExamples[_index_0] -- 1022
						local name = _des_0[1] -- 1022
						if match(name) then -- 1023
							showExample = true -- 1023
						end -- 1023
					end -- 1023
					local showTest = false -- 1024
					for _index_0 = 1, #doraTests do -- 1025
						local _des_0 = doraTests[_index_0] -- 1025
						local name = _des_0[1] -- 1025
						if match(name) then -- 1026
							showTest = true -- 1026
						end -- 1026
					end -- 1026
					for _index_0 = 1, #cppTests do -- 1027
						local _des_0 = cppTests[_index_0] -- 1027
						local name = _des_0[1] -- 1027
						if match(name) then -- 1028
							showTest = true -- 1028
						end -- 1028
					end -- 1028
					if not (showGame or showTool or showExample or showTest) then -- 1029
						goto endEntry -- 1029
					end -- 1029
					Columns(1, false) -- 1030
					TextColored(themeColor, "Dora SSR:") -- 1031
					SameLine() -- 1032
					Text(zh and "开发示例" or "Development Showcase") -- 1033
					Separator() -- 1034
					local demoViewWith <const> = 400 -- 1035
					if #games > 0 and showGame then -- 1036
						local opened -- 1037
						if (filterText ~= nil) then -- 1037
							opened = showGame -- 1037
						else -- 1037
							opened = false -- 1037
						end -- 1037
						SetNextItemOpen(gameOpen) -- 1038
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1039
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 1040
							Columns(columns, false) -- 1041
							for _index_0 = 1, #games do -- 1042
								local game = games[_index_0] -- 1042
								if not match(game[1]) then -- 1043
									goto _continue_0 -- 1043
								end -- 1043
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1044
								if columns > 1 then -- 1045
									if bannerFile then -- 1046
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1047
										local displayWidth <const> = demoViewWith - 40 -- 1048
										texHeight = displayWidth * texHeight / texWidth -- 1049
										texWidth = displayWidth -- 1050
										Text(gameName) -- 1051
										PushID(fileName, function() -- 1052
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1053
												return enterDemoEntry(game) -- 1054
											end -- 1053
										end) -- 1052
									else -- 1056
										PushID(fileName, function() -- 1056
											if Button(gameName, Vec2(-1, 40)) then -- 1057
												return enterDemoEntry(game) -- 1058
											end -- 1057
										end) -- 1056
									end -- 1046
								else -- 1060
									if bannerFile then -- 1060
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1061
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1062
										local sizing = 0.8 -- 1063
										texHeight = displayWidth * sizing * texHeight / texWidth -- 1064
										texWidth = displayWidth * sizing -- 1065
										if texWidth > 500 then -- 1066
											sizing = 0.6 -- 1067
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1068
											texWidth = displayWidth * sizing -- 1069
										end -- 1066
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1070
										Dummy(Vec2(padding, 0)) -- 1071
										SameLine() -- 1072
										Text(gameName) -- 1073
										Dummy(Vec2(padding, 0)) -- 1074
										SameLine() -- 1075
										PushID(fileName, function() -- 1076
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1077
												return enterDemoEntry(game) -- 1078
											end -- 1077
										end) -- 1076
									else -- 1080
										PushID(fileName, function() -- 1080
											if Button(gameName, Vec2(-1, 40)) then -- 1081
												return enterDemoEntry(game) -- 1082
											end -- 1081
										end) -- 1080
									end -- 1060
								end -- 1045
								NextColumn() -- 1083
								::_continue_0:: -- 1043
							end -- 1083
							Columns(1, false) -- 1084
							opened = true -- 1085
						end) -- 1039
						gameOpen = opened -- 1086
					end -- 1036
					if #doraTools > 0 and showTool then -- 1087
						local opened -- 1088
						if (filterText ~= nil) then -- 1088
							opened = showTool -- 1088
						else -- 1088
							opened = false -- 1088
						end -- 1088
						SetNextItemOpen(toolOpen) -- 1089
						TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1090
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1091
								Columns(maxColumns, false) -- 1092
								for _index_0 = 1, #doraTools do -- 1093
									local example = doraTools[_index_0] -- 1093
									if not match(example[1]) then -- 1094
										goto _continue_0 -- 1094
									end -- 1094
									if Button(example[1], Vec2(-1, 40)) then -- 1095
										enterDemoEntry(example) -- 1096
									end -- 1095
									NextColumn() -- 1097
									::_continue_0:: -- 1094
								end -- 1097
								Columns(1, false) -- 1098
								opened = true -- 1099
							end) -- 1091
						end) -- 1090
						toolOpen = opened -- 1100
					end -- 1087
					if #doraExamples > 0 and showExample then -- 1101
						local opened -- 1102
						if (filterText ~= nil) then -- 1102
							opened = showExample -- 1102
						else -- 1102
							opened = false -- 1102
						end -- 1102
						SetNextItemOpen(exampleOpen) -- 1103
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1104
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1105
								Columns(maxColumns, false) -- 1106
								for _index_0 = 1, #doraExamples do -- 1107
									local example = doraExamples[_index_0] -- 1107
									if not match(example[1]) then -- 1108
										goto _continue_0 -- 1108
									end -- 1108
									if Button(example[1], Vec2(-1, 40)) then -- 1109
										enterDemoEntry(example) -- 1110
									end -- 1109
									NextColumn() -- 1111
									::_continue_0:: -- 1108
								end -- 1111
								Columns(1, false) -- 1112
								opened = true -- 1113
							end) -- 1105
						end) -- 1104
						exampleOpen = opened -- 1114
					end -- 1101
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1115
						local opened -- 1116
						if (filterText ~= nil) then -- 1116
							opened = showTest -- 1116
						else -- 1116
							opened = false -- 1116
						end -- 1116
						SetNextItemOpen(testOpen) -- 1117
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1118
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1119
								Columns(maxColumns, false) -- 1120
								for _index_0 = 1, #doraTests do -- 1121
									local test = doraTests[_index_0] -- 1121
									if not match(test[1]) then -- 1122
										goto _continue_0 -- 1122
									end -- 1122
									if Button(test[1], Vec2(-1, 40)) then -- 1123
										enterDemoEntry(test) -- 1124
									end -- 1123
									NextColumn() -- 1125
									::_continue_0:: -- 1122
								end -- 1125
								for _index_0 = 1, #cppTests do -- 1126
									local test = cppTests[_index_0] -- 1126
									if not match(test[1]) then -- 1127
										goto _continue_1 -- 1127
									end -- 1127
									if Button(test[1], Vec2(-1, 40)) then -- 1128
										enterDemoEntry(test) -- 1129
									end -- 1128
									NextColumn() -- 1130
									::_continue_1:: -- 1127
								end -- 1130
								opened = true -- 1131
							end) -- 1119
						end) -- 1118
						testOpen = opened -- 1132
					end -- 1115
				end -- 1014
				::endEntry:: -- 1133
				if not anyEntryMatched then -- 1134
					SetNextWindowBgAlpha(0) -- 1135
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1136
					Begin("Entries Not Found", displayWindowFlags, function() -- 1137
						Separator() -- 1138
						TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1139
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1140
						return Separator() -- 1141
					end) -- 1137
				end -- 1134
				Columns(1, false) -- 1142
				Dummy(Vec2(100, 80)) -- 1143
				return ScrollWhenDraggingOnVoid() -- 1144
			end) -- 1144
		end) -- 1144
	end) -- 1144
end) -- 851
webStatus = require("Script.Dev.WebServer") -- 1146
return _module_0 -- 1146
