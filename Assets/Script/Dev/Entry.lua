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
	showEntry = true -- 108
end) -- 106
isDesktop = false -- 110
if (function() -- 111
	local _val_0 = App.platform -- 111
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 111
end)() then -- 111
	isDesktop = true -- 112
	if config.fullScreen then -- 113
		App.fullScreen = true -- 114
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 115
		local size = Size(config.winWidth, config.winHeight) -- 116
		if App.winSize ~= size then -- 117
			App.winSize = size -- 118
		end -- 117
		local winX, winY -- 119
		do -- 119
			local _obj_0 = App.winPosition -- 119
			winX, winY = _obj_0.x, _obj_0.y -- 119
		end -- 119
		if (config.winX ~= nil) then -- 120
			winX = config.winX -- 121
		else -- 123
			config.winX = -1 -- 123
		end -- 120
		if (config.winY ~= nil) then -- 124
			winY = config.winY -- 125
		else -- 127
			config.winY = -1 -- 127
		end -- 124
		App.winPosition = Vec2(winX, winY) -- 128
	end -- 113
	if (config.alwaysOnTop ~= nil) then -- 129
		App.alwaysOnTop = config.alwaysOnTop -- 130
	else -- 132
		config.alwaysOnTop = true -- 132
	end -- 129
end -- 111
if (config.themeColor ~= nil) then -- 134
	App.themeColor = Color(config.themeColor) -- 135
else -- 137
	config.themeColor = App.themeColor:toARGB() -- 137
end -- 134
if not (config.locale ~= nil) then -- 139
	config.locale = App.locale -- 140
end -- 139
local showStats = false -- 142
if (config.showStats ~= nil) then -- 143
	showStats = config.showStats -- 144
else -- 146
	config.showStats = showStats -- 146
end -- 143
local showConsole = false -- 148
if (config.showConsole ~= nil) then -- 149
	showConsole = config.showConsole -- 150
else -- 152
	config.showConsole = showConsole -- 152
end -- 149
local showFooter = true -- 154
if (config.showFooter ~= nil) then -- 155
	showFooter = config.showFooter -- 156
else -- 158
	config.showFooter = showFooter -- 158
end -- 155
local filterBuf = Buffer(20) -- 160
if (config.filter ~= nil) then -- 161
	filterBuf.text = config.filter -- 162
else -- 164
	config.filter = "" -- 164
end -- 161
local engineDev = false -- 166
if (config.engineDev ~= nil) then -- 167
	engineDev = config.engineDev -- 168
else -- 170
	config.engineDev = engineDev -- 170
end -- 167
if (config.webProfiler ~= nil) then -- 172
	Director.profilerSending = config.webProfiler -- 173
else -- 175
	config.webProfiler = true -- 175
	Director.profilerSending = true -- 176
end -- 172
if not (config.drawerWidth ~= nil) then -- 178
	config.drawerWidth = 200 -- 179
end -- 178
_module_0.getConfig = function() -- 181
	return config -- 181
end -- 181
_module_0.getEngineDev = function() -- 182
	if not App.debugging then -- 183
		return false -- 183
	end -- 183
	return config.engineDev -- 184
end -- 182
local _anon_func_0 = function(App) -- 189
	local _val_0 = App.platform -- 189
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 189
end -- 189
_module_0.connectWebIDE = function() -- 186
	if not config.webIDEConnected then -- 187
		config.webIDEConnected = true -- 188
		if _anon_func_0(App) then -- 189
			local ratio = App.winSize.width / App.visualSize.width -- 190
			App.winSize = Size(640 * ratio, 480 * ratio) -- 191
		end -- 189
	end -- 187
end -- 186
local updateCheck -- 193
updateCheck = function() -- 193
	return thread(function() -- 193
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 194
		if res then -- 194
			local data = json.load(res) -- 195
			if data then -- 195
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 196
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 197
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 198
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 199
				if na < a then -- 200
					goto not_new_version -- 201
				end -- 200
				if na == a then -- 202
					if nb < b then -- 203
						goto not_new_version -- 204
					end -- 203
					if nb == b then -- 205
						if nc < c then -- 206
							goto not_new_version -- 207
						end -- 206
						if nc == c then -- 208
							goto not_new_version -- 209
						end -- 208
					end -- 205
				end -- 202
				config.updateNotification = true -- 210
				::not_new_version:: -- 211
				config.lastUpdateCheck = os.time() -- 212
			end -- 195
		end -- 194
	end) -- 212
end -- 193
if (config.lastUpdateCheck ~= nil) then -- 214
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 215
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 216
		updateCheck() -- 217
	end -- 216
else -- 219
	updateCheck() -- 219
end -- 214
local Set, Struct, LintYueGlobals, GSplit -- 221
do -- 221
	local _obj_0 = require("Utils") -- 221
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 221
end -- 221
local yueext = yue.options.extension -- 222
SetDefaultFont("Font/sarasa-mono-sc-regular.ttf", 20) -- 224
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
	thread(function() -- 521
		sleep() -- 522
		return Cache:removeUnused() -- 523
	end) -- 521
	setupEventHandlers() -- 524
	Content.searchPaths = searchPaths -- 525
	App.idled = true -- 526
	return Wasm:clear() -- 527
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
local _anon_func_1 = function(App, _with_0) -- 571
	local _val_0 = App.platform -- 571
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 571
end -- 571
setupEventHandlers = function() -- 558
	local _with_0 = Director.postNode -- 559
	_with_0:onAppEvent(function(eventType) -- 560
		if eventType == "Quit" then -- 560
			allClear() -- 561
			return clearTempFiles() -- 562
		end -- 560
	end) -- 560
	_with_0:onAppChange(function(settingName) -- 563
		if "Theme" == settingName then -- 564
			config.themeColor = App.themeColor:toARGB() -- 565
		elseif "Locale" == settingName then -- 566
			config.locale = App.locale -- 567
			updateLocale() -- 568
			return teal.clear(true) -- 569
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 570
			if _anon_func_1(App, _with_0) then -- 571
				if "FullScreen" == settingName then -- 573
					config.fullScreen = App.fullScreen -- 573
				elseif "Position" == settingName then -- 574
					local _obj_0 = App.winPosition -- 574
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 574
				elseif "Size" == settingName then -- 575
					local width, height -- 576
					do -- 576
						local _obj_0 = App.winSize -- 576
						width, height = _obj_0.width, _obj_0.height -- 576
					end -- 576
					config.winWidth = width -- 577
					config.winHeight = height -- 578
				end -- 578
			end -- 571
		end -- 578
	end) -- 563
	_with_0:onAppWS(function(eventType) -- 579
		if eventType == "Close" then -- 579
			if HttpServer.wsConnectionCount == 0 then -- 580
				return updateEntries() -- 581
			end -- 580
		end -- 579
	end) -- 579
	_with_0:slot("UpdateEntries", function() -- 582
		return updateEntries() -- 582
	end) -- 582
	return _with_0 -- 559
end -- 558
setupEventHandlers() -- 584
clearTempFiles() -- 585
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
_module_0["stop"] = stop -- 592
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 609
	if workDir == nil then -- 602
		workDir = Path:getPath(file) -- 602
	end -- 602
	Content:insertSearchPath(1, workDir) -- 603
	local scriptPath = Path(workDir, "Script") -- 604
	if Content:exist(scriptPath) then -- 605
		Content:insertSearchPath(1, scriptPath) -- 606
	end -- 605
	local result = require(file) -- 607
	if "function" == type(result) then -- 608
		result() -- 608
	end -- 608
	return nil -- 609
end -- 602
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 641
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 638
	label.alignment = "Left" -- 639
	label.textWidth = width - fontSize -- 640
	label.text = err -- 641
	return label -- 638
end -- 638
local enterEntryAsync -- 594
enterEntryAsync = function(entry) -- 594
	isInEntry = false -- 595
	App.idled = false -- 596
	emit(Profiler.EventName, "ClearLoader") -- 597
	currentEntry = entry -- 598
	local file, workDir = entry[2], entry.workDir -- 599
	sleep() -- 600
	return xpcall(_anon_func_2, function(msg) -- 642
		local err = debug.traceback(msg) -- 611
		Log("Error", err) -- 612
		allClear() -- 613
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 614
		local viewWidth, viewHeight -- 615
		do -- 615
			local _obj_0 = View.size -- 615
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 615
		end -- 615
		local width, height = viewWidth - 20, viewHeight - 20 -- 616
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 617
		Director.ui:addChild((function() -- 618
			local root = AlignNode() -- 618
			do -- 619
				local _obj_0 = App.bufferSize -- 619
				width, height = _obj_0.width, _obj_0.height -- 619
			end -- 619
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 620
			root:onAppChange(function(settingName) -- 621
				if settingName == "Size" then -- 621
					do -- 622
						local _obj_0 = App.bufferSize -- 622
						width, height = _obj_0.width, _obj_0.height -- 622
					end -- 622
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 623
				end -- 621
			end) -- 621
			root:addChild((function() -- 624
				local _with_0 = ScrollArea({ -- 625
					width = width, -- 625
					height = height, -- 626
					paddingX = 0, -- 627
					paddingY = 50, -- 628
					viewWidth = height, -- 629
					viewHeight = height -- 630
				}) -- 624
				root:onAlignLayout(function(w, h) -- 632
					_with_0.position = Vec2(w / 2, h / 2) -- 633
					w = w - 20 -- 634
					h = h - 20 -- 635
					_with_0.view.children.first.textWidth = w - fontSize -- 636
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 637
				end) -- 632
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 638
				return _with_0 -- 624
			end)()) -- 624
			return root -- 618
		end)()) -- 618
		return err -- 642
	end, Content, Path, file, require, type, workDir) -- 642
end -- 594
_module_0["enterEntryAsync"] = enterEntryAsync -- 642
local enterDemoEntry -- 644
enterDemoEntry = function(entry) -- 644
	return thread(function() -- 644
		return enterEntryAsync(entry) -- 644
	end) -- 644
end -- 644
local reloadCurrentEntry -- 646
reloadCurrentEntry = function() -- 646
	if currentEntry then -- 647
		allClear() -- 648
		return enterDemoEntry(currentEntry) -- 649
	end -- 647
end -- 646
Director.clearColor = Color(0xff1a1a1a) -- 651
local isOSSLicenseExist = Content:exist("LICENSES") -- 653
local ossLicenses = nil -- 654
local ossLicenseOpen = false -- 655
local extraOperations -- 657
extraOperations = function() -- 657
	local zh = useChinese -- 658
	if isDesktop then -- 659
		local themeColor = App.themeColor -- 660
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 661
		do -- 662
			local changed -- 662
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 662
			if changed then -- 662
				App.alwaysOnTop = alwaysOnTop -- 663
				config.alwaysOnTop = alwaysOnTop -- 664
			end -- 662
		end -- 662
		SeparatorText(zh and "工作目录" or "Workspace") -- 665
		PushTextWrapPos(400, function() -- 666
			return TextColored(themeColor, writablePath) -- 667
		end) -- 666
		if Button(zh and "改变目录" or "Set Folder") then -- 668
			App:openFileDialog(true, function(path) -- 669
				if path ~= "" then -- 670
					return setWorkspace(path) -- 670
				end -- 670
			end) -- 669
		end -- 668
		SameLine() -- 671
		if Button(zh and "使用默认" or "Use Default") then -- 672
			setWorkspace(Content.appPath) -- 673
		end -- 672
		Separator() -- 674
	end -- 659
	if isOSSLicenseExist then -- 675
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 676
			if not ossLicenses then -- 677
				ossLicenses = { } -- 678
				local licenseText = Content:load("LICENSES") -- 679
				ossLicenseOpen = (licenseText ~= nil) -- 680
				if ossLicenseOpen then -- 680
					licenseText = licenseText:gsub("\r\n", "\n") -- 681
					for license in GSplit(licenseText, "\n--------\n", true) do -- 682
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 683
						if name then -- 683
							ossLicenses[#ossLicenses + 1] = { -- 684
								name, -- 684
								text -- 684
							} -- 684
						end -- 683
					end -- 684
				end -- 680
			else -- 686
				ossLicenseOpen = true -- 686
			end -- 677
		end -- 676
		if ossLicenseOpen then -- 687
			local width, height, themeColor -- 688
			do -- 688
				local _obj_0 = App -- 688
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 688
			end -- 688
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 689
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 690
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 691
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 694
					"NoSavedSettings" -- 694
				}, function() -- 695
					for _index_0 = 1, #ossLicenses do -- 695
						local _des_0 = ossLicenses[_index_0] -- 695
						local firstLine, text = _des_0[1], _des_0[2] -- 695
						local name, license = firstLine:match("(.+): (.+)") -- 696
						TextColored(themeColor, name) -- 697
						SameLine() -- 698
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 699
							return TextWrapped(text) -- 699
						end) -- 699
					end -- 699
				end) -- 691
			end) -- 691
		end -- 687
	end -- 675
	if not App.debugging then -- 701
		return -- 701
	end -- 701
	return TreeNode(zh and "开发操作" or "Development", function() -- 702
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 703
			OpenPopup("build") -- 703
		end -- 703
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 704
			return BeginPopup("build", function() -- 704
				if Selectable(zh and "编译" or "Compile") then -- 705
					doCompile(false) -- 705
				end -- 705
				Separator() -- 706
				if Selectable(zh and "压缩" or "Minify") then -- 707
					doCompile(true) -- 707
				end -- 707
				Separator() -- 708
				if Selectable(zh and "清理" or "Clean") then -- 709
					return doClean() -- 709
				end -- 709
			end) -- 709
		end) -- 704
		if isInEntry then -- 710
			if waitForWebStart then -- 711
				BeginDisabled(function() -- 712
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 712
				end) -- 712
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 713
				reloadDevEntry() -- 714
			end -- 711
		end -- 710
		do -- 715
			local changed -- 715
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 715
			if changed then -- 715
				View.scale = scaleContent and screenScale or 1 -- 716
			end -- 715
		end -- 715
		do -- 717
			local changed -- 717
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 717
			if changed then -- 717
				config.engineDev = engineDev -- 718
			end -- 717
		end -- 717
		if testingThread then -- 719
			return BeginDisabled(function() -- 720
				return Button(zh and "开始自动测试" or "Test automatically") -- 720
			end) -- 720
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 721
			testingThread = thread(function() -- 722
				local _ <close> = setmetatable({ }, { -- 723
					__close = function() -- 723
						allClear() -- 724
						testingThread = nil -- 725
						isInEntry = true -- 726
						currentEntry = nil -- 727
						return print("Testing done!") -- 728
					end -- 723
				}) -- 723
				for _, entry in ipairs(allEntries) do -- 729
					allClear() -- 730
					print("Start " .. tostring(entry[1])) -- 731
					enterDemoEntry(entry) -- 732
					sleep(2) -- 733
					print("Stop " .. tostring(entry[1])) -- 734
				end -- 734
			end) -- 722
		end -- 719
	end) -- 702
end -- 657
local transparant = Color(0x0) -- 736
local windowFlags = { -- 737
	"NoTitleBar", -- 737
	"NoResize", -- 737
	"NoMove", -- 737
	"NoCollapse", -- 737
	"NoSavedSettings", -- 737
	"NoBringToFrontOnFocus" -- 737
} -- 737
local initFooter = true -- 745
local _anon_func_4 = function(allEntries, currentIndex) -- 781
	if currentIndex > 1 then -- 781
		return allEntries[currentIndex - 1] -- 782
	else -- 784
		return allEntries[#allEntries] -- 784
	end -- 781
end -- 781
local _anon_func_5 = function(allEntries, currentIndex) -- 788
	if currentIndex < #allEntries then -- 788
		return allEntries[currentIndex + 1] -- 789
	else -- 791
		return allEntries[1] -- 791
	end -- 788
end -- 788
footerWindow = threadLoop(function() -- 746
	local zh = useChinese -- 747
	if HttpServer.wsConnectionCount > 0 then -- 748
		return -- 749
	end -- 748
	if Keyboard:isKeyDown("Escape") then -- 750
		allClear() -- 751
		App:shutdown() -- 752
	end -- 750
	do -- 753
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 754
		if ctrl and Keyboard:isKeyDown("Q") then -- 755
			stop() -- 756
		end -- 755
		if ctrl and Keyboard:isKeyDown("Z") then -- 757
			reloadCurrentEntry() -- 758
		end -- 757
		if ctrl and Keyboard:isKeyDown(",") then -- 759
			if showFooter then -- 760
				showStats = not showStats -- 760
			else -- 760
				showStats = true -- 760
			end -- 760
			showFooter = true -- 761
			config.showFooter = showFooter -- 762
			config.showStats = showStats -- 763
		end -- 759
		if ctrl and Keyboard:isKeyDown(".") then -- 764
			if showFooter then -- 765
				showConsole = not showConsole -- 765
			else -- 765
				showConsole = true -- 765
			end -- 765
			showFooter = true -- 766
			config.showFooter = showFooter -- 767
			config.showConsole = showConsole -- 768
		end -- 764
		if ctrl and Keyboard:isKeyDown("/") then -- 769
			showFooter = not showFooter -- 770
			config.showFooter = showFooter -- 771
		end -- 769
		local left = ctrl and Keyboard:isKeyDown("Left") -- 772
		local right = ctrl and Keyboard:isKeyDown("Right") -- 773
		local currentIndex = nil -- 774
		for i, entry in ipairs(allEntries) do -- 775
			if currentEntry == entry then -- 776
				currentIndex = i -- 777
			end -- 776
		end -- 777
		if left then -- 778
			allClear() -- 779
			if currentIndex == nil then -- 780
				currentIndex = #allEntries + 1 -- 780
			end -- 780
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 781
		end -- 778
		if right then -- 785
			allClear() -- 786
			if currentIndex == nil then -- 787
				currentIndex = 0 -- 787
			end -- 787
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 788
		end -- 785
	end -- 791
	if not showEntry then -- 792
		return -- 792
	end -- 792
	local width, height -- 794
	do -- 794
		local _obj_0 = App.visualSize -- 794
		width, height = _obj_0.width, _obj_0.height -- 794
	end -- 794
	SetNextWindowSize(Vec2(50, 50)) -- 795
	SetNextWindowPos(Vec2(width - 50, height - 50)) -- 796
	PushStyleColor("WindowBg", transparant, function() -- 797
		return Begin("Show", windowFlags, function() -- 797
			if isInEntry or width >= 540 then -- 798
				local changed -- 799
				changed, showFooter = Checkbox("##dev", showFooter) -- 799
				if changed then -- 799
					config.showFooter = showFooter -- 800
				end -- 799
			end -- 798
		end) -- 800
	end) -- 797
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 802
		reloadDevEntry() -- 806
	end -- 802
	if initFooter then -- 807
		initFooter = false -- 808
	else -- 810
		if not showFooter then -- 810
			return -- 810
		end -- 810
	end -- 807
	SetNextWindowSize(Vec2(width, 50)) -- 812
	SetNextWindowPos(Vec2(0, height - 50)) -- 813
	SetNextWindowBgAlpha(0.35) -- 814
	do -- 815
		return PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 816
			return Begin("Footer", windowFlags, function() -- 817
				Dummy(Vec2(width - 20, 0)) -- 818
				do -- 819
					local changed -- 819
					changed, showStats = Checkbox(zh and "状态" or "Stats", showStats) -- 819
					if changed then -- 819
						config.showStats = showStats -- 820
					end -- 819
				end -- 819
				SameLine() -- 821
				do -- 822
					local changed -- 822
					changed, showConsole = Checkbox(zh and "控制台" or "Log", showConsole) -- 822
					if changed then -- 822
						config.showConsole = showConsole -- 823
					end -- 822
				end -- 822
				if config.updateNotification then -- 824
					SameLine() -- 825
					if ImGui.Button(zh and "更新可用" or "Update Available") then -- 826
						allClear() -- 827
						config.updateNotification = false -- 828
						enterDemoEntry({ -- 830
							"SelfUpdater", -- 830
							Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 831
						}) -- 829
					end -- 826
				end -- 824
				if not isInEntry then -- 833
					SameLine() -- 834
					local back = Button(zh and "主页" or "Home", Vec2(70, 30)) -- 835
					local currentIndex = nil -- 836
					for i, entry in ipairs(allEntries) do -- 837
						if currentEntry == entry then -- 838
							currentIndex = i -- 839
						end -- 838
					end -- 839
					if currentIndex then -- 840
						if currentIndex > 1 then -- 841
							SameLine() -- 842
							if Button(zh and "前一个" or "Prev", Vec2(70, 30)) then -- 843
								allClear() -- 844
								enterDemoEntry(allEntries[currentIndex - 1]) -- 845
							end -- 843
						end -- 841
						if currentIndex < #allEntries then -- 846
							SameLine() -- 847
							if Button(zh and "后一个" or "Next", Vec2(70, 30)) then -- 848
								allClear() -- 849
								enterDemoEntry(allEntries[currentIndex + 1]) -- 850
							end -- 848
						end -- 846
					end -- 840
					SameLine() -- 851
					if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 852
						reloadCurrentEntry() -- 853
					end -- 852
					if back then -- 854
						allClear() -- 855
						isInEntry = true -- 856
						currentEntry = nil -- 857
					end -- 854
				end -- 833
				return PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 858
					if showStats then -- 859
						SetNextWindowPos(Vec2(10, 50), "FirstUseEver") -- 860
						showStats = ShowStats(showStats, extraOperations) -- 861
						config.showStats = showStats -- 862
					end -- 859
					if showConsole then -- 863
						SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 864
						showConsole = ShowConsole(showConsole) -- 865
						config.showConsole = showConsole -- 866
					end -- 863
				end) -- 858
			end) -- 817
		end) -- 816
	end -- 866
end) -- 746
local MaxWidth <const> = 960 -- 868
local displayWindowFlags = { -- 870
	"NoDecoration", -- 870
	"NoSavedSettings", -- 870
	"NoFocusOnAppearing", -- 870
	"NoNav", -- 870
	"NoMove", -- 870
	"NoScrollWithMouse", -- 870
	"AlwaysAutoResize", -- 870
	"NoBringToFrontOnFocus" -- 870
} -- 870
local webStatus = nil -- 881
local descColor = Color(0xffa1a1a1) -- 882
local toolOpen = false -- 883
local filterText = nil -- 884
local anyEntryMatched = false -- 885
local urlClicked = nil -- 886
local match -- 887
match = function(name) -- 887
	local res = not filterText or name:lower():match(filterText) -- 888
	if res then -- 889
		anyEntryMatched = true -- 889
	end -- 889
	return res -- 890
end -- 887
local icon = Path("Script", "Dev", "icon_s.png") -- 891
local iconTex = nil -- 892
thread(function() -- 893
	if Cache:loadAsync(icon) then -- 893
		iconTex = Texture2D(icon) -- 893
	end -- 893
end) -- 893
local sep -- 895
sep = function() -- 895
	return SeparatorText("") -- 895
end -- 895
local thinSep -- 896
thinSep = function() -- 896
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 896
end -- 896
entryWindow = threadLoop(function() -- 898
	if App.fpsLimited ~= config.fpsLimited then -- 899
		config.fpsLimited = App.fpsLimited -- 900
	end -- 899
	if App.targetFPS ~= config.targetFPS then -- 901
		config.targetFPS = App.targetFPS -- 902
	end -- 901
	if View.vsync ~= config.vsync then -- 903
		config.vsync = View.vsync -- 904
	end -- 903
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 905
		config.fixedFPS = Director.scheduler.fixedFPS -- 906
	end -- 905
	if Director.profilerSending ~= config.webProfiler then -- 907
		config.webProfiler = Director.profilerSending -- 908
	end -- 907
	if urlClicked then -- 909
		local _, result = coroutine.resume(urlClicked) -- 910
		if result then -- 911
			coroutine.close(urlClicked) -- 912
			urlClicked = nil -- 913
		end -- 911
	end -- 909
	if not showEntry then -- 914
		return -- 914
	end -- 914
	if not isInEntry then -- 915
		return -- 915
	end -- 915
	local zh = useChinese -- 916
	if HttpServer.wsConnectionCount > 0 then -- 917
		local themeColor = App.themeColor -- 918
		local width, height -- 919
		do -- 919
			local _obj_0 = App.visualSize -- 919
			width, height = _obj_0.width, _obj_0.height -- 919
		end -- 919
		SetNextWindowBgAlpha(0.5) -- 920
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 921
		Begin("Web IDE Connected", displayWindowFlags, function() -- 922
			Separator() -- 923
			TextColored(themeColor, tostring(zh and '网页 IDE 已连接 ……' or 'Web IDE connected ...')) -- 924
			if iconTex then -- 925
				Image(icon, Vec2(24, 24)) -- 926
				SameLine() -- 927
			end -- 925
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 928
			TextColored(descColor, slogon) -- 929
			return Separator() -- 930
		end) -- 922
		return -- 931
	end -- 917
	local themeColor = App.themeColor -- 933
	local fullWidth, height -- 934
	do -- 934
		local _obj_0 = App.visualSize -- 934
		fullWidth, height = _obj_0.width, _obj_0.height -- 934
	end -- 934
	SetNextWindowBgAlpha(0.85) -- 936
	SetNextWindowPos(Vec2(fullWidth - 30, height - 130), "Always", Vec2(1, 0)) -- 937
	PushStyleVar("WindowPadding", Vec2(10, 5), function() -- 938
		return Begin("Web IDE", displayWindowFlags, function() -- 939
			Separator() -- 940
			TextColored(themeColor, tostring(zh and '网页' or 'Web') .. " IDE") -- 941
			SameLine() -- 942
			TextDisabled('(?)') -- 943
			if IsItemHovered() then -- 944
				BeginTooltip(function() -- 945
					return PushTextWrapPos(280, function() -- 946
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问下面这个地址来使用网页 IDE' or 'You can use the Web IDE by accessing the following address in a browser on this machine or other devices connected to the local network') -- 947
					end) -- 947
				end) -- 945
			end -- 944
			do -- 948
				local url -- 948
				if webStatus ~= nil then -- 948
					url = webStatus.url -- 948
				end -- 948
				if url then -- 948
					if isDesktop and not config.fullScreen then -- 949
						if urlClicked then -- 950
							BeginDisabled(function() -- 951
								return Button(url) -- 951
							end) -- 951
						elseif Button(url) then -- 952
							urlClicked = once(function() -- 953
								return sleep(5) -- 953
							end) -- 953
							App:openURL("http://localhost:8866") -- 954
						end -- 950
					else -- 956
						TextColored(descColor, url) -- 956
					end -- 949
				else -- 958
					TextColored(descColor, zh and '不可用' or 'not available') -- 958
				end -- 948
			end -- 948
			return Separator() -- 959
		end) -- 959
	end) -- 938
	local width = math.min(MaxWidth, fullWidth) -- 961
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 962
	local maxColumns = math.max(math.floor(width / 200), 1) -- 963
	SetNextWindowPos(Vec2.zero) -- 964
	SetNextWindowBgAlpha(0) -- 965
	do -- 966
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 967
			return Begin("Dora Dev", displayWindowFlags, function() -- 968
				Dummy(Vec2(fullWidth - 20, 0)) -- 969
				if iconTex then -- 970
					Image(icon, Vec2(24, 24)) -- 971
					SameLine() -- 972
				end -- 970
				TextColored(themeColor, "DORA SSR " .. tostring(zh and '开发' or 'DEV')) -- 973
				if fullWidth >= 400 then -- 974
					SameLine() -- 975
					Dummy(Vec2(fullWidth - 400, 0)) -- 976
					SameLine() -- 977
					SetNextItemWidth(zh and -90 or -140) -- 978
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 979
						"AutoSelectAll" -- 979
					}) then -- 979
						config.filter = filterBuf.text -- 980
					end -- 979
					SameLine() -- 981
					if Button(zh and '下载' or 'Download') then -- 982
						allClear() -- 983
						enterDemoEntry({ -- 985
							"ResourceDownloader", -- 985
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 986
						}) -- 984
					end -- 982
				end -- 974
				Separator() -- 988
				return Dummy(Vec2(fullWidth - 20, 0)) -- 989
			end) -- 968
		end) -- 967
	end -- 989
	anyEntryMatched = false -- 991
	SetNextWindowPos(Vec2(0, 50)) -- 992
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 993
	do -- 994
		return PushStyleColor("WindowBg", transparant, function() -- 995
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 996
				return PushStyleVar("Alpha", 1, function() -- 997
					return Begin("Content", windowFlags, function() -- 998
						local DemoViewWidth <const> = 320 -- 999
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1000
						if filterText then -- 1001
							filterText = filterText:lower() -- 1001
						end -- 1001
						if #gamesInDev > 0 then -- 1002
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1003
							Columns(columns, false) -- 1004
							local realViewWidth = GetColumnWidth() - 50 -- 1005
							for _index_0 = 1, #gamesInDev do -- 1006
								local game = gamesInDev[_index_0] -- 1006
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1007
								if match(gameName) then -- 1008
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1009
									SameLine() -- 1010
									TextWrapped(gameName) -- 1011
									if columns > 1 then -- 1012
										if bannerFile then -- 1013
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1014
											local displayWidth <const> = realViewWidth -- 1015
											texHeight = displayWidth * texHeight / texWidth -- 1016
											texWidth = displayWidth -- 1017
											Dummy(Vec2.zero) -- 1018
											SameLine() -- 1019
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1020
										end -- 1013
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1021
											enterDemoEntry(game) -- 1022
										end -- 1021
									else -- 1024
										if bannerFile then -- 1024
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1025
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1026
											local sizing = 0.8 -- 1027
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1028
											texWidth = displayWidth * sizing -- 1029
											if texWidth > 500 then -- 1030
												sizing = 0.6 -- 1031
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1032
												texWidth = displayWidth * sizing -- 1033
											end -- 1030
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1034
											Dummy(Vec2(padding, 0)) -- 1035
											SameLine() -- 1036
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1037
										end -- 1024
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1038
											enterDemoEntry(game) -- 1039
										end -- 1038
									end -- 1012
									if #tests == 0 and #examples == 0 then -- 1040
										thinSep() -- 1041
									end -- 1040
									NextColumn() -- 1042
								end -- 1008
								local showSep = false -- 1043
								if #examples > 0 then -- 1044
									local showExample = false -- 1045
									do -- 1046
										local _accum_0 -- 1046
										for _index_1 = 1, #examples do -- 1046
											local _des_0 = examples[_index_1] -- 1046
											local name = _des_0[1] -- 1046
											if match(name) then -- 1047
												_accum_0 = true -- 1047
												break -- 1047
											end -- 1047
										end -- 1047
										showExample = _accum_0 -- 1046
									end -- 1047
									if showExample then -- 1048
										showSep = true -- 1049
										Columns(1, false) -- 1050
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1051
										SameLine() -- 1052
										local opened -- 1053
										if (filterText ~= nil) then -- 1053
											opened = showExample -- 1053
										else -- 1053
											opened = false -- 1053
										end -- 1053
										if game.exampleOpen == nil then -- 1054
											game.exampleOpen = opened -- 1054
										end -- 1054
										SetNextItemOpen(game.exampleOpen) -- 1055
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1056
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1057
												Columns(maxColumns, false) -- 1058
												for _index_1 = 1, #examples do -- 1059
													local example = examples[_index_1] -- 1059
													if not match(example[1]) then -- 1060
														goto _continue_0 -- 1060
													end -- 1060
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1061
														if Button(example[1], Vec2(-1, 40)) then -- 1062
															enterDemoEntry(example) -- 1063
														end -- 1062
														return NextColumn() -- 1064
													end) -- 1061
													opened = true -- 1065
													::_continue_0:: -- 1060
												end -- 1065
											end) -- 1057
										end) -- 1056
										game.exampleOpen = opened -- 1066
									end -- 1048
								end -- 1044
								if #tests > 0 then -- 1067
									local showTest = false -- 1068
									do -- 1069
										local _accum_0 -- 1069
										for _index_1 = 1, #tests do -- 1069
											local _des_0 = tests[_index_1] -- 1069
											local name = _des_0[1] -- 1069
											if match(name) then -- 1070
												_accum_0 = true -- 1070
												break -- 1070
											end -- 1070
										end -- 1070
										showTest = _accum_0 -- 1069
									end -- 1070
									if showTest then -- 1071
										showSep = true -- 1072
										Columns(1, false) -- 1073
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1074
										SameLine() -- 1075
										local opened -- 1076
										if (filterText ~= nil) then -- 1076
											opened = showTest -- 1076
										else -- 1076
											opened = false -- 1076
										end -- 1076
										if game.testOpen == nil then -- 1077
											game.testOpen = opened -- 1077
										end -- 1077
										SetNextItemOpen(game.testOpen) -- 1078
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1079
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1080
												Columns(maxColumns, false) -- 1081
												for _index_1 = 1, #tests do -- 1082
													local test = tests[_index_1] -- 1082
													if not match(test[1]) then -- 1083
														goto _continue_0 -- 1083
													end -- 1083
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1084
														if Button(test[1], Vec2(-1, 40)) then -- 1085
															enterDemoEntry(test) -- 1086
														end -- 1085
														return NextColumn() -- 1087
													end) -- 1084
													opened = true -- 1088
													::_continue_0:: -- 1083
												end -- 1088
											end) -- 1080
										end) -- 1079
										game.testOpen = opened -- 1089
									end -- 1071
								end -- 1067
								if showSep then -- 1090
									Columns(1, false) -- 1091
									thinSep() -- 1092
									Columns(columns, false) -- 1093
								end -- 1090
							end -- 1093
						end -- 1002
						if #doraTools > 0 then -- 1094
							local showTool = false -- 1095
							do -- 1096
								local _accum_0 -- 1096
								for _index_0 = 1, #doraTools do -- 1096
									local _des_0 = doraTools[_index_0] -- 1096
									local name = _des_0[1] -- 1096
									if match(name) then -- 1097
										_accum_0 = true -- 1097
										break -- 1097
									end -- 1097
								end -- 1097
								showTool = _accum_0 -- 1096
							end -- 1097
							if not showTool then -- 1098
								goto endEntry -- 1098
							end -- 1098
							Columns(1, false) -- 1099
							TextColored(themeColor, "Dora SSR:") -- 1100
							SameLine() -- 1101
							Text(zh and "开发支持" or "Development Support") -- 1102
							Separator() -- 1103
							if #doraTools > 0 then -- 1104
								local opened -- 1105
								if (filterText ~= nil) then -- 1105
									opened = showTool -- 1105
								else -- 1105
									opened = false -- 1105
								end -- 1105
								SetNextItemOpen(toolOpen) -- 1106
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1107
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1108
										Columns(maxColumns, false) -- 1109
										for _index_0 = 1, #doraTools do -- 1110
											local example = doraTools[_index_0] -- 1110
											if not match(example[1]) then -- 1111
												goto _continue_0 -- 1111
											end -- 1111
											if Button(example[1], Vec2(-1, 40)) then -- 1112
												enterDemoEntry(example) -- 1113
											end -- 1112
											NextColumn() -- 1114
											::_continue_0:: -- 1111
										end -- 1114
										Columns(1, false) -- 1115
										opened = true -- 1116
									end) -- 1108
								end) -- 1107
								toolOpen = opened -- 1117
							end -- 1104
						end -- 1094
						::endEntry:: -- 1118
						if not anyEntryMatched then -- 1119
							SetNextWindowBgAlpha(0) -- 1120
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1121
							Begin("Entries Not Found", displayWindowFlags, function() -- 1122
								Separator() -- 1123
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1124
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1125
								return Separator() -- 1126
							end) -- 1122
						end -- 1119
						Columns(1, false) -- 1127
						Dummy(Vec2(100, 80)) -- 1128
						return ScrollWhenDraggingOnVoid() -- 1129
					end) -- 998
				end) -- 997
			end) -- 996
		end) -- 995
	end -- 1129
end) -- 898
webStatus = require("Script.Dev.WebServer") -- 1131
return _module_0 -- 1131
