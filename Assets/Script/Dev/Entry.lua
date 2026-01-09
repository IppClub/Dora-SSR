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
		local fileName = _des_0.fileName -- 354
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 355
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
			local yueCodes -- 411
			if not success then -- 412
				yueCodes = Content:load(input) -- 413
				if yueCodes then -- 413
					local CheckTIC80Code -- 414
					do -- 414
						local _obj_0 = require("Utils") -- 414
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 414
					end -- 414
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 415
					if isTIC80 then -- 416
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 417
					end -- 416
				end -- 413
			end -- 412
			if success then -- 418
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 419
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 420
				codes = codes:gsub("^\n*", "") -- 421
				if not (result == "") then -- 422
					result = result .. "\n" -- 422
				end -- 422
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 423
			else -- 425
				if yueCodes then -- 425
					local globalErrors = { } -- 426
					for _index_1 = 1, #result do -- 427
						local _des_1 = result[_index_1] -- 427
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 427
						local countLine = 1 -- 428
						local code = "" -- 429
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 430
							if countLine == line then -- 431
								code = lineCode -- 432
								break -- 433
							end -- 431
							countLine = countLine + 1 -- 434
						end -- 430
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 435
					end -- 427
					if #globalErrors > 0 then -- 436
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 436
					end -- 436
				else -- 438
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 438
				end -- 425
				if #errors == 0 then -- 439
					return codes -- 439
				end -- 439
			end -- 418
		end, function(success) -- 406
			if success then -- 440
				print("Yue compiled: " .. tostring(filename)) -- 440
			end -- 440
			fileCount = fileCount + 1 -- 441
		end) -- 406
	end -- 404
	thread(function() -- 443
		for _index_0 = 1, #xmlFiles do -- 444
			local _des_0 = xmlFiles[_index_0] -- 444
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 444
			local filename -- 445
			if gamePath then -- 445
				filename = Path(gamePath, file) -- 445
			else -- 445
				filename = file -- 445
			end -- 445
			local sourceCodes = Content:loadAsync(input) -- 446
			local codes, err = xml.tolua(sourceCodes) -- 447
			if not codes then -- 448
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 449
			else -- 451
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 451
				print("Xml compiled: " .. tostring(filename)) -- 452
			end -- 448
			fileCount = fileCount + 1 -- 453
		end -- 444
	end) -- 443
	thread(function() -- 455
		for _index_0 = 1, #tlFiles do -- 456
			local _des_0 = tlFiles[_index_0] -- 456
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 456
			local filename -- 457
			if gamePath then -- 457
				filename = Path(gamePath, file) -- 457
			else -- 457
				filename = file -- 457
			end -- 457
			local sourceCodes = Content:loadAsync(input) -- 458
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 459
			if not codes then -- 460
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 461
			else -- 463
				Content:saveAsync(output, codes) -- 463
				print("Teal compiled: " .. tostring(filename)) -- 464
			end -- 460
			fileCount = fileCount + 1 -- 465
		end -- 456
	end) -- 455
	return thread(function() -- 467
		wait(function() -- 468
			return fileCount == totalFiles -- 468
		end) -- 468
		if minify then -- 469
			local _list_0 = { -- 470
				yueFiles, -- 470
				xmlFiles, -- 470
				tlFiles -- 470
			} -- 470
			for _index_0 = 1, #_list_0 do -- 470
				local files = _list_0[_index_0] -- 470
				for _index_1 = 1, #files do -- 470
					local file = files[_index_1] -- 470
					local output = Path:replaceExt(file[3], "lua") -- 471
					luaFiles[#luaFiles + 1] = { -- 473
						Path:replaceExt(file[1], "lua"), -- 473
						output, -- 474
						output -- 475
					} -- 472
				end -- 470
			end -- 470
			local FormatMini -- 477
			do -- 477
				local _obj_0 = require("luaminify") -- 477
				FormatMini = _obj_0.FormatMini -- 477
			end -- 477
			for _index_0 = 1, #luaFiles do -- 478
				local _des_0 = luaFiles[_index_0] -- 478
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 478
				if Content:exist(input) then -- 479
					local sourceCodes = Content:loadAsync(input) -- 480
					local res, err = FormatMini(sourceCodes) -- 481
					if res then -- 482
						Content:saveAsync(output, res) -- 483
						print("Minify: " .. tostring(file)) -- 484
					else -- 486
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 486
					end -- 482
				else -- 488
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 488
				end -- 479
			end -- 478
			package.loaded["luaminify.FormatMini"] = nil -- 489
			package.loaded["luaminify.ParseLua"] = nil -- 490
			package.loaded["luaminify.Scope"] = nil -- 491
			package.loaded["luaminify.Util"] = nil -- 492
		end -- 469
		local errorMessage = table.concat(errors, "\n") -- 493
		if errorMessage ~= "" then -- 494
			print(errorMessage) -- 494
		end -- 494
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 495
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 496
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 497
		Content:clearPathCache() -- 498
		teal.clear() -- 499
		yue.clear() -- 500
		building = false -- 501
	end) -- 467
end -- 338
local doClean -- 503
doClean = function() -- 503
	if building then -- 504
		return -- 504
	end -- 504
	local writablePath = Content.writablePath -- 505
	local targetDir = Path(writablePath, ".build") -- 506
	Content:clearPathCache() -- 507
	if Content:remove(targetDir) then -- 508
		return print("Cleaned: " .. tostring(targetDir)) -- 509
	end -- 508
end -- 503
local screenScale = 2.0 -- 511
local scaleContent = false -- 512
local isInEntry = true -- 513
local currentEntry = nil -- 514
local footerWindow = nil -- 516
local entryWindow = nil -- 517
local testingThread = nil -- 518
local setupEventHandlers = nil -- 520
local allClear -- 522
allClear = function() -- 522
	local _list_0 = Routine -- 523
	for _index_0 = 1, #_list_0 do -- 523
		local routine = _list_0[_index_0] -- 523
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 525
			goto _continue_0 -- 526
		else -- 528
			Routine:remove(routine) -- 528
		end -- 524
		::_continue_0:: -- 524
	end -- 523
	for _index_0 = 1, #moduleCache do -- 529
		local module = moduleCache[_index_0] -- 529
		package.loaded[module] = nil -- 530
	end -- 529
	moduleCache = { } -- 531
	Director:cleanup() -- 532
	Entity:clear() -- 533
	Platformer.Data:clear() -- 534
	Platformer.UnitAction:clear() -- 535
	Audio:stopAll(0.2) -- 536
	Struct:clear() -- 537
	View.postEffect = nil -- 538
	View.scale = scaleContent and screenScale or 1 -- 539
	Director.clearColor = Color(0xff1a1a1a) -- 540
	teal.clear() -- 541
	yue.clear() -- 542
	for _, item in pairs(ubox()) do -- 543
		local node = tolua.cast(item, "Node") -- 544
		if node then -- 544
			node:cleanup() -- 544
		end -- 544
	end -- 543
	collectgarbage() -- 545
	collectgarbage() -- 546
	Wasm:clear() -- 547
	thread(function() -- 548
		sleep() -- 549
		return Cache:removeUnused() -- 550
	end) -- 548
	setupEventHandlers() -- 551
	Content.searchPaths = searchPaths -- 552
	App.idled = true -- 553
end -- 522
_module_0["allClear"] = allClear -- 522
local clearTempFiles -- 555
clearTempFiles = function() -- 555
	local writablePath = Content.writablePath -- 556
	Content:remove(Path(writablePath, ".upload")) -- 557
	return Content:remove(Path(writablePath, ".download")) -- 558
end -- 555
local waitForWebStart = true -- 560
thread(function() -- 561
	sleep(2) -- 562
	waitForWebStart = false -- 563
end) -- 561
local reloadDevEntry -- 565
reloadDevEntry = function() -- 565
	return thread(function() -- 565
		waitForWebStart = true -- 566
		doClean() -- 567
		allClear() -- 568
		_G.require = oldRequire -- 569
		Dora.require = oldRequire -- 570
		package.loaded["Script.Dev.Entry"] = nil -- 571
		return Director.systemScheduler:schedule(function() -- 572
			Routine:clear() -- 573
			oldRequire("Script.Dev.Entry") -- 574
			return true -- 575
		end) -- 572
	end) -- 565
end -- 565
local setWorkspace -- 577
setWorkspace = function(path) -- 577
	clearTempFiles() -- 578
	Content.writablePath = path -- 579
	config.writablePath = Content.writablePath -- 580
	return thread(function() -- 581
		sleep() -- 582
		return reloadDevEntry() -- 583
	end) -- 581
end -- 577
local quit = false -- 585
local stop -- 587
stop = function() -- 587
	if isInEntry then -- 588
		return false -- 588
	end -- 588
	allClear() -- 589
	isInEntry = true -- 590
	currentEntry = nil -- 591
	return true -- 592
end -- 587
_module_0["stop"] = stop -- 587
local _anon_func_1 = function(App, _with_0) -- 611
	local _val_0 = App.platform -- 611
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 611
end -- 611
setupEventHandlers = function() -- 594
	local _with_0 = Director.postNode -- 595
	_with_0:onAppEvent(function(eventType) -- 596
		if "Quit" == eventType then -- 597
			quit = true -- 598
			allClear() -- 599
			return clearTempFiles() -- 600
		elseif "Shutdown" == eventType then -- 601
			return stop() -- 602
		end -- 596
	end) -- 596
	_with_0:onAppChange(function(settingName) -- 603
		if "Theme" == settingName then -- 604
			config.themeColor = App.themeColor:toARGB() -- 605
		elseif "Locale" == settingName then -- 606
			config.locale = App.locale -- 607
			updateLocale() -- 608
			return teal.clear(true) -- 609
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 610
			if _anon_func_1(App, _with_0) then -- 611
				if "FullScreen" == settingName then -- 613
					config.fullScreen = App.fullScreen -- 613
				elseif "Position" == settingName then -- 614
					local _obj_0 = App.winPosition -- 614
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 614
				elseif "Size" == settingName then -- 615
					local width, height -- 616
					do -- 616
						local _obj_0 = App.winSize -- 616
						width, height = _obj_0.width, _obj_0.height -- 616
					end -- 616
					config.winWidth = width -- 617
					config.winHeight = height -- 618
				end -- 612
			end -- 611
		end -- 603
	end) -- 603
	_with_0:onAppWS(function(eventType) -- 619
		if eventType == "Close" then -- 619
			if HttpServer.wsConnectionCount == 0 then -- 620
				return updateEntries() -- 621
			end -- 620
		end -- 619
	end) -- 619
	_with_0:slot("UpdateEntries", function() -- 622
		return updateEntries() -- 622
	end) -- 622
	return _with_0 -- 595
end -- 594
setupEventHandlers() -- 624
clearTempFiles() -- 625
local downloadFile -- 627
downloadFile = function(url, target) -- 627
	return Director.systemScheduler:schedule(once(function() -- 627
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 628
			if quit then -- 629
				return true -- 629
			end -- 629
			emit("AppWS", "Send", json.encode({ -- 631
				name = "Download", -- 631
				url = url, -- 631
				status = "downloading", -- 631
				progress = current / total -- 632
			})) -- 630
			return false -- 628
		end) -- 628
		return emit("AppWS", "Send", json.encode(success and { -- 635
			name = "Download", -- 635
			url = url, -- 635
			status = "completed", -- 635
			progress = 1.0 -- 636
		} or { -- 638
			name = "Download", -- 638
			url = url, -- 638
			status = "failed", -- 638
			progress = 0.0 -- 639
		})) -- 634
	end)) -- 627
end -- 627
_module_0["downloadFile"] = downloadFile -- 627
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 650
	if workDir == nil then -- 650
		workDir = Path:getPath(file) -- 650
	end -- 650
	Content:insertSearchPath(1, workDir) -- 651
	local scriptPath = Path(workDir, "Script") -- 652
	if Content:exist(scriptPath) then -- 653
		Content:insertSearchPath(1, scriptPath) -- 654
	end -- 653
	local result = require(file) -- 655
	if "function" == type(result) then -- 656
		result() -- 656
	end -- 656
	return nil -- 657
end -- 650
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 686
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 686
	label.alignment = "Left" -- 687
	label.textWidth = width - fontSize -- 688
	label.text = err -- 689
	return label -- 686
end -- 686
local enterEntryAsync -- 642
enterEntryAsync = function(entry) -- 642
	isInEntry = false -- 643
	App.idled = false -- 644
	emit(Profiler.EventName, "ClearLoader") -- 645
	currentEntry = entry -- 646
	local file, workDir = entry.fileName, entry.workDir -- 647
	sleep() -- 648
	return xpcall(_anon_func_2, function(msg) -- 657
		local err = debug.traceback(msg) -- 659
		Log("Error", err) -- 660
		allClear() -- 661
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 662
		local viewWidth, viewHeight -- 663
		do -- 663
			local _obj_0 = View.size -- 663
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 663
		end -- 663
		local width, height = viewWidth - 20, viewHeight - 20 -- 664
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 665
		Director.ui:addChild((function() -- 666
			local root = AlignNode() -- 666
			do -- 667
				local _obj_0 = App.bufferSize -- 667
				width, height = _obj_0.width, _obj_0.height -- 667
			end -- 667
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 668
			root:onAppChange(function(settingName) -- 669
				if settingName == "Size" then -- 669
					do -- 670
						local _obj_0 = App.bufferSize -- 670
						width, height = _obj_0.width, _obj_0.height -- 670
					end -- 670
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 671
				end -- 669
			end) -- 669
			root:addChild((function() -- 672
				local _with_0 = ScrollArea({ -- 673
					width = width, -- 673
					height = height, -- 674
					paddingX = 0, -- 675
					paddingY = 50, -- 676
					viewWidth = height, -- 677
					viewHeight = height -- 678
				}) -- 672
				root:onAlignLayout(function(w, h) -- 680
					_with_0.position = Vec2(w / 2, h / 2) -- 681
					w = w - 20 -- 682
					h = h - 20 -- 683
					_with_0.view.children.first.textWidth = w - fontSize -- 684
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 685
				end) -- 680
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 686
				return _with_0 -- 672
			end)()) -- 672
			return root -- 666
		end)()) -- 666
		return err -- 690
	end, Content, Path, file, require, type, workDir) -- 649
end -- 642
_module_0["enterEntryAsync"] = enterEntryAsync -- 642
local enterDemoEntry -- 692
enterDemoEntry = function(entry) -- 692
	return thread(function() -- 692
		return enterEntryAsync(entry) -- 692
	end) -- 692
end -- 692
local reloadCurrentEntry -- 694
reloadCurrentEntry = function() -- 694
	if currentEntry then -- 695
		allClear() -- 696
		return enterDemoEntry(currentEntry) -- 697
	end -- 695
end -- 694
Director.clearColor = Color(0xff1a1a1a) -- 699
local extraOperations -- 701
do -- 701
	local isOSSLicenseExist = Content:exist("LICENSES") -- 702
	local ossLicenses = nil -- 703
	local ossLicenseOpen = false -- 704
	local failedSetFolder = false -- 705
	local statusFlags = { -- 706
		"NoResize", -- 706
		"NoMove", -- 706
		"NoCollapse", -- 706
		"AlwaysAutoResize", -- 706
		"NoSavedSettings" -- 706
	} -- 706
	extraOperations = function() -- 713
		local zh = useChinese -- 714
		if isDesktop then -- 715
			local themeColor = App.themeColor -- 716
			local alwaysOnTop, writablePath, showPreview = config.alwaysOnTop, config.writablePath, config.showPreview -- 717
			do -- 718
				local changed -- 718
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 718
				if changed then -- 718
					App.alwaysOnTop = alwaysOnTop -- 719
					config.alwaysOnTop = alwaysOnTop -- 720
				end -- 718
			end -- 718
			do -- 721
				local changed -- 721
				changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 721
				if changed then -- 721
					config.showPreview = showPreview -- 722
					updateEntries() -- 723
					if not showPreview then -- 724
						thread(function() -- 725
							collectgarbage() -- 726
							return Cache:removeUnused("Texture") -- 727
						end) -- 725
					end -- 724
				end -- 721
			end -- 721
			SeparatorText(zh and "工作目录" or "Workspace") -- 728
			PushTextWrapPos(400, function() -- 729
				return TextColored(themeColor, writablePath) -- 730
			end) -- 729
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 731
			if Button(zh and "改变目录" or "Set Folder") then -- 732
				App:openFileDialog(true, function(path) -- 733
					if path == "" then -- 734
						return -- 734
					end -- 734
					local relPath = Path:getRelative(Content.assetPath, path) -- 735
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 736
						return setWorkspace(path) -- 737
					else -- 739
						failedSetFolder = true -- 739
					end -- 736
				end) -- 733
			end -- 732
			if failedSetFolder then -- 740
				failedSetFolder = false -- 741
				OpenPopup(popupName) -- 742
			end -- 740
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 743
			BeginPopupModal(popupName, statusFlags, function() -- 744
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 745
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 746
					return CloseCurrentPopup() -- 747
				end -- 746
			end) -- 744
			SameLine() -- 748
			if Button(zh and "使用默认" or "Use Default") then -- 749
				setWorkspace(Content.appPath) -- 750
			end -- 749
			Separator() -- 751
		end -- 715
		if isOSSLicenseExist then -- 752
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 753
				if not ossLicenses then -- 754
					ossLicenses = { } -- 755
					local licenseText = Content:load("LICENSES") -- 756
					ossLicenseOpen = (licenseText ~= nil) -- 757
					if ossLicenseOpen then -- 757
						licenseText = licenseText:gsub("\r\n", "\n") -- 758
						for license in GSplit(licenseText, "\n--------\n", true) do -- 759
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 760
							if name then -- 760
								ossLicenses[#ossLicenses + 1] = { -- 761
									name, -- 761
									text -- 761
								} -- 761
							end -- 760
						end -- 759
					end -- 757
				else -- 763
					ossLicenseOpen = true -- 763
				end -- 754
			end -- 753
			if ossLicenseOpen then -- 764
				local width, height, themeColor -- 765
				do -- 765
					local _obj_0 = App -- 765
					width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 765
				end -- 765
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 766
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 767
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 768
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 771
						"NoSavedSettings" -- 771
					}, function() -- 772
						for _index_0 = 1, #ossLicenses do -- 772
							local _des_0 = ossLicenses[_index_0] -- 772
							local firstLine, text = _des_0[1], _des_0[2] -- 772
							local name, license = firstLine:match("(.+): (.+)") -- 773
							TextColored(themeColor, name) -- 774
							SameLine() -- 775
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 776
								return TextWrapped(text) -- 776
							end) -- 776
						end -- 772
					end) -- 768
				end) -- 768
			end -- 764
		end -- 752
		if not App.debugging then -- 778
			return -- 778
		end -- 778
		return TreeNode(zh and "开发操作" or "Development", function() -- 779
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 780
				OpenPopup("build") -- 780
			end -- 780
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 781
				return BeginPopup("build", function() -- 781
					if Selectable(zh and "编译" or "Compile") then -- 782
						doCompile(false) -- 782
					end -- 782
					Separator() -- 783
					if Selectable(zh and "压缩" or "Minify") then -- 784
						doCompile(true) -- 784
					end -- 784
					Separator() -- 785
					if Selectable(zh and "清理" or "Clean") then -- 786
						return doClean() -- 786
					end -- 786
				end) -- 781
			end) -- 781
			if isInEntry then -- 787
				if waitForWebStart then -- 788
					BeginDisabled(function() -- 789
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 789
					end) -- 789
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 790
					reloadDevEntry() -- 791
				end -- 788
			end -- 787
			do -- 792
				local changed -- 792
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 792
				if changed then -- 792
					View.scale = scaleContent and screenScale or 1 -- 793
				end -- 792
			end -- 792
			do -- 794
				local changed -- 794
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 794
				if changed then -- 794
					config.engineDev = engineDev -- 795
				end -- 794
			end -- 794
			if testingThread then -- 796
				return BeginDisabled(function() -- 797
					return Button(zh and "开始自动测试" or "Test automatically") -- 797
				end) -- 797
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 798
				testingThread = thread(function() -- 799
					local _ <close> = setmetatable({ }, { -- 800
						__close = function() -- 800
							allClear() -- 801
							testingThread = nil -- 802
							isInEntry = true -- 803
							currentEntry = nil -- 804
							return print("Testing done!") -- 805
						end -- 800
					}) -- 800
					for _, entry in ipairs(allEntries) do -- 806
						allClear() -- 807
						print("Start " .. tostring(entry.entryName)) -- 808
						enterDemoEntry(entry) -- 809
						sleep(2) -- 810
						print("Stop " .. tostring(entry.entryName)) -- 811
					end -- 806
				end) -- 799
			end -- 796
		end) -- 779
	end -- 713
end -- 701
local icon = Path("Script", "Dev", "icon_s.png") -- 813
local iconTex = nil -- 814
thread(function() -- 815
	if Cache:loadAsync(icon) then -- 815
		iconTex = Texture2D(icon) -- 815
	end -- 815
end) -- 815
local webStatus = nil -- 817
local urlClicked = nil -- 818
local descColor = Color(0xffa1a1a1) -- 819
local transparant = Color(0x0) -- 821
local windowFlags = { -- 822
	"NoTitleBar", -- 822
	"NoResize", -- 822
	"NoMove", -- 822
	"NoCollapse", -- 822
	"NoSavedSettings", -- 822
	"NoFocusOnAppearing", -- 822
	"NoBringToFrontOnFocus" -- 822
} -- 822
local statusFlags = { -- 831
	"NoTitleBar", -- 831
	"NoResize", -- 831
	"NoMove", -- 831
	"NoCollapse", -- 831
	"AlwaysAutoResize", -- 831
	"NoSavedSettings" -- 831
} -- 831
local displayWindowFlags = { -- 839
	"NoDecoration", -- 839
	"NoSavedSettings", -- 839
	"NoNav", -- 839
	"NoMove", -- 839
	"NoScrollWithMouse", -- 839
	"AlwaysAutoResize", -- 839
	"NoFocusOnAppearing" -- 839
} -- 839
local initFooter = true -- 848
local _anon_func_4 = function(allEntries, currentIndex) -- 885
	if currentIndex > 1 then -- 885
		return allEntries[currentIndex - 1] -- 886
	else -- 888
		return allEntries[#allEntries] -- 888
	end -- 885
end -- 885
local _anon_func_5 = function(allEntries, currentIndex) -- 892
	if currentIndex < #allEntries then -- 892
		return allEntries[currentIndex + 1] -- 893
	else -- 895
		return allEntries[1] -- 895
	end -- 892
end -- 892
footerWindow = threadLoop(function() -- 849
	local zh = useChinese -- 850
	if HttpServer.wsConnectionCount > 0 then -- 851
		return -- 852
	end -- 851
	if Keyboard:isKeyDown("Escape") then -- 853
		allClear() -- 854
		App.devMode = false -- 855
		App:shutdown() -- 856
	end -- 853
	do -- 857
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 858
		if ctrl and Keyboard:isKeyDown("Q") then -- 859
			stop() -- 860
		end -- 859
		if ctrl and Keyboard:isKeyDown("Z") then -- 861
			reloadCurrentEntry() -- 862
		end -- 861
		if ctrl and Keyboard:isKeyDown(",") then -- 863
			if showFooter then -- 864
				showStats = not showStats -- 864
			else -- 864
				showStats = true -- 864
			end -- 864
			showFooter = true -- 865
			config.showFooter = showFooter -- 866
			config.showStats = showStats -- 867
		end -- 863
		if ctrl and Keyboard:isKeyDown(".") then -- 868
			if showFooter then -- 869
				showConsole = not showConsole -- 869
			else -- 869
				showConsole = true -- 869
			end -- 869
			showFooter = true -- 870
			config.showFooter = showFooter -- 871
			config.showConsole = showConsole -- 872
		end -- 868
		if ctrl and Keyboard:isKeyDown("/") then -- 873
			showFooter = not showFooter -- 874
			config.showFooter = showFooter -- 875
		end -- 873
		local left = ctrl and Keyboard:isKeyDown("Left") -- 876
		local right = ctrl and Keyboard:isKeyDown("Right") -- 877
		local currentIndex = nil -- 878
		for i, entry in ipairs(allEntries) do -- 879
			if currentEntry == entry then -- 880
				currentIndex = i -- 881
			end -- 880
		end -- 879
		if left then -- 882
			allClear() -- 883
			if currentIndex == nil then -- 884
				currentIndex = #allEntries + 1 -- 884
			end -- 884
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 885
		end -- 882
		if right then -- 889
			allClear() -- 890
			if currentIndex == nil then -- 891
				currentIndex = 0 -- 891
			end -- 891
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 892
		end -- 889
	end -- 857
	if not showEntry then -- 896
		return -- 896
	end -- 896
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 898
		reloadDevEntry() -- 902
	end -- 898
	if initFooter then -- 903
		initFooter = false -- 904
	end -- 903
	local width, height -- 906
	do -- 906
		local _obj_0 = App.visualSize -- 906
		width, height = _obj_0.width, _obj_0.height -- 906
	end -- 906
	if isInEntry or showFooter then -- 907
		SetNextWindowSize(Vec2(width, 50)) -- 908
		SetNextWindowPos(Vec2(0, height - 50)) -- 909
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 910
			return PushStyleVar("WindowRounding", 0, function() -- 911
				return Begin("Footer", windowFlags, function() -- 912
					Separator() -- 913
					if iconTex then -- 914
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 915
							showStats = not showStats -- 916
							config.showStats = showStats -- 917
						end -- 915
						SameLine() -- 918
						if Button(">_", Vec2(30, 30)) then -- 919
							showConsole = not showConsole -- 920
							config.showConsole = showConsole -- 921
						end -- 919
					end -- 914
					if isInEntry and config.updateNotification then -- 922
						SameLine() -- 923
						if ImGui.Button(zh and "更新可用" or "Update") then -- 924
							allClear() -- 925
							config.updateNotification = false -- 926
							enterDemoEntry({ -- 928
								entryName = "SelfUpdater", -- 928
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 929
							}) -- 927
						end -- 924
					end -- 922
					if not isInEntry then -- 930
						SameLine() -- 931
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 932
						local currentIndex = nil -- 933
						for i, entry in ipairs(allEntries) do -- 934
							if currentEntry == entry then -- 935
								currentIndex = i -- 936
							end -- 935
						end -- 934
						if currentIndex then -- 937
							if currentIndex > 1 then -- 938
								SameLine() -- 939
								if Button("<<", Vec2(30, 30)) then -- 940
									allClear() -- 941
									enterDemoEntry(allEntries[currentIndex - 1]) -- 942
								end -- 940
							end -- 938
							if currentIndex < #allEntries then -- 943
								SameLine() -- 944
								if Button(">>", Vec2(30, 30)) then -- 945
									allClear() -- 946
									enterDemoEntry(allEntries[currentIndex + 1]) -- 947
								end -- 945
							end -- 943
						end -- 937
						SameLine() -- 948
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 949
							reloadCurrentEntry() -- 950
						end -- 949
						if back then -- 951
							allClear() -- 952
							isInEntry = true -- 953
							currentEntry = nil -- 954
						end -- 951
					end -- 930
				end) -- 912
			end) -- 911
		end) -- 910
	end -- 907
	local showWebIDE = isInEntry -- 956
	if config.updateNotification then -- 957
		if width < 460 then -- 958
			showWebIDE = false -- 959
		end -- 958
	else -- 961
		if width < 360 then -- 961
			showWebIDE = false -- 962
		end -- 961
	end -- 957
	if showWebIDE then -- 963
		SetNextWindowBgAlpha(0.0) -- 964
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 965
		Begin("Web IDE", displayWindowFlags, function() -- 966
			do -- 967
				local url -- 967
				if webStatus ~= nil then -- 967
					url = webStatus.url -- 967
				end -- 967
				if url then -- 967
					if isDesktop and not config.fullScreen then -- 968
						if urlClicked then -- 969
							BeginDisabled(function() -- 970
								return Button(url) -- 970
							end) -- 970
						elseif Button(url) then -- 971
							urlClicked = once(function() -- 972
								return sleep(5) -- 972
							end) -- 972
							App:openURL("http://localhost:8866") -- 973
						end -- 969
					else -- 975
						TextColored(descColor, url) -- 975
					end -- 968
				else -- 977
					TextColored(descColor, zh and '不可用' or 'not available') -- 977
				end -- 967
			end -- 967
			SameLine() -- 978
			TextDisabled('(?)') -- 979
			if IsItemHovered() then -- 980
				return BeginTooltip(function() -- 981
					return PushTextWrapPos(280, function() -- 982
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 983
					end) -- 982
				end) -- 981
			end -- 980
		end) -- 966
	end -- 963
	if not isInEntry then -- 985
		SetNextWindowSize(Vec2(50, 50)) -- 986
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 987
		PushStyleColor("WindowBg", transparant, function() -- 988
			return Begin("Show", displayWindowFlags, function() -- 988
				if width >= 370 then -- 989
					local changed -- 990
					changed, showFooter = Checkbox("##dev", showFooter) -- 990
					if changed then -- 990
						config.showFooter = showFooter -- 991
					end -- 990
				end -- 989
			end) -- 988
		end) -- 988
	end -- 985
	if isInEntry or showFooter then -- 993
		if showStats then -- 994
			PushStyleVar("WindowRounding", 0, function() -- 995
				SetNextWindowPos(Vec2(0, 0), "Always") -- 996
				SetNextWindowSize(Vec2(0, height - 50)) -- 997
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 998
				config.showStats = showStats -- 999
			end) -- 995
		end -- 994
		if showConsole then -- 1000
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1001
			return PushStyleVar("WindowRounding", 6, function() -- 1002
				return ShowConsole() -- 1003
			end) -- 1002
		end -- 1000
	end -- 993
end) -- 849
local MaxWidth <const> = 960 -- 1005
local toolOpen = false -- 1007
local filterText = nil -- 1008
local anyEntryMatched = false -- 1009
local match -- 1010
match = function(name) -- 1010
	local res = not filterText or name:lower():match(filterText) -- 1011
	if res then -- 1012
		anyEntryMatched = true -- 1012
	end -- 1012
	return res -- 1013
end -- 1010
local sep -- 1015
sep = function() -- 1015
	return SeparatorText("") -- 1015
end -- 1015
local thinSep -- 1016
thinSep = function() -- 1016
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1016
end -- 1016
entryWindow = threadLoop(function() -- 1018
	if App.fpsLimited ~= config.fpsLimited then -- 1019
		config.fpsLimited = App.fpsLimited -- 1020
	end -- 1019
	if App.targetFPS ~= config.targetFPS then -- 1021
		config.targetFPS = App.targetFPS -- 1022
	end -- 1021
	if View.vsync ~= config.vsync then -- 1023
		config.vsync = View.vsync -- 1024
	end -- 1023
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1025
		config.fixedFPS = Director.scheduler.fixedFPS -- 1026
	end -- 1025
	if Director.profilerSending ~= config.webProfiler then -- 1027
		config.webProfiler = Director.profilerSending -- 1028
	end -- 1027
	if urlClicked then -- 1029
		local _, result = coroutine.resume(urlClicked) -- 1030
		if result then -- 1031
			coroutine.close(urlClicked) -- 1032
			urlClicked = nil -- 1033
		end -- 1031
	end -- 1029
	if not showEntry then -- 1034
		return -- 1034
	end -- 1034
	if not isInEntry then -- 1035
		return -- 1035
	end -- 1035
	local zh = useChinese -- 1036
	if HttpServer.wsConnectionCount > 0 then -- 1037
		local themeColor = App.themeColor -- 1038
		local width, height -- 1039
		do -- 1039
			local _obj_0 = App.visualSize -- 1039
			width, height = _obj_0.width, _obj_0.height -- 1039
		end -- 1039
		SetNextWindowBgAlpha(0.5) -- 1040
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1041
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1042
			Separator() -- 1043
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1044
			if iconTex then -- 1045
				Image(icon, Vec2(24, 24)) -- 1046
				SameLine() -- 1047
			end -- 1045
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1048
			TextColored(descColor, slogon) -- 1049
			return Separator() -- 1050
		end) -- 1042
		return -- 1051
	end -- 1037
	local themeColor = App.themeColor -- 1053
	local fullWidth, height -- 1054
	do -- 1054
		local _obj_0 = App.visualSize -- 1054
		fullWidth, height = _obj_0.width, _obj_0.height -- 1054
	end -- 1054
	local width = math.min(MaxWidth, fullWidth) -- 1055
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1056
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1057
	SetNextWindowPos(Vec2.zero) -- 1058
	SetNextWindowBgAlpha(0) -- 1059
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1060
	do -- 1061
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1062
			return Begin("Dora Dev", windowFlags, function() -- 1063
				Dummy(Vec2(fullWidth - 20, 0)) -- 1064
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1065
				if fullWidth >= 400 then -- 1066
					SameLine() -- 1067
					Dummy(Vec2(fullWidth - 400, 0)) -- 1068
					SameLine() -- 1069
					SetNextItemWidth(zh and -95 or -140) -- 1070
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1071
						"AutoSelectAll" -- 1071
					}) then -- 1071
						config.filter = filterBuf.text -- 1072
					end -- 1071
					SameLine() -- 1073
					if Button(zh and '下载' or 'Download') then -- 1074
						allClear() -- 1075
						enterDemoEntry({ -- 1077
							entryName = "ResourceDownloader", -- 1077
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1078
						}) -- 1076
					end -- 1074
				end -- 1066
				Separator() -- 1079
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1080
			end) -- 1063
		end) -- 1062
	end -- 1061
	anyEntryMatched = false -- 1082
	SetNextWindowPos(Vec2(0, 50)) -- 1083
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1084
	do -- 1085
		return PushStyleColor("WindowBg", transparant, function() -- 1086
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1087
				return PushStyleVar("Alpha", 1, function() -- 1088
					return Begin("Content", windowFlags, function() -- 1089
						local DemoViewWidth <const> = 220 -- 1090
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1091
						if filterText then -- 1092
							filterText = filterText:lower() -- 1092
						end -- 1092
						if #gamesInDev > 0 then -- 1093
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1094
							Columns(columns, false) -- 1095
							local realViewWidth = GetColumnWidth() - 50 -- 1096
							for _index_0 = 1, #gamesInDev do -- 1097
								local game = gamesInDev[_index_0] -- 1097
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1098
								local displayName -- 1107
								if repo then -- 1107
									if zh then -- 1108
										displayName = repo.title.zh -- 1108
									else -- 1108
										displayName = repo.title.en -- 1108
									end -- 1108
								end -- 1107
								if displayName == nil then -- 1109
									displayName = gameName -- 1109
								end -- 1109
								if match(displayName) then -- 1110
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1111
									SameLine() -- 1112
									TextWrapped(displayName) -- 1113
									if columns > 1 then -- 1114
										if bannerFile then -- 1115
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1116
											local displayWidth <const> = realViewWidth -- 1117
											texHeight = displayWidth * texHeight / texWidth -- 1118
											texWidth = displayWidth -- 1119
											Dummy(Vec2.zero) -- 1120
											SameLine() -- 1121
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1122
										end -- 1115
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1123
											enterDemoEntry(game) -- 1124
										end -- 1123
									else -- 1126
										if bannerFile then -- 1126
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1127
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1128
											local sizing = 0.8 -- 1129
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1130
											texWidth = displayWidth * sizing -- 1131
											if texWidth > 500 then -- 1132
												sizing = 0.6 -- 1133
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1134
												texWidth = displayWidth * sizing -- 1135
											end -- 1132
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1136
											Dummy(Vec2(padding, 0)) -- 1137
											SameLine() -- 1138
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1139
										end -- 1126
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1140
											enterDemoEntry(game) -- 1141
										end -- 1140
									end -- 1114
									if #tests == 0 and #examples == 0 then -- 1142
										thinSep() -- 1143
									end -- 1142
									NextColumn() -- 1144
								end -- 1110
								local showSep = false -- 1145
								if #examples > 0 then -- 1146
									local showExample = false -- 1147
									do -- 1148
										local _accum_0 -- 1148
										for _index_1 = 1, #examples do -- 1148
											local _des_0 = examples[_index_1] -- 1148
											local entryName = _des_0.entryName -- 1148
											if match(entryName) then -- 1149
												_accum_0 = true -- 1149
												break -- 1149
											end -- 1149
										end -- 1148
										showExample = _accum_0 -- 1148
									end -- 1148
									if showExample then -- 1150
										showSep = true -- 1151
										Columns(1, false) -- 1152
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1153
										SameLine() -- 1154
										local opened -- 1155
										if (filterText ~= nil) then -- 1155
											opened = showExample -- 1155
										else -- 1155
											opened = false -- 1155
										end -- 1155
										if game.exampleOpen == nil then -- 1156
											game.exampleOpen = opened -- 1156
										end -- 1156
										SetNextItemOpen(game.exampleOpen) -- 1157
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1158
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1159
												Columns(maxColumns, false) -- 1160
												for _index_1 = 1, #examples do -- 1161
													local example = examples[_index_1] -- 1161
													local entryName = example.entryName -- 1162
													if not match(entryName) then -- 1163
														goto _continue_0 -- 1163
													end -- 1163
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1164
														if Button(entryName, Vec2(-1, 40)) then -- 1165
															enterDemoEntry(example) -- 1166
														end -- 1165
														return NextColumn() -- 1167
													end) -- 1164
													opened = true -- 1168
													::_continue_0:: -- 1162
												end -- 1161
											end) -- 1159
										end) -- 1158
										game.exampleOpen = opened -- 1169
									end -- 1150
								end -- 1146
								if #tests > 0 then -- 1170
									local showTest = false -- 1171
									do -- 1172
										local _accum_0 -- 1172
										for _index_1 = 1, #tests do -- 1172
											local _des_0 = tests[_index_1] -- 1172
											local entryName = _des_0.entryName -- 1172
											if match(entryName) then -- 1173
												_accum_0 = true -- 1173
												break -- 1173
											end -- 1173
										end -- 1172
										showTest = _accum_0 -- 1172
									end -- 1172
									if showTest then -- 1174
										showSep = true -- 1175
										Columns(1, false) -- 1176
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1177
										SameLine() -- 1178
										local opened -- 1179
										if (filterText ~= nil) then -- 1179
											opened = showTest -- 1179
										else -- 1179
											opened = false -- 1179
										end -- 1179
										if game.testOpen == nil then -- 1180
											game.testOpen = opened -- 1180
										end -- 1180
										SetNextItemOpen(game.testOpen) -- 1181
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1182
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1183
												Columns(maxColumns, false) -- 1184
												for _index_1 = 1, #tests do -- 1185
													local test = tests[_index_1] -- 1185
													local entryName = test.entryName -- 1186
													if not match(entryName) then -- 1187
														goto _continue_0 -- 1187
													end -- 1187
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1188
														if Button(entryName, Vec2(-1, 40)) then -- 1189
															enterDemoEntry(test) -- 1190
														end -- 1189
														return NextColumn() -- 1191
													end) -- 1188
													opened = true -- 1192
													::_continue_0:: -- 1186
												end -- 1185
											end) -- 1183
										end) -- 1182
										game.testOpen = opened -- 1193
									end -- 1174
								end -- 1170
								if showSep then -- 1194
									Columns(1, false) -- 1195
									thinSep() -- 1196
									Columns(columns, false) -- 1197
								end -- 1194
							end -- 1097
						end -- 1093
						if #doraTools > 0 then -- 1198
							local showTool = false -- 1199
							do -- 1200
								local _accum_0 -- 1200
								for _index_0 = 1, #doraTools do -- 1200
									local _des_0 = doraTools[_index_0] -- 1200
									local entryName = _des_0.entryName -- 1200
									if match(entryName) then -- 1201
										_accum_0 = true -- 1201
										break -- 1201
									end -- 1201
								end -- 1200
								showTool = _accum_0 -- 1200
							end -- 1200
							if not showTool then -- 1202
								goto endEntry -- 1202
							end -- 1202
							Columns(1, false) -- 1203
							TextColored(themeColor, "Dora SSR:") -- 1204
							SameLine() -- 1205
							Text(zh and "开发支持" or "Development Support") -- 1206
							Separator() -- 1207
							if #doraTools > 0 then -- 1208
								local opened -- 1209
								if (filterText ~= nil) then -- 1209
									opened = showTool -- 1209
								else -- 1209
									opened = false -- 1209
								end -- 1209
								SetNextItemOpen(toolOpen) -- 1210
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1211
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1212
										Columns(maxColumns, false) -- 1213
										for _index_0 = 1, #doraTools do -- 1214
											local example = doraTools[_index_0] -- 1214
											local entryName = example.entryName -- 1215
											if not match(entryName) then -- 1216
												goto _continue_0 -- 1216
											end -- 1216
											if Button(entryName, Vec2(-1, 40)) then -- 1217
												enterDemoEntry(example) -- 1218
											end -- 1217
											NextColumn() -- 1219
											::_continue_0:: -- 1215
										end -- 1214
										Columns(1, false) -- 1220
										opened = true -- 1221
									end) -- 1212
								end) -- 1211
								toolOpen = opened -- 1222
							end -- 1208
						end -- 1198
						::endEntry:: -- 1223
						if not anyEntryMatched then -- 1224
							SetNextWindowBgAlpha(0) -- 1225
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1226
							Begin("Entries Not Found", displayWindowFlags, function() -- 1227
								Separator() -- 1228
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1229
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1230
								return Separator() -- 1231
							end) -- 1227
						end -- 1224
						Columns(1, false) -- 1232
						Dummy(Vec2(100, 80)) -- 1233
						return ScrollWhenDraggingOnVoid() -- 1234
					end) -- 1089
				end) -- 1088
			end) -- 1087
		end) -- 1086
	end -- 1085
end) -- 1018
webStatus = require("Script.Dev.WebServer") -- 1236
return _module_0 -- 1
