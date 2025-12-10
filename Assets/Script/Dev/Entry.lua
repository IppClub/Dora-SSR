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
ShowConsole(true) -- 15
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
				end -- 40
			end -- 40
			if locale ~= nil then -- 40
				if App.locale ~= locale then -- 40
					App.locale = locale -- 41
					updateLocale() -- 42
				end -- 40
			end -- 40
		end -- 39
	end -- 39
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
				end -- 45
			end -- 45
			if writablePath ~= nil then -- 45
				Content.writablePath = writablePath -- 46
			end -- 45
		end -- 44
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
			local data = json.decode(res) -- 192
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
	end) -- 190
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
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 221
local building = false -- 223
local getAllFiles -- 225
getAllFiles = function(path, exts, recursive) -- 225
	if recursive == nil then -- 225
		recursive = true -- 225
	end -- 225
	local filters = Set(exts) -- 226
	local files -- 227
	if recursive then -- 227
		files = Content:getAllFiles(path) -- 228
	else -- 230
		files = Content:getFiles(path) -- 230
	end -- 227
	local _accum_0 = { } -- 231
	local _len_0 = 1 -- 231
	for _index_0 = 1, #files do -- 231
		local file = files[_index_0] -- 231
		if not filters[Path:getExt(file)] then -- 232
			goto _continue_0 -- 232
		end -- 232
		_accum_0[_len_0] = file -- 233
		_len_0 = _len_0 + 1 -- 232
		::_continue_0:: -- 232
	end -- 231
	return _accum_0 -- 231
end -- 225
_module_0["getAllFiles"] = getAllFiles -- 225
local getFileEntries -- 235
getFileEntries = function(path, recursive, excludeFiles) -- 235
	if recursive == nil then -- 235
		recursive = true -- 235
	end -- 235
	if excludeFiles == nil then -- 235
		excludeFiles = nil -- 235
	end -- 235
	local entries = { } -- 236
	local excludes -- 237
	if excludeFiles then -- 237
		excludes = Set(excludeFiles) -- 238
	end -- 237
	local _list_0 = getAllFiles(path, { -- 239
		"lua", -- 239
		"xml", -- 239
		yueext, -- 239
		"tl" -- 239
	}, recursive) -- 239
	for _index_0 = 1, #_list_0 do -- 239
		local file = _list_0[_index_0] -- 239
		local entryName = Path:getName(file) -- 240
		if excludes and excludes[entryName] then -- 241
			goto _continue_0 -- 242
		end -- 241
		local fileName = Path:replaceExt(file, "") -- 243
		fileName = Path(path, fileName) -- 244
		local entryAdded -- 245
		do -- 245
			local _accum_0 -- 245
			for _index_1 = 1, #entries do -- 245
				local _des_0 = entries[_index_1] -- 245
				local ename, efile = _des_0.entryName, _des_0.fileName -- 245
				if entryName == ename and efile == fileName then -- 246
					_accum_0 = true -- 246
					break -- 246
				end -- 246
			end -- 245
			entryAdded = _accum_0 -- 245
		end -- 245
		if entryAdded then -- 247
			goto _continue_0 -- 247
		end -- 247
		local entry = { -- 248
			entryName = entryName, -- 248
			fileName = fileName -- 248
		} -- 248
		entries[#entries + 1] = entry -- 249
		::_continue_0:: -- 240
	end -- 239
	table.sort(entries, function(a, b) -- 250
		return a.entryName < b.entryName -- 250
	end) -- 250
	return entries -- 251
end -- 235
local getProjectEntries -- 253
getProjectEntries = function(path) -- 253
	local entries = { } -- 254
	local _list_0 = Content:getDirs(path) -- 255
	for _index_0 = 1, #_list_0 do -- 255
		local dir = _list_0[_index_0] -- 255
		if dir:match("^%.") then -- 256
			goto _continue_0 -- 256
		end -- 256
		local _list_1 = getAllFiles(Path(path, dir), { -- 257
			"lua", -- 257
			"xml", -- 257
			yueext, -- 257
			"tl", -- 257
			"wasm" -- 257
		}) -- 257
		for _index_1 = 1, #_list_1 do -- 257
			local file = _list_1[_index_1] -- 257
			if "init" == Path:getName(file):lower() then -- 258
				local fileName = Path:replaceExt(file, "") -- 259
				fileName = Path(path, dir, fileName) -- 260
				local repoFile = Path(Path:getPath(fileName), "repo.json") -- 261
				local repo = nil -- 262
				if Content:exist(repoFile) then -- 263
					local str = Content:load(repoFile) -- 264
					if str then -- 264
						repo = json.decode(str) -- 265
					end -- 264
				end -- 263
				local entryName = Path:getName(Path:getPath(fileName)) -- 266
				local entryAdded -- 267
				do -- 267
					local _accum_0 -- 267
					for _index_2 = 1, #entries do -- 267
						local _des_0 = entries[_index_2] -- 267
						local ename, efile = _des_0.entryName, _des_0.fileName -- 267
						if entryName == ename and efile == fileName then -- 268
							_accum_0 = true -- 268
							break -- 268
						end -- 268
					end -- 267
					entryAdded = _accum_0 -- 267
				end -- 267
				if entryAdded then -- 269
					goto _continue_1 -- 269
				end -- 269
				local examples = { } -- 270
				local tests = { } -- 271
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 272
				if Content:exist(examplePath) then -- 273
					local _list_2 = getFileEntries(examplePath) -- 274
					for _index_2 = 1, #_list_2 do -- 274
						local _des_0 = _list_2[_index_2] -- 274
						local name, ePath = _des_0.entryName, _des_0.fileName -- 274
						local entry = { -- 276
							entryName = name, -- 276
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 277
							workDir = Path:getPath(fileName) -- 278
						} -- 275
						examples[#examples + 1] = entry -- 280
					end -- 274
				end -- 273
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 281
				if Content:exist(testPath) then -- 282
					local _list_2 = getFileEntries(testPath) -- 283
					for _index_2 = 1, #_list_2 do -- 283
						local _des_0 = _list_2[_index_2] -- 283
						local name, tPath = _des_0.entryName, _des_0.fileName -- 283
						local entry = { -- 285
							entryName = name, -- 285
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 286
							workDir = Path:getPath(fileName) -- 287
						} -- 284
						tests[#tests + 1] = entry -- 289
					end -- 283
				end -- 282
				local entry = { -- 290
					entryName = entryName, -- 290
					fileName = fileName, -- 290
					examples = examples, -- 290
					tests = tests, -- 290
					repo = repo -- 290
				} -- 290
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 291
				if not Content:exist(bannerFile) then -- 292
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 293
					if not Content:exist(bannerFile) then -- 294
						bannerFile = nil -- 294
					end -- 294
				end -- 292
				if bannerFile then -- 295
					thread(function() -- 295
						if Cache:loadAsync(bannerFile) then -- 296
							local bannerTex = Texture2D(bannerFile) -- 297
							if bannerTex then -- 297
								entry.bannerFile = bannerFile -- 298
								entry.bannerTex = bannerTex -- 299
							end -- 297
						end -- 296
					end) -- 295
				end -- 295
				entries[#entries + 1] = entry -- 300
			end -- 258
			::_continue_1:: -- 258
		end -- 257
		::_continue_0:: -- 256
	end -- 255
	table.sort(entries, function(a, b) -- 301
		return a.entryName < b.entryName -- 301
	end) -- 301
	return entries -- 302
end -- 253
local gamesInDev -- 304
local doraTools -- 305
local allEntries -- 306
local updateEntries -- 308
updateEntries = function() -- 308
	gamesInDev = getProjectEntries(Content.writablePath) -- 309
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 310
	allEntries = { } -- 312
	for _index_0 = 1, #gamesInDev do -- 313
		local game = gamesInDev[_index_0] -- 313
		allEntries[#allEntries + 1] = game -- 314
		local examples, tests = game.examples, game.tests -- 315
		for _index_1 = 1, #examples do -- 316
			local example = examples[_index_1] -- 316
			allEntries[#allEntries + 1] = example -- 317
		end -- 316
		for _index_1 = 1, #tests do -- 318
			local test = tests[_index_1] -- 318
			allEntries[#allEntries + 1] = test -- 319
		end -- 318
	end -- 313
end -- 308
updateEntries() -- 321
local doCompile -- 323
doCompile = function(minify) -- 323
	if building then -- 324
		return -- 324
	end -- 324
	building = true -- 325
	local startTime = App.runningTime -- 326
	local luaFiles = { } -- 327
	local yueFiles = { } -- 328
	local xmlFiles = { } -- 329
	local tlFiles = { } -- 330
	local writablePath = Content.writablePath -- 331
	local buildPaths = { -- 333
		{ -- 334
			Content.assetPath, -- 334
			Path(writablePath, ".build"), -- 335
			"" -- 336
		} -- 333
	} -- 332
	for _index_0 = 1, #gamesInDev do -- 339
		local _des_0 = gamesInDev[_index_0] -- 339
		local entryFile = _des_0.entryFile -- 339
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 340
		buildPaths[#buildPaths + 1] = { -- 342
			Path(writablePath, gamePath), -- 342
			Path(writablePath, ".build", gamePath), -- 343
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 344
			gamePath -- 345
		} -- 341
	end -- 339
	for _index_0 = 1, #buildPaths do -- 346
		local _des_0 = buildPaths[_index_0] -- 346
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 346
		if not Content:exist(inputPath) then -- 347
			goto _continue_0 -- 347
		end -- 347
		local _list_0 = getAllFiles(inputPath, { -- 349
			"lua" -- 349
		}) -- 349
		for _index_1 = 1, #_list_0 do -- 349
			local file = _list_0[_index_1] -- 349
			luaFiles[#luaFiles + 1] = { -- 351
				file, -- 351
				Path(inputPath, file), -- 352
				Path(outputPath, file), -- 353
				gamePath -- 354
			} -- 350
		end -- 349
		local _list_1 = getAllFiles(inputPath, { -- 356
			yueext -- 356
		}) -- 356
		for _index_1 = 1, #_list_1 do -- 356
			local file = _list_1[_index_1] -- 356
			yueFiles[#yueFiles + 1] = { -- 358
				file, -- 358
				Path(inputPath, file), -- 359
				Path(outputPath, Path:replaceExt(file, "lua")), -- 360
				searchPath, -- 361
				gamePath -- 362
			} -- 357
		end -- 356
		local _list_2 = getAllFiles(inputPath, { -- 364
			"xml" -- 364
		}) -- 364
		for _index_1 = 1, #_list_2 do -- 364
			local file = _list_2[_index_1] -- 364
			xmlFiles[#xmlFiles + 1] = { -- 366
				file, -- 366
				Path(inputPath, file), -- 367
				Path(outputPath, Path:replaceExt(file, "lua")), -- 368
				gamePath -- 369
			} -- 365
		end -- 364
		local _list_3 = getAllFiles(inputPath, { -- 371
			"tl" -- 371
		}) -- 371
		for _index_1 = 1, #_list_3 do -- 371
			local file = _list_3[_index_1] -- 371
			if not file:match(".*%.d%.tl$") then -- 372
				tlFiles[#tlFiles + 1] = { -- 374
					file, -- 374
					Path(inputPath, file), -- 375
					Path(outputPath, Path:replaceExt(file, "lua")), -- 376
					searchPath, -- 377
					gamePath -- 378
				} -- 373
			end -- 372
		end -- 371
		::_continue_0:: -- 347
	end -- 346
	local paths -- 380
	do -- 380
		local _tbl_0 = { } -- 380
		local _list_0 = { -- 381
			luaFiles, -- 381
			yueFiles, -- 381
			xmlFiles, -- 381
			tlFiles -- 381
		} -- 381
		for _index_0 = 1, #_list_0 do -- 381
			local files = _list_0[_index_0] -- 381
			for _index_1 = 1, #files do -- 382
				local file = files[_index_1] -- 382
				_tbl_0[Path:getPath(file[3])] = true -- 380
			end -- 380
		end -- 380
		paths = _tbl_0 -- 380
	end -- 380
	for path in pairs(paths) do -- 384
		Content:mkdir(path) -- 384
	end -- 384
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 386
	local fileCount = 0 -- 387
	local errors = { } -- 388
	for _index_0 = 1, #yueFiles do -- 389
		local _des_0 = yueFiles[_index_0] -- 389
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 389
		local filename -- 390
		if gamePath then -- 390
			filename = Path(gamePath, file) -- 390
		else -- 390
			filename = file -- 390
		end -- 390
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 391
			if not codes then -- 392
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 393
				return -- 394
			end -- 392
			local success, result = LintYueGlobals(codes, globals) -- 395
			if success then -- 396
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 397
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 398
				codes = codes:gsub("^\n*", "") -- 399
				if not (result == "") then -- 400
					result = result .. "\n" -- 400
				end -- 400
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 401
			else -- 403
				local yueCodes = Content:load(input) -- 403
				if yueCodes then -- 403
					local globalErrors = { } -- 404
					for _index_1 = 1, #result do -- 405
						local _des_1 = result[_index_1] -- 405
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 405
						local countLine = 1 -- 406
						local code = "" -- 407
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 408
							if countLine == line then -- 409
								code = lineCode -- 410
								break -- 411
							end -- 409
							countLine = countLine + 1 -- 412
						end -- 408
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 413
					end -- 405
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 414
				else -- 416
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 416
				end -- 403
			end -- 396
		end, function(success) -- 391
			if success then -- 417
				print("Yue compiled: " .. tostring(filename)) -- 417
			end -- 417
			fileCount = fileCount + 1 -- 418
		end) -- 391
	end -- 389
	thread(function() -- 420
		for _index_0 = 1, #xmlFiles do -- 421
			local _des_0 = xmlFiles[_index_0] -- 421
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 421
			local filename -- 422
			if gamePath then -- 422
				filename = Path(gamePath, file) -- 422
			else -- 422
				filename = file -- 422
			end -- 422
			local sourceCodes = Content:loadAsync(input) -- 423
			local codes, err = xml.tolua(sourceCodes) -- 424
			if not codes then -- 425
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 426
			else -- 428
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 428
				print("Xml compiled: " .. tostring(filename)) -- 429
			end -- 425
			fileCount = fileCount + 1 -- 430
		end -- 421
	end) -- 420
	thread(function() -- 432
		for _index_0 = 1, #tlFiles do -- 433
			local _des_0 = tlFiles[_index_0] -- 433
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 433
			local filename -- 434
			if gamePath then -- 434
				filename = Path(gamePath, file) -- 434
			else -- 434
				filename = file -- 434
			end -- 434
			local sourceCodes = Content:loadAsync(input) -- 435
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 436
			if not codes then -- 437
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 438
			else -- 440
				Content:saveAsync(output, codes) -- 440
				print("Teal compiled: " .. tostring(filename)) -- 441
			end -- 437
			fileCount = fileCount + 1 -- 442
		end -- 433
	end) -- 432
	return thread(function() -- 444
		wait(function() -- 445
			return fileCount == totalFiles -- 445
		end) -- 445
		if minify then -- 446
			local _list_0 = { -- 447
				yueFiles, -- 447
				xmlFiles, -- 447
				tlFiles -- 447
			} -- 447
			for _index_0 = 1, #_list_0 do -- 447
				local files = _list_0[_index_0] -- 447
				for _index_1 = 1, #files do -- 447
					local file = files[_index_1] -- 447
					local output = Path:replaceExt(file[3], "lua") -- 448
					luaFiles[#luaFiles + 1] = { -- 450
						Path:replaceExt(file[1], "lua"), -- 450
						output, -- 451
						output -- 452
					} -- 449
				end -- 447
			end -- 447
			local FormatMini -- 454
			do -- 454
				local _obj_0 = require("luaminify") -- 454
				FormatMini = _obj_0.FormatMini -- 454
			end -- 454
			for _index_0 = 1, #luaFiles do -- 455
				local _des_0 = luaFiles[_index_0] -- 455
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 455
				if Content:exist(input) then -- 456
					local sourceCodes = Content:loadAsync(input) -- 457
					local res, err = FormatMini(sourceCodes) -- 458
					if res then -- 459
						Content:saveAsync(output, res) -- 460
						print("Minify: " .. tostring(file)) -- 461
					else -- 463
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 463
					end -- 459
				else -- 465
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 465
				end -- 456
			end -- 455
			package.loaded["luaminify.FormatMini"] = nil -- 466
			package.loaded["luaminify.ParseLua"] = nil -- 467
			package.loaded["luaminify.Scope"] = nil -- 468
			package.loaded["luaminify.Util"] = nil -- 469
		end -- 446
		local errorMessage = table.concat(errors, "\n") -- 470
		if errorMessage ~= "" then -- 471
			print(errorMessage) -- 471
		end -- 471
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 472
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 473
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 474
		Content:clearPathCache() -- 475
		teal.clear() -- 476
		yue.clear() -- 477
		building = false -- 478
	end) -- 444
end -- 323
local doClean -- 480
doClean = function() -- 480
	if building then -- 481
		return -- 481
	end -- 481
	local writablePath = Content.writablePath -- 482
	local targetDir = Path(writablePath, ".build") -- 483
	Content:clearPathCache() -- 484
	if Content:remove(targetDir) then -- 485
		return print("Cleaned: " .. tostring(targetDir)) -- 486
	end -- 485
end -- 480
local screenScale = 2.0 -- 488
local scaleContent = false -- 489
local isInEntry = true -- 490
local currentEntry = nil -- 491
local footerWindow = nil -- 493
local entryWindow = nil -- 494
local testingThread = nil -- 495
local setupEventHandlers = nil -- 497
local allClear -- 499
allClear = function() -- 499
	local _list_0 = Routine -- 500
	for _index_0 = 1, #_list_0 do -- 500
		local routine = _list_0[_index_0] -- 500
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 502
			goto _continue_0 -- 503
		else -- 505
			Routine:remove(routine) -- 505
		end -- 501
		::_continue_0:: -- 501
	end -- 500
	for _index_0 = 1, #moduleCache do -- 506
		local module = moduleCache[_index_0] -- 506
		package.loaded[module] = nil -- 507
	end -- 506
	moduleCache = { } -- 508
	Director:cleanup() -- 509
	Entity:clear() -- 510
	Platformer.Data:clear() -- 511
	Platformer.UnitAction:clear() -- 512
	Audio:stopAll(0.2) -- 513
	Struct:clear() -- 514
	View.postEffect = nil -- 515
	View.scale = scaleContent and screenScale or 1 -- 516
	Director.clearColor = Color(0xff1a1a1a) -- 517
	teal.clear() -- 518
	yue.clear() -- 519
	for _, item in pairs(ubox()) do -- 520
		local node = tolua.cast(item, "Node") -- 521
		if node then -- 521
			node:cleanup() -- 521
		end -- 521
	end -- 520
	collectgarbage() -- 522
	collectgarbage() -- 523
	Wasm:clear() -- 524
	thread(function() -- 525
		sleep() -- 526
		return Cache:removeUnused() -- 527
	end) -- 525
	setupEventHandlers() -- 528
	Content.searchPaths = searchPaths -- 529
	App.idled = true -- 530
end -- 499
_module_0["allClear"] = allClear -- 499
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
		end) -- 549
	end) -- 542
end -- 542
local setWorkspace -- 554
setWorkspace = function(path) -- 554
	Content.writablePath = path -- 555
	config.writablePath = Content.writablePath -- 556
	return thread(function() -- 557
		sleep() -- 558
		return reloadDevEntry() -- 559
	end) -- 557
end -- 554
local quit = false -- 561
local _anon_func_1 = function(App, _with_0) -- 577
	local _val_0 = App.platform -- 577
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 577
end -- 577
setupEventHandlers = function() -- 563
	local _with_0 = Director.postNode -- 564
	_with_0:onAppEvent(function(eventType) -- 565
		if eventType == "Quit" then -- 565
			quit = true -- 566
			allClear() -- 567
			return clearTempFiles() -- 568
		end -- 565
	end) -- 565
	_with_0:onAppChange(function(settingName) -- 569
		if "Theme" == settingName then -- 570
			config.themeColor = App.themeColor:toARGB() -- 571
		elseif "Locale" == settingName then -- 572
			config.locale = App.locale -- 573
			updateLocale() -- 574
			return teal.clear(true) -- 575
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 576
			if _anon_func_1(App, _with_0) then -- 577
				if "FullScreen" == settingName then -- 579
					config.fullScreen = App.fullScreen -- 579
				elseif "Position" == settingName then -- 580
					local _obj_0 = App.winPosition -- 580
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 580
				elseif "Size" == settingName then -- 581
					local width, height -- 582
					do -- 582
						local _obj_0 = App.winSize -- 582
						width, height = _obj_0.width, _obj_0.height -- 582
					end -- 582
					config.winWidth = width -- 583
					config.winHeight = height -- 584
				end -- 578
			end -- 577
		end -- 569
	end) -- 569
	_with_0:onAppWS(function(eventType) -- 585
		if eventType == "Close" then -- 585
			if HttpServer.wsConnectionCount == 0 then -- 586
				return updateEntries() -- 587
			end -- 586
		end -- 585
	end) -- 585
	_with_0:slot("UpdateEntries", function() -- 588
		return updateEntries() -- 588
	end) -- 588
	return _with_0 -- 564
end -- 563
setupEventHandlers() -- 590
clearTempFiles() -- 591
local downloadFile -- 593
downloadFile = function(url, target) -- 593
	return Director.systemScheduler:schedule(once(function() -- 593
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 594
			if quit then -- 595
				return true -- 595
			end -- 595
			emit("AppWS", "Send", json.encode({ -- 597
				name = "Download", -- 597
				url = url, -- 597
				status = "downloading", -- 597
				progress = current / total -- 598
			})) -- 596
			return false -- 594
		end) -- 594
		return emit("AppWS", "Send", json.encode(success and { -- 601
			name = "Download", -- 601
			url = url, -- 601
			status = "completed", -- 601
			progress = 1.0 -- 602
		} or { -- 604
			name = "Download", -- 604
			url = url, -- 604
			status = "failed", -- 604
			progress = 0.0 -- 605
		})) -- 600
	end)) -- 593
end -- 593
_module_0["downloadFile"] = downloadFile -- 593
local stop -- 608
stop = function() -- 608
	if isInEntry then -- 609
		return false -- 609
	end -- 609
	allClear() -- 610
	isInEntry = true -- 611
	currentEntry = nil -- 612
	return true -- 613
end -- 608
_module_0["stop"] = stop -- 608
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 623
	if workDir == nil then -- 623
		workDir = Path:getPath(file) -- 623
	end -- 623
	Content:insertSearchPath(1, workDir) -- 624
	local scriptPath = Path(workDir, "Script") -- 625
	if Content:exist(scriptPath) then -- 626
		Content:insertSearchPath(1, scriptPath) -- 627
	end -- 626
	local result = require(file) -- 628
	if "function" == type(result) then -- 629
		result() -- 629
	end -- 629
	return nil -- 630
end -- 623
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 659
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 659
	label.alignment = "Left" -- 660
	label.textWidth = width - fontSize -- 661
	label.text = err -- 662
	return label -- 659
end -- 659
local enterEntryAsync -- 615
enterEntryAsync = function(entry) -- 615
	isInEntry = false -- 616
	App.idled = false -- 617
	emit(Profiler.EventName, "ClearLoader") -- 618
	currentEntry = entry -- 619
	local file, workDir = entry.fileName, entry.workDir -- 620
	sleep() -- 621
	return xpcall(_anon_func_2, function(msg) -- 630
		local err = debug.traceback(msg) -- 632
		Log("Error", err) -- 633
		allClear() -- 634
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 635
		local viewWidth, viewHeight -- 636
		do -- 636
			local _obj_0 = View.size -- 636
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 636
		end -- 636
		local width, height = viewWidth - 20, viewHeight - 20 -- 637
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 638
		Director.ui:addChild((function() -- 639
			local root = AlignNode() -- 639
			do -- 640
				local _obj_0 = App.bufferSize -- 640
				width, height = _obj_0.width, _obj_0.height -- 640
			end -- 640
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 641
			root:onAppChange(function(settingName) -- 642
				if settingName == "Size" then -- 642
					do -- 643
						local _obj_0 = App.bufferSize -- 643
						width, height = _obj_0.width, _obj_0.height -- 643
					end -- 643
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 644
				end -- 642
			end) -- 642
			root:addChild((function() -- 645
				local _with_0 = ScrollArea({ -- 646
					width = width, -- 646
					height = height, -- 647
					paddingX = 0, -- 648
					paddingY = 50, -- 649
					viewWidth = height, -- 650
					viewHeight = height -- 651
				}) -- 645
				root:onAlignLayout(function(w, h) -- 653
					_with_0.position = Vec2(w / 2, h / 2) -- 654
					w = w - 20 -- 655
					h = h - 20 -- 656
					_with_0.view.children.first.textWidth = w - fontSize -- 657
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 658
				end) -- 653
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 659
				return _with_0 -- 645
			end)()) -- 645
			return root -- 639
		end)()) -- 639
		return err -- 663
	end, Content, Path, file, require, type, workDir) -- 622
end -- 615
_module_0["enterEntryAsync"] = enterEntryAsync -- 615
local enterDemoEntry -- 665
enterDemoEntry = function(entry) -- 665
	return thread(function() -- 665
		return enterEntryAsync(entry) -- 665
	end) -- 665
end -- 665
local reloadCurrentEntry -- 667
reloadCurrentEntry = function() -- 667
	if currentEntry then -- 668
		allClear() -- 669
		return enterDemoEntry(currentEntry) -- 670
	end -- 668
end -- 667
Director.clearColor = Color(0xff1a1a1a) -- 672
local isOSSLicenseExist = Content:exist("LICENSES") -- 674
local ossLicenses = nil -- 675
local ossLicenseOpen = false -- 676
local extraOperations -- 678
extraOperations = function() -- 678
	local zh = useChinese -- 679
	if isDesktop then -- 680
		local themeColor = App.themeColor -- 681
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 682
		do -- 683
			local changed -- 683
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 683
			if changed then -- 683
				App.alwaysOnTop = alwaysOnTop -- 684
				config.alwaysOnTop = alwaysOnTop -- 685
			end -- 683
		end -- 683
		SeparatorText(zh and "工作目录" or "Workspace") -- 686
		PushTextWrapPos(400, function() -- 687
			return TextColored(themeColor, writablePath) -- 688
		end) -- 687
		if Button(zh and "改变目录" or "Set Folder") then -- 689
			App:openFileDialog(true, function(path) -- 690
				if path ~= "" then -- 691
					return setWorkspace(path) -- 691
				end -- 691
			end) -- 690
		end -- 689
		SameLine() -- 692
		if Button(zh and "使用默认" or "Use Default") then -- 693
			setWorkspace(Content.appPath) -- 694
		end -- 693
		Separator() -- 695
	end -- 680
	if isOSSLicenseExist then -- 696
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 697
			if not ossLicenses then -- 698
				ossLicenses = { } -- 699
				local licenseText = Content:load("LICENSES") -- 700
				ossLicenseOpen = (licenseText ~= nil) -- 701
				if ossLicenseOpen then -- 701
					licenseText = licenseText:gsub("\r\n", "\n") -- 702
					for license in GSplit(licenseText, "\n--------\n", true) do -- 703
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 704
						if name then -- 704
							ossLicenses[#ossLicenses + 1] = { -- 705
								name, -- 705
								text -- 705
							} -- 705
						end -- 704
					end -- 703
				end -- 701
			else -- 707
				ossLicenseOpen = true -- 707
			end -- 698
		end -- 697
		if ossLicenseOpen then -- 708
			local width, height, themeColor -- 709
			do -- 709
				local _obj_0 = App -- 709
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 709
			end -- 709
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 710
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 711
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 712
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 715
					"NoSavedSettings" -- 715
				}, function() -- 716
					for _index_0 = 1, #ossLicenses do -- 716
						local _des_0 = ossLicenses[_index_0] -- 716
						local firstLine, text = _des_0[1], _des_0[2] -- 716
						local name, license = firstLine:match("(.+): (.+)") -- 717
						TextColored(themeColor, name) -- 718
						SameLine() -- 719
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 720
							return TextWrapped(text) -- 720
						end) -- 720
					end -- 716
				end) -- 712
			end) -- 712
		end -- 708
	end -- 696
	if not App.debugging then -- 722
		return -- 722
	end -- 722
	return TreeNode(zh and "开发操作" or "Development", function() -- 723
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 724
			OpenPopup("build") -- 724
		end -- 724
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 725
			return BeginPopup("build", function() -- 725
				if Selectable(zh and "编译" or "Compile") then -- 726
					doCompile(false) -- 726
				end -- 726
				Separator() -- 727
				if Selectable(zh and "压缩" or "Minify") then -- 728
					doCompile(true) -- 728
				end -- 728
				Separator() -- 729
				if Selectable(zh and "清理" or "Clean") then -- 730
					return doClean() -- 730
				end -- 730
			end) -- 725
		end) -- 725
		if isInEntry then -- 731
			if waitForWebStart then -- 732
				BeginDisabled(function() -- 733
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 733
				end) -- 733
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 734
				reloadDevEntry() -- 735
			end -- 732
		end -- 731
		do -- 736
			local changed -- 736
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 736
			if changed then -- 736
				View.scale = scaleContent and screenScale or 1 -- 737
			end -- 736
		end -- 736
		do -- 738
			local changed -- 738
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 738
			if changed then -- 738
				config.engineDev = engineDev -- 739
			end -- 738
		end -- 738
		if testingThread then -- 740
			return BeginDisabled(function() -- 741
				return Button(zh and "开始自动测试" or "Test automatically") -- 741
			end) -- 741
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 742
			testingThread = thread(function() -- 743
				local _ <close> = setmetatable({ }, { -- 744
					__close = function() -- 744
						allClear() -- 745
						testingThread = nil -- 746
						isInEntry = true -- 747
						currentEntry = nil -- 748
						return print("Testing done!") -- 749
					end -- 744
				}) -- 744
				for _, entry in ipairs(allEntries) do -- 750
					allClear() -- 751
					print("Start " .. tostring(entry.entryName)) -- 752
					enterDemoEntry(entry) -- 753
					sleep(2) -- 754
					print("Stop " .. tostring(entry.entryName)) -- 755
				end -- 750
			end) -- 743
		end -- 740
	end) -- 723
end -- 678
local icon = Path("Script", "Dev", "icon_s.png") -- 757
local iconTex = nil -- 758
thread(function() -- 759
	if Cache:loadAsync(icon) then -- 759
		iconTex = Texture2D(icon) -- 759
	end -- 759
end) -- 759
local webStatus = nil -- 761
local urlClicked = nil -- 762
local descColor = Color(0xffa1a1a1) -- 763
local transparant = Color(0x0) -- 765
local windowFlags = { -- 766
	"NoTitleBar", -- 766
	"NoResize", -- 766
	"NoMove", -- 766
	"NoCollapse", -- 766
	"NoSavedSettings", -- 766
	"NoFocusOnAppearing", -- 766
	"NoBringToFrontOnFocus" -- 766
} -- 766
local statusFlags = { -- 775
	"NoTitleBar", -- 775
	"NoResize", -- 775
	"NoMove", -- 775
	"NoCollapse", -- 775
	"AlwaysAutoResize", -- 775
	"NoSavedSettings" -- 775
} -- 775
local displayWindowFlags = { -- 783
	"NoDecoration", -- 783
	"NoSavedSettings", -- 783
	"NoNav", -- 783
	"NoMove", -- 783
	"NoScrollWithMouse", -- 783
	"AlwaysAutoResize", -- 783
	"NoFocusOnAppearing" -- 783
} -- 783
local initFooter = true -- 792
local _anon_func_4 = function(allEntries, currentIndex) -- 828
	if currentIndex > 1 then -- 828
		return allEntries[currentIndex - 1] -- 829
	else -- 831
		return allEntries[#allEntries] -- 831
	end -- 828
end -- 828
local _anon_func_5 = function(allEntries, currentIndex) -- 835
	if currentIndex < #allEntries then -- 835
		return allEntries[currentIndex + 1] -- 836
	else -- 838
		return allEntries[1] -- 838
	end -- 835
end -- 835
footerWindow = threadLoop(function() -- 793
	local zh = useChinese -- 794
	if HttpServer.wsConnectionCount > 0 then -- 795
		return -- 796
	end -- 795
	if Keyboard:isKeyDown("Escape") then -- 797
		allClear() -- 798
		App:shutdown() -- 799
	end -- 797
	do -- 800
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 801
		if ctrl and Keyboard:isKeyDown("Q") then -- 802
			stop() -- 803
		end -- 802
		if ctrl and Keyboard:isKeyDown("Z") then -- 804
			reloadCurrentEntry() -- 805
		end -- 804
		if ctrl and Keyboard:isKeyDown(",") then -- 806
			if showFooter then -- 807
				showStats = not showStats -- 807
			else -- 807
				showStats = true -- 807
			end -- 807
			showFooter = true -- 808
			config.showFooter = showFooter -- 809
			config.showStats = showStats -- 810
		end -- 806
		if ctrl and Keyboard:isKeyDown(".") then -- 811
			if showFooter then -- 812
				showConsole = not showConsole -- 812
			else -- 812
				showConsole = true -- 812
			end -- 812
			showFooter = true -- 813
			config.showFooter = showFooter -- 814
			config.showConsole = showConsole -- 815
		end -- 811
		if ctrl and Keyboard:isKeyDown("/") then -- 816
			showFooter = not showFooter -- 817
			config.showFooter = showFooter -- 818
		end -- 816
		local left = ctrl and Keyboard:isKeyDown("Left") -- 819
		local right = ctrl and Keyboard:isKeyDown("Right") -- 820
		local currentIndex = nil -- 821
		for i, entry in ipairs(allEntries) do -- 822
			if currentEntry == entry then -- 823
				currentIndex = i -- 824
			end -- 823
		end -- 822
		if left then -- 825
			allClear() -- 826
			if currentIndex == nil then -- 827
				currentIndex = #allEntries + 1 -- 827
			end -- 827
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 828
		end -- 825
		if right then -- 832
			allClear() -- 833
			if currentIndex == nil then -- 834
				currentIndex = 0 -- 834
			end -- 834
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 835
		end -- 832
	end -- 800
	if not showEntry then -- 839
		return -- 839
	end -- 839
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 841
		reloadDevEntry() -- 845
	end -- 841
	if initFooter then -- 846
		initFooter = false -- 847
	end -- 846
	local width, height -- 849
	do -- 849
		local _obj_0 = App.visualSize -- 849
		width, height = _obj_0.width, _obj_0.height -- 849
	end -- 849
	if isInEntry or showFooter then -- 850
		SetNextWindowSize(Vec2(width, 50)) -- 851
		SetNextWindowPos(Vec2(0, height - 50)) -- 852
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 853
			return PushStyleVar("WindowRounding", 0, function() -- 854
				return Begin("Footer", windowFlags, function() -- 855
					Separator() -- 856
					if iconTex then -- 857
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 858
							showStats = not showStats -- 859
							config.showStats = showStats -- 860
						end -- 858
						SameLine() -- 861
						if Button(">_", Vec2(30, 30)) then -- 862
							showConsole = not showConsole -- 863
							config.showConsole = showConsole -- 864
						end -- 862
					end -- 857
					if isInEntry and config.updateNotification then -- 865
						SameLine() -- 866
						if ImGui.Button(zh and "更新可用" or "Update") then -- 867
							allClear() -- 868
							config.updateNotification = false -- 869
							enterDemoEntry({ -- 871
								entryName = "SelfUpdater", -- 871
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 872
							}) -- 870
						end -- 867
					end -- 865
					if not isInEntry then -- 873
						SameLine() -- 874
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 875
						local currentIndex = nil -- 876
						for i, entry in ipairs(allEntries) do -- 877
							if currentEntry == entry then -- 878
								currentIndex = i -- 879
							end -- 878
						end -- 877
						if currentIndex then -- 880
							if currentIndex > 1 then -- 881
								SameLine() -- 882
								if Button("<<", Vec2(30, 30)) then -- 883
									allClear() -- 884
									enterDemoEntry(allEntries[currentIndex - 1]) -- 885
								end -- 883
							end -- 881
							if currentIndex < #allEntries then -- 886
								SameLine() -- 887
								if Button(">>", Vec2(30, 30)) then -- 888
									allClear() -- 889
									enterDemoEntry(allEntries[currentIndex + 1]) -- 890
								end -- 888
							end -- 886
						end -- 880
						SameLine() -- 891
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 892
							reloadCurrentEntry() -- 893
						end -- 892
						if back then -- 894
							allClear() -- 895
							isInEntry = true -- 896
							currentEntry = nil -- 897
						end -- 894
					end -- 873
				end) -- 855
			end) -- 854
		end) -- 853
	end -- 850
	local showWebIDE = isInEntry -- 899
	if config.updateNotification then -- 900
		if width < 460 then -- 901
			showWebIDE = false -- 902
		end -- 901
	else -- 904
		if width < 360 then -- 904
			showWebIDE = false -- 905
		end -- 904
	end -- 900
	if showWebIDE then -- 906
		SetNextWindowBgAlpha(0.0) -- 907
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 908
		Begin("Web IDE", displayWindowFlags, function() -- 909
			do -- 910
				local url -- 910
				if webStatus ~= nil then -- 910
					url = webStatus.url -- 910
				end -- 910
				if url then -- 910
					if isDesktop and not config.fullScreen then -- 911
						if urlClicked then -- 912
							BeginDisabled(function() -- 913
								return Button(url) -- 913
							end) -- 913
						elseif Button(url) then -- 914
							urlClicked = once(function() -- 915
								return sleep(5) -- 915
							end) -- 915
							App:openURL("http://localhost:8866") -- 916
						end -- 912
					else -- 918
						TextColored(descColor, url) -- 918
					end -- 911
				else -- 920
					TextColored(descColor, zh and '不可用' or 'not available') -- 920
				end -- 910
			end -- 910
			SameLine() -- 921
			TextDisabled('(?)') -- 922
			if IsItemHovered() then -- 923
				return BeginTooltip(function() -- 924
					return PushTextWrapPos(280, function() -- 925
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 926
					end) -- 925
				end) -- 924
			end -- 923
		end) -- 909
	end -- 906
	if not isInEntry then -- 928
		SetNextWindowSize(Vec2(50, 50)) -- 929
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 930
		PushStyleColor("WindowBg", transparant, function() -- 931
			return Begin("Show", displayWindowFlags, function() -- 931
				if width >= 370 then -- 932
					local changed -- 933
					changed, showFooter = Checkbox("##dev", showFooter) -- 933
					if changed then -- 933
						config.showFooter = showFooter -- 934
					end -- 933
				end -- 932
			end) -- 931
		end) -- 931
	end -- 928
	if isInEntry or showFooter then -- 936
		if showStats then -- 937
			PushStyleVar("WindowRounding", 0, function() -- 938
				SetNextWindowPos(Vec2(0, 0), "Always") -- 939
				SetNextWindowSize(Vec2(0, height - 50)) -- 940
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 941
				config.showStats = showStats -- 942
			end) -- 938
		end -- 937
		if showConsole then -- 943
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 944
			return PushStyleVar("WindowRounding", 6, function() -- 945
				return ShowConsole() -- 946
			end) -- 945
		end -- 943
	end -- 936
end) -- 793
local MaxWidth <const> = 960 -- 948
local toolOpen = false -- 950
local filterText = nil -- 951
local anyEntryMatched = false -- 952
local match -- 953
match = function(name) -- 953
	local res = not filterText or name:lower():match(filterText) -- 954
	if res then -- 955
		anyEntryMatched = true -- 955
	end -- 955
	return res -- 956
end -- 953
local sep -- 958
sep = function() -- 958
	return SeparatorText("") -- 958
end -- 958
local thinSep -- 959
thinSep = function() -- 959
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 959
end -- 959
entryWindow = threadLoop(function() -- 961
	if App.fpsLimited ~= config.fpsLimited then -- 962
		config.fpsLimited = App.fpsLimited -- 963
	end -- 962
	if App.targetFPS ~= config.targetFPS then -- 964
		config.targetFPS = App.targetFPS -- 965
	end -- 964
	if View.vsync ~= config.vsync then -- 966
		config.vsync = View.vsync -- 967
	end -- 966
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 968
		config.fixedFPS = Director.scheduler.fixedFPS -- 969
	end -- 968
	if Director.profilerSending ~= config.webProfiler then -- 970
		config.webProfiler = Director.profilerSending -- 971
	end -- 970
	if urlClicked then -- 972
		local _, result = coroutine.resume(urlClicked) -- 973
		if result then -- 974
			coroutine.close(urlClicked) -- 975
			urlClicked = nil -- 976
		end -- 974
	end -- 972
	if not showEntry then -- 977
		return -- 977
	end -- 977
	if not isInEntry then -- 978
		return -- 978
	end -- 978
	local zh = useChinese -- 979
	if HttpServer.wsConnectionCount > 0 then -- 980
		local themeColor = App.themeColor -- 981
		local width, height -- 982
		do -- 982
			local _obj_0 = App.visualSize -- 982
			width, height = _obj_0.width, _obj_0.height -- 982
		end -- 982
		SetNextWindowBgAlpha(0.5) -- 983
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 984
		Begin("Web IDE Connected", displayWindowFlags, function() -- 985
			Separator() -- 986
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 987
			if iconTex then -- 988
				Image(icon, Vec2(24, 24)) -- 989
				SameLine() -- 990
			end -- 988
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 991
			TextColored(descColor, slogon) -- 992
			return Separator() -- 993
		end) -- 985
		return -- 994
	end -- 980
	local themeColor = App.themeColor -- 996
	local fullWidth, height -- 997
	do -- 997
		local _obj_0 = App.visualSize -- 997
		fullWidth, height = _obj_0.width, _obj_0.height -- 997
	end -- 997
	local width = math.min(MaxWidth, fullWidth) -- 998
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 999
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1000
	SetNextWindowPos(Vec2.zero) -- 1001
	SetNextWindowBgAlpha(0) -- 1002
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1003
	do -- 1004
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1005
			return Begin("Dora Dev", windowFlags, function() -- 1006
				Dummy(Vec2(fullWidth - 20, 0)) -- 1007
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1008
				if fullWidth >= 400 then -- 1009
					SameLine() -- 1010
					Dummy(Vec2(fullWidth - 400, 0)) -- 1011
					SameLine() -- 1012
					SetNextItemWidth(zh and -95 or -140) -- 1013
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1014
						"AutoSelectAll" -- 1014
					}) then -- 1014
						config.filter = filterBuf.text -- 1015
					end -- 1014
					SameLine() -- 1016
					if Button(zh and '下载' or 'Download') then -- 1017
						allClear() -- 1018
						enterDemoEntry({ -- 1020
							entryName = "ResourceDownloader", -- 1020
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1021
						}) -- 1019
					end -- 1017
				end -- 1009
				Separator() -- 1022
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1023
			end) -- 1006
		end) -- 1005
	end -- 1004
	anyEntryMatched = false -- 1025
	SetNextWindowPos(Vec2(0, 50)) -- 1026
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1027
	do -- 1028
		return PushStyleColor("WindowBg", transparant, function() -- 1029
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1030
				return PushStyleVar("Alpha", 1, function() -- 1031
					return Begin("Content", windowFlags, function() -- 1032
						local DemoViewWidth <const> = 320 -- 1033
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1034
						if filterText then -- 1035
							filterText = filterText:lower() -- 1035
						end -- 1035
						if #gamesInDev > 0 then -- 1036
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1037
							Columns(columns, false) -- 1038
							local realViewWidth = GetColumnWidth() - 50 -- 1039
							for _index_0 = 1, #gamesInDev do -- 1040
								local game = gamesInDev[_index_0] -- 1040
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1041
								local displayName -- 1050
								if repo then -- 1050
									if zh then -- 1051
										displayName = repo.title.zh -- 1051
									else -- 1051
										displayName = repo.title.en -- 1051
									end -- 1051
								end -- 1050
								if displayName == nil then -- 1052
									displayName = gameName -- 1052
								end -- 1052
								if match(displayName) then -- 1053
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1054
									SameLine() -- 1055
									TextWrapped(displayName) -- 1056
									if columns > 1 then -- 1057
										if bannerFile then -- 1058
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1059
											local displayWidth <const> = realViewWidth -- 1060
											texHeight = displayWidth * texHeight / texWidth -- 1061
											texWidth = displayWidth -- 1062
											Dummy(Vec2.zero) -- 1063
											SameLine() -- 1064
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1065
										end -- 1058
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1066
											enterDemoEntry(game) -- 1067
										end -- 1066
									else -- 1069
										if bannerFile then -- 1069
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1070
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1071
											local sizing = 0.8 -- 1072
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1073
											texWidth = displayWidth * sizing -- 1074
											if texWidth > 500 then -- 1075
												sizing = 0.6 -- 1076
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1077
												texWidth = displayWidth * sizing -- 1078
											end -- 1075
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1079
											Dummy(Vec2(padding, 0)) -- 1080
											SameLine() -- 1081
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1082
										end -- 1069
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1083
											enterDemoEntry(game) -- 1084
										end -- 1083
									end -- 1057
									if #tests == 0 and #examples == 0 then -- 1085
										thinSep() -- 1086
									end -- 1085
									NextColumn() -- 1087
								end -- 1053
								local showSep = false -- 1088
								if #examples > 0 then -- 1089
									local showExample = false -- 1090
									do -- 1091
										local _accum_0 -- 1091
										for _index_1 = 1, #examples do -- 1091
											local _des_0 = examples[_index_1] -- 1091
											local entryName = _des_0.entryName -- 1091
											if match(entryName) then -- 1092
												_accum_0 = true -- 1092
												break -- 1092
											end -- 1092
										end -- 1091
										showExample = _accum_0 -- 1091
									end -- 1091
									if showExample then -- 1093
										showSep = true -- 1094
										Columns(1, false) -- 1095
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1096
										SameLine() -- 1097
										local opened -- 1098
										if (filterText ~= nil) then -- 1098
											opened = showExample -- 1098
										else -- 1098
											opened = false -- 1098
										end -- 1098
										if game.exampleOpen == nil then -- 1099
											game.exampleOpen = opened -- 1099
										end -- 1099
										SetNextItemOpen(game.exampleOpen) -- 1100
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1101
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1102
												Columns(maxColumns, false) -- 1103
												for _index_1 = 1, #examples do -- 1104
													local example = examples[_index_1] -- 1104
													local entryName = example.entryName -- 1105
													if not match(entryName) then -- 1106
														goto _continue_0 -- 1106
													end -- 1106
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1107
														if Button(entryName, Vec2(-1, 40)) then -- 1108
															enterDemoEntry(example) -- 1109
														end -- 1108
														return NextColumn() -- 1110
													end) -- 1107
													opened = true -- 1111
													::_continue_0:: -- 1105
												end -- 1104
											end) -- 1102
										end) -- 1101
										game.exampleOpen = opened -- 1112
									end -- 1093
								end -- 1089
								if #tests > 0 then -- 1113
									local showTest = false -- 1114
									do -- 1115
										local _accum_0 -- 1115
										for _index_1 = 1, #tests do -- 1115
											local _des_0 = tests[_index_1] -- 1115
											local entryName = _des_0.entryName -- 1115
											if match(entryName) then -- 1116
												_accum_0 = true -- 1116
												break -- 1116
											end -- 1116
										end -- 1115
										showTest = _accum_0 -- 1115
									end -- 1115
									if showTest then -- 1117
										showSep = true -- 1118
										Columns(1, false) -- 1119
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1120
										SameLine() -- 1121
										local opened -- 1122
										if (filterText ~= nil) then -- 1122
											opened = showTest -- 1122
										else -- 1122
											opened = false -- 1122
										end -- 1122
										if game.testOpen == nil then -- 1123
											game.testOpen = opened -- 1123
										end -- 1123
										SetNextItemOpen(game.testOpen) -- 1124
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1125
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1126
												Columns(maxColumns, false) -- 1127
												for _index_1 = 1, #tests do -- 1128
													local test = tests[_index_1] -- 1128
													local entryName = test.entryName -- 1129
													if not match(entryName) then -- 1130
														goto _continue_0 -- 1130
													end -- 1130
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1131
														if Button(entryName, Vec2(-1, 40)) then -- 1132
															enterDemoEntry(test) -- 1133
														end -- 1132
														return NextColumn() -- 1134
													end) -- 1131
													opened = true -- 1135
													::_continue_0:: -- 1129
												end -- 1128
											end) -- 1126
										end) -- 1125
										game.testOpen = opened -- 1136
									end -- 1117
								end -- 1113
								if showSep then -- 1137
									Columns(1, false) -- 1138
									thinSep() -- 1139
									Columns(columns, false) -- 1140
								end -- 1137
							end -- 1040
						end -- 1036
						if #doraTools > 0 then -- 1141
							local showTool = false -- 1142
							do -- 1143
								local _accum_0 -- 1143
								for _index_0 = 1, #doraTools do -- 1143
									local _des_0 = doraTools[_index_0] -- 1143
									local entryName = _des_0.entryName -- 1143
									if match(entryName) then -- 1144
										_accum_0 = true -- 1144
										break -- 1144
									end -- 1144
								end -- 1143
								showTool = _accum_0 -- 1143
							end -- 1143
							if not showTool then -- 1145
								goto endEntry -- 1145
							end -- 1145
							Columns(1, false) -- 1146
							TextColored(themeColor, "Dora SSR:") -- 1147
							SameLine() -- 1148
							Text(zh and "开发支持" or "Development Support") -- 1149
							Separator() -- 1150
							if #doraTools > 0 then -- 1151
								local opened -- 1152
								if (filterText ~= nil) then -- 1152
									opened = showTool -- 1152
								else -- 1152
									opened = false -- 1152
								end -- 1152
								SetNextItemOpen(toolOpen) -- 1153
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1154
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1155
										Columns(maxColumns, false) -- 1156
										for _index_0 = 1, #doraTools do -- 1157
											local example = doraTools[_index_0] -- 1157
											local entryName = example.entryName -- 1158
											if not match(entryName) then -- 1159
												goto _continue_0 -- 1159
											end -- 1159
											if Button(entryName, Vec2(-1, 40)) then -- 1160
												enterDemoEntry(example) -- 1161
											end -- 1160
											NextColumn() -- 1162
											::_continue_0:: -- 1158
										end -- 1157
										Columns(1, false) -- 1163
										opened = true -- 1164
									end) -- 1155
								end) -- 1154
								toolOpen = opened -- 1165
							end -- 1151
						end -- 1141
						::endEntry:: -- 1166
						if not anyEntryMatched then -- 1167
							SetNextWindowBgAlpha(0) -- 1168
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1169
							Begin("Entries Not Found", displayWindowFlags, function() -- 1170
								Separator() -- 1171
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1172
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1173
								return Separator() -- 1174
							end) -- 1170
						end -- 1167
						Columns(1, false) -- 1175
						Dummy(Vec2(100, 80)) -- 1176
						return ScrollWhenDraggingOnVoid() -- 1177
					end) -- 1032
				end) -- 1031
			end) -- 1030
		end) -- 1029
	end -- 1028
end) -- 961
webStatus = require("Script.Dev.WebServer") -- 1179
return _module_0 -- 1
