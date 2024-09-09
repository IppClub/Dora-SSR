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
local setmetatable = _G.setmetatable -- 1
local ipairs = _G.ipairs -- 1
local threadLoop = Dora.threadLoop -- 1
local Keyboard = Dora.Keyboard -- 1
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
local testingThread = nil -- 490
local setupEventHandlers = nil -- 492
local allClear -- 494
allClear = function() -- 494
	local _list_0 = Routine -- 495
	for _index_0 = 1, #_list_0 do -- 495
		local routine = _list_0[_index_0] -- 495
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 497
			goto _continue_0 -- 498
		else -- 500
			Routine:remove(routine) -- 500
		end -- 500
		::_continue_0:: -- 496
	end -- 500
	for _index_0 = 1, #moduleCache do -- 501
		local module = moduleCache[_index_0] -- 501
		package.loaded[module] = nil -- 502
	end -- 502
	moduleCache = { } -- 503
	Director:cleanup() -- 504
	Cache:unload() -- 505
	Entity:clear() -- 506
	Platformer.Data:clear() -- 507
	Platformer.UnitAction:clear() -- 508
	Audio:stopStream(0.5) -- 509
	Struct:clear() -- 510
	View.postEffect = nil -- 511
	View.scale = scaleContent and screenScale or 1 -- 512
	Director.clearColor = Color(0xff1a1a1a) -- 513
	teal.clear() -- 514
	yue.clear() -- 515
	for _, item in pairs(ubox()) do -- 516
		local node = tolua.cast(item, "Node") -- 517
		if node then -- 517
			node:cleanup() -- 517
		end -- 517
	end -- 517
	collectgarbage() -- 518
	collectgarbage() -- 519
	setupEventHandlers() -- 520
	Content.searchPaths = searchPaths -- 521
	App.idled = true -- 522
	return Wasm:clear() -- 523
end -- 494
_module_0["allClear"] = allClear -- 523
local clearTempFiles -- 525
clearTempFiles = function() -- 525
	local writablePath = Content.writablePath -- 526
	Content:remove(Path(writablePath, ".upload")) -- 527
	return Content:remove(Path(writablePath, ".download")) -- 528
end -- 525
local _anon_func_0 = function(App, _with_0) -- 543
	local _val_0 = App.platform -- 543
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 543
end -- 543
setupEventHandlers = function() -- 530
	local _with_0 = Director.postNode -- 531
	_with_0:onAppEvent(function(eventType) -- 532
		if eventType == "Quit" then -- 532
			allClear() -- 533
			return clearTempFiles() -- 534
		end -- 532
	end) -- 532
	_with_0:onAppChange(function(settingName) -- 535
		if "Theme" == settingName then -- 536
			config.themeColor = App.themeColor:toARGB() -- 537
		elseif "Locale" == settingName then -- 538
			config.locale = App.locale -- 539
			updateLocale() -- 540
			return teal.clear(true) -- 541
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 542
			if _anon_func_0(App, _with_0) then -- 543
				if "FullScreen" == settingName then -- 545
					config.fullScreen = App.fullScreen -- 545
				elseif "Position" == settingName then -- 546
					local _obj_0 = App.winPosition -- 546
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 546
				elseif "Size" == settingName then -- 547
					local width, height -- 548
					do -- 548
						local _obj_0 = App.winSize -- 548
						width, height = _obj_0.width, _obj_0.height -- 548
					end -- 548
					config.winWidth = width -- 549
					config.winHeight = height -- 550
				end -- 550
			end -- 543
		end -- 550
	end) -- 535
	_with_0:onAppWS(function(eventType) -- 551
		if eventType == "Close" then -- 551
			if HttpServer.wsConnectionCount == 0 then -- 552
				return updateEntries() -- 553
			end -- 552
		end -- 551
	end) -- 551
	return _with_0 -- 531
end -- 530
setupEventHandlers() -- 555
clearTempFiles() -- 556
local stop -- 558
stop = function() -- 558
	if isInEntry then -- 559
		return false -- 559
	end -- 559
	allClear() -- 560
	isInEntry = true -- 561
	currentEntry = nil -- 562
	return true -- 563
end -- 558
_module_0["stop"] = stop -- 563
local _anon_func_1 = function(Content, Path, file, require, type) -- 585
	local scriptPath = Path:getPath(file) -- 578
	Content:insertSearchPath(1, scriptPath) -- 579
	scriptPath = Path(scriptPath, "Script") -- 580
	if Content:exist(scriptPath) then -- 581
		Content:insertSearchPath(1, scriptPath) -- 582
	end -- 581
	local result = require(file) -- 583
	if "function" == type(result) then -- 584
		result() -- 584
	end -- 584
	return nil -- 585
end -- 578
local _anon_func_2 = function(Label, _with_0, err, fontSize, width) -- 617
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 614
	label.alignment = "Left" -- 615
	label.textWidth = width - fontSize -- 616
	label.text = err -- 617
	return label -- 614
end -- 614
local enterEntryAsync -- 565
enterEntryAsync = function(entry) -- 565
	isInEntry = false -- 566
	App.idled = false -- 567
	emit(Profiler.EventName, "ClearLoader") -- 568
	currentEntry = entry -- 569
	local name, file = entry[1], entry[2] -- 570
	if cppTestSet[entry] then -- 571
		if App:runTest(name) then -- 572
			return true -- 573
		else -- 575
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 575
		end -- 572
	end -- 571
	sleep() -- 576
	return xpcall(_anon_func_1, function(msg) -- 585
		local err = debug.traceback(msg) -- 587
		print(err) -- 588
		allClear() -- 589
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 590
		local viewWidth, viewHeight -- 591
		do -- 591
			local _obj_0 = View.size -- 591
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 591
		end -- 591
		local width, height = viewWidth - 20, viewHeight - 20 -- 592
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 593
		Director.ui:addChild((function() -- 594
			local root = AlignNode() -- 594
			do -- 595
				local _obj_0 = App.bufferSize -- 595
				width, height = _obj_0.width, _obj_0.height -- 595
			end -- 595
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 596
			root:onAppChange(function(settingName) -- 597
				if settingName == "Size" then -- 597
					do -- 598
						local _obj_0 = App.bufferSize -- 598
						width, height = _obj_0.width, _obj_0.height -- 598
					end -- 598
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 599
				end -- 597
			end) -- 597
			root:addChild((function() -- 600
				local _with_0 = ScrollArea({ -- 601
					width = width, -- 601
					height = height, -- 602
					paddingX = 0, -- 603
					paddingY = 50, -- 604
					viewWidth = height, -- 605
					viewHeight = height -- 606
				}) -- 600
				root:onAlignLayout(function(w, h) -- 608
					_with_0.position = Vec2(w / 2, h / 2) -- 609
					w = w - 20 -- 610
					h = h - 20 -- 611
					_with_0.view.children.first.textWidth = w - fontSize -- 612
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 613
				end) -- 608
				_with_0.view:addChild(_anon_func_2(Label, _with_0, err, fontSize, width)) -- 614
				return _with_0 -- 600
			end)()) -- 600
			return root -- 594
		end)()) -- 594
		return err -- 618
	end, Content, Path, file, require, type) -- 618
end -- 565
_module_0["enterEntryAsync"] = enterEntryAsync -- 618
local enterDemoEntry -- 620
enterDemoEntry = function(entry) -- 620
	return thread(function() -- 620
		return enterEntryAsync(entry) -- 620
	end) -- 620
end -- 620
local reloadCurrentEntry -- 622
reloadCurrentEntry = function() -- 622
	if currentEntry then -- 623
		allClear() -- 624
		return enterDemoEntry(currentEntry) -- 625
	end -- 623
end -- 622
Director.clearColor = Color(0xff1a1a1a) -- 627
local waitForWebStart = true -- 629
thread(function() -- 630
	sleep(2) -- 631
	waitForWebStart = false -- 632
end) -- 630
local reloadDevEntry -- 634
reloadDevEntry = function() -- 634
	return thread(function() -- 634
		waitForWebStart = true -- 635
		doClean() -- 636
		allClear() -- 637
		_G.require = oldRequire -- 638
		Dora.require = oldRequire -- 639
		package.loaded["Script.Dev.Entry"] = nil -- 640
		return Director.systemScheduler:schedule(function() -- 641
			Routine:clear() -- 642
			oldRequire("Script.Dev.Entry") -- 643
			return true -- 644
		end) -- 644
	end) -- 644
end -- 634
local isOSSLicenseExist = Content:exist("LICENSES") -- 646
local ossLicenses = nil -- 647
local ossLicenseOpen = false -- 648
local extraOperations -- 650
extraOperations = function() -- 650
	local zh = useChinese and isChineseSupported -- 651
	if isOSSLicenseExist then -- 652
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 653
			if not ossLicenses then -- 654
				ossLicenses = { } -- 655
				local licenseText = Content:load("LICENSES") -- 656
				ossLicenseOpen = (licenseText ~= nil) -- 657
				if ossLicenseOpen then -- 657
					licenseText = licenseText:gsub("\r\n", "\n") -- 658
					for license in GSplit(licenseText, "\n--------\n", true) do -- 659
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 660
						if name then -- 660
							ossLicenses[#ossLicenses + 1] = { -- 661
								name, -- 661
								text -- 661
							} -- 661
						end -- 660
					end -- 661
				end -- 657
			else -- 663
				ossLicenseOpen = true -- 663
			end -- 654
		end -- 653
		if ossLicenseOpen then -- 664
			local width, height, themeColor -- 665
			do -- 665
				local _obj_0 = App -- 665
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 665
			end -- 665
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 666
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 667
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 668
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 671
					"NoSavedSettings" -- 671
				}, function() -- 672
					for _index_0 = 1, #ossLicenses do -- 672
						local _des_0 = ossLicenses[_index_0] -- 672
						local firstLine, text = _des_0[1], _des_0[2] -- 672
						local name, license = firstLine:match("(.+): (.+)") -- 673
						TextColored(themeColor, name) -- 674
						SameLine() -- 675
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 676
							return TextWrapped(text) -- 676
						end) -- 676
					end -- 676
				end) -- 668
			end) -- 668
		end -- 664
	end -- 652
	if not App.debugging then -- 678
		return -- 678
	end -- 678
	return TreeNode(zh and "开发操作" or "Development", function() -- 679
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 680
			OpenPopup("build") -- 680
		end -- 680
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 681
			return BeginPopup("build", function() -- 681
				if Selectable(zh and "编译" or "Compile") then -- 682
					doCompile(false) -- 682
				end -- 682
				Separator() -- 683
				if Selectable(zh and "压缩" or "Minify") then -- 684
					doCompile(true) -- 684
				end -- 684
				Separator() -- 685
				if Selectable(zh and "清理" or "Clean") then -- 686
					return doClean() -- 686
				end -- 686
			end) -- 686
		end) -- 681
		if isInEntry then -- 687
			if waitForWebStart then -- 688
				BeginDisabled(function() -- 689
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 689
				end) -- 689
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 690
				reloadDevEntry() -- 691
			end -- 688
		end -- 687
		do -- 692
			local changed -- 692
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 692
			if changed then -- 692
				View.scale = scaleContent and screenScale or 1 -- 693
			end -- 692
		end -- 692
		do -- 694
			local changed -- 694
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 694
			if changed then -- 694
				config.engineDev = engineDev -- 695
			end -- 694
		end -- 694
		if Button(zh and "开始自动测试" or "Test automatically") then -- 696
			testingThread = thread(function() -- 697
				local _ <close> = setmetatable({ }, { -- 698
					__close = function() -- 698
						allClear() -- 699
						testingThread = nil -- 700
						isInEntry = true -- 701
						currentEntry = nil -- 702
						return print("Testing done!") -- 703
					end -- 698
				}) -- 698
				for _, entry in ipairs(allEntries) do -- 704
					allClear() -- 705
					print("Start " .. tostring(entry[1])) -- 706
					enterDemoEntry(entry) -- 707
					sleep(2) -- 708
					print("Stop " .. tostring(entry[1])) -- 709
				end -- 709
			end) -- 697
		end -- 696
	end) -- 679
end -- 650
local transparant = Color(0x0) -- 711
local windowFlags = { -- 712
	"NoTitleBar", -- 712
	"NoResize", -- 712
	"NoMove", -- 712
	"NoCollapse", -- 712
	"NoSavedSettings", -- 712
	"NoBringToFrontOnFocus" -- 712
} -- 712
local initFooter = true -- 720
local _anon_func_3 = function(allEntries, currentIndex) -- 756
	if currentIndex > 1 then -- 756
		return allEntries[currentIndex - 1] -- 757
	else -- 759
		return allEntries[#allEntries] -- 759
	end -- 756
end -- 756
local _anon_func_4 = function(allEntries, currentIndex) -- 763
	if currentIndex < #allEntries then -- 763
		return allEntries[currentIndex + 1] -- 764
	else -- 766
		return allEntries[1] -- 766
	end -- 763
end -- 763
footerWindow = threadLoop(function() -- 721
	local zh = useChinese and isChineseSupported -- 722
	if HttpServer.wsConnectionCount > 0 then -- 723
		return -- 724
	end -- 723
	if Keyboard:isKeyDown("Escape") then -- 725
		allClear() -- 726
		App:shutdown() -- 727
	end -- 725
	do -- 728
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 729
		if ctrl and Keyboard:isKeyDown("Q") then -- 730
			stop() -- 731
		end -- 730
		if ctrl and Keyboard:isKeyDown("Z") then -- 732
			reloadCurrentEntry() -- 733
		end -- 732
		if ctrl and Keyboard:isKeyDown(",") then -- 734
			if showFooter then -- 735
				showStats = not showStats -- 735
			else -- 735
				showStats = true -- 735
			end -- 735
			showFooter = true -- 736
			config.showFooter = showFooter -- 737
			config.showStats = showStats -- 738
		end -- 734
		if ctrl and Keyboard:isKeyDown(".") then -- 739
			if showFooter then -- 740
				showConsole = not showConsole -- 740
			else -- 740
				showConsole = true -- 740
			end -- 740
			showFooter = true -- 741
			config.showFooter = showFooter -- 742
			config.showConsole = showConsole -- 743
		end -- 739
		if ctrl and Keyboard:isKeyDown("/") then -- 744
			showFooter = not showFooter -- 745
			config.showFooter = showFooter -- 746
		end -- 744
		local left = ctrl and Keyboard:isKeyDown("Left") -- 747
		local right = ctrl and Keyboard:isKeyDown("Right") -- 748
		local currentIndex = nil -- 749
		for i, entry in ipairs(allEntries) do -- 750
			if currentEntry == entry then -- 751
				currentIndex = i -- 752
			end -- 751
		end -- 752
		if left then -- 753
			allClear() -- 754
			if currentIndex == nil then -- 755
				currentIndex = #allEntries + 1 -- 755
			end -- 755
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 756
		end -- 753
		if right then -- 760
			allClear() -- 761
			if currentIndex == nil then -- 762
				currentIndex = 0 -- 762
			end -- 762
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 763
		end -- 760
	end -- 766
	if not showEntry then -- 767
		return -- 767
	end -- 767
	local width, height -- 769
	do -- 769
		local _obj_0 = App.visualSize -- 769
		width, height = _obj_0.width, _obj_0.height -- 769
	end -- 769
	SetNextWindowSize(Vec2(50, 50)) -- 770
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 771
	PushStyleColor("WindowBg", transparant, function() -- 772
		return Begin("Show", windowFlags, function() -- 772
			if isInEntry or width >= 540 then -- 773
				local changed -- 774
				changed, showFooter = Checkbox("##dev", showFooter) -- 774
				if changed then -- 774
					config.showFooter = showFooter -- 775
				end -- 774
			end -- 773
		end) -- 775
	end) -- 772
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 777
		reloadDevEntry() -- 781
	end -- 777
	if initFooter then -- 782
		initFooter = false -- 783
	else -- 785
		if not showFooter then -- 785
			return -- 785
		end -- 785
	end -- 782
	SetNextWindowSize(Vec2(width, 50)) -- 787
	SetNextWindowPos(Vec2(0, height - 50)) -- 788
	SetNextWindowBgAlpha(0.35) -- 789
	do -- 790
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 791
			return Begin("Footer", windowFlags, function() -- 792
				Dummy(Vec2(width - 20, 0)) -- 793
				do -- 794
					local changed -- 794
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 794
					if changed then -- 794
						config.showStats = showStats -- 795
					end -- 794
				end -- 794
				SameLine() -- 796
				do -- 797
					local changed -- 797
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 797
					if changed then -- 797
						config.showConsole = showConsole -- 798
					end -- 797
				end -- 797
				if config.updateNotification then -- 799
					SameLine() -- 800
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 801
						config.updateNotification = false -- 802
						enterDemoEntry({ -- 803
							"SelfUpdater", -- 803
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 803
						}) -- 803
					end -- 801
				end -- 799
				if not isInEntry then -- 804
					SameLine() -- 805
					if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 806
						allClear() -- 807
						isInEntry = true -- 808
						currentEntry = nil -- 809
					end -- 806
					local currentIndex = nil -- 810
					for i, entry in ipairs(allEntries) do -- 811
						if currentEntry == entry then -- 812
							currentIndex = i -- 813
						end -- 812
					end -- 813
					if currentIndex then -- 814
						if currentIndex > 1 then -- 815
							SameLine() -- 816
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 817
								allClear() -- 818
								enterDemoEntry(allEntries[currentIndex - 1]) -- 819
							end -- 817
						end -- 815
						if currentIndex < #allEntries then -- 820
							SameLine() -- 821
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 822
								allClear() -- 823
								enterDemoEntry(allEntries[currentIndex + 1]) -- 824
							end -- 822
						end -- 820
					end -- 814
					SameLine() -- 825
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 826
						reloadCurrentEntry() -- 827
					end -- 826
				end -- 804
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 828
					if showStats then -- 829
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 830
						showStats = ShowStats(showStats, extraOperations) -- 831
						config.showStats = showStats -- 832
					end -- 829
					if showConsole then -- 833
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 834
						showConsole = ShowConsole(showConsole) -- 835
						config.showConsole = showConsole -- 836
					end -- 833
				end) -- 828
			end) -- 792
		end) -- 791
	end -- 836
end) -- 721
local MaxWidth <const> = 800 -- 838
local displayWindowFlags = { -- 840
	"NoDecoration", -- 840
	"NoSavedSettings", -- 840
	"NoFocusOnAppearing", -- 840
	"NoNav", -- 840
	"NoMove", -- 840
	"NoScrollWithMouse", -- 840
	"AlwaysAutoResize", -- 840
	"NoBringToFrontOnFocus" -- 840
} -- 840
local webStatus = nil -- 851
local descColor = Color(0xffa1a1a1) -- 852
local gameOpen = #gamesInDev == 0 -- 853
local toolOpen = false -- 854
local exampleOpen = false -- 855
local testOpen = false -- 856
local filterText = nil -- 857
local anyEntryMatched = false -- 858
local urlClicked = nil -- 859
local match -- 860
match = function(name) -- 860
	local res = not filterText or name:lower():match(filterText) -- 861
	if res then -- 862
		anyEntryMatched = true -- 862
	end -- 862
	return res -- 863
end -- 860
local iconTex = nil -- 864
thread(function() -- 865
	if Cache:loadAsync("Image/icon_s.png") then -- 865
		iconTex = Texture2D("Image/icon_s.png") -- 866
	end -- 865
end) -- 865
entryWindow = threadLoop(function() -- 868
	if App.fpsLimited ~= config.fpsLimited then -- 869
		config.fpsLimited = App.fpsLimited -- 870
	end -- 869
	if App.targetFPS ~= config.targetFPS then -- 871
		config.targetFPS = App.targetFPS -- 872
	end -- 871
	if View.vsync ~= config.vsync then -- 873
		config.vsync = View.vsync -- 874
	end -- 873
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 875
		config.fixedFPS = Director.scheduler.fixedFPS -- 876
	end -- 875
	if Director.profilerSending ~= config.webProfiler then -- 877
		config.webProfiler = Director.profilerSending -- 878
	end -- 877
	if urlClicked then -- 879
		local _, result = coroutine.resume(urlClicked) -- 880
		if result then -- 881
			coroutine.close(urlClicked) -- 882
			urlClicked = nil -- 883
		end -- 881
	end -- 879
	if not showEntry then -- 884
		return -- 884
	end -- 884
	if not isInEntry then -- 885
		return -- 885
	end -- 885
	local zh = useChinese and isChineseSupported -- 886
	if HttpServer.wsConnectionCount > 0 then -- 887
		local themeColor = App.themeColor -- 888
		local width, height -- 889
		do -- 889
			local _obj_0 = App.visualSize -- 889
			width, height = _obj_0.width, _obj_0.height -- 889
		end -- 889
		SetNextWindowBgAlpha(0.5) -- 890
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 891
		Begin("Web IDE Connected", displayWindowFlags, function() -- 892
			Separator() -- 893
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 894
			if iconTex then -- 895
				Image("Image/icon_s.png", Vec2(24, 24)) -- 896
				SameLine() -- 897
			end -- 895
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 898
			TextColored(descColor, slogon) -- 899
			return Separator() -- 900
		end) -- 892
		return -- 901
	end -- 887
	local themeColor = App.themeColor -- 903
	local fullWidth, height -- 904
	do -- 904
		local _obj_0 = App.visualSize -- 904
		fullWidth, height = _obj_0.width, _obj_0.height -- 904
	end -- 904
	SetNextWindowBgAlpha(0.85) -- 906
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 907
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 908
		return Begin("Web IDE", displayWindowFlags, function() -- 909
			Separator() -- 910
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 911
			SameLine() -- 912
			TextDisabled('(?)') -- 913
			if IsItemHovered() then -- 914
				BeginTooltip(function() -- 915
					return PushTextWrapPos(280, function() -- 916
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 917
					end) -- 917
				end) -- 915
			end -- 914
			do -- 918
				local url -- 918
				if webStatus ~= nil then -- 918
					url = webStatus.url -- 918
				end -- 918
				if url then -- 918
					if isDesktop and not config.fullScreen then -- 919
						if urlClicked then -- 920
							BeginDisabled(function() -- 921
								return Button(url) -- 921
							end) -- 921
						elseif Button(url) then -- 922
							urlClicked = once(function() -- 923
								return sleep(5) -- 923
							end) -- 923
							App:openURL("http://localhost:8866") -- 924
						end -- 920
					else -- 926
						TextColored(descColor, url) -- 926
					end -- 919
				else -- 928
					TextColored(descColor, zh and '不可用' or 'not available') -- 928
				end -- 918
			end -- 918
			return Separator() -- 929
		end) -- 929
	end) -- 908
	local width = math.min(MaxWidth, fullWidth) -- 931
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 932
	local maxColumns = math.max(math.floor(width / 200), 1) -- 933
	SetNextWindowPos(Vec2.zero) -- 934
	SetNextWindowBgAlpha(0) -- 935
	do -- 936
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 937
			return Begin("Dora Dev", displayWindowFlags, function() -- 938
				Dummy(Vec2(fullWidth - 20, 0)) -- 939
				if iconTex then -- 940
					Image("Image/icon_s.png", Vec2(24, 24)) -- 941
					SameLine() -- 942
				end -- 940
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 943
				SameLine() -- 944
				if fullWidth >= 360 then -- 945
					Dummy(Vec2(fullWidth - 360, 0)) -- 946
					SameLine() -- 947
					SetNextItemWidth(-50) -- 948
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 949
						"AutoSelectAll" -- 949
					}) then -- 949
						config.filter = filterBuf.text -- 950
					end -- 949
				end -- 945
				Separator() -- 951
				return Dummy(Vec2(fullWidth - 20, 0)) -- 952
			end) -- 938
		end) -- 937
	end -- 952
	anyEntryMatched = false -- 954
	SetNextWindowPos(Vec2(0, 50)) -- 955
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 956
	do -- 957
		return PushStyleColor("WindowBg", transparant, function() -- 958
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 959
				return Begin("Content", windowFlags, function() -- 960
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 961
					if filterText then -- 962
						filterText = filterText:lower() -- 962
					end -- 962
					if #gamesInDev > 0 then -- 963
						for _index_0 = 1, #gamesInDev do -- 964
							local game = gamesInDev[_index_0] -- 964
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 965
							local showSep = false -- 966
							if match(gameName) then -- 967
								Columns(1, false) -- 968
								TextColored(themeColor, zh and "项目：" or "Project:") -- 969
								SameLine() -- 970
								Text(gameName) -- 971
								Separator() -- 972
								if bannerFile then -- 973
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 974
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 975
									local sizing <const> = 0.8 -- 976
									texHeight = displayWidth * sizing * texHeight / texWidth -- 977
									texWidth = displayWidth * sizing -- 978
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 979
									Dummy(Vec2(padding, 0)) -- 980
									SameLine() -- 981
									PushID(fileName, function() -- 982
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 983
											return enterDemoEntry(game) -- 984
										end -- 983
									end) -- 982
								else -- 986
									PushID(fileName, function() -- 986
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 987
											return enterDemoEntry(game) -- 988
										end -- 987
									end) -- 986
								end -- 973
								NextColumn() -- 989
								showSep = true -- 990
							end -- 967
							if #examples > 0 then -- 991
								local showExample = false -- 992
								for _index_1 = 1, #examples do -- 993
									local example = examples[_index_1] -- 993
									if match(example[1]) then -- 994
										showExample = true -- 995
										break -- 996
									end -- 994
								end -- 996
								if showExample then -- 997
									Columns(1, false) -- 998
									TextColored(themeColor, zh and "示例：" or "Example:") -- 999
									SameLine() -- 1000
									Text(gameName) -- 1001
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1002
										Columns(maxColumns, false) -- 1003
										for _index_1 = 1, #examples do -- 1004
											local example = examples[_index_1] -- 1004
											if not match(example[1]) then -- 1005
												goto _continue_0 -- 1005
											end -- 1005
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1006
												if Button(example[1], Vec2(-1, 40)) then -- 1007
													enterDemoEntry(example) -- 1008
												end -- 1007
												return NextColumn() -- 1009
											end) -- 1006
											showSep = true -- 1010
											::_continue_0:: -- 1005
										end -- 1010
									end) -- 1002
								end -- 997
							end -- 991
							if #tests > 0 then -- 1011
								local showTest = false -- 1012
								for _index_1 = 1, #tests do -- 1013
									local test = tests[_index_1] -- 1013
									if match(test[1]) then -- 1014
										showTest = true -- 1015
										break -- 1016
									end -- 1014
								end -- 1016
								if showTest then -- 1017
									Columns(1, false) -- 1018
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1019
									SameLine() -- 1020
									Text(gameName) -- 1021
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1022
										Columns(maxColumns, false) -- 1023
										for _index_1 = 1, #tests do -- 1024
											local test = tests[_index_1] -- 1024
											if not match(test[1]) then -- 1025
												goto _continue_0 -- 1025
											end -- 1025
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1026
												if Button(test[1], Vec2(-1, 40)) then -- 1027
													enterDemoEntry(test) -- 1028
												end -- 1027
												return NextColumn() -- 1029
											end) -- 1026
											showSep = true -- 1030
											::_continue_0:: -- 1025
										end -- 1030
									end) -- 1022
								end -- 1017
							end -- 1011
							if showSep then -- 1031
								Columns(1, false) -- 1032
								Separator() -- 1033
							end -- 1031
						end -- 1033
					end -- 963
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1034
						local showGame = false -- 1035
						for _index_0 = 1, #games do -- 1036
							local _des_0 = games[_index_0] -- 1036
							local name = _des_0[1] -- 1036
							if match(name) then -- 1037
								showGame = true -- 1037
							end -- 1037
						end -- 1037
						local showTool = false -- 1038
						for _index_0 = 1, #doraTools do -- 1039
							local _des_0 = doraTools[_index_0] -- 1039
							local name = _des_0[1] -- 1039
							if match(name) then -- 1040
								showTool = true -- 1040
							end -- 1040
						end -- 1040
						local showExample = false -- 1041
						for _index_0 = 1, #doraExamples do -- 1042
							local _des_0 = doraExamples[_index_0] -- 1042
							local name = _des_0[1] -- 1042
							if match(name) then -- 1043
								showExample = true -- 1043
							end -- 1043
						end -- 1043
						local showTest = false -- 1044
						for _index_0 = 1, #doraTests do -- 1045
							local _des_0 = doraTests[_index_0] -- 1045
							local name = _des_0[1] -- 1045
							if match(name) then -- 1046
								showTest = true -- 1046
							end -- 1046
						end -- 1046
						for _index_0 = 1, #cppTests do -- 1047
							local _des_0 = cppTests[_index_0] -- 1047
							local name = _des_0[1] -- 1047
							if match(name) then -- 1048
								showTest = true -- 1048
							end -- 1048
						end -- 1048
						if not (showGame or showTool or showExample or showTest) then -- 1049
							goto endEntry -- 1049
						end -- 1049
						Columns(1, false) -- 1050
						TextColored(themeColor, "Dora SSR:") -- 1051
						SameLine() -- 1052
						Text(zh and "开发示例" or "Development Showcase") -- 1053
						Separator() -- 1054
						local demoViewWith <const> = 400 -- 1055
						if #games > 0 and showGame then -- 1056
							local opened -- 1057
							if (filterText ~= nil) then -- 1057
								opened = showGame -- 1057
							else -- 1057
								opened = false -- 1057
							end -- 1057
							SetNextItemOpen(gameOpen) -- 1058
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1059
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1060
								Columns(columns, false) -- 1061
								for _index_0 = 1, #games do -- 1062
									local game = games[_index_0] -- 1062
									if not match(game[1]) then -- 1063
										goto _continue_0 -- 1063
									end -- 1063
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1064
									if columns > 1 then -- 1065
										if bannerFile then -- 1066
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1067
											local displayWidth <const> = demoViewWith - 40 -- 1068
											texHeight = displayWidth * texHeight / texWidth -- 1069
											texWidth = displayWidth -- 1070
											Text(gameName) -- 1071
											PushID(fileName, function() -- 1072
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1073
													return enterDemoEntry(game) -- 1074
												end -- 1073
											end) -- 1072
										else -- 1076
											PushID(fileName, function() -- 1076
												if Button(gameName, Vec2(-1, 40)) then -- 1077
													return enterDemoEntry(game) -- 1078
												end -- 1077
											end) -- 1076
										end -- 1066
									else -- 1080
										if bannerFile then -- 1080
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1081
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1082
											local sizing = 0.8 -- 1083
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1084
											texWidth = displayWidth * sizing -- 1085
											if texWidth > 500 then -- 1086
												sizing = 0.6 -- 1087
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1088
												texWidth = displayWidth * sizing -- 1089
											end -- 1086
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1090
											Dummy(Vec2(padding, 0)) -- 1091
											SameLine() -- 1092
											Text(gameName) -- 1093
											Dummy(Vec2(padding, 0)) -- 1094
											SameLine() -- 1095
											PushID(fileName, function() -- 1096
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1097
													return enterDemoEntry(game) -- 1098
												end -- 1097
											end) -- 1096
										else -- 1100
											PushID(fileName, function() -- 1100
												if Button(gameName, Vec2(-1, 40)) then -- 1101
													return enterDemoEntry(game) -- 1102
												end -- 1101
											end) -- 1100
										end -- 1080
									end -- 1065
									NextColumn() -- 1103
									::_continue_0:: -- 1063
								end -- 1103
								Columns(1, false) -- 1104
								opened = true -- 1105
							end) -- 1059
							gameOpen = opened -- 1106
						end -- 1056
						if #doraTools > 0 and showTool then -- 1107
							local opened -- 1108
							if (filterText ~= nil) then -- 1108
								opened = showTool -- 1108
							else -- 1108
								opened = false -- 1108
							end -- 1108
							SetNextItemOpen(toolOpen) -- 1109
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1110
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1111
									Columns(maxColumns, false) -- 1112
									for _index_0 = 1, #doraTools do -- 1113
										local example = doraTools[_index_0] -- 1113
										if not match(example[1]) then -- 1114
											goto _continue_0 -- 1114
										end -- 1114
										if Button(example[1], Vec2(-1, 40)) then -- 1115
											enterDemoEntry(example) -- 1116
										end -- 1115
										NextColumn() -- 1117
										::_continue_0:: -- 1114
									end -- 1117
									Columns(1, false) -- 1118
									opened = true -- 1119
								end) -- 1111
							end) -- 1110
							toolOpen = opened -- 1120
						end -- 1107
						if #doraExamples > 0 and showExample then -- 1121
							local opened -- 1122
							if (filterText ~= nil) then -- 1122
								opened = showExample -- 1122
							else -- 1122
								opened = false -- 1122
							end -- 1122
							SetNextItemOpen(exampleOpen) -- 1123
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1124
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1125
									Columns(maxColumns, false) -- 1126
									for _index_0 = 1, #doraExamples do -- 1127
										local example = doraExamples[_index_0] -- 1127
										if not match(example[1]) then -- 1128
											goto _continue_0 -- 1128
										end -- 1128
										if Button(example[1], Vec2(-1, 40)) then -- 1129
											enterDemoEntry(example) -- 1130
										end -- 1129
										NextColumn() -- 1131
										::_continue_0:: -- 1128
									end -- 1131
									Columns(1, false) -- 1132
									opened = true -- 1133
								end) -- 1125
							end) -- 1124
							exampleOpen = opened -- 1134
						end -- 1121
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1135
							local opened -- 1136
							if (filterText ~= nil) then -- 1136
								opened = showTest -- 1136
							else -- 1136
								opened = false -- 1136
							end -- 1136
							SetNextItemOpen(testOpen) -- 1137
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1138
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1139
									Columns(maxColumns, false) -- 1140
									for _index_0 = 1, #doraTests do -- 1141
										local test = doraTests[_index_0] -- 1141
										if not match(test[1]) then -- 1142
											goto _continue_0 -- 1142
										end -- 1142
										if Button(test[1], Vec2(-1, 40)) then -- 1143
											enterDemoEntry(test) -- 1144
										end -- 1143
										NextColumn() -- 1145
										::_continue_0:: -- 1142
									end -- 1145
									for _index_0 = 1, #cppTests do -- 1146
										local test = cppTests[_index_0] -- 1146
										if not match(test[1]) then -- 1147
											goto _continue_1 -- 1147
										end -- 1147
										if Button(test[1], Vec2(-1, 40)) then -- 1148
											enterDemoEntry(test) -- 1149
										end -- 1148
										NextColumn() -- 1150
										::_continue_1:: -- 1147
									end -- 1150
									opened = true -- 1151
								end) -- 1139
							end) -- 1138
							testOpen = opened -- 1152
						end -- 1135
					end -- 1034
					::endEntry:: -- 1153
					if not anyEntryMatched then -- 1154
						SetNextWindowBgAlpha(0) -- 1155
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1156
						Begin("Entries Not Found", displayWindowFlags, function() -- 1157
							Separator() -- 1158
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1159
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1160
							return Separator() -- 1161
						end) -- 1157
					end -- 1154
					Columns(1, false) -- 1162
					Dummy(Vec2(100, 80)) -- 1163
					return ScrollWhenDraggingOnVoid() -- 1164
				end) -- 960
			end) -- 959
		end) -- 958
	end -- 1164
end) -- 868
webStatus = require("Script.Dev.WebServer") -- 1166
return _module_0 -- 1166
