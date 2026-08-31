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
local math <const> = math -- 11
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
local pcall <const> = pcall -- 11
local Log <const> = Log -- 11
local tolua <const> = tolua -- 11
local Routine <const> = Routine -- 11
local Entity <const> = Entity -- 11
local Platformer <const> = Platformer -- 11
local Audio <const> = Audio -- 11
local ubox <const> = ubox -- 11
local collectgarbage <const> = collectgarbage -- 11
local Wasm <const> = Wasm -- 11
local sleep <const> = sleep -- 11
local once <const> = once -- 11
local emit <const> = emit -- 11
local Profiler <const> = Profiler -- 11
local xpcall <const> = xpcall -- 11
local debug <const> = debug -- 11
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
local SetNextWindowBgAlpha <const> = SetNextWindowBgAlpha -- 11
local SetNextWindowPos <const> = SetNextWindowPos -- 11
local SetWindowFocus <const> = SetWindowFocus -- 11
local ImageButton <const> = ImageButton -- 11
local ImGui <const> = ImGui -- 11
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 50
config:load() -- 83
if not (config.writablePath ~= nil) then -- 85
	config.writablePath = Content.appPath -- 86
end -- 85
if not (config.webIDEConnected ~= nil) then -- 88
	config.webIDEConnected = false -- 89
end -- 88
if (config.fpsLimited ~= nil) then -- 91
	App.fpsLimited = config.fpsLimited -- 92
else -- 94
	config.fpsLimited = App.fpsLimited -- 94
end -- 91
if (config.targetFPS ~= nil) then -- 96
	App.targetFPS = math.floor(config.targetFPS) -- 97
else -- 99
	config.targetFPS = App.targetFPS -- 99
end -- 96
if (config.vsync ~= nil) then -- 101
	View.vsync = config.vsync -- 102
else -- 104
	config.vsync = View.vsync -- 104
end -- 101
if (config.fixedFPS ~= nil) then -- 106
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 107
else -- 109
	config.fixedFPS = Director.scheduler.fixedFPS -- 109
end -- 106
if not (config.showPreview ~= nil) then -- 111
	config.showPreview = true -- 112
end -- 111
if not (config.mobileFeed ~= nil) then -- 114
	local _val_0 = App.platform -- 115
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 115
end -- 114
if not (config.webIDETourCompleted ~= nil) then -- 117
	config.webIDETourCompleted = false -- 118
end -- 117
if not (config.authRequired ~= nil) then -- 120
	local _val_0 = App.platform -- 121
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 121
end -- 120
HttpServer.authRequired = config.authRequired -- 122
local showEntry = true -- 124
isDesktop = false -- 126
if (function() -- 127
	local _val_0 = App.platform -- 127
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 127
end)() then -- 127
	isDesktop = true -- 128
	if config.fullScreen then -- 129
		App.fullScreen = true -- 130
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 131
		local size = Size(config.winWidth, config.winHeight) -- 132
		if App.winSize ~= size then -- 133
			App.winSize = size -- 134
		end -- 133
		local winX, winY -- 135
		do -- 135
			local _obj_0 = App.winPosition -- 135
			winX, winY = _obj_0.x, _obj_0.y -- 135
		end -- 135
		if (config.winX ~= nil) then -- 136
			winX = config.winX -- 137
		else -- 139
			config.winX = -1 -- 139
		end -- 136
		if (config.winY ~= nil) then -- 140
			winY = config.winY -- 141
		else -- 143
			config.winY = -1 -- 143
		end -- 140
		App.winPosition = Vec2(winX, winY) -- 144
	end -- 129
	if (config.alwaysOnTop ~= nil) then -- 145
		App.alwaysOnTop = config.alwaysOnTop -- 146
	else -- 148
		config.alwaysOnTop = false -- 148
	end -- 145
end -- 127
if (config.themeColor ~= nil) then -- 150
	App.themeColor = Color(config.themeColor) -- 151
else -- 153
	config.themeColor = App.themeColor:toARGB() -- 153
end -- 150
if not (config.locale ~= nil) then -- 155
	config.locale = App.locale -- 156
end -- 155
local showStats = false -- 158
if (config.showStats ~= nil) then -- 159
	showStats = config.showStats -- 160
else -- 162
	config.showStats = showStats -- 162
end -- 159
local showConsole = false -- 164
if (config.showConsole ~= nil) then -- 165
	showConsole = config.showConsole -- 166
else -- 168
	config.showConsole = showConsole -- 168
end -- 165
local showFooter = true -- 170
if (config.showFooter ~= nil) then -- 171
	showFooter = config.showFooter -- 172
else -- 174
	config.showFooter = showFooter -- 174
end -- 171
local setFooterVisible -- 176
setFooterVisible = function(visible) -- 176
	if visible == nil then -- 176
		visible = true -- 176
	end -- 176
	showFooter = visible -- 177
	config.showFooter = showFooter -- 178
end -- 176
_module_0["setFooterVisible"] = setFooterVisible -- 176
local filterBuf = Buffer(20) -- 180
if (config.filter ~= nil) then -- 181
	filterBuf.text = config.filter -- 182
else -- 184
	config.filter = "" -- 184
end -- 181
local engineDev = false -- 186
if (config.engineDev ~= nil) then -- 187
	engineDev = config.engineDev -- 188
else -- 190
	config.engineDev = engineDev -- 190
end -- 187
if (config.webProfiler ~= nil) then -- 192
	Director.profilerSending = config.webProfiler -- 193
else -- 195
	config.webProfiler = true -- 195
	Director.profilerSending = true -- 196
end -- 192
if not (config.drawerWidth ~= nil) then -- 198
	config.drawerWidth = 200 -- 199
end -- 198
_module_0.getConfig = function() -- 201
	return config -- 201
end -- 201
_module_0.getEngineDev = function() -- 202
	if not App.debugging then -- 203
		return false -- 203
	end -- 203
	return config.engineDev -- 204
end -- 202
local _anon_func_0 = function() -- 209
	local _val_0 = App.platform -- 209
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 209
end -- 209
_module_0.connectWebIDE = function() -- 206
	if not config.webIDEConnected then -- 207
		config.webIDEConnected = true -- 208
		if _anon_func_0() then -- 209
			local ratio = App.winSize.width / App.visualSize.width -- 210
			App.winSize = Size(640 * ratio, 480 * ratio) -- 211
		end -- 209
	end -- 207
end -- 206
local updateCheck -- 213
updateCheck = function() -- 213
	return thread(function() -- 213
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 214
		if res then -- 214
			local data = json.decode(res) -- 215
			if data then -- 215
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 216
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 217
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 218
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 219
				if na < a then -- 220
					goto not_new_version -- 221
				end -- 220
				if na == a then -- 222
					if nb < b then -- 223
						goto not_new_version -- 224
					end -- 223
					if nb == b then -- 225
						if nc < c then -- 226
							goto not_new_version -- 227
						end -- 226
						if nc == c then -- 228
							goto not_new_version -- 229
						end -- 228
					end -- 225
				end -- 222
				config.updateNotification = true -- 230
				::not_new_version:: -- 231
				config.lastUpdateCheck = os.time() -- 232
			end -- 215
		end -- 214
	end) -- 213
end -- 213
if (config.lastUpdateCheck ~= nil) then -- 234
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 235
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 236
		updateCheck() -- 237
	end -- 236
else -- 239
	updateCheck() -- 239
end -- 234
local Set, Struct, LintYueGlobals, GSplit -- 241
do -- 241
	local _obj_0 = require("Utils") -- 241
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 241
end -- 241
local yueext = yue.options.extension -- 242
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 244
local building = false -- 246
local getAllFiles -- 248
getAllFiles = function(path, exts, recursive) -- 248
	if recursive == nil then -- 248
		recursive = true -- 248
	end -- 248
	local filters = Set(exts) -- 249
	local files -- 250
	if recursive then -- 250
		files = Content:getAllFiles(path) -- 251
	else -- 253
		files = Content:getFiles(path) -- 253
	end -- 250
	local _accum_0 = { } -- 254
	local _len_0 = 1 -- 254
	for _index_0 = 1, #files do -- 254
		local file = files[_index_0] -- 254
		if not filters[Path:getExt(file)] then -- 255
			goto _continue_0 -- 255
		end -- 255
		_accum_0[_len_0] = file -- 256
		_len_0 = _len_0 + 1 -- 255
		::_continue_0:: -- 255
	end -- 254
	return _accum_0 -- 254
end -- 248
_module_0["getAllFiles"] = getAllFiles -- 248
local getFileEntries -- 258
getFileEntries = function(path, recursive, excludeFiles) -- 258
	if recursive == nil then -- 258
		recursive = true -- 258
	end -- 258
	if excludeFiles == nil then -- 258
		excludeFiles = nil -- 258
	end -- 258
	local entries = { } -- 259
	local excludes -- 260
	if excludeFiles then -- 260
		excludes = Set(excludeFiles) -- 261
	end -- 260
	local _list_0 = getAllFiles(path, { -- 262
		"lua", -- 262
		"xml", -- 262
		yueext, -- 262
		"tl" -- 262
	}, recursive) -- 262
	for _index_0 = 1, #_list_0 do -- 262
		local file = _list_0[_index_0] -- 262
		local entryName = Path:getName(file) -- 263
		if excludes and excludes[entryName] then -- 264
			goto _continue_0 -- 265
		end -- 264
		local fileName = Path:replaceExt(file, "") -- 266
		fileName = Path(path, fileName) -- 267
		local entryAdded -- 268
		for _index_1 = 1, #entries do -- 268
			local _des_0 = entries[_index_1] -- 268
			local ename, efile = _des_0.entryName, _des_0.fileName -- 268
			if entryName == ename and efile == fileName then -- 269
				entryAdded = true -- 269
				break -- 269
			end -- 269
		end -- 268
		if entryAdded then -- 270
			goto _continue_0 -- 270
		end -- 270
		local entry = { -- 271
			entryName = entryName, -- 271
			fileName = fileName -- 271
		} -- 271
		entries[#entries + 1] = entry -- 272
		::_continue_0:: -- 263
	end -- 262
	table.sort(entries, function(a, b) -- 273
		return a.entryName < b.entryName -- 273
	end) -- 273
	return entries -- 274
end -- 258
local getProjectEntries -- 276
getProjectEntries = function(path, noPreview) -- 276
	if noPreview == nil then -- 276
		noPreview = false -- 276
	end -- 276
	local entries = { } -- 277
	local _list_0 = Content:getDirs(path) -- 278
	for _index_0 = 1, #_list_0 do -- 278
		local dir = _list_0[_index_0] -- 278
		if dir:match("^%.") then -- 279
			goto _continue_0 -- 279
		end -- 279
		local _list_1 = getAllFiles(Path(path, dir), { -- 280
			"lua", -- 280
			"xml", -- 280
			yueext, -- 280
			"tl", -- 280
			"wasm" -- 280
		}) -- 280
		for _index_1 = 1, #_list_1 do -- 280
			local file = _list_1[_index_1] -- 280
			if "init" == Path:getName(file):lower() then -- 281
				local fileName = Path:replaceExt(file, "") -- 282
				fileName = Path(path, dir, fileName) -- 283
				local projectPath = Path:getPath(fileName) -- 284
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 285
				local repo = nil -- 286
				if Content:exist(repoFile) then -- 287
					local str = Content:load(repoFile) -- 288
					if str then -- 288
						repo = json.decode(str) -- 289
					end -- 288
				end -- 287
				local entryName = Path:getName(projectPath) -- 290
				local entryAdded -- 291
				for _index_2 = 1, #entries do -- 291
					local _des_0 = entries[_index_2] -- 291
					local ename, efile = _des_0.entryName, _des_0.fileName -- 291
					if entryName == ename and efile == fileName then -- 292
						entryAdded = true -- 292
						break -- 292
					end -- 292
				end -- 291
				if entryAdded then -- 293
					goto _continue_1 -- 293
				end -- 293
				local examples = { } -- 294
				local tests = { } -- 295
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 296
				if Content:exist(examplePath) then -- 297
					local _list_2 = getFileEntries(examplePath) -- 298
					for _index_2 = 1, #_list_2 do -- 298
						local _des_0 = _list_2[_index_2] -- 298
						local name, ePath = _des_0.entryName, _des_0.fileName -- 298
						local entry = { -- 300
							entryName = name, -- 300
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 301
							workDir = projectPath -- 302
						} -- 299
						examples[#examples + 1] = entry -- 304
					end -- 298
				end -- 297
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 305
				if Content:exist(testPath) then -- 306
					local _list_2 = getFileEntries(testPath) -- 307
					for _index_2 = 1, #_list_2 do -- 307
						local _des_0 = _list_2[_index_2] -- 307
						local name, tPath = _des_0.entryName, _des_0.fileName -- 307
						local entry = { -- 309
							entryName = name, -- 309
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 310
							workDir = projectPath -- 311
						} -- 308
						tests[#tests + 1] = entry -- 313
					end -- 307
				end -- 306
				local entry = { -- 314
					entryName = entryName, -- 314
					fileName = fileName, -- 314
					examples = examples, -- 314
					tests = tests, -- 314
					repo = repo -- 314
				} -- 314
				local bannerFile -- 315
				do -- 315
					local _val_0 -- 315
					repeat -- 315
						if noPreview then -- 316
							_val_0 = nil -- 316
							break -- 316
						end -- 316
						if not config.showPreview then -- 317
							_val_0 = nil -- 317
							break -- 317
						end -- 317
						local f = Path(projectPath, ".dora", "banner.jpg") -- 318
						if Content:exist(f) then -- 319
							_val_0 = f -- 319
							break -- 319
						end -- 319
						f = Path(projectPath, ".dora", "banner.png") -- 320
						if Content:exist(f) then -- 321
							_val_0 = f -- 321
							break -- 321
						end -- 321
						f = Path(projectPath, "Image", "banner.jpg") -- 322
						if Content:exist(f) then -- 323
							_val_0 = f -- 323
							break -- 323
						end -- 323
						f = Path(projectPath, "Image", "banner.png") -- 324
						if Content:exist(f) then -- 325
							_val_0 = f -- 325
							break -- 325
						end -- 325
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 326
						if Content:exist(f) then -- 327
							_val_0 = f -- 327
							break -- 327
						end -- 327
					until true -- 315
					bannerFile = _val_0 -- 315
				end -- 315
				if bannerFile then -- 329
					thread(function() -- 329
						if Cache:loadAsync(bannerFile) then -- 330
							local bannerTex = Texture2D(bannerFile) -- 331
							if bannerTex then -- 331
								entry.bannerFile = bannerFile -- 332
								entry.bannerTex = bannerTex -- 333
							end -- 331
						end -- 330
					end) -- 329
				end -- 329
				entries[#entries + 1] = entry -- 334
			end -- 281
			::_continue_1:: -- 281
		end -- 280
		::_continue_0:: -- 279
	end -- 278
	table.sort(entries, function(a, b) -- 335
		return a.entryName < b.entryName -- 335
	end) -- 335
	return entries -- 336
end -- 276
_module_0["getProjectEntries"] = getProjectEntries -- 276
local gamesInDev -- 338
local doraTools -- 339
local allEntries -- 340
local isToolEntry -- 342
isToolEntry = function(entry) -- 342
	do -- 343
		local _type_0 = type(entry) -- 343
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 343
		if _tab_0 then -- 343
			local categories -- 343
			do -- 343
				local _obj_0 = entry.repo -- 343
				local _type_1 = type(_obj_0) -- 343
				if "table" == _type_1 or "userdata" == _type_1 then -- 343
					categories = _obj_0.categories -- 343
				end -- 343
			end -- 343
			if categories ~= nil then -- 343
				for _index_0 = 1, #categories do -- 344
					local category = categories[_index_0] -- 344
					if "string" == type(category) and category:lower() == "tool" then -- 345
						return true -- 346
					end -- 345
				end -- 344
			end -- 343
		end -- 343
	end -- 343
	return false -- 342
end -- 342
local getEntryTitle -- 348
getEntryTitle = function(entry) -- 348
	local title -- 349
	do -- 349
		local repo = entry.repo -- 349
		if repo then -- 349
			if repo.title and "table" == type(repo.title) then -- 350
				if useChinese then -- 351
					title = repo.title.zh -- 351
				else -- 351
					title = repo.title.en -- 351
				end -- 351
			end -- 350
		end -- 349
	end -- 349
	if title ~= nil then -- 352
		return title -- 352
	else -- 352
		return entry.entryName -- 352
	end -- 352
end -- 348
local updateEntries -- 354
updateEntries = function() -- 354
	local projectEntries = getProjectEntries(Content.writablePath) -- 355
	gamesInDev = { } -- 356
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 357
	for _index_0 = 1, #doraTools do -- 358
		local tool = doraTools[_index_0] -- 358
		tool.kind = "tool" -- 359
		tool.builtin = true -- 360
	end -- 358
	for _index_0 = 1, #projectEntries do -- 361
		local entry = projectEntries[_index_0] -- 361
		if isToolEntry(entry) then -- 362
			entry.kind = "tool" -- 363
			doraTools[#doraTools + 1] = entry -- 364
		else -- 366
			entry.kind = "game" -- 366
			gamesInDev[#gamesInDev + 1] = entry -- 367
		end -- 362
	end -- 361
	allEntries = { } -- 368
	for _index_0 = 1, #gamesInDev do -- 369
		local game = gamesInDev[_index_0] -- 369
		allEntries[#allEntries + 1] = game -- 370
		local examples, tests = game.examples, game.tests -- 371
		for _index_1 = 1, #examples do -- 372
			local example = examples[_index_1] -- 372
			allEntries[#allEntries + 1] = example -- 373
		end -- 372
		for _index_1 = 1, #tests do -- 374
			local test = tests[_index_1] -- 374
			allEntries[#allEntries + 1] = test -- 375
		end -- 374
	end -- 369
end -- 354
updateEntries() -- 377
local getLaunchEntries -- 379
getLaunchEntries = function(refresh) -- 379
	if refresh == nil then -- 379
		refresh = false -- 379
	end -- 379
	if refresh then -- 380
		updateEntries() -- 380
	end -- 380
	local toInfo -- 381
	toInfo = function(entry, kind) -- 381
		local file = entry.fileName -- 382
		local asProj = not entry.builtin -- 383
		return { -- 385
			name = getEntryTitle(entry), -- 385
			file = file, -- 386
			kind = kind, -- 387
			asProj = asProj -- 388
		} -- 384
	end -- 381
	local games -- 390
	do -- 390
		local _accum_0 = { } -- 390
		local _len_0 = 1 -- 390
		for _index_0 = 1, #gamesInDev do -- 390
			local game = gamesInDev[_index_0] -- 390
			_accum_0[_len_0] = toInfo(game, "game") -- 390
			_len_0 = _len_0 + 1 -- 390
		end -- 390
		games = _accum_0 -- 390
	end -- 390
	local tools -- 391
	do -- 391
		local _accum_0 = { } -- 391
		local _len_0 = 1 -- 391
		for _index_0 = 1, #doraTools do -- 391
			local tool = doraTools[_index_0] -- 391
			_accum_0[_len_0] = toInfo(tool, "tool") -- 391
			_len_0 = _len_0 + 1 -- 391
		end -- 391
		tools = _accum_0 -- 391
	end -- 391
	return { -- 392
		games = games, -- 392
		tools = tools -- 392
	} -- 392
end -- 379
_module_0["getLaunchEntries"] = getLaunchEntries -- 379
local _anon_func_1 = function(entry, useChinese) -- 401
	local _obj_0 = entry.repo -- 401
	if _obj_0 ~= nil then -- 401
		local _obj_1 = _obj_0.description -- 401
		if _obj_1 ~= nil then -- 401
			return _obj_1[useChinese and "zh" or "en"] -- 401
		end -- 401
		return nil -- 401
	end -- 401
	return nil -- 401
end -- 401
local getMobileFeedEntries -- 394
getMobileFeedEntries = function(refresh) -- 394
	if refresh == nil then -- 394
		refresh = false -- 394
	end -- 394
	if refresh then -- 395
		updateEntries() -- 395
	end -- 395
	local items = { } -- 396
	for _index_0 = 1, #gamesInDev do -- 397
		local entry = gamesInDev[_index_0] -- 397
		items[#items + 1] = { -- 399
			id = entry.entryName, -- 399
			title = getEntryTitle(entry), -- 400
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 401
			fileName = entry.fileName, -- 402
			workDir = Path:getPath(entry.fileName), -- 403
			bannerFile = entry.bannerFile, -- 404
			kind = "local" -- 405
		} -- 398
	end -- 397
	return items -- 407
end -- 394
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 394
local doCompile -- 409
doCompile = function(minify) -- 409
	if building then -- 410
		return -- 410
	end -- 410
	building = true -- 411
	local startTime = App.runningTime -- 412
	local luaFiles = { } -- 413
	local yueFiles = { } -- 414
	local xmlFiles = { } -- 415
	local tlFiles = { } -- 416
	local writablePath = Content.writablePath -- 417
	local buildPaths = { -- 419
		{ -- 420
			Content.assetPath, -- 420
			Path(writablePath, ".build"), -- 421
			"" -- 422
		} -- 419
	} -- 418
	for _index_0 = 1, #gamesInDev do -- 425
		local _des_0 = gamesInDev[_index_0] -- 425
		local fileName = _des_0.fileName -- 425
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 426
		buildPaths[#buildPaths + 1] = { -- 428
			Path(writablePath, gamePath), -- 428
			Path(writablePath, ".build", gamePath), -- 429
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 430
			gamePath -- 431
		} -- 427
	end -- 425
	for _index_0 = 1, #buildPaths do -- 432
		local _des_0 = buildPaths[_index_0] -- 432
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 432
		if not Content:exist(inputPath) then -- 433
			goto _continue_0 -- 433
		end -- 433
		local _list_0 = getAllFiles(inputPath, { -- 435
			"lua" -- 435
		}) -- 435
		for _index_1 = 1, #_list_0 do -- 435
			local file = _list_0[_index_1] -- 435
			luaFiles[#luaFiles + 1] = { -- 437
				file, -- 437
				Path(inputPath, file), -- 438
				Path(outputPath, file), -- 439
				gamePath -- 440
			} -- 436
		end -- 435
		local _list_1 = getAllFiles(inputPath, { -- 442
			yueext -- 442
		}) -- 442
		for _index_1 = 1, #_list_1 do -- 442
			local file = _list_1[_index_1] -- 442
			yueFiles[#yueFiles + 1] = { -- 444
				file, -- 444
				Path(inputPath, file), -- 445
				Path(outputPath, Path:replaceExt(file, "lua")), -- 446
				searchPath, -- 447
				gamePath -- 448
			} -- 443
		end -- 442
		local _list_2 = getAllFiles(inputPath, { -- 450
			"xml" -- 450
		}) -- 450
		for _index_1 = 1, #_list_2 do -- 450
			local file = _list_2[_index_1] -- 450
			xmlFiles[#xmlFiles + 1] = { -- 452
				file, -- 452
				Path(inputPath, file), -- 453
				Path(outputPath, Path:replaceExt(file, "lua")), -- 454
				gamePath -- 455
			} -- 451
		end -- 450
		local _list_3 = getAllFiles(inputPath, { -- 457
			"tl" -- 457
		}) -- 457
		for _index_1 = 1, #_list_3 do -- 457
			local file = _list_3[_index_1] -- 457
			if not file:match(".*%.d%.tl$") then -- 458
				tlFiles[#tlFiles + 1] = { -- 460
					file, -- 460
					Path(inputPath, file), -- 461
					Path(outputPath, Path:replaceExt(file, "lua")), -- 462
					searchPath, -- 463
					gamePath -- 464
				} -- 459
			end -- 458
		end -- 457
		::_continue_0:: -- 433
	end -- 432
	local paths -- 466
	do -- 466
		local _tbl_0 = { } -- 466
		local _list_0 = { -- 467
			luaFiles, -- 467
			yueFiles, -- 467
			xmlFiles, -- 467
			tlFiles -- 467
		} -- 467
		for _index_0 = 1, #_list_0 do -- 467
			local files = _list_0[_index_0] -- 467
			for _index_1 = 1, #files do -- 468
				local file = files[_index_1] -- 468
				_tbl_0[Path:getPath(file[3])] = true -- 466
			end -- 466
		end -- 466
		paths = _tbl_0 -- 466
	end -- 466
	for path in pairs(paths) do -- 470
		Content:mkdir(path) -- 470
	end -- 470
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 472
	local fileCount = 0 -- 473
	local errors = { } -- 474
	for _index_0 = 1, #yueFiles do -- 475
		local _des_0 = yueFiles[_index_0] -- 475
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 475
		local filename -- 476
		if gamePath then -- 476
			filename = Path(gamePath, file) -- 476
		else -- 476
			filename = file -- 476
		end -- 476
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 477
			if not codes then -- 478
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 479
				return -- 480
			end -- 478
			local success, result = LintYueGlobals(codes, globals) -- 481
			local yueCodes -- 482
			if not success then -- 483
				yueCodes = Content:load(input) -- 484
				if yueCodes then -- 484
					local CheckTIC80Code -- 485
					do -- 485
						local _obj_0 = require("Utils") -- 485
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 485
					end -- 485
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 486
					if isTIC80 then -- 487
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 488
					end -- 487
				end -- 484
			end -- 483
			if success then -- 489
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 490
			else -- 492
				if yueCodes then -- 492
					local globalErrors = { } -- 493
					for _index_1 = 1, #result do -- 494
						local _des_1 = result[_index_1] -- 494
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 494
						local countLine = 1 -- 495
						local code = "" -- 496
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 497
							if countLine == line then -- 498
								code = lineCode -- 499
								break -- 500
							end -- 498
							countLine = countLine + 1 -- 501
						end -- 497
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 502
					end -- 494
					if #globalErrors > 0 then -- 503
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 503
					end -- 503
				else -- 505
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 505
				end -- 492
				if #errors == 0 then -- 506
					return codes -- 506
				end -- 506
			end -- 489
		end, function(success) -- 477
			if success then -- 507
				print("Yue compiled: " .. tostring(filename)) -- 507
			end -- 507
			fileCount = fileCount + 1 -- 508
		end) -- 477
	end -- 475
	thread(function() -- 510
		for _index_0 = 1, #xmlFiles do -- 511
			local _des_0 = xmlFiles[_index_0] -- 511
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 511
			local filename -- 512
			if gamePath then -- 512
				filename = Path(gamePath, file) -- 512
			else -- 512
				filename = file -- 512
			end -- 512
			local sourceCodes = Content:loadAsync(input) -- 513
			local codes, err = xml.tolua(sourceCodes) -- 514
			if not codes then -- 515
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 516
			else -- 518
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 518
				print("Xml compiled: " .. tostring(filename)) -- 519
			end -- 515
			fileCount = fileCount + 1 -- 520
		end -- 511
	end) -- 510
	thread(function() -- 522
		for _index_0 = 1, #tlFiles do -- 523
			local _des_0 = tlFiles[_index_0] -- 523
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 523
			local filename -- 524
			if gamePath then -- 524
				filename = Path(gamePath, file) -- 524
			else -- 524
				filename = file -- 524
			end -- 524
			local sourceCodes = Content:loadAsync(input) -- 525
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 526
			if not codes then -- 527
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 528
			else -- 530
				Content:saveAsync(output, codes) -- 530
				print("Teal compiled: " .. tostring(filename)) -- 531
			end -- 527
			fileCount = fileCount + 1 -- 532
		end -- 523
	end) -- 522
	return thread(function() -- 534
		wait(function() -- 535
			return fileCount == totalFiles -- 535
		end) -- 535
		if minify then -- 536
			local _list_0 = { -- 537
				yueFiles, -- 537
				xmlFiles, -- 537
				tlFiles -- 537
			} -- 537
			for _index_0 = 1, #_list_0 do -- 537
				local files = _list_0[_index_0] -- 537
				for _index_1 = 1, #files do -- 537
					local file = files[_index_1] -- 537
					local output = Path:replaceExt(file[3], "lua") -- 538
					luaFiles[#luaFiles + 1] = { -- 540
						Path:replaceExt(file[1], "lua"), -- 540
						output, -- 541
						output -- 542
					} -- 539
				end -- 537
			end -- 537
			local FormatMini -- 544
			do -- 544
				local _obj_0 = require("luaminify") -- 544
				FormatMini = _obj_0.FormatMini -- 544
			end -- 544
			for _index_0 = 1, #luaFiles do -- 545
				local _des_0 = luaFiles[_index_0] -- 545
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 545
				if Content:exist(input) then -- 546
					local sourceCodes = Content:loadAsync(input) -- 547
					local res, err = FormatMini(sourceCodes) -- 548
					if res then -- 549
						Content:saveAsync(output, res) -- 550
						print("Minify: " .. tostring(file)) -- 551
					else -- 553
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 553
					end -- 549
				else -- 555
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 555
				end -- 546
			end -- 545
			package.loaded["luaminify.FormatMini"] = nil -- 556
			package.loaded["luaminify.ParseLua"] = nil -- 557
			package.loaded["luaminify.Scope"] = nil -- 558
			package.loaded["luaminify.Util"] = nil -- 559
		end -- 536
		local errorMessage = table.concat(errors, "\n") -- 560
		if errorMessage ~= "" then -- 561
			print(errorMessage) -- 561
		end -- 561
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 562
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 563
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 564
		Content:clearPathCache() -- 565
		teal.clear() -- 566
		yue.clear() -- 567
		building = false -- 568
	end) -- 534
end -- 409
local doClean -- 570
doClean = function() -- 570
	if building then -- 571
		return -- 571
	end -- 571
	local writablePath = Content.writablePath -- 572
	local targetDir = Path(writablePath, ".build") -- 573
	Content:clearPathCache() -- 574
	if Content:remove(targetDir) then -- 575
		return print("Cleaned: " .. tostring(targetDir)) -- 576
	end -- 575
end -- 570
local screenScale = 2.0 -- 578
local scaleContent = false -- 579
local isInEntry = true -- 580
local currentEntry = nil -- 581
local footerWindow = nil -- 583
local entryWindow = nil -- 584
local testingThread = nil -- 585
local mobileMode = config.mobileFeed -- 586
local pendingUIMode = nil -- 587
local feedHost = nil -- 588
local remixHost = nil -- 589
local startMobileUI = nil -- 590
local webControlled = false -- 591
local mobileHosts = { } -- 592
local suspendedMobileHosts = { } -- 593
local trackMobileHost -- 595
trackMobileHost = function(host) -- 595
	do -- 596
		local _accum_0 = { } -- 596
		local _len_0 = 1 -- 596
		for _index_0 = 1, #mobileHosts do -- 596
			local item = mobileHosts[_index_0] -- 596
			if item.parent then -- 596
				_accum_0[_len_0] = item -- 596
				_len_0 = _len_0 + 1 -- 596
			end -- 596
		end -- 596
		mobileHosts = _accum_0 -- 596
	end -- 596
	mobileHosts[#mobileHosts + 1] = host -- 597
	return host -- 598
end -- 595
local clearMobileUI -- 600
clearMobileUI = function() -- 600
	for _index_0 = 1, #mobileHosts do -- 601
		local host = mobileHosts[_index_0] -- 601
		if host.parent then -- 602
			host:removeFromParent(true) -- 602
		end -- 602
	end -- 601
	mobileHosts = { } -- 603
	suspendedMobileHosts = { } -- 604
	feedHost = nil -- 605
	remixHost = nil -- 606
end -- 600
local syncWebIDEControl -- 608
syncWebIDEControl = function() -- 608
	local connected = HttpServer.wsConnectionCount > 0 -- 609
	if connected then -- 610
		pendingUIMode = nil -- 611
		for _index_0 = 1, #mobileHosts do -- 612
			local host = mobileHosts[_index_0] -- 612
			if not host.parent then -- 613
				goto _continue_0 -- 613
			end -- 613
			if not (suspendedMobileHosts[host] ~= nil) then -- 614
				suspendedMobileHosts[host] = host.visible -- 615
				host:emit("SuspendLocalUI") -- 616
			end -- 614
			host.visible = false -- 617
			::_continue_0:: -- 613
		end -- 612
	elseif webControlled then -- 618
		for host, visible in pairs(suspendedMobileHosts) do -- 619
			if host.parent then -- 620
				host.visible = visible -- 621
				host:emit("ResumeLocalUI") -- 622
			end -- 620
		end -- 619
		suspendedMobileHosts = { } -- 623
	end -- 610
	webControlled = connected -- 624
	return connected -- 625
end -- 608
local getUIMode -- 627
getUIMode = function() -- 627
	return mobileMode and "mobile" or "traditional" -- 627
end -- 627
_module_0["getUIMode"] = getUIMode -- 627
local setUIMode -- 628
setUIMode = function(mode) -- 628
	if not (("mobile" == mode or "traditional" == mode)) then -- 629
		return false -- 629
	end -- 629
	if HttpServer.wsConnectionCount > 0 then -- 630
		return false -- 630
	end -- 630
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 631
		return false -- 631
	end -- 631
	local wantsMobile = mode == "mobile" -- 632
	if wantsMobile == mobileMode then -- 633
		return true -- 633
	end -- 633
	if mobileMode then -- 634
		if not (feedHost and feedHost.visible) then -- 635
			return false -- 635
		end -- 635
		feedHost:emit("SwitchUIMode") -- 637
		return pendingUIMode == false -- 638
	end -- 634
	pendingUIMode = true -- 639
	return true -- 640
end -- 628
_module_0["setUIMode"] = setUIMode -- 628
local applyUIMode -- 642
applyUIMode = function(enabled) -- 642
	if HttpServer.wsConnectionCount > 0 then -- 644
		return false -- 644
	end -- 644
	if enabled then -- 645
		local ok, err = pcall(startMobileUI) -- 646
		if not ok then -- 647
			if feedHost then -- 648
				feedHost:removeFromParent(true) -- 648
			end -- 648
			feedHost = nil -- 649
			mobileMode = false -- 650
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 651
			return false -- 652
		end -- 647
	else -- 654
		clearMobileUI() -- 654
		updateEntries() -- 655
	end -- 645
	mobileMode = enabled -- 656
	config.mobileFeed = enabled -- 657
	return true -- 658
end -- 642
local setupEventHandlers = nil -- 660
local allClear -- 662
allClear = function() -- 662
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 664
		clearMobileUI() -- 664
	end -- 664
	local systemNodes = { } -- 667
	local preserveSystemNode -- 668
	preserveSystemNode = function(node) -- 668
		if systemNodes[node] then -- 669
			return -- 669
		end -- 669
		systemNodes[node] = true -- 670
		do -- 671
			local clip = tolua.cast(node, "ClipNode") -- 671
			if clip then -- 671
				if clip.stencil then -- 672
					preserveSystemNode(clip.stencil) -- 672
				end -- 672
			end -- 671
		end -- 671
		return node:eachChild(function(child) -- 673
			preserveSystemNode(child) -- 674
			return false -- 675
		end) -- 673
	end -- 668
	for _index_0 = 1, #Routine do -- 676
		local routine = Routine[_index_0] -- 676
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 678
			goto _continue_0 -- 679
		else -- 681
			Routine:remove(routine) -- 681
		end -- 677
		::_continue_0:: -- 677
	end -- 676
	for _index_0 = 1, #moduleCache do -- 682
		local module = moduleCache[_index_0] -- 682
		package.loaded[module] = nil -- 683
	end -- 682
	moduleCache = { } -- 684
	Director:cleanup() -- 685
	Entity:clear() -- 686
	Platformer.Data:clear() -- 687
	Platformer.UnitAction:clear() -- 688
	Audio:stopAll(0.2) -- 689
	Struct:clear() -- 690
	View.postEffect = nil -- 691
	View.scale = scaleContent and screenScale or 1 -- 692
	Director.clearColor = Color(0xff1a1a1a) -- 693
	teal.clear() -- 694
	yue.clear() -- 695
	preserveSystemNode(Director.systemUI) -- 698
	for _, item in pairs(ubox()) do -- 699
		local node = tolua.cast(item, "Node") -- 700
		if node then -- 700
			if not systemNodes[node] then -- 701
				node:cleanup() -- 701
			end -- 701
		end -- 700
	end -- 699
	collectgarbage() -- 702
	collectgarbage() -- 703
	Wasm:clear() -- 704
	thread(function() -- 705
		sleep() -- 706
		return Cache:removeUnused() -- 707
	end) -- 705
	setupEventHandlers() -- 708
	Content.searchPaths = searchPaths -- 709
	App.idled = true -- 710
end -- 662
_module_0["allClear"] = allClear -- 662
local clearTempFiles -- 712
clearTempFiles = function() -- 712
	local writablePath = Content.writablePath -- 713
	if Content:exist(Path(writablePath, ".upload")) then -- 714
		Content:remove(Path(writablePath, ".upload")) -- 714
	end -- 714
	if Content:exist(Path(writablePath, ".download")) then -- 715
		return Content:remove(Path(writablePath, ".download")) -- 715
	end -- 715
end -- 712
local waitForWebStart = true -- 717
thread(function() -- 718
	sleep(2) -- 719
	waitForWebStart = false -- 720
end) -- 718
local reloadDevEntry -- 722
reloadDevEntry = function() -- 722
	return thread(function() -- 722
		waitForWebStart = true -- 723
		doClean() -- 724
		allClear() -- 725
		_G.require = oldRequire -- 726
		Dora.require = oldRequire -- 727
		package.loaded["Script.Dev.Entry"] = nil -- 728
		package.loaded["Script.Dev.WebServer"] = nil -- 729
		return Director.systemScheduler:schedule(function() -- 730
			Routine:clear() -- 731
			oldRequire("Script.Dev.Entry") -- 732
			return true -- 733
		end) -- 730
	end) -- 722
end -- 722
local setWorkspace -- 735
setWorkspace = function(path) -- 735
	clearTempFiles() -- 736
	Content.writablePath = path -- 737
	config.writablePath = Content.writablePath -- 738
	return thread(function() -- 739
		sleep() -- 740
		return reloadDevEntry() -- 741
	end) -- 739
end -- 735
_module_0["setWorkspace"] = setWorkspace -- 735
local quit = false -- 743
local activeSearchId = 0 -- 745
local handleSearchFiles -- 747
handleSearchFiles = function(payload) -- 747
	if not payload then -- 748
		return -- 748
	end -- 748
	local id = payload.id -- 749
	if id == nil then -- 750
		return -- 750
	end -- 750
	activeSearchId = id -- 751
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 752
	if path == nil then -- 753
		path = "" -- 753
	end -- 753
	if exts == nil then -- 754
		exts = { } -- 754
	end -- 754
	if globs == nil then -- 755
		globs = { } -- 755
	end -- 755
	if extensionLevels == nil then -- 756
		extensionLevels = { } -- 756
	end -- 756
	if pattern == nil then -- 757
		pattern = "" -- 757
	end -- 757
	if pattern == "" then -- 759
		return -- 759
	end -- 759
	local useRegex = payload.useRegex == true -- 760
	local caseSensitive = payload.caseSensitive == true -- 761
	local includeContent = payload.includeContent ~= false -- 762
	local contentWindow = payload.contentWindow or 0 -- 763
	return Director.systemScheduler:schedule(once(function() -- 764
		local stopped = false -- 765
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 766
			if activeSearchId ~= id then -- 767
				stopped = true -- 768
				return true -- 769
			end -- 767
			emit("AppWS", "Send", json.encode({ -- 771
				name = "SearchFilesResult", -- 771
				id = id, -- 771
				result = result -- 771
			})) -- 770
			return false -- 773
		end) -- 766
		return emit("AppWS", "Send", json.encode({ -- 775
			name = "SearchFilesDone", -- 775
			id = id, -- 775
			stopped = stopped -- 775
		})) -- 774
	end)) -- 764
end -- 747
local stop -- 778
stop = function() -- 778
	if isInEntry then -- 779
		return false -- 779
	end -- 779
	allClear() -- 780
	isInEntry = true -- 781
	currentEntry = nil -- 782
	return true -- 783
end -- 778
_module_0["stop"] = stop -- 778
local getCurrentEntryStatus -- 785
getCurrentEntryStatus = function() -- 785
	local entry = currentEntry -- 786
	if not (entry and not isInEntry) then -- 787
		return { -- 787
			success = true, -- 787
			running = false -- 787
		} -- 787
	end -- 787
	local status = { -- 789
		success = true, -- 789
		running = true, -- 790
		kind = entry.runKind or "file", -- 791
		entryName = entry.entryName, -- 792
		fileName = entry.fileName -- 793
	} -- 788
	if entry.workDir then -- 794
		status.workDir = entry.workDir -- 794
	end -- 794
	if entry.projectRoot then -- 795
		status.projectRoot = entry.projectRoot -- 795
	end -- 795
	return status -- 796
end -- 785
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 785
local _anon_func_2 = function(_with_0) -- 815
	local _val_0 = App.platform -- 815
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 815
end -- 815
setupEventHandlers = function() -- 798
	local _with_0 = Director.postNode -- 799
	_with_0:onAppEvent(function(eventType) -- 800
		if "Quit" == eventType then -- 801
			quit = true -- 802
			allClear() -- 803
			return clearTempFiles() -- 804
		elseif "Shutdown" == eventType then -- 805
			return stop() -- 806
		end -- 800
	end) -- 800
	_with_0:onAppChange(function(settingName) -- 807
		if "Theme" == settingName then -- 808
			config.themeColor = App.themeColor:toARGB() -- 809
		elseif "Locale" == settingName then -- 810
			config.locale = App.locale -- 811
			updateLocale() -- 812
			return teal.clear(true) -- 813
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 814
			if _anon_func_2(_with_0) then -- 815
				if "FullScreen" == settingName then -- 817
					config.fullScreen = App.fullScreen -- 817
				elseif "Position" == settingName then -- 818
					local _obj_0 = App.winPosition -- 818
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 818
				elseif "Size" == settingName then -- 819
					local width, height -- 820
					do -- 820
						local _obj_0 = App.winSize -- 820
						width, height = _obj_0.width, _obj_0.height -- 820
					end -- 820
					config.winWidth = width -- 821
					config.winHeight = height -- 822
				end -- 816
			end -- 815
		end -- 807
	end) -- 807
	_with_0:onAppWS(function(event) -- 823
		if event.type == "Close" then -- 824
			if HttpServer.wsConnectionCount == 0 then -- 825
				updateEntries() -- 826
			end -- 825
			return -- 827
		end -- 824
		if not (event.type == "Receive") then -- 828
			return -- 828
		end -- 828
		local data = json.decode(event.msg) -- 829
		if not data then -- 830
			return -- 830
		end -- 830
		local _exp_0 = data.name -- 831
		if "SearchFiles" == _exp_0 then -- 832
			return handleSearchFiles(data) -- 833
		elseif "SearchFilesStop" == _exp_0 then -- 834
			if data.id == nil or data.id == activeSearchId then -- 835
				activeSearchId = 0 -- 836
			end -- 835
		end -- 831
	end) -- 823
	_with_0:slot("UpdateEntries", function() -- 837
		return updateEntries() -- 837
	end) -- 837
	return _with_0 -- 799
end -- 798
setupEventHandlers() -- 839
clearTempFiles() -- 840
local downloadFile -- 842
downloadFile = function(url, target) -- 842
	return Director.systemScheduler:schedule(once(function() -- 842
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 843
			if quit then -- 844
				return true -- 844
			end -- 844
			emit("AppWS", "Send", json.encode({ -- 846
				name = "Download", -- 846
				url = url, -- 846
				status = "downloading", -- 846
				progress = current / total -- 847
			})) -- 845
			return false -- 843
		end) -- 843
		return emit("AppWS", "Send", json.encode(success and { -- 850
			name = "Download", -- 850
			url = url, -- 850
			status = "completed", -- 850
			progress = 1.0 -- 851
		} or { -- 853
			name = "Download", -- 853
			url = url, -- 853
			status = "failed", -- 853
			progress = 0.0 -- 854
		})) -- 849
	end)) -- 842
end -- 842
_module_0["downloadFile"] = downloadFile -- 842
local _anon_func_3 = function(file, require, workDir) -- 865
	if workDir == nil then -- 865
		workDir = Path:getPath(file) -- 865
	end -- 865
	Content:insertSearchPath(1, workDir) -- 866
	local scriptPath = Path(workDir, "Script") -- 867
	if Content:exist(scriptPath) then -- 868
		Content:insertSearchPath(1, scriptPath) -- 869
	end -- 868
	local result = require(file) -- 870
	if "function" == type(result) then -- 871
		result() -- 871
	end -- 871
	return nil -- 872
end -- 865
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 901
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 901
	label.alignment = "Left" -- 902
	label.textWidth = width - fontSize -- 903
	label.text = err -- 904
	return label -- 901
end -- 901
local enterEntryAsync -- 857
enterEntryAsync = function(entry) -- 857
	isInEntry = false -- 858
	App.idled = false -- 859
	emit(Profiler.EventName, "ClearLoader") -- 860
	currentEntry = entry -- 861
	local file, workDir = entry.fileName, entry.workDir -- 862
	sleep() -- 863
	return xpcall(_anon_func_3, function(msg) -- 872
		local err = debug.traceback(msg) -- 874
		Log("Error", err) -- 875
		allClear() -- 876
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 877
		local viewWidth, viewHeight -- 878
		do -- 878
			local _obj_0 = View.size -- 878
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 878
		end -- 878
		local width, height = viewWidth - 20, viewHeight - 20 -- 879
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 880
		Director.ui:addChild((function() -- 881
			local root = AlignNode() -- 881
			do -- 882
				local _obj_0 = App.bufferSize -- 882
				width, height = _obj_0.width, _obj_0.height -- 882
			end -- 882
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 883
			root:onAppChange(function(settingName) -- 884
				if settingName == "Size" then -- 884
					do -- 885
						local _obj_0 = App.bufferSize -- 885
						width, height = _obj_0.width, _obj_0.height -- 885
					end -- 885
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 886
				end -- 884
			end) -- 884
			root:addChild((function() -- 887
				local _with_0 = ScrollArea({ -- 888
					width = width, -- 888
					height = height, -- 889
					paddingX = 0, -- 890
					paddingY = 50, -- 891
					viewWidth = height, -- 892
					viewHeight = height -- 893
				}) -- 887
				root:onAlignLayout(function(w, h) -- 895
					_with_0.position = Vec2(w / 2, h / 2) -- 896
					w = w - 20 -- 897
					h = h - 20 -- 898
					_with_0.view.children.first.textWidth = w - fontSize -- 899
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 900
				end) -- 895
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 901
				return _with_0 -- 887
			end)()) -- 887
			return root -- 881
		end)()) -- 881
		return err -- 905
	end, file, require, workDir) -- 864
end -- 857
_module_0["enterEntryAsync"] = enterEntryAsync -- 857
local enterDemoEntry -- 907
enterDemoEntry = function(entry) -- 907
	return thread(function() -- 907
		return enterEntryAsync(entry) -- 907
	end) -- 907
end -- 907
local reloadCurrentEntry -- 909
reloadCurrentEntry = function() -- 909
	if currentEntry then -- 910
		allClear() -- 911
		return enterDemoEntry(currentEntry) -- 912
	end -- 910
end -- 909
Director.clearColor = Color(0xff1a1a1a) -- 914
local descColor = Color(0xffa1a1a1) -- 915
local extraOperations -- 917
do -- 917
	local isOSSLicenseExist = Content:exist("LICENSES") -- 918
	local ossLicenses = nil -- 919
	local ossLicenseOpen = false -- 920
	local failedSetFolder = false -- 921
	local statusFlags = { -- 922
		"NoResize", -- 922
		"NoMove", -- 922
		"NoCollapse", -- 922
		"AlwaysAutoResize", -- 922
		"NoSavedSettings" -- 922
	} -- 922
	extraOperations = function() -- 929
		local zh = useChinese -- 930
		if isDesktop then -- 931
			local alwaysOnTop = config.alwaysOnTop -- 932
			local changed -- 933
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 933
			if changed then -- 933
				App.alwaysOnTop = alwaysOnTop -- 934
				config.alwaysOnTop = alwaysOnTop -- 935
			end -- 933
		end -- 931
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 936
		do -- 941
			local changed -- 941
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 941
			if changed then -- 941
				config.showPreview = showPreview -- 942
				updateEntries() -- 943
				if not showPreview then -- 944
					thread(function() -- 945
						collectgarbage() -- 946
						return Cache:removeUnused("Texture") -- 947
					end) -- 945
				end -- 944
			end -- 941
		end -- 941
		do -- 948
			local changed -- 948
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 948
			if changed then -- 948
				config.authRequired = authRequired -- 949
				HttpServer.authRequired = authRequired -- 950
			end -- 948
		end -- 948
		SameLine() -- 951
		TextColored(descColor, "(?)") -- 952
		if IsItemHovered() then -- 953
			BeginTooltip(function() -- 954
				return PushTextWrapPos(280, function() -- 955
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 956
				end) -- 955
			end) -- 954
		end -- 953
		do -- 957
			local themeColor = App.themeColor -- 958
			local writablePath = config.writablePath -- 959
			SeparatorText(zh and "工作目录" or "Workspace") -- 960
			PushTextWrapPos(400, function() -- 961
				return TextColored(themeColor, writablePath) -- 962
			end) -- 961
			if not isDesktop then -- 963
				goto skipSetting -- 963
			end -- 963
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 964
			if Button(zh and "改变目录" or "Set Folder") then -- 965
				App:openFileDialog(true, function(path) -- 966
					if path == "" then -- 967
						return -- 967
					end -- 967
					local relPath = Path:getRelative(Content.assetPath, path) -- 968
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 969
						return setWorkspace(path) -- 970
					else -- 972
						failedSetFolder = true -- 972
					end -- 969
				end) -- 966
			end -- 965
			if failedSetFolder then -- 973
				failedSetFolder = false -- 974
				OpenPopup(popupName) -- 975
			end -- 973
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 976
			BeginPopupModal(popupName, statusFlags, function() -- 977
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 978
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 979
					return CloseCurrentPopup() -- 980
				end -- 979
			end) -- 977
			SameLine() -- 981
			if Button(zh and "使用默认" or "Use Default") then -- 982
				setWorkspace(Content.appPath) -- 983
			end -- 982
			Separator() -- 984
			::skipSetting:: -- 985
		end -- 957
		if isOSSLicenseExist then -- 986
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 987
				if not ossLicenses then -- 988
					ossLicenses = { } -- 989
					local licenseText = Content:load("LICENSES") -- 990
					ossLicenseOpen = (licenseText ~= nil) -- 991
					if ossLicenseOpen then -- 991
						licenseText = licenseText:gsub("\r\n", "\n") -- 992
						for license in GSplit(licenseText, "\n--------\n", true) do -- 993
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 994
							if name then -- 994
								ossLicenses[#ossLicenses + 1] = { -- 995
									name, -- 995
									text -- 995
								} -- 995
							end -- 994
						end -- 993
					end -- 991
				else -- 997
					ossLicenseOpen = true -- 997
				end -- 988
			end -- 987
			if ossLicenseOpen then -- 998
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 999
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1000
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1001
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1002
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 1005
						"NoSavedSettings" -- 1005
					}, function() -- 1006
						for _index_0 = 1, #ossLicenses do -- 1006
							local _des_0 = ossLicenses[_index_0] -- 1006
							local firstLine, text = _des_0[1], _des_0[2] -- 1006
							local name, license = firstLine:match("(.+): (.+)") -- 1007
							TextColored(themeColor, name) -- 1008
							SameLine() -- 1009
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1010
								return TextWrapped(text) -- 1010
							end) -- 1010
						end -- 1006
					end) -- 1002
				end) -- 1002
			end -- 998
		end -- 986
		if not App.debugging then -- 1012
			return -- 1012
		end -- 1012
		return TreeNode(zh and "开发操作" or "Development", function() -- 1013
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1014
				OpenPopup("build") -- 1014
			end -- 1014
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1015
				return BeginPopup("build", function() -- 1015
					if Selectable(zh and "编译" or "Compile") then -- 1016
						doCompile(false) -- 1016
					end -- 1016
					Separator() -- 1017
					if Selectable(zh and "压缩" or "Minify") then -- 1018
						doCompile(true) -- 1018
					end -- 1018
					Separator() -- 1019
					if Selectable(zh and "清理" or "Clean") then -- 1020
						return doClean() -- 1020
					end -- 1020
				end) -- 1015
			end) -- 1015
			if isInEntry then -- 1021
				if waitForWebStart then -- 1022
					BeginDisabled(function() -- 1023
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1023
					end) -- 1023
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1024
					reloadDevEntry() -- 1025
				end -- 1022
			end -- 1021
			do -- 1026
				local changed -- 1026
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1026
				if changed then -- 1026
					View.scale = scaleContent and screenScale or 1 -- 1027
				end -- 1026
			end -- 1026
			do -- 1028
				local changed -- 1028
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1028
				if changed then -- 1028
					config.engineDev = engineDev -- 1029
				end -- 1028
			end -- 1028
			do -- 1030
				local changed -- 1030
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1030
				if changed then -- 1030
					config.webIDETourCompleted = webIDETourCompleted -- 1031
				end -- 1030
			end -- 1030
			if testingThread then -- 1032
				return BeginDisabled(function() -- 1033
					return Button(zh and "开始自动测试" or "Test automatically") -- 1033
				end) -- 1033
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1034
				testingThread = thread(function() -- 1035
					local _ <close> = setmetatable({ }, { -- 1036
						__close = function() -- 1036
							allClear() -- 1037
							testingThread = nil -- 1038
							isInEntry = true -- 1039
							currentEntry = nil -- 1040
							return print("Testing done!") -- 1041
						end -- 1036
					}) -- 1036
					for _, entry in ipairs(allEntries) do -- 1042
						allClear() -- 1043
						print("Start " .. tostring(entry.entryName)) -- 1044
						enterDemoEntry(entry) -- 1045
						sleep(2) -- 1046
						print("Stop " .. tostring(entry.entryName)) -- 1047
					end -- 1042
				end) -- 1035
			end -- 1032
		end) -- 1013
	end -- 929
end -- 917
local icon = Path("Script", "Dev", "icon_s.png") -- 1049
local iconTex = nil -- 1050
thread(function() -- 1051
	if Cache:loadAsync(icon) then -- 1051
		iconTex = Texture2D(icon) -- 1051
	end -- 1051
end) -- 1051
local webStatus = nil -- 1053
local urlClicked = nil -- 1054
local authCode = string.format("%06d", math.random(0, 999999)) -- 1056
local authCodeTTL = 30.0 -- 1058
_module_0.getAuthCode = function() -- 1059
	return authCode -- 1059
end -- 1059
_module_0.invalidateAuthCode = function() -- 1060
	authCode = string.format("%06d", math.random(0, 999999)) -- 1061
	authCodeTTL = 30.0 -- 1062
end -- 1060
local AuthSession -- 1064
do -- 1064
	local pending = nil -- 1065
	local session = nil -- 1066
	AuthSession = { -- 1068
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1068
			pending = { -- 1070
				sessionId = sessionId, -- 1070
				confirmCode = confirmCode, -- 1071
				expiresAt = expiresAt, -- 1072
				ttl = ttl, -- 1073
				approved = false -- 1074
			} -- 1069
		end, -- 1068
		getPending = function() -- 1076
			return pending -- 1076
		end, -- 1076
		approvePending = function(sessionId) -- 1078
			if pending and pending.sessionId == sessionId then -- 1079
				pending.approved = true -- 1080
				return true -- 1081
			end -- 1079
			return false -- 1082
		end, -- 1078
		clearPending = function() -- 1084
			pending = nil -- 1084
		end, -- 1084
		setSession = function(sessionId, sessionSecret) -- 1086
			session = { -- 1088
				sessionId = sessionId, -- 1088
				sessionSecret = sessionSecret -- 1089
			} -- 1087
		end, -- 1086
		getSession = function() -- 1091
			return session -- 1091
		end -- 1091
	} -- 1067
end -- 1064
_module_0["AuthSession"] = AuthSession -- 1064
local transparant = Color(0x0) -- 1094
local windowFlags = { -- 1095
	"NoTitleBar", -- 1095
	"NoResize", -- 1095
	"NoMove", -- 1095
	"NoCollapse", -- 1095
	"NoSavedSettings", -- 1095
	"NoFocusOnAppearing", -- 1095
	"NoBringToFrontOnFocus" -- 1095
} -- 1095
local statusFlags = { -- 1104
	"NoTitleBar", -- 1104
	"NoResize", -- 1104
	"NoMove", -- 1104
	"NoCollapse", -- 1104
	"AlwaysAutoResize", -- 1104
	"NoSavedSettings" -- 1104
} -- 1104
local displayWindowFlags = { -- 1112
	"NoDecoration", -- 1112
	"NoSavedSettings", -- 1112
	"NoMove", -- 1112
	"NoScrollWithMouse", -- 1112
	"AlwaysAutoResize", -- 1112
	"NoFocusOnAppearing" -- 1112
} -- 1112
local gamepadInputWindowFlags = { -- 1120
	"NoDecoration", -- 1120
	"NoSavedSettings", -- 1120
	"NoMove", -- 1120
	"NoScrollbar", -- 1120
	"NoScrollWithMouse", -- 1120
	"NoFocusOnAppearing", -- 1120
	"NoBringToFrontOnFocus" -- 1120
} -- 1120
local initFooter = true -- 1129
local gamepadInputFocused = false -- 1130
local _anon_func_5 = function(allEntries, currentIndex) -- 1172
	if currentIndex > 1 then -- 1172
		return allEntries[currentIndex - 1] -- 1173
	else -- 1175
		return allEntries[#allEntries] -- 1175
	end -- 1172
end -- 1172
local _anon_func_6 = function(allEntries, currentIndex) -- 1179
	if currentIndex < #allEntries then -- 1179
		return allEntries[currentIndex + 1] -- 1180
	else -- 1182
		return allEntries[1] -- 1182
	end -- 1179
end -- 1179
footerWindow = threadLoop(function() -- 1131
	if mobileMode then -- 1132
		return -- 1132
	end -- 1132
	local zh = useChinese -- 1133
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1134
	if authCodeTTL <= 0 then -- 1135
		authCodeTTL = 30.0 -- 1136
		authCode = string.format("%06d", math.random(0, 999999)) -- 1137
	end -- 1135
	if HttpServer.wsConnectionCount > 0 then -- 1138
		return -- 1139
	end -- 1138
	if Keyboard:isKeyDown("Escape") then -- 1140
		allClear() -- 1141
		App.devMode = false -- 1142
		App:shutdown() -- 1143
	end -- 1140
	do -- 1144
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1145
		if ctrl and Keyboard:isKeyDown("Q") then -- 1146
			stop() -- 1147
		end -- 1146
		if ctrl and Keyboard:isKeyDown("Z") then -- 1148
			reloadCurrentEntry() -- 1149
		end -- 1148
		if ctrl and Keyboard:isKeyDown(",") then -- 1150
			if showFooter then -- 1151
				showStats = not showStats -- 1151
			else -- 1151
				showStats = true -- 1151
			end -- 1151
			showFooter = true -- 1152
			config.showFooter = showFooter -- 1153
			config.showStats = showStats -- 1154
		end -- 1150
		if ctrl and Keyboard:isKeyDown(".") then -- 1155
			if showFooter then -- 1156
				showConsole = not showConsole -- 1156
			else -- 1156
				showConsole = true -- 1156
			end -- 1156
			showFooter = true -- 1157
			config.showFooter = showFooter -- 1158
			config.showConsole = showConsole -- 1159
		end -- 1155
		if ctrl and Keyboard:isKeyDown("/") then -- 1160
			showFooter = not showFooter -- 1161
			config.showFooter = showFooter -- 1162
		end -- 1160
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1163
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1164
		local currentIndex = nil -- 1165
		for i, entry in ipairs(allEntries) do -- 1166
			if currentEntry == entry then -- 1167
				currentIndex = i -- 1168
			end -- 1167
		end -- 1166
		if left then -- 1169
			allClear() -- 1170
			if currentIndex == nil then -- 1171
				currentIndex = #allEntries + 1 -- 1171
			end -- 1171
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1172
		end -- 1169
		if right then -- 1176
			allClear() -- 1177
			if currentIndex == nil then -- 1178
				currentIndex = 0 -- 1178
			end -- 1178
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1179
		end -- 1176
	end -- 1144
	if not showEntry then -- 1183
		return -- 1183
	end -- 1183
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1185
		reloadDevEntry() -- 1189
	end -- 1185
	if initFooter then -- 1190
		initFooter = false -- 1191
	end -- 1190
	local width, height -- 1193
	do -- 1193
		local _obj_0 = App.visualSize -- 1193
		width, height = _obj_0.width, _obj_0.height -- 1193
	end -- 1193
	if isInEntry then -- 1194
		gamepadInputFocused = false -- 1195
	else -- 1197
		SetNextWindowBgAlpha(0.0) -- 1197
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1198
		SetNextWindowPos(Vec2.zero, "Always") -- 1199
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1200
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1201
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1202
					if not gamepadInputFocused then -- 1203
						SetWindowFocus("DoraGamepadInput") -- 1204
						gamepadInputFocused = true -- 1205
					end -- 1203
				end) -- 1202
			end) -- 1201
		end) -- 1200
	end -- 1194
	if isInEntry or showFooter then -- 1207
		SetNextWindowSize(Vec2(width, 50)) -- 1208
		SetNextWindowPos(Vec2(0, height - 50)) -- 1209
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1210
			return PushStyleVar("WindowRounding", 0, function() -- 1211
				return Begin("Footer", windowFlags, function() -- 1212
					Separator() -- 1213
					if iconTex then -- 1214
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1215
							showStats = not showStats -- 1216
							config.showStats = showStats -- 1217
						end -- 1215
						SameLine() -- 1218
						if Button(">_", Vec2(30, 30)) then -- 1219
							showConsole = not showConsole -- 1220
							config.showConsole = showConsole -- 1221
						end -- 1219
					end -- 1214
					if isInEntry and config.updateNotification then -- 1222
						SameLine() -- 1223
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1224
							allClear() -- 1225
							config.updateNotification = false -- 1226
							enterDemoEntry({ -- 1228
								entryName = "SelfUpdater", -- 1228
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1229
							}) -- 1227
						end -- 1224
					end -- 1222
					if not isInEntry then -- 1230
						SameLine() -- 1231
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1232
						local currentIndex = nil -- 1233
						for i, entry in ipairs(allEntries) do -- 1234
							if currentEntry == entry then -- 1235
								currentIndex = i -- 1236
							end -- 1235
						end -- 1234
						if currentIndex then -- 1237
							if currentIndex > 1 then -- 1238
								SameLine() -- 1239
								if Button("<<", Vec2(30, 30)) then -- 1240
									allClear() -- 1241
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1242
								end -- 1240
							end -- 1238
							if currentIndex < #allEntries then -- 1243
								SameLine() -- 1244
								if Button(">>", Vec2(30, 30)) then -- 1245
									allClear() -- 1246
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1247
								end -- 1245
							end -- 1243
						end -- 1237
						SameLine() -- 1248
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1249
							reloadCurrentEntry() -- 1250
						end -- 1249
						if back then -- 1251
							allClear() -- 1252
							isInEntry = true -- 1253
							currentEntry = nil -- 1254
						end -- 1251
					end -- 1230
				end) -- 1212
			end) -- 1211
		end) -- 1210
	end -- 1207
	if isInEntry then -- 1256
		local showURL = true -- 1257
		local webIDEWidth -- 1258
		do -- 1258
			local base -- 1259
			if config.updateNotification then -- 1259
				base = 460 -- 1259
			else -- 1259
				base = 360 -- 1259
			end -- 1259
			local extra -- 1260
			if config.authRequired then -- 1260
				extra = 35 -- 1260
			else -- 1260
				extra = 0 -- 1260
			end -- 1260
			webIDEWidth = base + extra -- 1261
		end -- 1258
		if width < webIDEWidth then -- 1262
			showURL = false -- 1262
		end -- 1262
		SetNextWindowBgAlpha(0.0) -- 1263
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1264
		Begin("Web IDE", displayWindowFlags, function() -- 1265
			local pending = AuthSession.getPending() -- 1266
			local hovered = false -- 1267
			if not pending and showURL then -- 1268
				do -- 1269
					local url -- 1269
					if webStatus ~= nil then -- 1269
						url = webStatus.url -- 1269
					end -- 1269
					if url then -- 1269
						if isDesktop and not config.fullScreen then -- 1270
							if urlClicked then -- 1271
								BeginDisabled(function() -- 1272
									return Button(url) -- 1272
								end) -- 1272
							elseif Button(url) then -- 1273
								urlClicked = once(function() -- 1274
									return sleep(5) -- 1274
								end) -- 1274
								App:openURL("http://localhost:8866") -- 1275
							end -- 1271
						else -- 1277
							TextColored(descColor, url) -- 1277
						end -- 1270
					else -- 1279
						TextColored(descColor, zh and '不可用' or 'not available') -- 1279
					end -- 1269
				end -- 1269
				hovered = IsItemHovered() -- 1280
			else -- 1282
				TextColored(descColor, "(?)") -- 1282
				hovered = IsItemHovered() -- 1283
			end -- 1268
			SameLine() -- 1284
			local themeColor = App.themeColor -- 1285
			if pending then -- 1286
				if not pending.approved then -- 1287
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1288
					local ttl = pending.ttl or 1 -- 1289
					PushStyleColor("Text", themeColor, function() -- 1290
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1291
						hovered = hovered or IsItemHovered() -- 1292
					end) -- 1290
					SameLine() -- 1293
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1294
						AuthSession.approvePending(pending.sessionId) -- 1295
					end -- 1294
					if hovered then -- 1296
						return BeginTooltip(function() -- 1297
							return PushTextWrapPos(280, function() -- 1298
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1299
							end) -- 1298
						end) -- 1297
					end -- 1296
				end -- 1287
			else -- 1301
				if config.authRequired then -- 1301
					PushStyleColor("Text", themeColor, function() -- 1302
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1303
						hovered = hovered or IsItemHovered() -- 1304
					end) -- 1302
					if hovered then -- 1305
						return BeginTooltip(function() -- 1306
							return PushTextWrapPos(280, function() -- 1307
								local url -- 1308
								if webStatus ~= nil then -- 1308
									url = webStatus.url -- 1308
								end -- 1308
								if url then -- 1308
									local address -- 1309
									if showURL then -- 1309
										address = "Web IDE" -- 1309
									else -- 1309
										address = url -- 1309
									end -- 1309
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1310
								else -- 1312
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1312
								end -- 1308
							end) -- 1307
						end) -- 1306
					end -- 1305
				else -- 1314
					if hovered then -- 1314
						return BeginTooltip(function() -- 1315
							return PushTextWrapPos(280, function() -- 1316
								local url -- 1317
								if webStatus ~= nil then -- 1317
									url = webStatus.url -- 1317
								end -- 1317
								if url then -- 1317
									local address -- 1318
									if showURL then -- 1318
										address = "Web IDE" -- 1318
									else -- 1318
										address = url -- 1318
									end -- 1318
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1319
								else -- 1321
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1321
								end -- 1317
							end) -- 1316
						end) -- 1315
					end -- 1314
				end -- 1301
			end -- 1286
		end) -- 1265
	end -- 1256
	if not isInEntry then -- 1323
		SetNextWindowSize(Vec2(50, 50)) -- 1324
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1325
		PushStyleColor("WindowBg", transparant, function() -- 1326
			return Begin("Show", displayWindowFlags, function() -- 1326
				if width >= 370 then -- 1327
					local changed -- 1328
					changed, showFooter = Checkbox("##dev", showFooter) -- 1328
					if changed then -- 1328
						config.showFooter = showFooter -- 1329
					end -- 1328
				end -- 1327
			end) -- 1326
		end) -- 1326
	end -- 1323
	if isInEntry or showFooter then -- 1331
		if showStats then -- 1332
			PushStyleVar("WindowRounding", 0, function() -- 1333
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1334
				SetNextWindowSize(Vec2(0, height - 50)) -- 1335
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1336
				config.showStats = showStats -- 1337
			end) -- 1333
		end -- 1332
		if showConsole then -- 1338
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1339
			return PushStyleVar("WindowRounding", 6, function() -- 1340
				return ShowConsole() -- 1341
			end) -- 1340
		end -- 1338
	end -- 1331
end) -- 1131
local MaxWidth <const> = 960 -- 1343
local toolOpen = false -- 1345
local filterText = nil -- 1346
local anyEntryMatched = false -- 1347
local match -- 1348
match = function(name) -- 1348
	local res = not filterText or name:lower():match(filterText) -- 1349
	if res then -- 1350
		anyEntryMatched = true -- 1350
	end -- 1350
	return res -- 1351
end -- 1348
local sep -- 1353
sep = function() -- 1353
	return SeparatorText("") -- 1353
end -- 1353
local thinSep -- 1354
thinSep = function() -- 1354
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1354
end -- 1354
entryWindow = threadLoop(function() -- 1356
	local connected = syncWebIDEControl() -- 1357
	if (pendingUIMode ~= nil) then -- 1359
		local nextMode = pendingUIMode -- 1360
		pendingUIMode = nil -- 1361
		applyUIMode(nextMode) -- 1362
	end -- 1359
	if mobileMode and not connected then -- 1363
		if isInEntry and not feedHost then -- 1364
			applyUIMode(true) -- 1364
		end -- 1364
		return -- 1365
	end -- 1363
	if App.fpsLimited ~= config.fpsLimited then -- 1366
		config.fpsLimited = App.fpsLimited -- 1367
	end -- 1366
	if App.targetFPS ~= config.targetFPS then -- 1368
		config.targetFPS = App.targetFPS -- 1369
	end -- 1368
	if View.vsync ~= config.vsync then -- 1370
		config.vsync = View.vsync -- 1371
	end -- 1370
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1372
		config.fixedFPS = Director.scheduler.fixedFPS -- 1373
	end -- 1372
	if Director.profilerSending ~= config.webProfiler then -- 1374
		config.webProfiler = Director.profilerSending -- 1375
	end -- 1374
	if urlClicked then -- 1376
		local _, result = coroutine.resume(urlClicked) -- 1377
		if result then -- 1378
			coroutine.close(urlClicked) -- 1379
			urlClicked = nil -- 1380
		end -- 1378
	end -- 1376
	if not isInEntry then -- 1381
		return -- 1381
	end -- 1381
	local zh = useChinese -- 1382
	local themeColor = App.themeColor -- 1383
	if connected then -- 1384
		local width, height -- 1385
		do -- 1385
			local _obj_0 = App.visualSize -- 1385
			width, height = _obj_0.width, _obj_0.height -- 1385
		end -- 1385
		SetNextWindowBgAlpha(0.5) -- 1386
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1387
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1388
			Separator() -- 1389
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1390
			if iconTex then -- 1391
				Image(icon, Vec2(24, 24)) -- 1392
				SameLine() -- 1393
			end -- 1391
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1394
			TextColored(descColor, slogon) -- 1395
			return Separator() -- 1396
		end) -- 1388
		return -- 1397
	end -- 1384
	if not showEntry then -- 1398
		return -- 1398
	end -- 1398
	local fullWidth, height -- 1400
	do -- 1400
		local _obj_0 = App.visualSize -- 1400
		fullWidth, height = _obj_0.width, _obj_0.height -- 1400
	end -- 1400
	local width = math.min(MaxWidth, fullWidth) -- 1401
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1402
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1403
	SetNextWindowPos(Vec2.zero) -- 1404
	SetNextWindowBgAlpha(0) -- 1405
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1406
	do -- 1407
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1408
			return Begin("Dora Dev", windowFlags, function() -- 1409
				Dummy(Vec2(fullWidth - 20, 0)) -- 1410
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1411
				SameLine() -- 1412
				if Button(zh and "Go 模式" or "Go Mode") then -- 1413
					setUIMode("mobile") -- 1414
				end -- 1413
				if fullWidth >= 540 then -- 1415
					SameLine() -- 1416
					Dummy(Vec2(fullWidth - 540, 0)) -- 1417
					SameLine() -- 1418
					SetNextItemWidth(zh and -95 or -140) -- 1419
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1420
						"AutoSelectAll" -- 1420
					}) then -- 1420
						config.filter = filterBuf.text -- 1421
					end -- 1420
					SameLine() -- 1422
					if Button(zh and '下载' or 'Download') then -- 1423
						allClear() -- 1424
						enterDemoEntry({ -- 1426
							entryName = "ResourceDownloader", -- 1426
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1427
						}) -- 1425
					end -- 1423
				end -- 1415
				return Separator() -- 1428
			end) -- 1409
		end) -- 1408
	end -- 1407
	anyEntryMatched = false -- 1430
	SetNextWindowPos(Vec2(0, 50)) -- 1431
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1432
	do -- 1433
		return PushStyleColor("WindowBg", transparant, function() -- 1434
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1435
				return PushStyleVar("Alpha", 1, function() -- 1436
					return Begin("Content", windowFlags, function() -- 1437
						local DemoViewWidth <const> = 220 -- 1438
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1439
						if filterText then -- 1440
							filterText = filterText:lower() -- 1440
						end -- 1440
						if #gamesInDev > 0 then -- 1441
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1442
							Columns(columns, false) -- 1443
							local realViewWidth = GetColumnWidth() - 50 -- 1444
							for _index_0 = 1, #gamesInDev do -- 1445
								local game = gamesInDev[_index_0] -- 1445
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1446
								local displayName -- 1455
								if repo then -- 1455
									if zh then -- 1456
										displayName = repo.title.zh -- 1456
									else -- 1456
										displayName = repo.title.en -- 1456
									end -- 1456
								end -- 1455
								if displayName == nil then -- 1457
									displayName = gameName -- 1457
								end -- 1457
								if match(displayName) then -- 1458
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1459
									SameLine() -- 1460
									TextWrapped(displayName) -- 1461
									if columns > 1 then -- 1462
										if bannerFile then -- 1463
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1464
											local displayWidth <const> = realViewWidth -- 1465
											texHeight = displayWidth * texHeight / texWidth -- 1466
											texWidth = displayWidth -- 1467
											Dummy(Vec2.zero) -- 1468
											SameLine() -- 1469
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1470
										end -- 1463
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1471
											enterDemoEntry(game) -- 1472
										end -- 1471
									else -- 1474
										if bannerFile then -- 1474
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1475
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1476
											local sizing = 0.8 -- 1477
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1478
											texWidth = displayWidth * sizing -- 1479
											if texWidth > 500 then -- 1480
												sizing = 0.6 -- 1481
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1482
												texWidth = displayWidth * sizing -- 1483
											end -- 1480
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1484
											Dummy(Vec2(padding, 0)) -- 1485
											SameLine() -- 1486
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1487
										end -- 1474
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1488
											enterDemoEntry(game) -- 1489
										end -- 1488
									end -- 1462
									if #tests == 0 and #examples == 0 then -- 1490
										thinSep() -- 1491
									end -- 1490
									NextColumn() -- 1492
								end -- 1458
								local showSep = false -- 1493
								if #examples > 0 then -- 1494
									local showExample = false -- 1495
									for _index_1 = 1, #examples do -- 1496
										local _des_0 = examples[_index_1] -- 1496
										local entryName = _des_0.entryName -- 1496
										if match(entryName) then -- 1497
											showExample = true -- 1497
											break -- 1497
										end -- 1497
									end -- 1496
									if showExample then -- 1498
										showSep = true -- 1499
										Columns(1, false) -- 1500
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1501
										SameLine() -- 1502
										local opened -- 1503
										if (filterText ~= nil) then -- 1503
											opened = showExample -- 1503
										else -- 1503
											opened = false -- 1503
										end -- 1503
										if game.exampleOpen == nil then -- 1504
											game.exampleOpen = opened -- 1504
										end -- 1504
										SetNextItemOpen(game.exampleOpen) -- 1505
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1506
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1507
												Columns(maxColumns, false) -- 1508
												for _index_1 = 1, #examples do -- 1509
													local example = examples[_index_1] -- 1509
													local entryName = example.entryName -- 1510
													if not match(entryName) then -- 1511
														goto _continue_0 -- 1511
													end -- 1511
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1512
														if Button(entryName, Vec2(-1, 40)) then -- 1513
															enterDemoEntry(example) -- 1514
														end -- 1513
														return NextColumn() -- 1515
													end) -- 1512
													opened = true -- 1516
													::_continue_0:: -- 1510
												end -- 1509
											end) -- 1507
										end) -- 1506
										game.exampleOpen = opened -- 1517
									end -- 1498
								end -- 1494
								if #tests > 0 then -- 1518
									local showTest = false -- 1519
									for _index_1 = 1, #tests do -- 1520
										local _des_0 = tests[_index_1] -- 1520
										local entryName = _des_0.entryName -- 1520
										if match(entryName) then -- 1521
											showTest = true -- 1521
											break -- 1521
										end -- 1521
									end -- 1520
									if showTest then -- 1522
										showSep = true -- 1523
										Columns(1, false) -- 1524
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1525
										SameLine() -- 1526
										local opened -- 1527
										if (filterText ~= nil) then -- 1527
											opened = showTest -- 1527
										else -- 1527
											opened = false -- 1527
										end -- 1527
										if game.testOpen == nil then -- 1528
											game.testOpen = opened -- 1528
										end -- 1528
										SetNextItemOpen(game.testOpen) -- 1529
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1530
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1531
												Columns(maxColumns, false) -- 1532
												for _index_1 = 1, #tests do -- 1533
													local test = tests[_index_1] -- 1533
													local entryName = test.entryName -- 1534
													if not match(entryName) then -- 1535
														goto _continue_0 -- 1535
													end -- 1535
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1536
														if Button(entryName, Vec2(-1, 40)) then -- 1537
															enterDemoEntry(test) -- 1538
														end -- 1537
														return NextColumn() -- 1539
													end) -- 1536
													opened = true -- 1540
													::_continue_0:: -- 1534
												end -- 1533
											end) -- 1531
										end) -- 1530
										game.testOpen = opened -- 1541
									end -- 1522
								end -- 1518
								if showSep then -- 1542
									Columns(1, false) -- 1543
									thinSep() -- 1544
									Columns(columns, false) -- 1545
								end -- 1542
							end -- 1445
						end -- 1441
						if #doraTools > 0 then -- 1546
							local showTool = false -- 1547
							for _index_0 = 1, #doraTools do -- 1548
								local _des_0 = doraTools[_index_0] -- 1548
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1548
								local displayName -- 1549
								if repo then -- 1549
									if zh then -- 1550
										displayName = repo.title.zh -- 1550
									else -- 1550
										displayName = repo.title.en -- 1550
									end -- 1550
								end -- 1549
								if displayName == nil then -- 1551
									displayName = entryName -- 1551
								end -- 1551
								if match(displayName) then -- 1552
									showTool = true -- 1552
									break -- 1552
								end -- 1552
							end -- 1548
							if not showTool then -- 1553
								goto endEntry -- 1553
							end -- 1553
							Columns(1, false) -- 1554
							TextColored(themeColor, "Dora SSR:") -- 1555
							SameLine() -- 1556
							Text(zh and "开发支持" or "Development Support") -- 1557
							Separator() -- 1558
							if #doraTools > 0 then -- 1559
								local opened -- 1560
								if (filterText ~= nil) then -- 1560
									opened = showTool -- 1560
								else -- 1560
									opened = false -- 1560
								end -- 1560
								SetNextItemOpen(toolOpen) -- 1561
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1562
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1563
										Columns(maxColumns, false) -- 1564
										for _index_0 = 1, #doraTools do -- 1565
											local tool = doraTools[_index_0] -- 1565
											local entryName, repo = tool.entryName, tool.repo -- 1566
											local displayName -- 1567
											if repo then -- 1567
												if zh then -- 1568
													displayName = repo.title.zh -- 1568
												else -- 1568
													displayName = repo.title.en -- 1568
												end -- 1568
											end -- 1567
											if displayName == nil then -- 1569
												displayName = entryName -- 1569
											end -- 1569
											if not match(displayName) then -- 1570
												goto _continue_0 -- 1570
											end -- 1570
											if Button(displayName, Vec2(-1, 40)) then -- 1571
												enterDemoEntry(tool) -- 1572
											end -- 1571
											NextColumn() -- 1573
											::_continue_0:: -- 1566
										end -- 1565
										Columns(1, false) -- 1574
										opened = true -- 1575
									end) -- 1563
								end) -- 1562
								toolOpen = opened -- 1576
							end -- 1559
						end -- 1546
						::endEntry:: -- 1577
						if not anyEntryMatched then -- 1578
							SetNextWindowBgAlpha(0) -- 1579
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1580
							Begin("Entries Not Found", displayWindowFlags, function() -- 1581
								Separator() -- 1582
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1583
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1584
								return Separator() -- 1585
							end) -- 1581
						end -- 1578
						Columns(1, false) -- 1586
						Dummy(Vec2(100, 80)) -- 1587
						return ScrollWhenDraggingOnVoid() -- 1588
					end) -- 1437
				end) -- 1436
			end) -- 1435
		end) -- 1434
	end -- 1433
end) -- 1356
local sceneModuleCache = moduleCache -- 1593
moduleCache = { } -- 1594
webStatus = oldRequire("Script.Dev.WebServer") -- 1595
moduleCache = sceneModuleCache -- 1596
startMobileUI = function() -- 1598
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1599
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1600
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1601
	local getMobileFeedResources -- 1602
	do -- 1602
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1602
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1602
	end -- 1602
	local loadCachedCatalog -- 1603
	do -- 1603
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1603
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1603
	end -- 1603
	local getResourceInstallPath -- 1604
	do -- 1604
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1604
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1604
	end -- 1604
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1605
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1606
	local feedOptions = nil -- 1607
	local mobileLaunchErrors = { } -- 1608
	local withMobileLaunchErrors -- 1609
	withMobileLaunchErrors = function(items) -- 1609
		for _index_0 = 1, #items do -- 1610
			local item = items[_index_0] -- 1610
			item.launchError = mobileLaunchErrors[item.id] -- 1611
		end -- 1610
		return items -- 1612
	end -- 1609
	local restartMobileFeed -- 1613
	restartMobileFeed = function(entry) -- 1613
		if feedHost then -- 1614
			feedHost:removeFromParent(true) -- 1614
		end -- 1614
		feedOptions.initialEntry = entry -- 1615
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1616
	end -- 1613
	local startMobilePlay -- 1617
	startMobilePlay = function(entry) -- 1617
		if HttpServer.wsConnectionCount > 0 then -- 1618
			return -- 1618
		end -- 1618
		if remixHost then -- 1619
			remixHost:removeFromParent(true) -- 1619
		end -- 1619
		remixHost = nil -- 1620
		feedHost.visible = false -- 1621
		mobileLaunchErrors[entry.id] = nil -- 1622
		entry.launchError = nil -- 1623
		local restoreMobileFeed -- 1624
		restoreMobileFeed = function() -- 1624
			allClear() -- 1625
			isInEntry = true -- 1626
			currentEntry = nil -- 1627
			return restartMobileFeed(entry) -- 1628
		end -- 1624
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1630
			onExit = function() -- 1630
				return restoreMobileFeed() -- 1630
			end, -- 1630
			onRuntimeError = function() -- 1631
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1632
				return restoreMobileFeed() -- 1633
			end -- 1631
		})) -- 1629
		return thread(function() -- 1635
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1636
			if success then -- 1637
				return -- 1637
			end -- 1637
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1638
			return restoreMobileFeed() -- 1639
		end) -- 1635
	end -- 1617
	feedOptions = { -- 1641
		onSwitchMode = function() -- 1641
			if HttpServer.wsConnectionCount == 0 then -- 1641
				pendingUIMode = false -- 1641
			end -- 1641
		end, -- 1641
		getLocalEntries = function() -- 1642
			return withMobileLaunchErrors(getMobileFeedEntries(true)) -- 1642
		end, -- 1642
		syncDiscover = function(onProgress, onDone) -- 1643
			return mobileCatalog.syncMobileCatalog(onProgress, onDone) -- 1643
		end, -- 1643
		getDiscoverEntries = function() -- 1644
			local cached = loadCachedCatalog() -- 1645
			if not (cached.success and cached.snapshot) then -- 1646
				return { } -- 1646
			end -- 1646
			local items = { } -- 1647
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1648
			for _index_0 = 1, #_list_0 do -- 1648
				local resource = _list_0[_index_0] -- 1648
				local installed = lifecycle.isMobileResourceReady(resource) -- 1649
				local installPath = getResourceInstallPath(resource.id) -- 1650
				items[#items + 1] = { -- 1652
					id = resource.id, -- 1652
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1653
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1654
					kind = "discover", -- 1655
					bannerFile = resource.bannerPath, -- 1656
					workDir = installed and installPath or nil, -- 1657
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1658
					installed = installed, -- 1659
					resource = resource, -- 1660
					catalogCommit = cached.snapshot.commit, -- 1661
					launchError = mobileLaunchErrors[resource.id] -- 1662
				} -- 1651
			end -- 1648
			return items -- 1664
		end, -- 1644
		prepare = function(entry, repairIncomplete, onProgress, onDone) -- 1665
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1666
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1667
			end), repairIncomplete) -- 1666
		end, -- 1665
		createProject = function(name) -- 1669
			local result = projectCreate.createMobileTypeScriptProject(name) -- 1670
			if not result.success then -- 1671
				return result -- 1671
			end -- 1671
			local _list_0 = getMobileFeedEntries(true) -- 1672
			for _index_0 = 1, #_list_0 do -- 1672
				local entry = _list_0[_index_0] -- 1672
				if entry.workDir == result.workDir then -- 1673
					return { -- 1674
						success = true, -- 1674
						entry = entry -- 1674
					} -- 1674
				end -- 1673
			end -- 1672
			return { -- 1675
				success = false, -- 1675
				error = "created-project-not-found" -- 1675
			} -- 1675
		end, -- 1669
		onPlay = function(entry) -- 1676
			return startMobilePlay(entry) -- 1676
		end, -- 1676
		onRemix = function(entry) -- 1677
			if HttpServer.wsConnectionCount > 0 then -- 1678
				return -- 1678
			end -- 1678
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1679
			local originFeed = feedHost -- 1680
			feedHost.visible = false -- 1681
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1683
				entry = entry, -- 1683
				onBack = function() -- 1684
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1685
						originFeed:emit("RestoreFeedEntry", entry) -- 1686
						originFeed.visible = true -- 1687
					end -- 1685
				end, -- 1684
				onPlay = function(current) -- 1688
					return startMobilePlay(current) -- 1688
				end -- 1688
			})) -- 1682
		end -- 1677
	} -- 1640
	return restartMobileFeed() -- 1691
end -- 1598
if mobileMode then -- 1693
	applyUIMode(true) -- 1693
end -- 1693
return _module_0 -- 1
