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
local OpenPopup = _module_0.OpenPopup -- 1
local SetNextWindowPosCenter = _module_0.SetNextWindowPosCenter -- 1
local BeginPopupModal = _module_0.BeginPopupModal -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local CloseCurrentPopup = _module_0.CloseCurrentPopup -- 1
local SameLine = _module_0.SameLine -- 1
local Separator = _module_0.Separator -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Begin = _module_0.Begin -- 1
local TreeNode = _module_0.TreeNode -- 1
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "showPreview") -- 51
config:load() -- 79
if not (config.writablePath ~= nil) then -- 81
	config.writablePath = Content.appPath -- 82
end -- 81
if not (config.webIDEConnected ~= nil) then -- 84
	config.webIDEConnected = false -- 85
end -- 84
if (config.fpsLimited ~= nil) then -- 87
	App.fpsLimited = config.fpsLimited -- 88
else -- 90
	config.fpsLimited = App.fpsLimited -- 90
end -- 87
if (config.targetFPS ~= nil) then -- 92
	App.targetFPS = config.targetFPS -- 93
else -- 95
	config.targetFPS = App.targetFPS -- 95
end -- 92
if (config.vsync ~= nil) then -- 97
	View.vsync = config.vsync -- 98
else -- 100
	config.vsync = View.vsync -- 100
end -- 97
if (config.fixedFPS ~= nil) then -- 102
	Director.scheduler.fixedFPS = config.fixedFPS -- 103
else -- 105
	config.fixedFPS = Director.scheduler.fixedFPS -- 105
end -- 102
if not (config.showPreview ~= nil) then -- 107
	config.showPreview = true -- 108
end -- 107
local showEntry = true -- 110
isDesktop = false -- 112
if (function() -- 113
	local _val_0 = App.platform -- 113
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 113
end)() then -- 113
	isDesktop = true -- 114
	if config.fullScreen then -- 115
		App.fullScreen = true -- 116
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 117
		local size = Size(config.winWidth, config.winHeight) -- 118
		if App.winSize ~= size then -- 119
			App.winSize = size -- 120
		end -- 119
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
	end -- 115
	if (config.alwaysOnTop ~= nil) then -- 131
		App.alwaysOnTop = config.alwaysOnTop -- 132
	else -- 134
		config.alwaysOnTop = true -- 134
	end -- 131
end -- 113
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
			local data = json.decode(res) -- 197
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
	end) -- 195
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
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 226
local building = false -- 228
local getAllFiles -- 230
getAllFiles = function(path, exts, recursive) -- 230
	if recursive == nil then -- 230
		recursive = true -- 230
	end -- 230
	local filters = Set(exts) -- 231
	local files -- 232
	if recursive then -- 232
		files = Content:getAllFiles(path) -- 233
	else -- 235
		files = Content:getFiles(path) -- 235
	end -- 232
	local _accum_0 = { } -- 236
	local _len_0 = 1 -- 236
	for _index_0 = 1, #files do -- 236
		local file = files[_index_0] -- 236
		if not filters[Path:getExt(file)] then -- 237
			goto _continue_0 -- 237
		end -- 237
		_accum_0[_len_0] = file -- 238
		_len_0 = _len_0 + 1 -- 237
		::_continue_0:: -- 237
	end -- 236
	return _accum_0 -- 236
end -- 230
_module_0["getAllFiles"] = getAllFiles -- 230
local getFileEntries -- 240
getFileEntries = function(path, recursive, excludeFiles) -- 240
	if recursive == nil then -- 240
		recursive = true -- 240
	end -- 240
	if excludeFiles == nil then -- 240
		excludeFiles = nil -- 240
	end -- 240
	local entries = { } -- 241
	local excludes -- 242
	if excludeFiles then -- 242
		excludes = Set(excludeFiles) -- 243
	end -- 242
	local _list_0 = getAllFiles(path, { -- 244
		"lua", -- 244
		"xml", -- 244
		yueext, -- 244
		"tl" -- 244
	}, recursive) -- 244
	for _index_0 = 1, #_list_0 do -- 244
		local file = _list_0[_index_0] -- 244
		local entryName = Path:getName(file) -- 245
		if excludes and excludes[entryName] then -- 246
			goto _continue_0 -- 247
		end -- 246
		local fileName = Path:replaceExt(file, "") -- 248
		fileName = Path(path, fileName) -- 249
		local entryAdded -- 250
		do -- 250
			local _accum_0 -- 250
			for _index_1 = 1, #entries do -- 250
				local _des_0 = entries[_index_1] -- 250
				local ename, efile = _des_0.entryName, _des_0.fileName -- 250
				if entryName == ename and efile == fileName then -- 251
					_accum_0 = true -- 251
					break -- 251
				end -- 251
			end -- 250
			entryAdded = _accum_0 -- 250
		end -- 250
		if entryAdded then -- 252
			goto _continue_0 -- 252
		end -- 252
		local entry = { -- 253
			entryName = entryName, -- 253
			fileName = fileName -- 253
		} -- 253
		entries[#entries + 1] = entry -- 254
		::_continue_0:: -- 245
	end -- 244
	table.sort(entries, function(a, b) -- 255
		return a.entryName < b.entryName -- 255
	end) -- 255
	return entries -- 256
end -- 240
local getProjectEntries -- 258
getProjectEntries = function(path) -- 258
	local entries = { } -- 259
	local _list_0 = Content:getDirs(path) -- 260
	for _index_0 = 1, #_list_0 do -- 260
		local dir = _list_0[_index_0] -- 260
		if dir:match("^%.") then -- 261
			goto _continue_0 -- 261
		end -- 261
		local _list_1 = getAllFiles(Path(path, dir), { -- 262
			"lua", -- 262
			"xml", -- 262
			yueext, -- 262
			"tl", -- 262
			"wasm" -- 262
		}) -- 262
		for _index_1 = 1, #_list_1 do -- 262
			local file = _list_1[_index_1] -- 262
			if "init" == Path:getName(file):lower() then -- 263
				local fileName = Path:replaceExt(file, "") -- 264
				fileName = Path(path, dir, fileName) -- 265
				local projectPath = Path:getPath(fileName) -- 266
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 267
				local repo = nil -- 268
				if Content:exist(repoFile) then -- 269
					local str = Content:load(repoFile) -- 270
					if str then -- 270
						repo = json.decode(str) -- 271
					end -- 270
				end -- 269
				local entryName = Path:getName(projectPath) -- 272
				local entryAdded -- 273
				do -- 273
					local _accum_0 -- 273
					for _index_2 = 1, #entries do -- 273
						local _des_0 = entries[_index_2] -- 273
						local ename, efile = _des_0.entryName, _des_0.fileName -- 273
						if entryName == ename and efile == fileName then -- 274
							_accum_0 = true -- 274
							break -- 274
						end -- 274
					end -- 273
					entryAdded = _accum_0 -- 273
				end -- 273
				if entryAdded then -- 275
					goto _continue_1 -- 275
				end -- 275
				local examples = { } -- 276
				local tests = { } -- 277
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 278
				if Content:exist(examplePath) then -- 279
					local _list_2 = getFileEntries(examplePath) -- 280
					for _index_2 = 1, #_list_2 do -- 280
						local _des_0 = _list_2[_index_2] -- 280
						local name, ePath = _des_0.entryName, _des_0.fileName -- 280
						local entry = { -- 282
							entryName = name, -- 282
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 283
							workDir = projectPath -- 284
						} -- 281
						examples[#examples + 1] = entry -- 286
					end -- 280
				end -- 279
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 287
				if Content:exist(testPath) then -- 288
					local _list_2 = getFileEntries(testPath) -- 289
					for _index_2 = 1, #_list_2 do -- 289
						local _des_0 = _list_2[_index_2] -- 289
						local name, tPath = _des_0.entryName, _des_0.fileName -- 289
						local entry = { -- 291
							entryName = name, -- 291
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 292
							workDir = projectPath -- 293
						} -- 290
						tests[#tests + 1] = entry -- 295
					end -- 289
				end -- 288
				local entry = { -- 296
					entryName = entryName, -- 296
					fileName = fileName, -- 296
					examples = examples, -- 296
					tests = tests, -- 296
					repo = repo -- 296
				} -- 296
				local bannerFile -- 297
				do -- 297
					local _accum_0 -- 297
					repeat -- 297
						if not config.showPreview then -- 298
							_accum_0 = nil -- 298
							break -- 298
						end -- 298
						local f = Path(projectPath, ".dora", "banner.jpg") -- 299
						if Content:exist(f) then -- 300
							_accum_0 = f -- 300
							break -- 300
						end -- 300
						f = Path(projectPath, ".dora", "banner.png") -- 301
						if Content:exist(f) then -- 302
							_accum_0 = f -- 302
							break -- 302
						end -- 302
						f = Path(projectPath, "Image", "banner.jpg") -- 303
						if Content:exist(f) then -- 304
							_accum_0 = f -- 304
							break -- 304
						end -- 304
						f = Path(projectPath, "Image", "banner.png") -- 305
						if Content:exist(f) then -- 306
							_accum_0 = f -- 306
							break -- 306
						end -- 306
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 307
						if Content:exist(f) then -- 308
							_accum_0 = f -- 308
							break -- 308
						end -- 308
					until true -- 297
					bannerFile = _accum_0 -- 297
				end -- 297
				if bannerFile then -- 310
					thread(function() -- 310
						if Cache:loadAsync(bannerFile) then -- 311
							local bannerTex = Texture2D(bannerFile) -- 312
							if bannerTex then -- 312
								entry.bannerFile = bannerFile -- 313
								entry.bannerTex = bannerTex -- 314
							end -- 312
						end -- 311
					end) -- 310
				end -- 310
				entries[#entries + 1] = entry -- 315
			end -- 263
			::_continue_1:: -- 263
		end -- 262
		::_continue_0:: -- 261
	end -- 260
	table.sort(entries, function(a, b) -- 316
		return a.entryName < b.entryName -- 316
	end) -- 316
	return entries -- 317
end -- 258
local gamesInDev -- 319
local doraTools -- 320
local allEntries -- 321
local updateEntries -- 323
updateEntries = function() -- 323
	gamesInDev = getProjectEntries(Content.writablePath) -- 324
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 325
	allEntries = { } -- 327
	for _index_0 = 1, #gamesInDev do -- 328
		local game = gamesInDev[_index_0] -- 328
		allEntries[#allEntries + 1] = game -- 329
		local examples, tests = game.examples, game.tests -- 330
		for _index_1 = 1, #examples do -- 331
			local example = examples[_index_1] -- 331
			allEntries[#allEntries + 1] = example -- 332
		end -- 331
		for _index_1 = 1, #tests do -- 333
			local test = tests[_index_1] -- 333
			allEntries[#allEntries + 1] = test -- 334
		end -- 333
	end -- 328
end -- 323
updateEntries() -- 336
local doCompile -- 338
doCompile = function(minify) -- 338
	if building then -- 339
		return -- 339
	end -- 339
	building = true -- 340
	local startTime = App.runningTime -- 341
	local luaFiles = { } -- 342
	local yueFiles = { } -- 343
	local xmlFiles = { } -- 344
	local tlFiles = { } -- 345
	local writablePath = Content.writablePath -- 346
	local buildPaths = { -- 348
		{ -- 349
			Content.assetPath, -- 349
			Path(writablePath, ".build"), -- 350
			"" -- 351
		} -- 348
	} -- 347
	for _index_0 = 1, #gamesInDev do -- 354
		local _des_0 = gamesInDev[_index_0] -- 354
		local entryFile = _des_0.entryFile -- 354
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 355
		buildPaths[#buildPaths + 1] = { -- 357
			Path(writablePath, gamePath), -- 357
			Path(writablePath, ".build", gamePath), -- 358
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 359
			gamePath -- 360
		} -- 356
	end -- 354
	for _index_0 = 1, #buildPaths do -- 361
		local _des_0 = buildPaths[_index_0] -- 361
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 361
		if not Content:exist(inputPath) then -- 362
			goto _continue_0 -- 362
		end -- 362
		local _list_0 = getAllFiles(inputPath, { -- 364
			"lua" -- 364
		}) -- 364
		for _index_1 = 1, #_list_0 do -- 364
			local file = _list_0[_index_1] -- 364
			luaFiles[#luaFiles + 1] = { -- 366
				file, -- 366
				Path(inputPath, file), -- 367
				Path(outputPath, file), -- 368
				gamePath -- 369
			} -- 365
		end -- 364
		local _list_1 = getAllFiles(inputPath, { -- 371
			yueext -- 371
		}) -- 371
		for _index_1 = 1, #_list_1 do -- 371
			local file = _list_1[_index_1] -- 371
			yueFiles[#yueFiles + 1] = { -- 373
				file, -- 373
				Path(inputPath, file), -- 374
				Path(outputPath, Path:replaceExt(file, "lua")), -- 375
				searchPath, -- 376
				gamePath -- 377
			} -- 372
		end -- 371
		local _list_2 = getAllFiles(inputPath, { -- 379
			"xml" -- 379
		}) -- 379
		for _index_1 = 1, #_list_2 do -- 379
			local file = _list_2[_index_1] -- 379
			xmlFiles[#xmlFiles + 1] = { -- 381
				file, -- 381
				Path(inputPath, file), -- 382
				Path(outputPath, Path:replaceExt(file, "lua")), -- 383
				gamePath -- 384
			} -- 380
		end -- 379
		local _list_3 = getAllFiles(inputPath, { -- 386
			"tl" -- 386
		}) -- 386
		for _index_1 = 1, #_list_3 do -- 386
			local file = _list_3[_index_1] -- 386
			if not file:match(".*%.d%.tl$") then -- 387
				tlFiles[#tlFiles + 1] = { -- 389
					file, -- 389
					Path(inputPath, file), -- 390
					Path(outputPath, Path:replaceExt(file, "lua")), -- 391
					searchPath, -- 392
					gamePath -- 393
				} -- 388
			end -- 387
		end -- 386
		::_continue_0:: -- 362
	end -- 361
	local paths -- 395
	do -- 395
		local _tbl_0 = { } -- 395
		local _list_0 = { -- 396
			luaFiles, -- 396
			yueFiles, -- 396
			xmlFiles, -- 396
			tlFiles -- 396
		} -- 396
		for _index_0 = 1, #_list_0 do -- 396
			local files = _list_0[_index_0] -- 396
			for _index_1 = 1, #files do -- 397
				local file = files[_index_1] -- 397
				_tbl_0[Path:getPath(file[3])] = true -- 395
			end -- 395
		end -- 395
		paths = _tbl_0 -- 395
	end -- 395
	for path in pairs(paths) do -- 399
		Content:mkdir(path) -- 399
	end -- 399
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 401
	local fileCount = 0 -- 402
	local errors = { } -- 403
	for _index_0 = 1, #yueFiles do -- 404
		local _des_0 = yueFiles[_index_0] -- 404
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 404
		local filename -- 405
		if gamePath then -- 405
			filename = Path(gamePath, file) -- 405
		else -- 405
			filename = file -- 405
		end -- 405
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 406
			if not codes then -- 407
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 408
				return -- 409
			end -- 407
			local success, result = LintYueGlobals(codes, globals) -- 410
			if success then -- 411
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 412
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 413
				codes = codes:gsub("^\n*", "") -- 414
				if not (result == "") then -- 415
					result = result .. "\n" -- 415
				end -- 415
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 416
			else -- 418
				local yueCodes = Content:load(input) -- 418
				if yueCodes then -- 418
					local globalErrors = { } -- 419
					for _index_1 = 1, #result do -- 420
						local _des_1 = result[_index_1] -- 420
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 420
						local countLine = 1 -- 421
						local code = "" -- 422
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 423
							if countLine == line then -- 424
								code = lineCode -- 425
								break -- 426
							end -- 424
							countLine = countLine + 1 -- 427
						end -- 423
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 428
					end -- 420
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 429
				else -- 431
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 431
				end -- 418
			end -- 411
		end, function(success) -- 406
			if success then -- 432
				print("Yue compiled: " .. tostring(filename)) -- 432
			end -- 432
			fileCount = fileCount + 1 -- 433
		end) -- 406
	end -- 404
	thread(function() -- 435
		for _index_0 = 1, #xmlFiles do -- 436
			local _des_0 = xmlFiles[_index_0] -- 436
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 436
			local filename -- 437
			if gamePath then -- 437
				filename = Path(gamePath, file) -- 437
			else -- 437
				filename = file -- 437
			end -- 437
			local sourceCodes = Content:loadAsync(input) -- 438
			local codes, err = xml.tolua(sourceCodes) -- 439
			if not codes then -- 440
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 441
			else -- 443
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 443
				print("Xml compiled: " .. tostring(filename)) -- 444
			end -- 440
			fileCount = fileCount + 1 -- 445
		end -- 436
	end) -- 435
	thread(function() -- 447
		for _index_0 = 1, #tlFiles do -- 448
			local _des_0 = tlFiles[_index_0] -- 448
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 448
			local filename -- 449
			if gamePath then -- 449
				filename = Path(gamePath, file) -- 449
			else -- 449
				filename = file -- 449
			end -- 449
			local sourceCodes = Content:loadAsync(input) -- 450
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 451
			if not codes then -- 452
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 453
			else -- 455
				Content:saveAsync(output, codes) -- 455
				print("Teal compiled: " .. tostring(filename)) -- 456
			end -- 452
			fileCount = fileCount + 1 -- 457
		end -- 448
	end) -- 447
	return thread(function() -- 459
		wait(function() -- 460
			return fileCount == totalFiles -- 460
		end) -- 460
		if minify then -- 461
			local _list_0 = { -- 462
				yueFiles, -- 462
				xmlFiles, -- 462
				tlFiles -- 462
			} -- 462
			for _index_0 = 1, #_list_0 do -- 462
				local files = _list_0[_index_0] -- 462
				for _index_1 = 1, #files do -- 462
					local file = files[_index_1] -- 462
					local output = Path:replaceExt(file[3], "lua") -- 463
					luaFiles[#luaFiles + 1] = { -- 465
						Path:replaceExt(file[1], "lua"), -- 465
						output, -- 466
						output -- 467
					} -- 464
				end -- 462
			end -- 462
			local FormatMini -- 469
			do -- 469
				local _obj_0 = require("luaminify") -- 469
				FormatMini = _obj_0.FormatMini -- 469
			end -- 469
			for _index_0 = 1, #luaFiles do -- 470
				local _des_0 = luaFiles[_index_0] -- 470
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 470
				if Content:exist(input) then -- 471
					local sourceCodes = Content:loadAsync(input) -- 472
					local res, err = FormatMini(sourceCodes) -- 473
					if res then -- 474
						Content:saveAsync(output, res) -- 475
						print("Minify: " .. tostring(file)) -- 476
					else -- 478
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 478
					end -- 474
				else -- 480
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 480
				end -- 471
			end -- 470
			package.loaded["luaminify.FormatMini"] = nil -- 481
			package.loaded["luaminify.ParseLua"] = nil -- 482
			package.loaded["luaminify.Scope"] = nil -- 483
			package.loaded["luaminify.Util"] = nil -- 484
		end -- 461
		local errorMessage = table.concat(errors, "\n") -- 485
		if errorMessage ~= "" then -- 486
			print(errorMessage) -- 486
		end -- 486
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 487
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 488
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 489
		Content:clearPathCache() -- 490
		teal.clear() -- 491
		yue.clear() -- 492
		building = false -- 493
	end) -- 459
end -- 338
local doClean -- 495
doClean = function() -- 495
	if building then -- 496
		return -- 496
	end -- 496
	local writablePath = Content.writablePath -- 497
	local targetDir = Path(writablePath, ".build") -- 498
	Content:clearPathCache() -- 499
	if Content:remove(targetDir) then -- 500
		return print("Cleaned: " .. tostring(targetDir)) -- 501
	end -- 500
end -- 495
local screenScale = 2.0 -- 503
local scaleContent = false -- 504
local isInEntry = true -- 505
local currentEntry = nil -- 506
local footerWindow = nil -- 508
local entryWindow = nil -- 509
local testingThread = nil -- 510
local setupEventHandlers = nil -- 512
local allClear -- 514
allClear = function() -- 514
	local _list_0 = Routine -- 515
	for _index_0 = 1, #_list_0 do -- 515
		local routine = _list_0[_index_0] -- 515
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 517
			goto _continue_0 -- 518
		else -- 520
			Routine:remove(routine) -- 520
		end -- 516
		::_continue_0:: -- 516
	end -- 515
	for _index_0 = 1, #moduleCache do -- 521
		local module = moduleCache[_index_0] -- 521
		package.loaded[module] = nil -- 522
	end -- 521
	moduleCache = { } -- 523
	Director:cleanup() -- 524
	Entity:clear() -- 525
	Platformer.Data:clear() -- 526
	Platformer.UnitAction:clear() -- 527
	Audio:stopAll(0.2) -- 528
	Struct:clear() -- 529
	View.postEffect = nil -- 530
	View.scale = scaleContent and screenScale or 1 -- 531
	Director.clearColor = Color(0xff1a1a1a) -- 532
	teal.clear() -- 533
	yue.clear() -- 534
	for _, item in pairs(ubox()) do -- 535
		local node = tolua.cast(item, "Node") -- 536
		if node then -- 536
			node:cleanup() -- 536
		end -- 536
	end -- 535
	collectgarbage() -- 537
	collectgarbage() -- 538
	Wasm:clear() -- 539
	thread(function() -- 540
		sleep() -- 541
		return Cache:removeUnused() -- 542
	end) -- 540
	setupEventHandlers() -- 543
	Content.searchPaths = searchPaths -- 544
	App.idled = true -- 545
end -- 514
_module_0["allClear"] = allClear -- 514
local clearTempFiles -- 547
clearTempFiles = function() -- 547
	local writablePath = Content.writablePath -- 548
	Content:remove(Path(writablePath, ".upload")) -- 549
	return Content:remove(Path(writablePath, ".download")) -- 550
end -- 547
local waitForWebStart = true -- 552
thread(function() -- 553
	sleep(2) -- 554
	waitForWebStart = false -- 555
end) -- 553
local reloadDevEntry -- 557
reloadDevEntry = function() -- 557
	return thread(function() -- 557
		waitForWebStart = true -- 558
		doClean() -- 559
		allClear() -- 560
		_G.require = oldRequire -- 561
		Dora.require = oldRequire -- 562
		package.loaded["Script.Dev.Entry"] = nil -- 563
		return Director.systemScheduler:schedule(function() -- 564
			Routine:clear() -- 565
			oldRequire("Script.Dev.Entry") -- 566
			return true -- 567
		end) -- 564
	end) -- 557
end -- 557
local setWorkspace -- 569
setWorkspace = function(path) -- 569
	clearTempFiles() -- 570
	Content.writablePath = path -- 571
	config.writablePath = Content.writablePath -- 572
	return thread(function() -- 573
		sleep() -- 574
		return reloadDevEntry() -- 575
	end) -- 573
end -- 569
local quit = false -- 577
local stop -- 579
stop = function() -- 579
	if isInEntry then -- 580
		return false -- 580
	end -- 580
	allClear() -- 581
	isInEntry = true -- 582
	currentEntry = nil -- 583
	return true -- 584
end -- 579
_module_0["stop"] = stop -- 579
local _anon_func_1 = function(App, _with_0) -- 603
	local _val_0 = App.platform -- 603
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 603
end -- 603
setupEventHandlers = function() -- 586
	local _with_0 = Director.postNode -- 587
	_with_0:onAppEvent(function(eventType) -- 588
		if "Quit" == eventType then -- 589
			quit = true -- 590
			allClear() -- 591
			return clearTempFiles() -- 592
		elseif "Shutdown" == eventType then -- 593
			return stop() -- 594
		end -- 588
	end) -- 588
	_with_0:onAppChange(function(settingName) -- 595
		if "Theme" == settingName then -- 596
			config.themeColor = App.themeColor:toARGB() -- 597
		elseif "Locale" == settingName then -- 598
			config.locale = App.locale -- 599
			updateLocale() -- 600
			return teal.clear(true) -- 601
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 602
			if _anon_func_1(App, _with_0) then -- 603
				if "FullScreen" == settingName then -- 605
					config.fullScreen = App.fullScreen -- 605
				elseif "Position" == settingName then -- 606
					local _obj_0 = App.winPosition -- 606
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 606
				elseif "Size" == settingName then -- 607
					local width, height -- 608
					do -- 608
						local _obj_0 = App.winSize -- 608
						width, height = _obj_0.width, _obj_0.height -- 608
					end -- 608
					config.winWidth = width -- 609
					config.winHeight = height -- 610
				end -- 604
			end -- 603
		end -- 595
	end) -- 595
	_with_0:onAppWS(function(eventType) -- 611
		if eventType == "Close" then -- 611
			if HttpServer.wsConnectionCount == 0 then -- 612
				return updateEntries() -- 613
			end -- 612
		end -- 611
	end) -- 611
	_with_0:slot("UpdateEntries", function() -- 614
		return updateEntries() -- 614
	end) -- 614
	return _with_0 -- 587
end -- 586
setupEventHandlers() -- 616
clearTempFiles() -- 617
local downloadFile -- 619
downloadFile = function(url, target) -- 619
	return Director.systemScheduler:schedule(once(function() -- 619
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 620
			if quit then -- 621
				return true -- 621
			end -- 621
			emit("AppWS", "Send", json.encode({ -- 623
				name = "Download", -- 623
				url = url, -- 623
				status = "downloading", -- 623
				progress = current / total -- 624
			})) -- 622
			return false -- 620
		end) -- 620
		return emit("AppWS", "Send", json.encode(success and { -- 627
			name = "Download", -- 627
			url = url, -- 627
			status = "completed", -- 627
			progress = 1.0 -- 628
		} or { -- 630
			name = "Download", -- 630
			url = url, -- 630
			status = "failed", -- 630
			progress = 0.0 -- 631
		})) -- 626
	end)) -- 619
end -- 619
_module_0["downloadFile"] = downloadFile -- 619
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 642
	if workDir == nil then -- 642
		workDir = Path:getPath(file) -- 642
	end -- 642
	Content:insertSearchPath(1, workDir) -- 643
	local scriptPath = Path(workDir, "Script") -- 644
	if Content:exist(scriptPath) then -- 645
		Content:insertSearchPath(1, scriptPath) -- 646
	end -- 645
	local result = require(file) -- 647
	if "function" == type(result) then -- 648
		result() -- 648
	end -- 648
	return nil -- 649
end -- 642
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 678
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 678
	label.alignment = "Left" -- 679
	label.textWidth = width - fontSize -- 680
	label.text = err -- 681
	return label -- 678
end -- 678
local enterEntryAsync -- 634
enterEntryAsync = function(entry) -- 634
	isInEntry = false -- 635
	App.idled = false -- 636
	emit(Profiler.EventName, "ClearLoader") -- 637
	currentEntry = entry -- 638
	local file, workDir = entry.fileName, entry.workDir -- 639
	sleep() -- 640
	return xpcall(_anon_func_2, function(msg) -- 649
		local err = debug.traceback(msg) -- 651
		Log("Error", err) -- 652
		allClear() -- 653
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 654
		local viewWidth, viewHeight -- 655
		do -- 655
			local _obj_0 = View.size -- 655
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 655
		end -- 655
		local width, height = viewWidth - 20, viewHeight - 20 -- 656
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 657
		Director.ui:addChild((function() -- 658
			local root = AlignNode() -- 658
			do -- 659
				local _obj_0 = App.bufferSize -- 659
				width, height = _obj_0.width, _obj_0.height -- 659
			end -- 659
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 660
			root:onAppChange(function(settingName) -- 661
				if settingName == "Size" then -- 661
					do -- 662
						local _obj_0 = App.bufferSize -- 662
						width, height = _obj_0.width, _obj_0.height -- 662
					end -- 662
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 663
				end -- 661
			end) -- 661
			root:addChild((function() -- 664
				local _with_0 = ScrollArea({ -- 665
					width = width, -- 665
					height = height, -- 666
					paddingX = 0, -- 667
					paddingY = 50, -- 668
					viewWidth = height, -- 669
					viewHeight = height -- 670
				}) -- 664
				root:onAlignLayout(function(w, h) -- 672
					_with_0.position = Vec2(w / 2, h / 2) -- 673
					w = w - 20 -- 674
					h = h - 20 -- 675
					_with_0.view.children.first.textWidth = w - fontSize -- 676
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 677
				end) -- 672
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 678
				return _with_0 -- 664
			end)()) -- 664
			return root -- 658
		end)()) -- 658
		return err -- 682
	end, Content, Path, file, require, type, workDir) -- 641
end -- 634
_module_0["enterEntryAsync"] = enterEntryAsync -- 634
local enterDemoEntry -- 684
enterDemoEntry = function(entry) -- 684
	return thread(function() -- 684
		return enterEntryAsync(entry) -- 684
	end) -- 684
end -- 684
local reloadCurrentEntry -- 686
reloadCurrentEntry = function() -- 686
	if currentEntry then -- 687
		allClear() -- 688
		return enterDemoEntry(currentEntry) -- 689
	end -- 687
end -- 686
Director.clearColor = Color(0xff1a1a1a) -- 691
local extraOperations -- 693
do -- 693
	local isOSSLicenseExist = Content:exist("LICENSES") -- 694
	local ossLicenses = nil -- 695
	local ossLicenseOpen = false -- 696
	local failedSetFolder = false -- 697
	local statusFlags = { -- 698
		"NoResize", -- 698
		"NoMove", -- 698
		"NoCollapse", -- 698
		"AlwaysAutoResize", -- 698
		"NoSavedSettings" -- 698
	} -- 698
	extraOperations = function() -- 705
		local zh = useChinese -- 706
		if isDesktop then -- 707
			local themeColor = App.themeColor -- 708
			local alwaysOnTop, writablePath, showPreview = config.alwaysOnTop, config.writablePath, config.showPreview -- 709
			do -- 710
				local changed -- 710
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 710
				if changed then -- 710
					App.alwaysOnTop = alwaysOnTop -- 711
					config.alwaysOnTop = alwaysOnTop -- 712
				end -- 710
			end -- 710
			do -- 713
				local changed -- 713
				changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 713
				if changed then -- 713
					config.showPreview = showPreview -- 714
					updateEntries() -- 715
					if not showPreview then -- 716
						thread(function() -- 717
							collectgarbage() -- 718
							return Cache:removeUnused("Texture") -- 719
						end) -- 717
					end -- 716
				end -- 713
			end -- 713
			SeparatorText(zh and "工作目录" or "Workspace") -- 720
			PushTextWrapPos(400, function() -- 721
				return TextColored(themeColor, writablePath) -- 722
			end) -- 721
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 723
			if Button(zh and "改变目录" or "Set Folder") then -- 724
				App:openFileDialog(true, function(path) -- 725
					if path == "" then -- 726
						return -- 726
					end -- 726
					local relPath = Path:getRelative(Content.assetPath, path) -- 727
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 728
						return setWorkspace(path) -- 729
					else -- 731
						failedSetFolder = true -- 731
					end -- 728
				end) -- 725
			end -- 724
			if failedSetFolder then -- 732
				failedSetFolder = false -- 733
				OpenPopup(popupName) -- 734
			end -- 732
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 735
			BeginPopupModal(popupName, statusFlags, function() -- 736
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 737
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 738
					return CloseCurrentPopup() -- 739
				end -- 738
			end) -- 736
			SameLine() -- 740
			if Button(zh and "使用默认" or "Use Default") then -- 741
				setWorkspace(Content.appPath) -- 742
			end -- 741
			Separator() -- 743
		end -- 707
		if isOSSLicenseExist then -- 744
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 745
				if not ossLicenses then -- 746
					ossLicenses = { } -- 747
					local licenseText = Content:load("LICENSES") -- 748
					ossLicenseOpen = (licenseText ~= nil) -- 749
					if ossLicenseOpen then -- 749
						licenseText = licenseText:gsub("\r\n", "\n") -- 750
						for license in GSplit(licenseText, "\n--------\n", true) do -- 751
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 752
							if name then -- 752
								ossLicenses[#ossLicenses + 1] = { -- 753
									name, -- 753
									text -- 753
								} -- 753
							end -- 752
						end -- 751
					end -- 749
				else -- 755
					ossLicenseOpen = true -- 755
				end -- 746
			end -- 745
			if ossLicenseOpen then -- 756
				local width, height, themeColor -- 757
				do -- 757
					local _obj_0 = App -- 757
					width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 757
				end -- 757
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 758
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 759
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 760
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 763
						"NoSavedSettings" -- 763
					}, function() -- 764
						for _index_0 = 1, #ossLicenses do -- 764
							local _des_0 = ossLicenses[_index_0] -- 764
							local firstLine, text = _des_0[1], _des_0[2] -- 764
							local name, license = firstLine:match("(.+): (.+)") -- 765
							TextColored(themeColor, name) -- 766
							SameLine() -- 767
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 768
								return TextWrapped(text) -- 768
							end) -- 768
						end -- 764
					end) -- 760
				end) -- 760
			end -- 756
		end -- 744
		if not App.debugging then -- 770
			return -- 770
		end -- 770
		return TreeNode(zh and "开发操作" or "Development", function() -- 771
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 772
				OpenPopup("build") -- 772
			end -- 772
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 773
				return BeginPopup("build", function() -- 773
					if Selectable(zh and "编译" or "Compile") then -- 774
						doCompile(false) -- 774
					end -- 774
					Separator() -- 775
					if Selectable(zh and "压缩" or "Minify") then -- 776
						doCompile(true) -- 776
					end -- 776
					Separator() -- 777
					if Selectable(zh and "清理" or "Clean") then -- 778
						return doClean() -- 778
					end -- 778
				end) -- 773
			end) -- 773
			if isInEntry then -- 779
				if waitForWebStart then -- 780
					BeginDisabled(function() -- 781
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 781
					end) -- 781
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 782
					reloadDevEntry() -- 783
				end -- 780
			end -- 779
			do -- 784
				local changed -- 784
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 784
				if changed then -- 784
					View.scale = scaleContent and screenScale or 1 -- 785
				end -- 784
			end -- 784
			do -- 786
				local changed -- 786
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 786
				if changed then -- 786
					config.engineDev = engineDev -- 787
				end -- 786
			end -- 786
			if testingThread then -- 788
				return BeginDisabled(function() -- 789
					return Button(zh and "开始自动测试" or "Test automatically") -- 789
				end) -- 789
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 790
				testingThread = thread(function() -- 791
					local _ <close> = setmetatable({ }, { -- 792
						__close = function() -- 792
							allClear() -- 793
							testingThread = nil -- 794
							isInEntry = true -- 795
							currentEntry = nil -- 796
							return print("Testing done!") -- 797
						end -- 792
					}) -- 792
					for _, entry in ipairs(allEntries) do -- 798
						allClear() -- 799
						print("Start " .. tostring(entry.entryName)) -- 800
						enterDemoEntry(entry) -- 801
						sleep(2) -- 802
						print("Stop " .. tostring(entry.entryName)) -- 803
					end -- 798
				end) -- 791
			end -- 788
		end) -- 771
	end -- 705
end -- 693
local icon = Path("Script", "Dev", "icon_s.png") -- 805
local iconTex = nil -- 806
thread(function() -- 807
	if Cache:loadAsync(icon) then -- 807
		iconTex = Texture2D(icon) -- 807
	end -- 807
end) -- 807
local webStatus = nil -- 809
local urlClicked = nil -- 810
local descColor = Color(0xffa1a1a1) -- 811
local transparant = Color(0x0) -- 813
local windowFlags = { -- 814
	"NoTitleBar", -- 814
	"NoResize", -- 814
	"NoMove", -- 814
	"NoCollapse", -- 814
	"NoSavedSettings", -- 814
	"NoFocusOnAppearing", -- 814
	"NoBringToFrontOnFocus" -- 814
} -- 814
local statusFlags = { -- 823
	"NoTitleBar", -- 823
	"NoResize", -- 823
	"NoMove", -- 823
	"NoCollapse", -- 823
	"AlwaysAutoResize", -- 823
	"NoSavedSettings" -- 823
} -- 823
local displayWindowFlags = { -- 831
	"NoDecoration", -- 831
	"NoSavedSettings", -- 831
	"NoNav", -- 831
	"NoMove", -- 831
	"NoScrollWithMouse", -- 831
	"AlwaysAutoResize", -- 831
	"NoFocusOnAppearing" -- 831
} -- 831
local initFooter = true -- 840
local _anon_func_4 = function(allEntries, currentIndex) -- 877
	if currentIndex > 1 then -- 877
		return allEntries[currentIndex - 1] -- 878
	else -- 880
		return allEntries[#allEntries] -- 880
	end -- 877
end -- 877
local _anon_func_5 = function(allEntries, currentIndex) -- 884
	if currentIndex < #allEntries then -- 884
		return allEntries[currentIndex + 1] -- 885
	else -- 887
		return allEntries[1] -- 887
	end -- 884
end -- 884
footerWindow = threadLoop(function() -- 841
	local zh = useChinese -- 842
	if HttpServer.wsConnectionCount > 0 then -- 843
		return -- 844
	end -- 843
	if Keyboard:isKeyDown("Escape") then -- 845
		allClear() -- 846
		App.devMode = false -- 847
		App:shutdown() -- 848
	end -- 845
	do -- 849
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 850
		if ctrl and Keyboard:isKeyDown("Q") then -- 851
			stop() -- 852
		end -- 851
		if ctrl and Keyboard:isKeyDown("Z") then -- 853
			reloadCurrentEntry() -- 854
		end -- 853
		if ctrl and Keyboard:isKeyDown(",") then -- 855
			if showFooter then -- 856
				showStats = not showStats -- 856
			else -- 856
				showStats = true -- 856
			end -- 856
			showFooter = true -- 857
			config.showFooter = showFooter -- 858
			config.showStats = showStats -- 859
		end -- 855
		if ctrl and Keyboard:isKeyDown(".") then -- 860
			if showFooter then -- 861
				showConsole = not showConsole -- 861
			else -- 861
				showConsole = true -- 861
			end -- 861
			showFooter = true -- 862
			config.showFooter = showFooter -- 863
			config.showConsole = showConsole -- 864
		end -- 860
		if ctrl and Keyboard:isKeyDown("/") then -- 865
			showFooter = not showFooter -- 866
			config.showFooter = showFooter -- 867
		end -- 865
		local left = ctrl and Keyboard:isKeyDown("Left") -- 868
		local right = ctrl and Keyboard:isKeyDown("Right") -- 869
		local currentIndex = nil -- 870
		for i, entry in ipairs(allEntries) do -- 871
			if currentEntry == entry then -- 872
				currentIndex = i -- 873
			end -- 872
		end -- 871
		if left then -- 874
			allClear() -- 875
			if currentIndex == nil then -- 876
				currentIndex = #allEntries + 1 -- 876
			end -- 876
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 877
		end -- 874
		if right then -- 881
			allClear() -- 882
			if currentIndex == nil then -- 883
				currentIndex = 0 -- 883
			end -- 883
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 884
		end -- 881
	end -- 849
	if not showEntry then -- 888
		return -- 888
	end -- 888
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 890
		reloadDevEntry() -- 894
	end -- 890
	if initFooter then -- 895
		initFooter = false -- 896
	end -- 895
	local width, height -- 898
	do -- 898
		local _obj_0 = App.visualSize -- 898
		width, height = _obj_0.width, _obj_0.height -- 898
	end -- 898
	if isInEntry or showFooter then -- 899
		SetNextWindowSize(Vec2(width, 50)) -- 900
		SetNextWindowPos(Vec2(0, height - 50)) -- 901
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 902
			return PushStyleVar("WindowRounding", 0, function() -- 903
				return Begin("Footer", windowFlags, function() -- 904
					Separator() -- 905
					if iconTex then -- 906
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 907
							showStats = not showStats -- 908
							config.showStats = showStats -- 909
						end -- 907
						SameLine() -- 910
						if Button(">_", Vec2(30, 30)) then -- 911
							showConsole = not showConsole -- 912
							config.showConsole = showConsole -- 913
						end -- 911
					end -- 906
					if isInEntry and config.updateNotification then -- 914
						SameLine() -- 915
						if ImGui.Button(zh and "更新可用" or "Update") then -- 916
							allClear() -- 917
							config.updateNotification = false -- 918
							enterDemoEntry({ -- 920
								entryName = "SelfUpdater", -- 920
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 921
							}) -- 919
						end -- 916
					end -- 914
					if not isInEntry then -- 922
						SameLine() -- 923
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 924
						local currentIndex = nil -- 925
						for i, entry in ipairs(allEntries) do -- 926
							if currentEntry == entry then -- 927
								currentIndex = i -- 928
							end -- 927
						end -- 926
						if currentIndex then -- 929
							if currentIndex > 1 then -- 930
								SameLine() -- 931
								if Button("<<", Vec2(30, 30)) then -- 932
									allClear() -- 933
									enterDemoEntry(allEntries[currentIndex - 1]) -- 934
								end -- 932
							end -- 930
							if currentIndex < #allEntries then -- 935
								SameLine() -- 936
								if Button(">>", Vec2(30, 30)) then -- 937
									allClear() -- 938
									enterDemoEntry(allEntries[currentIndex + 1]) -- 939
								end -- 937
							end -- 935
						end -- 929
						SameLine() -- 940
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 941
							reloadCurrentEntry() -- 942
						end -- 941
						if back then -- 943
							allClear() -- 944
							isInEntry = true -- 945
							currentEntry = nil -- 946
						end -- 943
					end -- 922
				end) -- 904
			end) -- 903
		end) -- 902
	end -- 899
	local showWebIDE = isInEntry -- 948
	if config.updateNotification then -- 949
		if width < 460 then -- 950
			showWebIDE = false -- 951
		end -- 950
	else -- 953
		if width < 360 then -- 953
			showWebIDE = false -- 954
		end -- 953
	end -- 949
	if showWebIDE then -- 955
		SetNextWindowBgAlpha(0.0) -- 956
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 957
		Begin("Web IDE", displayWindowFlags, function() -- 958
			do -- 959
				local url -- 959
				if webStatus ~= nil then -- 959
					url = webStatus.url -- 959
				end -- 959
				if url then -- 959
					if isDesktop and not config.fullScreen then -- 960
						if urlClicked then -- 961
							BeginDisabled(function() -- 962
								return Button(url) -- 962
							end) -- 962
						elseif Button(url) then -- 963
							urlClicked = once(function() -- 964
								return sleep(5) -- 964
							end) -- 964
							App:openURL("http://localhost:8866") -- 965
						end -- 961
					else -- 967
						TextColored(descColor, url) -- 967
					end -- 960
				else -- 969
					TextColored(descColor, zh and '不可用' or 'not available') -- 969
				end -- 959
			end -- 959
			SameLine() -- 970
			TextDisabled('(?)') -- 971
			if IsItemHovered() then -- 972
				return BeginTooltip(function() -- 973
					return PushTextWrapPos(280, function() -- 974
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 975
					end) -- 974
				end) -- 973
			end -- 972
		end) -- 958
	end -- 955
	if not isInEntry then -- 977
		SetNextWindowSize(Vec2(50, 50)) -- 978
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 979
		PushStyleColor("WindowBg", transparant, function() -- 980
			return Begin("Show", displayWindowFlags, function() -- 980
				if width >= 370 then -- 981
					local changed -- 982
					changed, showFooter = Checkbox("##dev", showFooter) -- 982
					if changed then -- 982
						config.showFooter = showFooter -- 983
					end -- 982
				end -- 981
			end) -- 980
		end) -- 980
	end -- 977
	if isInEntry or showFooter then -- 985
		if showStats then -- 986
			PushStyleVar("WindowRounding", 0, function() -- 987
				SetNextWindowPos(Vec2(0, 0), "Always") -- 988
				SetNextWindowSize(Vec2(0, height - 50)) -- 989
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 990
				config.showStats = showStats -- 991
			end) -- 987
		end -- 986
		if showConsole then -- 992
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 993
			return PushStyleVar("WindowRounding", 6, function() -- 994
				return ShowConsole() -- 995
			end) -- 994
		end -- 992
	end -- 985
end) -- 841
local MaxWidth <const> = 960 -- 997
local toolOpen = false -- 999
local filterText = nil -- 1000
local anyEntryMatched = false -- 1001
local match -- 1002
match = function(name) -- 1002
	local res = not filterText or name:lower():match(filterText) -- 1003
	if res then -- 1004
		anyEntryMatched = true -- 1004
	end -- 1004
	return res -- 1005
end -- 1002
local sep -- 1007
sep = function() -- 1007
	return SeparatorText("") -- 1007
end -- 1007
local thinSep -- 1008
thinSep = function() -- 1008
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1008
end -- 1008
entryWindow = threadLoop(function() -- 1010
	if App.fpsLimited ~= config.fpsLimited then -- 1011
		config.fpsLimited = App.fpsLimited -- 1012
	end -- 1011
	if App.targetFPS ~= config.targetFPS then -- 1013
		config.targetFPS = App.targetFPS -- 1014
	end -- 1013
	if View.vsync ~= config.vsync then -- 1015
		config.vsync = View.vsync -- 1016
	end -- 1015
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1017
		config.fixedFPS = Director.scheduler.fixedFPS -- 1018
	end -- 1017
	if Director.profilerSending ~= config.webProfiler then -- 1019
		config.webProfiler = Director.profilerSending -- 1020
	end -- 1019
	if urlClicked then -- 1021
		local _, result = coroutine.resume(urlClicked) -- 1022
		if result then -- 1023
			coroutine.close(urlClicked) -- 1024
			urlClicked = nil -- 1025
		end -- 1023
	end -- 1021
	if not showEntry then -- 1026
		return -- 1026
	end -- 1026
	if not isInEntry then -- 1027
		return -- 1027
	end -- 1027
	local zh = useChinese -- 1028
	if HttpServer.wsConnectionCount > 0 then -- 1029
		local themeColor = App.themeColor -- 1030
		local width, height -- 1031
		do -- 1031
			local _obj_0 = App.visualSize -- 1031
			width, height = _obj_0.width, _obj_0.height -- 1031
		end -- 1031
		SetNextWindowBgAlpha(0.5) -- 1032
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1033
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1034
			Separator() -- 1035
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1036
			if iconTex then -- 1037
				Image(icon, Vec2(24, 24)) -- 1038
				SameLine() -- 1039
			end -- 1037
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1040
			TextColored(descColor, slogon) -- 1041
			return Separator() -- 1042
		end) -- 1034
		return -- 1043
	end -- 1029
	local themeColor = App.themeColor -- 1045
	local fullWidth, height -- 1046
	do -- 1046
		local _obj_0 = App.visualSize -- 1046
		fullWidth, height = _obj_0.width, _obj_0.height -- 1046
	end -- 1046
	local width = math.min(MaxWidth, fullWidth) -- 1047
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1048
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1049
	SetNextWindowPos(Vec2.zero) -- 1050
	SetNextWindowBgAlpha(0) -- 1051
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1052
	do -- 1053
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1054
			return Begin("Dora Dev", windowFlags, function() -- 1055
				Dummy(Vec2(fullWidth - 20, 0)) -- 1056
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1057
				if fullWidth >= 400 then -- 1058
					SameLine() -- 1059
					Dummy(Vec2(fullWidth - 400, 0)) -- 1060
					SameLine() -- 1061
					SetNextItemWidth(zh and -95 or -140) -- 1062
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1063
						"AutoSelectAll" -- 1063
					}) then -- 1063
						config.filter = filterBuf.text -- 1064
					end -- 1063
					SameLine() -- 1065
					if Button(zh and '下载' or 'Download') then -- 1066
						allClear() -- 1067
						enterDemoEntry({ -- 1069
							entryName = "ResourceDownloader", -- 1069
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1070
						}) -- 1068
					end -- 1066
				end -- 1058
				Separator() -- 1071
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1072
			end) -- 1055
		end) -- 1054
	end -- 1053
	anyEntryMatched = false -- 1074
	SetNextWindowPos(Vec2(0, 50)) -- 1075
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1076
	do -- 1077
		return PushStyleColor("WindowBg", transparant, function() -- 1078
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1079
				return PushStyleVar("Alpha", 1, function() -- 1080
					return Begin("Content", windowFlags, function() -- 1081
						local DemoViewWidth <const> = 220 -- 1082
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1083
						if filterText then -- 1084
							filterText = filterText:lower() -- 1084
						end -- 1084
						if #gamesInDev > 0 then -- 1085
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1086
							Columns(columns, false) -- 1087
							local realViewWidth = GetColumnWidth() - 50 -- 1088
							for _index_0 = 1, #gamesInDev do -- 1089
								local game = gamesInDev[_index_0] -- 1089
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1090
								local displayName -- 1099
								if repo then -- 1099
									if zh then -- 1100
										displayName = repo.title.zh -- 1100
									else -- 1100
										displayName = repo.title.en -- 1100
									end -- 1100
								end -- 1099
								if displayName == nil then -- 1101
									displayName = gameName -- 1101
								end -- 1101
								if match(displayName) then -- 1102
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1103
									SameLine() -- 1104
									TextWrapped(displayName) -- 1105
									if columns > 1 then -- 1106
										if bannerFile then -- 1107
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1108
											local displayWidth <const> = realViewWidth -- 1109
											texHeight = displayWidth * texHeight / texWidth -- 1110
											texWidth = displayWidth -- 1111
											Dummy(Vec2.zero) -- 1112
											SameLine() -- 1113
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1114
										end -- 1107
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1115
											enterDemoEntry(game) -- 1116
										end -- 1115
									else -- 1118
										if bannerFile then -- 1118
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1119
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1120
											local sizing = 0.8 -- 1121
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1122
											texWidth = displayWidth * sizing -- 1123
											if texWidth > 500 then -- 1124
												sizing = 0.6 -- 1125
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1126
												texWidth = displayWidth * sizing -- 1127
											end -- 1124
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1128
											Dummy(Vec2(padding, 0)) -- 1129
											SameLine() -- 1130
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1131
										end -- 1118
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1132
											enterDemoEntry(game) -- 1133
										end -- 1132
									end -- 1106
									if #tests == 0 and #examples == 0 then -- 1134
										thinSep() -- 1135
									end -- 1134
									NextColumn() -- 1136
								end -- 1102
								local showSep = false -- 1137
								if #examples > 0 then -- 1138
									local showExample = false -- 1139
									do -- 1140
										local _accum_0 -- 1140
										for _index_1 = 1, #examples do -- 1140
											local _des_0 = examples[_index_1] -- 1140
											local entryName = _des_0.entryName -- 1140
											if match(entryName) then -- 1141
												_accum_0 = true -- 1141
												break -- 1141
											end -- 1141
										end -- 1140
										showExample = _accum_0 -- 1140
									end -- 1140
									if showExample then -- 1142
										showSep = true -- 1143
										Columns(1, false) -- 1144
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1145
										SameLine() -- 1146
										local opened -- 1147
										if (filterText ~= nil) then -- 1147
											opened = showExample -- 1147
										else -- 1147
											opened = false -- 1147
										end -- 1147
										if game.exampleOpen == nil then -- 1148
											game.exampleOpen = opened -- 1148
										end -- 1148
										SetNextItemOpen(game.exampleOpen) -- 1149
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1150
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1151
												Columns(maxColumns, false) -- 1152
												for _index_1 = 1, #examples do -- 1153
													local example = examples[_index_1] -- 1153
													local entryName = example.entryName -- 1154
													if not match(entryName) then -- 1155
														goto _continue_0 -- 1155
													end -- 1155
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1156
														if Button(entryName, Vec2(-1, 40)) then -- 1157
															enterDemoEntry(example) -- 1158
														end -- 1157
														return NextColumn() -- 1159
													end) -- 1156
													opened = true -- 1160
													::_continue_0:: -- 1154
												end -- 1153
											end) -- 1151
										end) -- 1150
										game.exampleOpen = opened -- 1161
									end -- 1142
								end -- 1138
								if #tests > 0 then -- 1162
									local showTest = false -- 1163
									do -- 1164
										local _accum_0 -- 1164
										for _index_1 = 1, #tests do -- 1164
											local _des_0 = tests[_index_1] -- 1164
											local entryName = _des_0.entryName -- 1164
											if match(entryName) then -- 1165
												_accum_0 = true -- 1165
												break -- 1165
											end -- 1165
										end -- 1164
										showTest = _accum_0 -- 1164
									end -- 1164
									if showTest then -- 1166
										showSep = true -- 1167
										Columns(1, false) -- 1168
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1169
										SameLine() -- 1170
										local opened -- 1171
										if (filterText ~= nil) then -- 1171
											opened = showTest -- 1171
										else -- 1171
											opened = false -- 1171
										end -- 1171
										if game.testOpen == nil then -- 1172
											game.testOpen = opened -- 1172
										end -- 1172
										SetNextItemOpen(game.testOpen) -- 1173
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1174
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1175
												Columns(maxColumns, false) -- 1176
												for _index_1 = 1, #tests do -- 1177
													local test = tests[_index_1] -- 1177
													local entryName = test.entryName -- 1178
													if not match(entryName) then -- 1179
														goto _continue_0 -- 1179
													end -- 1179
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1180
														if Button(entryName, Vec2(-1, 40)) then -- 1181
															enterDemoEntry(test) -- 1182
														end -- 1181
														return NextColumn() -- 1183
													end) -- 1180
													opened = true -- 1184
													::_continue_0:: -- 1178
												end -- 1177
											end) -- 1175
										end) -- 1174
										game.testOpen = opened -- 1185
									end -- 1166
								end -- 1162
								if showSep then -- 1186
									Columns(1, false) -- 1187
									thinSep() -- 1188
									Columns(columns, false) -- 1189
								end -- 1186
							end -- 1089
						end -- 1085
						if #doraTools > 0 then -- 1190
							local showTool = false -- 1191
							do -- 1192
								local _accum_0 -- 1192
								for _index_0 = 1, #doraTools do -- 1192
									local _des_0 = doraTools[_index_0] -- 1192
									local entryName = _des_0.entryName -- 1192
									if match(entryName) then -- 1193
										_accum_0 = true -- 1193
										break -- 1193
									end -- 1193
								end -- 1192
								showTool = _accum_0 -- 1192
							end -- 1192
							if not showTool then -- 1194
								goto endEntry -- 1194
							end -- 1194
							Columns(1, false) -- 1195
							TextColored(themeColor, "Dora SSR:") -- 1196
							SameLine() -- 1197
							Text(zh and "开发支持" or "Development Support") -- 1198
							Separator() -- 1199
							if #doraTools > 0 then -- 1200
								local opened -- 1201
								if (filterText ~= nil) then -- 1201
									opened = showTool -- 1201
								else -- 1201
									opened = false -- 1201
								end -- 1201
								SetNextItemOpen(toolOpen) -- 1202
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1203
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1204
										Columns(maxColumns, false) -- 1205
										for _index_0 = 1, #doraTools do -- 1206
											local example = doraTools[_index_0] -- 1206
											local entryName = example.entryName -- 1207
											if not match(entryName) then -- 1208
												goto _continue_0 -- 1208
											end -- 1208
											if Button(entryName, Vec2(-1, 40)) then -- 1209
												enterDemoEntry(example) -- 1210
											end -- 1209
											NextColumn() -- 1211
											::_continue_0:: -- 1207
										end -- 1206
										Columns(1, false) -- 1212
										opened = true -- 1213
									end) -- 1204
								end) -- 1203
								toolOpen = opened -- 1214
							end -- 1200
						end -- 1190
						::endEntry:: -- 1215
						if not anyEntryMatched then -- 1216
							SetNextWindowBgAlpha(0) -- 1217
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1218
							Begin("Entries Not Found", displayWindowFlags, function() -- 1219
								Separator() -- 1220
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1221
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1222
								return Separator() -- 1223
							end) -- 1219
						end -- 1216
						Columns(1, false) -- 1224
						Dummy(Vec2(100, 80)) -- 1225
						return ScrollWhenDraggingOnVoid() -- 1226
					end) -- 1081
				end) -- 1080
			end) -- 1079
		end) -- 1078
	end -- 1077
end) -- 1010
webStatus = require("Script.Dev.WebServer") -- 1228
return _module_0 -- 1
