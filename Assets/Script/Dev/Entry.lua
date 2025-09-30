-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local ShowConsole = _module_0.ShowConsole -- 1
local package = _G.package -- 1
local DB = Dora.DB -- 1
local View = Dora.View -- 1
local Director = Dora.Director -- 1
local thread = Dora.thread -- 1
local sleep = Dora.sleep -- 1
local Size = Dora.Size -- 1
local Vec2 = Dora.Vec2 -- 1
local Color = Dora.Color -- 1
local Buffer = Dora.Buffer -- 1
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
local showEntry = false -- 105
thread(function() -- 106
	sleep() -- 107
	sleep() -- 108
	showEntry = true -- 109
end) -- 106
isDesktop = false -- 111
if (function() -- 112
	local _val_0 = App.platform -- 112
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 112
end)() then -- 112
	isDesktop = true -- 113
	if config.fullScreen then -- 114
		App.fullScreen = true -- 115
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 116
		local size = Size(config.winWidth, config.winHeight) -- 117
		if App.winSize ~= size then -- 118
			App.winSize = size -- 119
		end -- 118
		local winX, winY -- 120
		do -- 120
			local _obj_0 = App.winPosition -- 120
			winX, winY = _obj_0.x, _obj_0.y -- 120
		end -- 120
		if (config.winX ~= nil) then -- 121
			winX = config.winX -- 122
		else -- 124
			config.winX = -1 -- 124
		end -- 121
		if (config.winY ~= nil) then -- 125
			winY = config.winY -- 126
		else -- 128
			config.winY = -1 -- 128
		end -- 125
		App.winPosition = Vec2(winX, winY) -- 129
	end -- 114
	if (config.alwaysOnTop ~= nil) then -- 130
		App.alwaysOnTop = config.alwaysOnTop -- 131
	else -- 133
		config.alwaysOnTop = true -- 133
	end -- 130
end -- 112
if (config.themeColor ~= nil) then -- 135
	App.themeColor = Color(config.themeColor) -- 136
else -- 138
	config.themeColor = App.themeColor:toARGB() -- 138
end -- 135
if not (config.locale ~= nil) then -- 140
	config.locale = App.locale -- 141
end -- 140
local showStats = false -- 143
if (config.showStats ~= nil) then -- 144
	showStats = config.showStats -- 145
else -- 147
	config.showStats = showStats -- 147
end -- 144
local showConsole = false -- 149
if (config.showConsole ~= nil) then -- 150
	showConsole = config.showConsole -- 151
else -- 153
	config.showConsole = showConsole -- 153
end -- 150
local showFooter = true -- 155
if (config.showFooter ~= nil) then -- 156
	showFooter = config.showFooter -- 157
else -- 159
	config.showFooter = showFooter -- 159
end -- 156
local filterBuf = Buffer(20) -- 161
if (config.filter ~= nil) then -- 162
	filterBuf.text = config.filter -- 163
else -- 165
	config.filter = "" -- 165
end -- 162
local engineDev = false -- 167
if (config.engineDev ~= nil) then -- 168
	engineDev = config.engineDev -- 169
else -- 171
	config.engineDev = engineDev -- 171
end -- 168
if (config.webProfiler ~= nil) then -- 173
	Director.profilerSending = config.webProfiler -- 174
else -- 176
	config.webProfiler = true -- 176
	Director.profilerSending = true -- 177
end -- 173
if not (config.drawerWidth ~= nil) then -- 179
	config.drawerWidth = 200 -- 180
end -- 179
_module_0.getConfig = function() -- 182
	return config -- 182
end -- 182
_module_0.getEngineDev = function() -- 183
	if not App.debugging then -- 184
		return false -- 184
	end -- 184
	return config.engineDev -- 185
end -- 183
local _anon_func_0 = function(App) -- 190
	local _val_0 = App.platform -- 190
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 190
end -- 190
_module_0.connectWebIDE = function() -- 187
	if not config.webIDEConnected then -- 188
		config.webIDEConnected = true -- 189
		if _anon_func_0(App) then -- 190
			local ratio = App.winSize.width / App.visualSize.width -- 191
			App.winSize = Size(640 * ratio, 480 * ratio) -- 192
		end -- 190
	end -- 188
end -- 187
local updateCheck -- 194
updateCheck = function() -- 194
	return thread(function() -- 194
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 195
		if res then -- 195
			local data = json.load(res) -- 196
			if data then -- 196
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 197
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 198
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 199
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 200
				if na < a then -- 201
					goto not_new_version -- 202
				end -- 201
				if na == a then -- 203
					if nb < b then -- 204
						goto not_new_version -- 205
					end -- 204
					if nb == b then -- 206
						if nc < c then -- 207
							goto not_new_version -- 208
						end -- 207
						if nc == c then -- 209
							goto not_new_version -- 210
						end -- 209
					end -- 206
				end -- 203
				config.updateNotification = true -- 211
				::not_new_version:: -- 212
				config.lastUpdateCheck = os.time() -- 213
			end -- 196
		end -- 195
	end) -- 213
end -- 194
if (config.lastUpdateCheck ~= nil) then -- 215
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 216
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 217
		updateCheck() -- 218
	end -- 217
else -- 220
	updateCheck() -- 220
end -- 215
local Set, Struct, LintYueGlobals, GSplit -- 222
do -- 222
	local _obj_0 = require("Utils") -- 222
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 222
end -- 222
local yueext = yue.options.extension -- 223
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 225
local building = false -- 227
local getAllFiles -- 229
getAllFiles = function(path, exts, recursive) -- 229
	if recursive == nil then -- 229
		recursive = true -- 229
	end -- 229
	local filters = Set(exts) -- 230
	local files -- 231
	if recursive then -- 231
		files = Content:getAllFiles(path) -- 232
	else -- 234
		files = Content:getFiles(path) -- 234
	end -- 231
	local _accum_0 = { } -- 235
	local _len_0 = 1 -- 235
	for _index_0 = 1, #files do -- 235
		local file = files[_index_0] -- 235
		if not filters[Path:getExt(file)] then -- 236
			goto _continue_0 -- 236
		end -- 236
		_accum_0[_len_0] = file -- 237
		_len_0 = _len_0 + 1 -- 236
		::_continue_0:: -- 236
	end -- 237
	return _accum_0 -- 237
end -- 229
_module_0["getAllFiles"] = getAllFiles -- 237
local getFileEntries -- 239
getFileEntries = function(path, recursive, excludeFiles) -- 239
	if recursive == nil then -- 239
		recursive = true -- 239
	end -- 239
	if excludeFiles == nil then -- 239
		excludeFiles = nil -- 239
	end -- 239
	local entries = { } -- 240
	local excludes -- 241
	if excludeFiles then -- 241
		excludes = Set(excludeFiles) -- 242
	end -- 241
	local _list_0 = getAllFiles(path, { -- 243
		"lua", -- 243
		"xml", -- 243
		yueext, -- 243
		"tl" -- 243
	}, recursive) -- 243
	for _index_0 = 1, #_list_0 do -- 243
		local file = _list_0[_index_0] -- 243
		local entryName = Path:getName(file) -- 244
		if excludes and excludes[entryName] then -- 245
			goto _continue_0 -- 246
		end -- 245
		local fileName = Path:replaceExt(file, "") -- 247
		fileName = Path(path, fileName) -- 248
		local entryAdded -- 249
		do -- 249
			local _accum_0 -- 249
			for _index_1 = 1, #entries do -- 249
				local _des_0 = entries[_index_1] -- 249
				local ename, efile = _des_0[1], _des_0[2] -- 249
				if entryName == ename and efile == fileName then -- 250
					_accum_0 = true -- 250
					break -- 250
				end -- 250
			end -- 250
			entryAdded = _accum_0 -- 249
		end -- 250
		if entryAdded then -- 251
			goto _continue_0 -- 251
		end -- 251
		local entry = { -- 252
			entryName, -- 252
			fileName -- 252
		} -- 252
		entries[#entries + 1] = entry -- 253
		::_continue_0:: -- 244
	end -- 253
	table.sort(entries, function(a, b) -- 254
		return a[1] < b[1] -- 254
	end) -- 254
	return entries -- 255
end -- 239
local getProjectEntries -- 257
getProjectEntries = function(path) -- 257
	local entries = { } -- 258
	local _list_0 = Content:getDirs(path) -- 259
	for _index_0 = 1, #_list_0 do -- 259
		local dir = _list_0[_index_0] -- 259
		if dir:match("^%.") then -- 260
			goto _continue_0 -- 260
		end -- 260
		local _list_1 = getAllFiles(Path(path, dir), { -- 261
			"lua", -- 261
			"xml", -- 261
			yueext, -- 261
			"tl", -- 261
			"wasm" -- 261
		}) -- 261
		for _index_1 = 1, #_list_1 do -- 261
			local file = _list_1[_index_1] -- 261
			if "init" == Path:getName(file):lower() then -- 262
				local fileName = Path:replaceExt(file, "") -- 263
				fileName = Path(path, dir, fileName) -- 264
				local entryName = Path:getName(Path:getPath(fileName)) -- 265
				local entryAdded -- 266
				do -- 266
					local _accum_0 -- 266
					for _index_2 = 1, #entries do -- 266
						local _des_0 = entries[_index_2] -- 266
						local ename, efile = _des_0[1], _des_0[2] -- 266
						if entryName == ename and efile == fileName then -- 267
							_accum_0 = true -- 267
							break -- 267
						end -- 267
					end -- 267
					entryAdded = _accum_0 -- 266
				end -- 267
				if entryAdded then -- 268
					goto _continue_1 -- 268
				end -- 268
				local examples = { } -- 269
				local tests = { } -- 270
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 271
				if Content:exist(examplePath) then -- 272
					local _list_2 = getFileEntries(examplePath) -- 273
					for _index_2 = 1, #_list_2 do -- 273
						local _des_0 = _list_2[_index_2] -- 273
						local name, ePath = _des_0[1], _des_0[2] -- 273
						local entry = { -- 275
							name, -- 275
							Path(path, dir, Path:getPath(file), ePath), -- 275
							workDir = Path:getPath(fileName) -- 276
						} -- 274
						examples[#examples + 1] = entry -- 278
					end -- 278
				end -- 272
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 279
				if Content:exist(testPath) then -- 280
					local _list_2 = getFileEntries(testPath) -- 281
					for _index_2 = 1, #_list_2 do -- 281
						local _des_0 = _list_2[_index_2] -- 281
						local name, tPath = _des_0[1], _des_0[2] -- 281
						local entry = { -- 283
							name, -- 283
							Path(path, dir, Path:getPath(file), tPath), -- 283
							workDir = Path:getPath(fileName) -- 284
						} -- 282
						tests[#tests + 1] = entry -- 286
					end -- 286
				end -- 280
				local entry = { -- 287
					entryName, -- 287
					fileName, -- 287
					examples, -- 287
					tests -- 287
				} -- 287
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 288
				if not Content:exist(bannerFile) then -- 289
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 290
					if not Content:exist(bannerFile) then -- 291
						bannerFile = nil -- 291
					end -- 291
				end -- 289
				if bannerFile then -- 292
					thread(function() -- 292
						if Cache:loadAsync(bannerFile) then -- 293
							local bannerTex = Texture2D(bannerFile) -- 294
							if bannerTex then -- 294
								entry[#entry + 1] = bannerFile -- 295
								entry[#entry + 1] = bannerTex -- 296
							end -- 294
						end -- 293
					end) -- 292
				end -- 292
				entries[#entries + 1] = entry -- 297
			end -- 262
			::_continue_1:: -- 262
		end -- 297
		::_continue_0:: -- 260
	end -- 297
	table.sort(entries, function(a, b) -- 298
		return a[1] < b[1] -- 298
	end) -- 298
	return entries -- 299
end -- 257
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
	Entity:clear() -- 507
	Platformer.Data:clear() -- 508
	Platformer.UnitAction:clear() -- 509
	Audio:stopStream(0.5) -- 510
	Struct:clear() -- 511
	View.postEffect = nil -- 512
	View.scale = scaleContent and screenScale or 1 -- 513
	Director.clearColor = Color(0xff1a1a1a) -- 514
	teal.clear() -- 515
	yue.clear() -- 516
	for _, item in pairs(ubox()) do -- 517
		local node = tolua.cast(item, "Node") -- 518
		if node then -- 518
			node:cleanup() -- 518
		end -- 518
	end -- 518
	collectgarbage() -- 519
	collectgarbage() -- 520
	Wasm:clear() -- 521
	thread(function() -- 522
		sleep() -- 523
		return Cache:removeUnused() -- 524
	end) -- 522
	setupEventHandlers() -- 525
	Content.searchPaths = searchPaths -- 526
	App.idled = true -- 527
end -- 496
_module_0["allClear"] = allClear -- 527
local clearTempFiles -- 529
clearTempFiles = function() -- 529
	local writablePath = Content.writablePath -- 530
	Content:remove(Path(writablePath, ".upload")) -- 531
	return Content:remove(Path(writablePath, ".download")) -- 532
end -- 529
local waitForWebStart = true -- 534
thread(function() -- 535
	sleep(2) -- 536
	waitForWebStart = false -- 537
end) -- 535
local reloadDevEntry -- 539
reloadDevEntry = function() -- 539
	return thread(function() -- 539
		waitForWebStart = true -- 540
		doClean() -- 541
		allClear() -- 542
		_G.require = oldRequire -- 543
		Dora.require = oldRequire -- 544
		package.loaded["Script.Dev.Entry"] = nil -- 545
		return Director.systemScheduler:schedule(function() -- 546
			Routine:clear() -- 547
			oldRequire("Script.Dev.Entry") -- 548
			return true -- 549
		end) -- 549
	end) -- 549
end -- 539
local setWorkspace -- 551
setWorkspace = function(path) -- 551
	Content.writablePath = path -- 552
	config.writablePath = Content.writablePath -- 553
	return thread(function() -- 554
		sleep() -- 555
		return reloadDevEntry() -- 556
	end) -- 556
end -- 551
local quit = false -- 558
local _anon_func_1 = function(App, _with_0) -- 574
	local _val_0 = App.platform -- 574
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 574
end -- 574
setupEventHandlers = function() -- 560
	local _with_0 = Director.postNode -- 561
	_with_0:onAppEvent(function(eventType) -- 562
		if eventType == "Quit" then -- 562
			quit = true -- 563
			allClear() -- 564
			return clearTempFiles() -- 565
		end -- 562
	end) -- 562
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
	return _with_0 -- 561
end -- 560
setupEventHandlers() -- 587
clearTempFiles() -- 588
local downloadFile -- 590
downloadFile = function(url, target) -- 590
	return Director.systemScheduler:schedule(once(function() -- 590
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 591
			if quit then -- 592
				return true -- 592
			end -- 592
			emit("AppWS", "Send", json.dump({ -- 594
				name = "Download", -- 594
				url = url, -- 594
				status = "downloading", -- 594
				progress = current / total -- 595
			})) -- 593
			return false -- 596
		end) -- 591
		return emit("AppWS", "Send", json.dump(success and { -- 598
			name = "Download", -- 598
			url = url, -- 598
			status = "completed", -- 598
			progress = 1.0 -- 599
		} or { -- 601
			name = "Download", -- 601
			url = url, -- 601
			status = "failed", -- 601
			progress = 0.0 -- 602
		})) -- 603
	end)) -- 603
end -- 590
_module_0["downloadFile"] = downloadFile -- 603
local stop -- 605
stop = function() -- 605
	if isInEntry then -- 606
		return false -- 606
	end -- 606
	allClear() -- 607
	isInEntry = true -- 608
	currentEntry = nil -- 609
	return true -- 610
end -- 605
_module_0["stop"] = stop -- 610
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 627
	if workDir == nil then -- 620
		workDir = Path:getPath(file) -- 620
	end -- 620
	Content:insertSearchPath(1, workDir) -- 621
	local scriptPath = Path(workDir, "Script") -- 622
	if Content:exist(scriptPath) then -- 623
		Content:insertSearchPath(1, scriptPath) -- 624
	end -- 623
	local result = require(file) -- 625
	if "function" == type(result) then -- 626
		result() -- 626
	end -- 626
	return nil -- 627
end -- 620
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 659
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 656
	label.alignment = "Left" -- 657
	label.textWidth = width - fontSize -- 658
	label.text = err -- 659
	return label -- 656
end -- 656
local enterEntryAsync -- 612
enterEntryAsync = function(entry) -- 612
	isInEntry = false -- 613
	App.idled = false -- 614
	emit(Profiler.EventName, "ClearLoader") -- 615
	currentEntry = entry -- 616
	local file, workDir = entry[2], entry.workDir -- 617
	sleep() -- 618
	return xpcall(_anon_func_2, function(msg) -- 660
		local err = debug.traceback(msg) -- 629
		Log("Error", err) -- 630
		allClear() -- 631
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 632
		local viewWidth, viewHeight -- 633
		do -- 633
			local _obj_0 = View.size -- 633
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 633
		end -- 633
		local width, height = viewWidth - 20, viewHeight - 20 -- 634
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 635
		Director.ui:addChild((function() -- 636
			local root = AlignNode() -- 636
			do -- 637
				local _obj_0 = App.bufferSize -- 637
				width, height = _obj_0.width, _obj_0.height -- 637
			end -- 637
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 638
			root:onAppChange(function(settingName) -- 639
				if settingName == "Size" then -- 639
					do -- 640
						local _obj_0 = App.bufferSize -- 640
						width, height = _obj_0.width, _obj_0.height -- 640
					end -- 640
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 641
				end -- 639
			end) -- 639
			root:addChild((function() -- 642
				local _with_0 = ScrollArea({ -- 643
					width = width, -- 643
					height = height, -- 644
					paddingX = 0, -- 645
					paddingY = 50, -- 646
					viewWidth = height, -- 647
					viewHeight = height -- 648
				}) -- 642
				root:onAlignLayout(function(w, h) -- 650
					_with_0.position = Vec2(w / 2, h / 2) -- 651
					w = w - 20 -- 652
					h = h - 20 -- 653
					_with_0.view.children.first.textWidth = w - fontSize -- 654
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 655
				end) -- 650
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 656
				return _with_0 -- 642
			end)()) -- 642
			return root -- 636
		end)()) -- 636
		return err -- 660
	end, Content, Path, file, require, type, workDir) -- 660
end -- 612
_module_0["enterEntryAsync"] = enterEntryAsync -- 660
local enterDemoEntry -- 662
enterDemoEntry = function(entry) -- 662
	return thread(function() -- 662
		return enterEntryAsync(entry) -- 662
	end) -- 662
end -- 662
local reloadCurrentEntry -- 664
reloadCurrentEntry = function() -- 664
	if currentEntry then -- 665
		allClear() -- 666
		return enterDemoEntry(currentEntry) -- 667
	end -- 665
end -- 664
Director.clearColor = Color(0xff1a1a1a) -- 669
local isOSSLicenseExist = Content:exist("LICENSES") -- 671
local ossLicenses = nil -- 672
local ossLicenseOpen = false -- 673
local extraOperations -- 675
extraOperations = function() -- 675
	local zh = useChinese -- 676
	if isDesktop then -- 677
		local themeColor = App.themeColor -- 678
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 679
		do -- 680
			local changed -- 680
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 680
			if changed then -- 680
				App.alwaysOnTop = alwaysOnTop -- 681
				config.alwaysOnTop = alwaysOnTop -- 682
			end -- 680
		end -- 680
		SeparatorText(zh and "工作目录" or "Workspace") -- 683
		PushTextWrapPos(400, function() -- 684
			return TextColored(themeColor, writablePath) -- 685
		end) -- 684
		if Button(zh and "改变目录" or "Set Folder") then -- 686
			App:openFileDialog(true, function(path) -- 687
				if path ~= "" then -- 688
					return setWorkspace(path) -- 688
				end -- 688
			end) -- 687
		end -- 686
		SameLine() -- 689
		if Button(zh and "使用默认" or "Use Default") then -- 690
			setWorkspace(Content.appPath) -- 691
		end -- 690
		Separator() -- 692
	end -- 677
	if isOSSLicenseExist then -- 693
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 694
			if not ossLicenses then -- 695
				ossLicenses = { } -- 696
				local licenseText = Content:load("LICENSES") -- 697
				ossLicenseOpen = (licenseText ~= nil) -- 698
				if ossLicenseOpen then -- 698
					licenseText = licenseText:gsub("\r\n", "\n") -- 699
					for license in GSplit(licenseText, "\n--------\n", true) do -- 700
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 701
						if name then -- 701
							ossLicenses[#ossLicenses + 1] = { -- 702
								name, -- 702
								text -- 702
							} -- 702
						end -- 701
					end -- 702
				end -- 698
			else -- 704
				ossLicenseOpen = true -- 704
			end -- 695
		end -- 694
		if ossLicenseOpen then -- 705
			local width, height, themeColor -- 706
			do -- 706
				local _obj_0 = App -- 706
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 706
			end -- 706
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 707
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 708
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 709
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 712
					"NoSavedSettings" -- 712
				}, function() -- 713
					for _index_0 = 1, #ossLicenses do -- 713
						local _des_0 = ossLicenses[_index_0] -- 713
						local firstLine, text = _des_0[1], _des_0[2] -- 713
						local name, license = firstLine:match("(.+): (.+)") -- 714
						TextColored(themeColor, name) -- 715
						SameLine() -- 716
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 717
							return TextWrapped(text) -- 717
						end) -- 717
					end -- 717
				end) -- 709
			end) -- 709
		end -- 705
	end -- 693
	if not App.debugging then -- 719
		return -- 719
	end -- 719
	return TreeNode(zh and "开发操作" or "Development", function() -- 720
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 721
			OpenPopup("build") -- 721
		end -- 721
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 722
			return BeginPopup("build", function() -- 722
				if Selectable(zh and "编译" or "Compile") then -- 723
					doCompile(false) -- 723
				end -- 723
				Separator() -- 724
				if Selectable(zh and "压缩" or "Minify") then -- 725
					doCompile(true) -- 725
				end -- 725
				Separator() -- 726
				if Selectable(zh and "清理" or "Clean") then -- 727
					return doClean() -- 727
				end -- 727
			end) -- 727
		end) -- 722
		if isInEntry then -- 728
			if waitForWebStart then -- 729
				BeginDisabled(function() -- 730
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 730
				end) -- 730
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 731
				reloadDevEntry() -- 732
			end -- 729
		end -- 728
		do -- 733
			local changed -- 733
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 733
			if changed then -- 733
				View.scale = scaleContent and screenScale or 1 -- 734
			end -- 733
		end -- 733
		do -- 735
			local changed -- 735
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 735
			if changed then -- 735
				config.engineDev = engineDev -- 736
			end -- 735
		end -- 735
		if testingThread then -- 737
			return BeginDisabled(function() -- 738
				return Button(zh and "开始自动测试" or "Test automatically") -- 738
			end) -- 738
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 739
			testingThread = thread(function() -- 740
				local _ <close> = setmetatable({ }, { -- 741
					__close = function() -- 741
						allClear() -- 742
						testingThread = nil -- 743
						isInEntry = true -- 744
						currentEntry = nil -- 745
						return print("Testing done!") -- 746
					end -- 741
				}) -- 741
				for _, entry in ipairs(allEntries) do -- 747
					allClear() -- 748
					print("Start " .. tostring(entry[1])) -- 749
					enterDemoEntry(entry) -- 750
					sleep(2) -- 751
					print("Stop " .. tostring(entry[1])) -- 752
				end -- 752
			end) -- 740
		end -- 737
	end) -- 720
end -- 675
local icon = Path("Script", "Dev", "icon_s.png") -- 754
local iconTex = nil -- 755
thread(function() -- 756
	if Cache:loadAsync(icon) then -- 756
		iconTex = Texture2D(icon) -- 756
	end -- 756
end) -- 756
local webStatus = nil -- 758
local urlClicked = nil -- 759
local descColor = Color(0xffa1a1a1) -- 760
local transparant = Color(0x0) -- 762
local windowFlags = { -- 763
	"NoTitleBar", -- 763
	"NoResize", -- 763
	"NoMove", -- 763
	"NoCollapse", -- 763
	"NoSavedSettings", -- 763
	"NoFocusOnAppearing", -- 763
	"NoBringToFrontOnFocus" -- 763
} -- 763
local statusFlags = { -- 772
	"NoTitleBar", -- 772
	"NoResize", -- 772
	"NoMove", -- 772
	"NoCollapse", -- 772
	"AlwaysAutoResize", -- 772
	"NoSavedSettings" -- 772
} -- 772
local displayWindowFlags = { -- 780
	"NoDecoration", -- 780
	"NoSavedSettings", -- 780
	"NoNav", -- 780
	"NoMove", -- 780
	"NoScrollWithMouse", -- 780
	"AlwaysAutoResize" -- 780
} -- 780
local initFooter = true -- 788
local _anon_func_4 = function(allEntries, currentIndex) -- 824
	if currentIndex > 1 then -- 824
		return allEntries[currentIndex - 1] -- 825
	else -- 827
		return allEntries[#allEntries] -- 827
	end -- 824
end -- 824
local _anon_func_5 = function(allEntries, currentIndex) -- 831
	if currentIndex < #allEntries then -- 831
		return allEntries[currentIndex + 1] -- 832
	else -- 834
		return allEntries[1] -- 834
	end -- 831
end -- 831
footerWindow = threadLoop(function() -- 789
	local zh = useChinese -- 790
	if HttpServer.wsConnectionCount > 0 then -- 791
		return -- 792
	end -- 791
	if Keyboard:isKeyDown("Escape") then -- 793
		allClear() -- 794
		App:shutdown() -- 795
	end -- 793
	do -- 796
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 797
		if ctrl and Keyboard:isKeyDown("Q") then -- 798
			stop() -- 799
		end -- 798
		if ctrl and Keyboard:isKeyDown("Z") then -- 800
			reloadCurrentEntry() -- 801
		end -- 800
		if ctrl and Keyboard:isKeyDown(",") then -- 802
			if showFooter then -- 803
				showStats = not showStats -- 803
			else -- 803
				showStats = true -- 803
			end -- 803
			showFooter = true -- 804
			config.showFooter = showFooter -- 805
			config.showStats = showStats -- 806
		end -- 802
		if ctrl and Keyboard:isKeyDown(".") then -- 807
			if showFooter then -- 808
				showConsole = not showConsole -- 808
			else -- 808
				showConsole = true -- 808
			end -- 808
			showFooter = true -- 809
			config.showFooter = showFooter -- 810
			config.showConsole = showConsole -- 811
		end -- 807
		if ctrl and Keyboard:isKeyDown("/") then -- 812
			showFooter = not showFooter -- 813
			config.showFooter = showFooter -- 814
		end -- 812
		local left = ctrl and Keyboard:isKeyDown("Left") -- 815
		local right = ctrl and Keyboard:isKeyDown("Right") -- 816
		local currentIndex = nil -- 817
		for i, entry in ipairs(allEntries) do -- 818
			if currentEntry == entry then -- 819
				currentIndex = i -- 820
			end -- 819
		end -- 820
		if left then -- 821
			allClear() -- 822
			if currentIndex == nil then -- 823
				currentIndex = #allEntries + 1 -- 823
			end -- 823
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 824
		end -- 821
		if right then -- 828
			allClear() -- 829
			if currentIndex == nil then -- 830
				currentIndex = 0 -- 830
			end -- 830
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 831
		end -- 828
	end -- 834
	if not showEntry then -- 835
		return -- 835
	end -- 835
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 837
		reloadDevEntry() -- 841
	end -- 837
	if initFooter then -- 842
		initFooter = false -- 843
	end -- 842
	local width, height -- 845
	do -- 845
		local _obj_0 = App.visualSize -- 845
		width, height = _obj_0.width, _obj_0.height -- 845
	end -- 845
	if isInEntry or showFooter then -- 846
		SetNextWindowSize(Vec2(width, 50)) -- 847
		SetNextWindowPos(Vec2(0, height - 50)) -- 848
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 849
			return PushStyleVar("WindowRounding", 0, function() -- 850
				return Begin("Footer", windowFlags, function() -- 851
					Separator() -- 852
					if iconTex then -- 853
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 854
							showStats = not showStats -- 855
							config.showStats = showStats -- 856
						end -- 854
						SameLine() -- 857
						if Button(">_", Vec2(30, 30)) then -- 858
							showConsole = not showConsole -- 859
							config.showConsole = showConsole -- 860
						end -- 858
					end -- 853
					if isInEntry and config.updateNotification then -- 861
						SameLine() -- 862
						if ImGui.Button(zh and "更新可用" or "Update") then -- 863
							allClear() -- 864
							config.updateNotification = false -- 865
							enterDemoEntry({ -- 867
								"SelfUpdater", -- 867
								Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 868
							}) -- 866
						end -- 863
					end -- 861
					if not isInEntry then -- 870
						SameLine() -- 871
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 872
						local currentIndex = nil -- 873
						for i, entry in ipairs(allEntries) do -- 874
							if currentEntry == entry then -- 875
								currentIndex = i -- 876
							end -- 875
						end -- 876
						if currentIndex then -- 877
							if currentIndex > 1 then -- 878
								SameLine() -- 879
								if Button("<<", Vec2(30, 30)) then -- 880
									allClear() -- 881
									enterDemoEntry(allEntries[currentIndex - 1]) -- 882
								end -- 880
							end -- 878
							if currentIndex < #allEntries then -- 883
								SameLine() -- 884
								if Button(">>", Vec2(30, 30)) then -- 885
									allClear() -- 886
									enterDemoEntry(allEntries[currentIndex + 1]) -- 887
								end -- 885
							end -- 883
						end -- 877
						SameLine() -- 888
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 889
							reloadCurrentEntry() -- 890
						end -- 889
						if back then -- 891
							allClear() -- 892
							isInEntry = true -- 893
							currentEntry = nil -- 894
						end -- 891
					end -- 870
				end) -- 851
			end) -- 850
		end) -- 849
	end -- 846
	local showWebIDE = isInEntry -- 896
	if config.updateNotification then -- 897
		if width < 460 then -- 898
			showWebIDE = false -- 899
		end -- 898
	else -- 901
		if width < 360 then -- 901
			showWebIDE = false -- 902
		end -- 901
	end -- 897
	if showWebIDE then -- 903
		SetNextWindowBgAlpha(0.0) -- 904
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 905
		Begin("Web IDE", displayWindowFlags, function() -- 906
			do -- 907
				local url -- 907
				if webStatus ~= nil then -- 907
					url = webStatus.url -- 907
				end -- 907
				if url then -- 907
					if isDesktop and not config.fullScreen then -- 908
						if urlClicked then -- 909
							BeginDisabled(function() -- 910
								return Button(url) -- 910
							end) -- 910
						elseif Button(url) then -- 911
							urlClicked = once(function() -- 912
								return sleep(5) -- 912
							end) -- 912
							App:openURL("http://localhost:8866") -- 913
						end -- 909
					else -- 915
						TextColored(descColor, url) -- 915
					end -- 908
				else -- 917
					TextColored(descColor, zh and '不可用' or 'not available') -- 917
				end -- 907
			end -- 907
			SameLine() -- 918
			TextDisabled('(?)') -- 919
			if IsItemHovered() then -- 920
				return BeginTooltip(function() -- 921
					return PushTextWrapPos(280, function() -- 922
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 923
					end) -- 923
				end) -- 923
			end -- 920
		end) -- 906
	end -- 903
	if not isInEntry then -- 925
		SetNextWindowSize(Vec2(50, 50)) -- 926
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 927
		PushStyleColor("WindowBg", transparant, function() -- 928
			return Begin("Show", displayWindowFlags, function() -- 928
				if width >= 370 then -- 929
					local changed -- 930
					changed, showFooter = Checkbox("##dev", showFooter) -- 930
					if changed then -- 930
						config.showFooter = showFooter -- 931
					end -- 930
				end -- 929
			end) -- 931
		end) -- 928
	end -- 925
	if isInEntry or showFooter then -- 933
		if showStats then -- 934
			PushStyleVar("WindowRounding", 0, function() -- 935
				SetNextWindowPos(Vec2(0, 0), "Always") -- 936
				SetNextWindowSize(Vec2(0, height - 50)) -- 937
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 938
				config.showStats = showStats -- 939
			end) -- 935
		end -- 934
		if showConsole then -- 940
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 941
			return PushStyleVar("WindowRounding", 6, function() -- 942
				return ShowConsole() -- 943
			end) -- 942
		end -- 940
	end -- 933
end) -- 789
local MaxWidth <const> = 960 -- 945
local toolOpen = false -- 947
local filterText = nil -- 948
local anyEntryMatched = false -- 949
local match -- 950
match = function(name) -- 950
	local res = not filterText or name:lower():match(filterText) -- 951
	if res then -- 952
		anyEntryMatched = true -- 952
	end -- 952
	return res -- 953
end -- 950
local sep -- 955
sep = function() -- 955
	return SeparatorText("") -- 955
end -- 955
local thinSep -- 956
thinSep = function() -- 956
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 956
end -- 956
entryWindow = threadLoop(function() -- 958
	if App.fpsLimited ~= config.fpsLimited then -- 959
		config.fpsLimited = App.fpsLimited -- 960
	end -- 959
	if App.targetFPS ~= config.targetFPS then -- 961
		config.targetFPS = App.targetFPS -- 962
	end -- 961
	if View.vsync ~= config.vsync then -- 963
		config.vsync = View.vsync -- 964
	end -- 963
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 965
		config.fixedFPS = Director.scheduler.fixedFPS -- 966
	end -- 965
	if Director.profilerSending ~= config.webProfiler then -- 967
		config.webProfiler = Director.profilerSending -- 968
	end -- 967
	if urlClicked then -- 969
		local _, result = coroutine.resume(urlClicked) -- 970
		if result then -- 971
			coroutine.close(urlClicked) -- 972
			urlClicked = nil -- 973
		end -- 971
	end -- 969
	if not showEntry then -- 974
		return -- 974
	end -- 974
	if not isInEntry then -- 975
		return -- 975
	end -- 975
	local zh = useChinese -- 976
	if HttpServer.wsConnectionCount > 0 then -- 977
		local themeColor = App.themeColor -- 978
		local width, height -- 979
		do -- 979
			local _obj_0 = App.visualSize -- 979
			width, height = _obj_0.width, _obj_0.height -- 979
		end -- 979
		SetNextWindowBgAlpha(0.5) -- 980
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 981
		Begin("Web IDE Connected", displayWindowFlags, function() -- 982
			Separator() -- 983
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 984
			if iconTex then -- 985
				Image(icon, Vec2(24, 24)) -- 986
				SameLine() -- 987
			end -- 985
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 988
			TextColored(descColor, slogon) -- 989
			return Separator() -- 990
		end) -- 982
		return -- 991
	end -- 977
	local themeColor = App.themeColor -- 993
	local fullWidth, height -- 994
	do -- 994
		local _obj_0 = App.visualSize -- 994
		fullWidth, height = _obj_0.width, _obj_0.height -- 994
	end -- 994
	local width = math.min(MaxWidth, fullWidth) -- 995
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 996
	local maxColumns = math.max(math.floor(width / 200), 1) -- 997
	SetNextWindowPos(Vec2.zero) -- 998
	SetNextWindowBgAlpha(0) -- 999
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1000
	do -- 1001
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1002
			return Begin("Dora Dev", windowFlags, function() -- 1003
				Dummy(Vec2(fullWidth - 20, 0)) -- 1004
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1005
				if fullWidth >= 400 then -- 1006
					SameLine() -- 1007
					Dummy(Vec2(fullWidth - 400, 0)) -- 1008
					SameLine() -- 1009
					SetNextItemWidth(zh and -95 or -140) -- 1010
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1011
						"AutoSelectAll" -- 1011
					}) then -- 1011
						config.filter = filterBuf.text -- 1012
					end -- 1011
					SameLine() -- 1013
					if Button(zh and '下载' or 'Download') then -- 1014
						allClear() -- 1015
						enterDemoEntry({ -- 1017
							"ResourceDownloader", -- 1017
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1018
						}) -- 1016
					end -- 1014
				end -- 1006
				Separator() -- 1020
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1021
			end) -- 1003
		end) -- 1002
	end -- 1021
	anyEntryMatched = false -- 1023
	SetNextWindowPos(Vec2(0, 50)) -- 1024
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1025
	do -- 1026
		return PushStyleColor("WindowBg", transparant, function() -- 1027
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1028
				return PushStyleVar("Alpha", 1, function() -- 1029
					return Begin("Content", windowFlags, function() -- 1030
						local DemoViewWidth <const> = 320 -- 1031
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1032
						if filterText then -- 1033
							filterText = filterText:lower() -- 1033
						end -- 1033
						if #gamesInDev > 0 then -- 1034
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1035
							Columns(columns, false) -- 1036
							local realViewWidth = GetColumnWidth() - 50 -- 1037
							for _index_0 = 1, #gamesInDev do -- 1038
								local game = gamesInDev[_index_0] -- 1038
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1039
								if match(gameName) then -- 1040
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1041
									SameLine() -- 1042
									TextWrapped(gameName) -- 1043
									if columns > 1 then -- 1044
										if bannerFile then -- 1045
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1046
											local displayWidth <const> = realViewWidth -- 1047
											texHeight = displayWidth * texHeight / texWidth -- 1048
											texWidth = displayWidth -- 1049
											Dummy(Vec2.zero) -- 1050
											SameLine() -- 1051
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1052
										end -- 1045
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1053
											enterDemoEntry(game) -- 1054
										end -- 1053
									else -- 1056
										if bannerFile then -- 1056
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1057
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1058
											local sizing = 0.8 -- 1059
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1060
											texWidth = displayWidth * sizing -- 1061
											if texWidth > 500 then -- 1062
												sizing = 0.6 -- 1063
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1064
												texWidth = displayWidth * sizing -- 1065
											end -- 1062
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1066
											Dummy(Vec2(padding, 0)) -- 1067
											SameLine() -- 1068
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1069
										end -- 1056
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1070
											enterDemoEntry(game) -- 1071
										end -- 1070
									end -- 1044
									if #tests == 0 and #examples == 0 then -- 1072
										thinSep() -- 1073
									end -- 1072
									NextColumn() -- 1074
								end -- 1040
								local showSep = false -- 1075
								if #examples > 0 then -- 1076
									local showExample = false -- 1077
									do -- 1078
										local _accum_0 -- 1078
										for _index_1 = 1, #examples do -- 1078
											local _des_0 = examples[_index_1] -- 1078
											local name = _des_0[1] -- 1078
											if match(name) then -- 1079
												_accum_0 = true -- 1079
												break -- 1079
											end -- 1079
										end -- 1079
										showExample = _accum_0 -- 1078
									end -- 1079
									if showExample then -- 1080
										showSep = true -- 1081
										Columns(1, false) -- 1082
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1083
										SameLine() -- 1084
										local opened -- 1085
										if (filterText ~= nil) then -- 1085
											opened = showExample -- 1085
										else -- 1085
											opened = false -- 1085
										end -- 1085
										if game.exampleOpen == nil then -- 1086
											game.exampleOpen = opened -- 1086
										end -- 1086
										SetNextItemOpen(game.exampleOpen) -- 1087
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1088
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1089
												Columns(maxColumns, false) -- 1090
												for _index_1 = 1, #examples do -- 1091
													local example = examples[_index_1] -- 1091
													if not match(example[1]) then -- 1092
														goto _continue_0 -- 1092
													end -- 1092
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1093
														if Button(example[1], Vec2(-1, 40)) then -- 1094
															enterDemoEntry(example) -- 1095
														end -- 1094
														return NextColumn() -- 1096
													end) -- 1093
													opened = true -- 1097
													::_continue_0:: -- 1092
												end -- 1097
											end) -- 1089
										end) -- 1088
										game.exampleOpen = opened -- 1098
									end -- 1080
								end -- 1076
								if #tests > 0 then -- 1099
									local showTest = false -- 1100
									do -- 1101
										local _accum_0 -- 1101
										for _index_1 = 1, #tests do -- 1101
											local _des_0 = tests[_index_1] -- 1101
											local name = _des_0[1] -- 1101
											if match(name) then -- 1102
												_accum_0 = true -- 1102
												break -- 1102
											end -- 1102
										end -- 1102
										showTest = _accum_0 -- 1101
									end -- 1102
									if showTest then -- 1103
										showSep = true -- 1104
										Columns(1, false) -- 1105
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1106
										SameLine() -- 1107
										local opened -- 1108
										if (filterText ~= nil) then -- 1108
											opened = showTest -- 1108
										else -- 1108
											opened = false -- 1108
										end -- 1108
										if game.testOpen == nil then -- 1109
											game.testOpen = opened -- 1109
										end -- 1109
										SetNextItemOpen(game.testOpen) -- 1110
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1111
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1112
												Columns(maxColumns, false) -- 1113
												for _index_1 = 1, #tests do -- 1114
													local test = tests[_index_1] -- 1114
													if not match(test[1]) then -- 1115
														goto _continue_0 -- 1115
													end -- 1115
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1116
														if Button(test[1], Vec2(-1, 40)) then -- 1117
															enterDemoEntry(test) -- 1118
														end -- 1117
														return NextColumn() -- 1119
													end) -- 1116
													opened = true -- 1120
													::_continue_0:: -- 1115
												end -- 1120
											end) -- 1112
										end) -- 1111
										game.testOpen = opened -- 1121
									end -- 1103
								end -- 1099
								if showSep then -- 1122
									Columns(1, false) -- 1123
									thinSep() -- 1124
									Columns(columns, false) -- 1125
								end -- 1122
							end -- 1125
						end -- 1034
						if #doraTools > 0 then -- 1126
							local showTool = false -- 1127
							do -- 1128
								local _accum_0 -- 1128
								for _index_0 = 1, #doraTools do -- 1128
									local _des_0 = doraTools[_index_0] -- 1128
									local name = _des_0[1] -- 1128
									if match(name) then -- 1129
										_accum_0 = true -- 1129
										break -- 1129
									end -- 1129
								end -- 1129
								showTool = _accum_0 -- 1128
							end -- 1129
							if not showTool then -- 1130
								goto endEntry -- 1130
							end -- 1130
							Columns(1, false) -- 1131
							TextColored(themeColor, "Dora SSR:") -- 1132
							SameLine() -- 1133
							Text(zh and "开发支持" or "Development Support") -- 1134
							Separator() -- 1135
							if #doraTools > 0 then -- 1136
								local opened -- 1137
								if (filterText ~= nil) then -- 1137
									opened = showTool -- 1137
								else -- 1137
									opened = false -- 1137
								end -- 1137
								SetNextItemOpen(toolOpen) -- 1138
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1139
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1140
										Columns(maxColumns, false) -- 1141
										for _index_0 = 1, #doraTools do -- 1142
											local example = doraTools[_index_0] -- 1142
											if not match(example[1]) then -- 1143
												goto _continue_0 -- 1143
											end -- 1143
											if Button(example[1], Vec2(-1, 40)) then -- 1144
												enterDemoEntry(example) -- 1145
											end -- 1144
											NextColumn() -- 1146
											::_continue_0:: -- 1143
										end -- 1146
										Columns(1, false) -- 1147
										opened = true -- 1148
									end) -- 1140
								end) -- 1139
								toolOpen = opened -- 1149
							end -- 1136
						end -- 1126
						::endEntry:: -- 1150
						if not anyEntryMatched then -- 1151
							SetNextWindowBgAlpha(0) -- 1152
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1153
							Begin("Entries Not Found", displayWindowFlags, function() -- 1154
								Separator() -- 1155
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1156
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1157
								return Separator() -- 1158
							end) -- 1154
						end -- 1151
						Columns(1, false) -- 1159
						Dummy(Vec2(100, 80)) -- 1160
						return ScrollWhenDraggingOnVoid() -- 1161
					end) -- 1030
				end) -- 1029
			end) -- 1028
		end) -- 1027
	end -- 1161
end) -- 958
webStatus = require("Script.Dev.WebServer") -- 1163
return _module_0 -- 1163
