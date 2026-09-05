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
	hasDirty = false -- 282
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
			running = false -- 832
		} -- 832
	end -- 832
	local status = { -- 834
		success = true, -- 834
		running = true, -- 835
		kind = entry.runKind or "file", -- 836
		entryName = entry.entryName, -- 837
		fileName = entry.fileName -- 838
	} -- 833
	if entry.workDir then -- 839
		status.workDir = entry.workDir -- 839
	end -- 839
	if entry.projectRoot then -- 840
		status.projectRoot = entry.projectRoot -- 840
	end -- 840
	return status -- 841
end -- 830
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 830
local _anon_func_2 = function(_with_0) -- 860
	local _val_0 = App.platform -- 860
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 860
end -- 860
setupEventHandlers = function() -- 843
	local _with_0 = Director.postNode -- 844
	_with_0:onAppEvent(function(eventType) -- 845
		if "Quit" == eventType then -- 846
			quit = true -- 847
			allClear() -- 848
			return clearTempFiles() -- 849
		elseif "Shutdown" == eventType then -- 850
			return stop() -- 851
		end -- 845
	end) -- 845
	_with_0:onAppChange(function(settingName) -- 852
		if "Theme" == settingName then -- 853
			config.themeColor = App.themeColor:toARGB() -- 854
		elseif "Locale" == settingName then -- 855
			config.locale = App.locale -- 856
			updateLocale() -- 857
			return teal.clear(true) -- 858
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 859
			if _anon_func_2(_with_0) then -- 860
				if "FullScreen" == settingName then -- 862
					config.fullScreen = App.fullScreen -- 862
				elseif "Position" == settingName then -- 863
					local _obj_0 = App.winPosition -- 863
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 863
				elseif "Size" == settingName then -- 864
					local width, height -- 865
					do -- 865
						local _obj_0 = App.winSize -- 865
						width, height = _obj_0.width, _obj_0.height -- 865
					end -- 865
					config.winWidth = width -- 866
					config.winHeight = height -- 867
				end -- 861
			end -- 860
		end -- 852
	end) -- 852
	_with_0:onAppWS(function(event) -- 868
		if event.type == "Close" then -- 869
			if HttpServer.wsConnectionCount == 0 then -- 870
				updateEntries() -- 871
			end -- 870
			return -- 872
		end -- 869
		if not (event.type == "Receive") then -- 873
			return -- 873
		end -- 873
		local data = json.decode(event.msg) -- 874
		if not data then -- 875
			return -- 875
		end -- 875
		local _exp_0 = data.name -- 876
		if "SearchFiles" == _exp_0 then -- 877
			return handleSearchFiles(data) -- 878
		elseif "SearchFilesStop" == _exp_0 then -- 879
			if data.id == nil or data.id == activeSearchId then -- 880
				activeSearchId = 0 -- 881
			end -- 880
		end -- 876
	end) -- 868
	_with_0:slot("UpdateEntries", function() -- 882
		return updateEntries() -- 882
	end) -- 882
	return _with_0 -- 844
end -- 843
setupEventHandlers() -- 884
clearTempFiles() -- 885
local downloadFile -- 887
downloadFile = function(url, target) -- 887
	return Director.systemScheduler:schedule(once(function() -- 887
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 888
			if quit then -- 889
				return true -- 889
			end -- 889
			emit("AppWS", "Send", json.encode({ -- 891
				name = "Download", -- 891
				url = url, -- 891
				status = "downloading", -- 891
				progress = current / total -- 892
			})) -- 890
			return false -- 888
		end) -- 888
		return emit("AppWS", "Send", json.encode(success and { -- 895
			name = "Download", -- 895
			url = url, -- 895
			status = "completed", -- 895
			progress = 1.0 -- 896
		} or { -- 898
			name = "Download", -- 898
			url = url, -- 898
			status = "failed", -- 898
			progress = 0.0 -- 899
		})) -- 894
	end)) -- 887
end -- 887
_module_0["downloadFile"] = downloadFile -- 887
local _anon_func_3 = function(file, require, workDir) -- 910
	if workDir == nil then -- 910
		workDir = Path:getPath(file) -- 910
	end -- 910
	Content:insertSearchPath(1, workDir) -- 911
	local scriptPath = Path(workDir, "Script") -- 912
	if Content:exist(scriptPath) then -- 913
		Content:insertSearchPath(1, scriptPath) -- 914
	end -- 913
	local result = require(file) -- 915
	if "function" == type(result) then -- 916
		result() -- 916
	end -- 916
	return nil -- 917
end -- 910
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 946
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 946
	label.alignment = "Left" -- 947
	label.textWidth = width - fontSize -- 948
	label.text = err -- 949
	return label -- 946
end -- 946
local enterEntryAsync -- 902
enterEntryAsync = function(entry) -- 902
	isInEntry = false -- 903
	App.idled = false -- 904
	emit(Profiler.EventName, "ClearLoader") -- 905
	currentEntry = entry -- 906
	local file, workDir = entry.fileName, entry.workDir -- 907
	sleep() -- 908
	return xpcall(_anon_func_3, function(msg) -- 917
		local err = debug.traceback(msg) -- 919
		Log("Error", err) -- 920
		allClear() -- 921
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 922
		local viewWidth, viewHeight -- 923
		do -- 923
			local _obj_0 = View.size -- 923
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 923
		end -- 923
		local width, height = viewWidth - 20, viewHeight - 20 -- 924
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 925
		Director.ui:addChild((function() -- 926
			local root = AlignNode() -- 926
			do -- 927
				local _obj_0 = App.bufferSize -- 927
				width, height = _obj_0.width, _obj_0.height -- 927
			end -- 927
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 928
			root:onAppChange(function(settingName) -- 929
				if settingName == "Size" then -- 929
					do -- 930
						local _obj_0 = App.bufferSize -- 930
						width, height = _obj_0.width, _obj_0.height -- 930
					end -- 930
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 931
				end -- 929
			end) -- 929
			root:addChild((function() -- 932
				local _with_0 = ScrollArea({ -- 933
					width = width, -- 933
					height = height, -- 934
					paddingX = 0, -- 935
					paddingY = 50, -- 936
					viewWidth = height, -- 937
					viewHeight = height -- 938
				}) -- 932
				root:onAlignLayout(function(w, h) -- 940
					_with_0.position = Vec2(w / 2, h / 2) -- 941
					w = w - 20 -- 942
					h = h - 20 -- 943
					_with_0.view.children.first.textWidth = w - fontSize -- 944
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 945
				end) -- 940
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 946
				return _with_0 -- 932
			end)()) -- 932
			return root -- 926
		end)()) -- 926
		return err -- 950
	end, file, require, workDir) -- 909
end -- 902
_module_0["enterEntryAsync"] = enterEntryAsync -- 902
local enterDemoEntry -- 952
enterDemoEntry = function(entry) -- 952
	return thread(function() -- 952
		return enterEntryAsync(entry) -- 952
	end) -- 952
end -- 952
local reloadCurrentEntry -- 954
reloadCurrentEntry = function() -- 954
	if currentEntry then -- 955
		allClear() -- 956
		return enterDemoEntry(currentEntry) -- 957
	end -- 955
end -- 954
Director.clearColor = Color(0xff1a1a1a) -- 959
local descColor = Color(0xffa1a1a1) -- 960
local extraOperations -- 962
do -- 962
	local isOSSLicenseExist = Content:exist("LICENSES") -- 963
	local ossLicenses = nil -- 964
	local ossLicenseOpen = false -- 965
	local failedSetFolder = false -- 966
	local statusFlags = { -- 967
		"NoResize", -- 967
		"NoMove", -- 967
		"NoCollapse", -- 967
		"AlwaysAutoResize", -- 967
		"NoSavedSettings" -- 967
	} -- 967
	extraOperations = function() -- 974
		local zh = useChinese -- 975
		if isDesktop then -- 976
			local alwaysOnTop = config.alwaysOnTop -- 977
			do -- 978
				local changed -- 978
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 978
				if changed then -- 978
					App.alwaysOnTop = alwaysOnTop -- 979
					config.alwaysOnTop = alwaysOnTop -- 980
				end -- 978
			end -- 978
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 981
			do -- 982
				local changed -- 982
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 982
				if changed then -- 982
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 983
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 984
				end -- 982
			end -- 982
			SameLine() -- 985
			TextColored(descColor, "(?)") -- 986
			if IsItemHovered() then -- 987
				BeginTooltip(function() -- 988
					return PushTextWrapPos(360, function() -- 989
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 990
					end) -- 989
				end) -- 988
			end -- 987
		end -- 976
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1005
		do -- 1010
			local changed -- 1010
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1010
			if changed then -- 1010
				config.showPreview = showPreview -- 1011
				updateEntries() -- 1012
				if not showPreview then -- 1013
					thread(function() -- 1014
						collectgarbage() -- 1015
						return Cache:removeUnused("Texture") -- 1016
					end) -- 1014
				end -- 1013
			end -- 1010
		end -- 1010
		do -- 1017
			local changed -- 1017
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1017
			if changed then -- 1017
				config.authRequired = authRequired -- 1018
				HttpServer.authRequired = authRequired -- 1019
			end -- 1017
		end -- 1017
		SameLine() -- 1020
		TextColored(descColor, "(?)") -- 1021
		if IsItemHovered() then -- 1022
			BeginTooltip(function() -- 1023
				return PushTextWrapPos(280, function() -- 1024
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1025
				end) -- 1024
			end) -- 1023
		end -- 1022
		do -- 1026
			local themeColor = App.themeColor -- 1027
			local writablePath = config.writablePath -- 1028
			SeparatorText(zh and "工作目录" or "Workspace") -- 1029
			PushTextWrapPos(400, function() -- 1030
				return TextColored(themeColor, writablePath) -- 1031
			end) -- 1030
			if not isDesktop then -- 1032
				goto skipSetting -- 1032
			end -- 1032
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1033
			if Button(zh and "改变目录" or "Set Folder") then -- 1034
				App:openFileDialog(true, function(path) -- 1035
					if path == "" then -- 1036
						return -- 1036
					end -- 1036
					local relPath = Path:getRelative(Content.assetPath, path) -- 1037
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1038
						return setWorkspace(path) -- 1039
					else -- 1041
						failedSetFolder = true -- 1041
					end -- 1038
				end) -- 1035
			end -- 1034
			if failedSetFolder then -- 1042
				failedSetFolder = false -- 1043
				OpenPopup(popupName) -- 1044
			end -- 1042
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1045
			BeginPopupModal(popupName, statusFlags, function() -- 1046
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1047
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1048
					return CloseCurrentPopup() -- 1049
				end -- 1048
			end) -- 1046
			SameLine() -- 1050
			if Button(zh and "使用默认" or "Use Default") then -- 1051
				setWorkspace(Content.appPath) -- 1052
			end -- 1051
			Separator() -- 1053
			::skipSetting:: -- 1054
		end -- 1026
		if isOSSLicenseExist then -- 1055
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1056
				if not ossLicenses then -- 1057
					ossLicenses = { } -- 1058
					local licenseText = Content:load("LICENSES") -- 1059
					ossLicenseOpen = (licenseText ~= nil) -- 1060
					if ossLicenseOpen then -- 1060
						licenseText = licenseText:gsub("\r\n", "\n") -- 1061
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1062
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1063
							if name then -- 1063
								ossLicenses[#ossLicenses + 1] = { -- 1064
									name, -- 1064
									text -- 1064
								} -- 1064
							end -- 1063
						end -- 1062
					end -- 1060
				else -- 1066
					ossLicenseOpen = true -- 1066
				end -- 1057
			end -- 1056
			if ossLicenseOpen then -- 1067
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1068
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1069
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1070
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1071
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 1074
						"NoSavedSettings" -- 1074
					}, function() -- 1075
						for _index_0 = 1, #ossLicenses do -- 1075
							local _des_0 = ossLicenses[_index_0] -- 1075
							local firstLine, text = _des_0[1], _des_0[2] -- 1075
							local name, license = firstLine:match("(.+): (.+)") -- 1076
							TextColored(themeColor, name) -- 1077
							SameLine() -- 1078
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1079
								return TextWrapped(text) -- 1079
							end) -- 1079
						end -- 1075
					end) -- 1071
				end) -- 1071
			end -- 1067
		end -- 1055
		if not App.debugging then -- 1081
			return -- 1081
		end -- 1081
		return TreeNode(zh and "开发操作" or "Development", function() -- 1082
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1083
				OpenPopup("build") -- 1083
			end -- 1083
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1084
				return BeginPopup("build", function() -- 1084
					if Selectable(zh and "编译" or "Compile") then -- 1085
						doCompile(false) -- 1085
					end -- 1085
					Separator() -- 1086
					if Selectable(zh and "压缩" or "Minify") then -- 1087
						doCompile(true) -- 1087
					end -- 1087
					Separator() -- 1088
					if Selectable(zh and "清理" or "Clean") then -- 1089
						return doClean() -- 1089
					end -- 1089
				end) -- 1084
			end) -- 1084
			if isInEntry then -- 1090
				if waitForWebStart then -- 1091
					BeginDisabled(function() -- 1092
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1092
					end) -- 1092
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1093
					reloadDevEntry() -- 1094
				end -- 1091
			end -- 1090
			do -- 1095
				local changed -- 1095
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1095
				if changed then -- 1095
					View.scale = scaleContent and screenScale or 1 -- 1096
				end -- 1095
			end -- 1095
			do -- 1097
				local changed -- 1097
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1097
				if changed then -- 1097
					config.engineDev = engineDev -- 1098
				end -- 1097
			end -- 1097
			do -- 1099
				local changed -- 1099
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1099
				if changed then -- 1099
					config.webIDETourCompleted = webIDETourCompleted -- 1100
				end -- 1099
			end -- 1099
			if testingThread then -- 1101
				return BeginDisabled(function() -- 1102
					return Button(zh and "开始自动测试" or "Test automatically") -- 1102
				end) -- 1102
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1103
				testingThread = thread(function() -- 1104
					local _ <close> = setmetatable({ }, { -- 1105
						__close = function() -- 1105
							allClear() -- 1106
							testingThread = nil -- 1107
							isInEntry = true -- 1108
							currentEntry = nil -- 1109
							return print("Testing done!") -- 1110
						end -- 1105
					}) -- 1105
					for _, entry in ipairs(allEntries) do -- 1111
						allClear() -- 1112
						print("Start " .. tostring(entry.entryName)) -- 1113
						enterDemoEntry(entry) -- 1114
						sleep(2) -- 1115
						print("Stop " .. tostring(entry.entryName)) -- 1116
					end -- 1111
				end) -- 1104
			end -- 1101
		end) -- 1082
	end -- 974
end -- 962
local icon = Path("Script", "Dev", "icon_s.png") -- 1118
local iconTex = nil -- 1119
thread(function() -- 1120
	if Cache:loadAsync(icon) then -- 1120
		iconTex = Texture2D(icon) -- 1120
	end -- 1120
end) -- 1120
local webStatus = nil -- 1122
local urlClicked = nil -- 1123
local authCode = string.format("%06d", math.random(0, 999999)) -- 1125
local authCodeTTL = 30.0 -- 1127
_module_0.getAuthCode = function() -- 1128
	return authCode -- 1128
end -- 1128
_module_0.invalidateAuthCode = function() -- 1129
	authCode = string.format("%06d", math.random(0, 999999)) -- 1130
	authCodeTTL = 30.0 -- 1131
end -- 1129
local AuthSession -- 1133
do -- 1133
	local pending = nil -- 1134
	local session = nil -- 1135
	AuthSession = { -- 1137
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1137
			pending = { -- 1139
				sessionId = sessionId, -- 1139
				confirmCode = confirmCode, -- 1140
				expiresAt = expiresAt, -- 1141
				ttl = ttl, -- 1142
				approved = false -- 1143
			} -- 1138
		end, -- 1137
		getPending = function() -- 1145
			return pending -- 1145
		end, -- 1145
		approvePending = function(sessionId) -- 1147
			if pending and pending.sessionId == sessionId then -- 1148
				pending.approved = true -- 1149
				return true -- 1150
			end -- 1148
			return false -- 1151
		end, -- 1147
		clearPending = function() -- 1153
			pending = nil -- 1153
		end, -- 1153
		setSession = function(sessionId, sessionSecret) -- 1155
			session = { -- 1157
				sessionId = sessionId, -- 1157
				sessionSecret = sessionSecret -- 1158
			} -- 1156
		end, -- 1155
		getSession = function() -- 1160
			return session -- 1160
		end -- 1160
	} -- 1136
end -- 1133
_module_0["AuthSession"] = AuthSession -- 1133
local transparant = Color(0x0) -- 1163
local windowFlags = { -- 1164
	"NoTitleBar", -- 1164
	"NoResize", -- 1164
	"NoMove", -- 1164
	"NoCollapse", -- 1164
	"NoSavedSettings", -- 1164
	"NoFocusOnAppearing", -- 1164
	"NoBringToFrontOnFocus" -- 1164
} -- 1164
local statusFlags = { -- 1173
	"NoTitleBar", -- 1173
	"NoResize", -- 1173
	"NoMove", -- 1173
	"NoCollapse", -- 1173
	"AlwaysAutoResize", -- 1173
	"NoSavedSettings" -- 1173
} -- 1173
local displayWindowFlags = { -- 1181
	"NoDecoration", -- 1181
	"NoSavedSettings", -- 1181
	"NoMove", -- 1181
	"NoScrollWithMouse", -- 1181
	"AlwaysAutoResize", -- 1181
	"NoFocusOnAppearing" -- 1181
} -- 1181
local gamepadInputWindowFlags = { -- 1189
	"NoDecoration", -- 1189
	"NoSavedSettings", -- 1189
	"NoMove", -- 1189
	"NoScrollbar", -- 1189
	"NoScrollWithMouse", -- 1189
	"NoFocusOnAppearing", -- 1189
	"NoBringToFrontOnFocus" -- 1189
} -- 1189
local initFooter = true -- 1198
local gamepadInputFocused = false -- 1199
local _anon_func_5 = function(allEntries, currentIndex) -- 1241
	if currentIndex > 1 then -- 1241
		return allEntries[currentIndex - 1] -- 1242
	else -- 1244
		return allEntries[#allEntries] -- 1244
	end -- 1241
end -- 1241
local _anon_func_6 = function(allEntries, currentIndex) -- 1248
	if currentIndex < #allEntries then -- 1248
		return allEntries[currentIndex + 1] -- 1249
	else -- 1251
		return allEntries[1] -- 1251
	end -- 1248
end -- 1248
footerWindow = threadLoop(function() -- 1200
	if mobileMode then -- 1201
		return -- 1201
	end -- 1201
	local zh = useChinese -- 1202
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1203
	if authCodeTTL <= 0 then -- 1204
		authCodeTTL = 30.0 -- 1205
		authCode = string.format("%06d", math.random(0, 999999)) -- 1206
	end -- 1204
	if HttpServer.wsConnectionCount > 0 then -- 1207
		return -- 1208
	end -- 1207
	if Keyboard:isKeyDown("Escape") then -- 1209
		allClear() -- 1210
		App.devMode = false -- 1211
		App:shutdown() -- 1212
	end -- 1209
	do -- 1213
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1214
		if ctrl and Keyboard:isKeyDown("Q") then -- 1215
			stop() -- 1216
		end -- 1215
		if ctrl and Keyboard:isKeyDown("Z") then -- 1217
			reloadCurrentEntry() -- 1218
		end -- 1217
		if ctrl and Keyboard:isKeyDown(",") then -- 1219
			if showFooter then -- 1220
				showStats = not showStats -- 1220
			else -- 1220
				showStats = true -- 1220
			end -- 1220
			showFooter = true -- 1221
			config.showFooter = showFooter -- 1222
			config.showStats = showStats -- 1223
		end -- 1219
		if ctrl and Keyboard:isKeyDown(".") then -- 1224
			if showFooter then -- 1225
				showConsole = not showConsole -- 1225
			else -- 1225
				showConsole = true -- 1225
			end -- 1225
			showFooter = true -- 1226
			config.showFooter = showFooter -- 1227
			config.showConsole = showConsole -- 1228
		end -- 1224
		if ctrl and Keyboard:isKeyDown("/") then -- 1229
			showFooter = not showFooter -- 1230
			config.showFooter = showFooter -- 1231
		end -- 1229
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1232
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1233
		local currentIndex = nil -- 1234
		for i, entry in ipairs(allEntries) do -- 1235
			if currentEntry == entry then -- 1236
				currentIndex = i -- 1237
			end -- 1236
		end -- 1235
		if left then -- 1238
			allClear() -- 1239
			if currentIndex == nil then -- 1240
				currentIndex = #allEntries + 1 -- 1240
			end -- 1240
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1241
		end -- 1238
		if right then -- 1245
			allClear() -- 1246
			if currentIndex == nil then -- 1247
				currentIndex = 0 -- 1247
			end -- 1247
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1248
		end -- 1245
	end -- 1213
	if not showEntry then -- 1252
		return -- 1252
	end -- 1252
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1254
		reloadDevEntry() -- 1258
	end -- 1254
	if initFooter then -- 1259
		initFooter = false -- 1260
	end -- 1259
	local width, height -- 1262
	do -- 1262
		local _obj_0 = App.visualSize -- 1262
		width, height = _obj_0.width, _obj_0.height -- 1262
	end -- 1262
	if isInEntry then -- 1263
		gamepadInputFocused = false -- 1264
	else -- 1266
		SetNextWindowBgAlpha(0.0) -- 1266
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1267
		SetNextWindowPos(Vec2.zero, "Always") -- 1268
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1269
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1270
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1271
					if not gamepadInputFocused then -- 1272
						SetWindowFocus("DoraGamepadInput") -- 1273
						gamepadInputFocused = true -- 1274
					end -- 1272
				end) -- 1271
			end) -- 1270
		end) -- 1269
	end -- 1263
	if isInEntry or showFooter then -- 1276
		SetNextWindowSize(Vec2(width, 50)) -- 1277
		SetNextWindowPos(Vec2(0, height - 50)) -- 1278
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1279
			return PushStyleVar("WindowRounding", 0, function() -- 1280
				return Begin("Footer", windowFlags, function() -- 1281
					Separator() -- 1282
					if iconTex then -- 1283
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1284
							showStats = not showStats -- 1285
							config.showStats = showStats -- 1286
						end -- 1284
						SameLine() -- 1287
						if Button(">_", Vec2(30, 30)) then -- 1288
							showConsole = not showConsole -- 1289
							config.showConsole = showConsole -- 1290
						end -- 1288
					end -- 1283
					if isInEntry and config.updateNotification then -- 1291
						SameLine() -- 1292
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1293
							allClear() -- 1294
							config.updateNotification = false -- 1295
							enterDemoEntry({ -- 1297
								entryName = "SelfUpdater", -- 1297
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1298
							}) -- 1296
						end -- 1293
					end -- 1291
					if not isInEntry then -- 1299
						SameLine() -- 1300
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1301
						local currentIndex = nil -- 1302
						for i, entry in ipairs(allEntries) do -- 1303
							if currentEntry == entry then -- 1304
								currentIndex = i -- 1305
							end -- 1304
						end -- 1303
						if currentIndex then -- 1306
							if currentIndex > 1 then -- 1307
								SameLine() -- 1308
								if Button("<<", Vec2(30, 30)) then -- 1309
									allClear() -- 1310
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1311
								end -- 1309
							end -- 1307
							if currentIndex < #allEntries then -- 1312
								SameLine() -- 1313
								if Button(">>", Vec2(30, 30)) then -- 1314
									allClear() -- 1315
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1316
								end -- 1314
							end -- 1312
						end -- 1306
						SameLine() -- 1317
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1318
							reloadCurrentEntry() -- 1319
						end -- 1318
						if back then -- 1320
							allClear() -- 1321
							isInEntry = true -- 1322
							currentEntry = nil -- 1323
						end -- 1320
					end -- 1299
				end) -- 1281
			end) -- 1280
		end) -- 1279
	end -- 1276
	if isInEntry then -- 1325
		local showURL = true -- 1326
		local webIDEWidth -- 1327
		do -- 1327
			local base -- 1328
			if config.updateNotification then -- 1328
				base = 460 -- 1328
			else -- 1328
				base = 360 -- 1328
			end -- 1328
			local extra -- 1329
			if config.authRequired then -- 1329
				extra = 35 -- 1329
			else -- 1329
				extra = 0 -- 1329
			end -- 1329
			webIDEWidth = base + extra -- 1330
		end -- 1327
		if width < webIDEWidth then -- 1331
			showURL = false -- 1331
		end -- 1331
		SetNextWindowBgAlpha(0.0) -- 1332
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1333
		Begin("Web IDE", displayWindowFlags, function() -- 1334
			local pending = AuthSession.getPending() -- 1335
			local hovered = false -- 1336
			if not pending and showURL then -- 1337
				do -- 1338
					local url -- 1338
					if webStatus ~= nil then -- 1338
						url = webStatus.url -- 1338
					end -- 1338
					if url then -- 1338
						if isDesktop and not config.fullScreen then -- 1339
							if urlClicked then -- 1340
								BeginDisabled(function() -- 1341
									return Button(url) -- 1341
								end) -- 1341
							elseif Button(url) then -- 1342
								urlClicked = once(function() -- 1343
									return sleep(5) -- 1343
								end) -- 1343
								App:openURL("http://localhost:8866") -- 1344
							end -- 1340
						else -- 1346
							TextColored(descColor, url) -- 1346
						end -- 1339
					else -- 1348
						TextColored(descColor, zh and '不可用' or 'not available') -- 1348
					end -- 1338
				end -- 1338
				hovered = IsItemHovered() -- 1349
			else -- 1351
				TextColored(descColor, "(?)") -- 1351
				hovered = IsItemHovered() -- 1352
			end -- 1337
			SameLine() -- 1353
			local themeColor = App.themeColor -- 1354
			if pending then -- 1355
				if not pending.approved then -- 1356
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1357
					local ttl = pending.ttl or 1 -- 1358
					PushStyleColor("Text", themeColor, function() -- 1359
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1360
						hovered = hovered or IsItemHovered() -- 1361
					end) -- 1359
					SameLine() -- 1362
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1363
						AuthSession.approvePending(pending.sessionId) -- 1364
					end -- 1363
					if hovered then -- 1365
						return BeginTooltip(function() -- 1366
							return PushTextWrapPos(280, function() -- 1367
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1368
							end) -- 1367
						end) -- 1366
					end -- 1365
				end -- 1356
			else -- 1370
				if config.authRequired then -- 1370
					PushStyleColor("Text", themeColor, function() -- 1371
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1372
						hovered = hovered or IsItemHovered() -- 1373
					end) -- 1371
					if hovered then -- 1374
						return BeginTooltip(function() -- 1375
							return PushTextWrapPos(280, function() -- 1376
								local url -- 1377
								if webStatus ~= nil then -- 1377
									url = webStatus.url -- 1377
								end -- 1377
								if url then -- 1377
									local address -- 1378
									if showURL then -- 1378
										address = "Web IDE" -- 1378
									else -- 1378
										address = url -- 1378
									end -- 1378
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1379
								else -- 1381
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1381
								end -- 1377
							end) -- 1376
						end) -- 1375
					end -- 1374
				else -- 1383
					if hovered then -- 1383
						return BeginTooltip(function() -- 1384
							return PushTextWrapPos(280, function() -- 1385
								local url -- 1386
								if webStatus ~= nil then -- 1386
									url = webStatus.url -- 1386
								end -- 1386
								if url then -- 1386
									local address -- 1387
									if showURL then -- 1387
										address = "Web IDE" -- 1387
									else -- 1387
										address = url -- 1387
									end -- 1387
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1388
								else -- 1390
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1390
								end -- 1386
							end) -- 1385
						end) -- 1384
					end -- 1383
				end -- 1370
			end -- 1355
		end) -- 1334
	end -- 1325
	if not isInEntry then -- 1392
		SetNextWindowSize(Vec2(50, 50)) -- 1393
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1394
		PushStyleColor("WindowBg", transparant, function() -- 1395
			return Begin("Show", displayWindowFlags, function() -- 1395
				if width >= 370 then -- 1396
					local changed -- 1397
					changed, showFooter = Checkbox("##dev", showFooter) -- 1397
					if changed then -- 1397
						config.showFooter = showFooter -- 1398
					end -- 1397
				end -- 1396
			end) -- 1395
		end) -- 1395
	end -- 1392
	if isInEntry or showFooter then -- 1400
		if showStats then -- 1401
			PushStyleVar("WindowRounding", 0, function() -- 1402
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1403
				SetNextWindowSize(Vec2(0, height - 50)) -- 1404
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1405
				config.showStats = showStats -- 1406
			end) -- 1402
		end -- 1401
		if showConsole then -- 1407
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1408
			return PushStyleVar("WindowRounding", 6, function() -- 1409
				return ShowConsole() -- 1410
			end) -- 1409
		end -- 1407
	end -- 1400
end) -- 1200
local MaxWidth <const> = 960 -- 1412
local toolOpen = false -- 1414
local filterText = nil -- 1415
allEntries.anyEntryMatched = false -- 1416
allEntries.match = function(name) -- 1417
	local res = not filterText or name:lower():match(filterText) -- 1418
	if res then -- 1419
		allEntries.anyEntryMatched = true -- 1419
	end -- 1419
	return res -- 1420
end -- 1417
allEntries.thinSep = function() -- 1422
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1422
		return SeparatorText("") -- 1422
	end) -- 1422
end -- 1422
entryWindow = threadLoop(function() -- 1424
	local connected = syncWebIDEControl() -- 1425
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1427
		if not allEntries.pendingPackagePath then -- 1428
			local path = App:takeReceivedFile() -- 1429
			if path ~= "" then -- 1430
				allEntries.pendingPackagePath = path -- 1430
			end -- 1430
		end -- 1428
		if allEntries.pendingPackagePath then -- 1431
			pendingUIMode = true -- 1431
		end -- 1431
	end -- 1427
	if (pendingUIMode ~= nil) then -- 1433
		local nextMode = pendingUIMode -- 1434
		pendingUIMode = nil -- 1435
		applyUIMode(nextMode) -- 1436
	end -- 1433
	if mobileMode and not connected then -- 1437
		if isInEntry and not feedHost then -- 1438
			applyUIMode(true) -- 1438
		end -- 1438
		return -- 1439
	end -- 1437
	if App.fpsLimited ~= config.fpsLimited then -- 1440
		config.fpsLimited = App.fpsLimited -- 1441
	end -- 1440
	if App.targetFPS ~= config.targetFPS then -- 1442
		config.targetFPS = App.targetFPS -- 1443
	end -- 1442
	if View.vsync ~= config.vsync then -- 1444
		config.vsync = View.vsync -- 1445
	end -- 1444
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1446
		config.fixedFPS = Director.scheduler.fixedFPS -- 1447
	end -- 1446
	if Director.profilerSending ~= config.webProfiler then -- 1448
		config.webProfiler = Director.profilerSending -- 1449
	end -- 1448
	if urlClicked then -- 1450
		local _, result = coroutine.resume(urlClicked) -- 1451
		if result then -- 1452
			coroutine.close(urlClicked) -- 1453
			urlClicked = nil -- 1454
		end -- 1452
	end -- 1450
	if not isInEntry then -- 1455
		return -- 1455
	end -- 1455
	local zh = useChinese -- 1456
	local themeColor = App.themeColor -- 1457
	if connected then -- 1458
		local width, height -- 1459
		do -- 1459
			local _obj_0 = App.visualSize -- 1459
			width, height = _obj_0.width, _obj_0.height -- 1459
		end -- 1459
		SetNextWindowBgAlpha(0.5) -- 1460
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1461
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1462
			Separator() -- 1463
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1464
			if iconTex then -- 1465
				Image(icon, Vec2(24, 24)) -- 1466
				SameLine() -- 1467
			end -- 1465
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1468
			TextColored(descColor, slogon) -- 1469
			return Separator() -- 1470
		end) -- 1462
		return -- 1471
	end -- 1458
	if not showEntry then -- 1472
		return -- 1472
	end -- 1472
	local fullWidth, height -- 1474
	do -- 1474
		local _obj_0 = App.visualSize -- 1474
		fullWidth, height = _obj_0.width, _obj_0.height -- 1474
	end -- 1474
	local width = math.min(MaxWidth, fullWidth) -- 1475
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1476
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1477
	SetNextWindowPos(Vec2.zero) -- 1478
	SetNextWindowBgAlpha(0) -- 1479
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1480
	do -- 1481
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1482
			return Begin("Dora Dev", windowFlags, function() -- 1483
				Dummy(Vec2(fullWidth - 20, 0)) -- 1484
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1485
				SameLine() -- 1486
				if Button(zh and "Go 模式" or "Go Mode") then -- 1487
					setUIMode("mobile") -- 1488
				end -- 1487
				if fullWidth >= 540 then -- 1489
					SameLine() -- 1490
					Dummy(Vec2(fullWidth - 540, 0)) -- 1491
					SameLine() -- 1492
					SetNextItemWidth(zh and -95 or -140) -- 1493
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1494
						"AutoSelectAll" -- 1494
					}) then -- 1494
						config.filter = filterBuf.text -- 1495
					end -- 1494
					SameLine() -- 1496
					if Button(zh and '下载' or 'Download') then -- 1497
						allClear() -- 1498
						enterDemoEntry({ -- 1500
							entryName = "ResourceDownloader", -- 1500
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1501
						}) -- 1499
					end -- 1497
				end -- 1489
				return Separator() -- 1502
			end) -- 1483
		end) -- 1482
	end -- 1481
	allEntries.anyEntryMatched = false -- 1504
	SetNextWindowPos(Vec2(0, 50)) -- 1505
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1506
	do -- 1507
		return PushStyleColor("WindowBg", transparant, function() -- 1508
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1509
				return PushStyleVar("Alpha", 1, function() -- 1510
					return Begin("Content", windowFlags, function() -- 1511
						local DemoViewWidth <const> = 220 -- 1512
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1513
						if filterText then -- 1514
							filterText = filterText:lower() -- 1514
						end -- 1514
						if #gamesInDev > 0 then -- 1515
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1516
							Columns(columns, false) -- 1517
							local realViewWidth = GetColumnWidth() - 50 -- 1518
							for _index_0 = 1, #gamesInDev do -- 1519
								local game = gamesInDev[_index_0] -- 1519
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1520
								local displayName -- 1529
								if repo then -- 1529
									if zh then -- 1530
										displayName = repo.title.zh -- 1530
									else -- 1530
										displayName = repo.title.en -- 1530
									end -- 1530
								end -- 1529
								if displayName == nil then -- 1531
									displayName = gameName -- 1531
								end -- 1531
								if allEntries.match(displayName) then -- 1532
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1533
									SameLine() -- 1534
									TextWrapped(displayName) -- 1535
									if columns > 1 then -- 1536
										if bannerFile and bannerTex then -- 1537
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1538
											local displayWidth <const> = realViewWidth -- 1539
											texHeight = displayWidth * texHeight / texWidth -- 1540
											texWidth = displayWidth -- 1541
											Dummy(Vec2.zero) -- 1542
											SameLine() -- 1543
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1544
										end -- 1537
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1545
											enterDemoEntry(game) -- 1546
										end -- 1545
									else -- 1548
										if bannerFile and bannerTex then -- 1548
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1549
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1550
											local sizing = 0.8 -- 1551
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1552
											texWidth = displayWidth * sizing -- 1553
											if texWidth > 500 then -- 1554
												sizing = 0.6 -- 1555
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1556
												texWidth = displayWidth * sizing -- 1557
											end -- 1554
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1558
											Dummy(Vec2(padding, 0)) -- 1559
											SameLine() -- 1560
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1561
										end -- 1548
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1562
											enterDemoEntry(game) -- 1563
										end -- 1562
									end -- 1536
									if #tests == 0 and #examples == 0 then -- 1564
										allEntries.thinSep() -- 1565
									end -- 1564
									NextColumn() -- 1566
								end -- 1532
								local showSep = false -- 1567
								if #examples > 0 then -- 1568
									local showExample = false -- 1569
									for _index_1 = 1, #examples do -- 1570
										local _des_0 = examples[_index_1] -- 1570
										local entryName = _des_0.entryName -- 1570
										if allEntries.match(entryName) then -- 1571
											showExample = true -- 1571
											break -- 1571
										end -- 1571
									end -- 1570
									if showExample then -- 1572
										showSep = true -- 1573
										Columns(1, false) -- 1574
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1575
										SameLine() -- 1576
										local opened -- 1577
										if (filterText ~= nil) then -- 1577
											opened = showExample -- 1577
										else -- 1577
											opened = false -- 1577
										end -- 1577
										if game.exampleOpen == nil then -- 1578
											game.exampleOpen = opened -- 1578
										end -- 1578
										SetNextItemOpen(game.exampleOpen) -- 1579
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1580
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1581
												Columns(maxColumns, false) -- 1582
												for _index_1 = 1, #examples do -- 1583
													local example = examples[_index_1] -- 1583
													local entryName = example.entryName -- 1584
													if not allEntries.match(entryName) then -- 1585
														goto _continue_0 -- 1585
													end -- 1585
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1586
														if Button(entryName, Vec2(-1, 40)) then -- 1587
															enterDemoEntry(example) -- 1588
														end -- 1587
														return NextColumn() -- 1589
													end) -- 1586
													opened = true -- 1590
													::_continue_0:: -- 1584
												end -- 1583
											end) -- 1581
										end) -- 1580
										game.exampleOpen = opened -- 1591
									end -- 1572
								end -- 1568
								if #tests > 0 then -- 1592
									local showTest = false -- 1593
									for _index_1 = 1, #tests do -- 1594
										local _des_0 = tests[_index_1] -- 1594
										local entryName = _des_0.entryName -- 1594
										if allEntries.match(entryName) then -- 1595
											showTest = true -- 1595
											break -- 1595
										end -- 1595
									end -- 1594
									if showTest then -- 1596
										showSep = true -- 1597
										Columns(1, false) -- 1598
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1599
										SameLine() -- 1600
										local opened -- 1601
										if (filterText ~= nil) then -- 1601
											opened = showTest -- 1601
										else -- 1601
											opened = false -- 1601
										end -- 1601
										if game.testOpen == nil then -- 1602
											game.testOpen = opened -- 1602
										end -- 1602
										SetNextItemOpen(game.testOpen) -- 1603
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1604
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1605
												Columns(maxColumns, false) -- 1606
												for _index_1 = 1, #tests do -- 1607
													local test = tests[_index_1] -- 1607
													local entryName = test.entryName -- 1608
													if not allEntries.match(entryName) then -- 1609
														goto _continue_0 -- 1609
													end -- 1609
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1610
														if Button(entryName, Vec2(-1, 40)) then -- 1611
															enterDemoEntry(test) -- 1612
														end -- 1611
														return NextColumn() -- 1613
													end) -- 1610
													opened = true -- 1614
													::_continue_0:: -- 1608
												end -- 1607
											end) -- 1605
										end) -- 1604
										game.testOpen = opened -- 1615
									end -- 1596
								end -- 1592
								if showSep then -- 1616
									Columns(1, false) -- 1617
									allEntries.thinSep() -- 1618
									Columns(columns, false) -- 1619
								end -- 1616
							end -- 1519
						end -- 1515
						if #doraTools > 0 then -- 1620
							local showTool = false -- 1621
							for _index_0 = 1, #doraTools do -- 1622
								local _des_0 = doraTools[_index_0] -- 1622
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1622
								local displayName -- 1623
								if repo then -- 1623
									if zh then -- 1624
										displayName = repo.title.zh -- 1624
									else -- 1624
										displayName = repo.title.en -- 1624
									end -- 1624
								end -- 1623
								if displayName == nil then -- 1625
									displayName = entryName -- 1625
								end -- 1625
								if allEntries.match(displayName) then -- 1626
									showTool = true -- 1626
									break -- 1626
								end -- 1626
							end -- 1622
							if not showTool then -- 1627
								goto endEntry -- 1627
							end -- 1627
							Columns(1, false) -- 1628
							TextColored(themeColor, "Dora SSR:") -- 1629
							SameLine() -- 1630
							Text(zh and "开发支持" or "Development Support") -- 1631
							Separator() -- 1632
							if #doraTools > 0 then -- 1633
								local opened -- 1634
								if (filterText ~= nil) then -- 1634
									opened = showTool -- 1634
								else -- 1634
									opened = false -- 1634
								end -- 1634
								SetNextItemOpen(toolOpen) -- 1635
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1636
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1637
										Columns(maxColumns, false) -- 1638
										for _index_0 = 1, #doraTools do -- 1639
											local tool = doraTools[_index_0] -- 1639
											local entryName, repo = tool.entryName, tool.repo -- 1640
											local displayName -- 1641
											if repo then -- 1641
												if zh then -- 1642
													displayName = repo.title.zh -- 1642
												else -- 1642
													displayName = repo.title.en -- 1642
												end -- 1642
											end -- 1641
											if displayName == nil then -- 1643
												displayName = entryName -- 1643
											end -- 1643
											if not allEntries.match(displayName) then -- 1644
												goto _continue_0 -- 1644
											end -- 1644
											if Button(displayName, Vec2(-1, 40)) then -- 1645
												enterDemoEntry(tool) -- 1646
											end -- 1645
											NextColumn() -- 1647
											::_continue_0:: -- 1640
										end -- 1639
										Columns(1, false) -- 1648
										opened = true -- 1649
									end) -- 1637
								end) -- 1636
								toolOpen = opened -- 1650
							end -- 1633
						end -- 1620
						::endEntry:: -- 1651
						if not allEntries.anyEntryMatched then -- 1652
							SetNextWindowBgAlpha(0) -- 1653
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1654
							Begin("Entries Not Found", displayWindowFlags, function() -- 1655
								Separator() -- 1656
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1657
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1658
								return Separator() -- 1659
							end) -- 1655
						end -- 1652
						Columns(1, false) -- 1660
						Dummy(Vec2(100, 80)) -- 1661
						return ScrollWhenDraggingOnVoid() -- 1662
					end) -- 1511
				end) -- 1510
			end) -- 1509
		end) -- 1508
	end -- 1507
end) -- 1424
do -- 1667
	local sceneModuleCache = moduleCache -- 1668
	moduleCache = { } -- 1669
	webStatus = oldRequire("Script.Dev.WebServer") -- 1670
	moduleCache = sceneModuleCache -- 1671
end -- 1667
local _anon_func_7 = function(saved) -- 1694
	local _val_0 = saved.kind -- 1694
	return "local" == _val_0 or "discover" == _val_0 -- 1694
end -- 1694
local _anon_func_8 = function(saved) -- 1698
	local _val_0 = saved.activeTab -- 1698
	return "local" == _val_0 or "discover" == _val_0 -- 1698
end -- 1698
startMobileUI = function() -- 1673
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1674
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1675
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1676
	local getMobileFeedResources -- 1677
	do -- 1677
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1677
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1677
	end -- 1677
	local loadCachedCatalog -- 1678
	do -- 1678
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1678
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1678
	end -- 1678
	local getResourceInstallPath -- 1679
	do -- 1679
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1679
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1679
	end -- 1679
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1680
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1681
	local feedOptions = nil -- 1682
	local mobileLaunchErrors = { } -- 1683
	local withMobileLaunchErrors -- 1684
	withMobileLaunchErrors = function(items) -- 1684
		for _index_0 = 1, #items do -- 1685
			local item = items[_index_0] -- 1685
			item.launchError = mobileLaunchErrors[item.id] -- 1686
		end -- 1685
		return items -- 1687
	end -- 1684
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1688
	local loadRememberedMobileFeedState -- 1689
	loadRememberedMobileFeedState = function() -- 1689
		local raw = rememberedMobileFeedData -- 1690
		if not (type(raw) == "string" and raw ~= "") then -- 1691
			return -- 1691
		end -- 1691
		local ok, saved = pcall(json.decode, raw) -- 1692
		if not (ok and type(saved) == "table") then -- 1693
			return -- 1693
		end -- 1693
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1694
			local state = { -- 1695
				activeTab = saved.kind -- 1695
			} -- 1695
			state[saved.kind] = saved -- 1696
			return state -- 1697
		end -- 1694
		local state = { -- 1698
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1698
		} -- 1698
		local _list_0 = { -- 1699
			"local", -- 1699
			"discover" -- 1699
		} -- 1699
		for _index_0 = 1, #_list_0 do -- 1699
			local kind = _list_0[_index_0] -- 1699
			local entry = saved[kind] -- 1700
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1701
				state[kind] = entry -- 1701
			end -- 1701
		end -- 1699
		return state -- 1702
	end -- 1689
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1703
		activeTab = "local" -- 1703
	} -- 1703
	local rememberMobileFeedEntry -- 1704
	rememberMobileFeedEntry = function(entry) -- 1704
		rememberedMobileFeedState.activeTab = entry.kind -- 1705
		rememberedMobileFeedState[entry.kind] = { -- 1707
			id = entry.id, -- 1707
			kind = entry.kind, -- 1708
			workDir = entry.workDir, -- 1709
			fileName = entry.fileName -- 1710
		} -- 1706
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1712
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1713
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1714
			rememberedMobileFeedData -- 1714
		}) -- 1714
	end -- 1704
	local restartMobileFeed -- 1715
	restartMobileFeed = function(entry) -- 1715
		if feedHost then -- 1716
			feedHost:removeFromParent(true) -- 1716
		end -- 1716
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1717
		local initialEntries = { } -- 1718
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1719
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1720
		feedOptions.initialEntries = initialEntries -- 1721
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1722
	end -- 1715
	local startMobilePlay -- 1723
	startMobilePlay = function(entry) -- 1723
		if HttpServer.wsConnectionCount > 0 then -- 1724
			return -- 1724
		end -- 1724
		local originFeed = feedHost -- 1725
		if remixHost then -- 1726
			remixHost:removeFromParent(true) -- 1726
		end -- 1726
		remixHost = nil -- 1727
		mobileLaunchErrors[entry.id] = nil -- 1728
		entry.launchError = nil -- 1729
		local playActive = true -- 1730
		local restoreMobileFeed -- 1731
		restoreMobileFeed = function() -- 1731
			if not playActive then -- 1732
				return -- 1732
			end -- 1732
			playActive = false -- 1733
			allClear() -- 1734
			isInEntry = true -- 1735
			currentEntry = nil -- 1736
			return restartMobileFeed(entry) -- 1737
		end -- 1731
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1739
			onExit = function() -- 1739
				return restoreMobileFeed() -- 1739
			end, -- 1739
			onRuntimeError = function() -- 1740
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1741
				return restoreMobileFeed() -- 1742
			end -- 1740
		})) -- 1738
		return thread(function() -- 1744
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1748
			if not playActive then -- 1749
				return -- 1749
			end -- 1749
			if success then -- 1750
				if originFeed and originFeed.parent then -- 1751
					originFeed.visible = false -- 1751
				end -- 1751
				return -- 1752
			end -- 1750
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1753
			return restoreMobileFeed() -- 1754
		end) -- 1744
	end -- 1723
	feedOptions = { -- 1756
		takeReceivedFile = function() -- 1756
			if allEntries.pendingPackagePath then -- 1757
				local path = allEntries.pendingPackagePath -- 1758
				allEntries.pendingPackagePath = nil -- 1759
				return path -- 1760
			end -- 1757
			return App:takeReceivedFile() -- 1761
		end, -- 1756
		onSwitchMode = function() -- 1762
			if HttpServer.wsConnectionCount == 0 then -- 1762
				pendingUIMode = false -- 1762
			end -- 1762
		end, -- 1762
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1763
		getLocalEntries = function(importedProjectPath) -- 1764
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1765
			feedOptions.dirtyProjectPath = nil -- 1766
			return withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1767
		end, -- 1764
		syncDiscover = function(onProgress, onDone) -- 1768
			return mobileCatalog.syncMobileCatalog(onProgress, onDone) -- 1768
		end, -- 1768
		getDiscoverEntries = function() -- 1769
			local cached = loadCachedCatalog() -- 1770
			if not (cached.success and cached.snapshot) then -- 1771
				return { } -- 1771
			end -- 1771
			local items = { } -- 1772
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1773
			for _index_0 = 1, #_list_0 do -- 1773
				local resource = _list_0[_index_0] -- 1773
				local installed = lifecycle.isMobileResourceReady(resource) -- 1774
				local installPath = getResourceInstallPath(resource.id) -- 1775
				items[#items + 1] = { -- 1777
					id = resource.id, -- 1777
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1778
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1779
					kind = "discover", -- 1780
					bannerFile = resource.bannerPath, -- 1781
					workDir = installed and installPath or nil, -- 1782
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1783
					installed = installed, -- 1784
					resource = resource, -- 1785
					catalogCommit = cached.snapshot.commit, -- 1786
					launchError = mobileLaunchErrors[resource.id] -- 1787
				} -- 1776
			end -- 1773
			return items -- 1789
		end, -- 1769
		prepare = function(entry, repairIncomplete, onProgress, onDone) -- 1790
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1791
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1792
			end), repairIncomplete) -- 1791
		end, -- 1790
		createProject = function(name) -- 1794
			local result = projectCreate.createMobileTypeScriptProject(name) -- 1795
			if not result.success then -- 1796
				return result -- 1796
			end -- 1796
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1797
			for _index_0 = 1, #_list_0 do -- 1797
				local entry = _list_0[_index_0] -- 1797
				if entry.workDir == result.workDir then -- 1798
					return { -- 1799
						success = true, -- 1799
						entry = entry -- 1799
					} -- 1799
				end -- 1798
			end -- 1797
			return { -- 1800
				success = false, -- 1800
				error = "created-project-not-found" -- 1800
			} -- 1800
		end, -- 1794
		onPlay = function(entry) -- 1801
			return startMobilePlay(entry) -- 1801
		end, -- 1801
		onRemix = function(entry) -- 1802
			if HttpServer.wsConnectionCount > 0 then -- 1803
				return -- 1803
			end -- 1803
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1804
			local originFeed = feedHost -- 1805
			feedHost.visible = false -- 1806
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1808
				entry = entry, -- 1808
				onProjectChanged = function(current) -- 1809
					feedOptions.dirtyProjectPath = current.workDir -- 1809
				end, -- 1809
				onBack = function() -- 1810
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1811
						originFeed:emit("RestoreFeedEntry", entry) -- 1812
						originFeed.visible = true -- 1813
					end -- 1811
				end, -- 1810
				onPlay = function(current) -- 1814
					return startMobilePlay(current) -- 1814
				end -- 1814
			})) -- 1807
		end -- 1802
	} -- 1755
	return restartMobileFeed() -- 1817
end -- 1673
if mobileMode then -- 1819
	applyUIMode(true) -- 1819
end -- 1819
return _module_0 -- 1
