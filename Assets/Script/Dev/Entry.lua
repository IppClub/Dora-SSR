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
		package.loaded["Script.Dev.WebServer"] = nil -- 614
		return Director.systemScheduler:schedule(function() -- 615
			Routine:clear() -- 616
			oldRequire("Script.Dev.Entry") -- 617
			return true -- 618
		end) -- 615
	end) -- 607
end -- 607
local setWorkspace -- 620
setWorkspace = function(path) -- 620
	clearTempFiles() -- 621
	Content.writablePath = path -- 622
	config.writablePath = Content.writablePath -- 623
	return thread(function() -- 624
		sleep() -- 625
		return reloadDevEntry() -- 626
	end) -- 624
end -- 620
_module_0["setWorkspace"] = setWorkspace -- 620
local quit = false -- 628
local activeSearchId = 0 -- 630
local handleSearchFiles -- 632
handleSearchFiles = function(payload) -- 632
	if not payload then -- 633
		return -- 633
	end -- 633
	local id = payload.id -- 634
	if id == nil then -- 635
		return -- 635
	end -- 635
	activeSearchId = id -- 636
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 637
	if path == nil then -- 638
		path = "" -- 638
	end -- 638
	if exts == nil then -- 639
		exts = { } -- 639
	end -- 639
	if globs == nil then -- 640
		globs = { } -- 640
	end -- 640
	if extensionLevels == nil then -- 641
		extensionLevels = { } -- 641
	end -- 641
	if pattern == nil then -- 642
		pattern = "" -- 642
	end -- 642
	if pattern == "" then -- 644
		return -- 644
	end -- 644
	local useRegex = payload.useRegex == true -- 645
	local caseSensitive = payload.caseSensitive == true -- 646
	local includeContent = payload.includeContent ~= false -- 647
	local contentWindow = payload.contentWindow or 0 -- 648
	return Director.systemScheduler:schedule(once(function() -- 649
		local stopped = false -- 650
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 651
			if activeSearchId ~= id then -- 652
				stopped = true -- 653
				return true -- 654
			end -- 652
			emit("AppWS", "Send", json.encode({ -- 656
				name = "SearchFilesResult", -- 656
				id = id, -- 656
				result = result -- 656
			})) -- 655
			return false -- 658
		end) -- 651
		return emit("AppWS", "Send", json.encode({ -- 660
			name = "SearchFilesDone", -- 660
			id = id, -- 660
			stopped = stopped -- 660
		})) -- 659
	end)) -- 649
end -- 632
local stop -- 663
stop = function() -- 663
	if isInEntry then -- 664
		return false -- 664
	end -- 664
	allClear() -- 665
	isInEntry = true -- 666
	currentEntry = nil -- 667
	return true -- 668
end -- 663
_module_0["stop"] = stop -- 663
local getCurrentEntryStatus -- 670
getCurrentEntryStatus = function() -- 670
	local entry = currentEntry -- 671
	if not (entry and not isInEntry) then -- 672
		return { -- 672
			success = true, -- 672
			running = false -- 672
		} -- 672
	end -- 672
	local status = { -- 674
		success = true, -- 674
		running = true, -- 675
		kind = entry.runKind or "file", -- 676
		entryName = entry.entryName, -- 677
		fileName = entry.fileName -- 678
	} -- 673
	if entry.workDir then -- 679
		status.workDir = entry.workDir -- 679
	end -- 679
	if entry.projectRoot then -- 680
		status.projectRoot = entry.projectRoot -- 680
	end -- 680
	return status -- 681
end -- 670
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 670
local _anon_func_1 = function(_with_0) -- 700
	local _val_0 = App.platform -- 700
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 700
end -- 700
setupEventHandlers = function() -- 683
	local _with_0 = Director.postNode -- 684
	_with_0:onAppEvent(function(eventType) -- 685
		if "Quit" == eventType then -- 686
			quit = true -- 687
			allClear() -- 688
			return clearTempFiles() -- 689
		elseif "Shutdown" == eventType then -- 690
			return stop() -- 691
		end -- 685
	end) -- 685
	_with_0:onAppChange(function(settingName) -- 692
		if "Theme" == settingName then -- 693
			config.themeColor = App.themeColor:toARGB() -- 694
		elseif "Locale" == settingName then -- 695
			config.locale = App.locale -- 696
			updateLocale() -- 697
			return teal.clear(true) -- 698
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 699
			if _anon_func_1(_with_0) then -- 700
				if "FullScreen" == settingName then -- 702
					config.fullScreen = App.fullScreen -- 702
				elseif "Position" == settingName then -- 703
					local _obj_0 = App.winPosition -- 703
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 703
				elseif "Size" == settingName then -- 704
					local width, height -- 705
					do -- 705
						local _obj_0 = App.winSize -- 705
						width, height = _obj_0.width, _obj_0.height -- 705
					end -- 705
					config.winWidth = width -- 706
					config.winHeight = height -- 707
				end -- 701
			end -- 700
		end -- 692
	end) -- 692
	_with_0:onAppWS(function(event) -- 708
		if event.type == "Close" then -- 709
			if HttpServer.wsConnectionCount == 0 then -- 710
				updateEntries() -- 711
			end -- 710
			return -- 712
		end -- 709
		if not (event.type == "Receive") then -- 713
			return -- 713
		end -- 713
		local data = json.decode(event.msg) -- 714
		if not data then -- 715
			return -- 715
		end -- 715
		local _exp_0 = data.name -- 716
		if "SearchFiles" == _exp_0 then -- 717
			return handleSearchFiles(data) -- 718
		elseif "SearchFilesStop" == _exp_0 then -- 719
			if data.id == nil or data.id == activeSearchId then -- 720
				activeSearchId = 0 -- 721
			end -- 720
		end -- 716
	end) -- 708
	_with_0:slot("UpdateEntries", function() -- 722
		return updateEntries() -- 722
	end) -- 722
	return _with_0 -- 684
end -- 683
setupEventHandlers() -- 724
clearTempFiles() -- 725
local downloadFile -- 727
downloadFile = function(url, target) -- 727
	return Director.systemScheduler:schedule(once(function() -- 727
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 728
			if quit then -- 729
				return true -- 729
			end -- 729
			emit("AppWS", "Send", json.encode({ -- 731
				name = "Download", -- 731
				url = url, -- 731
				status = "downloading", -- 731
				progress = current / total -- 732
			})) -- 730
			return false -- 728
		end) -- 728
		return emit("AppWS", "Send", json.encode(success and { -- 735
			name = "Download", -- 735
			url = url, -- 735
			status = "completed", -- 735
			progress = 1.0 -- 736
		} or { -- 738
			name = "Download", -- 738
			url = url, -- 738
			status = "failed", -- 738
			progress = 0.0 -- 739
		})) -- 734
	end)) -- 727
end -- 727
_module_0["downloadFile"] = downloadFile -- 727
local _anon_func_2 = function(file, require, workDir) -- 750
	if workDir == nil then -- 750
		workDir = Path:getPath(file) -- 750
	end -- 750
	Content:insertSearchPath(1, workDir) -- 751
	local scriptPath = Path(workDir, "Script") -- 752
	if Content:exist(scriptPath) then -- 753
		Content:insertSearchPath(1, scriptPath) -- 754
	end -- 753
	local result = require(file) -- 755
	if "function" == type(result) then -- 756
		result() -- 756
	end -- 756
	return nil -- 757
end -- 750
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 786
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 786
	label.alignment = "Left" -- 787
	label.textWidth = width - fontSize -- 788
	label.text = err -- 789
	return label -- 786
end -- 786
local enterEntryAsync -- 742
enterEntryAsync = function(entry) -- 742
	isInEntry = false -- 743
	App.idled = false -- 744
	emit(Profiler.EventName, "ClearLoader") -- 745
	currentEntry = entry -- 746
	local file, workDir = entry.fileName, entry.workDir -- 747
	sleep() -- 748
	return xpcall(_anon_func_2, function(msg) -- 757
		local err = debug.traceback(msg) -- 759
		Log("Error", err) -- 760
		allClear() -- 761
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 762
		local viewWidth, viewHeight -- 763
		do -- 763
			local _obj_0 = View.size -- 763
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 763
		end -- 763
		local width, height = viewWidth - 20, viewHeight - 20 -- 764
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 765
		Director.ui:addChild((function() -- 766
			local root = AlignNode() -- 766
			do -- 767
				local _obj_0 = App.bufferSize -- 767
				width, height = _obj_0.width, _obj_0.height -- 767
			end -- 767
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 768
			root:onAppChange(function(settingName) -- 769
				if settingName == "Size" then -- 769
					do -- 770
						local _obj_0 = App.bufferSize -- 770
						width, height = _obj_0.width, _obj_0.height -- 770
					end -- 770
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 771
				end -- 769
			end) -- 769
			root:addChild((function() -- 772
				local _with_0 = ScrollArea({ -- 773
					width = width, -- 773
					height = height, -- 774
					paddingX = 0, -- 775
					paddingY = 50, -- 776
					viewWidth = height, -- 777
					viewHeight = height -- 778
				}) -- 772
				root:onAlignLayout(function(w, h) -- 780
					_with_0.position = Vec2(w / 2, h / 2) -- 781
					w = w - 20 -- 782
					h = h - 20 -- 783
					_with_0.view.children.first.textWidth = w - fontSize -- 784
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 785
				end) -- 780
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 786
				return _with_0 -- 772
			end)()) -- 772
			return root -- 766
		end)()) -- 766
		return err -- 790
	end, file, require, workDir) -- 749
end -- 742
_module_0["enterEntryAsync"] = enterEntryAsync -- 742
local enterDemoEntry -- 792
enterDemoEntry = function(entry) -- 792
	return thread(function() -- 792
		return enterEntryAsync(entry) -- 792
	end) -- 792
end -- 792
local reloadCurrentEntry -- 794
reloadCurrentEntry = function() -- 794
	if currentEntry then -- 795
		allClear() -- 796
		return enterDemoEntry(currentEntry) -- 797
	end -- 795
end -- 794
Director.clearColor = Color(0xff1a1a1a) -- 799
local descColor = Color(0xffa1a1a1) -- 800
local extraOperations -- 802
do -- 802
	local isOSSLicenseExist = Content:exist("LICENSES") -- 803
	local ossLicenses = nil -- 804
	local ossLicenseOpen = false -- 805
	local failedSetFolder = false -- 806
	local statusFlags = { -- 807
		"NoResize", -- 807
		"NoMove", -- 807
		"NoCollapse", -- 807
		"AlwaysAutoResize", -- 807
		"NoSavedSettings" -- 807
	} -- 807
	extraOperations = function() -- 814
		local zh = useChinese -- 815
		if isDesktop then -- 816
			local alwaysOnTop = config.alwaysOnTop -- 817
			local changed -- 818
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 818
			if changed then -- 818
				App.alwaysOnTop = alwaysOnTop -- 819
				config.alwaysOnTop = alwaysOnTop -- 820
			end -- 818
		end -- 816
		local showPreview, authRequired = config.showPreview, config.authRequired -- 821
		do -- 822
			local changed -- 822
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 822
			if changed then -- 822
				config.showPreview = showPreview -- 823
				updateEntries() -- 824
				if not showPreview then -- 825
					thread(function() -- 826
						collectgarbage() -- 827
						return Cache:removeUnused("Texture") -- 828
					end) -- 826
				end -- 825
			end -- 822
		end -- 822
		do -- 829
			local changed -- 829
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 829
			if changed then -- 829
				config.authRequired = authRequired -- 830
				HttpServer.authRequired = authRequired -- 831
			end -- 829
		end -- 829
		SameLine() -- 832
		TextColored(descColor, "(?)") -- 833
		if IsItemHovered() then -- 834
			BeginTooltip(function() -- 835
				return PushTextWrapPos(280, function() -- 836
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 837
				end) -- 836
			end) -- 835
		end -- 834
		do -- 838
			local themeColor = App.themeColor -- 839
			local writablePath = config.writablePath -- 840
			SeparatorText(zh and "工作目录" or "Workspace") -- 841
			PushTextWrapPos(400, function() -- 842
				return TextColored(themeColor, writablePath) -- 843
			end) -- 842
			if not isDesktop then -- 844
				goto skipSetting -- 844
			end -- 844
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 845
			if Button(zh and "改变目录" or "Set Folder") then -- 846
				App:openFileDialog(true, function(path) -- 847
					if path == "" then -- 848
						return -- 848
					end -- 848
					local relPath = Path:getRelative(Content.assetPath, path) -- 849
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 850
						return setWorkspace(path) -- 851
					else -- 853
						failedSetFolder = true -- 853
					end -- 850
				end) -- 847
			end -- 846
			if failedSetFolder then -- 854
				failedSetFolder = false -- 855
				OpenPopup(popupName) -- 856
			end -- 854
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 857
			BeginPopupModal(popupName, statusFlags, function() -- 858
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 859
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 860
					return CloseCurrentPopup() -- 861
				end -- 860
			end) -- 858
			SameLine() -- 862
			if Button(zh and "使用默认" or "Use Default") then -- 863
				setWorkspace(Content.appPath) -- 864
			end -- 863
			Separator() -- 865
			::skipSetting:: -- 866
		end -- 838
		if isOSSLicenseExist then -- 867
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 868
				if not ossLicenses then -- 869
					ossLicenses = { } -- 870
					local licenseText = Content:load("LICENSES") -- 871
					ossLicenseOpen = (licenseText ~= nil) -- 872
					if ossLicenseOpen then -- 872
						licenseText = licenseText:gsub("\r\n", "\n") -- 873
						for license in GSplit(licenseText, "\n--------\n", true) do -- 874
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 875
							if name then -- 875
								ossLicenses[#ossLicenses + 1] = { -- 876
									name, -- 876
									text -- 876
								} -- 876
							end -- 875
						end -- 874
					end -- 872
				else -- 878
					ossLicenseOpen = true -- 878
				end -- 869
			end -- 868
			if ossLicenseOpen then -- 879
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 880
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 881
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 882
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 883
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 886
						"NoSavedSettings" -- 886
					}, function() -- 887
						for _index_0 = 1, #ossLicenses do -- 887
							local _des_0 = ossLicenses[_index_0] -- 887
							local firstLine, text = _des_0[1], _des_0[2] -- 887
							local name, license = firstLine:match("(.+): (.+)") -- 888
							TextColored(themeColor, name) -- 889
							SameLine() -- 890
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 891
								return TextWrapped(text) -- 891
							end) -- 891
						end -- 887
					end) -- 883
				end) -- 883
			end -- 879
		end -- 867
		if not App.debugging then -- 893
			return -- 893
		end -- 893
		return TreeNode(zh and "开发操作" or "Development", function() -- 894
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 895
				OpenPopup("build") -- 895
			end -- 895
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 896
				return BeginPopup("build", function() -- 896
					if Selectable(zh and "编译" or "Compile") then -- 897
						doCompile(false) -- 897
					end -- 897
					Separator() -- 898
					if Selectable(zh and "压缩" or "Minify") then -- 899
						doCompile(true) -- 899
					end -- 899
					Separator() -- 900
					if Selectable(zh and "清理" or "Clean") then -- 901
						return doClean() -- 901
					end -- 901
				end) -- 896
			end) -- 896
			if isInEntry then -- 902
				if waitForWebStart then -- 903
					BeginDisabled(function() -- 904
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 904
					end) -- 904
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 905
					reloadDevEntry() -- 906
				end -- 903
			end -- 902
			do -- 907
				local changed -- 907
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 907
				if changed then -- 907
					View.scale = scaleContent and screenScale or 1 -- 908
				end -- 907
			end -- 907
			do -- 909
				local changed -- 909
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 909
				if changed then -- 909
					config.engineDev = engineDev -- 910
				end -- 909
			end -- 909
			if testingThread then -- 911
				return BeginDisabled(function() -- 912
					return Button(zh and "开始自动测试" or "Test automatically") -- 912
				end) -- 912
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 913
				testingThread = thread(function() -- 914
					local _ <close> = setmetatable({ }, { -- 915
						__close = function() -- 915
							allClear() -- 916
							testingThread = nil -- 917
							isInEntry = true -- 918
							currentEntry = nil -- 919
							return print("Testing done!") -- 920
						end -- 915
					}) -- 915
					for _, entry in ipairs(allEntries) do -- 921
						allClear() -- 922
						print("Start " .. tostring(entry.entryName)) -- 923
						enterDemoEntry(entry) -- 924
						sleep(2) -- 925
						print("Stop " .. tostring(entry.entryName)) -- 926
					end -- 921
				end) -- 914
			end -- 911
		end) -- 894
	end -- 814
end -- 802
local icon = Path("Script", "Dev", "icon_s.png") -- 928
local iconTex = nil -- 929
thread(function() -- 930
	if Cache:loadAsync(icon) then -- 930
		iconTex = Texture2D(icon) -- 930
	end -- 930
end) -- 930
local webStatus = nil -- 932
local urlClicked = nil -- 933
local authCode = string.format("%06d", math.random(0, 999999)) -- 935
local authCodeTTL = 30.0 -- 937
_module_0.getAuthCode = function() -- 938
	return authCode -- 938
end -- 938
_module_0.invalidateAuthCode = function() -- 939
	authCode = string.format("%06d", math.random(0, 999999)) -- 940
	authCodeTTL = 30.0 -- 941
end -- 939
local AuthSession -- 943
do -- 943
	local pending = nil -- 944
	local session = nil -- 945
	AuthSession = { -- 947
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 947
			pending = { -- 949
				sessionId = sessionId, -- 949
				confirmCode = confirmCode, -- 950
				expiresAt = expiresAt, -- 951
				ttl = ttl, -- 952
				approved = false -- 953
			} -- 948
		end, -- 947
		getPending = function() -- 955
			return pending -- 955
		end, -- 955
		approvePending = function(sessionId) -- 957
			if pending and pending.sessionId == sessionId then -- 958
				pending.approved = true -- 959
				return true -- 960
			end -- 958
			return false -- 961
		end, -- 957
		clearPending = function() -- 963
			pending = nil -- 963
		end, -- 963
		setSession = function(sessionId, sessionSecret) -- 965
			session = { -- 967
				sessionId = sessionId, -- 967
				sessionSecret = sessionSecret -- 968
			} -- 966
		end, -- 965
		getSession = function() -- 970
			return session -- 970
		end -- 970
	} -- 946
end -- 943
_module_0["AuthSession"] = AuthSession -- 943
local transparant = Color(0x0) -- 973
local windowFlags = { -- 974
	"NoTitleBar", -- 974
	"NoResize", -- 974
	"NoMove", -- 974
	"NoCollapse", -- 974
	"NoSavedSettings", -- 974
	"NoFocusOnAppearing", -- 974
	"NoBringToFrontOnFocus" -- 974
} -- 974
local statusFlags = { -- 983
	"NoTitleBar", -- 983
	"NoResize", -- 983
	"NoMove", -- 983
	"NoCollapse", -- 983
	"AlwaysAutoResize", -- 983
	"NoSavedSettings" -- 983
} -- 983
local displayWindowFlags = { -- 991
	"NoDecoration", -- 991
	"NoSavedSettings", -- 991
	"NoNav", -- 991
	"NoMove", -- 991
	"NoScrollWithMouse", -- 991
	"AlwaysAutoResize", -- 991
	"NoFocusOnAppearing" -- 991
} -- 991
local initFooter = true -- 1000
local _anon_func_4 = function(allEntries, currentIndex) -- 1041
	if currentIndex > 1 then -- 1041
		return allEntries[currentIndex - 1] -- 1042
	else -- 1044
		return allEntries[#allEntries] -- 1044
	end -- 1041
end -- 1041
local _anon_func_5 = function(allEntries, currentIndex) -- 1048
	if currentIndex < #allEntries then -- 1048
		return allEntries[currentIndex + 1] -- 1049
	else -- 1051
		return allEntries[1] -- 1051
	end -- 1048
end -- 1048
footerWindow = threadLoop(function() -- 1001
	local zh = useChinese -- 1002
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1003
	if authCodeTTL <= 0 then -- 1004
		authCodeTTL = 30.0 -- 1005
		authCode = string.format("%06d", math.random(0, 999999)) -- 1006
	end -- 1004
	if HttpServer.wsConnectionCount > 0 then -- 1007
		return -- 1008
	end -- 1007
	if Keyboard:isKeyDown("Escape") then -- 1009
		allClear() -- 1010
		App.devMode = false -- 1011
		App:shutdown() -- 1012
	end -- 1009
	do -- 1013
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1014
		if ctrl and Keyboard:isKeyDown("Q") then -- 1015
			stop() -- 1016
		end -- 1015
		if ctrl and Keyboard:isKeyDown("Z") then -- 1017
			reloadCurrentEntry() -- 1018
		end -- 1017
		if ctrl and Keyboard:isKeyDown(",") then -- 1019
			if showFooter then -- 1020
				showStats = not showStats -- 1020
			else -- 1020
				showStats = true -- 1020
			end -- 1020
			showFooter = true -- 1021
			config.showFooter = showFooter -- 1022
			config.showStats = showStats -- 1023
		end -- 1019
		if ctrl and Keyboard:isKeyDown(".") then -- 1024
			if showFooter then -- 1025
				showConsole = not showConsole -- 1025
			else -- 1025
				showConsole = true -- 1025
			end -- 1025
			showFooter = true -- 1026
			config.showFooter = showFooter -- 1027
			config.showConsole = showConsole -- 1028
		end -- 1024
		if ctrl and Keyboard:isKeyDown("/") then -- 1029
			showFooter = not showFooter -- 1030
			config.showFooter = showFooter -- 1031
		end -- 1029
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1032
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1033
		local currentIndex = nil -- 1034
		for i, entry in ipairs(allEntries) do -- 1035
			if currentEntry == entry then -- 1036
				currentIndex = i -- 1037
			end -- 1036
		end -- 1035
		if left then -- 1038
			allClear() -- 1039
			if currentIndex == nil then -- 1040
				currentIndex = #allEntries + 1 -- 1040
			end -- 1040
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 1041
		end -- 1038
		if right then -- 1045
			allClear() -- 1046
			if currentIndex == nil then -- 1047
				currentIndex = 0 -- 1047
			end -- 1047
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1048
		end -- 1045
	end -- 1013
	if not showEntry then -- 1052
		return -- 1052
	end -- 1052
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1054
		reloadDevEntry() -- 1058
	end -- 1054
	if initFooter then -- 1059
		initFooter = false -- 1060
	end -- 1059
	local width, height -- 1062
	do -- 1062
		local _obj_0 = App.visualSize -- 1062
		width, height = _obj_0.width, _obj_0.height -- 1062
	end -- 1062
	if isInEntry or showFooter then -- 1063
		SetNextWindowSize(Vec2(width, 50)) -- 1064
		SetNextWindowPos(Vec2(0, height - 50)) -- 1065
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1066
			return PushStyleVar("WindowRounding", 0, function() -- 1067
				return Begin("Footer", windowFlags, function() -- 1068
					Separator() -- 1069
					if iconTex then -- 1070
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1071
							showStats = not showStats -- 1072
							config.showStats = showStats -- 1073
						end -- 1071
						SameLine() -- 1074
						if Button(">_", Vec2(30, 30)) then -- 1075
							showConsole = not showConsole -- 1076
							config.showConsole = showConsole -- 1077
						end -- 1075
					end -- 1070
					if isInEntry and config.updateNotification then -- 1078
						SameLine() -- 1079
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1080
							allClear() -- 1081
							config.updateNotification = false -- 1082
							enterDemoEntry({ -- 1084
								entryName = "SelfUpdater", -- 1084
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1085
							}) -- 1083
						end -- 1080
					end -- 1078
					if not isInEntry then -- 1086
						SameLine() -- 1087
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1088
						local currentIndex = nil -- 1089
						for i, entry in ipairs(allEntries) do -- 1090
							if currentEntry == entry then -- 1091
								currentIndex = i -- 1092
							end -- 1091
						end -- 1090
						if currentIndex then -- 1093
							if currentIndex > 1 then -- 1094
								SameLine() -- 1095
								if Button("<<", Vec2(30, 30)) then -- 1096
									allClear() -- 1097
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1098
								end -- 1096
							end -- 1094
							if currentIndex < #allEntries then -- 1099
								SameLine() -- 1100
								if Button(">>", Vec2(30, 30)) then -- 1101
									allClear() -- 1102
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1103
								end -- 1101
							end -- 1099
						end -- 1093
						SameLine() -- 1104
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1105
							reloadCurrentEntry() -- 1106
						end -- 1105
						if back then -- 1107
							allClear() -- 1108
							isInEntry = true -- 1109
							currentEntry = nil -- 1110
						end -- 1107
					end -- 1086
				end) -- 1068
			end) -- 1067
		end) -- 1066
	end -- 1063
	if isInEntry then -- 1112
		local showURL = true -- 1113
		local webIDEWidth -- 1114
		do -- 1114
			local base -- 1115
			if config.updateNotification then -- 1115
				base = 460 -- 1115
			else -- 1115
				base = 360 -- 1115
			end -- 1115
			local extra -- 1116
			if config.authRequired then -- 1116
				extra = 35 -- 1116
			else -- 1116
				extra = 0 -- 1116
			end -- 1116
			webIDEWidth = base + extra -- 1117
		end -- 1114
		if width < webIDEWidth then -- 1118
			showURL = false -- 1118
		end -- 1118
		SetNextWindowBgAlpha(0.0) -- 1119
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1120
		Begin("Web IDE", displayWindowFlags, function() -- 1121
			local pending = AuthSession.getPending() -- 1122
			local hovered = false -- 1123
			if not pending and showURL then -- 1124
				do -- 1125
					local url -- 1125
					if webStatus ~= nil then -- 1125
						url = webStatus.url -- 1125
					end -- 1125
					if url then -- 1125
						if isDesktop and not config.fullScreen then -- 1126
							if urlClicked then -- 1127
								BeginDisabled(function() -- 1128
									return Button(url) -- 1128
								end) -- 1128
							elseif Button(url) then -- 1129
								urlClicked = once(function() -- 1130
									return sleep(5) -- 1130
								end) -- 1130
								App:openURL("http://localhost:8866") -- 1131
							end -- 1127
						else -- 1133
							TextColored(descColor, url) -- 1133
						end -- 1126
					else -- 1135
						TextColored(descColor, zh and '不可用' or 'not available') -- 1135
					end -- 1125
				end -- 1125
				hovered = IsItemHovered() -- 1136
			else -- 1138
				TextColored(descColor, "(?)") -- 1138
				hovered = IsItemHovered() -- 1139
			end -- 1124
			SameLine() -- 1140
			local themeColor = App.themeColor -- 1141
			if pending then -- 1142
				if not pending.approved then -- 1143
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1144
					local ttl = pending.ttl or 1 -- 1145
					PushStyleColor("Text", themeColor, function() -- 1146
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1147
						hovered = hovered or IsItemHovered() -- 1148
					end) -- 1146
					SameLine() -- 1149
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1150
						AuthSession.approvePending(pending.sessionId) -- 1151
					end -- 1150
					if hovered then -- 1152
						return BeginTooltip(function() -- 1153
							return PushTextWrapPos(280, function() -- 1154
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1155
							end) -- 1154
						end) -- 1153
					end -- 1152
				end -- 1143
			else -- 1157
				if config.authRequired then -- 1157
					PushStyleColor("Text", themeColor, function() -- 1158
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1159
						hovered = hovered or IsItemHovered() -- 1160
					end) -- 1158
					if hovered then -- 1161
						return BeginTooltip(function() -- 1162
							return PushTextWrapPos(280, function() -- 1163
								local url -- 1164
								if webStatus ~= nil then -- 1164
									url = webStatus.url -- 1164
								end -- 1164
								if url then -- 1164
									local address -- 1165
									if showURL then -- 1165
										address = "Web IDE" -- 1165
									else -- 1165
										address = url -- 1165
									end -- 1165
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1166
								else -- 1168
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1168
								end -- 1164
							end) -- 1163
						end) -- 1162
					end -- 1161
				else -- 1170
					if hovered then -- 1170
						return BeginTooltip(function() -- 1171
							return PushTextWrapPos(280, function() -- 1172
								local url -- 1173
								if webStatus ~= nil then -- 1173
									url = webStatus.url -- 1173
								end -- 1173
								if url then -- 1173
									local address -- 1174
									if showURL then -- 1174
										address = "Web IDE" -- 1174
									else -- 1174
										address = url -- 1174
									end -- 1174
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1175
								else -- 1177
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1177
								end -- 1173
							end) -- 1172
						end) -- 1171
					end -- 1170
				end -- 1157
			end -- 1142
		end) -- 1121
	end -- 1112
	if not isInEntry then -- 1179
		SetNextWindowSize(Vec2(50, 50)) -- 1180
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1181
		PushStyleColor("WindowBg", transparant, function() -- 1182
			return Begin("Show", displayWindowFlags, function() -- 1182
				if width >= 370 then -- 1183
					local changed -- 1184
					changed, showFooter = Checkbox("##dev", showFooter) -- 1184
					if changed then -- 1184
						config.showFooter = showFooter -- 1185
					end -- 1184
				end -- 1183
			end) -- 1182
		end) -- 1182
	end -- 1179
	if isInEntry or showFooter then -- 1187
		if showStats then -- 1188
			PushStyleVar("WindowRounding", 0, function() -- 1189
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1190
				SetNextWindowSize(Vec2(0, height - 50)) -- 1191
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1192
				config.showStats = showStats -- 1193
			end) -- 1189
		end -- 1188
		if showConsole then -- 1194
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1195
			return PushStyleVar("WindowRounding", 6, function() -- 1196
				return ShowConsole() -- 1197
			end) -- 1196
		end -- 1194
	end -- 1187
end) -- 1001
local MaxWidth <const> = 960 -- 1199
local toolOpen = false -- 1201
local filterText = nil -- 1202
local anyEntryMatched = false -- 1203
local match -- 1204
match = function(name) -- 1204
	local res = not filterText or name:lower():match(filterText) -- 1205
	if res then -- 1206
		anyEntryMatched = true -- 1206
	end -- 1206
	return res -- 1207
end -- 1204
local sep -- 1209
sep = function() -- 1209
	return SeparatorText("") -- 1209
end -- 1209
local thinSep -- 1210
thinSep = function() -- 1210
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1210
end -- 1210
entryWindow = threadLoop(function() -- 1212
	if App.fpsLimited ~= config.fpsLimited then -- 1213
		config.fpsLimited = App.fpsLimited -- 1214
	end -- 1213
	if App.targetFPS ~= config.targetFPS then -- 1215
		config.targetFPS = App.targetFPS -- 1216
	end -- 1215
	if View.vsync ~= config.vsync then -- 1217
		config.vsync = View.vsync -- 1218
	end -- 1217
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1219
		config.fixedFPS = Director.scheduler.fixedFPS -- 1220
	end -- 1219
	if Director.profilerSending ~= config.webProfiler then -- 1221
		config.webProfiler = Director.profilerSending -- 1222
	end -- 1221
	if urlClicked then -- 1223
		local _, result = coroutine.resume(urlClicked) -- 1224
		if result then -- 1225
			coroutine.close(urlClicked) -- 1226
			urlClicked = nil -- 1227
		end -- 1225
	end -- 1223
	if not showEntry then -- 1228
		return -- 1228
	end -- 1228
	if not isInEntry then -- 1229
		return -- 1229
	end -- 1229
	local zh = useChinese -- 1230
	local themeColor = App.themeColor -- 1231
	if HttpServer.wsConnectionCount > 0 then -- 1232
		local width, height -- 1233
		do -- 1233
			local _obj_0 = App.visualSize -- 1233
			width, height = _obj_0.width, _obj_0.height -- 1233
		end -- 1233
		SetNextWindowBgAlpha(0.5) -- 1234
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1235
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1236
			Separator() -- 1237
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1238
			if iconTex then -- 1239
				Image(icon, Vec2(24, 24)) -- 1240
				SameLine() -- 1241
			end -- 1239
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1242
			TextColored(descColor, slogon) -- 1243
			return Separator() -- 1244
		end) -- 1236
		return -- 1245
	end -- 1232
	local fullWidth, height -- 1247
	do -- 1247
		local _obj_0 = App.visualSize -- 1247
		fullWidth, height = _obj_0.width, _obj_0.height -- 1247
	end -- 1247
	local width = math.min(MaxWidth, fullWidth) -- 1248
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1249
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1250
	SetNextWindowPos(Vec2.zero) -- 1251
	SetNextWindowBgAlpha(0) -- 1252
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1253
	do -- 1254
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1255
			return Begin("Dora Dev", windowFlags, function() -- 1256
				Dummy(Vec2(fullWidth - 20, 0)) -- 1257
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1258
				if fullWidth >= 400 then -- 1259
					SameLine() -- 1260
					Dummy(Vec2(fullWidth - 400, 0)) -- 1261
					SameLine() -- 1262
					SetNextItemWidth(zh and -95 or -140) -- 1263
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1264
						"AutoSelectAll" -- 1264
					}) then -- 1264
						config.filter = filterBuf.text -- 1265
					end -- 1264
					SameLine() -- 1266
					if Button(zh and '下载' or 'Download') then -- 1267
						allClear() -- 1268
						enterDemoEntry({ -- 1270
							entryName = "ResourceDownloader", -- 1270
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1271
						}) -- 1269
					end -- 1267
				end -- 1259
				return Separator() -- 1272
			end) -- 1256
		end) -- 1255
	end -- 1254
	anyEntryMatched = false -- 1274
	SetNextWindowPos(Vec2(0, 50)) -- 1275
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1276
	do -- 1277
		return PushStyleColor("WindowBg", transparant, function() -- 1278
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1279
				return PushStyleVar("Alpha", 1, function() -- 1280
					return Begin("Content", windowFlags, function() -- 1281
						local DemoViewWidth <const> = 220 -- 1282
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1283
						if filterText then -- 1284
							filterText = filterText:lower() -- 1284
						end -- 1284
						if #gamesInDev > 0 then -- 1285
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1286
							Columns(columns, false) -- 1287
							local realViewWidth = GetColumnWidth() - 50 -- 1288
							for _index_0 = 1, #gamesInDev do -- 1289
								local game = gamesInDev[_index_0] -- 1289
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1290
								local displayName -- 1299
								if repo then -- 1299
									if zh then -- 1300
										displayName = repo.title.zh -- 1300
									else -- 1300
										displayName = repo.title.en -- 1300
									end -- 1300
								end -- 1299
								if displayName == nil then -- 1301
									displayName = gameName -- 1301
								end -- 1301
								if match(displayName) then -- 1302
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1303
									SameLine() -- 1304
									TextWrapped(displayName) -- 1305
									if columns > 1 then -- 1306
										if bannerFile then -- 1307
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1308
											local displayWidth <const> = realViewWidth -- 1309
											texHeight = displayWidth * texHeight / texWidth -- 1310
											texWidth = displayWidth -- 1311
											Dummy(Vec2.zero) -- 1312
											SameLine() -- 1313
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1314
										end -- 1307
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1315
											enterDemoEntry(game) -- 1316
										end -- 1315
									else -- 1318
										if bannerFile then -- 1318
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1319
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1320
											local sizing = 0.8 -- 1321
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1322
											texWidth = displayWidth * sizing -- 1323
											if texWidth > 500 then -- 1324
												sizing = 0.6 -- 1325
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1326
												texWidth = displayWidth * sizing -- 1327
											end -- 1324
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1328
											Dummy(Vec2(padding, 0)) -- 1329
											SameLine() -- 1330
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1331
										end -- 1318
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1332
											enterDemoEntry(game) -- 1333
										end -- 1332
									end -- 1306
									if #tests == 0 and #examples == 0 then -- 1334
										thinSep() -- 1335
									end -- 1334
									NextColumn() -- 1336
								end -- 1302
								local showSep = false -- 1337
								if #examples > 0 then -- 1338
									local showExample = false -- 1339
									for _index_1 = 1, #examples do -- 1340
										local _des_0 = examples[_index_1] -- 1340
										local entryName = _des_0.entryName -- 1340
										if match(entryName) then -- 1341
											showExample = true -- 1341
											break -- 1341
										end -- 1341
									end -- 1340
									if showExample then -- 1342
										showSep = true -- 1343
										Columns(1, false) -- 1344
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1345
										SameLine() -- 1346
										local opened -- 1347
										if (filterText ~= nil) then -- 1347
											opened = showExample -- 1347
										else -- 1347
											opened = false -- 1347
										end -- 1347
										if game.exampleOpen == nil then -- 1348
											game.exampleOpen = opened -- 1348
										end -- 1348
										SetNextItemOpen(game.exampleOpen) -- 1349
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1350
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1351
												Columns(maxColumns, false) -- 1352
												for _index_1 = 1, #examples do -- 1353
													local example = examples[_index_1] -- 1353
													local entryName = example.entryName -- 1354
													if not match(entryName) then -- 1355
														goto _continue_0 -- 1355
													end -- 1355
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1356
														if Button(entryName, Vec2(-1, 40)) then -- 1357
															enterDemoEntry(example) -- 1358
														end -- 1357
														return NextColumn() -- 1359
													end) -- 1356
													opened = true -- 1360
													::_continue_0:: -- 1354
												end -- 1353
											end) -- 1351
										end) -- 1350
										game.exampleOpen = opened -- 1361
									end -- 1342
								end -- 1338
								if #tests > 0 then -- 1362
									local showTest = false -- 1363
									for _index_1 = 1, #tests do -- 1364
										local _des_0 = tests[_index_1] -- 1364
										local entryName = _des_0.entryName -- 1364
										if match(entryName) then -- 1365
											showTest = true -- 1365
											break -- 1365
										end -- 1365
									end -- 1364
									if showTest then -- 1366
										showSep = true -- 1367
										Columns(1, false) -- 1368
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1369
										SameLine() -- 1370
										local opened -- 1371
										if (filterText ~= nil) then -- 1371
											opened = showTest -- 1371
										else -- 1371
											opened = false -- 1371
										end -- 1371
										if game.testOpen == nil then -- 1372
											game.testOpen = opened -- 1372
										end -- 1372
										SetNextItemOpen(game.testOpen) -- 1373
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1374
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1375
												Columns(maxColumns, false) -- 1376
												for _index_1 = 1, #tests do -- 1377
													local test = tests[_index_1] -- 1377
													local entryName = test.entryName -- 1378
													if not match(entryName) then -- 1379
														goto _continue_0 -- 1379
													end -- 1379
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1380
														if Button(entryName, Vec2(-1, 40)) then -- 1381
															enterDemoEntry(test) -- 1382
														end -- 1381
														return NextColumn() -- 1383
													end) -- 1380
													opened = true -- 1384
													::_continue_0:: -- 1378
												end -- 1377
											end) -- 1375
										end) -- 1374
										game.testOpen = opened -- 1385
									end -- 1366
								end -- 1362
								if showSep then -- 1386
									Columns(1, false) -- 1387
									thinSep() -- 1388
									Columns(columns, false) -- 1389
								end -- 1386
							end -- 1289
						end -- 1285
						if #doraTools > 0 then -- 1390
							local showTool = false -- 1391
							for _index_0 = 1, #doraTools do -- 1392
								local _des_0 = doraTools[_index_0] -- 1392
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1392
								local displayName -- 1393
								if repo then -- 1393
									if zh then -- 1394
										displayName = repo.title.zh -- 1394
									else -- 1394
										displayName = repo.title.en -- 1394
									end -- 1394
								end -- 1393
								if displayName == nil then -- 1395
									displayName = entryName -- 1395
								end -- 1395
								if match(displayName) then -- 1396
									showTool = true -- 1396
									break -- 1396
								end -- 1396
							end -- 1392
							if not showTool then -- 1397
								goto endEntry -- 1397
							end -- 1397
							Columns(1, false) -- 1398
							TextColored(themeColor, "Dora SSR:") -- 1399
							SameLine() -- 1400
							Text(zh and "开发支持" or "Development Support") -- 1401
							Separator() -- 1402
							if #doraTools > 0 then -- 1403
								local opened -- 1404
								if (filterText ~= nil) then -- 1404
									opened = showTool -- 1404
								else -- 1404
									opened = false -- 1404
								end -- 1404
								SetNextItemOpen(toolOpen) -- 1405
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1406
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1407
										Columns(maxColumns, false) -- 1408
										for _index_0 = 1, #doraTools do -- 1409
											local tool = doraTools[_index_0] -- 1409
											local entryName, repo = tool.entryName, tool.repo -- 1410
											local displayName -- 1411
											if repo then -- 1411
												if zh then -- 1412
													displayName = repo.title.zh -- 1412
												else -- 1412
													displayName = repo.title.en -- 1412
												end -- 1412
											end -- 1411
											if displayName == nil then -- 1413
												displayName = entryName -- 1413
											end -- 1413
											if not match(displayName) then -- 1414
												goto _continue_0 -- 1414
											end -- 1414
											if Button(displayName, Vec2(-1, 40)) then -- 1415
												enterDemoEntry(tool) -- 1416
											end -- 1415
											NextColumn() -- 1417
											::_continue_0:: -- 1410
										end -- 1409
										Columns(1, false) -- 1418
										opened = true -- 1419
									end) -- 1407
								end) -- 1406
								toolOpen = opened -- 1420
							end -- 1403
						end -- 1390
						::endEntry:: -- 1421
						if not anyEntryMatched then -- 1422
							SetNextWindowBgAlpha(0) -- 1423
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1424
							Begin("Entries Not Found", displayWindowFlags, function() -- 1425
								Separator() -- 1426
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1427
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1428
								return Separator() -- 1429
							end) -- 1425
						end -- 1422
						Columns(1, false) -- 1430
						Dummy(Vec2(100, 80)) -- 1431
						return ScrollWhenDraggingOnVoid() -- 1432
					end) -- 1281
				end) -- 1280
			end) -- 1279
		end) -- 1278
	end -- 1277
end) -- 1212
webStatus = oldRequire("Script.Dev.WebServer") -- 1435
return _module_0 -- 1
