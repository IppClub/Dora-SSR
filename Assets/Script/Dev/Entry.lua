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
local Log <const> = Log -- 11
local tostring <const> = tostring -- 11
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
local string <const> = string -- 11
local print <const> = print -- 11
local xml <const> = xml -- 11
local teal <const> = teal -- 11
local wait <const> = wait -- 11
local pcall <const> = pcall -- 11
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
local Begin <const> = Begin -- 11
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
				if writablePath ~= "" and Content:exist(writablePath) and Content:isdir(writablePath) then -- 46
					Content.writablePath = writablePath -- 47
				else -- 49
					Log("Warning", "saved writable path \"" .. tostring(writablePath) .. "\" is unavailable; using \"" .. tostring(Content.writablePath) .. "\" instead") -- 49
					if not DB:exec("update Config set value_str = ? where name = ?", { -- 50
						Content.writablePath, -- 50
						"writablePath" -- 50
					}) then -- 50
						Log("Warning", "failed to persist the fallback writable path") -- 51
					end -- 50
				end -- 46
			end -- 45
		end -- 44
	end -- 43
end -- 38
local Config = require("Config") -- 53
if App.platform == "Emscripten" then -- 55
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 55
end -- 55
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 57
config:load() -- 92
if not (config.writablePath ~= nil) then -- 94
	config.writablePath = Content.appPath -- 95
end -- 94
if not (config.webIDEConnected ~= nil) then -- 97
	config.webIDEConnected = false -- 98
end -- 97
if (config.fpsLimited ~= nil) then -- 100
	App.fpsLimited = config.fpsLimited -- 101
else -- 103
	config.fpsLimited = App.fpsLimited -- 103
end -- 100
if (config.targetFPS ~= nil) then -- 105
	App.targetFPS = math.floor(config.targetFPS) -- 106
else -- 108
	config.targetFPS = App.targetFPS -- 108
end -- 105
if (config.vsync ~= nil) then -- 110
	View.vsync = config.vsync -- 111
else -- 113
	config.vsync = View.vsync -- 113
end -- 110
if (config.fixedFPS ~= nil) then -- 115
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 116
else -- 118
	config.fixedFPS = Director.scheduler.fixedFPS -- 118
end -- 115
if not (config.showPreview ~= nil) then -- 120
	config.showPreview = true -- 121
end -- 120
if not (config.mobileFeed ~= nil) then -- 123
	local _val_0 = App.platform -- 124
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 124
end -- 123
if not (config.webIDETourCompleted ~= nil) then -- 126
	config.webIDETourCompleted = false -- 127
end -- 126
if not (config.authRequired ~= nil) then -- 129
	local _val_0 = App.platform -- 130
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 130
end -- 129
HttpServer.authRequired = config.authRequired -- 131
local showEntry = true -- 133
isDesktop = false -- 135
if (function() -- 136
	local _val_0 = App.platform -- 136
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 136
end)() then -- 136
	isDesktop = true -- 137
	if config.fullScreen then -- 138
		App.fullScreen = true -- 139
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 140
		local size = Size(config.winWidth, config.winHeight) -- 141
		if App.winSize ~= size then -- 142
			App.winSize = size -- 143
		end -- 142
		local winX, winY -- 144
		do -- 144
			local _obj_0 = App.winPosition -- 144
			winX, winY = _obj_0.x, _obj_0.y -- 144
		end -- 144
		if (config.winX ~= nil) then -- 145
			winX = config.winX -- 146
		else -- 148
			config.winX = -1 -- 148
		end -- 145
		if (config.winY ~= nil) then -- 149
			winY = config.winY -- 150
		else -- 152
			config.winY = -1 -- 152
		end -- 149
		App.winPosition = Vec2(winX, winY) -- 153
	end -- 138
	if (config.alwaysOnTop ~= nil) then -- 154
		App.alwaysOnTop = config.alwaysOnTop -- 155
	else -- 157
		config.alwaysOnTop = false -- 157
	end -- 154
	if (config.virtualGamepadEnabled ~= nil) then -- 158
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 159
	else -- 161
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 161
	end -- 158
end -- 136
if (config.themeColor ~= nil) then -- 163
	App.themeColor = Color(config.themeColor) -- 164
else -- 166
	config.themeColor = App.themeColor:toARGB() -- 166
end -- 163
if not (config.locale ~= nil) then -- 168
	config.locale = App.locale -- 169
end -- 168
local showStats = false -- 171
if (config.showStats ~= nil) then -- 172
	showStats = config.showStats -- 173
else -- 175
	config.showStats = showStats -- 175
end -- 172
local showConsole = false -- 177
if (config.showConsole ~= nil) then -- 178
	showConsole = config.showConsole -- 179
else -- 181
	config.showConsole = showConsole -- 181
end -- 178
local showFooter = true -- 183
if (config.showFooter ~= nil) then -- 184
	showFooter = config.showFooter -- 185
else -- 187
	config.showFooter = showFooter -- 187
end -- 184
local setFooterVisible -- 189
setFooterVisible = function(visible) -- 189
	if visible == nil then -- 189
		visible = true -- 189
	end -- 189
	showFooter = visible -- 190
	config.showFooter = showFooter -- 191
end -- 189
_module_0["setFooterVisible"] = setFooterVisible -- 189
local filterBuf = Buffer(20) -- 193
if (config.filter ~= nil) then -- 194
	filterBuf.text = config.filter -- 195
else -- 197
	config.filter = "" -- 197
end -- 194
local engineDev = false -- 199
if (config.engineDev ~= nil) then -- 200
	engineDev = config.engineDev -- 201
else -- 203
	config.engineDev = engineDev -- 203
end -- 200
if (config.webProfiler ~= nil) then -- 205
	Director.profilerSending = config.webProfiler -- 206
else -- 208
	config.webProfiler = true -- 208
	Director.profilerSending = true -- 209
end -- 205
if not (config.drawerWidth ~= nil) then -- 211
	config.drawerWidth = 200 -- 212
end -- 211
_module_0.getConfig = function() -- 214
	return config -- 214
end -- 214
_module_0.getEngineDev = function() -- 215
	if not App.debugging then -- 216
		return false -- 216
	end -- 216
	return config.engineDev -- 217
end -- 215
local _anon_func_0 = function() -- 222
	local _val_0 = App.platform -- 222
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 222
end -- 222
_module_0.connectWebIDE = function() -- 219
	if not config.webIDEConnected then -- 220
		config.webIDEConnected = true -- 221
		if _anon_func_0() then -- 222
			local ratio = App.winSize.width / App.visualSize.width -- 223
			App.winSize = Size(640 * ratio, 480 * ratio) -- 224
		end -- 222
	end -- 220
end -- 219
local updateCheck -- 226
updateCheck = function() -- 226
	return thread(function() -- 226
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 227
		if res then -- 227
			local data = json.decode(res) -- 228
			if data then -- 228
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 229
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 230
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 231
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 232
				if na < a then -- 233
					goto not_new_version -- 234
				end -- 233
				if na == a then -- 235
					if nb < b then -- 236
						goto not_new_version -- 237
					end -- 236
					if nb == b then -- 238
						if nc < c then -- 239
							goto not_new_version -- 240
						end -- 239
						if nc == c then -- 241
							goto not_new_version -- 242
						end -- 241
					end -- 238
				end -- 235
				config.updateNotification = true -- 243
				::not_new_version:: -- 244
				config.lastUpdateCheck = os.time() -- 245
			end -- 228
		end -- 227
	end) -- 226
end -- 226
if (config.lastUpdateCheck ~= nil) then -- 247
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 248
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 249
		updateCheck() -- 250
	end -- 249
else -- 252
	updateCheck() -- 252
end -- 247
local Set, Struct, LintYueGlobals, GSplit -- 254
do -- 254
	local _obj_0 = require("Utils") -- 254
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 254
end -- 254
local yueext = yue.options.extension -- 255
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 257
local building = false -- 259
local getAllFiles -- 261
getAllFiles = function(path, exts, recursive) -- 261
	if recursive == nil then -- 261
		recursive = true -- 261
	end -- 261
	local filters = Set(exts) -- 262
	local files -- 263
	if recursive then -- 263
		files = Content:getAllFiles(path) -- 264
	else -- 266
		files = Content:getFiles(path) -- 266
	end -- 263
	local _accum_0 = { } -- 267
	local _len_0 = 1 -- 267
	for _index_0 = 1, #files do -- 267
		local file = files[_index_0] -- 267
		if not filters[Path:getExt(file)] then -- 268
			goto _continue_0 -- 268
		end -- 268
		_accum_0[_len_0] = file -- 269
		_len_0 = _len_0 + 1 -- 268
		::_continue_0:: -- 268
	end -- 267
	return _accum_0 -- 267
end -- 261
_module_0["getAllFiles"] = getAllFiles -- 261
local getFileEntries -- 271
getFileEntries = function(path, recursive, excludeFiles) -- 271
	if recursive == nil then -- 271
		recursive = true -- 271
	end -- 271
	if excludeFiles == nil then -- 271
		excludeFiles = nil -- 271
	end -- 271
	local entries = { } -- 272
	local excludes -- 273
	if excludeFiles then -- 273
		excludes = Set(excludeFiles) -- 274
	end -- 273
	local _list_0 = getAllFiles(path, { -- 275
		"lua", -- 275
		"xml", -- 275
		yueext, -- 275
		"tl" -- 275
	}, recursive) -- 275
	for _index_0 = 1, #_list_0 do -- 275
		local file = _list_0[_index_0] -- 275
		local entryName = Path:getName(file) -- 276
		if excludes and excludes[entryName] then -- 277
			goto _continue_0 -- 278
		end -- 277
		local fileName = Path:replaceExt(file, "") -- 279
		fileName = Path(path, fileName) -- 280
		local entryAdded -- 281
		for _index_1 = 1, #entries do -- 281
			local _des_0 = entries[_index_1] -- 281
			local ename, efile = _des_0.entryName, _des_0.fileName -- 281
			if entryName == ename and efile == fileName then -- 282
				entryAdded = true -- 282
				break -- 282
			end -- 282
		end -- 281
		if entryAdded then -- 283
			goto _continue_0 -- 283
		end -- 283
		local entry = { -- 284
			entryName = entryName, -- 284
			fileName = fileName -- 284
		} -- 284
		entries[#entries + 1] = entry -- 285
		::_continue_0:: -- 276
	end -- 275
	table.sort(entries, function(a, b) -- 286
		return a.entryName < b.entryName -- 286
	end) -- 286
	return entries -- 287
end -- 271
local allEntries = { -- 289
	dirty = { }, -- 289
	hasDirty = false, -- 289
	runId = 0 -- 289
} -- 289
allEntries.scanDir = function(path, dir, noPreview) -- 291
	if noPreview == nil then -- 291
		noPreview = false -- 291
	end -- 291
	local entries = { } -- 292
	if not dir:match("^%.") then -- 293
		local _list_0 = getAllFiles(Path(path, dir), { -- 294
			"lua", -- 294
			"xml", -- 294
			yueext, -- 294
			"tl", -- 294
			"wasm" -- 294
		}) -- 294
		for _index_0 = 1, #_list_0 do -- 294
			local file = _list_0[_index_0] -- 294
			if "init" == Path:getName(file):lower() then -- 295
				local fileName = Path:replaceExt(file, "") -- 296
				fileName = Path(path, dir, fileName) -- 297
				local projectPath = Path:getPath(fileName) -- 298
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 299
				local repo = nil -- 300
				if Content:exist(repoFile) then -- 301
					local str = Content:load(repoFile) -- 302
					if str then -- 302
						repo = json.decode(str) -- 303
					end -- 302
				end -- 301
				local entryName = Path:getName(projectPath) -- 304
				local entryAdded -- 305
				for _index_1 = 1, #entries do -- 305
					local _des_0 = entries[_index_1] -- 305
					local ename, efile = _des_0.entryName, _des_0.fileName -- 305
					if entryName == ename and efile == fileName then -- 306
						entryAdded = true -- 306
						break -- 306
					end -- 306
				end -- 305
				if entryAdded then -- 307
					goto _continue_0 -- 307
				end -- 307
				local examples = { } -- 308
				local tests = { } -- 309
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 310
				if Content:exist(examplePath) then -- 311
					local _list_1 = getFileEntries(examplePath) -- 312
					for _index_1 = 1, #_list_1 do -- 312
						local _des_0 = _list_1[_index_1] -- 312
						local name, ePath = _des_0.entryName, _des_0.fileName -- 312
						local entry = { -- 314
							entryName = name, -- 314
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 315
							workDir = projectPath -- 316
						} -- 313
						examples[#examples + 1] = entry -- 318
					end -- 312
				end -- 311
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 319
				if Content:exist(testPath) then -- 320
					local _list_1 = getFileEntries(testPath) -- 321
					for _index_1 = 1, #_list_1 do -- 321
						local _des_0 = _list_1[_index_1] -- 321
						local name, tPath = _des_0.entryName, _des_0.fileName -- 321
						local entry = { -- 323
							entryName = name, -- 323
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 324
							workDir = projectPath -- 325
						} -- 322
						tests[#tests + 1] = entry -- 327
					end -- 321
				end -- 320
				local entry = { -- 328
					entryName = entryName, -- 328
					fileName = fileName, -- 328
					projectPath = projectPath, -- 328
					examples = examples, -- 328
					tests = tests, -- 328
					repo = repo -- 328
				} -- 328
				local bannerFile -- 329
				do -- 329
					local _val_0 -- 329
					repeat -- 329
						if noPreview then -- 330
							_val_0 = nil -- 330
							break -- 330
						end -- 330
						if not config.showPreview then -- 331
							_val_0 = nil -- 331
							break -- 331
						end -- 331
						local f = Path(projectPath, ".dora", "banner.jpg") -- 332
						if Content:exist(f) then -- 333
							_val_0 = f -- 333
							break -- 333
						end -- 333
						f = Path(projectPath, ".dora", "banner.png") -- 334
						if Content:exist(f) then -- 335
							_val_0 = f -- 335
							break -- 335
						end -- 335
						f = Path(projectPath, "Image", "banner.jpg") -- 336
						if Content:exist(f) then -- 337
							_val_0 = f -- 337
							break -- 337
						end -- 337
						f = Path(projectPath, "Image", "banner.png") -- 338
						if Content:exist(f) then -- 339
							_val_0 = f -- 339
							break -- 339
						end -- 339
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 340
						if Content:exist(f) then -- 341
							_val_0 = f -- 341
							break -- 341
						end -- 341
					until true -- 329
					bannerFile = _val_0 -- 329
				end -- 329
				if bannerFile then -- 343
					entry.bannerFile = bannerFile -- 346
					thread(function() -- 347
						if Cache:loadAsync(bannerFile) then -- 348
							local bannerTex = Texture2D(bannerFile) -- 349
							if bannerTex then -- 349
								entry.bannerTex = bannerTex -- 350
							end -- 349
						end -- 348
					end) -- 347
				end -- 343
				entries[#entries + 1] = entry -- 351
			end -- 295
			::_continue_0:: -- 295
		end -- 294
	end -- 293
	return entries -- 352
end -- 291
local getProjectEntries -- 354
getProjectEntries = function(path, noPreview) -- 354
	if noPreview == nil then -- 354
		noPreview = false -- 354
	end -- 354
	local entries = { } -- 355
	local _list_0 = Content:getDirs(path) -- 356
	for _index_0 = 1, #_list_0 do -- 356
		local dir = _list_0[_index_0] -- 356
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 357
		for _index_1 = 1, #_list_1 do -- 357
			local entry = _list_1[_index_1] -- 357
			entries[#entries + 1] = entry -- 358
		end -- 357
	end -- 356
	table.sort(entries, function(a, b) -- 359
		return a.entryName < b.entryName -- 359
	end) -- 359
	return entries -- 360
end -- 354
_module_0["getProjectEntries"] = getProjectEntries -- 354
local gamesInDev -- 362
local doraTools -- 363
local isToolEntry -- 365
isToolEntry = function(entry) -- 365
	do -- 366
		local _type_0 = type(entry) -- 366
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 366
		if _tab_0 then -- 366
			local categories -- 366
			do -- 366
				local _obj_0 = entry.repo -- 366
				local _type_1 = type(_obj_0) -- 366
				if "table" == _type_1 or "userdata" == _type_1 then -- 366
					categories = _obj_0.categories -- 366
				end -- 366
			end -- 366
			if categories ~= nil then -- 366
				for _index_0 = 1, #categories do -- 367
					local category = categories[_index_0] -- 367
					if "string" == type(category) and category:lower() == "tool" then -- 368
						return true -- 369
					end -- 368
				end -- 367
			end -- 366
		end -- 366
	end -- 366
	return false -- 365
end -- 365
local getEntryTitle -- 371
getEntryTitle = function(entry) -- 371
	local title -- 372
	do -- 372
		local repo = entry.repo -- 372
		if repo then -- 372
			if repo.title and "table" == type(repo.title) then -- 373
				if useChinese then -- 374
					title = repo.title.zh -- 374
				else -- 374
					title = repo.title.en -- 374
				end -- 374
			end -- 373
		end -- 372
	end -- 372
	if title ~= nil then -- 375
		return title -- 375
	else -- 375
		return entry.entryName -- 375
	end -- 375
end -- 371
allEntries.rebuildEntries = function() -- 377
	gamesInDev = { } -- 378
	do -- 379
		local _accum_0 = { } -- 379
		local _len_0 = 1 -- 379
		local _list_0 = allEntries.builtinTools -- 379
		for _index_0 = 1, #_list_0 do -- 379
			local tool = _list_0[_index_0] -- 379
			_accum_0[_len_0] = tool -- 379
			_len_0 = _len_0 + 1 -- 379
		end -- 379
		doraTools = _accum_0 -- 379
	end -- 379
	local _list_0 = allEntries.projectEntries -- 380
	for _index_0 = 1, #_list_0 do -- 380
		local entry = _list_0[_index_0] -- 380
		if isToolEntry(entry) then -- 381
			entry.kind = "tool" -- 382
			doraTools[#doraTools + 1] = entry -- 383
		else -- 385
			entry.kind = "game" -- 385
			gamesInDev[#gamesInDev + 1] = entry -- 386
		end -- 381
	end -- 380
	for i = #allEntries, 1, -1 do -- 387
		allEntries[i] = nil -- 388
	end -- 387
	for _index_0 = 1, #gamesInDev do -- 389
		local game = gamesInDev[_index_0] -- 389
		allEntries[#allEntries + 1] = game -- 390
		local examples, tests = game.examples, game.tests -- 391
		for _index_1 = 1, #examples do -- 392
			local example = examples[_index_1] -- 392
			allEntries[#allEntries + 1] = example -- 393
		end -- 392
		for _index_1 = 1, #tests do -- 394
			local test = tests[_index_1] -- 394
			allEntries[#allEntries + 1] = test -- 395
		end -- 394
	end -- 389
end -- 377
local updateEntries -- 397
updateEntries = function() -- 397
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 398
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 399
	local _list_0 = allEntries.builtinTools -- 400
	for _index_0 = 1, #_list_0 do -- 400
		local tool = _list_0[_index_0] -- 400
		tool.kind = "tool" -- 401
		tool.builtin = true -- 402
	end -- 400
	return allEntries.rebuildEntries() -- 403
end -- 397
allEntries.refreshDirtyProjects = function() -- 405
	if not allEntries.hasDirty then -- 406
		return -- 406
	end -- 406
	local dirty = allEntries.dirty -- 407
	allEntries.dirty = { } -- 408
	allEntries.hasDirty = false -- 409
	for projectPath in pairs(dirty) do -- 410
		do -- 411
			local _accum_0 = { } -- 411
			local _len_0 = 1 -- 411
			local _list_0 = allEntries.projectEntries -- 411
			for _index_0 = 1, #_list_0 do -- 411
				local entry = _list_0[_index_0] -- 411
				if entry.projectPath ~= projectPath then -- 411
					_accum_0[_len_0] = entry -- 411
					_len_0 = _len_0 + 1 -- 411
				end -- 411
			end -- 411
			allEntries.projectEntries = _accum_0 -- 411
		end -- 411
		local parentPath = Path:getPath(projectPath) -- 412
		local dir = Path:getFilename(projectPath) -- 413
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 414
		for _index_0 = 1, #_list_0 do -- 414
			local entry = _list_0[_index_0] -- 414
			if entry.projectPath == projectPath then -- 415
				do -- 416
					local _obj_0 = allEntries.projectEntries -- 416
					_obj_0[#_obj_0 + 1] = entry -- 416
				end -- 416
				break -- 417
			end -- 415
		end -- 414
	end -- 410
	table.sort(allEntries.projectEntries, function(a, b) -- 418
		return a.entryName < b.entryName -- 418
	end) -- 418
	return allEntries.rebuildEntries() -- 419
end -- 405
updateEntries() -- 421
local getLaunchEntries -- 423
getLaunchEntries = function(refresh) -- 423
	if refresh == nil then -- 423
		refresh = false -- 423
	end -- 423
	if refresh then -- 424
		updateEntries() -- 424
	end -- 424
	local toInfo -- 425
	toInfo = function(entry, kind) -- 425
		local file = entry.fileName -- 426
		local asProj = not entry.builtin -- 427
		return { -- 429
			name = getEntryTitle(entry), -- 429
			file = file, -- 430
			kind = kind, -- 431
			asProj = asProj -- 432
		} -- 428
	end -- 425
	local games -- 434
	do -- 434
		local _accum_0 = { } -- 434
		local _len_0 = 1 -- 434
		for _index_0 = 1, #gamesInDev do -- 434
			local game = gamesInDev[_index_0] -- 434
			_accum_0[_len_0] = toInfo(game, "game") -- 434
			_len_0 = _len_0 + 1 -- 434
		end -- 434
		games = _accum_0 -- 434
	end -- 434
	local tools -- 435
	do -- 435
		local _accum_0 = { } -- 435
		local _len_0 = 1 -- 435
		for _index_0 = 1, #doraTools do -- 435
			local tool = doraTools[_index_0] -- 435
			_accum_0[_len_0] = toInfo(tool, "tool") -- 435
			_len_0 = _len_0 + 1 -- 435
		end -- 435
		tools = _accum_0 -- 435
	end -- 435
	return { -- 436
		games = games, -- 436
		tools = tools -- 436
	} -- 436
end -- 423
_module_0["getLaunchEntries"] = getLaunchEntries -- 423
local _anon_func_1 = function(entry, useChinese) -- 453
	local _obj_0 = entry.repo -- 453
	if _obj_0 ~= nil then -- 453
		local _obj_1 = _obj_0.description -- 453
		if _obj_1 ~= nil then -- 453
			return _obj_1[useChinese and "zh" or "en"] -- 453
		end -- 453
		return nil -- 453
	end -- 453
	return nil -- 453
end -- 453
local getMobileFeedEntries -- 438
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 438
	if refresh == nil then -- 438
		refresh = false -- 438
	end -- 438
	if dirtyProjectPath == nil then -- 438
		dirtyProjectPath = nil -- 438
	end -- 438
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 439
		allEntries.dirty[dirtyProjectPath] = true -- 440
		allEntries.hasDirty = true -- 441
	end -- 439
	if refresh then -- 442
		allEntries.dirty = { } -- 443
		allEntries.hasDirty = false -- 444
		updateEntries() -- 445
	else -- 447
		allEntries.refreshDirtyProjects() -- 447
	end -- 442
	local items = { } -- 448
	for _index_0 = 1, #gamesInDev do -- 449
		local entry = gamesInDev[_index_0] -- 449
		items[#items + 1] = { -- 451
			id = entry.entryName, -- 451
			title = getEntryTitle(entry), -- 452
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 453
			fileName = entry.fileName, -- 454
			workDir = Path:getPath(entry.fileName), -- 455
			bannerFile = entry.bannerFile, -- 456
			kind = "local" -- 457
		} -- 450
	end -- 449
	return items -- 459
end -- 438
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 438
local doCompile -- 461
doCompile = function(minify) -- 461
	if building then -- 462
		return -- 462
	end -- 462
	building = true -- 463
	local startTime = App.runningTime -- 464
	local luaFiles = { } -- 465
	local yueFiles = { } -- 466
	local xmlFiles = { } -- 467
	local tlFiles = { } -- 468
	local writablePath = Content.writablePath -- 469
	local buildPaths = { -- 471
		{ -- 472
			Content.assetPath, -- 472
			Path(writablePath, ".build"), -- 473
			"" -- 474
		} -- 471
	} -- 470
	for _index_0 = 1, #gamesInDev do -- 477
		local _des_0 = gamesInDev[_index_0] -- 477
		local fileName = _des_0.fileName -- 477
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 478
		buildPaths[#buildPaths + 1] = { -- 480
			Path(writablePath, gamePath), -- 480
			Path(writablePath, ".build", gamePath), -- 481
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 482
			gamePath -- 483
		} -- 479
	end -- 477
	for _index_0 = 1, #buildPaths do -- 484
		local _des_0 = buildPaths[_index_0] -- 484
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 484
		if not Content:exist(inputPath) then -- 485
			goto _continue_0 -- 485
		end -- 485
		local _list_0 = getAllFiles(inputPath, { -- 487
			"lua" -- 487
		}) -- 487
		for _index_1 = 1, #_list_0 do -- 487
			local file = _list_0[_index_1] -- 487
			luaFiles[#luaFiles + 1] = { -- 489
				file, -- 489
				Path(inputPath, file), -- 490
				Path(outputPath, file), -- 491
				gamePath -- 492
			} -- 488
		end -- 487
		local _list_1 = getAllFiles(inputPath, { -- 494
			yueext -- 494
		}) -- 494
		for _index_1 = 1, #_list_1 do -- 494
			local file = _list_1[_index_1] -- 494
			yueFiles[#yueFiles + 1] = { -- 496
				file, -- 496
				Path(inputPath, file), -- 497
				Path(outputPath, Path:replaceExt(file, "lua")), -- 498
				searchPath, -- 499
				gamePath -- 500
			} -- 495
		end -- 494
		local _list_2 = getAllFiles(inputPath, { -- 502
			"xml" -- 502
		}) -- 502
		for _index_1 = 1, #_list_2 do -- 502
			local file = _list_2[_index_1] -- 502
			xmlFiles[#xmlFiles + 1] = { -- 504
				file, -- 504
				Path(inputPath, file), -- 505
				Path(outputPath, Path:replaceExt(file, "lua")), -- 506
				gamePath -- 507
			} -- 503
		end -- 502
		local _list_3 = getAllFiles(inputPath, { -- 509
			"tl" -- 509
		}) -- 509
		for _index_1 = 1, #_list_3 do -- 509
			local file = _list_3[_index_1] -- 509
			if not file:match(".*%.d%.tl$") then -- 510
				tlFiles[#tlFiles + 1] = { -- 512
					file, -- 512
					Path(inputPath, file), -- 513
					Path(outputPath, Path:replaceExt(file, "lua")), -- 514
					searchPath, -- 515
					gamePath -- 516
				} -- 511
			end -- 510
		end -- 509
		::_continue_0:: -- 485
	end -- 484
	local paths -- 518
	do -- 518
		local _tbl_0 = { } -- 518
		local _list_0 = { -- 519
			luaFiles, -- 519
			yueFiles, -- 519
			xmlFiles, -- 519
			tlFiles -- 519
		} -- 519
		for _index_0 = 1, #_list_0 do -- 519
			local files = _list_0[_index_0] -- 519
			for _index_1 = 1, #files do -- 520
				local file = files[_index_1] -- 520
				_tbl_0[Path:getPath(file[3])] = true -- 518
			end -- 518
		end -- 518
		paths = _tbl_0 -- 518
	end -- 518
	for path in pairs(paths) do -- 522
		Content:mkdir(path) -- 522
	end -- 522
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 524
	local fileCount = 0 -- 525
	local errors = { } -- 526
	for _index_0 = 1, #yueFiles do -- 527
		local _des_0 = yueFiles[_index_0] -- 527
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 527
		local filename -- 528
		if gamePath then -- 528
			filename = Path(gamePath, file) -- 528
		else -- 528
			filename = file -- 528
		end -- 528
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 529
			if not codes then -- 530
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 531
				return -- 532
			end -- 530
			local success, result = LintYueGlobals(codes, globals) -- 533
			local yueCodes -- 534
			if not success then -- 535
				yueCodes = Content:load(input) -- 536
				if yueCodes then -- 536
					local CheckTIC80Code -- 537
					do -- 537
						local _obj_0 = require("Utils") -- 537
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 537
					end -- 537
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 538
					if isTIC80 then -- 539
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 540
					end -- 539
				end -- 536
			end -- 535
			if success then -- 541
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 542
			else -- 544
				if yueCodes then -- 544
					local globalErrors = { } -- 545
					for _index_1 = 1, #result do -- 546
						local _des_1 = result[_index_1] -- 546
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 546
						local countLine = 1 -- 547
						local code = "" -- 548
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 549
							if countLine == line then -- 550
								code = lineCode -- 551
								break -- 552
							end -- 550
							countLine = countLine + 1 -- 553
						end -- 549
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 554
					end -- 546
					if #globalErrors > 0 then -- 555
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 555
					end -- 555
				else -- 557
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 557
				end -- 544
				if #errors == 0 then -- 558
					return codes -- 558
				end -- 558
			end -- 541
		end, function(success) -- 529
			if success then -- 559
				print("Yue compiled: " .. tostring(filename)) -- 559
			end -- 559
			fileCount = fileCount + 1 -- 560
		end) -- 529
	end -- 527
	thread(function() -- 562
		for _index_0 = 1, #xmlFiles do -- 563
			local _des_0 = xmlFiles[_index_0] -- 563
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 563
			local filename -- 564
			if gamePath then -- 564
				filename = Path(gamePath, file) -- 564
			else -- 564
				filename = file -- 564
			end -- 564
			local sourceCodes = Content:loadAsync(input) -- 565
			local codes, err = xml.tolua(sourceCodes) -- 566
			if not codes then -- 567
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 568
			else -- 570
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 570
				print("Xml compiled: " .. tostring(filename)) -- 571
			end -- 567
			fileCount = fileCount + 1 -- 572
		end -- 563
	end) -- 562
	thread(function() -- 574
		for _index_0 = 1, #tlFiles do -- 575
			local _des_0 = tlFiles[_index_0] -- 575
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 575
			local filename -- 576
			if gamePath then -- 576
				filename = Path(gamePath, file) -- 576
			else -- 576
				filename = file -- 576
			end -- 576
			local sourceCodes = Content:loadAsync(input) -- 577
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 578
			if not codes then -- 579
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 580
			else -- 582
				Content:saveAsync(output, codes) -- 582
				print("Teal compiled: " .. tostring(filename)) -- 583
			end -- 579
			fileCount = fileCount + 1 -- 584
		end -- 575
	end) -- 574
	return thread(function() -- 586
		wait(function() -- 587
			return fileCount == totalFiles -- 587
		end) -- 587
		if minify then -- 588
			local _list_0 = { -- 589
				yueFiles, -- 589
				xmlFiles, -- 589
				tlFiles -- 589
			} -- 589
			for _index_0 = 1, #_list_0 do -- 589
				local files = _list_0[_index_0] -- 589
				for _index_1 = 1, #files do -- 589
					local file = files[_index_1] -- 589
					local output = Path:replaceExt(file[3], "lua") -- 590
					luaFiles[#luaFiles + 1] = { -- 592
						Path:replaceExt(file[1], "lua"), -- 592
						output, -- 593
						output -- 594
					} -- 591
				end -- 589
			end -- 589
			local FormatMini -- 596
			do -- 596
				local _obj_0 = require("luaminify") -- 596
				FormatMini = _obj_0.FormatMini -- 596
			end -- 596
			for _index_0 = 1, #luaFiles do -- 597
				local _des_0 = luaFiles[_index_0] -- 597
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 597
				if Content:exist(input) then -- 598
					local sourceCodes = Content:loadAsync(input) -- 599
					local res, err = FormatMini(sourceCodes) -- 600
					if res then -- 601
						Content:saveAsync(output, res) -- 602
						print("Minify: " .. tostring(file)) -- 603
					else -- 605
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 605
					end -- 601
				else -- 607
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 607
				end -- 598
			end -- 597
			package.loaded["luaminify.FormatMini"] = nil -- 608
			package.loaded["luaminify.ParseLua"] = nil -- 609
			package.loaded["luaminify.Scope"] = nil -- 610
			package.loaded["luaminify.Util"] = nil -- 611
		end -- 588
		local errorMessage = table.concat(errors, "\n") -- 612
		if errorMessage ~= "" then -- 613
			print(errorMessage) -- 613
		end -- 613
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 614
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 615
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 616
		Content:clearPathCache() -- 617
		teal.clear() -- 618
		yue.clear() -- 619
		building = false -- 620
	end) -- 586
end -- 461
local doClean -- 622
doClean = function() -- 622
	if building then -- 623
		return -- 623
	end -- 623
	local writablePath = Content.writablePath -- 624
	local targetDir = Path(writablePath, ".build") -- 625
	Content:clearPathCache() -- 626
	if Content:remove(targetDir) then -- 627
		return print("Cleaned: " .. tostring(targetDir)) -- 628
	end -- 627
end -- 622
local screenScale = 2.0 -- 630
local scaleContent = false -- 631
local isInEntry = true -- 632
local currentEntry = nil -- 633
local footerWindow = nil -- 635
local entryWindow = nil -- 636
local testingThread = nil -- 637
local mobileMode = config.mobileFeed -- 638
local pendingUIMode = nil -- 639
local feedHost = nil -- 640
local remixHost = nil -- 641
local startMobileUI = nil -- 642
local webControlled = false -- 643
local mobileHosts = { } -- 644
local suspendedMobileHosts = { } -- 645
local trackMobileHost -- 647
trackMobileHost = function(host) -- 647
	do -- 648
		local _accum_0 = { } -- 648
		local _len_0 = 1 -- 648
		for _index_0 = 1, #mobileHosts do -- 648
			local item = mobileHosts[_index_0] -- 648
			if item.parent then -- 648
				_accum_0[_len_0] = item -- 648
				_len_0 = _len_0 + 1 -- 648
			end -- 648
		end -- 648
		mobileHosts = _accum_0 -- 648
	end -- 648
	mobileHosts[#mobileHosts + 1] = host -- 649
	return host -- 650
end -- 647
local clearMobileUI -- 652
clearMobileUI = function() -- 652
	for _index_0 = 1, #mobileHosts do -- 653
		local host = mobileHosts[_index_0] -- 653
		if host.parent then -- 654
			host:removeFromParent(true) -- 654
		end -- 654
	end -- 653
	mobileHosts = { } -- 655
	suspendedMobileHosts = { } -- 656
	feedHost = nil -- 657
	remixHost = nil -- 658
end -- 652
local syncWebIDEControl -- 660
syncWebIDEControl = function() -- 660
	local connected = HttpServer.wsConnectionCount > 0 -- 661
	if connected then -- 662
		pendingUIMode = nil -- 663
		for _index_0 = 1, #mobileHosts do -- 664
			local host = mobileHosts[_index_0] -- 664
			if not host.parent then -- 665
				goto _continue_0 -- 665
			end -- 665
			if not (suspendedMobileHosts[host] ~= nil) then -- 666
				suspendedMobileHosts[host] = host.visible -- 667
				host:emit("SuspendLocalUI") -- 668
			end -- 666
			host.visible = false -- 669
			::_continue_0:: -- 665
		end -- 664
	elseif webControlled then -- 670
		for host, visible in pairs(suspendedMobileHosts) do -- 671
			if host.parent then -- 672
				host.visible = visible -- 673
				host:emit("ResumeLocalUI") -- 674
			end -- 672
		end -- 671
		suspendedMobileHosts = { } -- 675
	end -- 662
	webControlled = connected -- 676
	return connected -- 677
end -- 660
local getUIMode -- 679
getUIMode = function() -- 679
	return mobileMode and "mobile" or "traditional" -- 679
end -- 679
_module_0["getUIMode"] = getUIMode -- 679
local setUIMode -- 680
setUIMode = function(mode) -- 680
	if not (("mobile" == mode or "traditional" == mode)) then -- 681
		return false -- 681
	end -- 681
	if HttpServer.wsConnectionCount > 0 then -- 682
		return false -- 682
	end -- 682
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 683
		return false -- 683
	end -- 683
	local wantsMobile = mode == "mobile" -- 684
	if wantsMobile == mobileMode then -- 685
		return true -- 685
	end -- 685
	if mobileMode then -- 686
		if not (feedHost and feedHost.visible) then -- 687
			return false -- 687
		end -- 687
		feedHost:emit("SwitchUIMode") -- 689
		return pendingUIMode == false -- 690
	end -- 686
	pendingUIMode = true -- 691
	return true -- 692
end -- 680
_module_0["setUIMode"] = setUIMode -- 680
local applyUIMode -- 694
applyUIMode = function(enabled) -- 694
	if HttpServer.wsConnectionCount > 0 then -- 696
		return false -- 696
	end -- 696
	if enabled then -- 697
		local ok, err = pcall(startMobileUI) -- 698
		if not ok then -- 699
			if feedHost then -- 700
				feedHost:removeFromParent(true) -- 700
			end -- 700
			feedHost = nil -- 701
			mobileMode = false -- 702
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 703
			return false -- 704
		end -- 699
	else -- 706
		clearMobileUI() -- 706
		updateEntries() -- 707
	end -- 697
	mobileMode = enabled -- 708
	config.mobileFeed = enabled -- 709
	return true -- 710
end -- 694
local setupEventHandlers = nil -- 712
local allClear -- 714
allClear = function() -- 714
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 716
		clearMobileUI() -- 716
	end -- 716
	local systemNodes = { } -- 719
	local preserveSystemNode -- 720
	preserveSystemNode = function(node) -- 720
		if systemNodes[node] then -- 721
			return -- 721
		end -- 721
		systemNodes[node] = true -- 722
		do -- 723
			local clip = tolua.cast(node, "ClipNode") -- 723
			if clip then -- 723
				if clip.stencil then -- 724
					preserveSystemNode(clip.stencil) -- 724
				end -- 724
			end -- 723
		end -- 723
		return node:eachChild(function(child) -- 725
			preserveSystemNode(child) -- 726
			return false -- 727
		end) -- 725
	end -- 720
	for _index_0 = 1, #Routine do -- 728
		local routine = Routine[_index_0] -- 728
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 730
			goto _continue_0 -- 731
		else -- 733
			Routine:remove(routine) -- 733
		end -- 729
		::_continue_0:: -- 729
	end -- 728
	for _index_0 = 1, #moduleCache do -- 734
		local module = moduleCache[_index_0] -- 734
		package.loaded[module] = nil -- 735
	end -- 734
	moduleCache = { } -- 736
	Director:cleanup() -- 737
	Entity:clear() -- 738
	Platformer.Data:clear() -- 739
	Platformer.UnitAction:clear() -- 740
	Audio:stopAll(0.2) -- 741
	Struct:clear() -- 742
	View.nearPlaneDistance = 0.1 -- 745
	View.farPlaneDistance = 10000 -- 746
	View.fieldOfView = 45 -- 747
	View.postEffect = nil -- 748
	View.scale = scaleContent and screenScale or 1 -- 749
	Director.clearColor = Color(0xff1a1a1a) -- 750
	teal.clear() -- 751
	yue.clear() -- 752
	preserveSystemNode(Director.systemUI) -- 755
	for _, item in pairs(ubox()) do -- 756
		local node = tolua.cast(item, "Node") -- 757
		if node then -- 757
			if not systemNodes[node] then -- 758
				node:cleanup() -- 758
			end -- 758
		end -- 757
	end -- 756
	collectgarbage() -- 759
	collectgarbage() -- 760
	Wasm:clear() -- 761
	thread(function() -- 762
		sleep() -- 763
		return Cache:removeUnused() -- 764
	end) -- 762
	setupEventHandlers() -- 765
	Content.searchPaths = searchPaths -- 766
	App.idled = true -- 767
end -- 714
_module_0["allClear"] = allClear -- 714
local clearTempFiles -- 769
clearTempFiles = function() -- 769
	local writablePath = Content.writablePath -- 770
	if Content:exist(Path(writablePath, ".upload")) then -- 771
		Content:remove(Path(writablePath, ".upload")) -- 771
	end -- 771
	if Content:exist(Path(writablePath, ".download")) then -- 772
		return Content:remove(Path(writablePath, ".download")) -- 772
	end -- 772
end -- 769
local waitForWebStart = true -- 774
thread(function() -- 775
	sleep(2) -- 776
	waitForWebStart = false -- 777
end) -- 775
local reloadDevEntry -- 779
reloadDevEntry = function() -- 779
	return thread(function() -- 779
		waitForWebStart = true -- 780
		doClean() -- 781
		allClear() -- 782
		_G.require = oldRequire -- 783
		Dora.require = oldRequire -- 784
		package.loaded["Script.Dev.Entry"] = nil -- 785
		package.loaded["Script.Dev.WebServer"] = nil -- 786
		return Director.systemScheduler:schedule(function() -- 787
			Routine:clear() -- 788
			oldRequire("Script.Dev.Entry") -- 789
			return true -- 790
		end) -- 787
	end) -- 779
end -- 779
local setWorkspace -- 792
setWorkspace = function(path) -- 792
	clearTempFiles() -- 793
	Content.writablePath = path -- 794
	config.writablePath = Content.writablePath -- 795
	return thread(function() -- 796
		sleep() -- 797
		return reloadDevEntry() -- 798
	end) -- 796
end -- 792
_module_0["setWorkspace"] = setWorkspace -- 792
local quit = false -- 800
local activeSearchId = 0 -- 802
local handleSearchFiles -- 804
handleSearchFiles = function(payload) -- 804
	if not payload then -- 805
		return -- 805
	end -- 805
	local id = payload.id -- 806
	if id == nil then -- 807
		return -- 807
	end -- 807
	activeSearchId = id -- 808
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 809
	if path == nil then -- 810
		path = "" -- 810
	end -- 810
	if exts == nil then -- 811
		exts = { } -- 811
	end -- 811
	if globs == nil then -- 812
		globs = { } -- 812
	end -- 812
	if extensionLevels == nil then -- 813
		extensionLevels = { } -- 813
	end -- 813
	if pattern == nil then -- 814
		pattern = "" -- 814
	end -- 814
	if pattern == "" then -- 816
		return -- 816
	end -- 816
	local useRegex = payload.useRegex == true -- 817
	local caseSensitive = payload.caseSensitive == true -- 818
	local includeContent = payload.includeContent ~= false -- 819
	local contentWindow = payload.contentWindow or 0 -- 820
	return Director.systemScheduler:schedule(once(function() -- 821
		local stopped = false -- 822
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 823
			if activeSearchId ~= id then -- 824
				stopped = true -- 825
				return true -- 826
			end -- 824
			emit("AppWS", "Send", json.encode({ -- 828
				name = "SearchFilesResult", -- 828
				id = id, -- 828
				result = result -- 828
			})) -- 827
			return false -- 830
		end) -- 823
		return emit("AppWS", "Send", json.encode({ -- 832
			name = "SearchFilesDone", -- 832
			id = id, -- 832
			stopped = stopped -- 832
		})) -- 831
	end)) -- 821
end -- 804
local stop -- 835
stop = function() -- 835
	if isInEntry then -- 836
		return false -- 836
	end -- 836
	allClear() -- 837
	isInEntry = true -- 838
	currentEntry = nil -- 839
	return true -- 840
end -- 835
_module_0["stop"] = stop -- 835
local getCurrentEntryStatus -- 842
getCurrentEntryStatus = function() -- 842
	local entry = currentEntry -- 843
	if not (entry and not isInEntry) then -- 844
		return { -- 844
			success = true, -- 844
			running = false, -- 844
			runId = allEntries.runId -- 844
		} -- 844
	end -- 844
	local status = { -- 846
		success = true, -- 846
		running = true, -- 847
		kind = entry.runKind or "file", -- 848
		runId = allEntries.runId, -- 849
		entryName = entry.entryName, -- 850
		fileName = entry.fileName -- 851
	} -- 845
	if entry.workDir then -- 852
		status.workDir = entry.workDir -- 852
	end -- 852
	if entry.projectRoot then -- 853
		status.projectRoot = entry.projectRoot -- 853
	end -- 853
	return status -- 854
end -- 842
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 842
local _anon_func_2 = function(_with_0) -- 873
	local _val_0 = App.platform -- 873
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 873
end -- 873
setupEventHandlers = function() -- 856
	local _with_0 = Director.postNode -- 857
	_with_0:onAppEvent(function(eventType) -- 858
		if "Quit" == eventType then -- 859
			quit = true -- 860
			allClear() -- 861
			return clearTempFiles() -- 862
		elseif "Shutdown" == eventType then -- 863
			return stop() -- 864
		end -- 858
	end) -- 858
	_with_0:onAppChange(function(settingName) -- 865
		if "Theme" == settingName then -- 866
			config.themeColor = App.themeColor:toARGB() -- 867
		elseif "Locale" == settingName then -- 868
			config.locale = App.locale -- 869
			updateLocale() -- 870
			return teal.clear(true) -- 871
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 872
			if _anon_func_2(_with_0) then -- 873
				if "FullScreen" == settingName then -- 875
					config.fullScreen = App.fullScreen -- 875
				elseif "Position" == settingName then -- 876
					local _obj_0 = App.winPosition -- 876
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 876
				elseif "Size" == settingName then -- 877
					local width, height -- 878
					do -- 878
						local _obj_0 = App.winSize -- 878
						width, height = _obj_0.width, _obj_0.height -- 878
					end -- 878
					config.winWidth = width -- 879
					config.winHeight = height -- 880
				end -- 874
			end -- 873
		end -- 865
	end) -- 865
	_with_0:onAppWS(function(event) -- 881
		if event.type == "Close" then -- 882
			if HttpServer.wsConnectionCount == 0 then -- 883
				updateEntries() -- 884
			end -- 883
			return -- 885
		end -- 882
		if not (event.type == "Receive") then -- 886
			return -- 886
		end -- 886
		local data = json.decode(event.msg) -- 887
		if not data then -- 888
			return -- 888
		end -- 888
		local _exp_0 = data.name -- 889
		if "SearchFiles" == _exp_0 then -- 890
			return handleSearchFiles(data) -- 891
		elseif "SearchFilesStop" == _exp_0 then -- 892
			if data.id == nil or data.id == activeSearchId then -- 893
				activeSearchId = 0 -- 894
			end -- 893
		end -- 889
	end) -- 881
	_with_0:slot("UpdateEntries", function() -- 895
		return updateEntries() -- 895
	end) -- 895
	return _with_0 -- 857
end -- 856
setupEventHandlers() -- 897
clearTempFiles() -- 898
local downloadFile -- 900
downloadFile = function(url, target) -- 900
	return Director.systemScheduler:schedule(once(function() -- 900
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 901
			if quit then -- 902
				return true -- 902
			end -- 902
			emit("AppWS", "Send", json.encode({ -- 904
				name = "Download", -- 904
				url = url, -- 904
				status = "downloading", -- 904
				progress = current / total -- 905
			})) -- 903
			return false -- 901
		end) -- 901
		return emit("AppWS", "Send", json.encode(success and { -- 908
			name = "Download", -- 908
			url = url, -- 908
			status = "completed", -- 908
			progress = 1.0 -- 909
		} or { -- 911
			name = "Download", -- 911
			url = url, -- 911
			status = "failed", -- 911
			progress = 0.0 -- 912
		})) -- 907
	end)) -- 900
end -- 900
_module_0["downloadFile"] = downloadFile -- 900
local _anon_func_3 = function(file, require, workDir) -- 924
	if workDir == nil then -- 924
		workDir = Path:getPath(file) -- 924
	end -- 924
	Content:insertSearchPath(1, workDir) -- 925
	local scriptPath = Path(workDir, "Script") -- 926
	if Content:exist(scriptPath) then -- 927
		Content:insertSearchPath(1, scriptPath) -- 928
	end -- 927
	local result = require(file) -- 929
	if "function" == type(result) then -- 930
		result() -- 930
	end -- 930
	return nil -- 931
end -- 924
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 960
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 960
	label.alignment = "Left" -- 961
	label.textWidth = width - fontSize -- 962
	label.text = err -- 963
	return label -- 960
end -- 960
local enterEntryAsync -- 915
enterEntryAsync = function(entry) -- 915
	allEntries.runId = allEntries.runId + 1 -- 916
	isInEntry = false -- 917
	App.idled = false -- 918
	emit(Profiler.EventName, "ClearLoader") -- 919
	currentEntry = entry -- 920
	local file, workDir = entry.fileName, entry.workDir -- 921
	sleep() -- 922
	return xpcall(_anon_func_3, function(msg) -- 931
		local err = debug.traceback(msg) -- 933
		Log("Error", err) -- 934
		allClear() -- 935
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 936
		local viewWidth, viewHeight -- 937
		do -- 937
			local _obj_0 = View.size -- 937
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 937
		end -- 937
		local width, height = viewWidth - 20, viewHeight - 20 -- 938
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 939
		Director.ui:addChild((function() -- 940
			local root = AlignNode() -- 940
			do -- 941
				local _obj_0 = App.bufferSize -- 941
				width, height = _obj_0.width, _obj_0.height -- 941
			end -- 941
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 942
			root:onAppChange(function(settingName) -- 943
				if settingName == "Size" then -- 943
					do -- 944
						local _obj_0 = App.bufferSize -- 944
						width, height = _obj_0.width, _obj_0.height -- 944
					end -- 944
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 945
				end -- 943
			end) -- 943
			root:addChild((function() -- 946
				local _with_0 = ScrollArea({ -- 947
					width = width, -- 947
					height = height, -- 948
					paddingX = 0, -- 949
					paddingY = 50, -- 950
					viewWidth = height, -- 951
					viewHeight = height -- 952
				}) -- 946
				root:onAlignLayout(function(w, h) -- 954
					_with_0.position = Vec2(w / 2, h / 2) -- 955
					w = w - 20 -- 956
					h = h - 20 -- 957
					_with_0.view.children.first.textWidth = w - fontSize -- 958
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 959
				end) -- 954
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 960
				return _with_0 -- 946
			end)()) -- 946
			return root -- 940
		end)()) -- 940
		return err -- 964
	end, file, require, workDir) -- 923
end -- 915
_module_0["enterEntryAsync"] = enterEntryAsync -- 915
local enterDemoEntry -- 966
enterDemoEntry = function(entry) -- 966
	return thread(function() -- 966
		return enterEntryAsync(entry) -- 966
	end) -- 966
end -- 966
local reloadCurrentEntry -- 968
reloadCurrentEntry = function() -- 968
	if currentEntry then -- 969
		allClear() -- 970
		return enterDemoEntry(currentEntry) -- 971
	end -- 969
end -- 968
Director.clearColor = Color(0xff1a1a1a) -- 973
local descColor = Color(0xffa1a1a1) -- 974
local extraOperations -- 976
do -- 976
	local isOSSLicenseExist = Content:exist("LICENSES") -- 977
	local ossLicenses = nil -- 978
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 979
	local failedSetFolder = false -- 980
	local statusFlags = { -- 981
		"NoResize", -- 981
		"NoMove", -- 981
		"NoCollapse", -- 981
		"AlwaysAutoResize", -- 981
		"NoSavedSettings" -- 981
	} -- 981
	extraOperations = function() -- 988
		local zh = useChinese -- 989
		if isDesktop then -- 990
			local alwaysOnTop = config.alwaysOnTop -- 991
			do -- 992
				local changed -- 992
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 992
				if changed then -- 992
					App.alwaysOnTop = alwaysOnTop -- 993
					config.alwaysOnTop = alwaysOnTop -- 994
				end -- 992
			end -- 992
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 995
			do -- 996
				local changed -- 996
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 996
				if changed then -- 996
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 997
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 998
				end -- 996
			end -- 996
			SameLine() -- 999
			TextColored(descColor, "(?)") -- 1000
			if IsItemHovered() then -- 1001
				BeginTooltip(function() -- 1002
					return PushTextWrapPos(360, function() -- 1003
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1004
					end) -- 1003
				end) -- 1002
			end -- 1001
		end -- 990
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1019
		do -- 1024
			local changed -- 1024
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1024
			if changed then -- 1024
				config.showPreview = showPreview -- 1025
				updateEntries() -- 1026
				if not showPreview then -- 1027
					thread(function() -- 1028
						collectgarbage() -- 1029
						return Cache:removeUnused("Texture") -- 1030
					end) -- 1028
				end -- 1027
			end -- 1024
		end -- 1024
		do -- 1031
			local changed -- 1031
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1031
			if changed then -- 1031
				config.authRequired = authRequired -- 1032
				HttpServer.authRequired = authRequired -- 1033
			end -- 1031
		end -- 1031
		SameLine() -- 1034
		TextColored(descColor, "(?)") -- 1035
		if IsItemHovered() then -- 1036
			BeginTooltip(function() -- 1037
				return PushTextWrapPos(280, function() -- 1038
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1039
				end) -- 1038
			end) -- 1037
		end -- 1036
		do -- 1040
			local themeColor = App.themeColor -- 1041
			local writablePath = config.writablePath -- 1042
			SeparatorText(zh and "工作目录" or "Workspace") -- 1043
			PushTextWrapPos(400, function() -- 1044
				return TextColored(themeColor, writablePath) -- 1045
			end) -- 1044
			if not isDesktop then -- 1046
				goto skipSetting -- 1046
			end -- 1046
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1047
			if Button(zh and "改变目录" or "Set Folder") then -- 1048
				App:openFileDialog(true, function(path) -- 1049
					if path == "" then -- 1050
						return -- 1050
					end -- 1050
					local relPath = Path:getRelative(Content.assetPath, path) -- 1051
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1052
						return setWorkspace(path) -- 1053
					else -- 1055
						failedSetFolder = true -- 1055
					end -- 1052
				end) -- 1049
			end -- 1048
			if failedSetFolder then -- 1056
				failedSetFolder = false -- 1057
				OpenPopup(popupName) -- 1058
			end -- 1056
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1059
			BeginPopupModal(popupName, statusFlags, function() -- 1060
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1061
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1062
					return CloseCurrentPopup() -- 1063
				end -- 1062
			end) -- 1060
			SameLine() -- 1064
			if Button(zh and "使用默认" or "Use Default") then -- 1065
				setWorkspace(Content.appPath) -- 1066
			end -- 1065
			Separator() -- 1067
			::skipSetting:: -- 1068
		end -- 1040
		if isOSSLicenseExist then -- 1069
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1070
				if not ossLicenses then -- 1071
					local licenseText = Content:load("LICENSES") -- 1072
					if licenseText then -- 1072
						ossLicenses = { } -- 1073
						licenseText = licenseText:gsub("\r\n", "\n") -- 1074
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1075
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1076
							if name then -- 1076
								ossLicenses[#ossLicenses + 1] = { -- 1077
									name, -- 1077
									text -- 1077
								} -- 1077
							end -- 1076
						end -- 1075
					end -- 1072
				end -- 1071
				if ossLicenses then -- 1078
					OpenPopup(ossLicensePopup) -- 1078
				end -- 1078
			end -- 1070
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1079
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1080
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1081
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1082
				return BeginPopupModal(ossLicensePopup, true, { -- 1085
					"NoSavedSettings" -- 1085
				}, function() -- 1086
					for _index_0 = 1, #ossLicenses do -- 1087
						local _des_0 = ossLicenses[_index_0] -- 1087
						local firstLine, text = _des_0[1], _des_0[2] -- 1087
						local name, license = firstLine:match("(.+): (.+)") -- 1089
						if name then -- 1089
							TextColored(themeColor, name) -- 1090
							SameLine() -- 1091
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1092
								return TextWrapped(text) -- 1092
							end) -- 1092
						end -- 1089
					end -- 1087
				end) -- 1082
			end) -- 1082
		end -- 1069
		if not App.debugging then -- 1095
			return -- 1095
		end -- 1095
		return TreeNode(zh and "开发操作" or "Development", function() -- 1096
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1097
				OpenPopup("build") -- 1097
			end -- 1097
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1098
				return BeginPopup("build", function() -- 1098
					if Selectable(zh and "编译" or "Compile") then -- 1099
						doCompile(false) -- 1099
					end -- 1099
					Separator() -- 1100
					if Selectable(zh and "压缩" or "Minify") then -- 1101
						doCompile(true) -- 1101
					end -- 1101
					Separator() -- 1102
					if Selectable(zh and "清理" or "Clean") then -- 1103
						return doClean() -- 1103
					end -- 1103
				end) -- 1098
			end) -- 1098
			if isInEntry then -- 1104
				if waitForWebStart then -- 1105
					BeginDisabled(function() -- 1106
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1106
					end) -- 1106
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1107
					reloadDevEntry() -- 1108
				end -- 1105
			end -- 1104
			do -- 1109
				local changed -- 1109
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1109
				if changed then -- 1109
					View.scale = scaleContent and screenScale or 1 -- 1110
				end -- 1109
			end -- 1109
			do -- 1111
				local changed -- 1111
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1111
				if changed then -- 1111
					config.engineDev = engineDev -- 1112
				end -- 1111
			end -- 1111
			do -- 1113
				local changed -- 1113
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1113
				if changed then -- 1113
					config.webIDETourCompleted = webIDETourCompleted -- 1114
				end -- 1113
			end -- 1113
			if testingThread then -- 1115
				return BeginDisabled(function() -- 1116
					return Button(zh and "开始自动测试" or "Test automatically") -- 1116
				end) -- 1116
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1117
				testingThread = thread(function() -- 1118
					local _ <close> = setmetatable({ }, { -- 1119
						__close = function() -- 1119
							allClear() -- 1120
							testingThread = nil -- 1121
							isInEntry = true -- 1122
							currentEntry = nil -- 1123
							return print("Testing done!") -- 1124
						end -- 1119
					}) -- 1119
					for _, entry in ipairs(allEntries) do -- 1125
						allClear() -- 1126
						print("Start " .. tostring(entry.entryName)) -- 1127
						enterDemoEntry(entry) -- 1128
						sleep(2) -- 1129
						print("Stop " .. tostring(entry.entryName)) -- 1130
					end -- 1125
				end) -- 1118
			end -- 1115
		end) -- 1096
	end -- 988
end -- 976
local icon = Path("Script", "Dev", "icon_s.png") -- 1132
local iconTex = nil -- 1133
thread(function() -- 1134
	if Cache:loadAsync(icon) then -- 1134
		iconTex = Texture2D(icon) -- 1134
	end -- 1134
end) -- 1134
local webStatus = nil -- 1136
local urlClicked = nil -- 1137
local authCode = string.format("%06d", math.random(0, 999999)) -- 1139
local authCodeTTL = 30.0 -- 1141
_module_0.getAuthCode = function() -- 1142
	return authCode -- 1142
end -- 1142
_module_0.invalidateAuthCode = function() -- 1143
	authCode = string.format("%06d", math.random(0, 999999)) -- 1144
	authCodeTTL = 30.0 -- 1145
end -- 1143
local AuthSession -- 1147
do -- 1147
	local pending = nil -- 1148
	local session = nil -- 1149
	AuthSession = { -- 1151
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1151
			pending = { -- 1153
				sessionId = sessionId, -- 1153
				confirmCode = confirmCode, -- 1154
				expiresAt = expiresAt, -- 1155
				ttl = ttl, -- 1156
				approved = false -- 1157
			} -- 1152
		end, -- 1151
		getPending = function() -- 1159
			return pending -- 1159
		end, -- 1159
		approvePending = function(sessionId) -- 1161
			if pending and pending.sessionId == sessionId then -- 1162
				pending.approved = true -- 1163
				return true -- 1164
			end -- 1162
			return false -- 1165
		end, -- 1161
		clearPending = function() -- 1167
			pending = nil -- 1167
		end, -- 1167
		setSession = function(sessionId, sessionSecret) -- 1169
			session = { -- 1171
				sessionId = sessionId, -- 1171
				sessionSecret = sessionSecret -- 1172
			} -- 1170
		end, -- 1169
		getSession = function() -- 1174
			return session -- 1174
		end -- 1174
	} -- 1150
end -- 1147
_module_0["AuthSession"] = AuthSession -- 1147
local transparant = Color(0x0) -- 1177
local windowFlags = { -- 1178
	"NoTitleBar", -- 1178
	"NoResize", -- 1178
	"NoMove", -- 1178
	"NoCollapse", -- 1178
	"NoSavedSettings", -- 1178
	"NoFocusOnAppearing", -- 1178
	"NoBringToFrontOnFocus" -- 1178
} -- 1178
local statusFlags = { -- 1187
	"NoTitleBar", -- 1187
	"NoResize", -- 1187
	"NoMove", -- 1187
	"NoCollapse", -- 1187
	"AlwaysAutoResize", -- 1187
	"NoSavedSettings" -- 1187
} -- 1187
local displayWindowFlags = { -- 1195
	"NoDecoration", -- 1195
	"NoSavedSettings", -- 1195
	"NoMove", -- 1195
	"NoScrollWithMouse", -- 1195
	"AlwaysAutoResize", -- 1195
	"NoFocusOnAppearing" -- 1195
} -- 1195
local gamepadInputWindowFlags = { -- 1203
	"NoDecoration", -- 1203
	"NoSavedSettings", -- 1203
	"NoMove", -- 1203
	"NoScrollbar", -- 1203
	"NoScrollWithMouse", -- 1203
	"NoFocusOnAppearing", -- 1203
	"NoBringToFrontOnFocus" -- 1203
} -- 1203
local initFooter = true -- 1212
local gamepadInputFocused = false -- 1213
local _anon_func_5 = function(allEntries, currentIndex) -- 1259
	if currentIndex > 1 then -- 1259
		return allEntries[currentIndex - 1] -- 1260
	else -- 1262
		return allEntries[#allEntries] -- 1262
	end -- 1259
end -- 1259
local _anon_func_6 = function(allEntries, currentIndex) -- 1266
	if currentIndex < #allEntries then -- 1266
		return allEntries[currentIndex + 1] -- 1267
	else -- 1269
		return allEntries[1] -- 1269
	end -- 1266
end -- 1266
footerWindow = threadLoop(function() -- 1214
	if mobileMode then -- 1215
		return -- 1215
	end -- 1215
	local zh = useChinese -- 1216
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1217
	if authCodeTTL <= 0 then -- 1218
		authCodeTTL = 30.0 -- 1219
		authCode = string.format("%06d", math.random(0, 999999)) -- 1220
	end -- 1218
	if HttpServer.wsConnectionCount > 0 then -- 1221
		return -- 1222
	end -- 1221
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1223
		if App.platform == "Emscripten" then -- 1224
			stop() -- 1226
		else -- 1228
			allClear() -- 1228
			App.devMode = false -- 1229
			App:shutdown() -- 1230
		end -- 1224
	end -- 1223
	do -- 1231
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1232
		if ctrl and Keyboard:isKeyDown("Q") then -- 1233
			stop() -- 1234
		end -- 1233
		if ctrl and Keyboard:isKeyDown("Z") then -- 1235
			reloadCurrentEntry() -- 1236
		end -- 1235
		if ctrl and Keyboard:isKeyDown(",") then -- 1237
			if showFooter then -- 1238
				showStats = not showStats -- 1238
			else -- 1238
				showStats = true -- 1238
			end -- 1238
			showFooter = true -- 1239
			config.showFooter = showFooter -- 1240
			config.showStats = showStats -- 1241
		end -- 1237
		if ctrl and Keyboard:isKeyDown(".") then -- 1242
			if showFooter then -- 1243
				showConsole = not showConsole -- 1243
			else -- 1243
				showConsole = true -- 1243
			end -- 1243
			showFooter = true -- 1244
			config.showFooter = showFooter -- 1245
			config.showConsole = showConsole -- 1246
		end -- 1242
		if ctrl and Keyboard:isKeyDown("/") then -- 1247
			showFooter = not showFooter -- 1248
			config.showFooter = showFooter -- 1249
		end -- 1247
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1250
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1251
		local currentIndex = nil -- 1252
		for i, entry in ipairs(allEntries) do -- 1253
			if currentEntry == entry then -- 1254
				currentIndex = i -- 1255
			end -- 1254
		end -- 1253
		if left then -- 1256
			allClear() -- 1257
			if currentIndex == nil then -- 1258
				currentIndex = #allEntries + 1 -- 1258
			end -- 1258
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1259
		end -- 1256
		if right then -- 1263
			allClear() -- 1264
			if currentIndex == nil then -- 1265
				currentIndex = 0 -- 1265
			end -- 1265
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1266
		end -- 1263
	end -- 1231
	if not showEntry then -- 1270
		return -- 1270
	end -- 1270
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1272
		reloadDevEntry() -- 1276
	end -- 1272
	if initFooter then -- 1277
		initFooter = false -- 1278
	end -- 1277
	local width, height -- 1280
	do -- 1280
		local _obj_0 = App.visualSize -- 1280
		width, height = _obj_0.width, _obj_0.height -- 1280
	end -- 1280
	if isInEntry then -- 1281
		gamepadInputFocused = false -- 1282
	else -- 1284
		SetNextWindowBgAlpha(0.0) -- 1284
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1285
		SetNextWindowPos(Vec2.zero, "Always") -- 1286
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1287
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1288
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1289
					if not gamepadInputFocused then -- 1290
						SetWindowFocus("DoraGamepadInput") -- 1291
						gamepadInputFocused = true -- 1292
					end -- 1290
				end) -- 1289
			end) -- 1288
		end) -- 1287
	end -- 1281
	if isInEntry or showFooter then -- 1294
		SetNextWindowSize(Vec2(width, 50)) -- 1295
		SetNextWindowPos(Vec2(0, height - 50)) -- 1296
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1297
			return PushStyleVar("WindowRounding", 0, function() -- 1298
				return Begin("Footer", windowFlags, function() -- 1299
					Separator() -- 1300
					if iconTex then -- 1301
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1302
							showStats = not showStats -- 1303
							config.showStats = showStats -- 1304
						end -- 1302
						SameLine() -- 1305
						if Button(">_", Vec2(30, 30)) then -- 1306
							showConsole = not showConsole -- 1307
							config.showConsole = showConsole -- 1308
						end -- 1306
					end -- 1301
					if isInEntry and config.updateNotification then -- 1309
						SameLine() -- 1310
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1311
							allClear() -- 1312
							config.updateNotification = false -- 1313
							enterDemoEntry({ -- 1315
								entryName = "SelfUpdater", -- 1315
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1316
							}) -- 1314
						end -- 1311
					end -- 1309
					if not isInEntry then -- 1317
						SameLine() -- 1318
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1319
						local currentIndex = nil -- 1320
						for i, entry in ipairs(allEntries) do -- 1321
							if currentEntry == entry then -- 1322
								currentIndex = i -- 1323
							end -- 1322
						end -- 1321
						if currentIndex then -- 1324
							if currentIndex > 1 then -- 1325
								SameLine() -- 1326
								if Button("<<", Vec2(30, 30)) then -- 1327
									allClear() -- 1328
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1329
								end -- 1327
							end -- 1325
							if currentIndex < #allEntries then -- 1330
								SameLine() -- 1331
								if Button(">>", Vec2(30, 30)) then -- 1332
									allClear() -- 1333
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1334
								end -- 1332
							end -- 1330
						end -- 1324
						SameLine() -- 1335
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1336
							reloadCurrentEntry() -- 1337
						end -- 1336
						if back then -- 1338
							allClear() -- 1339
							isInEntry = true -- 1340
							currentEntry = nil -- 1341
						end -- 1338
					end -- 1317
				end) -- 1299
			end) -- 1298
		end) -- 1297
	end -- 1294
	if isInEntry then -- 1343
		local showURL = true -- 1344
		local webIDEWidth -- 1345
		do -- 1345
			local base -- 1346
			if config.updateNotification then -- 1346
				base = 460 -- 1346
			else -- 1346
				base = 360 -- 1346
			end -- 1346
			local extra -- 1347
			if config.authRequired then -- 1347
				extra = 35 -- 1347
			else -- 1347
				extra = 0 -- 1347
			end -- 1347
			webIDEWidth = base + extra -- 1348
		end -- 1345
		if width < webIDEWidth then -- 1349
			showURL = false -- 1349
		end -- 1349
		SetNextWindowBgAlpha(0.0) -- 1350
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1351
		Begin("Web IDE", displayWindowFlags, function() -- 1352
			local pending = AuthSession.getPending() -- 1353
			local hovered = false -- 1354
			if not pending and showURL then -- 1355
				do -- 1356
					local url -- 1356
					if webStatus ~= nil then -- 1356
						url = webStatus.url -- 1356
					end -- 1356
					if url then -- 1356
						if isDesktop and not config.fullScreen then -- 1357
							if urlClicked then -- 1358
								BeginDisabled(function() -- 1359
									return Button(url) -- 1359
								end) -- 1359
							elseif Button(url) then -- 1360
								urlClicked = once(function() -- 1361
									return sleep(5) -- 1361
								end) -- 1361
								App:openURL("http://localhost:8866") -- 1362
							end -- 1358
						else -- 1364
							TextColored(descColor, url) -- 1364
						end -- 1357
					else -- 1366
						TextColored(descColor, zh and '不可用' or 'not available') -- 1366
					end -- 1356
				end -- 1356
				hovered = IsItemHovered() -- 1367
			else -- 1369
				TextColored(descColor, "(?)") -- 1369
				hovered = IsItemHovered() -- 1370
			end -- 1355
			SameLine() -- 1371
			local themeColor = App.themeColor -- 1372
			if pending then -- 1373
				if not pending.approved then -- 1374
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1375
					local ttl = pending.ttl or 1 -- 1376
					PushStyleColor("Text", themeColor, function() -- 1377
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1378
						hovered = hovered or IsItemHovered() -- 1379
					end) -- 1377
					SameLine() -- 1380
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1381
						AuthSession.approvePending(pending.sessionId) -- 1382
					end -- 1381
					if hovered then -- 1383
						return BeginTooltip(function() -- 1384
							return PushTextWrapPos(280, function() -- 1385
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1386
							end) -- 1385
						end) -- 1384
					end -- 1383
				end -- 1374
			else -- 1388
				if config.authRequired then -- 1388
					PushStyleColor("Text", themeColor, function() -- 1389
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1390
						hovered = hovered or IsItemHovered() -- 1391
					end) -- 1389
					if hovered then -- 1392
						return BeginTooltip(function() -- 1393
							return PushTextWrapPos(280, function() -- 1394
								local url -- 1395
								if webStatus ~= nil then -- 1395
									url = webStatus.url -- 1395
								end -- 1395
								if url then -- 1395
									local address -- 1396
									if showURL then -- 1396
										address = "Web IDE" -- 1396
									else -- 1396
										address = url -- 1396
									end -- 1396
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1397
								else -- 1399
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1399
								end -- 1395
							end) -- 1394
						end) -- 1393
					end -- 1392
				else -- 1401
					if hovered then -- 1401
						return BeginTooltip(function() -- 1402
							return PushTextWrapPos(280, function() -- 1403
								local url -- 1404
								if webStatus ~= nil then -- 1404
									url = webStatus.url -- 1404
								end -- 1404
								if url then -- 1404
									local address -- 1405
									if showURL then -- 1405
										address = "Web IDE" -- 1405
									else -- 1405
										address = url -- 1405
									end -- 1405
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1406
								else -- 1408
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1408
								end -- 1404
							end) -- 1403
						end) -- 1402
					end -- 1401
				end -- 1388
			end -- 1373
		end) -- 1352
	end -- 1343
	if not isInEntry then -- 1410
		SetNextWindowSize(Vec2(50, 50)) -- 1411
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1412
		PushStyleColor("WindowBg", transparant, function() -- 1413
			return Begin("Show", displayWindowFlags, function() -- 1413
				if width >= 370 then -- 1414
					local changed -- 1415
					changed, showFooter = Checkbox("##dev", showFooter) -- 1415
					if changed then -- 1415
						config.showFooter = showFooter -- 1416
					end -- 1415
				end -- 1414
			end) -- 1413
		end) -- 1413
	end -- 1410
	if isInEntry or showFooter then -- 1418
		if showStats then -- 1419
			PushStyleVar("WindowRounding", 0, function() -- 1420
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1421
				SetNextWindowSize(Vec2(0, height - 50)) -- 1422
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1423
				config.showStats = showStats -- 1424
			end) -- 1420
		end -- 1419
		if showConsole then -- 1425
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1426
			return PushStyleVar("WindowRounding", 6, function() -- 1427
				return ShowConsole() -- 1428
			end) -- 1427
		end -- 1425
	end -- 1418
end) -- 1214
local MaxWidth <const> = 960 -- 1430
local toolOpen = false -- 1432
local filterText = nil -- 1433
allEntries.anyEntryMatched = false -- 1434
allEntries.match = function(name) -- 1435
	local res = not filterText or name:lower():match(filterText) -- 1436
	if res then -- 1437
		allEntries.anyEntryMatched = true -- 1437
	end -- 1437
	return res -- 1438
end -- 1435
allEntries.thinSep = function() -- 1440
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1440
		return SeparatorText("") -- 1440
	end) -- 1440
end -- 1440
entryWindow = threadLoop(function() -- 1442
	local connected = syncWebIDEControl() -- 1443
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1445
		if not allEntries.pendingPackagePath then -- 1446
			local path = App:takeReceivedFile() -- 1447
			if path ~= "" then -- 1448
				allEntries.pendingPackagePath = path -- 1448
			end -- 1448
		end -- 1446
		if allEntries.pendingPackagePath then -- 1449
			pendingUIMode = true -- 1449
		end -- 1449
	end -- 1445
	if (pendingUIMode ~= nil) then -- 1451
		local nextMode = pendingUIMode -- 1452
		pendingUIMode = nil -- 1453
		applyUIMode(nextMode) -- 1454
	end -- 1451
	if mobileMode and not connected then -- 1455
		if isInEntry and not feedHost then -- 1456
			applyUIMode(true) -- 1456
		end -- 1456
		return -- 1457
	end -- 1455
	if App.fpsLimited ~= config.fpsLimited then -- 1458
		config.fpsLimited = App.fpsLimited -- 1459
	end -- 1458
	if App.targetFPS ~= config.targetFPS then -- 1460
		config.targetFPS = App.targetFPS -- 1461
	end -- 1460
	if View.vsync ~= config.vsync then -- 1462
		config.vsync = View.vsync -- 1463
	end -- 1462
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1464
		config.fixedFPS = Director.scheduler.fixedFPS -- 1465
	end -- 1464
	if Director.profilerSending ~= config.webProfiler then -- 1466
		config.webProfiler = Director.profilerSending -- 1467
	end -- 1466
	if urlClicked then -- 1468
		local _, result = coroutine.resume(urlClicked) -- 1469
		if result then -- 1470
			coroutine.close(urlClicked) -- 1471
			urlClicked = nil -- 1472
		end -- 1470
	end -- 1468
	if not isInEntry then -- 1473
		return -- 1473
	end -- 1473
	local zh = useChinese -- 1474
	local themeColor = App.themeColor -- 1475
	if connected then -- 1476
		local width, height -- 1477
		do -- 1477
			local _obj_0 = App.visualSize -- 1477
			width, height = _obj_0.width, _obj_0.height -- 1477
		end -- 1477
		SetNextWindowBgAlpha(0.5) -- 1478
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1479
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1480
			Separator() -- 1481
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1482
			if iconTex then -- 1483
				Image(icon, Vec2(24, 24)) -- 1484
				SameLine() -- 1485
			end -- 1483
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1486
			TextColored(descColor, slogon) -- 1487
			return Separator() -- 1488
		end) -- 1480
		return -- 1489
	end -- 1476
	if not showEntry then -- 1490
		return -- 1490
	end -- 1490
	local fullWidth, height -- 1492
	do -- 1492
		local _obj_0 = App.visualSize -- 1492
		fullWidth, height = _obj_0.width, _obj_0.height -- 1492
	end -- 1492
	local width = math.min(MaxWidth, fullWidth) -- 1493
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1494
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1495
	SetNextWindowPos(Vec2.zero) -- 1496
	SetNextWindowBgAlpha(0) -- 1497
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1498
	do -- 1499
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1500
			return Begin("Dora Dev", windowFlags, function() -- 1501
				Dummy(Vec2(fullWidth - 20, 0)) -- 1502
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1503
				SameLine() -- 1504
				if Button(zh and "Go 模式" or "Go Mode") then -- 1505
					setUIMode("mobile") -- 1506
				end -- 1505
				if fullWidth >= 540 then -- 1507
					SameLine() -- 1508
					Dummy(Vec2(fullWidth - 540, 0)) -- 1509
					SameLine() -- 1510
					SetNextItemWidth(zh and -95 or -140) -- 1511
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1512
						"AutoSelectAll" -- 1512
					}) then -- 1512
						config.filter = filterBuf.text -- 1513
					end -- 1512
					SameLine() -- 1514
					if Button(zh and '下载' or 'Download') then -- 1515
						allClear() -- 1516
						enterDemoEntry({ -- 1518
							entryName = "ResourceDownloader", -- 1518
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1519
						}) -- 1517
					end -- 1515
				end -- 1507
				return Separator() -- 1520
			end) -- 1501
		end) -- 1500
	end -- 1499
	allEntries.anyEntryMatched = false -- 1522
	SetNextWindowPos(Vec2(0, 50)) -- 1523
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1524
	do -- 1525
		return PushStyleColor("WindowBg", transparant, function() -- 1526
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1527
				return PushStyleVar("Alpha", 1, function() -- 1528
					return Begin("Content", windowFlags, function() -- 1529
						local DemoViewWidth <const> = 220 -- 1530
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1531
						if filterText then -- 1532
							filterText = filterText:lower() -- 1532
						end -- 1532
						if App.platform == "Emscripten" then -- 1533
							Dora.globals.webProjects.draw(zh, themeColor) -- 1534
							allEntries.anyEntryMatched = true -- 1535
						end -- 1533
						if #gamesInDev > 0 then -- 1536
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1537
							Columns(columns, false) -- 1538
							local realViewWidth = GetColumnWidth() - 50 -- 1539
							for _index_0 = 1, #gamesInDev do -- 1540
								local game = gamesInDev[_index_0] -- 1540
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1541
								local displayName -- 1550
								if repo then -- 1550
									if zh then -- 1551
										displayName = repo.title.zh -- 1551
									else -- 1551
										displayName = repo.title.en -- 1551
									end -- 1551
								end -- 1550
								if displayName == nil then -- 1552
									displayName = gameName -- 1552
								end -- 1552
								if allEntries.match(displayName) then -- 1553
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1554
									SameLine() -- 1555
									TextWrapped(displayName) -- 1556
									if columns > 1 then -- 1557
										if bannerFile and bannerTex then -- 1558
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1559
											local displayWidth <const> = realViewWidth -- 1560
											texHeight = displayWidth * texHeight / texWidth -- 1561
											texWidth = displayWidth -- 1562
											Dummy(Vec2.zero) -- 1563
											SameLine() -- 1564
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1565
										end -- 1558
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1566
											enterDemoEntry(game) -- 1567
										end -- 1566
									else -- 1569
										if bannerFile and bannerTex then -- 1569
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1570
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1571
											local sizing = 0.8 -- 1572
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1573
											texWidth = displayWidth * sizing -- 1574
											if texWidth > 500 then -- 1575
												sizing = 0.6 -- 1576
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1577
												texWidth = displayWidth * sizing -- 1578
											end -- 1575
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1579
											Dummy(Vec2(padding, 0)) -- 1580
											SameLine() -- 1581
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1582
										end -- 1569
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1583
											enterDemoEntry(game) -- 1584
										end -- 1583
									end -- 1557
									if #tests == 0 and #examples == 0 then -- 1585
										allEntries.thinSep() -- 1586
									end -- 1585
									NextColumn() -- 1587
								end -- 1553
								local showSep = false -- 1588
								if #examples > 0 then -- 1589
									local showExample = false -- 1590
									for _index_1 = 1, #examples do -- 1591
										local _des_0 = examples[_index_1] -- 1591
										local entryName = _des_0.entryName -- 1591
										if allEntries.match(entryName) then -- 1592
											showExample = true -- 1592
											break -- 1592
										end -- 1592
									end -- 1591
									if showExample then -- 1593
										showSep = true -- 1594
										Columns(1, false) -- 1595
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1596
										SameLine() -- 1597
										local opened -- 1598
										if (filterText ~= nil) then -- 1598
											opened = showExample -- 1598
										else -- 1598
											opened = false -- 1598
										end -- 1598
										if game.exampleOpen == nil then -- 1599
											game.exampleOpen = opened -- 1599
										end -- 1599
										SetNextItemOpen(game.exampleOpen) -- 1600
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1601
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1602
												Columns(maxColumns, false) -- 1603
												for _index_1 = 1, #examples do -- 1604
													local example = examples[_index_1] -- 1604
													local entryName = example.entryName -- 1605
													if not allEntries.match(entryName) then -- 1606
														goto _continue_0 -- 1606
													end -- 1606
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1607
														if Button(entryName, Vec2(-1, 40)) then -- 1608
															enterDemoEntry(example) -- 1609
														end -- 1608
														return NextColumn() -- 1610
													end) -- 1607
													opened = true -- 1611
													::_continue_0:: -- 1605
												end -- 1604
											end) -- 1602
										end) -- 1601
										game.exampleOpen = opened -- 1612
									end -- 1593
								end -- 1589
								if #tests > 0 then -- 1613
									local showTest = false -- 1614
									for _index_1 = 1, #tests do -- 1615
										local _des_0 = tests[_index_1] -- 1615
										local entryName = _des_0.entryName -- 1615
										if allEntries.match(entryName) then -- 1616
											showTest = true -- 1616
											break -- 1616
										end -- 1616
									end -- 1615
									if showTest then -- 1617
										showSep = true -- 1618
										Columns(1, false) -- 1619
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1620
										SameLine() -- 1621
										local opened -- 1622
										if (filterText ~= nil) then -- 1622
											opened = showTest -- 1622
										else -- 1622
											opened = false -- 1622
										end -- 1622
										if game.testOpen == nil then -- 1623
											game.testOpen = opened -- 1623
										end -- 1623
										SetNextItemOpen(game.testOpen) -- 1624
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1625
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1626
												Columns(maxColumns, false) -- 1627
												for _index_1 = 1, #tests do -- 1628
													local test = tests[_index_1] -- 1628
													local entryName = test.entryName -- 1629
													if not allEntries.match(entryName) then -- 1630
														goto _continue_0 -- 1630
													end -- 1630
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1631
														if Button(entryName, Vec2(-1, 40)) then -- 1632
															enterDemoEntry(test) -- 1633
														end -- 1632
														return NextColumn() -- 1634
													end) -- 1631
													opened = true -- 1635
													::_continue_0:: -- 1629
												end -- 1628
											end) -- 1626
										end) -- 1625
										game.testOpen = opened -- 1636
									end -- 1617
								end -- 1613
								if showSep then -- 1637
									Columns(1, false) -- 1638
									allEntries.thinSep() -- 1639
									Columns(columns, false) -- 1640
								end -- 1637
							end -- 1540
						end -- 1536
						if #doraTools > 0 then -- 1641
							local showTool = false -- 1642
							for _index_0 = 1, #doraTools do -- 1643
								local _des_0 = doraTools[_index_0] -- 1643
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1643
								local displayName -- 1644
								if repo then -- 1644
									if zh then -- 1645
										displayName = repo.title.zh -- 1645
									else -- 1645
										displayName = repo.title.en -- 1645
									end -- 1645
								end -- 1644
								if displayName == nil then -- 1646
									displayName = entryName -- 1646
								end -- 1646
								if allEntries.match(displayName) then -- 1647
									showTool = true -- 1647
									break -- 1647
								end -- 1647
							end -- 1643
							if not showTool then -- 1648
								goto endEntry -- 1648
							end -- 1648
							Columns(1, false) -- 1649
							TextColored(themeColor, "Dora SSR:") -- 1650
							SameLine() -- 1651
							Text(zh and "开发支持" or "Development Support") -- 1652
							Separator() -- 1653
							if #doraTools > 0 then -- 1654
								local opened -- 1655
								if (filterText ~= nil) then -- 1655
									opened = showTool -- 1655
								else -- 1655
									opened = false -- 1655
								end -- 1655
								SetNextItemOpen(toolOpen) -- 1656
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1657
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1658
										Columns(maxColumns, false) -- 1659
										for _index_0 = 1, #doraTools do -- 1660
											local tool = doraTools[_index_0] -- 1660
											local entryName, repo = tool.entryName, tool.repo -- 1661
											local displayName -- 1662
											if repo then -- 1662
												if zh then -- 1663
													displayName = repo.title.zh -- 1663
												else -- 1663
													displayName = repo.title.en -- 1663
												end -- 1663
											end -- 1662
											if displayName == nil then -- 1664
												displayName = entryName -- 1664
											end -- 1664
											if not allEntries.match(displayName) then -- 1665
												goto _continue_0 -- 1665
											end -- 1665
											if Button(displayName, Vec2(-1, 40)) then -- 1666
												enterDemoEntry(tool) -- 1667
											end -- 1666
											NextColumn() -- 1668
											::_continue_0:: -- 1661
										end -- 1660
										Columns(1, false) -- 1669
										opened = true -- 1670
									end) -- 1658
								end) -- 1657
								toolOpen = opened -- 1671
							end -- 1654
						end -- 1641
						::endEntry:: -- 1672
						if not allEntries.anyEntryMatched then -- 1673
							SetNextWindowBgAlpha(0) -- 1674
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1675
							Begin("Entries Not Found", displayWindowFlags, function() -- 1676
								Separator() -- 1677
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1678
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1679
								return Separator() -- 1680
							end) -- 1676
						end -- 1673
						Columns(1, false) -- 1681
						Dummy(Vec2(100, 80)) -- 1682
						return ScrollWhenDraggingOnVoid() -- 1683
					end) -- 1529
				end) -- 1528
			end) -- 1527
		end) -- 1526
	end -- 1525
end) -- 1442
if not (App.platform == "Emscripten") then -- 1688
	local sceneModuleCache = moduleCache -- 1689
	moduleCache = { } -- 1690
	webStatus = oldRequire("Script.Dev.WebServer") -- 1691
	moduleCache = sceneModuleCache -- 1692
end -- 1688
local _anon_func_7 = function(saved) -- 1715
	local _val_0 = saved.kind -- 1715
	return "local" == _val_0 or "discover" == _val_0 -- 1715
end -- 1715
local _anon_func_8 = function(saved) -- 1719
	local _val_0 = saved.activeTab -- 1719
	return "local" == _val_0 or "discover" == _val_0 -- 1719
end -- 1719
startMobileUI = function() -- 1694
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1695
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1696
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1697
	local getMobileFeedResources -- 1698
	do -- 1698
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1698
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1698
	end -- 1698
	local loadCachedCatalog -- 1699
	do -- 1699
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1699
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1699
	end -- 1699
	local getResourceInstallPath -- 1700
	do -- 1700
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1700
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1700
	end -- 1700
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1701
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1702
	local feedOptions = nil -- 1703
	local mobileLaunchErrors = { } -- 1704
	local withMobileLaunchErrors -- 1705
	withMobileLaunchErrors = function(items) -- 1705
		for _index_0 = 1, #items do -- 1706
			local item = items[_index_0] -- 1706
			item.launchError = mobileLaunchErrors[item.id] -- 1707
		end -- 1706
		return items -- 1708
	end -- 1705
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1709
	local loadRememberedMobileFeedState -- 1710
	loadRememberedMobileFeedState = function() -- 1710
		local raw = rememberedMobileFeedData -- 1711
		if not (type(raw) == "string" and raw ~= "") then -- 1712
			return -- 1712
		end -- 1712
		local ok, saved = pcall(json.decode, raw) -- 1713
		if not (ok and type(saved) == "table") then -- 1714
			return -- 1714
		end -- 1714
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1715
			local state = { -- 1716
				activeTab = saved.kind -- 1716
			} -- 1716
			state[saved.kind] = saved -- 1717
			return state -- 1718
		end -- 1715
		local state = { -- 1719
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1719
		} -- 1719
		local _list_0 = { -- 1720
			"local", -- 1720
			"discover" -- 1720
		} -- 1720
		for _index_0 = 1, #_list_0 do -- 1720
			local kind = _list_0[_index_0] -- 1720
			local entry = saved[kind] -- 1721
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1722
				state[kind] = entry -- 1722
			end -- 1722
		end -- 1720
		return state -- 1723
	end -- 1710
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1724
		activeTab = "local" -- 1724
	} -- 1724
	local rememberMobileFeedEntry -- 1725
	rememberMobileFeedEntry = function(entry) -- 1725
		rememberedMobileFeedState.activeTab = entry.kind -- 1726
		rememberedMobileFeedState[entry.kind] = { -- 1728
			id = entry.id, -- 1728
			kind = entry.kind, -- 1729
			workDir = entry.workDir, -- 1730
			fileName = entry.fileName -- 1731
		} -- 1727
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1733
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1734
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1735
			rememberedMobileFeedData -- 1735
		}) -- 1735
	end -- 1725
	local restartMobileFeed -- 1736
	restartMobileFeed = function(entry) -- 1736
		if feedHost then -- 1737
			feedHost:removeFromParent(true) -- 1737
		end -- 1737
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1738
		local initialEntries = { } -- 1739
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1740
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1741
		feedOptions.initialEntries = initialEntries -- 1742
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1743
	end -- 1736
	local startMobilePlay -- 1744
	startMobilePlay = function(entry) -- 1744
		if HttpServer.wsConnectionCount > 0 then -- 1745
			return -- 1745
		end -- 1745
		local originFeed = feedHost -- 1746
		if remixHost then -- 1747
			remixHost:removeFromParent(true) -- 1747
		end -- 1747
		remixHost = nil -- 1748
		mobileLaunchErrors[entry.id] = nil -- 1749
		entry.launchError = nil -- 1750
		local playActive = true -- 1751
		local restoreMobileFeed -- 1752
		restoreMobileFeed = function() -- 1752
			if not playActive then -- 1753
				return -- 1753
			end -- 1753
			playActive = false -- 1754
			allClear() -- 1755
			isInEntry = true -- 1756
			currentEntry = nil -- 1757
			return restartMobileFeed(entry) -- 1758
		end -- 1752
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1760
			onExit = function() -- 1760
				return restoreMobileFeed() -- 1760
			end, -- 1760
			onRuntimeError = function() -- 1761
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1762
				return restoreMobileFeed() -- 1763
			end -- 1761
		})) -- 1759
		return thread(function() -- 1765
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1769
			if not playActive then -- 1770
				return -- 1770
			end -- 1770
			if success then -- 1771
				if originFeed and originFeed.parent then -- 1772
					originFeed.visible = false -- 1772
				end -- 1772
				return -- 1773
			end -- 1771
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1774
			return restoreMobileFeed() -- 1775
		end) -- 1765
	end -- 1744
	feedOptions = { -- 1777
		takeReceivedFile = function() -- 1777
			if allEntries.pendingPackagePath then -- 1778
				local path = allEntries.pendingPackagePath -- 1779
				allEntries.pendingPackagePath = nil -- 1780
				return path -- 1781
			end -- 1778
			return App:takeReceivedFile() -- 1782
		end, -- 1777
		onSwitchMode = function() -- 1783
			if HttpServer.wsConnectionCount == 0 then -- 1783
				pendingUIMode = false -- 1783
			end -- 1783
		end, -- 1783
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1784
		getLocalEntries = function(importedProjectPath) -- 1785
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1786
			feedOptions.dirtyProjectPath = nil -- 1787
			return withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1788
		end, -- 1785
		syncDiscover = function(onProgress, onDone, force) -- 1789
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1789
		end, -- 1789
		getDiscoverEntries = function() -- 1790
			local cached = loadCachedCatalog() -- 1791
			if not (cached.success and cached.snapshot) then -- 1792
				return { } -- 1792
			end -- 1792
			local items = { } -- 1793
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1794
			for _index_0 = 1, #_list_0 do -- 1794
				local resource = _list_0[_index_0] -- 1794
				local installed = lifecycle.isMobileResourceReady(resource) -- 1795
				local installPath = getResourceInstallPath(resource.id) -- 1796
				items[#items + 1] = { -- 1798
					id = resource.id, -- 1798
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1799
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1800
					kind = "discover", -- 1801
					bannerFile = resource.bannerPath, -- 1802
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1803
					sourceUrl = resource.versions[1].sources[1].url, -- 1804
					workDir = installed and installPath or nil, -- 1805
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1806
					installed = installed, -- 1807
					resource = resource, -- 1808
					catalogCommit = cached.snapshot.commit, -- 1809
					launchError = mobileLaunchErrors[resource.id] -- 1810
				} -- 1797
			end -- 1794
			return items -- 1812
		end, -- 1790
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1813
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1814
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1815
			end), repairIncomplete, isCanceled) -- 1814
		end, -- 1813
		createProject = function(name, language) -- 1817
			local result = projectCreate.createMobileProject(name, language) -- 1818
			if not result.success then -- 1819
				return result -- 1819
			end -- 1819
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1820
			for _index_0 = 1, #_list_0 do -- 1820
				local entry = _list_0[_index_0] -- 1820
				if entry.workDir == result.workDir then -- 1821
					return { -- 1822
						success = true, -- 1822
						entry = entry -- 1822
					} -- 1822
				end -- 1821
			end -- 1820
			return { -- 1823
				success = false, -- 1823
				error = "created-project-not-found" -- 1823
			} -- 1823
		end, -- 1817
		onPlay = function(entry) -- 1824
			return startMobilePlay(entry) -- 1824
		end, -- 1824
		onRemix = function(entry) -- 1825
			if HttpServer.wsConnectionCount > 0 then -- 1826
				return -- 1826
			end -- 1826
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1827
			local originFeed = feedHost -- 1828
			feedHost.visible = false -- 1829
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1831
				entry = entry, -- 1831
				onProjectChanged = function(current) -- 1832
					feedOptions.dirtyProjectPath = current.workDir -- 1832
				end, -- 1832
				onBack = function() -- 1833
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1834
						originFeed:emit("RestoreFeedEntry", entry) -- 1835
						originFeed.visible = true -- 1836
					end -- 1834
				end, -- 1833
				onPlay = function(current) -- 1837
					return startMobilePlay(current) -- 1837
				end -- 1837
			})) -- 1830
		end -- 1825
	} -- 1776
	return restartMobileFeed() -- 1840
end -- 1694
if mobileMode then -- 1842
	applyUIMode(true) -- 1842
end -- 1842
return _module_0 -- 1
