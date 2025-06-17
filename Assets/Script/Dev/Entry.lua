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
local Log = Dora.Log -- 1
local math = _G.math -- 1
local AlignNode = Dora.AlignNode -- 1
local Label = Dora.Label -- 1
local Checkbox = _module_0.Checkbox -- 1
local SeparatorText = _module_0.SeparatorText -- 1
local PushTextWrapPos = _module_0.PushTextWrapPos -- 1
local TextColored = _module_0.TextColored -- 1
local Button = _module_0.Button -- 1
local SameLine = _module_0.SameLine -- 1
local Separator = _module_0.Separator -- 1
local SetNextWindowPosCenter = _module_0.SetNextWindowPosCenter -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Begin = _module_0.Begin -- 1
local TreeNode = _module_0.TreeNode -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local OpenPopup = _module_0.OpenPopup -- 1
local BeginPopup = _module_0.BeginPopup -- 1
local Selectable = _module_0.Selectable -- 1
local BeginDisabled = _module_0.BeginDisabled -- 1
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
local Text = _module_0.Text -- 1
local once = Dora.once -- 1
local SetNextItemWidth = _module_0.SetNextItemWidth -- 1
local InputText = _module_0.InputText -- 1
local Columns = _module_0.Columns -- 1
local NextColumn = _module_0.NextColumn -- 1
local SetNextItemOpen = _module_0.SetNextItemOpen -- 1
local PushID = _module_0.PushID -- 1
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
local isDesktop -- 36
do -- 36
	local _val_0 = App.platform -- 36
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 36
end -- 36
if DB:exist("Config") then -- 38
	do -- 39
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 39
		local _type_0 = type(_exp_0) -- 40
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 40
		if _tab_0 then -- 40
			local locale -- 40
			do -- 40
				local _obj_0 = _exp_0[1] -- 40
				local _type_1 = type(_obj_0) -- 40
				if "table" == _type_1 or "userdata" == _type_1 then -- 40
					locale = _obj_0[1] -- 40
				end -- 42
			end -- 42
			if locale ~= nil then -- 40
				if App.locale ~= locale then -- 40
					App.locale = locale -- 41
					updateLocale() -- 42
				end -- 40
			end -- 40
		end -- 42
	end -- 42
	if isDesktop then -- 43
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 44
		local _type_0 = type(_exp_0) -- 45
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 45
		if _tab_0 then -- 45
			local writablePath -- 45
			do -- 45
				local _obj_0 = _exp_0[1] -- 45
				local _type_1 = type(_obj_0) -- 45
				if "table" == _type_1 or "userdata" == _type_1 then -- 45
					writablePath = _obj_0[1] -- 45
				end -- 46
			end -- 46
			if writablePath ~= nil then -- 45
				Content.writablePath = writablePath -- 46
			end -- 45
		end -- 46
	end -- 43
end -- 38
local Config = require("Config") -- 48
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected") -- 50
config:load() -- 77
if not (config.writablePath ~= nil) then -- 79
	config.writablePath = Content.appPath -- 80
end -- 79
if not (config.webIDEConnected ~= nil) then -- 82
	config.webIDEConnected = false -- 83
end -- 82
if (config.fpsLimited ~= nil) then -- 85
	App.fpsLimited = config.fpsLimited -- 86
else -- 88
	config.fpsLimited = App.fpsLimited -- 88
end -- 85
if (config.targetFPS ~= nil) then -- 90
	App.targetFPS = config.targetFPS -- 91
else -- 93
	config.targetFPS = App.targetFPS -- 93
end -- 90
if (config.vsync ~= nil) then -- 95
	View.vsync = config.vsync -- 96
else -- 98
	config.vsync = View.vsync -- 98
end -- 95
if (config.fixedFPS ~= nil) then -- 100
	Director.scheduler.fixedFPS = config.fixedFPS -- 101
else -- 103
	config.fixedFPS = Director.scheduler.fixedFPS -- 103
end -- 100
local showEntry = true -- 105
isDesktop = false -- 107
if (function() -- 108
	local _val_0 = App.platform -- 108
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 108
end)() then -- 108
	isDesktop = true -- 109
	if config.fullScreen then -- 110
		App.fullScreen = true -- 111
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 112
		local size = Size(config.winWidth, config.winHeight) -- 113
		if App.winSize ~= size then -- 114
			App.winSize = size -- 115
			showEntry = false -- 116
			thread(function() -- 117
				sleep() -- 118
				sleep() -- 119
				showEntry = true -- 120
			end) -- 117
		end -- 114
		local winX, winY -- 121
		do -- 121
			local _obj_0 = App.winPosition -- 121
			winX, winY = _obj_0.x, _obj_0.y -- 121
		end -- 121
		if (config.winX ~= nil) then -- 122
			winX = config.winX -- 123
		else -- 125
			config.winX = -1 -- 125
		end -- 122
		if (config.winY ~= nil) then -- 126
			winY = config.winY -- 127
		else -- 129
			config.winY = -1 -- 129
		end -- 126
		App.winPosition = Vec2(winX, winY) -- 130
	end -- 110
	if (config.alwaysOnTop ~= nil) then -- 131
		App.alwaysOnTop = config.alwaysOnTop -- 132
	else -- 134
		config.alwaysOnTop = true -- 134
	end -- 131
end -- 108
if (config.themeColor ~= nil) then -- 136
	App.themeColor = Color(config.themeColor) -- 137
else -- 139
	config.themeColor = App.themeColor:toARGB() -- 139
end -- 136
if not (config.locale ~= nil) then -- 141
	config.locale = App.locale -- 142
end -- 141
local showStats = false -- 144
if (config.showStats ~= nil) then -- 145
	showStats = config.showStats -- 146
else -- 148
	config.showStats = showStats -- 148
end -- 145
local showConsole = false -- 150
if (config.showConsole ~= nil) then -- 151
	showConsole = config.showConsole -- 152
else -- 154
	config.showConsole = showConsole -- 154
end -- 151
local showFooter = true -- 156
if (config.showFooter ~= nil) then -- 157
	showFooter = config.showFooter -- 158
else -- 160
	config.showFooter = showFooter -- 160
end -- 157
local filterBuf = Buffer(20) -- 162
if (config.filter ~= nil) then -- 163
	filterBuf.text = config.filter -- 164
else -- 166
	config.filter = "" -- 166
end -- 163
local engineDev = false -- 168
if (config.engineDev ~= nil) then -- 169
	engineDev = config.engineDev -- 170
else -- 172
	config.engineDev = engineDev -- 172
end -- 169
if (config.webProfiler ~= nil) then -- 174
	Director.profilerSending = config.webProfiler -- 175
else -- 177
	config.webProfiler = true -- 177
	Director.profilerSending = true -- 178
end -- 174
if not (config.drawerWidth ~= nil) then -- 180
	config.drawerWidth = 200 -- 181
end -- 180
_module_0.getConfig = function() -- 183
	return config -- 183
end -- 183
_module_0.getEngineDev = function() -- 184
	if not App.debugging then -- 185
		return false -- 185
	end -- 185
	return config.engineDev -- 186
end -- 184
local _anon_func_0 = function(App) -- 191
	local _val_0 = App.platform -- 191
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 191
end -- 191
_module_0.connectWebIDE = function() -- 188
	if not config.webIDEConnected then -- 189
		config.webIDEConnected = true -- 190
		if _anon_func_0(App) then -- 191
			local ratio = App.winSize.width / App.visualSize.width -- 192
			App.winSize = Size(640 * ratio, 480 * ratio) -- 193
		end -- 191
	end -- 189
end -- 188
local updateCheck -- 195
updateCheck = function() -- 195
	return thread(function() -- 195
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 196
		if res then -- 196
			local data = json.load(res) -- 197
			if data then -- 197
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 198
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 199
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 200
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 201
				if na < a then -- 202
					goto not_new_version -- 203
				end -- 202
				if na == a then -- 204
					if nb < b then -- 205
						goto not_new_version -- 206
					end -- 205
					if nb == b then -- 207
						if nc < c then -- 208
							goto not_new_version -- 209
						end -- 208
						if nc == c then -- 210
							goto not_new_version -- 211
						end -- 210
					end -- 207
				end -- 204
				config.updateNotification = true -- 212
				::not_new_version:: -- 213
				config.lastUpdateCheck = os.time() -- 214
			end -- 197
		end -- 196
	end) -- 214
end -- 195
if (config.lastUpdateCheck ~= nil) then -- 216
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 217
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 218
		updateCheck() -- 219
	end -- 218
else -- 221
	updateCheck() -- 221
end -- 216
local Set, Struct, LintYueGlobals, GSplit -- 223
do -- 223
	local _obj_0 = require("Utils") -- 223
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 223
end -- 223
local yueext = yue.options.extension -- 224
local isChineseSupported = IsFontLoaded() -- 226
if not isChineseSupported then -- 227
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 228
		isChineseSupported = true -- 229
	end) -- 228
end -- 227
local building = false -- 231
local getAllFiles -- 233
getAllFiles = function(path, exts, recursive) -- 233
	if recursive == nil then -- 233
		recursive = true -- 233
	end -- 233
	local filters = Set(exts) -- 234
	local files -- 235
	if recursive then -- 235
		files = Content:getAllFiles(path) -- 236
	else -- 238
		files = Content:getFiles(path) -- 238
	end -- 235
	local _accum_0 = { } -- 239
	local _len_0 = 1 -- 239
	for _index_0 = 1, #files do -- 239
		local file = files[_index_0] -- 239
		if not filters[Path:getExt(file)] then -- 240
			goto _continue_0 -- 240
		end -- 240
		_accum_0[_len_0] = file -- 241
		_len_0 = _len_0 + 1 -- 240
		::_continue_0:: -- 240
	end -- 241
	return _accum_0 -- 241
end -- 233
_module_0["getAllFiles"] = getAllFiles -- 241
local getFileEntries -- 243
getFileEntries = function(path, recursive, excludeFiles) -- 243
	if recursive == nil then -- 243
		recursive = true -- 243
	end -- 243
	if excludeFiles == nil then -- 243
		excludeFiles = nil -- 243
	end -- 243
	local entries = { } -- 244
	local excludes -- 245
	if excludeFiles then -- 245
		excludes = Set(excludeFiles) -- 246
	end -- 245
	local _list_0 = getAllFiles(path, { -- 247
		"lua", -- 247
		"xml", -- 247
		yueext, -- 247
		"tl" -- 247
	}, recursive) -- 247
	for _index_0 = 1, #_list_0 do -- 247
		local file = _list_0[_index_0] -- 247
		local entryName = Path:getName(file) -- 248
		if excludes and excludes[entryName] then -- 249
			goto _continue_0 -- 250
		end -- 249
		local fileName = Path:replaceExt(file, "") -- 251
		fileName = Path(path, fileName) -- 252
		local entryAdded -- 253
		do -- 253
			local _accum_0 -- 253
			for _index_1 = 1, #entries do -- 253
				local _des_0 = entries[_index_1] -- 253
				local ename, efile = _des_0[1], _des_0[2] -- 253
				if entryName == ename and efile == fileName then -- 254
					_accum_0 = true -- 254
					break -- 254
				end -- 254
			end -- 254
			entryAdded = _accum_0 -- 253
		end -- 254
		if entryAdded then -- 255
			goto _continue_0 -- 255
		end -- 255
		local entry = { -- 256
			entryName, -- 256
			fileName -- 256
		} -- 256
		entries[#entries + 1] = entry -- 257
		::_continue_0:: -- 248
	end -- 257
	table.sort(entries, function(a, b) -- 258
		return a[1] < b[1] -- 258
	end) -- 258
	return entries -- 259
end -- 243
local getProjectEntries -- 261
getProjectEntries = function(path) -- 261
	local entries = { } -- 262
	local _list_0 = Content:getDirs(path) -- 263
	for _index_0 = 1, #_list_0 do -- 263
		local dir = _list_0[_index_0] -- 263
		if dir:match("^%.") then -- 264
			goto _continue_0 -- 264
		end -- 264
		local _list_1 = getAllFiles(Path(path, dir), { -- 265
			"lua", -- 265
			"xml", -- 265
			yueext, -- 265
			"tl", -- 265
			"wasm" -- 265
		}) -- 265
		for _index_1 = 1, #_list_1 do -- 265
			local file = _list_1[_index_1] -- 265
			if "init" == Path:getName(file):lower() then -- 266
				local fileName = Path:replaceExt(file, "") -- 267
				fileName = Path(path, dir, fileName) -- 268
				local entryName = Path:getName(Path:getPath(fileName)) -- 269
				local entryAdded -- 270
				do -- 270
					local _accum_0 -- 270
					for _index_2 = 1, #entries do -- 270
						local _des_0 = entries[_index_2] -- 270
						local ename, efile = _des_0[1], _des_0[2] -- 270
						if entryName == ename and efile == fileName then -- 271
							_accum_0 = true -- 271
							break -- 271
						end -- 271
					end -- 271
					entryAdded = _accum_0 -- 270
				end -- 271
				if entryAdded then -- 272
					goto _continue_1 -- 272
				end -- 272
				local examples = { } -- 273
				local tests = { } -- 274
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 275
				if Content:exist(examplePath) then -- 276
					local _list_2 = getFileEntries(examplePath) -- 277
					for _index_2 = 1, #_list_2 do -- 277
						local _des_0 = _list_2[_index_2] -- 277
						local name, ePath = _des_0[1], _des_0[2] -- 277
						local entry = { -- 279
							name, -- 279
							Path(path, dir, Path:getPath(file), ePath), -- 279
							workDir = Path:getPath(fileName) -- 280
						} -- 278
						examples[#examples + 1] = entry -- 282
					end -- 282
				end -- 276
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 283
				if Content:exist(testPath) then -- 284
					local _list_2 = getFileEntries(testPath) -- 285
					for _index_2 = 1, #_list_2 do -- 285
						local _des_0 = _list_2[_index_2] -- 285
						local name, tPath = _des_0[1], _des_0[2] -- 285
						local entry = { -- 287
							name, -- 287
							Path(path, dir, Path:getPath(file), tPath), -- 287
							workDir = Path:getPath(fileName) -- 288
						} -- 286
						tests[#tests + 1] = entry -- 290
					end -- 290
				end -- 284
				local entry = { -- 291
					entryName, -- 291
					fileName, -- 291
					examples, -- 291
					tests -- 291
				} -- 291
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 292
				if not Content:exist(bannerFile) then -- 293
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 294
					if not Content:exist(bannerFile) then -- 295
						bannerFile = nil -- 295
					end -- 295
				end -- 293
				if bannerFile then -- 296
					thread(function() -- 296
						if Cache:loadAsync(bannerFile) then -- 297
							local bannerTex = Texture2D(bannerFile) -- 298
							if bannerTex then -- 299
								entry[#entry + 1] = bannerFile -- 300
								entry[#entry + 1] = bannerTex -- 301
							end -- 299
						end -- 297
					end) -- 296
				end -- 296
				entries[#entries + 1] = entry -- 302
			end -- 266
			::_continue_1:: -- 266
		end -- 302
		::_continue_0:: -- 264
	end -- 302
	table.sort(entries, function(a, b) -- 303
		return a[1] < b[1] -- 303
	end) -- 303
	return entries -- 304
end -- 261
local gamesInDev -- 306
local doraTools -- 307
local allEntries -- 308
local updateEntries -- 310
updateEntries = function() -- 310
	gamesInDev = getProjectEntries(Content.writablePath) -- 311
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 312
	allEntries = { } -- 314
	for _index_0 = 1, #gamesInDev do -- 315
		local game = gamesInDev[_index_0] -- 315
		allEntries[#allEntries + 1] = game -- 316
		local examples, tests = game[3], game[4] -- 317
		for _index_1 = 1, #examples do -- 318
			local example = examples[_index_1] -- 318
			allEntries[#allEntries + 1] = example -- 319
		end -- 319
		for _index_1 = 1, #tests do -- 320
			local test = tests[_index_1] -- 320
			allEntries[#allEntries + 1] = test -- 321
		end -- 321
	end -- 321
end -- 310
updateEntries() -- 323
local doCompile -- 325
doCompile = function(minify) -- 325
	if building then -- 326
		return -- 326
	end -- 326
	building = true -- 327
	local startTime = App.runningTime -- 328
	local luaFiles = { } -- 329
	local yueFiles = { } -- 330
	local xmlFiles = { } -- 331
	local tlFiles = { } -- 332
	local writablePath = Content.writablePath -- 333
	local buildPaths = { -- 335
		{ -- 336
			Content.assetPath, -- 336
			Path(writablePath, ".build"), -- 337
			"" -- 338
		} -- 335
	} -- 334
	for _index_0 = 1, #gamesInDev do -- 341
		local _des_0 = gamesInDev[_index_0] -- 341
		local entryFile = _des_0[2] -- 341
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 342
		buildPaths[#buildPaths + 1] = { -- 344
			Path(writablePath, gamePath), -- 344
			Path(writablePath, ".build", gamePath), -- 345
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 346
			gamePath -- 347
		} -- 343
	end -- 347
	for _index_0 = 1, #buildPaths do -- 348
		local _des_0 = buildPaths[_index_0] -- 348
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 348
		if not Content:exist(inputPath) then -- 349
			goto _continue_0 -- 349
		end -- 349
		local _list_0 = getAllFiles(inputPath, { -- 351
			"lua" -- 351
		}) -- 351
		for _index_1 = 1, #_list_0 do -- 351
			local file = _list_0[_index_1] -- 351
			luaFiles[#luaFiles + 1] = { -- 353
				file, -- 353
				Path(inputPath, file), -- 354
				Path(outputPath, file), -- 355
				gamePath -- 356
			} -- 352
		end -- 356
		local _list_1 = getAllFiles(inputPath, { -- 358
			yueext -- 358
		}) -- 358
		for _index_1 = 1, #_list_1 do -- 358
			local file = _list_1[_index_1] -- 358
			yueFiles[#yueFiles + 1] = { -- 360
				file, -- 360
				Path(inputPath, file), -- 361
				Path(outputPath, Path:replaceExt(file, "lua")), -- 362
				searchPath, -- 363
				gamePath -- 364
			} -- 359
		end -- 364
		local _list_2 = getAllFiles(inputPath, { -- 366
			"xml" -- 366
		}) -- 366
		for _index_1 = 1, #_list_2 do -- 366
			local file = _list_2[_index_1] -- 366
			xmlFiles[#xmlFiles + 1] = { -- 368
				file, -- 368
				Path(inputPath, file), -- 369
				Path(outputPath, Path:replaceExt(file, "lua")), -- 370
				gamePath -- 371
			} -- 367
		end -- 371
		local _list_3 = getAllFiles(inputPath, { -- 373
			"tl" -- 373
		}) -- 373
		for _index_1 = 1, #_list_3 do -- 373
			local file = _list_3[_index_1] -- 373
			if not file:match(".*%.d%.tl$") then -- 374
				tlFiles[#tlFiles + 1] = { -- 376
					file, -- 376
					Path(inputPath, file), -- 377
					Path(outputPath, Path:replaceExt(file, "lua")), -- 378
					searchPath, -- 379
					gamePath -- 380
				} -- 375
			end -- 374
		end -- 380
		::_continue_0:: -- 349
	end -- 380
	local paths -- 382
	do -- 382
		local _tbl_0 = { } -- 382
		local _list_0 = { -- 383
			luaFiles, -- 383
			yueFiles, -- 383
			xmlFiles, -- 383
			tlFiles -- 383
		} -- 383
		for _index_0 = 1, #_list_0 do -- 383
			local files = _list_0[_index_0] -- 383
			for _index_1 = 1, #files do -- 384
				local file = files[_index_1] -- 384
				_tbl_0[Path:getPath(file[3])] = true -- 382
			end -- 382
		end -- 382
		paths = _tbl_0 -- 382
	end -- 384
	for path in pairs(paths) do -- 386
		Content:mkdir(path) -- 386
	end -- 386
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 388
	local fileCount = 0 -- 389
	local errors = { } -- 390
	for _index_0 = 1, #yueFiles do -- 391
		local _des_0 = yueFiles[_index_0] -- 391
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 391
		local filename -- 392
		if gamePath then -- 392
			filename = Path(gamePath, file) -- 392
		else -- 392
			filename = file -- 392
		end -- 392
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 393
			if not codes then -- 394
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 395
				return -- 396
			end -- 394
			local success, result = LintYueGlobals(codes, globals) -- 397
			if success then -- 398
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 399
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 400
				codes = codes:gsub("^\n*", "") -- 401
				if not (result == "") then -- 402
					result = result .. "\n" -- 402
				end -- 402
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 403
			else -- 405
				local yueCodes = Content:load(input) -- 405
				if yueCodes then -- 405
					local globalErrors = { } -- 406
					for _index_1 = 1, #result do -- 407
						local _des_1 = result[_index_1] -- 407
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 407
						local countLine = 1 -- 408
						local code = "" -- 409
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 410
							if countLine == line then -- 411
								code = lineCode -- 412
								break -- 413
							end -- 411
							countLine = countLine + 1 -- 414
						end -- 414
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 415
					end -- 415
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 416
				else -- 418
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 418
				end -- 405
			end -- 398
		end, function(success) -- 393
			if success then -- 419
				print("Yue compiled: " .. tostring(filename)) -- 419
			end -- 419
			fileCount = fileCount + 1 -- 420
		end) -- 393
	end -- 420
	thread(function() -- 422
		for _index_0 = 1, #xmlFiles do -- 423
			local _des_0 = xmlFiles[_index_0] -- 423
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 423
			local filename -- 424
			if gamePath then -- 424
				filename = Path(gamePath, file) -- 424
			else -- 424
				filename = file -- 424
			end -- 424
			local sourceCodes = Content:loadAsync(input) -- 425
			local codes, err = xml.tolua(sourceCodes) -- 426
			if not codes then -- 427
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 428
			else -- 430
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 430
				print("Xml compiled: " .. tostring(filename)) -- 431
			end -- 427
			fileCount = fileCount + 1 -- 432
		end -- 432
	end) -- 422
	thread(function() -- 434
		for _index_0 = 1, #tlFiles do -- 435
			local _des_0 = tlFiles[_index_0] -- 435
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 435
			local filename -- 436
			if gamePath then -- 436
				filename = Path(gamePath, file) -- 436
			else -- 436
				filename = file -- 436
			end -- 436
			local sourceCodes = Content:loadAsync(input) -- 437
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 438
			if not codes then -- 439
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 440
			else -- 442
				Content:saveAsync(output, codes) -- 442
				print("Teal compiled: " .. tostring(filename)) -- 443
			end -- 439
			fileCount = fileCount + 1 -- 444
		end -- 444
	end) -- 434
	return thread(function() -- 446
		wait(function() -- 447
			return fileCount == totalFiles -- 447
		end) -- 447
		if minify then -- 448
			local _list_0 = { -- 449
				yueFiles, -- 449
				xmlFiles, -- 449
				tlFiles -- 449
			} -- 449
			for _index_0 = 1, #_list_0 do -- 449
				local files = _list_0[_index_0] -- 449
				for _index_1 = 1, #files do -- 449
					local file = files[_index_1] -- 449
					local output = Path:replaceExt(file[3], "lua") -- 450
					luaFiles[#luaFiles + 1] = { -- 452
						Path:replaceExt(file[1], "lua"), -- 452
						output, -- 453
						output -- 454
					} -- 451
				end -- 454
			end -- 454
			local FormatMini -- 456
			do -- 456
				local _obj_0 = require("luaminify") -- 456
				FormatMini = _obj_0.FormatMini -- 456
			end -- 456
			for _index_0 = 1, #luaFiles do -- 457
				local _des_0 = luaFiles[_index_0] -- 457
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 457
				if Content:exist(input) then -- 458
					local sourceCodes = Content:loadAsync(input) -- 459
					local res, err = FormatMini(sourceCodes) -- 460
					if res then -- 461
						Content:saveAsync(output, res) -- 462
						print("Minify: " .. tostring(file)) -- 463
					else -- 465
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 465
					end -- 461
				else -- 467
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 467
				end -- 458
			end -- 467
			package.loaded["luaminify.FormatMini"] = nil -- 468
			package.loaded["luaminify.ParseLua"] = nil -- 469
			package.loaded["luaminify.Scope"] = nil -- 470
			package.loaded["luaminify.Util"] = nil -- 471
		end -- 448
		local errorMessage = table.concat(errors, "\n") -- 472
		if errorMessage ~= "" then -- 473
			print(errorMessage) -- 473
		end -- 473
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 474
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 475
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 476
		Content:clearPathCache() -- 477
		teal.clear() -- 478
		yue.clear() -- 479
		building = false -- 480
	end) -- 480
end -- 325
local doClean -- 482
doClean = function() -- 482
	if building then -- 483
		return -- 483
	end -- 483
	local writablePath = Content.writablePath -- 484
	local targetDir = Path(writablePath, ".build") -- 485
	Content:clearPathCache() -- 486
	if Content:remove(targetDir) then -- 487
		return print("Cleaned: " .. tostring(targetDir)) -- 488
	end -- 487
end -- 482
local screenScale = 2.0 -- 490
local scaleContent = false -- 491
local isInEntry = true -- 492
local currentEntry = nil -- 493
local footerWindow = nil -- 495
local entryWindow = nil -- 496
local testingThread = nil -- 497
local setupEventHandlers = nil -- 499
local allClear -- 501
allClear = function() -- 501
	local _list_0 = Routine -- 502
	for _index_0 = 1, #_list_0 do -- 502
		local routine = _list_0[_index_0] -- 502
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 504
			goto _continue_0 -- 505
		else -- 507
			Routine:remove(routine) -- 507
		end -- 507
		::_continue_0:: -- 503
	end -- 507
	for _index_0 = 1, #moduleCache do -- 508
		local module = moduleCache[_index_0] -- 508
		package.loaded[module] = nil -- 509
	end -- 509
	moduleCache = { } -- 510
	Director:cleanup() -- 511
	Cache:unload() -- 512
	Entity:clear() -- 513
	Platformer.Data:clear() -- 514
	Platformer.UnitAction:clear() -- 515
	Audio:stopStream(0.5) -- 516
	Struct:clear() -- 517
	View.postEffect = nil -- 518
	View.scale = scaleContent and screenScale or 1 -- 519
	Director.clearColor = Color(0xff1a1a1a) -- 520
	teal.clear() -- 521
	yue.clear() -- 522
	for _, item in pairs(ubox()) do -- 523
		local node = tolua.cast(item, "Node") -- 524
		if node then -- 524
			node:cleanup() -- 524
		end -- 524
	end -- 524
	collectgarbage() -- 525
	collectgarbage() -- 526
	setupEventHandlers() -- 527
	Content.searchPaths = searchPaths -- 528
	App.idled = true -- 529
	return Wasm:clear() -- 530
end -- 501
_module_0["allClear"] = allClear -- 530
local clearTempFiles -- 532
clearTempFiles = function() -- 532
	local writablePath = Content.writablePath -- 533
	Content:remove(Path(writablePath, ".upload")) -- 534
	return Content:remove(Path(writablePath, ".download")) -- 535
end -- 532
local waitForWebStart = true -- 537
thread(function() -- 538
	sleep(2) -- 539
	waitForWebStart = false -- 540
end) -- 538
local reloadDevEntry -- 542
reloadDevEntry = function() -- 542
	return thread(function() -- 542
		waitForWebStart = true -- 543
		doClean() -- 544
		allClear() -- 545
		_G.require = oldRequire -- 546
		Dora.require = oldRequire -- 547
		package.loaded["Script.Dev.Entry"] = nil -- 548
		return Director.systemScheduler:schedule(function() -- 549
			Routine:clear() -- 550
			oldRequire("Script.Dev.Entry") -- 551
			return true -- 552
		end) -- 552
	end) -- 552
end -- 542
local setWorkspace -- 554
setWorkspace = function(path) -- 554
	Content.writablePath = path -- 555
	config.writablePath = Content.writablePath -- 556
	return thread(function() -- 557
		sleep() -- 558
		return reloadDevEntry() -- 559
	end) -- 559
end -- 554
local _anon_func_1 = function(App, _with_0) -- 574
	local _val_0 = App.platform -- 574
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 574
end -- 574
setupEventHandlers = function() -- 561
	local _with_0 = Director.postNode -- 562
	_with_0:onAppEvent(function(eventType) -- 563
		if eventType == "Quit" then -- 563
			allClear() -- 564
			return clearTempFiles() -- 565
		end -- 563
	end) -- 563
	_with_0:onAppChange(function(settingName) -- 566
		if "Theme" == settingName then -- 567
			config.themeColor = App.themeColor:toARGB() -- 568
		elseif "Locale" == settingName then -- 569
			config.locale = App.locale -- 570
			updateLocale() -- 571
			return teal.clear(true) -- 572
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 573
			if _anon_func_1(App, _with_0) then -- 574
				if "FullScreen" == settingName then -- 576
					config.fullScreen = App.fullScreen -- 576
				elseif "Position" == settingName then -- 577
					local _obj_0 = App.winPosition -- 577
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 577
				elseif "Size" == settingName then -- 578
					local width, height -- 579
					do -- 579
						local _obj_0 = App.winSize -- 579
						width, height = _obj_0.width, _obj_0.height -- 579
					end -- 579
					config.winWidth = width -- 580
					config.winHeight = height -- 581
				end -- 581
			end -- 574
		end -- 581
	end) -- 566
	_with_0:onAppWS(function(eventType) -- 582
		if eventType == "Close" then -- 582
			if HttpServer.wsConnectionCount == 0 then -- 583
				return updateEntries() -- 584
			end -- 583
		end -- 582
	end) -- 582
	_with_0:slot("UpdateEntries", function() -- 585
		return updateEntries() -- 585
	end) -- 585
	return _with_0 -- 562
end -- 561
setupEventHandlers() -- 587
clearTempFiles() -- 588
local stop -- 590
stop = function() -- 590
	if isInEntry then -- 591
		return false -- 591
	end -- 591
	allClear() -- 592
	isInEntry = true -- 593
	currentEntry = nil -- 594
	return true -- 595
end -- 590
_module_0["stop"] = stop -- 595
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 612
	if workDir == nil then -- 605
		workDir = Path:getPath(file) -- 605
	end -- 605
	Content:insertSearchPath(1, workDir) -- 606
	local scriptPath = Path(workDir, "Script") -- 607
	if Content:exist(scriptPath) then -- 608
		Content:insertSearchPath(1, scriptPath) -- 609
	end -- 608
	local result = require(file) -- 610
	if "function" == type(result) then -- 611
		result() -- 611
	end -- 611
	return nil -- 612
end -- 605
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 644
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 641
	label.alignment = "Left" -- 642
	label.textWidth = width - fontSize -- 643
	label.text = err -- 644
	return label -- 641
end -- 641
local enterEntryAsync -- 597
enterEntryAsync = function(entry) -- 597
	isInEntry = false -- 598
	App.idled = false -- 599
	emit(Profiler.EventName, "ClearLoader") -- 600
	currentEntry = entry -- 601
	local file, workDir = entry[2], entry.workDir -- 602
	sleep() -- 603
	return xpcall(_anon_func_2, function(msg) -- 645
		local err = debug.traceback(msg) -- 614
		Log("Error", err) -- 615
		allClear() -- 616
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 617
		local viewWidth, viewHeight -- 618
		do -- 618
			local _obj_0 = View.size -- 618
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 618
		end -- 618
		local width, height = viewWidth - 20, viewHeight - 20 -- 619
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 620
		Director.ui:addChild((function() -- 621
			local root = AlignNode() -- 621
			do -- 622
				local _obj_0 = App.bufferSize -- 622
				width, height = _obj_0.width, _obj_0.height -- 622
			end -- 622
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 623
			root:onAppChange(function(settingName) -- 624
				if settingName == "Size" then -- 624
					do -- 625
						local _obj_0 = App.bufferSize -- 625
						width, height = _obj_0.width, _obj_0.height -- 625
					end -- 625
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 626
				end -- 624
			end) -- 624
			root:addChild((function() -- 627
				local _with_0 = ScrollArea({ -- 628
					width = width, -- 628
					height = height, -- 629
					paddingX = 0, -- 630
					paddingY = 50, -- 631
					viewWidth = height, -- 632
					viewHeight = height -- 633
				}) -- 627
				root:onAlignLayout(function(w, h) -- 635
					_with_0.position = Vec2(w / 2, h / 2) -- 636
					w = w - 20 -- 637
					h = h - 20 -- 638
					_with_0.view.children.first.textWidth = w - fontSize -- 639
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 640
				end) -- 635
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 641
				return _with_0 -- 627
			end)()) -- 627
			return root -- 621
		end)()) -- 621
		return err -- 645
	end, Content, Path, file, require, type, workDir) -- 645
end -- 597
_module_0["enterEntryAsync"] = enterEntryAsync -- 645
local enterDemoEntry -- 647
enterDemoEntry = function(entry) -- 647
	return thread(function() -- 647
		return enterEntryAsync(entry) -- 647
	end) -- 647
end -- 647
local reloadCurrentEntry -- 649
reloadCurrentEntry = function() -- 649
	if currentEntry then -- 650
		allClear() -- 651
		return enterDemoEntry(currentEntry) -- 652
	end -- 650
end -- 649
Director.clearColor = Color(0xff1a1a1a) -- 654
local isOSSLicenseExist = Content:exist("LICENSES") -- 656
local ossLicenses = nil -- 657
local ossLicenseOpen = false -- 658
local extraOperations -- 660
extraOperations = function() -- 660
	local zh = useChinese and isChineseSupported -- 661
	if isDesktop then -- 662
		local themeColor = App.themeColor -- 663
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 664
		do -- 665
			local changed -- 665
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 665
			if changed then -- 665
				App.alwaysOnTop = alwaysOnTop -- 666
				config.alwaysOnTop = alwaysOnTop -- 667
			end -- 665
		end -- 665
		SeparatorText(zh and "工作目录" or "Workspace") -- 668
		PushTextWrapPos(400, function() -- 669
			return TextColored(themeColor, writablePath) -- 670
		end) -- 669
		if Button(zh and "改变目录" or "Set Folder") then -- 671
			App:openFileDialog(true, function(path) -- 672
				if path ~= "" then -- 673
					return setWorkspace(path) -- 673
				end -- 673
			end) -- 672
		end -- 671
		SameLine() -- 674
		if Button(zh and "使用默认" or "Use Default") then -- 675
			setWorkspace(Content.appPath) -- 676
		end -- 675
		Separator() -- 677
	end -- 662
	if isOSSLicenseExist then -- 678
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 679
			if not ossLicenses then -- 680
				ossLicenses = { } -- 681
				local licenseText = Content:load("LICENSES") -- 682
				ossLicenseOpen = (licenseText ~= nil) -- 683
				if ossLicenseOpen then -- 683
					licenseText = licenseText:gsub("\r\n", "\n") -- 684
					for license in GSplit(licenseText, "\n--------\n", true) do -- 685
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 686
						if name then -- 686
							ossLicenses[#ossLicenses + 1] = { -- 687
								name, -- 687
								text -- 687
							} -- 687
						end -- 686
					end -- 687
				end -- 683
			else -- 689
				ossLicenseOpen = true -- 689
			end -- 680
		end -- 679
		if ossLicenseOpen then -- 690
			local width, height, themeColor -- 691
			do -- 691
				local _obj_0 = App -- 691
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 691
			end -- 691
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 692
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 693
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 694
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 697
					"NoSavedSettings" -- 697
				}, function() -- 698
					for _index_0 = 1, #ossLicenses do -- 698
						local _des_0 = ossLicenses[_index_0] -- 698
						local firstLine, text = _des_0[1], _des_0[2] -- 698
						local name, license = firstLine:match("(.+): (.+)") -- 699
						TextColored(themeColor, name) -- 700
						SameLine() -- 701
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 702
							return TextWrapped(text) -- 702
						end) -- 702
					end -- 702
				end) -- 694
			end) -- 694
		end -- 690
	end -- 678
	if not App.debugging then -- 704
		return -- 704
	end -- 704
	return TreeNode(zh and "开发操作" or "Development", function() -- 705
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 706
			OpenPopup("build") -- 706
		end -- 706
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 707
			return BeginPopup("build", function() -- 707
				if Selectable(zh and "编译" or "Compile") then -- 708
					doCompile(false) -- 708
				end -- 708
				Separator() -- 709
				if Selectable(zh and "压缩" or "Minify") then -- 710
					doCompile(true) -- 710
				end -- 710
				Separator() -- 711
				if Selectable(zh and "清理" or "Clean") then -- 712
					return doClean() -- 712
				end -- 712
			end) -- 712
		end) -- 707
		if isInEntry then -- 713
			if waitForWebStart then -- 714
				BeginDisabled(function() -- 715
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 715
				end) -- 715
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 716
				reloadDevEntry() -- 717
			end -- 714
		end -- 713
		do -- 718
			local changed -- 718
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 718
			if changed then -- 718
				View.scale = scaleContent and screenScale or 1 -- 719
			end -- 718
		end -- 718
		do -- 720
			local changed -- 720
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 720
			if changed then -- 720
				config.engineDev = engineDev -- 721
			end -- 720
		end -- 720
		if Button(zh and "开始自动测试" or "Test automatically") then -- 722
			testingThread = thread(function() -- 723
				local _ <close> = setmetatable({ }, { -- 724
					__close = function() -- 724
						allClear() -- 725
						testingThread = nil -- 726
						isInEntry = true -- 727
						currentEntry = nil -- 728
						return print("Testing done!") -- 729
					end -- 724
				}) -- 724
				for _, entry in ipairs(allEntries) do -- 730
					allClear() -- 731
					print("Start " .. tostring(entry[1])) -- 732
					enterDemoEntry(entry) -- 733
					sleep(2) -- 734
					print("Stop " .. tostring(entry[1])) -- 735
				end -- 735
			end) -- 723
		end -- 722
	end) -- 705
end -- 660
local transparant = Color(0x0) -- 737
local windowFlags = { -- 738
	"NoTitleBar", -- 738
	"NoResize", -- 738
	"NoMove", -- 738
	"NoCollapse", -- 738
	"NoSavedSettings", -- 738
	"NoBringToFrontOnFocus" -- 738
} -- 738
local initFooter = true -- 746
local _anon_func_4 = function(allEntries, currentIndex) -- 782
	if currentIndex > 1 then -- 782
		return allEntries[currentIndex - 1] -- 783
	else -- 785
		return allEntries[#allEntries] -- 785
	end -- 782
end -- 782
local _anon_func_5 = function(allEntries, currentIndex) -- 789
	if currentIndex < #allEntries then -- 789
		return allEntries[currentIndex + 1] -- 790
	else -- 792
		return allEntries[1] -- 792
	end -- 789
end -- 789
footerWindow = threadLoop(function() -- 747
	local zh = useChinese and isChineseSupported -- 748
	if HttpServer.wsConnectionCount > 0 then -- 749
		return -- 750
	end -- 749
	if Keyboard:isKeyDown("Escape") then -- 751
		allClear() -- 752
		App:shutdown() -- 753
	end -- 751
	do -- 754
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 755
		if ctrl and Keyboard:isKeyDown("Q") then -- 756
			stop() -- 757
		end -- 756
		if ctrl and Keyboard:isKeyDown("Z") then -- 758
			reloadCurrentEntry() -- 759
		end -- 758
		if ctrl and Keyboard:isKeyDown(",") then -- 760
			if showFooter then -- 761
				showStats = not showStats -- 761
			else -- 761
				showStats = true -- 761
			end -- 761
			showFooter = true -- 762
			config.showFooter = showFooter -- 763
			config.showStats = showStats -- 764
		end -- 760
		if ctrl and Keyboard:isKeyDown(".") then -- 765
			if showFooter then -- 766
				showConsole = not showConsole -- 766
			else -- 766
				showConsole = true -- 766
			end -- 766
			showFooter = true -- 767
			config.showFooter = showFooter -- 768
			config.showConsole = showConsole -- 769
		end -- 765
		if ctrl and Keyboard:isKeyDown("/") then -- 770
			showFooter = not showFooter -- 771
			config.showFooter = showFooter -- 772
		end -- 770
		local left = ctrl and Keyboard:isKeyDown("Left") -- 773
		local right = ctrl and Keyboard:isKeyDown("Right") -- 774
		local currentIndex = nil -- 775
		for i, entry in ipairs(allEntries) do -- 776
			if currentEntry == entry then -- 777
				currentIndex = i -- 778
			end -- 777
		end -- 778
		if left then -- 779
			allClear() -- 780
			if currentIndex == nil then -- 781
				currentIndex = #allEntries + 1 -- 781
			end -- 781
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 782
		end -- 779
		if right then -- 786
			allClear() -- 787
			if currentIndex == nil then -- 788
				currentIndex = 0 -- 788
			end -- 788
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 789
		end -- 786
	end -- 792
	if not showEntry then -- 793
		return -- 793
	end -- 793
	local width, height -- 795
	do -- 795
		local _obj_0 = App.visualSize -- 795
		width, height = _obj_0.width, _obj_0.height -- 795
	end -- 795
	SetNextWindowSize(Vec2(50, 50)) -- 796
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 797
	PushStyleColor("WindowBg", transparant, function() -- 798
		return Begin("Show", windowFlags, function() -- 798
			if isInEntry or width >= 540 then -- 799
				local changed -- 800
				changed, showFooter = Checkbox("##dev", showFooter) -- 800
				if changed then -- 800
					config.showFooter = showFooter -- 801
				end -- 800
			end -- 799
		end) -- 801
	end) -- 798
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 803
		reloadDevEntry() -- 807
	end -- 803
	if initFooter then -- 808
		initFooter = false -- 809
	else -- 811
		if not showFooter then -- 811
			return -- 811
		end -- 811
	end -- 808
	SetNextWindowSize(Vec2(width, 50)) -- 813
	SetNextWindowPos(Vec2(0, height - 50)) -- 814
	SetNextWindowBgAlpha(0.35) -- 815
	do -- 816
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 817
			return Begin("Footer", windowFlags, function() -- 818
				Dummy(Vec2(width - 20, 0)) -- 819
				do -- 820
					local changed -- 820
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 820
					if changed then -- 820
						config.showStats = showStats -- 821
					end -- 820
				end -- 820
				SameLine() -- 822
				do -- 823
					local changed -- 823
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 823
					if changed then -- 823
						config.showConsole = showConsole -- 824
					end -- 823
				end -- 823
				if config.updateNotification then -- 825
					SameLine() -- 826
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 827
						allClear() -- 828
						config.updateNotification = false -- 829
						enterDemoEntry({ -- 831
							"SelfUpdater", -- 831
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 832
						}) -- 830
					end -- 827
				end -- 825
				if not isInEntry then -- 834
					SameLine() -- 835
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 836
					local currentIndex = nil -- 837
					for i, entry in ipairs(allEntries) do -- 838
						if currentEntry == entry then -- 839
							currentIndex = i -- 840
						end -- 839
					end -- 840
					if currentIndex then -- 841
						if currentIndex > 1 then -- 842
							SameLine() -- 843
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 844
								allClear() -- 845
								enterDemoEntry(allEntries[currentIndex - 1]) -- 846
							end -- 844
						end -- 842
						if currentIndex < #allEntries then -- 847
							SameLine() -- 848
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 849
								allClear() -- 850
								enterDemoEntry(allEntries[currentIndex + 1]) -- 851
							end -- 849
						end -- 847
					end -- 841
					SameLine() -- 852
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 853
						reloadCurrentEntry() -- 854
					end -- 853
					if back then -- 855
						allClear() -- 856
						isInEntry = true -- 857
						currentEntry = nil -- 858
					end -- 855
				end -- 834
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 859
					if showStats then -- 860
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 861
						showStats = ShowStats(showStats, extraOperations) -- 862
						config.showStats = showStats -- 863
					end -- 860
					if showConsole then -- 864
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 865
						showConsole = ShowConsole(showConsole) -- 866
						config.showConsole = showConsole -- 867
					end -- 864
				end) -- 859
			end) -- 818
		end) -- 817
	end -- 867
end) -- 747
local MaxWidth <const> = 960 -- 869
local displayWindowFlags = { -- 871
	"NoDecoration", -- 871
	"NoSavedSettings", -- 871
	"NoFocusOnAppearing", -- 871
	"NoNav", -- 871
	"NoMove", -- 871
	"NoScrollWithMouse", -- 871
	"AlwaysAutoResize", -- 871
	"NoBringToFrontOnFocus" -- 871
} -- 871
local webStatus = nil -- 882
local descColor = Color(0xffa1a1a1) -- 883
local toolOpen = false -- 884
local filterText = nil -- 885
local anyEntryMatched = false -- 886
local urlClicked = nil -- 887
local match -- 888
match = function(name) -- 888
	local res = not filterText or name:lower():match(filterText) -- 889
	if res then -- 890
		anyEntryMatched = true -- 890
	end -- 890
	return res -- 891
end -- 888
local icon = Path("Script", "Dev", "icon_s.png") -- 892
local iconTex = nil -- 893
thread(function() -- 894
	if Cache:loadAsync(icon) then -- 894
		iconTex = Texture2D(icon) -- 894
	end -- 894
end) -- 894
local sep -- 896
sep = function() -- 896
	return SeparatorText("") -- 896
end -- 896
local thinSep -- 897
thinSep = function() -- 897
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 897
end -- 897
entryWindow = threadLoop(function() -- 899
	if App.fpsLimited ~= config.fpsLimited then -- 900
		config.fpsLimited = App.fpsLimited -- 901
	end -- 900
	if App.targetFPS ~= config.targetFPS then -- 902
		config.targetFPS = App.targetFPS -- 903
	end -- 902
	if View.vsync ~= config.vsync then -- 904
		config.vsync = View.vsync -- 905
	end -- 904
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 906
		config.fixedFPS = Director.scheduler.fixedFPS -- 907
	end -- 906
	if Director.profilerSending ~= config.webProfiler then -- 908
		config.webProfiler = Director.profilerSending -- 909
	end -- 908
	if urlClicked then -- 910
		local _, result = coroutine.resume(urlClicked) -- 911
		if result then -- 912
			coroutine.close(urlClicked) -- 913
			urlClicked = nil -- 914
		end -- 912
	end -- 910
	if not showEntry then -- 915
		return -- 915
	end -- 915
	if not isInEntry then -- 916
		return -- 916
	end -- 916
	local zh = useChinese and isChineseSupported -- 917
	if HttpServer.wsConnectionCount > 0 then -- 918
		local themeColor = App.themeColor -- 919
		local width, height -- 920
		do -- 920
			local _obj_0 = App.visualSize -- 920
			width, height = _obj_0.width, _obj_0.height -- 920
		end -- 920
		SetNextWindowBgAlpha(0.5) -- 921
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 922
		Begin("Web IDE Connected", displayWindowFlags, function() -- 923
			Separator() -- 924
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 925
			if iconTex then -- 926
				Image(icon, Vec2(24, 24)) -- 927
				SameLine() -- 928
			end -- 926
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 929
			TextColored(descColor, slogon) -- 930
			return Separator() -- 931
		end) -- 923
		return -- 932
	end -- 918
	local themeColor = App.themeColor -- 934
	local fullWidth, height -- 935
	do -- 935
		local _obj_0 = App.visualSize -- 935
		fullWidth, height = _obj_0.width, _obj_0.height -- 935
	end -- 935
	SetNextWindowBgAlpha(0.85) -- 937
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 938
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 939
		return Begin("Web IDE", displayWindowFlags, function() -- 940
			Separator() -- 941
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 942
			SameLine() -- 943
			TextDisabled('(?)') -- 944
			if IsItemHovered() then -- 945
				BeginTooltip(function() -- 946
					return PushTextWrapPos(280, function() -- 947
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 948
					end) -- 948
				end) -- 946
			end -- 945
			do -- 949
				local url -- 949
				if webStatus ~= nil then -- 949
					url = webStatus.url -- 949
				end -- 949
				if url then -- 949
					if isDesktop and not config.fullScreen then -- 950
						if urlClicked then -- 951
							BeginDisabled(function() -- 952
								return Button(url) -- 952
							end) -- 952
						elseif Button(url) then -- 953
							urlClicked = once(function() -- 954
								return sleep(5) -- 954
							end) -- 954
							App:openURL("http://localhost:8866") -- 955
						end -- 951
					else -- 957
						TextColored(descColor, url) -- 957
					end -- 950
				else -- 959
					TextColored(descColor, zh and '不可用' or 'not available') -- 959
				end -- 949
			end -- 949
			return Separator() -- 960
		end) -- 960
	end) -- 939
	local width = math.min(MaxWidth, fullWidth) -- 962
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 963
	local maxColumns = math.max(math.floor(width / 200), 1) -- 964
	SetNextWindowPos(Vec2.zero) -- 965
	SetNextWindowBgAlpha(0) -- 966
	do -- 967
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 968
			return Begin("Dora Dev", displayWindowFlags, function() -- 969
				Dummy(Vec2(fullWidth - 20, 0)) -- 970
				if iconTex then -- 971
					Image(icon, Vec2(24, 24)) -- 972
					SameLine() -- 973
				end -- 971
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 974
				if fullWidth >= 400 then -- 975
					SameLine() -- 976
					Dummy(Vec2(fullWidth - 400, 0)) -- 977
					SameLine() -- 978
					SetNextItemWidth(zh and -90 or -140) -- 979
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 980
						"AutoSelectAll" -- 980
					}) then -- 980
						config.filter = filterBuf.text -- 981
					end -- 980
					SameLine() -- 982
					if Button(zh and '下载' or 'Download') then -- 983
						allClear() -- 984
						enterDemoEntry({ -- 986
							"ResourceDownloader", -- 986
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 987
						}) -- 985
					end -- 983
				end -- 975
				Separator() -- 989
				return Dummy(Vec2(fullWidth - 20, 0)) -- 990
			end) -- 969
		end) -- 968
	end -- 990
	anyEntryMatched = false -- 992
	SetNextWindowPos(Vec2(0, 50)) -- 993
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 994
	do -- 995
		return PushStyleColor("WindowBg", transparant, function() -- 996
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 997
				return PushStyleVar("Alpha", 1, function() -- 998
					return Begin("Content", windowFlags, function() -- 999
						local DemoViewWidth <const> = 320 -- 1000
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1001
						if filterText then -- 1002
							filterText = filterText:lower() -- 1002
						end -- 1002
						if #gamesInDev > 0 then -- 1003
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1004
							local realViewWidth = (width - 20) / columns -- 1005
							Columns(columns, false) -- 1006
							for _index_0 = 1, #gamesInDev do -- 1007
								local game = gamesInDev[_index_0] -- 1007
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1008
								if match(gameName) then -- 1009
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1010
									SameLine() -- 1011
									TextWrapped(gameName) -- 1012
									if columns > 1 then -- 1013
										if bannerFile then -- 1014
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1015
											local displayWidth <const> = realViewWidth - 20 -- 1016
											texHeight = displayWidth * texHeight / texWidth -- 1017
											texWidth = displayWidth -- 1018
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1019
										end -- 1014
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1020
											enterDemoEntry(game) -- 1021
										end -- 1020
									else -- 1023
										if bannerFile then -- 1023
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1024
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1025
											local sizing = 0.8 -- 1026
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1027
											texWidth = displayWidth * sizing -- 1028
											if texWidth > 500 then -- 1029
												sizing = 0.6 -- 1030
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1031
												texWidth = displayWidth * sizing -- 1032
											end -- 1029
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1033
											Dummy(Vec2(padding, 0)) -- 1034
											SameLine() -- 1035
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1036
										end -- 1023
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1037
											enterDemoEntry(game) -- 1038
										end -- 1037
									end -- 1013
									if #tests == 0 and #examples == 0 then -- 1039
										thinSep() -- 1040
									end -- 1039
									NextColumn() -- 1041
								end -- 1009
								local showSep = false -- 1042
								if #examples > 0 then -- 1043
									local showExample = false -- 1044
									do -- 1045
										local _accum_0 -- 1045
										for _index_1 = 1, #examples do -- 1045
											local _des_0 = examples[_index_1] -- 1045
											local name = _des_0[1] -- 1045
											if match(name) then -- 1046
												_accum_0 = true -- 1046
												break -- 1046
											end -- 1046
										end -- 1046
										showExample = _accum_0 -- 1045
									end -- 1046
									if showExample then -- 1047
										showSep = true -- 1048
										Columns(1, false) -- 1049
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1050
										SameLine() -- 1051
										local opened -- 1052
										if (filterText ~= nil) then -- 1052
											opened = showExample -- 1052
										else -- 1052
											opened = false -- 1052
										end -- 1052
										if game.exampleOpen == nil then -- 1053
											game.exampleOpen = opened -- 1053
										end -- 1053
										SetNextItemOpen(game.exampleOpen) -- 1054
										TreeNode(tostring(gameName) .. "###example-" .. tostring(fileName), function() -- 1055
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1056
												Columns(maxColumns, false) -- 1057
												for _index_1 = 1, #examples do -- 1058
													local example = examples[_index_1] -- 1058
													if not match(example[1]) then -- 1059
														goto _continue_0 -- 1059
													end -- 1059
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1060
														if Button(example[1], Vec2(-1, 40)) then -- 1061
															enterDemoEntry(example) -- 1062
														end -- 1061
														return NextColumn() -- 1063
													end) -- 1060
													opened = true -- 1064
													::_continue_0:: -- 1059
												end -- 1064
											end) -- 1056
										end) -- 1055
										game.exampleOpen = opened -- 1065
									end -- 1047
								end -- 1043
								if #tests > 0 then -- 1066
									local showTest = false -- 1067
									do -- 1068
										local _accum_0 -- 1068
										for _index_1 = 1, #tests do -- 1068
											local _des_0 = tests[_index_1] -- 1068
											local name = _des_0[1] -- 1068
											if match(name) then -- 1069
												_accum_0 = true -- 1069
												break -- 1069
											end -- 1069
										end -- 1069
										showTest = _accum_0 -- 1068
									end -- 1069
									if showTest then -- 1070
										showSep = true -- 1071
										Columns(1, false) -- 1072
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1073
										SameLine() -- 1074
										local opened -- 1075
										if (filterText ~= nil) then -- 1075
											opened = showTest -- 1075
										else -- 1075
											opened = false -- 1075
										end -- 1075
										if game.testOpen == nil then -- 1076
											game.testOpen = opened -- 1076
										end -- 1076
										SetNextItemOpen(game.testOpen) -- 1077
										TreeNode(tostring(gameName) .. "###test-" .. tostring(fileName), function() -- 1078
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1079
												Columns(maxColumns, false) -- 1080
												for _index_1 = 1, #tests do -- 1081
													local test = tests[_index_1] -- 1081
													if not match(test[1]) then -- 1082
														goto _continue_0 -- 1082
													end -- 1082
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1083
														if Button(test[1], Vec2(-1, 40)) then -- 1084
															enterDemoEntry(test) -- 1085
														end -- 1084
														return NextColumn() -- 1086
													end) -- 1083
													opened = true -- 1087
													::_continue_0:: -- 1082
												end -- 1087
											end) -- 1079
										end) -- 1078
										game.testOpen = opened -- 1088
									end -- 1070
								end -- 1066
								if showSep then -- 1089
									Columns(1, false) -- 1090
									thinSep() -- 1091
									Columns(columns, false) -- 1092
								end -- 1089
							end -- 1092
						end -- 1003
						if #doraTools > 0 then -- 1093
							local showTool = false -- 1094
							do -- 1095
								local _accum_0 -- 1095
								for _index_0 = 1, #doraTools do -- 1095
									local _des_0 = doraTools[_index_0] -- 1095
									local name = _des_0[1] -- 1095
									if match(name) then -- 1096
										_accum_0 = true -- 1096
										break -- 1096
									end -- 1096
								end -- 1096
								showTool = _accum_0 -- 1095
							end -- 1096
							if not showTool then -- 1097
								goto endEntry -- 1097
							end -- 1097
							Columns(1, false) -- 1098
							TextColored(themeColor, "Dora SSR:") -- 1099
							SameLine() -- 1100
							Text(zh and "开发支持" or "Development Support") -- 1101
							Separator() -- 1102
							if #doraTools > 0 then -- 1103
								local opened -- 1104
								if (filterText ~= nil) then -- 1104
									opened = showTool -- 1104
								else -- 1104
									opened = false -- 1104
								end -- 1104
								SetNextItemOpen(toolOpen) -- 1105
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1106
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1107
										Columns(maxColumns, false) -- 1108
										for _index_0 = 1, #doraTools do -- 1109
											local example = doraTools[_index_0] -- 1109
											if not match(example[1]) then -- 1110
												goto _continue_0 -- 1110
											end -- 1110
											if Button(example[1], Vec2(-1, 40)) then -- 1111
												enterDemoEntry(example) -- 1112
											end -- 1111
											NextColumn() -- 1113
											::_continue_0:: -- 1110
										end -- 1113
										Columns(1, false) -- 1114
										opened = true -- 1115
									end) -- 1107
								end) -- 1106
								toolOpen = opened -- 1116
							end -- 1103
						end -- 1093
						::endEntry:: -- 1117
						if not anyEntryMatched then -- 1118
							SetNextWindowBgAlpha(0) -- 1119
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1120
							Begin("Entries Not Found", displayWindowFlags, function() -- 1121
								Separator() -- 1122
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1123
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1124
								return Separator() -- 1125
							end) -- 1121
						end -- 1118
						Columns(1, false) -- 1126
						Dummy(Vec2(100, 80)) -- 1127
						return ScrollWhenDraggingOnVoid() -- 1128
					end) -- 999
				end) -- 998
			end) -- 997
		end) -- 996
	end -- 1128
end) -- 899
webStatus = require("Script.Dev.WebServer") -- 1130
return _module_0 -- 1130
