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
_module_0["setWorkspace"] = setWorkspace -- 572
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
local _anon_func_4 = function() -- 723
	local _val_0 = App.platform -- 723
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 or "Android" == _val_0 -- 723
end -- 723
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
			local alwaysOnTop = config.alwaysOnTop -- 711
			local changed -- 712
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 712
			if changed then -- 712
				App.alwaysOnTop = alwaysOnTop -- 713
				config.alwaysOnTop = alwaysOnTop -- 714
			end -- 712
		end -- 710
		local showPreview = config.showPreview -- 715
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
		if _anon_func_4() then -- 723
			local themeColor = App.themeColor -- 724
			local writablePath = config.writablePath -- 725
			SeparatorText(zh and "工作目录" or "Workspace") -- 726
			PushTextWrapPos(400, function() -- 727
				return TextColored(themeColor, writablePath) -- 728
			end) -- 727
			if App.platform == "Android" then -- 729
				goto skipSetting -- 729
			end -- 729
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 730
			if Button(zh and "改变目录" or "Set Folder") then -- 731
				App:openFileDialog(true, function(path) -- 732
					if path == "" then -- 733
						return -- 733
					end -- 733
					local relPath = Path:getRelative(Content.assetPath, path) -- 734
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 735
						return setWorkspace(path) -- 736
					else -- 738
						failedSetFolder = true -- 738
					end -- 735
				end) -- 732
			end -- 731
			if failedSetFolder then -- 739
				failedSetFolder = false -- 740
				OpenPopup(popupName) -- 741
			end -- 739
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 742
			BeginPopupModal(popupName, statusFlags, function() -- 743
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 744
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 745
					return CloseCurrentPopup() -- 746
				end -- 745
			end) -- 743
			SameLine() -- 747
			if Button(zh and "使用默认" or "Use Default") then -- 748
				setWorkspace(Content.appPath) -- 749
			end -- 748
			Separator() -- 750
			::skipSetting:: -- 751
		end -- 723
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
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 765
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
	end -- 708
end -- 696
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
local _anon_func_5 = function(allEntries, currentIndex) -- 885
	if currentIndex > 1 then -- 885
		return allEntries[currentIndex - 1] -- 886
	else -- 888
		return allEntries[#allEntries] -- 888
	end -- 885
end -- 885
local _anon_func_6 = function(allEntries, currentIndex) -- 892
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
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 885
		end -- 882
		if right then -- 889
			allClear() -- 890
			if currentIndex == nil then -- 891
				currentIndex = 0 -- 891
			end -- 891
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 892
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
