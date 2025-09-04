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
							if bannerTex then -- 295
								entry[#entry + 1] = bannerFile -- 296
								entry[#entry + 1] = bannerTex -- 297
							end -- 295
						end -- 293
					end) -- 292
				end -- 292
				entries[#entries + 1] = entry -- 298
			end -- 262
			::_continue_1:: -- 262
		end -- 298
		::_continue_0:: -- 260
	end -- 298
	table.sort(entries, function(a, b) -- 299
		return a[1] < b[1] -- 299
	end) -- 299
	return entries -- 300
end -- 257
local gamesInDev -- 302
local doraTools -- 303
local allEntries -- 304
local updateEntries -- 306
updateEntries = function() -- 306
	gamesInDev = getProjectEntries(Content.writablePath) -- 307
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 308
	allEntries = { } -- 310
	for _index_0 = 1, #gamesInDev do -- 311
		local game = gamesInDev[_index_0] -- 311
		allEntries[#allEntries + 1] = game -- 312
		local examples, tests = game[3], game[4] -- 313
		for _index_1 = 1, #examples do -- 314
			local example = examples[_index_1] -- 314
			allEntries[#allEntries + 1] = example -- 315
		end -- 315
		for _index_1 = 1, #tests do -- 316
			local test = tests[_index_1] -- 316
			allEntries[#allEntries + 1] = test -- 317
		end -- 317
	end -- 317
end -- 306
updateEntries() -- 319
local doCompile -- 321
doCompile = function(minify) -- 321
	if building then -- 322
		return -- 322
	end -- 322
	building = true -- 323
	local startTime = App.runningTime -- 324
	local luaFiles = { } -- 325
	local yueFiles = { } -- 326
	local xmlFiles = { } -- 327
	local tlFiles = { } -- 328
	local writablePath = Content.writablePath -- 329
	local buildPaths = { -- 331
		{ -- 332
			Content.assetPath, -- 332
			Path(writablePath, ".build"), -- 333
			"" -- 334
		} -- 331
	} -- 330
	for _index_0 = 1, #gamesInDev do -- 337
		local _des_0 = gamesInDev[_index_0] -- 337
		local entryFile = _des_0[2] -- 337
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 338
		buildPaths[#buildPaths + 1] = { -- 340
			Path(writablePath, gamePath), -- 340
			Path(writablePath, ".build", gamePath), -- 341
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 342
			gamePath -- 343
		} -- 339
	end -- 343
	for _index_0 = 1, #buildPaths do -- 344
		local _des_0 = buildPaths[_index_0] -- 344
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 344
		if not Content:exist(inputPath) then -- 345
			goto _continue_0 -- 345
		end -- 345
		local _list_0 = getAllFiles(inputPath, { -- 347
			"lua" -- 347
		}) -- 347
		for _index_1 = 1, #_list_0 do -- 347
			local file = _list_0[_index_1] -- 347
			luaFiles[#luaFiles + 1] = { -- 349
				file, -- 349
				Path(inputPath, file), -- 350
				Path(outputPath, file), -- 351
				gamePath -- 352
			} -- 348
		end -- 352
		local _list_1 = getAllFiles(inputPath, { -- 354
			yueext -- 354
		}) -- 354
		for _index_1 = 1, #_list_1 do -- 354
			local file = _list_1[_index_1] -- 354
			yueFiles[#yueFiles + 1] = { -- 356
				file, -- 356
				Path(inputPath, file), -- 357
				Path(outputPath, Path:replaceExt(file, "lua")), -- 358
				searchPath, -- 359
				gamePath -- 360
			} -- 355
		end -- 360
		local _list_2 = getAllFiles(inputPath, { -- 362
			"xml" -- 362
		}) -- 362
		for _index_1 = 1, #_list_2 do -- 362
			local file = _list_2[_index_1] -- 362
			xmlFiles[#xmlFiles + 1] = { -- 364
				file, -- 364
				Path(inputPath, file), -- 365
				Path(outputPath, Path:replaceExt(file, "lua")), -- 366
				gamePath -- 367
			} -- 363
		end -- 367
		local _list_3 = getAllFiles(inputPath, { -- 369
			"tl" -- 369
		}) -- 369
		for _index_1 = 1, #_list_3 do -- 369
			local file = _list_3[_index_1] -- 369
			if not file:match(".*%.d%.tl$") then -- 370
				tlFiles[#tlFiles + 1] = { -- 372
					file, -- 372
					Path(inputPath, file), -- 373
					Path(outputPath, Path:replaceExt(file, "lua")), -- 374
					searchPath, -- 375
					gamePath -- 376
				} -- 371
			end -- 370
		end -- 376
		::_continue_0:: -- 345
	end -- 376
	local paths -- 378
	do -- 378
		local _tbl_0 = { } -- 378
		local _list_0 = { -- 379
			luaFiles, -- 379
			yueFiles, -- 379
			xmlFiles, -- 379
			tlFiles -- 379
		} -- 379
		for _index_0 = 1, #_list_0 do -- 379
			local files = _list_0[_index_0] -- 379
			for _index_1 = 1, #files do -- 380
				local file = files[_index_1] -- 380
				_tbl_0[Path:getPath(file[3])] = true -- 378
			end -- 378
		end -- 378
		paths = _tbl_0 -- 378
	end -- 380
	for path in pairs(paths) do -- 382
		Content:mkdir(path) -- 382
	end -- 382
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 384
	local fileCount = 0 -- 385
	local errors = { } -- 386
	for _index_0 = 1, #yueFiles do -- 387
		local _des_0 = yueFiles[_index_0] -- 387
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 387
		local filename -- 388
		if gamePath then -- 388
			filename = Path(gamePath, file) -- 388
		else -- 388
			filename = file -- 388
		end -- 388
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 389
			if not codes then -- 390
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 391
				return -- 392
			end -- 390
			local success, result = LintYueGlobals(codes, globals) -- 393
			if success then -- 394
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 395
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 396
				codes = codes:gsub("^\n*", "") -- 397
				if not (result == "") then -- 398
					result = result .. "\n" -- 398
				end -- 398
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 399
			else -- 401
				local yueCodes = Content:load(input) -- 401
				if yueCodes then -- 401
					local globalErrors = { } -- 402
					for _index_1 = 1, #result do -- 403
						local _des_1 = result[_index_1] -- 403
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 403
						local countLine = 1 -- 404
						local code = "" -- 405
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 406
							if countLine == line then -- 407
								code = lineCode -- 408
								break -- 409
							end -- 407
							countLine = countLine + 1 -- 410
						end -- 410
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 411
					end -- 411
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 412
				else -- 414
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 414
				end -- 401
			end -- 394
		end, function(success) -- 389
			if success then -- 415
				print("Yue compiled: " .. tostring(filename)) -- 415
			end -- 415
			fileCount = fileCount + 1 -- 416
		end) -- 389
	end -- 416
	thread(function() -- 418
		for _index_0 = 1, #xmlFiles do -- 419
			local _des_0 = xmlFiles[_index_0] -- 419
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 419
			local filename -- 420
			if gamePath then -- 420
				filename = Path(gamePath, file) -- 420
			else -- 420
				filename = file -- 420
			end -- 420
			local sourceCodes = Content:loadAsync(input) -- 421
			local codes, err = xml.tolua(sourceCodes) -- 422
			if not codes then -- 423
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 424
			else -- 426
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 426
				print("Xml compiled: " .. tostring(filename)) -- 427
			end -- 423
			fileCount = fileCount + 1 -- 428
		end -- 428
	end) -- 418
	thread(function() -- 430
		for _index_0 = 1, #tlFiles do -- 431
			local _des_0 = tlFiles[_index_0] -- 431
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 431
			local filename -- 432
			if gamePath then -- 432
				filename = Path(gamePath, file) -- 432
			else -- 432
				filename = file -- 432
			end -- 432
			local sourceCodes = Content:loadAsync(input) -- 433
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 434
			if not codes then -- 435
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 436
			else -- 438
				Content:saveAsync(output, codes) -- 438
				print("Teal compiled: " .. tostring(filename)) -- 439
			end -- 435
			fileCount = fileCount + 1 -- 440
		end -- 440
	end) -- 430
	return thread(function() -- 442
		wait(function() -- 443
			return fileCount == totalFiles -- 443
		end) -- 443
		if minify then -- 444
			local _list_0 = { -- 445
				yueFiles, -- 445
				xmlFiles, -- 445
				tlFiles -- 445
			} -- 445
			for _index_0 = 1, #_list_0 do -- 445
				local files = _list_0[_index_0] -- 445
				for _index_1 = 1, #files do -- 445
					local file = files[_index_1] -- 445
					local output = Path:replaceExt(file[3], "lua") -- 446
					luaFiles[#luaFiles + 1] = { -- 448
						Path:replaceExt(file[1], "lua"), -- 448
						output, -- 449
						output -- 450
					} -- 447
				end -- 450
			end -- 450
			local FormatMini -- 452
			do -- 452
				local _obj_0 = require("luaminify") -- 452
				FormatMini = _obj_0.FormatMini -- 452
			end -- 452
			for _index_0 = 1, #luaFiles do -- 453
				local _des_0 = luaFiles[_index_0] -- 453
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 453
				if Content:exist(input) then -- 454
					local sourceCodes = Content:loadAsync(input) -- 455
					local res, err = FormatMini(sourceCodes) -- 456
					if res then -- 457
						Content:saveAsync(output, res) -- 458
						print("Minify: " .. tostring(file)) -- 459
					else -- 461
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 461
					end -- 457
				else -- 463
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 463
				end -- 454
			end -- 463
			package.loaded["luaminify.FormatMini"] = nil -- 464
			package.loaded["luaminify.ParseLua"] = nil -- 465
			package.loaded["luaminify.Scope"] = nil -- 466
			package.loaded["luaminify.Util"] = nil -- 467
		end -- 444
		local errorMessage = table.concat(errors, "\n") -- 468
		if errorMessage ~= "" then -- 469
			print(errorMessage) -- 469
		end -- 469
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 470
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 471
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 472
		Content:clearPathCache() -- 473
		teal.clear() -- 474
		yue.clear() -- 475
		building = false -- 476
	end) -- 476
end -- 321
local doClean -- 478
doClean = function() -- 478
	if building then -- 479
		return -- 479
	end -- 479
	local writablePath = Content.writablePath -- 480
	local targetDir = Path(writablePath, ".build") -- 481
	Content:clearPathCache() -- 482
	if Content:remove(targetDir) then -- 483
		return print("Cleaned: " .. tostring(targetDir)) -- 484
	end -- 483
end -- 478
local screenScale = 2.0 -- 486
local scaleContent = false -- 487
local isInEntry = true -- 488
local currentEntry = nil -- 489
local footerWindow = nil -- 491
local entryWindow = nil -- 492
local testingThread = nil -- 493
local setupEventHandlers = nil -- 495
local allClear -- 497
allClear = function() -- 497
	local _list_0 = Routine -- 498
	for _index_0 = 1, #_list_0 do -- 498
		local routine = _list_0[_index_0] -- 498
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 500
			goto _continue_0 -- 501
		else -- 503
			Routine:remove(routine) -- 503
		end -- 503
		::_continue_0:: -- 499
	end -- 503
	for _index_0 = 1, #moduleCache do -- 504
		local module = moduleCache[_index_0] -- 504
		package.loaded[module] = nil -- 505
	end -- 505
	moduleCache = { } -- 506
	Director:cleanup() -- 507
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
	Wasm:clear() -- 522
	thread(function() -- 523
		sleep() -- 524
		return Cache:removeUnused() -- 525
	end) -- 523
	setupEventHandlers() -- 526
	Content.searchPaths = searchPaths -- 527
	App.idled = true -- 528
end -- 497
_module_0["allClear"] = allClear -- 528
local clearTempFiles -- 530
clearTempFiles = function() -- 530
	local writablePath = Content.writablePath -- 531
	Content:remove(Path(writablePath, ".upload")) -- 532
	return Content:remove(Path(writablePath, ".download")) -- 533
end -- 530
local waitForWebStart = true -- 535
thread(function() -- 536
	sleep(2) -- 537
	waitForWebStart = false -- 538
end) -- 536
local reloadDevEntry -- 540
reloadDevEntry = function() -- 540
	return thread(function() -- 540
		waitForWebStart = true -- 541
		doClean() -- 542
		allClear() -- 543
		_G.require = oldRequire -- 544
		Dora.require = oldRequire -- 545
		package.loaded["Script.Dev.Entry"] = nil -- 546
		return Director.systemScheduler:schedule(function() -- 547
			Routine:clear() -- 548
			oldRequire("Script.Dev.Entry") -- 549
			return true -- 550
		end) -- 550
	end) -- 550
end -- 540
local setWorkspace -- 552
setWorkspace = function(path) -- 552
	Content.writablePath = path -- 553
	config.writablePath = Content.writablePath -- 554
	return thread(function() -- 555
		sleep() -- 556
		return reloadDevEntry() -- 557
	end) -- 557
end -- 552
local quit = false -- 559
local _anon_func_1 = function(App, _with_0) -- 575
	local _val_0 = App.platform -- 575
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 575
end -- 575
setupEventHandlers = function() -- 561
	local _with_0 = Director.postNode -- 562
	_with_0:onAppEvent(function(eventType) -- 563
		if eventType == "Quit" then -- 563
			quit = true -- 564
			allClear() -- 565
			return clearTempFiles() -- 566
		end -- 563
	end) -- 563
	_with_0:onAppChange(function(settingName) -- 567
		if "Theme" == settingName then -- 568
			config.themeColor = App.themeColor:toARGB() -- 569
		elseif "Locale" == settingName then -- 570
			config.locale = App.locale -- 571
			updateLocale() -- 572
			return teal.clear(true) -- 573
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 574
			if _anon_func_1(App, _with_0) then -- 575
				if "FullScreen" == settingName then -- 577
					config.fullScreen = App.fullScreen -- 577
				elseif "Position" == settingName then -- 578
					local _obj_0 = App.winPosition -- 578
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 578
				elseif "Size" == settingName then -- 579
					local width, height -- 580
					do -- 580
						local _obj_0 = App.winSize -- 580
						width, height = _obj_0.width, _obj_0.height -- 580
					end -- 580
					config.winWidth = width -- 581
					config.winHeight = height -- 582
				end -- 582
			end -- 575
		end -- 582
	end) -- 567
	_with_0:onAppWS(function(eventType) -- 583
		if eventType == "Close" then -- 583
			if HttpServer.wsConnectionCount == 0 then -- 584
				return updateEntries() -- 585
			end -- 584
		end -- 583
	end) -- 583
	_with_0:slot("UpdateEntries", function() -- 586
		return updateEntries() -- 586
	end) -- 586
	return _with_0 -- 562
end -- 561
setupEventHandlers() -- 588
clearTempFiles() -- 589
local downloadFile -- 591
downloadFile = function(url, target) -- 591
	return Director.systemScheduler:schedule(once(function() -- 591
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 592
			if quit then -- 593
				return true -- 593
			end -- 593
			emit("AppWS", "Send", json.dump({ -- 595
				name = "Download", -- 595
				url = url, -- 595
				status = "downloading", -- 595
				progress = current / total -- 596
			})) -- 594
			return false -- 597
		end) -- 592
		return emit("AppWS", "Send", json.dump(success and { -- 599
			name = "Download", -- 599
			url = url, -- 599
			status = "completed", -- 599
			progress = 1.0 -- 600
		} or { -- 602
			name = "Download", -- 602
			url = url, -- 602
			status = "failed", -- 602
			progress = 0.0 -- 603
		})) -- 604
	end)) -- 604
end -- 591
_module_0["downloadFile"] = downloadFile -- 604
local stop -- 606
stop = function() -- 606
	if isInEntry then -- 607
		return false -- 607
	end -- 607
	allClear() -- 608
	isInEntry = true -- 609
	currentEntry = nil -- 610
	return true -- 611
end -- 606
_module_0["stop"] = stop -- 611
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 628
	if workDir == nil then -- 621
		workDir = Path:getPath(file) -- 621
	end -- 621
	Content:insertSearchPath(1, workDir) -- 622
	local scriptPath = Path(workDir, "Script") -- 623
	if Content:exist(scriptPath) then -- 624
		Content:insertSearchPath(1, scriptPath) -- 625
	end -- 624
	local result = require(file) -- 626
	if "function" == type(result) then -- 627
		result() -- 627
	end -- 627
	return nil -- 628
end -- 621
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 660
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 657
	label.alignment = "Left" -- 658
	label.textWidth = width - fontSize -- 659
	label.text = err -- 660
	return label -- 657
end -- 657
local enterEntryAsync -- 613
enterEntryAsync = function(entry) -- 613
	isInEntry = false -- 614
	App.idled = false -- 615
	emit(Profiler.EventName, "ClearLoader") -- 616
	currentEntry = entry -- 617
	local file, workDir = entry[2], entry.workDir -- 618
	sleep() -- 619
	return xpcall(_anon_func_2, function(msg) -- 661
		local err = debug.traceback(msg) -- 630
		Log("Error", err) -- 631
		allClear() -- 632
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 633
		local viewWidth, viewHeight -- 634
		do -- 634
			local _obj_0 = View.size -- 634
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 634
		end -- 634
		local width, height = viewWidth - 20, viewHeight - 20 -- 635
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 636
		Director.ui:addChild((function() -- 637
			local root = AlignNode() -- 637
			do -- 638
				local _obj_0 = App.bufferSize -- 638
				width, height = _obj_0.width, _obj_0.height -- 638
			end -- 638
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 639
			root:onAppChange(function(settingName) -- 640
				if settingName == "Size" then -- 640
					do -- 641
						local _obj_0 = App.bufferSize -- 641
						width, height = _obj_0.width, _obj_0.height -- 641
					end -- 641
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 642
				end -- 640
			end) -- 640
			root:addChild((function() -- 643
				local _with_0 = ScrollArea({ -- 644
					width = width, -- 644
					height = height, -- 645
					paddingX = 0, -- 646
					paddingY = 50, -- 647
					viewWidth = height, -- 648
					viewHeight = height -- 649
				}) -- 643
				root:onAlignLayout(function(w, h) -- 651
					_with_0.position = Vec2(w / 2, h / 2) -- 652
					w = w - 20 -- 653
					h = h - 20 -- 654
					_with_0.view.children.first.textWidth = w - fontSize -- 655
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 656
				end) -- 651
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 657
				return _with_0 -- 643
			end)()) -- 643
			return root -- 637
		end)()) -- 637
		return err -- 661
	end, Content, Path, file, require, type, workDir) -- 661
end -- 613
_module_0["enterEntryAsync"] = enterEntryAsync -- 661
local enterDemoEntry -- 663
enterDemoEntry = function(entry) -- 663
	return thread(function() -- 663
		return enterEntryAsync(entry) -- 663
	end) -- 663
end -- 663
local reloadCurrentEntry -- 665
reloadCurrentEntry = function() -- 665
	if currentEntry then -- 666
		allClear() -- 667
		return enterDemoEntry(currentEntry) -- 668
	end -- 666
end -- 665
Director.clearColor = Color(0xff1a1a1a) -- 670
local isOSSLicenseExist = Content:exist("LICENSES") -- 672
local ossLicenses = nil -- 673
local ossLicenseOpen = false -- 674
local extraOperations -- 676
extraOperations = function() -- 676
	local zh = useChinese -- 677
	if isDesktop then -- 678
		local themeColor = App.themeColor -- 679
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 680
		do -- 681
			local changed -- 681
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 681
			if changed then -- 681
				App.alwaysOnTop = alwaysOnTop -- 682
				config.alwaysOnTop = alwaysOnTop -- 683
			end -- 681
		end -- 681
		SeparatorText(zh and "工作目录" or "Workspace") -- 684
		PushTextWrapPos(400, function() -- 685
			return TextColored(themeColor, writablePath) -- 686
		end) -- 685
		if Button(zh and "改变目录" or "Set Folder") then -- 687
			App:openFileDialog(true, function(path) -- 688
				if path ~= "" then -- 689
					return setWorkspace(path) -- 689
				end -- 689
			end) -- 688
		end -- 687
		SameLine() -- 690
		if Button(zh and "使用默认" or "Use Default") then -- 691
			setWorkspace(Content.appPath) -- 692
		end -- 691
		Separator() -- 693
	end -- 678
	if isOSSLicenseExist then -- 694
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 695
			if not ossLicenses then -- 696
				ossLicenses = { } -- 697
				local licenseText = Content:load("LICENSES") -- 698
				ossLicenseOpen = (licenseText ~= nil) -- 699
				if ossLicenseOpen then -- 699
					licenseText = licenseText:gsub("\r\n", "\n") -- 700
					for license in GSplit(licenseText, "\n--------\n", true) do -- 701
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 702
						if name then -- 702
							ossLicenses[#ossLicenses + 1] = { -- 703
								name, -- 703
								text -- 703
							} -- 703
						end -- 702
					end -- 703
				end -- 699
			else -- 705
				ossLicenseOpen = true -- 705
			end -- 696
		end -- 695
		if ossLicenseOpen then -- 706
			local width, height, themeColor -- 707
			do -- 707
				local _obj_0 = App -- 707
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 707
			end -- 707
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 708
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 709
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 710
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 713
					"NoSavedSettings" -- 713
				}, function() -- 714
					for _index_0 = 1, #ossLicenses do -- 714
						local _des_0 = ossLicenses[_index_0] -- 714
						local firstLine, text = _des_0[1], _des_0[2] -- 714
						local name, license = firstLine:match("(.+): (.+)") -- 715
						TextColored(themeColor, name) -- 716
						SameLine() -- 717
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 718
							return TextWrapped(text) -- 718
						end) -- 718
					end -- 718
				end) -- 710
			end) -- 710
		end -- 706
	end -- 694
	if not App.debugging then -- 720
		return -- 720
	end -- 720
	return TreeNode(zh and "开发操作" or "Development", function() -- 721
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 722
			OpenPopup("build") -- 722
		end -- 722
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 723
			return BeginPopup("build", function() -- 723
				if Selectable(zh and "编译" or "Compile") then -- 724
					doCompile(false) -- 724
				end -- 724
				Separator() -- 725
				if Selectable(zh and "压缩" or "Minify") then -- 726
					doCompile(true) -- 726
				end -- 726
				Separator() -- 727
				if Selectable(zh and "清理" or "Clean") then -- 728
					return doClean() -- 728
				end -- 728
			end) -- 728
		end) -- 723
		if isInEntry then -- 729
			if waitForWebStart then -- 730
				BeginDisabled(function() -- 731
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 731
				end) -- 731
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 732
				reloadDevEntry() -- 733
			end -- 730
		end -- 729
		do -- 734
			local changed -- 734
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 734
			if changed then -- 734
				View.scale = scaleContent and screenScale or 1 -- 735
			end -- 734
		end -- 734
		do -- 736
			local changed -- 736
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 736
			if changed then -- 736
				config.engineDev = engineDev -- 737
			end -- 736
		end -- 736
		if testingThread then -- 738
			return BeginDisabled(function() -- 739
				return Button(zh and "开始自动测试" or "Test automatically") -- 739
			end) -- 739
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 740
			testingThread = thread(function() -- 741
				local _ <close> = setmetatable({ }, { -- 742
					__close = function() -- 742
						allClear() -- 743
						testingThread = nil -- 744
						isInEntry = true -- 745
						currentEntry = nil -- 746
						return print("Testing done!") -- 747
					end -- 742
				}) -- 742
				for _, entry in ipairs(allEntries) do -- 748
					allClear() -- 749
					print("Start " .. tostring(entry[1])) -- 750
					enterDemoEntry(entry) -- 751
					sleep(2) -- 752
					print("Stop " .. tostring(entry[1])) -- 753
				end -- 753
			end) -- 741
		end -- 738
	end) -- 721
end -- 676
local icon = Path("Script", "Dev", "icon_s.png") -- 755
local iconTex = nil -- 756
thread(function() -- 757
	if Cache:loadAsync(icon) then -- 757
		iconTex = Texture2D(icon) -- 757
	end -- 757
end) -- 757
local webStatus = nil -- 759
local urlClicked = nil -- 760
local descColor = Color(0xffa1a1a1) -- 761
local transparant = Color(0x0) -- 763
local windowFlags = { -- 764
	"NoTitleBar", -- 764
	"NoResize", -- 764
	"NoMove", -- 764
	"NoCollapse", -- 764
	"NoSavedSettings", -- 764
	"NoFocusOnAppearing", -- 764
	"NoBringToFrontOnFocus" -- 764
} -- 764
local statusFlags = { -- 773
	"NoTitleBar", -- 773
	"NoResize", -- 773
	"NoMove", -- 773
	"NoCollapse", -- 773
	"AlwaysAutoResize", -- 773
	"NoSavedSettings" -- 773
} -- 773
local displayWindowFlags = { -- 781
	"NoDecoration", -- 781
	"NoSavedSettings", -- 781
	"NoNav", -- 781
	"NoMove", -- 781
	"NoScrollWithMouse", -- 781
	"AlwaysAutoResize" -- 781
} -- 781
local initFooter = true -- 789
local _anon_func_4 = function(allEntries, currentIndex) -- 825
	if currentIndex > 1 then -- 825
		return allEntries[currentIndex - 1] -- 826
	else -- 828
		return allEntries[#allEntries] -- 828
	end -- 825
end -- 825
local _anon_func_5 = function(allEntries, currentIndex) -- 832
	if currentIndex < #allEntries then -- 832
		return allEntries[currentIndex + 1] -- 833
	else -- 835
		return allEntries[1] -- 835
	end -- 832
end -- 832
footerWindow = threadLoop(function() -- 790
	local zh = useChinese -- 791
	if HttpServer.wsConnectionCount > 0 then -- 792
		return -- 793
	end -- 792
	if Keyboard:isKeyDown("Escape") then -- 794
		allClear() -- 795
		App:shutdown() -- 796
	end -- 794
	do -- 797
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 798
		if ctrl and Keyboard:isKeyDown("Q") then -- 799
			stop() -- 800
		end -- 799
		if ctrl and Keyboard:isKeyDown("Z") then -- 801
			reloadCurrentEntry() -- 802
		end -- 801
		if ctrl and Keyboard:isKeyDown(",") then -- 803
			if showFooter then -- 804
				showStats = not showStats -- 804
			else -- 804
				showStats = true -- 804
			end -- 804
			showFooter = true -- 805
			config.showFooter = showFooter -- 806
			config.showStats = showStats -- 807
		end -- 803
		if ctrl and Keyboard:isKeyDown(".") then -- 808
			if showFooter then -- 809
				showConsole = not showConsole -- 809
			else -- 809
				showConsole = true -- 809
			end -- 809
			showFooter = true -- 810
			config.showFooter = showFooter -- 811
			config.showConsole = showConsole -- 812
		end -- 808
		if ctrl and Keyboard:isKeyDown("/") then -- 813
			showFooter = not showFooter -- 814
			config.showFooter = showFooter -- 815
		end -- 813
		local left = ctrl and Keyboard:isKeyDown("Left") -- 816
		local right = ctrl and Keyboard:isKeyDown("Right") -- 817
		local currentIndex = nil -- 818
		for i, entry in ipairs(allEntries) do -- 819
			if currentEntry == entry then -- 820
				currentIndex = i -- 821
			end -- 820
		end -- 821
		if left then -- 822
			allClear() -- 823
			if currentIndex == nil then -- 824
				currentIndex = #allEntries + 1 -- 824
			end -- 824
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 825
		end -- 822
		if right then -- 829
			allClear() -- 830
			if currentIndex == nil then -- 831
				currentIndex = 0 -- 831
			end -- 831
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 832
		end -- 829
	end -- 835
	if not showEntry then -- 836
		return -- 836
	end -- 836
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 838
		reloadDevEntry() -- 842
	end -- 838
	if initFooter then -- 843
		initFooter = false -- 844
	end -- 843
	local width, height -- 846
	do -- 846
		local _obj_0 = App.visualSize -- 846
		width, height = _obj_0.width, _obj_0.height -- 846
	end -- 846
	if isInEntry or showFooter then -- 847
		SetNextWindowSize(Vec2(width, 50)) -- 848
		SetNextWindowPos(Vec2(0, height - 50)) -- 849
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 850
			return PushStyleVar("WindowRounding", 0, function() -- 851
				return Begin("Footer", windowFlags, function() -- 852
					Separator() -- 853
					if iconTex then -- 854
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 855
							showStats = not showStats -- 856
							config.showStats = showStats -- 857
						end -- 855
						SameLine() -- 858
						if Button(">_", Vec2(30, 30)) then -- 859
							showConsole = not showConsole -- 860
							config.showConsole = showConsole -- 861
						end -- 859
					end -- 854
					if isInEntry and config.updateNotification then -- 862
						SameLine() -- 863
						if ImGui.Button(zh and "更新可用" or "Update") then -- 864
							allClear() -- 865
							config.updateNotification = false -- 866
							enterDemoEntry({ -- 868
								"SelfUpdater", -- 868
								Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 869
							}) -- 867
						end -- 864
					end -- 862
					if not isInEntry then -- 871
						SameLine() -- 872
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 873
						local currentIndex = nil -- 874
						for i, entry in ipairs(allEntries) do -- 875
							if currentEntry == entry then -- 876
								currentIndex = i -- 877
							end -- 876
						end -- 877
						if currentIndex then -- 878
							if currentIndex > 1 then -- 879
								SameLine() -- 880
								if Button("<<", Vec2(30, 30)) then -- 881
									allClear() -- 882
									enterDemoEntry(allEntries[currentIndex - 1]) -- 883
								end -- 881
							end -- 879
							if currentIndex < #allEntries then -- 884
								SameLine() -- 885
								if Button(">>", Vec2(30, 30)) then -- 886
									allClear() -- 887
									enterDemoEntry(allEntries[currentIndex + 1]) -- 888
								end -- 886
							end -- 884
						end -- 878
						SameLine() -- 889
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 890
							reloadCurrentEntry() -- 891
						end -- 890
						if back then -- 892
							allClear() -- 893
							isInEntry = true -- 894
							currentEntry = nil -- 895
						end -- 892
					end -- 871
				end) -- 852
			end) -- 851
		end) -- 850
	end -- 847
	local showWebIDE = isInEntry -- 897
	if config.updateNotification then -- 898
		if width < 460 then -- 899
			showWebIDE = false -- 900
		end -- 899
	else -- 902
		if width < 360 then -- 902
			showWebIDE = false -- 903
		end -- 902
	end -- 898
	if showWebIDE then -- 904
		SetNextWindowBgAlpha(0.0) -- 905
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 906
		Begin("Web IDE", displayWindowFlags, function() -- 907
			do -- 908
				local url -- 908
				if webStatus ~= nil then -- 908
					url = webStatus.url -- 908
				end -- 908
				if url then -- 908
					if isDesktop and not config.fullScreen then -- 909
						if urlClicked then -- 910
							BeginDisabled(function() -- 911
								return Button(url) -- 911
							end) -- 911
						elseif Button(url) then -- 912
							urlClicked = once(function() -- 913
								return sleep(5) -- 913
							end) -- 913
							App:openURL("http://localhost:8866") -- 914
						end -- 910
					else -- 916
						TextColored(descColor, url) -- 916
					end -- 909
				else -- 918
					TextColored(descColor, zh and '不可用' or 'not available') -- 918
				end -- 908
			end -- 908
			SameLine() -- 919
			TextDisabled('(?)') -- 920
			if IsItemHovered() then -- 921
				return BeginTooltip(function() -- 922
					return PushTextWrapPos(280, function() -- 923
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 924
					end) -- 924
				end) -- 924
			end -- 921
		end) -- 907
	end -- 904
	if not isInEntry then -- 926
		SetNextWindowSize(Vec2(50, 50)) -- 927
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 928
		PushStyleColor("WindowBg", transparant, function() -- 929
			return Begin("Show", displayWindowFlags, function() -- 929
				if width >= 370 then -- 930
					local changed -- 931
					changed, showFooter = Checkbox("##dev", showFooter) -- 931
					if changed then -- 931
						config.showFooter = showFooter -- 932
					end -- 931
				end -- 930
			end) -- 932
		end) -- 929
	end -- 926
	if isInEntry or showFooter then -- 934
		if showStats then -- 935
			PushStyleVar("WindowRounding", 0, function() -- 936
				SetNextWindowPos(Vec2(0, 0), "Always") -- 937
				SetNextWindowSize(Vec2(0, height - 50)) -- 938
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 939
				config.showStats = showStats -- 940
			end) -- 936
		end -- 935
		if showConsole then -- 941
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 942
			return PushStyleVar("WindowRounding", 6, function() -- 943
				return ShowConsole() -- 944
			end) -- 943
		end -- 941
	end -- 934
end) -- 790
local MaxWidth <const> = 960 -- 946
local toolOpen = false -- 948
local filterText = nil -- 949
local anyEntryMatched = false -- 950
local match -- 951
match = function(name) -- 951
	local res = not filterText or name:lower():match(filterText) -- 952
	if res then -- 953
		anyEntryMatched = true -- 953
	end -- 953
	return res -- 954
end -- 951
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
	local zh = useChinese -- 977
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
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 985
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
	local width = math.min(MaxWidth, fullWidth) -- 996
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 997
	local maxColumns = math.max(math.floor(width / 200), 1) -- 998
	SetNextWindowPos(Vec2.zero) -- 999
	SetNextWindowBgAlpha(0) -- 1000
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1001
	do -- 1002
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1003
			return Begin("Dora Dev", windowFlags, function() -- 1004
				Dummy(Vec2(fullWidth - 20, 0)) -- 1005
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1006
				if fullWidth >= 400 then -- 1007
					SameLine() -- 1008
					Dummy(Vec2(fullWidth - 400, 0)) -- 1009
					SameLine() -- 1010
					SetNextItemWidth(zh and -95 or -140) -- 1011
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1012
						"AutoSelectAll" -- 1012
					}) then -- 1012
						config.filter = filterBuf.text -- 1013
					end -- 1012
					SameLine() -- 1014
					if Button(zh and '下载' or 'Download') then -- 1015
						allClear() -- 1016
						enterDemoEntry({ -- 1018
							"ResourceDownloader", -- 1018
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1019
						}) -- 1017
					end -- 1015
				end -- 1007
				Separator() -- 1021
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1022
			end) -- 1004
		end) -- 1003
	end -- 1022
	anyEntryMatched = false -- 1024
	SetNextWindowPos(Vec2(0, 50)) -- 1025
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1026
	do -- 1027
		return PushStyleColor("WindowBg", transparant, function() -- 1028
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1029
				return PushStyleVar("Alpha", 1, function() -- 1030
					return Begin("Content", windowFlags, function() -- 1031
						local DemoViewWidth <const> = 320 -- 1032
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1033
						if filterText then -- 1034
							filterText = filterText:lower() -- 1034
						end -- 1034
						if #gamesInDev > 0 then -- 1035
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1036
							Columns(columns, false) -- 1037
							local realViewWidth = GetColumnWidth() - 50 -- 1038
							for _index_0 = 1, #gamesInDev do -- 1039
								local game = gamesInDev[_index_0] -- 1039
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1040
								if match(gameName) then -- 1041
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1042
									SameLine() -- 1043
									TextWrapped(gameName) -- 1044
									if columns > 1 then -- 1045
										if bannerFile then -- 1046
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1047
											local displayWidth <const> = realViewWidth -- 1048
											texHeight = displayWidth * texHeight / texWidth -- 1049
											texWidth = displayWidth -- 1050
											Dummy(Vec2.zero) -- 1051
											SameLine() -- 1052
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1053
										end -- 1046
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1054
											enterDemoEntry(game) -- 1055
										end -- 1054
									else -- 1057
										if bannerFile then -- 1057
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1058
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1059
											local sizing = 0.8 -- 1060
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1061
											texWidth = displayWidth * sizing -- 1062
											if texWidth > 500 then -- 1063
												sizing = 0.6 -- 1064
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1065
												texWidth = displayWidth * sizing -- 1066
											end -- 1063
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1067
											Dummy(Vec2(padding, 0)) -- 1068
											SameLine() -- 1069
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1070
										end -- 1057
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1071
											enterDemoEntry(game) -- 1072
										end -- 1071
									end -- 1045
									if #tests == 0 and #examples == 0 then -- 1073
										thinSep() -- 1074
									end -- 1073
									NextColumn() -- 1075
								end -- 1041
								local showSep = false -- 1076
								if #examples > 0 then -- 1077
									local showExample = false -- 1078
									do -- 1079
										local _accum_0 -- 1079
										for _index_1 = 1, #examples do -- 1079
											local _des_0 = examples[_index_1] -- 1079
											local name = _des_0[1] -- 1079
											if match(name) then -- 1080
												_accum_0 = true -- 1080
												break -- 1080
											end -- 1080
										end -- 1080
										showExample = _accum_0 -- 1079
									end -- 1080
									if showExample then -- 1081
										showSep = true -- 1082
										Columns(1, false) -- 1083
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1084
										SameLine() -- 1085
										local opened -- 1086
										if (filterText ~= nil) then -- 1086
											opened = showExample -- 1086
										else -- 1086
											opened = false -- 1086
										end -- 1086
										if game.exampleOpen == nil then -- 1087
											game.exampleOpen = opened -- 1087
										end -- 1087
										SetNextItemOpen(game.exampleOpen) -- 1088
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1089
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1090
												Columns(maxColumns, false) -- 1091
												for _index_1 = 1, #examples do -- 1092
													local example = examples[_index_1] -- 1092
													if not match(example[1]) then -- 1093
														goto _continue_0 -- 1093
													end -- 1093
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1094
														if Button(example[1], Vec2(-1, 40)) then -- 1095
															enterDemoEntry(example) -- 1096
														end -- 1095
														return NextColumn() -- 1097
													end) -- 1094
													opened = true -- 1098
													::_continue_0:: -- 1093
												end -- 1098
											end) -- 1090
										end) -- 1089
										game.exampleOpen = opened -- 1099
									end -- 1081
								end -- 1077
								if #tests > 0 then -- 1100
									local showTest = false -- 1101
									do -- 1102
										local _accum_0 -- 1102
										for _index_1 = 1, #tests do -- 1102
											local _des_0 = tests[_index_1] -- 1102
											local name = _des_0[1] -- 1102
											if match(name) then -- 1103
												_accum_0 = true -- 1103
												break -- 1103
											end -- 1103
										end -- 1103
										showTest = _accum_0 -- 1102
									end -- 1103
									if showTest then -- 1104
										showSep = true -- 1105
										Columns(1, false) -- 1106
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1107
										SameLine() -- 1108
										local opened -- 1109
										if (filterText ~= nil) then -- 1109
											opened = showTest -- 1109
										else -- 1109
											opened = false -- 1109
										end -- 1109
										if game.testOpen == nil then -- 1110
											game.testOpen = opened -- 1110
										end -- 1110
										SetNextItemOpen(game.testOpen) -- 1111
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1112
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1113
												Columns(maxColumns, false) -- 1114
												for _index_1 = 1, #tests do -- 1115
													local test = tests[_index_1] -- 1115
													if not match(test[1]) then -- 1116
														goto _continue_0 -- 1116
													end -- 1116
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1117
														if Button(test[1], Vec2(-1, 40)) then -- 1118
															enterDemoEntry(test) -- 1119
														end -- 1118
														return NextColumn() -- 1120
													end) -- 1117
													opened = true -- 1121
													::_continue_0:: -- 1116
												end -- 1121
											end) -- 1113
										end) -- 1112
										game.testOpen = opened -- 1122
									end -- 1104
								end -- 1100
								if showSep then -- 1123
									Columns(1, false) -- 1124
									thinSep() -- 1125
									Columns(columns, false) -- 1126
								end -- 1123
							end -- 1126
						end -- 1035
						if #doraTools > 0 then -- 1127
							local showTool = false -- 1128
							do -- 1129
								local _accum_0 -- 1129
								for _index_0 = 1, #doraTools do -- 1129
									local _des_0 = doraTools[_index_0] -- 1129
									local name = _des_0[1] -- 1129
									if match(name) then -- 1130
										_accum_0 = true -- 1130
										break -- 1130
									end -- 1130
								end -- 1130
								showTool = _accum_0 -- 1129
							end -- 1130
							if not showTool then -- 1131
								goto endEntry -- 1131
							end -- 1131
							Columns(1, false) -- 1132
							TextColored(themeColor, "Dora SSR:") -- 1133
							SameLine() -- 1134
							Text(zh and "开发支持" or "Development Support") -- 1135
							Separator() -- 1136
							if #doraTools > 0 then -- 1137
								local opened -- 1138
								if (filterText ~= nil) then -- 1138
									opened = showTool -- 1138
								else -- 1138
									opened = false -- 1138
								end -- 1138
								SetNextItemOpen(toolOpen) -- 1139
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1140
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1141
										Columns(maxColumns, false) -- 1142
										for _index_0 = 1, #doraTools do -- 1143
											local example = doraTools[_index_0] -- 1143
											if not match(example[1]) then -- 1144
												goto _continue_0 -- 1144
											end -- 1144
											if Button(example[1], Vec2(-1, 40)) then -- 1145
												enterDemoEntry(example) -- 1146
											end -- 1145
											NextColumn() -- 1147
											::_continue_0:: -- 1144
										end -- 1147
										Columns(1, false) -- 1148
										opened = true -- 1149
									end) -- 1141
								end) -- 1140
								toolOpen = opened -- 1150
							end -- 1137
						end -- 1127
						::endEntry:: -- 1151
						if not anyEntryMatched then -- 1152
							SetNextWindowBgAlpha(0) -- 1153
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1154
							Begin("Entries Not Found", displayWindowFlags, function() -- 1155
								Separator() -- 1156
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1157
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1158
								return Separator() -- 1159
							end) -- 1155
						end -- 1152
						Columns(1, false) -- 1160
						Dummy(Vec2(100, 80)) -- 1161
						return ScrollWhenDraggingOnVoid() -- 1162
					end) -- 1031
				end) -- 1030
			end) -- 1029
		end) -- 1028
	end -- 1162
end) -- 959
webStatus = require("Script.Dev.WebServer") -- 1164
return _module_0 -- 1164
