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
local IsItemHovered <const> = IsItemHovered -- 11
local PushStyleColor <const> = PushStyleColor -- 11
local BeginTooltip <const> = BeginTooltip -- 11
local Text <const> = Text -- 11
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
getProjectEntries = function(path, noPreview) -- 257
	if noPreview == nil then -- 257
		noPreview = false -- 257
	end -- 257
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
						if noPreview then -- 297
							_accum_0 = nil -- 297
							break -- 297
						end -- 297
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
					until true -- 296
					bannerFile = _accum_0 -- 296
				end -- 296
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
			end -- 262
			::_continue_1:: -- 262
		end -- 261
		::_continue_0:: -- 260
	end -- 259
	table.sort(entries, function(a, b) -- 316
		return a.entryName < b.entryName -- 316
	end) -- 316
	return entries -- 317
end -- 257
_module_0["getProjectEntries"] = getProjectEntries -- 257
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
		local fileName = _des_0.fileName -- 354
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 355
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
			local yueCodes -- 411
			if not success then -- 412
				yueCodes = Content:load(input) -- 413
				if yueCodes then -- 413
					local CheckTIC80Code -- 414
					do -- 414
						local _obj_0 = require("Utils") -- 414
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 414
					end -- 414
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 415
					if isTIC80 then -- 416
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 417
					end -- 416
				end -- 413
			end -- 412
			if success then -- 418
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 419
			else -- 421
				if yueCodes then -- 421
					local globalErrors = { } -- 422
					for _index_1 = 1, #result do -- 423
						local _des_1 = result[_index_1] -- 423
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 423
						local countLine = 1 -- 424
						local code = "" -- 425
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 426
							if countLine == line then -- 427
								code = lineCode -- 428
								break -- 429
							end -- 427
							countLine = countLine + 1 -- 430
						end -- 426
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 431
					end -- 423
					if #globalErrors > 0 then -- 432
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 432
					end -- 432
				else -- 434
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 434
				end -- 421
				if #errors == 0 then -- 435
					return codes -- 435
				end -- 435
			end -- 418
		end, function(success) -- 406
			if success then -- 436
				print("Yue compiled: " .. tostring(filename)) -- 436
			end -- 436
			fileCount = fileCount + 1 -- 437
		end) -- 406
	end -- 404
	thread(function() -- 439
		for _index_0 = 1, #xmlFiles do -- 440
			local _des_0 = xmlFiles[_index_0] -- 440
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 440
			local filename -- 441
			if gamePath then -- 441
				filename = Path(gamePath, file) -- 441
			else -- 441
				filename = file -- 441
			end -- 441
			local sourceCodes = Content:loadAsync(input) -- 442
			local codes, err = xml.tolua(sourceCodes) -- 443
			if not codes then -- 444
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 445
			else -- 447
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 447
				print("Xml compiled: " .. tostring(filename)) -- 448
			end -- 444
			fileCount = fileCount + 1 -- 449
		end -- 440
	end) -- 439
	thread(function() -- 451
		for _index_0 = 1, #tlFiles do -- 452
			local _des_0 = tlFiles[_index_0] -- 452
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 452
			local filename -- 453
			if gamePath then -- 453
				filename = Path(gamePath, file) -- 453
			else -- 453
				filename = file -- 453
			end -- 453
			local sourceCodes = Content:loadAsync(input) -- 454
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 455
			if not codes then -- 456
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 457
			else -- 459
				Content:saveAsync(output, codes) -- 459
				print("Teal compiled: " .. tostring(filename)) -- 460
			end -- 456
			fileCount = fileCount + 1 -- 461
		end -- 452
	end) -- 451
	return thread(function() -- 463
		wait(function() -- 464
			return fileCount == totalFiles -- 464
		end) -- 464
		if minify then -- 465
			local _list_0 = { -- 466
				yueFiles, -- 466
				xmlFiles, -- 466
				tlFiles -- 466
			} -- 466
			for _index_0 = 1, #_list_0 do -- 466
				local files = _list_0[_index_0] -- 466
				for _index_1 = 1, #files do -- 466
					local file = files[_index_1] -- 466
					local output = Path:replaceExt(file[3], "lua") -- 467
					luaFiles[#luaFiles + 1] = { -- 469
						Path:replaceExt(file[1], "lua"), -- 469
						output, -- 470
						output -- 471
					} -- 468
				end -- 466
			end -- 466
			local FormatMini -- 473
			do -- 473
				local _obj_0 = require("luaminify") -- 473
				FormatMini = _obj_0.FormatMini -- 473
			end -- 473
			for _index_0 = 1, #luaFiles do -- 474
				local _des_0 = luaFiles[_index_0] -- 474
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 474
				if Content:exist(input) then -- 475
					local sourceCodes = Content:loadAsync(input) -- 476
					local res, err = FormatMini(sourceCodes) -- 477
					if res then -- 478
						Content:saveAsync(output, res) -- 479
						print("Minify: " .. tostring(file)) -- 480
					else -- 482
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 482
					end -- 478
				else -- 484
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 484
				end -- 475
			end -- 474
			package.loaded["luaminify.FormatMini"] = nil -- 485
			package.loaded["luaminify.ParseLua"] = nil -- 486
			package.loaded["luaminify.Scope"] = nil -- 487
			package.loaded["luaminify.Util"] = nil -- 488
		end -- 465
		local errorMessage = table.concat(errors, "\n") -- 489
		if errorMessage ~= "" then -- 490
			print(errorMessage) -- 490
		end -- 490
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 491
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 492
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 493
		Content:clearPathCache() -- 494
		teal.clear() -- 495
		yue.clear() -- 496
		building = false -- 497
	end) -- 463
end -- 338
local doClean -- 499
doClean = function() -- 499
	if building then -- 500
		return -- 500
	end -- 500
	local writablePath = Content.writablePath -- 501
	local targetDir = Path(writablePath, ".build") -- 502
	Content:clearPathCache() -- 503
	if Content:remove(targetDir) then -- 504
		return print("Cleaned: " .. tostring(targetDir)) -- 505
	end -- 504
end -- 499
local screenScale = 2.0 -- 507
local scaleContent = false -- 508
local isInEntry = true -- 509
local currentEntry = nil -- 510
local footerWindow = nil -- 512
local entryWindow = nil -- 513
local testingThread = nil -- 514
local setupEventHandlers = nil -- 516
local allClear -- 518
allClear = function() -- 518
	for _index_0 = 1, #Routine do -- 519
		local routine = Routine[_index_0] -- 519
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 521
			goto _continue_0 -- 522
		else -- 524
			Routine:remove(routine) -- 524
		end -- 520
		::_continue_0:: -- 520
	end -- 519
	for _index_0 = 1, #moduleCache do -- 525
		local module = moduleCache[_index_0] -- 525
		package.loaded[module] = nil -- 526
	end -- 525
	moduleCache = { } -- 527
	Director:cleanup() -- 528
	Entity:clear() -- 529
	Platformer.Data:clear() -- 530
	Platformer.UnitAction:clear() -- 531
	Audio:stopAll(0.2) -- 532
	Struct:clear() -- 533
	View.postEffect = nil -- 534
	View.scale = scaleContent and screenScale or 1 -- 535
	Director.clearColor = Color(0xff1a1a1a) -- 536
	teal.clear() -- 537
	yue.clear() -- 538
	for _, item in pairs(ubox()) do -- 539
		local node = tolua.cast(item, "Node") -- 540
		if node then -- 540
			node:cleanup() -- 540
		end -- 540
	end -- 539
	collectgarbage() -- 541
	collectgarbage() -- 542
	Wasm:clear() -- 543
	thread(function() -- 544
		sleep() -- 545
		return Cache:removeUnused() -- 546
	end) -- 544
	setupEventHandlers() -- 547
	Content.searchPaths = searchPaths -- 548
	App.idled = true -- 549
end -- 518
_module_0["allClear"] = allClear -- 518
local clearTempFiles -- 551
clearTempFiles = function() -- 551
	local writablePath = Content.writablePath -- 552
	Content:remove(Path(writablePath, ".upload")) -- 553
	return Content:remove(Path(writablePath, ".download")) -- 554
end -- 551
local waitForWebStart = true -- 556
thread(function() -- 557
	sleep(2) -- 558
	waitForWebStart = false -- 559
end) -- 557
local reloadDevEntry -- 561
reloadDevEntry = function() -- 561
	return thread(function() -- 561
		waitForWebStart = true -- 562
		doClean() -- 563
		allClear() -- 564
		_G.require = oldRequire -- 565
		Dora.require = oldRequire -- 566
		package.loaded["Script.Dev.Entry"] = nil -- 567
		return Director.systemScheduler:schedule(function() -- 568
			Routine:clear() -- 569
			oldRequire("Script.Dev.Entry") -- 570
			return true -- 571
		end) -- 568
	end) -- 561
end -- 561
local setWorkspace -- 573
setWorkspace = function(path) -- 573
	clearTempFiles() -- 574
	Content.writablePath = path -- 575
	config.writablePath = Content.writablePath -- 576
	return thread(function() -- 577
		sleep() -- 578
		return reloadDevEntry() -- 579
	end) -- 577
end -- 573
_module_0["setWorkspace"] = setWorkspace -- 573
local quit = false -- 581
local activeSearchId = 0 -- 583
local handleSearchFiles -- 585
handleSearchFiles = function(payload) -- 585
	if not payload then -- 586
		return -- 586
	end -- 586
	local id = payload.id -- 587
	if id == nil then -- 588
		return -- 588
	end -- 588
	activeSearchId = id -- 589
	local path = payload.path or "" -- 590
	local exts = payload.exts or { } -- 591
	local extensionLevels = payload.extensionLevels or { } -- 592
	local excludes = payload.excludes or { } -- 593
	local pattern = payload.pattern or "" -- 594
	if pattern == "" then -- 595
		return -- 595
	end -- 595
	local useRegex = payload.useRegex == true -- 596
	local caseSensitive = payload.caseSensitive == true -- 597
	local includeContent = payload.includeContent ~= false -- 598
	local contentWindow = payload.contentWindow or 0 -- 599
	return Director.systemScheduler:schedule(once(function() -- 600
		local stopped = false -- 601
		Content:searchFilesAsync(path, exts, extensionLevels, excludes, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 602
			if activeSearchId ~= id then -- 603
				stopped = true -- 604
				return true -- 605
			end -- 603
			emit("AppWS", "Send", json.encode({ -- 607
				name = "SearchFilesResult", -- 607
				id = id, -- 607
				result = result -- 607
			})) -- 606
			return false -- 609
		end) -- 602
		return emit("AppWS", "Send", json.encode({ -- 611
			name = "SearchFilesDone", -- 611
			id = id, -- 611
			stopped = stopped -- 611
		})) -- 610
	end)) -- 600
end -- 585
local stop -- 614
stop = function() -- 614
	if isInEntry then -- 615
		return false -- 615
	end -- 615
	allClear() -- 616
	isInEntry = true -- 617
	currentEntry = nil -- 618
	return true -- 619
end -- 614
_module_0["stop"] = stop -- 614
local _anon_func_1 = function(_with_0) -- 638
	local _val_0 = App.platform -- 638
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 638
end -- 638
setupEventHandlers = function() -- 621
	local _with_0 = Director.postNode -- 622
	_with_0:onAppEvent(function(eventType) -- 623
		if "Quit" == eventType then -- 624
			quit = true -- 625
			allClear() -- 626
			return clearTempFiles() -- 627
		elseif "Shutdown" == eventType then -- 628
			return stop() -- 629
		end -- 623
	end) -- 623
	_with_0:onAppChange(function(settingName) -- 630
		if "Theme" == settingName then -- 631
			config.themeColor = App.themeColor:toARGB() -- 632
		elseif "Locale" == settingName then -- 633
			config.locale = App.locale -- 634
			updateLocale() -- 635
			return teal.clear(true) -- 636
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 637
			if _anon_func_1(_with_0) then -- 638
				if "FullScreen" == settingName then -- 640
					config.fullScreen = App.fullScreen -- 640
				elseif "Position" == settingName then -- 641
					local _obj_0 = App.winPosition -- 641
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 641
				elseif "Size" == settingName then -- 642
					local width, height -- 643
					do -- 643
						local _obj_0 = App.winSize -- 643
						width, height = _obj_0.width, _obj_0.height -- 643
					end -- 643
					config.winWidth = width -- 644
					config.winHeight = height -- 645
				end -- 639
			end -- 638
		end -- 630
	end) -- 630
	_with_0:onAppWS(function(eventType, msg) -- 646
		if eventType == "Close" then -- 647
			if HttpServer.wsConnectionCount == 0 then -- 648
				updateEntries() -- 649
			end -- 648
			return -- 650
		end -- 647
		if not (eventType == "Receive") then -- 651
			return -- 651
		end -- 651
		local data = json.decode(msg) -- 652
		if not data then -- 653
			return -- 653
		end -- 653
		local _exp_0 = data.name -- 654
		if "SearchFiles" == _exp_0 then -- 655
			return handleSearchFiles(data) -- 656
		elseif "SearchFilesStop" == _exp_0 then -- 657
			if data.id == nil or data.id == activeSearchId then -- 658
				activeSearchId = 0 -- 659
			end -- 658
		end -- 654
	end) -- 646
	_with_0:slot("UpdateEntries", function() -- 660
		return updateEntries() -- 660
	end) -- 660
	return _with_0 -- 622
end -- 621
setupEventHandlers() -- 662
clearTempFiles() -- 663
local downloadFile -- 665
downloadFile = function(url, target) -- 665
	return Director.systemScheduler:schedule(once(function() -- 665
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 666
			if quit then -- 667
				return true -- 667
			end -- 667
			emit("AppWS", "Send", json.encode({ -- 669
				name = "Download", -- 669
				url = url, -- 669
				status = "downloading", -- 669
				progress = current / total -- 670
			})) -- 668
			return false -- 666
		end) -- 666
		return emit("AppWS", "Send", json.encode(success and { -- 673
			name = "Download", -- 673
			url = url, -- 673
			status = "completed", -- 673
			progress = 1.0 -- 674
		} or { -- 676
			name = "Download", -- 676
			url = url, -- 676
			status = "failed", -- 676
			progress = 0.0 -- 677
		})) -- 672
	end)) -- 665
end -- 665
_module_0["downloadFile"] = downloadFile -- 665
local _anon_func_2 = function(file, require, workDir) -- 688
	if workDir == nil then -- 688
		workDir = Path:getPath(file) -- 688
	end -- 688
	Content:insertSearchPath(1, workDir) -- 689
	local scriptPath = Path(workDir, "Script") -- 690
	if Content:exist(scriptPath) then -- 691
		Content:insertSearchPath(1, scriptPath) -- 692
	end -- 691
	local result = require(file) -- 693
	if "function" == type(result) then -- 694
		result() -- 694
	end -- 694
	return nil -- 695
end -- 688
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 724
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 724
	label.alignment = "Left" -- 725
	label.textWidth = width - fontSize -- 726
	label.text = err -- 727
	return label -- 724
end -- 724
local enterEntryAsync -- 680
enterEntryAsync = function(entry) -- 680
	isInEntry = false -- 681
	App.idled = false -- 682
	emit(Profiler.EventName, "ClearLoader") -- 683
	currentEntry = entry -- 684
	local file, workDir = entry.fileName, entry.workDir -- 685
	sleep() -- 686
	return xpcall(_anon_func_2, function(msg) -- 695
		local err = debug.traceback(msg) -- 697
		Log("Error", err) -- 698
		allClear() -- 699
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 700
		local viewWidth, viewHeight -- 701
		do -- 701
			local _obj_0 = View.size -- 701
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 701
		end -- 701
		local width, height = viewWidth - 20, viewHeight - 20 -- 702
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 703
		Director.ui:addChild((function() -- 704
			local root = AlignNode() -- 704
			do -- 705
				local _obj_0 = App.bufferSize -- 705
				width, height = _obj_0.width, _obj_0.height -- 705
			end -- 705
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 706
			root:onAppChange(function(settingName) -- 707
				if settingName == "Size" then -- 707
					do -- 708
						local _obj_0 = App.bufferSize -- 708
						width, height = _obj_0.width, _obj_0.height -- 708
					end -- 708
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 709
				end -- 707
			end) -- 707
			root:addChild((function() -- 710
				local _with_0 = ScrollArea({ -- 711
					width = width, -- 711
					height = height, -- 712
					paddingX = 0, -- 713
					paddingY = 50, -- 714
					viewWidth = height, -- 715
					viewHeight = height -- 716
				}) -- 710
				root:onAlignLayout(function(w, h) -- 718
					_with_0.position = Vec2(w / 2, h / 2) -- 719
					w = w - 20 -- 720
					h = h - 20 -- 721
					_with_0.view.children.first.textWidth = w - fontSize -- 722
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 723
				end) -- 718
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 724
				return _with_0 -- 710
			end)()) -- 710
			return root -- 704
		end)()) -- 704
		return err -- 728
	end, file, require, workDir) -- 687
end -- 680
_module_0["enterEntryAsync"] = enterEntryAsync -- 680
local enterDemoEntry -- 730
enterDemoEntry = function(entry) -- 730
	return thread(function() -- 730
		return enterEntryAsync(entry) -- 730
	end) -- 730
end -- 730
local reloadCurrentEntry -- 732
reloadCurrentEntry = function() -- 732
	if currentEntry then -- 733
		allClear() -- 734
		return enterDemoEntry(currentEntry) -- 735
	end -- 733
end -- 732
Director.clearColor = Color(0xff1a1a1a) -- 737
local extraOperations -- 739
do -- 739
	local isOSSLicenseExist = Content:exist("LICENSES") -- 740
	local ossLicenses = nil -- 741
	local ossLicenseOpen = false -- 742
	local failedSetFolder = false -- 743
	local statusFlags = { -- 744
		"NoResize", -- 744
		"NoMove", -- 744
		"NoCollapse", -- 744
		"AlwaysAutoResize", -- 744
		"NoSavedSettings" -- 744
	} -- 744
	extraOperations = function() -- 751
		local zh = useChinese -- 752
		if isDesktop then -- 753
			local alwaysOnTop = config.alwaysOnTop -- 754
			local changed -- 755
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 755
			if changed then -- 755
				App.alwaysOnTop = alwaysOnTop -- 756
				config.alwaysOnTop = alwaysOnTop -- 757
			end -- 755
		end -- 753
		local showPreview = config.showPreview -- 758
		do -- 759
			local changed -- 759
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 759
			if changed then -- 759
				config.showPreview = showPreview -- 760
				updateEntries() -- 761
				if not showPreview then -- 762
					thread(function() -- 763
						collectgarbage() -- 764
						return Cache:removeUnused("Texture") -- 765
					end) -- 763
				end -- 762
			end -- 759
		end -- 759
		do -- 766
			local themeColor = App.themeColor -- 767
			local writablePath = config.writablePath -- 768
			SeparatorText(zh and "工作目录" or "Workspace") -- 769
			PushTextWrapPos(400, function() -- 770
				return TextColored(themeColor, writablePath) -- 771
			end) -- 770
			if not isDesktop then -- 772
				goto skipSetting -- 772
			end -- 772
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 773
			if Button(zh and "改变目录" or "Set Folder") then -- 774
				App:openFileDialog(true, function(path) -- 775
					if path == "" then -- 776
						return -- 776
					end -- 776
					local relPath = Path:getRelative(Content.assetPath, path) -- 777
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 778
						return setWorkspace(path) -- 779
					else -- 781
						failedSetFolder = true -- 781
					end -- 778
				end) -- 775
			end -- 774
			if failedSetFolder then -- 782
				failedSetFolder = false -- 783
				OpenPopup(popupName) -- 784
			end -- 782
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 785
			BeginPopupModal(popupName, statusFlags, function() -- 786
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 787
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 788
					return CloseCurrentPopup() -- 789
				end -- 788
			end) -- 786
			SameLine() -- 790
			if Button(zh and "使用默认" or "Use Default") then -- 791
				setWorkspace(Content.appPath) -- 792
			end -- 791
			Separator() -- 793
			::skipSetting:: -- 794
		end -- 766
		if isOSSLicenseExist then -- 795
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 796
				if not ossLicenses then -- 797
					ossLicenses = { } -- 798
					local licenseText = Content:load("LICENSES") -- 799
					ossLicenseOpen = (licenseText ~= nil) -- 800
					if ossLicenseOpen then -- 800
						licenseText = licenseText:gsub("\r\n", "\n") -- 801
						for license in GSplit(licenseText, "\n--------\n", true) do -- 802
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 803
							if name then -- 803
								ossLicenses[#ossLicenses + 1] = { -- 804
									name, -- 804
									text -- 804
								} -- 804
							end -- 803
						end -- 802
					end -- 800
				else -- 806
					ossLicenseOpen = true -- 806
				end -- 797
			end -- 796
			if ossLicenseOpen then -- 807
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 808
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 809
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 810
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 811
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 814
						"NoSavedSettings" -- 814
					}, function() -- 815
						for _index_0 = 1, #ossLicenses do -- 815
							local _des_0 = ossLicenses[_index_0] -- 815
							local firstLine, text = _des_0[1], _des_0[2] -- 815
							local name, license = firstLine:match("(.+): (.+)") -- 816
							TextColored(themeColor, name) -- 817
							SameLine() -- 818
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 819
								return TextWrapped(text) -- 819
							end) -- 819
						end -- 815
					end) -- 811
				end) -- 811
			end -- 807
		end -- 795
		if not App.debugging then -- 821
			return -- 821
		end -- 821
		return TreeNode(zh and "开发操作" or "Development", function() -- 822
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 823
				OpenPopup("build") -- 823
			end -- 823
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 824
				return BeginPopup("build", function() -- 824
					if Selectable(zh and "编译" or "Compile") then -- 825
						doCompile(false) -- 825
					end -- 825
					Separator() -- 826
					if Selectable(zh and "压缩" or "Minify") then -- 827
						doCompile(true) -- 827
					end -- 827
					Separator() -- 828
					if Selectable(zh and "清理" or "Clean") then -- 829
						return doClean() -- 829
					end -- 829
				end) -- 824
			end) -- 824
			if isInEntry then -- 830
				if waitForWebStart then -- 831
					BeginDisabled(function() -- 832
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 832
					end) -- 832
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 833
					reloadDevEntry() -- 834
				end -- 831
			end -- 830
			do -- 835
				local changed -- 835
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 835
				if changed then -- 835
					View.scale = scaleContent and screenScale or 1 -- 836
				end -- 835
			end -- 835
			do -- 837
				local changed -- 837
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 837
				if changed then -- 837
					config.engineDev = engineDev -- 838
				end -- 837
			end -- 837
			if testingThread then -- 839
				return BeginDisabled(function() -- 840
					return Button(zh and "开始自动测试" or "Test automatically") -- 840
				end) -- 840
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 841
				testingThread = thread(function() -- 842
					local _ <close> = setmetatable({ }, { -- 843
						__close = function() -- 843
							allClear() -- 844
							testingThread = nil -- 845
							isInEntry = true -- 846
							currentEntry = nil -- 847
							return print("Testing done!") -- 848
						end -- 843
					}) -- 843
					for _, entry in ipairs(allEntries) do -- 849
						allClear() -- 850
						print("Start " .. tostring(entry.entryName)) -- 851
						enterDemoEntry(entry) -- 852
						sleep(2) -- 853
						print("Stop " .. tostring(entry.entryName)) -- 854
					end -- 849
				end) -- 842
			end -- 839
		end) -- 822
	end -- 751
end -- 739
local icon = Path("Script", "Dev", "icon_s.png") -- 856
local iconTex = nil -- 857
thread(function() -- 858
	if Cache:loadAsync(icon) then -- 858
		iconTex = Texture2D(icon) -- 858
	end -- 858
end) -- 858
local webStatus = nil -- 860
local urlClicked = nil -- 861
local descColor = Color(0xffa1a1a1) -- 862
local authCode = string.format("%06d", math.random(0, 999999)) -- 864
local authCodeTTL = 30 -- 866
_module_0.getAuthCode = function() -- 867
	return authCode -- 867
end -- 867
_module_0.invalidateAuthCode = function() -- 868
	authCode = string.format("%06d", math.random(0, 999999)) -- 869
	authCodeTTL = 30 -- 870
end -- 868
local AuthSession -- 872
do -- 872
	local pending = nil -- 873
	local session = nil -- 874
	AuthSession = { -- 876
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 876
			pending = { -- 878
				sessionId = sessionId, -- 878
				confirmCode = confirmCode, -- 879
				expiresAt = expiresAt, -- 880
				ttl = ttl, -- 881
				approved = false -- 882
			} -- 877
		end, -- 876
		getPending = function() -- 884
			return pending -- 884
		end, -- 884
		approvePending = function(sessionId) -- 886
			if pending and pending.sessionId == sessionId then -- 887
				pending.approved = true -- 888
				return true -- 889
			end -- 887
			return false -- 890
		end, -- 886
		clearPending = function() -- 892
			pending = nil -- 892
		end, -- 892
		setSession = function(sessionId, sessionSecret) -- 894
			session = { -- 896
				sessionId = sessionId, -- 896
				sessionSecret = sessionSecret -- 897
			} -- 895
		end, -- 894
		getSession = function() -- 899
			return session -- 899
		end -- 899
	} -- 875
end -- 872
_module_0["AuthSession"] = AuthSession -- 872
local transparant = Color(0x0) -- 902
local windowFlags = { -- 903
	"NoTitleBar", -- 903
	"NoResize", -- 903
	"NoMove", -- 903
	"NoCollapse", -- 903
	"NoSavedSettings", -- 903
	"NoFocusOnAppearing", -- 903
	"NoBringToFrontOnFocus" -- 903
} -- 903
local statusFlags = { -- 912
	"NoTitleBar", -- 912
	"NoResize", -- 912
	"NoMove", -- 912
	"NoCollapse", -- 912
	"AlwaysAutoResize", -- 912
	"NoSavedSettings" -- 912
} -- 912
local displayWindowFlags = { -- 920
	"NoDecoration", -- 920
	"NoSavedSettings", -- 920
	"NoNav", -- 920
	"NoMove", -- 920
	"NoScrollWithMouse", -- 920
	"AlwaysAutoResize", -- 920
	"NoFocusOnAppearing" -- 920
} -- 920
local initFooter = true -- 929
local _anon_func_4 = function(allEntries, currentIndex) -- 970
	if currentIndex > 1 then -- 970
		return allEntries[currentIndex - 1] -- 971
	else -- 973
		return allEntries[#allEntries] -- 973
	end -- 970
end -- 970
local _anon_func_5 = function(allEntries, currentIndex) -- 977
	if currentIndex < #allEntries then -- 977
		return allEntries[currentIndex + 1] -- 978
	else -- 980
		return allEntries[1] -- 980
	end -- 977
end -- 977
footerWindow = threadLoop(function() -- 930
	local zh = useChinese -- 931
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 932
	if authCodeTTL <= 0 then -- 933
		authCodeTTL = 30 -- 934
		authCode = string.format("%06d", math.random(0, 999999)) -- 935
	end -- 933
	if HttpServer.wsConnectionCount > 0 then -- 936
		return -- 937
	end -- 936
	if Keyboard:isKeyDown("Escape") then -- 938
		allClear() -- 939
		App.devMode = false -- 940
		App:shutdown() -- 941
	end -- 938
	do -- 942
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 943
		if ctrl and Keyboard:isKeyDown("Q") then -- 944
			stop() -- 945
		end -- 944
		if ctrl and Keyboard:isKeyDown("Z") then -- 946
			reloadCurrentEntry() -- 947
		end -- 946
		if ctrl and Keyboard:isKeyDown(",") then -- 948
			if showFooter then -- 949
				showStats = not showStats -- 949
			else -- 949
				showStats = true -- 949
			end -- 949
			showFooter = true -- 950
			config.showFooter = showFooter -- 951
			config.showStats = showStats -- 952
		end -- 948
		if ctrl and Keyboard:isKeyDown(".") then -- 953
			if showFooter then -- 954
				showConsole = not showConsole -- 954
			else -- 954
				showConsole = true -- 954
			end -- 954
			showFooter = true -- 955
			config.showFooter = showFooter -- 956
			config.showConsole = showConsole -- 957
		end -- 953
		if ctrl and Keyboard:isKeyDown("/") then -- 958
			showFooter = not showFooter -- 959
			config.showFooter = showFooter -- 960
		end -- 958
		local left = ctrl and Keyboard:isKeyDown("Left") -- 961
		local right = ctrl and Keyboard:isKeyDown("Right") -- 962
		local currentIndex = nil -- 963
		for i, entry in ipairs(allEntries) do -- 964
			if currentEntry == entry then -- 965
				currentIndex = i -- 966
			end -- 965
		end -- 964
		if left then -- 967
			allClear() -- 968
			if currentIndex == nil then -- 969
				currentIndex = #allEntries + 1 -- 969
			end -- 969
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 970
		end -- 967
		if right then -- 974
			allClear() -- 975
			if currentIndex == nil then -- 976
				currentIndex = 0 -- 976
			end -- 976
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 977
		end -- 974
	end -- 942
	if not showEntry then -- 981
		return -- 981
	end -- 981
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 983
		reloadDevEntry() -- 987
	end -- 983
	if initFooter then -- 988
		initFooter = false -- 989
	end -- 988
	local width, height -- 991
	do -- 991
		local _obj_0 = App.visualSize -- 991
		width, height = _obj_0.width, _obj_0.height -- 991
	end -- 991
	if isInEntry or showFooter then -- 992
		SetNextWindowSize(Vec2(width, 50)) -- 993
		SetNextWindowPos(Vec2(0, height - 50)) -- 994
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 995
			return PushStyleVar("WindowRounding", 0, function() -- 996
				return Begin("Footer", windowFlags, function() -- 997
					Separator() -- 998
					if iconTex then -- 999
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1000
							showStats = not showStats -- 1001
							config.showStats = showStats -- 1002
						end -- 1000
						SameLine() -- 1003
						if Button(">_", Vec2(30, 30)) then -- 1004
							showConsole = not showConsole -- 1005
							config.showConsole = showConsole -- 1006
						end -- 1004
					end -- 999
					if isInEntry and config.updateNotification then -- 1007
						SameLine() -- 1008
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1009
							allClear() -- 1010
							config.updateNotification = false -- 1011
							enterDemoEntry({ -- 1013
								entryName = "SelfUpdater", -- 1013
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1014
							}) -- 1012
						end -- 1009
					end -- 1007
					if not isInEntry then -- 1015
						SameLine() -- 1016
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1017
						local currentIndex = nil -- 1018
						for i, entry in ipairs(allEntries) do -- 1019
							if currentEntry == entry then -- 1020
								currentIndex = i -- 1021
							end -- 1020
						end -- 1019
						if currentIndex then -- 1022
							if currentIndex > 1 then -- 1023
								SameLine() -- 1024
								if Button("<<", Vec2(30, 30)) then -- 1025
									allClear() -- 1026
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1027
								end -- 1025
							end -- 1023
							if currentIndex < #allEntries then -- 1028
								SameLine() -- 1029
								if Button(">>", Vec2(30, 30)) then -- 1030
									allClear() -- 1031
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1032
								end -- 1030
							end -- 1028
						end -- 1022
						SameLine() -- 1033
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1034
							reloadCurrentEntry() -- 1035
						end -- 1034
						if back then -- 1036
							allClear() -- 1037
							isInEntry = true -- 1038
							currentEntry = nil -- 1039
						end -- 1036
					end -- 1015
				end) -- 997
			end) -- 996
		end) -- 995
	end -- 992
	local showWebIDE = isInEntry -- 1041
	if config.updateNotification then -- 1042
		if width < 460 then -- 1043
			showWebIDE = false -- 1044
		end -- 1043
	else -- 1046
		if width < 360 then -- 1046
			showWebIDE = false -- 1047
		end -- 1046
	end -- 1042
	if showWebIDE then -- 1048
		SetNextWindowBgAlpha(0.0) -- 1049
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1050
		Begin("Web IDE", displayWindowFlags, function() -- 1051
			local pending = AuthSession.getPending() -- 1052
			local hovered = false -- 1053
			if not pending then -- 1054
				do -- 1055
					local url -- 1055
					if webStatus ~= nil then -- 1055
						url = webStatus.url -- 1055
					end -- 1055
					if url then -- 1055
						if isDesktop and not config.fullScreen then -- 1056
							if urlClicked then -- 1057
								BeginDisabled(function() -- 1058
									return Button(url) -- 1058
								end) -- 1058
							elseif Button(url) then -- 1059
								urlClicked = once(function() -- 1060
									return sleep(5) -- 1060
								end) -- 1060
								App:openURL("http://localhost:8866") -- 1061
							end -- 1057
						else -- 1063
							TextColored(descColor, url) -- 1063
						end -- 1056
					else -- 1065
						TextColored(descColor, zh and '不可用' or 'not available') -- 1065
					end -- 1055
				end -- 1055
				hovered = IsItemHovered() -- 1066
				SameLine() -- 1067
			end -- 1054
			local themeColor = App.themeColor -- 1068
			if pending then -- 1069
				if not pending.approved then -- 1070
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1071
					local ttl = pending.ttl or 1 -- 1072
					PushStyleColor("Text", themeColor, function() -- 1073
						ImGui.ProgressBar(remaining / ttl, Vec2(40, -1), pending.confirmCode) -- 1074
						hovered = hovered or IsItemHovered() -- 1075
					end) -- 1073
					SameLine() -- 1076
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1077
						AuthSession.approvePending(pending.sessionId) -- 1078
					end -- 1077
					if hovered then -- 1079
						return BeginTooltip(function() -- 1080
							return PushTextWrapPos(280, function() -- 1081
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1082
							end) -- 1081
						end) -- 1080
					end -- 1079
				end -- 1070
			else -- 1084
				PushStyleColor("Text", themeColor, function() -- 1084
					ImGui.ProgressBar(authCodeTTL / 30, Vec2(60, -1), authCode) -- 1085
					hovered = hovered or IsItemHovered() -- 1086
				end) -- 1084
				if hovered then -- 1087
					return BeginTooltip(function() -- 1088
						return PushTextWrapPos(280, function() -- 1089
							return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址并输入后面的 PIN 码来使用 Web IDE（PIN 仅用于一次认证）' or 'Open this address in a browser on this machine or another device on the local network and enter the PIN below to start the Web IDE (PIN is one-time).') -- 1090
						end) -- 1089
					end) -- 1088
				end -- 1087
			end -- 1069
		end) -- 1051
	end -- 1048
	if not isInEntry then -- 1092
		SetNextWindowSize(Vec2(50, 50)) -- 1093
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1094
		PushStyleColor("WindowBg", transparant, function() -- 1095
			return Begin("Show", displayWindowFlags, function() -- 1095
				if width >= 370 then -- 1096
					local changed -- 1097
					changed, showFooter = Checkbox("##dev", showFooter) -- 1097
					if changed then -- 1097
						config.showFooter = showFooter -- 1098
					end -- 1097
				end -- 1096
			end) -- 1095
		end) -- 1095
	end -- 1092
	if isInEntry or showFooter then -- 1100
		if showStats then -- 1101
			PushStyleVar("WindowRounding", 0, function() -- 1102
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1103
				SetNextWindowSize(Vec2(0, height - 50)) -- 1104
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1105
				config.showStats = showStats -- 1106
			end) -- 1102
		end -- 1101
		if showConsole then -- 1107
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1108
			return PushStyleVar("WindowRounding", 6, function() -- 1109
				return ShowConsole() -- 1110
			end) -- 1109
		end -- 1107
	end -- 1100
end) -- 930
local MaxWidth <const> = 960 -- 1112
local toolOpen = false -- 1114
local filterText = nil -- 1115
local anyEntryMatched = false -- 1116
local match -- 1117
match = function(name) -- 1117
	local res = not filterText or name:lower():match(filterText) -- 1118
	if res then -- 1119
		anyEntryMatched = true -- 1119
	end -- 1119
	return res -- 1120
end -- 1117
local sep -- 1122
sep = function() -- 1122
	return SeparatorText("") -- 1122
end -- 1122
local thinSep -- 1123
thinSep = function() -- 1123
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1123
end -- 1123
entryWindow = threadLoop(function() -- 1125
	if App.fpsLimited ~= config.fpsLimited then -- 1126
		config.fpsLimited = App.fpsLimited -- 1127
	end -- 1126
	if App.targetFPS ~= config.targetFPS then -- 1128
		config.targetFPS = App.targetFPS -- 1129
	end -- 1128
	if View.vsync ~= config.vsync then -- 1130
		config.vsync = View.vsync -- 1131
	end -- 1130
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1132
		config.fixedFPS = Director.scheduler.fixedFPS -- 1133
	end -- 1132
	if Director.profilerSending ~= config.webProfiler then -- 1134
		config.webProfiler = Director.profilerSending -- 1135
	end -- 1134
	if urlClicked then -- 1136
		local _, result = coroutine.resume(urlClicked) -- 1137
		if result then -- 1138
			coroutine.close(urlClicked) -- 1139
			urlClicked = nil -- 1140
		end -- 1138
	end -- 1136
	if not showEntry then -- 1141
		return -- 1141
	end -- 1141
	if not isInEntry then -- 1142
		return -- 1142
	end -- 1142
	local zh = useChinese -- 1143
	local themeColor = App.themeColor -- 1144
	if HttpServer.wsConnectionCount > 0 then -- 1145
		local width, height -- 1146
		do -- 1146
			local _obj_0 = App.visualSize -- 1146
			width, height = _obj_0.width, _obj_0.height -- 1146
		end -- 1146
		SetNextWindowBgAlpha(0.5) -- 1147
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1148
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1149
			Separator() -- 1150
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1151
			if iconTex then -- 1152
				Image(icon, Vec2(24, 24)) -- 1153
				SameLine() -- 1154
			end -- 1152
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1155
			TextColored(descColor, slogon) -- 1156
			return Separator() -- 1157
		end) -- 1149
		return -- 1158
	end -- 1145
	local fullWidth, height -- 1160
	do -- 1160
		local _obj_0 = App.visualSize -- 1160
		fullWidth, height = _obj_0.width, _obj_0.height -- 1160
	end -- 1160
	local width = math.min(MaxWidth, fullWidth) -- 1161
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1162
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1163
	SetNextWindowPos(Vec2.zero) -- 1164
	SetNextWindowBgAlpha(0) -- 1165
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1166
	do -- 1167
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1168
			return Begin("Dora Dev", windowFlags, function() -- 1169
				Dummy(Vec2(fullWidth - 20, 0)) -- 1170
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1171
				if fullWidth >= 400 then -- 1172
					SameLine() -- 1173
					Dummy(Vec2(fullWidth - 400, 0)) -- 1174
					SameLine() -- 1175
					SetNextItemWidth(zh and -95 or -140) -- 1176
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1177
						"AutoSelectAll" -- 1177
					}) then -- 1177
						config.filter = filterBuf.text -- 1178
					end -- 1177
					SameLine() -- 1179
					if Button(zh and '下载' or 'Download') then -- 1180
						allClear() -- 1181
						enterDemoEntry({ -- 1183
							entryName = "ResourceDownloader", -- 1183
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1184
						}) -- 1182
					end -- 1180
				end -- 1172
				Separator() -- 1185
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1186
			end) -- 1169
		end) -- 1168
	end -- 1167
	anyEntryMatched = false -- 1188
	SetNextWindowPos(Vec2(0, 50)) -- 1189
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1190
	do -- 1191
		return PushStyleColor("WindowBg", transparant, function() -- 1192
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1193
				return PushStyleVar("Alpha", 1, function() -- 1194
					return Begin("Content", windowFlags, function() -- 1195
						local DemoViewWidth <const> = 220 -- 1196
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1197
						if filterText then -- 1198
							filterText = filterText:lower() -- 1198
						end -- 1198
						if #gamesInDev > 0 then -- 1199
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1200
							Columns(columns, false) -- 1201
							local realViewWidth = GetColumnWidth() - 50 -- 1202
							for _index_0 = 1, #gamesInDev do -- 1203
								local game = gamesInDev[_index_0] -- 1203
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1204
								local displayName -- 1213
								if repo then -- 1213
									if zh then -- 1214
										displayName = repo.title.zh -- 1214
									else -- 1214
										displayName = repo.title.en -- 1214
									end -- 1214
								end -- 1213
								if displayName == nil then -- 1215
									displayName = gameName -- 1215
								end -- 1215
								if match(displayName) then -- 1216
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1217
									SameLine() -- 1218
									TextWrapped(displayName) -- 1219
									if columns > 1 then -- 1220
										if bannerFile then -- 1221
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1222
											local displayWidth <const> = realViewWidth -- 1223
											texHeight = displayWidth * texHeight / texWidth -- 1224
											texWidth = displayWidth -- 1225
											Dummy(Vec2.zero) -- 1226
											SameLine() -- 1227
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1228
										end -- 1221
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1229
											enterDemoEntry(game) -- 1230
										end -- 1229
									else -- 1232
										if bannerFile then -- 1232
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1233
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1234
											local sizing = 0.8 -- 1235
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1236
											texWidth = displayWidth * sizing -- 1237
											if texWidth > 500 then -- 1238
												sizing = 0.6 -- 1239
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1240
												texWidth = displayWidth * sizing -- 1241
											end -- 1238
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1242
											Dummy(Vec2(padding, 0)) -- 1243
											SameLine() -- 1244
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1245
										end -- 1232
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1246
											enterDemoEntry(game) -- 1247
										end -- 1246
									end -- 1220
									if #tests == 0 and #examples == 0 then -- 1248
										thinSep() -- 1249
									end -- 1248
									NextColumn() -- 1250
								end -- 1216
								local showSep = false -- 1251
								if #examples > 0 then -- 1252
									local showExample = false -- 1253
									do -- 1254
										local _accum_0 -- 1254
										for _index_1 = 1, #examples do -- 1254
											local _des_0 = examples[_index_1] -- 1254
											local entryName = _des_0.entryName -- 1254
											if match(entryName) then -- 1255
												_accum_0 = true -- 1255
												break -- 1255
											end -- 1255
										end -- 1254
										showExample = _accum_0 -- 1254
									end -- 1254
									if showExample then -- 1256
										showSep = true -- 1257
										Columns(1, false) -- 1258
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1259
										SameLine() -- 1260
										local opened -- 1261
										if (filterText ~= nil) then -- 1261
											opened = showExample -- 1261
										else -- 1261
											opened = false -- 1261
										end -- 1261
										if game.exampleOpen == nil then -- 1262
											game.exampleOpen = opened -- 1262
										end -- 1262
										SetNextItemOpen(game.exampleOpen) -- 1263
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1264
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1265
												Columns(maxColumns, false) -- 1266
												for _index_1 = 1, #examples do -- 1267
													local example = examples[_index_1] -- 1267
													local entryName = example.entryName -- 1268
													if not match(entryName) then -- 1269
														goto _continue_0 -- 1269
													end -- 1269
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1270
														if Button(entryName, Vec2(-1, 40)) then -- 1271
															enterDemoEntry(example) -- 1272
														end -- 1271
														return NextColumn() -- 1273
													end) -- 1270
													opened = true -- 1274
													::_continue_0:: -- 1268
												end -- 1267
											end) -- 1265
										end) -- 1264
										game.exampleOpen = opened -- 1275
									end -- 1256
								end -- 1252
								if #tests > 0 then -- 1276
									local showTest = false -- 1277
									do -- 1278
										local _accum_0 -- 1278
										for _index_1 = 1, #tests do -- 1278
											local _des_0 = tests[_index_1] -- 1278
											local entryName = _des_0.entryName -- 1278
											if match(entryName) then -- 1279
												_accum_0 = true -- 1279
												break -- 1279
											end -- 1279
										end -- 1278
										showTest = _accum_0 -- 1278
									end -- 1278
									if showTest then -- 1280
										showSep = true -- 1281
										Columns(1, false) -- 1282
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1283
										SameLine() -- 1284
										local opened -- 1285
										if (filterText ~= nil) then -- 1285
											opened = showTest -- 1285
										else -- 1285
											opened = false -- 1285
										end -- 1285
										if game.testOpen == nil then -- 1286
											game.testOpen = opened -- 1286
										end -- 1286
										SetNextItemOpen(game.testOpen) -- 1287
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1288
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1289
												Columns(maxColumns, false) -- 1290
												for _index_1 = 1, #tests do -- 1291
													local test = tests[_index_1] -- 1291
													local entryName = test.entryName -- 1292
													if not match(entryName) then -- 1293
														goto _continue_0 -- 1293
													end -- 1293
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1294
														if Button(entryName, Vec2(-1, 40)) then -- 1295
															enterDemoEntry(test) -- 1296
														end -- 1295
														return NextColumn() -- 1297
													end) -- 1294
													opened = true -- 1298
													::_continue_0:: -- 1292
												end -- 1291
											end) -- 1289
										end) -- 1288
										game.testOpen = opened -- 1299
									end -- 1280
								end -- 1276
								if showSep then -- 1300
									Columns(1, false) -- 1301
									thinSep() -- 1302
									Columns(columns, false) -- 1303
								end -- 1300
							end -- 1203
						end -- 1199
						if #doraTools > 0 then -- 1304
							local showTool = false -- 1305
							do -- 1306
								local _accum_0 -- 1306
								for _index_0 = 1, #doraTools do -- 1306
									local _des_0 = doraTools[_index_0] -- 1306
									local entryName = _des_0.entryName -- 1306
									if match(entryName) then -- 1307
										_accum_0 = true -- 1307
										break -- 1307
									end -- 1307
								end -- 1306
								showTool = _accum_0 -- 1306
							end -- 1306
							if not showTool then -- 1308
								goto endEntry -- 1308
							end -- 1308
							Columns(1, false) -- 1309
							TextColored(themeColor, "Dora SSR:") -- 1310
							SameLine() -- 1311
							Text(zh and "开发支持" or "Development Support") -- 1312
							Separator() -- 1313
							if #doraTools > 0 then -- 1314
								local opened -- 1315
								if (filterText ~= nil) then -- 1315
									opened = showTool -- 1315
								else -- 1315
									opened = false -- 1315
								end -- 1315
								SetNextItemOpen(toolOpen) -- 1316
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1317
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1318
										Columns(maxColumns, false) -- 1319
										for _index_0 = 1, #doraTools do -- 1320
											local example = doraTools[_index_0] -- 1320
											local entryName = example.entryName -- 1321
											if not match(entryName) then -- 1322
												goto _continue_0 -- 1322
											end -- 1322
											if Button(entryName, Vec2(-1, 40)) then -- 1323
												enterDemoEntry(example) -- 1324
											end -- 1323
											NextColumn() -- 1325
											::_continue_0:: -- 1321
										end -- 1320
										Columns(1, false) -- 1326
										opened = true -- 1327
									end) -- 1318
								end) -- 1317
								toolOpen = opened -- 1328
							end -- 1314
						end -- 1304
						::endEntry:: -- 1329
						if not anyEntryMatched then -- 1330
							SetNextWindowBgAlpha(0) -- 1331
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1332
							Begin("Entries Not Found", displayWindowFlags, function() -- 1333
								Separator() -- 1334
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1335
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1336
								return Separator() -- 1337
							end) -- 1333
						end -- 1330
						Columns(1, false) -- 1338
						Dummy(Vec2(100, 80)) -- 1339
						return ScrollWhenDraggingOnVoid() -- 1340
					end) -- 1195
				end) -- 1194
			end) -- 1193
		end) -- 1192
	end -- 1191
end) -- 1125
webStatus = require("Script.Dev.WebServer") -- 1342
return _module_0 -- 1
