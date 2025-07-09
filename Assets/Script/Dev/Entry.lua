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
SetDefaultFont("Font/sarasa-mono-sc-regular.ttf", 20) -- 225
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
	thread(function() -- 522
		sleep() -- 523
		return Cache:removeUnused() -- 524
	end) -- 522
	setupEventHandlers() -- 525
	Content.searchPaths = searchPaths -- 526
	App.idled = true -- 527
	return Wasm:clear() -- 528
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
local transparant = Color(0x0) -- 737
local windowFlags = { -- 738
	"NoTitleBar", -- 738
	"NoResize", -- 738
	"NoMove", -- 738
	"NoCollapse", -- 738
	"NoSavedSettings", -- 738
	"NoBringToFrontOnFocus" -- 738
} -- 738
local initFooter = true -- 746
local _anon_func_4 = function(allEntries, currentIndex) -- 782
	if currentIndex > 1 then -- 782
		return allEntries[currentIndex - 1] -- 783
	else -- 785
		return allEntries[#allEntries] -- 785
	end -- 782
end -- 782
local _anon_func_5 = function(allEntries, currentIndex) -- 789
	if currentIndex < #allEntries then -- 789
		return allEntries[currentIndex + 1] -- 790
	else -- 792
		return allEntries[1] -- 792
	end -- 789
end -- 789
footerWindow = threadLoop(function() -- 747
	local zh = useChinese -- 748
	if HttpServer.wsConnectionCount > 0 then -- 749
		return -- 750
	end -- 749
	if Keyboard:isKeyDown("Escape") then -- 751
		allClear() -- 752
		App:shutdown() -- 753
	end -- 751
	do -- 754
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 755
		if ctrl and Keyboard:isKeyDown("Q") then -- 756
			stop() -- 757
		end -- 756
		if ctrl and Keyboard:isKeyDown("Z") then -- 758
			reloadCurrentEntry() -- 759
		end -- 758
		if ctrl and Keyboard:isKeyDown(",") then -- 760
			if showFooter then -- 761
				showStats = not showStats -- 761
			else -- 761
				showStats = true -- 761
			end -- 761
			showFooter = true -- 762
			config.showFooter = showFooter -- 763
			config.showStats = showStats -- 764
		end -- 760
		if ctrl and Keyboard:isKeyDown(".") then -- 765
			if showFooter then -- 766
				showConsole = not showConsole -- 766
			else -- 766
				showConsole = true -- 766
			end -- 766
			showFooter = true -- 767
			config.showFooter = showFooter -- 768
			config.showConsole = showConsole -- 769
		end -- 765
		if ctrl and Keyboard:isKeyDown("/") then -- 770
			showFooter = not showFooter -- 771
			config.showFooter = showFooter -- 772
		end -- 770
		local left = ctrl and Keyboard:isKeyDown("Left") -- 773
		local right = ctrl and Keyboard:isKeyDown("Right") -- 774
		local currentIndex = nil -- 775
		for i, entry in ipairs(allEntries) do -- 776
			if currentEntry == entry then -- 777
				currentIndex = i -- 778
			end -- 777
		end -- 778
		if left then -- 779
			allClear() -- 780
			if currentIndex == nil then -- 781
				currentIndex = #allEntries + 1 -- 781
			end -- 781
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 782
		end -- 779
		if right then -- 786
			allClear() -- 787
			if currentIndex == nil then -- 788
				currentIndex = 0 -- 788
			end -- 788
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 789
		end -- 786
	end -- 792
	if not showEntry then -- 793
		return -- 793
	end -- 793
	local width, height -- 795
	do -- 795
		local _obj_0 = App.visualSize -- 795
		width, height = _obj_0.width, _obj_0.height -- 795
	end -- 795
	SetNextWindowSize(Vec2(50, 50)) -- 796
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 797
	PushStyleColor("WindowBg", transparant, function() -- 798
		return Begin("Show", windowFlags, function() -- 798
			if isInEntry or width >= 540 then -- 799
				local changed -- 800
				changed, showFooter = Checkbox("##dev", showFooter) -- 800
				if changed then -- 800
					config.showFooter = showFooter -- 801
				end -- 800
			end -- 799
		end) -- 801
	end) -- 798
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 803
		reloadDevEntry() -- 807
	end -- 803
	if initFooter then -- 808
		initFooter = false -- 809
	else -- 811
		if not showFooter then -- 811
			return -- 811
		end -- 811
	end -- 808
	SetNextWindowSize(Vec2(width, 50)) -- 813
	SetNextWindowPos(Vec2(0, height - 50)) -- 814
	SetNextWindowBgAlpha(0.35) -- 815
	do -- 816
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 817
			return Begin("Footer", windowFlags, function() -- 818
				Dummy(Vec2(width - 20, 0)) -- 819
				do -- 820
					local changed -- 820
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 820
					if changed then -- 820
						config.showStats = showStats -- 821
					end -- 820
				end -- 820
				SameLine() -- 822
				do -- 823
					local changed -- 823
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 823
					if changed then -- 823
						config.showConsole = showConsole -- 824
					end -- 823
				end -- 823
				if config.updateNotification then -- 825
					SameLine() -- 826
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 827
						allClear() -- 828
						config.updateNotification = false -- 829
						enterDemoEntry({ -- 831
							"SelfUpdater", -- 831
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 832
						}) -- 830
					end -- 827
				end -- 825
				if not isInEntry then -- 834
					SameLine() -- 835
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 836
					local currentIndex = nil -- 837
					for i, entry in ipairs(allEntries) do -- 838
						if currentEntry == entry then -- 839
							currentIndex = i -- 840
						end -- 839
					end -- 840
					if currentIndex then -- 841
						if currentIndex > 1 then -- 842
							SameLine() -- 843
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 844
								allClear() -- 845
								enterDemoEntry(allEntries[currentIndex - 1]) -- 846
							end -- 844
						end -- 842
						if currentIndex < #allEntries then -- 847
							SameLine() -- 848
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 849
								allClear() -- 850
								enterDemoEntry(allEntries[currentIndex + 1]) -- 851
							end -- 849
						end -- 847
					end -- 841
					SameLine() -- 852
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 853
						reloadCurrentEntry() -- 854
					end -- 853
					if back then -- 855
						allClear() -- 856
						isInEntry = true -- 857
						currentEntry = nil -- 858
					end -- 855
				end -- 834
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 859
					if showStats then -- 860
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 861
						showStats = ShowStats(showStats, extraOperations) -- 862
						config.showStats = showStats -- 863
					end -- 860
					if showConsole then -- 864
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 865
						showConsole = ShowConsole(showConsole) -- 866
						config.showConsole = showConsole -- 867
					end -- 864
				end) -- 859
			end) -- 818
		end) -- 817
	end -- 867
end) -- 747
local MaxWidth <const> = 960 -- 869
local displayWindowFlags = { -- 871
	"NoDecoration", -- 871
	"NoSavedSettings", -- 871
	"NoFocusOnAppearing", -- 871
	"NoNav", -- 871
	"NoMove", -- 871
	"NoScrollWithMouse", -- 871
	"AlwaysAutoResize", -- 871
	"NoBringToFrontOnFocus" -- 871
} -- 871
local webStatus = nil -- 882
local descColor = Color(0xffa1a1a1) -- 883
local toolOpen = false -- 884
local filterText = nil -- 885
local anyEntryMatched = false -- 886
local urlClicked = nil -- 887
local match -- 888
match = function(name) -- 888
	local res = not filterText or name:lower():match(filterText) -- 889
	if res then -- 890
		anyEntryMatched = true -- 890
	end -- 890
	return res -- 891
end -- 888
local icon = Path("Script", "Dev", "icon_s.png") -- 892
local iconTex = nil -- 893
thread(function() -- 894
	if Cache:loadAsync(icon) then -- 894
		iconTex = Texture2D(icon) -- 894
	end -- 894
end) -- 894
local sep -- 896
sep = function() -- 896
	return SeparatorText("") -- 896
end -- 896
local thinSep -- 897
thinSep = function() -- 897
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 897
end -- 897
entryWindow = threadLoop(function() -- 899
	if App.fpsLimited ~= config.fpsLimited then -- 900
		config.fpsLimited = App.fpsLimited -- 901
	end -- 900
	if App.targetFPS ~= config.targetFPS then -- 902
		config.targetFPS = App.targetFPS -- 903
	end -- 902
	if View.vsync ~= config.vsync then -- 904
		config.vsync = View.vsync -- 905
	end -- 904
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 906
		config.fixedFPS = Director.scheduler.fixedFPS -- 907
	end -- 906
	if Director.profilerSending ~= config.webProfiler then -- 908
		config.webProfiler = Director.profilerSending -- 909
	end -- 908
	if urlClicked then -- 910
		local _, result = coroutine.resume(urlClicked) -- 911
		if result then -- 912
			coroutine.close(urlClicked) -- 913
			urlClicked = nil -- 914
		end -- 912
	end -- 910
	if not showEntry then -- 915
		return -- 915
	end -- 915
	if not isInEntry then -- 916
		return -- 916
	end -- 916
	local zh = useChinese -- 917
	if HttpServer.wsConnectionCount > 0 then -- 918
		local themeColor = App.themeColor -- 919
		local width, height -- 920
		do -- 920
			local _obj_0 = App.visualSize -- 920
			width, height = _obj_0.width, _obj_0.height -- 920
		end -- 920
		SetNextWindowBgAlpha(0.5) -- 921
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 922
		Begin("Web IDE Connected", displayWindowFlags, function() -- 923
			Separator() -- 924
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 925
			if iconTex then -- 926
				Image(icon, Vec2(24, 24)) -- 927
				SameLine() -- 928
			end -- 926
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 929
			TextColored(descColor, slogon) -- 930
			return Separator() -- 931
		end) -- 923
		return -- 932
	end -- 918
	local themeColor = App.themeColor -- 934
	local fullWidth, height -- 935
	do -- 935
		local _obj_0 = App.visualSize -- 935
		fullWidth, height = _obj_0.width, _obj_0.height -- 935
	end -- 935
	SetNextWindowBgAlpha(0.85) -- 937
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 938
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 939
		return Begin("Web IDE", displayWindowFlags, function() -- 940
			Separator() -- 941
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 942
			SameLine() -- 943
			TextDisabled('(?)') -- 944
			if IsItemHovered() then -- 945
				BeginTooltip(function() -- 946
					return PushTextWrapPos(280, function() -- 947
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 948
					end) -- 948
				end) -- 946
			end -- 945
			do -- 949
				local url -- 949
				if webStatus ~= nil then -- 949
					url = webStatus.url -- 949
				end -- 949
				if url then -- 949
					if isDesktop and not config.fullScreen then -- 950
						if urlClicked then -- 951
							BeginDisabled(function() -- 952
								return Button(url) -- 952
							end) -- 952
						elseif Button(url) then -- 953
							urlClicked = once(function() -- 954
								return sleep(5) -- 954
							end) -- 954
							App:openURL("http://localhost:8866") -- 955
						end -- 951
					else -- 957
						TextColored(descColor, url) -- 957
					end -- 950
				else -- 959
					TextColored(descColor, zh and '不可用' or 'not available') -- 959
				end -- 949
			end -- 949
			return Separator() -- 960
		end) -- 960
	end) -- 939
	local width = math.min(MaxWidth, fullWidth) -- 962
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 963
	local maxColumns = math.max(math.floor(width / 200), 1) -- 964
	SetNextWindowPos(Vec2.zero) -- 965
	SetNextWindowBgAlpha(0) -- 966
	do -- 967
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 968
			return Begin("Dora Dev", displayWindowFlags, function() -- 969
				Dummy(Vec2(fullWidth - 20, 0)) -- 970
				if iconTex then -- 971
					Image(icon, Vec2(24, 24)) -- 972
					SameLine() -- 973
				end -- 971
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 974
				if fullWidth >= 400 then -- 975
					SameLine() -- 976
					Dummy(Vec2(fullWidth - 400, 0)) -- 977
					SameLine() -- 978
					SetNextItemWidth(zh and -90 or -140) -- 979
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 980
						"AutoSelectAll" -- 980
					}) then -- 980
						config.filter = filterBuf.text -- 981
					end -- 980
					SameLine() -- 982
					if Button(zh and '下载' or 'Download') then -- 983
						allClear() -- 984
						enterDemoEntry({ -- 986
							"ResourceDownloader", -- 986
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 987
						}) -- 985
					end -- 983
				end -- 975
				Separator() -- 989
				return Dummy(Vec2(fullWidth - 20, 0)) -- 990
			end) -- 969
		end) -- 968
	end -- 990
	anyEntryMatched = false -- 992
	SetNextWindowPos(Vec2(0, 50)) -- 993
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 994
	do -- 995
		return PushStyleColor("WindowBg", transparant, function() -- 996
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 997
				return PushStyleVar("Alpha", 1, function() -- 998
					return Begin("Content", windowFlags, function() -- 999
						local DemoViewWidth <const> = 320 -- 1000
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1001
						if filterText then -- 1002
							filterText = filterText:lower() -- 1002
						end -- 1002
						if #gamesInDev > 0 then -- 1003
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1004
							Columns(columns, false) -- 1005
							local realViewWidth = GetColumnWidth() - 50 -- 1006
							for _index_0 = 1, #gamesInDev do -- 1007
								local game = gamesInDev[_index_0] -- 1007
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1008
								if match(gameName) then -- 1009
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1010
									SameLine() -- 1011
									TextWrapped(gameName) -- 1012
									if columns > 1 then -- 1013
										if bannerFile then -- 1014
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1015
											local displayWidth <const> = realViewWidth -- 1016
											texHeight = displayWidth * texHeight / texWidth -- 1017
											texWidth = displayWidth -- 1018
											Dummy(Vec2.zero) -- 1019
											SameLine() -- 1020
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1021
										end -- 1014
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1022
											enterDemoEntry(game) -- 1023
										end -- 1022
									else -- 1025
										if bannerFile then -- 1025
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1026
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1027
											local sizing = 0.8 -- 1028
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1029
											texWidth = displayWidth * sizing -- 1030
											if texWidth > 500 then -- 1031
												sizing = 0.6 -- 1032
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1033
												texWidth = displayWidth * sizing -- 1034
											end -- 1031
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1035
											Dummy(Vec2(padding, 0)) -- 1036
											SameLine() -- 1037
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1038
										end -- 1025
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1039
											enterDemoEntry(game) -- 1040
										end -- 1039
									end -- 1013
									if #tests == 0 and #examples == 0 then -- 1041
										thinSep() -- 1042
									end -- 1041
									NextColumn() -- 1043
								end -- 1009
								local showSep = false -- 1044
								if #examples > 0 then -- 1045
									local showExample = false -- 1046
									do -- 1047
										local _accum_0 -- 1047
										for _index_1 = 1, #examples do -- 1047
											local _des_0 = examples[_index_1] -- 1047
											local name = _des_0[1] -- 1047
											if match(name) then -- 1048
												_accum_0 = true -- 1048
												break -- 1048
											end -- 1048
										end -- 1048
										showExample = _accum_0 -- 1047
									end -- 1048
									if showExample then -- 1049
										showSep = true -- 1050
										Columns(1, false) -- 1051
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1052
										SameLine() -- 1053
										local opened -- 1054
										if (filterText ~= nil) then -- 1054
											opened = showExample -- 1054
										else -- 1054
											opened = false -- 1054
										end -- 1054
										if game.exampleOpen == nil then -- 1055
											game.exampleOpen = opened -- 1055
										end -- 1055
										SetNextItemOpen(game.exampleOpen) -- 1056
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1057
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1058
												Columns(maxColumns, false) -- 1059
												for _index_1 = 1, #examples do -- 1060
													local example = examples[_index_1] -- 1060
													if not match(example[1]) then -- 1061
														goto _continue_0 -- 1061
													end -- 1061
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1062
														if Button(example[1], Vec2(-1, 40)) then -- 1063
															enterDemoEntry(example) -- 1064
														end -- 1063
														return NextColumn() -- 1065
													end) -- 1062
													opened = true -- 1066
													::_continue_0:: -- 1061
												end -- 1066
											end) -- 1058
										end) -- 1057
										game.exampleOpen = opened -- 1067
									end -- 1049
								end -- 1045
								if #tests > 0 then -- 1068
									local showTest = false -- 1069
									do -- 1070
										local _accum_0 -- 1070
										for _index_1 = 1, #tests do -- 1070
											local _des_0 = tests[_index_1] -- 1070
											local name = _des_0[1] -- 1070
											if match(name) then -- 1071
												_accum_0 = true -- 1071
												break -- 1071
											end -- 1071
										end -- 1071
										showTest = _accum_0 -- 1070
									end -- 1071
									if showTest then -- 1072
										showSep = true -- 1073
										Columns(1, false) -- 1074
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1075
										SameLine() -- 1076
										local opened -- 1077
										if (filterText ~= nil) then -- 1077
											opened = showTest -- 1077
										else -- 1077
											opened = false -- 1077
										end -- 1077
										if game.testOpen == nil then -- 1078
											game.testOpen = opened -- 1078
										end -- 1078
										SetNextItemOpen(game.testOpen) -- 1079
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1080
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1081
												Columns(maxColumns, false) -- 1082
												for _index_1 = 1, #tests do -- 1083
													local test = tests[_index_1] -- 1083
													if not match(test[1]) then -- 1084
														goto _continue_0 -- 1084
													end -- 1084
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1085
														if Button(test[1], Vec2(-1, 40)) then -- 1086
															enterDemoEntry(test) -- 1087
														end -- 1086
														return NextColumn() -- 1088
													end) -- 1085
													opened = true -- 1089
													::_continue_0:: -- 1084
												end -- 1089
											end) -- 1081
										end) -- 1080
										game.testOpen = opened -- 1090
									end -- 1072
								end -- 1068
								if showSep then -- 1091
									Columns(1, false) -- 1092
									thinSep() -- 1093
									Columns(columns, false) -- 1094
								end -- 1091
							end -- 1094
						end -- 1003
						if #doraTools > 0 then -- 1095
							local showTool = false -- 1096
							do -- 1097
								local _accum_0 -- 1097
								for _index_0 = 1, #doraTools do -- 1097
									local _des_0 = doraTools[_index_0] -- 1097
									local name = _des_0[1] -- 1097
									if match(name) then -- 1098
										_accum_0 = true -- 1098
										break -- 1098
									end -- 1098
								end -- 1098
								showTool = _accum_0 -- 1097
							end -- 1098
							if not showTool then -- 1099
								goto endEntry -- 1099
							end -- 1099
							Columns(1, false) -- 1100
							TextColored(themeColor, "Dora SSR:") -- 1101
							SameLine() -- 1102
							Text(zh and "开发支持" or "Development Support") -- 1103
							Separator() -- 1104
							if #doraTools > 0 then -- 1105
								local opened -- 1106
								if (filterText ~= nil) then -- 1106
									opened = showTool -- 1106
								else -- 1106
									opened = false -- 1106
								end -- 1106
								SetNextItemOpen(toolOpen) -- 1107
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1108
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1109
										Columns(maxColumns, false) -- 1110
										for _index_0 = 1, #doraTools do -- 1111
											local example = doraTools[_index_0] -- 1111
											if not match(example[1]) then -- 1112
												goto _continue_0 -- 1112
											end -- 1112
											if Button(example[1], Vec2(-1, 40)) then -- 1113
												enterDemoEntry(example) -- 1114
											end -- 1113
											NextColumn() -- 1115
											::_continue_0:: -- 1112
										end -- 1115
										Columns(1, false) -- 1116
										opened = true -- 1117
									end) -- 1109
								end) -- 1108
								toolOpen = opened -- 1118
							end -- 1105
						end -- 1095
						::endEntry:: -- 1119
						if not anyEntryMatched then -- 1120
							SetNextWindowBgAlpha(0) -- 1121
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1122
							Begin("Entries Not Found", displayWindowFlags, function() -- 1123
								Separator() -- 1124
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1125
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1126
								return Separator() -- 1127
							end) -- 1123
						end -- 1120
						Columns(1, false) -- 1128
						Dummy(Vec2(100, 80)) -- 1129
						return ScrollWhenDraggingOnVoid() -- 1130
					end) -- 999
				end) -- 998
			end) -- 997
		end) -- 996
	end -- 1130
end) -- 899
webStatus = require("Script.Dev.WebServer") -- 1132
return _module_0 -- 1132
