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
local getCurrentEntryStatus -- 669
getCurrentEntryStatus = function() -- 669
	local entry = currentEntry -- 670
	if not (entry and not isInEntry) then -- 671
		return { -- 671
			success = true, -- 671
			running = false -- 671
		} -- 671
	end -- 671
	local status = { -- 673
		success = true, -- 673
		running = true, -- 674
		kind = entry.runKind or "file", -- 675
		entryName = entry.entryName, -- 676
		fileName = entry.fileName -- 677
	} -- 672
	if entry.workDir then -- 678
		status.workDir = entry.workDir -- 678
	end -- 678
	if entry.projectRoot then -- 679
		status.projectRoot = entry.projectRoot -- 679
	end -- 679
	return status -- 680
end -- 669
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 669
local _anon_func_1 = function(_with_0) -- 699
	local _val_0 = App.platform -- 699
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 699
end -- 699
setupEventHandlers = function() -- 682
	local _with_0 = Director.postNode -- 683
	_with_0:onAppEvent(function(eventType) -- 684
		if "Quit" == eventType then -- 685
			quit = true -- 686
			allClear() -- 687
			return clearTempFiles() -- 688
		elseif "Shutdown" == eventType then -- 689
			return stop() -- 690
		end -- 684
	end) -- 684
	_with_0:onAppChange(function(settingName) -- 691
		if "Theme" == settingName then -- 692
			config.themeColor = App.themeColor:toARGB() -- 693
		elseif "Locale" == settingName then -- 694
			config.locale = App.locale -- 695
			updateLocale() -- 696
			return teal.clear(true) -- 697
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 698
			if _anon_func_1(_with_0) then -- 699
				if "FullScreen" == settingName then -- 701
					config.fullScreen = App.fullScreen -- 701
				elseif "Position" == settingName then -- 702
					local _obj_0 = App.winPosition -- 702
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 702
				elseif "Size" == settingName then -- 703
					local width, height -- 704
					do -- 704
						local _obj_0 = App.winSize -- 704
						width, height = _obj_0.width, _obj_0.height -- 704
					end -- 704
					config.winWidth = width -- 705
					config.winHeight = height -- 706
				end -- 700
			end -- 699
		end -- 691
	end) -- 691
	_with_0:onAppWS(function(event) -- 707
		if event.type == "Close" then -- 708
			if HttpServer.wsConnectionCount == 0 then -- 709
				updateEntries() -- 710
			end -- 709
			return -- 711
		end -- 708
		if not (event.type == "Receive") then -- 712
			return -- 712
		end -- 712
		local data = json.decode(event.msg) -- 713
		if not data then -- 714
			return -- 714
		end -- 714
		local _exp_0 = data.name -- 715
		if "SearchFiles" == _exp_0 then -- 716
			return handleSearchFiles(data) -- 717
		elseif "SearchFilesStop" == _exp_0 then -- 718
			if data.id == nil or data.id == activeSearchId then -- 719
				activeSearchId = 0 -- 720
			end -- 719
		end -- 715
	end) -- 707
	_with_0:slot("UpdateEntries", function() -- 721
		return updateEntries() -- 721
	end) -- 721
	return _with_0 -- 683
end -- 682
setupEventHandlers() -- 723
clearTempFiles() -- 724
local downloadFile -- 726
downloadFile = function(url, target) -- 726
	return Director.systemScheduler:schedule(once(function() -- 726
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 727
			if quit then -- 728
				return true -- 728
			end -- 728
			emit("AppWS", "Send", json.encode({ -- 730
				name = "Download", -- 730
				url = url, -- 730
				status = "downloading", -- 730
				progress = current / total -- 731
			})) -- 729
			return false -- 727
		end) -- 727
		return emit("AppWS", "Send", json.encode(success and { -- 734
			name = "Download", -- 734
			url = url, -- 734
			status = "completed", -- 734
			progress = 1.0 -- 735
		} or { -- 737
			name = "Download", -- 737
			url = url, -- 737
			status = "failed", -- 737
			progress = 0.0 -- 738
		})) -- 733
	end)) -- 726
end -- 726
_module_0["downloadFile"] = downloadFile -- 726
local _anon_func_2 = function(file, require, workDir) -- 749
	if workDir == nil then -- 749
		workDir = Path:getPath(file) -- 749
	end -- 749
	Content:insertSearchPath(1, workDir) -- 750
	local scriptPath = Path(workDir, "Script") -- 751
	if Content:exist(scriptPath) then -- 752
		Content:insertSearchPath(1, scriptPath) -- 753
	end -- 752
	local result = require(file) -- 754
	if "function" == type(result) then -- 755
		result() -- 755
	end -- 755
	return nil -- 756
end -- 749
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 785
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 785
	label.alignment = "Left" -- 786
	label.textWidth = width - fontSize -- 787
	label.text = err -- 788
	return label -- 785
end -- 785
local enterEntryAsync -- 741
enterEntryAsync = function(entry) -- 741
	isInEntry = false -- 742
	App.idled = false -- 743
	emit(Profiler.EventName, "ClearLoader") -- 744
	currentEntry = entry -- 745
	local file, workDir = entry.fileName, entry.workDir -- 746
	sleep() -- 747
	return xpcall(_anon_func_2, function(msg) -- 756
		local err = debug.traceback(msg) -- 758
		Log("Error", err) -- 759
		allClear() -- 760
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 761
		local viewWidth, viewHeight -- 762
		do -- 762
			local _obj_0 = View.size -- 762
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 762
		end -- 762
		local width, height = viewWidth - 20, viewHeight - 20 -- 763
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 764
		Director.ui:addChild((function() -- 765
			local root = AlignNode() -- 765
			do -- 766
				local _obj_0 = App.bufferSize -- 766
				width, height = _obj_0.width, _obj_0.height -- 766
			end -- 766
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 767
			root:onAppChange(function(settingName) -- 768
				if settingName == "Size" then -- 768
					do -- 769
						local _obj_0 = App.bufferSize -- 769
						width, height = _obj_0.width, _obj_0.height -- 769
					end -- 769
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 770
				end -- 768
			end) -- 768
			root:addChild((function() -- 771
				local _with_0 = ScrollArea({ -- 772
					width = width, -- 772
					height = height, -- 773
					paddingX = 0, -- 774
					paddingY = 50, -- 775
					viewWidth = height, -- 776
					viewHeight = height -- 777
				}) -- 771
				root:onAlignLayout(function(w, h) -- 779
					_with_0.position = Vec2(w / 2, h / 2) -- 780
					w = w - 20 -- 781
					h = h - 20 -- 782
					_with_0.view.children.first.textWidth = w - fontSize -- 783
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 784
				end) -- 779
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 785
				return _with_0 -- 771
			end)()) -- 771
			return root -- 765
		end)()) -- 765
		return err -- 789
	end, file, require, workDir) -- 748
end -- 741
_module_0["enterEntryAsync"] = enterEntryAsync -- 741
local enterDemoEntry -- 791
enterDemoEntry = function(entry) -- 791
	return thread(function() -- 791
		return enterEntryAsync(entry) -- 791
	end) -- 791
end -- 791
local reloadCurrentEntry -- 793
reloadCurrentEntry = function() -- 793
	if currentEntry then -- 794
		allClear() -- 795
		return enterDemoEntry(currentEntry) -- 796
	end -- 794
end -- 793
Director.clearColor = Color(0xff1a1a1a) -- 798
local descColor = Color(0xffa1a1a1) -- 799
local extraOperations -- 801
do -- 801
	local isOSSLicenseExist = Content:exist("LICENSES") -- 802
	local ossLicenses = nil -- 803
	local ossLicenseOpen = false -- 804
	local failedSetFolder = false -- 805
	local statusFlags = { -- 806
		"NoResize", -- 806
		"NoMove", -- 806
		"NoCollapse", -- 806
		"AlwaysAutoResize", -- 806
		"NoSavedSettings" -- 806
	} -- 806
	extraOperations = function() -- 813
		local zh = useChinese -- 814
		if isDesktop then -- 815
			local alwaysOnTop = config.alwaysOnTop -- 816
			local changed -- 817
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 817
			if changed then -- 817
				App.alwaysOnTop = alwaysOnTop -- 818
				config.alwaysOnTop = alwaysOnTop -- 819
			end -- 817
		end -- 815
		local showPreview, authRequired = config.showPreview, config.authRequired -- 820
		do -- 821
			local changed -- 821
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 821
			if changed then -- 821
				config.showPreview = showPreview -- 822
				updateEntries() -- 823
				if not showPreview then -- 824
					thread(function() -- 825
						collectgarbage() -- 826
						return Cache:removeUnused("Texture") -- 827
					end) -- 825
				end -- 824
			end -- 821
		end -- 821
		do -- 828
			local changed -- 828
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 828
			if changed then -- 828
				config.authRequired = authRequired -- 829
				HttpServer.authRequired = authRequired -- 830
			end -- 828
		end -- 828
		SameLine() -- 831
		TextColored(descColor, "(?)") -- 832
		if IsItemHovered() then -- 833
			BeginTooltip(function() -- 834
				return PushTextWrapPos(280, function() -- 835
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 836
				end) -- 835
			end) -- 834
		end -- 833
		do -- 837
			local themeColor = App.themeColor -- 838
			local writablePath = config.writablePath -- 839
			SeparatorText(zh and "工作目录" or "Workspace") -- 840
			PushTextWrapPos(400, function() -- 841
				return TextColored(themeColor, writablePath) -- 842
			end) -- 841
			if not isDesktop then -- 843
				goto skipSetting -- 843
			end -- 843
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 844
			if Button(zh and "改变目录" or "Set Folder") then -- 845
				App:openFileDialog(true, function(path) -- 846
					if path == "" then -- 847
						return -- 847
					end -- 847
					local relPath = Path:getRelative(Content.assetPath, path) -- 848
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 849
						return setWorkspace(path) -- 850
					else -- 852
						failedSetFolder = true -- 852
					end -- 849
				end) -- 846
			end -- 845
			if failedSetFolder then -- 853
				failedSetFolder = false -- 854
				OpenPopup(popupName) -- 855
			end -- 853
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 856
			BeginPopupModal(popupName, statusFlags, function() -- 857
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 858
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 859
					return CloseCurrentPopup() -- 860
				end -- 859
			end) -- 857
			SameLine() -- 861
			if Button(zh and "使用默认" or "Use Default") then -- 862
				setWorkspace(Content.appPath) -- 863
			end -- 862
			Separator() -- 864
			::skipSetting:: -- 865
		end -- 837
		if isOSSLicenseExist then -- 866
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 867
				if not ossLicenses then -- 868
					ossLicenses = { } -- 869
					local licenseText = Content:load("LICENSES") -- 870
					ossLicenseOpen = (licenseText ~= nil) -- 871
					if ossLicenseOpen then -- 871
						licenseText = licenseText:gsub("\r\n", "\n") -- 872
						for license in GSplit(licenseText, "\n--------\n", true) do -- 873
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 874
							if name then -- 874
								ossLicenses[#ossLicenses + 1] = { -- 875
									name, -- 875
									text -- 875
								} -- 875
							end -- 874
						end -- 873
					end -- 871
				else -- 877
					ossLicenseOpen = true -- 877
				end -- 868
			end -- 867
			if ossLicenseOpen then -- 878
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 879
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 880
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 881
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 882
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 885
						"NoSavedSettings" -- 885
					}, function() -- 886
						for _index_0 = 1, #ossLicenses do -- 886
							local _des_0 = ossLicenses[_index_0] -- 886
							local firstLine, text = _des_0[1], _des_0[2] -- 886
							local name, license = firstLine:match("(.+): (.+)") -- 887
							TextColored(themeColor, name) -- 888
							SameLine() -- 889
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 890
								return TextWrapped(text) -- 890
							end) -- 890
						end -- 886
					end) -- 882
				end) -- 882
			end -- 878
		end -- 866
		if not App.debugging then -- 892
			return -- 892
		end -- 892
		return TreeNode(zh and "开发操作" or "Development", function() -- 893
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 894
				OpenPopup("build") -- 894
			end -- 894
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 895
				return BeginPopup("build", function() -- 895
					if Selectable(zh and "编译" or "Compile") then -- 896
						doCompile(false) -- 896
					end -- 896
					Separator() -- 897
					if Selectable(zh and "压缩" or "Minify") then -- 898
						doCompile(true) -- 898
					end -- 898
					Separator() -- 899
					if Selectable(zh and "清理" or "Clean") then -- 900
						return doClean() -- 900
					end -- 900
				end) -- 895
			end) -- 895
			if isInEntry then -- 901
				if waitForWebStart then -- 902
					BeginDisabled(function() -- 903
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 903
					end) -- 903
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 904
					reloadDevEntry() -- 905
				end -- 902
			end -- 901
			do -- 906
				local changed -- 906
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 906
				if changed then -- 906
					View.scale = scaleContent and screenScale or 1 -- 907
				end -- 906
			end -- 906
			do -- 908
				local changed -- 908
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 908
				if changed then -- 908
					config.engineDev = engineDev -- 909
				end -- 908
			end -- 908
			if testingThread then -- 910
				return BeginDisabled(function() -- 911
					return Button(zh and "开始自动测试" or "Test automatically") -- 911
				end) -- 911
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 912
				testingThread = thread(function() -- 913
					local _ <close> = setmetatable({ }, { -- 914
						__close = function() -- 914
							allClear() -- 915
							testingThread = nil -- 916
							isInEntry = true -- 917
							currentEntry = nil -- 918
							return print("Testing done!") -- 919
						end -- 914
					}) -- 914
					for _, entry in ipairs(allEntries) do -- 920
						allClear() -- 921
						print("Start " .. tostring(entry.entryName)) -- 922
						enterDemoEntry(entry) -- 923
						sleep(2) -- 924
						print("Stop " .. tostring(entry.entryName)) -- 925
					end -- 920
				end) -- 913
			end -- 910
		end) -- 893
	end -- 813
end -- 801
local icon = Path("Script", "Dev", "icon_s.png") -- 927
local iconTex = nil -- 928
thread(function() -- 929
	if Cache:loadAsync(icon) then -- 929
		iconTex = Texture2D(icon) -- 929
	end -- 929
end) -- 929
local webStatus = nil -- 931
local urlClicked = nil -- 932
local authCode = string.format("%06d", math.random(0, 999999)) -- 934
local authCodeTTL = 30.0 -- 936
_module_0.getAuthCode = function() -- 937
	return authCode -- 937
end -- 937
_module_0.invalidateAuthCode = function() -- 938
	authCode = string.format("%06d", math.random(0, 999999)) -- 939
	authCodeTTL = 30.0 -- 940
end -- 938
local AuthSession -- 942
do -- 942
	local pending = nil -- 943
	local session = nil -- 944
	AuthSession = { -- 946
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 946
			pending = { -- 948
				sessionId = sessionId, -- 948
				confirmCode = confirmCode, -- 949
				expiresAt = expiresAt, -- 950
				ttl = ttl, -- 951
				approved = false -- 952
			} -- 947
		end, -- 946
		getPending = function() -- 954
			return pending -- 954
		end, -- 954
		approvePending = function(sessionId) -- 956
			if pending and pending.sessionId == sessionId then -- 957
				pending.approved = true -- 958
				return true -- 959
			end -- 957
			return false -- 960
		end, -- 956
		clearPending = function() -- 962
			pending = nil -- 962
		end, -- 962
		setSession = function(sessionId, sessionSecret) -- 964
			session = { -- 966
				sessionId = sessionId, -- 966
				sessionSecret = sessionSecret -- 967
			} -- 965
		end, -- 964
		getSession = function() -- 969
			return session -- 969
		end -- 969
	} -- 945
end -- 942
_module_0["AuthSession"] = AuthSession -- 942
local transparant = Color(0x0) -- 972
local windowFlags = { -- 973
	"NoTitleBar", -- 973
	"NoResize", -- 973
	"NoMove", -- 973
	"NoCollapse", -- 973
	"NoSavedSettings", -- 973
	"NoFocusOnAppearing", -- 973
	"NoBringToFrontOnFocus" -- 973
} -- 973
local statusFlags = { -- 982
	"NoTitleBar", -- 982
	"NoResize", -- 982
	"NoMove", -- 982
	"NoCollapse", -- 982
	"AlwaysAutoResize", -- 982
	"NoSavedSettings" -- 982
} -- 982
local displayWindowFlags = { -- 990
	"NoDecoration", -- 990
	"NoSavedSettings", -- 990
	"NoNav", -- 990
	"NoMove", -- 990
	"NoScrollWithMouse", -- 990
	"AlwaysAutoResize", -- 990
	"NoFocusOnAppearing" -- 990
} -- 990
local initFooter = true -- 999
local _anon_func_4 = function(allEntries, currentIndex) -- 1040
	if currentIndex > 1 then -- 1040
		return allEntries[currentIndex - 1] -- 1041
	else -- 1043
		return allEntries[#allEntries] -- 1043
	end -- 1040
end -- 1040
local _anon_func_5 = function(allEntries, currentIndex) -- 1047
	if currentIndex < #allEntries then -- 1047
		return allEntries[currentIndex + 1] -- 1048
	else -- 1050
		return allEntries[1] -- 1050
	end -- 1047
end -- 1047
footerWindow = threadLoop(function() -- 1000
	local zh = useChinese -- 1001
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1002
	if authCodeTTL <= 0 then -- 1003
		authCodeTTL = 30.0 -- 1004
		authCode = string.format("%06d", math.random(0, 999999)) -- 1005
	end -- 1003
	if HttpServer.wsConnectionCount > 0 then -- 1006
		return -- 1007
	end -- 1006
	if Keyboard:isKeyDown("Escape") then -- 1008
		allClear() -- 1009
		App.devMode = false -- 1010
		App:shutdown() -- 1011
	end -- 1008
	do -- 1012
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1013
		if ctrl and Keyboard:isKeyDown("Q") then -- 1014
			stop() -- 1015
		end -- 1014
		if ctrl and Keyboard:isKeyDown("Z") then -- 1016
			reloadCurrentEntry() -- 1017
		end -- 1016
		if ctrl and Keyboard:isKeyDown(",") then -- 1018
			if showFooter then -- 1019
				showStats = not showStats -- 1019
			else -- 1019
				showStats = true -- 1019
			end -- 1019
			showFooter = true -- 1020
			config.showFooter = showFooter -- 1021
			config.showStats = showStats -- 1022
		end -- 1018
		if ctrl and Keyboard:isKeyDown(".") then -- 1023
			if showFooter then -- 1024
				showConsole = not showConsole -- 1024
			else -- 1024
				showConsole = true -- 1024
			end -- 1024
			showFooter = true -- 1025
			config.showFooter = showFooter -- 1026
			config.showConsole = showConsole -- 1027
		end -- 1023
		if ctrl and Keyboard:isKeyDown("/") then -- 1028
			showFooter = not showFooter -- 1029
			config.showFooter = showFooter -- 1030
		end -- 1028
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1031
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1032
		local currentIndex = nil -- 1033
		for i, entry in ipairs(allEntries) do -- 1034
			if currentEntry == entry then -- 1035
				currentIndex = i -- 1036
			end -- 1035
		end -- 1034
		if left then -- 1037
			allClear() -- 1038
			if currentIndex == nil then -- 1039
				currentIndex = #allEntries + 1 -- 1039
			end -- 1039
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 1040
		end -- 1037
		if right then -- 1044
			allClear() -- 1045
			if currentIndex == nil then -- 1046
				currentIndex = 0 -- 1046
			end -- 1046
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1047
		end -- 1044
	end -- 1012
	if not showEntry then -- 1051
		return -- 1051
	end -- 1051
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1053
		reloadDevEntry() -- 1057
	end -- 1053
	if initFooter then -- 1058
		initFooter = false -- 1059
	end -- 1058
	local width, height -- 1061
	do -- 1061
		local _obj_0 = App.visualSize -- 1061
		width, height = _obj_0.width, _obj_0.height -- 1061
	end -- 1061
	if isInEntry or showFooter then -- 1062
		SetNextWindowSize(Vec2(width, 50)) -- 1063
		SetNextWindowPos(Vec2(0, height - 50)) -- 1064
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1065
			return PushStyleVar("WindowRounding", 0, function() -- 1066
				return Begin("Footer", windowFlags, function() -- 1067
					Separator() -- 1068
					if iconTex then -- 1069
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1070
							showStats = not showStats -- 1071
							config.showStats = showStats -- 1072
						end -- 1070
						SameLine() -- 1073
						if Button(">_", Vec2(30, 30)) then -- 1074
							showConsole = not showConsole -- 1075
							config.showConsole = showConsole -- 1076
						end -- 1074
					end -- 1069
					if isInEntry and config.updateNotification then -- 1077
						SameLine() -- 1078
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1079
							allClear() -- 1080
							config.updateNotification = false -- 1081
							enterDemoEntry({ -- 1083
								entryName = "SelfUpdater", -- 1083
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1084
							}) -- 1082
						end -- 1079
					end -- 1077
					if not isInEntry then -- 1085
						SameLine() -- 1086
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1087
						local currentIndex = nil -- 1088
						for i, entry in ipairs(allEntries) do -- 1089
							if currentEntry == entry then -- 1090
								currentIndex = i -- 1091
							end -- 1090
						end -- 1089
						if currentIndex then -- 1092
							if currentIndex > 1 then -- 1093
								SameLine() -- 1094
								if Button("<<", Vec2(30, 30)) then -- 1095
									allClear() -- 1096
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1097
								end -- 1095
							end -- 1093
							if currentIndex < #allEntries then -- 1098
								SameLine() -- 1099
								if Button(">>", Vec2(30, 30)) then -- 1100
									allClear() -- 1101
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1102
								end -- 1100
							end -- 1098
						end -- 1092
						SameLine() -- 1103
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1104
							reloadCurrentEntry() -- 1105
						end -- 1104
						if back then -- 1106
							allClear() -- 1107
							isInEntry = true -- 1108
							currentEntry = nil -- 1109
						end -- 1106
					end -- 1085
				end) -- 1067
			end) -- 1066
		end) -- 1065
	end -- 1062
	if isInEntry then -- 1111
		local showURL = true -- 1112
		local webIDEWidth -- 1113
		do -- 1113
			local base -- 1114
			if config.updateNotification then -- 1114
				base = 460 -- 1114
			else -- 1114
				base = 360 -- 1114
			end -- 1114
			local extra -- 1115
			if config.authRequired then -- 1115
				extra = 35 -- 1115
			else -- 1115
				extra = 0 -- 1115
			end -- 1115
			webIDEWidth = base + extra -- 1116
		end -- 1113
		if width < webIDEWidth then -- 1117
			showURL = false -- 1117
		end -- 1117
		SetNextWindowBgAlpha(0.0) -- 1118
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1119
		Begin("Web IDE", displayWindowFlags, function() -- 1120
			local pending = AuthSession.getPending() -- 1121
			local hovered = false -- 1122
			if not pending and showURL then -- 1123
				do -- 1124
					local url -- 1124
					if webStatus ~= nil then -- 1124
						url = webStatus.url -- 1124
					end -- 1124
					if url then -- 1124
						if isDesktop and not config.fullScreen then -- 1125
							if urlClicked then -- 1126
								BeginDisabled(function() -- 1127
									return Button(url) -- 1127
								end) -- 1127
							elseif Button(url) then -- 1128
								urlClicked = once(function() -- 1129
									return sleep(5) -- 1129
								end) -- 1129
								App:openURL("http://localhost:8866") -- 1130
							end -- 1126
						else -- 1132
							TextColored(descColor, url) -- 1132
						end -- 1125
					else -- 1134
						TextColored(descColor, zh and '不可用' or 'not available') -- 1134
					end -- 1124
				end -- 1124
				hovered = IsItemHovered() -- 1135
			else -- 1137
				TextColored(descColor, "(?)") -- 1137
				hovered = IsItemHovered() -- 1138
			end -- 1123
			SameLine() -- 1139
			local themeColor = App.themeColor -- 1140
			if pending then -- 1141
				if not pending.approved then -- 1142
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1143
					local ttl = pending.ttl or 1 -- 1144
					PushStyleColor("Text", themeColor, function() -- 1145
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1146
						hovered = hovered or IsItemHovered() -- 1147
					end) -- 1145
					SameLine() -- 1148
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1149
						AuthSession.approvePending(pending.sessionId) -- 1150
					end -- 1149
					if hovered then -- 1151
						return BeginTooltip(function() -- 1152
							return PushTextWrapPos(280, function() -- 1153
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1154
							end) -- 1153
						end) -- 1152
					end -- 1151
				end -- 1142
			else -- 1156
				if config.authRequired then -- 1156
					PushStyleColor("Text", themeColor, function() -- 1157
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1158
						hovered = hovered or IsItemHovered() -- 1159
					end) -- 1157
					if hovered then -- 1160
						return BeginTooltip(function() -- 1161
							return PushTextWrapPos(280, function() -- 1162
								local url -- 1163
								if webStatus ~= nil then -- 1163
									url = webStatus.url -- 1163
								end -- 1163
								if url then -- 1163
									local address -- 1164
									if showURL then -- 1164
										address = "Web IDE" -- 1164
									else -- 1164
										address = url -- 1164
									end -- 1164
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1165
								else -- 1167
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1167
								end -- 1163
							end) -- 1162
						end) -- 1161
					end -- 1160
				else -- 1169
					if hovered then -- 1169
						return BeginTooltip(function() -- 1170
							return PushTextWrapPos(280, function() -- 1171
								local url -- 1172
								if webStatus ~= nil then -- 1172
									url = webStatus.url -- 1172
								end -- 1172
								if url then -- 1172
									local address -- 1173
									if showURL then -- 1173
										address = "Web IDE" -- 1173
									else -- 1173
										address = url -- 1173
									end -- 1173
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1174
								else -- 1176
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1176
								end -- 1172
							end) -- 1171
						end) -- 1170
					end -- 1169
				end -- 1156
			end -- 1141
		end) -- 1120
	end -- 1111
	if not isInEntry then -- 1178
		SetNextWindowSize(Vec2(50, 50)) -- 1179
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1180
		PushStyleColor("WindowBg", transparant, function() -- 1181
			return Begin("Show", displayWindowFlags, function() -- 1181
				if width >= 370 then -- 1182
					local changed -- 1183
					changed, showFooter = Checkbox("##dev", showFooter) -- 1183
					if changed then -- 1183
						config.showFooter = showFooter -- 1184
					end -- 1183
				end -- 1182
			end) -- 1181
		end) -- 1181
	end -- 1178
	if isInEntry or showFooter then -- 1186
		if showStats then -- 1187
			PushStyleVar("WindowRounding", 0, function() -- 1188
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1189
				SetNextWindowSize(Vec2(0, height - 50)) -- 1190
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1191
				config.showStats = showStats -- 1192
			end) -- 1188
		end -- 1187
		if showConsole then -- 1193
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1194
			return PushStyleVar("WindowRounding", 6, function() -- 1195
				return ShowConsole() -- 1196
			end) -- 1195
		end -- 1193
	end -- 1186
end) -- 1000
local MaxWidth <const> = 960 -- 1198
local toolOpen = false -- 1200
local filterText = nil -- 1201
local anyEntryMatched = false -- 1202
local match -- 1203
match = function(name) -- 1203
	local res = not filterText or name:lower():match(filterText) -- 1204
	if res then -- 1205
		anyEntryMatched = true -- 1205
	end -- 1205
	return res -- 1206
end -- 1203
local sep -- 1208
sep = function() -- 1208
	return SeparatorText("") -- 1208
end -- 1208
local thinSep -- 1209
thinSep = function() -- 1209
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1209
end -- 1209
entryWindow = threadLoop(function() -- 1211
	if App.fpsLimited ~= config.fpsLimited then -- 1212
		config.fpsLimited = App.fpsLimited -- 1213
	end -- 1212
	if App.targetFPS ~= config.targetFPS then -- 1214
		config.targetFPS = App.targetFPS -- 1215
	end -- 1214
	if View.vsync ~= config.vsync then -- 1216
		config.vsync = View.vsync -- 1217
	end -- 1216
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1218
		config.fixedFPS = Director.scheduler.fixedFPS -- 1219
	end -- 1218
	if Director.profilerSending ~= config.webProfiler then -- 1220
		config.webProfiler = Director.profilerSending -- 1221
	end -- 1220
	if urlClicked then -- 1222
		local _, result = coroutine.resume(urlClicked) -- 1223
		if result then -- 1224
			coroutine.close(urlClicked) -- 1225
			urlClicked = nil -- 1226
		end -- 1224
	end -- 1222
	if not showEntry then -- 1227
		return -- 1227
	end -- 1227
	if not isInEntry then -- 1228
		return -- 1228
	end -- 1228
	local zh = useChinese -- 1229
	local themeColor = App.themeColor -- 1230
	if HttpServer.wsConnectionCount > 0 then -- 1231
		local width, height -- 1232
		do -- 1232
			local _obj_0 = App.visualSize -- 1232
			width, height = _obj_0.width, _obj_0.height -- 1232
		end -- 1232
		SetNextWindowBgAlpha(0.5) -- 1233
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1234
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1235
			Separator() -- 1236
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1237
			if iconTex then -- 1238
				Image(icon, Vec2(24, 24)) -- 1239
				SameLine() -- 1240
			end -- 1238
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1241
			TextColored(descColor, slogon) -- 1242
			return Separator() -- 1243
		end) -- 1235
		return -- 1244
	end -- 1231
	local fullWidth, height -- 1246
	do -- 1246
		local _obj_0 = App.visualSize -- 1246
		fullWidth, height = _obj_0.width, _obj_0.height -- 1246
	end -- 1246
	local width = math.min(MaxWidth, fullWidth) -- 1247
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1248
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1249
	SetNextWindowPos(Vec2.zero) -- 1250
	SetNextWindowBgAlpha(0) -- 1251
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1252
	do -- 1253
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1254
			return Begin("Dora Dev", windowFlags, function() -- 1255
				Dummy(Vec2(fullWidth - 20, 0)) -- 1256
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1257
				if fullWidth >= 400 then -- 1258
					SameLine() -- 1259
					Dummy(Vec2(fullWidth - 400, 0)) -- 1260
					SameLine() -- 1261
					SetNextItemWidth(zh and -95 or -140) -- 1262
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1263
						"AutoSelectAll" -- 1263
					}) then -- 1263
						config.filter = filterBuf.text -- 1264
					end -- 1263
					SameLine() -- 1265
					if Button(zh and '下载' or 'Download') then -- 1266
						allClear() -- 1267
						enterDemoEntry({ -- 1269
							entryName = "ResourceDownloader", -- 1269
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1270
						}) -- 1268
					end -- 1266
				end -- 1258
				return Separator() -- 1271
			end) -- 1255
		end) -- 1254
	end -- 1253
	anyEntryMatched = false -- 1273
	SetNextWindowPos(Vec2(0, 50)) -- 1274
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1275
	do -- 1276
		return PushStyleColor("WindowBg", transparant, function() -- 1277
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1278
				return PushStyleVar("Alpha", 1, function() -- 1279
					return Begin("Content", windowFlags, function() -- 1280
						local DemoViewWidth <const> = 220 -- 1281
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1282
						if filterText then -- 1283
							filterText = filterText:lower() -- 1283
						end -- 1283
						if #gamesInDev > 0 then -- 1284
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1285
							Columns(columns, false) -- 1286
							local realViewWidth = GetColumnWidth() - 50 -- 1287
							for _index_0 = 1, #gamesInDev do -- 1288
								local game = gamesInDev[_index_0] -- 1288
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1289
								local displayName -- 1298
								if repo then -- 1298
									if zh then -- 1299
										displayName = repo.title.zh -- 1299
									else -- 1299
										displayName = repo.title.en -- 1299
									end -- 1299
								end -- 1298
								if displayName == nil then -- 1300
									displayName = gameName -- 1300
								end -- 1300
								if match(displayName) then -- 1301
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1302
									SameLine() -- 1303
									TextWrapped(displayName) -- 1304
									if columns > 1 then -- 1305
										if bannerFile then -- 1306
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1307
											local displayWidth <const> = realViewWidth -- 1308
											texHeight = displayWidth * texHeight / texWidth -- 1309
											texWidth = displayWidth -- 1310
											Dummy(Vec2.zero) -- 1311
											SameLine() -- 1312
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1313
										end -- 1306
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1314
											enterDemoEntry(game) -- 1315
										end -- 1314
									else -- 1317
										if bannerFile then -- 1317
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1318
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1319
											local sizing = 0.8 -- 1320
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1321
											texWidth = displayWidth * sizing -- 1322
											if texWidth > 500 then -- 1323
												sizing = 0.6 -- 1324
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1325
												texWidth = displayWidth * sizing -- 1326
											end -- 1323
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1327
											Dummy(Vec2(padding, 0)) -- 1328
											SameLine() -- 1329
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1330
										end -- 1317
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1331
											enterDemoEntry(game) -- 1332
										end -- 1331
									end -- 1305
									if #tests == 0 and #examples == 0 then -- 1333
										thinSep() -- 1334
									end -- 1333
									NextColumn() -- 1335
								end -- 1301
								local showSep = false -- 1336
								if #examples > 0 then -- 1337
									local showExample = false -- 1338
									for _index_1 = 1, #examples do -- 1339
										local _des_0 = examples[_index_1] -- 1339
										local entryName = _des_0.entryName -- 1339
										if match(entryName) then -- 1340
											showExample = true -- 1340
											break -- 1340
										end -- 1340
									end -- 1339
									if showExample then -- 1341
										showSep = true -- 1342
										Columns(1, false) -- 1343
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1344
										SameLine() -- 1345
										local opened -- 1346
										if (filterText ~= nil) then -- 1346
											opened = showExample -- 1346
										else -- 1346
											opened = false -- 1346
										end -- 1346
										if game.exampleOpen == nil then -- 1347
											game.exampleOpen = opened -- 1347
										end -- 1347
										SetNextItemOpen(game.exampleOpen) -- 1348
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1349
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1350
												Columns(maxColumns, false) -- 1351
												for _index_1 = 1, #examples do -- 1352
													local example = examples[_index_1] -- 1352
													local entryName = example.entryName -- 1353
													if not match(entryName) then -- 1354
														goto _continue_0 -- 1354
													end -- 1354
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1355
														if Button(entryName, Vec2(-1, 40)) then -- 1356
															enterDemoEntry(example) -- 1357
														end -- 1356
														return NextColumn() -- 1358
													end) -- 1355
													opened = true -- 1359
													::_continue_0:: -- 1353
												end -- 1352
											end) -- 1350
										end) -- 1349
										game.exampleOpen = opened -- 1360
									end -- 1341
								end -- 1337
								if #tests > 0 then -- 1361
									local showTest = false -- 1362
									for _index_1 = 1, #tests do -- 1363
										local _des_0 = tests[_index_1] -- 1363
										local entryName = _des_0.entryName -- 1363
										if match(entryName) then -- 1364
											showTest = true -- 1364
											break -- 1364
										end -- 1364
									end -- 1363
									if showTest then -- 1365
										showSep = true -- 1366
										Columns(1, false) -- 1367
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1368
										SameLine() -- 1369
										local opened -- 1370
										if (filterText ~= nil) then -- 1370
											opened = showTest -- 1370
										else -- 1370
											opened = false -- 1370
										end -- 1370
										if game.testOpen == nil then -- 1371
											game.testOpen = opened -- 1371
										end -- 1371
										SetNextItemOpen(game.testOpen) -- 1372
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1373
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1374
												Columns(maxColumns, false) -- 1375
												for _index_1 = 1, #tests do -- 1376
													local test = tests[_index_1] -- 1376
													local entryName = test.entryName -- 1377
													if not match(entryName) then -- 1378
														goto _continue_0 -- 1378
													end -- 1378
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1379
														if Button(entryName, Vec2(-1, 40)) then -- 1380
															enterDemoEntry(test) -- 1381
														end -- 1380
														return NextColumn() -- 1382
													end) -- 1379
													opened = true -- 1383
													::_continue_0:: -- 1377
												end -- 1376
											end) -- 1374
										end) -- 1373
										game.testOpen = opened -- 1384
									end -- 1365
								end -- 1361
								if showSep then -- 1385
									Columns(1, false) -- 1386
									thinSep() -- 1387
									Columns(columns, false) -- 1388
								end -- 1385
							end -- 1288
						end -- 1284
						if #doraTools > 0 then -- 1389
							local showTool = false -- 1390
							for _index_0 = 1, #doraTools do -- 1391
								local _des_0 = doraTools[_index_0] -- 1391
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1391
								local displayName -- 1392
								if repo then -- 1392
									if zh then -- 1393
										displayName = repo.title.zh -- 1393
									else -- 1393
										displayName = repo.title.en -- 1393
									end -- 1393
								end -- 1392
								if displayName == nil then -- 1394
									displayName = entryName -- 1394
								end -- 1394
								if match(displayName) then -- 1395
									showTool = true -- 1395
									break -- 1395
								end -- 1395
							end -- 1391
							if not showTool then -- 1396
								goto endEntry -- 1396
							end -- 1396
							Columns(1, false) -- 1397
							TextColored(themeColor, "Dora SSR:") -- 1398
							SameLine() -- 1399
							Text(zh and "开发支持" or "Development Support") -- 1400
							Separator() -- 1401
							if #doraTools > 0 then -- 1402
								local opened -- 1403
								if (filterText ~= nil) then -- 1403
									opened = showTool -- 1403
								else -- 1403
									opened = false -- 1403
								end -- 1403
								SetNextItemOpen(toolOpen) -- 1404
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1405
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1406
										Columns(maxColumns, false) -- 1407
										for _index_0 = 1, #doraTools do -- 1408
											local tool = doraTools[_index_0] -- 1408
											local entryName, repo = tool.entryName, tool.repo -- 1409
											local displayName -- 1410
											if repo then -- 1410
												if zh then -- 1411
													displayName = repo.title.zh -- 1411
												else -- 1411
													displayName = repo.title.en -- 1411
												end -- 1411
											end -- 1410
											if displayName == nil then -- 1412
												displayName = entryName -- 1412
											end -- 1412
											if not match(displayName) then -- 1413
												goto _continue_0 -- 1413
											end -- 1413
											if Button(displayName, Vec2(-1, 40)) then -- 1414
												enterDemoEntry(tool) -- 1415
											end -- 1414
											NextColumn() -- 1416
											::_continue_0:: -- 1409
										end -- 1408
										Columns(1, false) -- 1417
										opened = true -- 1418
									end) -- 1406
								end) -- 1405
								toolOpen = opened -- 1419
							end -- 1402
						end -- 1389
						::endEntry:: -- 1420
						if not anyEntryMatched then -- 1421
							SetNextWindowBgAlpha(0) -- 1422
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1423
							Begin("Entries Not Found", displayWindowFlags, function() -- 1424
								Separator() -- 1425
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1426
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1427
								return Separator() -- 1428
							end) -- 1424
						end -- 1421
						Columns(1, false) -- 1429
						Dummy(Vec2(100, 80)) -- 1430
						return ScrollWhenDraggingOnVoid() -- 1431
					end) -- 1280
				end) -- 1279
			end) -- 1278
		end) -- 1277
	end -- 1276
end) -- 1211
webStatus = require("Script.Dev.WebServer") -- 1433
return _module_0 -- 1
