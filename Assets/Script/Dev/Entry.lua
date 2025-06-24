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
local setmetatable = _G.setmetatable -- 1
local GitPullOrCloneAsync = Dora.GitPullOrCloneAsync -- 1
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
local GetColumnWidth = _module_0.GetColumnWidth -- 1
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
local waStatus = { -- 562
	buildResult = nil, -- 562
	building = false, -- 563
	formatResult = nil, -- 564
	formating = false, -- 565
	pullCloneResult = nil, -- 566
	pullCloneProgress = "", -- 567
	pullCloning = false -- 568
} -- 561
local buildWaAsync -- 570
buildWaAsync = function(projDir) -- 570
	if waStatus.building then -- 571
		return "already building Wa project" -- 571
	end -- 571
	waStatus.building = true -- 572
	local _ <close> = setmetatable({ }, { -- 573
		__close = function() -- 573
			waStatus.building = false -- 574
			waStatus.buildResult = nil -- 575
		end -- 573
	}) -- 573
	local success = Wasm:buildWaAsync(projDir) -- 576
	if success then -- 576
		wait(function() -- 577
			return (waStatus.buildResult ~= nil) -- 577
		end) -- 577
		return waStatus.buildResult -- 578
	else -- 580
		return "failed to build Wa project \"" .. tostring(projDir) .. "\"" -- 580
	end -- 576
end -- 570
_module_0["buildWaAsync"] = buildWaAsync -- 580
local formatWaAsync -- 582
formatWaAsync = function(file) -- 582
	if waStatus.formating then -- 583
		return "" -- 583
	end -- 583
	waStatus.formating = true -- 584
	local _ <close> = setmetatable({ }, { -- 585
		__close = function() -- 585
			waStatus.formating = false -- 586
			waStatus.formatResult = nil -- 587
		end -- 585
	}) -- 585
	local success = Wasm:formatWaAsync(file) -- 588
	if success then -- 588
		wait(function() -- 589
			return (waStatus.formatResult ~= nil) -- 589
		end) -- 589
		return waStatus.formatResult -- 590
	else -- 592
		return "" -- 592
	end -- 588
end -- 582
_module_0["formatWaAsync"] = formatWaAsync -- 592
local gitPullOrCloneAsync -- 594
gitPullOrCloneAsync = function(url, file, depth) -- 594
	if depth == nil then -- 594
		depth = 0 -- 594
	end -- 594
	if waStatus.pullCloning then -- 595
		return "already pulling or cloning repo" -- 595
	end -- 595
	waStatus.pullCloning = true -- 596
	local _ <close> = setmetatable({ }, { -- 597
		__close = function() -- 597
			waStatus.pullCloning = false -- 598
			waStatus.pullCloneResult = nil -- 599
			waStatus.pullCloneProgress = "" -- 600
		end -- 597
	}) -- 597
	local success = GitPullOrCloneAsync(url, file, depth) -- 601
	if success then -- 601
		wait(function() -- 602
			return (waStatus.pullCloneResult ~= nil) -- 602
		end) -- 602
		return waStatus.pullCloneResult -- 603
	else -- 605
		return "failed to pull or clone repo \"" .. tostring(url) .. "\"" -- 605
	end -- 601
end -- 594
_module_0["gitPullOrCloneAsync"] = gitPullOrCloneAsync -- 605
local _anon_func_1 = function(App, _with_0) -- 620
	local _val_0 = App.platform -- 620
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 620
end -- 620
setupEventHandlers = function() -- 607
	local _with_0 = Director.postNode -- 608
	_with_0:onAppEvent(function(eventType) -- 609
		if eventType == "Quit" then -- 609
			allClear() -- 610
			return clearTempFiles() -- 611
		end -- 609
	end) -- 609
	_with_0:onAppChange(function(settingName) -- 612
		if "Theme" == settingName then -- 613
			config.themeColor = App.themeColor:toARGB() -- 614
		elseif "Locale" == settingName then -- 615
			config.locale = App.locale -- 616
			updateLocale() -- 617
			return teal.clear(true) -- 618
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 619
			if _anon_func_1(App, _with_0) then -- 620
				if "FullScreen" == settingName then -- 622
					config.fullScreen = App.fullScreen -- 622
				elseif "Position" == settingName then -- 623
					local _obj_0 = App.winPosition -- 623
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 623
				elseif "Size" == settingName then -- 624
					local width, height -- 625
					do -- 625
						local _obj_0 = App.winSize -- 625
						width, height = _obj_0.width, _obj_0.height -- 625
					end -- 625
					config.winWidth = width -- 626
					config.winHeight = height -- 627
				end -- 627
			end -- 620
		end -- 627
	end) -- 612
	_with_0:onAppWS(function(eventType) -- 628
		if eventType == "Close" then -- 628
			if HttpServer.wsConnectionCount == 0 then -- 629
				return updateEntries() -- 630
			end -- 629
		end -- 628
	end) -- 628
	_with_0:slot("UpdateEntries", function() -- 631
		return updateEntries() -- 631
	end) -- 631
	_with_0:gslot("WaLang", function(event, result) -- 632
		if "Format" == event then -- 633
			waStatus.formatResult = result -- 634
		elseif "Build" == event then -- 635
			waStatus.buildResult = result -- 636
		elseif "GitProgress" == event then -- 637
			waStatus.pullCloneProgress = waStatus.pullCloneProgress .. result -- 638
		elseif "GitPullOrClone" == event then -- 639
			waStatus.pullCloneResult = result -- 640
		end -- 640
	end) -- 632
	return _with_0 -- 608
end -- 607
setupEventHandlers() -- 642
clearTempFiles() -- 643
local stop -- 645
stop = function() -- 645
	if isInEntry then -- 646
		return false -- 646
	end -- 646
	allClear() -- 647
	isInEntry = true -- 648
	currentEntry = nil -- 649
	return true -- 650
end -- 645
_module_0["stop"] = stop -- 650
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 667
	if workDir == nil then -- 660
		workDir = Path:getPath(file) -- 660
	end -- 660
	Content:insertSearchPath(1, workDir) -- 661
	local scriptPath = Path(workDir, "Script") -- 662
	if Content:exist(scriptPath) then -- 663
		Content:insertSearchPath(1, scriptPath) -- 664
	end -- 663
	local result = require(file) -- 665
	if "function" == type(result) then -- 666
		result() -- 666
	end -- 666
	return nil -- 667
end -- 660
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 699
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 696
	label.alignment = "Left" -- 697
	label.textWidth = width - fontSize -- 698
	label.text = err -- 699
	return label -- 696
end -- 696
local enterEntryAsync -- 652
enterEntryAsync = function(entry) -- 652
	isInEntry = false -- 653
	App.idled = false -- 654
	emit(Profiler.EventName, "ClearLoader") -- 655
	currentEntry = entry -- 656
	local file, workDir = entry[2], entry.workDir -- 657
	sleep() -- 658
	return xpcall(_anon_func_2, function(msg) -- 700
		local err = debug.traceback(msg) -- 669
		Log("Error", err) -- 670
		allClear() -- 671
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 672
		local viewWidth, viewHeight -- 673
		do -- 673
			local _obj_0 = View.size -- 673
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 673
		end -- 673
		local width, height = viewWidth - 20, viewHeight - 20 -- 674
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 675
		Director.ui:addChild((function() -- 676
			local root = AlignNode() -- 676
			do -- 677
				local _obj_0 = App.bufferSize -- 677
				width, height = _obj_0.width, _obj_0.height -- 677
			end -- 677
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 678
			root:onAppChange(function(settingName) -- 679
				if settingName == "Size" then -- 679
					do -- 680
						local _obj_0 = App.bufferSize -- 680
						width, height = _obj_0.width, _obj_0.height -- 680
					end -- 680
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 681
				end -- 679
			end) -- 679
			root:addChild((function() -- 682
				local _with_0 = ScrollArea({ -- 683
					width = width, -- 683
					height = height, -- 684
					paddingX = 0, -- 685
					paddingY = 50, -- 686
					viewWidth = height, -- 687
					viewHeight = height -- 688
				}) -- 682
				root:onAlignLayout(function(w, h) -- 690
					_with_0.position = Vec2(w / 2, h / 2) -- 691
					w = w - 20 -- 692
					h = h - 20 -- 693
					_with_0.view.children.first.textWidth = w - fontSize -- 694
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 695
				end) -- 690
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 696
				return _with_0 -- 682
			end)()) -- 682
			return root -- 676
		end)()) -- 676
		return err -- 700
	end, Content, Path, file, require, type, workDir) -- 700
end -- 652
_module_0["enterEntryAsync"] = enterEntryAsync -- 700
local enterDemoEntry -- 702
enterDemoEntry = function(entry) -- 702
	return thread(function() -- 702
		return enterEntryAsync(entry) -- 702
	end) -- 702
end -- 702
local reloadCurrentEntry -- 704
reloadCurrentEntry = function() -- 704
	if currentEntry then -- 705
		allClear() -- 706
		return enterDemoEntry(currentEntry) -- 707
	end -- 705
end -- 704
Director.clearColor = Color(0xff1a1a1a) -- 709
local isOSSLicenseExist = Content:exist("LICENSES") -- 711
local ossLicenses = nil -- 712
local ossLicenseOpen = false -- 713
local extraOperations -- 715
extraOperations = function() -- 715
	local zh = useChinese and isChineseSupported -- 716
	if isDesktop then -- 717
		local themeColor = App.themeColor -- 718
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 719
		do -- 720
			local changed -- 720
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 720
			if changed then -- 720
				App.alwaysOnTop = alwaysOnTop -- 721
				config.alwaysOnTop = alwaysOnTop -- 722
			end -- 720
		end -- 720
		SeparatorText(zh and "工作目录" or "Workspace") -- 723
		PushTextWrapPos(400, function() -- 724
			return TextColored(themeColor, writablePath) -- 725
		end) -- 724
		if Button(zh and "改变目录" or "Set Folder") then -- 726
			App:openFileDialog(true, function(path) -- 727
				if path ~= "" then -- 728
					return setWorkspace(path) -- 728
				end -- 728
			end) -- 727
		end -- 726
		SameLine() -- 729
		if Button(zh and "使用默认" or "Use Default") then -- 730
			setWorkspace(Content.appPath) -- 731
		end -- 730
		Separator() -- 732
	end -- 717
	if isOSSLicenseExist then -- 733
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 734
			if not ossLicenses then -- 735
				ossLicenses = { } -- 736
				local licenseText = Content:load("LICENSES") -- 737
				ossLicenseOpen = (licenseText ~= nil) -- 738
				if ossLicenseOpen then -- 738
					licenseText = licenseText:gsub("\r\n", "\n") -- 739
					for license in GSplit(licenseText, "\n--------\n", true) do -- 740
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 741
						if name then -- 741
							ossLicenses[#ossLicenses + 1] = { -- 742
								name, -- 742
								text -- 742
							} -- 742
						end -- 741
					end -- 742
				end -- 738
			else -- 744
				ossLicenseOpen = true -- 744
			end -- 735
		end -- 734
		if ossLicenseOpen then -- 745
			local width, height, themeColor -- 746
			do -- 746
				local _obj_0 = App -- 746
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 746
			end -- 746
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 747
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 748
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 749
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 752
					"NoSavedSettings" -- 752
				}, function() -- 753
					for _index_0 = 1, #ossLicenses do -- 753
						local _des_0 = ossLicenses[_index_0] -- 753
						local firstLine, text = _des_0[1], _des_0[2] -- 753
						local name, license = firstLine:match("(.+): (.+)") -- 754
						TextColored(themeColor, name) -- 755
						SameLine() -- 756
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 757
							return TextWrapped(text) -- 757
						end) -- 757
					end -- 757
				end) -- 749
			end) -- 749
		end -- 745
	end -- 733
	if not App.debugging then -- 759
		return -- 759
	end -- 759
	return TreeNode(zh and "开发操作" or "Development", function() -- 760
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 761
			OpenPopup("build") -- 761
		end -- 761
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 762
			return BeginPopup("build", function() -- 762
				if Selectable(zh and "编译" or "Compile") then -- 763
					doCompile(false) -- 763
				end -- 763
				Separator() -- 764
				if Selectable(zh and "压缩" or "Minify") then -- 765
					doCompile(true) -- 765
				end -- 765
				Separator() -- 766
				if Selectable(zh and "清理" or "Clean") then -- 767
					return doClean() -- 767
				end -- 767
			end) -- 767
		end) -- 762
		if isInEntry then -- 768
			if waitForWebStart then -- 769
				BeginDisabled(function() -- 770
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 770
				end) -- 770
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 771
				reloadDevEntry() -- 772
			end -- 769
		end -- 768
		do -- 773
			local changed -- 773
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 773
			if changed then -- 773
				View.scale = scaleContent and screenScale or 1 -- 774
			end -- 773
		end -- 773
		do -- 775
			local changed -- 775
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 775
			if changed then -- 775
				config.engineDev = engineDev -- 776
			end -- 775
		end -- 775
		if testingThread then -- 777
			return BeginDisabled(function() -- 778
				return Button(zh and "开始自动测试" or "Test automatically") -- 778
			end) -- 778
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 779
			testingThread = thread(function() -- 780
				local _ <close> = setmetatable({ }, { -- 781
					__close = function() -- 781
						allClear() -- 782
						testingThread = nil -- 783
						isInEntry = true -- 784
						currentEntry = nil -- 785
						return print("Testing done!") -- 786
					end -- 781
				}) -- 781
				for _, entry in ipairs(allEntries) do -- 787
					allClear() -- 788
					print("Start " .. tostring(entry[1])) -- 789
					enterDemoEntry(entry) -- 790
					sleep(2) -- 791
					print("Stop " .. tostring(entry[1])) -- 792
				end -- 792
			end) -- 780
		end -- 777
	end) -- 760
end -- 715
local transparant = Color(0x0) -- 794
local windowFlags = { -- 795
	"NoTitleBar", -- 795
	"NoResize", -- 795
	"NoMove", -- 795
	"NoCollapse", -- 795
	"NoSavedSettings", -- 795
	"NoBringToFrontOnFocus" -- 795
} -- 795
local initFooter = true -- 803
local _anon_func_4 = function(allEntries, currentIndex) -- 839
	if currentIndex > 1 then -- 839
		return allEntries[currentIndex - 1] -- 840
	else -- 842
		return allEntries[#allEntries] -- 842
	end -- 839
end -- 839
local _anon_func_5 = function(allEntries, currentIndex) -- 846
	if currentIndex < #allEntries then -- 846
		return allEntries[currentIndex + 1] -- 847
	else -- 849
		return allEntries[1] -- 849
	end -- 846
end -- 846
footerWindow = threadLoop(function() -- 804
	local zh = useChinese and isChineseSupported -- 805
	if HttpServer.wsConnectionCount > 0 then -- 806
		return -- 807
	end -- 806
	if Keyboard:isKeyDown("Escape") then -- 808
		allClear() -- 809
		App:shutdown() -- 810
	end -- 808
	do -- 811
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 812
		if ctrl and Keyboard:isKeyDown("Q") then -- 813
			stop() -- 814
		end -- 813
		if ctrl and Keyboard:isKeyDown("Z") then -- 815
			reloadCurrentEntry() -- 816
		end -- 815
		if ctrl and Keyboard:isKeyDown(",") then -- 817
			if showFooter then -- 818
				showStats = not showStats -- 818
			else -- 818
				showStats = true -- 818
			end -- 818
			showFooter = true -- 819
			config.showFooter = showFooter -- 820
			config.showStats = showStats -- 821
		end -- 817
		if ctrl and Keyboard:isKeyDown(".") then -- 822
			if showFooter then -- 823
				showConsole = not showConsole -- 823
			else -- 823
				showConsole = true -- 823
			end -- 823
			showFooter = true -- 824
			config.showFooter = showFooter -- 825
			config.showConsole = showConsole -- 826
		end -- 822
		if ctrl and Keyboard:isKeyDown("/") then -- 827
			showFooter = not showFooter -- 828
			config.showFooter = showFooter -- 829
		end -- 827
		local left = ctrl and Keyboard:isKeyDown("Left") -- 830
		local right = ctrl and Keyboard:isKeyDown("Right") -- 831
		local currentIndex = nil -- 832
		for i, entry in ipairs(allEntries) do -- 833
			if currentEntry == entry then -- 834
				currentIndex = i -- 835
			end -- 834
		end -- 835
		if left then -- 836
			allClear() -- 837
			if currentIndex == nil then -- 838
				currentIndex = #allEntries + 1 -- 838
			end -- 838
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 839
		end -- 836
		if right then -- 843
			allClear() -- 844
			if currentIndex == nil then -- 845
				currentIndex = 0 -- 845
			end -- 845
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 846
		end -- 843
	end -- 849
	if not showEntry then -- 850
		return -- 850
	end -- 850
	local width, height -- 852
	do -- 852
		local _obj_0 = App.visualSize -- 852
		width, height = _obj_0.width, _obj_0.height -- 852
	end -- 852
	SetNextWindowSize(Vec2(50, 50)) -- 853
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 854
	PushStyleColor("WindowBg", transparant, function() -- 855
		return Begin("Show", windowFlags, function() -- 855
			if isInEntry or width >= 540 then -- 856
				local changed -- 857
				changed, showFooter = Checkbox("##dev", showFooter) -- 857
				if changed then -- 857
					config.showFooter = showFooter -- 858
				end -- 857
			end -- 856
		end) -- 858
	end) -- 855
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 860
		reloadDevEntry() -- 864
	end -- 860
	if initFooter then -- 865
		initFooter = false -- 866
	else -- 868
		if not showFooter then -- 868
			return -- 868
		end -- 868
	end -- 865
	SetNextWindowSize(Vec2(width, 50)) -- 870
	SetNextWindowPos(Vec2(0, height - 50)) -- 871
	SetNextWindowBgAlpha(0.35) -- 872
	do -- 873
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 874
			return Begin("Footer", windowFlags, function() -- 875
				Dummy(Vec2(width - 20, 0)) -- 876
				do -- 877
					local changed -- 877
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 877
					if changed then -- 877
						config.showStats = showStats -- 878
					end -- 877
				end -- 877
				SameLine() -- 879
				do -- 880
					local changed -- 880
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 880
					if changed then -- 880
						config.showConsole = showConsole -- 881
					end -- 880
				end -- 880
				if config.updateNotification then -- 882
					SameLine() -- 883
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 884
						allClear() -- 885
						config.updateNotification = false -- 886
						enterDemoEntry({ -- 888
							"SelfUpdater", -- 888
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 889
						}) -- 887
					end -- 884
				end -- 882
				if not isInEntry then -- 891
					SameLine() -- 892
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 893
					local currentIndex = nil -- 894
					for i, entry in ipairs(allEntries) do -- 895
						if currentEntry == entry then -- 896
							currentIndex = i -- 897
						end -- 896
					end -- 897
					if currentIndex then -- 898
						if currentIndex > 1 then -- 899
							SameLine() -- 900
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 901
								allClear() -- 902
								enterDemoEntry(allEntries[currentIndex - 1]) -- 903
							end -- 901
						end -- 899
						if currentIndex < #allEntries then -- 904
							SameLine() -- 905
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 906
								allClear() -- 907
								enterDemoEntry(allEntries[currentIndex + 1]) -- 908
							end -- 906
						end -- 904
					end -- 898
					SameLine() -- 909
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 910
						reloadCurrentEntry() -- 911
					end -- 910
					if back then -- 912
						allClear() -- 913
						isInEntry = true -- 914
						currentEntry = nil -- 915
					end -- 912
				end -- 891
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 916
					if showStats then -- 917
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 918
						showStats = ShowStats(showStats, extraOperations) -- 919
						config.showStats = showStats -- 920
					end -- 917
					if showConsole then -- 921
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 922
						showConsole = ShowConsole(showConsole) -- 923
						config.showConsole = showConsole -- 924
					end -- 921
				end) -- 916
			end) -- 875
		end) -- 874
	end -- 924
end) -- 804
local MaxWidth <const> = 960 -- 926
local displayWindowFlags = { -- 928
	"NoDecoration", -- 928
	"NoSavedSettings", -- 928
	"NoFocusOnAppearing", -- 928
	"NoNav", -- 928
	"NoMove", -- 928
	"NoScrollWithMouse", -- 928
	"AlwaysAutoResize", -- 928
	"NoBringToFrontOnFocus" -- 928
} -- 928
local webStatus = nil -- 939
local descColor = Color(0xffa1a1a1) -- 940
local toolOpen = false -- 941
local filterText = nil -- 942
local anyEntryMatched = false -- 943
local urlClicked = nil -- 944
local match -- 945
match = function(name) -- 945
	local res = not filterText or name:lower():match(filterText) -- 946
	if res then -- 947
		anyEntryMatched = true -- 947
	end -- 947
	return res -- 948
end -- 945
local icon = Path("Script", "Dev", "icon_s.png") -- 949
local iconTex = nil -- 950
thread(function() -- 951
	if Cache:loadAsync(icon) then -- 951
		iconTex = Texture2D(icon) -- 951
	end -- 951
end) -- 951
local sep -- 953
sep = function() -- 953
	return SeparatorText("") -- 953
end -- 953
local thinSep -- 954
thinSep = function() -- 954
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 954
end -- 954
entryWindow = threadLoop(function() -- 956
	if App.fpsLimited ~= config.fpsLimited then -- 957
		config.fpsLimited = App.fpsLimited -- 958
	end -- 957
	if App.targetFPS ~= config.targetFPS then -- 959
		config.targetFPS = App.targetFPS -- 960
	end -- 959
	if View.vsync ~= config.vsync then -- 961
		config.vsync = View.vsync -- 962
	end -- 961
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 963
		config.fixedFPS = Director.scheduler.fixedFPS -- 964
	end -- 963
	if Director.profilerSending ~= config.webProfiler then -- 965
		config.webProfiler = Director.profilerSending -- 966
	end -- 965
	if urlClicked then -- 967
		local _, result = coroutine.resume(urlClicked) -- 968
		if result then -- 969
			coroutine.close(urlClicked) -- 970
			urlClicked = nil -- 971
		end -- 969
	end -- 967
	if not showEntry then -- 972
		return -- 972
	end -- 972
	if not isInEntry then -- 973
		return -- 973
	end -- 973
	local zh = useChinese and isChineseSupported -- 974
	if HttpServer.wsConnectionCount > 0 then -- 975
		local themeColor = App.themeColor -- 976
		local width, height -- 977
		do -- 977
			local _obj_0 = App.visualSize -- 977
			width, height = _obj_0.width, _obj_0.height -- 977
		end -- 977
		SetNextWindowBgAlpha(0.5) -- 978
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 979
		Begin("Web IDE Connected", displayWindowFlags, function() -- 980
			Separator() -- 981
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 982
			if iconTex then -- 983
				Image(icon, Vec2(24, 24)) -- 984
				SameLine() -- 985
			end -- 983
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 986
			TextColored(descColor, slogon) -- 987
			return Separator() -- 988
		end) -- 980
		return -- 989
	end -- 975
	local themeColor = App.themeColor -- 991
	local fullWidth, height -- 992
	do -- 992
		local _obj_0 = App.visualSize -- 992
		fullWidth, height = _obj_0.width, _obj_0.height -- 992
	end -- 992
	SetNextWindowBgAlpha(0.85) -- 994
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 995
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 996
		return Begin("Web IDE", displayWindowFlags, function() -- 997
			Separator() -- 998
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 999
			SameLine() -- 1000
			TextDisabled('(?)') -- 1001
			if IsItemHovered() then -- 1002
				BeginTooltip(function() -- 1003
					return PushTextWrapPos(280, function() -- 1004
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 1005
					end) -- 1005
				end) -- 1003
			end -- 1002
			do -- 1006
				local url -- 1006
				if webStatus ~= nil then -- 1006
					url = webStatus.url -- 1006
				end -- 1006
				if url then -- 1006
					if isDesktop and not config.fullScreen then -- 1007
						if urlClicked then -- 1008
							BeginDisabled(function() -- 1009
								return Button(url) -- 1009
							end) -- 1009
						elseif Button(url) then -- 1010
							urlClicked = once(function() -- 1011
								return sleep(5) -- 1011
							end) -- 1011
							App:openURL("http://localhost:8866") -- 1012
						end -- 1008
					else -- 1014
						TextColored(descColor, url) -- 1014
					end -- 1007
				else -- 1016
					TextColored(descColor, zh and '不可用' or 'not available') -- 1016
				end -- 1006
			end -- 1006
			return Separator() -- 1017
		end) -- 1017
	end) -- 996
	local width = math.min(MaxWidth, fullWidth) -- 1019
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1020
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1021
	SetNextWindowPos(Vec2.zero) -- 1022
	SetNextWindowBgAlpha(0) -- 1023
	do -- 1024
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1025
			return Begin("Dora Dev", displayWindowFlags, function() -- 1026
				Dummy(Vec2(fullWidth - 20, 0)) -- 1027
				if iconTex then -- 1028
					Image(icon, Vec2(24, 24)) -- 1029
					SameLine() -- 1030
				end -- 1028
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 1031
				if fullWidth >= 400 then -- 1032
					SameLine() -- 1033
					Dummy(Vec2(fullWidth - 400, 0)) -- 1034
					SameLine() -- 1035
					SetNextItemWidth(zh and -90 or -140) -- 1036
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1037
						"AutoSelectAll" -- 1037
					}) then -- 1037
						config.filter = filterBuf.text -- 1038
					end -- 1037
					SameLine() -- 1039
					if Button(zh and '下载' or 'Download') then -- 1040
						allClear() -- 1041
						enterDemoEntry({ -- 1043
							"ResourceDownloader", -- 1043
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1044
						}) -- 1042
					end -- 1040
				end -- 1032
				Separator() -- 1046
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1047
			end) -- 1026
		end) -- 1025
	end -- 1047
	anyEntryMatched = false -- 1049
	SetNextWindowPos(Vec2(0, 50)) -- 1050
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1051
	do -- 1052
		return PushStyleColor("WindowBg", transparant, function() -- 1053
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1054
				return PushStyleVar("Alpha", 1, function() -- 1055
					return Begin("Content", windowFlags, function() -- 1056
						local DemoViewWidth <const> = 320 -- 1057
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1058
						if filterText then -- 1059
							filterText = filterText:lower() -- 1059
						end -- 1059
						if #gamesInDev > 0 then -- 1060
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1061
							Columns(columns, false) -- 1062
							local realViewWidth = GetColumnWidth() - 50 -- 1063
							for _index_0 = 1, #gamesInDev do -- 1064
								local game = gamesInDev[_index_0] -- 1064
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1065
								if match(gameName) then -- 1066
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1067
									SameLine() -- 1068
									TextWrapped(gameName) -- 1069
									if columns > 1 then -- 1070
										if bannerFile then -- 1071
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1072
											local displayWidth <const> = realViewWidth -- 1073
											texHeight = displayWidth * texHeight / texWidth -- 1074
											texWidth = displayWidth -- 1075
											Dummy(Vec2.zero) -- 1076
											SameLine() -- 1077
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1078
										end -- 1071
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1079
											enterDemoEntry(game) -- 1080
										end -- 1079
									else -- 1082
										if bannerFile then -- 1082
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1083
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1084
											local sizing = 0.8 -- 1085
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1086
											texWidth = displayWidth * sizing -- 1087
											if texWidth > 500 then -- 1088
												sizing = 0.6 -- 1089
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1090
												texWidth = displayWidth * sizing -- 1091
											end -- 1088
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1092
											Dummy(Vec2(padding, 0)) -- 1093
											SameLine() -- 1094
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1095
										end -- 1082
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1096
											enterDemoEntry(game) -- 1097
										end -- 1096
									end -- 1070
									if #tests == 0 and #examples == 0 then -- 1098
										thinSep() -- 1099
									end -- 1098
									NextColumn() -- 1100
								end -- 1066
								local showSep = false -- 1101
								if #examples > 0 then -- 1102
									local showExample = false -- 1103
									do -- 1104
										local _accum_0 -- 1104
										for _index_1 = 1, #examples do -- 1104
											local _des_0 = examples[_index_1] -- 1104
											local name = _des_0[1] -- 1104
											if match(name) then -- 1105
												_accum_0 = true -- 1105
												break -- 1105
											end -- 1105
										end -- 1105
										showExample = _accum_0 -- 1104
									end -- 1105
									if showExample then -- 1106
										showSep = true -- 1107
										Columns(1, false) -- 1108
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1109
										SameLine() -- 1110
										local opened -- 1111
										if (filterText ~= nil) then -- 1111
											opened = showExample -- 1111
										else -- 1111
											opened = false -- 1111
										end -- 1111
										if game.exampleOpen == nil then -- 1112
											game.exampleOpen = opened -- 1112
										end -- 1112
										SetNextItemOpen(game.exampleOpen) -- 1113
										TreeNode(tostring(gameName) .. "###example-" .. tostring(fileName), function() -- 1114
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1115
												Columns(maxColumns, false) -- 1116
												for _index_1 = 1, #examples do -- 1117
													local example = examples[_index_1] -- 1117
													if not match(example[1]) then -- 1118
														goto _continue_0 -- 1118
													end -- 1118
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1119
														if Button(example[1], Vec2(-1, 40)) then -- 1120
															enterDemoEntry(example) -- 1121
														end -- 1120
														return NextColumn() -- 1122
													end) -- 1119
													opened = true -- 1123
													::_continue_0:: -- 1118
												end -- 1123
											end) -- 1115
										end) -- 1114
										game.exampleOpen = opened -- 1124
									end -- 1106
								end -- 1102
								if #tests > 0 then -- 1125
									local showTest = false -- 1126
									do -- 1127
										local _accum_0 -- 1127
										for _index_1 = 1, #tests do -- 1127
											local _des_0 = tests[_index_1] -- 1127
											local name = _des_0[1] -- 1127
											if match(name) then -- 1128
												_accum_0 = true -- 1128
												break -- 1128
											end -- 1128
										end -- 1128
										showTest = _accum_0 -- 1127
									end -- 1128
									if showTest then -- 1129
										showSep = true -- 1130
										Columns(1, false) -- 1131
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1132
										SameLine() -- 1133
										local opened -- 1134
										if (filterText ~= nil) then -- 1134
											opened = showTest -- 1134
										else -- 1134
											opened = false -- 1134
										end -- 1134
										if game.testOpen == nil then -- 1135
											game.testOpen = opened -- 1135
										end -- 1135
										SetNextItemOpen(game.testOpen) -- 1136
										TreeNode(tostring(gameName) .. "###test-" .. tostring(fileName), function() -- 1137
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1138
												Columns(maxColumns, false) -- 1139
												for _index_1 = 1, #tests do -- 1140
													local test = tests[_index_1] -- 1140
													if not match(test[1]) then -- 1141
														goto _continue_0 -- 1141
													end -- 1141
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1142
														if Button(test[1], Vec2(-1, 40)) then -- 1143
															enterDemoEntry(test) -- 1144
														end -- 1143
														return NextColumn() -- 1145
													end) -- 1142
													opened = true -- 1146
													::_continue_0:: -- 1141
												end -- 1146
											end) -- 1138
										end) -- 1137
										game.testOpen = opened -- 1147
									end -- 1129
								end -- 1125
								if showSep then -- 1148
									Columns(1, false) -- 1149
									thinSep() -- 1150
									Columns(columns, false) -- 1151
								end -- 1148
							end -- 1151
						end -- 1060
						if #doraTools > 0 then -- 1152
							local showTool = false -- 1153
							do -- 1154
								local _accum_0 -- 1154
								for _index_0 = 1, #doraTools do -- 1154
									local _des_0 = doraTools[_index_0] -- 1154
									local name = _des_0[1] -- 1154
									if match(name) then -- 1155
										_accum_0 = true -- 1155
										break -- 1155
									end -- 1155
								end -- 1155
								showTool = _accum_0 -- 1154
							end -- 1155
							if not showTool then -- 1156
								goto endEntry -- 1156
							end -- 1156
							Columns(1, false) -- 1157
							TextColored(themeColor, "Dora SSR:") -- 1158
							SameLine() -- 1159
							Text(zh and "开发支持" or "Development Support") -- 1160
							Separator() -- 1161
							if #doraTools > 0 then -- 1162
								local opened -- 1163
								if (filterText ~= nil) then -- 1163
									opened = showTool -- 1163
								else -- 1163
									opened = false -- 1163
								end -- 1163
								SetNextItemOpen(toolOpen) -- 1164
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1165
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1166
										Columns(maxColumns, false) -- 1167
										for _index_0 = 1, #doraTools do -- 1168
											local example = doraTools[_index_0] -- 1168
											if not match(example[1]) then -- 1169
												goto _continue_0 -- 1169
											end -- 1169
											if Button(example[1], Vec2(-1, 40)) then -- 1170
												enterDemoEntry(example) -- 1171
											end -- 1170
											NextColumn() -- 1172
											::_continue_0:: -- 1169
										end -- 1172
										Columns(1, false) -- 1173
										opened = true -- 1174
									end) -- 1166
								end) -- 1165
								toolOpen = opened -- 1175
							end -- 1162
						end -- 1152
						::endEntry:: -- 1176
						if not anyEntryMatched then -- 1177
							SetNextWindowBgAlpha(0) -- 1178
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1179
							Begin("Entries Not Found", displayWindowFlags, function() -- 1180
								Separator() -- 1181
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1182
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1183
								return Separator() -- 1184
							end) -- 1180
						end -- 1177
						Columns(1, false) -- 1185
						Dummy(Vec2(100, 80)) -- 1186
						return ScrollWhenDraggingOnVoid() -- 1187
					end) -- 1056
				end) -- 1055
			end) -- 1054
		end) -- 1053
	end -- 1187
end) -- 956
webStatus = require("Script.Dev.WebServer") -- 1189
return _module_0 -- 1189
