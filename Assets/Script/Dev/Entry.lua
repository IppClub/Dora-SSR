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
	local path = payload.path or "" -- 595
	local exts = payload.exts or { } -- 596
	local extensionLevels = payload.extensionLevels or { } -- 597
	local excludes = payload.excludes or { } -- 598
	local pattern = payload.pattern or "" -- 599
	if pattern == "" then -- 600
		return -- 600
	end -- 600
	local useRegex = payload.useRegex == true -- 601
	local caseSensitive = payload.caseSensitive == true -- 602
	local includeContent = payload.includeContent ~= false -- 603
	local contentWindow = payload.contentWindow or 0 -- 604
	return Director.systemScheduler:schedule(once(function() -- 605
		local stopped = false -- 606
		Content:searchFilesAsync(path, exts, extensionLevels, excludes, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 607
			if activeSearchId ~= id then -- 608
				stopped = true -- 609
				return true -- 610
			end -- 608
			emit("AppWS", "Send", json.encode({ -- 612
				name = "SearchFilesResult", -- 612
				id = id, -- 612
				result = result -- 612
			})) -- 611
			return false -- 614
		end) -- 607
		return emit("AppWS", "Send", json.encode({ -- 616
			name = "SearchFilesDone", -- 616
			id = id, -- 616
			stopped = stopped -- 616
		})) -- 615
	end)) -- 605
end -- 590
local stop -- 619
stop = function() -- 619
	if isInEntry then -- 620
		return false -- 620
	end -- 620
	allClear() -- 621
	isInEntry = true -- 622
	currentEntry = nil -- 623
	return true -- 624
end -- 619
_module_0["stop"] = stop -- 619
local _anon_func_1 = function(_with_0) -- 643
	local _val_0 = App.platform -- 643
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 643
end -- 643
setupEventHandlers = function() -- 626
	local _with_0 = Director.postNode -- 627
	_with_0:onAppEvent(function(eventType) -- 628
		if "Quit" == eventType then -- 629
			quit = true -- 630
			allClear() -- 631
			return clearTempFiles() -- 632
		elseif "Shutdown" == eventType then -- 633
			return stop() -- 634
		end -- 628
	end) -- 628
	_with_0:onAppChange(function(settingName) -- 635
		if "Theme" == settingName then -- 636
			config.themeColor = App.themeColor:toARGB() -- 637
		elseif "Locale" == settingName then -- 638
			config.locale = App.locale -- 639
			updateLocale() -- 640
			return teal.clear(true) -- 641
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 642
			if _anon_func_1(_with_0) then -- 643
				if "FullScreen" == settingName then -- 645
					config.fullScreen = App.fullScreen -- 645
				elseif "Position" == settingName then -- 646
					local _obj_0 = App.winPosition -- 646
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 646
				elseif "Size" == settingName then -- 647
					local width, height -- 648
					do -- 648
						local _obj_0 = App.winSize -- 648
						width, height = _obj_0.width, _obj_0.height -- 648
					end -- 648
					config.winWidth = width -- 649
					config.winHeight = height -- 650
				end -- 644
			end -- 643
		end -- 635
	end) -- 635
	_with_0:onAppWS(function(eventType, msg) -- 651
		if eventType == "Close" then -- 652
			if HttpServer.wsConnectionCount == 0 then -- 653
				updateEntries() -- 654
			end -- 653
			return -- 655
		end -- 652
		if not (eventType == "Receive") then -- 656
			return -- 656
		end -- 656
		local data = json.decode(msg) -- 657
		if not data then -- 658
			return -- 658
		end -- 658
		local _exp_0 = data.name -- 659
		if "SearchFiles" == _exp_0 then -- 660
			return handleSearchFiles(data) -- 661
		elseif "SearchFilesStop" == _exp_0 then -- 662
			if data.id == nil or data.id == activeSearchId then -- 663
				activeSearchId = 0 -- 664
			end -- 663
		end -- 659
	end) -- 651
	_with_0:slot("UpdateEntries", function() -- 665
		return updateEntries() -- 665
	end) -- 665
	return _with_0 -- 627
end -- 626
setupEventHandlers() -- 667
clearTempFiles() -- 668
local downloadFile -- 670
downloadFile = function(url, target) -- 670
	return Director.systemScheduler:schedule(once(function() -- 670
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 671
			if quit then -- 672
				return true -- 672
			end -- 672
			emit("AppWS", "Send", json.encode({ -- 674
				name = "Download", -- 674
				url = url, -- 674
				status = "downloading", -- 674
				progress = current / total -- 675
			})) -- 673
			return false -- 671
		end) -- 671
		return emit("AppWS", "Send", json.encode(success and { -- 678
			name = "Download", -- 678
			url = url, -- 678
			status = "completed", -- 678
			progress = 1.0 -- 679
		} or { -- 681
			name = "Download", -- 681
			url = url, -- 681
			status = "failed", -- 681
			progress = 0.0 -- 682
		})) -- 677
	end)) -- 670
end -- 670
_module_0["downloadFile"] = downloadFile -- 670
local _anon_func_2 = function(file, require, workDir) -- 693
	if workDir == nil then -- 693
		workDir = Path:getPath(file) -- 693
	end -- 693
	Content:insertSearchPath(1, workDir) -- 694
	local scriptPath = Path(workDir, "Script") -- 695
	if Content:exist(scriptPath) then -- 696
		Content:insertSearchPath(1, scriptPath) -- 697
	end -- 696
	local result = require(file) -- 698
	if "function" == type(result) then -- 699
		result() -- 699
	end -- 699
	return nil -- 700
end -- 693
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 729
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 729
	label.alignment = "Left" -- 730
	label.textWidth = width - fontSize -- 731
	label.text = err -- 732
	return label -- 729
end -- 729
local enterEntryAsync -- 685
enterEntryAsync = function(entry) -- 685
	isInEntry = false -- 686
	App.idled = false -- 687
	emit(Profiler.EventName, "ClearLoader") -- 688
	currentEntry = entry -- 689
	local file, workDir = entry.fileName, entry.workDir -- 690
	sleep() -- 691
	return xpcall(_anon_func_2, function(msg) -- 700
		local err = debug.traceback(msg) -- 702
		Log("Error", err) -- 703
		allClear() -- 704
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 705
		local viewWidth, viewHeight -- 706
		do -- 706
			local _obj_0 = View.size -- 706
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 706
		end -- 706
		local width, height = viewWidth - 20, viewHeight - 20 -- 707
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 708
		Director.ui:addChild((function() -- 709
			local root = AlignNode() -- 709
			do -- 710
				local _obj_0 = App.bufferSize -- 710
				width, height = _obj_0.width, _obj_0.height -- 710
			end -- 710
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 711
			root:onAppChange(function(settingName) -- 712
				if settingName == "Size" then -- 712
					do -- 713
						local _obj_0 = App.bufferSize -- 713
						width, height = _obj_0.width, _obj_0.height -- 713
					end -- 713
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 714
				end -- 712
			end) -- 712
			root:addChild((function() -- 715
				local _with_0 = ScrollArea({ -- 716
					width = width, -- 716
					height = height, -- 717
					paddingX = 0, -- 718
					paddingY = 50, -- 719
					viewWidth = height, -- 720
					viewHeight = height -- 721
				}) -- 715
				root:onAlignLayout(function(w, h) -- 723
					_with_0.position = Vec2(w / 2, h / 2) -- 724
					w = w - 20 -- 725
					h = h - 20 -- 726
					_with_0.view.children.first.textWidth = w - fontSize -- 727
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 728
				end) -- 723
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 729
				return _with_0 -- 715
			end)()) -- 715
			return root -- 709
		end)()) -- 709
		return err -- 733
	end, file, require, workDir) -- 692
end -- 685
_module_0["enterEntryAsync"] = enterEntryAsync -- 685
local enterDemoEntry -- 735
enterDemoEntry = function(entry) -- 735
	return thread(function() -- 735
		return enterEntryAsync(entry) -- 735
	end) -- 735
end -- 735
local reloadCurrentEntry -- 737
reloadCurrentEntry = function() -- 737
	if currentEntry then -- 738
		allClear() -- 739
		return enterDemoEntry(currentEntry) -- 740
	end -- 738
end -- 737
Director.clearColor = Color(0xff1a1a1a) -- 742
local descColor = Color(0xffa1a1a1) -- 743
local extraOperations -- 745
do -- 745
	local isOSSLicenseExist = Content:exist("LICENSES") -- 746
	local ossLicenses = nil -- 747
	local ossLicenseOpen = false -- 748
	local failedSetFolder = false -- 749
	local statusFlags = { -- 750
		"NoResize", -- 750
		"NoMove", -- 750
		"NoCollapse", -- 750
		"AlwaysAutoResize", -- 750
		"NoSavedSettings" -- 750
	} -- 750
	extraOperations = function() -- 757
		local zh = useChinese -- 758
		if isDesktop then -- 759
			local alwaysOnTop = config.alwaysOnTop -- 760
			local changed -- 761
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 761
			if changed then -- 761
				App.alwaysOnTop = alwaysOnTop -- 762
				config.alwaysOnTop = alwaysOnTop -- 763
			end -- 761
		end -- 759
		local showPreview, authRequired = config.showPreview, config.authRequired -- 764
		do -- 765
			local changed -- 765
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 765
			if changed then -- 765
				config.showPreview = showPreview -- 766
				updateEntries() -- 767
				if not showPreview then -- 768
					thread(function() -- 769
						collectgarbage() -- 770
						return Cache:removeUnused("Texture") -- 771
					end) -- 769
				end -- 768
			end -- 765
		end -- 765
		do -- 772
			local changed -- 772
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 772
			if changed then -- 772
				config.authRequired = authRequired -- 773
				HttpServer.authRequired = authRequired -- 774
			end -- 772
		end -- 772
		SameLine() -- 775
		TextColored(descColor, "(?)") -- 776
		if IsItemHovered() then -- 777
			BeginTooltip(function() -- 778
				return PushTextWrapPos(280, function() -- 779
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 780
				end) -- 779
			end) -- 778
		end -- 777
		do -- 781
			local themeColor = App.themeColor -- 782
			local writablePath = config.writablePath -- 783
			SeparatorText(zh and "工作目录" or "Workspace") -- 784
			PushTextWrapPos(400, function() -- 785
				return TextColored(themeColor, writablePath) -- 786
			end) -- 785
			if not isDesktop then -- 787
				goto skipSetting -- 787
			end -- 787
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 788
			if Button(zh and "改变目录" or "Set Folder") then -- 789
				App:openFileDialog(true, function(path) -- 790
					if path == "" then -- 791
						return -- 791
					end -- 791
					local relPath = Path:getRelative(Content.assetPath, path) -- 792
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 793
						return setWorkspace(path) -- 794
					else -- 796
						failedSetFolder = true -- 796
					end -- 793
				end) -- 790
			end -- 789
			if failedSetFolder then -- 797
				failedSetFolder = false -- 798
				OpenPopup(popupName) -- 799
			end -- 797
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 800
			BeginPopupModal(popupName, statusFlags, function() -- 801
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 802
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 803
					return CloseCurrentPopup() -- 804
				end -- 803
			end) -- 801
			SameLine() -- 805
			if Button(zh and "使用默认" or "Use Default") then -- 806
				setWorkspace(Content.appPath) -- 807
			end -- 806
			Separator() -- 808
			::skipSetting:: -- 809
		end -- 781
		if isOSSLicenseExist then -- 810
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 811
				if not ossLicenses then -- 812
					ossLicenses = { } -- 813
					local licenseText = Content:load("LICENSES") -- 814
					ossLicenseOpen = (licenseText ~= nil) -- 815
					if ossLicenseOpen then -- 815
						licenseText = licenseText:gsub("\r\n", "\n") -- 816
						for license in GSplit(licenseText, "\n--------\n", true) do -- 817
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 818
							if name then -- 818
								ossLicenses[#ossLicenses + 1] = { -- 819
									name, -- 819
									text -- 819
								} -- 819
							end -- 818
						end -- 817
					end -- 815
				else -- 821
					ossLicenseOpen = true -- 821
				end -- 812
			end -- 811
			if ossLicenseOpen then -- 822
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 823
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 824
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 825
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 826
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 829
						"NoSavedSettings" -- 829
					}, function() -- 830
						for _index_0 = 1, #ossLicenses do -- 830
							local _des_0 = ossLicenses[_index_0] -- 830
							local firstLine, text = _des_0[1], _des_0[2] -- 830
							local name, license = firstLine:match("(.+): (.+)") -- 831
							TextColored(themeColor, name) -- 832
							SameLine() -- 833
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 834
								return TextWrapped(text) -- 834
							end) -- 834
						end -- 830
					end) -- 826
				end) -- 826
			end -- 822
		end -- 810
		if not App.debugging then -- 836
			return -- 836
		end -- 836
		return TreeNode(zh and "开发操作" or "Development", function() -- 837
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 838
				OpenPopup("build") -- 838
			end -- 838
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 839
				return BeginPopup("build", function() -- 839
					if Selectable(zh and "编译" or "Compile") then -- 840
						doCompile(false) -- 840
					end -- 840
					Separator() -- 841
					if Selectable(zh and "压缩" or "Minify") then -- 842
						doCompile(true) -- 842
					end -- 842
					Separator() -- 843
					if Selectable(zh and "清理" or "Clean") then -- 844
						return doClean() -- 844
					end -- 844
				end) -- 839
			end) -- 839
			if isInEntry then -- 845
				if waitForWebStart then -- 846
					BeginDisabled(function() -- 847
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 847
					end) -- 847
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 848
					reloadDevEntry() -- 849
				end -- 846
			end -- 845
			do -- 850
				local changed -- 850
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 850
				if changed then -- 850
					View.scale = scaleContent and screenScale or 1 -- 851
				end -- 850
			end -- 850
			do -- 852
				local changed -- 852
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 852
				if changed then -- 852
					config.engineDev = engineDev -- 853
				end -- 852
			end -- 852
			if testingThread then -- 854
				return BeginDisabled(function() -- 855
					return Button(zh and "开始自动测试" or "Test automatically") -- 855
				end) -- 855
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 856
				testingThread = thread(function() -- 857
					local _ <close> = setmetatable({ }, { -- 858
						__close = function() -- 858
							allClear() -- 859
							testingThread = nil -- 860
							isInEntry = true -- 861
							currentEntry = nil -- 862
							return print("Testing done!") -- 863
						end -- 858
					}) -- 858
					for _, entry in ipairs(allEntries) do -- 864
						allClear() -- 865
						print("Start " .. tostring(entry.entryName)) -- 866
						enterDemoEntry(entry) -- 867
						sleep(2) -- 868
						print("Stop " .. tostring(entry.entryName)) -- 869
					end -- 864
				end) -- 857
			end -- 854
		end) -- 837
	end -- 757
end -- 745
local icon = Path("Script", "Dev", "icon_s.png") -- 871
local iconTex = nil -- 872
thread(function() -- 873
	if Cache:loadAsync(icon) then -- 873
		iconTex = Texture2D(icon) -- 873
	end -- 873
end) -- 873
local webStatus = nil -- 875
local urlClicked = nil -- 876
local authCode = string.format("%06d", math.random(0, 999999)) -- 878
local authCodeTTL = 30 -- 880
_module_0.getAuthCode = function() -- 881
	return authCode -- 881
end -- 881
_module_0.invalidateAuthCode = function() -- 882
	authCode = string.format("%06d", math.random(0, 999999)) -- 883
	authCodeTTL = 30 -- 884
end -- 882
local AuthSession -- 886
do -- 886
	local pending = nil -- 887
	local session = nil -- 888
	AuthSession = { -- 890
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 890
			pending = { -- 892
				sessionId = sessionId, -- 892
				confirmCode = confirmCode, -- 893
				expiresAt = expiresAt, -- 894
				ttl = ttl, -- 895
				approved = false -- 896
			} -- 891
		end, -- 890
		getPending = function() -- 898
			return pending -- 898
		end, -- 898
		approvePending = function(sessionId) -- 900
			if pending and pending.sessionId == sessionId then -- 901
				pending.approved = true -- 902
				return true -- 903
			end -- 901
			return false -- 904
		end, -- 900
		clearPending = function() -- 906
			pending = nil -- 906
		end, -- 906
		setSession = function(sessionId, sessionSecret) -- 908
			session = { -- 910
				sessionId = sessionId, -- 910
				sessionSecret = sessionSecret -- 911
			} -- 909
		end, -- 908
		getSession = function() -- 913
			return session -- 913
		end -- 913
	} -- 889
end -- 886
_module_0["AuthSession"] = AuthSession -- 886
local transparant = Color(0x0) -- 916
local windowFlags = { -- 917
	"NoTitleBar", -- 917
	"NoResize", -- 917
	"NoMove", -- 917
	"NoCollapse", -- 917
	"NoSavedSettings", -- 917
	"NoFocusOnAppearing", -- 917
	"NoBringToFrontOnFocus" -- 917
} -- 917
local statusFlags = { -- 926
	"NoTitleBar", -- 926
	"NoResize", -- 926
	"NoMove", -- 926
	"NoCollapse", -- 926
	"AlwaysAutoResize", -- 926
	"NoSavedSettings" -- 926
} -- 926
local displayWindowFlags = { -- 934
	"NoDecoration", -- 934
	"NoSavedSettings", -- 934
	"NoNav", -- 934
	"NoMove", -- 934
	"NoScrollWithMouse", -- 934
	"AlwaysAutoResize", -- 934
	"NoFocusOnAppearing" -- 934
} -- 934
local initFooter = true -- 943
local _anon_func_4 = function(allEntries, currentIndex) -- 984
	if currentIndex > 1 then -- 984
		return allEntries[currentIndex - 1] -- 985
	else -- 987
		return allEntries[#allEntries] -- 987
	end -- 984
end -- 984
local _anon_func_5 = function(allEntries, currentIndex) -- 991
	if currentIndex < #allEntries then -- 991
		return allEntries[currentIndex + 1] -- 992
	else -- 994
		return allEntries[1] -- 994
	end -- 991
end -- 991
footerWindow = threadLoop(function() -- 944
	local zh = useChinese -- 945
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 946
	if authCodeTTL <= 0 then -- 947
		authCodeTTL = 30 -- 948
		authCode = string.format("%06d", math.random(0, 999999)) -- 949
	end -- 947
	if HttpServer.wsConnectionCount > 0 then -- 950
		return -- 951
	end -- 950
	if Keyboard:isKeyDown("Escape") then -- 952
		allClear() -- 953
		App.devMode = false -- 954
		App:shutdown() -- 955
	end -- 952
	do -- 956
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 957
		if ctrl and Keyboard:isKeyDown("Q") then -- 958
			stop() -- 959
		end -- 958
		if ctrl and Keyboard:isKeyDown("Z") then -- 960
			reloadCurrentEntry() -- 961
		end -- 960
		if ctrl and Keyboard:isKeyDown(",") then -- 962
			if showFooter then -- 963
				showStats = not showStats -- 963
			else -- 963
				showStats = true -- 963
			end -- 963
			showFooter = true -- 964
			config.showFooter = showFooter -- 965
			config.showStats = showStats -- 966
		end -- 962
		if ctrl and Keyboard:isKeyDown(".") then -- 967
			if showFooter then -- 968
				showConsole = not showConsole -- 968
			else -- 968
				showConsole = true -- 968
			end -- 968
			showFooter = true -- 969
			config.showFooter = showFooter -- 970
			config.showConsole = showConsole -- 971
		end -- 967
		if ctrl and Keyboard:isKeyDown("/") then -- 972
			showFooter = not showFooter -- 973
			config.showFooter = showFooter -- 974
		end -- 972
		local left = ctrl and Keyboard:isKeyDown("Left") -- 975
		local right = ctrl and Keyboard:isKeyDown("Right") -- 976
		local currentIndex = nil -- 977
		for i, entry in ipairs(allEntries) do -- 978
			if currentEntry == entry then -- 979
				currentIndex = i -- 980
			end -- 979
		end -- 978
		if left then -- 981
			allClear() -- 982
			if currentIndex == nil then -- 983
				currentIndex = #allEntries + 1 -- 983
			end -- 983
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 984
		end -- 981
		if right then -- 988
			allClear() -- 989
			if currentIndex == nil then -- 990
				currentIndex = 0 -- 990
			end -- 990
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 991
		end -- 988
	end -- 956
	if not showEntry then -- 995
		return -- 995
	end -- 995
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 997
		reloadDevEntry() -- 1001
	end -- 997
	if initFooter then -- 1002
		initFooter = false -- 1003
	end -- 1002
	local width, height -- 1005
	do -- 1005
		local _obj_0 = App.visualSize -- 1005
		width, height = _obj_0.width, _obj_0.height -- 1005
	end -- 1005
	if isInEntry or showFooter then -- 1006
		SetNextWindowSize(Vec2(width, 50)) -- 1007
		SetNextWindowPos(Vec2(0, height - 50)) -- 1008
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1009
			return PushStyleVar("WindowRounding", 0, function() -- 1010
				return Begin("Footer", windowFlags, function() -- 1011
					Separator() -- 1012
					if iconTex then -- 1013
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1014
							showStats = not showStats -- 1015
							config.showStats = showStats -- 1016
						end -- 1014
						SameLine() -- 1017
						if Button(">_", Vec2(30, 30)) then -- 1018
							showConsole = not showConsole -- 1019
							config.showConsole = showConsole -- 1020
						end -- 1018
					end -- 1013
					if isInEntry and config.updateNotification then -- 1021
						SameLine() -- 1022
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1023
							allClear() -- 1024
							config.updateNotification = false -- 1025
							enterDemoEntry({ -- 1027
								entryName = "SelfUpdater", -- 1027
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1028
							}) -- 1026
						end -- 1023
					end -- 1021
					if not isInEntry then -- 1029
						SameLine() -- 1030
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1031
						local currentIndex = nil -- 1032
						for i, entry in ipairs(allEntries) do -- 1033
							if currentEntry == entry then -- 1034
								currentIndex = i -- 1035
							end -- 1034
						end -- 1033
						if currentIndex then -- 1036
							if currentIndex > 1 then -- 1037
								SameLine() -- 1038
								if Button("<<", Vec2(30, 30)) then -- 1039
									allClear() -- 1040
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1041
								end -- 1039
							end -- 1037
							if currentIndex < #allEntries then -- 1042
								SameLine() -- 1043
								if Button(">>", Vec2(30, 30)) then -- 1044
									allClear() -- 1045
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1046
								end -- 1044
							end -- 1042
						end -- 1036
						SameLine() -- 1047
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1048
							reloadCurrentEntry() -- 1049
						end -- 1048
						if back then -- 1050
							allClear() -- 1051
							isInEntry = true -- 1052
							currentEntry = nil -- 1053
						end -- 1050
					end -- 1029
				end) -- 1011
			end) -- 1010
		end) -- 1009
	end -- 1006
	local showWebIDE = isInEntry -- 1055
	if config.updateNotification then -- 1056
		if width < 460 then -- 1057
			showWebIDE = false -- 1058
		end -- 1057
	else -- 1060
		if width < 360 then -- 1060
			showWebIDE = false -- 1061
		end -- 1060
	end -- 1056
	if showWebIDE then -- 1062
		SetNextWindowBgAlpha(0.0) -- 1063
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1064
		Begin("Web IDE", displayWindowFlags, function() -- 1065
			local pending = AuthSession.getPending() -- 1066
			local hovered = false -- 1067
			if not pending then -- 1068
				do -- 1069
					local url -- 1069
					if webStatus ~= nil then -- 1069
						url = webStatus.url -- 1069
					end -- 1069
					if url then -- 1069
						if isDesktop and not config.fullScreen then -- 1070
							if urlClicked then -- 1071
								BeginDisabled(function() -- 1072
									return Button(url) -- 1072
								end) -- 1072
							elseif Button(url) then -- 1073
								urlClicked = once(function() -- 1074
									return sleep(5) -- 1074
								end) -- 1074
								App:openURL("http://localhost:8866") -- 1075
							end -- 1071
						else -- 1077
							TextColored(descColor, url) -- 1077
						end -- 1070
					else -- 1079
						TextColored(descColor, zh and '不可用' or 'not available') -- 1079
					end -- 1069
				end -- 1069
				hovered = IsItemHovered() -- 1080
				SameLine() -- 1081
			end -- 1068
			local themeColor = App.themeColor -- 1082
			if pending then -- 1083
				if not pending.approved then -- 1084
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1085
					local ttl = pending.ttl or 1 -- 1086
					PushStyleColor("Text", themeColor, function() -- 1087
						ImGui.ProgressBar(remaining / ttl, Vec2(40, -1), pending.confirmCode) -- 1088
						hovered = hovered or IsItemHovered() -- 1089
					end) -- 1087
					SameLine() -- 1090
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1091
						AuthSession.approvePending(pending.sessionId) -- 1092
					end -- 1091
					if hovered then -- 1093
						return BeginTooltip(function() -- 1094
							return PushTextWrapPos(280, function() -- 1095
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1096
							end) -- 1095
						end) -- 1094
					end -- 1093
				end -- 1084
			else -- 1098
				if config.authRequired then -- 1098
					PushStyleColor("Text", themeColor, function() -- 1099
						ImGui.ProgressBar(authCodeTTL / 30, Vec2(60, -1), authCode) -- 1100
						hovered = hovered or IsItemHovered() -- 1101
					end) -- 1099
					if hovered then -- 1102
						return BeginTooltip(function() -- 1103
							return PushTextWrapPos(280, function() -- 1104
								return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址并输入后面的 PIN 码来使用 Web IDE（PIN 仅用于一次认证）' or 'Open this address in a browser on this machine or another device on the local network and enter the PIN below to start the Web IDE (PIN is one-time)') -- 1105
							end) -- 1104
						end) -- 1103
					end -- 1102
				else -- 1107
					if hovered then -- 1107
						return BeginTooltip(function() -- 1108
							return PushTextWrapPos(280, function() -- 1109
								return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址' or 'Open this address in a browser on this machine or another device on the local network') -- 1110
							end) -- 1109
						end) -- 1108
					end -- 1107
				end -- 1098
			end -- 1083
		end) -- 1065
	end -- 1062
	if not isInEntry then -- 1112
		SetNextWindowSize(Vec2(50, 50)) -- 1113
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1114
		PushStyleColor("WindowBg", transparant, function() -- 1115
			return Begin("Show", displayWindowFlags, function() -- 1115
				if width >= 370 then -- 1116
					local changed -- 1117
					changed, showFooter = Checkbox("##dev", showFooter) -- 1117
					if changed then -- 1117
						config.showFooter = showFooter -- 1118
					end -- 1117
				end -- 1116
			end) -- 1115
		end) -- 1115
	end -- 1112
	if isInEntry or showFooter then -- 1120
		if showStats then -- 1121
			PushStyleVar("WindowRounding", 0, function() -- 1122
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1123
				SetNextWindowSize(Vec2(0, height - 50)) -- 1124
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1125
				config.showStats = showStats -- 1126
			end) -- 1122
		end -- 1121
		if showConsole then -- 1127
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1128
			return PushStyleVar("WindowRounding", 6, function() -- 1129
				return ShowConsole() -- 1130
			end) -- 1129
		end -- 1127
	end -- 1120
end) -- 944
local MaxWidth <const> = 960 -- 1132
local toolOpen = false -- 1134
local filterText = nil -- 1135
local anyEntryMatched = false -- 1136
local match -- 1137
match = function(name) -- 1137
	local res = not filterText or name:lower():match(filterText) -- 1138
	if res then -- 1139
		anyEntryMatched = true -- 1139
	end -- 1139
	return res -- 1140
end -- 1137
local sep -- 1142
sep = function() -- 1142
	return SeparatorText("") -- 1142
end -- 1142
local thinSep -- 1143
thinSep = function() -- 1143
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1143
end -- 1143
entryWindow = threadLoop(function() -- 1145
	if App.fpsLimited ~= config.fpsLimited then -- 1146
		config.fpsLimited = App.fpsLimited -- 1147
	end -- 1146
	if App.targetFPS ~= config.targetFPS then -- 1148
		config.targetFPS = App.targetFPS -- 1149
	end -- 1148
	if View.vsync ~= config.vsync then -- 1150
		config.vsync = View.vsync -- 1151
	end -- 1150
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1152
		config.fixedFPS = Director.scheduler.fixedFPS -- 1153
	end -- 1152
	if Director.profilerSending ~= config.webProfiler then -- 1154
		config.webProfiler = Director.profilerSending -- 1155
	end -- 1154
	if urlClicked then -- 1156
		local _, result = coroutine.resume(urlClicked) -- 1157
		if result then -- 1158
			coroutine.close(urlClicked) -- 1159
			urlClicked = nil -- 1160
		end -- 1158
	end -- 1156
	if not showEntry then -- 1161
		return -- 1161
	end -- 1161
	if not isInEntry then -- 1162
		return -- 1162
	end -- 1162
	local zh = useChinese -- 1163
	local themeColor = App.themeColor -- 1164
	if HttpServer.wsConnectionCount > 0 then -- 1165
		local width, height -- 1166
		do -- 1166
			local _obj_0 = App.visualSize -- 1166
			width, height = _obj_0.width, _obj_0.height -- 1166
		end -- 1166
		SetNextWindowBgAlpha(0.5) -- 1167
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1168
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1169
			Separator() -- 1170
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1171
			if iconTex then -- 1172
				Image(icon, Vec2(24, 24)) -- 1173
				SameLine() -- 1174
			end -- 1172
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1175
			TextColored(descColor, slogon) -- 1176
			return Separator() -- 1177
		end) -- 1169
		return -- 1178
	end -- 1165
	local fullWidth, height -- 1180
	do -- 1180
		local _obj_0 = App.visualSize -- 1180
		fullWidth, height = _obj_0.width, _obj_0.height -- 1180
	end -- 1180
	local width = math.min(MaxWidth, fullWidth) -- 1181
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1182
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1183
	SetNextWindowPos(Vec2.zero) -- 1184
	SetNextWindowBgAlpha(0) -- 1185
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 1186
	do -- 1187
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1188
			return Begin("Dora Dev", windowFlags, function() -- 1189
				Dummy(Vec2(fullWidth - 20, 0)) -- 1190
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1191
				if fullWidth >= 400 then -- 1192
					SameLine() -- 1193
					Dummy(Vec2(fullWidth - 400, 0)) -- 1194
					SameLine() -- 1195
					SetNextItemWidth(zh and -95 or -140) -- 1196
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1197
						"AutoSelectAll" -- 1197
					}) then -- 1197
						config.filter = filterBuf.text -- 1198
					end -- 1197
					SameLine() -- 1199
					if Button(zh and '下载' or 'Download') then -- 1200
						allClear() -- 1201
						enterDemoEntry({ -- 1203
							entryName = "ResourceDownloader", -- 1203
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1204
						}) -- 1202
					end -- 1200
				end -- 1192
				Separator() -- 1205
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1206
			end) -- 1189
		end) -- 1188
	end -- 1187
	anyEntryMatched = false -- 1208
	SetNextWindowPos(Vec2(0, 50)) -- 1209
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1210
	do -- 1211
		return PushStyleColor("WindowBg", transparant, function() -- 1212
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1213
				return PushStyleVar("Alpha", 1, function() -- 1214
					return Begin("Content", windowFlags, function() -- 1215
						local DemoViewWidth <const> = 220 -- 1216
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1217
						if filterText then -- 1218
							filterText = filterText:lower() -- 1218
						end -- 1218
						if #gamesInDev > 0 then -- 1219
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1220
							Columns(columns, false) -- 1221
							local realViewWidth = GetColumnWidth() - 50 -- 1222
							for _index_0 = 1, #gamesInDev do -- 1223
								local game = gamesInDev[_index_0] -- 1223
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1224
								local displayName -- 1233
								if repo then -- 1233
									if zh then -- 1234
										displayName = repo.title.zh -- 1234
									else -- 1234
										displayName = repo.title.en -- 1234
									end -- 1234
								end -- 1233
								if displayName == nil then -- 1235
									displayName = gameName -- 1235
								end -- 1235
								if match(displayName) then -- 1236
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1237
									SameLine() -- 1238
									TextWrapped(displayName) -- 1239
									if columns > 1 then -- 1240
										if bannerFile then -- 1241
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1242
											local displayWidth <const> = realViewWidth -- 1243
											texHeight = displayWidth * texHeight / texWidth -- 1244
											texWidth = displayWidth -- 1245
											Dummy(Vec2.zero) -- 1246
											SameLine() -- 1247
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1248
										end -- 1241
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1249
											enterDemoEntry(game) -- 1250
										end -- 1249
									else -- 1252
										if bannerFile then -- 1252
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1253
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1254
											local sizing = 0.8 -- 1255
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1256
											texWidth = displayWidth * sizing -- 1257
											if texWidth > 500 then -- 1258
												sizing = 0.6 -- 1259
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1260
												texWidth = displayWidth * sizing -- 1261
											end -- 1258
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1262
											Dummy(Vec2(padding, 0)) -- 1263
											SameLine() -- 1264
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1265
										end -- 1252
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1266
											enterDemoEntry(game) -- 1267
										end -- 1266
									end -- 1240
									if #tests == 0 and #examples == 0 then -- 1268
										thinSep() -- 1269
									end -- 1268
									NextColumn() -- 1270
								end -- 1236
								local showSep = false -- 1271
								if #examples > 0 then -- 1272
									local showExample = false -- 1273
									do -- 1274
										local _accum_0 -- 1274
										for _index_1 = 1, #examples do -- 1274
											local _des_0 = examples[_index_1] -- 1274
											local entryName = _des_0.entryName -- 1274
											if match(entryName) then -- 1275
												_accum_0 = true -- 1275
												break -- 1275
											end -- 1275
										end -- 1274
										showExample = _accum_0 -- 1274
									end -- 1274
									if showExample then -- 1276
										showSep = true -- 1277
										Columns(1, false) -- 1278
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1279
										SameLine() -- 1280
										local opened -- 1281
										if (filterText ~= nil) then -- 1281
											opened = showExample -- 1281
										else -- 1281
											opened = false -- 1281
										end -- 1281
										if game.exampleOpen == nil then -- 1282
											game.exampleOpen = opened -- 1282
										end -- 1282
										SetNextItemOpen(game.exampleOpen) -- 1283
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1284
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1285
												Columns(maxColumns, false) -- 1286
												for _index_1 = 1, #examples do -- 1287
													local example = examples[_index_1] -- 1287
													local entryName = example.entryName -- 1288
													if not match(entryName) then -- 1289
														goto _continue_0 -- 1289
													end -- 1289
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1290
														if Button(entryName, Vec2(-1, 40)) then -- 1291
															enterDemoEntry(example) -- 1292
														end -- 1291
														return NextColumn() -- 1293
													end) -- 1290
													opened = true -- 1294
													::_continue_0:: -- 1288
												end -- 1287
											end) -- 1285
										end) -- 1284
										game.exampleOpen = opened -- 1295
									end -- 1276
								end -- 1272
								if #tests > 0 then -- 1296
									local showTest = false -- 1297
									do -- 1298
										local _accum_0 -- 1298
										for _index_1 = 1, #tests do -- 1298
											local _des_0 = tests[_index_1] -- 1298
											local entryName = _des_0.entryName -- 1298
											if match(entryName) then -- 1299
												_accum_0 = true -- 1299
												break -- 1299
											end -- 1299
										end -- 1298
										showTest = _accum_0 -- 1298
									end -- 1298
									if showTest then -- 1300
										showSep = true -- 1301
										Columns(1, false) -- 1302
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1303
										SameLine() -- 1304
										local opened -- 1305
										if (filterText ~= nil) then -- 1305
											opened = showTest -- 1305
										else -- 1305
											opened = false -- 1305
										end -- 1305
										if game.testOpen == nil then -- 1306
											game.testOpen = opened -- 1306
										end -- 1306
										SetNextItemOpen(game.testOpen) -- 1307
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1308
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1309
												Columns(maxColumns, false) -- 1310
												for _index_1 = 1, #tests do -- 1311
													local test = tests[_index_1] -- 1311
													local entryName = test.entryName -- 1312
													if not match(entryName) then -- 1313
														goto _continue_0 -- 1313
													end -- 1313
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1314
														if Button(entryName, Vec2(-1, 40)) then -- 1315
															enterDemoEntry(test) -- 1316
														end -- 1315
														return NextColumn() -- 1317
													end) -- 1314
													opened = true -- 1318
													::_continue_0:: -- 1312
												end -- 1311
											end) -- 1309
										end) -- 1308
										game.testOpen = opened -- 1319
									end -- 1300
								end -- 1296
								if showSep then -- 1320
									Columns(1, false) -- 1321
									thinSep() -- 1322
									Columns(columns, false) -- 1323
								end -- 1320
							end -- 1223
						end -- 1219
						if #doraTools > 0 then -- 1324
							local showTool = false -- 1325
							do -- 1326
								local _accum_0 -- 1326
								for _index_0 = 1, #doraTools do -- 1326
									local _des_0 = doraTools[_index_0] -- 1326
									local entryName = _des_0.entryName -- 1326
									if match(entryName) then -- 1327
										_accum_0 = true -- 1327
										break -- 1327
									end -- 1327
								end -- 1326
								showTool = _accum_0 -- 1326
							end -- 1326
							if not showTool then -- 1328
								goto endEntry -- 1328
							end -- 1328
							Columns(1, false) -- 1329
							TextColored(themeColor, "Dora SSR:") -- 1330
							SameLine() -- 1331
							Text(zh and "开发支持" or "Development Support") -- 1332
							Separator() -- 1333
							if #doraTools > 0 then -- 1334
								local opened -- 1335
								if (filterText ~= nil) then -- 1335
									opened = showTool -- 1335
								else -- 1335
									opened = false -- 1335
								end -- 1335
								SetNextItemOpen(toolOpen) -- 1336
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1337
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1338
										Columns(maxColumns, false) -- 1339
										for _index_0 = 1, #doraTools do -- 1340
											local example = doraTools[_index_0] -- 1340
											local entryName = example.entryName -- 1341
											if not match(entryName) then -- 1342
												goto _continue_0 -- 1342
											end -- 1342
											if Button(entryName, Vec2(-1, 40)) then -- 1343
												enterDemoEntry(example) -- 1344
											end -- 1343
											NextColumn() -- 1345
											::_continue_0:: -- 1341
										end -- 1340
										Columns(1, false) -- 1346
										opened = true -- 1347
									end) -- 1338
								end) -- 1337
								toolOpen = opened -- 1348
							end -- 1334
						end -- 1324
						::endEntry:: -- 1349
						if not anyEntryMatched then -- 1350
							SetNextWindowBgAlpha(0) -- 1351
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1352
							Begin("Entries Not Found", displayWindowFlags, function() -- 1353
								Separator() -- 1354
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1355
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1356
								return Separator() -- 1357
							end) -- 1353
						end -- 1350
						Columns(1, false) -- 1358
						Dummy(Vec2(100, 80)) -- 1359
						return ScrollWhenDraggingOnVoid() -- 1360
					end) -- 1215
				end) -- 1214
			end) -- 1213
		end) -- 1212
	end -- 1211
end) -- 1145
webStatus = require("Script.Dev.WebServer") -- 1362
return _module_0 -- 1
