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
		if not (path == "Script.Dev.AgentHost" or path:match("^Agent[./]")) then -- 24
			moduleCache[#moduleCache + 1] = path -- 25
		end -- 24
		return oldRequire(path) -- 26
	end -- 21
	return loaded -- 27
end -- 19
_G.require = require -- 28
Dora.require = require -- 29
local searchPaths = Content.searchPaths -- 31
local useChinese = (App.locale:match("^zh") ~= nil) -- 33
local updateLocale -- 34
updateLocale = function() -- 34
	useChinese = (App.locale:match("^zh") ~= nil) -- 35
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 36
	Content.searchPaths = searchPaths -- 37
end -- 34
local isDesktop -- 39
do -- 39
	local _val_0 = App.platform -- 39
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 39
end -- 39
if DB:exist("Config") then -- 41
	do -- 42
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 42
		local _type_0 = type(_exp_0) -- 43
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 43
		if _tab_0 then -- 43
			local locale -- 43
			do -- 43
				local _obj_0 = _exp_0[1] -- 43
				local _type_1 = type(_obj_0) -- 43
				if "table" == _type_1 or "userdata" == _type_1 then -- 43
					locale = _obj_0[1] -- 43
				end -- 43
			end -- 43
			if locale ~= nil then -- 43
				if App.locale ~= locale then -- 43
					App.locale = locale -- 44
					updateLocale() -- 45
				end -- 43
			end -- 43
		end -- 42
	end -- 42
	if isDesktop then -- 46
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 47
		local _type_0 = type(_exp_0) -- 48
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 48
		if _tab_0 then -- 48
			local writablePath -- 48
			do -- 48
				local _obj_0 = _exp_0[1] -- 48
				local _type_1 = type(_obj_0) -- 48
				if "table" == _type_1 or "userdata" == _type_1 then -- 48
					writablePath = _obj_0[1] -- 48
				end -- 48
			end -- 48
			if writablePath ~= nil then -- 48
				if writablePath ~= "" and Content:exist(writablePath) and Content:isdir(writablePath) then -- 49
					Content.writablePath = writablePath -- 50
				else -- 52
					Log("Warning", "saved writable path \"" .. tostring(writablePath) .. "\" is unavailable; using \"" .. tostring(Content.writablePath) .. "\" instead") -- 52
					if not DB:exec("update Config set value_str = ? where name = ?", { -- 53
						Content.writablePath, -- 53
						"writablePath" -- 53
					}) then -- 53
						Log("Warning", "failed to persist the fallback writable path") -- 54
					end -- 53
				end -- 49
			end -- 48
		end -- 47
	end -- 46
end -- 41
local Config = require("Config") -- 56
if App.platform == "Emscripten" then -- 58
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 58
end -- 58
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "agentLLMConfigVersion", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired", "webIDEEnabled") -- 60
config:load() -- 97
if not (config.webIDEEnabled ~= nil) then -- 99
	config.webIDEEnabled = true -- 100
end -- 99
App.webIDEEnabled = config.webIDEEnabled -- 101
if not (config.writablePath ~= nil) then -- 103
	config.writablePath = Content.appPath -- 104
end -- 103
if not (config.webIDEConnected ~= nil) then -- 106
	config.webIDEConnected = false -- 107
end -- 106
if (config.fpsLimited ~= nil) then -- 109
	App.fpsLimited = config.fpsLimited -- 110
else -- 112
	config.fpsLimited = App.fpsLimited -- 112
end -- 109
if (config.targetFPS ~= nil) then -- 114
	App.targetFPS = math.floor(config.targetFPS) -- 115
else -- 117
	config.targetFPS = App.targetFPS -- 117
end -- 114
if (config.vsync ~= nil) then -- 119
	View.vsync = config.vsync -- 120
else -- 122
	config.vsync = View.vsync -- 122
end -- 119
if (config.fixedFPS ~= nil) then -- 124
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 125
else -- 127
	config.fixedFPS = Director.scheduler.fixedFPS -- 127
end -- 124
if not (config.showPreview ~= nil) then -- 129
	config.showPreview = true -- 130
end -- 129
if not (config.mobileFeed ~= nil) then -- 132
	local _val_0 = App.platform -- 133
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 133
end -- 132
if not (config.webIDETourCompleted ~= nil) then -- 135
	config.webIDETourCompleted = false -- 136
end -- 135
if not (config.authRequired ~= nil) then -- 138
	local _val_0 = App.platform -- 139
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 139
end -- 138
HttpServer.authRequired = config.authRequired -- 140
local showEntry = true -- 142
isDesktop = false -- 144
if (function() -- 145
	local _val_0 = App.platform -- 145
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 145
end)() then -- 145
	isDesktop = true -- 146
	if config.fullScreen then -- 147
		App.fullScreen = true -- 148
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 149
		local size = Size(config.winWidth, config.winHeight) -- 150
		if App.winSize ~= size then -- 151
			App.winSize = size -- 152
		end -- 151
		local winX, winY -- 153
		do -- 153
			local _obj_0 = App.winPosition -- 153
			winX, winY = _obj_0.x, _obj_0.y -- 153
		end -- 153
		if (config.winX ~= nil) then -- 154
			winX = config.winX -- 155
		else -- 157
			config.winX = -1 -- 157
		end -- 154
		if (config.winY ~= nil) then -- 158
			winY = config.winY -- 159
		else -- 161
			config.winY = -1 -- 161
		end -- 158
		App.winPosition = Vec2(winX, winY) -- 162
	end -- 147
	if (config.alwaysOnTop ~= nil) then -- 163
		App.alwaysOnTop = config.alwaysOnTop -- 164
	else -- 166
		config.alwaysOnTop = false -- 166
	end -- 163
	if (config.virtualGamepadEnabled ~= nil) then -- 167
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 168
	else -- 170
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 170
	end -- 167
end -- 145
if (config.themeColor ~= nil) then -- 172
	App.themeColor = Color(config.themeColor) -- 173
else -- 175
	config.themeColor = App.themeColor:toARGB() -- 175
end -- 172
if not (config.locale ~= nil) then -- 177
	config.locale = App.locale -- 178
end -- 177
local showStats = false -- 180
if (config.showStats ~= nil) then -- 181
	showStats = config.showStats -- 182
else -- 184
	config.showStats = showStats -- 184
end -- 181
local showConsole = false -- 186
if (config.showConsole ~= nil) then -- 187
	showConsole = config.showConsole -- 188
else -- 190
	config.showConsole = showConsole -- 190
end -- 187
local showFooter = true -- 192
if (config.showFooter ~= nil) then -- 193
	showFooter = config.showFooter -- 194
else -- 196
	config.showFooter = showFooter -- 196
end -- 193
local setFooterVisible -- 198
setFooterVisible = function(visible) -- 198
	if visible == nil then -- 198
		visible = true -- 198
	end -- 198
	showFooter = visible -- 199
	config.showFooter = showFooter -- 200
end -- 198
_module_0["setFooterVisible"] = setFooterVisible -- 198
local filterBuf = Buffer(20) -- 202
if (config.filter ~= nil) then -- 203
	filterBuf.text = config.filter -- 204
else -- 206
	config.filter = "" -- 206
end -- 203
local engineDev = false -- 208
if (config.engineDev ~= nil) then -- 209
	engineDev = config.engineDev -- 210
else -- 212
	config.engineDev = engineDev -- 212
end -- 209
if (config.webProfiler ~= nil) then -- 214
	Director.profilerSending = config.webProfiler -- 215
else -- 217
	config.webProfiler = true -- 217
	Director.profilerSending = true -- 218
end -- 214
if not (config.drawerWidth ~= nil) then -- 220
	config.drawerWidth = 200 -- 221
end -- 220
_module_0.getConfig = function() -- 223
	return config -- 223
end -- 223
_module_0.getEngineDev = function() -- 224
	if not App.debugging then -- 225
		return false -- 225
	end -- 225
	return config.engineDev -- 226
end -- 224
local _anon_func_0 = function() -- 231
	local _val_0 = App.platform -- 231
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 231
end -- 231
_module_0.connectWebIDE = function() -- 228
	if not config.webIDEConnected then -- 229
		config.webIDEConnected = true -- 230
		if _anon_func_0() then -- 231
			local ratio = App.winSize.width / App.visualSize.width -- 232
			App.winSize = Size(640 * ratio, 480 * ratio) -- 233
		end -- 231
	end -- 229
end -- 228
local updateCheck -- 235
updateCheck = function() -- 235
	return thread(function() -- 235
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 236
		if res then -- 236
			local data = json.decode(res) -- 237
			if data then -- 237
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 238
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 239
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 240
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 241
				if na < a then -- 242
					goto not_new_version -- 243
				end -- 242
				if na == a then -- 244
					if nb < b then -- 245
						goto not_new_version -- 246
					end -- 245
					if nb == b then -- 247
						if nc < c then -- 248
							goto not_new_version -- 249
						end -- 248
						if nc == c then -- 250
							goto not_new_version -- 251
						end -- 250
					end -- 247
				end -- 244
				config.updateNotification = true -- 252
				::not_new_version:: -- 253
				config.lastUpdateCheck = os.time() -- 254
			end -- 237
		end -- 236
	end) -- 235
end -- 235
if (config.lastUpdateCheck ~= nil) then -- 256
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 257
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 258
		updateCheck() -- 259
	end -- 258
else -- 261
	updateCheck() -- 261
end -- 256
local Set, Struct, LintYueGlobals, GSplit -- 263
do -- 263
	local _obj_0 = require("Utils") -- 263
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 263
end -- 263
local yueext = yue.options.extension -- 264
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 266
local building = false -- 268
local getAllFiles -- 270
getAllFiles = function(path, exts, recursive) -- 270
	if recursive == nil then -- 270
		recursive = true -- 270
	end -- 270
	local filters = Set(exts) -- 271
	local files -- 272
	if recursive then -- 272
		files = Content:getAllFiles(path) -- 273
	else -- 275
		files = Content:getFiles(path) -- 275
	end -- 272
	local _accum_0 = { } -- 276
	local _len_0 = 1 -- 276
	for _index_0 = 1, #files do -- 276
		local file = files[_index_0] -- 276
		if not filters[Path:getExt(file)] then -- 277
			goto _continue_0 -- 277
		end -- 277
		_accum_0[_len_0] = file -- 278
		_len_0 = _len_0 + 1 -- 277
		::_continue_0:: -- 277
	end -- 276
	return _accum_0 -- 276
end -- 270
_module_0["getAllFiles"] = getAllFiles -- 270
local getFileEntries -- 280
getFileEntries = function(path, recursive, excludeFiles) -- 280
	if recursive == nil then -- 280
		recursive = true -- 280
	end -- 280
	if excludeFiles == nil then -- 280
		excludeFiles = nil -- 280
	end -- 280
	local entries = { } -- 281
	local excludes -- 282
	if excludeFiles then -- 282
		excludes = Set(excludeFiles) -- 283
	end -- 282
	local _list_0 = getAllFiles(path, { -- 284
		"lua", -- 284
		"xml", -- 284
		yueext, -- 284
		"tl" -- 284
	}, recursive) -- 284
	for _index_0 = 1, #_list_0 do -- 284
		local file = _list_0[_index_0] -- 284
		local entryName = Path:getName(file) -- 285
		if excludes and excludes[entryName] then -- 286
			goto _continue_0 -- 287
		end -- 286
		local fileName = Path:replaceExt(file, "") -- 288
		fileName = Path(path, fileName) -- 289
		local entryAdded -- 290
		for _index_1 = 1, #entries do -- 290
			local _des_0 = entries[_index_1] -- 290
			local ename, efile = _des_0.entryName, _des_0.fileName -- 290
			if entryName == ename and efile == fileName then -- 291
				entryAdded = true -- 291
				break -- 291
			end -- 291
		end -- 290
		if entryAdded then -- 292
			goto _continue_0 -- 292
		end -- 292
		local entry = { -- 293
			entryName = entryName, -- 293
			fileName = fileName -- 293
		} -- 293
		entries[#entries + 1] = entry -- 294
		::_continue_0:: -- 285
	end -- 284
	table.sort(entries, function(a, b) -- 295
		return a.entryName < b.entryName -- 295
	end) -- 295
	return entries -- 296
end -- 280
local allEntries = { -- 298
	dirty = { }, -- 298
	hasDirty = false, -- 298
	runId = 0 -- 298
} -- 298
allEntries.scanDir = function(path, dir, noPreview) -- 300
	if noPreview == nil then -- 300
		noPreview = false -- 300
	end -- 300
	local entries = { } -- 301
	if not dir:match("^%.") then -- 302
		local _list_0 = getAllFiles(Path(path, dir), { -- 303
			"lua", -- 303
			"xml", -- 303
			yueext, -- 303
			"tl", -- 303
			"wasm" -- 303
		}) -- 303
		for _index_0 = 1, #_list_0 do -- 303
			local file = _list_0[_index_0] -- 303
			if "init" == Path:getName(file):lower() then -- 304
				local fileName = Path:replaceExt(file, "") -- 305
				fileName = Path(path, dir, fileName) -- 306
				local projectPath = Path:getPath(fileName) -- 307
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 308
				local repo = nil -- 309
				if Content:exist(repoFile) then -- 310
					local str = Content:load(repoFile) -- 311
					if str then -- 311
						repo = json.decode(str) -- 312
					end -- 311
				end -- 310
				local entryName = Path:getName(projectPath) -- 313
				local entryAdded -- 314
				for _index_1 = 1, #entries do -- 314
					local _des_0 = entries[_index_1] -- 314
					local ename, efile = _des_0.entryName, _des_0.fileName -- 314
					if entryName == ename and efile == fileName then -- 315
						entryAdded = true -- 315
						break -- 315
					end -- 315
				end -- 314
				if entryAdded then -- 316
					goto _continue_0 -- 316
				end -- 316
				local examples = { } -- 317
				local tests = { } -- 318
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 319
				if Content:exist(examplePath) then -- 320
					local _list_1 = getFileEntries(examplePath) -- 321
					for _index_1 = 1, #_list_1 do -- 321
						local _des_0 = _list_1[_index_1] -- 321
						local name, ePath = _des_0.entryName, _des_0.fileName -- 321
						local entry = { -- 323
							entryName = name, -- 323
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 324
							workDir = projectPath -- 325
						} -- 322
						examples[#examples + 1] = entry -- 327
					end -- 321
				end -- 320
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 328
				if Content:exist(testPath) then -- 329
					local _list_1 = getFileEntries(testPath) -- 330
					for _index_1 = 1, #_list_1 do -- 330
						local _des_0 = _list_1[_index_1] -- 330
						local name, tPath = _des_0.entryName, _des_0.fileName -- 330
						local entry = { -- 332
							entryName = name, -- 332
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 333
							workDir = projectPath -- 334
						} -- 331
						tests[#tests + 1] = entry -- 336
					end -- 330
				end -- 329
				local entry = { -- 337
					entryName = entryName, -- 337
					fileName = fileName, -- 337
					projectPath = projectPath, -- 337
					examples = examples, -- 337
					tests = tests, -- 337
					repo = repo -- 337
				} -- 337
				local bannerFile -- 338
				do -- 338
					local _val_0 -- 338
					repeat -- 338
						if noPreview then -- 339
							_val_0 = nil -- 339
							break -- 339
						end -- 339
						if not config.showPreview then -- 340
							_val_0 = nil -- 340
							break -- 340
						end -- 340
						local f = Path(projectPath, ".dora", "banner.jpg") -- 341
						if Content:exist(f) then -- 342
							_val_0 = f -- 342
							break -- 342
						end -- 342
						f = Path(projectPath, ".dora", "banner.png") -- 343
						if Content:exist(f) then -- 344
							_val_0 = f -- 344
							break -- 344
						end -- 344
						f = Path(projectPath, "Image", "banner.jpg") -- 345
						if Content:exist(f) then -- 346
							_val_0 = f -- 346
							break -- 346
						end -- 346
						f = Path(projectPath, "Image", "banner.png") -- 347
						if Content:exist(f) then -- 348
							_val_0 = f -- 348
							break -- 348
						end -- 348
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 349
						if Content:exist(f) then -- 350
							_val_0 = f -- 350
							break -- 350
						end -- 350
					until true -- 338
					bannerFile = _val_0 -- 338
				end -- 338
				if bannerFile then -- 352
					entry.bannerFile = bannerFile -- 355
					thread(function() -- 356
						if Cache:loadAsync(bannerFile) then -- 357
							local bannerTex = Texture2D(bannerFile) -- 358
							if bannerTex then -- 358
								entry.bannerTex = bannerTex -- 359
							end -- 358
						end -- 357
					end) -- 356
				end -- 352
				entries[#entries + 1] = entry -- 360
			end -- 304
			::_continue_0:: -- 304
		end -- 303
	end -- 302
	return entries -- 361
end -- 300
local getProjectEntries -- 363
getProjectEntries = function(path, noPreview) -- 363
	if noPreview == nil then -- 363
		noPreview = false -- 363
	end -- 363
	local entries = { } -- 364
	local _list_0 = Content:getDirs(path) -- 365
	for _index_0 = 1, #_list_0 do -- 365
		local dir = _list_0[_index_0] -- 365
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 366
		for _index_1 = 1, #_list_1 do -- 366
			local entry = _list_1[_index_1] -- 366
			entries[#entries + 1] = entry -- 367
		end -- 366
	end -- 365
	table.sort(entries, function(a, b) -- 368
		return a.entryName < b.entryName -- 368
	end) -- 368
	return entries -- 369
end -- 363
_module_0["getProjectEntries"] = getProjectEntries -- 363
local gamesInDev -- 371
local doraTools -- 372
local isToolEntry -- 374
isToolEntry = function(entry) -- 374
	do -- 375
		local _type_0 = type(entry) -- 375
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 375
		if _tab_0 then -- 375
			local categories -- 375
			do -- 375
				local _obj_0 = entry.repo -- 375
				local _type_1 = type(_obj_0) -- 375
				if "table" == _type_1 or "userdata" == _type_1 then -- 375
					categories = _obj_0.categories -- 375
				end -- 375
			end -- 375
			if categories ~= nil then -- 375
				for _index_0 = 1, #categories do -- 376
					local category = categories[_index_0] -- 376
					if "string" == type(category) and category:lower() == "tool" then -- 377
						return true -- 378
					end -- 377
				end -- 376
			end -- 375
		end -- 375
	end -- 375
	return false -- 374
end -- 374
local getEntryTitle -- 380
getEntryTitle = function(entry) -- 380
	local title -- 381
	do -- 381
		local repo = entry.repo -- 381
		if repo then -- 381
			if repo.title and "table" == type(repo.title) then -- 382
				if useChinese then -- 383
					title = repo.title.zh -- 383
				else -- 383
					title = repo.title.en -- 383
				end -- 383
			end -- 382
		end -- 381
	end -- 381
	if title ~= nil then -- 384
		return title -- 384
	else -- 384
		return entry.entryName -- 384
	end -- 384
end -- 380
allEntries.rebuildEntries = function() -- 386
	gamesInDev = { } -- 387
	do -- 388
		local _accum_0 = { } -- 388
		local _len_0 = 1 -- 388
		local _list_0 = allEntries.builtinTools -- 388
		for _index_0 = 1, #_list_0 do -- 388
			local tool = _list_0[_index_0] -- 388
			_accum_0[_len_0] = tool -- 388
			_len_0 = _len_0 + 1 -- 388
		end -- 388
		doraTools = _accum_0 -- 388
	end -- 388
	local _list_0 = allEntries.projectEntries -- 389
	for _index_0 = 1, #_list_0 do -- 389
		local entry = _list_0[_index_0] -- 389
		if isToolEntry(entry) then -- 390
			entry.kind = "tool" -- 391
			doraTools[#doraTools + 1] = entry -- 392
		else -- 394
			entry.kind = "game" -- 394
			gamesInDev[#gamesInDev + 1] = entry -- 395
		end -- 390
	end -- 389
	for i = #allEntries, 1, -1 do -- 396
		allEntries[i] = nil -- 397
	end -- 396
	for _index_0 = 1, #gamesInDev do -- 398
		local game = gamesInDev[_index_0] -- 398
		allEntries[#allEntries + 1] = game -- 399
		local examples, tests = game.examples, game.tests -- 400
		for _index_1 = 1, #examples do -- 401
			local example = examples[_index_1] -- 401
			allEntries[#allEntries + 1] = example -- 402
		end -- 401
		for _index_1 = 1, #tests do -- 403
			local test = tests[_index_1] -- 403
			allEntries[#allEntries + 1] = test -- 404
		end -- 403
	end -- 398
end -- 386
local updateEntries -- 406
updateEntries = function() -- 406
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 407
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 408
	local _list_0 = allEntries.builtinTools -- 409
	for _index_0 = 1, #_list_0 do -- 409
		local tool = _list_0[_index_0] -- 409
		tool.kind = "tool" -- 410
		tool.builtin = true -- 411
	end -- 409
	return allEntries.rebuildEntries() -- 412
end -- 406
allEntries.refreshDirtyProjects = function() -- 414
	if not allEntries.hasDirty then -- 415
		return -- 415
	end -- 415
	local dirty = allEntries.dirty -- 416
	allEntries.dirty = { } -- 417
	allEntries.hasDirty = false -- 418
	for projectPath in pairs(dirty) do -- 419
		do -- 420
			local _accum_0 = { } -- 420
			local _len_0 = 1 -- 420
			local _list_0 = allEntries.projectEntries -- 420
			for _index_0 = 1, #_list_0 do -- 420
				local entry = _list_0[_index_0] -- 420
				if entry.projectPath ~= projectPath then -- 420
					_accum_0[_len_0] = entry -- 420
					_len_0 = _len_0 + 1 -- 420
				end -- 420
			end -- 420
			allEntries.projectEntries = _accum_0 -- 420
		end -- 420
		local parentPath = Path:getPath(projectPath) -- 421
		local dir = Path:getFilename(projectPath) -- 422
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 423
		for _index_0 = 1, #_list_0 do -- 423
			local entry = _list_0[_index_0] -- 423
			if entry.projectPath == projectPath then -- 424
				do -- 425
					local _obj_0 = allEntries.projectEntries -- 425
					_obj_0[#_obj_0 + 1] = entry -- 425
				end -- 425
				break -- 426
			end -- 424
		end -- 423
	end -- 419
	table.sort(allEntries.projectEntries, function(a, b) -- 427
		return a.entryName < b.entryName -- 427
	end) -- 427
	return allEntries.rebuildEntries() -- 428
end -- 414
updateEntries() -- 430
local getLaunchEntries -- 432
getLaunchEntries = function(refresh) -- 432
	if refresh == nil then -- 432
		refresh = false -- 432
	end -- 432
	if refresh then -- 433
		updateEntries() -- 433
	end -- 433
	local toInfo -- 434
	toInfo = function(entry, kind) -- 434
		local file = entry.fileName -- 435
		local asProj = not entry.builtin -- 436
		return { -- 438
			name = getEntryTitle(entry), -- 438
			file = file, -- 439
			kind = kind, -- 440
			asProj = asProj -- 441
		} -- 437
	end -- 434
	local games -- 443
	do -- 443
		local _accum_0 = { } -- 443
		local _len_0 = 1 -- 443
		for _index_0 = 1, #gamesInDev do -- 443
			local game = gamesInDev[_index_0] -- 443
			_accum_0[_len_0] = toInfo(game, "game") -- 443
			_len_0 = _len_0 + 1 -- 443
		end -- 443
		games = _accum_0 -- 443
	end -- 443
	local tools -- 444
	do -- 444
		local _accum_0 = { } -- 444
		local _len_0 = 1 -- 444
		for _index_0 = 1, #doraTools do -- 444
			local tool = doraTools[_index_0] -- 444
			_accum_0[_len_0] = toInfo(tool, "tool") -- 444
			_len_0 = _len_0 + 1 -- 444
		end -- 444
		tools = _accum_0 -- 444
	end -- 444
	return { -- 445
		games = games, -- 445
		tools = tools -- 445
	} -- 445
end -- 432
_module_0["getLaunchEntries"] = getLaunchEntries -- 432
local _anon_func_1 = function(entry, useChinese) -- 462
	local _obj_0 = entry.repo -- 462
	if _obj_0 ~= nil then -- 462
		local _obj_1 = _obj_0.description -- 462
		if _obj_1 ~= nil then -- 462
			return _obj_1[useChinese and "zh" or "en"] -- 462
		end -- 462
		return nil -- 462
	end -- 462
	return nil -- 462
end -- 462
local getMobileFeedEntries -- 447
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 447
	if refresh == nil then -- 447
		refresh = false -- 447
	end -- 447
	if dirtyProjectPath == nil then -- 447
		dirtyProjectPath = nil -- 447
	end -- 447
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 448
		allEntries.dirty[dirtyProjectPath] = true -- 449
		allEntries.hasDirty = true -- 450
	end -- 448
	if refresh then -- 451
		allEntries.dirty = { } -- 452
		allEntries.hasDirty = false -- 453
		updateEntries() -- 454
	else -- 456
		allEntries.refreshDirtyProjects() -- 456
	end -- 451
	local items = { } -- 457
	for _index_0 = 1, #gamesInDev do -- 458
		local entry = gamesInDev[_index_0] -- 458
		items[#items + 1] = { -- 460
			id = entry.entryName, -- 460
			title = getEntryTitle(entry), -- 461
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 462
			fileName = entry.fileName, -- 463
			workDir = Path:getPath(entry.fileName), -- 464
			bannerFile = entry.bannerFile, -- 465
			kind = "local" -- 466
		} -- 459
	end -- 458
	return items -- 468
end -- 447
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 447
local doCompile -- 470
doCompile = function(minify) -- 470
	if building then -- 471
		return -- 471
	end -- 471
	building = true -- 472
	local startTime = App.runningTime -- 473
	local luaFiles = { } -- 474
	local yueFiles = { } -- 475
	local xmlFiles = { } -- 476
	local tlFiles = { } -- 477
	local writablePath = Content.writablePath -- 478
	local buildPaths = { -- 480
		{ -- 481
			Content.assetPath, -- 481
			Path(writablePath, ".build"), -- 482
			"" -- 483
		} -- 480
	} -- 479
	for _index_0 = 1, #gamesInDev do -- 486
		local _des_0 = gamesInDev[_index_0] -- 486
		local fileName = _des_0.fileName -- 486
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 487
		buildPaths[#buildPaths + 1] = { -- 489
			Path(writablePath, gamePath), -- 489
			Path(writablePath, ".build", gamePath), -- 490
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 491
			gamePath -- 492
		} -- 488
	end -- 486
	for _index_0 = 1, #buildPaths do -- 493
		local _des_0 = buildPaths[_index_0] -- 493
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 493
		if not Content:exist(inputPath) then -- 494
			goto _continue_0 -- 494
		end -- 494
		local _list_0 = getAllFiles(inputPath, { -- 496
			"lua" -- 496
		}) -- 496
		for _index_1 = 1, #_list_0 do -- 496
			local file = _list_0[_index_1] -- 496
			luaFiles[#luaFiles + 1] = { -- 498
				file, -- 498
				Path(inputPath, file), -- 499
				Path(outputPath, file), -- 500
				gamePath -- 501
			} -- 497
		end -- 496
		local _list_1 = getAllFiles(inputPath, { -- 503
			yueext -- 503
		}) -- 503
		for _index_1 = 1, #_list_1 do -- 503
			local file = _list_1[_index_1] -- 503
			yueFiles[#yueFiles + 1] = { -- 505
				file, -- 505
				Path(inputPath, file), -- 506
				Path(outputPath, Path:replaceExt(file, "lua")), -- 507
				searchPath, -- 508
				gamePath -- 509
			} -- 504
		end -- 503
		local _list_2 = getAllFiles(inputPath, { -- 511
			"xml" -- 511
		}) -- 511
		for _index_1 = 1, #_list_2 do -- 511
			local file = _list_2[_index_1] -- 511
			xmlFiles[#xmlFiles + 1] = { -- 513
				file, -- 513
				Path(inputPath, file), -- 514
				Path(outputPath, Path:replaceExt(file, "lua")), -- 515
				gamePath -- 516
			} -- 512
		end -- 511
		local _list_3 = getAllFiles(inputPath, { -- 518
			"tl" -- 518
		}) -- 518
		for _index_1 = 1, #_list_3 do -- 518
			local file = _list_3[_index_1] -- 518
			if not file:match(".*%.d%.tl$") then -- 519
				tlFiles[#tlFiles + 1] = { -- 521
					file, -- 521
					Path(inputPath, file), -- 522
					Path(outputPath, Path:replaceExt(file, "lua")), -- 523
					searchPath, -- 524
					gamePath -- 525
				} -- 520
			end -- 519
		end -- 518
		::_continue_0:: -- 494
	end -- 493
	local paths -- 527
	do -- 527
		local _tbl_0 = { } -- 527
		local _list_0 = { -- 528
			luaFiles, -- 528
			yueFiles, -- 528
			xmlFiles, -- 528
			tlFiles -- 528
		} -- 528
		for _index_0 = 1, #_list_0 do -- 528
			local files = _list_0[_index_0] -- 528
			for _index_1 = 1, #files do -- 529
				local file = files[_index_1] -- 529
				_tbl_0[Path:getPath(file[3])] = true -- 527
			end -- 527
		end -- 527
		paths = _tbl_0 -- 527
	end -- 527
	for path in pairs(paths) do -- 531
		Content:mkdir(path) -- 531
	end -- 531
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 533
	local fileCount = 0 -- 534
	local errors = { } -- 535
	for _index_0 = 1, #yueFiles do -- 536
		local _des_0 = yueFiles[_index_0] -- 536
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 536
		local filename -- 537
		if gamePath then -- 537
			filename = Path(gamePath, file) -- 537
		else -- 537
			filename = file -- 537
		end -- 537
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 538
			if not codes then -- 539
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 540
				return -- 541
			end -- 539
			local success, result = LintYueGlobals(codes, globals) -- 542
			local yueCodes -- 543
			if not success then -- 544
				yueCodes = Content:load(input) -- 545
				if yueCodes then -- 545
					local CheckTIC80Code -- 546
					do -- 546
						local _obj_0 = require("Utils") -- 546
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 546
					end -- 546
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 547
					if isTIC80 then -- 548
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 549
					end -- 548
				end -- 545
			end -- 544
			if success then -- 550
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 551
			else -- 553
				if yueCodes then -- 553
					local globalErrors = { } -- 554
					for _index_1 = 1, #result do -- 555
						local _des_1 = result[_index_1] -- 555
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 555
						local countLine = 1 -- 556
						local code = "" -- 557
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 558
							if countLine == line then -- 559
								code = lineCode -- 560
								break -- 561
							end -- 559
							countLine = countLine + 1 -- 562
						end -- 558
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 563
					end -- 555
					if #globalErrors > 0 then -- 564
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 564
					end -- 564
				else -- 566
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 566
				end -- 553
				if #errors == 0 then -- 567
					return codes -- 567
				end -- 567
			end -- 550
		end, function(success) -- 538
			if success then -- 568
				print("Yue compiled: " .. tostring(filename)) -- 568
			end -- 568
			fileCount = fileCount + 1 -- 569
		end) -- 538
	end -- 536
	thread(function() -- 571
		for _index_0 = 1, #xmlFiles do -- 572
			local _des_0 = xmlFiles[_index_0] -- 572
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 572
			local filename -- 573
			if gamePath then -- 573
				filename = Path(gamePath, file) -- 573
			else -- 573
				filename = file -- 573
			end -- 573
			local sourceCodes = Content:loadAsync(input) -- 574
			local codes, err = xml.tolua(sourceCodes) -- 575
			if not codes then -- 576
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 577
			else -- 579
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 579
				print("Xml compiled: " .. tostring(filename)) -- 580
			end -- 576
			fileCount = fileCount + 1 -- 581
		end -- 572
	end) -- 571
	thread(function() -- 583
		for _index_0 = 1, #tlFiles do -- 584
			local _des_0 = tlFiles[_index_0] -- 584
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 584
			local filename -- 585
			if gamePath then -- 585
				filename = Path(gamePath, file) -- 585
			else -- 585
				filename = file -- 585
			end -- 585
			local sourceCodes = Content:loadAsync(input) -- 586
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 587
			if not codes then -- 588
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 589
			else -- 591
				Content:saveAsync(output, codes) -- 591
				print("Teal compiled: " .. tostring(filename)) -- 592
			end -- 588
			fileCount = fileCount + 1 -- 593
		end -- 584
	end) -- 583
	return thread(function() -- 595
		wait(function() -- 596
			return fileCount == totalFiles -- 596
		end) -- 596
		if minify then -- 597
			local _list_0 = { -- 598
				yueFiles, -- 598
				xmlFiles, -- 598
				tlFiles -- 598
			} -- 598
			for _index_0 = 1, #_list_0 do -- 598
				local files = _list_0[_index_0] -- 598
				for _index_1 = 1, #files do -- 598
					local file = files[_index_1] -- 598
					local output = Path:replaceExt(file[3], "lua") -- 599
					luaFiles[#luaFiles + 1] = { -- 601
						Path:replaceExt(file[1], "lua"), -- 601
						output, -- 602
						output -- 603
					} -- 600
				end -- 598
			end -- 598
			local FormatMini -- 605
			do -- 605
				local _obj_0 = require("luaminify") -- 605
				FormatMini = _obj_0.FormatMini -- 605
			end -- 605
			for _index_0 = 1, #luaFiles do -- 606
				local _des_0 = luaFiles[_index_0] -- 606
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 606
				if Content:exist(input) then -- 607
					local sourceCodes = Content:loadAsync(input) -- 608
					local res, err = FormatMini(sourceCodes) -- 609
					if res then -- 610
						Content:saveAsync(output, res) -- 611
						print("Minify: " .. tostring(file)) -- 612
					else -- 614
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 614
					end -- 610
				else -- 616
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 616
				end -- 607
			end -- 606
			package.loaded["luaminify.FormatMini"] = nil -- 617
			package.loaded["luaminify.ParseLua"] = nil -- 618
			package.loaded["luaminify.Scope"] = nil -- 619
			package.loaded["luaminify.Util"] = nil -- 620
		end -- 597
		local errorMessage = table.concat(errors, "\n") -- 621
		if errorMessage ~= "" then -- 622
			print(errorMessage) -- 622
		end -- 622
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 623
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 624
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 625
		Content:clearPathCache() -- 626
		teal.clear() -- 627
		yue.clear() -- 628
		building = false -- 629
	end) -- 595
end -- 470
local doClean -- 631
doClean = function() -- 631
	if building then -- 632
		return -- 632
	end -- 632
	local writablePath = Content.writablePath -- 633
	local targetDir = Path(writablePath, ".build") -- 634
	Content:clearPathCache() -- 635
	if Content:remove(targetDir) then -- 636
		return print("Cleaned: " .. tostring(targetDir)) -- 637
	end -- 636
end -- 631
local screenScale = 2.0 -- 639
local scaleContent = false -- 640
local isInEntry = true -- 641
local currentEntry = nil -- 642
local footerWindow = nil -- 644
local entryWindow = nil -- 645
local testingThread = nil -- 646
local mobileMode = config.mobileFeed -- 647
local pendingUIMode = nil -- 648
local feedHost = nil -- 649
local remixHost = nil -- 650
local startMobileUI = nil -- 651
local webControlled = false -- 652
local mobileHosts = { } -- 653
local suspendedMobileHosts = { } -- 654
local trackMobileHost -- 656
trackMobileHost = function(host) -- 656
	do -- 657
		local _accum_0 = { } -- 657
		local _len_0 = 1 -- 657
		for _index_0 = 1, #mobileHosts do -- 657
			local item = mobileHosts[_index_0] -- 657
			if item.parent then -- 657
				_accum_0[_len_0] = item -- 657
				_len_0 = _len_0 + 1 -- 657
			end -- 657
		end -- 657
		mobileHosts = _accum_0 -- 657
	end -- 657
	mobileHosts[#mobileHosts + 1] = host -- 658
	return host -- 659
end -- 656
local clearMobileUI -- 661
clearMobileUI = function() -- 661
	for _index_0 = 1, #mobileHosts do -- 662
		local host = mobileHosts[_index_0] -- 662
		if host.parent then -- 663
			host:removeFromParent(true) -- 663
		end -- 663
	end -- 662
	mobileHosts = { } -- 664
	suspendedMobileHosts = { } -- 665
	feedHost = nil -- 666
	remixHost = nil -- 667
end -- 661
local syncWebIDEControl -- 669
syncWebIDEControl = function() -- 669
	local connected = HttpServer.wsConnectionCount > 0 -- 670
	if connected then -- 671
		pendingUIMode = nil -- 672
		for _index_0 = 1, #mobileHosts do -- 673
			local host = mobileHosts[_index_0] -- 673
			if not host.parent then -- 674
				goto _continue_0 -- 674
			end -- 674
			if not (suspendedMobileHosts[host] ~= nil) then -- 675
				suspendedMobileHosts[host] = host.visible -- 676
				host:emit("SuspendLocalUI") -- 677
			end -- 675
			host.visible = false -- 678
			::_continue_0:: -- 674
		end -- 673
	elseif webControlled then -- 679
		for host, visible in pairs(suspendedMobileHosts) do -- 680
			if host.parent then -- 681
				host.visible = visible -- 682
				host:emit("ResumeLocalUI") -- 683
			end -- 681
		end -- 680
		suspendedMobileHosts = { } -- 684
	end -- 671
	webControlled = connected -- 685
	return connected -- 686
end -- 669
local getUIMode -- 688
getUIMode = function() -- 688
	return mobileMode and "mobile" or "traditional" -- 688
end -- 688
_module_0["getUIMode"] = getUIMode -- 688
local setUIMode -- 689
setUIMode = function(mode) -- 689
	if not (("mobile" == mode or "traditional" == mode)) then -- 690
		return false -- 690
	end -- 690
	if HttpServer.wsConnectionCount > 0 then -- 691
		return false -- 691
	end -- 691
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 692
		return false -- 692
	end -- 692
	local wantsMobile = mode == "mobile" -- 693
	if wantsMobile == mobileMode then -- 694
		return true -- 694
	end -- 694
	if mobileMode then -- 695
		if not (feedHost and feedHost.visible) then -- 696
			return false -- 696
		end -- 696
		feedHost:emit("SwitchUIMode") -- 698
		return pendingUIMode == false -- 699
	end -- 695
	pendingUIMode = true -- 700
	return true -- 701
end -- 689
_module_0["setUIMode"] = setUIMode -- 689
local applyUIMode -- 703
applyUIMode = function(enabled) -- 703
	if HttpServer.wsConnectionCount > 0 then -- 705
		return false -- 705
	end -- 705
	if enabled then -- 706
		local ok, err = pcall(startMobileUI) -- 707
		if not ok then -- 708
			if feedHost then -- 709
				feedHost:removeFromParent(true) -- 709
			end -- 709
			feedHost = nil -- 710
			mobileMode = false -- 711
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 712
			return false -- 713
		end -- 708
	else -- 715
		clearMobileUI() -- 715
		updateEntries() -- 716
	end -- 706
	mobileMode = enabled -- 717
	config.mobileFeed = enabled -- 718
	return true -- 719
end -- 703
local setupEventHandlers = nil -- 721
local allClear -- 723
allClear = function() -- 723
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 725
		clearMobileUI() -- 725
	end -- 725
	local systemNodes = { } -- 728
	local preserveSystemNode -- 729
	preserveSystemNode = function(node) -- 729
		if systemNodes[node] then -- 730
			return -- 730
		end -- 730
		systemNodes[node] = true -- 731
		do -- 732
			local clip = tolua.cast(node, "ClipNode") -- 732
			if clip then -- 732
				if clip.stencil then -- 733
					preserveSystemNode(clip.stencil) -- 733
				end -- 733
			end -- 732
		end -- 732
		return node:eachChild(function(child) -- 734
			preserveSystemNode(child) -- 735
			return false -- 736
		end) -- 734
	end -- 729
	for _index_0 = 1, #Routine do -- 737
		local routine = Routine[_index_0] -- 737
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 739
			goto _continue_0 -- 740
		else -- 742
			Routine:remove(routine) -- 742
		end -- 738
		::_continue_0:: -- 738
	end -- 737
	for _index_0 = 1, #moduleCache do -- 743
		local module = moduleCache[_index_0] -- 743
		package.loaded[module] = nil -- 744
	end -- 743
	moduleCache = { } -- 745
	Director:cleanup() -- 746
	Entity:clear() -- 747
	Platformer.Data:clear() -- 748
	Platformer.UnitAction:clear() -- 749
	Audio:stopAll(0.2) -- 750
	Struct:clear() -- 751
	View.nearPlaneDistance = 0.1 -- 754
	View.farPlaneDistance = 10000 -- 755
	View.fieldOfView = 45 -- 756
	View.postEffect = nil -- 757
	View.scale = scaleContent and screenScale or 1 -- 758
	Director.clearColor = Color(0xff1a1a1a) -- 759
	teal.clear() -- 760
	yue.clear() -- 761
	preserveSystemNode(Director.systemUI) -- 764
	for _, item in pairs(ubox()) do -- 765
		local node = tolua.cast(item, "Node") -- 766
		if node then -- 766
			if not systemNodes[node] then -- 767
				node:cleanup() -- 767
			end -- 767
		end -- 766
	end -- 765
	collectgarbage() -- 768
	collectgarbage() -- 769
	Wasm:clear() -- 770
	thread(function() -- 771
		sleep() -- 772
		return Cache:removeUnused() -- 773
	end) -- 771
	setupEventHandlers() -- 774
	Content.searchPaths = searchPaths -- 775
	App.idled = true -- 776
end -- 723
_module_0["allClear"] = allClear -- 723
local clearTempFiles -- 778
clearTempFiles = function() -- 778
	local writablePath = Content.writablePath -- 779
	if Content:exist(Path(writablePath, ".upload")) then -- 780
		Content:remove(Path(writablePath, ".upload")) -- 780
	end -- 780
	if Content:exist(Path(writablePath, ".download")) then -- 781
		return Content:remove(Path(writablePath, ".download")) -- 781
	end -- 781
end -- 778
local waitForWebStart = true -- 783
thread(function() -- 784
	sleep(2) -- 785
	waitForWebStart = false -- 786
end) -- 784
local reloadDevEntry -- 788
reloadDevEntry = function() -- 788
	return thread(function() -- 788
		waitForWebStart = true -- 789
		doClean() -- 790
		allClear() -- 791
		_G.require = oldRequire -- 792
		Dora.require = oldRequire -- 793
		package.loaded["Script.Dev.Entry"] = nil -- 794
		package.loaded["Script.Dev.WebServer"] = nil -- 795
		return Director.systemScheduler:schedule(function() -- 796
			Routine:clear() -- 797
			oldRequire("Script.Dev.Entry") -- 798
			return true -- 799
		end) -- 796
	end) -- 788
end -- 788
local setWorkspace -- 801
setWorkspace = function(path) -- 801
	clearTempFiles() -- 802
	Content.writablePath = path -- 803
	config.writablePath = Content.writablePath -- 804
	return thread(function() -- 805
		sleep() -- 806
		return reloadDevEntry() -- 807
	end) -- 805
end -- 801
_module_0["setWorkspace"] = setWorkspace -- 801
local quit = false -- 809
local activeSearchId = 0 -- 811
local handleSearchFiles -- 813
handleSearchFiles = function(payload) -- 813
	if not payload then -- 814
		return -- 814
	end -- 814
	local id = payload.id -- 815
	if id == nil then -- 816
		return -- 816
	end -- 816
	activeSearchId = id -- 817
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 818
	if path == nil then -- 819
		path = "" -- 819
	end -- 819
	if exts == nil then -- 820
		exts = { } -- 820
	end -- 820
	if globs == nil then -- 821
		globs = { } -- 821
	end -- 821
	if extensionLevels == nil then -- 822
		extensionLevels = { } -- 822
	end -- 822
	if pattern == nil then -- 823
		pattern = "" -- 823
	end -- 823
	if pattern == "" then -- 825
		return -- 825
	end -- 825
	local useRegex = payload.useRegex == true -- 826
	local caseSensitive = payload.caseSensitive == true -- 827
	local includeContent = payload.includeContent ~= false -- 828
	local contentWindow = payload.contentWindow or 0 -- 829
	return Director.systemScheduler:schedule(once(function() -- 830
		local stopped = false -- 831
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 832
			if activeSearchId ~= id then -- 833
				stopped = true -- 834
				return true -- 835
			end -- 833
			emit("AppWS", "Send", json.encode({ -- 837
				name = "SearchFilesResult", -- 837
				id = id, -- 837
				result = result -- 837
			})) -- 836
			return false -- 839
		end) -- 832
		return emit("AppWS", "Send", json.encode({ -- 841
			name = "SearchFilesDone", -- 841
			id = id, -- 841
			stopped = stopped -- 841
		})) -- 840
	end)) -- 830
end -- 813
local stop -- 844
stop = function() -- 844
	if isInEntry then -- 845
		return false -- 845
	end -- 845
	allClear() -- 846
	isInEntry = true -- 847
	currentEntry = nil -- 848
	return true -- 849
end -- 844
_module_0["stop"] = stop -- 844
local getCurrentEntryStatus -- 851
getCurrentEntryStatus = function() -- 851
	local entry = currentEntry -- 852
	if not (entry and not isInEntry) then -- 853
		return { -- 853
			success = true, -- 853
			running = false, -- 853
			runId = allEntries.runId -- 853
		} -- 853
	end -- 853
	local status = { -- 855
		success = true, -- 855
		running = true, -- 856
		kind = entry.runKind or "file", -- 857
		runId = allEntries.runId, -- 858
		entryName = entry.entryName, -- 859
		fileName = entry.fileName -- 860
	} -- 854
	if entry.workDir then -- 861
		status.workDir = entry.workDir -- 861
	end -- 861
	if entry.projectRoot then -- 862
		status.projectRoot = entry.projectRoot -- 862
	end -- 862
	return status -- 863
end -- 851
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 851
local _anon_func_2 = function(_with_0) -- 882
	local _val_0 = App.platform -- 882
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 882
end -- 882
setupEventHandlers = function() -- 865
	local _with_0 = Director.postNode -- 866
	_with_0:onAppEvent(function(eventType) -- 867
		if "Quit" == eventType then -- 868
			quit = true -- 869
			allClear() -- 870
			return clearTempFiles() -- 871
		elseif "Shutdown" == eventType then -- 872
			return stop() -- 873
		end -- 867
	end) -- 867
	_with_0:onAppChange(function(settingName) -- 874
		if "Theme" == settingName then -- 875
			config.themeColor = App.themeColor:toARGB() -- 876
		elseif "Locale" == settingName then -- 877
			config.locale = App.locale -- 878
			updateLocale() -- 879
			return teal.clear(true) -- 880
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 881
			if _anon_func_2(_with_0) then -- 882
				if "FullScreen" == settingName then -- 884
					config.fullScreen = App.fullScreen -- 884
				elseif "Position" == settingName then -- 885
					local _obj_0 = App.winPosition -- 885
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 885
				elseif "Size" == settingName then -- 886
					local width, height -- 887
					do -- 887
						local _obj_0 = App.winSize -- 887
						width, height = _obj_0.width, _obj_0.height -- 887
					end -- 887
					config.winWidth = width -- 888
					config.winHeight = height -- 889
				end -- 883
			end -- 882
		end -- 874
	end) -- 874
	_with_0:onAppWS(function(event) -- 890
		if event.type == "Close" then -- 891
			if HttpServer.wsConnectionCount == 0 then -- 892
				updateEntries() -- 893
			end -- 892
			return -- 894
		end -- 891
		if not (event.type == "Receive") then -- 895
			return -- 895
		end -- 895
		local data = json.decode(event.msg) -- 896
		if not data then -- 897
			return -- 897
		end -- 897
		local _exp_0 = data.name -- 898
		if "SearchFiles" == _exp_0 then -- 899
			return handleSearchFiles(data) -- 900
		elseif "SearchFilesStop" == _exp_0 then -- 901
			if data.id == nil or data.id == activeSearchId then -- 902
				activeSearchId = 0 -- 903
			end -- 902
		end -- 898
	end) -- 890
	_with_0:slot("UpdateEntries", function() -- 904
		return updateEntries() -- 904
	end) -- 904
	return _with_0 -- 866
end -- 865
setupEventHandlers() -- 906
clearTempFiles() -- 907
local downloadFile -- 909
downloadFile = function(url, target) -- 909
	return Director.systemScheduler:schedule(once(function() -- 909
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 910
			if quit then -- 911
				return true -- 911
			end -- 911
			emit("AppWS", "Send", json.encode({ -- 913
				name = "Download", -- 913
				url = url, -- 913
				status = "downloading", -- 913
				progress = current / total -- 914
			})) -- 912
			return false -- 910
		end) -- 910
		return emit("AppWS", "Send", json.encode(success and { -- 917
			name = "Download", -- 917
			url = url, -- 917
			status = "completed", -- 917
			progress = 1.0 -- 918
		} or { -- 920
			name = "Download", -- 920
			url = url, -- 920
			status = "failed", -- 920
			progress = 0.0 -- 921
		})) -- 916
	end)) -- 909
end -- 909
_module_0["downloadFile"] = downloadFile -- 909
local _anon_func_3 = function(file, require, workDir) -- 933
	if workDir == nil then -- 933
		workDir = Path:getPath(file) -- 933
	end -- 933
	Content:insertSearchPath(1, workDir) -- 934
	local scriptPath = Path(workDir, "Script") -- 935
	if Content:exist(scriptPath) then -- 936
		Content:insertSearchPath(1, scriptPath) -- 937
	end -- 936
	local result = require(file) -- 938
	if "function" == type(result) then -- 939
		result() -- 939
	end -- 939
	return nil -- 940
end -- 933
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 969
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 969
	label.alignment = "Left" -- 970
	label.textWidth = width - fontSize -- 971
	label.text = err -- 972
	return label -- 969
end -- 969
local enterEntryAsync -- 924
enterEntryAsync = function(entry) -- 924
	allEntries.runId = allEntries.runId + 1 -- 925
	isInEntry = false -- 926
	App.idled = false -- 927
	emit(Profiler.EventName, "ClearLoader") -- 928
	currentEntry = entry -- 929
	local file, workDir = entry.fileName, entry.workDir -- 930
	sleep() -- 931
	return xpcall(_anon_func_3, function(msg) -- 940
		local err = debug.traceback(msg) -- 942
		Log("Error", err) -- 943
		allClear() -- 944
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 945
		local viewWidth, viewHeight -- 946
		do -- 946
			local _obj_0 = View.size -- 946
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 946
		end -- 946
		local width, height = viewWidth - 20, viewHeight - 20 -- 947
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 948
		Director.ui:addChild((function() -- 949
			local root = AlignNode() -- 949
			do -- 950
				local _obj_0 = App.bufferSize -- 950
				width, height = _obj_0.width, _obj_0.height -- 950
			end -- 950
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 951
			root:onAppChange(function(settingName) -- 952
				if settingName == "Size" then -- 952
					do -- 953
						local _obj_0 = App.bufferSize -- 953
						width, height = _obj_0.width, _obj_0.height -- 953
					end -- 953
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 954
				end -- 952
			end) -- 952
			root:addChild((function() -- 955
				local _with_0 = ScrollArea({ -- 956
					width = width, -- 956
					height = height, -- 957
					paddingX = 0, -- 958
					paddingY = 50, -- 959
					viewWidth = height, -- 960
					viewHeight = height -- 961
				}) -- 955
				root:onAlignLayout(function(w, h) -- 963
					_with_0.position = Vec2(w / 2, h / 2) -- 964
					w = w - 20 -- 965
					h = h - 20 -- 966
					_with_0.view.children.first.textWidth = w - fontSize -- 967
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 968
				end) -- 963
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 969
				return _with_0 -- 955
			end)()) -- 955
			return root -- 949
		end)()) -- 949
		return err -- 973
	end, file, require, workDir) -- 932
end -- 924
_module_0["enterEntryAsync"] = enterEntryAsync -- 924
local enterDemoEntry -- 975
enterDemoEntry = function(entry) -- 975
	return thread(function() -- 975
		return enterEntryAsync(entry) -- 975
	end) -- 975
end -- 975
local reloadCurrentEntry -- 977
reloadCurrentEntry = function() -- 977
	if currentEntry then -- 978
		allClear() -- 979
		return enterDemoEntry(currentEntry) -- 980
	end -- 978
end -- 977
Director.clearColor = Color(0xff1a1a1a) -- 982
local descColor = Color(0xffa1a1a1) -- 983
local extraOperations -- 985
do -- 985
	local isOSSLicenseExist = Content:exist("LICENSES") -- 986
	local ossLicenses = nil -- 987
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 988
	local failedSetFolder = false -- 989
	local statusFlags = { -- 990
		"NoResize", -- 990
		"NoMove", -- 990
		"NoCollapse", -- 990
		"AlwaysAutoResize", -- 990
		"NoSavedSettings" -- 990
	} -- 990
	extraOperations = function() -- 997
		local zh = useChinese -- 998
		if isDesktop then -- 999
			local alwaysOnTop = config.alwaysOnTop -- 1000
			do -- 1001
				local changed -- 1001
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1001
				if changed then -- 1001
					App.alwaysOnTop = alwaysOnTop -- 1002
					config.alwaysOnTop = alwaysOnTop -- 1003
				end -- 1001
			end -- 1001
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1004
			do -- 1005
				local changed -- 1005
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1005
				if changed then -- 1005
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1006
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1007
				end -- 1005
			end -- 1005
			SameLine() -- 1008
			TextColored(descColor, "(?)") -- 1009
			if IsItemHovered() then -- 1010
				BeginTooltip(function() -- 1011
					return PushTextWrapPos(360, function() -- 1012
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1013
					end) -- 1012
				end) -- 1011
			end -- 1010
		end -- 999
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1028
		do -- 1033
			local changed -- 1033
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1033
			if changed then -- 1033
				config.showPreview = showPreview -- 1034
				updateEntries() -- 1035
				if not showPreview then -- 1036
					thread(function() -- 1037
						collectgarbage() -- 1038
						return Cache:removeUnused("Texture") -- 1039
					end) -- 1037
				end -- 1036
			end -- 1033
		end -- 1033
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1040
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1041
			if changed then -- 1041
				config.webIDEEnabled = webIDEEnabled -- 1042
				App.webIDEEnabled = webIDEEnabled -- 1043
			end -- 1041
		end -- 1040
		do -- 1044
			local changed -- 1044
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1044
			if changed then -- 1044
				config.authRequired = authRequired -- 1045
				HttpServer.authRequired = authRequired -- 1046
			end -- 1044
		end -- 1044
		SameLine() -- 1047
		TextColored(descColor, "(?)") -- 1048
		if IsItemHovered() then -- 1049
			BeginTooltip(function() -- 1050
				return PushTextWrapPos(280, function() -- 1051
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1052
				end) -- 1051
			end) -- 1050
		end -- 1049
		do -- 1053
			local themeColor = App.themeColor -- 1054
			local writablePath = config.writablePath -- 1055
			SeparatorText(zh and "工作目录" or "Workspace") -- 1056
			PushTextWrapPos(400, function() -- 1057
				return TextColored(themeColor, writablePath) -- 1058
			end) -- 1057
			if not isDesktop then -- 1059
				goto skipSetting -- 1059
			end -- 1059
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1060
			if Button(zh and "改变目录" or "Set Folder") then -- 1061
				App:openFileDialog(true, function(path) -- 1062
					if path == "" then -- 1063
						return -- 1063
					end -- 1063
					local relPath = Path:getRelative(Content.assetPath, path) -- 1064
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1065
						return setWorkspace(path) -- 1066
					else -- 1068
						failedSetFolder = true -- 1068
					end -- 1065
				end) -- 1062
			end -- 1061
			if failedSetFolder then -- 1069
				failedSetFolder = false -- 1070
				OpenPopup(popupName) -- 1071
			end -- 1069
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1072
			BeginPopupModal(popupName, statusFlags, function() -- 1073
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1074
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1075
					return CloseCurrentPopup() -- 1076
				end -- 1075
			end) -- 1073
			SameLine() -- 1077
			if Button(zh and "使用默认" or "Use Default") then -- 1078
				setWorkspace(Content.appPath) -- 1079
			end -- 1078
			Separator() -- 1080
			::skipSetting:: -- 1081
		end -- 1053
		if isOSSLicenseExist then -- 1082
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1083
				if not ossLicenses then -- 1084
					local licenseText = Content:load("LICENSES") -- 1085
					if licenseText then -- 1085
						ossLicenses = { } -- 1086
						licenseText = licenseText:gsub("\r\n", "\n") -- 1087
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1088
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1089
							if name then -- 1089
								ossLicenses[#ossLicenses + 1] = { -- 1090
									name, -- 1090
									text -- 1090
								} -- 1090
							end -- 1089
						end -- 1088
					end -- 1085
				end -- 1084
				if ossLicenses then -- 1091
					OpenPopup(ossLicensePopup) -- 1091
				end -- 1091
			end -- 1083
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1092
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1093
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1094
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1095
				return BeginPopupModal(ossLicensePopup, true, { -- 1098
					"NoSavedSettings" -- 1098
				}, function() -- 1099
					for _index_0 = 1, #ossLicenses do -- 1100
						local _des_0 = ossLicenses[_index_0] -- 1100
						local firstLine, text = _des_0[1], _des_0[2] -- 1100
						local name, license = firstLine:match("(.+): (.+)") -- 1102
						if name then -- 1102
							TextColored(themeColor, name) -- 1103
							SameLine() -- 1104
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1105
								return TextWrapped(text) -- 1105
							end) -- 1105
						end -- 1102
					end -- 1100
				end) -- 1095
			end) -- 1095
		end -- 1082
		if not App.debugging then -- 1108
			return -- 1108
		end -- 1108
		return TreeNode(zh and "开发操作" or "Development", function() -- 1109
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1110
				OpenPopup("build") -- 1110
			end -- 1110
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1111
				return BeginPopup("build", function() -- 1111
					if Selectable(zh and "编译" or "Compile") then -- 1112
						doCompile(false) -- 1112
					end -- 1112
					Separator() -- 1113
					if Selectable(zh and "压缩" or "Minify") then -- 1114
						doCompile(true) -- 1114
					end -- 1114
					Separator() -- 1115
					if Selectable(zh and "清理" or "Clean") then -- 1116
						return doClean() -- 1116
					end -- 1116
				end) -- 1111
			end) -- 1111
			if isInEntry then -- 1117
				if waitForWebStart then -- 1118
					BeginDisabled(function() -- 1119
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1119
					end) -- 1119
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1120
					reloadDevEntry() -- 1121
				end -- 1118
			end -- 1117
			do -- 1122
				local changed -- 1122
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1122
				if changed then -- 1122
					View.scale = scaleContent and screenScale or 1 -- 1123
				end -- 1122
			end -- 1122
			do -- 1124
				local changed -- 1124
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1124
				if changed then -- 1124
					config.engineDev = engineDev -- 1125
				end -- 1124
			end -- 1124
			do -- 1126
				local changed -- 1126
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1126
				if changed then -- 1126
					config.webIDETourCompleted = webIDETourCompleted -- 1127
				end -- 1126
			end -- 1126
			if testingThread then -- 1128
				return BeginDisabled(function() -- 1129
					return Button(zh and "开始自动测试" or "Test automatically") -- 1129
				end) -- 1129
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1130
				testingThread = thread(function() -- 1131
					local _ <close> = setmetatable({ }, { -- 1132
						__close = function() -- 1132
							allClear() -- 1133
							testingThread = nil -- 1134
							isInEntry = true -- 1135
							currentEntry = nil -- 1136
							return print("Testing done!") -- 1137
						end -- 1132
					}) -- 1132
					for _, entry in ipairs(allEntries) do -- 1138
						allClear() -- 1139
						print("Start " .. tostring(entry.entryName)) -- 1140
						enterDemoEntry(entry) -- 1141
						sleep(2) -- 1142
						print("Stop " .. tostring(entry.entryName)) -- 1143
					end -- 1138
				end) -- 1131
			end -- 1128
		end) -- 1109
	end -- 997
end -- 985
local icon = Path("Script", "Dev", "icon_s.png") -- 1145
local iconTex = nil -- 1146
thread(function() -- 1147
	if Cache:loadAsync(icon) then -- 1147
		iconTex = Texture2D(icon) -- 1147
	end -- 1147
end) -- 1147
local webStatus = nil -- 1149
local urlClicked = nil -- 1150
local authCode = string.format("%06d", math.random(0, 999999)) -- 1152
local authCodeTTL = 30.0 -- 1154
_module_0.getAuthCode = function() -- 1155
	return authCode -- 1155
end -- 1155
_module_0.invalidateAuthCode = function() -- 1156
	authCode = string.format("%06d", math.random(0, 999999)) -- 1157
	authCodeTTL = 30.0 -- 1158
end -- 1156
local AuthSession -- 1160
do -- 1160
	local pending = nil -- 1161
	local session = nil -- 1162
	AuthSession = { -- 1164
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1164
			pending = { -- 1166
				sessionId = sessionId, -- 1166
				confirmCode = confirmCode, -- 1167
				expiresAt = expiresAt, -- 1168
				ttl = ttl, -- 1169
				approved = false -- 1170
			} -- 1165
		end, -- 1164
		getPending = function() -- 1172
			return pending -- 1172
		end, -- 1172
		approvePending = function(sessionId) -- 1174
			if pending and pending.sessionId == sessionId then -- 1175
				pending.approved = true -- 1176
				return true -- 1177
			end -- 1175
			return false -- 1178
		end, -- 1174
		clearPending = function() -- 1180
			pending = nil -- 1180
		end, -- 1180
		setSession = function(sessionId, sessionSecret) -- 1182
			session = { -- 1184
				sessionId = sessionId, -- 1184
				sessionSecret = sessionSecret -- 1185
			} -- 1183
		end, -- 1182
		getSession = function() -- 1187
			return session -- 1187
		end -- 1187
	} -- 1163
end -- 1160
_module_0["AuthSession"] = AuthSession -- 1160
local transparant = Color(0x0) -- 1190
local windowFlags = { -- 1191
	"NoTitleBar", -- 1191
	"NoResize", -- 1191
	"NoMove", -- 1191
	"NoCollapse", -- 1191
	"NoSavedSettings", -- 1191
	"NoFocusOnAppearing", -- 1191
	"NoBringToFrontOnFocus" -- 1191
} -- 1191
local statusFlags = { -- 1200
	"NoTitleBar", -- 1200
	"NoResize", -- 1200
	"NoMove", -- 1200
	"NoCollapse", -- 1200
	"AlwaysAutoResize", -- 1200
	"NoSavedSettings" -- 1200
} -- 1200
local displayWindowFlags = { -- 1208
	"NoDecoration", -- 1208
	"NoSavedSettings", -- 1208
	"NoMove", -- 1208
	"NoScrollWithMouse", -- 1208
	"AlwaysAutoResize", -- 1208
	"NoFocusOnAppearing" -- 1208
} -- 1208
local gamepadInputWindowFlags = { -- 1216
	"NoDecoration", -- 1216
	"NoSavedSettings", -- 1216
	"NoMove", -- 1216
	"NoScrollbar", -- 1216
	"NoScrollWithMouse", -- 1216
	"NoFocusOnAppearing", -- 1216
	"NoBringToFrontOnFocus" -- 1216
} -- 1216
local initFooter = true -- 1225
local gamepadInputFocused = false -- 1226
local _anon_func_5 = function(allEntries, currentIndex) -- 1272
	if currentIndex > 1 then -- 1272
		return allEntries[currentIndex - 1] -- 1273
	else -- 1275
		return allEntries[#allEntries] -- 1275
	end -- 1272
end -- 1272
local _anon_func_6 = function(allEntries, currentIndex) -- 1279
	if currentIndex < #allEntries then -- 1279
		return allEntries[currentIndex + 1] -- 1280
	else -- 1282
		return allEntries[1] -- 1282
	end -- 1279
end -- 1279
footerWindow = threadLoop(function() -- 1227
	if mobileMode then -- 1228
		return -- 1228
	end -- 1228
	local zh = useChinese -- 1229
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1230
	if authCodeTTL <= 0 then -- 1231
		authCodeTTL = 30.0 -- 1232
		authCode = string.format("%06d", math.random(0, 999999)) -- 1233
	end -- 1231
	if HttpServer.wsConnectionCount > 0 then -- 1234
		return -- 1235
	end -- 1234
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1236
		if App.platform == "Emscripten" then -- 1237
			stop() -- 1239
		else -- 1241
			allClear() -- 1241
			App.devMode = false -- 1242
			App:shutdown() -- 1243
		end -- 1237
	end -- 1236
	do -- 1244
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1245
		if ctrl and Keyboard:isKeyDown("Q") then -- 1246
			stop() -- 1247
		end -- 1246
		if ctrl and Keyboard:isKeyDown("Z") then -- 1248
			reloadCurrentEntry() -- 1249
		end -- 1248
		if ctrl and Keyboard:isKeyDown(",") then -- 1250
			if showFooter then -- 1251
				showStats = not showStats -- 1251
			else -- 1251
				showStats = true -- 1251
			end -- 1251
			showFooter = true -- 1252
			config.showFooter = showFooter -- 1253
			config.showStats = showStats -- 1254
		end -- 1250
		if ctrl and Keyboard:isKeyDown(".") then -- 1255
			if showFooter then -- 1256
				showConsole = not showConsole -- 1256
			else -- 1256
				showConsole = true -- 1256
			end -- 1256
			showFooter = true -- 1257
			config.showFooter = showFooter -- 1258
			config.showConsole = showConsole -- 1259
		end -- 1255
		if ctrl and Keyboard:isKeyDown("/") then -- 1260
			showFooter = not showFooter -- 1261
			config.showFooter = showFooter -- 1262
		end -- 1260
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1263
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1264
		local currentIndex = nil -- 1265
		for i, entry in ipairs(allEntries) do -- 1266
			if currentEntry == entry then -- 1267
				currentIndex = i -- 1268
			end -- 1267
		end -- 1266
		if left then -- 1269
			allClear() -- 1270
			if currentIndex == nil then -- 1271
				currentIndex = #allEntries + 1 -- 1271
			end -- 1271
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1272
		end -- 1269
		if right then -- 1276
			allClear() -- 1277
			if currentIndex == nil then -- 1278
				currentIndex = 0 -- 1278
			end -- 1278
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1279
		end -- 1276
	end -- 1244
	if not showEntry then -- 1283
		return -- 1283
	end -- 1283
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1285
		reloadDevEntry() -- 1289
	end -- 1285
	if initFooter then -- 1290
		initFooter = false -- 1291
	end -- 1290
	local width, height -- 1293
	do -- 1293
		local _obj_0 = App.visualSize -- 1293
		width, height = _obj_0.width, _obj_0.height -- 1293
	end -- 1293
	if isInEntry then -- 1294
		gamepadInputFocused = false -- 1295
	else -- 1297
		SetNextWindowBgAlpha(0.0) -- 1297
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1298
		SetNextWindowPos(Vec2.zero, "Always") -- 1299
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1300
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1301
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1302
					if not gamepadInputFocused then -- 1303
						SetWindowFocus("DoraGamepadInput") -- 1304
						gamepadInputFocused = true -- 1305
					end -- 1303
				end) -- 1302
			end) -- 1301
		end) -- 1300
	end -- 1294
	if isInEntry or showFooter then -- 1307
		SetNextWindowSize(Vec2(width, 50)) -- 1308
		SetNextWindowPos(Vec2(0, height - 50)) -- 1309
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1310
			return PushStyleVar("WindowRounding", 0, function() -- 1311
				return Begin("Footer", windowFlags, function() -- 1312
					Separator() -- 1313
					if iconTex then -- 1314
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1315
							showStats = not showStats -- 1316
							config.showStats = showStats -- 1317
						end -- 1315
						SameLine() -- 1318
						if Button(">_", Vec2(30, 30)) then -- 1319
							showConsole = not showConsole -- 1320
							config.showConsole = showConsole -- 1321
						end -- 1319
					end -- 1314
					if isInEntry and config.updateNotification then -- 1322
						SameLine() -- 1323
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1324
							allClear() -- 1325
							config.updateNotification = false -- 1326
							enterDemoEntry({ -- 1328
								entryName = "SelfUpdater", -- 1328
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1329
							}) -- 1327
						end -- 1324
					end -- 1322
					if not isInEntry then -- 1330
						SameLine() -- 1331
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1332
						local currentIndex = nil -- 1333
						for i, entry in ipairs(allEntries) do -- 1334
							if currentEntry == entry then -- 1335
								currentIndex = i -- 1336
							end -- 1335
						end -- 1334
						if currentIndex then -- 1337
							if currentIndex > 1 then -- 1338
								SameLine() -- 1339
								if Button("<<", Vec2(30, 30)) then -- 1340
									allClear() -- 1341
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1342
								end -- 1340
							end -- 1338
							if currentIndex < #allEntries then -- 1343
								SameLine() -- 1344
								if Button(">>", Vec2(30, 30)) then -- 1345
									allClear() -- 1346
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1347
								end -- 1345
							end -- 1343
						end -- 1337
						SameLine() -- 1348
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1349
							reloadCurrentEntry() -- 1350
						end -- 1349
						if back then -- 1351
							allClear() -- 1352
							isInEntry = true -- 1353
							currentEntry = nil -- 1354
						end -- 1351
					end -- 1330
				end) -- 1312
			end) -- 1311
		end) -- 1310
	end -- 1307
	if isInEntry then -- 1356
		local showURL = true -- 1357
		local webIDEWidth -- 1358
		do -- 1358
			local base -- 1359
			if config.updateNotification then -- 1359
				base = 460 -- 1359
			else -- 1359
				base = 360 -- 1359
			end -- 1359
			local extra -- 1360
			if config.authRequired then -- 1360
				extra = 35 -- 1360
			else -- 1360
				extra = 0 -- 1360
			end -- 1360
			webIDEWidth = base + extra -- 1361
		end -- 1358
		if width < webIDEWidth then -- 1362
			showURL = false -- 1362
		end -- 1362
		SetNextWindowBgAlpha(0.0) -- 1363
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1364
		Begin("Web IDE", displayWindowFlags, function() -- 1365
			local pending = AuthSession.getPending() -- 1366
			local hovered = false -- 1367
			if not pending and showURL then -- 1368
				do -- 1369
					local url -- 1369
					if webStatus ~= nil then -- 1369
						url = webStatus.url -- 1369
					end -- 1369
					if url then -- 1369
						if isDesktop and not config.fullScreen then -- 1370
							if urlClicked then -- 1371
								BeginDisabled(function() -- 1372
									return Button(url) -- 1372
								end) -- 1372
							elseif Button(url) then -- 1373
								urlClicked = once(function() -- 1374
									return sleep(5) -- 1374
								end) -- 1374
								App:openURL("http://localhost:8866") -- 1375
							end -- 1371
						else -- 1377
							TextColored(descColor, url) -- 1377
						end -- 1370
					else -- 1379
						TextColored(descColor, zh and '不可用' or 'not available') -- 1379
					end -- 1369
				end -- 1369
				hovered = IsItemHovered() -- 1380
			else -- 1382
				TextColored(descColor, "(?)") -- 1382
				hovered = IsItemHovered() -- 1383
			end -- 1368
			SameLine() -- 1384
			local themeColor = App.themeColor -- 1385
			if pending then -- 1386
				if not pending.approved then -- 1387
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1388
					local ttl = pending.ttl or 1 -- 1389
					PushStyleColor("Text", themeColor, function() -- 1390
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1391
						hovered = hovered or IsItemHovered() -- 1392
					end) -- 1390
					SameLine() -- 1393
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1394
						AuthSession.approvePending(pending.sessionId) -- 1395
					end -- 1394
					if hovered then -- 1396
						return BeginTooltip(function() -- 1397
							return PushTextWrapPos(280, function() -- 1398
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1399
							end) -- 1398
						end) -- 1397
					end -- 1396
				end -- 1387
			else -- 1401
				if config.authRequired then -- 1401
					PushStyleColor("Text", themeColor, function() -- 1402
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1403
						hovered = hovered or IsItemHovered() -- 1404
					end) -- 1402
					if hovered then -- 1405
						return BeginTooltip(function() -- 1406
							return PushTextWrapPos(280, function() -- 1407
								local url -- 1408
								if webStatus ~= nil then -- 1408
									url = webStatus.url -- 1408
								end -- 1408
								if url then -- 1408
									local address -- 1409
									if showURL then -- 1409
										address = "Web IDE" -- 1409
									else -- 1409
										address = url -- 1409
									end -- 1409
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1410
								else -- 1412
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1412
								end -- 1408
							end) -- 1407
						end) -- 1406
					end -- 1405
				else -- 1414
					if hovered then -- 1414
						return BeginTooltip(function() -- 1415
							return PushTextWrapPos(280, function() -- 1416
								local url -- 1417
								if webStatus ~= nil then -- 1417
									url = webStatus.url -- 1417
								end -- 1417
								if url then -- 1417
									local address -- 1418
									if showURL then -- 1418
										address = "Web IDE" -- 1418
									else -- 1418
										address = url -- 1418
									end -- 1418
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1419
								else -- 1421
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1421
								end -- 1417
							end) -- 1416
						end) -- 1415
					end -- 1414
				end -- 1401
			end -- 1386
		end) -- 1365
	end -- 1356
	if not isInEntry then -- 1423
		SetNextWindowSize(Vec2(50, 50)) -- 1424
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1425
		PushStyleColor("WindowBg", transparant, function() -- 1426
			return Begin("Show", displayWindowFlags, function() -- 1426
				if width >= 370 then -- 1427
					local changed -- 1428
					changed, showFooter = Checkbox("##dev", showFooter) -- 1428
					if changed then -- 1428
						config.showFooter = showFooter -- 1429
					end -- 1428
				end -- 1427
			end) -- 1426
		end) -- 1426
	end -- 1423
	if isInEntry or showFooter then -- 1431
		if showStats then -- 1432
			PushStyleVar("WindowRounding", 0, function() -- 1433
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1434
				SetNextWindowSize(Vec2(0, height - 50)) -- 1435
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1436
				config.showStats = showStats -- 1437
			end) -- 1433
		end -- 1432
		if showConsole then -- 1438
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1439
			return PushStyleVar("WindowRounding", 6, function() -- 1440
				return ShowConsole() -- 1441
			end) -- 1440
		end -- 1438
	end -- 1431
end) -- 1227
local MaxWidth <const> = 960 -- 1443
local toolOpen = false -- 1445
local filterText = nil -- 1446
allEntries.anyEntryMatched = false -- 1447
allEntries.match = function(name) -- 1448
	local res = not filterText or name:lower():match(filterText) -- 1449
	if res then -- 1450
		allEntries.anyEntryMatched = true -- 1450
	end -- 1450
	return res -- 1451
end -- 1448
allEntries.thinSep = function() -- 1453
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1453
		return SeparatorText("") -- 1453
	end) -- 1453
end -- 1453
entryWindow = threadLoop(function() -- 1455
	local connected = syncWebIDEControl() -- 1456
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1458
		if not allEntries.pendingPackagePath then -- 1459
			local path = App:takeReceivedFile() -- 1460
			if path ~= "" then -- 1461
				allEntries.pendingPackagePath = path -- 1461
			end -- 1461
		end -- 1459
		if allEntries.pendingPackagePath then -- 1462
			pendingUIMode = true -- 1462
		end -- 1462
	end -- 1458
	if (pendingUIMode ~= nil) then -- 1464
		local nextMode = pendingUIMode -- 1465
		pendingUIMode = nil -- 1466
		applyUIMode(nextMode) -- 1467
	end -- 1464
	if mobileMode and not connected then -- 1468
		if isInEntry and not feedHost then -- 1469
			applyUIMode(true) -- 1469
		end -- 1469
		return -- 1470
	end -- 1468
	if App.fpsLimited ~= config.fpsLimited then -- 1471
		config.fpsLimited = App.fpsLimited -- 1472
	end -- 1471
	if App.targetFPS ~= config.targetFPS then -- 1473
		config.targetFPS = App.targetFPS -- 1474
	end -- 1473
	if View.vsync ~= config.vsync then -- 1475
		config.vsync = View.vsync -- 1476
	end -- 1475
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1477
		config.fixedFPS = Director.scheduler.fixedFPS -- 1478
	end -- 1477
	if Director.profilerSending ~= config.webProfiler then -- 1479
		config.webProfiler = Director.profilerSending -- 1480
	end -- 1479
	if urlClicked then -- 1481
		local _, result = coroutine.resume(urlClicked) -- 1482
		if result then -- 1483
			coroutine.close(urlClicked) -- 1484
			urlClicked = nil -- 1485
		end -- 1483
	end -- 1481
	if not isInEntry then -- 1486
		return -- 1486
	end -- 1486
	local zh = useChinese -- 1487
	local themeColor = App.themeColor -- 1488
	if connected then -- 1489
		local width, height -- 1490
		do -- 1490
			local _obj_0 = App.visualSize -- 1490
			width, height = _obj_0.width, _obj_0.height -- 1490
		end -- 1490
		SetNextWindowBgAlpha(0.5) -- 1491
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1492
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1493
			Separator() -- 1494
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1495
			if iconTex then -- 1496
				Image(icon, Vec2(24, 24)) -- 1497
				SameLine() -- 1498
			end -- 1496
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1499
			TextColored(descColor, slogon) -- 1500
			return Separator() -- 1501
		end) -- 1493
		return -- 1502
	end -- 1489
	if not showEntry then -- 1503
		return -- 1503
	end -- 1503
	local fullWidth, height -- 1505
	do -- 1505
		local _obj_0 = App.visualSize -- 1505
		fullWidth, height = _obj_0.width, _obj_0.height -- 1505
	end -- 1505
	local width = math.min(MaxWidth, fullWidth) -- 1506
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1507
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1508
	SetNextWindowPos(Vec2.zero) -- 1509
	SetNextWindowBgAlpha(0) -- 1510
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1511
	do -- 1512
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1513
			return Begin("Dora Dev", windowFlags, function() -- 1514
				Dummy(Vec2(fullWidth - 20, 0)) -- 1515
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1516
				SameLine() -- 1517
				if Button(zh and "Go 模式" or "Go Mode") then -- 1518
					setUIMode("mobile") -- 1519
				end -- 1518
				if fullWidth >= 540 then -- 1520
					SameLine() -- 1521
					Dummy(Vec2(fullWidth - 540, 0)) -- 1522
					SameLine() -- 1523
					SetNextItemWidth(zh and -95 or -140) -- 1524
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1525
						"AutoSelectAll" -- 1525
					}) then -- 1525
						config.filter = filterBuf.text -- 1526
					end -- 1525
					SameLine() -- 1527
					if Button(zh and '下载' or 'Download') then -- 1528
						allClear() -- 1529
						enterDemoEntry({ -- 1531
							entryName = "ResourceDownloader", -- 1531
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1532
						}) -- 1530
					end -- 1528
				end -- 1520
				return Separator() -- 1533
			end) -- 1514
		end) -- 1513
	end -- 1512
	allEntries.anyEntryMatched = false -- 1535
	SetNextWindowPos(Vec2(0, 50)) -- 1536
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1537
	do -- 1538
		return PushStyleColor("WindowBg", transparant, function() -- 1539
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1540
				return PushStyleVar("Alpha", 1, function() -- 1541
					return Begin("Content", windowFlags, function() -- 1542
						local DemoViewWidth <const> = 220 -- 1543
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1544
						if filterText then -- 1545
							filterText = filterText:lower() -- 1545
						end -- 1545
						if App.platform == "Emscripten" then -- 1546
							Dora.globals.webProjects.draw(zh, themeColor) -- 1547
							allEntries.anyEntryMatched = true -- 1548
						end -- 1546
						if #gamesInDev > 0 then -- 1549
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1550
							Columns(columns, false) -- 1551
							local realViewWidth = GetColumnWidth() - 50 -- 1552
							for _index_0 = 1, #gamesInDev do -- 1553
								local game = gamesInDev[_index_0] -- 1553
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1554
								local displayName -- 1563
								if repo then -- 1563
									if zh then -- 1564
										displayName = repo.title.zh -- 1564
									else -- 1564
										displayName = repo.title.en -- 1564
									end -- 1564
								end -- 1563
								if displayName == nil then -- 1565
									displayName = gameName -- 1565
								end -- 1565
								if allEntries.match(displayName) then -- 1566
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1567
									SameLine() -- 1568
									TextWrapped(displayName) -- 1569
									if columns > 1 then -- 1570
										if bannerFile and bannerTex then -- 1571
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1572
											local displayWidth <const> = realViewWidth -- 1573
											texHeight = displayWidth * texHeight / texWidth -- 1574
											texWidth = displayWidth -- 1575
											Dummy(Vec2.zero) -- 1576
											SameLine() -- 1577
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1578
										end -- 1571
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1579
											enterDemoEntry(game) -- 1580
										end -- 1579
									else -- 1582
										if bannerFile and bannerTex then -- 1582
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1583
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1584
											local sizing = 0.8 -- 1585
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1586
											texWidth = displayWidth * sizing -- 1587
											if texWidth > 500 then -- 1588
												sizing = 0.6 -- 1589
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1590
												texWidth = displayWidth * sizing -- 1591
											end -- 1588
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1592
											Dummy(Vec2(padding, 0)) -- 1593
											SameLine() -- 1594
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1595
										end -- 1582
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1596
											enterDemoEntry(game) -- 1597
										end -- 1596
									end -- 1570
									if #tests == 0 and #examples == 0 then -- 1598
										allEntries.thinSep() -- 1599
									end -- 1598
									NextColumn() -- 1600
								end -- 1566
								local showSep = false -- 1601
								if #examples > 0 then -- 1602
									local showExample = false -- 1603
									for _index_1 = 1, #examples do -- 1604
										local _des_0 = examples[_index_1] -- 1604
										local entryName = _des_0.entryName -- 1604
										if allEntries.match(entryName) then -- 1605
											showExample = true -- 1605
											break -- 1605
										end -- 1605
									end -- 1604
									if showExample then -- 1606
										showSep = true -- 1607
										Columns(1, false) -- 1608
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1609
										SameLine() -- 1610
										local opened -- 1611
										if (filterText ~= nil) then -- 1611
											opened = showExample -- 1611
										else -- 1611
											opened = false -- 1611
										end -- 1611
										if game.exampleOpen == nil then -- 1612
											game.exampleOpen = opened -- 1612
										end -- 1612
										SetNextItemOpen(game.exampleOpen) -- 1613
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1614
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1615
												Columns(maxColumns, false) -- 1616
												for _index_1 = 1, #examples do -- 1617
													local example = examples[_index_1] -- 1617
													local entryName = example.entryName -- 1618
													if not allEntries.match(entryName) then -- 1619
														goto _continue_0 -- 1619
													end -- 1619
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1620
														if Button(entryName, Vec2(-1, 40)) then -- 1621
															enterDemoEntry(example) -- 1622
														end -- 1621
														return NextColumn() -- 1623
													end) -- 1620
													opened = true -- 1624
													::_continue_0:: -- 1618
												end -- 1617
											end) -- 1615
										end) -- 1614
										game.exampleOpen = opened -- 1625
									end -- 1606
								end -- 1602
								if #tests > 0 then -- 1626
									local showTest = false -- 1627
									for _index_1 = 1, #tests do -- 1628
										local _des_0 = tests[_index_1] -- 1628
										local entryName = _des_0.entryName -- 1628
										if allEntries.match(entryName) then -- 1629
											showTest = true -- 1629
											break -- 1629
										end -- 1629
									end -- 1628
									if showTest then -- 1630
										showSep = true -- 1631
										Columns(1, false) -- 1632
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1633
										SameLine() -- 1634
										local opened -- 1635
										if (filterText ~= nil) then -- 1635
											opened = showTest -- 1635
										else -- 1635
											opened = false -- 1635
										end -- 1635
										if game.testOpen == nil then -- 1636
											game.testOpen = opened -- 1636
										end -- 1636
										SetNextItemOpen(game.testOpen) -- 1637
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1638
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1639
												Columns(maxColumns, false) -- 1640
												for _index_1 = 1, #tests do -- 1641
													local test = tests[_index_1] -- 1641
													local entryName = test.entryName -- 1642
													if not allEntries.match(entryName) then -- 1643
														goto _continue_0 -- 1643
													end -- 1643
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1644
														if Button(entryName, Vec2(-1, 40)) then -- 1645
															enterDemoEntry(test) -- 1646
														end -- 1645
														return NextColumn() -- 1647
													end) -- 1644
													opened = true -- 1648
													::_continue_0:: -- 1642
												end -- 1641
											end) -- 1639
										end) -- 1638
										game.testOpen = opened -- 1649
									end -- 1630
								end -- 1626
								if showSep then -- 1650
									Columns(1, false) -- 1651
									allEntries.thinSep() -- 1652
									Columns(columns, false) -- 1653
								end -- 1650
							end -- 1553
						end -- 1549
						if #doraTools > 0 then -- 1654
							local showTool = false -- 1655
							for _index_0 = 1, #doraTools do -- 1656
								local _des_0 = doraTools[_index_0] -- 1656
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1656
								local displayName -- 1657
								if repo then -- 1657
									if zh then -- 1658
										displayName = repo.title.zh -- 1658
									else -- 1658
										displayName = repo.title.en -- 1658
									end -- 1658
								end -- 1657
								if displayName == nil then -- 1659
									displayName = entryName -- 1659
								end -- 1659
								if allEntries.match(displayName) then -- 1660
									showTool = true -- 1660
									break -- 1660
								end -- 1660
							end -- 1656
							if not showTool then -- 1661
								goto endEntry -- 1661
							end -- 1661
							Columns(1, false) -- 1662
							TextColored(themeColor, "Dora SSR:") -- 1663
							SameLine() -- 1664
							Text(zh and "开发支持" or "Development Support") -- 1665
							Separator() -- 1666
							if #doraTools > 0 then -- 1667
								local opened -- 1668
								if (filterText ~= nil) then -- 1668
									opened = showTool -- 1668
								else -- 1668
									opened = false -- 1668
								end -- 1668
								SetNextItemOpen(toolOpen) -- 1669
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1670
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1671
										Columns(maxColumns, false) -- 1672
										for _index_0 = 1, #doraTools do -- 1673
											local tool = doraTools[_index_0] -- 1673
											local entryName, repo = tool.entryName, tool.repo -- 1674
											local displayName -- 1675
											if repo then -- 1675
												if zh then -- 1676
													displayName = repo.title.zh -- 1676
												else -- 1676
													displayName = repo.title.en -- 1676
												end -- 1676
											end -- 1675
											if displayName == nil then -- 1677
												displayName = entryName -- 1677
											end -- 1677
											if not allEntries.match(displayName) then -- 1678
												goto _continue_0 -- 1678
											end -- 1678
											if Button(displayName, Vec2(-1, 40)) then -- 1679
												enterDemoEntry(tool) -- 1680
											end -- 1679
											NextColumn() -- 1681
											::_continue_0:: -- 1674
										end -- 1673
										Columns(1, false) -- 1682
										opened = true -- 1683
									end) -- 1671
								end) -- 1670
								toolOpen = opened -- 1684
							end -- 1667
						end -- 1654
						::endEntry:: -- 1685
						if not allEntries.anyEntryMatched then -- 1686
							SetNextWindowBgAlpha(0) -- 1687
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1688
							Begin("Entries Not Found", displayWindowFlags, function() -- 1689
								Separator() -- 1690
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1691
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1692
								return Separator() -- 1693
							end) -- 1689
						end -- 1686
						Columns(1, false) -- 1694
						Dummy(Vec2(100, 80)) -- 1695
						return ScrollWhenDraggingOnVoid() -- 1696
					end) -- 1542
				end) -- 1541
			end) -- 1540
		end) -- 1539
	end -- 1538
end) -- 1455
if not (App.platform == "Emscripten") then -- 1701
	local sceneModuleCache = moduleCache -- 1702
	moduleCache = { } -- 1703
	webStatus = oldRequire("Script.Dev.WebServer") -- 1704
	moduleCache = sceneModuleCache -- 1705
end -- 1701
local _anon_func_7 = function(saved) -- 1728
	local _val_0 = saved.kind -- 1728
	return "local" == _val_0 or "discover" == _val_0 -- 1728
end -- 1728
local _anon_func_8 = function(saved) -- 1732
	local _val_0 = saved.activeTab -- 1732
	return "local" == _val_0 or "discover" == _val_0 -- 1732
end -- 1732
startMobileUI = function() -- 1707
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1708
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1709
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1710
	local getMobileFeedResources -- 1711
	do -- 1711
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1711
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1711
	end -- 1711
	local loadCachedCatalog -- 1712
	do -- 1712
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1712
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1712
	end -- 1712
	local getResourceInstallPath, getInstalledCatalogResource -- 1713
	do -- 1713
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1713
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1713
	end -- 1713
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1714
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1715
	local feedOptions = nil -- 1716
	local mobileLaunchErrors = { } -- 1717
	local withMobileLaunchErrors -- 1718
	withMobileLaunchErrors = function(items) -- 1718
		for _index_0 = 1, #items do -- 1719
			local item = items[_index_0] -- 1719
			item.launchError = mobileLaunchErrors[item.id] -- 1720
		end -- 1719
		return items -- 1721
	end -- 1718
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1722
	local loadRememberedMobileFeedState -- 1723
	loadRememberedMobileFeedState = function() -- 1723
		local raw = rememberedMobileFeedData -- 1724
		if not (type(raw) == "string" and raw ~= "") then -- 1725
			return -- 1725
		end -- 1725
		local ok, saved = pcall(json.decode, raw) -- 1726
		if not (ok and type(saved) == "table") then -- 1727
			return -- 1727
		end -- 1727
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1728
			local state = { -- 1729
				activeTab = saved.kind -- 1729
			} -- 1729
			state[saved.kind] = saved -- 1730
			return state -- 1731
		end -- 1728
		local state = { -- 1732
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1732
		} -- 1732
		local _list_0 = { -- 1733
			"local", -- 1733
			"discover" -- 1733
		} -- 1733
		for _index_0 = 1, #_list_0 do -- 1733
			local kind = _list_0[_index_0] -- 1733
			local entry = saved[kind] -- 1734
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1735
				state[kind] = entry -- 1735
			end -- 1735
		end -- 1733
		return state -- 1736
	end -- 1723
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1737
		activeTab = "local" -- 1737
	} -- 1737
	local rememberMobileFeedEntry -- 1738
	rememberMobileFeedEntry = function(entry) -- 1738
		rememberedMobileFeedState.activeTab = entry.kind -- 1739
		rememberedMobileFeedState[entry.kind] = { -- 1741
			id = entry.id, -- 1741
			kind = entry.kind, -- 1742
			workDir = entry.workDir, -- 1743
			fileName = entry.fileName -- 1744
		} -- 1740
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1746
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1747
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1748
			rememberedMobileFeedData -- 1748
		}) -- 1748
	end -- 1738
	local restartMobileFeed -- 1749
	restartMobileFeed = function(entry) -- 1749
		if feedHost then -- 1750
			feedHost:removeFromParent(true) -- 1750
		end -- 1750
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1751
		local initialEntries = { } -- 1752
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1753
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1754
		feedOptions.initialEntries = initialEntries -- 1755
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1756
	end -- 1749
	local startMobilePlay -- 1757
	startMobilePlay = function(entry) -- 1757
		if HttpServer.wsConnectionCount > 0 then -- 1758
			return -- 1758
		end -- 1758
		local originFeed = feedHost -- 1759
		if remixHost then -- 1760
			remixHost:removeFromParent(true) -- 1760
		end -- 1760
		remixHost = nil -- 1761
		mobileLaunchErrors[entry.id] = nil -- 1762
		entry.launchError = nil -- 1763
		local playActive = true -- 1764
		local restoreMobileFeed -- 1765
		restoreMobileFeed = function() -- 1765
			if not playActive then -- 1766
				return -- 1766
			end -- 1766
			playActive = false -- 1767
			allClear() -- 1768
			isInEntry = true -- 1769
			currentEntry = nil -- 1770
			return restartMobileFeed(entry) -- 1771
		end -- 1765
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1773
			onExit = function() -- 1773
				return restoreMobileFeed() -- 1773
			end, -- 1773
			onRuntimeError = function() -- 1774
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1775
				return restoreMobileFeed() -- 1776
			end -- 1774
		})) -- 1772
		return thread(function() -- 1778
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1782
			if not playActive then -- 1783
				return -- 1783
			end -- 1783
			if success then -- 1784
				if originFeed and originFeed.parent then -- 1785
					originFeed.visible = false -- 1785
				end -- 1785
				return -- 1786
			end -- 1784
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1787
			return restoreMobileFeed() -- 1788
		end) -- 1778
	end -- 1757
	feedOptions = { -- 1790
		takeReceivedFile = function() -- 1790
			if allEntries.pendingPackagePath then -- 1791
				local path = allEntries.pendingPackagePath -- 1792
				allEntries.pendingPackagePath = nil -- 1793
				return path -- 1794
			end -- 1791
			return App:takeReceivedFile() -- 1795
		end, -- 1790
		onSwitchMode = function() -- 1796
			if HttpServer.wsConnectionCount == 0 then -- 1796
				pendingUIMode = false -- 1796
			end -- 1796
		end, -- 1796
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1797
		getLocalEntries = function(importedProjectPath) -- 1798
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1799
			feedOptions.dirtyProjectPath = nil -- 1800
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1801
			local cached = loadCachedCatalog() -- 1802
			if cached.success and cached.snapshot then -- 1803
				for _index_0 = 1, #items do -- 1804
					local entry = items[_index_0] -- 1804
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1805
					if resource then -- 1806
						entry.resource = resource -- 1807
						entry.catalogCommit = cached.snapshot.commit -- 1808
					end -- 1806
				end -- 1804
			end -- 1803
			return items -- 1809
		end, -- 1798
		syncDiscover = function(onProgress, onDone, force) -- 1810
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1810
		end, -- 1810
		getDiscoverEntries = function() -- 1811
			local cached = loadCachedCatalog() -- 1812
			if not (cached.success and cached.snapshot) then -- 1813
				return { } -- 1813
			end -- 1813
			local items = { } -- 1814
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1815
			for _index_0 = 1, #_list_0 do -- 1815
				local resource = _list_0[_index_0] -- 1815
				local installed = lifecycle.isMobileResourceReady(resource) -- 1816
				local installPath = getResourceInstallPath(resource.id) -- 1817
				items[#items + 1] = { -- 1819
					id = resource.id, -- 1819
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1820
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1821
					kind = "discover", -- 1822
					bannerFile = resource.bannerPath, -- 1823
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1824
					sourceUrl = resource.versions[1].sources[1].url, -- 1825
					workDir = installed and installPath or nil, -- 1826
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1827
					installed = installed, -- 1828
					resource = resource, -- 1829
					catalogCommit = cached.snapshot.commit, -- 1830
					launchError = mobileLaunchErrors[resource.id] -- 1831
				} -- 1818
			end -- 1815
			return items -- 1833
		end, -- 1811
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1834
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1835
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1836
			end), repairIncomplete, isCanceled) -- 1835
		end, -- 1834
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1838
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1839
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1840
			end), isCanceled) -- 1839
		end, -- 1838
		createProject = function(name, language) -- 1842
			local result = projectCreate.createMobileProject(name, language) -- 1843
			if not result.success then -- 1844
				return result -- 1844
			end -- 1844
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1845
			for _index_0 = 1, #_list_0 do -- 1845
				local entry = _list_0[_index_0] -- 1845
				if entry.workDir == result.workDir then -- 1846
					return { -- 1847
						success = true, -- 1847
						entry = entry -- 1847
					} -- 1847
				end -- 1846
			end -- 1845
			return { -- 1848
				success = false, -- 1848
				error = "created-project-not-found" -- 1848
			} -- 1848
		end, -- 1842
		onPlay = function(entry) -- 1849
			return startMobilePlay(entry) -- 1849
		end, -- 1849
		onRemix = function(entry) -- 1850
			if HttpServer.wsConnectionCount > 0 then -- 1851
				return -- 1851
			end -- 1851
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1852
			local originFeed = feedHost -- 1853
			feedHost.visible = false -- 1854
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1856
				entry = entry, -- 1856
				onProjectChanged = function(current) -- 1857
					feedOptions.dirtyProjectPath = current.workDir -- 1857
				end, -- 1857
				onBack = function() -- 1858
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1859
						originFeed:emit("RestoreFeedEntry", entry) -- 1860
						originFeed.visible = true -- 1861
					end -- 1859
				end, -- 1858
				onPlay = function(current) -- 1862
					return startMobilePlay(current) -- 1862
				end -- 1862
			})) -- 1855
		end -- 1850
	} -- 1789
	return restartMobileFeed() -- 1865
end -- 1707
if mobileMode then -- 1867
	applyUIMode(true) -- 1867
end -- 1867
return _module_0 -- 1
