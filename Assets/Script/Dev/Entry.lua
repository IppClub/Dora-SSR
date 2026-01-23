-- [yue]: Script/Dev/Entry.yue
local _module_0 = { } -- 1
local _ENV = Dora(Dora.ImGui) -- 9
local App <const> = App -- 11
local ShowConsole <const> = ShowConsole -- 11
local _G <const> = _G -- 11
local package <const> = package -- 11
local Dora <const> = Dora -- 11
local Content <const> = Content -- 11
local Path <const> = Path -- 11
local DB <const> = DB -- 11
local type <const> = type -- 11
local View <const> = View -- 11
local Director <const> = Director -- 11
local Size <const> = Size -- 11
local Vec2 <const> = Vec2 -- 11
local Color <const> = Color -- 11
local Buffer <const> = Buffer -- 11
local thread <const> = thread -- 11
local HttpClient <const> = HttpClient -- 11
local json <const> = json -- 11
local tonumber <const> = tonumber -- 11
local os <const> = os -- 11
local yue <const> = yue -- 11
local SetDefaultFont <const> = SetDefaultFont -- 11
local table <const> = table -- 11
local Cache <const> = Cache -- 11
local Texture2D <const> = Texture2D -- 11
local pairs <const> = pairs -- 11
local tostring <const> = tostring -- 11
local string <const> = string -- 11
local print <const> = print -- 11
local xml <const> = xml -- 11
local teal <const> = teal -- 11
local wait <const> = wait -- 11
local Routine <const> = Routine -- 11
local Entity <const> = Entity -- 11
local Platformer <const> = Platformer -- 11
local Audio <const> = Audio -- 11
local ubox <const> = ubox -- 11
local tolua <const> = tolua -- 11
local collectgarbage <const> = collectgarbage -- 11
local Wasm <const> = Wasm -- 11
local sleep <const> = sleep -- 11
local HttpServer <const> = HttpServer -- 11
local once <const> = once -- 11
local emit <const> = emit -- 11
local Profiler <const> = Profiler -- 11
local xpcall <const> = xpcall -- 11
local debug <const> = debug -- 11
local Log <const> = Log -- 11
local math <const> = math -- 11
local AlignNode <const> = AlignNode -- 11
local Label <const> = Label -- 11
local Checkbox <const> = Checkbox -- 11
local SeparatorText <const> = SeparatorText -- 11
local PushTextWrapPos <const> = PushTextWrapPos -- 11
local TextColored <const> = TextColored -- 11
local Button <const> = Button -- 11
local OpenPopup <const> = OpenPopup -- 11
local SetNextWindowPosCenter <const> = SetNextWindowPosCenter -- 11
local BeginPopupModal <const> = BeginPopupModal -- 11
local TextWrapped <const> = TextWrapped -- 11
local CloseCurrentPopup <const> = CloseCurrentPopup -- 11
local SameLine <const> = SameLine -- 11
local Separator <const> = Separator -- 11
local SetNextWindowSize <const> = SetNextWindowSize -- 11
local PushStyleVar <const> = PushStyleVar -- 11
local Begin <const> = Begin -- 11
local TreeNode <const> = TreeNode -- 11
local BeginPopup <const> = BeginPopup -- 11
local Selectable <const> = Selectable -- 11
local BeginDisabled <const> = BeginDisabled -- 11
local setmetatable <const> = setmetatable -- 11
local ipairs <const> = ipairs -- 11
local threadLoop <const> = threadLoop -- 11
local Keyboard <const> = Keyboard -- 11
local SetNextWindowPos <const> = SetNextWindowPos -- 11
local ImageButton <const> = ImageButton -- 11
local ImGui <const> = ImGui -- 11
local SetNextWindowBgAlpha <const> = SetNextWindowBgAlpha -- 11
local TextDisabled <const> = TextDisabled -- 11
local IsItemHovered <const> = IsItemHovered -- 11
local BeginTooltip <const> = BeginTooltip -- 11
local Text <const> = Text -- 11
local PushStyleColor <const> = PushStyleColor -- 11
local ShowStats <const> = ShowStats -- 11
local coroutine <const> = coroutine -- 11
local Image <const> = Image -- 11
local Dummy <const> = Dummy -- 11
local SetNextItemWidth <const> = SetNextItemWidth -- 11
local InputText <const> = InputText -- 11
local Columns <const> = Columns -- 11
local GetColumnWidth <const> = GetColumnWidth -- 11
local NextColumn <const> = NextColumn -- 11
local SetNextItemOpen <const> = SetNextItemOpen -- 11
local PushID <const> = PushID -- 11
local ScrollWhenDraggingOnVoid <const> = ScrollWhenDraggingOnVoid -- 11
App.idled = true -- 13
App.devMode = true -- 14
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "showPreview") -- 50
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
if not (config.showPreview ~= nil) then -- 106
	config.showPreview = true -- 107
end -- 106
local showEntry = true -- 109
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
local _anon_func_0 = function() -- 190
	local _val_0 = App.platform -- 190
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 190
end -- 190
_module_0.connectWebIDE = function() -- 187
	if not config.webIDEConnected then -- 188
		config.webIDEConnected = true -- 189
		if _anon_func_0() then -- 190
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
			local data = json.decode(res) -- 196
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
	end) -- 194
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
	end -- 235
	return _accum_0 -- 235
end -- 229
_module_0["getAllFiles"] = getAllFiles -- 229
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
				local ename, efile = _des_0.entryName, _des_0.fileName -- 249
				if entryName == ename and efile == fileName then -- 250
					_accum_0 = true -- 250
					break -- 250
				end -- 250
			end -- 249
			entryAdded = _accum_0 -- 249
		end -- 249
		if entryAdded then -- 251
			goto _continue_0 -- 251
		end -- 251
		local entry = { -- 252
			entryName = entryName, -- 252
			fileName = fileName -- 252
		} -- 252
		entries[#entries + 1] = entry -- 253
		::_continue_0:: -- 244
	end -- 243
	table.sort(entries, function(a, b) -- 254
		return a.entryName < b.entryName -- 254
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
				local projectPath = Path:getPath(fileName) -- 265
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 266
				local repo = nil -- 267
				if Content:exist(repoFile) then -- 268
					local str = Content:load(repoFile) -- 269
					if str then -- 269
						repo = json.decode(str) -- 270
					end -- 269
				end -- 268
				local entryName = Path:getName(projectPath) -- 271
				local entryAdded -- 272
				do -- 272
					local _accum_0 -- 272
					for _index_2 = 1, #entries do -- 272
						local _des_0 = entries[_index_2] -- 272
						local ename, efile = _des_0.entryName, _des_0.fileName -- 272
						if entryName == ename and efile == fileName then -- 273
							_accum_0 = true -- 273
							break -- 273
						end -- 273
					end -- 272
					entryAdded = _accum_0 -- 272
				end -- 272
				if entryAdded then -- 274
					goto _continue_1 -- 274
				end -- 274
				local examples = { } -- 275
				local tests = { } -- 276
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 277
				if Content:exist(examplePath) then -- 278
					local _list_2 = getFileEntries(examplePath) -- 279
					for _index_2 = 1, #_list_2 do -- 279
						local _des_0 = _list_2[_index_2] -- 279
						local name, ePath = _des_0.entryName, _des_0.fileName -- 279
						local entry = { -- 281
							entryName = name, -- 281
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 282
							workDir = projectPath -- 283
						} -- 280
						examples[#examples + 1] = entry -- 285
					end -- 279
				end -- 278
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 286
				if Content:exist(testPath) then -- 287
					local _list_2 = getFileEntries(testPath) -- 288
					for _index_2 = 1, #_list_2 do -- 288
						local _des_0 = _list_2[_index_2] -- 288
						local name, tPath = _des_0.entryName, _des_0.fileName -- 288
						local entry = { -- 290
							entryName = name, -- 290
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 291
							workDir = projectPath -- 292
						} -- 289
						tests[#tests + 1] = entry -- 294
					end -- 288
				end -- 287
				local entry = { -- 295
					entryName = entryName, -- 295
					fileName = fileName, -- 295
					examples = examples, -- 295
					tests = tests, -- 295
					repo = repo -- 295
				} -- 295
				local bannerFile -- 296
				do -- 296
					local _accum_0 -- 296
					repeat -- 296
						if not config.showPreview then -- 297
							_accum_0 = nil -- 297
							break -- 297
						end -- 297
						local f = Path(projectPath, ".dora", "banner.jpg") -- 298
						if Content:exist(f) then -- 299
							_accum_0 = f -- 299
							break -- 299
						end -- 299
						f = Path(projectPath, ".dora", "banner.png") -- 300
						if Content:exist(f) then -- 301
							_accum_0 = f -- 301
							break -- 301
						end -- 301
						f = Path(projectPath, "Image", "banner.jpg") -- 302
						if Content:exist(f) then -- 303
							_accum_0 = f -- 303
							break -- 303
						end -- 303
						f = Path(projectPath, "Image", "banner.png") -- 304
						if Content:exist(f) then -- 305
							_accum_0 = f -- 305
							break -- 305
						end -- 305
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 306
						if Content:exist(f) then -- 307
							_accum_0 = f -- 307
							break -- 307
						end -- 307
					until true -- 296
					bannerFile = _accum_0 -- 296
				end -- 296
				if bannerFile then -- 309
					thread(function() -- 309
						if Cache:loadAsync(bannerFile) then -- 310
							local bannerTex = Texture2D(bannerFile) -- 311
							if bannerTex then -- 311
								entry.bannerFile = bannerFile -- 312
								entry.bannerTex = bannerTex -- 313
							end -- 311
						end -- 310
					end) -- 309
				end -- 309
				entries[#entries + 1] = entry -- 314
			end -- 262
			::_continue_1:: -- 262
		end -- 261
		::_continue_0:: -- 260
	end -- 259
	table.sort(entries, function(a, b) -- 315
		return a.entryName < b.entryName -- 315
	end) -- 315
	return entries -- 316
end -- 257
local gamesInDev -- 318
local doraTools -- 319
local allEntries -- 320
local updateEntries -- 322
updateEntries = function() -- 322
	gamesInDev = getProjectEntries(Content.writablePath) -- 323
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 324
	allEntries = { } -- 326
	for _index_0 = 1, #gamesInDev do -- 327
		local game = gamesInDev[_index_0] -- 327
		allEntries[#allEntries + 1] = game -- 328
		local examples, tests = game.examples, game.tests -- 329
		for _index_1 = 1, #examples do -- 330
			local example = examples[_index_1] -- 330
			allEntries[#allEntries + 1] = example -- 331
		end -- 330
		for _index_1 = 1, #tests do -- 332
			local test = tests[_index_1] -- 332
			allEntries[#allEntries + 1] = test -- 333
		end -- 332
	end -- 327
end -- 322
updateEntries() -- 335
local doCompile -- 337
doCompile = function(minify) -- 337
	if building then -- 338
		return -- 338
	end -- 338
	building = true -- 339
	local startTime = App.runningTime -- 340
	local luaFiles = { } -- 341
	local yueFiles = { } -- 342
	local xmlFiles = { } -- 343
	local tlFiles = { } -- 344
	local writablePath = Content.writablePath -- 345
	local buildPaths = { -- 347
		{ -- 348
			Content.assetPath, -- 348
			Path(writablePath, ".build"), -- 349
			"" -- 350
		} -- 347
	} -- 346
	for _index_0 = 1, #gamesInDev do -- 353
		local _des_0 = gamesInDev[_index_0] -- 353
		local fileName = _des_0.fileName -- 353
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 354
		buildPaths[#buildPaths + 1] = { -- 356
			Path(writablePath, gamePath), -- 356
			Path(writablePath, ".build", gamePath), -- 357
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 358
			gamePath -- 359
		} -- 355
	end -- 353
	for _index_0 = 1, #buildPaths do -- 360
		local _des_0 = buildPaths[_index_0] -- 360
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 360
		if not Content:exist(inputPath) then -- 361
			goto _continue_0 -- 361
		end -- 361
		local _list_0 = getAllFiles(inputPath, { -- 363
			"lua" -- 363
		}) -- 363
		for _index_1 = 1, #_list_0 do -- 363
			local file = _list_0[_index_1] -- 363
			luaFiles[#luaFiles + 1] = { -- 365
				file, -- 365
				Path(inputPath, file), -- 366
				Path(outputPath, file), -- 367
				gamePath -- 368
			} -- 364
		end -- 363
		local _list_1 = getAllFiles(inputPath, { -- 370
			yueext -- 370
		}) -- 370
		for _index_1 = 1, #_list_1 do -- 370
			local file = _list_1[_index_1] -- 370
			yueFiles[#yueFiles + 1] = { -- 372
				file, -- 372
				Path(inputPath, file), -- 373
				Path(outputPath, Path:replaceExt(file, "lua")), -- 374
				searchPath, -- 375
				gamePath -- 376
			} -- 371
		end -- 370
		local _list_2 = getAllFiles(inputPath, { -- 378
			"xml" -- 378
		}) -- 378
		for _index_1 = 1, #_list_2 do -- 378
			local file = _list_2[_index_1] -- 378
			xmlFiles[#xmlFiles + 1] = { -- 380
				file, -- 380
				Path(inputPath, file), -- 381
				Path(outputPath, Path:replaceExt(file, "lua")), -- 382
				gamePath -- 383
			} -- 379
		end -- 378
		local _list_3 = getAllFiles(inputPath, { -- 385
			"tl" -- 385
		}) -- 385
		for _index_1 = 1, #_list_3 do -- 385
			local file = _list_3[_index_1] -- 385
			if not file:match(".*%.d%.tl$") then -- 386
				tlFiles[#tlFiles + 1] = { -- 388
					file, -- 388
					Path(inputPath, file), -- 389
					Path(outputPath, Path:replaceExt(file, "lua")), -- 390
					searchPath, -- 391
					gamePath -- 392
				} -- 387
			end -- 386
		end -- 385
		::_continue_0:: -- 361
	end -- 360
	local paths -- 394
	do -- 394
		local _tbl_0 = { } -- 394
		local _list_0 = { -- 395
			luaFiles, -- 395
			yueFiles, -- 395
			xmlFiles, -- 395
			tlFiles -- 395
		} -- 395
		for _index_0 = 1, #_list_0 do -- 395
			local files = _list_0[_index_0] -- 395
			for _index_1 = 1, #files do -- 396
				local file = files[_index_1] -- 396
				_tbl_0[Path:getPath(file[3])] = true -- 394
			end -- 394
		end -- 394
		paths = _tbl_0 -- 394
	end -- 394
	for path in pairs(paths) do -- 398
		Content:mkdir(path) -- 398
	end -- 398
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 400
	local fileCount = 0 -- 401
	local errors = { } -- 402
	for _index_0 = 1, #yueFiles do -- 403
		local _des_0 = yueFiles[_index_0] -- 403
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 403
		local filename -- 404
		if gamePath then -- 404
			filename = Path(gamePath, file) -- 404
		else -- 404
			filename = file -- 404
		end -- 404
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 405
			if not codes then -- 406
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 407
				return -- 408
			end -- 406
			local success, result = LintYueGlobals(codes, globals) -- 409
			local yueCodes -- 410
			if not success then -- 411
				yueCodes = Content:load(input) -- 412
				if yueCodes then -- 412
					local CheckTIC80Code -- 413
					do -- 413
						local _obj_0 = require("Utils") -- 413
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 413
					end -- 413
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 414
					if isTIC80 then -- 415
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 416
					end -- 415
				end -- 412
			end -- 411
			if success then -- 417
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 418
			else -- 420
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
					if #globalErrors > 0 then -- 431
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 431
					end -- 431
				else -- 433
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 433
				end -- 420
				if #errors == 0 then -- 434
					return codes -- 434
				end -- 434
			end -- 417
		end, function(success) -- 405
			if success then -- 435
				print("Yue compiled: " .. tostring(filename)) -- 435
			end -- 435
			fileCount = fileCount + 1 -- 436
		end) -- 405
	end -- 403
	thread(function() -- 438
		for _index_0 = 1, #xmlFiles do -- 439
			local _des_0 = xmlFiles[_index_0] -- 439
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 439
			local filename -- 440
			if gamePath then -- 440
				filename = Path(gamePath, file) -- 440
			else -- 440
				filename = file -- 440
			end -- 440
			local sourceCodes = Content:loadAsync(input) -- 441
			local codes, err = xml.tolua(sourceCodes) -- 442
			if not codes then -- 443
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 444
			else -- 446
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 446
				print("Xml compiled: " .. tostring(filename)) -- 447
			end -- 443
			fileCount = fileCount + 1 -- 448
		end -- 439
	end) -- 438
	thread(function() -- 450
		for _index_0 = 1, #tlFiles do -- 451
			local _des_0 = tlFiles[_index_0] -- 451
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 451
			local filename -- 452
			if gamePath then -- 452
				filename = Path(gamePath, file) -- 452
			else -- 452
				filename = file -- 452
			end -- 452
			local sourceCodes = Content:loadAsync(input) -- 453
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 454
			if not codes then -- 455
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 456
			else -- 458
				Content:saveAsync(output, codes) -- 458
				print("Teal compiled: " .. tostring(filename)) -- 459
			end -- 455
			fileCount = fileCount + 1 -- 460
		end -- 451
	end) -- 450
	return thread(function() -- 462
		wait(function() -- 463
			return fileCount == totalFiles -- 463
		end) -- 463
		if minify then -- 464
			local _list_0 = { -- 465
				yueFiles, -- 465
				xmlFiles, -- 465
				tlFiles -- 465
			} -- 465
			for _index_0 = 1, #_list_0 do -- 465
				local files = _list_0[_index_0] -- 465
				for _index_1 = 1, #files do -- 465
					local file = files[_index_1] -- 465
					local output = Path:replaceExt(file[3], "lua") -- 466
					luaFiles[#luaFiles + 1] = { -- 468
						Path:replaceExt(file[1], "lua"), -- 468
						output, -- 469
						output -- 470
					} -- 467
				end -- 465
			end -- 465
			local FormatMini -- 472
			do -- 472
				local _obj_0 = require("luaminify") -- 472
				FormatMini = _obj_0.FormatMini -- 472
			end -- 472
			for _index_0 = 1, #luaFiles do -- 473
				local _des_0 = luaFiles[_index_0] -- 473
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 473
				if Content:exist(input) then -- 474
					local sourceCodes = Content:loadAsync(input) -- 475
					local res, err = FormatMini(sourceCodes) -- 476
					if res then -- 477
						Content:saveAsync(output, res) -- 478
						print("Minify: " .. tostring(file)) -- 479
					else -- 481
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 481
					end -- 477
				else -- 483
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 483
				end -- 474
			end -- 473
			package.loaded["luaminify.FormatMini"] = nil -- 484
			package.loaded["luaminify.ParseLua"] = nil -- 485
			package.loaded["luaminify.Scope"] = nil -- 486
			package.loaded["luaminify.Util"] = nil -- 487
		end -- 464
		local errorMessage = table.concat(errors, "\n") -- 488
		if errorMessage ~= "" then -- 489
			print(errorMessage) -- 489
		end -- 489
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 490
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 491
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 492
		Content:clearPathCache() -- 493
		teal.clear() -- 494
		yue.clear() -- 495
		building = false -- 496
	end) -- 462
end -- 337
local doClean -- 498
doClean = function() -- 498
	if building then -- 499
		return -- 499
	end -- 499
	local writablePath = Content.writablePath -- 500
	local targetDir = Path(writablePath, ".build") -- 501
	Content:clearPathCache() -- 502
	if Content:remove(targetDir) then -- 503
		return print("Cleaned: " .. tostring(targetDir)) -- 504
	end -- 503
end -- 498
local screenScale = 2.0 -- 506
local scaleContent = false -- 507
local isInEntry = true -- 508
local currentEntry = nil -- 509
local footerWindow = nil -- 511
local entryWindow = nil -- 512
local testingThread = nil -- 513
local setupEventHandlers = nil -- 515
local allClear -- 517
allClear = function() -- 517
	for _index_0 = 1, #Routine do -- 518
		local routine = Routine[_index_0] -- 518
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 520
			goto _continue_0 -- 521
		else -- 523
			Routine:remove(routine) -- 523
		end -- 519
		::_continue_0:: -- 519
	end -- 518
	for _index_0 = 1, #moduleCache do -- 524
		local module = moduleCache[_index_0] -- 524
		package.loaded[module] = nil -- 525
	end -- 524
	moduleCache = { } -- 526
	Director:cleanup() -- 527
	Entity:clear() -- 528
	Platformer.Data:clear() -- 529
	Platformer.UnitAction:clear() -- 530
	Audio:stopAll(0.2) -- 531
	Struct:clear() -- 532
	View.postEffect = nil -- 533
	View.scale = scaleContent and screenScale or 1 -- 534
	Director.clearColor = Color(0xff1a1a1a) -- 535
	teal.clear() -- 536
	yue.clear() -- 537
	for _, item in pairs(ubox()) do -- 538
		local node = tolua.cast(item, "Node") -- 539
		if node then -- 539
			node:cleanup() -- 539
		end -- 539
	end -- 538
	collectgarbage() -- 540
	collectgarbage() -- 541
	Wasm:clear() -- 542
	thread(function() -- 543
		sleep() -- 544
		return Cache:removeUnused() -- 545
	end) -- 543
	setupEventHandlers() -- 546
	Content.searchPaths = searchPaths -- 547
	App.idled = true -- 548
end -- 517
_module_0["allClear"] = allClear -- 517
local clearTempFiles -- 550
clearTempFiles = function() -- 550
	local writablePath = Content.writablePath -- 551
	Content:remove(Path(writablePath, ".upload")) -- 552
	return Content:remove(Path(writablePath, ".download")) -- 553
end -- 550
local waitForWebStart = true -- 555
thread(function() -- 556
	sleep(2) -- 557
	waitForWebStart = false -- 558
end) -- 556
local reloadDevEntry -- 560
reloadDevEntry = function() -- 560
	return thread(function() -- 560
		waitForWebStart = true -- 561
		doClean() -- 562
		allClear() -- 563
		_G.require = oldRequire -- 564
		Dora.require = oldRequire -- 565
		package.loaded["Script.Dev.Entry"] = nil -- 566
		return Director.systemScheduler:schedule(function() -- 567
			Routine:clear() -- 568
			oldRequire("Script.Dev.Entry") -- 569
			return true -- 570
		end) -- 567
	end) -- 560
end -- 560
local setWorkspace -- 572
setWorkspace = function(path) -- 572
	clearTempFiles() -- 573
	Content.writablePath = path -- 574
	config.writablePath = Content.writablePath -- 575
	return thread(function() -- 576
		sleep() -- 577
		return reloadDevEntry() -- 578
	end) -- 576
end -- 572
local quit = false -- 580
local stop -- 582
stop = function() -- 582
	if isInEntry then -- 583
		return false -- 583
	end -- 583
	allClear() -- 584
	isInEntry = true -- 585
	currentEntry = nil -- 586
	return true -- 587
end -- 582
_module_0["stop"] = stop -- 582
local _anon_func_1 = function(_with_0) -- 606
	local _val_0 = App.platform -- 606
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 606
end -- 606
setupEventHandlers = function() -- 589
	local _with_0 = Director.postNode -- 590
	_with_0:onAppEvent(function(eventType) -- 591
		if "Quit" == eventType then -- 592
			quit = true -- 593
			allClear() -- 594
			return clearTempFiles() -- 595
		elseif "Shutdown" == eventType then -- 596
			return stop() -- 597
		end -- 591
	end) -- 591
	_with_0:onAppChange(function(settingName) -- 598
		if "Theme" == settingName then -- 599
			config.themeColor = App.themeColor:toARGB() -- 600
		elseif "Locale" == settingName then -- 601
			config.locale = App.locale -- 602
			updateLocale() -- 603
			return teal.clear(true) -- 604
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 605
			if _anon_func_1(_with_0) then -- 606
				if "FullScreen" == settingName then -- 608
					config.fullScreen = App.fullScreen -- 608
				elseif "Position" == settingName then -- 609
					local _obj_0 = App.winPosition -- 609
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 609
				elseif "Size" == settingName then -- 610
					local width, height -- 611
					do -- 611
						local _obj_0 = App.winSize -- 611
						width, height = _obj_0.width, _obj_0.height -- 611
					end -- 611
					config.winWidth = width -- 612
					config.winHeight = height -- 613
				end -- 607
			end -- 606
		end -- 598
	end) -- 598
	_with_0:onAppWS(function(eventType) -- 614
		if eventType == "Close" then -- 614
			if HttpServer.wsConnectionCount == 0 then -- 615
				return updateEntries() -- 616
			end -- 615
		end -- 614
	end) -- 614
	_with_0:slot("UpdateEntries", function() -- 617
		return updateEntries() -- 617
	end) -- 617
	return _with_0 -- 590
end -- 589
setupEventHandlers() -- 619
clearTempFiles() -- 620
local downloadFile -- 622
downloadFile = function(url, target) -- 622
	return Director.systemScheduler:schedule(once(function() -- 622
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 623
			if quit then -- 624
				return true -- 624
			end -- 624
			emit("AppWS", "Send", json.encode({ -- 626
				name = "Download", -- 626
				url = url, -- 626
				status = "downloading", -- 626
				progress = current / total -- 627
			})) -- 625
			return false -- 623
		end) -- 623
		return emit("AppWS", "Send", json.encode(success and { -- 630
			name = "Download", -- 630
			url = url, -- 630
			status = "completed", -- 630
			progress = 1.0 -- 631
		} or { -- 633
			name = "Download", -- 633
			url = url, -- 633
			status = "failed", -- 633
			progress = 0.0 -- 634
		})) -- 629
	end)) -- 622
end -- 622
_module_0["downloadFile"] = downloadFile -- 622
local _anon_func_2 = function(file, require, workDir) -- 645
	if workDir == nil then -- 645
		workDir = Path:getPath(file) -- 645
	end -- 645
	Content:insertSearchPath(1, workDir) -- 646
	local scriptPath = Path(workDir, "Script") -- 647
	if Content:exist(scriptPath) then -- 648
		Content:insertSearchPath(1, scriptPath) -- 649
	end -- 648
	local result = require(file) -- 650
	if "function" == type(result) then -- 651
		result() -- 651
	end -- 651
	return nil -- 652
end -- 645
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 681
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 681
	label.alignment = "Left" -- 682
	label.textWidth = width - fontSize -- 683
	label.text = err -- 684
	return label -- 681
end -- 681
local enterEntryAsync -- 637
enterEntryAsync = function(entry) -- 637
	isInEntry = false -- 638
	App.idled = false -- 639
	emit(Profiler.EventName, "ClearLoader") -- 640
	currentEntry = entry -- 641
	local file, workDir = entry.fileName, entry.workDir -- 642
	sleep() -- 643
	return xpcall(_anon_func_2, function(msg) -- 652
		local err = debug.traceback(msg) -- 654
		Log("Error", err) -- 655
		allClear() -- 656
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 657
		local viewWidth, viewHeight -- 658
		do -- 658
			local _obj_0 = View.size -- 658
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 658
		end -- 658
		local width, height = viewWidth - 20, viewHeight - 20 -- 659
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 660
		Director.ui:addChild((function() -- 661
			local root = AlignNode() -- 661
			do -- 662
				local _obj_0 = App.bufferSize -- 662
				width, height = _obj_0.width, _obj_0.height -- 662
			end -- 662
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 663
			root:onAppChange(function(settingName) -- 664
				if settingName == "Size" then -- 664
					do -- 665
						local _obj_0 = App.bufferSize -- 665
						width, height = _obj_0.width, _obj_0.height -- 665
					end -- 665
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 666
				end -- 664
			end) -- 664
			root:addChild((function() -- 667
				local _with_0 = ScrollArea({ -- 668
					width = width, -- 668
					height = height, -- 669
					paddingX = 0, -- 670
					paddingY = 50, -- 671
					viewWidth = height, -- 672
					viewHeight = height -- 673
				}) -- 667
				root:onAlignLayout(function(w, h) -- 675
					_with_0.position = Vec2(w / 2, h / 2) -- 676
					w = w - 20 -- 677
					h = h - 20 -- 678
					_with_0.view.children.first.textWidth = w - fontSize -- 679
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 680
				end) -- 675
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 681
				return _with_0 -- 667
			end)()) -- 667
			return root -- 661
		end)()) -- 661
		return err -- 685
	end, file, require, workDir) -- 644
end -- 637
_module_0["enterEntryAsync"] = enterEntryAsync -- 637
local enterDemoEntry -- 687
enterDemoEntry = function(entry) -- 687
	return thread(function() -- 687
		return enterEntryAsync(entry) -- 687
	end) -- 687
end -- 687
local reloadCurrentEntry -- 689
reloadCurrentEntry = function() -- 689
	if currentEntry then -- 690
		allClear() -- 691
		return enterDemoEntry(currentEntry) -- 692
	end -- 690
end -- 689
Director.clearColor = Color(0xff1a1a1a) -- 694
local extraOperations -- 696
do -- 696
	local isOSSLicenseExist = Content:exist("LICENSES") -- 697
	local ossLicenses = nil -- 698
	local ossLicenseOpen = false -- 699
	local failedSetFolder = false -- 700
	local statusFlags = { -- 701
		"NoResize", -- 701
		"NoMove", -- 701
		"NoCollapse", -- 701
		"AlwaysAutoResize", -- 701
		"NoSavedSettings" -- 701
	} -- 701
	extraOperations = function() -- 708
		local zh = useChinese -- 709
		if isDesktop then -- 710
			local themeColor = App.themeColor -- 711
			local alwaysOnTop, writablePath, showPreview = config.alwaysOnTop, config.writablePath, config.showPreview -- 712
			do -- 713
				local changed -- 713
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 713
				if changed then -- 713
					App.alwaysOnTop = alwaysOnTop -- 714
					config.alwaysOnTop = alwaysOnTop -- 715
				end -- 713
			end -- 713
			do -- 716
				local changed -- 716
				changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 716
				if changed then -- 716
					config.showPreview = showPreview -- 717
					updateEntries() -- 718
					if not showPreview then -- 719
						thread(function() -- 720
							collectgarbage() -- 721
							return Cache:removeUnused("Texture") -- 722
						end) -- 720
					end -- 719
				end -- 716
			end -- 716
			SeparatorText(zh and "工作目录" or "Workspace") -- 723
			PushTextWrapPos(400, function() -- 724
				return TextColored(themeColor, writablePath) -- 725
			end) -- 724
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 726
			if Button(zh and "改变目录" or "Set Folder") then -- 727
				App:openFileDialog(true, function(path) -- 728
					if path == "" then -- 729
						return -- 729
					end -- 729
					local relPath = Path:getRelative(Content.assetPath, path) -- 730
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 731
						return setWorkspace(path) -- 732
					else -- 734
						failedSetFolder = true -- 734
					end -- 731
				end) -- 728
			end -- 727
			if failedSetFolder then -- 735
				failedSetFolder = false -- 736
				OpenPopup(popupName) -- 737
			end -- 735
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 738
			BeginPopupModal(popupName, statusFlags, function() -- 739
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 740
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 741
					return CloseCurrentPopup() -- 742
				end -- 741
			end) -- 739
			SameLine() -- 743
			if Button(zh and "使用默认" or "Use Default") then -- 744
				setWorkspace(Content.appPath) -- 745
			end -- 744
			Separator() -- 746
		end -- 710
		if isOSSLicenseExist then -- 747
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 748
				if not ossLicenses then -- 749
					ossLicenses = { } -- 750
					local licenseText = Content:load("LICENSES") -- 751
					ossLicenseOpen = (licenseText ~= nil) -- 752
					if ossLicenseOpen then -- 752
						licenseText = licenseText:gsub("\r\n", "\n") -- 753
						for license in GSplit(licenseText, "\n--------\n", true) do -- 754
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 755
							if name then -- 755
								ossLicenses[#ossLicenses + 1] = { -- 756
									name, -- 756
									text -- 756
								} -- 756
							end -- 755
						end -- 754
					end -- 752
				else -- 758
					ossLicenseOpen = true -- 758
				end -- 749
			end -- 748
			if ossLicenseOpen then -- 759
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 760
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 761
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 762
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 763
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 766
						"NoSavedSettings" -- 766
					}, function() -- 767
						for _index_0 = 1, #ossLicenses do -- 767
							local _des_0 = ossLicenses[_index_0] -- 767
							local firstLine, text = _des_0[1], _des_0[2] -- 767
							local name, license = firstLine:match("(.+): (.+)") -- 768
							TextColored(themeColor, name) -- 769
							SameLine() -- 770
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 771
								return TextWrapped(text) -- 771
							end) -- 771
						end -- 767
					end) -- 763
				end) -- 763
			end -- 759
		end -- 747
		if not App.debugging then -- 773
			return -- 773
		end -- 773
		return TreeNode(zh and "开发操作" or "Development", function() -- 774
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 775
				OpenPopup("build") -- 775
			end -- 775
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 776
				return BeginPopup("build", function() -- 776
					if Selectable(zh and "编译" or "Compile") then -- 777
						doCompile(false) -- 777
					end -- 777
					Separator() -- 778
					if Selectable(zh and "压缩" or "Minify") then -- 779
						doCompile(true) -- 779
					end -- 779
					Separator() -- 780
					if Selectable(zh and "清理" or "Clean") then -- 781
						return doClean() -- 781
					end -- 781
				end) -- 776
			end) -- 776
			if isInEntry then -- 782
				if waitForWebStart then -- 783
					BeginDisabled(function() -- 784
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 784
					end) -- 784
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 785
					reloadDevEntry() -- 786
				end -- 783
			end -- 782
			do -- 787
				local changed -- 787
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 787
				if changed then -- 787
					View.scale = scaleContent and screenScale or 1 -- 788
				end -- 787
			end -- 787
			do -- 789
				local changed -- 789
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 789
				if changed then -- 789
					config.engineDev = engineDev -- 790
				end -- 789
			end -- 789
			if testingThread then -- 791
				return BeginDisabled(function() -- 792
					return Button(zh and "开始自动测试" or "Test automatically") -- 792
				end) -- 792
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 793
				testingThread = thread(function() -- 794
					local _ <close> = setmetatable({ }, { -- 795
						__close = function() -- 795
							allClear() -- 796
							testingThread = nil -- 797
							isInEntry = true -- 798
							currentEntry = nil -- 799
							return print("Testing done!") -- 800
						end -- 795
					}) -- 795
					for _, entry in ipairs(allEntries) do -- 801
						allClear() -- 802
						print("Start " .. tostring(entry.entryName)) -- 803
						enterDemoEntry(entry) -- 804
						sleep(2) -- 805
						print("Stop " .. tostring(entry.entryName)) -- 806
					end -- 801
				end) -- 794
			end -- 791
		end) -- 774
	end -- 708
end -- 696
local icon = Path("Script", "Dev", "icon_s.png") -- 808
local iconTex = nil -- 809
thread(function() -- 810
	if Cache:loadAsync(icon) then -- 810
		iconTex = Texture2D(icon) -- 810
	end -- 810
end) -- 810
local webStatus = nil -- 812
local urlClicked = nil -- 813
local descColor = Color(0xffa1a1a1) -- 814
local transparant = Color(0x0) -- 816
local windowFlags = { -- 817
	"NoTitleBar", -- 817
	"NoResize", -- 817
	"NoMove", -- 817
	"NoCollapse", -- 817
	"NoSavedSettings", -- 817
	"NoFocusOnAppearing", -- 817
	"NoBringToFrontOnFocus" -- 817
} -- 817
local statusFlags = { -- 826
	"NoTitleBar", -- 826
	"NoResize", -- 826
	"NoMove", -- 826
	"NoCollapse", -- 826
	"AlwaysAutoResize", -- 826
	"NoSavedSettings" -- 826
} -- 826
local displayWindowFlags = { -- 834
	"NoDecoration", -- 834
	"NoSavedSettings", -- 834
	"NoNav", -- 834
	"NoMove", -- 834
	"NoScrollWithMouse", -- 834
	"AlwaysAutoResize", -- 834
	"NoFocusOnAppearing" -- 834
} -- 834
local initFooter = true -- 843
local _anon_func_4 = function(allEntries, currentIndex) -- 880
	if currentIndex > 1 then -- 880
		return allEntries[currentIndex - 1] -- 881
	else -- 883
		return allEntries[#allEntries] -- 883
	end -- 880
end -- 880
local _anon_func_5 = function(allEntries, currentIndex) -- 887
	if currentIndex < #allEntries then -- 887
		return allEntries[currentIndex + 1] -- 888
	else -- 890
		return allEntries[1] -- 890
	end -- 887
end -- 887
footerWindow = threadLoop(function() -- 844
	local zh = useChinese -- 845
	if HttpServer.wsConnectionCount > 0 then -- 846
		return -- 847
	end -- 846
	if Keyboard:isKeyDown("Escape") then -- 848
		allClear() -- 849
		App.devMode = false -- 850
		App:shutdown() -- 851
	end -- 848
	do -- 852
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 853
		if ctrl and Keyboard:isKeyDown("Q") then -- 854
			stop() -- 855
		end -- 854
		if ctrl and Keyboard:isKeyDown("Z") then -- 856
			reloadCurrentEntry() -- 857
		end -- 856
		if ctrl and Keyboard:isKeyDown(",") then -- 858
			if showFooter then -- 859
				showStats = not showStats -- 859
			else -- 859
				showStats = true -- 859
			end -- 859
			showFooter = true -- 860
			config.showFooter = showFooter -- 861
			config.showStats = showStats -- 862
		end -- 858
		if ctrl and Keyboard:isKeyDown(".") then -- 863
			if showFooter then -- 864
				showConsole = not showConsole -- 864
			else -- 864
				showConsole = true -- 864
			end -- 864
			showFooter = true -- 865
			config.showFooter = showFooter -- 866
			config.showConsole = showConsole -- 867
		end -- 863
		if ctrl and Keyboard:isKeyDown("/") then -- 868
			showFooter = not showFooter -- 869
			config.showFooter = showFooter -- 870
		end -- 868
		local left = ctrl and Keyboard:isKeyDown("Left") -- 871
		local right = ctrl and Keyboard:isKeyDown("Right") -- 872
		local currentIndex = nil -- 873
		for i, entry in ipairs(allEntries) do -- 874
			if currentEntry == entry then -- 875
				currentIndex = i -- 876
			end -- 875
		end -- 874
		if left then -- 877
			allClear() -- 878
			if currentIndex == nil then -- 879
				currentIndex = #allEntries + 1 -- 879
			end -- 879
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 880
		end -- 877
		if right then -- 884
			allClear() -- 885
			if currentIndex == nil then -- 886
				currentIndex = 0 -- 886
			end -- 886
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 887
		end -- 884
	end -- 852
	if not showEntry then -- 891
		return -- 891
	end -- 891
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 893
		reloadDevEntry() -- 897
	end -- 893
	if initFooter then -- 898
		initFooter = false -- 899
	end -- 898
	local width, height -- 901
	do -- 901
		local _obj_0 = App.visualSize -- 901
		width, height = _obj_0.width, _obj_0.height -- 901
	end -- 901
	if isInEntry or showFooter then -- 902
		SetNextWindowSize(Vec2(width, 50)) -- 903
		SetNextWindowPos(Vec2(0, height - 50)) -- 904
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 905
			return PushStyleVar("WindowRounding", 0, function() -- 906
				return Begin("Footer", windowFlags, function() -- 907
					Separator() -- 908
					if iconTex then -- 909
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 910
							showStats = not showStats -- 911
							config.showStats = showStats -- 912
						end -- 910
						SameLine() -- 913
						if Button(">_", Vec2(30, 30)) then -- 914
							showConsole = not showConsole -- 915
							config.showConsole = showConsole -- 916
						end -- 914
					end -- 909
					if isInEntry and config.updateNotification then -- 917
						SameLine() -- 918
						if ImGui.Button(zh and "更新可用" or "Update") then -- 919
							allClear() -- 920
							config.updateNotification = false -- 921
							enterDemoEntry({ -- 923
								entryName = "SelfUpdater", -- 923
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 924
							}) -- 922
						end -- 919
					end -- 917
					if not isInEntry then -- 925
						SameLine() -- 926
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 927
						local currentIndex = nil -- 928
						for i, entry in ipairs(allEntries) do -- 929
							if currentEntry == entry then -- 930
								currentIndex = i -- 931
							end -- 930
						end -- 929
						if currentIndex then -- 932
							if currentIndex > 1 then -- 933
								SameLine() -- 934
								if Button("<<", Vec2(30, 30)) then -- 935
									allClear() -- 936
									enterDemoEntry(allEntries[currentIndex - 1]) -- 937
								end -- 935
							end -- 933
							if currentIndex < #allEntries then -- 938
								SameLine() -- 939
								if Button(">>", Vec2(30, 30)) then -- 940
									allClear() -- 941
									enterDemoEntry(allEntries[currentIndex + 1]) -- 942
								end -- 940
							end -- 938
						end -- 932
						SameLine() -- 943
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 944
							reloadCurrentEntry() -- 945
						end -- 944
						if back then -- 946
							allClear() -- 947
							isInEntry = true -- 948
							currentEntry = nil -- 949
						end -- 946
					end -- 925
				end) -- 907
			end) -- 906
		end) -- 905
	end -- 902
	local showWebIDE = isInEntry -- 951
	if config.updateNotification then -- 952
		if width < 460 then -- 953
			showWebIDE = false -- 954
		end -- 953
	else -- 956
		if width < 360 then -- 956
			showWebIDE = false -- 957
		end -- 956
	end -- 952
	if showWebIDE then -- 958
		SetNextWindowBgAlpha(0.0) -- 959
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 960
		Begin("Web IDE", displayWindowFlags, function() -- 961
			do -- 962
				local url -- 962
				if webStatus ~= nil then -- 962
					url = webStatus.url -- 962
				end -- 962
				if url then -- 962
					if isDesktop and not config.fullScreen then -- 963
						if urlClicked then -- 964
							BeginDisabled(function() -- 965
								return Button(url) -- 965
							end) -- 965
						elseif Button(url) then -- 966
							urlClicked = once(function() -- 967
								return sleep(5) -- 967
							end) -- 967
							App:openURL("http://localhost:8866") -- 968
						end -- 964
					else -- 970
						TextColored(descColor, url) -- 970
					end -- 963
				else -- 972
					TextColored(descColor, zh and '不可用' or 'not available') -- 972
				end -- 962
			end -- 962
			SameLine() -- 973
			TextDisabled('(?)') -- 974
			if IsItemHovered() then -- 975
				return BeginTooltip(function() -- 976
					return PushTextWrapPos(280, function() -- 977
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 978
					end) -- 977
				end) -- 976
			end -- 975
		end) -- 961
	end -- 958
	if not isInEntry then -- 980
		SetNextWindowSize(Vec2(50, 50)) -- 981
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 982
		PushStyleColor("WindowBg", transparant, function() -- 983
			return Begin("Show", displayWindowFlags, function() -- 983
				if width >= 370 then -- 984
					local changed -- 985
					changed, showFooter = Checkbox("##dev", showFooter) -- 985
					if changed then -- 985
						config.showFooter = showFooter -- 986
					end -- 985
				end -- 984
			end) -- 983
		end) -- 983
	end -- 980
	if isInEntry or showFooter then -- 988
		if showStats then -- 989
			PushStyleVar("WindowRounding", 0, function() -- 990
				SetNextWindowPos(Vec2(0, 0), "Always") -- 991
				SetNextWindowSize(Vec2(0, height - 50)) -- 992
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 993
				config.showStats = showStats -- 994
			end) -- 990
		end -- 989
		if showConsole then -- 995
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 996
			return PushStyleVar("WindowRounding", 6, function() -- 997
				return ShowConsole() -- 998
			end) -- 997
		end -- 995
	end -- 988
end) -- 844
local MaxWidth <const> = 960 -- 1000
local toolOpen = false -- 1002
local filterText = nil -- 1003
local anyEntryMatched = false -- 1004
local match -- 1005
match = function(name) -- 1005
	local res = not filterText or name:lower():match(filterText) -- 1006
	if res then -- 1007
		anyEntryMatched = true -- 1007
	end -- 1007
	return res -- 1008
end -- 1005
local sep -- 1010
sep = function() -- 1010
	return SeparatorText("") -- 1010
end -- 1010
local thinSep -- 1011
thinSep = function() -- 1011
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1011
end -- 1011
entryWindow = threadLoop(function() -- 1013
	if App.fpsLimited ~= config.fpsLimited then -- 1014
		config.fpsLimited = App.fpsLimited -- 1015
	end -- 1014
	if App.targetFPS ~= config.targetFPS then -- 1016
		config.targetFPS = App.targetFPS -- 1017
	end -- 1016
	if View.vsync ~= config.vsync then -- 1018
		config.vsync = View.vsync -- 1019
	end -- 1018
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1020
		config.fixedFPS = Director.scheduler.fixedFPS -- 1021
	end -- 1020
	if Director.profilerSending ~= config.webProfiler then -- 1022
		config.webProfiler = Director.profilerSending -- 1023
	end -- 1022
	if urlClicked then -- 1024
		local _, result = coroutine.resume(urlClicked) -- 1025
		if result then -- 1026
			coroutine.close(urlClicked) -- 1027
			urlClicked = nil -- 1028
		end -- 1026
	end -- 1024
	if not showEntry then -- 1029
		return -- 1029
	end -- 1029
	if not isInEntry then -- 1030
		return -- 1030
	end -- 1030
	local zh = useChinese -- 1031
	if HttpServer.wsConnectionCount > 0 then -- 1032
		local themeColor = App.themeColor -- 1033
		local width, height -- 1034
		do -- 1034
			local _obj_0 = App.visualSize -- 1034
			width, height = _obj_0.width, _obj_0.height -- 1034
		end -- 1034
		SetNextWindowBgAlpha(0.5) -- 1035
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1036
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1037
			Separator() -- 1038
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1039
			if iconTex then -- 1040
				Image(icon, Vec2(24, 24)) -- 1041
				SameLine() -- 1042
			end -- 1040
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1043
			TextColored(descColor, slogon) -- 1044
			return Separator() -- 1045
		end) -- 1037
		return -- 1046
	end -- 1032
	local themeColor = App.themeColor -- 1048
	local fullWidth, height -- 1049
	do -- 1049
		local _obj_0 = App.visualSize -- 1049
		fullWidth, height = _obj_0.width, _obj_0.height -- 1049
	end -- 1049
	local width = math.min(MaxWidth, fullWidth) -- 1050
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1051
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1052
	SetNextWindowPos(Vec2.zero) -- 1053
	SetNextWindowBgAlpha(0) -- 1054
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1055
	do -- 1056
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1057
			return Begin("Dora Dev", windowFlags, function() -- 1058
				Dummy(Vec2(fullWidth - 20, 0)) -- 1059
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1060
				if fullWidth >= 400 then -- 1061
					SameLine() -- 1062
					Dummy(Vec2(fullWidth - 400, 0)) -- 1063
					SameLine() -- 1064
					SetNextItemWidth(zh and -95 or -140) -- 1065
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1066
						"AutoSelectAll" -- 1066
					}) then -- 1066
						config.filter = filterBuf.text -- 1067
					end -- 1066
					SameLine() -- 1068
					if Button(zh and '下载' or 'Download') then -- 1069
						allClear() -- 1070
						enterDemoEntry({ -- 1072
							entryName = "ResourceDownloader", -- 1072
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1073
						}) -- 1071
					end -- 1069
				end -- 1061
				Separator() -- 1074
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1075
			end) -- 1058
		end) -- 1057
	end -- 1056
	anyEntryMatched = false -- 1077
	SetNextWindowPos(Vec2(0, 50)) -- 1078
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1079
	do -- 1080
		return PushStyleColor("WindowBg", transparant, function() -- 1081
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1082
				return PushStyleVar("Alpha", 1, function() -- 1083
					return Begin("Content", windowFlags, function() -- 1084
						local DemoViewWidth <const> = 220 -- 1085
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1086
						if filterText then -- 1087
							filterText = filterText:lower() -- 1087
						end -- 1087
						if #gamesInDev > 0 then -- 1088
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1089
							Columns(columns, false) -- 1090
							local realViewWidth = GetColumnWidth() - 50 -- 1091
							for _index_0 = 1, #gamesInDev do -- 1092
								local game = gamesInDev[_index_0] -- 1092
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1093
								local displayName -- 1102
								if repo then -- 1102
									if zh then -- 1103
										displayName = repo.title.zh -- 1103
									else -- 1103
										displayName = repo.title.en -- 1103
									end -- 1103
								end -- 1102
								if displayName == nil then -- 1104
									displayName = gameName -- 1104
								end -- 1104
								if match(displayName) then -- 1105
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1106
									SameLine() -- 1107
									TextWrapped(displayName) -- 1108
									if columns > 1 then -- 1109
										if bannerFile then -- 1110
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1111
											local displayWidth <const> = realViewWidth -- 1112
											texHeight = displayWidth * texHeight / texWidth -- 1113
											texWidth = displayWidth -- 1114
											Dummy(Vec2.zero) -- 1115
											SameLine() -- 1116
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1117
										end -- 1110
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1118
											enterDemoEntry(game) -- 1119
										end -- 1118
									else -- 1121
										if bannerFile then -- 1121
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1122
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1123
											local sizing = 0.8 -- 1124
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1125
											texWidth = displayWidth * sizing -- 1126
											if texWidth > 500 then -- 1127
												sizing = 0.6 -- 1128
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1129
												texWidth = displayWidth * sizing -- 1130
											end -- 1127
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1131
											Dummy(Vec2(padding, 0)) -- 1132
											SameLine() -- 1133
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1134
										end -- 1121
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1135
											enterDemoEntry(game) -- 1136
										end -- 1135
									end -- 1109
									if #tests == 0 and #examples == 0 then -- 1137
										thinSep() -- 1138
									end -- 1137
									NextColumn() -- 1139
								end -- 1105
								local showSep = false -- 1140
								if #examples > 0 then -- 1141
									local showExample = false -- 1142
									do -- 1143
										local _accum_0 -- 1143
										for _index_1 = 1, #examples do -- 1143
											local _des_0 = examples[_index_1] -- 1143
											local entryName = _des_0.entryName -- 1143
											if match(entryName) then -- 1144
												_accum_0 = true -- 1144
												break -- 1144
											end -- 1144
										end -- 1143
										showExample = _accum_0 -- 1143
									end -- 1143
									if showExample then -- 1145
										showSep = true -- 1146
										Columns(1, false) -- 1147
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1148
										SameLine() -- 1149
										local opened -- 1150
										if (filterText ~= nil) then -- 1150
											opened = showExample -- 1150
										else -- 1150
											opened = false -- 1150
										end -- 1150
										if game.exampleOpen == nil then -- 1151
											game.exampleOpen = opened -- 1151
										end -- 1151
										SetNextItemOpen(game.exampleOpen) -- 1152
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1153
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1154
												Columns(maxColumns, false) -- 1155
												for _index_1 = 1, #examples do -- 1156
													local example = examples[_index_1] -- 1156
													local entryName = example.entryName -- 1157
													if not match(entryName) then -- 1158
														goto _continue_0 -- 1158
													end -- 1158
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1159
														if Button(entryName, Vec2(-1, 40)) then -- 1160
															enterDemoEntry(example) -- 1161
														end -- 1160
														return NextColumn() -- 1162
													end) -- 1159
													opened = true -- 1163
													::_continue_0:: -- 1157
												end -- 1156
											end) -- 1154
										end) -- 1153
										game.exampleOpen = opened -- 1164
									end -- 1145
								end -- 1141
								if #tests > 0 then -- 1165
									local showTest = false -- 1166
									do -- 1167
										local _accum_0 -- 1167
										for _index_1 = 1, #tests do -- 1167
											local _des_0 = tests[_index_1] -- 1167
											local entryName = _des_0.entryName -- 1167
											if match(entryName) then -- 1168
												_accum_0 = true -- 1168
												break -- 1168
											end -- 1168
										end -- 1167
										showTest = _accum_0 -- 1167
									end -- 1167
									if showTest then -- 1169
										showSep = true -- 1170
										Columns(1, false) -- 1171
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1172
										SameLine() -- 1173
										local opened -- 1174
										if (filterText ~= nil) then -- 1174
											opened = showTest -- 1174
										else -- 1174
											opened = false -- 1174
										end -- 1174
										if game.testOpen == nil then -- 1175
											game.testOpen = opened -- 1175
										end -- 1175
										SetNextItemOpen(game.testOpen) -- 1176
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1177
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1178
												Columns(maxColumns, false) -- 1179
												for _index_1 = 1, #tests do -- 1180
													local test = tests[_index_1] -- 1180
													local entryName = test.entryName -- 1181
													if not match(entryName) then -- 1182
														goto _continue_0 -- 1182
													end -- 1182
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1183
														if Button(entryName, Vec2(-1, 40)) then -- 1184
															enterDemoEntry(test) -- 1185
														end -- 1184
														return NextColumn() -- 1186
													end) -- 1183
													opened = true -- 1187
													::_continue_0:: -- 1181
												end -- 1180
											end) -- 1178
										end) -- 1177
										game.testOpen = opened -- 1188
									end -- 1169
								end -- 1165
								if showSep then -- 1189
									Columns(1, false) -- 1190
									thinSep() -- 1191
									Columns(columns, false) -- 1192
								end -- 1189
							end -- 1092
						end -- 1088
						if #doraTools > 0 then -- 1193
							local showTool = false -- 1194
							do -- 1195
								local _accum_0 -- 1195
								for _index_0 = 1, #doraTools do -- 1195
									local _des_0 = doraTools[_index_0] -- 1195
									local entryName = _des_0.entryName -- 1195
									if match(entryName) then -- 1196
										_accum_0 = true -- 1196
										break -- 1196
									end -- 1196
								end -- 1195
								showTool = _accum_0 -- 1195
							end -- 1195
							if not showTool then -- 1197
								goto endEntry -- 1197
							end -- 1197
							Columns(1, false) -- 1198
							TextColored(themeColor, "Dora SSR:") -- 1199
							SameLine() -- 1200
							Text(zh and "开发支持" or "Development Support") -- 1201
							Separator() -- 1202
							if #doraTools > 0 then -- 1203
								local opened -- 1204
								if (filterText ~= nil) then -- 1204
									opened = showTool -- 1204
								else -- 1204
									opened = false -- 1204
								end -- 1204
								SetNextItemOpen(toolOpen) -- 1205
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1206
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1207
										Columns(maxColumns, false) -- 1208
										for _index_0 = 1, #doraTools do -- 1209
											local example = doraTools[_index_0] -- 1209
											local entryName = example.entryName -- 1210
											if not match(entryName) then -- 1211
												goto _continue_0 -- 1211
											end -- 1211
											if Button(entryName, Vec2(-1, 40)) then -- 1212
												enterDemoEntry(example) -- 1213
											end -- 1212
											NextColumn() -- 1214
											::_continue_0:: -- 1210
										end -- 1209
										Columns(1, false) -- 1215
										opened = true -- 1216
									end) -- 1207
								end) -- 1206
								toolOpen = opened -- 1217
							end -- 1203
						end -- 1193
						::endEntry:: -- 1218
						if not anyEntryMatched then -- 1219
							SetNextWindowBgAlpha(0) -- 1220
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1221
							Begin("Entries Not Found", displayWindowFlags, function() -- 1222
								Separator() -- 1223
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1224
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1225
								return Separator() -- 1226
							end) -- 1222
						end -- 1219
						Columns(1, false) -- 1227
						Dummy(Vec2(100, 80)) -- 1228
						return ScrollWhenDraggingOnVoid() -- 1229
					end) -- 1084
				end) -- 1083
			end) -- 1082
		end) -- 1081
	end -- 1080
end) -- 1013
webStatus = require("Script.Dev.WebServer") -- 1231
return _module_0 -- 1
