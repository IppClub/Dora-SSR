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
local Controller <const> = Controller -- 11
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
local rawset <const> = rawset -- 11
local getmetatable <const> = getmetatable -- 11
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
if App.platform == "Emscripten" then -- 50
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 50
end -- 50
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 50
config:load() -- 85
if not (config.writablePath ~= nil) then -- 87
	config.writablePath = Content.appPath -- 88
end -- 87
if not (config.webIDEConnected ~= nil) then -- 90
	config.webIDEConnected = false -- 91
end -- 90
if (config.fpsLimited ~= nil) then -- 93
	App.fpsLimited = config.fpsLimited -- 94
else -- 96
	config.fpsLimited = App.fpsLimited -- 96
end -- 93
if (config.targetFPS ~= nil) then -- 98
	App.targetFPS = math.floor(config.targetFPS) -- 99
else -- 101
	config.targetFPS = App.targetFPS -- 101
end -- 98
if (config.vsync ~= nil) then -- 103
	View.vsync = config.vsync -- 104
else -- 106
	config.vsync = View.vsync -- 106
end -- 103
if (config.fixedFPS ~= nil) then -- 108
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 109
else -- 111
	config.fixedFPS = Director.scheduler.fixedFPS -- 111
end -- 108
if not (config.showPreview ~= nil) then -- 113
	config.showPreview = true -- 114
end -- 113
if not (config.mobileFeed ~= nil) then -- 116
	local _val_0 = App.platform -- 117
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 117
end -- 116
if not (config.webIDETourCompleted ~= nil) then -- 119
	config.webIDETourCompleted = false -- 120
end -- 119
if not (config.authRequired ~= nil) then -- 122
	local _val_0 = App.platform -- 123
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 123
end -- 122
HttpServer.authRequired = config.authRequired -- 124
local showEntry = true -- 126
isDesktop = false -- 128
if (function() -- 129
	local _val_0 = App.platform -- 129
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 129
end)() then -- 129
	isDesktop = true -- 130
	if config.fullScreen then -- 131
		App.fullScreen = true -- 132
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 133
		local size = Size(config.winWidth, config.winHeight) -- 134
		if App.winSize ~= size then -- 135
			App.winSize = size -- 136
		end -- 135
		local winX, winY -- 137
		do -- 137
			local _obj_0 = App.winPosition -- 137
			winX, winY = _obj_0.x, _obj_0.y -- 137
		end -- 137
		if (config.winX ~= nil) then -- 138
			winX = config.winX -- 139
		else -- 141
			config.winX = -1 -- 141
		end -- 138
		if (config.winY ~= nil) then -- 142
			winY = config.winY -- 143
		else -- 145
			config.winY = -1 -- 145
		end -- 142
		App.winPosition = Vec2(winX, winY) -- 146
	end -- 131
	if (config.alwaysOnTop ~= nil) then -- 147
		App.alwaysOnTop = config.alwaysOnTop -- 148
	else -- 150
		config.alwaysOnTop = false -- 150
	end -- 147
	if (config.virtualGamepadEnabled ~= nil) then -- 151
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 152
	else -- 154
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 154
	end -- 151
end -- 129
if (config.themeColor ~= nil) then -- 156
	App.themeColor = Color(config.themeColor) -- 157
else -- 159
	config.themeColor = App.themeColor:toARGB() -- 159
end -- 156
if not (config.locale ~= nil) then -- 161
	config.locale = App.locale -- 162
end -- 161
local showStats = false -- 164
if (config.showStats ~= nil) then -- 165
	showStats = config.showStats -- 166
else -- 168
	config.showStats = showStats -- 168
end -- 165
local showConsole = false -- 170
if (config.showConsole ~= nil) then -- 171
	showConsole = config.showConsole -- 172
else -- 174
	config.showConsole = showConsole -- 174
end -- 171
local showFooter = true -- 176
if (config.showFooter ~= nil) then -- 177
	showFooter = config.showFooter -- 178
else -- 180
	config.showFooter = showFooter -- 180
end -- 177
local setFooterVisible -- 182
setFooterVisible = function(visible) -- 182
	if visible == nil then -- 182
		visible = true -- 182
	end -- 182
	showFooter = visible -- 183
	config.showFooter = showFooter -- 184
end -- 182
_module_0["setFooterVisible"] = setFooterVisible -- 182
local filterBuf = Buffer(20) -- 186
if (config.filter ~= nil) then -- 187
	filterBuf.text = config.filter -- 188
else -- 190
	config.filter = "" -- 190
end -- 187
local engineDev = false -- 192
if (config.engineDev ~= nil) then -- 193
	engineDev = config.engineDev -- 194
else -- 196
	config.engineDev = engineDev -- 196
end -- 193
if (config.webProfiler ~= nil) then -- 198
	Director.profilerSending = config.webProfiler -- 199
else -- 201
	config.webProfiler = true -- 201
	Director.profilerSending = true -- 202
end -- 198
if not (config.drawerWidth ~= nil) then -- 204
	config.drawerWidth = 200 -- 205
end -- 204
_module_0.getConfig = function() -- 207
	return config -- 207
end -- 207
_module_0.getEngineDev = function() -- 208
	if not App.debugging then -- 209
		return false -- 209
	end -- 209
	return config.engineDev -- 210
end -- 208
local _anon_func_0 = function() -- 215
	local _val_0 = App.platform -- 215
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 215
end -- 215
_module_0.connectWebIDE = function() -- 212
	if not config.webIDEConnected then -- 213
		config.webIDEConnected = true -- 214
		if _anon_func_0() then -- 215
			local ratio = App.winSize.width / App.visualSize.width -- 216
			App.winSize = Size(640 * ratio, 480 * ratio) -- 217
		end -- 215
	end -- 213
end -- 212
local updateCheck -- 219
updateCheck = function() -- 219
	return thread(function() -- 219
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 220
		if res then -- 220
			local data = json.decode(res) -- 221
			if data then -- 221
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 222
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 223
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 224
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 225
				if na < a then -- 226
					goto not_new_version -- 227
				end -- 226
				if na == a then -- 228
					if nb < b then -- 229
						goto not_new_version -- 230
					end -- 229
					if nb == b then -- 231
						if nc < c then -- 232
							goto not_new_version -- 233
						end -- 232
						if nc == c then -- 234
							goto not_new_version -- 235
						end -- 234
					end -- 231
				end -- 228
				config.updateNotification = true -- 236
				::not_new_version:: -- 237
				config.lastUpdateCheck = os.time() -- 238
			end -- 221
		end -- 220
	end) -- 219
end -- 219
if (config.lastUpdateCheck ~= nil) then -- 240
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 241
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 242
		updateCheck() -- 243
	end -- 242
else -- 245
	updateCheck() -- 245
end -- 240
local Set, Struct, LintYueGlobals, GSplit -- 247
do -- 247
	local _obj_0 = require("Utils") -- 247
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 247
end -- 247
local yueext = yue.options.extension -- 248
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 250
local building = false -- 252
local getAllFiles -- 254
getAllFiles = function(path, exts, recursive) -- 254
	if recursive == nil then -- 254
		recursive = true -- 254
	end -- 254
	local filters = Set(exts) -- 255
	local files -- 256
	if recursive then -- 256
		files = Content:getAllFiles(path) -- 257
	else -- 259
		files = Content:getFiles(path) -- 259
	end -- 256
	local _accum_0 = { } -- 260
	local _len_0 = 1 -- 260
	for _index_0 = 1, #files do -- 260
		local file = files[_index_0] -- 260
		if not filters[Path:getExt(file)] then -- 261
			goto _continue_0 -- 261
		end -- 261
		_accum_0[_len_0] = file -- 262
		_len_0 = _len_0 + 1 -- 261
		::_continue_0:: -- 261
	end -- 260
	return _accum_0 -- 260
end -- 254
_module_0["getAllFiles"] = getAllFiles -- 254
local getFileEntries -- 264
getFileEntries = function(path, recursive, excludeFiles) -- 264
	if recursive == nil then -- 264
		recursive = true -- 264
	end -- 264
	if excludeFiles == nil then -- 264
		excludeFiles = nil -- 264
	end -- 264
	local entries = { } -- 265
	local excludes -- 266
	if excludeFiles then -- 266
		excludes = Set(excludeFiles) -- 267
	end -- 266
	local _list_0 = getAllFiles(path, { -- 268
		"lua", -- 268
		"xml", -- 268
		yueext, -- 268
		"tl" -- 268
	}, recursive) -- 268
	for _index_0 = 1, #_list_0 do -- 268
		local file = _list_0[_index_0] -- 268
		local entryName = Path:getName(file) -- 269
		if excludes and excludes[entryName] then -- 270
			goto _continue_0 -- 271
		end -- 270
		local fileName = Path:replaceExt(file, "") -- 272
		fileName = Path(path, fileName) -- 273
		local entryAdded -- 274
		for _index_1 = 1, #entries do -- 274
			local _des_0 = entries[_index_1] -- 274
			local ename, efile = _des_0.entryName, _des_0.fileName -- 274
			if entryName == ename and efile == fileName then -- 275
				entryAdded = true -- 275
				break -- 275
			end -- 275
		end -- 274
		if entryAdded then -- 276
			goto _continue_0 -- 276
		end -- 276
		local entry = { -- 277
			entryName = entryName, -- 277
			fileName = fileName -- 277
		} -- 277
		entries[#entries + 1] = entry -- 278
		::_continue_0:: -- 269
	end -- 268
	table.sort(entries, function(a, b) -- 279
		return a.entryName < b.entryName -- 279
	end) -- 279
	return entries -- 280
end -- 264
local allEntries = { -- 282
	dirty = { }, -- 282
	hasDirty = false, -- 282
	runId = 0 -- 282
} -- 282
allEntries.scanDir = function(path, dir, noPreview) -- 284
	if noPreview == nil then -- 284
		noPreview = false -- 284
	end -- 284
	local entries = { } -- 285
	if not dir:match("^%.") then -- 286
		local _list_0 = getAllFiles(Path(path, dir), { -- 287
			"lua", -- 287
			"xml", -- 287
			yueext, -- 287
			"tl", -- 287
			"wasm" -- 287
		}) -- 287
		for _index_0 = 1, #_list_0 do -- 287
			local file = _list_0[_index_0] -- 287
			if "init" == Path:getName(file):lower() then -- 288
				local fileName = Path:replaceExt(file, "") -- 289
				fileName = Path(path, dir, fileName) -- 290
				local projectPath = Path:getPath(fileName) -- 291
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 292
				local repo = nil -- 293
				if Content:exist(repoFile) then -- 294
					local str = Content:load(repoFile) -- 295
					if str then -- 295
						repo = json.decode(str) -- 296
					end -- 295
				end -- 294
				local entryName = Path:getName(projectPath) -- 297
				local entryAdded -- 298
				for _index_1 = 1, #entries do -- 298
					local _des_0 = entries[_index_1] -- 298
					local ename, efile = _des_0.entryName, _des_0.fileName -- 298
					if entryName == ename and efile == fileName then -- 299
						entryAdded = true -- 299
						break -- 299
					end -- 299
				end -- 298
				if entryAdded then -- 300
					goto _continue_0 -- 300
				end -- 300
				local examples = { } -- 301
				local tests = { } -- 302
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 303
				if Content:exist(examplePath) then -- 304
					local _list_1 = getFileEntries(examplePath) -- 305
					for _index_1 = 1, #_list_1 do -- 305
						local _des_0 = _list_1[_index_1] -- 305
						local name, ePath = _des_0.entryName, _des_0.fileName -- 305
						local entry = { -- 307
							entryName = name, -- 307
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 308
							workDir = projectPath -- 309
						} -- 306
						examples[#examples + 1] = entry -- 311
					end -- 305
				end -- 304
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 312
				if Content:exist(testPath) then -- 313
					local _list_1 = getFileEntries(testPath) -- 314
					for _index_1 = 1, #_list_1 do -- 314
						local _des_0 = _list_1[_index_1] -- 314
						local name, tPath = _des_0.entryName, _des_0.fileName -- 314
						local entry = { -- 316
							entryName = name, -- 316
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 317
							workDir = projectPath -- 318
						} -- 315
						tests[#tests + 1] = entry -- 320
					end -- 314
				end -- 313
				local entry = { -- 321
					entryName = entryName, -- 321
					fileName = fileName, -- 321
					projectPath = projectPath, -- 321
					examples = examples, -- 321
					tests = tests, -- 321
					repo = repo -- 321
				} -- 321
				local bannerFile -- 322
				do -- 322
					local _val_0 -- 322
					repeat -- 322
						if noPreview then -- 323
							_val_0 = nil -- 323
							break -- 323
						end -- 323
						if not config.showPreview then -- 324
							_val_0 = nil -- 324
							break -- 324
						end -- 324
						local f = Path(projectPath, ".dora", "banner.jpg") -- 325
						if Content:exist(f) then -- 326
							_val_0 = f -- 326
							break -- 326
						end -- 326
						f = Path(projectPath, ".dora", "banner.png") -- 327
						if Content:exist(f) then -- 328
							_val_0 = f -- 328
							break -- 328
						end -- 328
						f = Path(projectPath, "Image", "banner.jpg") -- 329
						if Content:exist(f) then -- 330
							_val_0 = f -- 330
							break -- 330
						end -- 330
						f = Path(projectPath, "Image", "banner.png") -- 331
						if Content:exist(f) then -- 332
							_val_0 = f -- 332
							break -- 332
						end -- 332
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 333
						if Content:exist(f) then -- 334
							_val_0 = f -- 334
							break -- 334
						end -- 334
					until true -- 322
					bannerFile = _val_0 -- 322
				end -- 322
				if bannerFile then -- 336
					entry.bannerFile = bannerFile -- 339
					thread(function() -- 340
						if Cache:loadAsync(bannerFile) then -- 341
							local bannerTex = Texture2D(bannerFile) -- 342
							if bannerTex then -- 342
								entry.bannerTex = bannerTex -- 343
							end -- 342
						end -- 341
					end) -- 340
				end -- 336
				entries[#entries + 1] = entry -- 344
			end -- 288
			::_continue_0:: -- 288
		end -- 287
	end -- 286
	return entries -- 345
end -- 284
local getProjectEntries -- 347
getProjectEntries = function(path, noPreview) -- 347
	if noPreview == nil then -- 347
		noPreview = false -- 347
	end -- 347
	local entries = { } -- 348
	local _list_0 = Content:getDirs(path) -- 349
	for _index_0 = 1, #_list_0 do -- 349
		local dir = _list_0[_index_0] -- 349
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 350
		for _index_1 = 1, #_list_1 do -- 350
			local entry = _list_1[_index_1] -- 350
			entries[#entries + 1] = entry -- 351
		end -- 350
	end -- 349
	table.sort(entries, function(a, b) -- 352
		return a.entryName < b.entryName -- 352
	end) -- 352
	return entries -- 353
end -- 347
_module_0["getProjectEntries"] = getProjectEntries -- 347
local gamesInDev -- 355
local doraTools -- 356
local isToolEntry -- 358
isToolEntry = function(entry) -- 358
	do -- 359
		local _type_0 = type(entry) -- 359
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 359
		if _tab_0 then -- 359
			local categories -- 359
			do -- 359
				local _obj_0 = entry.repo -- 359
				local _type_1 = type(_obj_0) -- 359
				if "table" == _type_1 or "userdata" == _type_1 then -- 359
					categories = _obj_0.categories -- 359
				end -- 359
			end -- 359
			if categories ~= nil then -- 359
				for _index_0 = 1, #categories do -- 360
					local category = categories[_index_0] -- 360
					if "string" == type(category) and category:lower() == "tool" then -- 361
						return true -- 362
					end -- 361
				end -- 360
			end -- 359
		end -- 359
	end -- 359
	return false -- 358
end -- 358
local getEntryTitle -- 364
getEntryTitle = function(entry) -- 364
	local title -- 365
	do -- 365
		local repo = entry.repo -- 365
		if repo then -- 365
			if repo.title and "table" == type(repo.title) then -- 366
				if useChinese then -- 367
					title = repo.title.zh -- 367
				else -- 367
					title = repo.title.en -- 367
				end -- 367
			end -- 366
		end -- 365
	end -- 365
	if title ~= nil then -- 368
		return title -- 368
	else -- 368
		return entry.entryName -- 368
	end -- 368
end -- 364
allEntries.rebuildEntries = function() -- 370
	gamesInDev = { } -- 371
	do -- 372
		local _accum_0 = { } -- 372
		local _len_0 = 1 -- 372
		local _list_0 = allEntries.builtinTools -- 372
		for _index_0 = 1, #_list_0 do -- 372
			local tool = _list_0[_index_0] -- 372
			_accum_0[_len_0] = tool -- 372
			_len_0 = _len_0 + 1 -- 372
		end -- 372
		doraTools = _accum_0 -- 372
	end -- 372
	local _list_0 = allEntries.projectEntries -- 373
	for _index_0 = 1, #_list_0 do -- 373
		local entry = _list_0[_index_0] -- 373
		if isToolEntry(entry) then -- 374
			entry.kind = "tool" -- 375
			doraTools[#doraTools + 1] = entry -- 376
		else -- 378
			entry.kind = "game" -- 378
			gamesInDev[#gamesInDev + 1] = entry -- 379
		end -- 374
	end -- 373
	for i = #allEntries, 1, -1 do -- 380
		allEntries[i] = nil -- 381
	end -- 380
	for _index_0 = 1, #gamesInDev do -- 382
		local game = gamesInDev[_index_0] -- 382
		allEntries[#allEntries + 1] = game -- 383
		local examples, tests = game.examples, game.tests -- 384
		for _index_1 = 1, #examples do -- 385
			local example = examples[_index_1] -- 385
			allEntries[#allEntries + 1] = example -- 386
		end -- 385
		for _index_1 = 1, #tests do -- 387
			local test = tests[_index_1] -- 387
			allEntries[#allEntries + 1] = test -- 388
		end -- 387
	end -- 382
end -- 370
local updateEntries -- 390
updateEntries = function() -- 390
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 391
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 392
	local _list_0 = allEntries.builtinTools -- 393
	for _index_0 = 1, #_list_0 do -- 393
		local tool = _list_0[_index_0] -- 393
		tool.kind = "tool" -- 394
		tool.builtin = true -- 395
	end -- 393
	return allEntries.rebuildEntries() -- 396
end -- 390
allEntries.refreshDirtyProjects = function() -- 398
	if not allEntries.hasDirty then -- 399
		return -- 399
	end -- 399
	local dirty = allEntries.dirty -- 400
	allEntries.dirty = { } -- 401
	allEntries.hasDirty = false -- 402
	for projectPath in pairs(dirty) do -- 403
		do -- 404
			local _accum_0 = { } -- 404
			local _len_0 = 1 -- 404
			local _list_0 = allEntries.projectEntries -- 404
			for _index_0 = 1, #_list_0 do -- 404
				local entry = _list_0[_index_0] -- 404
				if entry.projectPath ~= projectPath then -- 404
					_accum_0[_len_0] = entry -- 404
					_len_0 = _len_0 + 1 -- 404
				end -- 404
			end -- 404
			allEntries.projectEntries = _accum_0 -- 404
		end -- 404
		local parentPath = Path:getPath(projectPath) -- 405
		local dir = Path:getFilename(projectPath) -- 406
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 407
		for _index_0 = 1, #_list_0 do -- 407
			local entry = _list_0[_index_0] -- 407
			if entry.projectPath == projectPath then -- 408
				do -- 409
					local _obj_0 = allEntries.projectEntries -- 409
					_obj_0[#_obj_0 + 1] = entry -- 409
				end -- 409
				break -- 410
			end -- 408
		end -- 407
	end -- 403
	table.sort(allEntries.projectEntries, function(a, b) -- 411
		return a.entryName < b.entryName -- 411
	end) -- 411
	return allEntries.rebuildEntries() -- 412
end -- 398
updateEntries() -- 414
local getLaunchEntries -- 416
getLaunchEntries = function(refresh) -- 416
	if refresh == nil then -- 416
		refresh = false -- 416
	end -- 416
	if refresh then -- 417
		updateEntries() -- 417
	end -- 417
	local toInfo -- 418
	toInfo = function(entry, kind) -- 418
		local file = entry.fileName -- 419
		local asProj = not entry.builtin -- 420
		return { -- 422
			name = getEntryTitle(entry), -- 422
			file = file, -- 423
			kind = kind, -- 424
			asProj = asProj -- 425
		} -- 421
	end -- 418
	local games -- 427
	do -- 427
		local _accum_0 = { } -- 427
		local _len_0 = 1 -- 427
		for _index_0 = 1, #gamesInDev do -- 427
			local game = gamesInDev[_index_0] -- 427
			_accum_0[_len_0] = toInfo(game, "game") -- 427
			_len_0 = _len_0 + 1 -- 427
		end -- 427
		games = _accum_0 -- 427
	end -- 427
	local tools -- 428
	do -- 428
		local _accum_0 = { } -- 428
		local _len_0 = 1 -- 428
		for _index_0 = 1, #doraTools do -- 428
			local tool = doraTools[_index_0] -- 428
			_accum_0[_len_0] = toInfo(tool, "tool") -- 428
			_len_0 = _len_0 + 1 -- 428
		end -- 428
		tools = _accum_0 -- 428
	end -- 428
	return { -- 429
		games = games, -- 429
		tools = tools -- 429
	} -- 429
end -- 416
_module_0["getLaunchEntries"] = getLaunchEntries -- 416
local _anon_func_1 = function(entry, useChinese) -- 446
	local _obj_0 = entry.repo -- 446
	if _obj_0 ~= nil then -- 446
		local _obj_1 = _obj_0.description -- 446
		if _obj_1 ~= nil then -- 446
			return _obj_1[useChinese and "zh" or "en"] -- 446
		end -- 446
		return nil -- 446
	end -- 446
	return nil -- 446
end -- 446
local getMobileFeedEntries -- 431
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 431
	if refresh == nil then -- 431
		refresh = false -- 431
	end -- 431
	if dirtyProjectPath == nil then -- 431
		dirtyProjectPath = nil -- 431
	end -- 431
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 432
		allEntries.dirty[dirtyProjectPath] = true -- 433
		allEntries.hasDirty = true -- 434
	end -- 432
	if refresh then -- 435
		allEntries.dirty = { } -- 436
		allEntries.hasDirty = false -- 437
		updateEntries() -- 438
	else -- 440
		allEntries.refreshDirtyProjects() -- 440
	end -- 435
	local items = { } -- 441
	for _index_0 = 1, #gamesInDev do -- 442
		local entry = gamesInDev[_index_0] -- 442
		items[#items + 1] = { -- 444
			id = entry.entryName, -- 444
			title = getEntryTitle(entry), -- 445
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 446
			fileName = entry.fileName, -- 447
			workDir = Path:getPath(entry.fileName), -- 448
			bannerFile = entry.bannerFile, -- 449
			kind = "local" -- 450
		} -- 443
	end -- 442
	return items -- 452
end -- 431
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 431
local doCompile -- 454
doCompile = function(minify) -- 454
	if building then -- 455
		return -- 455
	end -- 455
	building = true -- 456
	local startTime = App.runningTime -- 457
	local luaFiles = { } -- 458
	local yueFiles = { } -- 459
	local xmlFiles = { } -- 460
	local tlFiles = { } -- 461
	local writablePath = Content.writablePath -- 462
	local buildPaths = { -- 464
		{ -- 465
			Content.assetPath, -- 465
			Path(writablePath, ".build"), -- 466
			"" -- 467
		} -- 464
	} -- 463
	for _index_0 = 1, #gamesInDev do -- 470
		local _des_0 = gamesInDev[_index_0] -- 470
		local fileName = _des_0.fileName -- 470
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 471
		buildPaths[#buildPaths + 1] = { -- 473
			Path(writablePath, gamePath), -- 473
			Path(writablePath, ".build", gamePath), -- 474
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 475
			gamePath -- 476
		} -- 472
	end -- 470
	for _index_0 = 1, #buildPaths do -- 477
		local _des_0 = buildPaths[_index_0] -- 477
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 477
		if not Content:exist(inputPath) then -- 478
			goto _continue_0 -- 478
		end -- 478
		local _list_0 = getAllFiles(inputPath, { -- 480
			"lua" -- 480
		}) -- 480
		for _index_1 = 1, #_list_0 do -- 480
			local file = _list_0[_index_1] -- 480
			luaFiles[#luaFiles + 1] = { -- 482
				file, -- 482
				Path(inputPath, file), -- 483
				Path(outputPath, file), -- 484
				gamePath -- 485
			} -- 481
		end -- 480
		local _list_1 = getAllFiles(inputPath, { -- 487
			yueext -- 487
		}) -- 487
		for _index_1 = 1, #_list_1 do -- 487
			local file = _list_1[_index_1] -- 487
			yueFiles[#yueFiles + 1] = { -- 489
				file, -- 489
				Path(inputPath, file), -- 490
				Path(outputPath, Path:replaceExt(file, "lua")), -- 491
				searchPath, -- 492
				gamePath -- 493
			} -- 488
		end -- 487
		local _list_2 = getAllFiles(inputPath, { -- 495
			"xml" -- 495
		}) -- 495
		for _index_1 = 1, #_list_2 do -- 495
			local file = _list_2[_index_1] -- 495
			xmlFiles[#xmlFiles + 1] = { -- 497
				file, -- 497
				Path(inputPath, file), -- 498
				Path(outputPath, Path:replaceExt(file, "lua")), -- 499
				gamePath -- 500
			} -- 496
		end -- 495
		local _list_3 = getAllFiles(inputPath, { -- 502
			"tl" -- 502
		}) -- 502
		for _index_1 = 1, #_list_3 do -- 502
			local file = _list_3[_index_1] -- 502
			if not file:match(".*%.d%.tl$") then -- 503
				tlFiles[#tlFiles + 1] = { -- 505
					file, -- 505
					Path(inputPath, file), -- 506
					Path(outputPath, Path:replaceExt(file, "lua")), -- 507
					searchPath, -- 508
					gamePath -- 509
				} -- 504
			end -- 503
		end -- 502
		::_continue_0:: -- 478
	end -- 477
	local paths -- 511
	do -- 511
		local _tbl_0 = { } -- 511
		local _list_0 = { -- 512
			luaFiles, -- 512
			yueFiles, -- 512
			xmlFiles, -- 512
			tlFiles -- 512
		} -- 512
		for _index_0 = 1, #_list_0 do -- 512
			local files = _list_0[_index_0] -- 512
			for _index_1 = 1, #files do -- 513
				local file = files[_index_1] -- 513
				_tbl_0[Path:getPath(file[3])] = true -- 511
			end -- 511
		end -- 511
		paths = _tbl_0 -- 511
	end -- 511
	for path in pairs(paths) do -- 515
		Content:mkdir(path) -- 515
	end -- 515
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 517
	local fileCount = 0 -- 518
	local errors = { } -- 519
	for _index_0 = 1, #yueFiles do -- 520
		local _des_0 = yueFiles[_index_0] -- 520
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 520
		local filename -- 521
		if gamePath then -- 521
			filename = Path(gamePath, file) -- 521
		else -- 521
			filename = file -- 521
		end -- 521
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 522
			if not codes then -- 523
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 524
				return -- 525
			end -- 523
			local success, result = LintYueGlobals(codes, globals) -- 526
			local yueCodes -- 527
			if not success then -- 528
				yueCodes = Content:load(input) -- 529
				if yueCodes then -- 529
					local CheckTIC80Code -- 530
					do -- 530
						local _obj_0 = require("Utils") -- 530
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 530
					end -- 530
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 531
					if isTIC80 then -- 532
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 533
					end -- 532
				end -- 529
			end -- 528
			if success then -- 534
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 535
			else -- 537
				if yueCodes then -- 537
					local globalErrors = { } -- 538
					for _index_1 = 1, #result do -- 539
						local _des_1 = result[_index_1] -- 539
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 539
						local countLine = 1 -- 540
						local code = "" -- 541
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 542
							if countLine == line then -- 543
								code = lineCode -- 544
								break -- 545
							end -- 543
							countLine = countLine + 1 -- 546
						end -- 542
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 547
					end -- 539
					if #globalErrors > 0 then -- 548
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 548
					end -- 548
				else -- 550
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 550
				end -- 537
				if #errors == 0 then -- 551
					return codes -- 551
				end -- 551
			end -- 534
		end, function(success) -- 522
			if success then -- 552
				print("Yue compiled: " .. tostring(filename)) -- 552
			end -- 552
			fileCount = fileCount + 1 -- 553
		end) -- 522
	end -- 520
	thread(function() -- 555
		for _index_0 = 1, #xmlFiles do -- 556
			local _des_0 = xmlFiles[_index_0] -- 556
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 556
			local filename -- 557
			if gamePath then -- 557
				filename = Path(gamePath, file) -- 557
			else -- 557
				filename = file -- 557
			end -- 557
			local sourceCodes = Content:loadAsync(input) -- 558
			local codes, err = xml.tolua(sourceCodes) -- 559
			if not codes then -- 560
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 561
			else -- 563
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 563
				print("Xml compiled: " .. tostring(filename)) -- 564
			end -- 560
			fileCount = fileCount + 1 -- 565
		end -- 556
	end) -- 555
	thread(function() -- 567
		for _index_0 = 1, #tlFiles do -- 568
			local _des_0 = tlFiles[_index_0] -- 568
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 568
			local filename -- 569
			if gamePath then -- 569
				filename = Path(gamePath, file) -- 569
			else -- 569
				filename = file -- 569
			end -- 569
			local sourceCodes = Content:loadAsync(input) -- 570
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 571
			if not codes then -- 572
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 573
			else -- 575
				Content:saveAsync(output, codes) -- 575
				print("Teal compiled: " .. tostring(filename)) -- 576
			end -- 572
			fileCount = fileCount + 1 -- 577
		end -- 568
	end) -- 567
	return thread(function() -- 579
		wait(function() -- 580
			return fileCount == totalFiles -- 580
		end) -- 580
		if minify then -- 581
			local _list_0 = { -- 582
				yueFiles, -- 582
				xmlFiles, -- 582
				tlFiles -- 582
			} -- 582
			for _index_0 = 1, #_list_0 do -- 582
				local files = _list_0[_index_0] -- 582
				for _index_1 = 1, #files do -- 582
					local file = files[_index_1] -- 582
					local output = Path:replaceExt(file[3], "lua") -- 583
					luaFiles[#luaFiles + 1] = { -- 585
						Path:replaceExt(file[1], "lua"), -- 585
						output, -- 586
						output -- 587
					} -- 584
				end -- 582
			end -- 582
			local FormatMini -- 589
			do -- 589
				local _obj_0 = require("luaminify") -- 589
				FormatMini = _obj_0.FormatMini -- 589
			end -- 589
			for _index_0 = 1, #luaFiles do -- 590
				local _des_0 = luaFiles[_index_0] -- 590
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 590
				if Content:exist(input) then -- 591
					local sourceCodes = Content:loadAsync(input) -- 592
					local res, err = FormatMini(sourceCodes) -- 593
					if res then -- 594
						Content:saveAsync(output, res) -- 595
						print("Minify: " .. tostring(file)) -- 596
					else -- 598
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 598
					end -- 594
				else -- 600
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 600
				end -- 591
			end -- 590
			package.loaded["luaminify.FormatMini"] = nil -- 601
			package.loaded["luaminify.ParseLua"] = nil -- 602
			package.loaded["luaminify.Scope"] = nil -- 603
			package.loaded["luaminify.Util"] = nil -- 604
		end -- 581
		local errorMessage = table.concat(errors, "\n") -- 605
		if errorMessage ~= "" then -- 606
			print(errorMessage) -- 606
		end -- 606
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 607
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 608
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 609
		Content:clearPathCache() -- 610
		teal.clear() -- 611
		yue.clear() -- 612
		building = false -- 613
	end) -- 579
end -- 454
local doClean -- 615
doClean = function() -- 615
	if building then -- 616
		return -- 616
	end -- 616
	local writablePath = Content.writablePath -- 617
	local targetDir = Path(writablePath, ".build") -- 618
	Content:clearPathCache() -- 619
	if Content:remove(targetDir) then -- 620
		return print("Cleaned: " .. tostring(targetDir)) -- 621
	end -- 620
end -- 615
local screenScale = 2.0 -- 623
local scaleContent = false -- 624
local isInEntry = true -- 625
local currentEntry = nil -- 626
local footerWindow = nil -- 628
local entryWindow = nil -- 629
local testingThread = nil -- 630
local mobileMode = config.mobileFeed -- 631
local pendingUIMode = nil -- 632
local feedHost = nil -- 633
local remixHost = nil -- 634
local startMobileUI = nil -- 635
local webControlled = false -- 636
local mobileHosts = { } -- 637
local suspendedMobileHosts = { } -- 638
local trackMobileHost -- 640
trackMobileHost = function(host) -- 640
	do -- 641
		local _accum_0 = { } -- 641
		local _len_0 = 1 -- 641
		for _index_0 = 1, #mobileHosts do -- 641
			local item = mobileHosts[_index_0] -- 641
			if item.parent then -- 641
				_accum_0[_len_0] = item -- 641
				_len_0 = _len_0 + 1 -- 641
			end -- 641
		end -- 641
		mobileHosts = _accum_0 -- 641
	end -- 641
	mobileHosts[#mobileHosts + 1] = host -- 642
	return host -- 643
end -- 640
local clearMobileUI -- 645
clearMobileUI = function() -- 645
	for _index_0 = 1, #mobileHosts do -- 646
		local host = mobileHosts[_index_0] -- 646
		if host.parent then -- 647
			host:removeFromParent(true) -- 647
		end -- 647
	end -- 646
	mobileHosts = { } -- 648
	suspendedMobileHosts = { } -- 649
	feedHost = nil -- 650
	remixHost = nil -- 651
end -- 645
local syncWebIDEControl -- 653
syncWebIDEControl = function() -- 653
	local connected = HttpServer.wsConnectionCount > 0 -- 654
	if connected then -- 655
		pendingUIMode = nil -- 656
		for _index_0 = 1, #mobileHosts do -- 657
			local host = mobileHosts[_index_0] -- 657
			if not host.parent then -- 658
				goto _continue_0 -- 658
			end -- 658
			if not (suspendedMobileHosts[host] ~= nil) then -- 659
				suspendedMobileHosts[host] = host.visible -- 660
				host:emit("SuspendLocalUI") -- 661
			end -- 659
			host.visible = false -- 662
			::_continue_0:: -- 658
		end -- 657
	elseif webControlled then -- 663
		for host, visible in pairs(suspendedMobileHosts) do -- 664
			if host.parent then -- 665
				host.visible = visible -- 666
				host:emit("ResumeLocalUI") -- 667
			end -- 665
		end -- 664
		suspendedMobileHosts = { } -- 668
	end -- 655
	webControlled = connected -- 669
	return connected -- 670
end -- 653
local getUIMode -- 672
getUIMode = function() -- 672
	return mobileMode and "mobile" or "traditional" -- 672
end -- 672
_module_0["getUIMode"] = getUIMode -- 672
local setUIMode -- 673
setUIMode = function(mode) -- 673
	if not (("mobile" == mode or "traditional" == mode)) then -- 674
		return false -- 674
	end -- 674
	if HttpServer.wsConnectionCount > 0 then -- 675
		return false -- 675
	end -- 675
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 676
		return false -- 676
	end -- 676
	local wantsMobile = mode == "mobile" -- 677
	if wantsMobile == mobileMode then -- 678
		return true -- 678
	end -- 678
	if mobileMode then -- 679
		if not (feedHost and feedHost.visible) then -- 680
			return false -- 680
		end -- 680
		feedHost:emit("SwitchUIMode") -- 682
		return pendingUIMode == false -- 683
	end -- 679
	pendingUIMode = true -- 684
	return true -- 685
end -- 673
_module_0["setUIMode"] = setUIMode -- 673
local applyUIMode -- 687
applyUIMode = function(enabled) -- 687
	if HttpServer.wsConnectionCount > 0 then -- 689
		return false -- 689
	end -- 689
	if enabled then -- 690
		local ok, err = pcall(startMobileUI) -- 691
		if not ok then -- 692
			if feedHost then -- 693
				feedHost:removeFromParent(true) -- 693
			end -- 693
			feedHost = nil -- 694
			mobileMode = false -- 695
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 696
			return false -- 697
		end -- 692
	else -- 699
		clearMobileUI() -- 699
		updateEntries() -- 700
	end -- 690
	mobileMode = enabled -- 701
	config.mobileFeed = enabled -- 702
	return true -- 703
end -- 687
local setupEventHandlers = nil -- 705
local allClear -- 707
allClear = function() -- 707
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 709
		clearMobileUI() -- 709
	end -- 709
	local systemNodes = { } -- 712
	local preserveSystemNode -- 713
	preserveSystemNode = function(node) -- 713
		if systemNodes[node] then -- 714
			return -- 714
		end -- 714
		systemNodes[node] = true -- 715
		do -- 716
			local clip = tolua.cast(node, "ClipNode") -- 716
			if clip then -- 716
				if clip.stencil then -- 717
					preserveSystemNode(clip.stencil) -- 717
				end -- 717
			end -- 716
		end -- 716
		return node:eachChild(function(child) -- 718
			preserveSystemNode(child) -- 719
			return false -- 720
		end) -- 718
	end -- 713
	for _index_0 = 1, #Routine do -- 721
		local routine = Routine[_index_0] -- 721
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 723
			goto _continue_0 -- 724
		else -- 726
			Routine:remove(routine) -- 726
		end -- 722
		::_continue_0:: -- 722
	end -- 721
	for _index_0 = 1, #moduleCache do -- 727
		local module = moduleCache[_index_0] -- 727
		package.loaded[module] = nil -- 728
	end -- 727
	moduleCache = { } -- 729
	Director:cleanup() -- 730
	Entity:clear() -- 731
	Platformer.Data:clear() -- 732
	Platformer.UnitAction:clear() -- 733
	Audio:stopAll(0.2) -- 734
	Struct:clear() -- 735
	View.postEffect = nil -- 736
	View.scale = scaleContent and screenScale or 1 -- 737
	Director.clearColor = Color(0xff1a1a1a) -- 738
	teal.clear() -- 739
	yue.clear() -- 740
	preserveSystemNode(Director.systemUI) -- 743
	for _, item in pairs(ubox()) do -- 744
		local node = tolua.cast(item, "Node") -- 745
		if node then -- 745
			if not systemNodes[node] then -- 746
				node:cleanup() -- 746
			end -- 746
		end -- 745
	end -- 744
	collectgarbage() -- 747
	collectgarbage() -- 748
	Wasm:clear() -- 749
	thread(function() -- 750
		sleep() -- 751
		return Cache:removeUnused() -- 752
	end) -- 750
	setupEventHandlers() -- 753
	Content.searchPaths = searchPaths -- 754
	App.idled = true -- 755
end -- 707
_module_0["allClear"] = allClear -- 707
local clearTempFiles -- 757
clearTempFiles = function() -- 757
	local writablePath = Content.writablePath -- 758
	if Content:exist(Path(writablePath, ".upload")) then -- 759
		Content:remove(Path(writablePath, ".upload")) -- 759
	end -- 759
	if Content:exist(Path(writablePath, ".download")) then -- 760
		return Content:remove(Path(writablePath, ".download")) -- 760
	end -- 760
end -- 757
local waitForWebStart = true -- 762
thread(function() -- 763
	sleep(2) -- 764
	waitForWebStart = false -- 765
end) -- 763
local reloadDevEntry -- 767
reloadDevEntry = function() -- 767
	return thread(function() -- 767
		waitForWebStart = true -- 768
		doClean() -- 769
		allClear() -- 770
		_G.require = oldRequire -- 771
		Dora.require = oldRequire -- 772
		package.loaded["Script.Dev.Entry"] = nil -- 773
		package.loaded["Script.Dev.WebServer"] = nil -- 774
		return Director.systemScheduler:schedule(function() -- 775
			Routine:clear() -- 776
			oldRequire("Script.Dev.Entry") -- 777
			return true -- 778
		end) -- 775
	end) -- 767
end -- 767
local setWorkspace -- 780
setWorkspace = function(path) -- 780
	clearTempFiles() -- 781
	Content.writablePath = path -- 782
	config.writablePath = Content.writablePath -- 783
	return thread(function() -- 784
		sleep() -- 785
		return reloadDevEntry() -- 786
	end) -- 784
end -- 780
_module_0["setWorkspace"] = setWorkspace -- 780
local quit = false -- 788
local activeSearchId = 0 -- 790
local handleSearchFiles -- 792
handleSearchFiles = function(payload) -- 792
	if not payload then -- 793
		return -- 793
	end -- 793
	local id = payload.id -- 794
	if id == nil then -- 795
		return -- 795
	end -- 795
	activeSearchId = id -- 796
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 797
	if path == nil then -- 798
		path = "" -- 798
	end -- 798
	if exts == nil then -- 799
		exts = { } -- 799
	end -- 799
	if globs == nil then -- 800
		globs = { } -- 800
	end -- 800
	if extensionLevels == nil then -- 801
		extensionLevels = { } -- 801
	end -- 801
	if pattern == nil then -- 802
		pattern = "" -- 802
	end -- 802
	if pattern == "" then -- 804
		return -- 804
	end -- 804
	local useRegex = payload.useRegex == true -- 805
	local caseSensitive = payload.caseSensitive == true -- 806
	local includeContent = payload.includeContent ~= false -- 807
	local contentWindow = payload.contentWindow or 0 -- 808
	return Director.systemScheduler:schedule(once(function() -- 809
		local stopped = false -- 810
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 811
			if activeSearchId ~= id then -- 812
				stopped = true -- 813
				return true -- 814
			end -- 812
			emit("AppWS", "Send", json.encode({ -- 816
				name = "SearchFilesResult", -- 816
				id = id, -- 816
				result = result -- 816
			})) -- 815
			return false -- 818
		end) -- 811
		return emit("AppWS", "Send", json.encode({ -- 820
			name = "SearchFilesDone", -- 820
			id = id, -- 820
			stopped = stopped -- 820
		})) -- 819
	end)) -- 809
end -- 792
local stop -- 823
stop = function() -- 823
	if isInEntry then -- 824
		return false -- 824
	end -- 824
	allClear() -- 825
	isInEntry = true -- 826
	currentEntry = nil -- 827
	return true -- 828
end -- 823
_module_0["stop"] = stop -- 823
local getCurrentEntryStatus -- 830
getCurrentEntryStatus = function() -- 830
	local entry = currentEntry -- 831
	if not (entry and not isInEntry) then -- 832
		return { -- 832
			success = true, -- 832
			running = false, -- 832
			runId = allEntries.runId -- 832
		} -- 832
	end -- 832
	local status = { -- 834
		success = true, -- 834
		running = true, -- 835
		kind = entry.runKind or "file", -- 836
		runId = allEntries.runId, -- 837
		entryName = entry.entryName, -- 838
		fileName = entry.fileName -- 839
	} -- 833
	if entry.workDir then -- 840
		status.workDir = entry.workDir -- 840
	end -- 840
	if entry.projectRoot then -- 841
		status.projectRoot = entry.projectRoot -- 841
	end -- 841
	return status -- 842
end -- 830
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 830
local _anon_func_2 = function(_with_0) -- 861
	local _val_0 = App.platform -- 861
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 861
end -- 861
setupEventHandlers = function() -- 844
	local _with_0 = Director.postNode -- 845
	_with_0:onAppEvent(function(eventType) -- 846
		if "Quit" == eventType then -- 847
			quit = true -- 848
			allClear() -- 849
			return clearTempFiles() -- 850
		elseif "Shutdown" == eventType then -- 851
			return stop() -- 852
		end -- 846
	end) -- 846
	_with_0:onAppChange(function(settingName) -- 853
		if "Theme" == settingName then -- 854
			config.themeColor = App.themeColor:toARGB() -- 855
		elseif "Locale" == settingName then -- 856
			config.locale = App.locale -- 857
			updateLocale() -- 858
			return teal.clear(true) -- 859
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 860
			if _anon_func_2(_with_0) then -- 861
				if "FullScreen" == settingName then -- 863
					config.fullScreen = App.fullScreen -- 863
				elseif "Position" == settingName then -- 864
					local _obj_0 = App.winPosition -- 864
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 864
				elseif "Size" == settingName then -- 865
					local width, height -- 866
					do -- 866
						local _obj_0 = App.winSize -- 866
						width, height = _obj_0.width, _obj_0.height -- 866
					end -- 866
					config.winWidth = width -- 867
					config.winHeight = height -- 868
				end -- 862
			end -- 861
		end -- 853
	end) -- 853
	_with_0:onAppWS(function(event) -- 869
		if event.type == "Close" then -- 870
			if HttpServer.wsConnectionCount == 0 then -- 871
				updateEntries() -- 872
			end -- 871
			return -- 873
		end -- 870
		if not (event.type == "Receive") then -- 874
			return -- 874
		end -- 874
		local data = json.decode(event.msg) -- 875
		if not data then -- 876
			return -- 876
		end -- 876
		local _exp_0 = data.name -- 877
		if "SearchFiles" == _exp_0 then -- 878
			return handleSearchFiles(data) -- 879
		elseif "SearchFilesStop" == _exp_0 then -- 880
			if data.id == nil or data.id == activeSearchId then -- 881
				activeSearchId = 0 -- 882
			end -- 881
		end -- 877
	end) -- 869
	_with_0:slot("UpdateEntries", function() -- 883
		return updateEntries() -- 883
	end) -- 883
	return _with_0 -- 845
end -- 844
setupEventHandlers() -- 885
clearTempFiles() -- 886
local downloadFile -- 888
downloadFile = function(url, target) -- 888
	return Director.systemScheduler:schedule(once(function() -- 888
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 889
			if quit then -- 890
				return true -- 890
			end -- 890
			emit("AppWS", "Send", json.encode({ -- 892
				name = "Download", -- 892
				url = url, -- 892
				status = "downloading", -- 892
				progress = current / total -- 893
			})) -- 891
			return false -- 889
		end) -- 889
		return emit("AppWS", "Send", json.encode(success and { -- 896
			name = "Download", -- 896
			url = url, -- 896
			status = "completed", -- 896
			progress = 1.0 -- 897
		} or { -- 899
			name = "Download", -- 899
			url = url, -- 899
			status = "failed", -- 899
			progress = 0.0 -- 900
		})) -- 895
	end)) -- 888
end -- 888
_module_0["downloadFile"] = downloadFile -- 888
local _anon_func_3 = function(file, require, workDir) -- 912
	if workDir == nil then -- 912
		workDir = Path:getPath(file) -- 912
	end -- 912
	Content:insertSearchPath(1, workDir) -- 913
	local scriptPath = Path(workDir, "Script") -- 914
	if Content:exist(scriptPath) then -- 915
		Content:insertSearchPath(1, scriptPath) -- 916
	end -- 915
	local result = require(file) -- 917
	if "function" == type(result) then -- 918
		result() -- 918
	end -- 918
	return nil -- 919
end -- 912
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 948
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 948
	label.alignment = "Left" -- 949
	label.textWidth = width - fontSize -- 950
	label.text = err -- 951
	return label -- 948
end -- 948
local enterEntryAsync -- 903
enterEntryAsync = function(entry) -- 903
	allEntries.runId = allEntries.runId + 1 -- 904
	isInEntry = false -- 905
	App.idled = false -- 906
	emit(Profiler.EventName, "ClearLoader") -- 907
	currentEntry = entry -- 908
	local file, workDir = entry.fileName, entry.workDir -- 909
	sleep() -- 910
	return xpcall(_anon_func_3, function(msg) -- 919
		local err = debug.traceback(msg) -- 921
		Log("Error", err) -- 922
		allClear() -- 923
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 924
		local viewWidth, viewHeight -- 925
		do -- 925
			local _obj_0 = View.size -- 925
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 925
		end -- 925
		local width, height = viewWidth - 20, viewHeight - 20 -- 926
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 927
		Director.ui:addChild((function() -- 928
			local root = AlignNode() -- 928
			do -- 929
				local _obj_0 = App.bufferSize -- 929
				width, height = _obj_0.width, _obj_0.height -- 929
			end -- 929
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 930
			root:onAppChange(function(settingName) -- 931
				if settingName == "Size" then -- 931
					do -- 932
						local _obj_0 = App.bufferSize -- 932
						width, height = _obj_0.width, _obj_0.height -- 932
					end -- 932
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 933
				end -- 931
			end) -- 931
			root:addChild((function() -- 934
				local _with_0 = ScrollArea({ -- 935
					width = width, -- 935
					height = height, -- 936
					paddingX = 0, -- 937
					paddingY = 50, -- 938
					viewWidth = height, -- 939
					viewHeight = height -- 940
				}) -- 934
				root:onAlignLayout(function(w, h) -- 942
					_with_0.position = Vec2(w / 2, h / 2) -- 943
					w = w - 20 -- 944
					h = h - 20 -- 945
					_with_0.view.children.first.textWidth = w - fontSize -- 946
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 947
				end) -- 942
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 948
				return _with_0 -- 934
			end)()) -- 934
			return root -- 928
		end)()) -- 928
		return err -- 952
	end, file, require, workDir) -- 911
end -- 903
_module_0["enterEntryAsync"] = enterEntryAsync -- 903
local enterDemoEntry -- 954
enterDemoEntry = function(entry) -- 954
	return thread(function() -- 954
		return enterEntryAsync(entry) -- 954
	end) -- 954
end -- 954
local reloadCurrentEntry -- 956
reloadCurrentEntry = function() -- 956
	if currentEntry then -- 957
		allClear() -- 958
		return enterDemoEntry(currentEntry) -- 959
	end -- 957
end -- 956
Director.clearColor = Color(0xff1a1a1a) -- 961
local descColor = Color(0xffa1a1a1) -- 962
local extraOperations -- 964
do -- 964
	local isOSSLicenseExist = Content:exist("LICENSES") -- 965
	local ossLicenses = nil -- 966
	local ossLicenseOpen = false -- 967
	local failedSetFolder = false -- 968
	local statusFlags = { -- 969
		"NoResize", -- 969
		"NoMove", -- 969
		"NoCollapse", -- 969
		"AlwaysAutoResize", -- 969
		"NoSavedSettings" -- 969
	} -- 969
	extraOperations = function() -- 976
		local zh = useChinese -- 977
		if isDesktop then -- 978
			local alwaysOnTop = config.alwaysOnTop -- 979
			do -- 980
				local changed -- 980
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 980
				if changed then -- 980
					App.alwaysOnTop = alwaysOnTop -- 981
					config.alwaysOnTop = alwaysOnTop -- 982
				end -- 980
			end -- 980
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 983
			do -- 984
				local changed -- 984
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 984
				if changed then -- 984
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 985
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 986
				end -- 984
			end -- 984
			SameLine() -- 987
			TextColored(descColor, "(?)") -- 988
			if IsItemHovered() then -- 989
				BeginTooltip(function() -- 990
					return PushTextWrapPos(360, function() -- 991
						return Text(zh and [[键盘映射：
方向键 / WASD → 十字键
J / K / U / I → A / B / X / Y
Tab / Ctrl → Back
Q / E → LB / RB
Enter → Start

启用后，普通按键和文本输入事件都会被屏蔽；以上映射键仅作为虚拟手柄输入。]] or [[Keyboard mapping:
Arrow keys / WASD → D-pad
J / K / U / I → A / B / X / Y
Tab / Ctrl → Back
Q / E → LB / RB
Enter → Start

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 992
					end) -- 991
				end) -- 990
			end -- 989
		end -- 978
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1007
		do -- 1012
			local changed -- 1012
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1012
			if changed then -- 1012
				config.showPreview = showPreview -- 1013
				updateEntries() -- 1014
				if not showPreview then -- 1015
					thread(function() -- 1016
						collectgarbage() -- 1017
						return Cache:removeUnused("Texture") -- 1018
					end) -- 1016
				end -- 1015
			end -- 1012
		end -- 1012
		do -- 1019
			local changed -- 1019
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1019
			if changed then -- 1019
				config.authRequired = authRequired -- 1020
				HttpServer.authRequired = authRequired -- 1021
			end -- 1019
		end -- 1019
		SameLine() -- 1022
		TextColored(descColor, "(?)") -- 1023
		if IsItemHovered() then -- 1024
			BeginTooltip(function() -- 1025
				return PushTextWrapPos(280, function() -- 1026
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1027
				end) -- 1026
			end) -- 1025
		end -- 1024
		do -- 1028
			local themeColor = App.themeColor -- 1029
			local writablePath = config.writablePath -- 1030
			SeparatorText(zh and "工作目录" or "Workspace") -- 1031
			PushTextWrapPos(400, function() -- 1032
				return TextColored(themeColor, writablePath) -- 1033
			end) -- 1032
			if not isDesktop then -- 1034
				goto skipSetting -- 1034
			end -- 1034
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1035
			if Button(zh and "改变目录" or "Set Folder") then -- 1036
				App:openFileDialog(true, function(path) -- 1037
					if path == "" then -- 1038
						return -- 1038
					end -- 1038
					local relPath = Path:getRelative(Content.assetPath, path) -- 1039
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1040
						return setWorkspace(path) -- 1041
					else -- 1043
						failedSetFolder = true -- 1043
					end -- 1040
				end) -- 1037
			end -- 1036
			if failedSetFolder then -- 1044
				failedSetFolder = false -- 1045
				OpenPopup(popupName) -- 1046
			end -- 1044
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1047
			BeginPopupModal(popupName, statusFlags, function() -- 1048
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1049
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1050
					return CloseCurrentPopup() -- 1051
				end -- 1050
			end) -- 1048
			SameLine() -- 1052
			if Button(zh and "使用默认" or "Use Default") then -- 1053
				setWorkspace(Content.appPath) -- 1054
			end -- 1053
			Separator() -- 1055
			::skipSetting:: -- 1056
		end -- 1028
		if isOSSLicenseExist then -- 1057
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1058
				if not ossLicenses then -- 1059
					ossLicenses = { } -- 1060
					local licenseText = Content:load("LICENSES") -- 1061
					ossLicenseOpen = (licenseText ~= nil) -- 1062
					if ossLicenseOpen then -- 1062
						licenseText = licenseText:gsub("\r\n", "\n") -- 1063
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1064
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1065
							if name then -- 1065
								ossLicenses[#ossLicenses + 1] = { -- 1066
									name, -- 1066
									text -- 1066
								} -- 1066
							end -- 1065
						end -- 1064
					end -- 1062
				else -- 1068
					ossLicenseOpen = true -- 1068
				end -- 1059
			end -- 1058
			if ossLicenseOpen then -- 1069
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1070
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1071
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1072
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1073
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 1076
						"NoSavedSettings" -- 1076
					}, function() -- 1077
						for _index_0 = 1, #ossLicenses do -- 1077
							local _des_0 = ossLicenses[_index_0] -- 1077
							local firstLine, text = _des_0[1], _des_0[2] -- 1077
							local name, license = firstLine:match("(.+): (.+)") -- 1078
							TextColored(themeColor, name) -- 1079
							SameLine() -- 1080
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1081
								return TextWrapped(text) -- 1081
							end) -- 1081
						end -- 1077
					end) -- 1073
				end) -- 1073
			end -- 1069
		end -- 1057
		if not App.debugging then -- 1083
			return -- 1083
		end -- 1083
		return TreeNode(zh and "开发操作" or "Development", function() -- 1084
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1085
				OpenPopup("build") -- 1085
			end -- 1085
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1086
				return BeginPopup("build", function() -- 1086
					if Selectable(zh and "编译" or "Compile") then -- 1087
						doCompile(false) -- 1087
					end -- 1087
					Separator() -- 1088
					if Selectable(zh and "压缩" or "Minify") then -- 1089
						doCompile(true) -- 1089
					end -- 1089
					Separator() -- 1090
					if Selectable(zh and "清理" or "Clean") then -- 1091
						return doClean() -- 1091
					end -- 1091
				end) -- 1086
			end) -- 1086
			if isInEntry then -- 1092
				if waitForWebStart then -- 1093
					BeginDisabled(function() -- 1094
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1094
					end) -- 1094
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1095
					reloadDevEntry() -- 1096
				end -- 1093
			end -- 1092
			do -- 1097
				local changed -- 1097
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1097
				if changed then -- 1097
					View.scale = scaleContent and screenScale or 1 -- 1098
				end -- 1097
			end -- 1097
			do -- 1099
				local changed -- 1099
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1099
				if changed then -- 1099
					config.engineDev = engineDev -- 1100
				end -- 1099
			end -- 1099
			do -- 1101
				local changed -- 1101
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1101
				if changed then -- 1101
					config.webIDETourCompleted = webIDETourCompleted -- 1102
				end -- 1101
			end -- 1101
			if testingThread then -- 1103
				return BeginDisabled(function() -- 1104
					return Button(zh and "开始自动测试" or "Test automatically") -- 1104
				end) -- 1104
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1105
				testingThread = thread(function() -- 1106
					local _ <close> = setmetatable({ }, { -- 1107
						__close = function() -- 1107
							allClear() -- 1108
							testingThread = nil -- 1109
							isInEntry = true -- 1110
							currentEntry = nil -- 1111
							return print("Testing done!") -- 1112
						end -- 1107
					}) -- 1107
					for _, entry in ipairs(allEntries) do -- 1113
						allClear() -- 1114
						print("Start " .. tostring(entry.entryName)) -- 1115
						enterDemoEntry(entry) -- 1116
						sleep(2) -- 1117
						print("Stop " .. tostring(entry.entryName)) -- 1118
					end -- 1113
				end) -- 1106
			end -- 1103
		end) -- 1084
	end -- 976
end -- 964
local icon = Path("Script", "Dev", "icon_s.png") -- 1120
local iconTex = nil -- 1121
thread(function() -- 1122
	if Cache:loadAsync(icon) then -- 1122
		iconTex = Texture2D(icon) -- 1122
	end -- 1122
end) -- 1122
local webStatus = nil -- 1124
local urlClicked = nil -- 1125
local authCode = string.format("%06d", math.random(0, 999999)) -- 1127
local authCodeTTL = 30.0 -- 1129
_module_0.getAuthCode = function() -- 1130
	return authCode -- 1130
end -- 1130
_module_0.invalidateAuthCode = function() -- 1131
	authCode = string.format("%06d", math.random(0, 999999)) -- 1132
	authCodeTTL = 30.0 -- 1133
end -- 1131
local AuthSession -- 1135
do -- 1135
	local pending = nil -- 1136
	local session = nil -- 1137
	AuthSession = { -- 1139
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1139
			pending = { -- 1141
				sessionId = sessionId, -- 1141
				confirmCode = confirmCode, -- 1142
				expiresAt = expiresAt, -- 1143
				ttl = ttl, -- 1144
				approved = false -- 1145
			} -- 1140
		end, -- 1139
		getPending = function() -- 1147
			return pending -- 1147
		end, -- 1147
		approvePending = function(sessionId) -- 1149
			if pending and pending.sessionId == sessionId then -- 1150
				pending.approved = true -- 1151
				return true -- 1152
			end -- 1150
			return false -- 1153
		end, -- 1149
		clearPending = function() -- 1155
			pending = nil -- 1155
		end, -- 1155
		setSession = function(sessionId, sessionSecret) -- 1157
			session = { -- 1159
				sessionId = sessionId, -- 1159
				sessionSecret = sessionSecret -- 1160
			} -- 1158
		end, -- 1157
		getSession = function() -- 1162
			return session -- 1162
		end -- 1162
	} -- 1138
end -- 1135
_module_0["AuthSession"] = AuthSession -- 1135
local transparant = Color(0x0) -- 1165
local windowFlags = { -- 1166
	"NoTitleBar", -- 1166
	"NoResize", -- 1166
	"NoMove", -- 1166
	"NoCollapse", -- 1166
	"NoSavedSettings", -- 1166
	"NoFocusOnAppearing", -- 1166
	"NoBringToFrontOnFocus" -- 1166
} -- 1166
local statusFlags = { -- 1175
	"NoTitleBar", -- 1175
	"NoResize", -- 1175
	"NoMove", -- 1175
	"NoCollapse", -- 1175
	"AlwaysAutoResize", -- 1175
	"NoSavedSettings" -- 1175
} -- 1175
local displayWindowFlags = { -- 1183
	"NoDecoration", -- 1183
	"NoSavedSettings", -- 1183
	"NoMove", -- 1183
	"NoScrollWithMouse", -- 1183
	"AlwaysAutoResize", -- 1183
	"NoFocusOnAppearing" -- 1183
} -- 1183
local gamepadInputWindowFlags = { -- 1191
	"NoDecoration", -- 1191
	"NoSavedSettings", -- 1191
	"NoMove", -- 1191
	"NoScrollbar", -- 1191
	"NoScrollWithMouse", -- 1191
	"NoFocusOnAppearing", -- 1191
	"NoBringToFrontOnFocus" -- 1191
} -- 1191
local initFooter = true -- 1200
local gamepadInputFocused = false -- 1201
local _anon_func_5 = function(allEntries, currentIndex) -- 1243
	if currentIndex > 1 then -- 1243
		return allEntries[currentIndex - 1] -- 1244
	else -- 1246
		return allEntries[#allEntries] -- 1246
	end -- 1243
end -- 1243
local _anon_func_6 = function(allEntries, currentIndex) -- 1250
	if currentIndex < #allEntries then -- 1250
		return allEntries[currentIndex + 1] -- 1251
	else -- 1253
		return allEntries[1] -- 1253
	end -- 1250
end -- 1250
footerWindow = threadLoop(function() -- 1202
	if mobileMode then -- 1203
		return -- 1203
	end -- 1203
	local zh = useChinese -- 1204
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1205
	if authCodeTTL <= 0 then -- 1206
		authCodeTTL = 30.0 -- 1207
		authCode = string.format("%06d", math.random(0, 999999)) -- 1208
	end -- 1206
	if HttpServer.wsConnectionCount > 0 then -- 1209
		return -- 1210
	end -- 1209
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1211
		if App.platform == "Emscripten" then
			-- With no project running, keep the browser runtime alive.
			stop()
		else
			allClear() -- 1212
			App.devMode = false -- 1213
			App:shutdown() -- 1214
		end
	end -- 1211
	do -- 1215
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1216
		if ctrl and Keyboard:isKeyDown("Q") then -- 1217
			stop() -- 1218
		end -- 1217
		if ctrl and Keyboard:isKeyDown("Z") then -- 1219
			reloadCurrentEntry() -- 1220
		end -- 1219
		if ctrl and Keyboard:isKeyDown(",") then -- 1221
			if showFooter then -- 1222
				showStats = not showStats -- 1222
			else -- 1222
				showStats = true -- 1222
			end -- 1222
			showFooter = true -- 1223
			config.showFooter = showFooter -- 1224
			config.showStats = showStats -- 1225
		end -- 1221
		if ctrl and Keyboard:isKeyDown(".") then -- 1226
			if showFooter then -- 1227
				showConsole = not showConsole -- 1227
			else -- 1227
				showConsole = true -- 1227
			end -- 1227
			showFooter = true -- 1228
			config.showFooter = showFooter -- 1229
			config.showConsole = showConsole -- 1230
		end -- 1226
		if ctrl and Keyboard:isKeyDown("/") then -- 1231
			showFooter = not showFooter -- 1232
			config.showFooter = showFooter -- 1233
		end -- 1231
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1234
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1235
		local currentIndex = nil -- 1236
		for i, entry in ipairs(allEntries) do -- 1237
			if currentEntry == entry then -- 1238
				currentIndex = i -- 1239
			end -- 1238
		end -- 1237
		if left then -- 1240
			allClear() -- 1241
			if currentIndex == nil then -- 1242
				currentIndex = #allEntries + 1 -- 1242
			end -- 1242
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1243
		end -- 1240
		if right then -- 1247
			allClear() -- 1248
			if currentIndex == nil then -- 1249
				currentIndex = 0 -- 1249
			end -- 1249
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1250
		end -- 1247
	end -- 1215
	if not showEntry then -- 1254
		return -- 1254
	end -- 1254
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1256
		reloadDevEntry() -- 1260
	end -- 1256
	if initFooter then -- 1261
		initFooter = false -- 1262
	end -- 1261
	local width, height -- 1264
	do -- 1264
		local _obj_0 = App.visualSize -- 1264
		width, height = _obj_0.width, _obj_0.height -- 1264
	end -- 1264
	if isInEntry then -- 1265
		gamepadInputFocused = false -- 1266
	else -- 1268
		SetNextWindowBgAlpha(0.0) -- 1268
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1269
		SetNextWindowPos(Vec2.zero, "Always") -- 1270
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1271
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1272
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1273
					if not gamepadInputFocused then -- 1274
						SetWindowFocus("DoraGamepadInput") -- 1275
						gamepadInputFocused = true -- 1276
					end -- 1274
				end) -- 1273
			end) -- 1272
		end) -- 1271
	end -- 1265
	if isInEntry or showFooter then -- 1278
		SetNextWindowSize(Vec2(width, 50)) -- 1279
		SetNextWindowPos(Vec2(0, height - 50)) -- 1280
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1281
			return PushStyleVar("WindowRounding", 0, function() -- 1282
				return Begin("Footer", windowFlags, function() -- 1283
					Separator() -- 1284
					if iconTex then -- 1285
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1286
							showStats = not showStats -- 1287
							config.showStats = showStats -- 1288
						end -- 1286
						SameLine() -- 1289
						if Button(">_", Vec2(30, 30)) then -- 1290
							showConsole = not showConsole -- 1291
							config.showConsole = showConsole -- 1292
						end -- 1290
					end -- 1285
					if isInEntry and config.updateNotification then -- 1293
						SameLine() -- 1294
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1295
							allClear() -- 1296
							config.updateNotification = false -- 1297
							enterDemoEntry({ -- 1299
								entryName = "SelfUpdater", -- 1299
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1300
							}) -- 1298
						end -- 1295
					end -- 1293
					if not isInEntry then -- 1301
						SameLine() -- 1302
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1303
						local currentIndex = nil -- 1304
						for i, entry in ipairs(allEntries) do -- 1305
							if currentEntry == entry then -- 1306
								currentIndex = i -- 1307
							end -- 1306
						end -- 1305
						if currentIndex then -- 1308
							if currentIndex > 1 then -- 1309
								SameLine() -- 1310
								if Button("<<", Vec2(30, 30)) then -- 1311
									allClear() -- 1312
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1313
								end -- 1311
							end -- 1309
							if currentIndex < #allEntries then -- 1314
								SameLine() -- 1315
								if Button(">>", Vec2(30, 30)) then -- 1316
									allClear() -- 1317
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1318
								end -- 1316
							end -- 1314
						end -- 1308
						SameLine() -- 1319
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1320
							reloadCurrentEntry() -- 1321
						end -- 1320
						if back then -- 1322
							allClear() -- 1323
							isInEntry = true -- 1324
							currentEntry = nil -- 1325
						end -- 1322
					end -- 1301
				end) -- 1283
			end) -- 1282
		end) -- 1281
	end -- 1278
	if isInEntry then -- 1327
		local showURL = true -- 1328
		local webIDEWidth -- 1329
		do -- 1329
			local base -- 1330
			if config.updateNotification then -- 1330
				base = 460 -- 1330
			else -- 1330
				base = 360 -- 1330
			end -- 1330
			local extra -- 1331
			if config.authRequired then -- 1331
				extra = 35 -- 1331
			else -- 1331
				extra = 0 -- 1331
			end -- 1331
			webIDEWidth = base + extra -- 1332
		end -- 1329
		if width < webIDEWidth then -- 1333
			showURL = false -- 1333
		end -- 1333
		SetNextWindowBgAlpha(0.0) -- 1334
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1335
		Begin("Web IDE", displayWindowFlags, function() -- 1336
			local pending = AuthSession.getPending() -- 1337
			local hovered = false -- 1338
			if not pending and showURL then -- 1339
				do -- 1340
					local url -- 1340
					if webStatus ~= nil then -- 1340
						url = webStatus.url -- 1340
					end -- 1340
					if url then -- 1340
						if isDesktop and not config.fullScreen then -- 1341
							if urlClicked then -- 1342
								BeginDisabled(function() -- 1343
									return Button(url) -- 1343
								end) -- 1343
							elseif Button(url) then -- 1344
								urlClicked = once(function() -- 1345
									return sleep(5) -- 1345
								end) -- 1345
								App:openURL("http://localhost:8866") -- 1346
							end -- 1342
						else -- 1348
							TextColored(descColor, url) -- 1348
						end -- 1341
					else -- 1350
						TextColored(descColor, zh and '不可用' or 'not available') -- 1350
					end -- 1340
				end -- 1340
				hovered = IsItemHovered() -- 1351
			else -- 1353
				TextColored(descColor, "(?)") -- 1353
				hovered = IsItemHovered() -- 1354
			end -- 1339
			SameLine() -- 1355
			local themeColor = App.themeColor -- 1356
			if pending then -- 1357
				if not pending.approved then -- 1358
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1359
					local ttl = pending.ttl or 1 -- 1360
					PushStyleColor("Text", themeColor, function() -- 1361
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1362
						hovered = hovered or IsItemHovered() -- 1363
					end) -- 1361
					SameLine() -- 1364
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1365
						AuthSession.approvePending(pending.sessionId) -- 1366
					end -- 1365
					if hovered then -- 1367
						return BeginTooltip(function() -- 1368
							return PushTextWrapPos(280, function() -- 1369
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1370
							end) -- 1369
						end) -- 1368
					end -- 1367
				end -- 1358
			else -- 1372
				if config.authRequired then -- 1372
					PushStyleColor("Text", themeColor, function() -- 1373
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1374
						hovered = hovered or IsItemHovered() -- 1375
					end) -- 1373
					if hovered then -- 1376
						return BeginTooltip(function() -- 1377
							return PushTextWrapPos(280, function() -- 1378
								local url -- 1379
								if webStatus ~= nil then -- 1379
									url = webStatus.url -- 1379
								end -- 1379
								if url then -- 1379
									local address -- 1380
									if showURL then -- 1380
										address = "Web IDE" -- 1380
									else -- 1380
										address = url -- 1380
									end -- 1380
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1381
								else -- 1383
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1383
								end -- 1379
							end) -- 1378
						end) -- 1377
					end -- 1376
				else -- 1385
					if hovered then -- 1385
						return BeginTooltip(function() -- 1386
							return PushTextWrapPos(280, function() -- 1387
								local url -- 1388
								if webStatus ~= nil then -- 1388
									url = webStatus.url -- 1388
								end -- 1388
								if url then -- 1388
									local address -- 1389
									if showURL then -- 1389
										address = "Web IDE" -- 1389
									else -- 1389
										address = url -- 1389
									end -- 1389
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1390
								else -- 1392
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1392
								end -- 1388
							end) -- 1387
						end) -- 1386
					end -- 1385
				end -- 1372
			end -- 1357
		end) -- 1336
	end -- 1327
	if not isInEntry then -- 1394
		SetNextWindowSize(Vec2(50, 50)) -- 1395
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1396
		PushStyleColor("WindowBg", transparant, function() -- 1397
			return Begin("Show", displayWindowFlags, function() -- 1397
				if width >= 370 then -- 1398
					local changed -- 1399
					changed, showFooter = Checkbox("##dev", showFooter) -- 1399
					if changed then -- 1399
						config.showFooter = showFooter -- 1400
					end -- 1399
				end -- 1398
			end) -- 1397
		end) -- 1397
	end -- 1394
	if isInEntry or showFooter then -- 1402
		if showStats then -- 1403
			PushStyleVar("WindowRounding", 0, function() -- 1404
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1405
				SetNextWindowSize(Vec2(0, height - 50)) -- 1406
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1407
				config.showStats = showStats -- 1408
			end) -- 1404
		end -- 1403
		if showConsole then -- 1409
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1410
			return PushStyleVar("WindowRounding", 6, function() -- 1411
				return ShowConsole() -- 1412
			end) -- 1411
		end -- 1409
	end -- 1402
end) -- 1202
local MaxWidth <const> = 960 -- 1414
local toolOpen = false -- 1416
local filterText = nil -- 1417
allEntries.anyEntryMatched = false -- 1418
allEntries.match = function(name) -- 1419
	local res = not filterText or name:lower():match(filterText) -- 1420
	if res then -- 1421
		allEntries.anyEntryMatched = true -- 1421
	end -- 1421
	return res -- 1422
end -- 1419
allEntries.thinSep = function() -- 1424
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1424
		return SeparatorText("") -- 1424
	end) -- 1424
end -- 1424
entryWindow = threadLoop(function() -- 1426
	local connected = syncWebIDEControl() -- 1427
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1429
		if not allEntries.pendingPackagePath then -- 1430
			local path = App:takeReceivedFile() -- 1431
			if path ~= "" then -- 1432
				allEntries.pendingPackagePath = path -- 1432
			end -- 1432
		end -- 1430
		if allEntries.pendingPackagePath then -- 1433
			pendingUIMode = true -- 1433
		end -- 1433
	end -- 1429
	if (pendingUIMode ~= nil) then -- 1435
		local nextMode = pendingUIMode -- 1436
		pendingUIMode = nil -- 1437
		applyUIMode(nextMode) -- 1438
	end -- 1435
	if mobileMode and not connected then -- 1439
		if isInEntry and not feedHost then -- 1440
			applyUIMode(true) -- 1440
		end -- 1440
		return -- 1441
	end -- 1439
	if App.fpsLimited ~= config.fpsLimited then -- 1442
		config.fpsLimited = App.fpsLimited -- 1443
	end -- 1442
	if App.targetFPS ~= config.targetFPS then -- 1444
		config.targetFPS = App.targetFPS -- 1445
	end -- 1444
	if View.vsync ~= config.vsync then -- 1446
		config.vsync = View.vsync -- 1447
	end -- 1446
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1448
		config.fixedFPS = Director.scheduler.fixedFPS -- 1449
	end -- 1448
	if Director.profilerSending ~= config.webProfiler then -- 1450
		config.webProfiler = Director.profilerSending -- 1451
	end -- 1450
	if urlClicked then -- 1452
		local _, result = coroutine.resume(urlClicked) -- 1453
		if result then -- 1454
			coroutine.close(urlClicked) -- 1455
			urlClicked = nil -- 1456
		end -- 1454
	end -- 1452
	if not isInEntry then -- 1457
		return -- 1457
	end -- 1457
	local zh = useChinese -- 1458
	local themeColor = App.themeColor -- 1459
	if connected then -- 1460
		local width, height -- 1461
		do -- 1461
			local _obj_0 = App.visualSize -- 1461
			width, height = _obj_0.width, _obj_0.height -- 1461
		end -- 1461
		SetNextWindowBgAlpha(0.5) -- 1462
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1463
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1464
			Separator() -- 1465
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1466
			if iconTex then -- 1467
				Image(icon, Vec2(24, 24)) -- 1468
				SameLine() -- 1469
			end -- 1467
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1470
			TextColored(descColor, slogon) -- 1471
			return Separator() -- 1472
		end) -- 1464
		return -- 1473
	end -- 1460
	if not showEntry then -- 1474
		return -- 1474
	end -- 1474
	local fullWidth, height -- 1476
	do -- 1476
		local _obj_0 = App.visualSize -- 1476
		fullWidth, height = _obj_0.width, _obj_0.height -- 1476
	end -- 1476
	local width = math.min(MaxWidth, fullWidth) -- 1477
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1478
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1479
	SetNextWindowPos(Vec2.zero) -- 1480
	SetNextWindowBgAlpha(0) -- 1481
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1482
	do -- 1483
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1484
			return Begin("Dora Dev", windowFlags, function() -- 1485
				Dummy(Vec2(fullWidth - 20, 0)) -- 1486
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1487
				SameLine() -- 1488
				if Button(zh and "Go 模式" or "Go Mode") then -- 1489
					setUIMode("mobile") -- 1490
				end -- 1489
				if fullWidth >= 540 then -- 1491
					SameLine() -- 1492
					Dummy(Vec2(fullWidth - 540, 0)) -- 1493
					SameLine() -- 1494
					SetNextItemWidth(zh and -95 or -140) -- 1495
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1496
						"AutoSelectAll" -- 1496
					}) then -- 1496
						config.filter = filterBuf.text -- 1497
					end -- 1496
					SameLine() -- 1498
					if Button(zh and '下载' or 'Download') then -- 1499
						allClear() -- 1500
						enterDemoEntry({ -- 1502
							entryName = "ResourceDownloader", -- 1502
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1503
						}) -- 1501
					end -- 1499
				end -- 1491
				return Separator() -- 1504
			end) -- 1485
		end) -- 1484
	end -- 1483
	allEntries.anyEntryMatched = false -- 1506
	SetNextWindowPos(Vec2(0, 50)) -- 1507
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1508
	do -- 1509
		return PushStyleColor("WindowBg", transparant, function() -- 1510
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1511
				return PushStyleVar("Alpha", 1, function() -- 1512
					return Begin("Content", windowFlags, function() -- 1513
						local DemoViewWidth <const> = 220 -- 1514
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1515
						if filterText then -- 1516
							filterText = filterText:lower() -- 1516
						end -- 1516
						if App.platform == "Emscripten" then
							Dora.globals.webProjects.draw(zh, themeColor)
							anyEntryMatched = true
						end
						if #gamesInDev > 0 then -- 1517
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1518
							Columns(columns, false) -- 1519
							local realViewWidth = GetColumnWidth() - 50 -- 1520
							for _index_0 = 1, #gamesInDev do -- 1521
								local game = gamesInDev[_index_0] -- 1521
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1522
								local displayName -- 1531
								if repo then -- 1531
									if zh then -- 1532
										displayName = repo.title.zh -- 1532
									else -- 1532
										displayName = repo.title.en -- 1532
									end -- 1532
								end -- 1531
								if displayName == nil then -- 1533
									displayName = gameName -- 1533
								end -- 1533
								if allEntries.match(displayName) then -- 1534
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1535
									SameLine() -- 1536
									TextWrapped(displayName) -- 1537
									if columns > 1 then -- 1538
										if bannerFile and bannerTex then -- 1539
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1540
											local displayWidth <const> = realViewWidth -- 1541
											texHeight = displayWidth * texHeight / texWidth -- 1542
											texWidth = displayWidth -- 1543
											Dummy(Vec2.zero) -- 1544
											SameLine() -- 1545
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1546
										end -- 1539
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1547
											enterDemoEntry(game) -- 1548
										end -- 1547
									else -- 1550
										if bannerFile and bannerTex then -- 1550
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1551
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1552
											local sizing = 0.8 -- 1553
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1554
											texWidth = displayWidth * sizing -- 1555
											if texWidth > 500 then -- 1556
												sizing = 0.6 -- 1557
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1558
												texWidth = displayWidth * sizing -- 1559
											end -- 1556
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1560
											Dummy(Vec2(padding, 0)) -- 1561
											SameLine() -- 1562
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1563
										end -- 1550
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1564
											enterDemoEntry(game) -- 1565
										end -- 1564
									end -- 1538
									if #tests == 0 and #examples == 0 then -- 1566
										allEntries.thinSep() -- 1567
									end -- 1566
									NextColumn() -- 1568
								end -- 1534
								local showSep = false -- 1569
								if #examples > 0 then -- 1570
									local showExample = false -- 1571
									for _index_1 = 1, #examples do -- 1572
										local _des_0 = examples[_index_1] -- 1572
										local entryName = _des_0.entryName -- 1572
										if allEntries.match(entryName) then -- 1573
											showExample = true -- 1573
											break -- 1573
										end -- 1573
									end -- 1572
									if showExample then -- 1574
										showSep = true -- 1575
										Columns(1, false) -- 1576
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1577
										SameLine() -- 1578
										local opened -- 1579
										if (filterText ~= nil) then -- 1579
											opened = showExample -- 1579
										else -- 1579
											opened = false -- 1579
										end -- 1579
										if game.exampleOpen == nil then -- 1580
											game.exampleOpen = opened -- 1580
										end -- 1580
										SetNextItemOpen(game.exampleOpen) -- 1581
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1582
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1583
												Columns(maxColumns, false) -- 1584
												for _index_1 = 1, #examples do -- 1585
													local example = examples[_index_1] -- 1585
													local entryName = example.entryName -- 1586
													if not allEntries.match(entryName) then -- 1587
														goto _continue_0 -- 1587
													end -- 1587
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1588
														if Button(entryName, Vec2(-1, 40)) then -- 1589
															enterDemoEntry(example) -- 1590
														end -- 1589
														return NextColumn() -- 1591
													end) -- 1588
													opened = true -- 1592
													::_continue_0:: -- 1586
												end -- 1585
											end) -- 1583
										end) -- 1582
										game.exampleOpen = opened -- 1593
									end -- 1574
								end -- 1570
								if #tests > 0 then -- 1594
									local showTest = false -- 1595
									for _index_1 = 1, #tests do -- 1596
										local _des_0 = tests[_index_1] -- 1596
										local entryName = _des_0.entryName -- 1596
										if allEntries.match(entryName) then -- 1597
											showTest = true -- 1597
											break -- 1597
										end -- 1597
									end -- 1596
									if showTest then -- 1598
										showSep = true -- 1599
										Columns(1, false) -- 1600
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1601
										SameLine() -- 1602
										local opened -- 1603
										if (filterText ~= nil) then -- 1603
											opened = showTest -- 1603
										else -- 1603
											opened = false -- 1603
										end -- 1603
										if game.testOpen == nil then -- 1604
											game.testOpen = opened -- 1604
										end -- 1604
										SetNextItemOpen(game.testOpen) -- 1605
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1606
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1607
												Columns(maxColumns, false) -- 1608
												for _index_1 = 1, #tests do -- 1609
													local test = tests[_index_1] -- 1609
													local entryName = test.entryName -- 1610
													if not allEntries.match(entryName) then -- 1611
														goto _continue_0 -- 1611
													end -- 1611
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1612
														if Button(entryName, Vec2(-1, 40)) then -- 1613
															enterDemoEntry(test) -- 1614
														end -- 1613
														return NextColumn() -- 1615
													end) -- 1612
													opened = true -- 1616
													::_continue_0:: -- 1610
												end -- 1609
											end) -- 1607
										end) -- 1606
										game.testOpen = opened -- 1617
									end -- 1598
								end -- 1594
								if showSep then -- 1618
									Columns(1, false) -- 1619
									allEntries.thinSep() -- 1620
									Columns(columns, false) -- 1621
								end -- 1618
							end -- 1521
						end -- 1517
						if #doraTools > 0 then -- 1622
							local showTool = false -- 1623
							for _index_0 = 1, #doraTools do -- 1624
								local _des_0 = doraTools[_index_0] -- 1624
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1624
								local displayName -- 1625
								if repo then -- 1625
									if zh then -- 1626
										displayName = repo.title.zh -- 1626
									else -- 1626
										displayName = repo.title.en -- 1626
									end -- 1626
								end -- 1625
								if displayName == nil then -- 1627
									displayName = entryName -- 1627
								end -- 1627
								if allEntries.match(displayName) then -- 1628
									showTool = true -- 1628
									break -- 1628
								end -- 1628
							end -- 1624
							if not showTool then -- 1629
								goto endEntry -- 1629
							end -- 1629
							Columns(1, false) -- 1630
							TextColored(themeColor, "Dora SSR:") -- 1631
							SameLine() -- 1632
							Text(zh and "开发支持" or "Development Support") -- 1633
							Separator() -- 1634
							if #doraTools > 0 then -- 1635
								local opened -- 1636
								if (filterText ~= nil) then -- 1636
									opened = showTool -- 1636
								else -- 1636
									opened = false -- 1636
								end -- 1636
								SetNextItemOpen(toolOpen) -- 1637
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1638
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1639
										Columns(maxColumns, false) -- 1640
										for _index_0 = 1, #doraTools do -- 1641
											local tool = doraTools[_index_0] -- 1641
											local entryName, repo = tool.entryName, tool.repo -- 1642
											local displayName -- 1643
											if repo then -- 1643
												if zh then -- 1644
													displayName = repo.title.zh -- 1644
												else -- 1644
													displayName = repo.title.en -- 1644
												end -- 1644
											end -- 1643
											if displayName == nil then -- 1645
												displayName = entryName -- 1645
											end -- 1645
											if not allEntries.match(displayName) then -- 1646
												goto _continue_0 -- 1646
											end -- 1646
											if Button(displayName, Vec2(-1, 40)) then -- 1647
												enterDemoEntry(tool) -- 1648
											end -- 1647
											NextColumn() -- 1649
											::_continue_0:: -- 1642
										end -- 1641
										Columns(1, false) -- 1650
										opened = true -- 1651
									end) -- 1639
								end) -- 1638
								toolOpen = opened -- 1652
							end -- 1635
						end -- 1622
						::endEntry:: -- 1653
						if not allEntries.anyEntryMatched then -- 1654
							SetNextWindowBgAlpha(0) -- 1655
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1656
							Begin("Entries Not Found", displayWindowFlags, function() -- 1657
								Separator() -- 1658
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1659
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1660
								return Separator() -- 1661
							end) -- 1657
						end -- 1654
						Columns(1, false) -- 1662
						Dummy(Vec2(100, 80)) -- 1663
						return ScrollWhenDraggingOnVoid() -- 1664
					end) -- 1513
				end) -- 1512
			end) -- 1511
		end) -- 1510
	end -- 1509
end) -- 1426
if App.platform ~= "Emscripten" then
	local sceneModuleCache = moduleCache -- 1670
	moduleCache = { } -- 1671
	webStatus = oldRequire("Script.Dev.WebServer") -- 1672
	moduleCache = sceneModuleCache -- 1673
end -- 1669
local _anon_func_7 = function(saved) -- 1696
	local _val_0 = saved.kind -- 1696
	return "local" == _val_0 or "discover" == _val_0 -- 1696
end -- 1696
local _anon_func_8 = function(saved) -- 1700
	local _val_0 = saved.activeTab -- 1700
	return "local" == _val_0 or "discover" == _val_0 -- 1700
end -- 1700
startMobileUI = function() -- 1675
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1676
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1677
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1678
	local getMobileFeedResources -- 1679
	do -- 1679
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1679
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1679
	end -- 1679
	local loadCachedCatalog -- 1680
	do -- 1680
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1680
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1680
	end -- 1680
	local getResourceInstallPath -- 1681
	do -- 1681
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1681
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1681
	end -- 1681
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1682
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1683
	local feedOptions = nil -- 1684
	local mobileLaunchErrors = { } -- 1685
	local withMobileLaunchErrors -- 1686
	withMobileLaunchErrors = function(items) -- 1686
		for _index_0 = 1, #items do -- 1687
			local item = items[_index_0] -- 1687
			item.launchError = mobileLaunchErrors[item.id] -- 1688
		end -- 1687
		return items -- 1689
	end -- 1686
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1690
	local loadRememberedMobileFeedState -- 1691
	loadRememberedMobileFeedState = function() -- 1691
		local raw = rememberedMobileFeedData -- 1692
		if not (type(raw) == "string" and raw ~= "") then -- 1693
			return -- 1693
		end -- 1693
		local ok, saved = pcall(json.decode, raw) -- 1694
		if not (ok and type(saved) == "table") then -- 1695
			return -- 1695
		end -- 1695
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1696
			local state = { -- 1697
				activeTab = saved.kind -- 1697
			} -- 1697
			state[saved.kind] = saved -- 1698
			return state -- 1699
		end -- 1696
		local state = { -- 1700
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1700
		} -- 1700
		local _list_0 = { -- 1701
			"local", -- 1701
			"discover" -- 1701
		} -- 1701
		for _index_0 = 1, #_list_0 do -- 1701
			local kind = _list_0[_index_0] -- 1701
			local entry = saved[kind] -- 1702
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1703
				state[kind] = entry -- 1703
			end -- 1703
		end -- 1701
		return state -- 1704
	end -- 1691
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1705
		activeTab = "local" -- 1705
	} -- 1705
	local rememberMobileFeedEntry -- 1706
	rememberMobileFeedEntry = function(entry) -- 1706
		rememberedMobileFeedState.activeTab = entry.kind -- 1707
		rememberedMobileFeedState[entry.kind] = { -- 1709
			id = entry.id, -- 1709
			kind = entry.kind, -- 1710
			workDir = entry.workDir, -- 1711
			fileName = entry.fileName -- 1712
		} -- 1708
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1714
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1715
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1716
			rememberedMobileFeedData -- 1716
		}) -- 1716
	end -- 1706
	local restartMobileFeed -- 1717
	restartMobileFeed = function(entry) -- 1717
		if feedHost then -- 1718
			feedHost:removeFromParent(true) -- 1718
		end -- 1718
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1719
		local initialEntries = { } -- 1720
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1721
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1722
		feedOptions.initialEntries = initialEntries -- 1723
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1724
	end -- 1717
	local startMobilePlay -- 1725
	startMobilePlay = function(entry) -- 1725
		if HttpServer.wsConnectionCount > 0 then -- 1726
			return -- 1726
		end -- 1726
		local originFeed = feedHost -- 1727
		if remixHost then -- 1728
			remixHost:removeFromParent(true) -- 1728
		end -- 1728
		remixHost = nil -- 1729
		mobileLaunchErrors[entry.id] = nil -- 1730
		entry.launchError = nil -- 1731
		local playActive = true -- 1732
		local restoreMobileFeed -- 1733
		restoreMobileFeed = function() -- 1733
			if not playActive then -- 1734
				return -- 1734
			end -- 1734
			playActive = false -- 1735
			allClear() -- 1736
			isInEntry = true -- 1737
			currentEntry = nil -- 1738
			return restartMobileFeed(entry) -- 1739
		end -- 1733
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1741
			onExit = function() -- 1741
				return restoreMobileFeed() -- 1741
			end, -- 1741
			onRuntimeError = function() -- 1742
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1743
				return restoreMobileFeed() -- 1744
			end -- 1742
		})) -- 1740
		return thread(function() -- 1746
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1750
			if not playActive then -- 1751
				return -- 1751
			end -- 1751
			if success then -- 1752
				if originFeed and originFeed.parent then -- 1753
					originFeed.visible = false -- 1753
				end -- 1753
				return -- 1754
			end -- 1752
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1755
			return restoreMobileFeed() -- 1756
		end) -- 1746
	end -- 1725
	feedOptions = { -- 1758
		takeReceivedFile = function() -- 1758
			if allEntries.pendingPackagePath then -- 1759
				local path = allEntries.pendingPackagePath -- 1760
				allEntries.pendingPackagePath = nil -- 1761
				return path -- 1762
			end -- 1759
			return App:takeReceivedFile() -- 1763
		end, -- 1758
		onSwitchMode = function() -- 1764
			if HttpServer.wsConnectionCount == 0 then -- 1764
				pendingUIMode = false -- 1764
			end -- 1764
		end, -- 1764
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1765
		getLocalEntries = function(importedProjectPath) -- 1766
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1767
			feedOptions.dirtyProjectPath = nil -- 1768
			return withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1769
		end, -- 1766
		syncDiscover = function(onProgress, onDone, force) -- 1770
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1770
		end, -- 1770
		getDiscoverEntries = function() -- 1771
			local cached = loadCachedCatalog() -- 1772
			if not (cached.success and cached.snapshot) then -- 1773
				return { } -- 1773
			end -- 1773
			local items = { } -- 1774
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1775
			for _index_0 = 1, #_list_0 do -- 1775
				local resource = _list_0[_index_0] -- 1775
				local installed = lifecycle.isMobileResourceReady(resource) -- 1776
				local installPath = getResourceInstallPath(resource.id) -- 1777
				items[#items + 1] = { -- 1779
					id = resource.id, -- 1779
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1780
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1781
					kind = "discover", -- 1782
					bannerFile = resource.bannerPath, -- 1783
					workDir = installed and installPath or nil, -- 1784
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1785
					installed = installed, -- 1786
					resource = resource, -- 1787
					catalogCommit = cached.snapshot.commit, -- 1788
					launchError = mobileLaunchErrors[resource.id] -- 1789
				} -- 1778
			end -- 1775
			return items -- 1791
		end, -- 1771
		prepare = function(entry, repairIncomplete, onProgress, onDone) -- 1792
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1793
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1794
			end), repairIncomplete) -- 1793
		end, -- 1792
		createProject = function(name, language) -- 1796
			local result = projectCreate.createMobileProject(name, language) -- 1797
			if not result.success then -- 1798
				return result -- 1798
			end -- 1798
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1799
			for _index_0 = 1, #_list_0 do -- 1799
				local entry = _list_0[_index_0] -- 1799
				if entry.workDir == result.workDir then -- 1800
					return { -- 1801
						success = true, -- 1801
						entry = entry -- 1801
					} -- 1801
				end -- 1800
			end -- 1799
			return { -- 1802
				success = false, -- 1802
				error = "created-project-not-found" -- 1802
			} -- 1802
		end, -- 1796
		onPlay = function(entry) -- 1803
			return startMobilePlay(entry) -- 1803
		end, -- 1803
		onRemix = function(entry) -- 1804
			if HttpServer.wsConnectionCount > 0 then -- 1805
				return -- 1805
			end -- 1805
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1806
			local originFeed = feedHost -- 1807
			feedHost.visible = false -- 1808
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1810
				entry = entry, -- 1810
				onProjectChanged = function(current) -- 1811
					feedOptions.dirtyProjectPath = current.workDir -- 1811
				end, -- 1811
				onBack = function() -- 1812
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1813
						originFeed:emit("RestoreFeedEntry", entry) -- 1814
						originFeed.visible = true -- 1815
					end -- 1813
				end, -- 1812
				onPlay = function(current) -- 1816
					return startMobilePlay(current) -- 1816
				end -- 1816
			})) -- 1809
		end -- 1804
	} -- 1757
	return restartMobileFeed() -- 1819
end -- 1675
if mobileMode then -- 1821
	applyUIMode(true) -- 1821
end -- 1821
return _module_0 -- 1
