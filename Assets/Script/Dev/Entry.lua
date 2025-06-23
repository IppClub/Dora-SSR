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
	if success then -- 577
		wait(function() -- 578
			return (waStatus.buildResult ~= nil) -- 578
		end) -- 578
		return waStatus.buildResult -- 579
	else -- 581
		return "failed to build Wa project \"" .. tostring(projDir) .. "\"" -- 581
	end -- 577
end -- 570
_module_0["buildWaAsync"] = buildWaAsync -- 581
local formatWaAsync -- 583
formatWaAsync = function(file) -- 583
	if waStatus.formating then -- 584
		return "" -- 584
	end -- 584
	waStatus.formating = true -- 585
	local _ <close> = setmetatable({ }, { -- 586
		__close = function() -- 586
			waStatus.formating = false -- 587
			waStatus.formatResult = nil -- 588
		end -- 586
	}) -- 586
	local success = Wasm:formatWaAsync(file) -- 589
	if success then -- 590
		wait(function() -- 591
			return (waStatus.formatResult ~= nil) -- 591
		end) -- 591
		return waStatus.formatResult -- 592
	else -- 594
		return "" -- 594
	end -- 590
end -- 583
_module_0["formatWaAsync"] = formatWaAsync -- 594
local gitPullOrCloneAsync -- 596
gitPullOrCloneAsync = function(url, file, depth) -- 596
	if depth == nil then -- 596
		depth = 0 -- 596
	end -- 596
	if waStatus.pullCloning then -- 597
		return "already pulling or cloning repo" -- 597
	end -- 597
	waStatus.pullCloning = true -- 598
	local _ <close> = setmetatable({ }, { -- 599
		__close = function() -- 599
			waStatus.pullCloning = false -- 600
			waStatus.pullCloneResult = nil -- 601
			waStatus.pullCloneProgress = "" -- 602
		end -- 599
	}) -- 599
	local success = GitPullOrCloneAsync(url, file, depth) -- 603
	if success then -- 604
		wait(function() -- 605
			return (waStatus.pullCloneResult ~= nil) -- 605
		end) -- 605
		return waStatus.pullCloneResult -- 606
	else -- 608
		return "failed to pull or clone repo \"" .. tostring(url) .. "\"" -- 608
	end -- 604
end -- 596
_module_0["gitPullOrCloneAsync"] = gitPullOrCloneAsync -- 608
local _anon_func_1 = function(App, _with_0) -- 623
	local _val_0 = App.platform -- 623
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 623
end -- 623
setupEventHandlers = function() -- 610
	local _with_0 = Director.postNode -- 611
	_with_0:onAppEvent(function(eventType) -- 612
		if eventType == "Quit" then -- 612
			allClear() -- 613
			return clearTempFiles() -- 614
		end -- 612
	end) -- 612
	_with_0:onAppChange(function(settingName) -- 615
		if "Theme" == settingName then -- 616
			config.themeColor = App.themeColor:toARGB() -- 617
		elseif "Locale" == settingName then -- 618
			config.locale = App.locale -- 619
			updateLocale() -- 620
			return teal.clear(true) -- 621
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 622
			if _anon_func_1(App, _with_0) then -- 623
				if "FullScreen" == settingName then -- 625
					config.fullScreen = App.fullScreen -- 625
				elseif "Position" == settingName then -- 626
					local _obj_0 = App.winPosition -- 626
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 626
				elseif "Size" == settingName then -- 627
					local width, height -- 628
					do -- 628
						local _obj_0 = App.winSize -- 628
						width, height = _obj_0.width, _obj_0.height -- 628
					end -- 628
					config.winWidth = width -- 629
					config.winHeight = height -- 630
				end -- 630
			end -- 623
		end -- 630
	end) -- 615
	_with_0:onAppWS(function(eventType) -- 631
		if eventType == "Close" then -- 631
			if HttpServer.wsConnectionCount == 0 then -- 632
				return updateEntries() -- 633
			end -- 632
		end -- 631
	end) -- 631
	_with_0:slot("UpdateEntries", function() -- 634
		return updateEntries() -- 634
	end) -- 634
	_with_0:gslot("WaLang", function(event, result) -- 635
		if "Format" == event then -- 636
			waStatus.formatResult = result -- 637
		elseif "Build" == event then -- 638
			waStatus.buildResult = result -- 639
		elseif "GitProgress" == event then -- 640
			waStatus.pullCloneProgress = waStatus.pullCloneProgress .. result -- 641
		elseif "GitPullOrClone" == event then -- 642
			waStatus.pullCloneResult = result -- 643
		end -- 643
	end) -- 635
	return _with_0 -- 611
end -- 610
setupEventHandlers() -- 645
clearTempFiles() -- 646
local stop -- 648
stop = function() -- 648
	if isInEntry then -- 649
		return false -- 649
	end -- 649
	allClear() -- 650
	isInEntry = true -- 651
	currentEntry = nil -- 652
	return true -- 653
end -- 648
_module_0["stop"] = stop -- 653
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 670
	if workDir == nil then -- 663
		workDir = Path:getPath(file) -- 663
	end -- 663
	Content:insertSearchPath(1, workDir) -- 664
	local scriptPath = Path(workDir, "Script") -- 665
	if Content:exist(scriptPath) then -- 666
		Content:insertSearchPath(1, scriptPath) -- 667
	end -- 666
	local result = require(file) -- 668
	if "function" == type(result) then -- 669
		result() -- 669
	end -- 669
	return nil -- 670
end -- 663
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 702
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 699
	label.alignment = "Left" -- 700
	label.textWidth = width - fontSize -- 701
	label.text = err -- 702
	return label -- 699
end -- 699
local enterEntryAsync -- 655
enterEntryAsync = function(entry) -- 655
	isInEntry = false -- 656
	App.idled = false -- 657
	emit(Profiler.EventName, "ClearLoader") -- 658
	currentEntry = entry -- 659
	local file, workDir = entry[2], entry.workDir -- 660
	sleep() -- 661
	return xpcall(_anon_func_2, function(msg) -- 703
		local err = debug.traceback(msg) -- 672
		Log("Error", err) -- 673
		allClear() -- 674
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 675
		local viewWidth, viewHeight -- 676
		do -- 676
			local _obj_0 = View.size -- 676
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 676
		end -- 676
		local width, height = viewWidth - 20, viewHeight - 20 -- 677
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 678
		Director.ui:addChild((function() -- 679
			local root = AlignNode() -- 679
			do -- 680
				local _obj_0 = App.bufferSize -- 680
				width, height = _obj_0.width, _obj_0.height -- 680
			end -- 680
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 681
			root:onAppChange(function(settingName) -- 682
				if settingName == "Size" then -- 682
					do -- 683
						local _obj_0 = App.bufferSize -- 683
						width, height = _obj_0.width, _obj_0.height -- 683
					end -- 683
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 684
				end -- 682
			end) -- 682
			root:addChild((function() -- 685
				local _with_0 = ScrollArea({ -- 686
					width = width, -- 686
					height = height, -- 687
					paddingX = 0, -- 688
					paddingY = 50, -- 689
					viewWidth = height, -- 690
					viewHeight = height -- 691
				}) -- 685
				root:onAlignLayout(function(w, h) -- 693
					_with_0.position = Vec2(w / 2, h / 2) -- 694
					w = w - 20 -- 695
					h = h - 20 -- 696
					_with_0.view.children.first.textWidth = w - fontSize -- 697
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 698
				end) -- 693
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 699
				return _with_0 -- 685
			end)()) -- 685
			return root -- 679
		end)()) -- 679
		return err -- 703
	end, Content, Path, file, require, type, workDir) -- 703
end -- 655
_module_0["enterEntryAsync"] = enterEntryAsync -- 703
local enterDemoEntry -- 705
enterDemoEntry = function(entry) -- 705
	return thread(function() -- 705
		return enterEntryAsync(entry) -- 705
	end) -- 705
end -- 705
local reloadCurrentEntry -- 707
reloadCurrentEntry = function() -- 707
	if currentEntry then -- 708
		allClear() -- 709
		return enterDemoEntry(currentEntry) -- 710
	end -- 708
end -- 707
Director.clearColor = Color(0xff1a1a1a) -- 712
local isOSSLicenseExist = Content:exist("LICENSES") -- 714
local ossLicenses = nil -- 715
local ossLicenseOpen = false -- 716
local extraOperations -- 718
extraOperations = function() -- 718
	local zh = useChinese and isChineseSupported -- 719
	if isDesktop then -- 720
		local themeColor = App.themeColor -- 721
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 722
		do -- 723
			local changed -- 723
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 723
			if changed then -- 723
				App.alwaysOnTop = alwaysOnTop -- 724
				config.alwaysOnTop = alwaysOnTop -- 725
			end -- 723
		end -- 723
		SeparatorText(zh and "工作目录" or "Workspace") -- 726
		PushTextWrapPos(400, function() -- 727
			return TextColored(themeColor, writablePath) -- 728
		end) -- 727
		if Button(zh and "改变目录" or "Set Folder") then -- 729
			App:openFileDialog(true, function(path) -- 730
				if path ~= "" then -- 731
					return setWorkspace(path) -- 731
				end -- 731
			end) -- 730
		end -- 729
		SameLine() -- 732
		if Button(zh and "使用默认" or "Use Default") then -- 733
			setWorkspace(Content.appPath) -- 734
		end -- 733
		Separator() -- 735
	end -- 720
	if isOSSLicenseExist then -- 736
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 737
			if not ossLicenses then -- 738
				ossLicenses = { } -- 739
				local licenseText = Content:load("LICENSES") -- 740
				ossLicenseOpen = (licenseText ~= nil) -- 741
				if ossLicenseOpen then -- 741
					licenseText = licenseText:gsub("\r\n", "\n") -- 742
					for license in GSplit(licenseText, "\n--------\n", true) do -- 743
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 744
						if name then -- 744
							ossLicenses[#ossLicenses + 1] = { -- 745
								name, -- 745
								text -- 745
							} -- 745
						end -- 744
					end -- 745
				end -- 741
			else -- 747
				ossLicenseOpen = true -- 747
			end -- 738
		end -- 737
		if ossLicenseOpen then -- 748
			local width, height, themeColor -- 749
			do -- 749
				local _obj_0 = App -- 749
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 749
			end -- 749
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 750
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 751
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 752
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 755
					"NoSavedSettings" -- 755
				}, function() -- 756
					for _index_0 = 1, #ossLicenses do -- 756
						local _des_0 = ossLicenses[_index_0] -- 756
						local firstLine, text = _des_0[1], _des_0[2] -- 756
						local name, license = firstLine:match("(.+): (.+)") -- 757
						TextColored(themeColor, name) -- 758
						SameLine() -- 759
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 760
							return TextWrapped(text) -- 760
						end) -- 760
					end -- 760
				end) -- 752
			end) -- 752
		end -- 748
	end -- 736
	if not App.debugging then -- 762
		return -- 762
	end -- 762
	return TreeNode(zh and "开发操作" or "Development", function() -- 763
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 764
			OpenPopup("build") -- 764
		end -- 764
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 765
			return BeginPopup("build", function() -- 765
				if Selectable(zh and "编译" or "Compile") then -- 766
					doCompile(false) -- 766
				end -- 766
				Separator() -- 767
				if Selectable(zh and "压缩" or "Minify") then -- 768
					doCompile(true) -- 768
				end -- 768
				Separator() -- 769
				if Selectable(zh and "清理" or "Clean") then -- 770
					return doClean() -- 770
				end -- 770
			end) -- 770
		end) -- 765
		if isInEntry then -- 771
			if waitForWebStart then -- 772
				BeginDisabled(function() -- 773
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 773
				end) -- 773
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 774
				reloadDevEntry() -- 775
			end -- 772
		end -- 771
		do -- 776
			local changed -- 776
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 776
			if changed then -- 776
				View.scale = scaleContent and screenScale or 1 -- 777
			end -- 776
		end -- 776
		do -- 778
			local changed -- 778
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 778
			if changed then -- 778
				config.engineDev = engineDev -- 779
			end -- 778
		end -- 778
		if testingThread then -- 780
			return BeginDisabled(function() -- 781
				return Button(zh and "开始自动测试" or "Test automatically") -- 781
			end) -- 781
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 782
			testingThread = thread(function() -- 783
				local _ <close> = setmetatable({ }, { -- 784
					__close = function() -- 784
						allClear() -- 785
						testingThread = nil -- 786
						isInEntry = true -- 787
						currentEntry = nil -- 788
						return print("Testing done!") -- 789
					end -- 784
				}) -- 784
				for _, entry in ipairs(allEntries) do -- 790
					allClear() -- 791
					print("Start " .. tostring(entry[1])) -- 792
					enterDemoEntry(entry) -- 793
					sleep(2) -- 794
					print("Stop " .. tostring(entry[1])) -- 795
				end -- 795
			end) -- 783
		end -- 780
	end) -- 763
end -- 718
local transparant = Color(0x0) -- 797
local windowFlags = { -- 798
	"NoTitleBar", -- 798
	"NoResize", -- 798
	"NoMove", -- 798
	"NoCollapse", -- 798
	"NoSavedSettings", -- 798
	"NoBringToFrontOnFocus" -- 798
} -- 798
local initFooter = true -- 806
local _anon_func_4 = function(allEntries, currentIndex) -- 842
	if currentIndex > 1 then -- 842
		return allEntries[currentIndex - 1] -- 843
	else -- 845
		return allEntries[#allEntries] -- 845
	end -- 842
end -- 842
local _anon_func_5 = function(allEntries, currentIndex) -- 849
	if currentIndex < #allEntries then -- 849
		return allEntries[currentIndex + 1] -- 850
	else -- 852
		return allEntries[1] -- 852
	end -- 849
end -- 849
footerWindow = threadLoop(function() -- 807
	local zh = useChinese and isChineseSupported -- 808
	if HttpServer.wsConnectionCount > 0 then -- 809
		return -- 810
	end -- 809
	if Keyboard:isKeyDown("Escape") then -- 811
		allClear() -- 812
		App:shutdown() -- 813
	end -- 811
	do -- 814
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 815
		if ctrl and Keyboard:isKeyDown("Q") then -- 816
			stop() -- 817
		end -- 816
		if ctrl and Keyboard:isKeyDown("Z") then -- 818
			reloadCurrentEntry() -- 819
		end -- 818
		if ctrl and Keyboard:isKeyDown(",") then -- 820
			if showFooter then -- 821
				showStats = not showStats -- 821
			else -- 821
				showStats = true -- 821
			end -- 821
			showFooter = true -- 822
			config.showFooter = showFooter -- 823
			config.showStats = showStats -- 824
		end -- 820
		if ctrl and Keyboard:isKeyDown(".") then -- 825
			if showFooter then -- 826
				showConsole = not showConsole -- 826
			else -- 826
				showConsole = true -- 826
			end -- 826
			showFooter = true -- 827
			config.showFooter = showFooter -- 828
			config.showConsole = showConsole -- 829
		end -- 825
		if ctrl and Keyboard:isKeyDown("/") then -- 830
			showFooter = not showFooter -- 831
			config.showFooter = showFooter -- 832
		end -- 830
		local left = ctrl and Keyboard:isKeyDown("Left") -- 833
		local right = ctrl and Keyboard:isKeyDown("Right") -- 834
		local currentIndex = nil -- 835
		for i, entry in ipairs(allEntries) do -- 836
			if currentEntry == entry then -- 837
				currentIndex = i -- 838
			end -- 837
		end -- 838
		if left then -- 839
			allClear() -- 840
			if currentIndex == nil then -- 841
				currentIndex = #allEntries + 1 -- 841
			end -- 841
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 842
		end -- 839
		if right then -- 846
			allClear() -- 847
			if currentIndex == nil then -- 848
				currentIndex = 0 -- 848
			end -- 848
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 849
		end -- 846
	end -- 852
	if not showEntry then -- 853
		return -- 853
	end -- 853
	local width, height -- 855
	do -- 855
		local _obj_0 = App.visualSize -- 855
		width, height = _obj_0.width, _obj_0.height -- 855
	end -- 855
	SetNextWindowSize(Vec2(50, 50)) -- 856
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 857
	PushStyleColor("WindowBg", transparant, function() -- 858
		return Begin("Show", windowFlags, function() -- 858
			if isInEntry or width >= 540 then -- 859
				local changed -- 860
				changed, showFooter = Checkbox("##dev", showFooter) -- 860
				if changed then -- 860
					config.showFooter = showFooter -- 861
				end -- 860
			end -- 859
		end) -- 861
	end) -- 858
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 863
		reloadDevEntry() -- 867
	end -- 863
	if initFooter then -- 868
		initFooter = false -- 869
	else -- 871
		if not showFooter then -- 871
			return -- 871
		end -- 871
	end -- 868
	SetNextWindowSize(Vec2(width, 50)) -- 873
	SetNextWindowPos(Vec2(0, height - 50)) -- 874
	SetNextWindowBgAlpha(0.35) -- 875
	do -- 876
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 877
			return Begin("Footer", windowFlags, function() -- 878
				Dummy(Vec2(width - 20, 0)) -- 879
				do -- 880
					local changed -- 880
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 880
					if changed then -- 880
						config.showStats = showStats -- 881
					end -- 880
				end -- 880
				SameLine() -- 882
				do -- 883
					local changed -- 883
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 883
					if changed then -- 883
						config.showConsole = showConsole -- 884
					end -- 883
				end -- 883
				if config.updateNotification then -- 885
					SameLine() -- 886
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 887
						allClear() -- 888
						config.updateNotification = false -- 889
						enterDemoEntry({ -- 891
							"SelfUpdater", -- 891
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 892
						}) -- 890
					end -- 887
				end -- 885
				if not isInEntry then -- 894
					SameLine() -- 895
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 896
					local currentIndex = nil -- 897
					for i, entry in ipairs(allEntries) do -- 898
						if currentEntry == entry then -- 899
							currentIndex = i -- 900
						end -- 899
					end -- 900
					if currentIndex then -- 901
						if currentIndex > 1 then -- 902
							SameLine() -- 903
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 904
								allClear() -- 905
								enterDemoEntry(allEntries[currentIndex - 1]) -- 906
							end -- 904
						end -- 902
						if currentIndex < #allEntries then -- 907
							SameLine() -- 908
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 909
								allClear() -- 910
								enterDemoEntry(allEntries[currentIndex + 1]) -- 911
							end -- 909
						end -- 907
					end -- 901
					SameLine() -- 912
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 913
						reloadCurrentEntry() -- 914
					end -- 913
					if back then -- 915
						allClear() -- 916
						isInEntry = true -- 917
						currentEntry = nil -- 918
					end -- 915
				end -- 894
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 919
					if showStats then -- 920
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 921
						showStats = ShowStats(showStats, extraOperations) -- 922
						config.showStats = showStats -- 923
					end -- 920
					if showConsole then -- 924
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 925
						showConsole = ShowConsole(showConsole) -- 926
						config.showConsole = showConsole -- 927
					end -- 924
				end) -- 919
			end) -- 878
		end) -- 877
	end -- 927
end) -- 807
local MaxWidth <const> = 960 -- 929
local displayWindowFlags = { -- 931
	"NoDecoration", -- 931
	"NoSavedSettings", -- 931
	"NoFocusOnAppearing", -- 931
	"NoNav", -- 931
	"NoMove", -- 931
	"NoScrollWithMouse", -- 931
	"AlwaysAutoResize", -- 931
	"NoBringToFrontOnFocus" -- 931
} -- 931
local webStatus = nil -- 942
local descColor = Color(0xffa1a1a1) -- 943
local toolOpen = false -- 944
local filterText = nil -- 945
local anyEntryMatched = false -- 946
local urlClicked = nil -- 947
local match -- 948
match = function(name) -- 948
	local res = not filterText or name:lower():match(filterText) -- 949
	if res then -- 950
		anyEntryMatched = true -- 950
	end -- 950
	return res -- 951
end -- 948
local icon = Path("Script", "Dev", "icon_s.png") -- 952
local iconTex = nil -- 953
thread(function() -- 954
	if Cache:loadAsync(icon) then -- 954
		iconTex = Texture2D(icon) -- 954
	end -- 954
end) -- 954
local sep -- 956
sep = function() -- 956
	return SeparatorText("") -- 956
end -- 956
local thinSep -- 957
thinSep = function() -- 957
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 957
end -- 957
entryWindow = threadLoop(function() -- 959
	if App.fpsLimited ~= config.fpsLimited then -- 960
		config.fpsLimited = App.fpsLimited -- 961
	end -- 960
	if App.targetFPS ~= config.targetFPS then -- 962
		config.targetFPS = App.targetFPS -- 963
	end -- 962
	if View.vsync ~= config.vsync then -- 964
		config.vsync = View.vsync -- 965
	end -- 964
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 966
		config.fixedFPS = Director.scheduler.fixedFPS -- 967
	end -- 966
	if Director.profilerSending ~= config.webProfiler then -- 968
		config.webProfiler = Director.profilerSending -- 969
	end -- 968
	if urlClicked then -- 970
		local _, result = coroutine.resume(urlClicked) -- 971
		if result then -- 972
			coroutine.close(urlClicked) -- 973
			urlClicked = nil -- 974
		end -- 972
	end -- 970
	if not showEntry then -- 975
		return -- 975
	end -- 975
	if not isInEntry then -- 976
		return -- 976
	end -- 976
	local zh = useChinese and isChineseSupported -- 977
	if HttpServer.wsConnectionCount > 0 then -- 978
		local themeColor = App.themeColor -- 979
		local width, height -- 980
		do -- 980
			local _obj_0 = App.visualSize -- 980
			width, height = _obj_0.width, _obj_0.height -- 980
		end -- 980
		SetNextWindowBgAlpha(0.5) -- 981
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 982
		Begin("Web IDE Connected", displayWindowFlags, function() -- 983
			Separator() -- 984
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 985
			if iconTex then -- 986
				Image(icon, Vec2(24, 24)) -- 987
				SameLine() -- 988
			end -- 986
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 989
			TextColored(descColor, slogon) -- 990
			return Separator() -- 991
		end) -- 983
		return -- 992
	end -- 978
	local themeColor = App.themeColor -- 994
	local fullWidth, height -- 995
	do -- 995
		local _obj_0 = App.visualSize -- 995
		fullWidth, height = _obj_0.width, _obj_0.height -- 995
	end -- 995
	SetNextWindowBgAlpha(0.85) -- 997
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 998
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 999
		return Begin("Web IDE", displayWindowFlags, function() -- 1000
			Separator() -- 1001
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 1002
			SameLine() -- 1003
			TextDisabled('(?)') -- 1004
			if IsItemHovered() then -- 1005
				BeginTooltip(function() -- 1006
					return PushTextWrapPos(280, function() -- 1007
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 1008
					end) -- 1008
				end) -- 1006
			end -- 1005
			do -- 1009
				local url -- 1009
				if webStatus ~= nil then -- 1009
					url = webStatus.url -- 1009
				end -- 1009
				if url then -- 1009
					if isDesktop and not config.fullScreen then -- 1010
						if urlClicked then -- 1011
							BeginDisabled(function() -- 1012
								return Button(url) -- 1012
							end) -- 1012
						elseif Button(url) then -- 1013
							urlClicked = once(function() -- 1014
								return sleep(5) -- 1014
							end) -- 1014
							App:openURL("http://localhost:8866") -- 1015
						end -- 1011
					else -- 1017
						TextColored(descColor, url) -- 1017
					end -- 1010
				else -- 1019
					TextColored(descColor, zh and '不可用' or 'not available') -- 1019
				end -- 1009
			end -- 1009
			return Separator() -- 1020
		end) -- 1020
	end) -- 999
	local width = math.min(MaxWidth, fullWidth) -- 1022
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1023
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1024
	SetNextWindowPos(Vec2.zero) -- 1025
	SetNextWindowBgAlpha(0) -- 1026
	do -- 1027
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1028
			return Begin("Dora Dev", displayWindowFlags, function() -- 1029
				Dummy(Vec2(fullWidth - 20, 0)) -- 1030
				if iconTex then -- 1031
					Image(icon, Vec2(24, 24)) -- 1032
					SameLine() -- 1033
				end -- 1031
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 1034
				if fullWidth >= 400 then -- 1035
					SameLine() -- 1036
					Dummy(Vec2(fullWidth - 400, 0)) -- 1037
					SameLine() -- 1038
					SetNextItemWidth(zh and -90 or -140) -- 1039
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1040
						"AutoSelectAll" -- 1040
					}) then -- 1040
						config.filter = filterBuf.text -- 1041
					end -- 1040
					SameLine() -- 1042
					if Button(zh and '下载' or 'Download') then -- 1043
						allClear() -- 1044
						enterDemoEntry({ -- 1046
							"ResourceDownloader", -- 1046
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1047
						}) -- 1045
					end -- 1043
				end -- 1035
				Separator() -- 1049
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1050
			end) -- 1029
		end) -- 1028
	end -- 1050
	anyEntryMatched = false -- 1052
	SetNextWindowPos(Vec2(0, 50)) -- 1053
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1054
	do -- 1055
		return PushStyleColor("WindowBg", transparant, function() -- 1056
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1057
				return PushStyleVar("Alpha", 1, function() -- 1058
					return Begin("Content", windowFlags, function() -- 1059
						local DemoViewWidth <const> = 320 -- 1060
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1061
						if filterText then -- 1062
							filterText = filterText:lower() -- 1062
						end -- 1062
						if #gamesInDev > 0 then -- 1063
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1064
							Columns(columns, false) -- 1065
							local realViewWidth = GetColumnWidth() - 50 -- 1066
							for _index_0 = 1, #gamesInDev do -- 1067
								local game = gamesInDev[_index_0] -- 1067
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1068
								if match(gameName) then -- 1069
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1070
									SameLine() -- 1071
									TextWrapped(gameName) -- 1072
									if columns > 1 then -- 1073
										if bannerFile then -- 1074
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1075
											local displayWidth <const> = realViewWidth -- 1076
											texHeight = displayWidth * texHeight / texWidth -- 1077
											texWidth = displayWidth -- 1078
											Dummy(Vec2.zero) -- 1079
											SameLine() -- 1080
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1081
										end -- 1074
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1082
											enterDemoEntry(game) -- 1083
										end -- 1082
									else -- 1085
										if bannerFile then -- 1085
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1086
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1087
											local sizing = 0.8 -- 1088
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1089
											texWidth = displayWidth * sizing -- 1090
											if texWidth > 500 then -- 1091
												sizing = 0.6 -- 1092
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1093
												texWidth = displayWidth * sizing -- 1094
											end -- 1091
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1095
											Dummy(Vec2(padding, 0)) -- 1096
											SameLine() -- 1097
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1098
										end -- 1085
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1099
											enterDemoEntry(game) -- 1100
										end -- 1099
									end -- 1073
									if #tests == 0 and #examples == 0 then -- 1101
										thinSep() -- 1102
									end -- 1101
									NextColumn() -- 1103
								end -- 1069
								local showSep = false -- 1104
								if #examples > 0 then -- 1105
									local showExample = false -- 1106
									do -- 1107
										local _accum_0 -- 1107
										for _index_1 = 1, #examples do -- 1107
											local _des_0 = examples[_index_1] -- 1107
											local name = _des_0[1] -- 1107
											if match(name) then -- 1108
												_accum_0 = true -- 1108
												break -- 1108
											end -- 1108
										end -- 1108
										showExample = _accum_0 -- 1107
									end -- 1108
									if showExample then -- 1109
										showSep = true -- 1110
										Columns(1, false) -- 1111
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1112
										SameLine() -- 1113
										local opened -- 1114
										if (filterText ~= nil) then -- 1114
											opened = showExample -- 1114
										else -- 1114
											opened = false -- 1114
										end -- 1114
										if game.exampleOpen == nil then -- 1115
											game.exampleOpen = opened -- 1115
										end -- 1115
										SetNextItemOpen(game.exampleOpen) -- 1116
										TreeNode(tostring(gameName) .. "###example-" .. tostring(fileName), function() -- 1117
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1118
												Columns(maxColumns, false) -- 1119
												for _index_1 = 1, #examples do -- 1120
													local example = examples[_index_1] -- 1120
													if not match(example[1]) then -- 1121
														goto _continue_0 -- 1121
													end -- 1121
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1122
														if Button(example[1], Vec2(-1, 40)) then -- 1123
															enterDemoEntry(example) -- 1124
														end -- 1123
														return NextColumn() -- 1125
													end) -- 1122
													opened = true -- 1126
													::_continue_0:: -- 1121
												end -- 1126
											end) -- 1118
										end) -- 1117
										game.exampleOpen = opened -- 1127
									end -- 1109
								end -- 1105
								if #tests > 0 then -- 1128
									local showTest = false -- 1129
									do -- 1130
										local _accum_0 -- 1130
										for _index_1 = 1, #tests do -- 1130
											local _des_0 = tests[_index_1] -- 1130
											local name = _des_0[1] -- 1130
											if match(name) then -- 1131
												_accum_0 = true -- 1131
												break -- 1131
											end -- 1131
										end -- 1131
										showTest = _accum_0 -- 1130
									end -- 1131
									if showTest then -- 1132
										showSep = true -- 1133
										Columns(1, false) -- 1134
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1135
										SameLine() -- 1136
										local opened -- 1137
										if (filterText ~= nil) then -- 1137
											opened = showTest -- 1137
										else -- 1137
											opened = false -- 1137
										end -- 1137
										if game.testOpen == nil then -- 1138
											game.testOpen = opened -- 1138
										end -- 1138
										SetNextItemOpen(game.testOpen) -- 1139
										TreeNode(tostring(gameName) .. "###test-" .. tostring(fileName), function() -- 1140
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1141
												Columns(maxColumns, false) -- 1142
												for _index_1 = 1, #tests do -- 1143
													local test = tests[_index_1] -- 1143
													if not match(test[1]) then -- 1144
														goto _continue_0 -- 1144
													end -- 1144
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1145
														if Button(test[1], Vec2(-1, 40)) then -- 1146
															enterDemoEntry(test) -- 1147
														end -- 1146
														return NextColumn() -- 1148
													end) -- 1145
													opened = true -- 1149
													::_continue_0:: -- 1144
												end -- 1149
											end) -- 1141
										end) -- 1140
										game.testOpen = opened -- 1150
									end -- 1132
								end -- 1128
								if showSep then -- 1151
									Columns(1, false) -- 1152
									thinSep() -- 1153
									Columns(columns, false) -- 1154
								end -- 1151
							end -- 1154
						end -- 1063
						if #doraTools > 0 then -- 1155
							local showTool = false -- 1156
							do -- 1157
								local _accum_0 -- 1157
								for _index_0 = 1, #doraTools do -- 1157
									local _des_0 = doraTools[_index_0] -- 1157
									local name = _des_0[1] -- 1157
									if match(name) then -- 1158
										_accum_0 = true -- 1158
										break -- 1158
									end -- 1158
								end -- 1158
								showTool = _accum_0 -- 1157
							end -- 1158
							if not showTool then -- 1159
								goto endEntry -- 1159
							end -- 1159
							Columns(1, false) -- 1160
							TextColored(themeColor, "Dora SSR:") -- 1161
							SameLine() -- 1162
							Text(zh and "开发支持" or "Development Support") -- 1163
							Separator() -- 1164
							if #doraTools > 0 then -- 1165
								local opened -- 1166
								if (filterText ~= nil) then -- 1166
									opened = showTool -- 1166
								else -- 1166
									opened = false -- 1166
								end -- 1166
								SetNextItemOpen(toolOpen) -- 1167
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1168
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1169
										Columns(maxColumns, false) -- 1170
										for _index_0 = 1, #doraTools do -- 1171
											local example = doraTools[_index_0] -- 1171
											if not match(example[1]) then -- 1172
												goto _continue_0 -- 1172
											end -- 1172
											if Button(example[1], Vec2(-1, 40)) then -- 1173
												enterDemoEntry(example) -- 1174
											end -- 1173
											NextColumn() -- 1175
											::_continue_0:: -- 1172
										end -- 1175
										Columns(1, false) -- 1176
										opened = true -- 1177
									end) -- 1169
								end) -- 1168
								toolOpen = opened -- 1178
							end -- 1165
						end -- 1155
						::endEntry:: -- 1179
						if not anyEntryMatched then -- 1180
							SetNextWindowBgAlpha(0) -- 1181
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1182
							Begin("Entries Not Found", displayWindowFlags, function() -- 1183
								Separator() -- 1184
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1185
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1186
								return Separator() -- 1187
							end) -- 1183
						end -- 1180
						Columns(1, false) -- 1188
						Dummy(Vec2(100, 80)) -- 1189
						return ScrollWhenDraggingOnVoid() -- 1190
					end) -- 1059
				end) -- 1058
			end) -- 1057
		end) -- 1056
	end -- 1190
end) -- 959
webStatus = require("Script.Dev.WebServer") -- 1192
return _module_0 -- 1192
