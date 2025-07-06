-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local ShowConsole = _module_0.ShowConsole -- 1
local package = _G.package -- 1
local DB = Dora.DB -- 1
local View = Dora.View -- 1
local Director = Dora.Director -- 1
local Size = Dora.Size -- 1
local Vec2 = Dora.Vec2 -- 1
local Color = Dora.Color -- 1
local Buffer = Dora.Buffer -- 1
local thread = Dora.thread -- 1
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
local sleep = Dora.sleep -- 1
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
		end -- 114
		local winX, winY -- 116
		do -- 116
			local _obj_0 = App.winPosition -- 116
			winX, winY = _obj_0.x, _obj_0.y -- 116
		end -- 116
		if (config.winX ~= nil) then -- 117
			winX = config.winX -- 118
		else -- 120
			config.winX = -1 -- 120
		end -- 117
		if (config.winY ~= nil) then -- 121
			winY = config.winY -- 122
		else -- 124
			config.winY = -1 -- 124
		end -- 121
		App.winPosition = Vec2(winX, winY) -- 125
	end -- 110
	if (config.alwaysOnTop ~= nil) then -- 126
		App.alwaysOnTop = config.alwaysOnTop -- 127
	else -- 129
		config.alwaysOnTop = true -- 129
	end -- 126
end -- 108
if (config.themeColor ~= nil) then -- 131
	App.themeColor = Color(config.themeColor) -- 132
else -- 134
	config.themeColor = App.themeColor:toARGB() -- 134
end -- 131
if not (config.locale ~= nil) then -- 136
	config.locale = App.locale -- 137
end -- 136
local showStats = false -- 139
if (config.showStats ~= nil) then -- 140
	showStats = config.showStats -- 141
else -- 143
	config.showStats = showStats -- 143
end -- 140
local showConsole = false -- 145
if (config.showConsole ~= nil) then -- 146
	showConsole = config.showConsole -- 147
else -- 149
	config.showConsole = showConsole -- 149
end -- 146
local showFooter = true -- 151
if (config.showFooter ~= nil) then -- 152
	showFooter = config.showFooter -- 153
else -- 155
	config.showFooter = showFooter -- 155
end -- 152
local filterBuf = Buffer(20) -- 157
if (config.filter ~= nil) then -- 158
	filterBuf.text = config.filter -- 159
else -- 161
	config.filter = "" -- 161
end -- 158
local engineDev = false -- 163
if (config.engineDev ~= nil) then -- 164
	engineDev = config.engineDev -- 165
else -- 167
	config.engineDev = engineDev -- 167
end -- 164
if (config.webProfiler ~= nil) then -- 169
	Director.profilerSending = config.webProfiler -- 170
else -- 172
	config.webProfiler = true -- 172
	Director.profilerSending = true -- 173
end -- 169
if not (config.drawerWidth ~= nil) then -- 175
	config.drawerWidth = 200 -- 176
end -- 175
_module_0.getConfig = function() -- 178
	return config -- 178
end -- 178
_module_0.getEngineDev = function() -- 179
	if not App.debugging then -- 180
		return false -- 180
	end -- 180
	return config.engineDev -- 181
end -- 179
local _anon_func_0 = function(App) -- 186
	local _val_0 = App.platform -- 186
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 186
end -- 186
_module_0.connectWebIDE = function() -- 183
	if not config.webIDEConnected then -- 184
		config.webIDEConnected = true -- 185
		if _anon_func_0(App) then -- 186
			local ratio = App.winSize.width / App.visualSize.width -- 187
			App.winSize = Size(640 * ratio, 480 * ratio) -- 188
		end -- 186
	end -- 184
end -- 183
local updateCheck -- 190
updateCheck = function() -- 190
	return thread(function() -- 190
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 191
		if res then -- 191
			local data = json.load(res) -- 192
			if data then -- 192
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 193
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 194
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 195
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 196
				if na < a then -- 197
					goto not_new_version -- 198
				end -- 197
				if na == a then -- 199
					if nb < b then -- 200
						goto not_new_version -- 201
					end -- 200
					if nb == b then -- 202
						if nc < c then -- 203
							goto not_new_version -- 204
						end -- 203
						if nc == c then -- 205
							goto not_new_version -- 206
						end -- 205
					end -- 202
				end -- 199
				config.updateNotification = true -- 207
				::not_new_version:: -- 208
				config.lastUpdateCheck = os.time() -- 209
			end -- 192
		end -- 191
	end) -- 209
end -- 190
if (config.lastUpdateCheck ~= nil) then -- 211
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 212
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 213
		updateCheck() -- 214
	end -- 213
else -- 216
	updateCheck() -- 216
end -- 211
local Set, Struct, LintYueGlobals, GSplit -- 218
do -- 218
	local _obj_0 = require("Utils") -- 218
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 218
end -- 218
local yueext = yue.options.extension -- 219
local isChineseSupported = IsFontLoaded() -- 221
if not isChineseSupported then -- 222
	LoadFontTTF("Font/sarasa-mono-sc-regular.ttf", 20, "Chinese", function() -- 223
		isChineseSupported = true -- 224
	end) -- 223
end -- 222
local building = false -- 226
local getAllFiles -- 228
getAllFiles = function(path, exts, recursive) -- 228
	if recursive == nil then -- 228
		recursive = true -- 228
	end -- 228
	local filters = Set(exts) -- 229
	local files -- 230
	if recursive then -- 230
		files = Content:getAllFiles(path) -- 231
	else -- 233
		files = Content:getFiles(path) -- 233
	end -- 230
	local _accum_0 = { } -- 234
	local _len_0 = 1 -- 234
	for _index_0 = 1, #files do -- 234
		local file = files[_index_0] -- 234
		if not filters[Path:getExt(file)] then -- 235
			goto _continue_0 -- 235
		end -- 235
		_accum_0[_len_0] = file -- 236
		_len_0 = _len_0 + 1 -- 235
		::_continue_0:: -- 235
	end -- 236
	return _accum_0 -- 236
end -- 228
_module_0["getAllFiles"] = getAllFiles -- 236
local getFileEntries -- 238
getFileEntries = function(path, recursive, excludeFiles) -- 238
	if recursive == nil then -- 238
		recursive = true -- 238
	end -- 238
	if excludeFiles == nil then -- 238
		excludeFiles = nil -- 238
	end -- 238
	local entries = { } -- 239
	local excludes -- 240
	if excludeFiles then -- 240
		excludes = Set(excludeFiles) -- 241
	end -- 240
	local _list_0 = getAllFiles(path, { -- 242
		"lua", -- 242
		"xml", -- 242
		yueext, -- 242
		"tl" -- 242
	}, recursive) -- 242
	for _index_0 = 1, #_list_0 do -- 242
		local file = _list_0[_index_0] -- 242
		local entryName = Path:getName(file) -- 243
		if excludes and excludes[entryName] then -- 244
			goto _continue_0 -- 245
		end -- 244
		local fileName = Path:replaceExt(file, "") -- 246
		fileName = Path(path, fileName) -- 247
		local entryAdded -- 248
		do -- 248
			local _accum_0 -- 248
			for _index_1 = 1, #entries do -- 248
				local _des_0 = entries[_index_1] -- 248
				local ename, efile = _des_0[1], _des_0[2] -- 248
				if entryName == ename and efile == fileName then -- 249
					_accum_0 = true -- 249
					break -- 249
				end -- 249
			end -- 249
			entryAdded = _accum_0 -- 248
		end -- 249
		if entryAdded then -- 250
			goto _continue_0 -- 250
		end -- 250
		local entry = { -- 251
			entryName, -- 251
			fileName -- 251
		} -- 251
		entries[#entries + 1] = entry -- 252
		::_continue_0:: -- 243
	end -- 252
	table.sort(entries, function(a, b) -- 253
		return a[1] < b[1] -- 253
	end) -- 253
	return entries -- 254
end -- 238
local getProjectEntries -- 256
getProjectEntries = function(path) -- 256
	local entries = { } -- 257
	local _list_0 = Content:getDirs(path) -- 258
	for _index_0 = 1, #_list_0 do -- 258
		local dir = _list_0[_index_0] -- 258
		if dir:match("^%.") then -- 259
			goto _continue_0 -- 259
		end -- 259
		local _list_1 = getAllFiles(Path(path, dir), { -- 260
			"lua", -- 260
			"xml", -- 260
			yueext, -- 260
			"tl", -- 260
			"wasm" -- 260
		}) -- 260
		for _index_1 = 1, #_list_1 do -- 260
			local file = _list_1[_index_1] -- 260
			if "init" == Path:getName(file):lower() then -- 261
				local fileName = Path:replaceExt(file, "") -- 262
				fileName = Path(path, dir, fileName) -- 263
				local entryName = Path:getName(Path:getPath(fileName)) -- 264
				local entryAdded -- 265
				do -- 265
					local _accum_0 -- 265
					for _index_2 = 1, #entries do -- 265
						local _des_0 = entries[_index_2] -- 265
						local ename, efile = _des_0[1], _des_0[2] -- 265
						if entryName == ename and efile == fileName then -- 266
							_accum_0 = true -- 266
							break -- 266
						end -- 266
					end -- 266
					entryAdded = _accum_0 -- 265
				end -- 266
				if entryAdded then -- 267
					goto _continue_1 -- 267
				end -- 267
				local examples = { } -- 268
				local tests = { } -- 269
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 270
				if Content:exist(examplePath) then -- 271
					local _list_2 = getFileEntries(examplePath) -- 272
					for _index_2 = 1, #_list_2 do -- 272
						local _des_0 = _list_2[_index_2] -- 272
						local name, ePath = _des_0[1], _des_0[2] -- 272
						local entry = { -- 274
							name, -- 274
							Path(path, dir, Path:getPath(file), ePath), -- 274
							workDir = Path:getPath(fileName) -- 275
						} -- 273
						examples[#examples + 1] = entry -- 277
					end -- 277
				end -- 271
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 278
				if Content:exist(testPath) then -- 279
					local _list_2 = getFileEntries(testPath) -- 280
					for _index_2 = 1, #_list_2 do -- 280
						local _des_0 = _list_2[_index_2] -- 280
						local name, tPath = _des_0[1], _des_0[2] -- 280
						local entry = { -- 282
							name, -- 282
							Path(path, dir, Path:getPath(file), tPath), -- 282
							workDir = Path:getPath(fileName) -- 283
						} -- 281
						tests[#tests + 1] = entry -- 285
					end -- 285
				end -- 279
				local entry = { -- 286
					entryName, -- 286
					fileName, -- 286
					examples, -- 286
					tests -- 286
				} -- 286
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 287
				if not Content:exist(bannerFile) then -- 288
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 289
					if not Content:exist(bannerFile) then -- 290
						bannerFile = nil -- 290
					end -- 290
				end -- 288
				if bannerFile then -- 291
					thread(function() -- 291
						if Cache:loadAsync(bannerFile) then -- 292
							local bannerTex = Texture2D(bannerFile) -- 293
							if bannerTex then -- 294
								entry[#entry + 1] = bannerFile -- 295
								entry[#entry + 1] = bannerTex -- 296
							end -- 294
						end -- 292
					end) -- 291
				end -- 291
				entries[#entries + 1] = entry -- 297
			end -- 261
			::_continue_1:: -- 261
		end -- 297
		::_continue_0:: -- 259
	end -- 297
	table.sort(entries, function(a, b) -- 298
		return a[1] < b[1] -- 298
	end) -- 298
	return entries -- 299
end -- 256
local gamesInDev -- 301
local doraTools -- 302
local allEntries -- 303
local updateEntries -- 305
updateEntries = function() -- 305
	gamesInDev = getProjectEntries(Content.writablePath) -- 306
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 307
	allEntries = { } -- 309
	for _index_0 = 1, #gamesInDev do -- 310
		local game = gamesInDev[_index_0] -- 310
		allEntries[#allEntries + 1] = game -- 311
		local examples, tests = game[3], game[4] -- 312
		for _index_1 = 1, #examples do -- 313
			local example = examples[_index_1] -- 313
			allEntries[#allEntries + 1] = example -- 314
		end -- 314
		for _index_1 = 1, #tests do -- 315
			local test = tests[_index_1] -- 315
			allEntries[#allEntries + 1] = test -- 316
		end -- 316
	end -- 316
end -- 305
updateEntries() -- 318
local doCompile -- 320
doCompile = function(minify) -- 320
	if building then -- 321
		return -- 321
	end -- 321
	building = true -- 322
	local startTime = App.runningTime -- 323
	local luaFiles = { } -- 324
	local yueFiles = { } -- 325
	local xmlFiles = { } -- 326
	local tlFiles = { } -- 327
	local writablePath = Content.writablePath -- 328
	local buildPaths = { -- 330
		{ -- 331
			Content.assetPath, -- 331
			Path(writablePath, ".build"), -- 332
			"" -- 333
		} -- 330
	} -- 329
	for _index_0 = 1, #gamesInDev do -- 336
		local _des_0 = gamesInDev[_index_0] -- 336
		local entryFile = _des_0[2] -- 336
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 337
		buildPaths[#buildPaths + 1] = { -- 339
			Path(writablePath, gamePath), -- 339
			Path(writablePath, ".build", gamePath), -- 340
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 341
			gamePath -- 342
		} -- 338
	end -- 342
	for _index_0 = 1, #buildPaths do -- 343
		local _des_0 = buildPaths[_index_0] -- 343
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 343
		if not Content:exist(inputPath) then -- 344
			goto _continue_0 -- 344
		end -- 344
		local _list_0 = getAllFiles(inputPath, { -- 346
			"lua" -- 346
		}) -- 346
		for _index_1 = 1, #_list_0 do -- 346
			local file = _list_0[_index_1] -- 346
			luaFiles[#luaFiles + 1] = { -- 348
				file, -- 348
				Path(inputPath, file), -- 349
				Path(outputPath, file), -- 350
				gamePath -- 351
			} -- 347
		end -- 351
		local _list_1 = getAllFiles(inputPath, { -- 353
			yueext -- 353
		}) -- 353
		for _index_1 = 1, #_list_1 do -- 353
			local file = _list_1[_index_1] -- 353
			yueFiles[#yueFiles + 1] = { -- 355
				file, -- 355
				Path(inputPath, file), -- 356
				Path(outputPath, Path:replaceExt(file, "lua")), -- 357
				searchPath, -- 358
				gamePath -- 359
			} -- 354
		end -- 359
		local _list_2 = getAllFiles(inputPath, { -- 361
			"xml" -- 361
		}) -- 361
		for _index_1 = 1, #_list_2 do -- 361
			local file = _list_2[_index_1] -- 361
			xmlFiles[#xmlFiles + 1] = { -- 363
				file, -- 363
				Path(inputPath, file), -- 364
				Path(outputPath, Path:replaceExt(file, "lua")), -- 365
				gamePath -- 366
			} -- 362
		end -- 366
		local _list_3 = getAllFiles(inputPath, { -- 368
			"tl" -- 368
		}) -- 368
		for _index_1 = 1, #_list_3 do -- 368
			local file = _list_3[_index_1] -- 368
			if not file:match(".*%.d%.tl$") then -- 369
				tlFiles[#tlFiles + 1] = { -- 371
					file, -- 371
					Path(inputPath, file), -- 372
					Path(outputPath, Path:replaceExt(file, "lua")), -- 373
					searchPath, -- 374
					gamePath -- 375
				} -- 370
			end -- 369
		end -- 375
		::_continue_0:: -- 344
	end -- 375
	local paths -- 377
	do -- 377
		local _tbl_0 = { } -- 377
		local _list_0 = { -- 378
			luaFiles, -- 378
			yueFiles, -- 378
			xmlFiles, -- 378
			tlFiles -- 378
		} -- 378
		for _index_0 = 1, #_list_0 do -- 378
			local files = _list_0[_index_0] -- 378
			for _index_1 = 1, #files do -- 379
				local file = files[_index_1] -- 379
				_tbl_0[Path:getPath(file[3])] = true -- 377
			end -- 377
		end -- 377
		paths = _tbl_0 -- 377
	end -- 379
	for path in pairs(paths) do -- 381
		Content:mkdir(path) -- 381
	end -- 381
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 383
	local fileCount = 0 -- 384
	local errors = { } -- 385
	for _index_0 = 1, #yueFiles do -- 386
		local _des_0 = yueFiles[_index_0] -- 386
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 386
		local filename -- 387
		if gamePath then -- 387
			filename = Path(gamePath, file) -- 387
		else -- 387
			filename = file -- 387
		end -- 387
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 388
			if not codes then -- 389
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 390
				return -- 391
			end -- 389
			local success, result = LintYueGlobals(codes, globals) -- 392
			if success then -- 393
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 394
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 395
				codes = codes:gsub("^\n*", "") -- 396
				if not (result == "") then -- 397
					result = result .. "\n" -- 397
				end -- 397
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 398
			else -- 400
				local yueCodes = Content:load(input) -- 400
				if yueCodes then -- 400
					local globalErrors = { } -- 401
					for _index_1 = 1, #result do -- 402
						local _des_1 = result[_index_1] -- 402
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 402
						local countLine = 1 -- 403
						local code = "" -- 404
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 405
							if countLine == line then -- 406
								code = lineCode -- 407
								break -- 408
							end -- 406
							countLine = countLine + 1 -- 409
						end -- 409
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 410
					end -- 410
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 411
				else -- 413
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 413
				end -- 400
			end -- 393
		end, function(success) -- 388
			if success then -- 414
				print("Yue compiled: " .. tostring(filename)) -- 414
			end -- 414
			fileCount = fileCount + 1 -- 415
		end) -- 388
	end -- 415
	thread(function() -- 417
		for _index_0 = 1, #xmlFiles do -- 418
			local _des_0 = xmlFiles[_index_0] -- 418
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 418
			local filename -- 419
			if gamePath then -- 419
				filename = Path(gamePath, file) -- 419
			else -- 419
				filename = file -- 419
			end -- 419
			local sourceCodes = Content:loadAsync(input) -- 420
			local codes, err = xml.tolua(sourceCodes) -- 421
			if not codes then -- 422
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 423
			else -- 425
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 425
				print("Xml compiled: " .. tostring(filename)) -- 426
			end -- 422
			fileCount = fileCount + 1 -- 427
		end -- 427
	end) -- 417
	thread(function() -- 429
		for _index_0 = 1, #tlFiles do -- 430
			local _des_0 = tlFiles[_index_0] -- 430
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 430
			local filename -- 431
			if gamePath then -- 431
				filename = Path(gamePath, file) -- 431
			else -- 431
				filename = file -- 431
			end -- 431
			local sourceCodes = Content:loadAsync(input) -- 432
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 433
			if not codes then -- 434
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 435
			else -- 437
				Content:saveAsync(output, codes) -- 437
				print("Teal compiled: " .. tostring(filename)) -- 438
			end -- 434
			fileCount = fileCount + 1 -- 439
		end -- 439
	end) -- 429
	return thread(function() -- 441
		wait(function() -- 442
			return fileCount == totalFiles -- 442
		end) -- 442
		if minify then -- 443
			local _list_0 = { -- 444
				yueFiles, -- 444
				xmlFiles, -- 444
				tlFiles -- 444
			} -- 444
			for _index_0 = 1, #_list_0 do -- 444
				local files = _list_0[_index_0] -- 444
				for _index_1 = 1, #files do -- 444
					local file = files[_index_1] -- 444
					local output = Path:replaceExt(file[3], "lua") -- 445
					luaFiles[#luaFiles + 1] = { -- 447
						Path:replaceExt(file[1], "lua"), -- 447
						output, -- 448
						output -- 449
					} -- 446
				end -- 449
			end -- 449
			local FormatMini -- 451
			do -- 451
				local _obj_0 = require("luaminify") -- 451
				FormatMini = _obj_0.FormatMini -- 451
			end -- 451
			for _index_0 = 1, #luaFiles do -- 452
				local _des_0 = luaFiles[_index_0] -- 452
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 452
				if Content:exist(input) then -- 453
					local sourceCodes = Content:loadAsync(input) -- 454
					local res, err = FormatMini(sourceCodes) -- 455
					if res then -- 456
						Content:saveAsync(output, res) -- 457
						print("Minify: " .. tostring(file)) -- 458
					else -- 460
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 460
					end -- 456
				else -- 462
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 462
				end -- 453
			end -- 462
			package.loaded["luaminify.FormatMini"] = nil -- 463
			package.loaded["luaminify.ParseLua"] = nil -- 464
			package.loaded["luaminify.Scope"] = nil -- 465
			package.loaded["luaminify.Util"] = nil -- 466
		end -- 443
		local errorMessage = table.concat(errors, "\n") -- 467
		if errorMessage ~= "" then -- 468
			print(errorMessage) -- 468
		end -- 468
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 469
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 470
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 471
		Content:clearPathCache() -- 472
		teal.clear() -- 473
		yue.clear() -- 474
		building = false -- 475
	end) -- 475
end -- 320
local doClean -- 477
doClean = function() -- 477
	if building then -- 478
		return -- 478
	end -- 478
	local writablePath = Content.writablePath -- 479
	local targetDir = Path(writablePath, ".build") -- 480
	Content:clearPathCache() -- 481
	if Content:remove(targetDir) then -- 482
		return print("Cleaned: " .. tostring(targetDir)) -- 483
	end -- 482
end -- 477
local screenScale = 2.0 -- 485
local scaleContent = false -- 486
local isInEntry = true -- 487
local currentEntry = nil -- 488
local footerWindow = nil -- 490
local entryWindow = nil -- 491
local testingThread = nil -- 492
local setupEventHandlers = nil -- 494
local allClear -- 496
allClear = function() -- 496
	local _list_0 = Routine -- 497
	for _index_0 = 1, #_list_0 do -- 497
		local routine = _list_0[_index_0] -- 497
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 499
			goto _continue_0 -- 500
		else -- 502
			Routine:remove(routine) -- 502
		end -- 502
		::_continue_0:: -- 498
	end -- 502
	for _index_0 = 1, #moduleCache do -- 503
		local module = moduleCache[_index_0] -- 503
		package.loaded[module] = nil -- 504
	end -- 504
	moduleCache = { } -- 505
	Director:cleanup() -- 506
	Cache:unload() -- 507
	Entity:clear() -- 508
	Platformer.Data:clear() -- 509
	Platformer.UnitAction:clear() -- 510
	Audio:stopStream(0.5) -- 511
	Struct:clear() -- 512
	View.postEffect = nil -- 513
	View.scale = scaleContent and screenScale or 1 -- 514
	Director.clearColor = Color(0xff1a1a1a) -- 515
	teal.clear() -- 516
	yue.clear() -- 517
	for _, item in pairs(ubox()) do -- 518
		local node = tolua.cast(item, "Node") -- 519
		if node then -- 519
			node:cleanup() -- 519
		end -- 519
	end -- 519
	collectgarbage() -- 520
	collectgarbage() -- 521
	setupEventHandlers() -- 522
	Content.searchPaths = searchPaths -- 523
	App.idled = true -- 524
	return Wasm:clear() -- 525
end -- 496
_module_0["allClear"] = allClear -- 525
local clearTempFiles -- 527
clearTempFiles = function() -- 527
	local writablePath = Content.writablePath -- 528
	Content:remove(Path(writablePath, ".upload")) -- 529
	return Content:remove(Path(writablePath, ".download")) -- 530
end -- 527
local waitForWebStart = true -- 532
thread(function() -- 533
	sleep(2) -- 534
	waitForWebStart = false -- 535
end) -- 533
local reloadDevEntry -- 537
reloadDevEntry = function() -- 537
	return thread(function() -- 537
		waitForWebStart = true -- 538
		doClean() -- 539
		allClear() -- 540
		_G.require = oldRequire -- 541
		Dora.require = oldRequire -- 542
		package.loaded["Script.Dev.Entry"] = nil -- 543
		return Director.systemScheduler:schedule(function() -- 544
			Routine:clear() -- 545
			oldRequire("Script.Dev.Entry") -- 546
			return true -- 547
		end) -- 547
	end) -- 547
end -- 537
local setWorkspace -- 549
setWorkspace = function(path) -- 549
	Content.writablePath = path -- 550
	config.writablePath = Content.writablePath -- 551
	return thread(function() -- 552
		sleep() -- 553
		return reloadDevEntry() -- 554
	end) -- 554
end -- 549
local _anon_func_1 = function(App, _with_0) -- 569
	local _val_0 = App.platform -- 569
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 569
end -- 569
setupEventHandlers = function() -- 556
	local _with_0 = Director.postNode -- 557
	_with_0:onAppEvent(function(eventType) -- 558
		if eventType == "Quit" then -- 558
			allClear() -- 559
			return clearTempFiles() -- 560
		end -- 558
	end) -- 558
	_with_0:onAppChange(function(settingName) -- 561
		if "Theme" == settingName then -- 562
			config.themeColor = App.themeColor:toARGB() -- 563
		elseif "Locale" == settingName then -- 564
			config.locale = App.locale -- 565
			updateLocale() -- 566
			return teal.clear(true) -- 567
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 568
			if _anon_func_1(App, _with_0) then -- 569
				if "FullScreen" == settingName then -- 571
					config.fullScreen = App.fullScreen -- 571
				elseif "Position" == settingName then -- 572
					local _obj_0 = App.winPosition -- 572
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 572
				elseif "Size" == settingName then -- 573
					local width, height -- 574
					do -- 574
						local _obj_0 = App.winSize -- 574
						width, height = _obj_0.width, _obj_0.height -- 574
					end -- 574
					config.winWidth = width -- 575
					config.winHeight = height -- 576
				end -- 576
			end -- 569
		end -- 576
	end) -- 561
	_with_0:onAppWS(function(eventType) -- 577
		if eventType == "Close" then -- 577
			if HttpServer.wsConnectionCount == 0 then -- 578
				return updateEntries() -- 579
			end -- 578
		end -- 577
	end) -- 577
	_with_0:slot("UpdateEntries", function() -- 580
		return updateEntries() -- 580
	end) -- 580
	return _with_0 -- 557
end -- 556
setupEventHandlers() -- 582
clearTempFiles() -- 583
local stop -- 585
stop = function() -- 585
	if isInEntry then -- 586
		return false -- 586
	end -- 586
	allClear() -- 587
	isInEntry = true -- 588
	currentEntry = nil -- 589
	return true -- 590
end -- 585
_module_0["stop"] = stop -- 590
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 607
	if workDir == nil then -- 600
		workDir = Path:getPath(file) -- 600
	end -- 600
	Content:insertSearchPath(1, workDir) -- 601
	local scriptPath = Path(workDir, "Script") -- 602
	if Content:exist(scriptPath) then -- 603
		Content:insertSearchPath(1, scriptPath) -- 604
	end -- 603
	local result = require(file) -- 605
	if "function" == type(result) then -- 606
		result() -- 606
	end -- 606
	return nil -- 607
end -- 600
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 639
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 636
	label.alignment = "Left" -- 637
	label.textWidth = width - fontSize -- 638
	label.text = err -- 639
	return label -- 636
end -- 636
local enterEntryAsync -- 592
enterEntryAsync = function(entry) -- 592
	isInEntry = false -- 593
	App.idled = false -- 594
	emit(Profiler.EventName, "ClearLoader") -- 595
	currentEntry = entry -- 596
	local file, workDir = entry[2], entry.workDir -- 597
	sleep() -- 598
	return xpcall(_anon_func_2, function(msg) -- 640
		local err = debug.traceback(msg) -- 609
		Log("Error", err) -- 610
		allClear() -- 611
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 612
		local viewWidth, viewHeight -- 613
		do -- 613
			local _obj_0 = View.size -- 613
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 613
		end -- 613
		local width, height = viewWidth - 20, viewHeight - 20 -- 614
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 615
		Director.ui:addChild((function() -- 616
			local root = AlignNode() -- 616
			do -- 617
				local _obj_0 = App.bufferSize -- 617
				width, height = _obj_0.width, _obj_0.height -- 617
			end -- 617
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 618
			root:onAppChange(function(settingName) -- 619
				if settingName == "Size" then -- 619
					do -- 620
						local _obj_0 = App.bufferSize -- 620
						width, height = _obj_0.width, _obj_0.height -- 620
					end -- 620
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 621
				end -- 619
			end) -- 619
			root:addChild((function() -- 622
				local _with_0 = ScrollArea({ -- 623
					width = width, -- 623
					height = height, -- 624
					paddingX = 0, -- 625
					paddingY = 50, -- 626
					viewWidth = height, -- 627
					viewHeight = height -- 628
				}) -- 622
				root:onAlignLayout(function(w, h) -- 630
					_with_0.position = Vec2(w / 2, h / 2) -- 631
					w = w - 20 -- 632
					h = h - 20 -- 633
					_with_0.view.children.first.textWidth = w - fontSize -- 634
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 635
				end) -- 630
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 636
				return _with_0 -- 622
			end)()) -- 622
			return root -- 616
		end)()) -- 616
		return err -- 640
	end, Content, Path, file, require, type, workDir) -- 640
end -- 592
_module_0["enterEntryAsync"] = enterEntryAsync -- 640
local enterDemoEntry -- 642
enterDemoEntry = function(entry) -- 642
	return thread(function() -- 642
		return enterEntryAsync(entry) -- 642
	end) -- 642
end -- 642
local reloadCurrentEntry -- 644
reloadCurrentEntry = function() -- 644
	if currentEntry then -- 645
		allClear() -- 646
		return enterDemoEntry(currentEntry) -- 647
	end -- 645
end -- 644
Director.clearColor = Color(0xff1a1a1a) -- 649
local isOSSLicenseExist = Content:exist("LICENSES") -- 651
local ossLicenses = nil -- 652
local ossLicenseOpen = false -- 653
local extraOperations -- 655
extraOperations = function() -- 655
	local zh = useChinese and isChineseSupported -- 656
	if isDesktop then -- 657
		local themeColor = App.themeColor -- 658
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 659
		do -- 660
			local changed -- 660
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 660
			if changed then -- 660
				App.alwaysOnTop = alwaysOnTop -- 661
				config.alwaysOnTop = alwaysOnTop -- 662
			end -- 660
		end -- 660
		SeparatorText(zh and "工作目录" or "Workspace") -- 663
		PushTextWrapPos(400, function() -- 664
			return TextColored(themeColor, writablePath) -- 665
		end) -- 664
		if Button(zh and "改变目录" or "Set Folder") then -- 666
			App:openFileDialog(true, function(path) -- 667
				if path ~= "" then -- 668
					return setWorkspace(path) -- 668
				end -- 668
			end) -- 667
		end -- 666
		SameLine() -- 669
		if Button(zh and "使用默认" or "Use Default") then -- 670
			setWorkspace(Content.appPath) -- 671
		end -- 670
		Separator() -- 672
	end -- 657
	if isOSSLicenseExist then -- 673
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 674
			if not ossLicenses then -- 675
				ossLicenses = { } -- 676
				local licenseText = Content:load("LICENSES") -- 677
				ossLicenseOpen = (licenseText ~= nil) -- 678
				if ossLicenseOpen then -- 678
					licenseText = licenseText:gsub("\r\n", "\n") -- 679
					for license in GSplit(licenseText, "\n--------\n", true) do -- 680
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 681
						if name then -- 681
							ossLicenses[#ossLicenses + 1] = { -- 682
								name, -- 682
								text -- 682
							} -- 682
						end -- 681
					end -- 682
				end -- 678
			else -- 684
				ossLicenseOpen = true -- 684
			end -- 675
		end -- 674
		if ossLicenseOpen then -- 685
			local width, height, themeColor -- 686
			do -- 686
				local _obj_0 = App -- 686
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 686
			end -- 686
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 687
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 688
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 689
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 692
					"NoSavedSettings" -- 692
				}, function() -- 693
					for _index_0 = 1, #ossLicenses do -- 693
						local _des_0 = ossLicenses[_index_0] -- 693
						local firstLine, text = _des_0[1], _des_0[2] -- 693
						local name, license = firstLine:match("(.+): (.+)") -- 694
						TextColored(themeColor, name) -- 695
						SameLine() -- 696
						TreeNode(tostring(license) .. "###" .. tostring(name), function() -- 697
							return TextWrapped(text) -- 697
						end) -- 697
					end -- 697
				end) -- 689
			end) -- 689
		end -- 685
	end -- 673
	if not App.debugging then -- 699
		return -- 699
	end -- 699
	return TreeNode(zh and "开发操作" or "Development", function() -- 700
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 701
			OpenPopup("build") -- 701
		end -- 701
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 702
			return BeginPopup("build", function() -- 702
				if Selectable(zh and "编译" or "Compile") then -- 703
					doCompile(false) -- 703
				end -- 703
				Separator() -- 704
				if Selectable(zh and "压缩" or "Minify") then -- 705
					doCompile(true) -- 705
				end -- 705
				Separator() -- 706
				if Selectable(zh and "清理" or "Clean") then -- 707
					return doClean() -- 707
				end -- 707
			end) -- 707
		end) -- 702
		if isInEntry then -- 708
			if waitForWebStart then -- 709
				BeginDisabled(function() -- 710
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 710
				end) -- 710
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 711
				reloadDevEntry() -- 712
			end -- 709
		end -- 708
		do -- 713
			local changed -- 713
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 713
			if changed then -- 713
				View.scale = scaleContent and screenScale or 1 -- 714
			end -- 713
		end -- 713
		do -- 715
			local changed -- 715
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 715
			if changed then -- 715
				config.engineDev = engineDev -- 716
			end -- 715
		end -- 715
		if testingThread then -- 717
			return BeginDisabled(function() -- 718
				return Button(zh and "开始自动测试" or "Test automatically") -- 718
			end) -- 718
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 719
			testingThread = thread(function() -- 720
				local _ <close> = setmetatable({ }, { -- 721
					__close = function() -- 721
						allClear() -- 722
						testingThread = nil -- 723
						isInEntry = true -- 724
						currentEntry = nil -- 725
						return print("Testing done!") -- 726
					end -- 721
				}) -- 721
				for _, entry in ipairs(allEntries) do -- 727
					allClear() -- 728
					print("Start " .. tostring(entry[1])) -- 729
					enterDemoEntry(entry) -- 730
					sleep(2) -- 731
					print("Stop " .. tostring(entry[1])) -- 732
				end -- 732
			end) -- 720
		end -- 717
	end) -- 700
end -- 655
local transparant = Color(0x0) -- 734
local windowFlags = { -- 735
	"NoTitleBar", -- 735
	"NoResize", -- 735
	"NoMove", -- 735
	"NoCollapse", -- 735
	"NoSavedSettings", -- 735
	"NoBringToFrontOnFocus" -- 735
} -- 735
local initFooter = true -- 743
local _anon_func_4 = function(allEntries, currentIndex) -- 779
	if currentIndex > 1 then -- 779
		return allEntries[currentIndex - 1] -- 780
	else -- 782
		return allEntries[#allEntries] -- 782
	end -- 779
end -- 779
local _anon_func_5 = function(allEntries, currentIndex) -- 786
	if currentIndex < #allEntries then -- 786
		return allEntries[currentIndex + 1] -- 787
	else -- 789
		return allEntries[1] -- 789
	end -- 786
end -- 786
footerWindow = threadLoop(function() -- 744
	local zh = useChinese and isChineseSupported -- 745
	if HttpServer.wsConnectionCount > 0 then -- 746
		return -- 747
	end -- 746
	if Keyboard:isKeyDown("Escape") then -- 748
		allClear() -- 749
		App:shutdown() -- 750
	end -- 748
	do -- 751
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 752
		if ctrl and Keyboard:isKeyDown("Q") then -- 753
			stop() -- 754
		end -- 753
		if ctrl and Keyboard:isKeyDown("Z") then -- 755
			reloadCurrentEntry() -- 756
		end -- 755
		if ctrl and Keyboard:isKeyDown(",") then -- 757
			if showFooter then -- 758
				showStats = not showStats -- 758
			else -- 758
				showStats = true -- 758
			end -- 758
			showFooter = true -- 759
			config.showFooter = showFooter -- 760
			config.showStats = showStats -- 761
		end -- 757
		if ctrl and Keyboard:isKeyDown(".") then -- 762
			if showFooter then -- 763
				showConsole = not showConsole -- 763
			else -- 763
				showConsole = true -- 763
			end -- 763
			showFooter = true -- 764
			config.showFooter = showFooter -- 765
			config.showConsole = showConsole -- 766
		end -- 762
		if ctrl and Keyboard:isKeyDown("/") then -- 767
			showFooter = not showFooter -- 768
			config.showFooter = showFooter -- 769
		end -- 767
		local left = ctrl and Keyboard:isKeyDown("Left") -- 770
		local right = ctrl and Keyboard:isKeyDown("Right") -- 771
		local currentIndex = nil -- 772
		for i, entry in ipairs(allEntries) do -- 773
			if currentEntry == entry then -- 774
				currentIndex = i -- 775
			end -- 774
		end -- 775
		if left then -- 776
			allClear() -- 777
			if currentIndex == nil then -- 778
				currentIndex = #allEntries + 1 -- 778
			end -- 778
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 779
		end -- 776
		if right then -- 783
			allClear() -- 784
			if currentIndex == nil then -- 785
				currentIndex = 0 -- 785
			end -- 785
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 786
		end -- 783
	end -- 789
	if not showEntry then -- 790
		return -- 790
	end -- 790
	local width, height -- 792
	do -- 792
		local _obj_0 = App.visualSize -- 792
		width, height = _obj_0.width, _obj_0.height -- 792
	end -- 792
	SetNextWindowSize(Vec2(50, 50)) -- 793
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 794
	PushStyleColor("WindowBg", transparant, function() -- 795
		return Begin("Show", windowFlags, function() -- 795
			if isInEntry or width >= 540 then -- 796
				local changed -- 797
				changed, showFooter = Checkbox("##dev", showFooter) -- 797
				if changed then -- 797
					config.showFooter = showFooter -- 798
				end -- 797
			end -- 796
		end) -- 798
	end) -- 795
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 800
		reloadDevEntry() -- 804
	end -- 800
	if initFooter then -- 805
		initFooter = false -- 806
	else -- 808
		if not showFooter then -- 808
			return -- 808
		end -- 808
	end -- 805
	SetNextWindowSize(Vec2(width, 50)) -- 810
	SetNextWindowPos(Vec2(0, height - 50)) -- 811
	SetNextWindowBgAlpha(0.35) -- 812
	do -- 813
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 814
			return Begin("Footer", windowFlags, function() -- 815
				Dummy(Vec2(width - 20, 0)) -- 816
				do -- 817
					local changed -- 817
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 817
					if changed then -- 817
						config.showStats = showStats -- 818
					end -- 817
				end -- 817
				SameLine() -- 819
				do -- 820
					local changed -- 820
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 820
					if changed then -- 820
						config.showConsole = showConsole -- 821
					end -- 820
				end -- 820
				if config.updateNotification then -- 822
					SameLine() -- 823
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 824
						allClear() -- 825
						config.updateNotification = false -- 826
						enterDemoEntry({ -- 828
							"SelfUpdater", -- 828
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 829
						}) -- 827
					end -- 824
				end -- 822
				if not isInEntry then -- 831
					SameLine() -- 832
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 833
					local currentIndex = nil -- 834
					for i, entry in ipairs(allEntries) do -- 835
						if currentEntry == entry then -- 836
							currentIndex = i -- 837
						end -- 836
					end -- 837
					if currentIndex then -- 838
						if currentIndex > 1 then -- 839
							SameLine() -- 840
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 841
								allClear() -- 842
								enterDemoEntry(allEntries[currentIndex - 1]) -- 843
							end -- 841
						end -- 839
						if currentIndex < #allEntries then -- 844
							SameLine() -- 845
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 846
								allClear() -- 847
								enterDemoEntry(allEntries[currentIndex + 1]) -- 848
							end -- 846
						end -- 844
					end -- 838
					SameLine() -- 849
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 850
						reloadCurrentEntry() -- 851
					end -- 850
					if back then -- 852
						allClear() -- 853
						isInEntry = true -- 854
						currentEntry = nil -- 855
					end -- 852
				end -- 831
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 856
					if showStats then -- 857
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 858
						showStats = ShowStats(showStats, extraOperations) -- 859
						config.showStats = showStats -- 860
					end -- 857
					if showConsole then -- 861
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 862
						showConsole = ShowConsole(showConsole) -- 863
						config.showConsole = showConsole -- 864
					end -- 861
				end) -- 856
			end) -- 815
		end) -- 814
	end -- 864
end) -- 744
local MaxWidth <const> = 960 -- 866
local displayWindowFlags = { -- 868
	"NoDecoration", -- 868
	"NoSavedSettings", -- 868
	"NoFocusOnAppearing", -- 868
	"NoNav", -- 868
	"NoMove", -- 868
	"NoScrollWithMouse", -- 868
	"AlwaysAutoResize", -- 868
	"NoBringToFrontOnFocus" -- 868
} -- 868
local webStatus = nil -- 879
local descColor = Color(0xffa1a1a1) -- 880
local toolOpen = false -- 881
local filterText = nil -- 882
local anyEntryMatched = false -- 883
local urlClicked = nil -- 884
local match -- 885
match = function(name) -- 885
	local res = not filterText or name:lower():match(filterText) -- 886
	if res then -- 887
		anyEntryMatched = true -- 887
	end -- 887
	return res -- 888
end -- 885
local icon = Path("Script", "Dev", "icon_s.png") -- 889
local iconTex = nil -- 890
thread(function() -- 891
	if Cache:loadAsync(icon) then -- 891
		iconTex = Texture2D(icon) -- 891
	end -- 891
end) -- 891
local sep -- 893
sep = function() -- 893
	return SeparatorText("") -- 893
end -- 893
local thinSep -- 894
thinSep = function() -- 894
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 894
end -- 894
entryWindow = threadLoop(function() -- 896
	if App.fpsLimited ~= config.fpsLimited then -- 897
		config.fpsLimited = App.fpsLimited -- 898
	end -- 897
	if App.targetFPS ~= config.targetFPS then -- 899
		config.targetFPS = App.targetFPS -- 900
	end -- 899
	if View.vsync ~= config.vsync then -- 901
		config.vsync = View.vsync -- 902
	end -- 901
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 903
		config.fixedFPS = Director.scheduler.fixedFPS -- 904
	end -- 903
	if Director.profilerSending ~= config.webProfiler then -- 905
		config.webProfiler = Director.profilerSending -- 906
	end -- 905
	if urlClicked then -- 907
		local _, result = coroutine.resume(urlClicked) -- 908
		if result then -- 909
			coroutine.close(urlClicked) -- 910
			urlClicked = nil -- 911
		end -- 909
	end -- 907
	if not showEntry then -- 912
		return -- 912
	end -- 912
	if not isInEntry then -- 913
		return -- 913
	end -- 913
	local zh = useChinese and isChineseSupported -- 914
	if HttpServer.wsConnectionCount > 0 then -- 915
		local themeColor = App.themeColor -- 916
		local width, height -- 917
		do -- 917
			local _obj_0 = App.visualSize -- 917
			width, height = _obj_0.width, _obj_0.height -- 917
		end -- 917
		SetNextWindowBgAlpha(0.5) -- 918
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 919
		Begin("Web IDE Connected", displayWindowFlags, function() -- 920
			Separator() -- 921
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 922
			if iconTex then -- 923
				Image(icon, Vec2(24, 24)) -- 924
				SameLine() -- 925
			end -- 923
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 926
			TextColored(descColor, slogon) -- 927
			return Separator() -- 928
		end) -- 920
		return -- 929
	end -- 915
	local themeColor = App.themeColor -- 931
	local fullWidth, height -- 932
	do -- 932
		local _obj_0 = App.visualSize -- 932
		fullWidth, height = _obj_0.width, _obj_0.height -- 932
	end -- 932
	SetNextWindowBgAlpha(0.85) -- 934
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 935
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 936
		return Begin("Web IDE", displayWindowFlags, function() -- 937
			Separator() -- 938
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 939
			SameLine() -- 940
			TextDisabled('(?)') -- 941
			if IsItemHovered() then -- 942
				BeginTooltip(function() -- 943
					return PushTextWrapPos(280, function() -- 944
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 945
					end) -- 945
				end) -- 943
			end -- 942
			do -- 946
				local url -- 946
				if webStatus ~= nil then -- 946
					url = webStatus.url -- 946
				end -- 946
				if url then -- 946
					if isDesktop and not config.fullScreen then -- 947
						if urlClicked then -- 948
							BeginDisabled(function() -- 949
								return Button(url) -- 949
							end) -- 949
						elseif Button(url) then -- 950
							urlClicked = once(function() -- 951
								return sleep(5) -- 951
							end) -- 951
							App:openURL("http://localhost:8866") -- 952
						end -- 948
					else -- 954
						TextColored(descColor, url) -- 954
					end -- 947
				else -- 956
					TextColored(descColor, zh and '不可用' or 'not available') -- 956
				end -- 946
			end -- 946
			return Separator() -- 957
		end) -- 957
	end) -- 936
	local width = math.min(MaxWidth, fullWidth) -- 959
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 960
	local maxColumns = math.max(math.floor(width / 200), 1) -- 961
	SetNextWindowPos(Vec2.zero) -- 962
	SetNextWindowBgAlpha(0) -- 963
	do -- 964
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 965
			return Begin("Dora Dev", displayWindowFlags, function() -- 966
				Dummy(Vec2(fullWidth - 20, 0)) -- 967
				if iconTex then -- 968
					Image(icon, Vec2(24, 24)) -- 969
					SameLine() -- 970
				end -- 968
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 971
				if fullWidth >= 400 then -- 972
					SameLine() -- 973
					Dummy(Vec2(fullWidth - 400, 0)) -- 974
					SameLine() -- 975
					SetNextItemWidth(zh and -90 or -140) -- 976
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 977
						"AutoSelectAll" -- 977
					}) then -- 977
						config.filter = filterBuf.text -- 978
					end -- 977
					SameLine() -- 979
					if Button(zh and '下载' or 'Download') then -- 980
						allClear() -- 981
						enterDemoEntry({ -- 983
							"ResourceDownloader", -- 983
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 984
						}) -- 982
					end -- 980
				end -- 972
				Separator() -- 986
				return Dummy(Vec2(fullWidth - 20, 0)) -- 987
			end) -- 966
		end) -- 965
	end -- 987
	anyEntryMatched = false -- 989
	SetNextWindowPos(Vec2(0, 50)) -- 990
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 991
	do -- 992
		return PushStyleColor("WindowBg", transparant, function() -- 993
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 994
				return PushStyleVar("Alpha", 1, function() -- 995
					return Begin("Content", windowFlags, function() -- 996
						local DemoViewWidth <const> = 320 -- 997
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 998
						if filterText then -- 999
							filterText = filterText:lower() -- 999
						end -- 999
						if #gamesInDev > 0 then -- 1000
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1001
							Columns(columns, false) -- 1002
							local realViewWidth = GetColumnWidth() - 50 -- 1003
							for _index_0 = 1, #gamesInDev do -- 1004
								local game = gamesInDev[_index_0] -- 1004
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1005
								if match(gameName) then -- 1006
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1007
									SameLine() -- 1008
									TextWrapped(gameName) -- 1009
									if columns > 1 then -- 1010
										if bannerFile then -- 1011
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1012
											local displayWidth <const> = realViewWidth -- 1013
											texHeight = displayWidth * texHeight / texWidth -- 1014
											texWidth = displayWidth -- 1015
											Dummy(Vec2.zero) -- 1016
											SameLine() -- 1017
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1018
										end -- 1011
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1019
											enterDemoEntry(game) -- 1020
										end -- 1019
									else -- 1022
										if bannerFile then -- 1022
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1023
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1024
											local sizing = 0.8 -- 1025
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1026
											texWidth = displayWidth * sizing -- 1027
											if texWidth > 500 then -- 1028
												sizing = 0.6 -- 1029
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1030
												texWidth = displayWidth * sizing -- 1031
											end -- 1028
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1032
											Dummy(Vec2(padding, 0)) -- 1033
											SameLine() -- 1034
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1035
										end -- 1022
										if Button(tostring(zh and "开始运行" or "Game Start") .. "###" .. tostring(fileName), Vec2(-1, 40)) then -- 1036
											enterDemoEntry(game) -- 1037
										end -- 1036
									end -- 1010
									if #tests == 0 and #examples == 0 then -- 1038
										thinSep() -- 1039
									end -- 1038
									NextColumn() -- 1040
								end -- 1006
								local showSep = false -- 1041
								if #examples > 0 then -- 1042
									local showExample = false -- 1043
									do -- 1044
										local _accum_0 -- 1044
										for _index_1 = 1, #examples do -- 1044
											local _des_0 = examples[_index_1] -- 1044
											local name = _des_0[1] -- 1044
											if match(name) then -- 1045
												_accum_0 = true -- 1045
												break -- 1045
											end -- 1045
										end -- 1045
										showExample = _accum_0 -- 1044
									end -- 1045
									if showExample then -- 1046
										showSep = true -- 1047
										Columns(1, false) -- 1048
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1049
										SameLine() -- 1050
										local opened -- 1051
										if (filterText ~= nil) then -- 1051
											opened = showExample -- 1051
										else -- 1051
											opened = false -- 1051
										end -- 1051
										if game.exampleOpen == nil then -- 1052
											game.exampleOpen = opened -- 1052
										end -- 1052
										SetNextItemOpen(game.exampleOpen) -- 1053
										TreeNode(tostring(gameName) .. "###example-" .. tostring(fileName), function() -- 1054
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1055
												Columns(maxColumns, false) -- 1056
												for _index_1 = 1, #examples do -- 1057
													local example = examples[_index_1] -- 1057
													if not match(example[1]) then -- 1058
														goto _continue_0 -- 1058
													end -- 1058
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1059
														if Button(example[1], Vec2(-1, 40)) then -- 1060
															enterDemoEntry(example) -- 1061
														end -- 1060
														return NextColumn() -- 1062
													end) -- 1059
													opened = true -- 1063
													::_continue_0:: -- 1058
												end -- 1063
											end) -- 1055
										end) -- 1054
										game.exampleOpen = opened -- 1064
									end -- 1046
								end -- 1042
								if #tests > 0 then -- 1065
									local showTest = false -- 1066
									do -- 1067
										local _accum_0 -- 1067
										for _index_1 = 1, #tests do -- 1067
											local _des_0 = tests[_index_1] -- 1067
											local name = _des_0[1] -- 1067
											if match(name) then -- 1068
												_accum_0 = true -- 1068
												break -- 1068
											end -- 1068
										end -- 1068
										showTest = _accum_0 -- 1067
									end -- 1068
									if showTest then -- 1069
										showSep = true -- 1070
										Columns(1, false) -- 1071
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1072
										SameLine() -- 1073
										local opened -- 1074
										if (filterText ~= nil) then -- 1074
											opened = showTest -- 1074
										else -- 1074
											opened = false -- 1074
										end -- 1074
										if game.testOpen == nil then -- 1075
											game.testOpen = opened -- 1075
										end -- 1075
										SetNextItemOpen(game.testOpen) -- 1076
										TreeNode(tostring(gameName) .. "###test-" .. tostring(fileName), function() -- 1077
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1078
												Columns(maxColumns, false) -- 1079
												for _index_1 = 1, #tests do -- 1080
													local test = tests[_index_1] -- 1080
													if not match(test[1]) then -- 1081
														goto _continue_0 -- 1081
													end -- 1081
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1082
														if Button(test[1], Vec2(-1, 40)) then -- 1083
															enterDemoEntry(test) -- 1084
														end -- 1083
														return NextColumn() -- 1085
													end) -- 1082
													opened = true -- 1086
													::_continue_0:: -- 1081
												end -- 1086
											end) -- 1078
										end) -- 1077
										game.testOpen = opened -- 1087
									end -- 1069
								end -- 1065
								if showSep then -- 1088
									Columns(1, false) -- 1089
									thinSep() -- 1090
									Columns(columns, false) -- 1091
								end -- 1088
							end -- 1091
						end -- 1000
						if #doraTools > 0 then -- 1092
							local showTool = false -- 1093
							do -- 1094
								local _accum_0 -- 1094
								for _index_0 = 1, #doraTools do -- 1094
									local _des_0 = doraTools[_index_0] -- 1094
									local name = _des_0[1] -- 1094
									if match(name) then -- 1095
										_accum_0 = true -- 1095
										break -- 1095
									end -- 1095
								end -- 1095
								showTool = _accum_0 -- 1094
							end -- 1095
							if not showTool then -- 1096
								goto endEntry -- 1096
							end -- 1096
							Columns(1, false) -- 1097
							TextColored(themeColor, "Dora SSR:") -- 1098
							SameLine() -- 1099
							Text(zh and "开发支持" or "Development Support") -- 1100
							Separator() -- 1101
							if #doraTools > 0 then -- 1102
								local opened -- 1103
								if (filterText ~= nil) then -- 1103
									opened = showTool -- 1103
								else -- 1103
									opened = false -- 1103
								end -- 1103
								SetNextItemOpen(toolOpen) -- 1104
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1105
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1106
										Columns(maxColumns, false) -- 1107
										for _index_0 = 1, #doraTools do -- 1108
											local example = doraTools[_index_0] -- 1108
											if not match(example[1]) then -- 1109
												goto _continue_0 -- 1109
											end -- 1109
											if Button(example[1], Vec2(-1, 40)) then -- 1110
												enterDemoEntry(example) -- 1111
											end -- 1110
											NextColumn() -- 1112
											::_continue_0:: -- 1109
										end -- 1112
										Columns(1, false) -- 1113
										opened = true -- 1114
									end) -- 1106
								end) -- 1105
								toolOpen = opened -- 1115
							end -- 1102
						end -- 1092
						::endEntry:: -- 1116
						if not anyEntryMatched then -- 1117
							SetNextWindowBgAlpha(0) -- 1118
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1119
							Begin("Entries Not Found", displayWindowFlags, function() -- 1120
								Separator() -- 1121
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1122
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1123
								return Separator() -- 1124
							end) -- 1120
						end -- 1117
						Columns(1, false) -- 1125
						Dummy(Vec2(100, 80)) -- 1126
						return ScrollWhenDraggingOnVoid() -- 1127
					end) -- 996
				end) -- 995
			end) -- 994
		end) -- 993
	end -- 1127
end) -- 896
webStatus = require("Script.Dev.WebServer") -- 1129
return _module_0 -- 1129
