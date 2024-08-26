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
		print("Cleaned: " .. tostring(targetDir)) -- 481
	end -- 480
	Content:remove(Path(writablePath, ".upload")) -- 482
	return Content:remove(Path(writablePath, ".download")) -- 483
end -- 475
local screenScale = 2.0 -- 485
local scaleContent = false -- 486
local isInEntry = true -- 487
local currentEntry = nil -- 488
local footerWindow = nil -- 490
local entryWindow = nil -- 491
local setupEventHandlers = nil -- 493
local allClear -- 495
allClear = function() -- 495
	local _list_0 = Routine -- 496
	for _index_0 = 1, #_list_0 do -- 496
		local routine = _list_0[_index_0] -- 496
		if footerWindow == routine or entryWindow == routine then -- 498
			goto _continue_0 -- 499
		else -- 501
			Routine:remove(routine) -- 501
		end -- 501
		::_continue_0:: -- 497
	end -- 501
	for _index_0 = 1, #moduleCache do -- 502
		local module = moduleCache[_index_0] -- 502
		package.loaded[module] = nil -- 503
	end -- 503
	moduleCache = { } -- 504
	Director:cleanup() -- 505
	Cache:unload() -- 506
	Entity:clear() -- 507
	Platformer.Data:clear() -- 508
	Platformer.UnitAction:clear() -- 509
	Audio:stopStream(0.5) -- 510
	Struct:clear() -- 511
	View.postEffect = nil -- 512
	View.scale = scaleContent and screenScale or 1 -- 513
	Director.clearColor = Color(0xff1a1a1a) -- 514
	teal.clear() -- 515
	yue.clear() -- 516
	for _, item in pairs(ubox()) do -- 517
		local node = tolua.cast(item, "Node") -- 518
		if node then -- 518
			node:cleanup() -- 518
		end -- 518
	end -- 518
	collectgarbage() -- 519
	collectgarbage() -- 520
	setupEventHandlers() -- 521
	Content.searchPaths = searchPaths -- 522
	App.idled = true -- 523
	return Wasm:clear() -- 524
end -- 495
_module_0["allClear"] = allClear -- 524
setupEventHandlers = function() -- 526
	local _with_0 = Director.postNode -- 527
	_with_0:gslot("AppQuit", allClear) -- 528
	_with_0:gslot("AppTheme", function(argb) -- 529
		config.themeColor = argb -- 530
	end) -- 529
	_with_0:gslot("AppLocale", function(locale) -- 531
		config.locale = locale -- 532
		updateLocale() -- 533
		return teal.clear(true) -- 534
	end) -- 531
	_with_0:gslot("AppWSClose", function() -- 535
		if HttpServer.wsConnectionCount == 0 then -- 536
			return updateEntries() -- 537
		end -- 536
	end) -- 535
	local _exp_0 = App.platform -- 538
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 538
		_with_0:gslot("AppSizeChanged", function() -- 539
			local width, height -- 540
			do -- 540
				local _obj_0 = App.winSize -- 540
				width, height = _obj_0.width, _obj_0.height -- 540
			end -- 540
			config.winWidth = width -- 541
			config.winHeight = height -- 542
		end) -- 539
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 543
			config.fullScreen = fullScreen -- 544
		end) -- 543
		_with_0:gslot("AppMoved", function() -- 545
			local _obj_0 = App.winPosition -- 546
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 546
		end) -- 545
	end -- 546
	return _with_0 -- 527
end -- 526
setupEventHandlers() -- 548
local stop -- 550
stop = function() -- 550
	if isInEntry then -- 551
		return false -- 551
	end -- 551
	allClear() -- 552
	isInEntry = true -- 553
	currentEntry = nil -- 554
	return true -- 555
end -- 550
_module_0["stop"] = stop -- 555
local _anon_func_0 = function(Content, Path, file, require, type) -- 577
	local scriptPath = Path:getPath(file) -- 570
	Content:insertSearchPath(1, scriptPath) -- 571
	scriptPath = Path(scriptPath, "Script") -- 572
	if Content:exist(scriptPath) then -- 573
		Content:insertSearchPath(1, scriptPath) -- 574
	end -- 573
	local result = require(file) -- 575
	if "function" == type(result) then -- 576
		result() -- 576
	end -- 576
	return nil -- 577
end -- 570
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 609
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 606
	label.alignment = "Left" -- 607
	label.textWidth = width - fontSize -- 608
	label.text = err -- 609
	return label -- 606
end -- 606
local enterEntryAsync -- 557
enterEntryAsync = function(entry) -- 557
	isInEntry = false -- 558
	App.idled = false -- 559
	emit(Profiler.EventName, "ClearLoader") -- 560
	currentEntry = entry -- 561
	local name, file = entry[1], entry[2] -- 562
	if cppTestSet[entry] then -- 563
		if App:runTest(name) then -- 564
			return true -- 565
		else -- 567
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 567
		end -- 564
	end -- 563
	sleep() -- 568
	return xpcall(_anon_func_0, function(msg) -- 577
		local err = debug.traceback(msg) -- 579
		allClear() -- 580
		print(err) -- 581
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 582
		local viewWidth, viewHeight -- 583
		do -- 583
			local _obj_0 = View.size -- 583
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 583
		end -- 583
		local width, height = viewWidth - 20, viewHeight - 20 -- 584
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 585
		Director.ui:addChild((function() -- 586
			local root = AlignNode() -- 586
			do -- 587
				local _obj_0 = App.bufferSize -- 587
				width, height = _obj_0.width, _obj_0.height -- 587
			end -- 587
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 588
			root:gslot("AppSizeChanged", function() -- 589
				do -- 590
					local _obj_0 = App.bufferSize -- 590
					width, height = _obj_0.width, _obj_0.height -- 590
				end -- 590
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 591
			end) -- 589
			root:addChild((function() -- 592
				local _with_0 = ScrollArea({ -- 593
					width = width, -- 593
					height = height, -- 594
					paddingX = 0, -- 595
					paddingY = 50, -- 596
					viewWidth = height, -- 597
					viewHeight = height -- 598
				}) -- 592
				root:slot("AlignLayout", function(w, h) -- 600
					_with_0.position = Vec2(w / 2, h / 2) -- 601
					w = w - 20 -- 602
					h = h - 20 -- 603
					_with_0.view.children.first.textWidth = w - fontSize -- 604
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 605
				end) -- 600
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 606
				return _with_0 -- 592
			end)()) -- 592
			return root -- 586
		end)()) -- 586
		return err -- 610
	end, Content, Path, file, require, type) -- 610
end -- 557
_module_0["enterEntryAsync"] = enterEntryAsync -- 610
local enterDemoEntry -- 612
enterDemoEntry = function(entry) -- 612
	return thread(function() -- 612
		return enterEntryAsync(entry) -- 612
	end) -- 612
end -- 612
local reloadCurrentEntry -- 614
reloadCurrentEntry = function() -- 614
	if currentEntry then -- 615
		allClear() -- 616
		return enterDemoEntry(currentEntry) -- 617
	end -- 615
end -- 614
Director.clearColor = Color(0xff1a1a1a) -- 619
local waitForWebStart = true -- 621
thread(function() -- 622
	sleep(2) -- 623
	waitForWebStart = false -- 624
end) -- 622
local reloadDevEntry -- 626
reloadDevEntry = function() -- 626
	return thread(function() -- 626
		waitForWebStart = true -- 627
		doClean() -- 628
		allClear() -- 629
		_G.require = oldRequire -- 630
		Dora.require = oldRequire -- 631
		package.loaded["Script.Dev.Entry"] = nil -- 632
		return Director.systemScheduler:schedule(function() -- 633
			Routine:clear() -- 634
			oldRequire("Script.Dev.Entry") -- 635
			return true -- 636
		end) -- 636
	end) -- 636
end -- 626
local isOSSLicenseExist = Content:exist("LICENSES") -- 638
local ossLicenses = nil -- 639
local ossLicenseOpen = false -- 640
local extraOperations -- 642
extraOperations = function() -- 642
	local zh = useChinese and isChineseSupported -- 643
	if isOSSLicenseExist then -- 644
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 645
			if not ossLicenses then -- 646
				ossLicenses = { } -- 647
				local licenseText = Content:load("LICENSES") -- 648
				ossLicenseOpen = (licenseText ~= nil) -- 649
				if ossLicenseOpen then -- 649
					licenseText = licenseText:gsub("\r\n", "\n") -- 650
					for license in GSplit(licenseText, "\n--------\n", true) do -- 651
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 652
						if name then -- 652
							ossLicenses[#ossLicenses + 1] = { -- 653
								name, -- 653
								text -- 653
							} -- 653
						end -- 652
					end -- 653
				end -- 649
			else -- 655
				ossLicenseOpen = true -- 655
			end -- 646
		end -- 645
		if ossLicenseOpen then -- 656
			local width, height, themeColor -- 657
			do -- 657
				local _obj_0 = App -- 657
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 657
			end -- 657
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 658
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 659
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 660
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 663
					"NoSavedSettings" -- 663
				}, function() -- 664
					for _index_0 = 1, #ossLicenses do -- 664
						local _des_0 = ossLicenses[_index_0] -- 664
						local firstLine, text = _des_0[1], _des_0[2] -- 664
						local name, license = firstLine:match("(.+): (.+)") -- 665
						TextColored(themeColor, name) -- 666
						SameLine() -- 667
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 668
							return TextWrapped(text) -- 668
						end) -- 668
					end -- 668
				end) -- 660
			end) -- 660
		end -- 656
	end -- 644
	if not App.debugging then -- 670
		return -- 670
	end -- 670
	return TreeNode(zh and "开发操作" or "Development", function() -- 671
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 672
			OpenPopup("build") -- 672
		end -- 672
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 673
			return BeginPopup("build", function() -- 673
				if Selectable(zh and "编译" or "Compile") then -- 674
					doCompile(false) -- 674
				end -- 674
				Separator() -- 675
				if Selectable(zh and "压缩" or "Minify") then -- 676
					doCompile(true) -- 676
				end -- 676
				Separator() -- 677
				if Selectable(zh and "清理" or "Clean") then -- 678
					return doClean() -- 678
				end -- 678
			end) -- 678
		end) -- 673
		if isInEntry then -- 679
			if waitForWebStart then -- 680
				BeginDisabled(function() -- 681
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 681
				end) -- 681
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 682
				reloadDevEntry() -- 683
			end -- 680
		end -- 679
		do -- 684
			local changed -- 684
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 684
			if changed then -- 684
				View.scale = scaleContent and screenScale or 1 -- 685
			end -- 684
		end -- 684
		local changed -- 686
		changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 686
		if changed then -- 686
			config.engineDev = engineDev -- 687
		end -- 686
	end) -- 671
end -- 642
local transparant = Color(0x0) -- 689
local windowFlags = { -- 690
	"NoTitleBar", -- 690
	"NoResize", -- 690
	"NoMove", -- 690
	"NoCollapse", -- 690
	"NoSavedSettings", -- 690
	"NoBringToFrontOnFocus" -- 690
} -- 690
local initFooter = true -- 698
local _anon_func_2 = function(allEntries, currentIndex) -- 734
	if currentIndex > 1 then -- 734
		return allEntries[currentIndex - 1] -- 735
	else -- 737
		return allEntries[#allEntries] -- 737
	end -- 734
end -- 734
local _anon_func_3 = function(allEntries, currentIndex) -- 741
	if currentIndex < #allEntries then -- 741
		return allEntries[currentIndex + 1] -- 742
	else -- 744
		return allEntries[1] -- 744
	end -- 741
end -- 741
footerWindow = threadLoop(function() -- 699
	local zh = useChinese and isChineseSupported -- 700
	if HttpServer.wsConnectionCount > 0 then -- 701
		return -- 702
	end -- 701
	if Keyboard:isKeyDown("Escape") then -- 703
		allClear() -- 704
		App:shutdown() -- 705
	end -- 703
	do -- 706
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 707
		if ctrl and Keyboard:isKeyDown("Q") then -- 708
			stop() -- 709
		end -- 708
		if ctrl and Keyboard:isKeyDown("Z") then -- 710
			reloadCurrentEntry() -- 711
		end -- 710
		if ctrl and Keyboard:isKeyDown(",") then -- 712
			if showFooter then -- 713
				showStats = not showStats -- 713
			else -- 713
				showStats = true -- 713
			end -- 713
			showFooter = true -- 714
			config.showFooter = showFooter -- 715
			config.showStats = showStats -- 716
		end -- 712
		if ctrl and Keyboard:isKeyDown(".") then -- 717
			if showFooter then -- 718
				showConsole = not showConsole -- 718
			else -- 718
				showConsole = true -- 718
			end -- 718
			showFooter = true -- 719
			config.showFooter = showFooter -- 720
			config.showConsole = showConsole -- 721
		end -- 717
		if ctrl and Keyboard:isKeyDown("/") then -- 722
			showFooter = not showFooter -- 723
			config.showFooter = showFooter -- 724
		end -- 722
		local left = ctrl and Keyboard:isKeyDown("Left") -- 725
		local right = ctrl and Keyboard:isKeyDown("Right") -- 726
		local currentIndex = nil -- 727
		for i, entry in ipairs(allEntries) do -- 728
			if currentEntry == entry then -- 729
				currentIndex = i -- 730
			end -- 729
		end -- 730
		if left then -- 731
			allClear() -- 732
			if currentIndex == nil then -- 733
				currentIndex = #allEntries + 1 -- 733
			end -- 733
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 734
		end -- 731
		if right then -- 738
			allClear() -- 739
			if currentIndex == nil then -- 740
				currentIndex = 0 -- 740
			end -- 740
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 741
		end -- 738
	end -- 744
	if not showEntry then -- 745
		return -- 745
	end -- 745
	local width, height -- 747
	do -- 747
		local _obj_0 = App.visualSize -- 747
		width, height = _obj_0.width, _obj_0.height -- 747
	end -- 747
	SetNextWindowSize(Vec2(50, 50)) -- 748
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 749
	PushStyleColor("WindowBg", transparant, function() -- 750
		return Begin("Show", windowFlags, function() -- 750
			if isInEntry or width >= 540 then -- 751
				local changed -- 752
				changed, showFooter = Checkbox("##dev", showFooter) -- 752
				if changed then -- 752
					config.showFooter = showFooter -- 753
				end -- 752
			end -- 751
		end) -- 753
	end) -- 750
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 755
		reloadDevEntry() -- 759
	end -- 755
	if initFooter then -- 760
		initFooter = false -- 761
	else -- 763
		if not showFooter then -- 763
			return -- 763
		end -- 763
	end -- 760
	SetNextWindowSize(Vec2(width, 50)) -- 765
	SetNextWindowPos(Vec2(0, height - 50)) -- 766
	SetNextWindowBgAlpha(0.35) -- 767
	return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 768
		return Begin("Footer", windowFlags, function() -- 768
			Dummy(Vec2(width - 20, 0)) -- 769
			do -- 770
				local changed -- 770
				changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 770
				if changed then -- 770
					config.showStats = showStats -- 771
				end -- 770
			end -- 770
			SameLine() -- 772
			do -- 773
				local changed -- 773
				changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 773
				if changed then -- 773
					config.showConsole = showConsole -- 774
				end -- 773
			end -- 773
			if config.updateNotification then -- 775
				SameLine() -- 776
				if ImGui.Button(zh and "更新可用" or "Update Available") then -- 777
					config.updateNotification = false -- 778
					enterDemoEntry({ -- 779
						"SelfUpdater", -- 779
						Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 779
					}) -- 779
				end -- 777
			end -- 775
			if not isInEntry then -- 780
				SameLine() -- 781
				if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 782
					allClear() -- 783
					isInEntry = true -- 784
					currentEntry = nil -- 785
				end -- 782
				local currentIndex = nil -- 786
				for i, entry in ipairs(allEntries) do -- 787
					if currentEntry == entry then -- 788
						currentIndex = i -- 789
					end -- 788
				end -- 789
				if currentIndex then -- 790
					if currentIndex > 1 then -- 791
						SameLine() -- 792
						if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 793
							allClear() -- 794
							enterDemoEntry(allEntries[currentIndex - 1]) -- 795
						end -- 793
					end -- 791
					if currentIndex < #allEntries then -- 796
						SameLine() -- 797
						if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 798
							allClear() -- 799
							enterDemoEntry(allEntries[currentIndex + 1]) -- 800
						end -- 798
					end -- 796
				end -- 790
				SameLine() -- 801
				if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 802
					reloadCurrentEntry() -- 803
				end -- 802
			end -- 780
			return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 804
				if showStats then -- 805
					SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 806
					showStats = ShowStats(showStats, extraOperations) -- 807
					config.showStats = showStats -- 808
				end -- 805
				if showConsole then -- 809
					SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 810
					showConsole = ShowConsole(showConsole) -- 811
					config.showConsole = showConsole -- 812
				end -- 809
			end) -- 812
		end) -- 812
	end) -- 812
end) -- 699
local MaxWidth <const> = 800 -- 814
local displayWindowFlags = { -- 816
	"NoDecoration", -- 816
	"NoSavedSettings", -- 816
	"NoFocusOnAppearing", -- 816
	"NoNav", -- 816
	"NoMove", -- 816
	"NoScrollWithMouse", -- 816
	"AlwaysAutoResize", -- 816
	"NoBringToFrontOnFocus" -- 816
} -- 816
local webStatus = nil -- 827
local descColor = Color(0xffa1a1a1) -- 828
local gameOpen = #gamesInDev == 0 -- 829
local toolOpen = false -- 830
local exampleOpen = false -- 831
local testOpen = false -- 832
local filterText = nil -- 833
local anyEntryMatched = false -- 834
local urlClicked = nil -- 835
local match -- 836
match = function(name) -- 836
	local res = not filterText or name:lower():match(filterText) -- 837
	if res then -- 838
		anyEntryMatched = true -- 838
	end -- 838
	return res -- 839
end -- 836
local iconTex = nil -- 840
thread(function() -- 841
	if Cache:loadAsync("Image/icon_s.png") then -- 842
		iconTex = Texture2D("Image/icon_s.png") -- 843
	end -- 842
end) -- 841
entryWindow = threadLoop(function() -- 845
	if App.fpsLimited ~= config.fpsLimited then -- 846
		config.fpsLimited = App.fpsLimited -- 847
	end -- 846
	if App.targetFPS ~= config.targetFPS then -- 848
		config.targetFPS = App.targetFPS -- 849
	end -- 848
	if View.vsync ~= config.vsync then -- 850
		config.vsync = View.vsync -- 851
	end -- 850
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 852
		config.fixedFPS = Director.scheduler.fixedFPS -- 853
	end -- 852
	if Director.profilerSending ~= config.webProfiler then -- 854
		config.webProfiler = Director.profilerSending -- 855
	end -- 854
	if urlClicked then -- 856
		local _, result = coroutine.resume(urlClicked) -- 857
		if result then -- 858
			coroutine.close(urlClicked) -- 859
			urlClicked = nil -- 860
		end -- 858
	end -- 856
	if not showEntry then -- 861
		return -- 861
	end -- 861
	if not isInEntry then -- 862
		return -- 862
	end -- 862
	local zh = useChinese and isChineseSupported -- 863
	if HttpServer.wsConnectionCount > 0 then -- 864
		local themeColor = App.themeColor -- 865
		local width, height -- 866
		do -- 866
			local _obj_0 = App.visualSize -- 866
			width, height = _obj_0.width, _obj_0.height -- 866
		end -- 866
		SetNextWindowBgAlpha(0.5) -- 867
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 868
		Begin("Web IDE Connected", displayWindowFlags, function() -- 869
			Separator() -- 870
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 871
			if iconTex then -- 872
				Image("Image/icon_s.png", Vec2(24, 24)) -- 873
				SameLine() -- 874
			end -- 872
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 875
			TextColored(descColor, slogon) -- 876
			return Separator() -- 877
		end) -- 869
		return -- 878
	end -- 864
	local themeColor = App.themeColor -- 880
	local fullWidth, height -- 881
	do -- 881
		local _obj_0 = App.visualSize -- 881
		fullWidth, height = _obj_0.width, _obj_0.height -- 881
	end -- 881
	SetNextWindowBgAlpha(0.85) -- 883
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 884
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 885
		return Begin("Web IDE", displayWindowFlags, function() -- 886
			Separator() -- 887
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 888
			SameLine() -- 889
			TextDisabled('(?)') -- 890
			if IsItemHovered() then -- 891
				BeginTooltip(function() -- 892
					return PushTextWrapPos(280, function() -- 893
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 894
					end) -- 894
				end) -- 892
			end -- 891
			do -- 895
				local url -- 895
				if webStatus ~= nil then -- 895
					url = webStatus.url -- 895
				end -- 895
				if url then -- 895
					if isDesktop and not config.fullScreen then -- 896
						if urlClicked then -- 897
							BeginDisabled(function() -- 898
								return Button(url) -- 898
							end) -- 898
						elseif Button(url) then -- 899
							urlClicked = once(function() -- 900
								return sleep(5) -- 900
							end) -- 900
							App:openURL("http://localhost:8866") -- 901
						end -- 897
					else -- 903
						TextColored(descColor, url) -- 903
					end -- 896
				else -- 905
					TextColored(descColor, zh and '不可用' or 'not available') -- 905
				end -- 895
			end -- 895
			return Separator() -- 906
		end) -- 906
	end) -- 885
	local width = math.min(MaxWidth, fullWidth) -- 908
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 909
	local maxColumns = math.max(math.floor(width / 200), 1) -- 910
	SetNextWindowPos(Vec2.zero) -- 911
	SetNextWindowBgAlpha(0) -- 912
	PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 913
		return Begin("Dora Dev", displayWindowFlags, function() -- 914
			Dummy(Vec2(fullWidth - 20, 0)) -- 915
			if iconTex then -- 916
				Image("Image/icon_s.png", Vec2(24, 24)) -- 917
				SameLine() -- 918
			end -- 916
			TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 919
			SameLine() -- 920
			if fullWidth >= 360 then -- 921
				Dummy(Vec2(fullWidth - 360, 0)) -- 922
				SameLine() -- 923
				SetNextItemWidth(-50) -- 924
				if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 925
					"AutoSelectAll" -- 925
				}) then -- 925
					config.filter = filterBuf.text -- 926
				end -- 925
			end -- 921
			Separator() -- 927
			return Dummy(Vec2(fullWidth - 20, 0)) -- 928
		end) -- 928
	end) -- 913
	anyEntryMatched = false -- 930
	SetNextWindowPos(Vec2(0, 50)) -- 931
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 932
	return PushStyleColor("WindowBg", transparant, function() -- 933
		return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 933
			return Begin("Content", windowFlags, function() -- 934
				filterText = filterBuf.text:match("[^%%%.%[]+") -- 935
				if filterText then -- 936
					filterText = filterText:lower() -- 936
				end -- 936
				if #gamesInDev > 0 then -- 937
					for _index_0 = 1, #gamesInDev do -- 938
						local game = gamesInDev[_index_0] -- 938
						local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 939
						local showSep = false -- 940
						if match(gameName) then -- 941
							Columns(1, false) -- 942
							TextColored(themeColor, zh and "项目：" or "Project:") -- 943
							SameLine() -- 944
							Text(gameName) -- 945
							Separator() -- 946
							if bannerFile then -- 947
								local texWidth, texHeight = bannerTex.width, bannerTex.height -- 948
								local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 949
								local sizing <const> = 0.8 -- 950
								texHeight = displayWidth * sizing * texHeight / texWidth -- 951
								texWidth = displayWidth * sizing -- 952
								local padding = displayWidth * (1 - sizing) / 2 - 10 -- 953
								Dummy(Vec2(padding, 0)) -- 954
								SameLine() -- 955
								PushID(fileName, function() -- 956
									if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 957
										return enterDemoEntry(game) -- 958
									end -- 957
								end) -- 956
							else -- 960
								PushID(fileName, function() -- 960
									if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 961
										return enterDemoEntry(game) -- 962
									end -- 961
								end) -- 960
							end -- 947
							NextColumn() -- 963
							showSep = true -- 964
						end -- 941
						if #examples > 0 then -- 965
							local showExample = false -- 966
							for _index_1 = 1, #examples do -- 967
								local example = examples[_index_1] -- 967
								if match(example[1]) then -- 968
									showExample = true -- 969
									break -- 970
								end -- 968
							end -- 970
							if showExample then -- 971
								Columns(1, false) -- 972
								TextColored(themeColor, zh and "示例：" or "Example:") -- 973
								SameLine() -- 974
								Text(gameName) -- 975
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 976
									Columns(maxColumns, false) -- 977
									for _index_1 = 1, #examples do -- 978
										local example = examples[_index_1] -- 978
										if not match(example[1]) then -- 979
											goto _continue_0 -- 979
										end -- 979
										PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 980
											if Button(example[1], Vec2(-1, 40)) then -- 981
												enterDemoEntry(example) -- 982
											end -- 981
											return NextColumn() -- 983
										end) -- 980
										showSep = true -- 984
										::_continue_0:: -- 979
									end -- 984
								end) -- 976
							end -- 971
						end -- 965
						if #tests > 0 then -- 985
							local showTest = false -- 986
							for _index_1 = 1, #tests do -- 987
								local test = tests[_index_1] -- 987
								if match(test[1]) then -- 988
									showTest = true -- 989
									break -- 990
								end -- 988
							end -- 990
							if showTest then -- 991
								Columns(1, false) -- 992
								TextColored(themeColor, zh and "测试：" or "Test:") -- 993
								SameLine() -- 994
								Text(gameName) -- 995
								PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 996
									Columns(maxColumns, false) -- 997
									for _index_1 = 1, #tests do -- 998
										local test = tests[_index_1] -- 998
										if not match(test[1]) then -- 999
											goto _continue_0 -- 999
										end -- 999
										PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1000
											if Button(test[1], Vec2(-1, 40)) then -- 1001
												enterDemoEntry(test) -- 1002
											end -- 1001
											return NextColumn() -- 1003
										end) -- 1000
										showSep = true -- 1004
										::_continue_0:: -- 999
									end -- 1004
								end) -- 996
							end -- 991
						end -- 985
						if showSep then -- 1005
							Columns(1, false) -- 1006
							Separator() -- 1007
						end -- 1005
					end -- 1007
				end -- 937
				if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1008
					local showGame = false -- 1009
					for _index_0 = 1, #games do -- 1010
						local _des_0 = games[_index_0] -- 1010
						local name = _des_0[1] -- 1010
						if match(name) then -- 1011
							showGame = true -- 1011
						end -- 1011
					end -- 1011
					local showTool = false -- 1012
					for _index_0 = 1, #doraTools do -- 1013
						local _des_0 = doraTools[_index_0] -- 1013
						local name = _des_0[1] -- 1013
						if match(name) then -- 1014
							showTool = true -- 1014
						end -- 1014
					end -- 1014
					local showExample = false -- 1015
					for _index_0 = 1, #doraExamples do -- 1016
						local _des_0 = doraExamples[_index_0] -- 1016
						local name = _des_0[1] -- 1016
						if match(name) then -- 1017
							showExample = true -- 1017
						end -- 1017
					end -- 1017
					local showTest = false -- 1018
					for _index_0 = 1, #doraTests do -- 1019
						local _des_0 = doraTests[_index_0] -- 1019
						local name = _des_0[1] -- 1019
						if match(name) then -- 1020
							showTest = true -- 1020
						end -- 1020
					end -- 1020
					for _index_0 = 1, #cppTests do -- 1021
						local _des_0 = cppTests[_index_0] -- 1021
						local name = _des_0[1] -- 1021
						if match(name) then -- 1022
							showTest = true -- 1022
						end -- 1022
					end -- 1022
					if not (showGame or showTool or showExample or showTest) then -- 1023
						goto endEntry -- 1023
					end -- 1023
					Columns(1, false) -- 1024
					TextColored(themeColor, "Dora SSR:") -- 1025
					SameLine() -- 1026
					Text(zh and "开发示例" or "Development Showcase") -- 1027
					Separator() -- 1028
					local demoViewWith <const> = 400 -- 1029
					if #games > 0 and showGame then -- 1030
						local opened -- 1031
						if (filterText ~= nil) then -- 1031
							opened = showGame -- 1031
						else -- 1031
							opened = false -- 1031
						end -- 1031
						SetNextItemOpen(gameOpen) -- 1032
						TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1033
							local columns = math.max(math.floor(width / demoViewWith), 1) -- 1034
							Columns(columns, false) -- 1035
							for _index_0 = 1, #games do -- 1036
								local game = games[_index_0] -- 1036
								if not match(game[1]) then -- 1037
									goto _continue_0 -- 1037
								end -- 1037
								local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1038
								if columns > 1 then -- 1039
									if bannerFile then -- 1040
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1041
										local displayWidth <const> = demoViewWith - 40 -- 1042
										texHeight = displayWidth * texHeight / texWidth -- 1043
										texWidth = displayWidth -- 1044
										Text(gameName) -- 1045
										PushID(fileName, function() -- 1046
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1047
												return enterDemoEntry(game) -- 1048
											end -- 1047
										end) -- 1046
									else -- 1050
										PushID(fileName, function() -- 1050
											if Button(gameName, Vec2(-1, 40)) then -- 1051
												return enterDemoEntry(game) -- 1052
											end -- 1051
										end) -- 1050
									end -- 1040
								else -- 1054
									if bannerFile then -- 1054
										local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1055
										local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1056
										local sizing = 0.8 -- 1057
										texHeight = displayWidth * sizing * texHeight / texWidth -- 1058
										texWidth = displayWidth * sizing -- 1059
										if texWidth > 500 then -- 1060
											sizing = 0.6 -- 1061
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1062
											texWidth = displayWidth * sizing -- 1063
										end -- 1060
										local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1064
										Dummy(Vec2(padding, 0)) -- 1065
										SameLine() -- 1066
										Text(gameName) -- 1067
										Dummy(Vec2(padding, 0)) -- 1068
										SameLine() -- 1069
										PushID(fileName, function() -- 1070
											if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1071
												return enterDemoEntry(game) -- 1072
											end -- 1071
										end) -- 1070
									else -- 1074
										PushID(fileName, function() -- 1074
											if Button(gameName, Vec2(-1, 40)) then -- 1075
												return enterDemoEntry(game) -- 1076
											end -- 1075
										end) -- 1074
									end -- 1054
								end -- 1039
								NextColumn() -- 1077
								::_continue_0:: -- 1037
							end -- 1077
							Columns(1, false) -- 1078
							opened = true -- 1079
						end) -- 1033
						gameOpen = opened -- 1080
					end -- 1030
					if #doraTools > 0 and showTool then -- 1081
						local opened -- 1082
						if (filterText ~= nil) then -- 1082
							opened = showTool -- 1082
						else -- 1082
							opened = false -- 1082
						end -- 1082
						SetNextItemOpen(toolOpen) -- 1083
						TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1084
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1085
								Columns(maxColumns, false) -- 1086
								for _index_0 = 1, #doraTools do -- 1087
									local example = doraTools[_index_0] -- 1087
									if not match(example[1]) then -- 1088
										goto _continue_0 -- 1088
									end -- 1088
									if Button(example[1], Vec2(-1, 40)) then -- 1089
										enterDemoEntry(example) -- 1090
									end -- 1089
									NextColumn() -- 1091
									::_continue_0:: -- 1088
								end -- 1091
								Columns(1, false) -- 1092
								opened = true -- 1093
							end) -- 1085
						end) -- 1084
						toolOpen = opened -- 1094
					end -- 1081
					if #doraExamples > 0 and showExample then -- 1095
						local opened -- 1096
						if (filterText ~= nil) then -- 1096
							opened = showExample -- 1096
						else -- 1096
							opened = false -- 1096
						end -- 1096
						SetNextItemOpen(exampleOpen) -- 1097
						TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1098
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1099
								Columns(maxColumns, false) -- 1100
								for _index_0 = 1, #doraExamples do -- 1101
									local example = doraExamples[_index_0] -- 1101
									if not match(example[1]) then -- 1102
										goto _continue_0 -- 1102
									end -- 1102
									if Button(example[1], Vec2(-1, 40)) then -- 1103
										enterDemoEntry(example) -- 1104
									end -- 1103
									NextColumn() -- 1105
									::_continue_0:: -- 1102
								end -- 1105
								Columns(1, false) -- 1106
								opened = true -- 1107
							end) -- 1099
						end) -- 1098
						exampleOpen = opened -- 1108
					end -- 1095
					if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1109
						local opened -- 1110
						if (filterText ~= nil) then -- 1110
							opened = showTest -- 1110
						else -- 1110
							opened = false -- 1110
						end -- 1110
						SetNextItemOpen(testOpen) -- 1111
						TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1112
							return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1113
								Columns(maxColumns, false) -- 1114
								for _index_0 = 1, #doraTests do -- 1115
									local test = doraTests[_index_0] -- 1115
									if not match(test[1]) then -- 1116
										goto _continue_0 -- 1116
									end -- 1116
									if Button(test[1], Vec2(-1, 40)) then -- 1117
										enterDemoEntry(test) -- 1118
									end -- 1117
									NextColumn() -- 1119
									::_continue_0:: -- 1116
								end -- 1119
								for _index_0 = 1, #cppTests do -- 1120
									local test = cppTests[_index_0] -- 1120
									if not match(test[1]) then -- 1121
										goto _continue_1 -- 1121
									end -- 1121
									if Button(test[1], Vec2(-1, 40)) then -- 1122
										enterDemoEntry(test) -- 1123
									end -- 1122
									NextColumn() -- 1124
									::_continue_1:: -- 1121
								end -- 1124
								opened = true -- 1125
							end) -- 1113
						end) -- 1112
						testOpen = opened -- 1126
					end -- 1109
				end -- 1008
				::endEntry:: -- 1127
				if not anyEntryMatched then -- 1128
					SetNextWindowBgAlpha(0) -- 1129
					SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1130
					Begin("Entries Not Found", displayWindowFlags, function() -- 1131
						Separator() -- 1132
						TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1133
						TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1134
						return Separator() -- 1135
					end) -- 1131
				end -- 1128
				Columns(1, false) -- 1136
				Dummy(Vec2(100, 80)) -- 1137
				return ScrollWhenDraggingOnVoid() -- 1138
			end) -- 1138
		end) -- 1138
	end) -- 1138
end) -- 845
webStatus = require("Script.Dev.WebServer") -- 1140
return _module_0 -- 1140
