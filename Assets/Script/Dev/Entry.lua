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
local once = Dora.once -- 1
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
local _anon_func_1 = function(App, _with_0) -- 572
	local _val_0 = App.platform -- 572
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 572
end -- 572
setupEventHandlers = function() -- 559
	local _with_0 = Director.postNode -- 560
	_with_0:onAppEvent(function(eventType) -- 561
		if eventType == "Quit" then -- 561
			allClear() -- 562
			return clearTempFiles() -- 563
		end -- 561
	end) -- 561
	_with_0:onAppChange(function(settingName) -- 564
		if "Theme" == settingName then -- 565
			config.themeColor = App.themeColor:toARGB() -- 566
		elseif "Locale" == settingName then -- 567
			config.locale = App.locale -- 568
			updateLocale() -- 569
			return teal.clear(true) -- 570
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 571
			if _anon_func_1(App, _with_0) then -- 572
				if "FullScreen" == settingName then -- 574
					config.fullScreen = App.fullScreen -- 574
				elseif "Position" == settingName then -- 575
					local _obj_0 = App.winPosition -- 575
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 575
				elseif "Size" == settingName then -- 576
					local width, height -- 577
					do -- 577
						local _obj_0 = App.winSize -- 577
						width, height = _obj_0.width, _obj_0.height -- 577
					end -- 577
					config.winWidth = width -- 578
					config.winHeight = height -- 579
				end -- 579
			end -- 572
		end -- 579
	end) -- 564
	_with_0:onAppWS(function(eventType) -- 580
		if eventType == "Close" then -- 580
			if HttpServer.wsConnectionCount == 0 then -- 581
				return updateEntries() -- 582
			end -- 581
		end -- 580
	end) -- 580
	_with_0:slot("UpdateEntries", function() -- 583
		return updateEntries() -- 583
	end) -- 583
	return _with_0 -- 560
end -- 559
setupEventHandlers() -- 585
clearTempFiles() -- 586
local stop -- 588
stop = function() -- 588
	if isInEntry then -- 589
		return false -- 589
	end -- 589
	allClear() -- 590
	isInEntry = true -- 591
	currentEntry = nil -- 592
	return true -- 593
end -- 588
_module_0["stop"] = stop -- 593
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 610
	if workDir == nil then -- 603
		workDir = Path:getPath(file) -- 603
	end -- 603
	Content:insertSearchPath(1, workDir) -- 604
	local scriptPath = Path(workDir, "Script") -- 605
	if Content:exist(scriptPath) then -- 606
		Content:insertSearchPath(1, scriptPath) -- 607
	end -- 606
	local result = require(file) -- 608
	if "function" == type(result) then -- 609
		result() -- 609
	end -- 609
	return nil -- 610
end -- 603
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 642
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 639
	label.alignment = "Left" -- 640
	label.textWidth = width - fontSize -- 641
	label.text = err -- 642
	return label -- 639
end -- 639
local enterEntryAsync -- 595
enterEntryAsync = function(entry) -- 595
	isInEntry = false -- 596
	App.idled = false -- 597
	emit(Profiler.EventName, "ClearLoader") -- 598
	currentEntry = entry -- 599
	local file, workDir = entry[2], entry.workDir -- 600
	sleep() -- 601
	return xpcall(_anon_func_2, function(msg) -- 643
		local err = debug.traceback(msg) -- 612
		Log("Error", err) -- 613
		allClear() -- 614
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 615
		local viewWidth, viewHeight -- 616
		do -- 616
			local _obj_0 = View.size -- 616
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 616
		end -- 616
		local width, height = viewWidth - 20, viewHeight - 20 -- 617
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 618
		Director.ui:addChild((function() -- 619
			local root = AlignNode() -- 619
			do -- 620
				local _obj_0 = App.bufferSize -- 620
				width, height = _obj_0.width, _obj_0.height -- 620
			end -- 620
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 621
			root:onAppChange(function(settingName) -- 622
				if settingName == "Size" then -- 622
					do -- 623
						local _obj_0 = App.bufferSize -- 623
						width, height = _obj_0.width, _obj_0.height -- 623
					end -- 623
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 624
				end -- 622
			end) -- 622
			root:addChild((function() -- 625
				local _with_0 = ScrollArea({ -- 626
					width = width, -- 626
					height = height, -- 627
					paddingX = 0, -- 628
					paddingY = 50, -- 629
					viewWidth = height, -- 630
					viewHeight = height -- 631
				}) -- 625
				root:onAlignLayout(function(w, h) -- 633
					_with_0.position = Vec2(w / 2, h / 2) -- 634
					w = w - 20 -- 635
					h = h - 20 -- 636
					_with_0.view.children.first.textWidth = w - fontSize -- 637
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 638
				end) -- 633
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 639
				return _with_0 -- 625
			end)()) -- 625
			return root -- 619
		end)()) -- 619
		return err -- 643
	end, Content, Path, file, require, type, workDir) -- 643
end -- 595
_module_0["enterEntryAsync"] = enterEntryAsync -- 643
local enterDemoEntry -- 645
enterDemoEntry = function(entry) -- 645
	return thread(function() -- 645
		return enterEntryAsync(entry) -- 645
	end) -- 645
end -- 645
local reloadCurrentEntry -- 647
reloadCurrentEntry = function() -- 647
	if currentEntry then -- 648
		allClear() -- 649
		return enterDemoEntry(currentEntry) -- 650
	end -- 648
end -- 647
Director.clearColor = Color(0xff1a1a1a) -- 652
local isOSSLicenseExist = Content:exist("LICENSES") -- 654
local ossLicenses = nil -- 655
local ossLicenseOpen = false -- 656
local extraOperations -- 658
extraOperations = function() -- 658
	local zh = useChinese -- 659
	if isDesktop then -- 660
		local themeColor = App.themeColor -- 661
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 662
		do -- 663
			local changed -- 663
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 663
			if changed then -- 663
				App.alwaysOnTop = alwaysOnTop -- 664
				config.alwaysOnTop = alwaysOnTop -- 665
			end -- 663
		end -- 663
		SeparatorText(zh and "工作目录" or "Workspace") -- 666
		PushTextWrapPos(400, function() -- 667
			return TextColored(themeColor, writablePath) -- 668
		end) -- 667
		if Button(zh and "改变目录" or "Set Folder") then -- 669
			App:openFileDialog(true, function(path) -- 670
				if path ~= "" then -- 671
					return setWorkspace(path) -- 671
				end -- 671
			end) -- 670
		end -- 669
		SameLine() -- 672
		if Button(zh and "使用默认" or "Use Default") then -- 673
			setWorkspace(Content.appPath) -- 674
		end -- 673
		Separator() -- 675
	end -- 660
	if isOSSLicenseExist then -- 676
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 677
			if not ossLicenses then -- 678
				ossLicenses = { } -- 679
				local licenseText = Content:load("LICENSES") -- 680
				ossLicenseOpen = (licenseText ~= nil) -- 681
				if ossLicenseOpen then -- 681
					licenseText = licenseText:gsub("\r\n", "\n") -- 682
					for license in GSplit(licenseText, "\n--------\n", true) do -- 683
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 684
						if name then -- 684
							ossLicenses[#ossLicenses + 1] = { -- 685
								name, -- 685
								text -- 685
							} -- 685
						end -- 684
					end -- 685
				end -- 681
			else -- 687
				ossLicenseOpen = true -- 687
			end -- 678
		end -- 677
		if ossLicenseOpen then -- 688
			local width, height, themeColor -- 689
			do -- 689
				local _obj_0 = App -- 689
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 689
			end -- 689
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 690
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 691
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 692
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 695
					"NoSavedSettings" -- 695
				}, function() -- 696
					for _index_0 = 1, #ossLicenses do -- 696
						local _des_0 = ossLicenses[_index_0] -- 696
						local firstLine, text = _des_0[1], _des_0[2] -- 696
						local name, license = firstLine:match("(.+): (.+)") -- 697
						TextColored(themeColor, name) -- 698
						SameLine() -- 699
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 700
							return TextWrapped(text) -- 700
						end) -- 700
					end -- 700
				end) -- 692
			end) -- 692
		end -- 688
	end -- 676
	if not App.debugging then -- 702
		return -- 702
	end -- 702
	return TreeNode(zh and "开发操作" or "Development", function() -- 703
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 704
			OpenPopup("build") -- 704
		end -- 704
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 705
			return BeginPopup("build", function() -- 705
				if Selectable(zh and "编译" or "Compile") then -- 706
					doCompile(false) -- 706
				end -- 706
				Separator() -- 707
				if Selectable(zh and "压缩" or "Minify") then -- 708
					doCompile(true) -- 708
				end -- 708
				Separator() -- 709
				if Selectable(zh and "清理" or "Clean") then -- 710
					return doClean() -- 710
				end -- 710
			end) -- 710
		end) -- 705
		if isInEntry then -- 711
			if waitForWebStart then -- 712
				BeginDisabled(function() -- 713
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 713
				end) -- 713
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 714
				reloadDevEntry() -- 715
			end -- 712
		end -- 711
		do -- 716
			local changed -- 716
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 716
			if changed then -- 716
				View.scale = scaleContent and screenScale or 1 -- 717
			end -- 716
		end -- 716
		do -- 718
			local changed -- 718
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 718
			if changed then -- 718
				config.engineDev = engineDev -- 719
			end -- 718
		end -- 718
		if testingThread then -- 720
			return BeginDisabled(function() -- 721
				return Button(zh and "开始自动测试" or "Test automatically") -- 721
			end) -- 721
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 722
			testingThread = thread(function() -- 723
				local _ <close> = setmetatable({ }, { -- 724
					__close = function() -- 724
						allClear() -- 725
						testingThread = nil -- 726
						isInEntry = true -- 727
						currentEntry = nil -- 728
						return print("Testing done!") -- 729
					end -- 724
				}) -- 724
				for _, entry in ipairs(allEntries) do -- 730
					allClear() -- 731
					print("Start " .. tostring(entry[1])) -- 732
					enterDemoEntry(entry) -- 733
					sleep(2) -- 734
					print("Stop " .. tostring(entry[1])) -- 735
				end -- 735
			end) -- 723
		end -- 720
	end) -- 703
end -- 658
local icon = Path("Script", "Dev", "icon_s.png") -- 737
local iconTex = nil -- 738
thread(function() -- 739
	if Cache:loadAsync(icon) then -- 739
		iconTex = Texture2D(icon) -- 739
	end -- 739
end) -- 739
local webStatus = nil -- 741
local urlClicked = nil -- 742
local descColor = Color(0xffa1a1a1) -- 743
local transparant = Color(0x0) -- 745
local windowFlags = { -- 746
	"NoTitleBar", -- 746
	"NoResize", -- 746
	"NoMove", -- 746
	"NoCollapse", -- 746
	"NoSavedSettings", -- 746
	"NoFocusOnAppearing", -- 746
	"NoBringToFrontOnFocus" -- 746
} -- 746
local statusFlags = { -- 755
	"NoTitleBar", -- 755
	"NoResize", -- 755
	"NoMove", -- 755
	"NoCollapse", -- 755
	"AlwaysAutoResize", -- 755
	"NoSavedSettings" -- 755
} -- 755
local displayWindowFlags = { -- 763
	"NoDecoration", -- 763
	"NoSavedSettings", -- 763
	"NoNav", -- 763
	"NoMove", -- 763
	"NoScrollWithMouse", -- 763
	"AlwaysAutoResize" -- 763
} -- 763
local initFooter = true -- 771
local _anon_func_4 = function(allEntries, currentIndex) -- 807
	if currentIndex > 1 then -- 807
		return allEntries[currentIndex - 1] -- 808
	else -- 810
		return allEntries[#allEntries] -- 810
	end -- 807
end -- 807
local _anon_func_5 = function(allEntries, currentIndex) -- 814
	if currentIndex < #allEntries then -- 814
		return allEntries[currentIndex + 1] -- 815
	else -- 817
		return allEntries[1] -- 817
	end -- 814
end -- 814
footerWindow = threadLoop(function() -- 772
	local zh = useChinese -- 773
	if HttpServer.wsConnectionCount > 0 then -- 774
		return -- 775
	end -- 774
	if Keyboard:isKeyDown("Escape") then -- 776
		allClear() -- 777
		App:shutdown() -- 778
	end -- 776
	do -- 779
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 780
		if ctrl and Keyboard:isKeyDown("Q") then -- 781
			stop() -- 782
		end -- 781
		if ctrl and Keyboard:isKeyDown("Z") then -- 783
			reloadCurrentEntry() -- 784
		end -- 783
		if ctrl and Keyboard:isKeyDown(",") then -- 785
			if showFooter then -- 786
				showStats = not showStats -- 786
			else -- 786
				showStats = true -- 786
			end -- 786
			showFooter = true -- 787
			config.showFooter = showFooter -- 788
			config.showStats = showStats -- 789
		end -- 785
		if ctrl and Keyboard:isKeyDown(".") then -- 790
			if showFooter then -- 791
				showConsole = not showConsole -- 791
			else -- 791
				showConsole = true -- 791
			end -- 791
			showFooter = true -- 792
			config.showFooter = showFooter -- 793
			config.showConsole = showConsole -- 794
		end -- 790
		if ctrl and Keyboard:isKeyDown("/") then -- 795
			showFooter = not showFooter -- 796
			config.showFooter = showFooter -- 797
		end -- 795
		local left = ctrl and Keyboard:isKeyDown("Left") -- 798
		local right = ctrl and Keyboard:isKeyDown("Right") -- 799
		local currentIndex = nil -- 800
		for i, entry in ipairs(allEntries) do -- 801
			if currentEntry == entry then -- 802
				currentIndex = i -- 803
			end -- 802
		end -- 803
		if left then -- 804
			allClear() -- 805
			if currentIndex == nil then -- 806
				currentIndex = #allEntries + 1 -- 806
			end -- 806
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 807
		end -- 804
		if right then -- 811
			allClear() -- 812
			if currentIndex == nil then -- 813
				currentIndex = 0 -- 813
			end -- 813
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 814
		end -- 811
	end -- 817
	if not showEntry then -- 818
		return -- 818
	end -- 818
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 820
		reloadDevEntry() -- 824
	end -- 820
	if initFooter then -- 825
		initFooter = false -- 826
	end -- 825
	local width, height -- 828
	do -- 828
		local _obj_0 = App.visualSize -- 828
		width, height = _obj_0.width, _obj_0.height -- 828
	end -- 828
	if isInEntry or showFooter then -- 829
		SetNextWindowSize(Vec2(width, 50)) -- 830
		SetNextWindowPos(Vec2(0, height - 50)) -- 831
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 832
			return PushStyleVar("WindowRounding", 0, function() -- 833
				return Begin("Footer", windowFlags, function() -- 834
					Separator() -- 835
					if iconTex then -- 836
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 837
							showStats = not showStats -- 838
							config.showStats = showStats -- 839
						end -- 837
						SameLine() -- 840
						if Button(">_", Vec2(30, 30)) then -- 841
							showConsole = not showConsole -- 842
							config.showConsole = showConsole -- 843
						end -- 841
					end -- 836
					if isInEntry and config.updateNotification then -- 844
						SameLine() -- 845
						if ImGui.Button(zh and "更新可用" or "Update") then -- 846
							allClear() -- 847
							config.updateNotification = false -- 848
							enterDemoEntry({ -- 850
								"SelfUpdater", -- 850
								Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 851
							}) -- 849
						end -- 846
					end -- 844
					if not isInEntry then -- 853
						SameLine() -- 854
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 855
						local currentIndex = nil -- 856
						for i, entry in ipairs(allEntries) do -- 857
							if currentEntry == entry then -- 858
								currentIndex = i -- 859
							end -- 858
						end -- 859
						if currentIndex then -- 860
							if currentIndex > 1 then -- 861
								SameLine() -- 862
								if Button("<<", Vec2(30, 30)) then -- 863
									allClear() -- 864
									enterDemoEntry(allEntries[currentIndex - 1]) -- 865
								end -- 863
							end -- 861
							if currentIndex < #allEntries then -- 866
								SameLine() -- 867
								if Button(">>", Vec2(30, 30)) then -- 868
									allClear() -- 869
									enterDemoEntry(allEntries[currentIndex + 1]) -- 870
								end -- 868
							end -- 866
						end -- 860
						SameLine() -- 871
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 872
							reloadCurrentEntry() -- 873
						end -- 872
						if back then -- 874
							allClear() -- 875
							isInEntry = true -- 876
							currentEntry = nil -- 877
						end -- 874
					end -- 853
				end) -- 834
			end) -- 833
		end) -- 832
	end -- 829
	local showWebIDE = isInEntry -- 879
	if config.updateNotification then -- 880
		if width < 460 then -- 881
			showWebIDE = false -- 882
		end -- 881
	else -- 884
		if width < 360 then -- 884
			showWebIDE = false -- 885
		end -- 884
	end -- 880
	if showWebIDE then -- 886
		SetNextWindowBgAlpha(0.0) -- 887
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 888
		Begin("Web IDE", displayWindowFlags, function() -- 889
			do -- 890
				local url -- 890
				if webStatus ~= nil then -- 890
					url = webStatus.url -- 890
				end -- 890
				if url then -- 890
					if isDesktop and not config.fullScreen then -- 891
						if urlClicked then -- 892
							BeginDisabled(function() -- 893
								return Button(url) -- 893
							end) -- 893
						elseif Button(url) then -- 894
							urlClicked = once(function() -- 895
								return sleep(5) -- 895
							end) -- 895
							App:openURL("http://localhost:8866") -- 896
						end -- 892
					else -- 898
						TextColored(descColor, url) -- 898
					end -- 891
				else -- 900
					TextColored(descColor, zh and '不可用' or 'not available') -- 900
				end -- 890
			end -- 890
			SameLine() -- 901
			TextDisabled('(?)') -- 902
			if IsItemHovered() then -- 903
				return BeginTooltip(function() -- 904
					return PushTextWrapPos(280, function() -- 905
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 906
					end) -- 906
				end) -- 906
			end -- 903
		end) -- 889
	end -- 886
	if not isInEntry then -- 908
		SetNextWindowSize(Vec2(50, 50)) -- 909
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 910
		PushStyleColor("WindowBg", transparant, function() -- 911
			return Begin("Show", displayWindowFlags, function() -- 911
				if width >= 370 then -- 912
					local changed -- 913
					changed, showFooter = Checkbox("##dev", showFooter) -- 913
					if changed then -- 913
						config.showFooter = showFooter -- 914
					end -- 913
				end -- 912
			end) -- 914
		end) -- 911
	end -- 908
	if isInEntry or showFooter then -- 916
		if showStats then -- 917
			PushStyleVar("WindowRounding", 0, function() -- 918
				SetNextWindowPos(Vec2(0, 0), "Always") -- 919
				SetNextWindowSize(Vec2(0, height - 50)) -- 920
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 921
				config.showStats = showStats -- 922
			end) -- 918
		end -- 917
		if showConsole then -- 923
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 924
			return PushStyleVar("WindowRounding", 6, function() -- 925
				return ShowConsole() -- 926
			end) -- 925
		end -- 923
	end -- 916
end) -- 772
local MaxWidth <const> = 960 -- 928
local toolOpen = false -- 930
local filterText = nil -- 931
local anyEntryMatched = false -- 932
local match -- 933
match = function(name) -- 933
	local res = not filterText or name:lower():match(filterText) -- 934
	if res then -- 935
		anyEntryMatched = true -- 935
	end -- 935
	return res -- 936
end -- 933
local sep -- 938
sep = function() -- 938
	return SeparatorText("") -- 938
end -- 938
local thinSep -- 939
thinSep = function() -- 939
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 939
end -- 939
entryWindow = threadLoop(function() -- 941
	if App.fpsLimited ~= config.fpsLimited then -- 942
		config.fpsLimited = App.fpsLimited -- 943
	end -- 942
	if App.targetFPS ~= config.targetFPS then -- 944
		config.targetFPS = App.targetFPS -- 945
	end -- 944
	if View.vsync ~= config.vsync then -- 946
		config.vsync = View.vsync -- 947
	end -- 946
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 948
		config.fixedFPS = Director.scheduler.fixedFPS -- 949
	end -- 948
	if Director.profilerSending ~= config.webProfiler then -- 950
		config.webProfiler = Director.profilerSending -- 951
	end -- 950
	if urlClicked then -- 952
		local _, result = coroutine.resume(urlClicked) -- 953
		if result then -- 954
			coroutine.close(urlClicked) -- 955
			urlClicked = nil -- 956
		end -- 954
	end -- 952
	if not showEntry then -- 957
		return -- 957
	end -- 957
	if not isInEntry then -- 958
		return -- 958
	end -- 958
	local zh = useChinese -- 959
	if HttpServer.wsConnectionCount > 0 then -- 960
		local themeColor = App.themeColor -- 961
		local width, height -- 962
		do -- 962
			local _obj_0 = App.visualSize -- 962
			width, height = _obj_0.width, _obj_0.height -- 962
		end -- 962
		SetNextWindowBgAlpha(0.5) -- 963
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 964
		Begin("Web IDE Connected", displayWindowFlags, function() -- 965
			Separator() -- 966
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 967
			if iconTex then -- 968
				Image(icon, Vec2(24, 24)) -- 969
				SameLine() -- 970
			end -- 968
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 971
			TextColored(descColor, slogon) -- 972
			return Separator() -- 973
		end) -- 965
		return -- 974
	end -- 960
	local themeColor = App.themeColor -- 976
	local fullWidth, height -- 977
	do -- 977
		local _obj_0 = App.visualSize -- 977
		fullWidth, height = _obj_0.width, _obj_0.height -- 977
	end -- 977
	local width = math.min(MaxWidth, fullWidth) -- 978
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 979
	local maxColumns = math.max(math.floor(width / 200), 1) -- 980
	SetNextWindowPos(Vec2.zero) -- 981
	SetNextWindowBgAlpha(0) -- 982
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 983
	do -- 984
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 985
			return Begin("Dora Dev", windowFlags, function() -- 986
				Dummy(Vec2(fullWidth - 20, 0)) -- 987
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 988
				if fullWidth >= 400 then -- 989
					SameLine() -- 990
					Dummy(Vec2(fullWidth - 400, 0)) -- 991
					SameLine() -- 992
					SetNextItemWidth(zh and -95 or -140) -- 993
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 994
						"AutoSelectAll" -- 994
					}) then -- 994
						config.filter = filterBuf.text -- 995
					end -- 994
					SameLine() -- 996
					if Button(zh and '下载' or 'Download') then -- 997
						allClear() -- 998
						enterDemoEntry({ -- 1000
							"ResourceDownloader", -- 1000
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1001
						}) -- 999
					end -- 997
				end -- 989
				Separator() -- 1003
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1004
			end) -- 986
		end) -- 985
	end -- 1004
	anyEntryMatched = false -- 1006
	SetNextWindowPos(Vec2(0, 50)) -- 1007
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1008
	do -- 1009
		return PushStyleColor("WindowBg", transparant, function() -- 1010
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1011
				return PushStyleVar("Alpha", 1, function() -- 1012
					return Begin("Content", windowFlags, function() -- 1013
						local DemoViewWidth <const> = 320 -- 1014
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1015
						if filterText then -- 1016
							filterText = filterText:lower() -- 1016
						end -- 1016
						if #gamesInDev > 0 then -- 1017
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1018
							Columns(columns, false) -- 1019
							local realViewWidth = GetColumnWidth() - 50 -- 1020
							for _index_0 = 1, #gamesInDev do -- 1021
								local game = gamesInDev[_index_0] -- 1021
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1022
								if match(gameName) then -- 1023
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1024
									SameLine() -- 1025
									TextWrapped(gameName) -- 1026
									if columns > 1 then -- 1027
										if bannerFile then -- 1028
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1029
											local displayWidth <const> = realViewWidth -- 1030
											texHeight = displayWidth * texHeight / texWidth -- 1031
											texWidth = displayWidth -- 1032
											Dummy(Vec2.zero) -- 1033
											SameLine() -- 1034
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1035
										end -- 1028
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1036
											enterDemoEntry(game) -- 1037
										end -- 1036
									else -- 1039
										if bannerFile then -- 1039
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1040
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1041
											local sizing = 0.8 -- 1042
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1043
											texWidth = displayWidth * sizing -- 1044
											if texWidth > 500 then -- 1045
												sizing = 0.6 -- 1046
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1047
												texWidth = displayWidth * sizing -- 1048
											end -- 1045
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1049
											Dummy(Vec2(padding, 0)) -- 1050
											SameLine() -- 1051
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1052
										end -- 1039
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1053
											enterDemoEntry(game) -- 1054
										end -- 1053
									end -- 1027
									if #tests == 0 and #examples == 0 then -- 1055
										thinSep() -- 1056
									end -- 1055
									NextColumn() -- 1057
								end -- 1023
								local showSep = false -- 1058
								if #examples > 0 then -- 1059
									local showExample = false -- 1060
									do -- 1061
										local _accum_0 -- 1061
										for _index_1 = 1, #examples do -- 1061
											local _des_0 = examples[_index_1] -- 1061
											local name = _des_0[1] -- 1061
											if match(name) then -- 1062
												_accum_0 = true -- 1062
												break -- 1062
											end -- 1062
										end -- 1062
										showExample = _accum_0 -- 1061
									end -- 1062
									if showExample then -- 1063
										showSep = true -- 1064
										Columns(1, false) -- 1065
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1066
										SameLine() -- 1067
										local opened -- 1068
										if (filterText ~= nil) then -- 1068
											opened = showExample -- 1068
										else -- 1068
											opened = false -- 1068
										end -- 1068
										if game.exampleOpen == nil then -- 1069
											game.exampleOpen = opened -- 1069
										end -- 1069
										SetNextItemOpen(game.exampleOpen) -- 1070
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1071
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1072
												Columns(maxColumns, false) -- 1073
												for _index_1 = 1, #examples do -- 1074
													local example = examples[_index_1] -- 1074
													if not match(example[1]) then -- 1075
														goto _continue_0 -- 1075
													end -- 1075
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1076
														if Button(example[1], Vec2(-1, 40)) then -- 1077
															enterDemoEntry(example) -- 1078
														end -- 1077
														return NextColumn() -- 1079
													end) -- 1076
													opened = true -- 1080
													::_continue_0:: -- 1075
												end -- 1080
											end) -- 1072
										end) -- 1071
										game.exampleOpen = opened -- 1081
									end -- 1063
								end -- 1059
								if #tests > 0 then -- 1082
									local showTest = false -- 1083
									do -- 1084
										local _accum_0 -- 1084
										for _index_1 = 1, #tests do -- 1084
											local _des_0 = tests[_index_1] -- 1084
											local name = _des_0[1] -- 1084
											if match(name) then -- 1085
												_accum_0 = true -- 1085
												break -- 1085
											end -- 1085
										end -- 1085
										showTest = _accum_0 -- 1084
									end -- 1085
									if showTest then -- 1086
										showSep = true -- 1087
										Columns(1, false) -- 1088
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1089
										SameLine() -- 1090
										local opened -- 1091
										if (filterText ~= nil) then -- 1091
											opened = showTest -- 1091
										else -- 1091
											opened = false -- 1091
										end -- 1091
										if game.testOpen == nil then -- 1092
											game.testOpen = opened -- 1092
										end -- 1092
										SetNextItemOpen(game.testOpen) -- 1093
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1094
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1095
												Columns(maxColumns, false) -- 1096
												for _index_1 = 1, #tests do -- 1097
													local test = tests[_index_1] -- 1097
													if not match(test[1]) then -- 1098
														goto _continue_0 -- 1098
													end -- 1098
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1099
														if Button(test[1], Vec2(-1, 40)) then -- 1100
															enterDemoEntry(test) -- 1101
														end -- 1100
														return NextColumn() -- 1102
													end) -- 1099
													opened = true -- 1103
													::_continue_0:: -- 1098
												end -- 1103
											end) -- 1095
										end) -- 1094
										game.testOpen = opened -- 1104
									end -- 1086
								end -- 1082
								if showSep then -- 1105
									Columns(1, false) -- 1106
									thinSep() -- 1107
									Columns(columns, false) -- 1108
								end -- 1105
							end -- 1108
						end -- 1017
						if #doraTools > 0 then -- 1109
							local showTool = false -- 1110
							do -- 1111
								local _accum_0 -- 1111
								for _index_0 = 1, #doraTools do -- 1111
									local _des_0 = doraTools[_index_0] -- 1111
									local name = _des_0[1] -- 1111
									if match(name) then -- 1112
										_accum_0 = true -- 1112
										break -- 1112
									end -- 1112
								end -- 1112
								showTool = _accum_0 -- 1111
							end -- 1112
							if not showTool then -- 1113
								goto endEntry -- 1113
							end -- 1113
							Columns(1, false) -- 1114
							TextColored(themeColor, "Dora SSR:") -- 1115
							SameLine() -- 1116
							Text(zh and "开发支持" or "Development Support") -- 1117
							Separator() -- 1118
							if #doraTools > 0 then -- 1119
								local opened -- 1120
								if (filterText ~= nil) then -- 1120
									opened = showTool -- 1120
								else -- 1120
									opened = false -- 1120
								end -- 1120
								SetNextItemOpen(toolOpen) -- 1121
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1122
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1123
										Columns(maxColumns, false) -- 1124
										for _index_0 = 1, #doraTools do -- 1125
											local example = doraTools[_index_0] -- 1125
											if not match(example[1]) then -- 1126
												goto _continue_0 -- 1126
											end -- 1126
											if Button(example[1], Vec2(-1, 40)) then -- 1127
												enterDemoEntry(example) -- 1128
											end -- 1127
											NextColumn() -- 1129
											::_continue_0:: -- 1126
										end -- 1129
										Columns(1, false) -- 1130
										opened = true -- 1131
									end) -- 1123
								end) -- 1122
								toolOpen = opened -- 1132
							end -- 1119
						end -- 1109
						::endEntry:: -- 1133
						if not anyEntryMatched then -- 1134
							SetNextWindowBgAlpha(0) -- 1135
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1136
							Begin("Entries Not Found", displayWindowFlags, function() -- 1137
								Separator() -- 1138
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1139
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1140
								return Separator() -- 1141
							end) -- 1137
						end -- 1134
						Columns(1, false) -- 1142
						Dummy(Vec2(100, 80)) -- 1143
						return ScrollWhenDraggingOnVoid() -- 1144
					end) -- 1013
				end) -- 1012
			end) -- 1011
		end) -- 1010
	end -- 1144
end) -- 941
webStatus = require("Script.Dev.WebServer") -- 1146
return _module_0 -- 1146
