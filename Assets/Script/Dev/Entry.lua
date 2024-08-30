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
setupEventHandlers = function() -- 530
	local _with_0 = Director.postNode -- 531
	_with_0:gslot("AppQuit", function() -- 532
		allClear() -- 533
		return clearTempFiles() -- 534
	end) -- 532
	_with_0:gslot("AppTheme", function(argb) -- 535
		config.themeColor = argb -- 536
	end) -- 535
	_with_0:gslot("AppLocale", function(locale) -- 537
		config.locale = locale -- 538
		updateLocale() -- 539
		return teal.clear(true) -- 540
	end) -- 537
	_with_0:gslot("AppWSClose", function() -- 541
		if HttpServer.wsConnectionCount == 0 then -- 542
			return updateEntries() -- 543
		end -- 542
	end) -- 541
	local _exp_0 = App.platform -- 544
	if "Linux" == _exp_0 or "Windows" == _exp_0 or "macOS" == _exp_0 then -- 544
		_with_0:gslot("AppSizeChanged", function() -- 545
			local width, height -- 546
			do -- 546
				local _obj_0 = App.winSize -- 546
				width, height = _obj_0.width, _obj_0.height -- 546
			end -- 546
			config.winWidth = width -- 547
			config.winHeight = height -- 548
		end) -- 545
		_with_0:gslot("AppFullScreen", function(fullScreen) -- 549
			config.fullScreen = fullScreen -- 550
		end) -- 549
		_with_0:gslot("AppMoved", function() -- 551
			local _obj_0 = App.winPosition -- 552
			config.winX, config.winY = _obj_0.x, _obj_0.y -- 552
		end) -- 551
	end -- 552
	return _with_0 -- 531
end -- 530
setupEventHandlers() -- 554
clearTempFiles() -- 555
local stop -- 557
stop = function() -- 557
	if isInEntry then -- 558
		return false -- 558
	end -- 558
	allClear() -- 559
	isInEntry = true -- 560
	currentEntry = nil -- 561
	return true -- 562
end -- 557
_module_0["stop"] = stop -- 562
local _anon_func_0 = function(Content, Path, file, require, type) -- 584
	local scriptPath = Path:getPath(file) -- 577
	Content:insertSearchPath(1, scriptPath) -- 578
	scriptPath = Path(scriptPath, "Script") -- 579
	if Content:exist(scriptPath) then -- 580
		Content:insertSearchPath(1, scriptPath) -- 581
	end -- 580
	local result = require(file) -- 582
	if "function" == type(result) then -- 583
		result() -- 583
	end -- 583
	return nil -- 584
end -- 577
local _anon_func_1 = function(Label, _with_0, err, fontSize, width) -- 616
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 613
	label.alignment = "Left" -- 614
	label.textWidth = width - fontSize -- 615
	label.text = err -- 616
	return label -- 613
end -- 613
local enterEntryAsync -- 564
enterEntryAsync = function(entry) -- 564
	isInEntry = false -- 565
	App.idled = false -- 566
	emit(Profiler.EventName, "ClearLoader") -- 567
	currentEntry = entry -- 568
	local name, file = entry[1], entry[2] -- 569
	if cppTestSet[entry] then -- 570
		if App:runTest(name) then -- 571
			return true -- 572
		else -- 574
			return false, "failed to run cpp test '" .. tostring(name) .. "'" -- 574
		end -- 571
	end -- 570
	sleep() -- 575
	return xpcall(_anon_func_0, function(msg) -- 584
		local err = debug.traceback(msg) -- 586
		print(err) -- 587
		allClear() -- 588
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 589
		local viewWidth, viewHeight -- 590
		do -- 590
			local _obj_0 = View.size -- 590
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 590
		end -- 590
		local width, height = viewWidth - 20, viewHeight - 20 -- 591
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 592
		Director.ui:addChild((function() -- 593
			local root = AlignNode() -- 593
			do -- 594
				local _obj_0 = App.bufferSize -- 594
				width, height = _obj_0.width, _obj_0.height -- 594
			end -- 594
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 595
			root:gslot("AppSizeChanged", function() -- 596
				do -- 597
					local _obj_0 = App.bufferSize -- 597
					width, height = _obj_0.width, _obj_0.height -- 597
				end -- 597
				return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 598
			end) -- 596
			root:addChild((function() -- 599
				local _with_0 = ScrollArea({ -- 600
					width = width, -- 600
					height = height, -- 601
					paddingX = 0, -- 602
					paddingY = 50, -- 603
					viewWidth = height, -- 604
					viewHeight = height -- 605
				}) -- 599
				root:slot("AlignLayout", function(w, h) -- 607
					_with_0.position = Vec2(w / 2, h / 2) -- 608
					w = w - 20 -- 609
					h = h - 20 -- 610
					_with_0.view.children.first.textWidth = w - fontSize -- 611
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 612
				end) -- 607
				_with_0.view:addChild(_anon_func_1(Label, _with_0, err, fontSize, width)) -- 613
				return _with_0 -- 599
			end)()) -- 599
			return root -- 593
		end)()) -- 593
		return err -- 617
	end, Content, Path, file, require, type) -- 617
end -- 564
_module_0["enterEntryAsync"] = enterEntryAsync -- 617
local enterDemoEntry -- 619
enterDemoEntry = function(entry) -- 619
	return thread(function() -- 619
		return enterEntryAsync(entry) -- 619
	end) -- 619
end -- 619
local reloadCurrentEntry -- 621
reloadCurrentEntry = function() -- 621
	if currentEntry then -- 622
		allClear() -- 623
		return enterDemoEntry(currentEntry) -- 624
	end -- 622
end -- 621
Director.clearColor = Color(0xff1a1a1a) -- 626
local waitForWebStart = true -- 628
thread(function() -- 629
	sleep(2) -- 630
	waitForWebStart = false -- 631
end) -- 629
local reloadDevEntry -- 633
reloadDevEntry = function() -- 633
	return thread(function() -- 633
		waitForWebStart = true -- 634
		doClean() -- 635
		allClear() -- 636
		_G.require = oldRequire -- 637
		Dora.require = oldRequire -- 638
		package.loaded["Script.Dev.Entry"] = nil -- 639
		return Director.systemScheduler:schedule(function() -- 640
			Routine:clear() -- 641
			oldRequire("Script.Dev.Entry") -- 642
			return true -- 643
		end) -- 643
	end) -- 643
end -- 633
local isOSSLicenseExist = Content:exist("LICENSES") -- 645
local ossLicenses = nil -- 646
local ossLicenseOpen = false -- 647
local extraOperations -- 649
extraOperations = function() -- 649
	local zh = useChinese and isChineseSupported -- 650
	if isOSSLicenseExist then -- 651
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 652
			if not ossLicenses then -- 653
				ossLicenses = { } -- 654
				local licenseText = Content:load("LICENSES") -- 655
				ossLicenseOpen = (licenseText ~= nil) -- 656
				if ossLicenseOpen then -- 656
					licenseText = licenseText:gsub("\r\n", "\n") -- 657
					for license in GSplit(licenseText, "\n--------\n", true) do -- 658
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 659
						if name then -- 659
							ossLicenses[#ossLicenses + 1] = { -- 660
								name, -- 660
								text -- 660
							} -- 660
						end -- 659
					end -- 660
				end -- 656
			else -- 662
				ossLicenseOpen = true -- 662
			end -- 653
		end -- 652
		if ossLicenseOpen then -- 663
			local width, height, themeColor -- 664
			do -- 664
				local _obj_0 = App -- 664
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 664
			end -- 664
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 665
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 666
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 667
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 670
					"NoSavedSettings" -- 670
				}, function() -- 671
					for _index_0 = 1, #ossLicenses do -- 671
						local _des_0 = ossLicenses[_index_0] -- 671
						local firstLine, text = _des_0[1], _des_0[2] -- 671
						local name, license = firstLine:match("(.+): (.+)") -- 672
						TextColored(themeColor, name) -- 673
						SameLine() -- 674
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 675
							return TextWrapped(text) -- 675
						end) -- 675
					end -- 675
				end) -- 667
			end) -- 667
		end -- 663
	end -- 651
	if not App.debugging then -- 677
		return -- 677
	end -- 677
	return TreeNode(zh and "开发操作" or "Development", function() -- 678
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 679
			OpenPopup("build") -- 679
		end -- 679
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 680
			return BeginPopup("build", function() -- 680
				if Selectable(zh and "编译" or "Compile") then -- 681
					doCompile(false) -- 681
				end -- 681
				Separator() -- 682
				if Selectable(zh and "压缩" or "Minify") then -- 683
					doCompile(true) -- 683
				end -- 683
				Separator() -- 684
				if Selectable(zh and "清理" or "Clean") then -- 685
					return doClean() -- 685
				end -- 685
			end) -- 685
		end) -- 680
		if isInEntry then -- 686
			if waitForWebStart then -- 687
				BeginDisabled(function() -- 688
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 688
				end) -- 688
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 689
				reloadDevEntry() -- 690
			end -- 687
		end -- 686
		do -- 691
			local changed -- 691
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 691
			if changed then -- 691
				View.scale = scaleContent and screenScale or 1 -- 692
			end -- 691
		end -- 691
		do -- 693
			local changed -- 693
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 693
			if changed then -- 693
				config.engineDev = engineDev -- 694
			end -- 693
		end -- 693
		if Button(zh and "开始自动测试" or "Test automatically") then -- 695
			testingThread = thread(function() -- 696
				local _ <close> = setmetatable({ }, { -- 697
					__close = function() -- 697
						allClear() -- 698
						testingThread = nil -- 699
						isInEntry = true -- 700
						currentEntry = nil -- 701
						return print("Testing done!") -- 702
					end -- 697
				}) -- 697
				for _, entry in ipairs(allEntries) do -- 703
					allClear() -- 704
					print("Start " .. tostring(entry[1])) -- 705
					enterDemoEntry(entry) -- 706
					sleep(2) -- 707
					print("Stop " .. tostring(entry[1])) -- 708
				end -- 708
			end) -- 696
		end -- 695
	end) -- 678
end -- 649
local transparant = Color(0x0) -- 710
local windowFlags = { -- 711
	"NoTitleBar", -- 711
	"NoResize", -- 711
	"NoMove", -- 711
	"NoCollapse", -- 711
	"NoSavedSettings", -- 711
	"NoBringToFrontOnFocus" -- 711
} -- 711
local initFooter = true -- 719
local _anon_func_2 = function(allEntries, currentIndex) -- 755
	if currentIndex > 1 then -- 755
		return allEntries[currentIndex - 1] -- 756
	else -- 758
		return allEntries[#allEntries] -- 758
	end -- 755
end -- 755
local _anon_func_3 = function(allEntries, currentIndex) -- 762
	if currentIndex < #allEntries then -- 762
		return allEntries[currentIndex + 1] -- 763
	else -- 765
		return allEntries[1] -- 765
	end -- 762
end -- 762
footerWindow = threadLoop(function() -- 720
	local zh = useChinese and isChineseSupported -- 721
	if HttpServer.wsConnectionCount > 0 then -- 722
		return -- 723
	end -- 722
	if Keyboard:isKeyDown("Escape") then -- 724
		allClear() -- 725
		App:shutdown() -- 726
	end -- 724
	do -- 727
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 728
		if ctrl and Keyboard:isKeyDown("Q") then -- 729
			stop() -- 730
		end -- 729
		if ctrl and Keyboard:isKeyDown("Z") then -- 731
			reloadCurrentEntry() -- 732
		end -- 731
		if ctrl and Keyboard:isKeyDown(",") then -- 733
			if showFooter then -- 734
				showStats = not showStats -- 734
			else -- 734
				showStats = true -- 734
			end -- 734
			showFooter = true -- 735
			config.showFooter = showFooter -- 736
			config.showStats = showStats -- 737
		end -- 733
		if ctrl and Keyboard:isKeyDown(".") then -- 738
			if showFooter then -- 739
				showConsole = not showConsole -- 739
			else -- 739
				showConsole = true -- 739
			end -- 739
			showFooter = true -- 740
			config.showFooter = showFooter -- 741
			config.showConsole = showConsole -- 742
		end -- 738
		if ctrl and Keyboard:isKeyDown("/") then -- 743
			showFooter = not showFooter -- 744
			config.showFooter = showFooter -- 745
		end -- 743
		local left = ctrl and Keyboard:isKeyDown("Left") -- 746
		local right = ctrl and Keyboard:isKeyDown("Right") -- 747
		local currentIndex = nil -- 748
		for i, entry in ipairs(allEntries) do -- 749
			if currentEntry == entry then -- 750
				currentIndex = i -- 751
			end -- 750
		end -- 751
		if left then -- 752
			allClear() -- 753
			if currentIndex == nil then -- 754
				currentIndex = #allEntries + 1 -- 754
			end -- 754
			enterDemoEntry(_anon_func_2(allEntries, currentIndex)) -- 755
		end -- 752
		if right then -- 759
			allClear() -- 760
			if currentIndex == nil then -- 761
				currentIndex = 0 -- 761
			end -- 761
			enterDemoEntry(_anon_func_3(allEntries, currentIndex)) -- 762
		end -- 759
	end -- 765
	if not showEntry then -- 766
		return -- 766
	end -- 766
	local width, height -- 768
	do -- 768
		local _obj_0 = App.visualSize -- 768
		width, height = _obj_0.width, _obj_0.height -- 768
	end -- 768
	SetNextWindowSize(Vec2(50, 50)) -- 769
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 770
	PushStyleColor("WindowBg", transparant, function() -- 771
		return Begin("Show", windowFlags, function() -- 771
			if isInEntry or width >= 540 then -- 772
				local changed -- 773
				changed, showFooter = Checkbox("##dev", showFooter) -- 773
				if changed then -- 773
					config.showFooter = showFooter -- 774
				end -- 773
			end -- 772
		end) -- 774
	end) -- 771
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 776
		reloadDevEntry() -- 780
	end -- 776
	if initFooter then -- 781
		initFooter = false -- 782
	else -- 784
		if not showFooter then -- 784
			return -- 784
		end -- 784
	end -- 781
	SetNextWindowSize(Vec2(width, 50)) -- 786
	SetNextWindowPos(Vec2(0, height - 50)) -- 787
	SetNextWindowBgAlpha(0.35) -- 788
	do -- 789
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 790
			return Begin("Footer", windowFlags, function() -- 791
				Dummy(Vec2(width - 20, 0)) -- 792
				do -- 793
					local changed -- 793
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 793
					if changed then -- 793
						config.showStats = showStats -- 794
					end -- 793
				end -- 793
				SameLine() -- 795
				do -- 796
					local changed -- 796
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 796
					if changed then -- 796
						config.showConsole = showConsole -- 797
					end -- 796
				end -- 796
				if config.updateNotification then -- 798
					SameLine() -- 799
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 800
						config.updateNotification = false -- 801
						enterDemoEntry({ -- 802
							"SelfUpdater", -- 802
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 802
						}) -- 802
					end -- 800
				end -- 798
				if not isInEntry then -- 803
					SameLine() -- 804
					if Button(zh and "主页" or "Home", Vec2(70, 30)) then -- 805
						allClear() -- 806
						isInEntry = true -- 807
						currentEntry = nil -- 808
					end -- 805
					local currentIndex = nil -- 809
					for i, entry in ipairs(allEntries) do -- 810
						if currentEntry == entry then -- 811
							currentIndex = i -- 812
						end -- 811
					end -- 812
					if currentIndex then -- 813
						if currentIndex > 1 then -- 814
							SameLine() -- 815
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 816
								allClear() -- 817
								enterDemoEntry(allEntries[currentIndex - 1]) -- 818
							end -- 816
						end -- 814
						if currentIndex < #allEntries then -- 819
							SameLine() -- 820
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 821
								allClear() -- 822
								enterDemoEntry(allEntries[currentIndex + 1]) -- 823
							end -- 821
						end -- 819
					end -- 813
					SameLine() -- 824
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 825
						reloadCurrentEntry() -- 826
					end -- 825
				end -- 803
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 827
					if showStats then -- 828
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 829
						showStats = ShowStats(showStats, extraOperations) -- 830
						config.showStats = showStats -- 831
					end -- 828
					if showConsole then -- 832
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 833
						showConsole = ShowConsole(showConsole) -- 834
						config.showConsole = showConsole -- 835
					end -- 832
				end) -- 827
			end) -- 791
		end) -- 790
	end -- 835
end) -- 720
local MaxWidth <const> = 800 -- 837
local displayWindowFlags = { -- 839
	"NoDecoration", -- 839
	"NoSavedSettings", -- 839
	"NoFocusOnAppearing", -- 839
	"NoNav", -- 839
	"NoMove", -- 839
	"NoScrollWithMouse", -- 839
	"AlwaysAutoResize", -- 839
	"NoBringToFrontOnFocus" -- 839
} -- 839
local webStatus = nil -- 850
local descColor = Color(0xffa1a1a1) -- 851
local gameOpen = #gamesInDev == 0 -- 852
local toolOpen = false -- 853
local exampleOpen = false -- 854
local testOpen = false -- 855
local filterText = nil -- 856
local anyEntryMatched = false -- 857
local urlClicked = nil -- 858
local match -- 859
match = function(name) -- 859
	local res = not filterText or name:lower():match(filterText) -- 860
	if res then -- 861
		anyEntryMatched = true -- 861
	end -- 861
	return res -- 862
end -- 859
local iconTex = nil -- 863
thread(function() -- 864
	if Cache:loadAsync("Image/icon_s.png") then -- 864
		iconTex = Texture2D("Image/icon_s.png") -- 865
	end -- 864
end) -- 864
entryWindow = threadLoop(function() -- 867
	if App.fpsLimited ~= config.fpsLimited then -- 868
		config.fpsLimited = App.fpsLimited -- 869
	end -- 868
	if App.targetFPS ~= config.targetFPS then -- 870
		config.targetFPS = App.targetFPS -- 871
	end -- 870
	if View.vsync ~= config.vsync then -- 872
		config.vsync = View.vsync -- 873
	end -- 872
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 874
		config.fixedFPS = Director.scheduler.fixedFPS -- 875
	end -- 874
	if Director.profilerSending ~= config.webProfiler then -- 876
		config.webProfiler = Director.profilerSending -- 877
	end -- 876
	if urlClicked then -- 878
		local _, result = coroutine.resume(urlClicked) -- 879
		if result then -- 880
			coroutine.close(urlClicked) -- 881
			urlClicked = nil -- 882
		end -- 880
	end -- 878
	if not showEntry then -- 883
		return -- 883
	end -- 883
	if not isInEntry then -- 884
		return -- 884
	end -- 884
	local zh = useChinese and isChineseSupported -- 885
	if HttpServer.wsConnectionCount > 0 then -- 886
		local themeColor = App.themeColor -- 887
		local width, height -- 888
		do -- 888
			local _obj_0 = App.visualSize -- 888
			width, height = _obj_0.width, _obj_0.height -- 888
		end -- 888
		SetNextWindowBgAlpha(0.5) -- 889
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 890
		Begin("Web IDE Connected", displayWindowFlags, function() -- 891
			Separator() -- 892
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 893
			if iconTex then -- 894
				Image("Image/icon_s.png", Vec2(24, 24)) -- 895
				SameLine() -- 896
			end -- 894
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 897
			TextColored(descColor, slogon) -- 898
			return Separator() -- 899
		end) -- 891
		return -- 900
	end -- 886
	local themeColor = App.themeColor -- 902
	local fullWidth, height -- 903
	do -- 903
		local _obj_0 = App.visualSize -- 903
		fullWidth, height = _obj_0.width, _obj_0.height -- 903
	end -- 903
	SetNextWindowBgAlpha(0.85) -- 905
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 906
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 907
		return Begin("Web IDE", displayWindowFlags, function() -- 908
			Separator() -- 909
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 910
			SameLine() -- 911
			TextDisabled('(?)') -- 912
			if IsItemHovered() then -- 913
				BeginTooltip(function() -- 914
					return PushTextWrapPos(280, function() -- 915
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 916
					end) -- 916
				end) -- 914
			end -- 913
			do -- 917
				local url -- 917
				if webStatus ~= nil then -- 917
					url = webStatus.url -- 917
				end -- 917
				if url then -- 917
					if isDesktop and not config.fullScreen then -- 918
						if urlClicked then -- 919
							BeginDisabled(function() -- 920
								return Button(url) -- 920
							end) -- 920
						elseif Button(url) then -- 921
							urlClicked = once(function() -- 922
								return sleep(5) -- 922
							end) -- 922
							App:openURL("http://localhost:8866") -- 923
						end -- 919
					else -- 925
						TextColored(descColor, url) -- 925
					end -- 918
				else -- 927
					TextColored(descColor, zh and '不可用' or 'not available') -- 927
				end -- 917
			end -- 917
			return Separator() -- 928
		end) -- 928
	end) -- 907
	local width = math.min(MaxWidth, fullWidth) -- 930
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 931
	local maxColumns = math.max(math.floor(width / 200), 1) -- 932
	SetNextWindowPos(Vec2.zero) -- 933
	SetNextWindowBgAlpha(0) -- 934
	do -- 935
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 936
			return Begin("Dora Dev", displayWindowFlags, function() -- 937
				Dummy(Vec2(fullWidth - 20, 0)) -- 938
				if iconTex then -- 939
					Image("Image/icon_s.png", Vec2(24, 24)) -- 940
					SameLine() -- 941
				end -- 939
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 942
				SameLine() -- 943
				if fullWidth >= 360 then -- 944
					Dummy(Vec2(fullWidth - 360, 0)) -- 945
					SameLine() -- 946
					SetNextItemWidth(-50) -- 947
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 948
						"AutoSelectAll" -- 948
					}) then -- 948
						config.filter = filterBuf.text -- 949
					end -- 948
				end -- 944
				Separator() -- 950
				return Dummy(Vec2(fullWidth - 20, 0)) -- 951
			end) -- 937
		end) -- 936
	end -- 951
	anyEntryMatched = false -- 953
	SetNextWindowPos(Vec2(0, 50)) -- 954
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 955
	do -- 956
		return PushStyleColor("WindowBg", transparant, function() -- 957
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 958
				return Begin("Content", windowFlags, function() -- 959
					filterText = filterBuf.text:match("[^%%%.%[]+") -- 960
					if filterText then -- 961
						filterText = filterText:lower() -- 961
					end -- 961
					if #gamesInDev > 0 then -- 962
						for _index_0 = 1, #gamesInDev do -- 963
							local game = gamesInDev[_index_0] -- 963
							local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 964
							local showSep = false -- 965
							if match(gameName) then -- 966
								Columns(1, false) -- 967
								TextColored(themeColor, zh and "项目：" or "Project:") -- 968
								SameLine() -- 969
								Text(gameName) -- 970
								Separator() -- 971
								if bannerFile then -- 972
									local texWidth, texHeight = bannerTex.width, bannerTex.height -- 973
									local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 974
									local sizing <const> = 0.8 -- 975
									texHeight = displayWidth * sizing * texHeight / texWidth -- 976
									texWidth = displayWidth * sizing -- 977
									local padding = displayWidth * (1 - sizing) / 2 - 10 -- 978
									Dummy(Vec2(padding, 0)) -- 979
									SameLine() -- 980
									PushID(fileName, function() -- 981
										if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 982
											return enterDemoEntry(game) -- 983
										end -- 982
									end) -- 981
								else -- 985
									PushID(fileName, function() -- 985
										if Button(zh and "开始运行" or "Game Start", Vec2(-1, 40)) then -- 986
											return enterDemoEntry(game) -- 987
										end -- 986
									end) -- 985
								end -- 972
								NextColumn() -- 988
								showSep = true -- 989
							end -- 966
							if #examples > 0 then -- 990
								local showExample = false -- 991
								for _index_1 = 1, #examples do -- 992
									local example = examples[_index_1] -- 992
									if match(example[1]) then -- 993
										showExample = true -- 994
										break -- 995
									end -- 993
								end -- 995
								if showExample then -- 996
									Columns(1, false) -- 997
									TextColored(themeColor, zh and "示例：" or "Example:") -- 998
									SameLine() -- 999
									Text(gameName) -- 1000
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1001
										Columns(maxColumns, false) -- 1002
										for _index_1 = 1, #examples do -- 1003
											local example = examples[_index_1] -- 1003
											if not match(example[1]) then -- 1004
												goto _continue_0 -- 1004
											end -- 1004
											PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1005
												if Button(example[1], Vec2(-1, 40)) then -- 1006
													enterDemoEntry(example) -- 1007
												end -- 1006
												return NextColumn() -- 1008
											end) -- 1005
											showSep = true -- 1009
											::_continue_0:: -- 1004
										end -- 1009
									end) -- 1001
								end -- 996
							end -- 990
							if #tests > 0 then -- 1010
								local showTest = false -- 1011
								for _index_1 = 1, #tests do -- 1012
									local test = tests[_index_1] -- 1012
									if match(test[1]) then -- 1013
										showTest = true -- 1014
										break -- 1015
									end -- 1013
								end -- 1015
								if showTest then -- 1016
									Columns(1, false) -- 1017
									TextColored(themeColor, zh and "测试：" or "Test:") -- 1018
									SameLine() -- 1019
									Text(gameName) -- 1020
									PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1021
										Columns(maxColumns, false) -- 1022
										for _index_1 = 1, #tests do -- 1023
											local test = tests[_index_1] -- 1023
											if not match(test[1]) then -- 1024
												goto _continue_0 -- 1024
											end -- 1024
											PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1025
												if Button(test[1], Vec2(-1, 40)) then -- 1026
													enterDemoEntry(test) -- 1027
												end -- 1026
												return NextColumn() -- 1028
											end) -- 1025
											showSep = true -- 1029
											::_continue_0:: -- 1024
										end -- 1029
									end) -- 1021
								end -- 1016
							end -- 1010
							if showSep then -- 1030
								Columns(1, false) -- 1031
								Separator() -- 1032
							end -- 1030
						end -- 1032
					end -- 962
					if #games > 0 or #doraExamples > 0 or #doraTests > 0 then -- 1033
						local showGame = false -- 1034
						for _index_0 = 1, #games do -- 1035
							local _des_0 = games[_index_0] -- 1035
							local name = _des_0[1] -- 1035
							if match(name) then -- 1036
								showGame = true -- 1036
							end -- 1036
						end -- 1036
						local showTool = false -- 1037
						for _index_0 = 1, #doraTools do -- 1038
							local _des_0 = doraTools[_index_0] -- 1038
							local name = _des_0[1] -- 1038
							if match(name) then -- 1039
								showTool = true -- 1039
							end -- 1039
						end -- 1039
						local showExample = false -- 1040
						for _index_0 = 1, #doraExamples do -- 1041
							local _des_0 = doraExamples[_index_0] -- 1041
							local name = _des_0[1] -- 1041
							if match(name) then -- 1042
								showExample = true -- 1042
							end -- 1042
						end -- 1042
						local showTest = false -- 1043
						for _index_0 = 1, #doraTests do -- 1044
							local _des_0 = doraTests[_index_0] -- 1044
							local name = _des_0[1] -- 1044
							if match(name) then -- 1045
								showTest = true -- 1045
							end -- 1045
						end -- 1045
						for _index_0 = 1, #cppTests do -- 1046
							local _des_0 = cppTests[_index_0] -- 1046
							local name = _des_0[1] -- 1046
							if match(name) then -- 1047
								showTest = true -- 1047
							end -- 1047
						end -- 1047
						if not (showGame or showTool or showExample or showTest) then -- 1048
							goto endEntry -- 1048
						end -- 1048
						Columns(1, false) -- 1049
						TextColored(themeColor, "Dora SSR:") -- 1050
						SameLine() -- 1051
						Text(zh and "开发示例" or "Development Showcase") -- 1052
						Separator() -- 1053
						local demoViewWith <const> = 400 -- 1054
						if #games > 0 and showGame then -- 1055
							local opened -- 1056
							if (filterText ~= nil) then -- 1056
								opened = showGame -- 1056
							else -- 1056
								opened = false -- 1056
							end -- 1056
							SetNextItemOpen(gameOpen) -- 1057
							TreeNode(zh and "游戏演示" or "Game Demo", function() -- 1058
								local columns = math.max(math.floor(width / demoViewWith), 1) -- 1059
								Columns(columns, false) -- 1060
								for _index_0 = 1, #games do -- 1061
									local game = games[_index_0] -- 1061
									if not match(game[1]) then -- 1062
										goto _continue_0 -- 1062
									end -- 1062
									local gameName, fileName, bannerFile, bannerTex = game[1], game[2], game[5], game[6] -- 1063
									if columns > 1 then -- 1064
										if bannerFile then -- 1065
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1066
											local displayWidth <const> = demoViewWith - 40 -- 1067
											texHeight = displayWidth * texHeight / texWidth -- 1068
											texWidth = displayWidth -- 1069
											Text(gameName) -- 1070
											PushID(fileName, function() -- 1071
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1072
													return enterDemoEntry(game) -- 1073
												end -- 1072
											end) -- 1071
										else -- 1075
											PushID(fileName, function() -- 1075
												if Button(gameName, Vec2(-1, 40)) then -- 1076
													return enterDemoEntry(game) -- 1077
												end -- 1076
											end) -- 1075
										end -- 1065
									else -- 1079
										if bannerFile then -- 1079
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1080
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1081
											local sizing = 0.8 -- 1082
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1083
											texWidth = displayWidth * sizing -- 1084
											if texWidth > 500 then -- 1085
												sizing = 0.6 -- 1086
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1087
												texWidth = displayWidth * sizing -- 1088
											end -- 1085
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1089
											Dummy(Vec2(padding, 0)) -- 1090
											SameLine() -- 1091
											Text(gameName) -- 1092
											Dummy(Vec2(padding, 0)) -- 1093
											SameLine() -- 1094
											PushID(fileName, function() -- 1095
												if ImageButton(gameName, bannerFile, Vec2(texWidth, texHeight)) then -- 1096
													return enterDemoEntry(game) -- 1097
												end -- 1096
											end) -- 1095
										else -- 1099
											PushID(fileName, function() -- 1099
												if Button(gameName, Vec2(-1, 40)) then -- 1100
													return enterDemoEntry(game) -- 1101
												end -- 1100
											end) -- 1099
										end -- 1079
									end -- 1064
									NextColumn() -- 1102
									::_continue_0:: -- 1062
								end -- 1102
								Columns(1, false) -- 1103
								opened = true -- 1104
							end) -- 1058
							gameOpen = opened -- 1105
						end -- 1055
						if #doraTools > 0 and showTool then -- 1106
							local opened -- 1107
							if (filterText ~= nil) then -- 1107
								opened = showTool -- 1107
							else -- 1107
								opened = false -- 1107
							end -- 1107
							SetNextItemOpen(toolOpen) -- 1108
							TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1109
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1110
									Columns(maxColumns, false) -- 1111
									for _index_0 = 1, #doraTools do -- 1112
										local example = doraTools[_index_0] -- 1112
										if not match(example[1]) then -- 1113
											goto _continue_0 -- 1113
										end -- 1113
										if Button(example[1], Vec2(-1, 40)) then -- 1114
											enterDemoEntry(example) -- 1115
										end -- 1114
										NextColumn() -- 1116
										::_continue_0:: -- 1113
									end -- 1116
									Columns(1, false) -- 1117
									opened = true -- 1118
								end) -- 1110
							end) -- 1109
							toolOpen = opened -- 1119
						end -- 1106
						if #doraExamples > 0 and showExample then -- 1120
							local opened -- 1121
							if (filterText ~= nil) then -- 1121
								opened = showExample -- 1121
							else -- 1121
								opened = false -- 1121
							end -- 1121
							SetNextItemOpen(exampleOpen) -- 1122
							TreeNode(zh and "引擎示例" or "Engine Example", function() -- 1123
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1124
									Columns(maxColumns, false) -- 1125
									for _index_0 = 1, #doraExamples do -- 1126
										local example = doraExamples[_index_0] -- 1126
										if not match(example[1]) then -- 1127
											goto _continue_0 -- 1127
										end -- 1127
										if Button(example[1], Vec2(-1, 40)) then -- 1128
											enterDemoEntry(example) -- 1129
										end -- 1128
										NextColumn() -- 1130
										::_continue_0:: -- 1127
									end -- 1130
									Columns(1, false) -- 1131
									opened = true -- 1132
								end) -- 1124
							end) -- 1123
							exampleOpen = opened -- 1133
						end -- 1120
						if (#doraTests > 0 or #cppTests > 0) and showTest then -- 1134
							local opened -- 1135
							if (filterText ~= nil) then -- 1135
								opened = showTest -- 1135
							else -- 1135
								opened = false -- 1135
							end -- 1135
							SetNextItemOpen(testOpen) -- 1136
							TreeNode(zh and "引擎测试" or "Engine Test", function() -- 1137
								return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1138
									Columns(maxColumns, false) -- 1139
									for _index_0 = 1, #doraTests do -- 1140
										local test = doraTests[_index_0] -- 1140
										if not match(test[1]) then -- 1141
											goto _continue_0 -- 1141
										end -- 1141
										if Button(test[1], Vec2(-1, 40)) then -- 1142
											enterDemoEntry(test) -- 1143
										end -- 1142
										NextColumn() -- 1144
										::_continue_0:: -- 1141
									end -- 1144
									for _index_0 = 1, #cppTests do -- 1145
										local test = cppTests[_index_0] -- 1145
										if not match(test[1]) then -- 1146
											goto _continue_1 -- 1146
										end -- 1146
										if Button(test[1], Vec2(-1, 40)) then -- 1147
											enterDemoEntry(test) -- 1148
										end -- 1147
										NextColumn() -- 1149
										::_continue_1:: -- 1146
									end -- 1149
									opened = true -- 1150
								end) -- 1138
							end) -- 1137
							testOpen = opened -- 1151
						end -- 1134
					end -- 1033
					::endEntry:: -- 1152
					if not anyEntryMatched then -- 1153
						SetNextWindowBgAlpha(0) -- 1154
						SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1155
						Begin("Entries Not Found", displayWindowFlags, function() -- 1156
							Separator() -- 1157
							TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1158
							TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1159
							return Separator() -- 1160
						end) -- 1156
					end -- 1153
					Columns(1, false) -- 1161
					Dummy(Vec2(100, 80)) -- 1162
					return ScrollWhenDraggingOnVoid() -- 1163
				end) -- 959
			end) -- 958
		end) -- 957
	end -- 1163
end) -- 867
webStatus = require("Script.Dev.WebServer") -- 1165
return _module_0 -- 1165
