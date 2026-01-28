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
local once <const> = once -- 11
local emit <const> = emit -- 11
local HttpServer <const> = HttpServer -- 11
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
local activeSearchId = 0 -- 582
local handleSearchFiles -- 584
handleSearchFiles = function(payload) -- 584
	if not payload then -- 585
		return -- 585
	end -- 585
	local id = payload.id -- 586
	if id == nil then -- 587
		return -- 587
	end -- 587
	activeSearchId = id -- 588
	local path = payload.path or "" -- 589
	local exts = payload.exts or { } -- 590
	local extensionLevels = payload.extensionLevels or { } -- 591
	local excludes = payload.excludes or { } -- 592
	local pattern = payload.pattern or "" -- 593
	if pattern == "" then -- 594
		return -- 594
	end -- 594
	local useRegex = payload.useRegex == true -- 595
	local caseSensitive = payload.caseSensitive == true -- 596
	local includeContent = payload.includeContent ~= false -- 597
	local contentWindow = payload.contentWindow or 0 -- 598
	return Director.systemScheduler:schedule(once(function() -- 599
		local stopped = false -- 600
		Content:searchFilesAsync(path, exts, extensionLevels, excludes, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 601
			if activeSearchId ~= id then -- 602
				stopped = true -- 603
				return true -- 604
			end -- 602
			emit("AppWS", "Send", json.encode({ -- 606
				name = "SearchFilesResult", -- 606
				id = id, -- 606
				result = result -- 606
			})) -- 605
			return false -- 608
		end) -- 601
		return emit("AppWS", "Send", json.encode({ -- 610
			name = "SearchFilesDone", -- 610
			id = id, -- 610
			stopped = stopped -- 610
		})) -- 609
	end)) -- 599
end -- 584
local stop -- 613
stop = function() -- 613
	if isInEntry then -- 614
		return false -- 614
	end -- 614
	allClear() -- 615
	isInEntry = true -- 616
	currentEntry = nil -- 617
	return true -- 618
end -- 613
_module_0["stop"] = stop -- 613
local _anon_func_1 = function(_with_0) -- 637
	local _val_0 = App.platform -- 637
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 637
end -- 637
setupEventHandlers = function() -- 620
	local _with_0 = Director.postNode -- 621
	_with_0:onAppEvent(function(eventType) -- 622
		if "Quit" == eventType then -- 623
			quit = true -- 624
			allClear() -- 625
			return clearTempFiles() -- 626
		elseif "Shutdown" == eventType then -- 627
			return stop() -- 628
		end -- 622
	end) -- 622
	_with_0:onAppChange(function(settingName) -- 629
		if "Theme" == settingName then -- 630
			config.themeColor = App.themeColor:toARGB() -- 631
		elseif "Locale" == settingName then -- 632
			config.locale = App.locale -- 633
			updateLocale() -- 634
			return teal.clear(true) -- 635
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 636
			if _anon_func_1(_with_0) then -- 637
				if "FullScreen" == settingName then -- 639
					config.fullScreen = App.fullScreen -- 639
				elseif "Position" == settingName then -- 640
					local _obj_0 = App.winPosition -- 640
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 640
				elseif "Size" == settingName then -- 641
					local width, height -- 642
					do -- 642
						local _obj_0 = App.winSize -- 642
						width, height = _obj_0.width, _obj_0.height -- 642
					end -- 642
					config.winWidth = width -- 643
					config.winHeight = height -- 644
				end -- 638
			end -- 637
		end -- 629
	end) -- 629
	_with_0:onAppWS(function(eventType, msg) -- 645
		if eventType == "Close" then -- 646
			if HttpServer.wsConnectionCount == 0 then -- 647
				updateEntries() -- 648
			end -- 647
			return -- 649
		end -- 646
		if not (eventType == "Receive") then -- 650
			return -- 650
		end -- 650
		local data = json.decode(msg) -- 651
		if not data then -- 652
			return -- 652
		end -- 652
		local _exp_0 = data.name -- 653
		if "SearchFiles" == _exp_0 then -- 654
			return handleSearchFiles(data) -- 655
		elseif "SearchFilesStop" == _exp_0 then -- 656
			if data.id == nil or data.id == activeSearchId then -- 657
				activeSearchId = 0 -- 658
			end -- 657
		end -- 653
	end) -- 645
	_with_0:slot("UpdateEntries", function() -- 659
		return updateEntries() -- 659
	end) -- 659
	return _with_0 -- 621
end -- 620
setupEventHandlers() -- 661
clearTempFiles() -- 662
local downloadFile -- 664
downloadFile = function(url, target) -- 664
	return Director.systemScheduler:schedule(once(function() -- 664
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 665
			if quit then -- 666
				return true -- 666
			end -- 666
			emit("AppWS", "Send", json.encode({ -- 668
				name = "Download", -- 668
				url = url, -- 668
				status = "downloading", -- 668
				progress = current / total -- 669
			})) -- 667
			return false -- 665
		end) -- 665
		return emit("AppWS", "Send", json.encode(success and { -- 672
			name = "Download", -- 672
			url = url, -- 672
			status = "completed", -- 672
			progress = 1.0 -- 673
		} or { -- 675
			name = "Download", -- 675
			url = url, -- 675
			status = "failed", -- 675
			progress = 0.0 -- 676
		})) -- 671
	end)) -- 664
end -- 664
_module_0["downloadFile"] = downloadFile -- 664
local _anon_func_2 = function(file, require, workDir) -- 687
	if workDir == nil then -- 687
		workDir = Path:getPath(file) -- 687
	end -- 687
	Content:insertSearchPath(1, workDir) -- 688
	local scriptPath = Path(workDir, "Script") -- 689
	if Content:exist(scriptPath) then -- 690
		Content:insertSearchPath(1, scriptPath) -- 691
	end -- 690
	local result = require(file) -- 692
	if "function" == type(result) then -- 693
		result() -- 693
	end -- 693
	return nil -- 694
end -- 687
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 723
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 723
	label.alignment = "Left" -- 724
	label.textWidth = width - fontSize -- 725
	label.text = err -- 726
	return label -- 723
end -- 723
local enterEntryAsync -- 679
enterEntryAsync = function(entry) -- 679
	isInEntry = false -- 680
	App.idled = false -- 681
	emit(Profiler.EventName, "ClearLoader") -- 682
	currentEntry = entry -- 683
	local file, workDir = entry.fileName, entry.workDir -- 684
	sleep() -- 685
	return xpcall(_anon_func_2, function(msg) -- 694
		local err = debug.traceback(msg) -- 696
		Log("Error", err) -- 697
		allClear() -- 698
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 699
		local viewWidth, viewHeight -- 700
		do -- 700
			local _obj_0 = View.size -- 700
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 700
		end -- 700
		local width, height = viewWidth - 20, viewHeight - 20 -- 701
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 702
		Director.ui:addChild((function() -- 703
			local root = AlignNode() -- 703
			do -- 704
				local _obj_0 = App.bufferSize -- 704
				width, height = _obj_0.width, _obj_0.height -- 704
			end -- 704
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 705
			root:onAppChange(function(settingName) -- 706
				if settingName == "Size" then -- 706
					do -- 707
						local _obj_0 = App.bufferSize -- 707
						width, height = _obj_0.width, _obj_0.height -- 707
					end -- 707
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 708
				end -- 706
			end) -- 706
			root:addChild((function() -- 709
				local _with_0 = ScrollArea({ -- 710
					width = width, -- 710
					height = height, -- 711
					paddingX = 0, -- 712
					paddingY = 50, -- 713
					viewWidth = height, -- 714
					viewHeight = height -- 715
				}) -- 709
				root:onAlignLayout(function(w, h) -- 717
					_with_0.position = Vec2(w / 2, h / 2) -- 718
					w = w - 20 -- 719
					h = h - 20 -- 720
					_with_0.view.children.first.textWidth = w - fontSize -- 721
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 722
				end) -- 717
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 723
				return _with_0 -- 709
			end)()) -- 709
			return root -- 703
		end)()) -- 703
		return err -- 727
	end, file, require, workDir) -- 686
end -- 679
_module_0["enterEntryAsync"] = enterEntryAsync -- 679
local enterDemoEntry -- 729
enterDemoEntry = function(entry) -- 729
	return thread(function() -- 729
		return enterEntryAsync(entry) -- 729
	end) -- 729
end -- 729
local reloadCurrentEntry -- 731
reloadCurrentEntry = function() -- 731
	if currentEntry then -- 732
		allClear() -- 733
		return enterDemoEntry(currentEntry) -- 734
	end -- 732
end -- 731
Director.clearColor = Color(0xff1a1a1a) -- 736
local extraOperations -- 738
do -- 738
	local isOSSLicenseExist = Content:exist("LICENSES") -- 739
	local ossLicenses = nil -- 740
	local ossLicenseOpen = false -- 741
	local failedSetFolder = false -- 742
	local statusFlags = { -- 743
		"NoResize", -- 743
		"NoMove", -- 743
		"NoCollapse", -- 743
		"AlwaysAutoResize", -- 743
		"NoSavedSettings" -- 743
	} -- 743
	extraOperations = function() -- 750
		local zh = useChinese -- 751
		if isDesktop then -- 752
			local alwaysOnTop = config.alwaysOnTop -- 753
			local changed -- 754
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 754
			if changed then -- 754
				App.alwaysOnTop = alwaysOnTop -- 755
				config.alwaysOnTop = alwaysOnTop -- 756
			end -- 754
		end -- 752
		local showPreview = config.showPreview -- 757
		do -- 758
			local changed -- 758
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 758
			if changed then -- 758
				config.showPreview = showPreview -- 759
				updateEntries() -- 760
				if not showPreview then -- 761
					thread(function() -- 762
						collectgarbage() -- 763
						return Cache:removeUnused("Texture") -- 764
					end) -- 762
				end -- 761
			end -- 758
		end -- 758
		do -- 765
			local themeColor = App.themeColor -- 766
			local writablePath = config.writablePath -- 767
			SeparatorText(zh and "工作目录" or "Workspace") -- 768
			PushTextWrapPos(400, function() -- 769
				return TextColored(themeColor, writablePath) -- 770
			end) -- 769
			if not isDesktop then -- 771
				goto skipSetting -- 771
			end -- 771
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 772
			if Button(zh and "改变目录" or "Set Folder") then -- 773
				App:openFileDialog(true, function(path) -- 774
					if path == "" then -- 775
						return -- 775
					end -- 775
					local relPath = Path:getRelative(Content.assetPath, path) -- 776
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 777
						return setWorkspace(path) -- 778
					else -- 780
						failedSetFolder = true -- 780
					end -- 777
				end) -- 774
			end -- 773
			if failedSetFolder then -- 781
				failedSetFolder = false -- 782
				OpenPopup(popupName) -- 783
			end -- 781
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 784
			BeginPopupModal(popupName, statusFlags, function() -- 785
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 786
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 787
					return CloseCurrentPopup() -- 788
				end -- 787
			end) -- 785
			SameLine() -- 789
			if Button(zh and "使用默认" or "Use Default") then -- 790
				setWorkspace(Content.appPath) -- 791
			end -- 790
			Separator() -- 792
			::skipSetting:: -- 793
		end -- 765
		if isOSSLicenseExist then -- 794
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 795
				if not ossLicenses then -- 796
					ossLicenses = { } -- 797
					local licenseText = Content:load("LICENSES") -- 798
					ossLicenseOpen = (licenseText ~= nil) -- 799
					if ossLicenseOpen then -- 799
						licenseText = licenseText:gsub("\r\n", "\n") -- 800
						for license in GSplit(licenseText, "\n--------\n", true) do -- 801
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 802
							if name then -- 802
								ossLicenses[#ossLicenses + 1] = { -- 803
									name, -- 803
									text -- 803
								} -- 803
							end -- 802
						end -- 801
					end -- 799
				else -- 805
					ossLicenseOpen = true -- 805
				end -- 796
			end -- 795
			if ossLicenseOpen then -- 806
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 807
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 808
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 809
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 810
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 813
						"NoSavedSettings" -- 813
					}, function() -- 814
						for _index_0 = 1, #ossLicenses do -- 814
							local _des_0 = ossLicenses[_index_0] -- 814
							local firstLine, text = _des_0[1], _des_0[2] -- 814
							local name, license = firstLine:match("(.+): (.+)") -- 815
							TextColored(themeColor, name) -- 816
							SameLine() -- 817
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 818
								return TextWrapped(text) -- 818
							end) -- 818
						end -- 814
					end) -- 810
				end) -- 810
			end -- 806
		end -- 794
		if not App.debugging then -- 820
			return -- 820
		end -- 820
		return TreeNode(zh and "开发操作" or "Development", function() -- 821
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 822
				OpenPopup("build") -- 822
			end -- 822
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 823
				return BeginPopup("build", function() -- 823
					if Selectable(zh and "编译" or "Compile") then -- 824
						doCompile(false) -- 824
					end -- 824
					Separator() -- 825
					if Selectable(zh and "压缩" or "Minify") then -- 826
						doCompile(true) -- 826
					end -- 826
					Separator() -- 827
					if Selectable(zh and "清理" or "Clean") then -- 828
						return doClean() -- 828
					end -- 828
				end) -- 823
			end) -- 823
			if isInEntry then -- 829
				if waitForWebStart then -- 830
					BeginDisabled(function() -- 831
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 831
					end) -- 831
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 832
					reloadDevEntry() -- 833
				end -- 830
			end -- 829
			do -- 834
				local changed -- 834
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 834
				if changed then -- 834
					View.scale = scaleContent and screenScale or 1 -- 835
				end -- 834
			end -- 834
			do -- 836
				local changed -- 836
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 836
				if changed then -- 836
					config.engineDev = engineDev -- 837
				end -- 836
			end -- 836
			if testingThread then -- 838
				return BeginDisabled(function() -- 839
					return Button(zh and "开始自动测试" or "Test automatically") -- 839
				end) -- 839
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 840
				testingThread = thread(function() -- 841
					local _ <close> = setmetatable({ }, { -- 842
						__close = function() -- 842
							allClear() -- 843
							testingThread = nil -- 844
							isInEntry = true -- 845
							currentEntry = nil -- 846
							return print("Testing done!") -- 847
						end -- 842
					}) -- 842
					for _, entry in ipairs(allEntries) do -- 848
						allClear() -- 849
						print("Start " .. tostring(entry.entryName)) -- 850
						enterDemoEntry(entry) -- 851
						sleep(2) -- 852
						print("Stop " .. tostring(entry.entryName)) -- 853
					end -- 848
				end) -- 841
			end -- 838
		end) -- 821
	end -- 750
end -- 738
local icon = Path("Script", "Dev", "icon_s.png") -- 855
local iconTex = nil -- 856
thread(function() -- 857
	if Cache:loadAsync(icon) then -- 857
		iconTex = Texture2D(icon) -- 857
	end -- 857
end) -- 857
local webStatus = nil -- 859
local urlClicked = nil -- 860
local descColor = Color(0xffa1a1a1) -- 861
local transparant = Color(0x0) -- 863
local windowFlags = { -- 864
	"NoTitleBar", -- 864
	"NoResize", -- 864
	"NoMove", -- 864
	"NoCollapse", -- 864
	"NoSavedSettings", -- 864
	"NoFocusOnAppearing", -- 864
	"NoBringToFrontOnFocus" -- 864
} -- 864
local statusFlags = { -- 873
	"NoTitleBar", -- 873
	"NoResize", -- 873
	"NoMove", -- 873
	"NoCollapse", -- 873
	"AlwaysAutoResize", -- 873
	"NoSavedSettings" -- 873
} -- 873
local displayWindowFlags = { -- 881
	"NoDecoration", -- 881
	"NoSavedSettings", -- 881
	"NoNav", -- 881
	"NoMove", -- 881
	"NoScrollWithMouse", -- 881
	"AlwaysAutoResize", -- 881
	"NoFocusOnAppearing" -- 881
} -- 881
local initFooter = true -- 890
local _anon_func_4 = function(allEntries, currentIndex) -- 927
	if currentIndex > 1 then -- 927
		return allEntries[currentIndex - 1] -- 928
	else -- 930
		return allEntries[#allEntries] -- 930
	end -- 927
end -- 927
local _anon_func_5 = function(allEntries, currentIndex) -- 934
	if currentIndex < #allEntries then -- 934
		return allEntries[currentIndex + 1] -- 935
	else -- 937
		return allEntries[1] -- 937
	end -- 934
end -- 934
footerWindow = threadLoop(function() -- 891
	local zh = useChinese -- 892
	if HttpServer.wsConnectionCount > 0 then -- 893
		return -- 894
	end -- 893
	if Keyboard:isKeyDown("Escape") then -- 895
		allClear() -- 896
		App.devMode = false -- 897
		App:shutdown() -- 898
	end -- 895
	do -- 899
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 900
		if ctrl and Keyboard:isKeyDown("Q") then -- 901
			stop() -- 902
		end -- 901
		if ctrl and Keyboard:isKeyDown("Z") then -- 903
			reloadCurrentEntry() -- 904
		end -- 903
		if ctrl and Keyboard:isKeyDown(",") then -- 905
			if showFooter then -- 906
				showStats = not showStats -- 906
			else -- 906
				showStats = true -- 906
			end -- 906
			showFooter = true -- 907
			config.showFooter = showFooter -- 908
			config.showStats = showStats -- 909
		end -- 905
		if ctrl and Keyboard:isKeyDown(".") then -- 910
			if showFooter then -- 911
				showConsole = not showConsole -- 911
			else -- 911
				showConsole = true -- 911
			end -- 911
			showFooter = true -- 912
			config.showFooter = showFooter -- 913
			config.showConsole = showConsole -- 914
		end -- 910
		if ctrl and Keyboard:isKeyDown("/") then -- 915
			showFooter = not showFooter -- 916
			config.showFooter = showFooter -- 917
		end -- 915
		local left = ctrl and Keyboard:isKeyDown("Left") -- 918
		local right = ctrl and Keyboard:isKeyDown("Right") -- 919
		local currentIndex = nil -- 920
		for i, entry in ipairs(allEntries) do -- 921
			if currentEntry == entry then -- 922
				currentIndex = i -- 923
			end -- 922
		end -- 921
		if left then -- 924
			allClear() -- 925
			if currentIndex == nil then -- 926
				currentIndex = #allEntries + 1 -- 926
			end -- 926
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 927
		end -- 924
		if right then -- 931
			allClear() -- 932
			if currentIndex == nil then -- 933
				currentIndex = 0 -- 933
			end -- 933
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 934
		end -- 931
	end -- 899
	if not showEntry then -- 938
		return -- 938
	end -- 938
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 940
		reloadDevEntry() -- 944
	end -- 940
	if initFooter then -- 945
		initFooter = false -- 946
	end -- 945
	local width, height -- 948
	do -- 948
		local _obj_0 = App.visualSize -- 948
		width, height = _obj_0.width, _obj_0.height -- 948
	end -- 948
	if isInEntry or showFooter then -- 949
		SetNextWindowSize(Vec2(width, 50)) -- 950
		SetNextWindowPos(Vec2(0, height - 50)) -- 951
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 952
			return PushStyleVar("WindowRounding", 0, function() -- 953
				return Begin("Footer", windowFlags, function() -- 954
					Separator() -- 955
					if iconTex then -- 956
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 957
							showStats = not showStats -- 958
							config.showStats = showStats -- 959
						end -- 957
						SameLine() -- 960
						if Button(">_", Vec2(30, 30)) then -- 961
							showConsole = not showConsole -- 962
							config.showConsole = showConsole -- 963
						end -- 961
					end -- 956
					if isInEntry and config.updateNotification then -- 964
						SameLine() -- 965
						if ImGui.Button(zh and "更新可用" or "Update") then -- 966
							allClear() -- 967
							config.updateNotification = false -- 968
							enterDemoEntry({ -- 970
								entryName = "SelfUpdater", -- 970
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 971
							}) -- 969
						end -- 966
					end -- 964
					if not isInEntry then -- 972
						SameLine() -- 973
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 974
						local currentIndex = nil -- 975
						for i, entry in ipairs(allEntries) do -- 976
							if currentEntry == entry then -- 977
								currentIndex = i -- 978
							end -- 977
						end -- 976
						if currentIndex then -- 979
							if currentIndex > 1 then -- 980
								SameLine() -- 981
								if Button("<<", Vec2(30, 30)) then -- 982
									allClear() -- 983
									enterDemoEntry(allEntries[currentIndex - 1]) -- 984
								end -- 982
							end -- 980
							if currentIndex < #allEntries then -- 985
								SameLine() -- 986
								if Button(">>", Vec2(30, 30)) then -- 987
									allClear() -- 988
									enterDemoEntry(allEntries[currentIndex + 1]) -- 989
								end -- 987
							end -- 985
						end -- 979
						SameLine() -- 990
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 991
							reloadCurrentEntry() -- 992
						end -- 991
						if back then -- 993
							allClear() -- 994
							isInEntry = true -- 995
							currentEntry = nil -- 996
						end -- 993
					end -- 972
				end) -- 954
			end) -- 953
		end) -- 952
	end -- 949
	local showWebIDE = isInEntry -- 998
	if config.updateNotification then -- 999
		if width < 460 then -- 1000
			showWebIDE = false -- 1001
		end -- 1000
	else -- 1003
		if width < 360 then -- 1003
			showWebIDE = false -- 1004
		end -- 1003
	end -- 999
	if showWebIDE then -- 1005
		SetNextWindowBgAlpha(0.0) -- 1006
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1007
		Begin("Web IDE", displayWindowFlags, function() -- 1008
			do -- 1009
				local url -- 1009
				if webStatus ~= nil then -- 1009
					url = webStatus.url -- 1009
				end -- 1009
				if url then -- 1009
					if isDesktop and not config.fullScreen then -- 1010
						if urlClicked then -- 1011
							BeginDisabled(function() -- 1012
								return Button(url) -- 1012
							end) -- 1012
						elseif Button(url) then -- 1013
							urlClicked = once(function() -- 1014
								return sleep(5) -- 1014
							end) -- 1014
							App:openURL("http://localhost:8866") -- 1015
						end -- 1011
					else -- 1017
						TextColored(descColor, url) -- 1017
					end -- 1010
				else -- 1019
					TextColored(descColor, zh and '不可用' or 'not available') -- 1019
				end -- 1009
			end -- 1009
			SameLine() -- 1020
			TextDisabled('(?)') -- 1021
			if IsItemHovered() then -- 1022
				return BeginTooltip(function() -- 1023
					return PushTextWrapPos(280, function() -- 1024
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 1025
					end) -- 1024
				end) -- 1023
			end -- 1022
		end) -- 1008
	end -- 1005
	if not isInEntry then -- 1027
		SetNextWindowSize(Vec2(50, 50)) -- 1028
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1029
		PushStyleColor("WindowBg", transparant, function() -- 1030
			return Begin("Show", displayWindowFlags, function() -- 1030
				if width >= 370 then -- 1031
					local changed -- 1032
					changed, showFooter = Checkbox("##dev", showFooter) -- 1032
					if changed then -- 1032
						config.showFooter = showFooter -- 1033
					end -- 1032
				end -- 1031
			end) -- 1030
		end) -- 1030
	end -- 1027
	if isInEntry or showFooter then -- 1035
		if showStats then -- 1036
			PushStyleVar("WindowRounding", 0, function() -- 1037
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1038
				SetNextWindowSize(Vec2(0, height - 50)) -- 1039
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1040
				config.showStats = showStats -- 1041
			end) -- 1037
		end -- 1036
		if showConsole then -- 1042
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1043
			return PushStyleVar("WindowRounding", 6, function() -- 1044
				return ShowConsole() -- 1045
			end) -- 1044
		end -- 1042
	end -- 1035
end) -- 891
local MaxWidth <const> = 960 -- 1047
local toolOpen = false -- 1049
local filterText = nil -- 1050
local anyEntryMatched = false -- 1051
local match -- 1052
match = function(name) -- 1052
	local res = not filterText or name:lower():match(filterText) -- 1053
	if res then -- 1054
		anyEntryMatched = true -- 1054
	end -- 1054
	return res -- 1055
end -- 1052
local sep -- 1057
sep = function() -- 1057
	return SeparatorText("") -- 1057
end -- 1057
local thinSep -- 1058
thinSep = function() -- 1058
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1058
end -- 1058
entryWindow = threadLoop(function() -- 1060
	if App.fpsLimited ~= config.fpsLimited then -- 1061
		config.fpsLimited = App.fpsLimited -- 1062
	end -- 1061
	if App.targetFPS ~= config.targetFPS then -- 1063
		config.targetFPS = App.targetFPS -- 1064
	end -- 1063
	if View.vsync ~= config.vsync then -- 1065
		config.vsync = View.vsync -- 1066
	end -- 1065
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1067
		config.fixedFPS = Director.scheduler.fixedFPS -- 1068
	end -- 1067
	if Director.profilerSending ~= config.webProfiler then -- 1069
		config.webProfiler = Director.profilerSending -- 1070
	end -- 1069
	if urlClicked then -- 1071
		local _, result = coroutine.resume(urlClicked) -- 1072
		if result then -- 1073
			coroutine.close(urlClicked) -- 1074
			urlClicked = nil -- 1075
		end -- 1073
	end -- 1071
	if not showEntry then -- 1076
		return -- 1076
	end -- 1076
	if not isInEntry then -- 1077
		return -- 1077
	end -- 1077
	local zh = useChinese -- 1078
	if HttpServer.wsConnectionCount > 0 then -- 1079
		local themeColor = App.themeColor -- 1080
		local width, height -- 1081
		do -- 1081
			local _obj_0 = App.visualSize -- 1081
			width, height = _obj_0.width, _obj_0.height -- 1081
		end -- 1081
		SetNextWindowBgAlpha(0.5) -- 1082
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1083
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1084
			Separator() -- 1085
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1086
			if iconTex then -- 1087
				Image(icon, Vec2(24, 24)) -- 1088
				SameLine() -- 1089
			end -- 1087
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1090
			TextColored(descColor, slogon) -- 1091
			return Separator() -- 1092
		end) -- 1084
		return -- 1093
	end -- 1079
	local themeColor = App.themeColor -- 1095
	local fullWidth, height -- 1096
	do -- 1096
		local _obj_0 = App.visualSize -- 1096
		fullWidth, height = _obj_0.width, _obj_0.height -- 1096
	end -- 1096
	local width = math.min(MaxWidth, fullWidth) -- 1097
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1098
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1099
	SetNextWindowPos(Vec2.zero) -- 1100
	SetNextWindowBgAlpha(0) -- 1101
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1102
	do -- 1103
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1104
			return Begin("Dora Dev", windowFlags, function() -- 1105
				Dummy(Vec2(fullWidth - 20, 0)) -- 1106
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1107
				if fullWidth >= 400 then -- 1108
					SameLine() -- 1109
					Dummy(Vec2(fullWidth - 400, 0)) -- 1110
					SameLine() -- 1111
					SetNextItemWidth(zh and -95 or -140) -- 1112
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1113
						"AutoSelectAll" -- 1113
					}) then -- 1113
						config.filter = filterBuf.text -- 1114
					end -- 1113
					SameLine() -- 1115
					if Button(zh and '下载' or 'Download') then -- 1116
						allClear() -- 1117
						enterDemoEntry({ -- 1119
							entryName = "ResourceDownloader", -- 1119
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1120
						}) -- 1118
					end -- 1116
				end -- 1108
				Separator() -- 1121
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1122
			end) -- 1105
		end) -- 1104
	end -- 1103
	anyEntryMatched = false -- 1124
	SetNextWindowPos(Vec2(0, 50)) -- 1125
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1126
	do -- 1127
		return PushStyleColor("WindowBg", transparant, function() -- 1128
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1129
				return PushStyleVar("Alpha", 1, function() -- 1130
					return Begin("Content", windowFlags, function() -- 1131
						local DemoViewWidth <const> = 220 -- 1132
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1133
						if filterText then -- 1134
							filterText = filterText:lower() -- 1134
						end -- 1134
						if #gamesInDev > 0 then -- 1135
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1136
							Columns(columns, false) -- 1137
							local realViewWidth = GetColumnWidth() - 50 -- 1138
							for _index_0 = 1, #gamesInDev do -- 1139
								local game = gamesInDev[_index_0] -- 1139
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1140
								local displayName -- 1149
								if repo then -- 1149
									if zh then -- 1150
										displayName = repo.title.zh -- 1150
									else -- 1150
										displayName = repo.title.en -- 1150
									end -- 1150
								end -- 1149
								if displayName == nil then -- 1151
									displayName = gameName -- 1151
								end -- 1151
								if match(displayName) then -- 1152
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1153
									SameLine() -- 1154
									TextWrapped(displayName) -- 1155
									if columns > 1 then -- 1156
										if bannerFile then -- 1157
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1158
											local displayWidth <const> = realViewWidth -- 1159
											texHeight = displayWidth * texHeight / texWidth -- 1160
											texWidth = displayWidth -- 1161
											Dummy(Vec2.zero) -- 1162
											SameLine() -- 1163
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1164
										end -- 1157
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1165
											enterDemoEntry(game) -- 1166
										end -- 1165
									else -- 1168
										if bannerFile then -- 1168
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1169
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1170
											local sizing = 0.8 -- 1171
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1172
											texWidth = displayWidth * sizing -- 1173
											if texWidth > 500 then -- 1174
												sizing = 0.6 -- 1175
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1176
												texWidth = displayWidth * sizing -- 1177
											end -- 1174
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1178
											Dummy(Vec2(padding, 0)) -- 1179
											SameLine() -- 1180
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1181
										end -- 1168
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1182
											enterDemoEntry(game) -- 1183
										end -- 1182
									end -- 1156
									if #tests == 0 and #examples == 0 then -- 1184
										thinSep() -- 1185
									end -- 1184
									NextColumn() -- 1186
								end -- 1152
								local showSep = false -- 1187
								if #examples > 0 then -- 1188
									local showExample = false -- 1189
									do -- 1190
										local _accum_0 -- 1190
										for _index_1 = 1, #examples do -- 1190
											local _des_0 = examples[_index_1] -- 1190
											local entryName = _des_0.entryName -- 1190
											if match(entryName) then -- 1191
												_accum_0 = true -- 1191
												break -- 1191
											end -- 1191
										end -- 1190
										showExample = _accum_0 -- 1190
									end -- 1190
									if showExample then -- 1192
										showSep = true -- 1193
										Columns(1, false) -- 1194
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1195
										SameLine() -- 1196
										local opened -- 1197
										if (filterText ~= nil) then -- 1197
											opened = showExample -- 1197
										else -- 1197
											opened = false -- 1197
										end -- 1197
										if game.exampleOpen == nil then -- 1198
											game.exampleOpen = opened -- 1198
										end -- 1198
										SetNextItemOpen(game.exampleOpen) -- 1199
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1200
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1201
												Columns(maxColumns, false) -- 1202
												for _index_1 = 1, #examples do -- 1203
													local example = examples[_index_1] -- 1203
													local entryName = example.entryName -- 1204
													if not match(entryName) then -- 1205
														goto _continue_0 -- 1205
													end -- 1205
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1206
														if Button(entryName, Vec2(-1, 40)) then -- 1207
															enterDemoEntry(example) -- 1208
														end -- 1207
														return NextColumn() -- 1209
													end) -- 1206
													opened = true -- 1210
													::_continue_0:: -- 1204
												end -- 1203
											end) -- 1201
										end) -- 1200
										game.exampleOpen = opened -- 1211
									end -- 1192
								end -- 1188
								if #tests > 0 then -- 1212
									local showTest = false -- 1213
									do -- 1214
										local _accum_0 -- 1214
										for _index_1 = 1, #tests do -- 1214
											local _des_0 = tests[_index_1] -- 1214
											local entryName = _des_0.entryName -- 1214
											if match(entryName) then -- 1215
												_accum_0 = true -- 1215
												break -- 1215
											end -- 1215
										end -- 1214
										showTest = _accum_0 -- 1214
									end -- 1214
									if showTest then -- 1216
										showSep = true -- 1217
										Columns(1, false) -- 1218
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1219
										SameLine() -- 1220
										local opened -- 1221
										if (filterText ~= nil) then -- 1221
											opened = showTest -- 1221
										else -- 1221
											opened = false -- 1221
										end -- 1221
										if game.testOpen == nil then -- 1222
											game.testOpen = opened -- 1222
										end -- 1222
										SetNextItemOpen(game.testOpen) -- 1223
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1224
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1225
												Columns(maxColumns, false) -- 1226
												for _index_1 = 1, #tests do -- 1227
													local test = tests[_index_1] -- 1227
													local entryName = test.entryName -- 1228
													if not match(entryName) then -- 1229
														goto _continue_0 -- 1229
													end -- 1229
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1230
														if Button(entryName, Vec2(-1, 40)) then -- 1231
															enterDemoEntry(test) -- 1232
														end -- 1231
														return NextColumn() -- 1233
													end) -- 1230
													opened = true -- 1234
													::_continue_0:: -- 1228
												end -- 1227
											end) -- 1225
										end) -- 1224
										game.testOpen = opened -- 1235
									end -- 1216
								end -- 1212
								if showSep then -- 1236
									Columns(1, false) -- 1237
									thinSep() -- 1238
									Columns(columns, false) -- 1239
								end -- 1236
							end -- 1139
						end -- 1135
						if #doraTools > 0 then -- 1240
							local showTool = false -- 1241
							do -- 1242
								local _accum_0 -- 1242
								for _index_0 = 1, #doraTools do -- 1242
									local _des_0 = doraTools[_index_0] -- 1242
									local entryName = _des_0.entryName -- 1242
									if match(entryName) then -- 1243
										_accum_0 = true -- 1243
										break -- 1243
									end -- 1243
								end -- 1242
								showTool = _accum_0 -- 1242
							end -- 1242
							if not showTool then -- 1244
								goto endEntry -- 1244
							end -- 1244
							Columns(1, false) -- 1245
							TextColored(themeColor, "Dora SSR:") -- 1246
							SameLine() -- 1247
							Text(zh and "开发支持" or "Development Support") -- 1248
							Separator() -- 1249
							if #doraTools > 0 then -- 1250
								local opened -- 1251
								if (filterText ~= nil) then -- 1251
									opened = showTool -- 1251
								else -- 1251
									opened = false -- 1251
								end -- 1251
								SetNextItemOpen(toolOpen) -- 1252
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1253
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1254
										Columns(maxColumns, false) -- 1255
										for _index_0 = 1, #doraTools do -- 1256
											local example = doraTools[_index_0] -- 1256
											local entryName = example.entryName -- 1257
											if not match(entryName) then -- 1258
												goto _continue_0 -- 1258
											end -- 1258
											if Button(entryName, Vec2(-1, 40)) then -- 1259
												enterDemoEntry(example) -- 1260
											end -- 1259
											NextColumn() -- 1261
											::_continue_0:: -- 1257
										end -- 1256
										Columns(1, false) -- 1262
										opened = true -- 1263
									end) -- 1254
								end) -- 1253
								toolOpen = opened -- 1264
							end -- 1250
						end -- 1240
						::endEntry:: -- 1265
						if not anyEntryMatched then -- 1266
							SetNextWindowBgAlpha(0) -- 1267
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1268
							Begin("Entries Not Found", displayWindowFlags, function() -- 1269
								Separator() -- 1270
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1271
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1272
								return Separator() -- 1273
							end) -- 1269
						end -- 1266
						Columns(1, false) -- 1274
						Dummy(Vec2(100, 80)) -- 1275
						return ScrollWhenDraggingOnVoid() -- 1276
					end) -- 1131
				end) -- 1130
			end) -- 1129
		end) -- 1128
	end -- 1127
end) -- 1060
webStatus = require("Script.Dev.WebServer") -- 1278
return _module_0 -- 1
