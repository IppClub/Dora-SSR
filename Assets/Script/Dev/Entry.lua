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
local HttpServer <const> = HttpServer -- 11
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
local Profiler <const> = Profiler -- 11
local xpcall <const> = xpcall -- 11
local debug <const> = debug -- 11
local Log <const> = Log -- 11
local math <const> = math -- 11
local AlignNode <const> = AlignNode -- 11
local Label <const> = Label -- 11
local Checkbox <const> = Checkbox -- 11
local SameLine <const> = SameLine -- 11
local TextColored <const> = TextColored -- 11
local IsItemHovered <const> = IsItemHovered -- 11
local BeginTooltip <const> = BeginTooltip -- 11
local PushTextWrapPos <const> = PushTextWrapPos -- 11
local Text <const> = Text -- 11
local SeparatorText <const> = SeparatorText -- 11
local Button <const> = Button -- 11
local OpenPopup <const> = OpenPopup -- 11
local SetNextWindowPosCenter <const> = SetNextWindowPosCenter -- 11
local BeginPopupModal <const> = BeginPopupModal -- 11
local TextWrapped <const> = TextWrapped -- 11
local CloseCurrentPopup <const> = CloseCurrentPopup -- 11
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "showPreview", "authRequired") -- 50
config:load() -- 79
if not (config.writablePath ~= nil) then -- 81
	config.writablePath = Content.appPath -- 82
end -- 81
if not (config.webIDEConnected ~= nil) then -- 84
	config.webIDEConnected = false -- 85
end -- 84
if (config.fpsLimited ~= nil) then -- 87
	App.fpsLimited = config.fpsLimited -- 88
else -- 90
	config.fpsLimited = App.fpsLimited -- 90
end -- 87
if (config.targetFPS ~= nil) then -- 92
	App.targetFPS = config.targetFPS -- 93
else -- 95
	config.targetFPS = App.targetFPS -- 95
end -- 92
if (config.vsync ~= nil) then -- 97
	View.vsync = config.vsync -- 98
else -- 100
	config.vsync = View.vsync -- 100
end -- 97
if (config.fixedFPS ~= nil) then -- 102
	Director.scheduler.fixedFPS = config.fixedFPS -- 103
else -- 105
	config.fixedFPS = Director.scheduler.fixedFPS -- 105
end -- 102
if not (config.showPreview ~= nil) then -- 107
	config.showPreview = true -- 108
end -- 107
if not (config.authRequired ~= nil) then -- 110
	config.authRequired = true -- 111
end -- 110
HttpServer.authRequired = config.authRequired -- 112
local showEntry = true -- 114
isDesktop = false -- 116
if (function() -- 117
	local _val_0 = App.platform -- 117
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 117
end)() then -- 117
	isDesktop = true -- 118
	if config.fullScreen then -- 119
		App.fullScreen = true -- 120
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 121
		local size = Size(config.winWidth, config.winHeight) -- 122
		if App.winSize ~= size then -- 123
			App.winSize = size -- 124
		end -- 123
		local winX, winY -- 125
		do -- 125
			local _obj_0 = App.winPosition -- 125
			winX, winY = _obj_0.x, _obj_0.y -- 125
		end -- 125
		if (config.winX ~= nil) then -- 126
			winX = config.winX -- 127
		else -- 129
			config.winX = -1 -- 129
		end -- 126
		if (config.winY ~= nil) then -- 130
			winY = config.winY -- 131
		else -- 133
			config.winY = -1 -- 133
		end -- 130
		App.winPosition = Vec2(winX, winY) -- 134
	end -- 119
	if (config.alwaysOnTop ~= nil) then -- 135
		App.alwaysOnTop = config.alwaysOnTop -- 136
	else -- 138
		config.alwaysOnTop = true -- 138
	end -- 135
end -- 117
if (config.themeColor ~= nil) then -- 140
	App.themeColor = Color(config.themeColor) -- 141
else -- 143
	config.themeColor = App.themeColor:toARGB() -- 143
end -- 140
if not (config.locale ~= nil) then -- 145
	config.locale = App.locale -- 146
end -- 145
local showStats = false -- 148
if (config.showStats ~= nil) then -- 149
	showStats = config.showStats -- 150
else -- 152
	config.showStats = showStats -- 152
end -- 149
local showConsole = false -- 154
if (config.showConsole ~= nil) then -- 155
	showConsole = config.showConsole -- 156
else -- 158
	config.showConsole = showConsole -- 158
end -- 155
local showFooter = true -- 160
if (config.showFooter ~= nil) then -- 161
	showFooter = config.showFooter -- 162
else -- 164
	config.showFooter = showFooter -- 164
end -- 161
local filterBuf = Buffer(20) -- 166
if (config.filter ~= nil) then -- 167
	filterBuf.text = config.filter -- 168
else -- 170
	config.filter = "" -- 170
end -- 167
local engineDev = false -- 172
if (config.engineDev ~= nil) then -- 173
	engineDev = config.engineDev -- 174
else -- 176
	config.engineDev = engineDev -- 176
end -- 173
if (config.webProfiler ~= nil) then -- 178
	Director.profilerSending = config.webProfiler -- 179
else -- 181
	config.webProfiler = true -- 181
	Director.profilerSending = true -- 182
end -- 178
if not (config.drawerWidth ~= nil) then -- 184
	config.drawerWidth = 200 -- 185
end -- 184
_module_0.getConfig = function() -- 187
	return config -- 187
end -- 187
_module_0.getEngineDev = function() -- 188
	if not App.debugging then -- 189
		return false -- 189
	end -- 189
	return config.engineDev -- 190
end -- 188
local _anon_func_0 = function() -- 195
	local _val_0 = App.platform -- 195
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 195
end -- 195
_module_0.connectWebIDE = function() -- 192
	if not config.webIDEConnected then -- 193
		config.webIDEConnected = true -- 194
		if _anon_func_0() then -- 195
			local ratio = App.winSize.width / App.visualSize.width -- 196
			App.winSize = Size(640 * ratio, 480 * ratio) -- 197
		end -- 195
	end -- 193
end -- 192
local updateCheck -- 199
updateCheck = function() -- 199
	return thread(function() -- 199
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 200
		if res then -- 200
			local data = json.decode(res) -- 201
			if data then -- 201
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 202
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 203
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 204
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 205
				if na < a then -- 206
					goto not_new_version -- 207
				end -- 206
				if na == a then -- 208
					if nb < b then -- 209
						goto not_new_version -- 210
					end -- 209
					if nb == b then -- 211
						if nc < c then -- 212
							goto not_new_version -- 213
						end -- 212
						if nc == c then -- 214
							goto not_new_version -- 215
						end -- 214
					end -- 211
				end -- 208
				config.updateNotification = true -- 216
				::not_new_version:: -- 217
				config.lastUpdateCheck = os.time() -- 218
			end -- 201
		end -- 200
	end) -- 199
end -- 199
if (config.lastUpdateCheck ~= nil) then -- 220
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 221
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 222
		updateCheck() -- 223
	end -- 222
else -- 225
	updateCheck() -- 225
end -- 220
local Set, Struct, LintYueGlobals, GSplit -- 227
do -- 227
	local _obj_0 = require("Utils") -- 227
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 227
end -- 227
local yueext = yue.options.extension -- 228
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 230
local building = false -- 232
local getAllFiles -- 234
getAllFiles = function(path, exts, recursive) -- 234
	if recursive == nil then -- 234
		recursive = true -- 234
	end -- 234
	local filters = Set(exts) -- 235
	local files -- 236
	if recursive then -- 236
		files = Content:getAllFiles(path) -- 237
	else -- 239
		files = Content:getFiles(path) -- 239
	end -- 236
	local _accum_0 = { } -- 240
	local _len_0 = 1 -- 240
	for _index_0 = 1, #files do -- 240
		local file = files[_index_0] -- 240
		if not filters[Path:getExt(file)] then -- 241
			goto _continue_0 -- 241
		end -- 241
		_accum_0[_len_0] = file -- 242
		_len_0 = _len_0 + 1 -- 241
		::_continue_0:: -- 241
	end -- 240
	return _accum_0 -- 240
end -- 234
_module_0["getAllFiles"] = getAllFiles -- 234
local getFileEntries -- 244
getFileEntries = function(path, recursive, excludeFiles) -- 244
	if recursive == nil then -- 244
		recursive = true -- 244
	end -- 244
	if excludeFiles == nil then -- 244
		excludeFiles = nil -- 244
	end -- 244
	local entries = { } -- 245
	local excludes -- 246
	if excludeFiles then -- 246
		excludes = Set(excludeFiles) -- 247
	end -- 246
	local _list_0 = getAllFiles(path, { -- 248
		"lua", -- 248
		"xml", -- 248
		yueext, -- 248
		"tl" -- 248
	}, recursive) -- 248
	for _index_0 = 1, #_list_0 do -- 248
		local file = _list_0[_index_0] -- 248
		local entryName = Path:getName(file) -- 249
		if excludes and excludes[entryName] then -- 250
			goto _continue_0 -- 251
		end -- 250
		local fileName = Path:replaceExt(file, "") -- 252
		fileName = Path(path, fileName) -- 253
		local entryAdded -- 254
		do -- 254
			local _accum_0 -- 254
			for _index_1 = 1, #entries do -- 254
				local _des_0 = entries[_index_1] -- 254
				local ename, efile = _des_0.entryName, _des_0.fileName -- 254
				if entryName == ename and efile == fileName then -- 255
					_accum_0 = true -- 255
					break -- 255
				end -- 255
			end -- 254
			entryAdded = _accum_0 -- 254
		end -- 254
		if entryAdded then -- 256
			goto _continue_0 -- 256
		end -- 256
		local entry = { -- 257
			entryName = entryName, -- 257
			fileName = fileName -- 257
		} -- 257
		entries[#entries + 1] = entry -- 258
		::_continue_0:: -- 249
	end -- 248
	table.sort(entries, function(a, b) -- 259
		return a.entryName < b.entryName -- 259
	end) -- 259
	return entries -- 260
end -- 244
local getProjectEntries -- 262
getProjectEntries = function(path, noPreview) -- 262
	if noPreview == nil then -- 262
		noPreview = false -- 262
	end -- 262
	local entries = { } -- 263
	local _list_0 = Content:getDirs(path) -- 264
	for _index_0 = 1, #_list_0 do -- 264
		local dir = _list_0[_index_0] -- 264
		if dir:match("^%.") then -- 265
			goto _continue_0 -- 265
		end -- 265
		local _list_1 = getAllFiles(Path(path, dir), { -- 266
			"lua", -- 266
			"xml", -- 266
			yueext, -- 266
			"tl", -- 266
			"wasm" -- 266
		}) -- 266
		for _index_1 = 1, #_list_1 do -- 266
			local file = _list_1[_index_1] -- 266
			if "init" == Path:getName(file):lower() then -- 267
				local fileName = Path:replaceExt(file, "") -- 268
				fileName = Path(path, dir, fileName) -- 269
				local projectPath = Path:getPath(fileName) -- 270
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 271
				local repo = nil -- 272
				if Content:exist(repoFile) then -- 273
					local str = Content:load(repoFile) -- 274
					if str then -- 274
						repo = json.decode(str) -- 275
					end -- 274
				end -- 273
				local entryName = Path:getName(projectPath) -- 276
				local entryAdded -- 277
				do -- 277
					local _accum_0 -- 277
					for _index_2 = 1, #entries do -- 277
						local _des_0 = entries[_index_2] -- 277
						local ename, efile = _des_0.entryName, _des_0.fileName -- 277
						if entryName == ename and efile == fileName then -- 278
							_accum_0 = true -- 278
							break -- 278
						end -- 278
					end -- 277
					entryAdded = _accum_0 -- 277
				end -- 277
				if entryAdded then -- 279
					goto _continue_1 -- 279
				end -- 279
				local examples = { } -- 280
				local tests = { } -- 281
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 282
				if Content:exist(examplePath) then -- 283
					local _list_2 = getFileEntries(examplePath) -- 284
					for _index_2 = 1, #_list_2 do -- 284
						local _des_0 = _list_2[_index_2] -- 284
						local name, ePath = _des_0.entryName, _des_0.fileName -- 284
						local entry = { -- 286
							entryName = name, -- 286
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 287
							workDir = projectPath -- 288
						} -- 285
						examples[#examples + 1] = entry -- 290
					end -- 284
				end -- 283
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 291
				if Content:exist(testPath) then -- 292
					local _list_2 = getFileEntries(testPath) -- 293
					for _index_2 = 1, #_list_2 do -- 293
						local _des_0 = _list_2[_index_2] -- 293
						local name, tPath = _des_0.entryName, _des_0.fileName -- 293
						local entry = { -- 295
							entryName = name, -- 295
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 296
							workDir = projectPath -- 297
						} -- 294
						tests[#tests + 1] = entry -- 299
					end -- 293
				end -- 292
				local entry = { -- 300
					entryName = entryName, -- 300
					fileName = fileName, -- 300
					examples = examples, -- 300
					tests = tests, -- 300
					repo = repo -- 300
				} -- 300
				local bannerFile -- 301
				do -- 301
					local _accum_0 -- 301
					repeat -- 301
						if noPreview then -- 302
							_accum_0 = nil -- 302
							break -- 302
						end -- 302
						if not config.showPreview then -- 303
							_accum_0 = nil -- 303
							break -- 303
						end -- 303
						local f = Path(projectPath, ".dora", "banner.jpg") -- 304
						if Content:exist(f) then -- 305
							_accum_0 = f -- 305
							break -- 305
						end -- 305
						f = Path(projectPath, ".dora", "banner.png") -- 306
						if Content:exist(f) then -- 307
							_accum_0 = f -- 307
							break -- 307
						end -- 307
						f = Path(projectPath, "Image", "banner.jpg") -- 308
						if Content:exist(f) then -- 309
							_accum_0 = f -- 309
							break -- 309
						end -- 309
						f = Path(projectPath, "Image", "banner.png") -- 310
						if Content:exist(f) then -- 311
							_accum_0 = f -- 311
							break -- 311
						end -- 311
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 312
						if Content:exist(f) then -- 313
							_accum_0 = f -- 313
							break -- 313
						end -- 313
					until true -- 301
					bannerFile = _accum_0 -- 301
				end -- 301
				if bannerFile then -- 315
					thread(function() -- 315
						if Cache:loadAsync(bannerFile) then -- 316
							local bannerTex = Texture2D(bannerFile) -- 317
							if bannerTex then -- 317
								entry.bannerFile = bannerFile -- 318
								entry.bannerTex = bannerTex -- 319
							end -- 317
						end -- 316
					end) -- 315
				end -- 315
				entries[#entries + 1] = entry -- 320
			end -- 267
			::_continue_1:: -- 267
		end -- 266
		::_continue_0:: -- 265
	end -- 264
	table.sort(entries, function(a, b) -- 321
		return a.entryName < b.entryName -- 321
	end) -- 321
	return entries -- 322
end -- 262
_module_0["getProjectEntries"] = getProjectEntries -- 262
local gamesInDev -- 324
local doraTools -- 325
local allEntries -- 326
local updateEntries -- 328
updateEntries = function() -- 328
	gamesInDev = getProjectEntries(Content.writablePath) -- 329
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 330
	allEntries = { } -- 332
	for _index_0 = 1, #gamesInDev do -- 333
		local game = gamesInDev[_index_0] -- 333
		allEntries[#allEntries + 1] = game -- 334
		local examples, tests = game.examples, game.tests -- 335
		for _index_1 = 1, #examples do -- 336
			local example = examples[_index_1] -- 336
			allEntries[#allEntries + 1] = example -- 337
		end -- 336
		for _index_1 = 1, #tests do -- 338
			local test = tests[_index_1] -- 338
			allEntries[#allEntries + 1] = test -- 339
		end -- 338
	end -- 333
end -- 328
updateEntries() -- 341
local doCompile -- 343
doCompile = function(minify) -- 343
	if building then -- 344
		return -- 344
	end -- 344
	building = true -- 345
	local startTime = App.runningTime -- 346
	local luaFiles = { } -- 347
	local yueFiles = { } -- 348
	local xmlFiles = { } -- 349
	local tlFiles = { } -- 350
	local writablePath = Content.writablePath -- 351
	local buildPaths = { -- 353
		{ -- 354
			Content.assetPath, -- 354
			Path(writablePath, ".build"), -- 355
			"" -- 356
		} -- 353
	} -- 352
	for _index_0 = 1, #gamesInDev do -- 359
		local _des_0 = gamesInDev[_index_0] -- 359
		local fileName = _des_0.fileName -- 359
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 360
		buildPaths[#buildPaths + 1] = { -- 362
			Path(writablePath, gamePath), -- 362
			Path(writablePath, ".build", gamePath), -- 363
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 364
			gamePath -- 365
		} -- 361
	end -- 359
	for _index_0 = 1, #buildPaths do -- 366
		local _des_0 = buildPaths[_index_0] -- 366
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 366
		if not Content:exist(inputPath) then -- 367
			goto _continue_0 -- 367
		end -- 367
		local _list_0 = getAllFiles(inputPath, { -- 369
			"lua" -- 369
		}) -- 369
		for _index_1 = 1, #_list_0 do -- 369
			local file = _list_0[_index_1] -- 369
			luaFiles[#luaFiles + 1] = { -- 371
				file, -- 371
				Path(inputPath, file), -- 372
				Path(outputPath, file), -- 373
				gamePath -- 374
			} -- 370
		end -- 369
		local _list_1 = getAllFiles(inputPath, { -- 376
			yueext -- 376
		}) -- 376
		for _index_1 = 1, #_list_1 do -- 376
			local file = _list_1[_index_1] -- 376
			yueFiles[#yueFiles + 1] = { -- 378
				file, -- 378
				Path(inputPath, file), -- 379
				Path(outputPath, Path:replaceExt(file, "lua")), -- 380
				searchPath, -- 381
				gamePath -- 382
			} -- 377
		end -- 376
		local _list_2 = getAllFiles(inputPath, { -- 384
			"xml" -- 384
		}) -- 384
		for _index_1 = 1, #_list_2 do -- 384
			local file = _list_2[_index_1] -- 384
			xmlFiles[#xmlFiles + 1] = { -- 386
				file, -- 386
				Path(inputPath, file), -- 387
				Path(outputPath, Path:replaceExt(file, "lua")), -- 388
				gamePath -- 389
			} -- 385
		end -- 384
		local _list_3 = getAllFiles(inputPath, { -- 391
			"tl" -- 391
		}) -- 391
		for _index_1 = 1, #_list_3 do -- 391
			local file = _list_3[_index_1] -- 391
			if not file:match(".*%.d%.tl$") then -- 392
				tlFiles[#tlFiles + 1] = { -- 394
					file, -- 394
					Path(inputPath, file), -- 395
					Path(outputPath, Path:replaceExt(file, "lua")), -- 396
					searchPath, -- 397
					gamePath -- 398
				} -- 393
			end -- 392
		end -- 391
		::_continue_0:: -- 367
	end -- 366
	local paths -- 400
	do -- 400
		local _tbl_0 = { } -- 400
		local _list_0 = { -- 401
			luaFiles, -- 401
			yueFiles, -- 401
			xmlFiles, -- 401
			tlFiles -- 401
		} -- 401
		for _index_0 = 1, #_list_0 do -- 401
			local files = _list_0[_index_0] -- 401
			for _index_1 = 1, #files do -- 402
				local file = files[_index_1] -- 402
				_tbl_0[Path:getPath(file[3])] = true -- 400
			end -- 400
		end -- 400
		paths = _tbl_0 -- 400
	end -- 400
	for path in pairs(paths) do -- 404
		Content:mkdir(path) -- 404
	end -- 404
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 406
	local fileCount = 0 -- 407
	local errors = { } -- 408
	for _index_0 = 1, #yueFiles do -- 409
		local _des_0 = yueFiles[_index_0] -- 409
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 409
		local filename -- 410
		if gamePath then -- 410
			filename = Path(gamePath, file) -- 410
		else -- 410
			filename = file -- 410
		end -- 410
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 411
			if not codes then -- 412
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 413
				return -- 414
			end -- 412
			local success, result = LintYueGlobals(codes, globals) -- 415
			local yueCodes -- 416
			if not success then -- 417
				yueCodes = Content:load(input) -- 418
				if yueCodes then -- 418
					local CheckTIC80Code -- 419
					do -- 419
						local _obj_0 = require("Utils") -- 419
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 419
					end -- 419
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 420
					if isTIC80 then -- 421
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 422
					end -- 421
				end -- 418
			end -- 417
			if success then -- 423
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 424
			else -- 426
				if yueCodes then -- 426
					local globalErrors = { } -- 427
					for _index_1 = 1, #result do -- 428
						local _des_1 = result[_index_1] -- 428
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 428
						local countLine = 1 -- 429
						local code = "" -- 430
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 431
							if countLine == line then -- 432
								code = lineCode -- 433
								break -- 434
							end -- 432
							countLine = countLine + 1 -- 435
						end -- 431
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 436
					end -- 428
					if #globalErrors > 0 then -- 437
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 437
					end -- 437
				else -- 439
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 439
				end -- 426
				if #errors == 0 then -- 440
					return codes -- 440
				end -- 440
			end -- 423
		end, function(success) -- 411
			if success then -- 441
				print("Yue compiled: " .. tostring(filename)) -- 441
			end -- 441
			fileCount = fileCount + 1 -- 442
		end) -- 411
	end -- 409
	thread(function() -- 444
		for _index_0 = 1, #xmlFiles do -- 445
			local _des_0 = xmlFiles[_index_0] -- 445
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 445
			local filename -- 446
			if gamePath then -- 446
				filename = Path(gamePath, file) -- 446
			else -- 446
				filename = file -- 446
			end -- 446
			local sourceCodes = Content:loadAsync(input) -- 447
			local codes, err = xml.tolua(sourceCodes) -- 448
			if not codes then -- 449
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 450
			else -- 452
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 452
				print("Xml compiled: " .. tostring(filename)) -- 453
			end -- 449
			fileCount = fileCount + 1 -- 454
		end -- 445
	end) -- 444
	thread(function() -- 456
		for _index_0 = 1, #tlFiles do -- 457
			local _des_0 = tlFiles[_index_0] -- 457
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 457
			local filename -- 458
			if gamePath then -- 458
				filename = Path(gamePath, file) -- 458
			else -- 458
				filename = file -- 458
			end -- 458
			local sourceCodes = Content:loadAsync(input) -- 459
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 460
			if not codes then -- 461
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 462
			else -- 464
				Content:saveAsync(output, codes) -- 464
				print("Teal compiled: " .. tostring(filename)) -- 465
			end -- 461
			fileCount = fileCount + 1 -- 466
		end -- 457
	end) -- 456
	return thread(function() -- 468
		wait(function() -- 469
			return fileCount == totalFiles -- 469
		end) -- 469
		if minify then -- 470
			local _list_0 = { -- 471
				yueFiles, -- 471
				xmlFiles, -- 471
				tlFiles -- 471
			} -- 471
			for _index_0 = 1, #_list_0 do -- 471
				local files = _list_0[_index_0] -- 471
				for _index_1 = 1, #files do -- 471
					local file = files[_index_1] -- 471
					local output = Path:replaceExt(file[3], "lua") -- 472
					luaFiles[#luaFiles + 1] = { -- 474
						Path:replaceExt(file[1], "lua"), -- 474
						output, -- 475
						output -- 476
					} -- 473
				end -- 471
			end -- 471
			local FormatMini -- 478
			do -- 478
				local _obj_0 = require("luaminify") -- 478
				FormatMini = _obj_0.FormatMini -- 478
			end -- 478
			for _index_0 = 1, #luaFiles do -- 479
				local _des_0 = luaFiles[_index_0] -- 479
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 479
				if Content:exist(input) then -- 480
					local sourceCodes = Content:loadAsync(input) -- 481
					local res, err = FormatMini(sourceCodes) -- 482
					if res then -- 483
						Content:saveAsync(output, res) -- 484
						print("Minify: " .. tostring(file)) -- 485
					else -- 487
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 487
					end -- 483
				else -- 489
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 489
				end -- 480
			end -- 479
			package.loaded["luaminify.FormatMini"] = nil -- 490
			package.loaded["luaminify.ParseLua"] = nil -- 491
			package.loaded["luaminify.Scope"] = nil -- 492
			package.loaded["luaminify.Util"] = nil -- 493
		end -- 470
		local errorMessage = table.concat(errors, "\n") -- 494
		if errorMessage ~= "" then -- 495
			print(errorMessage) -- 495
		end -- 495
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 496
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 497
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 498
		Content:clearPathCache() -- 499
		teal.clear() -- 500
		yue.clear() -- 501
		building = false -- 502
	end) -- 468
end -- 343
local doClean -- 504
doClean = function() -- 504
	if building then -- 505
		return -- 505
	end -- 505
	local writablePath = Content.writablePath -- 506
	local targetDir = Path(writablePath, ".build") -- 507
	Content:clearPathCache() -- 508
	if Content:remove(targetDir) then -- 509
		return print("Cleaned: " .. tostring(targetDir)) -- 510
	end -- 509
end -- 504
local screenScale = 2.0 -- 512
local scaleContent = false -- 513
local isInEntry = true -- 514
local currentEntry = nil -- 515
local footerWindow = nil -- 517
local entryWindow = nil -- 518
local testingThread = nil -- 519
local setupEventHandlers = nil -- 521
local allClear -- 523
allClear = function() -- 523
	for _index_0 = 1, #Routine do -- 524
		local routine = Routine[_index_0] -- 524
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 526
			goto _continue_0 -- 527
		else -- 529
			Routine:remove(routine) -- 529
		end -- 525
		::_continue_0:: -- 525
	end -- 524
	for _index_0 = 1, #moduleCache do -- 530
		local module = moduleCache[_index_0] -- 530
		package.loaded[module] = nil -- 531
	end -- 530
	moduleCache = { } -- 532
	Director:cleanup() -- 533
	Entity:clear() -- 534
	Platformer.Data:clear() -- 535
	Platformer.UnitAction:clear() -- 536
	Audio:stopAll(0.2) -- 537
	Struct:clear() -- 538
	View.postEffect = nil -- 539
	View.scale = scaleContent and screenScale or 1 -- 540
	Director.clearColor = Color(0xff1a1a1a) -- 541
	teal.clear() -- 542
	yue.clear() -- 543
	for _, item in pairs(ubox()) do -- 544
		local node = tolua.cast(item, "Node") -- 545
		if node then -- 545
			node:cleanup() -- 545
		end -- 545
	end -- 544
	collectgarbage() -- 546
	collectgarbage() -- 547
	Wasm:clear() -- 548
	thread(function() -- 549
		sleep() -- 550
		return Cache:removeUnused() -- 551
	end) -- 549
	setupEventHandlers() -- 552
	Content.searchPaths = searchPaths -- 553
	App.idled = true -- 554
end -- 523
_module_0["allClear"] = allClear -- 523
local clearTempFiles -- 556
clearTempFiles = function() -- 556
	local writablePath = Content.writablePath -- 557
	Content:remove(Path(writablePath, ".upload")) -- 558
	return Content:remove(Path(writablePath, ".download")) -- 559
end -- 556
local waitForWebStart = true -- 561
thread(function() -- 562
	sleep(2) -- 563
	waitForWebStart = false -- 564
end) -- 562
local reloadDevEntry -- 566
reloadDevEntry = function() -- 566
	return thread(function() -- 566
		waitForWebStart = true -- 567
		doClean() -- 568
		allClear() -- 569
		_G.require = oldRequire -- 570
		Dora.require = oldRequire -- 571
		package.loaded["Script.Dev.Entry"] = nil -- 572
		return Director.systemScheduler:schedule(function() -- 573
			Routine:clear() -- 574
			oldRequire("Script.Dev.Entry") -- 575
			return true -- 576
		end) -- 573
	end) -- 566
end -- 566
local setWorkspace -- 578
setWorkspace = function(path) -- 578
	clearTempFiles() -- 579
	Content.writablePath = path -- 580
	config.writablePath = Content.writablePath -- 581
	return thread(function() -- 582
		sleep() -- 583
		return reloadDevEntry() -- 584
	end) -- 582
end -- 578
_module_0["setWorkspace"] = setWorkspace -- 578
local quit = false -- 586
local activeSearchId = 0 -- 588
local handleSearchFiles -- 590
handleSearchFiles = function(payload) -- 590
	if not payload then -- 591
		return -- 591
	end -- 591
	local id = payload.id -- 592
	if id == nil then -- 593
		return -- 593
	end -- 593
	activeSearchId = id -- 594
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 595
	if path == nil then -- 596
		path = "" -- 596
	end -- 596
	if exts == nil then -- 597
		exts = { } -- 597
	end -- 597
	if globs == nil then -- 598
		globs = { } -- 598
	end -- 598
	if extensionLevels == nil then -- 599
		extensionLevels = { } -- 599
	end -- 599
	if pattern == nil then -- 600
		pattern = "" -- 600
	end -- 600
	if pattern == "" then -- 602
		return -- 602
	end -- 602
	local useRegex = payload.useRegex == true -- 603
	local caseSensitive = payload.caseSensitive == true -- 604
	local includeContent = payload.includeContent ~= false -- 605
	local contentWindow = payload.contentWindow or 0 -- 606
	return Director.systemScheduler:schedule(once(function() -- 607
		local stopped = false -- 608
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 609
			if activeSearchId ~= id then -- 610
				stopped = true -- 611
				return true -- 612
			end -- 610
			emit("AppWS", "Send", json.encode({ -- 614
				name = "SearchFilesResult", -- 614
				id = id, -- 614
				result = result -- 614
			})) -- 613
			return false -- 616
		end) -- 609
		return emit("AppWS", "Send", json.encode({ -- 618
			name = "SearchFilesDone", -- 618
			id = id, -- 618
			stopped = stopped -- 618
		})) -- 617
	end)) -- 607
end -- 590
local stop -- 621
stop = function() -- 621
	if isInEntry then -- 622
		return false -- 622
	end -- 622
	allClear() -- 623
	isInEntry = true -- 624
	currentEntry = nil -- 625
	return true -- 626
end -- 621
_module_0["stop"] = stop -- 621
local _anon_func_1 = function(_with_0) -- 645
	local _val_0 = App.platform -- 645
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 645
end -- 645
setupEventHandlers = function() -- 628
	local _with_0 = Director.postNode -- 629
	_with_0:onAppEvent(function(eventType) -- 630
		if "Quit" == eventType then -- 631
			quit = true -- 632
			allClear() -- 633
			return clearTempFiles() -- 634
		elseif "Shutdown" == eventType then -- 635
			return stop() -- 636
		end -- 630
	end) -- 630
	_with_0:onAppChange(function(settingName) -- 637
		if "Theme" == settingName then -- 638
			config.themeColor = App.themeColor:toARGB() -- 639
		elseif "Locale" == settingName then -- 640
			config.locale = App.locale -- 641
			updateLocale() -- 642
			return teal.clear(true) -- 643
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 644
			if _anon_func_1(_with_0) then -- 645
				if "FullScreen" == settingName then -- 647
					config.fullScreen = App.fullScreen -- 647
				elseif "Position" == settingName then -- 648
					local _obj_0 = App.winPosition -- 648
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 648
				elseif "Size" == settingName then -- 649
					local width, height -- 650
					do -- 650
						local _obj_0 = App.winSize -- 650
						width, height = _obj_0.width, _obj_0.height -- 650
					end -- 650
					config.winWidth = width -- 651
					config.winHeight = height -- 652
				end -- 646
			end -- 645
		end -- 637
	end) -- 637
	_with_0:onAppWS(function(eventType, msg) -- 653
		if eventType == "Close" then -- 654
			if HttpServer.wsConnectionCount == 0 then -- 655
				updateEntries() -- 656
			end -- 655
			return -- 657
		end -- 654
		if not (eventType == "Receive") then -- 658
			return -- 658
		end -- 658
		local data = json.decode(msg) -- 659
		if not data then -- 660
			return -- 660
		end -- 660
		local _exp_0 = data.name -- 661
		if "SearchFiles" == _exp_0 then -- 662
			return handleSearchFiles(data) -- 663
		elseif "SearchFilesStop" == _exp_0 then -- 664
			if data.id == nil or data.id == activeSearchId then -- 665
				activeSearchId = 0 -- 666
			end -- 665
		end -- 661
	end) -- 653
	_with_0:slot("UpdateEntries", function() -- 667
		return updateEntries() -- 667
	end) -- 667
	return _with_0 -- 629
end -- 628
setupEventHandlers() -- 669
clearTempFiles() -- 670
local downloadFile -- 672
downloadFile = function(url, target) -- 672
	return Director.systemScheduler:schedule(once(function() -- 672
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 673
			if quit then -- 674
				return true -- 674
			end -- 674
			emit("AppWS", "Send", json.encode({ -- 676
				name = "Download", -- 676
				url = url, -- 676
				status = "downloading", -- 676
				progress = current / total -- 677
			})) -- 675
			return false -- 673
		end) -- 673
		return emit("AppWS", "Send", json.encode(success and { -- 680
			name = "Download", -- 680
			url = url, -- 680
			status = "completed", -- 680
			progress = 1.0 -- 681
		} or { -- 683
			name = "Download", -- 683
			url = url, -- 683
			status = "failed", -- 683
			progress = 0.0 -- 684
		})) -- 679
	end)) -- 672
end -- 672
_module_0["downloadFile"] = downloadFile -- 672
local _anon_func_2 = function(file, require, workDir) -- 695
	if workDir == nil then -- 695
		workDir = Path:getPath(file) -- 695
	end -- 695
	Content:insertSearchPath(1, workDir) -- 696
	local scriptPath = Path(workDir, "Script") -- 697
	if Content:exist(scriptPath) then -- 698
		Content:insertSearchPath(1, scriptPath) -- 699
	end -- 698
	local result = require(file) -- 700
	if "function" == type(result) then -- 701
		result() -- 701
	end -- 701
	return nil -- 702
end -- 695
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 731
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 731
	label.alignment = "Left" -- 732
	label.textWidth = width - fontSize -- 733
	label.text = err -- 734
	return label -- 731
end -- 731
local enterEntryAsync -- 687
enterEntryAsync = function(entry) -- 687
	isInEntry = false -- 688
	App.idled = false -- 689
	emit(Profiler.EventName, "ClearLoader") -- 690
	currentEntry = entry -- 691
	local file, workDir = entry.fileName, entry.workDir -- 692
	sleep() -- 693
	return xpcall(_anon_func_2, function(msg) -- 702
		local err = debug.traceback(msg) -- 704
		Log("Error", err) -- 705
		allClear() -- 706
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 707
		local viewWidth, viewHeight -- 708
		do -- 708
			local _obj_0 = View.size -- 708
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 708
		end -- 708
		local width, height = viewWidth - 20, viewHeight - 20 -- 709
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 710
		Director.ui:addChild((function() -- 711
			local root = AlignNode() -- 711
			do -- 712
				local _obj_0 = App.bufferSize -- 712
				width, height = _obj_0.width, _obj_0.height -- 712
			end -- 712
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 713
			root:onAppChange(function(settingName) -- 714
				if settingName == "Size" then -- 714
					do -- 715
						local _obj_0 = App.bufferSize -- 715
						width, height = _obj_0.width, _obj_0.height -- 715
					end -- 715
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 716
				end -- 714
			end) -- 714
			root:addChild((function() -- 717
				local _with_0 = ScrollArea({ -- 718
					width = width, -- 718
					height = height, -- 719
					paddingX = 0, -- 720
					paddingY = 50, -- 721
					viewWidth = height, -- 722
					viewHeight = height -- 723
				}) -- 717
				root:onAlignLayout(function(w, h) -- 725
					_with_0.position = Vec2(w / 2, h / 2) -- 726
					w = w - 20 -- 727
					h = h - 20 -- 728
					_with_0.view.children.first.textWidth = w - fontSize -- 729
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 730
				end) -- 725
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 731
				return _with_0 -- 717
			end)()) -- 717
			return root -- 711
		end)()) -- 711
		return err -- 735
	end, file, require, workDir) -- 694
end -- 687
_module_0["enterEntryAsync"] = enterEntryAsync -- 687
local enterDemoEntry -- 737
enterDemoEntry = function(entry) -- 737
	return thread(function() -- 737
		return enterEntryAsync(entry) -- 737
	end) -- 737
end -- 737
local reloadCurrentEntry -- 739
reloadCurrentEntry = function() -- 739
	if currentEntry then -- 740
		allClear() -- 741
		return enterDemoEntry(currentEntry) -- 742
	end -- 740
end -- 739
Director.clearColor = Color(0xff1a1a1a) -- 744
local descColor = Color(0xffa1a1a1) -- 745
local extraOperations -- 747
do -- 747
	local isOSSLicenseExist = Content:exist("LICENSES") -- 748
	local ossLicenses = nil -- 749
	local ossLicenseOpen = false -- 750
	local failedSetFolder = false -- 751
	local statusFlags = { -- 752
		"NoResize", -- 752
		"NoMove", -- 752
		"NoCollapse", -- 752
		"AlwaysAutoResize", -- 752
		"NoSavedSettings" -- 752
	} -- 752
	extraOperations = function() -- 759
		local zh = useChinese -- 760
		if isDesktop then -- 761
			local alwaysOnTop = config.alwaysOnTop -- 762
			local changed -- 763
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 763
			if changed then -- 763
				App.alwaysOnTop = alwaysOnTop -- 764
				config.alwaysOnTop = alwaysOnTop -- 765
			end -- 763
		end -- 761
		local showPreview, authRequired = config.showPreview, config.authRequired -- 766
		do -- 767
			local changed -- 767
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 767
			if changed then -- 767
				config.showPreview = showPreview -- 768
				updateEntries() -- 769
				if not showPreview then -- 770
					thread(function() -- 771
						collectgarbage() -- 772
						return Cache:removeUnused("Texture") -- 773
					end) -- 771
				end -- 770
			end -- 767
		end -- 767
		do -- 774
			local changed -- 774
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 774
			if changed then -- 774
				config.authRequired = authRequired -- 775
				HttpServer.authRequired = authRequired -- 776
			end -- 774
		end -- 774
		SameLine() -- 777
		TextColored(descColor, "(?)") -- 778
		if IsItemHovered() then -- 779
			BeginTooltip(function() -- 780
				return PushTextWrapPos(280, function() -- 781
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 782
				end) -- 781
			end) -- 780
		end -- 779
		do -- 783
			local themeColor = App.themeColor -- 784
			local writablePath = config.writablePath -- 785
			SeparatorText(zh and "工作目录" or "Workspace") -- 786
			PushTextWrapPos(400, function() -- 787
				return TextColored(themeColor, writablePath) -- 788
			end) -- 787
			if not isDesktop then -- 789
				goto skipSetting -- 789
			end -- 789
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 790
			if Button(zh and "改变目录" or "Set Folder") then -- 791
				App:openFileDialog(true, function(path) -- 792
					if path == "" then -- 793
						return -- 793
					end -- 793
					local relPath = Path:getRelative(Content.assetPath, path) -- 794
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 795
						return setWorkspace(path) -- 796
					else -- 798
						failedSetFolder = true -- 798
					end -- 795
				end) -- 792
			end -- 791
			if failedSetFolder then -- 799
				failedSetFolder = false -- 800
				OpenPopup(popupName) -- 801
			end -- 799
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 802
			BeginPopupModal(popupName, statusFlags, function() -- 803
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 804
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 805
					return CloseCurrentPopup() -- 806
				end -- 805
			end) -- 803
			SameLine() -- 807
			if Button(zh and "使用默认" or "Use Default") then -- 808
				setWorkspace(Content.appPath) -- 809
			end -- 808
			Separator() -- 810
			::skipSetting:: -- 811
		end -- 783
		if isOSSLicenseExist then -- 812
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 813
				if not ossLicenses then -- 814
					ossLicenses = { } -- 815
					local licenseText = Content:load("LICENSES") -- 816
					ossLicenseOpen = (licenseText ~= nil) -- 817
					if ossLicenseOpen then -- 817
						licenseText = licenseText:gsub("\r\n", "\n") -- 818
						for license in GSplit(licenseText, "\n--------\n", true) do -- 819
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 820
							if name then -- 820
								ossLicenses[#ossLicenses + 1] = { -- 821
									name, -- 821
									text -- 821
								} -- 821
							end -- 820
						end -- 819
					end -- 817
				else -- 823
					ossLicenseOpen = true -- 823
				end -- 814
			end -- 813
			if ossLicenseOpen then -- 824
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 825
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 826
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 827
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 828
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 831
						"NoSavedSettings" -- 831
					}, function() -- 832
						for _index_0 = 1, #ossLicenses do -- 832
							local _des_0 = ossLicenses[_index_0] -- 832
							local firstLine, text = _des_0[1], _des_0[2] -- 832
							local name, license = firstLine:match("(.+): (.+)") -- 833
							TextColored(themeColor, name) -- 834
							SameLine() -- 835
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 836
								return TextWrapped(text) -- 836
							end) -- 836
						end -- 832
					end) -- 828
				end) -- 828
			end -- 824
		end -- 812
		if not App.debugging then -- 838
			return -- 838
		end -- 838
		return TreeNode(zh and "开发操作" or "Development", function() -- 839
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 840
				OpenPopup("build") -- 840
			end -- 840
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 841
				return BeginPopup("build", function() -- 841
					if Selectable(zh and "编译" or "Compile") then -- 842
						doCompile(false) -- 842
					end -- 842
					Separator() -- 843
					if Selectable(zh and "压缩" or "Minify") then -- 844
						doCompile(true) -- 844
					end -- 844
					Separator() -- 845
					if Selectable(zh and "清理" or "Clean") then -- 846
						return doClean() -- 846
					end -- 846
				end) -- 841
			end) -- 841
			if isInEntry then -- 847
				if waitForWebStart then -- 848
					BeginDisabled(function() -- 849
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 849
					end) -- 849
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 850
					reloadDevEntry() -- 851
				end -- 848
			end -- 847
			do -- 852
				local changed -- 852
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 852
				if changed then -- 852
					View.scale = scaleContent and screenScale or 1 -- 853
				end -- 852
			end -- 852
			do -- 854
				local changed -- 854
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 854
				if changed then -- 854
					config.engineDev = engineDev -- 855
				end -- 854
			end -- 854
			if testingThread then -- 856
				return BeginDisabled(function() -- 857
					return Button(zh and "开始自动测试" or "Test automatically") -- 857
				end) -- 857
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 858
				testingThread = thread(function() -- 859
					local _ <close> = setmetatable({ }, { -- 860
						__close = function() -- 860
							allClear() -- 861
							testingThread = nil -- 862
							isInEntry = true -- 863
							currentEntry = nil -- 864
							return print("Testing done!") -- 865
						end -- 860
					}) -- 860
					for _, entry in ipairs(allEntries) do -- 866
						allClear() -- 867
						print("Start " .. tostring(entry.entryName)) -- 868
						enterDemoEntry(entry) -- 869
						sleep(2) -- 870
						print("Stop " .. tostring(entry.entryName)) -- 871
					end -- 866
				end) -- 859
			end -- 856
		end) -- 839
	end -- 759
end -- 747
local icon = Path("Script", "Dev", "icon_s.png") -- 873
local iconTex = nil -- 874
thread(function() -- 875
	if Cache:loadAsync(icon) then -- 875
		iconTex = Texture2D(icon) -- 875
	end -- 875
end) -- 875
local webStatus = nil -- 877
local urlClicked = nil -- 878
local authCode = string.format("%06d", math.random(0, 999999)) -- 880
local authCodeTTL = 30 -- 882
_module_0.getAuthCode = function() -- 883
	return authCode -- 883
end -- 883
_module_0.invalidateAuthCode = function() -- 884
	authCode = string.format("%06d", math.random(0, 999999)) -- 885
	authCodeTTL = 30 -- 886
end -- 884
local AuthSession -- 888
do -- 888
	local pending = nil -- 889
	local session = nil -- 890
	AuthSession = { -- 892
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 892
			pending = { -- 894
				sessionId = sessionId, -- 894
				confirmCode = confirmCode, -- 895
				expiresAt = expiresAt, -- 896
				ttl = ttl, -- 897
				approved = false -- 898
			} -- 893
		end, -- 892
		getPending = function() -- 900
			return pending -- 900
		end, -- 900
		approvePending = function(sessionId) -- 902
			if pending and pending.sessionId == sessionId then -- 903
				pending.approved = true -- 904
				return true -- 905
			end -- 903
			return false -- 906
		end, -- 902
		clearPending = function() -- 908
			pending = nil -- 908
		end, -- 908
		setSession = function(sessionId, sessionSecret) -- 910
			session = { -- 912
				sessionId = sessionId, -- 912
				sessionSecret = sessionSecret -- 913
			} -- 911
		end, -- 910
		getSession = function() -- 915
			return session -- 915
		end -- 915
	} -- 891
end -- 888
_module_0["AuthSession"] = AuthSession -- 888
local transparant = Color(0x0) -- 918
local windowFlags = { -- 919
	"NoTitleBar", -- 919
	"NoResize", -- 919
	"NoMove", -- 919
	"NoCollapse", -- 919
	"NoSavedSettings", -- 919
	"NoFocusOnAppearing", -- 919
	"NoBringToFrontOnFocus" -- 919
} -- 919
local statusFlags = { -- 928
	"NoTitleBar", -- 928
	"NoResize", -- 928
	"NoMove", -- 928
	"NoCollapse", -- 928
	"AlwaysAutoResize", -- 928
	"NoSavedSettings" -- 928
} -- 928
local displayWindowFlags = { -- 936
	"NoDecoration", -- 936
	"NoSavedSettings", -- 936
	"NoNav", -- 936
	"NoMove", -- 936
	"NoScrollWithMouse", -- 936
	"AlwaysAutoResize", -- 936
	"NoFocusOnAppearing" -- 936
} -- 936
local initFooter = true -- 945
local _anon_func_4 = function(allEntries, currentIndex) -- 986
	if currentIndex > 1 then -- 986
		return allEntries[currentIndex - 1] -- 987
	else -- 989
		return allEntries[#allEntries] -- 989
	end -- 986
end -- 986
local _anon_func_5 = function(allEntries, currentIndex) -- 993
	if currentIndex < #allEntries then -- 993
		return allEntries[currentIndex + 1] -- 994
	else -- 996
		return allEntries[1] -- 996
	end -- 993
end -- 993
footerWindow = threadLoop(function() -- 946
	local zh = useChinese -- 947
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 948
	if authCodeTTL <= 0 then -- 949
		authCodeTTL = 30 -- 950
		authCode = string.format("%06d", math.random(0, 999999)) -- 951
	end -- 949
	if HttpServer.wsConnectionCount > 0 then -- 952
		return -- 953
	end -- 952
	if Keyboard:isKeyDown("Escape") then -- 954
		allClear() -- 955
		App.devMode = false -- 956
		App:shutdown() -- 957
	end -- 954
	do -- 958
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 959
		if ctrl and Keyboard:isKeyDown("Q") then -- 960
			stop() -- 961
		end -- 960
		if ctrl and Keyboard:isKeyDown("Z") then -- 962
			reloadCurrentEntry() -- 963
		end -- 962
		if ctrl and Keyboard:isKeyDown(",") then -- 964
			if showFooter then -- 965
				showStats = not showStats -- 965
			else -- 965
				showStats = true -- 965
			end -- 965
			showFooter = true -- 966
			config.showFooter = showFooter -- 967
			config.showStats = showStats -- 968
		end -- 964
		if ctrl and Keyboard:isKeyDown(".") then -- 969
			if showFooter then -- 970
				showConsole = not showConsole -- 970
			else -- 970
				showConsole = true -- 970
			end -- 970
			showFooter = true -- 971
			config.showFooter = showFooter -- 972
			config.showConsole = showConsole -- 973
		end -- 969
		if ctrl and Keyboard:isKeyDown("/") then -- 974
			showFooter = not showFooter -- 975
			config.showFooter = showFooter -- 976
		end -- 974
		local left = ctrl and Keyboard:isKeyDown("Left") -- 977
		local right = ctrl and Keyboard:isKeyDown("Right") -- 978
		local currentIndex = nil -- 979
		for i, entry in ipairs(allEntries) do -- 980
			if currentEntry == entry then -- 981
				currentIndex = i -- 982
			end -- 981
		end -- 980
		if left then -- 983
			allClear() -- 984
			if currentIndex == nil then -- 985
				currentIndex = #allEntries + 1 -- 985
			end -- 985
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 986
		end -- 983
		if right then -- 990
			allClear() -- 991
			if currentIndex == nil then -- 992
				currentIndex = 0 -- 992
			end -- 992
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 993
		end -- 990
	end -- 958
	if not showEntry then -- 997
		return -- 997
	end -- 997
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 999
		reloadDevEntry() -- 1003
	end -- 999
	if initFooter then -- 1004
		initFooter = false -- 1005
	end -- 1004
	local width, height -- 1007
	do -- 1007
		local _obj_0 = App.visualSize -- 1007
		width, height = _obj_0.width, _obj_0.height -- 1007
	end -- 1007
	if isInEntry or showFooter then -- 1008
		SetNextWindowSize(Vec2(width, 50)) -- 1009
		SetNextWindowPos(Vec2(0, height - 50)) -- 1010
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1011
			return PushStyleVar("WindowRounding", 0, function() -- 1012
				return Begin("Footer", windowFlags, function() -- 1013
					Separator() -- 1014
					if iconTex then -- 1015
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1016
							showStats = not showStats -- 1017
							config.showStats = showStats -- 1018
						end -- 1016
						SameLine() -- 1019
						if Button(">_", Vec2(30, 30)) then -- 1020
							showConsole = not showConsole -- 1021
							config.showConsole = showConsole -- 1022
						end -- 1020
					end -- 1015
					if isInEntry and config.updateNotification then -- 1023
						SameLine() -- 1024
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1025
							allClear() -- 1026
							config.updateNotification = false -- 1027
							enterDemoEntry({ -- 1029
								entryName = "SelfUpdater", -- 1029
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1030
							}) -- 1028
						end -- 1025
					end -- 1023
					if not isInEntry then -- 1031
						SameLine() -- 1032
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1033
						local currentIndex = nil -- 1034
						for i, entry in ipairs(allEntries) do -- 1035
							if currentEntry == entry then -- 1036
								currentIndex = i -- 1037
							end -- 1036
						end -- 1035
						if currentIndex then -- 1038
							if currentIndex > 1 then -- 1039
								SameLine() -- 1040
								if Button("<<", Vec2(30, 30)) then -- 1041
									allClear() -- 1042
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1043
								end -- 1041
							end -- 1039
							if currentIndex < #allEntries then -- 1044
								SameLine() -- 1045
								if Button(">>", Vec2(30, 30)) then -- 1046
									allClear() -- 1047
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1048
								end -- 1046
							end -- 1044
						end -- 1038
						SameLine() -- 1049
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1050
							reloadCurrentEntry() -- 1051
						end -- 1050
						if back then -- 1052
							allClear() -- 1053
							isInEntry = true -- 1054
							currentEntry = nil -- 1055
						end -- 1052
					end -- 1031
				end) -- 1013
			end) -- 1012
		end) -- 1011
	end -- 1008
	local showWebIDE = isInEntry -- 1057
	if config.updateNotification then -- 1058
		if width < 460 then -- 1059
			showWebIDE = false -- 1060
		end -- 1059
	else -- 1062
		if width < 360 then -- 1062
			showWebIDE = false -- 1063
		end -- 1062
	end -- 1058
	if showWebIDE then -- 1064
		SetNextWindowBgAlpha(0.0) -- 1065
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1066
		Begin("Web IDE", displayWindowFlags, function() -- 1067
			local pending = AuthSession.getPending() -- 1068
			local hovered = false -- 1069
			if not pending then -- 1070
				do -- 1071
					local url -- 1071
					if webStatus ~= nil then -- 1071
						url = webStatus.url -- 1071
					end -- 1071
					if url then -- 1071
						if isDesktop and not config.fullScreen then -- 1072
							if urlClicked then -- 1073
								BeginDisabled(function() -- 1074
									return Button(url) -- 1074
								end) -- 1074
							elseif Button(url) then -- 1075
								urlClicked = once(function() -- 1076
									return sleep(5) -- 1076
								end) -- 1076
								App:openURL("http://localhost:8866") -- 1077
							end -- 1073
						else -- 1079
							TextColored(descColor, url) -- 1079
						end -- 1072
					else -- 1081
						TextColored(descColor, zh and '不可用' or 'not available') -- 1081
					end -- 1071
				end -- 1071
				hovered = IsItemHovered() -- 1082
				SameLine() -- 1083
			end -- 1070
			local themeColor = App.themeColor -- 1084
			if pending then -- 1085
				if not pending.approved then -- 1086
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1087
					local ttl = pending.ttl or 1 -- 1088
					PushStyleColor("Text", themeColor, function() -- 1089
						ImGui.ProgressBar(remaining / ttl, Vec2(40, -1), pending.confirmCode) -- 1090
						hovered = hovered or IsItemHovered() -- 1091
					end) -- 1089
					SameLine() -- 1092
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1093
						AuthSession.approvePending(pending.sessionId) -- 1094
					end -- 1093
					if hovered then -- 1095
						return BeginTooltip(function() -- 1096
							return PushTextWrapPos(280, function() -- 1097
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1098
							end) -- 1097
						end) -- 1096
					end -- 1095
				end -- 1086
			else -- 1100
				if config.authRequired then -- 1100
					PushStyleColor("Text", themeColor, function() -- 1101
						ImGui.ProgressBar(authCodeTTL / 30, Vec2(60, -1), authCode) -- 1102
						hovered = hovered or IsItemHovered() -- 1103
					end) -- 1101
					if hovered then -- 1104
						return BeginTooltip(function() -- 1105
							return PushTextWrapPos(280, function() -- 1106
								return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址并输入后面的 PIN 码来使用 Web IDE（PIN 仅用于一次认证）' or 'Open this address in a browser on this machine or another device on the local network and enter the PIN below to start the Web IDE (PIN is one-time)') -- 1107
							end) -- 1106
						end) -- 1105
					end -- 1104
				else -- 1109
					if hovered then -- 1109
						return BeginTooltip(function() -- 1110
							return PushTextWrapPos(280, function() -- 1111
								return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址' or 'Open this address in a browser on this machine or another device on the local network') -- 1112
							end) -- 1111
						end) -- 1110
					end -- 1109
				end -- 1100
			end -- 1085
		end) -- 1067
	end -- 1064
	if not isInEntry then -- 1114
		SetNextWindowSize(Vec2(50, 50)) -- 1115
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1116
		PushStyleColor("WindowBg", transparant, function() -- 1117
			return Begin("Show", displayWindowFlags, function() -- 1117
				if width >= 370 then -- 1118
					local changed -- 1119
					changed, showFooter = Checkbox("##dev", showFooter) -- 1119
					if changed then -- 1119
						config.showFooter = showFooter -- 1120
					end -- 1119
				end -- 1118
			end) -- 1117
		end) -- 1117
	end -- 1114
	if isInEntry or showFooter then -- 1122
		if showStats then -- 1123
			PushStyleVar("WindowRounding", 0, function() -- 1124
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1125
				SetNextWindowSize(Vec2(0, height - 50)) -- 1126
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1127
				config.showStats = showStats -- 1128
			end) -- 1124
		end -- 1123
		if showConsole then -- 1129
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1130
			return PushStyleVar("WindowRounding", 6, function() -- 1131
				return ShowConsole() -- 1132
			end) -- 1131
		end -- 1129
	end -- 1122
end) -- 946
local MaxWidth <const> = 960 -- 1134
local toolOpen = false -- 1136
local filterText = nil -- 1137
local anyEntryMatched = false -- 1138
local match -- 1139
match = function(name) -- 1139
	local res = not filterText or name:lower():match(filterText) -- 1140
	if res then -- 1141
		anyEntryMatched = true -- 1141
	end -- 1141
	return res -- 1142
end -- 1139
local sep -- 1144
sep = function() -- 1144
	return SeparatorText("") -- 1144
end -- 1144
local thinSep -- 1145
thinSep = function() -- 1145
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1145
end -- 1145
entryWindow = threadLoop(function() -- 1147
	if App.fpsLimited ~= config.fpsLimited then -- 1148
		config.fpsLimited = App.fpsLimited -- 1149
	end -- 1148
	if App.targetFPS ~= config.targetFPS then -- 1150
		config.targetFPS = App.targetFPS -- 1151
	end -- 1150
	if View.vsync ~= config.vsync then -- 1152
		config.vsync = View.vsync -- 1153
	end -- 1152
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1154
		config.fixedFPS = Director.scheduler.fixedFPS -- 1155
	end -- 1154
	if Director.profilerSending ~= config.webProfiler then -- 1156
		config.webProfiler = Director.profilerSending -- 1157
	end -- 1156
	if urlClicked then -- 1158
		local _, result = coroutine.resume(urlClicked) -- 1159
		if result then -- 1160
			coroutine.close(urlClicked) -- 1161
			urlClicked = nil -- 1162
		end -- 1160
	end -- 1158
	if not showEntry then -- 1163
		return -- 1163
	end -- 1163
	if not isInEntry then -- 1164
		return -- 1164
	end -- 1164
	local zh = useChinese -- 1165
	local themeColor = App.themeColor -- 1166
	if HttpServer.wsConnectionCount > 0 then -- 1167
		local width, height -- 1168
		do -- 1168
			local _obj_0 = App.visualSize -- 1168
			width, height = _obj_0.width, _obj_0.height -- 1168
		end -- 1168
		SetNextWindowBgAlpha(0.5) -- 1169
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1170
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1171
			Separator() -- 1172
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1173
			if iconTex then -- 1174
				Image(icon, Vec2(24, 24)) -- 1175
				SameLine() -- 1176
			end -- 1174
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1177
			TextColored(descColor, slogon) -- 1178
			return Separator() -- 1179
		end) -- 1171
		return -- 1180
	end -- 1167
	local fullWidth, height -- 1182
	do -- 1182
		local _obj_0 = App.visualSize -- 1182
		fullWidth, height = _obj_0.width, _obj_0.height -- 1182
	end -- 1182
	local width = math.min(MaxWidth, fullWidth) -- 1183
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1184
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1185
	SetNextWindowPos(Vec2.zero) -- 1186
	SetNextWindowBgAlpha(0) -- 1187
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1188
	do -- 1189
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1190
			return Begin("Dora Dev", windowFlags, function() -- 1191
				Dummy(Vec2(fullWidth - 20, 0)) -- 1192
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1193
				if fullWidth >= 400 then -- 1194
					SameLine() -- 1195
					Dummy(Vec2(fullWidth - 400, 0)) -- 1196
					SameLine() -- 1197
					SetNextItemWidth(zh and -95 or -140) -- 1198
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1199
						"AutoSelectAll" -- 1199
					}) then -- 1199
						config.filter = filterBuf.text -- 1200
					end -- 1199
					SameLine() -- 1201
					if Button(zh and '下载' or 'Download') then -- 1202
						allClear() -- 1203
						enterDemoEntry({ -- 1205
							entryName = "ResourceDownloader", -- 1205
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1206
						}) -- 1204
					end -- 1202
				end -- 1194
				Separator() -- 1207
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1208
			end) -- 1191
		end) -- 1190
	end -- 1189
	anyEntryMatched = false -- 1210
	SetNextWindowPos(Vec2(0, 50)) -- 1211
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1212
	do -- 1213
		return PushStyleColor("WindowBg", transparant, function() -- 1214
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1215
				return PushStyleVar("Alpha", 1, function() -- 1216
					return Begin("Content", windowFlags, function() -- 1217
						local DemoViewWidth <const> = 220 -- 1218
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1219
						if filterText then -- 1220
							filterText = filterText:lower() -- 1220
						end -- 1220
						if #gamesInDev > 0 then -- 1221
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1222
							Columns(columns, false) -- 1223
							local realViewWidth = GetColumnWidth() - 50 -- 1224
							for _index_0 = 1, #gamesInDev do -- 1225
								local game = gamesInDev[_index_0] -- 1225
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1226
								local displayName -- 1235
								if repo then -- 1235
									if zh then -- 1236
										displayName = repo.title.zh -- 1236
									else -- 1236
										displayName = repo.title.en -- 1236
									end -- 1236
								end -- 1235
								if displayName == nil then -- 1237
									displayName = gameName -- 1237
								end -- 1237
								if match(displayName) then -- 1238
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1239
									SameLine() -- 1240
									TextWrapped(displayName) -- 1241
									if columns > 1 then -- 1242
										if bannerFile then -- 1243
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1244
											local displayWidth <const> = realViewWidth -- 1245
											texHeight = displayWidth * texHeight / texWidth -- 1246
											texWidth = displayWidth -- 1247
											Dummy(Vec2.zero) -- 1248
											SameLine() -- 1249
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1250
										end -- 1243
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1251
											enterDemoEntry(game) -- 1252
										end -- 1251
									else -- 1254
										if bannerFile then -- 1254
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1255
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1256
											local sizing = 0.8 -- 1257
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1258
											texWidth = displayWidth * sizing -- 1259
											if texWidth > 500 then -- 1260
												sizing = 0.6 -- 1261
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1262
												texWidth = displayWidth * sizing -- 1263
											end -- 1260
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1264
											Dummy(Vec2(padding, 0)) -- 1265
											SameLine() -- 1266
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1267
										end -- 1254
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1268
											enterDemoEntry(game) -- 1269
										end -- 1268
									end -- 1242
									if #tests == 0 and #examples == 0 then -- 1270
										thinSep() -- 1271
									end -- 1270
									NextColumn() -- 1272
								end -- 1238
								local showSep = false -- 1273
								if #examples > 0 then -- 1274
									local showExample = false -- 1275
									do -- 1276
										local _accum_0 -- 1276
										for _index_1 = 1, #examples do -- 1276
											local _des_0 = examples[_index_1] -- 1276
											local entryName = _des_0.entryName -- 1276
											if match(entryName) then -- 1277
												_accum_0 = true -- 1277
												break -- 1277
											end -- 1277
										end -- 1276
										showExample = _accum_0 -- 1276
									end -- 1276
									if showExample then -- 1278
										showSep = true -- 1279
										Columns(1, false) -- 1280
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1281
										SameLine() -- 1282
										local opened -- 1283
										if (filterText ~= nil) then -- 1283
											opened = showExample -- 1283
										else -- 1283
											opened = false -- 1283
										end -- 1283
										if game.exampleOpen == nil then -- 1284
											game.exampleOpen = opened -- 1284
										end -- 1284
										SetNextItemOpen(game.exampleOpen) -- 1285
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1286
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1287
												Columns(maxColumns, false) -- 1288
												for _index_1 = 1, #examples do -- 1289
													local example = examples[_index_1] -- 1289
													local entryName = example.entryName -- 1290
													if not match(entryName) then -- 1291
														goto _continue_0 -- 1291
													end -- 1291
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1292
														if Button(entryName, Vec2(-1, 40)) then -- 1293
															enterDemoEntry(example) -- 1294
														end -- 1293
														return NextColumn() -- 1295
													end) -- 1292
													opened = true -- 1296
													::_continue_0:: -- 1290
												end -- 1289
											end) -- 1287
										end) -- 1286
										game.exampleOpen = opened -- 1297
									end -- 1278
								end -- 1274
								if #tests > 0 then -- 1298
									local showTest = false -- 1299
									do -- 1300
										local _accum_0 -- 1300
										for _index_1 = 1, #tests do -- 1300
											local _des_0 = tests[_index_1] -- 1300
											local entryName = _des_0.entryName -- 1300
											if match(entryName) then -- 1301
												_accum_0 = true -- 1301
												break -- 1301
											end -- 1301
										end -- 1300
										showTest = _accum_0 -- 1300
									end -- 1300
									if showTest then -- 1302
										showSep = true -- 1303
										Columns(1, false) -- 1304
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1305
										SameLine() -- 1306
										local opened -- 1307
										if (filterText ~= nil) then -- 1307
											opened = showTest -- 1307
										else -- 1307
											opened = false -- 1307
										end -- 1307
										if game.testOpen == nil then -- 1308
											game.testOpen = opened -- 1308
										end -- 1308
										SetNextItemOpen(game.testOpen) -- 1309
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1310
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1311
												Columns(maxColumns, false) -- 1312
												for _index_1 = 1, #tests do -- 1313
													local test = tests[_index_1] -- 1313
													local entryName = test.entryName -- 1314
													if not match(entryName) then -- 1315
														goto _continue_0 -- 1315
													end -- 1315
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1316
														if Button(entryName, Vec2(-1, 40)) then -- 1317
															enterDemoEntry(test) -- 1318
														end -- 1317
														return NextColumn() -- 1319
													end) -- 1316
													opened = true -- 1320
													::_continue_0:: -- 1314
												end -- 1313
											end) -- 1311
										end) -- 1310
										game.testOpen = opened -- 1321
									end -- 1302
								end -- 1298
								if showSep then -- 1322
									Columns(1, false) -- 1323
									thinSep() -- 1324
									Columns(columns, false) -- 1325
								end -- 1322
							end -- 1225
						end -- 1221
						if #doraTools > 0 then -- 1326
							local showTool = false -- 1327
							do -- 1328
								local _accum_0 -- 1328
								for _index_0 = 1, #doraTools do -- 1328
									local _des_0 = doraTools[_index_0] -- 1328
									local entryName = _des_0.entryName -- 1328
									if match(entryName) then -- 1329
										_accum_0 = true -- 1329
										break -- 1329
									end -- 1329
								end -- 1328
								showTool = _accum_0 -- 1328
							end -- 1328
							if not showTool then -- 1330
								goto endEntry -- 1330
							end -- 1330
							Columns(1, false) -- 1331
							TextColored(themeColor, "Dora SSR:") -- 1332
							SameLine() -- 1333
							Text(zh and "开发支持" or "Development Support") -- 1334
							Separator() -- 1335
							if #doraTools > 0 then -- 1336
								local opened -- 1337
								if (filterText ~= nil) then -- 1337
									opened = showTool -- 1337
								else -- 1337
									opened = false -- 1337
								end -- 1337
								SetNextItemOpen(toolOpen) -- 1338
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1339
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1340
										Columns(maxColumns, false) -- 1341
										for _index_0 = 1, #doraTools do -- 1342
											local example = doraTools[_index_0] -- 1342
											local entryName = example.entryName -- 1343
											if not match(entryName) then -- 1344
												goto _continue_0 -- 1344
											end -- 1344
											if Button(entryName, Vec2(-1, 40)) then -- 1345
												enterDemoEntry(example) -- 1346
											end -- 1345
											NextColumn() -- 1347
											::_continue_0:: -- 1343
										end -- 1342
										Columns(1, false) -- 1348
										opened = true -- 1349
									end) -- 1340
								end) -- 1339
								toolOpen = opened -- 1350
							end -- 1336
						end -- 1326
						::endEntry:: -- 1351
						if not anyEntryMatched then -- 1352
							SetNextWindowBgAlpha(0) -- 1353
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1354
							Begin("Entries Not Found", displayWindowFlags, function() -- 1355
								Separator() -- 1356
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1357
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1358
								return Separator() -- 1359
							end) -- 1355
						end -- 1352
						Columns(1, false) -- 1360
						Dummy(Vec2(100, 80)) -- 1361
						return ScrollWhenDraggingOnVoid() -- 1362
					end) -- 1217
				end) -- 1216
			end) -- 1215
		end) -- 1214
	end -- 1213
end) -- 1147
webStatus = require("Script.Dev.WebServer") -- 1364
return _module_0 -- 1
