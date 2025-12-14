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
	Content.writablePath = path -- 570
	config.writablePath = Content.writablePath -- 571
	return thread(function() -- 572
		sleep() -- 573
		return reloadDevEntry() -- 574
	end) -- 572
end -- 569
local quit = false -- 576
local stop -- 578
stop = function() -- 578
	if isInEntry then -- 579
		return false -- 579
	end -- 579
	allClear() -- 580
	isInEntry = true -- 581
	currentEntry = nil -- 582
	return true -- 583
end -- 578
_module_0["stop"] = stop -- 578
local _anon_func_1 = function(App, _with_0) -- 602
	local _val_0 = App.platform -- 602
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 602
end -- 602
setupEventHandlers = function() -- 585
	local _with_0 = Director.postNode -- 586
	_with_0:onAppEvent(function(eventType) -- 587
		if "Quit" == eventType then -- 588
			quit = true -- 589
			allClear() -- 590
			return clearTempFiles() -- 591
		elseif "Shutdown" == eventType then -- 592
			return stop() -- 593
		end -- 587
	end) -- 587
	_with_0:onAppChange(function(settingName) -- 594
		if "Theme" == settingName then -- 595
			config.themeColor = App.themeColor:toARGB() -- 596
		elseif "Locale" == settingName then -- 597
			config.locale = App.locale -- 598
			updateLocale() -- 599
			return teal.clear(true) -- 600
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 601
			if _anon_func_1(App, _with_0) then -- 602
				if "FullScreen" == settingName then -- 604
					config.fullScreen = App.fullScreen -- 604
				elseif "Position" == settingName then -- 605
					local _obj_0 = App.winPosition -- 605
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 605
				elseif "Size" == settingName then -- 606
					local width, height -- 607
					do -- 607
						local _obj_0 = App.winSize -- 607
						width, height = _obj_0.width, _obj_0.height -- 607
					end -- 607
					config.winWidth = width -- 608
					config.winHeight = height -- 609
				end -- 603
			end -- 602
		end -- 594
	end) -- 594
	_with_0:onAppWS(function(eventType) -- 610
		if eventType == "Close" then -- 610
			if HttpServer.wsConnectionCount == 0 then -- 611
				return updateEntries() -- 612
			end -- 611
		end -- 610
	end) -- 610
	_with_0:slot("UpdateEntries", function() -- 613
		return updateEntries() -- 613
	end) -- 613
	return _with_0 -- 586
end -- 585
setupEventHandlers() -- 615
clearTempFiles() -- 616
local downloadFile -- 618
downloadFile = function(url, target) -- 618
	return Director.systemScheduler:schedule(once(function() -- 618
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 619
			if quit then -- 620
				return true -- 620
			end -- 620
			emit("AppWS", "Send", json.encode({ -- 622
				name = "Download", -- 622
				url = url, -- 622
				status = "downloading", -- 622
				progress = current / total -- 623
			})) -- 621
			return false -- 619
		end) -- 619
		return emit("AppWS", "Send", json.encode(success and { -- 626
			name = "Download", -- 626
			url = url, -- 626
			status = "completed", -- 626
			progress = 1.0 -- 627
		} or { -- 629
			name = "Download", -- 629
			url = url, -- 629
			status = "failed", -- 629
			progress = 0.0 -- 630
		})) -- 625
	end)) -- 618
end -- 618
_module_0["downloadFile"] = downloadFile -- 618
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 641
	if workDir == nil then -- 641
		workDir = Path:getPath(file) -- 641
	end -- 641
	Content:insertSearchPath(1, workDir) -- 642
	local scriptPath = Path(workDir, "Script") -- 643
	if Content:exist(scriptPath) then -- 644
		Content:insertSearchPath(1, scriptPath) -- 645
	end -- 644
	local result = require(file) -- 646
	if "function" == type(result) then -- 647
		result() -- 647
	end -- 647
	return nil -- 648
end -- 641
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 677
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 677
	label.alignment = "Left" -- 678
	label.textWidth = width - fontSize -- 679
	label.text = err -- 680
	return label -- 677
end -- 677
local enterEntryAsync -- 633
enterEntryAsync = function(entry) -- 633
	isInEntry = false -- 634
	App.idled = false -- 635
	emit(Profiler.EventName, "ClearLoader") -- 636
	currentEntry = entry -- 637
	local file, workDir = entry.fileName, entry.workDir -- 638
	sleep() -- 639
	return xpcall(_anon_func_2, function(msg) -- 648
		local err = debug.traceback(msg) -- 650
		Log("Error", err) -- 651
		allClear() -- 652
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 653
		local viewWidth, viewHeight -- 654
		do -- 654
			local _obj_0 = View.size -- 654
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 654
		end -- 654
		local width, height = viewWidth - 20, viewHeight - 20 -- 655
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 656
		Director.ui:addChild((function() -- 657
			local root = AlignNode() -- 657
			do -- 658
				local _obj_0 = App.bufferSize -- 658
				width, height = _obj_0.width, _obj_0.height -- 658
			end -- 658
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 659
			root:onAppChange(function(settingName) -- 660
				if settingName == "Size" then -- 660
					do -- 661
						local _obj_0 = App.bufferSize -- 661
						width, height = _obj_0.width, _obj_0.height -- 661
					end -- 661
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 662
				end -- 660
			end) -- 660
			root:addChild((function() -- 663
				local _with_0 = ScrollArea({ -- 664
					width = width, -- 664
					height = height, -- 665
					paddingX = 0, -- 666
					paddingY = 50, -- 667
					viewWidth = height, -- 668
					viewHeight = height -- 669
				}) -- 663
				root:onAlignLayout(function(w, h) -- 671
					_with_0.position = Vec2(w / 2, h / 2) -- 672
					w = w - 20 -- 673
					h = h - 20 -- 674
					_with_0.view.children.first.textWidth = w - fontSize -- 675
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 676
				end) -- 671
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 677
				return _with_0 -- 663
			end)()) -- 663
			return root -- 657
		end)()) -- 657
		return err -- 681
	end, Content, Path, file, require, type, workDir) -- 640
end -- 633
_module_0["enterEntryAsync"] = enterEntryAsync -- 633
local enterDemoEntry -- 683
enterDemoEntry = function(entry) -- 683
	return thread(function() -- 683
		return enterEntryAsync(entry) -- 683
	end) -- 683
end -- 683
local reloadCurrentEntry -- 685
reloadCurrentEntry = function() -- 685
	if currentEntry then -- 686
		allClear() -- 687
		return enterDemoEntry(currentEntry) -- 688
	end -- 686
end -- 685
Director.clearColor = Color(0xff1a1a1a) -- 690
local extraOperations -- 692
do -- 692
	local isOSSLicenseExist = Content:exist("LICENSES") -- 693
	local ossLicenses = nil -- 694
	local ossLicenseOpen = false -- 695
	local failedSetFolder = false -- 696
	local statusFlags = { -- 697
		"NoResize", -- 697
		"NoMove", -- 697
		"NoCollapse", -- 697
		"AlwaysAutoResize", -- 697
		"NoSavedSettings" -- 697
	} -- 697
	extraOperations = function() -- 704
		local zh = useChinese -- 705
		if isDesktop then -- 706
			local themeColor = App.themeColor -- 707
			local alwaysOnTop, writablePath, showPreview = config.alwaysOnTop, config.writablePath, config.showPreview -- 708
			do -- 709
				local changed -- 709
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 709
				if changed then -- 709
					App.alwaysOnTop = alwaysOnTop -- 710
					config.alwaysOnTop = alwaysOnTop -- 711
				end -- 709
			end -- 709
			do -- 712
				local changed -- 712
				changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 712
				if changed then -- 712
					config.showPreview = showPreview -- 713
					updateEntries() -- 714
					if not showPreview then -- 715
						thread(function() -- 716
							collectgarbage() -- 717
							return Cache:removeUnused("Texture") -- 718
						end) -- 716
					end -- 715
				end -- 712
			end -- 712
			SeparatorText(zh and "工作目录" or "Workspace") -- 719
			PushTextWrapPos(400, function() -- 720
				return TextColored(themeColor, writablePath) -- 721
			end) -- 720
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 722
			if Button(zh and "改变目录" or "Set Folder") then -- 723
				App:openFileDialog(true, function(path) -- 724
					if path == "" then -- 725
						return -- 725
					end -- 725
					local relPath = Path:getRelative(Content.assetPath, path) -- 726
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 727
						return setWorkspace(path) -- 728
					else -- 730
						failedSetFolder = true -- 730
					end -- 727
				end) -- 724
			end -- 723
			if failedSetFolder then -- 731
				failedSetFolder = false -- 732
				OpenPopup(popupName) -- 733
			end -- 731
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 734
			BeginPopupModal(popupName, statusFlags, function() -- 735
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 736
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 737
					return CloseCurrentPopup() -- 738
				end -- 737
			end) -- 735
			SameLine() -- 739
			if Button(zh and "使用默认" or "Use Default") then -- 740
				setWorkspace(Content.appPath) -- 741
			end -- 740
			Separator() -- 742
		end -- 706
		if isOSSLicenseExist then -- 743
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 744
				if not ossLicenses then -- 745
					ossLicenses = { } -- 746
					local licenseText = Content:load("LICENSES") -- 747
					ossLicenseOpen = (licenseText ~= nil) -- 748
					if ossLicenseOpen then -- 748
						licenseText = licenseText:gsub("\r\n", "\n") -- 749
						for license in GSplit(licenseText, "\n--------\n", true) do -- 750
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 751
							if name then -- 751
								ossLicenses[#ossLicenses + 1] = { -- 752
									name, -- 752
									text -- 752
								} -- 752
							end -- 751
						end -- 750
					end -- 748
				else -- 754
					ossLicenseOpen = true -- 754
				end -- 745
			end -- 744
			if ossLicenseOpen then -- 755
				local width, height, themeColor -- 756
				do -- 756
					local _obj_0 = App -- 756
					width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 756
				end -- 756
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 757
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 758
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 759
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 762
						"NoSavedSettings" -- 762
					}, function() -- 763
						for _index_0 = 1, #ossLicenses do -- 763
							local _des_0 = ossLicenses[_index_0] -- 763
							local firstLine, text = _des_0[1], _des_0[2] -- 763
							local name, license = firstLine:match("(.+): (.+)") -- 764
							TextColored(themeColor, name) -- 765
							SameLine() -- 766
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 767
								return TextWrapped(text) -- 767
							end) -- 767
						end -- 763
					end) -- 759
				end) -- 759
			end -- 755
		end -- 743
		if not App.debugging then -- 769
			return -- 769
		end -- 769
		return TreeNode(zh and "开发操作" or "Development", function() -- 770
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 771
				OpenPopup("build") -- 771
			end -- 771
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 772
				return BeginPopup("build", function() -- 772
					if Selectable(zh and "编译" or "Compile") then -- 773
						doCompile(false) -- 773
					end -- 773
					Separator() -- 774
					if Selectable(zh and "压缩" or "Minify") then -- 775
						doCompile(true) -- 775
					end -- 775
					Separator() -- 776
					if Selectable(zh and "清理" or "Clean") then -- 777
						return doClean() -- 777
					end -- 777
				end) -- 772
			end) -- 772
			if isInEntry then -- 778
				if waitForWebStart then -- 779
					BeginDisabled(function() -- 780
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 780
					end) -- 780
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 781
					reloadDevEntry() -- 782
				end -- 779
			end -- 778
			do -- 783
				local changed -- 783
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 783
				if changed then -- 783
					View.scale = scaleContent and screenScale or 1 -- 784
				end -- 783
			end -- 783
			do -- 785
				local changed -- 785
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 785
				if changed then -- 785
					config.engineDev = engineDev -- 786
				end -- 785
			end -- 785
			if testingThread then -- 787
				return BeginDisabled(function() -- 788
					return Button(zh and "开始自动测试" or "Test automatically") -- 788
				end) -- 788
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 789
				testingThread = thread(function() -- 790
					local _ <close> = setmetatable({ }, { -- 791
						__close = function() -- 791
							allClear() -- 792
							testingThread = nil -- 793
							isInEntry = true -- 794
							currentEntry = nil -- 795
							return print("Testing done!") -- 796
						end -- 791
					}) -- 791
					for _, entry in ipairs(allEntries) do -- 797
						allClear() -- 798
						print("Start " .. tostring(entry.entryName)) -- 799
						enterDemoEntry(entry) -- 800
						sleep(2) -- 801
						print("Stop " .. tostring(entry.entryName)) -- 802
					end -- 797
				end) -- 790
			end -- 787
		end) -- 770
	end -- 704
end -- 692
local icon = Path("Script", "Dev", "icon_s.png") -- 804
local iconTex = nil -- 805
thread(function() -- 806
	if Cache:loadAsync(icon) then -- 806
		iconTex = Texture2D(icon) -- 806
	end -- 806
end) -- 806
local webStatus = nil -- 808
local urlClicked = nil -- 809
local descColor = Color(0xffa1a1a1) -- 810
local transparant = Color(0x0) -- 812
local windowFlags = { -- 813
	"NoTitleBar", -- 813
	"NoResize", -- 813
	"NoMove", -- 813
	"NoCollapse", -- 813
	"NoSavedSettings", -- 813
	"NoFocusOnAppearing", -- 813
	"NoBringToFrontOnFocus" -- 813
} -- 813
local statusFlags = { -- 822
	"NoTitleBar", -- 822
	"NoResize", -- 822
	"NoMove", -- 822
	"NoCollapse", -- 822
	"AlwaysAutoResize", -- 822
	"NoSavedSettings" -- 822
} -- 822
local displayWindowFlags = { -- 830
	"NoDecoration", -- 830
	"NoSavedSettings", -- 830
	"NoNav", -- 830
	"NoMove", -- 830
	"NoScrollWithMouse", -- 830
	"AlwaysAutoResize", -- 830
	"NoFocusOnAppearing" -- 830
} -- 830
local initFooter = true -- 839
local _anon_func_4 = function(allEntries, currentIndex) -- 876
	if currentIndex > 1 then -- 876
		return allEntries[currentIndex - 1] -- 877
	else -- 879
		return allEntries[#allEntries] -- 879
	end -- 876
end -- 876
local _anon_func_5 = function(allEntries, currentIndex) -- 883
	if currentIndex < #allEntries then -- 883
		return allEntries[currentIndex + 1] -- 884
	else -- 886
		return allEntries[1] -- 886
	end -- 883
end -- 883
footerWindow = threadLoop(function() -- 840
	local zh = useChinese -- 841
	if HttpServer.wsConnectionCount > 0 then -- 842
		return -- 843
	end -- 842
	if Keyboard:isKeyDown("Escape") then -- 844
		allClear() -- 845
		App.devMode = false -- 846
		App:shutdown() -- 847
	end -- 844
	do -- 848
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 849
		if ctrl and Keyboard:isKeyDown("Q") then -- 850
			stop() -- 851
		end -- 850
		if ctrl and Keyboard:isKeyDown("Z") then -- 852
			reloadCurrentEntry() -- 853
		end -- 852
		if ctrl and Keyboard:isKeyDown(",") then -- 854
			if showFooter then -- 855
				showStats = not showStats -- 855
			else -- 855
				showStats = true -- 855
			end -- 855
			showFooter = true -- 856
			config.showFooter = showFooter -- 857
			config.showStats = showStats -- 858
		end -- 854
		if ctrl and Keyboard:isKeyDown(".") then -- 859
			if showFooter then -- 860
				showConsole = not showConsole -- 860
			else -- 860
				showConsole = true -- 860
			end -- 860
			showFooter = true -- 861
			config.showFooter = showFooter -- 862
			config.showConsole = showConsole -- 863
		end -- 859
		if ctrl and Keyboard:isKeyDown("/") then -- 864
			showFooter = not showFooter -- 865
			config.showFooter = showFooter -- 866
		end -- 864
		local left = ctrl and Keyboard:isKeyDown("Left") -- 867
		local right = ctrl and Keyboard:isKeyDown("Right") -- 868
		local currentIndex = nil -- 869
		for i, entry in ipairs(allEntries) do -- 870
			if currentEntry == entry then -- 871
				currentIndex = i -- 872
			end -- 871
		end -- 870
		if left then -- 873
			allClear() -- 874
			if currentIndex == nil then -- 875
				currentIndex = #allEntries + 1 -- 875
			end -- 875
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 876
		end -- 873
		if right then -- 880
			allClear() -- 881
			if currentIndex == nil then -- 882
				currentIndex = 0 -- 882
			end -- 882
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 883
		end -- 880
	end -- 848
	if not showEntry then -- 887
		return -- 887
	end -- 887
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 889
		reloadDevEntry() -- 893
	end -- 889
	if initFooter then -- 894
		initFooter = false -- 895
	end -- 894
	local width, height -- 897
	do -- 897
		local _obj_0 = App.visualSize -- 897
		width, height = _obj_0.width, _obj_0.height -- 897
	end -- 897
	if isInEntry or showFooter then -- 898
		SetNextWindowSize(Vec2(width, 50)) -- 899
		SetNextWindowPos(Vec2(0, height - 50)) -- 900
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 901
			return PushStyleVar("WindowRounding", 0, function() -- 902
				return Begin("Footer", windowFlags, function() -- 903
					Separator() -- 904
					if iconTex then -- 905
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 906
							showStats = not showStats -- 907
							config.showStats = showStats -- 908
						end -- 906
						SameLine() -- 909
						if Button(">_", Vec2(30, 30)) then -- 910
							showConsole = not showConsole -- 911
							config.showConsole = showConsole -- 912
						end -- 910
					end -- 905
					if isInEntry and config.updateNotification then -- 913
						SameLine() -- 914
						if ImGui.Button(zh and "更新可用" or "Update") then -- 915
							allClear() -- 916
							config.updateNotification = false -- 917
							enterDemoEntry({ -- 919
								entryName = "SelfUpdater", -- 919
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 920
							}) -- 918
						end -- 915
					end -- 913
					if not isInEntry then -- 921
						SameLine() -- 922
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 923
						local currentIndex = nil -- 924
						for i, entry in ipairs(allEntries) do -- 925
							if currentEntry == entry then -- 926
								currentIndex = i -- 927
							end -- 926
						end -- 925
						if currentIndex then -- 928
							if currentIndex > 1 then -- 929
								SameLine() -- 930
								if Button("<<", Vec2(30, 30)) then -- 931
									allClear() -- 932
									enterDemoEntry(allEntries[currentIndex - 1]) -- 933
								end -- 931
							end -- 929
							if currentIndex < #allEntries then -- 934
								SameLine() -- 935
								if Button(">>", Vec2(30, 30)) then -- 936
									allClear() -- 937
									enterDemoEntry(allEntries[currentIndex + 1]) -- 938
								end -- 936
							end -- 934
						end -- 928
						SameLine() -- 939
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 940
							reloadCurrentEntry() -- 941
						end -- 940
						if back then -- 942
							allClear() -- 943
							isInEntry = true -- 944
							currentEntry = nil -- 945
						end -- 942
					end -- 921
				end) -- 903
			end) -- 902
		end) -- 901
	end -- 898
	local showWebIDE = isInEntry -- 947
	if config.updateNotification then -- 948
		if width < 460 then -- 949
			showWebIDE = false -- 950
		end -- 949
	else -- 952
		if width < 360 then -- 952
			showWebIDE = false -- 953
		end -- 952
	end -- 948
	if showWebIDE then -- 954
		SetNextWindowBgAlpha(0.0) -- 955
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 956
		Begin("Web IDE", displayWindowFlags, function() -- 957
			do -- 958
				local url -- 958
				if webStatus ~= nil then -- 958
					url = webStatus.url -- 958
				end -- 958
				if url then -- 958
					if isDesktop and not config.fullScreen then -- 959
						if urlClicked then -- 960
							BeginDisabled(function() -- 961
								return Button(url) -- 961
							end) -- 961
						elseif Button(url) then -- 962
							urlClicked = once(function() -- 963
								return sleep(5) -- 963
							end) -- 963
							App:openURL("http://localhost:8866") -- 964
						end -- 960
					else -- 966
						TextColored(descColor, url) -- 966
					end -- 959
				else -- 968
					TextColored(descColor, zh and '不可用' or 'not available') -- 968
				end -- 958
			end -- 958
			SameLine() -- 969
			TextDisabled('(?)') -- 970
			if IsItemHovered() then -- 971
				return BeginTooltip(function() -- 972
					return PushTextWrapPos(280, function() -- 973
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 974
					end) -- 973
				end) -- 972
			end -- 971
		end) -- 957
	end -- 954
	if not isInEntry then -- 976
		SetNextWindowSize(Vec2(50, 50)) -- 977
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 978
		PushStyleColor("WindowBg", transparant, function() -- 979
			return Begin("Show", displayWindowFlags, function() -- 979
				if width >= 370 then -- 980
					local changed -- 981
					changed, showFooter = Checkbox("##dev", showFooter) -- 981
					if changed then -- 981
						config.showFooter = showFooter -- 982
					end -- 981
				end -- 980
			end) -- 979
		end) -- 979
	end -- 976
	if isInEntry or showFooter then -- 984
		if showStats then -- 985
			PushStyleVar("WindowRounding", 0, function() -- 986
				SetNextWindowPos(Vec2(0, 0), "Always") -- 987
				SetNextWindowSize(Vec2(0, height - 50)) -- 988
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 989
				config.showStats = showStats -- 990
			end) -- 986
		end -- 985
		if showConsole then -- 991
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 992
			return PushStyleVar("WindowRounding", 6, function() -- 993
				return ShowConsole() -- 994
			end) -- 993
		end -- 991
	end -- 984
end) -- 840
local MaxWidth <const> = 960 -- 996
local toolOpen = false -- 998
local filterText = nil -- 999
local anyEntryMatched = false -- 1000
local match -- 1001
match = function(name) -- 1001
	local res = not filterText or name:lower():match(filterText) -- 1002
	if res then -- 1003
		anyEntryMatched = true -- 1003
	end -- 1003
	return res -- 1004
end -- 1001
local sep -- 1006
sep = function() -- 1006
	return SeparatorText("") -- 1006
end -- 1006
local thinSep -- 1007
thinSep = function() -- 1007
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1007
end -- 1007
entryWindow = threadLoop(function() -- 1009
	if App.fpsLimited ~= config.fpsLimited then -- 1010
		config.fpsLimited = App.fpsLimited -- 1011
	end -- 1010
	if App.targetFPS ~= config.targetFPS then -- 1012
		config.targetFPS = App.targetFPS -- 1013
	end -- 1012
	if View.vsync ~= config.vsync then -- 1014
		config.vsync = View.vsync -- 1015
	end -- 1014
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1016
		config.fixedFPS = Director.scheduler.fixedFPS -- 1017
	end -- 1016
	if Director.profilerSending ~= config.webProfiler then -- 1018
		config.webProfiler = Director.profilerSending -- 1019
	end -- 1018
	if urlClicked then -- 1020
		local _, result = coroutine.resume(urlClicked) -- 1021
		if result then -- 1022
			coroutine.close(urlClicked) -- 1023
			urlClicked = nil -- 1024
		end -- 1022
	end -- 1020
	if not showEntry then -- 1025
		return -- 1025
	end -- 1025
	if not isInEntry then -- 1026
		return -- 1026
	end -- 1026
	local zh = useChinese -- 1027
	if HttpServer.wsConnectionCount > 0 then -- 1028
		local themeColor = App.themeColor -- 1029
		local width, height -- 1030
		do -- 1030
			local _obj_0 = App.visualSize -- 1030
			width, height = _obj_0.width, _obj_0.height -- 1030
		end -- 1030
		SetNextWindowBgAlpha(0.5) -- 1031
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1032
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1033
			Separator() -- 1034
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1035
			if iconTex then -- 1036
				Image(icon, Vec2(24, 24)) -- 1037
				SameLine() -- 1038
			end -- 1036
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1039
			TextColored(descColor, slogon) -- 1040
			return Separator() -- 1041
		end) -- 1033
		return -- 1042
	end -- 1028
	local themeColor = App.themeColor -- 1044
	local fullWidth, height -- 1045
	do -- 1045
		local _obj_0 = App.visualSize -- 1045
		fullWidth, height = _obj_0.width, _obj_0.height -- 1045
	end -- 1045
	local width = math.min(MaxWidth, fullWidth) -- 1046
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1047
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1048
	SetNextWindowPos(Vec2.zero) -- 1049
	SetNextWindowBgAlpha(0) -- 1050
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1051
	do -- 1052
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1053
			return Begin("Dora Dev", windowFlags, function() -- 1054
				Dummy(Vec2(fullWidth - 20, 0)) -- 1055
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1056
				if fullWidth >= 400 then -- 1057
					SameLine() -- 1058
					Dummy(Vec2(fullWidth - 400, 0)) -- 1059
					SameLine() -- 1060
					SetNextItemWidth(zh and -95 or -140) -- 1061
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1062
						"AutoSelectAll" -- 1062
					}) then -- 1062
						config.filter = filterBuf.text -- 1063
					end -- 1062
					SameLine() -- 1064
					if Button(zh and '下载' or 'Download') then -- 1065
						allClear() -- 1066
						enterDemoEntry({ -- 1068
							entryName = "ResourceDownloader", -- 1068
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1069
						}) -- 1067
					end -- 1065
				end -- 1057
				Separator() -- 1070
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1071
			end) -- 1054
		end) -- 1053
	end -- 1052
	anyEntryMatched = false -- 1073
	SetNextWindowPos(Vec2(0, 50)) -- 1074
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1075
	do -- 1076
		return PushStyleColor("WindowBg", transparant, function() -- 1077
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1078
				return PushStyleVar("Alpha", 1, function() -- 1079
					return Begin("Content", windowFlags, function() -- 1080
						local DemoViewWidth <const> = 220 -- 1081
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1082
						if filterText then -- 1083
							filterText = filterText:lower() -- 1083
						end -- 1083
						if #gamesInDev > 0 then -- 1084
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1085
							Columns(columns, false) -- 1086
							local realViewWidth = GetColumnWidth() - 50 -- 1087
							for _index_0 = 1, #gamesInDev do -- 1088
								local game = gamesInDev[_index_0] -- 1088
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1089
								local displayName -- 1098
								if repo then -- 1098
									if zh then -- 1099
										displayName = repo.title.zh -- 1099
									else -- 1099
										displayName = repo.title.en -- 1099
									end -- 1099
								end -- 1098
								if displayName == nil then -- 1100
									displayName = gameName -- 1100
								end -- 1100
								if match(displayName) then -- 1101
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1102
									SameLine() -- 1103
									TextWrapped(displayName) -- 1104
									if columns > 1 then -- 1105
										if bannerFile then -- 1106
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1107
											local displayWidth <const> = realViewWidth -- 1108
											texHeight = displayWidth * texHeight / texWidth -- 1109
											texWidth = displayWidth -- 1110
											Dummy(Vec2.zero) -- 1111
											SameLine() -- 1112
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1113
										end -- 1106
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1114
											enterDemoEntry(game) -- 1115
										end -- 1114
									else -- 1117
										if bannerFile then -- 1117
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1118
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1119
											local sizing = 0.8 -- 1120
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1121
											texWidth = displayWidth * sizing -- 1122
											if texWidth > 500 then -- 1123
												sizing = 0.6 -- 1124
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1125
												texWidth = displayWidth * sizing -- 1126
											end -- 1123
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1127
											Dummy(Vec2(padding, 0)) -- 1128
											SameLine() -- 1129
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1130
										end -- 1117
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1131
											enterDemoEntry(game) -- 1132
										end -- 1131
									end -- 1105
									if #tests == 0 and #examples == 0 then -- 1133
										thinSep() -- 1134
									end -- 1133
									NextColumn() -- 1135
								end -- 1101
								local showSep = false -- 1136
								if #examples > 0 then -- 1137
									local showExample = false -- 1138
									do -- 1139
										local _accum_0 -- 1139
										for _index_1 = 1, #examples do -- 1139
											local _des_0 = examples[_index_1] -- 1139
											local entryName = _des_0.entryName -- 1139
											if match(entryName) then -- 1140
												_accum_0 = true -- 1140
												break -- 1140
											end -- 1140
										end -- 1139
										showExample = _accum_0 -- 1139
									end -- 1139
									if showExample then -- 1141
										showSep = true -- 1142
										Columns(1, false) -- 1143
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1144
										SameLine() -- 1145
										local opened -- 1146
										if (filterText ~= nil) then -- 1146
											opened = showExample -- 1146
										else -- 1146
											opened = false -- 1146
										end -- 1146
										if game.exampleOpen == nil then -- 1147
											game.exampleOpen = opened -- 1147
										end -- 1147
										SetNextItemOpen(game.exampleOpen) -- 1148
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1149
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1150
												Columns(maxColumns, false) -- 1151
												for _index_1 = 1, #examples do -- 1152
													local example = examples[_index_1] -- 1152
													local entryName = example.entryName -- 1153
													if not match(entryName) then -- 1154
														goto _continue_0 -- 1154
													end -- 1154
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1155
														if Button(entryName, Vec2(-1, 40)) then -- 1156
															enterDemoEntry(example) -- 1157
														end -- 1156
														return NextColumn() -- 1158
													end) -- 1155
													opened = true -- 1159
													::_continue_0:: -- 1153
												end -- 1152
											end) -- 1150
										end) -- 1149
										game.exampleOpen = opened -- 1160
									end -- 1141
								end -- 1137
								if #tests > 0 then -- 1161
									local showTest = false -- 1162
									do -- 1163
										local _accum_0 -- 1163
										for _index_1 = 1, #tests do -- 1163
											local _des_0 = tests[_index_1] -- 1163
											local entryName = _des_0.entryName -- 1163
											if match(entryName) then -- 1164
												_accum_0 = true -- 1164
												break -- 1164
											end -- 1164
										end -- 1163
										showTest = _accum_0 -- 1163
									end -- 1163
									if showTest then -- 1165
										showSep = true -- 1166
										Columns(1, false) -- 1167
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1168
										SameLine() -- 1169
										local opened -- 1170
										if (filterText ~= nil) then -- 1170
											opened = showTest -- 1170
										else -- 1170
											opened = false -- 1170
										end -- 1170
										if game.testOpen == nil then -- 1171
											game.testOpen = opened -- 1171
										end -- 1171
										SetNextItemOpen(game.testOpen) -- 1172
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1173
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1174
												Columns(maxColumns, false) -- 1175
												for _index_1 = 1, #tests do -- 1176
													local test = tests[_index_1] -- 1176
													local entryName = test.entryName -- 1177
													if not match(entryName) then -- 1178
														goto _continue_0 -- 1178
													end -- 1178
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1179
														if Button(entryName, Vec2(-1, 40)) then -- 1180
															enterDemoEntry(test) -- 1181
														end -- 1180
														return NextColumn() -- 1182
													end) -- 1179
													opened = true -- 1183
													::_continue_0:: -- 1177
												end -- 1176
											end) -- 1174
										end) -- 1173
										game.testOpen = opened -- 1184
									end -- 1165
								end -- 1161
								if showSep then -- 1185
									Columns(1, false) -- 1186
									thinSep() -- 1187
									Columns(columns, false) -- 1188
								end -- 1185
							end -- 1088
						end -- 1084
						if #doraTools > 0 then -- 1189
							local showTool = false -- 1190
							do -- 1191
								local _accum_0 -- 1191
								for _index_0 = 1, #doraTools do -- 1191
									local _des_0 = doraTools[_index_0] -- 1191
									local entryName = _des_0.entryName -- 1191
									if match(entryName) then -- 1192
										_accum_0 = true -- 1192
										break -- 1192
									end -- 1192
								end -- 1191
								showTool = _accum_0 -- 1191
							end -- 1191
							if not showTool then -- 1193
								goto endEntry -- 1193
							end -- 1193
							Columns(1, false) -- 1194
							TextColored(themeColor, "Dora SSR:") -- 1195
							SameLine() -- 1196
							Text(zh and "开发支持" or "Development Support") -- 1197
							Separator() -- 1198
							if #doraTools > 0 then -- 1199
								local opened -- 1200
								if (filterText ~= nil) then -- 1200
									opened = showTool -- 1200
								else -- 1200
									opened = false -- 1200
								end -- 1200
								SetNextItemOpen(toolOpen) -- 1201
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1202
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1203
										Columns(maxColumns, false) -- 1204
										for _index_0 = 1, #doraTools do -- 1205
											local example = doraTools[_index_0] -- 1205
											local entryName = example.entryName -- 1206
											if not match(entryName) then -- 1207
												goto _continue_0 -- 1207
											end -- 1207
											if Button(entryName, Vec2(-1, 40)) then -- 1208
												enterDemoEntry(example) -- 1209
											end -- 1208
											NextColumn() -- 1210
											::_continue_0:: -- 1206
										end -- 1205
										Columns(1, false) -- 1211
										opened = true -- 1212
									end) -- 1203
								end) -- 1202
								toolOpen = opened -- 1213
							end -- 1199
						end -- 1189
						::endEntry:: -- 1214
						if not anyEntryMatched then -- 1215
							SetNextWindowBgAlpha(0) -- 1216
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1217
							Begin("Entries Not Found", displayWindowFlags, function() -- 1218
								Separator() -- 1219
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1220
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1221
								return Separator() -- 1222
							end) -- 1218
						end -- 1215
						Columns(1, false) -- 1223
						Dummy(Vec2(100, 80)) -- 1224
						return ScrollWhenDraggingOnVoid() -- 1225
					end) -- 1080
				end) -- 1079
			end) -- 1078
		end) -- 1077
	end -- 1076
end) -- 1009
webStatus = require("Script.Dev.WebServer") -- 1227
return _module_0 -- 1
