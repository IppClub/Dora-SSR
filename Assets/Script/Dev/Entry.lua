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
	App.targetFPS = math.floor(config.targetFPS) -- 93
else -- 95
	config.targetFPS = App.targetFPS -- 95
end -- 92
if (config.vsync ~= nil) then -- 97
	View.vsync = config.vsync -- 98
else -- 100
	config.vsync = View.vsync -- 100
end -- 97
if (config.fixedFPS ~= nil) then -- 102
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 103
else -- 105
	config.fixedFPS = Director.scheduler.fixedFPS -- 105
end -- 102
if not (config.showPreview ~= nil) then -- 107
	config.showPreview = true -- 108
end -- 107
if not (config.authRequired ~= nil) then -- 110
	local _val_0 = App.platform -- 111
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 111
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
		config.alwaysOnTop = false -- 138
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
local setFooterVisible -- 166
setFooterVisible = function(visible) -- 166
	if visible == nil then -- 166
		visible = true -- 166
	end -- 166
	showFooter = visible -- 167
	config.showFooter = showFooter -- 168
end -- 166
_module_0["setFooterVisible"] = setFooterVisible -- 166
local filterBuf = Buffer(20) -- 170
if (config.filter ~= nil) then -- 171
	filterBuf.text = config.filter -- 172
else -- 174
	config.filter = "" -- 174
end -- 171
local engineDev = false -- 176
if (config.engineDev ~= nil) then -- 177
	engineDev = config.engineDev -- 178
else -- 180
	config.engineDev = engineDev -- 180
end -- 177
if (config.webProfiler ~= nil) then -- 182
	Director.profilerSending = config.webProfiler -- 183
else -- 185
	config.webProfiler = true -- 185
	Director.profilerSending = true -- 186
end -- 182
if not (config.drawerWidth ~= nil) then -- 188
	config.drawerWidth = 200 -- 189
end -- 188
_module_0.getConfig = function() -- 191
	return config -- 191
end -- 191
_module_0.getEngineDev = function() -- 192
	if not App.debugging then -- 193
		return false -- 193
	end -- 193
	return config.engineDev -- 194
end -- 192
local _anon_func_0 = function() -- 199
	local _val_0 = App.platform -- 199
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 199
end -- 199
_module_0.connectWebIDE = function() -- 196
	if not config.webIDEConnected then -- 197
		config.webIDEConnected = true -- 198
		if _anon_func_0() then -- 199
			local ratio = App.winSize.width / App.visualSize.width -- 200
			App.winSize = Size(640 * ratio, 480 * ratio) -- 201
		end -- 199
	end -- 197
end -- 196
local updateCheck -- 203
updateCheck = function() -- 203
	return thread(function() -- 203
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 204
		if res then -- 204
			local data = json.decode(res) -- 205
			if data then -- 205
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 206
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 207
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 208
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 209
				if na < a then -- 210
					goto not_new_version -- 211
				end -- 210
				if na == a then -- 212
					if nb < b then -- 213
						goto not_new_version -- 214
					end -- 213
					if nb == b then -- 215
						if nc < c then -- 216
							goto not_new_version -- 217
						end -- 216
						if nc == c then -- 218
							goto not_new_version -- 219
						end -- 218
					end -- 215
				end -- 212
				config.updateNotification = true -- 220
				::not_new_version:: -- 221
				config.lastUpdateCheck = os.time() -- 222
			end -- 205
		end -- 204
	end) -- 203
end -- 203
if (config.lastUpdateCheck ~= nil) then -- 224
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 225
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 226
		updateCheck() -- 227
	end -- 226
else -- 229
	updateCheck() -- 229
end -- 224
local Set, Struct, LintYueGlobals, GSplit -- 231
do -- 231
	local _obj_0 = require("Utils") -- 231
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 231
end -- 231
local yueext = yue.options.extension -- 232
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 234
local building = false -- 236
local getAllFiles -- 238
getAllFiles = function(path, exts, recursive) -- 238
	if recursive == nil then -- 238
		recursive = true -- 238
	end -- 238
	local filters = Set(exts) -- 239
	local files -- 240
	if recursive then -- 240
		files = Content:getAllFiles(path) -- 241
	else -- 243
		files = Content:getFiles(path) -- 243
	end -- 240
	local _accum_0 = { } -- 244
	local _len_0 = 1 -- 244
	for _index_0 = 1, #files do -- 244
		local file = files[_index_0] -- 244
		if not filters[Path:getExt(file)] then -- 245
			goto _continue_0 -- 245
		end -- 245
		_accum_0[_len_0] = file -- 246
		_len_0 = _len_0 + 1 -- 245
		::_continue_0:: -- 245
	end -- 244
	return _accum_0 -- 244
end -- 238
_module_0["getAllFiles"] = getAllFiles -- 238
local getFileEntries -- 248
getFileEntries = function(path, recursive, excludeFiles) -- 248
	if recursive == nil then -- 248
		recursive = true -- 248
	end -- 248
	if excludeFiles == nil then -- 248
		excludeFiles = nil -- 248
	end -- 248
	local entries = { } -- 249
	local excludes -- 250
	if excludeFiles then -- 250
		excludes = Set(excludeFiles) -- 251
	end -- 250
	local _list_0 = getAllFiles(path, { -- 252
		"lua", -- 252
		"xml", -- 252
		yueext, -- 252
		"tl" -- 252
	}, recursive) -- 252
	for _index_0 = 1, #_list_0 do -- 252
		local file = _list_0[_index_0] -- 252
		local entryName = Path:getName(file) -- 253
		if excludes and excludes[entryName] then -- 254
			goto _continue_0 -- 255
		end -- 254
		local fileName = Path:replaceExt(file, "") -- 256
		fileName = Path(path, fileName) -- 257
		local entryAdded -- 258
		for _index_1 = 1, #entries do -- 258
			local _des_0 = entries[_index_1] -- 258
			local ename, efile = _des_0.entryName, _des_0.fileName -- 258
			if entryName == ename and efile == fileName then -- 259
				entryAdded = true -- 259
				break -- 259
			end -- 259
		end -- 258
		if entryAdded then -- 260
			goto _continue_0 -- 260
		end -- 260
		local entry = { -- 261
			entryName = entryName, -- 261
			fileName = fileName -- 261
		} -- 261
		entries[#entries + 1] = entry -- 262
		::_continue_0:: -- 253
	end -- 252
	table.sort(entries, function(a, b) -- 263
		return a.entryName < b.entryName -- 263
	end) -- 263
	return entries -- 264
end -- 248
local getProjectEntries -- 266
getProjectEntries = function(path, noPreview) -- 266
	if noPreview == nil then -- 266
		noPreview = false -- 266
	end -- 266
	local entries = { } -- 267
	local _list_0 = Content:getDirs(path) -- 268
	for _index_0 = 1, #_list_0 do -- 268
		local dir = _list_0[_index_0] -- 268
		if dir:match("^%.") then -- 269
			goto _continue_0 -- 269
		end -- 269
		local _list_1 = getAllFiles(Path(path, dir), { -- 270
			"lua", -- 270
			"xml", -- 270
			yueext, -- 270
			"tl", -- 270
			"wasm" -- 270
		}) -- 270
		for _index_1 = 1, #_list_1 do -- 270
			local file = _list_1[_index_1] -- 270
			if "init" == Path:getName(file):lower() then -- 271
				local fileName = Path:replaceExt(file, "") -- 272
				fileName = Path(path, dir, fileName) -- 273
				local projectPath = Path:getPath(fileName) -- 274
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 275
				local repo = nil -- 276
				if Content:exist(repoFile) then -- 277
					local str = Content:load(repoFile) -- 278
					if str then -- 278
						repo = json.decode(str) -- 279
					end -- 278
				end -- 277
				local entryName = Path:getName(projectPath) -- 280
				local entryAdded -- 281
				for _index_2 = 1, #entries do -- 281
					local _des_0 = entries[_index_2] -- 281
					local ename, efile = _des_0.entryName, _des_0.fileName -- 281
					if entryName == ename and efile == fileName then -- 282
						entryAdded = true -- 282
						break -- 282
					end -- 282
				end -- 281
				if entryAdded then -- 283
					goto _continue_1 -- 283
				end -- 283
				local examples = { } -- 284
				local tests = { } -- 285
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 286
				if Content:exist(examplePath) then -- 287
					local _list_2 = getFileEntries(examplePath) -- 288
					for _index_2 = 1, #_list_2 do -- 288
						local _des_0 = _list_2[_index_2] -- 288
						local name, ePath = _des_0.entryName, _des_0.fileName -- 288
						local entry = { -- 290
							entryName = name, -- 290
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 291
							workDir = projectPath -- 292
						} -- 289
						examples[#examples + 1] = entry -- 294
					end -- 288
				end -- 287
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 295
				if Content:exist(testPath) then -- 296
					local _list_2 = getFileEntries(testPath) -- 297
					for _index_2 = 1, #_list_2 do -- 297
						local _des_0 = _list_2[_index_2] -- 297
						local name, tPath = _des_0.entryName, _des_0.fileName -- 297
						local entry = { -- 299
							entryName = name, -- 299
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 300
							workDir = projectPath -- 301
						} -- 298
						tests[#tests + 1] = entry -- 303
					end -- 297
				end -- 296
				local entry = { -- 304
					entryName = entryName, -- 304
					fileName = fileName, -- 304
					examples = examples, -- 304
					tests = tests, -- 304
					repo = repo -- 304
				} -- 304
				local bannerFile -- 305
				do -- 305
					local _val_0 -- 305
					repeat -- 305
						if noPreview then -- 306
							_val_0 = nil -- 306
							break -- 306
						end -- 306
						if not config.showPreview then -- 307
							_val_0 = nil -- 307
							break -- 307
						end -- 307
						local f = Path(projectPath, ".dora", "banner.jpg") -- 308
						if Content:exist(f) then -- 309
							_val_0 = f -- 309
							break -- 309
						end -- 309
						f = Path(projectPath, ".dora", "banner.png") -- 310
						if Content:exist(f) then -- 311
							_val_0 = f -- 311
							break -- 311
						end -- 311
						f = Path(projectPath, "Image", "banner.jpg") -- 312
						if Content:exist(f) then -- 313
							_val_0 = f -- 313
							break -- 313
						end -- 313
						f = Path(projectPath, "Image", "banner.png") -- 314
						if Content:exist(f) then -- 315
							_val_0 = f -- 315
							break -- 315
						end -- 315
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 316
						if Content:exist(f) then -- 317
							_val_0 = f -- 317
							break -- 317
						end -- 317
					until true -- 305
					bannerFile = _val_0 -- 305
				end -- 305
				if bannerFile then -- 319
					thread(function() -- 319
						if Cache:loadAsync(bannerFile) then -- 320
							local bannerTex = Texture2D(bannerFile) -- 321
							if bannerTex then -- 321
								entry.bannerFile = bannerFile -- 322
								entry.bannerTex = bannerTex -- 323
							end -- 321
						end -- 320
					end) -- 319
				end -- 319
				entries[#entries + 1] = entry -- 324
			end -- 271
			::_continue_1:: -- 271
		end -- 270
		::_continue_0:: -- 269
	end -- 268
	table.sort(entries, function(a, b) -- 325
		return a.entryName < b.entryName -- 325
	end) -- 325
	return entries -- 326
end -- 266
_module_0["getProjectEntries"] = getProjectEntries -- 266
local gamesInDev -- 328
local doraTools -- 329
local allEntries -- 330
local isToolEntry -- 332
isToolEntry = function(entry) -- 332
	do -- 333
		local _type_0 = type(entry) -- 333
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 333
		if _tab_0 then -- 333
			local categories -- 333
			do -- 333
				local _obj_0 = entry.repo -- 333
				local _type_1 = type(_obj_0) -- 333
				if "table" == _type_1 or "userdata" == _type_1 then -- 333
					categories = _obj_0.categories -- 333
				end -- 333
			end -- 333
			if categories ~= nil then -- 333
				for _index_0 = 1, #categories do -- 334
					local category = categories[_index_0] -- 334
					if "string" == type(category) and category:lower() == "tool" then -- 335
						return true -- 336
					end -- 335
				end -- 334
			end -- 333
		end -- 333
	end -- 333
	return false -- 332
end -- 332
local getEntryTitle -- 338
getEntryTitle = function(entry) -- 338
	local title -- 339
	do -- 339
		local repo = entry.repo -- 339
		if repo then -- 339
			if repo.title and "table" == type(repo.title) then -- 340
				if useChinese then -- 341
					title = repo.title.zh -- 341
				else -- 341
					title = repo.title.en -- 341
				end -- 341
			end -- 340
		end -- 339
	end -- 339
	if title ~= nil then -- 342
		return title -- 342
	else -- 342
		return entry.entryName -- 342
	end -- 342
end -- 338
local updateEntries -- 344
updateEntries = function() -- 344
	local projectEntries = getProjectEntries(Content.writablePath) -- 345
	gamesInDev = { } -- 346
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 347
	for _index_0 = 1, #doraTools do -- 348
		local tool = doraTools[_index_0] -- 348
		tool.kind = "tool" -- 349
		tool.builtin = true -- 350
	end -- 348
	for _index_0 = 1, #projectEntries do -- 351
		local entry = projectEntries[_index_0] -- 351
		if isToolEntry(entry) then -- 352
			entry.kind = "tool" -- 353
			doraTools[#doraTools + 1] = entry -- 354
		else -- 356
			entry.kind = "game" -- 356
			gamesInDev[#gamesInDev + 1] = entry -- 357
		end -- 352
	end -- 351
	allEntries = { } -- 358
	for _index_0 = 1, #gamesInDev do -- 359
		local game = gamesInDev[_index_0] -- 359
		allEntries[#allEntries + 1] = game -- 360
		local examples, tests = game.examples, game.tests -- 361
		for _index_1 = 1, #examples do -- 362
			local example = examples[_index_1] -- 362
			allEntries[#allEntries + 1] = example -- 363
		end -- 362
		for _index_1 = 1, #tests do -- 364
			local test = tests[_index_1] -- 364
			allEntries[#allEntries + 1] = test -- 365
		end -- 364
	end -- 359
end -- 344
updateEntries() -- 367
local getLaunchEntries -- 369
getLaunchEntries = function() -- 369
	updateEntries() -- 370
	local toInfo -- 371
	toInfo = function(entry, kind) -- 371
		local file = entry.fileName -- 372
		local asProj = not entry.builtin -- 373
		return { -- 375
			name = getEntryTitle(entry), -- 375
			file = file, -- 376
			kind = kind, -- 377
			asProj = asProj -- 378
		} -- 374
	end -- 371
	local games -- 380
	do -- 380
		local _accum_0 = { } -- 380
		local _len_0 = 1 -- 380
		for _index_0 = 1, #gamesInDev do -- 380
			local game = gamesInDev[_index_0] -- 380
			_accum_0[_len_0] = toInfo(game, "game") -- 380
			_len_0 = _len_0 + 1 -- 380
		end -- 380
		games = _accum_0 -- 380
	end -- 380
	local tools -- 381
	do -- 381
		local _accum_0 = { } -- 381
		local _len_0 = 1 -- 381
		for _index_0 = 1, #doraTools do -- 381
			local tool = doraTools[_index_0] -- 381
			_accum_0[_len_0] = toInfo(tool, "tool") -- 381
			_len_0 = _len_0 + 1 -- 381
		end -- 381
		tools = _accum_0 -- 381
	end -- 381
	return { -- 382
		games = games, -- 382
		tools = tools -- 382
	} -- 382
end -- 369
_module_0["getLaunchEntries"] = getLaunchEntries -- 369
local doCompile -- 384
doCompile = function(minify) -- 384
	if building then -- 385
		return -- 385
	end -- 385
	building = true -- 386
	local startTime = App.runningTime -- 387
	local luaFiles = { } -- 388
	local yueFiles = { } -- 389
	local xmlFiles = { } -- 390
	local tlFiles = { } -- 391
	local writablePath = Content.writablePath -- 392
	local buildPaths = { -- 394
		{ -- 395
			Content.assetPath, -- 395
			Path(writablePath, ".build"), -- 396
			"" -- 397
		} -- 394
	} -- 393
	for _index_0 = 1, #gamesInDev do -- 400
		local _des_0 = gamesInDev[_index_0] -- 400
		local fileName = _des_0.fileName -- 400
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 401
		buildPaths[#buildPaths + 1] = { -- 403
			Path(writablePath, gamePath), -- 403
			Path(writablePath, ".build", gamePath), -- 404
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 405
			gamePath -- 406
		} -- 402
	end -- 400
	for _index_0 = 1, #buildPaths do -- 407
		local _des_0 = buildPaths[_index_0] -- 407
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 407
		if not Content:exist(inputPath) then -- 408
			goto _continue_0 -- 408
		end -- 408
		local _list_0 = getAllFiles(inputPath, { -- 410
			"lua" -- 410
		}) -- 410
		for _index_1 = 1, #_list_0 do -- 410
			local file = _list_0[_index_1] -- 410
			luaFiles[#luaFiles + 1] = { -- 412
				file, -- 412
				Path(inputPath, file), -- 413
				Path(outputPath, file), -- 414
				gamePath -- 415
			} -- 411
		end -- 410
		local _list_1 = getAllFiles(inputPath, { -- 417
			yueext -- 417
		}) -- 417
		for _index_1 = 1, #_list_1 do -- 417
			local file = _list_1[_index_1] -- 417
			yueFiles[#yueFiles + 1] = { -- 419
				file, -- 419
				Path(inputPath, file), -- 420
				Path(outputPath, Path:replaceExt(file, "lua")), -- 421
				searchPath, -- 422
				gamePath -- 423
			} -- 418
		end -- 417
		local _list_2 = getAllFiles(inputPath, { -- 425
			"xml" -- 425
		}) -- 425
		for _index_1 = 1, #_list_2 do -- 425
			local file = _list_2[_index_1] -- 425
			xmlFiles[#xmlFiles + 1] = { -- 427
				file, -- 427
				Path(inputPath, file), -- 428
				Path(outputPath, Path:replaceExt(file, "lua")), -- 429
				gamePath -- 430
			} -- 426
		end -- 425
		local _list_3 = getAllFiles(inputPath, { -- 432
			"tl" -- 432
		}) -- 432
		for _index_1 = 1, #_list_3 do -- 432
			local file = _list_3[_index_1] -- 432
			if not file:match(".*%.d%.tl$") then -- 433
				tlFiles[#tlFiles + 1] = { -- 435
					file, -- 435
					Path(inputPath, file), -- 436
					Path(outputPath, Path:replaceExt(file, "lua")), -- 437
					searchPath, -- 438
					gamePath -- 439
				} -- 434
			end -- 433
		end -- 432
		::_continue_0:: -- 408
	end -- 407
	local paths -- 441
	do -- 441
		local _tbl_0 = { } -- 441
		local _list_0 = { -- 442
			luaFiles, -- 442
			yueFiles, -- 442
			xmlFiles, -- 442
			tlFiles -- 442
		} -- 442
		for _index_0 = 1, #_list_0 do -- 442
			local files = _list_0[_index_0] -- 442
			for _index_1 = 1, #files do -- 443
				local file = files[_index_1] -- 443
				_tbl_0[Path:getPath(file[3])] = true -- 441
			end -- 441
		end -- 441
		paths = _tbl_0 -- 441
	end -- 441
	for path in pairs(paths) do -- 445
		Content:mkdir(path) -- 445
	end -- 445
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 447
	local fileCount = 0 -- 448
	local errors = { } -- 449
	for _index_0 = 1, #yueFiles do -- 450
		local _des_0 = yueFiles[_index_0] -- 450
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 450
		local filename -- 451
		if gamePath then -- 451
			filename = Path(gamePath, file) -- 451
		else -- 451
			filename = file -- 451
		end -- 451
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 452
			if not codes then -- 453
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 454
				return -- 455
			end -- 453
			local success, result = LintYueGlobals(codes, globals) -- 456
			local yueCodes -- 457
			if not success then -- 458
				yueCodes = Content:load(input) -- 459
				if yueCodes then -- 459
					local CheckTIC80Code -- 460
					do -- 460
						local _obj_0 = require("Utils") -- 460
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 460
					end -- 460
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 461
					if isTIC80 then -- 462
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 463
					end -- 462
				end -- 459
			end -- 458
			if success then -- 464
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 465
			else -- 467
				if yueCodes then -- 467
					local globalErrors = { } -- 468
					for _index_1 = 1, #result do -- 469
						local _des_1 = result[_index_1] -- 469
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 469
						local countLine = 1 -- 470
						local code = "" -- 471
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 472
							if countLine == line then -- 473
								code = lineCode -- 474
								break -- 475
							end -- 473
							countLine = countLine + 1 -- 476
						end -- 472
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 477
					end -- 469
					if #globalErrors > 0 then -- 478
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 478
					end -- 478
				else -- 480
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 480
				end -- 467
				if #errors == 0 then -- 481
					return codes -- 481
				end -- 481
			end -- 464
		end, function(success) -- 452
			if success then -- 482
				print("Yue compiled: " .. tostring(filename)) -- 482
			end -- 482
			fileCount = fileCount + 1 -- 483
		end) -- 452
	end -- 450
	thread(function() -- 485
		for _index_0 = 1, #xmlFiles do -- 486
			local _des_0 = xmlFiles[_index_0] -- 486
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 486
			local filename -- 487
			if gamePath then -- 487
				filename = Path(gamePath, file) -- 487
			else -- 487
				filename = file -- 487
			end -- 487
			local sourceCodes = Content:loadAsync(input) -- 488
			local codes, err = xml.tolua(sourceCodes) -- 489
			if not codes then -- 490
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 491
			else -- 493
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 493
				print("Xml compiled: " .. tostring(filename)) -- 494
			end -- 490
			fileCount = fileCount + 1 -- 495
		end -- 486
	end) -- 485
	thread(function() -- 497
		for _index_0 = 1, #tlFiles do -- 498
			local _des_0 = tlFiles[_index_0] -- 498
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 498
			local filename -- 499
			if gamePath then -- 499
				filename = Path(gamePath, file) -- 499
			else -- 499
				filename = file -- 499
			end -- 499
			local sourceCodes = Content:loadAsync(input) -- 500
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 501
			if not codes then -- 502
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 503
			else -- 505
				Content:saveAsync(output, codes) -- 505
				print("Teal compiled: " .. tostring(filename)) -- 506
			end -- 502
			fileCount = fileCount + 1 -- 507
		end -- 498
	end) -- 497
	return thread(function() -- 509
		wait(function() -- 510
			return fileCount == totalFiles -- 510
		end) -- 510
		if minify then -- 511
			local _list_0 = { -- 512
				yueFiles, -- 512
				xmlFiles, -- 512
				tlFiles -- 512
			} -- 512
			for _index_0 = 1, #_list_0 do -- 512
				local files = _list_0[_index_0] -- 512
				for _index_1 = 1, #files do -- 512
					local file = files[_index_1] -- 512
					local output = Path:replaceExt(file[3], "lua") -- 513
					luaFiles[#luaFiles + 1] = { -- 515
						Path:replaceExt(file[1], "lua"), -- 515
						output, -- 516
						output -- 517
					} -- 514
				end -- 512
			end -- 512
			local FormatMini -- 519
			do -- 519
				local _obj_0 = require("luaminify") -- 519
				FormatMini = _obj_0.FormatMini -- 519
			end -- 519
			for _index_0 = 1, #luaFiles do -- 520
				local _des_0 = luaFiles[_index_0] -- 520
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 520
				if Content:exist(input) then -- 521
					local sourceCodes = Content:loadAsync(input) -- 522
					local res, err = FormatMini(sourceCodes) -- 523
					if res then -- 524
						Content:saveAsync(output, res) -- 525
						print("Minify: " .. tostring(file)) -- 526
					else -- 528
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 528
					end -- 524
				else -- 530
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 530
				end -- 521
			end -- 520
			package.loaded["luaminify.FormatMini"] = nil -- 531
			package.loaded["luaminify.ParseLua"] = nil -- 532
			package.loaded["luaminify.Scope"] = nil -- 533
			package.loaded["luaminify.Util"] = nil -- 534
		end -- 511
		local errorMessage = table.concat(errors, "\n") -- 535
		if errorMessage ~= "" then -- 536
			print(errorMessage) -- 536
		end -- 536
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 537
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 538
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 539
		Content:clearPathCache() -- 540
		teal.clear() -- 541
		yue.clear() -- 542
		building = false -- 543
	end) -- 509
end -- 384
local doClean -- 545
doClean = function() -- 545
	if building then -- 546
		return -- 546
	end -- 546
	local writablePath = Content.writablePath -- 547
	local targetDir = Path(writablePath, ".build") -- 548
	Content:clearPathCache() -- 549
	if Content:remove(targetDir) then -- 550
		return print("Cleaned: " .. tostring(targetDir)) -- 551
	end -- 550
end -- 545
local screenScale = 2.0 -- 553
local scaleContent = false -- 554
local isInEntry = true -- 555
local currentEntry = nil -- 556
local footerWindow = nil -- 558
local entryWindow = nil -- 559
local testingThread = nil -- 560
local setupEventHandlers = nil -- 562
local allClear -- 564
allClear = function() -- 564
	for _index_0 = 1, #Routine do -- 565
		local routine = Routine[_index_0] -- 565
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 567
			goto _continue_0 -- 568
		else -- 570
			Routine:remove(routine) -- 570
		end -- 566
		::_continue_0:: -- 566
	end -- 565
	for _index_0 = 1, #moduleCache do -- 571
		local module = moduleCache[_index_0] -- 571
		package.loaded[module] = nil -- 572
	end -- 571
	moduleCache = { } -- 573
	Director:cleanup() -- 574
	Entity:clear() -- 575
	Platformer.Data:clear() -- 576
	Platformer.UnitAction:clear() -- 577
	Audio:stopAll(0.2) -- 578
	Struct:clear() -- 579
	View.postEffect = nil -- 580
	View.scale = scaleContent and screenScale or 1 -- 581
	Director.clearColor = Color(0xff1a1a1a) -- 582
	teal.clear() -- 583
	yue.clear() -- 584
	for _, item in pairs(ubox()) do -- 585
		local node = tolua.cast(item, "Node") -- 586
		if node then -- 586
			node:cleanup() -- 586
		end -- 586
	end -- 585
	collectgarbage() -- 587
	collectgarbage() -- 588
	Wasm:clear() -- 589
	thread(function() -- 590
		sleep() -- 591
		return Cache:removeUnused() -- 592
	end) -- 590
	setupEventHandlers() -- 593
	Content.searchPaths = searchPaths -- 594
	App.idled = true -- 595
end -- 564
_module_0["allClear"] = allClear -- 564
local clearTempFiles -- 597
clearTempFiles = function() -- 597
	local writablePath = Content.writablePath -- 598
	Content:remove(Path(writablePath, ".upload")) -- 599
	return Content:remove(Path(writablePath, ".download")) -- 600
end -- 597
local waitForWebStart = true -- 602
thread(function() -- 603
	sleep(2) -- 604
	waitForWebStart = false -- 605
end) -- 603
local reloadDevEntry -- 607
reloadDevEntry = function() -- 607
	return thread(function() -- 607
		waitForWebStart = true -- 608
		doClean() -- 609
		allClear() -- 610
		_G.require = oldRequire -- 611
		Dora.require = oldRequire -- 612
		package.loaded["Script.Dev.Entry"] = nil -- 613
		return Director.systemScheduler:schedule(function() -- 614
			Routine:clear() -- 615
			oldRequire("Script.Dev.Entry") -- 616
			return true -- 617
		end) -- 614
	end) -- 607
end -- 607
local setWorkspace -- 619
setWorkspace = function(path) -- 619
	clearTempFiles() -- 620
	Content.writablePath = path -- 621
	config.writablePath = Content.writablePath -- 622
	return thread(function() -- 623
		sleep() -- 624
		return reloadDevEntry() -- 625
	end) -- 623
end -- 619
_module_0["setWorkspace"] = setWorkspace -- 619
local quit = false -- 627
local activeSearchId = 0 -- 629
local handleSearchFiles -- 631
handleSearchFiles = function(payload) -- 631
	if not payload then -- 632
		return -- 632
	end -- 632
	local id = payload.id -- 633
	if id == nil then -- 634
		return -- 634
	end -- 634
	activeSearchId = id -- 635
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 636
	if path == nil then -- 637
		path = "" -- 637
	end -- 637
	if exts == nil then -- 638
		exts = { } -- 638
	end -- 638
	if globs == nil then -- 639
		globs = { } -- 639
	end -- 639
	if extensionLevels == nil then -- 640
		extensionLevels = { } -- 640
	end -- 640
	if pattern == nil then -- 641
		pattern = "" -- 641
	end -- 641
	if pattern == "" then -- 643
		return -- 643
	end -- 643
	local useRegex = payload.useRegex == true -- 644
	local caseSensitive = payload.caseSensitive == true -- 645
	local includeContent = payload.includeContent ~= false -- 646
	local contentWindow = payload.contentWindow or 0 -- 647
	return Director.systemScheduler:schedule(once(function() -- 648
		local stopped = false -- 649
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 650
			if activeSearchId ~= id then -- 651
				stopped = true -- 652
				return true -- 653
			end -- 651
			emit("AppWS", "Send", json.encode({ -- 655
				name = "SearchFilesResult", -- 655
				id = id, -- 655
				result = result -- 655
			})) -- 654
			return false -- 657
		end) -- 650
		return emit("AppWS", "Send", json.encode({ -- 659
			name = "SearchFilesDone", -- 659
			id = id, -- 659
			stopped = stopped -- 659
		})) -- 658
	end)) -- 648
end -- 631
local stop -- 662
stop = function() -- 662
	if isInEntry then -- 663
		return false -- 663
	end -- 663
	allClear() -- 664
	isInEntry = true -- 665
	currentEntry = nil -- 666
	return true -- 667
end -- 662
_module_0["stop"] = stop -- 662
local _anon_func_1 = function(_with_0) -- 686
	local _val_0 = App.platform -- 686
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 686
end -- 686
setupEventHandlers = function() -- 669
	local _with_0 = Director.postNode -- 670
	_with_0:onAppEvent(function(eventType) -- 671
		if "Quit" == eventType then -- 672
			quit = true -- 673
			allClear() -- 674
			return clearTempFiles() -- 675
		elseif "Shutdown" == eventType then -- 676
			return stop() -- 677
		end -- 671
	end) -- 671
	_with_0:onAppChange(function(settingName) -- 678
		if "Theme" == settingName then -- 679
			config.themeColor = App.themeColor:toARGB() -- 680
		elseif "Locale" == settingName then -- 681
			config.locale = App.locale -- 682
			updateLocale() -- 683
			return teal.clear(true) -- 684
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 685
			if _anon_func_1(_with_0) then -- 686
				if "FullScreen" == settingName then -- 688
					config.fullScreen = App.fullScreen -- 688
				elseif "Position" == settingName then -- 689
					local _obj_0 = App.winPosition -- 689
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 689
				elseif "Size" == settingName then -- 690
					local width, height -- 691
					do -- 691
						local _obj_0 = App.winSize -- 691
						width, height = _obj_0.width, _obj_0.height -- 691
					end -- 691
					config.winWidth = width -- 692
					config.winHeight = height -- 693
				end -- 687
			end -- 686
		end -- 678
	end) -- 678
	_with_0:onAppWS(function(event) -- 694
		if event.type == "Close" then -- 695
			if HttpServer.wsConnectionCount == 0 then -- 696
				updateEntries() -- 697
			end -- 696
			return -- 698
		end -- 695
		if not (event.type == "Receive") then -- 699
			return -- 699
		end -- 699
		local data = json.decode(event.msg) -- 700
		if not data then -- 701
			return -- 701
		end -- 701
		local _exp_0 = data.name -- 702
		if "SearchFiles" == _exp_0 then -- 703
			return handleSearchFiles(data) -- 704
		elseif "SearchFilesStop" == _exp_0 then -- 705
			if data.id == nil or data.id == activeSearchId then -- 706
				activeSearchId = 0 -- 707
			end -- 706
		end -- 702
	end) -- 694
	_with_0:slot("UpdateEntries", function() -- 708
		return updateEntries() -- 708
	end) -- 708
	return _with_0 -- 670
end -- 669
setupEventHandlers() -- 710
clearTempFiles() -- 711
local downloadFile -- 713
downloadFile = function(url, target) -- 713
	return Director.systemScheduler:schedule(once(function() -- 713
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 714
			if quit then -- 715
				return true -- 715
			end -- 715
			emit("AppWS", "Send", json.encode({ -- 717
				name = "Download", -- 717
				url = url, -- 717
				status = "downloading", -- 717
				progress = current / total -- 718
			})) -- 716
			return false -- 714
		end) -- 714
		return emit("AppWS", "Send", json.encode(success and { -- 721
			name = "Download", -- 721
			url = url, -- 721
			status = "completed", -- 721
			progress = 1.0 -- 722
		} or { -- 724
			name = "Download", -- 724
			url = url, -- 724
			status = "failed", -- 724
			progress = 0.0 -- 725
		})) -- 720
	end)) -- 713
end -- 713
_module_0["downloadFile"] = downloadFile -- 713
local _anon_func_2 = function(file, require, workDir) -- 736
	if workDir == nil then -- 736
		workDir = Path:getPath(file) -- 736
	end -- 736
	Content:insertSearchPath(1, workDir) -- 737
	local scriptPath = Path(workDir, "Script") -- 738
	if Content:exist(scriptPath) then -- 739
		Content:insertSearchPath(1, scriptPath) -- 740
	end -- 739
	local result = require(file) -- 741
	if "function" == type(result) then -- 742
		result() -- 742
	end -- 742
	return nil -- 743
end -- 736
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 772
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 772
	label.alignment = "Left" -- 773
	label.textWidth = width - fontSize -- 774
	label.text = err -- 775
	return label -- 772
end -- 772
local enterEntryAsync -- 728
enterEntryAsync = function(entry) -- 728
	isInEntry = false -- 729
	App.idled = false -- 730
	emit(Profiler.EventName, "ClearLoader") -- 731
	currentEntry = entry -- 732
	local file, workDir = entry.fileName, entry.workDir -- 733
	sleep() -- 734
	return xpcall(_anon_func_2, function(msg) -- 743
		local err = debug.traceback(msg) -- 745
		Log("Error", err) -- 746
		allClear() -- 747
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 748
		local viewWidth, viewHeight -- 749
		do -- 749
			local _obj_0 = View.size -- 749
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 749
		end -- 749
		local width, height = viewWidth - 20, viewHeight - 20 -- 750
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 751
		Director.ui:addChild((function() -- 752
			local root = AlignNode() -- 752
			do -- 753
				local _obj_0 = App.bufferSize -- 753
				width, height = _obj_0.width, _obj_0.height -- 753
			end -- 753
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 754
			root:onAppChange(function(settingName) -- 755
				if settingName == "Size" then -- 755
					do -- 756
						local _obj_0 = App.bufferSize -- 756
						width, height = _obj_0.width, _obj_0.height -- 756
					end -- 756
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 757
				end -- 755
			end) -- 755
			root:addChild((function() -- 758
				local _with_0 = ScrollArea({ -- 759
					width = width, -- 759
					height = height, -- 760
					paddingX = 0, -- 761
					paddingY = 50, -- 762
					viewWidth = height, -- 763
					viewHeight = height -- 764
				}) -- 758
				root:onAlignLayout(function(w, h) -- 766
					_with_0.position = Vec2(w / 2, h / 2) -- 767
					w = w - 20 -- 768
					h = h - 20 -- 769
					_with_0.view.children.first.textWidth = w - fontSize -- 770
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 771
				end) -- 766
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 772
				return _with_0 -- 758
			end)()) -- 758
			return root -- 752
		end)()) -- 752
		return err -- 776
	end, file, require, workDir) -- 735
end -- 728
_module_0["enterEntryAsync"] = enterEntryAsync -- 728
local enterDemoEntry -- 778
enterDemoEntry = function(entry) -- 778
	return thread(function() -- 778
		return enterEntryAsync(entry) -- 778
	end) -- 778
end -- 778
local reloadCurrentEntry -- 780
reloadCurrentEntry = function() -- 780
	if currentEntry then -- 781
		allClear() -- 782
		return enterDemoEntry(currentEntry) -- 783
	end -- 781
end -- 780
Director.clearColor = Color(0xff1a1a1a) -- 785
local descColor = Color(0xffa1a1a1) -- 786
local extraOperations -- 788
do -- 788
	local isOSSLicenseExist = Content:exist("LICENSES") -- 789
	local ossLicenses = nil -- 790
	local ossLicenseOpen = false -- 791
	local failedSetFolder = false -- 792
	local statusFlags = { -- 793
		"NoResize", -- 793
		"NoMove", -- 793
		"NoCollapse", -- 793
		"AlwaysAutoResize", -- 793
		"NoSavedSettings" -- 793
	} -- 793
	extraOperations = function() -- 800
		local zh = useChinese -- 801
		if isDesktop then -- 802
			local alwaysOnTop = config.alwaysOnTop -- 803
			local changed -- 804
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 804
			if changed then -- 804
				App.alwaysOnTop = alwaysOnTop -- 805
				config.alwaysOnTop = alwaysOnTop -- 806
			end -- 804
		end -- 802
		local showPreview, authRequired = config.showPreview, config.authRequired -- 807
		do -- 808
			local changed -- 808
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 808
			if changed then -- 808
				config.showPreview = showPreview -- 809
				updateEntries() -- 810
				if not showPreview then -- 811
					thread(function() -- 812
						collectgarbage() -- 813
						return Cache:removeUnused("Texture") -- 814
					end) -- 812
				end -- 811
			end -- 808
		end -- 808
		do -- 815
			local changed -- 815
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 815
			if changed then -- 815
				config.authRequired = authRequired -- 816
				HttpServer.authRequired = authRequired -- 817
			end -- 815
		end -- 815
		SameLine() -- 818
		TextColored(descColor, "(?)") -- 819
		if IsItemHovered() then -- 820
			BeginTooltip(function() -- 821
				return PushTextWrapPos(280, function() -- 822
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 823
				end) -- 822
			end) -- 821
		end -- 820
		do -- 824
			local themeColor = App.themeColor -- 825
			local writablePath = config.writablePath -- 826
			SeparatorText(zh and "工作目录" or "Workspace") -- 827
			PushTextWrapPos(400, function() -- 828
				return TextColored(themeColor, writablePath) -- 829
			end) -- 828
			if not isDesktop then -- 830
				goto skipSetting -- 830
			end -- 830
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 831
			if Button(zh and "改变目录" or "Set Folder") then -- 832
				App:openFileDialog(true, function(path) -- 833
					if path == "" then -- 834
						return -- 834
					end -- 834
					local relPath = Path:getRelative(Content.assetPath, path) -- 835
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 836
						return setWorkspace(path) -- 837
					else -- 839
						failedSetFolder = true -- 839
					end -- 836
				end) -- 833
			end -- 832
			if failedSetFolder then -- 840
				failedSetFolder = false -- 841
				OpenPopup(popupName) -- 842
			end -- 840
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 843
			BeginPopupModal(popupName, statusFlags, function() -- 844
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 845
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 846
					return CloseCurrentPopup() -- 847
				end -- 846
			end) -- 844
			SameLine() -- 848
			if Button(zh and "使用默认" or "Use Default") then -- 849
				setWorkspace(Content.appPath) -- 850
			end -- 849
			Separator() -- 851
			::skipSetting:: -- 852
		end -- 824
		if isOSSLicenseExist then -- 853
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 854
				if not ossLicenses then -- 855
					ossLicenses = { } -- 856
					local licenseText = Content:load("LICENSES") -- 857
					ossLicenseOpen = (licenseText ~= nil) -- 858
					if ossLicenseOpen then -- 858
						licenseText = licenseText:gsub("\r\n", "\n") -- 859
						for license in GSplit(licenseText, "\n--------\n", true) do -- 860
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 861
							if name then -- 861
								ossLicenses[#ossLicenses + 1] = { -- 862
									name, -- 862
									text -- 862
								} -- 862
							end -- 861
						end -- 860
					end -- 858
				else -- 864
					ossLicenseOpen = true -- 864
				end -- 855
			end -- 854
			if ossLicenseOpen then -- 865
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 866
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 867
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 868
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 869
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 872
						"NoSavedSettings" -- 872
					}, function() -- 873
						for _index_0 = 1, #ossLicenses do -- 873
							local _des_0 = ossLicenses[_index_0] -- 873
							local firstLine, text = _des_0[1], _des_0[2] -- 873
							local name, license = firstLine:match("(.+): (.+)") -- 874
							TextColored(themeColor, name) -- 875
							SameLine() -- 876
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 877
								return TextWrapped(text) -- 877
							end) -- 877
						end -- 873
					end) -- 869
				end) -- 869
			end -- 865
		end -- 853
		if not App.debugging then -- 879
			return -- 879
		end -- 879
		return TreeNode(zh and "开发操作" or "Development", function() -- 880
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 881
				OpenPopup("build") -- 881
			end -- 881
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 882
				return BeginPopup("build", function() -- 882
					if Selectable(zh and "编译" or "Compile") then -- 883
						doCompile(false) -- 883
					end -- 883
					Separator() -- 884
					if Selectable(zh and "压缩" or "Minify") then -- 885
						doCompile(true) -- 885
					end -- 885
					Separator() -- 886
					if Selectable(zh and "清理" or "Clean") then -- 887
						return doClean() -- 887
					end -- 887
				end) -- 882
			end) -- 882
			if isInEntry then -- 888
				if waitForWebStart then -- 889
					BeginDisabled(function() -- 890
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 890
					end) -- 890
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 891
					reloadDevEntry() -- 892
				end -- 889
			end -- 888
			do -- 893
				local changed -- 893
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 893
				if changed then -- 893
					View.scale = scaleContent and screenScale or 1 -- 894
				end -- 893
			end -- 893
			do -- 895
				local changed -- 895
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 895
				if changed then -- 895
					config.engineDev = engineDev -- 896
				end -- 895
			end -- 895
			if testingThread then -- 897
				return BeginDisabled(function() -- 898
					return Button(zh and "开始自动测试" or "Test automatically") -- 898
				end) -- 898
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 899
				testingThread = thread(function() -- 900
					local _ <close> = setmetatable({ }, { -- 901
						__close = function() -- 901
							allClear() -- 902
							testingThread = nil -- 903
							isInEntry = true -- 904
							currentEntry = nil -- 905
							return print("Testing done!") -- 906
						end -- 901
					}) -- 901
					for _, entry in ipairs(allEntries) do -- 907
						allClear() -- 908
						print("Start " .. tostring(entry.entryName)) -- 909
						enterDemoEntry(entry) -- 910
						sleep(2) -- 911
						print("Stop " .. tostring(entry.entryName)) -- 912
					end -- 907
				end) -- 900
			end -- 897
		end) -- 880
	end -- 800
end -- 788
local icon = Path("Script", "Dev", "icon_s.png") -- 914
local iconTex = nil -- 915
thread(function() -- 916
	if Cache:loadAsync(icon) then -- 916
		iconTex = Texture2D(icon) -- 916
	end -- 916
end) -- 916
local webStatus = nil -- 918
local urlClicked = nil -- 919
local authCode = string.format("%06d", math.random(0, 999999)) -- 921
local authCodeTTL = 30.0 -- 923
_module_0.getAuthCode = function() -- 924
	return authCode -- 924
end -- 924
_module_0.invalidateAuthCode = function() -- 925
	authCode = string.format("%06d", math.random(0, 999999)) -- 926
	authCodeTTL = 30.0 -- 927
end -- 925
local AuthSession -- 929
do -- 929
	local pending = nil -- 930
	local session = nil -- 931
	AuthSession = { -- 933
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 933
			pending = { -- 935
				sessionId = sessionId, -- 935
				confirmCode = confirmCode, -- 936
				expiresAt = expiresAt, -- 937
				ttl = ttl, -- 938
				approved = false -- 939
			} -- 934
		end, -- 933
		getPending = function() -- 941
			return pending -- 941
		end, -- 941
		approvePending = function(sessionId) -- 943
			if pending and pending.sessionId == sessionId then -- 944
				pending.approved = true -- 945
				return true -- 946
			end -- 944
			return false -- 947
		end, -- 943
		clearPending = function() -- 949
			pending = nil -- 949
		end, -- 949
		setSession = function(sessionId, sessionSecret) -- 951
			session = { -- 953
				sessionId = sessionId, -- 953
				sessionSecret = sessionSecret -- 954
			} -- 952
		end, -- 951
		getSession = function() -- 956
			return session -- 956
		end -- 956
	} -- 932
end -- 929
_module_0["AuthSession"] = AuthSession -- 929
local transparant = Color(0x0) -- 959
local windowFlags = { -- 960
	"NoTitleBar", -- 960
	"NoResize", -- 960
	"NoMove", -- 960
	"NoCollapse", -- 960
	"NoSavedSettings", -- 960
	"NoFocusOnAppearing", -- 960
	"NoBringToFrontOnFocus" -- 960
} -- 960
local statusFlags = { -- 969
	"NoTitleBar", -- 969
	"NoResize", -- 969
	"NoMove", -- 969
	"NoCollapse", -- 969
	"AlwaysAutoResize", -- 969
	"NoSavedSettings" -- 969
} -- 969
local displayWindowFlags = { -- 977
	"NoDecoration", -- 977
	"NoSavedSettings", -- 977
	"NoNav", -- 977
	"NoMove", -- 977
	"NoScrollWithMouse", -- 977
	"AlwaysAutoResize", -- 977
	"NoFocusOnAppearing" -- 977
} -- 977
local initFooter = true -- 986
local _anon_func_4 = function(allEntries, currentIndex) -- 1027
	if currentIndex > 1 then -- 1027
		return allEntries[currentIndex - 1] -- 1028
	else -- 1030
		return allEntries[#allEntries] -- 1030
	end -- 1027
end -- 1027
local _anon_func_5 = function(allEntries, currentIndex) -- 1034
	if currentIndex < #allEntries then -- 1034
		return allEntries[currentIndex + 1] -- 1035
	else -- 1037
		return allEntries[1] -- 1037
	end -- 1034
end -- 1034
footerWindow = threadLoop(function() -- 987
	local zh = useChinese -- 988
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 989
	if authCodeTTL <= 0 then -- 990
		authCodeTTL = 30.0 -- 991
		authCode = string.format("%06d", math.random(0, 999999)) -- 992
	end -- 990
	if HttpServer.wsConnectionCount > 0 then -- 993
		return -- 994
	end -- 993
	if Keyboard:isKeyDown("Escape") then -- 995
		allClear() -- 996
		App.devMode = false -- 997
		App:shutdown() -- 998
	end -- 995
	do -- 999
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1000
		if ctrl and Keyboard:isKeyDown("Q") then -- 1001
			stop() -- 1002
		end -- 1001
		if ctrl and Keyboard:isKeyDown("Z") then -- 1003
			reloadCurrentEntry() -- 1004
		end -- 1003
		if ctrl and Keyboard:isKeyDown(",") then -- 1005
			if showFooter then -- 1006
				showStats = not showStats -- 1006
			else -- 1006
				showStats = true -- 1006
			end -- 1006
			showFooter = true -- 1007
			config.showFooter = showFooter -- 1008
			config.showStats = showStats -- 1009
		end -- 1005
		if ctrl and Keyboard:isKeyDown(".") then -- 1010
			if showFooter then -- 1011
				showConsole = not showConsole -- 1011
			else -- 1011
				showConsole = true -- 1011
			end -- 1011
			showFooter = true -- 1012
			config.showFooter = showFooter -- 1013
			config.showConsole = showConsole -- 1014
		end -- 1010
		if ctrl and Keyboard:isKeyDown("/") then -- 1015
			showFooter = not showFooter -- 1016
			config.showFooter = showFooter -- 1017
		end -- 1015
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1018
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1019
		local currentIndex = nil -- 1020
		for i, entry in ipairs(allEntries) do -- 1021
			if currentEntry == entry then -- 1022
				currentIndex = i -- 1023
			end -- 1022
		end -- 1021
		if left then -- 1024
			allClear() -- 1025
			if currentIndex == nil then -- 1026
				currentIndex = #allEntries + 1 -- 1026
			end -- 1026
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 1027
		end -- 1024
		if right then -- 1031
			allClear() -- 1032
			if currentIndex == nil then -- 1033
				currentIndex = 0 -- 1033
			end -- 1033
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1034
		end -- 1031
	end -- 999
	if not showEntry then -- 1038
		return -- 1038
	end -- 1038
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1040
		reloadDevEntry() -- 1044
	end -- 1040
	if initFooter then -- 1045
		initFooter = false -- 1046
	end -- 1045
	local width, height -- 1048
	do -- 1048
		local _obj_0 = App.visualSize -- 1048
		width, height = _obj_0.width, _obj_0.height -- 1048
	end -- 1048
	if isInEntry or showFooter then -- 1049
		SetNextWindowSize(Vec2(width, 50)) -- 1050
		SetNextWindowPos(Vec2(0, height - 50)) -- 1051
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1052
			return PushStyleVar("WindowRounding", 0, function() -- 1053
				return Begin("Footer", windowFlags, function() -- 1054
					Separator() -- 1055
					if iconTex then -- 1056
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1057
							showStats = not showStats -- 1058
							config.showStats = showStats -- 1059
						end -- 1057
						SameLine() -- 1060
						if Button(">_", Vec2(30, 30)) then -- 1061
							showConsole = not showConsole -- 1062
							config.showConsole = showConsole -- 1063
						end -- 1061
					end -- 1056
					if isInEntry and config.updateNotification then -- 1064
						SameLine() -- 1065
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1066
							allClear() -- 1067
							config.updateNotification = false -- 1068
							enterDemoEntry({ -- 1070
								entryName = "SelfUpdater", -- 1070
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1071
							}) -- 1069
						end -- 1066
					end -- 1064
					if not isInEntry then -- 1072
						SameLine() -- 1073
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1074
						local currentIndex = nil -- 1075
						for i, entry in ipairs(allEntries) do -- 1076
							if currentEntry == entry then -- 1077
								currentIndex = i -- 1078
							end -- 1077
						end -- 1076
						if currentIndex then -- 1079
							if currentIndex > 1 then -- 1080
								SameLine() -- 1081
								if Button("<<", Vec2(30, 30)) then -- 1082
									allClear() -- 1083
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1084
								end -- 1082
							end -- 1080
							if currentIndex < #allEntries then -- 1085
								SameLine() -- 1086
								if Button(">>", Vec2(30, 30)) then -- 1087
									allClear() -- 1088
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1089
								end -- 1087
							end -- 1085
						end -- 1079
						SameLine() -- 1090
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1091
							reloadCurrentEntry() -- 1092
						end -- 1091
						if back then -- 1093
							allClear() -- 1094
							isInEntry = true -- 1095
							currentEntry = nil -- 1096
						end -- 1093
					end -- 1072
				end) -- 1054
			end) -- 1053
		end) -- 1052
	end -- 1049
	if isInEntry then -- 1098
		local showURL = true -- 1099
		local webIDEWidth -- 1100
		do -- 1100
			local base -- 1101
			if config.updateNotification then -- 1101
				base = 460 -- 1101
			else -- 1101
				base = 360 -- 1101
			end -- 1101
			local extra -- 1102
			if config.authRequired then -- 1102
				extra = 35 -- 1102
			else -- 1102
				extra = 0 -- 1102
			end -- 1102
			webIDEWidth = base + extra -- 1103
		end -- 1100
		if width < webIDEWidth then -- 1104
			showURL = false -- 1104
		end -- 1104
		SetNextWindowBgAlpha(0.0) -- 1105
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1106
		Begin("Web IDE", displayWindowFlags, function() -- 1107
			local pending = AuthSession.getPending() -- 1108
			local hovered = false -- 1109
			if not pending and showURL then -- 1110
				do -- 1111
					local url -- 1111
					if webStatus ~= nil then -- 1111
						url = webStatus.url -- 1111
					end -- 1111
					if url then -- 1111
						if isDesktop and not config.fullScreen then -- 1112
							if urlClicked then -- 1113
								BeginDisabled(function() -- 1114
									return Button(url) -- 1114
								end) -- 1114
							elseif Button(url) then -- 1115
								urlClicked = once(function() -- 1116
									return sleep(5) -- 1116
								end) -- 1116
								App:openURL("http://localhost:8866") -- 1117
							end -- 1113
						else -- 1119
							TextColored(descColor, url) -- 1119
						end -- 1112
					else -- 1121
						TextColored(descColor, zh and '不可用' or 'not available') -- 1121
					end -- 1111
				end -- 1111
				hovered = IsItemHovered() -- 1122
			else -- 1124
				TextColored(descColor, "(?)") -- 1124
				hovered = IsItemHovered() -- 1125
			end -- 1110
			SameLine() -- 1126
			local themeColor = App.themeColor -- 1127
			if pending then -- 1128
				if not pending.approved then -- 1129
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1130
					local ttl = pending.ttl or 1 -- 1131
					PushStyleColor("Text", themeColor, function() -- 1132
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1133
						hovered = hovered or IsItemHovered() -- 1134
					end) -- 1132
					SameLine() -- 1135
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1136
						AuthSession.approvePending(pending.sessionId) -- 1137
					end -- 1136
					if hovered then -- 1138
						return BeginTooltip(function() -- 1139
							return PushTextWrapPos(280, function() -- 1140
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1141
							end) -- 1140
						end) -- 1139
					end -- 1138
				end -- 1129
			else -- 1143
				if config.authRequired then -- 1143
					PushStyleColor("Text", themeColor, function() -- 1144
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1145
						hovered = hovered or IsItemHovered() -- 1146
					end) -- 1144
					if hovered then -- 1147
						return BeginTooltip(function() -- 1148
							return PushTextWrapPos(280, function() -- 1149
								local url -- 1150
								if webStatus ~= nil then -- 1150
									url = webStatus.url -- 1150
								end -- 1150
								if url then -- 1150
									local address -- 1151
									if showURL then -- 1151
										address = "Web IDE" -- 1151
									else -- 1151
										address = url -- 1151
									end -- 1151
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1152
								else -- 1154
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1154
								end -- 1150
							end) -- 1149
						end) -- 1148
					end -- 1147
				else -- 1156
					if hovered then -- 1156
						return BeginTooltip(function() -- 1157
							return PushTextWrapPos(280, function() -- 1158
								local url -- 1159
								if webStatus ~= nil then -- 1159
									url = webStatus.url -- 1159
								end -- 1159
								if url then -- 1159
									local address -- 1160
									if showURL then -- 1160
										address = "Web IDE" -- 1160
									else -- 1160
										address = url -- 1160
									end -- 1160
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1161
								else -- 1163
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1163
								end -- 1159
							end) -- 1158
						end) -- 1157
					end -- 1156
				end -- 1143
			end -- 1128
		end) -- 1107
	end -- 1098
	if not isInEntry then -- 1165
		SetNextWindowSize(Vec2(50, 50)) -- 1166
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1167
		PushStyleColor("WindowBg", transparant, function() -- 1168
			return Begin("Show", displayWindowFlags, function() -- 1168
				if width >= 370 then -- 1169
					local changed -- 1170
					changed, showFooter = Checkbox("##dev", showFooter) -- 1170
					if changed then -- 1170
						config.showFooter = showFooter -- 1171
					end -- 1170
				end -- 1169
			end) -- 1168
		end) -- 1168
	end -- 1165
	if isInEntry or showFooter then -- 1173
		if showStats then -- 1174
			PushStyleVar("WindowRounding", 0, function() -- 1175
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1176
				SetNextWindowSize(Vec2(0, height - 50)) -- 1177
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1178
				config.showStats = showStats -- 1179
			end) -- 1175
		end -- 1174
		if showConsole then -- 1180
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1181
			return PushStyleVar("WindowRounding", 6, function() -- 1182
				return ShowConsole() -- 1183
			end) -- 1182
		end -- 1180
	end -- 1173
end) -- 987
local MaxWidth <const> = 960 -- 1185
local toolOpen = false -- 1187
local filterText = nil -- 1188
local anyEntryMatched = false -- 1189
local match -- 1190
match = function(name) -- 1190
	local res = not filterText or name:lower():match(filterText) -- 1191
	if res then -- 1192
		anyEntryMatched = true -- 1192
	end -- 1192
	return res -- 1193
end -- 1190
local sep -- 1195
sep = function() -- 1195
	return SeparatorText("") -- 1195
end -- 1195
local thinSep -- 1196
thinSep = function() -- 1196
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1196
end -- 1196
entryWindow = threadLoop(function() -- 1198
	if App.fpsLimited ~= config.fpsLimited then -- 1199
		config.fpsLimited = App.fpsLimited -- 1200
	end -- 1199
	if App.targetFPS ~= config.targetFPS then -- 1201
		config.targetFPS = App.targetFPS -- 1202
	end -- 1201
	if View.vsync ~= config.vsync then -- 1203
		config.vsync = View.vsync -- 1204
	end -- 1203
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1205
		config.fixedFPS = Director.scheduler.fixedFPS -- 1206
	end -- 1205
	if Director.profilerSending ~= config.webProfiler then -- 1207
		config.webProfiler = Director.profilerSending -- 1208
	end -- 1207
	if urlClicked then -- 1209
		local _, result = coroutine.resume(urlClicked) -- 1210
		if result then -- 1211
			coroutine.close(urlClicked) -- 1212
			urlClicked = nil -- 1213
		end -- 1211
	end -- 1209
	if not showEntry then -- 1214
		return -- 1214
	end -- 1214
	if not isInEntry then -- 1215
		return -- 1215
	end -- 1215
	local zh = useChinese -- 1216
	local themeColor = App.themeColor -- 1217
	if HttpServer.wsConnectionCount > 0 then -- 1218
		local width, height -- 1219
		do -- 1219
			local _obj_0 = App.visualSize -- 1219
			width, height = _obj_0.width, _obj_0.height -- 1219
		end -- 1219
		SetNextWindowBgAlpha(0.5) -- 1220
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1221
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1222
			Separator() -- 1223
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1224
			if iconTex then -- 1225
				Image(icon, Vec2(24, 24)) -- 1226
				SameLine() -- 1227
			end -- 1225
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1228
			TextColored(descColor, slogon) -- 1229
			return Separator() -- 1230
		end) -- 1222
		return -- 1231
	end -- 1218
	local fullWidth, height -- 1233
	do -- 1233
		local _obj_0 = App.visualSize -- 1233
		fullWidth, height = _obj_0.width, _obj_0.height -- 1233
	end -- 1233
	local width = math.min(MaxWidth, fullWidth) -- 1234
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1235
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1236
	SetNextWindowPos(Vec2.zero) -- 1237
	SetNextWindowBgAlpha(0) -- 1238
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1239
	do -- 1240
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1241
			return Begin("Dora Dev", windowFlags, function() -- 1242
				Dummy(Vec2(fullWidth - 20, 0)) -- 1243
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1244
				if fullWidth >= 400 then -- 1245
					SameLine() -- 1246
					Dummy(Vec2(fullWidth - 400, 0)) -- 1247
					SameLine() -- 1248
					SetNextItemWidth(zh and -95 or -140) -- 1249
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1250
						"AutoSelectAll" -- 1250
					}) then -- 1250
						config.filter = filterBuf.text -- 1251
					end -- 1250
					SameLine() -- 1252
					if Button(zh and '下载' or 'Download') then -- 1253
						allClear() -- 1254
						enterDemoEntry({ -- 1256
							entryName = "ResourceDownloader", -- 1256
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1257
						}) -- 1255
					end -- 1253
				end -- 1245
				return Separator() -- 1258
			end) -- 1242
		end) -- 1241
	end -- 1240
	anyEntryMatched = false -- 1260
	SetNextWindowPos(Vec2(0, 50)) -- 1261
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1262
	do -- 1263
		return PushStyleColor("WindowBg", transparant, function() -- 1264
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1265
				return PushStyleVar("Alpha", 1, function() -- 1266
					return Begin("Content", windowFlags, function() -- 1267
						local DemoViewWidth <const> = 220 -- 1268
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1269
						if filterText then -- 1270
							filterText = filterText:lower() -- 1270
						end -- 1270
						if #gamesInDev > 0 then -- 1271
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1272
							Columns(columns, false) -- 1273
							local realViewWidth = GetColumnWidth() - 50 -- 1274
							for _index_0 = 1, #gamesInDev do -- 1275
								local game = gamesInDev[_index_0] -- 1275
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1276
								local displayName -- 1285
								if repo then -- 1285
									if zh then -- 1286
										displayName = repo.title.zh -- 1286
									else -- 1286
										displayName = repo.title.en -- 1286
									end -- 1286
								end -- 1285
								if displayName == nil then -- 1287
									displayName = gameName -- 1287
								end -- 1287
								if match(displayName) then -- 1288
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1289
									SameLine() -- 1290
									TextWrapped(displayName) -- 1291
									if columns > 1 then -- 1292
										if bannerFile then -- 1293
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1294
											local displayWidth <const> = realViewWidth -- 1295
											texHeight = displayWidth * texHeight / texWidth -- 1296
											texWidth = displayWidth -- 1297
											Dummy(Vec2.zero) -- 1298
											SameLine() -- 1299
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1300
										end -- 1293
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1301
											enterDemoEntry(game) -- 1302
										end -- 1301
									else -- 1304
										if bannerFile then -- 1304
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1305
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1306
											local sizing = 0.8 -- 1307
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1308
											texWidth = displayWidth * sizing -- 1309
											if texWidth > 500 then -- 1310
												sizing = 0.6 -- 1311
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1312
												texWidth = displayWidth * sizing -- 1313
											end -- 1310
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1314
											Dummy(Vec2(padding, 0)) -- 1315
											SameLine() -- 1316
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1317
										end -- 1304
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1318
											enterDemoEntry(game) -- 1319
										end -- 1318
									end -- 1292
									if #tests == 0 and #examples == 0 then -- 1320
										thinSep() -- 1321
									end -- 1320
									NextColumn() -- 1322
								end -- 1288
								local showSep = false -- 1323
								if #examples > 0 then -- 1324
									local showExample = false -- 1325
									for _index_1 = 1, #examples do -- 1326
										local _des_0 = examples[_index_1] -- 1326
										local entryName = _des_0.entryName -- 1326
										if match(entryName) then -- 1327
											showExample = true -- 1327
											break -- 1327
										end -- 1327
									end -- 1326
									if showExample then -- 1328
										showSep = true -- 1329
										Columns(1, false) -- 1330
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1331
										SameLine() -- 1332
										local opened -- 1333
										if (filterText ~= nil) then -- 1333
											opened = showExample -- 1333
										else -- 1333
											opened = false -- 1333
										end -- 1333
										if game.exampleOpen == nil then -- 1334
											game.exampleOpen = opened -- 1334
										end -- 1334
										SetNextItemOpen(game.exampleOpen) -- 1335
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1336
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1337
												Columns(maxColumns, false) -- 1338
												for _index_1 = 1, #examples do -- 1339
													local example = examples[_index_1] -- 1339
													local entryName = example.entryName -- 1340
													if not match(entryName) then -- 1341
														goto _continue_0 -- 1341
													end -- 1341
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1342
														if Button(entryName, Vec2(-1, 40)) then -- 1343
															enterDemoEntry(example) -- 1344
														end -- 1343
														return NextColumn() -- 1345
													end) -- 1342
													opened = true -- 1346
													::_continue_0:: -- 1340
												end -- 1339
											end) -- 1337
										end) -- 1336
										game.exampleOpen = opened -- 1347
									end -- 1328
								end -- 1324
								if #tests > 0 then -- 1348
									local showTest = false -- 1349
									for _index_1 = 1, #tests do -- 1350
										local _des_0 = tests[_index_1] -- 1350
										local entryName = _des_0.entryName -- 1350
										if match(entryName) then -- 1351
											showTest = true -- 1351
											break -- 1351
										end -- 1351
									end -- 1350
									if showTest then -- 1352
										showSep = true -- 1353
										Columns(1, false) -- 1354
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1355
										SameLine() -- 1356
										local opened -- 1357
										if (filterText ~= nil) then -- 1357
											opened = showTest -- 1357
										else -- 1357
											opened = false -- 1357
										end -- 1357
										if game.testOpen == nil then -- 1358
											game.testOpen = opened -- 1358
										end -- 1358
										SetNextItemOpen(game.testOpen) -- 1359
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1360
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1361
												Columns(maxColumns, false) -- 1362
												for _index_1 = 1, #tests do -- 1363
													local test = tests[_index_1] -- 1363
													local entryName = test.entryName -- 1364
													if not match(entryName) then -- 1365
														goto _continue_0 -- 1365
													end -- 1365
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1366
														if Button(entryName, Vec2(-1, 40)) then -- 1367
															enterDemoEntry(test) -- 1368
														end -- 1367
														return NextColumn() -- 1369
													end) -- 1366
													opened = true -- 1370
													::_continue_0:: -- 1364
												end -- 1363
											end) -- 1361
										end) -- 1360
										game.testOpen = opened -- 1371
									end -- 1352
								end -- 1348
								if showSep then -- 1372
									Columns(1, false) -- 1373
									thinSep() -- 1374
									Columns(columns, false) -- 1375
								end -- 1372
							end -- 1275
						end -- 1271
						if #doraTools > 0 then -- 1376
							local showTool = false -- 1377
							for _index_0 = 1, #doraTools do -- 1378
								local _des_0 = doraTools[_index_0] -- 1378
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1378
								local displayName -- 1379
								if repo then -- 1379
									if zh then -- 1380
										displayName = repo.title.zh -- 1380
									else -- 1380
										displayName = repo.title.en -- 1380
									end -- 1380
								end -- 1379
								if displayName == nil then -- 1381
									displayName = entryName -- 1381
								end -- 1381
								if match(displayName) then -- 1382
									showTool = true -- 1382
									break -- 1382
								end -- 1382
							end -- 1378
							if not showTool then -- 1383
								goto endEntry -- 1383
							end -- 1383
							Columns(1, false) -- 1384
							TextColored(themeColor, "Dora SSR:") -- 1385
							SameLine() -- 1386
							Text(zh and "开发支持" or "Development Support") -- 1387
							Separator() -- 1388
							if #doraTools > 0 then -- 1389
								local opened -- 1390
								if (filterText ~= nil) then -- 1390
									opened = showTool -- 1390
								else -- 1390
									opened = false -- 1390
								end -- 1390
								SetNextItemOpen(toolOpen) -- 1391
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1392
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1393
										Columns(maxColumns, false) -- 1394
										for _index_0 = 1, #doraTools do -- 1395
											local tool = doraTools[_index_0] -- 1395
											local entryName, repo = tool.entryName, tool.repo -- 1396
											local displayName -- 1397
											if repo then -- 1397
												if zh then -- 1398
													displayName = repo.title.zh -- 1398
												else -- 1398
													displayName = repo.title.en -- 1398
												end -- 1398
											end -- 1397
											if displayName == nil then -- 1399
												displayName = entryName -- 1399
											end -- 1399
											if not match(displayName) then -- 1400
												goto _continue_0 -- 1400
											end -- 1400
											if Button(displayName, Vec2(-1, 40)) then -- 1401
												enterDemoEntry(tool) -- 1402
											end -- 1401
											NextColumn() -- 1403
											::_continue_0:: -- 1396
										end -- 1395
										Columns(1, false) -- 1404
										opened = true -- 1405
									end) -- 1393
								end) -- 1392
								toolOpen = opened -- 1406
							end -- 1389
						end -- 1376
						::endEntry:: -- 1407
						if not anyEntryMatched then -- 1408
							SetNextWindowBgAlpha(0) -- 1409
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1410
							Begin("Entries Not Found", displayWindowFlags, function() -- 1411
								Separator() -- 1412
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1413
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1414
								return Separator() -- 1415
							end) -- 1411
						end -- 1408
						Columns(1, false) -- 1416
						Dummy(Vec2(100, 80)) -- 1417
						return ScrollWhenDraggingOnVoid() -- 1418
					end) -- 1267
				end) -- 1266
			end) -- 1265
		end) -- 1264
	end -- 1263
end) -- 1198
webStatus = require("Script.Dev.WebServer") -- 1420
return _module_0 -- 1
