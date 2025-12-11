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
local SetDefaultFont = _module_0.SetDefaultFont -- 1
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
local once = Dora.once -- 1
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
local ImageButton = _module_0.ImageButton -- 1
local ImGui = Dora.ImGui -- 1
local SetNextWindowBgAlpha = _module_0.SetNextWindowBgAlpha -- 1
local TextDisabled = _module_0.TextDisabled -- 1
local IsItemHovered = _module_0.IsItemHovered -- 1
local BeginTooltip = _module_0.BeginTooltip -- 1
local Text = _module_0.Text -- 1
local PushStyleColor = _module_0.PushStyleColor -- 1
local ShowStats = _module_0.ShowStats -- 1
local coroutine = _G.coroutine -- 1
local Image = _module_0.Image -- 1
local Dummy = _module_0.Dummy -- 1
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
App.devMode = true -- 15
ShowConsole(true) -- 16
local moduleCache = { } -- 18
local oldRequire = _G.require -- 19
local require -- 20
require = function(path) -- 20
	local loaded = package.loaded[path] -- 21
	if loaded == nil then -- 22
		moduleCache[#moduleCache + 1] = path -- 23
		return oldRequire(path) -- 24
	end -- 22
	return loaded -- 25
end -- 20
_G.require = require -- 26
Dora.require = require -- 27
local searchPaths = Content.searchPaths -- 29
local useChinese = (App.locale:match("^zh") ~= nil) -- 31
local updateLocale -- 32
updateLocale = function() -- 32
	useChinese = (App.locale:match("^zh") ~= nil) -- 33
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 34
	Content.searchPaths = searchPaths -- 35
end -- 32
local isDesktop -- 37
do -- 37
	local _val_0 = App.platform -- 37
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 37
end -- 37
if DB:exist("Config") then -- 39
	do -- 40
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 40
		local _type_0 = type(_exp_0) -- 41
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 41
		if _tab_0 then -- 41
			local locale -- 41
			do -- 41
				local _obj_0 = _exp_0[1] -- 41
				local _type_1 = type(_obj_0) -- 41
				if "table" == _type_1 or "userdata" == _type_1 then -- 41
					locale = _obj_0[1] -- 41
				end -- 41
			end -- 41
			if locale ~= nil then -- 41
				if App.locale ~= locale then -- 41
					App.locale = locale -- 42
					updateLocale() -- 43
				end -- 41
			end -- 41
		end -- 40
	end -- 40
	if isDesktop then -- 44
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 45
		local _type_0 = type(_exp_0) -- 46
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 46
		if _tab_0 then -- 46
			local writablePath -- 46
			do -- 46
				local _obj_0 = _exp_0[1] -- 46
				local _type_1 = type(_obj_0) -- 46
				if "table" == _type_1 or "userdata" == _type_1 then -- 46
					writablePath = _obj_0[1] -- 46
				end -- 46
			end -- 46
			if writablePath ~= nil then -- 46
				Content.writablePath = writablePath -- 47
			end -- 46
		end -- 45
	end -- 44
end -- 39
local Config = require("Config") -- 49
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected") -- 51
config:load() -- 78
if not (config.writablePath ~= nil) then -- 80
	config.writablePath = Content.appPath -- 81
end -- 80
if not (config.webIDEConnected ~= nil) then -- 83
	config.webIDEConnected = false -- 84
end -- 83
if (config.fpsLimited ~= nil) then -- 86
	App.fpsLimited = config.fpsLimited -- 87
else -- 89
	config.fpsLimited = App.fpsLimited -- 89
end -- 86
if (config.targetFPS ~= nil) then -- 91
	App.targetFPS = config.targetFPS -- 92
else -- 94
	config.targetFPS = App.targetFPS -- 94
end -- 91
if (config.vsync ~= nil) then -- 96
	View.vsync = config.vsync -- 97
else -- 99
	config.vsync = View.vsync -- 99
end -- 96
if (config.fixedFPS ~= nil) then -- 101
	Director.scheduler.fixedFPS = config.fixedFPS -- 102
else -- 104
	config.fixedFPS = Director.scheduler.fixedFPS -- 104
end -- 101
local showEntry = true -- 106
isDesktop = false -- 108
if (function() -- 109
	local _val_0 = App.platform -- 109
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 109
end)() then -- 109
	isDesktop = true -- 110
	if config.fullScreen then -- 111
		App.fullScreen = true -- 112
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 113
		local size = Size(config.winWidth, config.winHeight) -- 114
		if App.winSize ~= size then -- 115
			App.winSize = size -- 116
		end -- 115
		local winX, winY -- 117
		do -- 117
			local _obj_0 = App.winPosition -- 117
			winX, winY = _obj_0.x, _obj_0.y -- 117
		end -- 117
		if (config.winX ~= nil) then -- 118
			winX = config.winX -- 119
		else -- 121
			config.winX = -1 -- 121
		end -- 118
		if (config.winY ~= nil) then -- 122
			winY = config.winY -- 123
		else -- 125
			config.winY = -1 -- 125
		end -- 122
		App.winPosition = Vec2(winX, winY) -- 126
	end -- 111
	if (config.alwaysOnTop ~= nil) then -- 127
		App.alwaysOnTop = config.alwaysOnTop -- 128
	else -- 130
		config.alwaysOnTop = true -- 130
	end -- 127
end -- 109
if (config.themeColor ~= nil) then -- 132
	App.themeColor = Color(config.themeColor) -- 133
else -- 135
	config.themeColor = App.themeColor:toARGB() -- 135
end -- 132
if not (config.locale ~= nil) then -- 137
	config.locale = App.locale -- 138
end -- 137
local showStats = false -- 140
if (config.showStats ~= nil) then -- 141
	showStats = config.showStats -- 142
else -- 144
	config.showStats = showStats -- 144
end -- 141
local showConsole = false -- 146
if (config.showConsole ~= nil) then -- 147
	showConsole = config.showConsole -- 148
else -- 150
	config.showConsole = showConsole -- 150
end -- 147
local showFooter = true -- 152
if (config.showFooter ~= nil) then -- 153
	showFooter = config.showFooter -- 154
else -- 156
	config.showFooter = showFooter -- 156
end -- 153
local filterBuf = Buffer(20) -- 158
if (config.filter ~= nil) then -- 159
	filterBuf.text = config.filter -- 160
else -- 162
	config.filter = "" -- 162
end -- 159
local engineDev = false -- 164
if (config.engineDev ~= nil) then -- 165
	engineDev = config.engineDev -- 166
else -- 168
	config.engineDev = engineDev -- 168
end -- 165
if (config.webProfiler ~= nil) then -- 170
	Director.profilerSending = config.webProfiler -- 171
else -- 173
	config.webProfiler = true -- 173
	Director.profilerSending = true -- 174
end -- 170
if not (config.drawerWidth ~= nil) then -- 176
	config.drawerWidth = 200 -- 177
end -- 176
_module_0.getConfig = function() -- 179
	return config -- 179
end -- 179
_module_0.getEngineDev = function() -- 180
	if not App.debugging then -- 181
		return false -- 181
	end -- 181
	return config.engineDev -- 182
end -- 180
local _anon_func_0 = function(App) -- 187
	local _val_0 = App.platform -- 187
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 187
end -- 187
_module_0.connectWebIDE = function() -- 184
	if not config.webIDEConnected then -- 185
		config.webIDEConnected = true -- 186
		if _anon_func_0(App) then -- 187
			local ratio = App.winSize.width / App.visualSize.width -- 188
			App.winSize = Size(640 * ratio, 480 * ratio) -- 189
		end -- 187
	end -- 185
end -- 184
local updateCheck -- 191
updateCheck = function() -- 191
	return thread(function() -- 191
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 192
		if res then -- 192
			local data = json.decode(res) -- 193
			if data then -- 193
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 194
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 195
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 196
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 197
				if na < a then -- 198
					goto not_new_version -- 199
				end -- 198
				if na == a then -- 200
					if nb < b then -- 201
						goto not_new_version -- 202
					end -- 201
					if nb == b then -- 203
						if nc < c then -- 204
							goto not_new_version -- 205
						end -- 204
						if nc == c then -- 206
							goto not_new_version -- 207
						end -- 206
					end -- 203
				end -- 200
				config.updateNotification = true -- 208
				::not_new_version:: -- 209
				config.lastUpdateCheck = os.time() -- 210
			end -- 193
		end -- 192
	end) -- 191
end -- 191
if (config.lastUpdateCheck ~= nil) then -- 212
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 213
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 214
		updateCheck() -- 215
	end -- 214
else -- 217
	updateCheck() -- 217
end -- 212
local Set, Struct, LintYueGlobals, GSplit -- 219
do -- 219
	local _obj_0 = require("Utils") -- 219
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 219
end -- 219
local yueext = yue.options.extension -- 220
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 222
local building = false -- 224
local getAllFiles -- 226
getAllFiles = function(path, exts, recursive) -- 226
	if recursive == nil then -- 226
		recursive = true -- 226
	end -- 226
	local filters = Set(exts) -- 227
	local files -- 228
	if recursive then -- 228
		files = Content:getAllFiles(path) -- 229
	else -- 231
		files = Content:getFiles(path) -- 231
	end -- 228
	local _accum_0 = { } -- 232
	local _len_0 = 1 -- 232
	for _index_0 = 1, #files do -- 232
		local file = files[_index_0] -- 232
		if not filters[Path:getExt(file)] then -- 233
			goto _continue_0 -- 233
		end -- 233
		_accum_0[_len_0] = file -- 234
		_len_0 = _len_0 + 1 -- 233
		::_continue_0:: -- 233
	end -- 232
	return _accum_0 -- 232
end -- 226
_module_0["getAllFiles"] = getAllFiles -- 226
local getFileEntries -- 236
getFileEntries = function(path, recursive, excludeFiles) -- 236
	if recursive == nil then -- 236
		recursive = true -- 236
	end -- 236
	if excludeFiles == nil then -- 236
		excludeFiles = nil -- 236
	end -- 236
	local entries = { } -- 237
	local excludes -- 238
	if excludeFiles then -- 238
		excludes = Set(excludeFiles) -- 239
	end -- 238
	local _list_0 = getAllFiles(path, { -- 240
		"lua", -- 240
		"xml", -- 240
		yueext, -- 240
		"tl" -- 240
	}, recursive) -- 240
	for _index_0 = 1, #_list_0 do -- 240
		local file = _list_0[_index_0] -- 240
		local entryName = Path:getName(file) -- 241
		if excludes and excludes[entryName] then -- 242
			goto _continue_0 -- 243
		end -- 242
		local fileName = Path:replaceExt(file, "") -- 244
		fileName = Path(path, fileName) -- 245
		local entryAdded -- 246
		do -- 246
			local _accum_0 -- 246
			for _index_1 = 1, #entries do -- 246
				local _des_0 = entries[_index_1] -- 246
				local ename, efile = _des_0.entryName, _des_0.fileName -- 246
				if entryName == ename and efile == fileName then -- 247
					_accum_0 = true -- 247
					break -- 247
				end -- 247
			end -- 246
			entryAdded = _accum_0 -- 246
		end -- 246
		if entryAdded then -- 248
			goto _continue_0 -- 248
		end -- 248
		local entry = { -- 249
			entryName = entryName, -- 249
			fileName = fileName -- 249
		} -- 249
		entries[#entries + 1] = entry -- 250
		::_continue_0:: -- 241
	end -- 240
	table.sort(entries, function(a, b) -- 251
		return a.entryName < b.entryName -- 251
	end) -- 251
	return entries -- 252
end -- 236
local getProjectEntries -- 254
getProjectEntries = function(path) -- 254
	local entries = { } -- 255
	local _list_0 = Content:getDirs(path) -- 256
	for _index_0 = 1, #_list_0 do -- 256
		local dir = _list_0[_index_0] -- 256
		if dir:match("^%.") then -- 257
			goto _continue_0 -- 257
		end -- 257
		local _list_1 = getAllFiles(Path(path, dir), { -- 258
			"lua", -- 258
			"xml", -- 258
			yueext, -- 258
			"tl", -- 258
			"wasm" -- 258
		}) -- 258
		for _index_1 = 1, #_list_1 do -- 258
			local file = _list_1[_index_1] -- 258
			if "init" == Path:getName(file):lower() then -- 259
				local fileName = Path:replaceExt(file, "") -- 260
				fileName = Path(path, dir, fileName) -- 261
				local projectPath = Path:getPath(fileName) -- 262
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 263
				local repo = nil -- 264
				if Content:exist(repoFile) then -- 265
					local str = Content:load(repoFile) -- 266
					if str then -- 266
						repo = json.decode(str) -- 267
					end -- 266
				end -- 265
				local entryName = Path:getName(projectPath) -- 268
				local entryAdded -- 269
				do -- 269
					local _accum_0 -- 269
					for _index_2 = 1, #entries do -- 269
						local _des_0 = entries[_index_2] -- 269
						local ename, efile = _des_0.entryName, _des_0.fileName -- 269
						if entryName == ename and efile == fileName then -- 270
							_accum_0 = true -- 270
							break -- 270
						end -- 270
					end -- 269
					entryAdded = _accum_0 -- 269
				end -- 269
				if entryAdded then -- 271
					goto _continue_1 -- 271
				end -- 271
				local examples = { } -- 272
				local tests = { } -- 273
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 274
				if Content:exist(examplePath) then -- 275
					local _list_2 = getFileEntries(examplePath) -- 276
					for _index_2 = 1, #_list_2 do -- 276
						local _des_0 = _list_2[_index_2] -- 276
						local name, ePath = _des_0.entryName, _des_0.fileName -- 276
						local entry = { -- 278
							entryName = name, -- 278
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 279
							workDir = projectPath -- 280
						} -- 277
						examples[#examples + 1] = entry -- 282
					end -- 276
				end -- 275
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 283
				if Content:exist(testPath) then -- 284
					local _list_2 = getFileEntries(testPath) -- 285
					for _index_2 = 1, #_list_2 do -- 285
						local _des_0 = _list_2[_index_2] -- 285
						local name, tPath = _des_0.entryName, _des_0.fileName -- 285
						local entry = { -- 287
							entryName = name, -- 287
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 288
							workDir = projectPath -- 289
						} -- 286
						tests[#tests + 1] = entry -- 291
					end -- 285
				end -- 284
				local entry = { -- 292
					entryName = entryName, -- 292
					fileName = fileName, -- 292
					examples = examples, -- 292
					tests = tests, -- 292
					repo = repo -- 292
				} -- 292
				local bannerFile -- 293
				do -- 293
					local _accum_0 -- 293
					repeat -- 293
						local f = Path(projectPath, ".dora", "banner.jpg") -- 294
						if Content:exist(f) then -- 295
							_accum_0 = f -- 295
							break -- 295
						end -- 295
						f = Path(projectPath, ".dora", "banner.png") -- 296
						if Content:exist(f) then -- 297
							_accum_0 = f -- 297
							break -- 297
						end -- 297
						f = Path(projectPath, "Image", "banner.jpg") -- 298
						if Content:exist(f) then -- 299
							_accum_0 = f -- 299
							break -- 299
						end -- 299
						f = Path(projectPath, "Image", "banner.png") -- 300
						if Content:exist(f) then -- 301
							_accum_0 = f -- 301
							break -- 301
						end -- 301
					until true -- 293
					bannerFile = _accum_0 -- 293
				end -- 293
				if bannerFile then -- 303
					thread(function() -- 303
						if Cache:loadAsync(bannerFile) then -- 304
							local bannerTex = Texture2D(bannerFile) -- 305
							if bannerTex then -- 305
								entry.bannerFile = bannerFile -- 306
								entry.bannerTex = bannerTex -- 307
							end -- 305
						end -- 304
					end) -- 303
				end -- 303
				entries[#entries + 1] = entry -- 308
			end -- 259
			::_continue_1:: -- 259
		end -- 258
		::_continue_0:: -- 257
	end -- 256
	table.sort(entries, function(a, b) -- 309
		return a.entryName < b.entryName -- 309
	end) -- 309
	return entries -- 310
end -- 254
local defaultBannerFile -- 312
local defaultBannerTex -- 313
thread(function() -- 314
	local bannerFile = Path(Content.assetPath, "Image", "banner.jpg") -- 315
	if not Content:exist(bannerFile) then -- 316
		return -- 316
	end -- 316
	if Cache:loadAsync(bannerFile) then -- 317
		defaultBannerTex = Texture2D(bannerFile) -- 318
		if defaultBannerTex then -- 318
			defaultBannerFile = bannerFile -- 319
		end -- 318
	end -- 317
end) -- 314
local gamesInDev -- 321
local doraTools -- 322
local allEntries -- 323
local updateEntries -- 325
updateEntries = function() -- 325
	gamesInDev = getProjectEntries(Content.writablePath) -- 326
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 327
	allEntries = { } -- 329
	for _index_0 = 1, #gamesInDev do -- 330
		local game = gamesInDev[_index_0] -- 330
		allEntries[#allEntries + 1] = game -- 331
		local examples, tests = game.examples, game.tests -- 332
		for _index_1 = 1, #examples do -- 333
			local example = examples[_index_1] -- 333
			allEntries[#allEntries + 1] = example -- 334
		end -- 333
		for _index_1 = 1, #tests do -- 335
			local test = tests[_index_1] -- 335
			allEntries[#allEntries + 1] = test -- 336
		end -- 335
	end -- 330
end -- 325
updateEntries() -- 338
local doCompile -- 340
doCompile = function(minify) -- 340
	if building then -- 341
		return -- 341
	end -- 341
	building = true -- 342
	local startTime = App.runningTime -- 343
	local luaFiles = { } -- 344
	local yueFiles = { } -- 345
	local xmlFiles = { } -- 346
	local tlFiles = { } -- 347
	local writablePath = Content.writablePath -- 348
	local buildPaths = { -- 350
		{ -- 351
			Content.assetPath, -- 351
			Path(writablePath, ".build"), -- 352
			"" -- 353
		} -- 350
	} -- 349
	for _index_0 = 1, #gamesInDev do -- 356
		local _des_0 = gamesInDev[_index_0] -- 356
		local entryFile = _des_0.entryFile -- 356
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 357
		buildPaths[#buildPaths + 1] = { -- 359
			Path(writablePath, gamePath), -- 359
			Path(writablePath, ".build", gamePath), -- 360
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 361
			gamePath -- 362
		} -- 358
	end -- 356
	for _index_0 = 1, #buildPaths do -- 363
		local _des_0 = buildPaths[_index_0] -- 363
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 363
		if not Content:exist(inputPath) then -- 364
			goto _continue_0 -- 364
		end -- 364
		local _list_0 = getAllFiles(inputPath, { -- 366
			"lua" -- 366
		}) -- 366
		for _index_1 = 1, #_list_0 do -- 366
			local file = _list_0[_index_1] -- 366
			luaFiles[#luaFiles + 1] = { -- 368
				file, -- 368
				Path(inputPath, file), -- 369
				Path(outputPath, file), -- 370
				gamePath -- 371
			} -- 367
		end -- 366
		local _list_1 = getAllFiles(inputPath, { -- 373
			yueext -- 373
		}) -- 373
		for _index_1 = 1, #_list_1 do -- 373
			local file = _list_1[_index_1] -- 373
			yueFiles[#yueFiles + 1] = { -- 375
				file, -- 375
				Path(inputPath, file), -- 376
				Path(outputPath, Path:replaceExt(file, "lua")), -- 377
				searchPath, -- 378
				gamePath -- 379
			} -- 374
		end -- 373
		local _list_2 = getAllFiles(inputPath, { -- 381
			"xml" -- 381
		}) -- 381
		for _index_1 = 1, #_list_2 do -- 381
			local file = _list_2[_index_1] -- 381
			xmlFiles[#xmlFiles + 1] = { -- 383
				file, -- 383
				Path(inputPath, file), -- 384
				Path(outputPath, Path:replaceExt(file, "lua")), -- 385
				gamePath -- 386
			} -- 382
		end -- 381
		local _list_3 = getAllFiles(inputPath, { -- 388
			"tl" -- 388
		}) -- 388
		for _index_1 = 1, #_list_3 do -- 388
			local file = _list_3[_index_1] -- 388
			if not file:match(".*%.d%.tl$") then -- 389
				tlFiles[#tlFiles + 1] = { -- 391
					file, -- 391
					Path(inputPath, file), -- 392
					Path(outputPath, Path:replaceExt(file, "lua")), -- 393
					searchPath, -- 394
					gamePath -- 395
				} -- 390
			end -- 389
		end -- 388
		::_continue_0:: -- 364
	end -- 363
	local paths -- 397
	do -- 397
		local _tbl_0 = { } -- 397
		local _list_0 = { -- 398
			luaFiles, -- 398
			yueFiles, -- 398
			xmlFiles, -- 398
			tlFiles -- 398
		} -- 398
		for _index_0 = 1, #_list_0 do -- 398
			local files = _list_0[_index_0] -- 398
			for _index_1 = 1, #files do -- 399
				local file = files[_index_1] -- 399
				_tbl_0[Path:getPath(file[3])] = true -- 397
			end -- 397
		end -- 397
		paths = _tbl_0 -- 397
	end -- 397
	for path in pairs(paths) do -- 401
		Content:mkdir(path) -- 401
	end -- 401
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 403
	local fileCount = 0 -- 404
	local errors = { } -- 405
	for _index_0 = 1, #yueFiles do -- 406
		local _des_0 = yueFiles[_index_0] -- 406
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 406
		local filename -- 407
		if gamePath then -- 407
			filename = Path(gamePath, file) -- 407
		else -- 407
			filename = file -- 407
		end -- 407
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 408
			if not codes then -- 409
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 410
				return -- 411
			end -- 409
			local success, result = LintYueGlobals(codes, globals) -- 412
			if success then -- 413
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 414
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 415
				codes = codes:gsub("^\n*", "") -- 416
				if not (result == "") then -- 417
					result = result .. "\n" -- 417
				end -- 417
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 418
			else -- 420
				local yueCodes = Content:load(input) -- 420
				if yueCodes then -- 420
					local globalErrors = { } -- 421
					for _index_1 = 1, #result do -- 422
						local _des_1 = result[_index_1] -- 422
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 422
						local countLine = 1 -- 423
						local code = "" -- 424
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 425
							if countLine == line then -- 426
								code = lineCode -- 427
								break -- 428
							end -- 426
							countLine = countLine + 1 -- 429
						end -- 425
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 430
					end -- 422
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 431
				else -- 433
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 433
				end -- 420
			end -- 413
		end, function(success) -- 408
			if success then -- 434
				print("Yue compiled: " .. tostring(filename)) -- 434
			end -- 434
			fileCount = fileCount + 1 -- 435
		end) -- 408
	end -- 406
	thread(function() -- 437
		for _index_0 = 1, #xmlFiles do -- 438
			local _des_0 = xmlFiles[_index_0] -- 438
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 438
			local filename -- 439
			if gamePath then -- 439
				filename = Path(gamePath, file) -- 439
			else -- 439
				filename = file -- 439
			end -- 439
			local sourceCodes = Content:loadAsync(input) -- 440
			local codes, err = xml.tolua(sourceCodes) -- 441
			if not codes then -- 442
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 443
			else -- 445
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 445
				print("Xml compiled: " .. tostring(filename)) -- 446
			end -- 442
			fileCount = fileCount + 1 -- 447
		end -- 438
	end) -- 437
	thread(function() -- 449
		for _index_0 = 1, #tlFiles do -- 450
			local _des_0 = tlFiles[_index_0] -- 450
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 450
			local filename -- 451
			if gamePath then -- 451
				filename = Path(gamePath, file) -- 451
			else -- 451
				filename = file -- 451
			end -- 451
			local sourceCodes = Content:loadAsync(input) -- 452
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 453
			if not codes then -- 454
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 455
			else -- 457
				Content:saveAsync(output, codes) -- 457
				print("Teal compiled: " .. tostring(filename)) -- 458
			end -- 454
			fileCount = fileCount + 1 -- 459
		end -- 450
	end) -- 449
	return thread(function() -- 461
		wait(function() -- 462
			return fileCount == totalFiles -- 462
		end) -- 462
		if minify then -- 463
			local _list_0 = { -- 464
				yueFiles, -- 464
				xmlFiles, -- 464
				tlFiles -- 464
			} -- 464
			for _index_0 = 1, #_list_0 do -- 464
				local files = _list_0[_index_0] -- 464
				for _index_1 = 1, #files do -- 464
					local file = files[_index_1] -- 464
					local output = Path:replaceExt(file[3], "lua") -- 465
					luaFiles[#luaFiles + 1] = { -- 467
						Path:replaceExt(file[1], "lua"), -- 467
						output, -- 468
						output -- 469
					} -- 466
				end -- 464
			end -- 464
			local FormatMini -- 471
			do -- 471
				local _obj_0 = require("luaminify") -- 471
				FormatMini = _obj_0.FormatMini -- 471
			end -- 471
			for _index_0 = 1, #luaFiles do -- 472
				local _des_0 = luaFiles[_index_0] -- 472
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 472
				if Content:exist(input) then -- 473
					local sourceCodes = Content:loadAsync(input) -- 474
					local res, err = FormatMini(sourceCodes) -- 475
					if res then -- 476
						Content:saveAsync(output, res) -- 477
						print("Minify: " .. tostring(file)) -- 478
					else -- 480
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 480
					end -- 476
				else -- 482
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 482
				end -- 473
			end -- 472
			package.loaded["luaminify.FormatMini"] = nil -- 483
			package.loaded["luaminify.ParseLua"] = nil -- 484
			package.loaded["luaminify.Scope"] = nil -- 485
			package.loaded["luaminify.Util"] = nil -- 486
		end -- 463
		local errorMessage = table.concat(errors, "\n") -- 487
		if errorMessage ~= "" then -- 488
			print(errorMessage) -- 488
		end -- 488
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 489
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 490
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 491
		Content:clearPathCache() -- 492
		teal.clear() -- 493
		yue.clear() -- 494
		building = false -- 495
	end) -- 461
end -- 340
local doClean -- 497
doClean = function() -- 497
	if building then -- 498
		return -- 498
	end -- 498
	local writablePath = Content.writablePath -- 499
	local targetDir = Path(writablePath, ".build") -- 500
	Content:clearPathCache() -- 501
	if Content:remove(targetDir) then -- 502
		return print("Cleaned: " .. tostring(targetDir)) -- 503
	end -- 502
end -- 497
local screenScale = 2.0 -- 505
local scaleContent = false -- 506
local isInEntry = true -- 507
local currentEntry = nil -- 508
local footerWindow = nil -- 510
local entryWindow = nil -- 511
local testingThread = nil -- 512
local setupEventHandlers = nil -- 514
local allClear -- 516
allClear = function() -- 516
	local _list_0 = Routine -- 517
	for _index_0 = 1, #_list_0 do -- 517
		local routine = _list_0[_index_0] -- 517
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 519
			goto _continue_0 -- 520
		else -- 522
			Routine:remove(routine) -- 522
		end -- 518
		::_continue_0:: -- 518
	end -- 517
	for _index_0 = 1, #moduleCache do -- 523
		local module = moduleCache[_index_0] -- 523
		package.loaded[module] = nil -- 524
	end -- 523
	moduleCache = { } -- 525
	Director:cleanup() -- 526
	Entity:clear() -- 527
	Platformer.Data:clear() -- 528
	Platformer.UnitAction:clear() -- 529
	Audio:stopAll(0.2) -- 530
	Struct:clear() -- 531
	View.postEffect = nil -- 532
	View.scale = scaleContent and screenScale or 1 -- 533
	Director.clearColor = Color(0xff1a1a1a) -- 534
	teal.clear() -- 535
	yue.clear() -- 536
	for _, item in pairs(ubox()) do -- 537
		local node = tolua.cast(item, "Node") -- 538
		if node then -- 538
			node:cleanup() -- 538
		end -- 538
	end -- 537
	collectgarbage() -- 539
	collectgarbage() -- 540
	Wasm:clear() -- 541
	thread(function() -- 542
		sleep() -- 543
		return Cache:removeUnused() -- 544
	end) -- 542
	setupEventHandlers() -- 545
	Content.searchPaths = searchPaths -- 546
	App.idled = true -- 547
end -- 516
_module_0["allClear"] = allClear -- 516
local clearTempFiles -- 549
clearTempFiles = function() -- 549
	local writablePath = Content.writablePath -- 550
	Content:remove(Path(writablePath, ".upload")) -- 551
	return Content:remove(Path(writablePath, ".download")) -- 552
end -- 549
local waitForWebStart = true -- 554
thread(function() -- 555
	sleep(2) -- 556
	waitForWebStart = false -- 557
end) -- 555
local reloadDevEntry -- 559
reloadDevEntry = function() -- 559
	return thread(function() -- 559
		waitForWebStart = true -- 560
		doClean() -- 561
		allClear() -- 562
		_G.require = oldRequire -- 563
		Dora.require = oldRequire -- 564
		package.loaded["Script.Dev.Entry"] = nil -- 565
		return Director.systemScheduler:schedule(function() -- 566
			Routine:clear() -- 567
			oldRequire("Script.Dev.Entry") -- 568
			return true -- 569
		end) -- 566
	end) -- 559
end -- 559
local setWorkspace -- 571
setWorkspace = function(path) -- 571
	Content.writablePath = path -- 572
	config.writablePath = Content.writablePath -- 573
	return thread(function() -- 574
		sleep() -- 575
		return reloadDevEntry() -- 576
	end) -- 574
end -- 571
local quit = false -- 578
local stop -- 580
stop = function() -- 580
	if isInEntry then -- 581
		return false -- 581
	end -- 581
	allClear() -- 582
	isInEntry = true -- 583
	currentEntry = nil -- 584
	return true -- 585
end -- 580
_module_0["stop"] = stop -- 580
local _anon_func_1 = function(App, _with_0) -- 604
	local _val_0 = App.platform -- 604
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 604
end -- 604
setupEventHandlers = function() -- 587
	local _with_0 = Director.postNode -- 588
	_with_0:onAppEvent(function(eventType) -- 589
		if "Quit" == eventType then -- 590
			quit = true -- 591
			allClear() -- 592
			return clearTempFiles() -- 593
		elseif "Shutdown" == eventType then -- 594
			return stop() -- 595
		end -- 589
	end) -- 589
	_with_0:onAppChange(function(settingName) -- 596
		if "Theme" == settingName then -- 597
			config.themeColor = App.themeColor:toARGB() -- 598
		elseif "Locale" == settingName then -- 599
			config.locale = App.locale -- 600
			updateLocale() -- 601
			return teal.clear(true) -- 602
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 603
			if _anon_func_1(App, _with_0) then -- 604
				if "FullScreen" == settingName then -- 606
					config.fullScreen = App.fullScreen -- 606
				elseif "Position" == settingName then -- 607
					local _obj_0 = App.winPosition -- 607
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 607
				elseif "Size" == settingName then -- 608
					local width, height -- 609
					do -- 609
						local _obj_0 = App.winSize -- 609
						width, height = _obj_0.width, _obj_0.height -- 609
					end -- 609
					config.winWidth = width -- 610
					config.winHeight = height -- 611
				end -- 605
			end -- 604
		end -- 596
	end) -- 596
	_with_0:onAppWS(function(eventType) -- 612
		if eventType == "Close" then -- 612
			if HttpServer.wsConnectionCount == 0 then -- 613
				return updateEntries() -- 614
			end -- 613
		end -- 612
	end) -- 612
	_with_0:slot("UpdateEntries", function() -- 615
		return updateEntries() -- 615
	end) -- 615
	return _with_0 -- 588
end -- 587
setupEventHandlers() -- 617
clearTempFiles() -- 618
local downloadFile -- 620
downloadFile = function(url, target) -- 620
	return Director.systemScheduler:schedule(once(function() -- 620
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 621
			if quit then -- 622
				return true -- 622
			end -- 622
			emit("AppWS", "Send", json.encode({ -- 624
				name = "Download", -- 624
				url = url, -- 624
				status = "downloading", -- 624
				progress = current / total -- 625
			})) -- 623
			return false -- 621
		end) -- 621
		return emit("AppWS", "Send", json.encode(success and { -- 628
			name = "Download", -- 628
			url = url, -- 628
			status = "completed", -- 628
			progress = 1.0 -- 629
		} or { -- 631
			name = "Download", -- 631
			url = url, -- 631
			status = "failed", -- 631
			progress = 0.0 -- 632
		})) -- 627
	end)) -- 620
end -- 620
_module_0["downloadFile"] = downloadFile -- 620
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 643
	if workDir == nil then -- 643
		workDir = Path:getPath(file) -- 643
	end -- 643
	Content:insertSearchPath(1, workDir) -- 644
	local scriptPath = Path(workDir, "Script") -- 645
	if Content:exist(scriptPath) then -- 646
		Content:insertSearchPath(1, scriptPath) -- 647
	end -- 646
	local result = require(file) -- 648
	if "function" == type(result) then -- 649
		result() -- 649
	end -- 649
	return nil -- 650
end -- 643
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 679
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 679
	label.alignment = "Left" -- 680
	label.textWidth = width - fontSize -- 681
	label.text = err -- 682
	return label -- 679
end -- 679
local enterEntryAsync -- 635
enterEntryAsync = function(entry) -- 635
	isInEntry = false -- 636
	App.idled = false -- 637
	emit(Profiler.EventName, "ClearLoader") -- 638
	currentEntry = entry -- 639
	local file, workDir = entry.fileName, entry.workDir -- 640
	sleep() -- 641
	return xpcall(_anon_func_2, function(msg) -- 650
		local err = debug.traceback(msg) -- 652
		Log("Error", err) -- 653
		allClear() -- 654
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 655
		local viewWidth, viewHeight -- 656
		do -- 656
			local _obj_0 = View.size -- 656
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 656
		end -- 656
		local width, height = viewWidth - 20, viewHeight - 20 -- 657
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 658
		Director.ui:addChild((function() -- 659
			local root = AlignNode() -- 659
			do -- 660
				local _obj_0 = App.bufferSize -- 660
				width, height = _obj_0.width, _obj_0.height -- 660
			end -- 660
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 661
			root:onAppChange(function(settingName) -- 662
				if settingName == "Size" then -- 662
					do -- 663
						local _obj_0 = App.bufferSize -- 663
						width, height = _obj_0.width, _obj_0.height -- 663
					end -- 663
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 664
				end -- 662
			end) -- 662
			root:addChild((function() -- 665
				local _with_0 = ScrollArea({ -- 666
					width = width, -- 666
					height = height, -- 667
					paddingX = 0, -- 668
					paddingY = 50, -- 669
					viewWidth = height, -- 670
					viewHeight = height -- 671
				}) -- 665
				root:onAlignLayout(function(w, h) -- 673
					_with_0.position = Vec2(w / 2, h / 2) -- 674
					w = w - 20 -- 675
					h = h - 20 -- 676
					_with_0.view.children.first.textWidth = w - fontSize -- 677
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 678
				end) -- 673
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 679
				return _with_0 -- 665
			end)()) -- 665
			return root -- 659
		end)()) -- 659
		return err -- 683
	end, Content, Path, file, require, type, workDir) -- 642
end -- 635
_module_0["enterEntryAsync"] = enterEntryAsync -- 635
local enterDemoEntry -- 685
enterDemoEntry = function(entry) -- 685
	return thread(function() -- 685
		return enterEntryAsync(entry) -- 685
	end) -- 685
end -- 685
local reloadCurrentEntry -- 687
reloadCurrentEntry = function() -- 687
	if currentEntry then -- 688
		allClear() -- 689
		return enterDemoEntry(currentEntry) -- 690
	end -- 688
end -- 687
Director.clearColor = Color(0xff1a1a1a) -- 692
local isOSSLicenseExist = Content:exist("LICENSES") -- 694
local ossLicenses = nil -- 695
local ossLicenseOpen = false -- 696
local extraOperations -- 698
extraOperations = function() -- 698
	local zh = useChinese -- 699
	if isDesktop then -- 700
		local themeColor = App.themeColor -- 701
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 702
		do -- 703
			local changed -- 703
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 703
			if changed then -- 703
				App.alwaysOnTop = alwaysOnTop -- 704
				config.alwaysOnTop = alwaysOnTop -- 705
			end -- 703
		end -- 703
		SeparatorText(zh and "工作目录" or "Workspace") -- 706
		PushTextWrapPos(400, function() -- 707
			return TextColored(themeColor, writablePath) -- 708
		end) -- 707
		if Button(zh and "改变目录" or "Set Folder") then -- 709
			App:openFileDialog(true, function(path) -- 710
				if path ~= "" then -- 711
					return setWorkspace(path) -- 711
				end -- 711
			end) -- 710
		end -- 709
		SameLine() -- 712
		if Button(zh and "使用默认" or "Use Default") then -- 713
			setWorkspace(Content.appPath) -- 714
		end -- 713
		Separator() -- 715
	end -- 700
	if isOSSLicenseExist then -- 716
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 717
			if not ossLicenses then -- 718
				ossLicenses = { } -- 719
				local licenseText = Content:load("LICENSES") -- 720
				ossLicenseOpen = (licenseText ~= nil) -- 721
				if ossLicenseOpen then -- 721
					licenseText = licenseText:gsub("\r\n", "\n") -- 722
					for license in GSplit(licenseText, "\n--------\n", true) do -- 723
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 724
						if name then -- 724
							ossLicenses[#ossLicenses + 1] = { -- 725
								name, -- 725
								text -- 725
							} -- 725
						end -- 724
					end -- 723
				end -- 721
			else -- 727
				ossLicenseOpen = true -- 727
			end -- 718
		end -- 717
		if ossLicenseOpen then -- 728
			local width, height, themeColor -- 729
			do -- 729
				local _obj_0 = App -- 729
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 729
			end -- 729
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 730
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 731
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 732
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 735
					"NoSavedSettings" -- 735
				}, function() -- 736
					for _index_0 = 1, #ossLicenses do -- 736
						local _des_0 = ossLicenses[_index_0] -- 736
						local firstLine, text = _des_0[1], _des_0[2] -- 736
						local name, license = firstLine:match("(.+): (.+)") -- 737
						TextColored(themeColor, name) -- 738
						SameLine() -- 739
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 740
							return TextWrapped(text) -- 740
						end) -- 740
					end -- 736
				end) -- 732
			end) -- 732
		end -- 728
	end -- 716
	if not App.debugging then -- 742
		return -- 742
	end -- 742
	return TreeNode(zh and "开发操作" or "Development", function() -- 743
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 744
			OpenPopup("build") -- 744
		end -- 744
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 745
			return BeginPopup("build", function() -- 745
				if Selectable(zh and "编译" or "Compile") then -- 746
					doCompile(false) -- 746
				end -- 746
				Separator() -- 747
				if Selectable(zh and "压缩" or "Minify") then -- 748
					doCompile(true) -- 748
				end -- 748
				Separator() -- 749
				if Selectable(zh and "清理" or "Clean") then -- 750
					return doClean() -- 750
				end -- 750
			end) -- 745
		end) -- 745
		if isInEntry then -- 751
			if waitForWebStart then -- 752
				BeginDisabled(function() -- 753
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 753
				end) -- 753
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 754
				reloadDevEntry() -- 755
			end -- 752
		end -- 751
		do -- 756
			local changed -- 756
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 756
			if changed then -- 756
				View.scale = scaleContent and screenScale or 1 -- 757
			end -- 756
		end -- 756
		do -- 758
			local changed -- 758
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 758
			if changed then -- 758
				config.engineDev = engineDev -- 759
			end -- 758
		end -- 758
		if testingThread then -- 760
			return BeginDisabled(function() -- 761
				return Button(zh and "开始自动测试" or "Test automatically") -- 761
			end) -- 761
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 762
			testingThread = thread(function() -- 763
				local _ <close> = setmetatable({ }, { -- 764
					__close = function() -- 764
						allClear() -- 765
						testingThread = nil -- 766
						isInEntry = true -- 767
						currentEntry = nil -- 768
						return print("Testing done!") -- 769
					end -- 764
				}) -- 764
				for _, entry in ipairs(allEntries) do -- 770
					allClear() -- 771
					print("Start " .. tostring(entry.entryName)) -- 772
					enterDemoEntry(entry) -- 773
					sleep(2) -- 774
					print("Stop " .. tostring(entry.entryName)) -- 775
				end -- 770
			end) -- 763
		end -- 760
	end) -- 743
end -- 698
local icon = Path("Script", "Dev", "icon_s.png") -- 777
local iconTex = nil -- 778
thread(function() -- 779
	if Cache:loadAsync(icon) then -- 779
		iconTex = Texture2D(icon) -- 779
	end -- 779
end) -- 779
local webStatus = nil -- 781
local urlClicked = nil -- 782
local descColor = Color(0xffa1a1a1) -- 783
local transparant = Color(0x0) -- 785
local windowFlags = { -- 786
	"NoTitleBar", -- 786
	"NoResize", -- 786
	"NoMove", -- 786
	"NoCollapse", -- 786
	"NoSavedSettings", -- 786
	"NoFocusOnAppearing", -- 786
	"NoBringToFrontOnFocus" -- 786
} -- 786
local statusFlags = { -- 795
	"NoTitleBar", -- 795
	"NoResize", -- 795
	"NoMove", -- 795
	"NoCollapse", -- 795
	"AlwaysAutoResize", -- 795
	"NoSavedSettings" -- 795
} -- 795
local displayWindowFlags = { -- 803
	"NoDecoration", -- 803
	"NoSavedSettings", -- 803
	"NoNav", -- 803
	"NoMove", -- 803
	"NoScrollWithMouse", -- 803
	"AlwaysAutoResize", -- 803
	"NoFocusOnAppearing" -- 803
} -- 803
local initFooter = true -- 812
local _anon_func_4 = function(allEntries, currentIndex) -- 849
	if currentIndex > 1 then -- 849
		return allEntries[currentIndex - 1] -- 850
	else -- 852
		return allEntries[#allEntries] -- 852
	end -- 849
end -- 849
local _anon_func_5 = function(allEntries, currentIndex) -- 856
	if currentIndex < #allEntries then -- 856
		return allEntries[currentIndex + 1] -- 857
	else -- 859
		return allEntries[1] -- 859
	end -- 856
end -- 856
footerWindow = threadLoop(function() -- 813
	local zh = useChinese -- 814
	if HttpServer.wsConnectionCount > 0 then -- 815
		return -- 816
	end -- 815
	if Keyboard:isKeyDown("Escape") then -- 817
		allClear() -- 818
		App.devMode = false -- 819
		App:shutdown() -- 820
	end -- 817
	do -- 821
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 822
		if ctrl and Keyboard:isKeyDown("Q") then -- 823
			stop() -- 824
		end -- 823
		if ctrl and Keyboard:isKeyDown("Z") then -- 825
			reloadCurrentEntry() -- 826
		end -- 825
		if ctrl and Keyboard:isKeyDown(",") then -- 827
			if showFooter then -- 828
				showStats = not showStats -- 828
			else -- 828
				showStats = true -- 828
			end -- 828
			showFooter = true -- 829
			config.showFooter = showFooter -- 830
			config.showStats = showStats -- 831
		end -- 827
		if ctrl and Keyboard:isKeyDown(".") then -- 832
			if showFooter then -- 833
				showConsole = not showConsole -- 833
			else -- 833
				showConsole = true -- 833
			end -- 833
			showFooter = true -- 834
			config.showFooter = showFooter -- 835
			config.showConsole = showConsole -- 836
		end -- 832
		if ctrl and Keyboard:isKeyDown("/") then -- 837
			showFooter = not showFooter -- 838
			config.showFooter = showFooter -- 839
		end -- 837
		local left = ctrl and Keyboard:isKeyDown("Left") -- 840
		local right = ctrl and Keyboard:isKeyDown("Right") -- 841
		local currentIndex = nil -- 842
		for i, entry in ipairs(allEntries) do -- 843
			if currentEntry == entry then -- 844
				currentIndex = i -- 845
			end -- 844
		end -- 843
		if left then -- 846
			allClear() -- 847
			if currentIndex == nil then -- 848
				currentIndex = #allEntries + 1 -- 848
			end -- 848
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 849
		end -- 846
		if right then -- 853
			allClear() -- 854
			if currentIndex == nil then -- 855
				currentIndex = 0 -- 855
			end -- 855
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 856
		end -- 853
	end -- 821
	if not showEntry then -- 860
		return -- 860
	end -- 860
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 862
		reloadDevEntry() -- 866
	end -- 862
	if initFooter then -- 867
		initFooter = false -- 868
	end -- 867
	local width, height -- 870
	do -- 870
		local _obj_0 = App.visualSize -- 870
		width, height = _obj_0.width, _obj_0.height -- 870
	end -- 870
	if isInEntry or showFooter then -- 871
		SetNextWindowSize(Vec2(width, 50)) -- 872
		SetNextWindowPos(Vec2(0, height - 50)) -- 873
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 874
			return PushStyleVar("WindowRounding", 0, function() -- 875
				return Begin("Footer", windowFlags, function() -- 876
					Separator() -- 877
					if iconTex then -- 878
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 879
							showStats = not showStats -- 880
							config.showStats = showStats -- 881
						end -- 879
						SameLine() -- 882
						if Button(">_", Vec2(30, 30)) then -- 883
							showConsole = not showConsole -- 884
							config.showConsole = showConsole -- 885
						end -- 883
					end -- 878
					if isInEntry and config.updateNotification then -- 886
						SameLine() -- 887
						if ImGui.Button(zh and "更新可用" or "Update") then -- 888
							allClear() -- 889
							config.updateNotification = false -- 890
							enterDemoEntry({ -- 892
								entryName = "SelfUpdater", -- 892
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 893
							}) -- 891
						end -- 888
					end -- 886
					if not isInEntry then -- 894
						SameLine() -- 895
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 896
						local currentIndex = nil -- 897
						for i, entry in ipairs(allEntries) do -- 898
							if currentEntry == entry then -- 899
								currentIndex = i -- 900
							end -- 899
						end -- 898
						if currentIndex then -- 901
							if currentIndex > 1 then -- 902
								SameLine() -- 903
								if Button("<<", Vec2(30, 30)) then -- 904
									allClear() -- 905
									enterDemoEntry(allEntries[currentIndex - 1]) -- 906
								end -- 904
							end -- 902
							if currentIndex < #allEntries then -- 907
								SameLine() -- 908
								if Button(">>", Vec2(30, 30)) then -- 909
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
				end) -- 876
			end) -- 875
		end) -- 874
	end -- 871
	local showWebIDE = isInEntry -- 920
	if config.updateNotification then -- 921
		if width < 460 then -- 922
			showWebIDE = false -- 923
		end -- 922
	else -- 925
		if width < 360 then -- 925
			showWebIDE = false -- 926
		end -- 925
	end -- 921
	if showWebIDE then -- 927
		SetNextWindowBgAlpha(0.0) -- 928
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 929
		Begin("Web IDE", displayWindowFlags, function() -- 930
			do -- 931
				local url -- 931
				if webStatus ~= nil then -- 931
					url = webStatus.url -- 931
				end -- 931
				if url then -- 931
					if isDesktop and not config.fullScreen then -- 932
						if urlClicked then -- 933
							BeginDisabled(function() -- 934
								return Button(url) -- 934
							end) -- 934
						elseif Button(url) then -- 935
							urlClicked = once(function() -- 936
								return sleep(5) -- 936
							end) -- 936
							App:openURL("http://localhost:8866") -- 937
						end -- 933
					else -- 939
						TextColored(descColor, url) -- 939
					end -- 932
				else -- 941
					TextColored(descColor, zh and '不可用' or 'not available') -- 941
				end -- 931
			end -- 931
			SameLine() -- 942
			TextDisabled('(?)') -- 943
			if IsItemHovered() then -- 944
				return BeginTooltip(function() -- 945
					return PushTextWrapPos(280, function() -- 946
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 947
					end) -- 946
				end) -- 945
			end -- 944
		end) -- 930
	end -- 927
	if not isInEntry then -- 949
		SetNextWindowSize(Vec2(50, 50)) -- 950
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 951
		PushStyleColor("WindowBg", transparant, function() -- 952
			return Begin("Show", displayWindowFlags, function() -- 952
				if width >= 370 then -- 953
					local changed -- 954
					changed, showFooter = Checkbox("##dev", showFooter) -- 954
					if changed then -- 954
						config.showFooter = showFooter -- 955
					end -- 954
				end -- 953
			end) -- 952
		end) -- 952
	end -- 949
	if isInEntry or showFooter then -- 957
		if showStats then -- 958
			PushStyleVar("WindowRounding", 0, function() -- 959
				SetNextWindowPos(Vec2(0, 0), "Always") -- 960
				SetNextWindowSize(Vec2(0, height - 50)) -- 961
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 962
				config.showStats = showStats -- 963
			end) -- 959
		end -- 958
		if showConsole then -- 964
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 965
			return PushStyleVar("WindowRounding", 6, function() -- 966
				return ShowConsole() -- 967
			end) -- 966
		end -- 964
	end -- 957
end) -- 813
local MaxWidth <const> = 960 -- 969
local toolOpen = false -- 971
local filterText = nil -- 972
local anyEntryMatched = false -- 973
local match -- 974
match = function(name) -- 974
	local res = not filterText or name:lower():match(filterText) -- 975
	if res then -- 976
		anyEntryMatched = true -- 976
	end -- 976
	return res -- 977
end -- 974
local sep -- 979
sep = function() -- 979
	return SeparatorText("") -- 979
end -- 979
local thinSep -- 980
thinSep = function() -- 980
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 980
end -- 980
entryWindow = threadLoop(function() -- 982
	if App.fpsLimited ~= config.fpsLimited then -- 983
		config.fpsLimited = App.fpsLimited -- 984
	end -- 983
	if App.targetFPS ~= config.targetFPS then -- 985
		config.targetFPS = App.targetFPS -- 986
	end -- 985
	if View.vsync ~= config.vsync then -- 987
		config.vsync = View.vsync -- 988
	end -- 987
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 989
		config.fixedFPS = Director.scheduler.fixedFPS -- 990
	end -- 989
	if Director.profilerSending ~= config.webProfiler then -- 991
		config.webProfiler = Director.profilerSending -- 992
	end -- 991
	if urlClicked then -- 993
		local _, result = coroutine.resume(urlClicked) -- 994
		if result then -- 995
			coroutine.close(urlClicked) -- 996
			urlClicked = nil -- 997
		end -- 995
	end -- 993
	if not showEntry then -- 998
		return -- 998
	end -- 998
	if not isInEntry then -- 999
		return -- 999
	end -- 999
	local zh = useChinese -- 1000
	if HttpServer.wsConnectionCount > 0 then -- 1001
		local themeColor = App.themeColor -- 1002
		local width, height -- 1003
		do -- 1003
			local _obj_0 = App.visualSize -- 1003
			width, height = _obj_0.width, _obj_0.height -- 1003
		end -- 1003
		SetNextWindowBgAlpha(0.5) -- 1004
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1005
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1006
			Separator() -- 1007
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1008
			if iconTex then -- 1009
				Image(icon, Vec2(24, 24)) -- 1010
				SameLine() -- 1011
			end -- 1009
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1012
			TextColored(descColor, slogon) -- 1013
			return Separator() -- 1014
		end) -- 1006
		return -- 1015
	end -- 1001
	local themeColor = App.themeColor -- 1017
	local fullWidth, height -- 1018
	do -- 1018
		local _obj_0 = App.visualSize -- 1018
		fullWidth, height = _obj_0.width, _obj_0.height -- 1018
	end -- 1018
	local width = math.min(MaxWidth, fullWidth) -- 1019
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1020
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1021
	SetNextWindowPos(Vec2.zero) -- 1022
	SetNextWindowBgAlpha(0) -- 1023
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1024
	do -- 1025
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1026
			return Begin("Dora Dev", windowFlags, function() -- 1027
				Dummy(Vec2(fullWidth - 20, 0)) -- 1028
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1029
				if fullWidth >= 400 then -- 1030
					SameLine() -- 1031
					Dummy(Vec2(fullWidth - 400, 0)) -- 1032
					SameLine() -- 1033
					SetNextItemWidth(zh and -95 or -140) -- 1034
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1035
						"AutoSelectAll" -- 1035
					}) then -- 1035
						config.filter = filterBuf.text -- 1036
					end -- 1035
					SameLine() -- 1037
					if Button(zh and '下载' or 'Download') then -- 1038
						allClear() -- 1039
						enterDemoEntry({ -- 1041
							entryName = "ResourceDownloader", -- 1041
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1042
						}) -- 1040
					end -- 1038
				end -- 1030
				Separator() -- 1043
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1044
			end) -- 1027
		end) -- 1026
	end -- 1025
	anyEntryMatched = false -- 1046
	SetNextWindowPos(Vec2(0, 50)) -- 1047
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1048
	do -- 1049
		return PushStyleColor("WindowBg", transparant, function() -- 1050
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1051
				return PushStyleVar("Alpha", 1, function() -- 1052
					return Begin("Content", windowFlags, function() -- 1053
						local DemoViewWidth <const> = 220 -- 1054
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1055
						if filterText then -- 1056
							filterText = filterText:lower() -- 1056
						end -- 1056
						if #gamesInDev > 0 then -- 1057
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1058
							Columns(columns, false) -- 1059
							local realViewWidth = GetColumnWidth() - 50 -- 1060
							for _index_0 = 1, #gamesInDev do -- 1061
								local game = gamesInDev[_index_0] -- 1061
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1062
								if bannerFile == nil then -- 1068
									bannerFile = defaultBannerFile -- 1068
								end -- 1068
								if bannerTex == nil then -- 1069
									bannerTex = defaultBannerTex -- 1069
								end -- 1069
								local displayName -- 1071
								if repo then -- 1071
									if zh then -- 1072
										displayName = repo.title.zh -- 1072
									else -- 1072
										displayName = repo.title.en -- 1072
									end -- 1072
								end -- 1071
								if displayName == nil then -- 1073
									displayName = gameName -- 1073
								end -- 1073
								if match(displayName) then -- 1074
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1075
									SameLine() -- 1076
									TextWrapped(displayName) -- 1077
									if columns > 1 then -- 1078
										if bannerFile then -- 1079
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1080
											local displayWidth <const> = realViewWidth -- 1081
											texHeight = displayWidth * texHeight / texWidth -- 1082
											texWidth = displayWidth -- 1083
											Dummy(Vec2.zero) -- 1084
											SameLine() -- 1085
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1086
										end -- 1079
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1087
											enterDemoEntry(game) -- 1088
										end -- 1087
									else -- 1090
										if bannerFile then -- 1090
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1091
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1092
											local sizing = 0.8 -- 1093
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1094
											texWidth = displayWidth * sizing -- 1095
											if texWidth > 500 then -- 1096
												sizing = 0.6 -- 1097
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1098
												texWidth = displayWidth * sizing -- 1099
											end -- 1096
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1100
											Dummy(Vec2(padding, 0)) -- 1101
											SameLine() -- 1102
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1103
										end -- 1090
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1104
											enterDemoEntry(game) -- 1105
										end -- 1104
									end -- 1078
									if #tests == 0 and #examples == 0 then -- 1106
										thinSep() -- 1107
									end -- 1106
									NextColumn() -- 1108
								end -- 1074
								local showSep = false -- 1109
								if #examples > 0 then -- 1110
									local showExample = false -- 1111
									do -- 1112
										local _accum_0 -- 1112
										for _index_1 = 1, #examples do -- 1112
											local _des_0 = examples[_index_1] -- 1112
											local entryName = _des_0.entryName -- 1112
											if match(entryName) then -- 1113
												_accum_0 = true -- 1113
												break -- 1113
											end -- 1113
										end -- 1112
										showExample = _accum_0 -- 1112
									end -- 1112
									if showExample then -- 1114
										showSep = true -- 1115
										Columns(1, false) -- 1116
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1117
										SameLine() -- 1118
										local opened -- 1119
										if (filterText ~= nil) then -- 1119
											opened = showExample -- 1119
										else -- 1119
											opened = false -- 1119
										end -- 1119
										if game.exampleOpen == nil then -- 1120
											game.exampleOpen = opened -- 1120
										end -- 1120
										SetNextItemOpen(game.exampleOpen) -- 1121
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1122
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1123
												Columns(maxColumns, false) -- 1124
												for _index_1 = 1, #examples do -- 1125
													local example = examples[_index_1] -- 1125
													local entryName = example.entryName -- 1126
													if not match(entryName) then -- 1127
														goto _continue_0 -- 1127
													end -- 1127
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1128
														if Button(entryName, Vec2(-1, 40)) then -- 1129
															enterDemoEntry(example) -- 1130
														end -- 1129
														return NextColumn() -- 1131
													end) -- 1128
													opened = true -- 1132
													::_continue_0:: -- 1126
												end -- 1125
											end) -- 1123
										end) -- 1122
										game.exampleOpen = opened -- 1133
									end -- 1114
								end -- 1110
								if #tests > 0 then -- 1134
									local showTest = false -- 1135
									do -- 1136
										local _accum_0 -- 1136
										for _index_1 = 1, #tests do -- 1136
											local _des_0 = tests[_index_1] -- 1136
											local entryName = _des_0.entryName -- 1136
											if match(entryName) then -- 1137
												_accum_0 = true -- 1137
												break -- 1137
											end -- 1137
										end -- 1136
										showTest = _accum_0 -- 1136
									end -- 1136
									if showTest then -- 1138
										showSep = true -- 1139
										Columns(1, false) -- 1140
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1141
										SameLine() -- 1142
										local opened -- 1143
										if (filterText ~= nil) then -- 1143
											opened = showTest -- 1143
										else -- 1143
											opened = false -- 1143
										end -- 1143
										if game.testOpen == nil then -- 1144
											game.testOpen = opened -- 1144
										end -- 1144
										SetNextItemOpen(game.testOpen) -- 1145
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1146
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1147
												Columns(maxColumns, false) -- 1148
												for _index_1 = 1, #tests do -- 1149
													local test = tests[_index_1] -- 1149
													local entryName = test.entryName -- 1150
													if not match(entryName) then -- 1151
														goto _continue_0 -- 1151
													end -- 1151
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1152
														if Button(entryName, Vec2(-1, 40)) then -- 1153
															enterDemoEntry(test) -- 1154
														end -- 1153
														return NextColumn() -- 1155
													end) -- 1152
													opened = true -- 1156
													::_continue_0:: -- 1150
												end -- 1149
											end) -- 1147
										end) -- 1146
										game.testOpen = opened -- 1157
									end -- 1138
								end -- 1134
								if showSep then -- 1158
									Columns(1, false) -- 1159
									thinSep() -- 1160
									Columns(columns, false) -- 1161
								end -- 1158
							end -- 1061
						end -- 1057
						if #doraTools > 0 then -- 1162
							local showTool = false -- 1163
							do -- 1164
								local _accum_0 -- 1164
								for _index_0 = 1, #doraTools do -- 1164
									local _des_0 = doraTools[_index_0] -- 1164
									local entryName = _des_0.entryName -- 1164
									if match(entryName) then -- 1165
										_accum_0 = true -- 1165
										break -- 1165
									end -- 1165
								end -- 1164
								showTool = _accum_0 -- 1164
							end -- 1164
							if not showTool then -- 1166
								goto endEntry -- 1166
							end -- 1166
							Columns(1, false) -- 1167
							TextColored(themeColor, "Dora SSR:") -- 1168
							SameLine() -- 1169
							Text(zh and "开发支持" or "Development Support") -- 1170
							Separator() -- 1171
							if #doraTools > 0 then -- 1172
								local opened -- 1173
								if (filterText ~= nil) then -- 1173
									opened = showTool -- 1173
								else -- 1173
									opened = false -- 1173
								end -- 1173
								SetNextItemOpen(toolOpen) -- 1174
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1175
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1176
										Columns(maxColumns, false) -- 1177
										for _index_0 = 1, #doraTools do -- 1178
											local example = doraTools[_index_0] -- 1178
											local entryName = example.entryName -- 1179
											if not match(entryName) then -- 1180
												goto _continue_0 -- 1180
											end -- 1180
											if Button(entryName, Vec2(-1, 40)) then -- 1181
												enterDemoEntry(example) -- 1182
											end -- 1181
											NextColumn() -- 1183
											::_continue_0:: -- 1179
										end -- 1178
										Columns(1, false) -- 1184
										opened = true -- 1185
									end) -- 1176
								end) -- 1175
								toolOpen = opened -- 1186
							end -- 1172
						end -- 1162
						::endEntry:: -- 1187
						if not anyEntryMatched then -- 1188
							SetNextWindowBgAlpha(0) -- 1189
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1190
							Begin("Entries Not Found", displayWindowFlags, function() -- 1191
								Separator() -- 1192
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1193
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1194
								return Separator() -- 1195
							end) -- 1191
						end -- 1188
						Columns(1, false) -- 1196
						Dummy(Vec2(100, 80)) -- 1197
						return ScrollWhenDraggingOnVoid() -- 1198
					end) -- 1053
				end) -- 1052
			end) -- 1051
		end) -- 1050
	end -- 1049
end) -- 982
webStatus = require("Script.Dev.WebServer") -- 1200
return _module_0 -- 1
