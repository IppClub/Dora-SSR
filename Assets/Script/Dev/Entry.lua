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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 60
config:load() -- 95
if not (config.writablePath ~= nil) then -- 97
	config.writablePath = Content.appPath -- 98
end -- 97
if not (config.webIDEConnected ~= nil) then -- 100
	config.webIDEConnected = false -- 101
end -- 100
if (config.fpsLimited ~= nil) then -- 103
	App.fpsLimited = config.fpsLimited -- 104
else -- 106
	config.fpsLimited = App.fpsLimited -- 106
end -- 103
if (config.targetFPS ~= nil) then -- 108
	App.targetFPS = math.floor(config.targetFPS) -- 109
else -- 111
	config.targetFPS = App.targetFPS -- 111
end -- 108
if (config.vsync ~= nil) then -- 113
	View.vsync = config.vsync -- 114
else -- 116
	config.vsync = View.vsync -- 116
end -- 113
if (config.fixedFPS ~= nil) then -- 118
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 119
else -- 121
	config.fixedFPS = Director.scheduler.fixedFPS -- 121
end -- 118
if not (config.showPreview ~= nil) then -- 123
	config.showPreview = true -- 124
end -- 123
if not (config.mobileFeed ~= nil) then -- 126
	local _val_0 = App.platform -- 127
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 127
end -- 126
if not (config.webIDETourCompleted ~= nil) then -- 129
	config.webIDETourCompleted = false -- 130
end -- 129
if not (config.authRequired ~= nil) then -- 132
	local _val_0 = App.platform -- 133
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 133
end -- 132
HttpServer.authRequired = config.authRequired -- 134
local showEntry = true -- 136
isDesktop = false -- 138
if (function() -- 139
	local _val_0 = App.platform -- 139
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 139
end)() then -- 139
	isDesktop = true -- 140
	if config.fullScreen then -- 141
		App.fullScreen = true -- 142
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 143
		local size = Size(config.winWidth, config.winHeight) -- 144
		if App.winSize ~= size then -- 145
			App.winSize = size -- 146
		end -- 145
		local winX, winY -- 147
		do -- 147
			local _obj_0 = App.winPosition -- 147
			winX, winY = _obj_0.x, _obj_0.y -- 147
		end -- 147
		if (config.winX ~= nil) then -- 148
			winX = config.winX -- 149
		else -- 151
			config.winX = -1 -- 151
		end -- 148
		if (config.winY ~= nil) then -- 152
			winY = config.winY -- 153
		else -- 155
			config.winY = -1 -- 155
		end -- 152
		App.winPosition = Vec2(winX, winY) -- 156
	end -- 141
	if (config.alwaysOnTop ~= nil) then -- 157
		App.alwaysOnTop = config.alwaysOnTop -- 158
	else -- 160
		config.alwaysOnTop = false -- 160
	end -- 157
	if (config.virtualGamepadEnabled ~= nil) then -- 161
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 162
	else -- 164
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 164
	end -- 161
end -- 139
if (config.themeColor ~= nil) then -- 166
	App.themeColor = Color(config.themeColor) -- 167
else -- 169
	config.themeColor = App.themeColor:toARGB() -- 169
end -- 166
if not (config.locale ~= nil) then -- 171
	config.locale = App.locale -- 172
end -- 171
local showStats = false -- 174
if (config.showStats ~= nil) then -- 175
	showStats = config.showStats -- 176
else -- 178
	config.showStats = showStats -- 178
end -- 175
local showConsole = false -- 180
if (config.showConsole ~= nil) then -- 181
	showConsole = config.showConsole -- 182
else -- 184
	config.showConsole = showConsole -- 184
end -- 181
local showFooter = true -- 186
if (config.showFooter ~= nil) then -- 187
	showFooter = config.showFooter -- 188
else -- 190
	config.showFooter = showFooter -- 190
end -- 187
local setFooterVisible -- 192
setFooterVisible = function(visible) -- 192
	if visible == nil then -- 192
		visible = true -- 192
	end -- 192
	showFooter = visible -- 193
	config.showFooter = showFooter -- 194
end -- 192
_module_0["setFooterVisible"] = setFooterVisible -- 192
local filterBuf = Buffer(20) -- 196
if (config.filter ~= nil) then -- 197
	filterBuf.text = config.filter -- 198
else -- 200
	config.filter = "" -- 200
end -- 197
local engineDev = false -- 202
if (config.engineDev ~= nil) then -- 203
	engineDev = config.engineDev -- 204
else -- 206
	config.engineDev = engineDev -- 206
end -- 203
if (config.webProfiler ~= nil) then -- 208
	Director.profilerSending = config.webProfiler -- 209
else -- 211
	config.webProfiler = true -- 211
	Director.profilerSending = true -- 212
end -- 208
if not (config.drawerWidth ~= nil) then -- 214
	config.drawerWidth = 200 -- 215
end -- 214
_module_0.getConfig = function() -- 217
	return config -- 217
end -- 217
_module_0.getEngineDev = function() -- 218
	if not App.debugging then -- 219
		return false -- 219
	end -- 219
	return config.engineDev -- 220
end -- 218
local _anon_func_0 = function() -- 225
	local _val_0 = App.platform -- 225
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 225
end -- 225
_module_0.connectWebIDE = function() -- 222
	if not config.webIDEConnected then -- 223
		config.webIDEConnected = true -- 224
		if _anon_func_0() then -- 225
			local ratio = App.winSize.width / App.visualSize.width -- 226
			App.winSize = Size(640 * ratio, 480 * ratio) -- 227
		end -- 225
	end -- 223
end -- 222
local updateCheck -- 229
updateCheck = function() -- 229
	return thread(function() -- 229
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 230
		if res then -- 230
			local data = json.decode(res) -- 231
			if data then -- 231
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 232
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 233
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 234
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 235
				if na < a then -- 236
					goto not_new_version -- 237
				end -- 236
				if na == a then -- 238
					if nb < b then -- 239
						goto not_new_version -- 240
					end -- 239
					if nb == b then -- 241
						if nc < c then -- 242
							goto not_new_version -- 243
						end -- 242
						if nc == c then -- 244
							goto not_new_version -- 245
						end -- 244
					end -- 241
				end -- 238
				config.updateNotification = true -- 246
				::not_new_version:: -- 247
				config.lastUpdateCheck = os.time() -- 248
			end -- 231
		end -- 230
	end) -- 229
end -- 229
if (config.lastUpdateCheck ~= nil) then -- 250
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 251
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 252
		updateCheck() -- 253
	end -- 252
else -- 255
	updateCheck() -- 255
end -- 250
local Set, Struct, LintYueGlobals, GSplit -- 257
do -- 257
	local _obj_0 = require("Utils") -- 257
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 257
end -- 257
local yueext = yue.options.extension -- 258
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 260
local building = false -- 262
local getAllFiles -- 264
getAllFiles = function(path, exts, recursive) -- 264
	if recursive == nil then -- 264
		recursive = true -- 264
	end -- 264
	local filters = Set(exts) -- 265
	local files -- 266
	if recursive then -- 266
		files = Content:getAllFiles(path) -- 267
	else -- 269
		files = Content:getFiles(path) -- 269
	end -- 266
	local _accum_0 = { } -- 270
	local _len_0 = 1 -- 270
	for _index_0 = 1, #files do -- 270
		local file = files[_index_0] -- 270
		if not filters[Path:getExt(file)] then -- 271
			goto _continue_0 -- 271
		end -- 271
		_accum_0[_len_0] = file -- 272
		_len_0 = _len_0 + 1 -- 271
		::_continue_0:: -- 271
	end -- 270
	return _accum_0 -- 270
end -- 264
_module_0["getAllFiles"] = getAllFiles -- 264
local getFileEntries -- 274
getFileEntries = function(path, recursive, excludeFiles) -- 274
	if recursive == nil then -- 274
		recursive = true -- 274
	end -- 274
	if excludeFiles == nil then -- 274
		excludeFiles = nil -- 274
	end -- 274
	local entries = { } -- 275
	local excludes -- 276
	if excludeFiles then -- 276
		excludes = Set(excludeFiles) -- 277
	end -- 276
	local _list_0 = getAllFiles(path, { -- 278
		"lua", -- 278
		"xml", -- 278
		yueext, -- 278
		"tl" -- 278
	}, recursive) -- 278
	for _index_0 = 1, #_list_0 do -- 278
		local file = _list_0[_index_0] -- 278
		local entryName = Path:getName(file) -- 279
		if excludes and excludes[entryName] then -- 280
			goto _continue_0 -- 281
		end -- 280
		local fileName = Path:replaceExt(file, "") -- 282
		fileName = Path(path, fileName) -- 283
		local entryAdded -- 284
		for _index_1 = 1, #entries do -- 284
			local _des_0 = entries[_index_1] -- 284
			local ename, efile = _des_0.entryName, _des_0.fileName -- 284
			if entryName == ename and efile == fileName then -- 285
				entryAdded = true -- 285
				break -- 285
			end -- 285
		end -- 284
		if entryAdded then -- 286
			goto _continue_0 -- 286
		end -- 286
		local entry = { -- 287
			entryName = entryName, -- 287
			fileName = fileName -- 287
		} -- 287
		entries[#entries + 1] = entry -- 288
		::_continue_0:: -- 279
	end -- 278
	table.sort(entries, function(a, b) -- 289
		return a.entryName < b.entryName -- 289
	end) -- 289
	return entries -- 290
end -- 274
local allEntries = { -- 292
	dirty = { }, -- 292
	hasDirty = false, -- 292
	runId = 0 -- 292
} -- 292
allEntries.scanDir = function(path, dir, noPreview) -- 294
	if noPreview == nil then -- 294
		noPreview = false -- 294
	end -- 294
	local entries = { } -- 295
	if not dir:match("^%.") then -- 296
		local _list_0 = getAllFiles(Path(path, dir), { -- 297
			"lua", -- 297
			"xml", -- 297
			yueext, -- 297
			"tl", -- 297
			"wasm" -- 297
		}) -- 297
		for _index_0 = 1, #_list_0 do -- 297
			local file = _list_0[_index_0] -- 297
			if "init" == Path:getName(file):lower() then -- 298
				local fileName = Path:replaceExt(file, "") -- 299
				fileName = Path(path, dir, fileName) -- 300
				local projectPath = Path:getPath(fileName) -- 301
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 302
				local repo = nil -- 303
				if Content:exist(repoFile) then -- 304
					local str = Content:load(repoFile) -- 305
					if str then -- 305
						repo = json.decode(str) -- 306
					end -- 305
				end -- 304
				local entryName = Path:getName(projectPath) -- 307
				local entryAdded -- 308
				for _index_1 = 1, #entries do -- 308
					local _des_0 = entries[_index_1] -- 308
					local ename, efile = _des_0.entryName, _des_0.fileName -- 308
					if entryName == ename and efile == fileName then -- 309
						entryAdded = true -- 309
						break -- 309
					end -- 309
				end -- 308
				if entryAdded then -- 310
					goto _continue_0 -- 310
				end -- 310
				local examples = { } -- 311
				local tests = { } -- 312
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 313
				if Content:exist(examplePath) then -- 314
					local _list_1 = getFileEntries(examplePath) -- 315
					for _index_1 = 1, #_list_1 do -- 315
						local _des_0 = _list_1[_index_1] -- 315
						local name, ePath = _des_0.entryName, _des_0.fileName -- 315
						local entry = { -- 317
							entryName = name, -- 317
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 318
							workDir = projectPath -- 319
						} -- 316
						examples[#examples + 1] = entry -- 321
					end -- 315
				end -- 314
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 322
				if Content:exist(testPath) then -- 323
					local _list_1 = getFileEntries(testPath) -- 324
					for _index_1 = 1, #_list_1 do -- 324
						local _des_0 = _list_1[_index_1] -- 324
						local name, tPath = _des_0.entryName, _des_0.fileName -- 324
						local entry = { -- 326
							entryName = name, -- 326
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 327
							workDir = projectPath -- 328
						} -- 325
						tests[#tests + 1] = entry -- 330
					end -- 324
				end -- 323
				local entry = { -- 331
					entryName = entryName, -- 331
					fileName = fileName, -- 331
					projectPath = projectPath, -- 331
					examples = examples, -- 331
					tests = tests, -- 331
					repo = repo -- 331
				} -- 331
				local bannerFile -- 332
				do -- 332
					local _val_0 -- 332
					repeat -- 332
						if noPreview then -- 333
							_val_0 = nil -- 333
							break -- 333
						end -- 333
						if not config.showPreview then -- 334
							_val_0 = nil -- 334
							break -- 334
						end -- 334
						local f = Path(projectPath, ".dora", "banner.jpg") -- 335
						if Content:exist(f) then -- 336
							_val_0 = f -- 336
							break -- 336
						end -- 336
						f = Path(projectPath, ".dora", "banner.png") -- 337
						if Content:exist(f) then -- 338
							_val_0 = f -- 338
							break -- 338
						end -- 338
						f = Path(projectPath, "Image", "banner.jpg") -- 339
						if Content:exist(f) then -- 340
							_val_0 = f -- 340
							break -- 340
						end -- 340
						f = Path(projectPath, "Image", "banner.png") -- 341
						if Content:exist(f) then -- 342
							_val_0 = f -- 342
							break -- 342
						end -- 342
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 343
						if Content:exist(f) then -- 344
							_val_0 = f -- 344
							break -- 344
						end -- 344
					until true -- 332
					bannerFile = _val_0 -- 332
				end -- 332
				if bannerFile then -- 346
					entry.bannerFile = bannerFile -- 349
					thread(function() -- 350
						if Cache:loadAsync(bannerFile) then -- 351
							local bannerTex = Texture2D(bannerFile) -- 352
							if bannerTex then -- 352
								entry.bannerTex = bannerTex -- 353
							end -- 352
						end -- 351
					end) -- 350
				end -- 346
				entries[#entries + 1] = entry -- 354
			end -- 298
			::_continue_0:: -- 298
		end -- 297
	end -- 296
	return entries -- 355
end -- 294
local getProjectEntries -- 357
getProjectEntries = function(path, noPreview) -- 357
	if noPreview == nil then -- 357
		noPreview = false -- 357
	end -- 357
	local entries = { } -- 358
	local _list_0 = Content:getDirs(path) -- 359
	for _index_0 = 1, #_list_0 do -- 359
		local dir = _list_0[_index_0] -- 359
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 360
		for _index_1 = 1, #_list_1 do -- 360
			local entry = _list_1[_index_1] -- 360
			entries[#entries + 1] = entry -- 361
		end -- 360
	end -- 359
	table.sort(entries, function(a, b) -- 362
		return a.entryName < b.entryName -- 362
	end) -- 362
	return entries -- 363
end -- 357
_module_0["getProjectEntries"] = getProjectEntries -- 357
local gamesInDev -- 365
local doraTools -- 366
local isToolEntry -- 368
isToolEntry = function(entry) -- 368
	do -- 369
		local _type_0 = type(entry) -- 369
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 369
		if _tab_0 then -- 369
			local categories -- 369
			do -- 369
				local _obj_0 = entry.repo -- 369
				local _type_1 = type(_obj_0) -- 369
				if "table" == _type_1 or "userdata" == _type_1 then -- 369
					categories = _obj_0.categories -- 369
				end -- 369
			end -- 369
			if categories ~= nil then -- 369
				for _index_0 = 1, #categories do -- 370
					local category = categories[_index_0] -- 370
					if "string" == type(category) and category:lower() == "tool" then -- 371
						return true -- 372
					end -- 371
				end -- 370
			end -- 369
		end -- 369
	end -- 369
	return false -- 368
end -- 368
local getEntryTitle -- 374
getEntryTitle = function(entry) -- 374
	local title -- 375
	do -- 375
		local repo = entry.repo -- 375
		if repo then -- 375
			if repo.title and "table" == type(repo.title) then -- 376
				if useChinese then -- 377
					title = repo.title.zh -- 377
				else -- 377
					title = repo.title.en -- 377
				end -- 377
			end -- 376
		end -- 375
	end -- 375
	if title ~= nil then -- 378
		return title -- 378
	else -- 378
		return entry.entryName -- 378
	end -- 378
end -- 374
allEntries.rebuildEntries = function() -- 380
	gamesInDev = { } -- 381
	do -- 382
		local _accum_0 = { } -- 382
		local _len_0 = 1 -- 382
		local _list_0 = allEntries.builtinTools -- 382
		for _index_0 = 1, #_list_0 do -- 382
			local tool = _list_0[_index_0] -- 382
			_accum_0[_len_0] = tool -- 382
			_len_0 = _len_0 + 1 -- 382
		end -- 382
		doraTools = _accum_0 -- 382
	end -- 382
	local _list_0 = allEntries.projectEntries -- 383
	for _index_0 = 1, #_list_0 do -- 383
		local entry = _list_0[_index_0] -- 383
		if isToolEntry(entry) then -- 384
			entry.kind = "tool" -- 385
			doraTools[#doraTools + 1] = entry -- 386
		else -- 388
			entry.kind = "game" -- 388
			gamesInDev[#gamesInDev + 1] = entry -- 389
		end -- 384
	end -- 383
	for i = #allEntries, 1, -1 do -- 390
		allEntries[i] = nil -- 391
	end -- 390
	for _index_0 = 1, #gamesInDev do -- 392
		local game = gamesInDev[_index_0] -- 392
		allEntries[#allEntries + 1] = game -- 393
		local examples, tests = game.examples, game.tests -- 394
		for _index_1 = 1, #examples do -- 395
			local example = examples[_index_1] -- 395
			allEntries[#allEntries + 1] = example -- 396
		end -- 395
		for _index_1 = 1, #tests do -- 397
			local test = tests[_index_1] -- 397
			allEntries[#allEntries + 1] = test -- 398
		end -- 397
	end -- 392
end -- 380
local updateEntries -- 400
updateEntries = function() -- 400
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 401
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 402
	local _list_0 = allEntries.builtinTools -- 403
	for _index_0 = 1, #_list_0 do -- 403
		local tool = _list_0[_index_0] -- 403
		tool.kind = "tool" -- 404
		tool.builtin = true -- 405
	end -- 403
	return allEntries.rebuildEntries() -- 406
end -- 400
allEntries.refreshDirtyProjects = function() -- 408
	if not allEntries.hasDirty then -- 409
		return -- 409
	end -- 409
	local dirty = allEntries.dirty -- 410
	allEntries.dirty = { } -- 411
	allEntries.hasDirty = false -- 412
	for projectPath in pairs(dirty) do -- 413
		do -- 414
			local _accum_0 = { } -- 414
			local _len_0 = 1 -- 414
			local _list_0 = allEntries.projectEntries -- 414
			for _index_0 = 1, #_list_0 do -- 414
				local entry = _list_0[_index_0] -- 414
				if entry.projectPath ~= projectPath then -- 414
					_accum_0[_len_0] = entry -- 414
					_len_0 = _len_0 + 1 -- 414
				end -- 414
			end -- 414
			allEntries.projectEntries = _accum_0 -- 414
		end -- 414
		local parentPath = Path:getPath(projectPath) -- 415
		local dir = Path:getFilename(projectPath) -- 416
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 417
		for _index_0 = 1, #_list_0 do -- 417
			local entry = _list_0[_index_0] -- 417
			if entry.projectPath == projectPath then -- 418
				do -- 419
					local _obj_0 = allEntries.projectEntries -- 419
					_obj_0[#_obj_0 + 1] = entry -- 419
				end -- 419
				break -- 420
			end -- 418
		end -- 417
	end -- 413
	table.sort(allEntries.projectEntries, function(a, b) -- 421
		return a.entryName < b.entryName -- 421
	end) -- 421
	return allEntries.rebuildEntries() -- 422
end -- 408
updateEntries() -- 424
local getLaunchEntries -- 426
getLaunchEntries = function(refresh) -- 426
	if refresh == nil then -- 426
		refresh = false -- 426
	end -- 426
	if refresh then -- 427
		updateEntries() -- 427
	end -- 427
	local toInfo -- 428
	toInfo = function(entry, kind) -- 428
		local file = entry.fileName -- 429
		local asProj = not entry.builtin -- 430
		return { -- 432
			name = getEntryTitle(entry), -- 432
			file = file, -- 433
			kind = kind, -- 434
			asProj = asProj -- 435
		} -- 431
	end -- 428
	local games -- 437
	do -- 437
		local _accum_0 = { } -- 437
		local _len_0 = 1 -- 437
		for _index_0 = 1, #gamesInDev do -- 437
			local game = gamesInDev[_index_0] -- 437
			_accum_0[_len_0] = toInfo(game, "game") -- 437
			_len_0 = _len_0 + 1 -- 437
		end -- 437
		games = _accum_0 -- 437
	end -- 437
	local tools -- 438
	do -- 438
		local _accum_0 = { } -- 438
		local _len_0 = 1 -- 438
		for _index_0 = 1, #doraTools do -- 438
			local tool = doraTools[_index_0] -- 438
			_accum_0[_len_0] = toInfo(tool, "tool") -- 438
			_len_0 = _len_0 + 1 -- 438
		end -- 438
		tools = _accum_0 -- 438
	end -- 438
	return { -- 439
		games = games, -- 439
		tools = tools -- 439
	} -- 439
end -- 426
_module_0["getLaunchEntries"] = getLaunchEntries -- 426
local _anon_func_1 = function(entry, useChinese) -- 456
	local _obj_0 = entry.repo -- 456
	if _obj_0 ~= nil then -- 456
		local _obj_1 = _obj_0.description -- 456
		if _obj_1 ~= nil then -- 456
			return _obj_1[useChinese and "zh" or "en"] -- 456
		end -- 456
		return nil -- 456
	end -- 456
	return nil -- 456
end -- 456
local getMobileFeedEntries -- 441
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 441
	if refresh == nil then -- 441
		refresh = false -- 441
	end -- 441
	if dirtyProjectPath == nil then -- 441
		dirtyProjectPath = nil -- 441
	end -- 441
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 442
		allEntries.dirty[dirtyProjectPath] = true -- 443
		allEntries.hasDirty = true -- 444
	end -- 442
	if refresh then -- 445
		allEntries.dirty = { } -- 446
		allEntries.hasDirty = false -- 447
		updateEntries() -- 448
	else -- 450
		allEntries.refreshDirtyProjects() -- 450
	end -- 445
	local items = { } -- 451
	for _index_0 = 1, #gamesInDev do -- 452
		local entry = gamesInDev[_index_0] -- 452
		items[#items + 1] = { -- 454
			id = entry.entryName, -- 454
			title = getEntryTitle(entry), -- 455
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 456
			fileName = entry.fileName, -- 457
			workDir = Path:getPath(entry.fileName), -- 458
			bannerFile = entry.bannerFile, -- 459
			kind = "local" -- 460
		} -- 453
	end -- 452
	return items -- 462
end -- 441
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 441
local doCompile -- 464
doCompile = function(minify) -- 464
	if building then -- 465
		return -- 465
	end -- 465
	building = true -- 466
	local startTime = App.runningTime -- 467
	local luaFiles = { } -- 468
	local yueFiles = { } -- 469
	local xmlFiles = { } -- 470
	local tlFiles = { } -- 471
	local writablePath = Content.writablePath -- 472
	local buildPaths = { -- 474
		{ -- 475
			Content.assetPath, -- 475
			Path(writablePath, ".build"), -- 476
			"" -- 477
		} -- 474
	} -- 473
	for _index_0 = 1, #gamesInDev do -- 480
		local _des_0 = gamesInDev[_index_0] -- 480
		local fileName = _des_0.fileName -- 480
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 481
		buildPaths[#buildPaths + 1] = { -- 483
			Path(writablePath, gamePath), -- 483
			Path(writablePath, ".build", gamePath), -- 484
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 485
			gamePath -- 486
		} -- 482
	end -- 480
	for _index_0 = 1, #buildPaths do -- 487
		local _des_0 = buildPaths[_index_0] -- 487
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 487
		if not Content:exist(inputPath) then -- 488
			goto _continue_0 -- 488
		end -- 488
		local _list_0 = getAllFiles(inputPath, { -- 490
			"lua" -- 490
		}) -- 490
		for _index_1 = 1, #_list_0 do -- 490
			local file = _list_0[_index_1] -- 490
			luaFiles[#luaFiles + 1] = { -- 492
				file, -- 492
				Path(inputPath, file), -- 493
				Path(outputPath, file), -- 494
				gamePath -- 495
			} -- 491
		end -- 490
		local _list_1 = getAllFiles(inputPath, { -- 497
			yueext -- 497
		}) -- 497
		for _index_1 = 1, #_list_1 do -- 497
			local file = _list_1[_index_1] -- 497
			yueFiles[#yueFiles + 1] = { -- 499
				file, -- 499
				Path(inputPath, file), -- 500
				Path(outputPath, Path:replaceExt(file, "lua")), -- 501
				searchPath, -- 502
				gamePath -- 503
			} -- 498
		end -- 497
		local _list_2 = getAllFiles(inputPath, { -- 505
			"xml" -- 505
		}) -- 505
		for _index_1 = 1, #_list_2 do -- 505
			local file = _list_2[_index_1] -- 505
			xmlFiles[#xmlFiles + 1] = { -- 507
				file, -- 507
				Path(inputPath, file), -- 508
				Path(outputPath, Path:replaceExt(file, "lua")), -- 509
				gamePath -- 510
			} -- 506
		end -- 505
		local _list_3 = getAllFiles(inputPath, { -- 512
			"tl" -- 512
		}) -- 512
		for _index_1 = 1, #_list_3 do -- 512
			local file = _list_3[_index_1] -- 512
			if not file:match(".*%.d%.tl$") then -- 513
				tlFiles[#tlFiles + 1] = { -- 515
					file, -- 515
					Path(inputPath, file), -- 516
					Path(outputPath, Path:replaceExt(file, "lua")), -- 517
					searchPath, -- 518
					gamePath -- 519
				} -- 514
			end -- 513
		end -- 512
		::_continue_0:: -- 488
	end -- 487
	local paths -- 521
	do -- 521
		local _tbl_0 = { } -- 521
		local _list_0 = { -- 522
			luaFiles, -- 522
			yueFiles, -- 522
			xmlFiles, -- 522
			tlFiles -- 522
		} -- 522
		for _index_0 = 1, #_list_0 do -- 522
			local files = _list_0[_index_0] -- 522
			for _index_1 = 1, #files do -- 523
				local file = files[_index_1] -- 523
				_tbl_0[Path:getPath(file[3])] = true -- 521
			end -- 521
		end -- 521
		paths = _tbl_0 -- 521
	end -- 521
	for path in pairs(paths) do -- 525
		Content:mkdir(path) -- 525
	end -- 525
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 527
	local fileCount = 0 -- 528
	local errors = { } -- 529
	for _index_0 = 1, #yueFiles do -- 530
		local _des_0 = yueFiles[_index_0] -- 530
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 530
		local filename -- 531
		if gamePath then -- 531
			filename = Path(gamePath, file) -- 531
		else -- 531
			filename = file -- 531
		end -- 531
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 532
			if not codes then -- 533
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 534
				return -- 535
			end -- 533
			local success, result = LintYueGlobals(codes, globals) -- 536
			local yueCodes -- 537
			if not success then -- 538
				yueCodes = Content:load(input) -- 539
				if yueCodes then -- 539
					local CheckTIC80Code -- 540
					do -- 540
						local _obj_0 = require("Utils") -- 540
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 540
					end -- 540
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 541
					if isTIC80 then -- 542
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 543
					end -- 542
				end -- 539
			end -- 538
			if success then -- 544
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 545
			else -- 547
				if yueCodes then -- 547
					local globalErrors = { } -- 548
					for _index_1 = 1, #result do -- 549
						local _des_1 = result[_index_1] -- 549
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 549
						local countLine = 1 -- 550
						local code = "" -- 551
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 552
							if countLine == line then -- 553
								code = lineCode -- 554
								break -- 555
							end -- 553
							countLine = countLine + 1 -- 556
						end -- 552
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 557
					end -- 549
					if #globalErrors > 0 then -- 558
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 558
					end -- 558
				else -- 560
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 560
				end -- 547
				if #errors == 0 then -- 561
					return codes -- 561
				end -- 561
			end -- 544
		end, function(success) -- 532
			if success then -- 562
				print("Yue compiled: " .. tostring(filename)) -- 562
			end -- 562
			fileCount = fileCount + 1 -- 563
		end) -- 532
	end -- 530
	thread(function() -- 565
		for _index_0 = 1, #xmlFiles do -- 566
			local _des_0 = xmlFiles[_index_0] -- 566
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 566
			local filename -- 567
			if gamePath then -- 567
				filename = Path(gamePath, file) -- 567
			else -- 567
				filename = file -- 567
			end -- 567
			local sourceCodes = Content:loadAsync(input) -- 568
			local codes, err = xml.tolua(sourceCodes) -- 569
			if not codes then -- 570
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 571
			else -- 573
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 573
				print("Xml compiled: " .. tostring(filename)) -- 574
			end -- 570
			fileCount = fileCount + 1 -- 575
		end -- 566
	end) -- 565
	thread(function() -- 577
		for _index_0 = 1, #tlFiles do -- 578
			local _des_0 = tlFiles[_index_0] -- 578
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 578
			local filename -- 579
			if gamePath then -- 579
				filename = Path(gamePath, file) -- 579
			else -- 579
				filename = file -- 579
			end -- 579
			local sourceCodes = Content:loadAsync(input) -- 580
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 581
			if not codes then -- 582
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 583
			else -- 585
				Content:saveAsync(output, codes) -- 585
				print("Teal compiled: " .. tostring(filename)) -- 586
			end -- 582
			fileCount = fileCount + 1 -- 587
		end -- 578
	end) -- 577
	return thread(function() -- 589
		wait(function() -- 590
			return fileCount == totalFiles -- 590
		end) -- 590
		if minify then -- 591
			local _list_0 = { -- 592
				yueFiles, -- 592
				xmlFiles, -- 592
				tlFiles -- 592
			} -- 592
			for _index_0 = 1, #_list_0 do -- 592
				local files = _list_0[_index_0] -- 592
				for _index_1 = 1, #files do -- 592
					local file = files[_index_1] -- 592
					local output = Path:replaceExt(file[3], "lua") -- 593
					luaFiles[#luaFiles + 1] = { -- 595
						Path:replaceExt(file[1], "lua"), -- 595
						output, -- 596
						output -- 597
					} -- 594
				end -- 592
			end -- 592
			local FormatMini -- 599
			do -- 599
				local _obj_0 = require("luaminify") -- 599
				FormatMini = _obj_0.FormatMini -- 599
			end -- 599
			for _index_0 = 1, #luaFiles do -- 600
				local _des_0 = luaFiles[_index_0] -- 600
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 600
				if Content:exist(input) then -- 601
					local sourceCodes = Content:loadAsync(input) -- 602
					local res, err = FormatMini(sourceCodes) -- 603
					if res then -- 604
						Content:saveAsync(output, res) -- 605
						print("Minify: " .. tostring(file)) -- 606
					else -- 608
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 608
					end -- 604
				else -- 610
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 610
				end -- 601
			end -- 600
			package.loaded["luaminify.FormatMini"] = nil -- 611
			package.loaded["luaminify.ParseLua"] = nil -- 612
			package.loaded["luaminify.Scope"] = nil -- 613
			package.loaded["luaminify.Util"] = nil -- 614
		end -- 591
		local errorMessage = table.concat(errors, "\n") -- 615
		if errorMessage ~= "" then -- 616
			print(errorMessage) -- 616
		end -- 616
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 617
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 618
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 619
		Content:clearPathCache() -- 620
		teal.clear() -- 621
		yue.clear() -- 622
		building = false -- 623
	end) -- 589
end -- 464
local doClean -- 625
doClean = function() -- 625
	if building then -- 626
		return -- 626
	end -- 626
	local writablePath = Content.writablePath -- 627
	local targetDir = Path(writablePath, ".build") -- 628
	Content:clearPathCache() -- 629
	if Content:remove(targetDir) then -- 630
		return print("Cleaned: " .. tostring(targetDir)) -- 631
	end -- 630
end -- 625
local screenScale = 2.0 -- 633
local scaleContent = false -- 634
local isInEntry = true -- 635
local currentEntry = nil -- 636
local footerWindow = nil -- 638
local entryWindow = nil -- 639
local testingThread = nil -- 640
local mobileMode = config.mobileFeed -- 641
local pendingUIMode = nil -- 642
local feedHost = nil -- 643
local remixHost = nil -- 644
local startMobileUI = nil -- 645
local webControlled = false -- 646
local mobileHosts = { } -- 647
local suspendedMobileHosts = { } -- 648
local trackMobileHost -- 650
trackMobileHost = function(host) -- 650
	do -- 651
		local _accum_0 = { } -- 651
		local _len_0 = 1 -- 651
		for _index_0 = 1, #mobileHosts do -- 651
			local item = mobileHosts[_index_0] -- 651
			if item.parent then -- 651
				_accum_0[_len_0] = item -- 651
				_len_0 = _len_0 + 1 -- 651
			end -- 651
		end -- 651
		mobileHosts = _accum_0 -- 651
	end -- 651
	mobileHosts[#mobileHosts + 1] = host -- 652
	return host -- 653
end -- 650
local clearMobileUI -- 655
clearMobileUI = function() -- 655
	for _index_0 = 1, #mobileHosts do -- 656
		local host = mobileHosts[_index_0] -- 656
		if host.parent then -- 657
			host:removeFromParent(true) -- 657
		end -- 657
	end -- 656
	mobileHosts = { } -- 658
	suspendedMobileHosts = { } -- 659
	feedHost = nil -- 660
	remixHost = nil -- 661
end -- 655
local syncWebIDEControl -- 663
syncWebIDEControl = function() -- 663
	local connected = HttpServer.wsConnectionCount > 0 -- 664
	if connected then -- 665
		pendingUIMode = nil -- 666
		for _index_0 = 1, #mobileHosts do -- 667
			local host = mobileHosts[_index_0] -- 667
			if not host.parent then -- 668
				goto _continue_0 -- 668
			end -- 668
			if not (suspendedMobileHosts[host] ~= nil) then -- 669
				suspendedMobileHosts[host] = host.visible -- 670
				host:emit("SuspendLocalUI") -- 671
			end -- 669
			host.visible = false -- 672
			::_continue_0:: -- 668
		end -- 667
	elseif webControlled then -- 673
		for host, visible in pairs(suspendedMobileHosts) do -- 674
			if host.parent then -- 675
				host.visible = visible -- 676
				host:emit("ResumeLocalUI") -- 677
			end -- 675
		end -- 674
		suspendedMobileHosts = { } -- 678
	end -- 665
	webControlled = connected -- 679
	return connected -- 680
end -- 663
local getUIMode -- 682
getUIMode = function() -- 682
	return mobileMode and "mobile" or "traditional" -- 682
end -- 682
_module_0["getUIMode"] = getUIMode -- 682
local setUIMode -- 683
setUIMode = function(mode) -- 683
	if not (("mobile" == mode or "traditional" == mode)) then -- 684
		return false -- 684
	end -- 684
	if HttpServer.wsConnectionCount > 0 then -- 685
		return false -- 685
	end -- 685
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 686
		return false -- 686
	end -- 686
	local wantsMobile = mode == "mobile" -- 687
	if wantsMobile == mobileMode then -- 688
		return true -- 688
	end -- 688
	if mobileMode then -- 689
		if not (feedHost and feedHost.visible) then -- 690
			return false -- 690
		end -- 690
		feedHost:emit("SwitchUIMode") -- 692
		return pendingUIMode == false -- 693
	end -- 689
	pendingUIMode = true -- 694
	return true -- 695
end -- 683
_module_0["setUIMode"] = setUIMode -- 683
local applyUIMode -- 697
applyUIMode = function(enabled) -- 697
	if HttpServer.wsConnectionCount > 0 then -- 699
		return false -- 699
	end -- 699
	if enabled then -- 700
		local ok, err = pcall(startMobileUI) -- 701
		if not ok then -- 702
			if feedHost then -- 703
				feedHost:removeFromParent(true) -- 703
			end -- 703
			feedHost = nil -- 704
			mobileMode = false -- 705
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 706
			return false -- 707
		end -- 702
	else -- 709
		clearMobileUI() -- 709
		updateEntries() -- 710
	end -- 700
	mobileMode = enabled -- 711
	config.mobileFeed = enabled -- 712
	return true -- 713
end -- 697
local setupEventHandlers = nil -- 715
local allClear -- 717
allClear = function() -- 717
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 719
		clearMobileUI() -- 719
	end -- 719
	local systemNodes = { } -- 722
	local preserveSystemNode -- 723
	preserveSystemNode = function(node) -- 723
		if systemNodes[node] then -- 724
			return -- 724
		end -- 724
		systemNodes[node] = true -- 725
		do -- 726
			local clip = tolua.cast(node, "ClipNode") -- 726
			if clip then -- 726
				if clip.stencil then -- 727
					preserveSystemNode(clip.stencil) -- 727
				end -- 727
			end -- 726
		end -- 726
		return node:eachChild(function(child) -- 728
			preserveSystemNode(child) -- 729
			return false -- 730
		end) -- 728
	end -- 723
	for _index_0 = 1, #Routine do -- 731
		local routine = Routine[_index_0] -- 731
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 733
			goto _continue_0 -- 734
		else -- 736
			Routine:remove(routine) -- 736
		end -- 732
		::_continue_0:: -- 732
	end -- 731
	for _index_0 = 1, #moduleCache do -- 737
		local module = moduleCache[_index_0] -- 737
		package.loaded[module] = nil -- 738
	end -- 737
	moduleCache = { } -- 739
	Director:cleanup() -- 740
	Entity:clear() -- 741
	Platformer.Data:clear() -- 742
	Platformer.UnitAction:clear() -- 743
	Audio:stopAll(0.2) -- 744
	Struct:clear() -- 745
	View.nearPlaneDistance = 0.1 -- 748
	View.farPlaneDistance = 10000 -- 749
	View.fieldOfView = 45 -- 750
	View.postEffect = nil -- 751
	View.scale = scaleContent and screenScale or 1 -- 752
	Director.clearColor = Color(0xff1a1a1a) -- 753
	teal.clear() -- 754
	yue.clear() -- 755
	preserveSystemNode(Director.systemUI) -- 758
	for _, item in pairs(ubox()) do -- 759
		local node = tolua.cast(item, "Node") -- 760
		if node then -- 760
			if not systemNodes[node] then -- 761
				node:cleanup() -- 761
			end -- 761
		end -- 760
	end -- 759
	collectgarbage() -- 762
	collectgarbage() -- 763
	Wasm:clear() -- 764
	thread(function() -- 765
		sleep() -- 766
		return Cache:removeUnused() -- 767
	end) -- 765
	setupEventHandlers() -- 768
	Content.searchPaths = searchPaths -- 769
	App.idled = true -- 770
end -- 717
_module_0["allClear"] = allClear -- 717
local clearTempFiles -- 772
clearTempFiles = function() -- 772
	local writablePath = Content.writablePath -- 773
	if Content:exist(Path(writablePath, ".upload")) then -- 774
		Content:remove(Path(writablePath, ".upload")) -- 774
	end -- 774
	if Content:exist(Path(writablePath, ".download")) then -- 775
		return Content:remove(Path(writablePath, ".download")) -- 775
	end -- 775
end -- 772
local waitForWebStart = true -- 777
thread(function() -- 778
	sleep(2) -- 779
	waitForWebStart = false -- 780
end) -- 778
local reloadDevEntry -- 782
reloadDevEntry = function() -- 782
	return thread(function() -- 782
		waitForWebStart = true -- 783
		doClean() -- 784
		allClear() -- 785
		_G.require = oldRequire -- 786
		Dora.require = oldRequire -- 787
		package.loaded["Script.Dev.Entry"] = nil -- 788
		package.loaded["Script.Dev.WebServer"] = nil -- 789
		return Director.systemScheduler:schedule(function() -- 790
			Routine:clear() -- 791
			oldRequire("Script.Dev.Entry") -- 792
			return true -- 793
		end) -- 790
	end) -- 782
end -- 782
local setWorkspace -- 795
setWorkspace = function(path) -- 795
	clearTempFiles() -- 796
	Content.writablePath = path -- 797
	config.writablePath = Content.writablePath -- 798
	return thread(function() -- 799
		sleep() -- 800
		return reloadDevEntry() -- 801
	end) -- 799
end -- 795
_module_0["setWorkspace"] = setWorkspace -- 795
local quit = false -- 803
local activeSearchId = 0 -- 805
local handleSearchFiles -- 807
handleSearchFiles = function(payload) -- 807
	if not payload then -- 808
		return -- 808
	end -- 808
	local id = payload.id -- 809
	if id == nil then -- 810
		return -- 810
	end -- 810
	activeSearchId = id -- 811
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 812
	if path == nil then -- 813
		path = "" -- 813
	end -- 813
	if exts == nil then -- 814
		exts = { } -- 814
	end -- 814
	if globs == nil then -- 815
		globs = { } -- 815
	end -- 815
	if extensionLevels == nil then -- 816
		extensionLevels = { } -- 816
	end -- 816
	if pattern == nil then -- 817
		pattern = "" -- 817
	end -- 817
	if pattern == "" then -- 819
		return -- 819
	end -- 819
	local useRegex = payload.useRegex == true -- 820
	local caseSensitive = payload.caseSensitive == true -- 821
	local includeContent = payload.includeContent ~= false -- 822
	local contentWindow = payload.contentWindow or 0 -- 823
	return Director.systemScheduler:schedule(once(function() -- 824
		local stopped = false -- 825
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 826
			if activeSearchId ~= id then -- 827
				stopped = true -- 828
				return true -- 829
			end -- 827
			emit("AppWS", "Send", json.encode({ -- 831
				name = "SearchFilesResult", -- 831
				id = id, -- 831
				result = result -- 831
			})) -- 830
			return false -- 833
		end) -- 826
		return emit("AppWS", "Send", json.encode({ -- 835
			name = "SearchFilesDone", -- 835
			id = id, -- 835
			stopped = stopped -- 835
		})) -- 834
	end)) -- 824
end -- 807
local stop -- 838
stop = function() -- 838
	if isInEntry then -- 839
		return false -- 839
	end -- 839
	allClear() -- 840
	isInEntry = true -- 841
	currentEntry = nil -- 842
	return true -- 843
end -- 838
_module_0["stop"] = stop -- 838
local getCurrentEntryStatus -- 845
getCurrentEntryStatus = function() -- 845
	local entry = currentEntry -- 846
	if not (entry and not isInEntry) then -- 847
		return { -- 847
			success = true, -- 847
			running = false, -- 847
			runId = allEntries.runId -- 847
		} -- 847
	end -- 847
	local status = { -- 849
		success = true, -- 849
		running = true, -- 850
		kind = entry.runKind or "file", -- 851
		runId = allEntries.runId, -- 852
		entryName = entry.entryName, -- 853
		fileName = entry.fileName -- 854
	} -- 848
	if entry.workDir then -- 855
		status.workDir = entry.workDir -- 855
	end -- 855
	if entry.projectRoot then -- 856
		status.projectRoot = entry.projectRoot -- 856
	end -- 856
	return status -- 857
end -- 845
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 845
local _anon_func_2 = function(_with_0) -- 876
	local _val_0 = App.platform -- 876
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 876
end -- 876
setupEventHandlers = function() -- 859
	local _with_0 = Director.postNode -- 860
	_with_0:onAppEvent(function(eventType) -- 861
		if "Quit" == eventType then -- 862
			quit = true -- 863
			allClear() -- 864
			return clearTempFiles() -- 865
		elseif "Shutdown" == eventType then -- 866
			return stop() -- 867
		end -- 861
	end) -- 861
	_with_0:onAppChange(function(settingName) -- 868
		if "Theme" == settingName then -- 869
			config.themeColor = App.themeColor:toARGB() -- 870
		elseif "Locale" == settingName then -- 871
			config.locale = App.locale -- 872
			updateLocale() -- 873
			return teal.clear(true) -- 874
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 875
			if _anon_func_2(_with_0) then -- 876
				if "FullScreen" == settingName then -- 878
					config.fullScreen = App.fullScreen -- 878
				elseif "Position" == settingName then -- 879
					local _obj_0 = App.winPosition -- 879
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 879
				elseif "Size" == settingName then -- 880
					local width, height -- 881
					do -- 881
						local _obj_0 = App.winSize -- 881
						width, height = _obj_0.width, _obj_0.height -- 881
					end -- 881
					config.winWidth = width -- 882
					config.winHeight = height -- 883
				end -- 877
			end -- 876
		end -- 868
	end) -- 868
	_with_0:onAppWS(function(event) -- 884
		if event.type == "Close" then -- 885
			if HttpServer.wsConnectionCount == 0 then -- 886
				updateEntries() -- 887
			end -- 886
			return -- 888
		end -- 885
		if not (event.type == "Receive") then -- 889
			return -- 889
		end -- 889
		local data = json.decode(event.msg) -- 890
		if not data then -- 891
			return -- 891
		end -- 891
		local _exp_0 = data.name -- 892
		if "SearchFiles" == _exp_0 then -- 893
			return handleSearchFiles(data) -- 894
		elseif "SearchFilesStop" == _exp_0 then -- 895
			if data.id == nil or data.id == activeSearchId then -- 896
				activeSearchId = 0 -- 897
			end -- 896
		end -- 892
	end) -- 884
	_with_0:slot("UpdateEntries", function() -- 898
		return updateEntries() -- 898
	end) -- 898
	return _with_0 -- 860
end -- 859
setupEventHandlers() -- 900
clearTempFiles() -- 901
local downloadFile -- 903
downloadFile = function(url, target) -- 903
	return Director.systemScheduler:schedule(once(function() -- 903
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 904
			if quit then -- 905
				return true -- 905
			end -- 905
			emit("AppWS", "Send", json.encode({ -- 907
				name = "Download", -- 907
				url = url, -- 907
				status = "downloading", -- 907
				progress = current / total -- 908
			})) -- 906
			return false -- 904
		end) -- 904
		return emit("AppWS", "Send", json.encode(success and { -- 911
			name = "Download", -- 911
			url = url, -- 911
			status = "completed", -- 911
			progress = 1.0 -- 912
		} or { -- 914
			name = "Download", -- 914
			url = url, -- 914
			status = "failed", -- 914
			progress = 0.0 -- 915
		})) -- 910
	end)) -- 903
end -- 903
_module_0["downloadFile"] = downloadFile -- 903
local _anon_func_3 = function(file, require, workDir) -- 927
	if workDir == nil then -- 927
		workDir = Path:getPath(file) -- 927
	end -- 927
	Content:insertSearchPath(1, workDir) -- 928
	local scriptPath = Path(workDir, "Script") -- 929
	if Content:exist(scriptPath) then -- 930
		Content:insertSearchPath(1, scriptPath) -- 931
	end -- 930
	local result = require(file) -- 932
	if "function" == type(result) then -- 933
		result() -- 933
	end -- 933
	return nil -- 934
end -- 927
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 963
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 963
	label.alignment = "Left" -- 964
	label.textWidth = width - fontSize -- 965
	label.text = err -- 966
	return label -- 963
end -- 963
local enterEntryAsync -- 918
enterEntryAsync = function(entry) -- 918
	allEntries.runId = allEntries.runId + 1 -- 919
	isInEntry = false -- 920
	App.idled = false -- 921
	emit(Profiler.EventName, "ClearLoader") -- 922
	currentEntry = entry -- 923
	local file, workDir = entry.fileName, entry.workDir -- 924
	sleep() -- 925
	return xpcall(_anon_func_3, function(msg) -- 934
		local err = debug.traceback(msg) -- 936
		Log("Error", err) -- 937
		allClear() -- 938
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 939
		local viewWidth, viewHeight -- 940
		do -- 940
			local _obj_0 = View.size -- 940
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 940
		end -- 940
		local width, height = viewWidth - 20, viewHeight - 20 -- 941
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 942
		Director.ui:addChild((function() -- 943
			local root = AlignNode() -- 943
			do -- 944
				local _obj_0 = App.bufferSize -- 944
				width, height = _obj_0.width, _obj_0.height -- 944
			end -- 944
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 945
			root:onAppChange(function(settingName) -- 946
				if settingName == "Size" then -- 946
					do -- 947
						local _obj_0 = App.bufferSize -- 947
						width, height = _obj_0.width, _obj_0.height -- 947
					end -- 947
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 948
				end -- 946
			end) -- 946
			root:addChild((function() -- 949
				local _with_0 = ScrollArea({ -- 950
					width = width, -- 950
					height = height, -- 951
					paddingX = 0, -- 952
					paddingY = 50, -- 953
					viewWidth = height, -- 954
					viewHeight = height -- 955
				}) -- 949
				root:onAlignLayout(function(w, h) -- 957
					_with_0.position = Vec2(w / 2, h / 2) -- 958
					w = w - 20 -- 959
					h = h - 20 -- 960
					_with_0.view.children.first.textWidth = w - fontSize -- 961
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 962
				end) -- 957
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 963
				return _with_0 -- 949
			end)()) -- 949
			return root -- 943
		end)()) -- 943
		return err -- 967
	end, file, require, workDir) -- 926
end -- 918
_module_0["enterEntryAsync"] = enterEntryAsync -- 918
local enterDemoEntry -- 969
enterDemoEntry = function(entry) -- 969
	return thread(function() -- 969
		return enterEntryAsync(entry) -- 969
	end) -- 969
end -- 969
local reloadCurrentEntry -- 971
reloadCurrentEntry = function() -- 971
	if currentEntry then -- 972
		allClear() -- 973
		return enterDemoEntry(currentEntry) -- 974
	end -- 972
end -- 971
Director.clearColor = Color(0xff1a1a1a) -- 976
local descColor = Color(0xffa1a1a1) -- 977
local extraOperations -- 979
do -- 979
	local isOSSLicenseExist = Content:exist("LICENSES") -- 980
	local ossLicenses = nil -- 981
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 982
	local failedSetFolder = false -- 983
	local statusFlags = { -- 984
		"NoResize", -- 984
		"NoMove", -- 984
		"NoCollapse", -- 984
		"AlwaysAutoResize", -- 984
		"NoSavedSettings" -- 984
	} -- 984
	extraOperations = function() -- 991
		local zh = useChinese -- 992
		if isDesktop then -- 993
			local alwaysOnTop = config.alwaysOnTop -- 994
			do -- 995
				local changed -- 995
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 995
				if changed then -- 995
					App.alwaysOnTop = alwaysOnTop -- 996
					config.alwaysOnTop = alwaysOnTop -- 997
				end -- 995
			end -- 995
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 998
			do -- 999
				local changed -- 999
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 999
				if changed then -- 999
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1000
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1001
				end -- 999
			end -- 999
			SameLine() -- 1002
			TextColored(descColor, "(?)") -- 1003
			if IsItemHovered() then -- 1004
				BeginTooltip(function() -- 1005
					return PushTextWrapPos(360, function() -- 1006
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1007
					end) -- 1006
				end) -- 1005
			end -- 1004
		end -- 993
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1022
		do -- 1027
			local changed -- 1027
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1027
			if changed then -- 1027
				config.showPreview = showPreview -- 1028
				updateEntries() -- 1029
				if not showPreview then -- 1030
					thread(function() -- 1031
						collectgarbage() -- 1032
						return Cache:removeUnused("Texture") -- 1033
					end) -- 1031
				end -- 1030
			end -- 1027
		end -- 1027
		do -- 1034
			local changed -- 1034
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1034
			if changed then -- 1034
				config.authRequired = authRequired -- 1035
				HttpServer.authRequired = authRequired -- 1036
			end -- 1034
		end -- 1034
		SameLine() -- 1037
		TextColored(descColor, "(?)") -- 1038
		if IsItemHovered() then -- 1039
			BeginTooltip(function() -- 1040
				return PushTextWrapPos(280, function() -- 1041
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1042
				end) -- 1041
			end) -- 1040
		end -- 1039
		do -- 1043
			local themeColor = App.themeColor -- 1044
			local writablePath = config.writablePath -- 1045
			SeparatorText(zh and "工作目录" or "Workspace") -- 1046
			PushTextWrapPos(400, function() -- 1047
				return TextColored(themeColor, writablePath) -- 1048
			end) -- 1047
			if not isDesktop then -- 1049
				goto skipSetting -- 1049
			end -- 1049
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1050
			if Button(zh and "改变目录" or "Set Folder") then -- 1051
				App:openFileDialog(true, function(path) -- 1052
					if path == "" then -- 1053
						return -- 1053
					end -- 1053
					local relPath = Path:getRelative(Content.assetPath, path) -- 1054
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1055
						return setWorkspace(path) -- 1056
					else -- 1058
						failedSetFolder = true -- 1058
					end -- 1055
				end) -- 1052
			end -- 1051
			if failedSetFolder then -- 1059
				failedSetFolder = false -- 1060
				OpenPopup(popupName) -- 1061
			end -- 1059
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1062
			BeginPopupModal(popupName, statusFlags, function() -- 1063
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1064
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1065
					return CloseCurrentPopup() -- 1066
				end -- 1065
			end) -- 1063
			SameLine() -- 1067
			if Button(zh and "使用默认" or "Use Default") then -- 1068
				setWorkspace(Content.appPath) -- 1069
			end -- 1068
			Separator() -- 1070
			::skipSetting:: -- 1071
		end -- 1043
		if isOSSLicenseExist then -- 1072
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1073
				if not ossLicenses then -- 1074
					local licenseText = Content:load("LICENSES") -- 1075
					if licenseText then -- 1075
						ossLicenses = { } -- 1076
						licenseText = licenseText:gsub("\r\n", "\n") -- 1077
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1078
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1079
							if name then -- 1079
								ossLicenses[#ossLicenses + 1] = { -- 1080
									name, -- 1080
									text -- 1080
								} -- 1080
							end -- 1079
						end -- 1078
					end -- 1075
				end -- 1074
				if ossLicenses then -- 1081
					OpenPopup(ossLicensePopup) -- 1081
				end -- 1081
			end -- 1073
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1082
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1083
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1084
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1085
				return BeginPopupModal(ossLicensePopup, true, { -- 1088
					"NoSavedSettings" -- 1088
				}, function() -- 1089
					for _index_0 = 1, #ossLicenses do -- 1090
						local _des_0 = ossLicenses[_index_0] -- 1090
						local firstLine, text = _des_0[1], _des_0[2] -- 1090
						local name, license = firstLine:match("(.+): (.+)") -- 1092
						if name then -- 1092
							TextColored(themeColor, name) -- 1093
							SameLine() -- 1094
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1095
								return TextWrapped(text) -- 1095
							end) -- 1095
						end -- 1092
					end -- 1090
				end) -- 1085
			end) -- 1085
		end -- 1072
		if not App.debugging then -- 1098
			return -- 1098
		end -- 1098
		return TreeNode(zh and "开发操作" or "Development", function() -- 1099
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1100
				OpenPopup("build") -- 1100
			end -- 1100
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1101
				return BeginPopup("build", function() -- 1101
					if Selectable(zh and "编译" or "Compile") then -- 1102
						doCompile(false) -- 1102
					end -- 1102
					Separator() -- 1103
					if Selectable(zh and "压缩" or "Minify") then -- 1104
						doCompile(true) -- 1104
					end -- 1104
					Separator() -- 1105
					if Selectable(zh and "清理" or "Clean") then -- 1106
						return doClean() -- 1106
					end -- 1106
				end) -- 1101
			end) -- 1101
			if isInEntry then -- 1107
				if waitForWebStart then -- 1108
					BeginDisabled(function() -- 1109
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1109
					end) -- 1109
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1110
					reloadDevEntry() -- 1111
				end -- 1108
			end -- 1107
			do -- 1112
				local changed -- 1112
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1112
				if changed then -- 1112
					View.scale = scaleContent and screenScale or 1 -- 1113
				end -- 1112
			end -- 1112
			do -- 1114
				local changed -- 1114
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1114
				if changed then -- 1114
					config.engineDev = engineDev -- 1115
				end -- 1114
			end -- 1114
			do -- 1116
				local changed -- 1116
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1116
				if changed then -- 1116
					config.webIDETourCompleted = webIDETourCompleted -- 1117
				end -- 1116
			end -- 1116
			if testingThread then -- 1118
				return BeginDisabled(function() -- 1119
					return Button(zh and "开始自动测试" or "Test automatically") -- 1119
				end) -- 1119
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1120
				testingThread = thread(function() -- 1121
					local _ <close> = setmetatable({ }, { -- 1122
						__close = function() -- 1122
							allClear() -- 1123
							testingThread = nil -- 1124
							isInEntry = true -- 1125
							currentEntry = nil -- 1126
							return print("Testing done!") -- 1127
						end -- 1122
					}) -- 1122
					for _, entry in ipairs(allEntries) do -- 1128
						allClear() -- 1129
						print("Start " .. tostring(entry.entryName)) -- 1130
						enterDemoEntry(entry) -- 1131
						sleep(2) -- 1132
						print("Stop " .. tostring(entry.entryName)) -- 1133
					end -- 1128
				end) -- 1121
			end -- 1118
		end) -- 1099
	end -- 991
end -- 979
local icon = Path("Script", "Dev", "icon_s.png") -- 1135
local iconTex = nil -- 1136
thread(function() -- 1137
	if Cache:loadAsync(icon) then -- 1137
		iconTex = Texture2D(icon) -- 1137
	end -- 1137
end) -- 1137
local webStatus = nil -- 1139
local urlClicked = nil -- 1140
local authCode = string.format("%06d", math.random(0, 999999)) -- 1142
local authCodeTTL = 30.0 -- 1144
_module_0.getAuthCode = function() -- 1145
	return authCode -- 1145
end -- 1145
_module_0.invalidateAuthCode = function() -- 1146
	authCode = string.format("%06d", math.random(0, 999999)) -- 1147
	authCodeTTL = 30.0 -- 1148
end -- 1146
local AuthSession -- 1150
do -- 1150
	local pending = nil -- 1151
	local session = nil -- 1152
	AuthSession = { -- 1154
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1154
			pending = { -- 1156
				sessionId = sessionId, -- 1156
				confirmCode = confirmCode, -- 1157
				expiresAt = expiresAt, -- 1158
				ttl = ttl, -- 1159
				approved = false -- 1160
			} -- 1155
		end, -- 1154
		getPending = function() -- 1162
			return pending -- 1162
		end, -- 1162
		approvePending = function(sessionId) -- 1164
			if pending and pending.sessionId == sessionId then -- 1165
				pending.approved = true -- 1166
				return true -- 1167
			end -- 1165
			return false -- 1168
		end, -- 1164
		clearPending = function() -- 1170
			pending = nil -- 1170
		end, -- 1170
		setSession = function(sessionId, sessionSecret) -- 1172
			session = { -- 1174
				sessionId = sessionId, -- 1174
				sessionSecret = sessionSecret -- 1175
			} -- 1173
		end, -- 1172
		getSession = function() -- 1177
			return session -- 1177
		end -- 1177
	} -- 1153
end -- 1150
_module_0["AuthSession"] = AuthSession -- 1150
local transparant = Color(0x0) -- 1180
local windowFlags = { -- 1181
	"NoTitleBar", -- 1181
	"NoResize", -- 1181
	"NoMove", -- 1181
	"NoCollapse", -- 1181
	"NoSavedSettings", -- 1181
	"NoFocusOnAppearing", -- 1181
	"NoBringToFrontOnFocus" -- 1181
} -- 1181
local statusFlags = { -- 1190
	"NoTitleBar", -- 1190
	"NoResize", -- 1190
	"NoMove", -- 1190
	"NoCollapse", -- 1190
	"AlwaysAutoResize", -- 1190
	"NoSavedSettings" -- 1190
} -- 1190
local displayWindowFlags = { -- 1198
	"NoDecoration", -- 1198
	"NoSavedSettings", -- 1198
	"NoMove", -- 1198
	"NoScrollWithMouse", -- 1198
	"AlwaysAutoResize", -- 1198
	"NoFocusOnAppearing" -- 1198
} -- 1198
local gamepadInputWindowFlags = { -- 1206
	"NoDecoration", -- 1206
	"NoSavedSettings", -- 1206
	"NoMove", -- 1206
	"NoScrollbar", -- 1206
	"NoScrollWithMouse", -- 1206
	"NoFocusOnAppearing", -- 1206
	"NoBringToFrontOnFocus" -- 1206
} -- 1206
local initFooter = true -- 1215
local gamepadInputFocused = false -- 1216
local _anon_func_5 = function(allEntries, currentIndex) -- 1262
	if currentIndex > 1 then -- 1262
		return allEntries[currentIndex - 1] -- 1263
	else -- 1265
		return allEntries[#allEntries] -- 1265
	end -- 1262
end -- 1262
local _anon_func_6 = function(allEntries, currentIndex) -- 1269
	if currentIndex < #allEntries then -- 1269
		return allEntries[currentIndex + 1] -- 1270
	else -- 1272
		return allEntries[1] -- 1272
	end -- 1269
end -- 1269
footerWindow = threadLoop(function() -- 1217
	if mobileMode then -- 1218
		return -- 1218
	end -- 1218
	local zh = useChinese -- 1219
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1220
	if authCodeTTL <= 0 then -- 1221
		authCodeTTL = 30.0 -- 1222
		authCode = string.format("%06d", math.random(0, 999999)) -- 1223
	end -- 1221
	if HttpServer.wsConnectionCount > 0 then -- 1224
		return -- 1225
	end -- 1224
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1226
		if App.platform == "Emscripten" then -- 1227
			stop() -- 1229
		else -- 1231
			allClear() -- 1231
			App.devMode = false -- 1232
			App:shutdown() -- 1233
		end -- 1227
	end -- 1226
	do -- 1234
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1235
		if ctrl and Keyboard:isKeyDown("Q") then -- 1236
			stop() -- 1237
		end -- 1236
		if ctrl and Keyboard:isKeyDown("Z") then -- 1238
			reloadCurrentEntry() -- 1239
		end -- 1238
		if ctrl and Keyboard:isKeyDown(",") then -- 1240
			if showFooter then -- 1241
				showStats = not showStats -- 1241
			else -- 1241
				showStats = true -- 1241
			end -- 1241
			showFooter = true -- 1242
			config.showFooter = showFooter -- 1243
			config.showStats = showStats -- 1244
		end -- 1240
		if ctrl and Keyboard:isKeyDown(".") then -- 1245
			if showFooter then -- 1246
				showConsole = not showConsole -- 1246
			else -- 1246
				showConsole = true -- 1246
			end -- 1246
			showFooter = true -- 1247
			config.showFooter = showFooter -- 1248
			config.showConsole = showConsole -- 1249
		end -- 1245
		if ctrl and Keyboard:isKeyDown("/") then -- 1250
			showFooter = not showFooter -- 1251
			config.showFooter = showFooter -- 1252
		end -- 1250
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1253
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1254
		local currentIndex = nil -- 1255
		for i, entry in ipairs(allEntries) do -- 1256
			if currentEntry == entry then -- 1257
				currentIndex = i -- 1258
			end -- 1257
		end -- 1256
		if left then -- 1259
			allClear() -- 1260
			if currentIndex == nil then -- 1261
				currentIndex = #allEntries + 1 -- 1261
			end -- 1261
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1262
		end -- 1259
		if right then -- 1266
			allClear() -- 1267
			if currentIndex == nil then -- 1268
				currentIndex = 0 -- 1268
			end -- 1268
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1269
		end -- 1266
	end -- 1234
	if not showEntry then -- 1273
		return -- 1273
	end -- 1273
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1275
		reloadDevEntry() -- 1279
	end -- 1275
	if initFooter then -- 1280
		initFooter = false -- 1281
	end -- 1280
	local width, height -- 1283
	do -- 1283
		local _obj_0 = App.visualSize -- 1283
		width, height = _obj_0.width, _obj_0.height -- 1283
	end -- 1283
	if isInEntry then -- 1284
		gamepadInputFocused = false -- 1285
	else -- 1287
		SetNextWindowBgAlpha(0.0) -- 1287
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1288
		SetNextWindowPos(Vec2.zero, "Always") -- 1289
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1290
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1291
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1292
					if not gamepadInputFocused then -- 1293
						SetWindowFocus("DoraGamepadInput") -- 1294
						gamepadInputFocused = true -- 1295
					end -- 1293
				end) -- 1292
			end) -- 1291
		end) -- 1290
	end -- 1284
	if isInEntry or showFooter then -- 1297
		SetNextWindowSize(Vec2(width, 50)) -- 1298
		SetNextWindowPos(Vec2(0, height - 50)) -- 1299
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1300
			return PushStyleVar("WindowRounding", 0, function() -- 1301
				return Begin("Footer", windowFlags, function() -- 1302
					Separator() -- 1303
					if iconTex then -- 1304
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1305
							showStats = not showStats -- 1306
							config.showStats = showStats -- 1307
						end -- 1305
						SameLine() -- 1308
						if Button(">_", Vec2(30, 30)) then -- 1309
							showConsole = not showConsole -- 1310
							config.showConsole = showConsole -- 1311
						end -- 1309
					end -- 1304
					if isInEntry and config.updateNotification then -- 1312
						SameLine() -- 1313
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1314
							allClear() -- 1315
							config.updateNotification = false -- 1316
							enterDemoEntry({ -- 1318
								entryName = "SelfUpdater", -- 1318
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1319
							}) -- 1317
						end -- 1314
					end -- 1312
					if not isInEntry then -- 1320
						SameLine() -- 1321
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1322
						local currentIndex = nil -- 1323
						for i, entry in ipairs(allEntries) do -- 1324
							if currentEntry == entry then -- 1325
								currentIndex = i -- 1326
							end -- 1325
						end -- 1324
						if currentIndex then -- 1327
							if currentIndex > 1 then -- 1328
								SameLine() -- 1329
								if Button("<<", Vec2(30, 30)) then -- 1330
									allClear() -- 1331
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1332
								end -- 1330
							end -- 1328
							if currentIndex < #allEntries then -- 1333
								SameLine() -- 1334
								if Button(">>", Vec2(30, 30)) then -- 1335
									allClear() -- 1336
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1337
								end -- 1335
							end -- 1333
						end -- 1327
						SameLine() -- 1338
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1339
							reloadCurrentEntry() -- 1340
						end -- 1339
						if back then -- 1341
							allClear() -- 1342
							isInEntry = true -- 1343
							currentEntry = nil -- 1344
						end -- 1341
					end -- 1320
				end) -- 1302
			end) -- 1301
		end) -- 1300
	end -- 1297
	if isInEntry then -- 1346
		local showURL = true -- 1347
		local webIDEWidth -- 1348
		do -- 1348
			local base -- 1349
			if config.updateNotification then -- 1349
				base = 460 -- 1349
			else -- 1349
				base = 360 -- 1349
			end -- 1349
			local extra -- 1350
			if config.authRequired then -- 1350
				extra = 35 -- 1350
			else -- 1350
				extra = 0 -- 1350
			end -- 1350
			webIDEWidth = base + extra -- 1351
		end -- 1348
		if width < webIDEWidth then -- 1352
			showURL = false -- 1352
		end -- 1352
		SetNextWindowBgAlpha(0.0) -- 1353
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1354
		Begin("Web IDE", displayWindowFlags, function() -- 1355
			local pending = AuthSession.getPending() -- 1356
			local hovered = false -- 1357
			if not pending and showURL then -- 1358
				do -- 1359
					local url -- 1359
					if webStatus ~= nil then -- 1359
						url = webStatus.url -- 1359
					end -- 1359
					if url then -- 1359
						if isDesktop and not config.fullScreen then -- 1360
							if urlClicked then -- 1361
								BeginDisabled(function() -- 1362
									return Button(url) -- 1362
								end) -- 1362
							elseif Button(url) then -- 1363
								urlClicked = once(function() -- 1364
									return sleep(5) -- 1364
								end) -- 1364
								App:openURL("http://localhost:8866") -- 1365
							end -- 1361
						else -- 1367
							TextColored(descColor, url) -- 1367
						end -- 1360
					else -- 1369
						TextColored(descColor, zh and '不可用' or 'not available') -- 1369
					end -- 1359
				end -- 1359
				hovered = IsItemHovered() -- 1370
			else -- 1372
				TextColored(descColor, "(?)") -- 1372
				hovered = IsItemHovered() -- 1373
			end -- 1358
			SameLine() -- 1374
			local themeColor = App.themeColor -- 1375
			if pending then -- 1376
				if not pending.approved then -- 1377
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1378
					local ttl = pending.ttl or 1 -- 1379
					PushStyleColor("Text", themeColor, function() -- 1380
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1381
						hovered = hovered or IsItemHovered() -- 1382
					end) -- 1380
					SameLine() -- 1383
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1384
						AuthSession.approvePending(pending.sessionId) -- 1385
					end -- 1384
					if hovered then -- 1386
						return BeginTooltip(function() -- 1387
							return PushTextWrapPos(280, function() -- 1388
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1389
							end) -- 1388
						end) -- 1387
					end -- 1386
				end -- 1377
			else -- 1391
				if config.authRequired then -- 1391
					PushStyleColor("Text", themeColor, function() -- 1392
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1393
						hovered = hovered or IsItemHovered() -- 1394
					end) -- 1392
					if hovered then -- 1395
						return BeginTooltip(function() -- 1396
							return PushTextWrapPos(280, function() -- 1397
								local url -- 1398
								if webStatus ~= nil then -- 1398
									url = webStatus.url -- 1398
								end -- 1398
								if url then -- 1398
									local address -- 1399
									if showURL then -- 1399
										address = "Web IDE" -- 1399
									else -- 1399
										address = url -- 1399
									end -- 1399
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1400
								else -- 1402
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1402
								end -- 1398
							end) -- 1397
						end) -- 1396
					end -- 1395
				else -- 1404
					if hovered then -- 1404
						return BeginTooltip(function() -- 1405
							return PushTextWrapPos(280, function() -- 1406
								local url -- 1407
								if webStatus ~= nil then -- 1407
									url = webStatus.url -- 1407
								end -- 1407
								if url then -- 1407
									local address -- 1408
									if showURL then -- 1408
										address = "Web IDE" -- 1408
									else -- 1408
										address = url -- 1408
									end -- 1408
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1409
								else -- 1411
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1411
								end -- 1407
							end) -- 1406
						end) -- 1405
					end -- 1404
				end -- 1391
			end -- 1376
		end) -- 1355
	end -- 1346
	if not isInEntry then -- 1413
		SetNextWindowSize(Vec2(50, 50)) -- 1414
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1415
		PushStyleColor("WindowBg", transparant, function() -- 1416
			return Begin("Show", displayWindowFlags, function() -- 1416
				if width >= 370 then -- 1417
					local changed -- 1418
					changed, showFooter = Checkbox("##dev", showFooter) -- 1418
					if changed then -- 1418
						config.showFooter = showFooter -- 1419
					end -- 1418
				end -- 1417
			end) -- 1416
		end) -- 1416
	end -- 1413
	if isInEntry or showFooter then -- 1421
		if showStats then -- 1422
			PushStyleVar("WindowRounding", 0, function() -- 1423
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1424
				SetNextWindowSize(Vec2(0, height - 50)) -- 1425
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1426
				config.showStats = showStats -- 1427
			end) -- 1423
		end -- 1422
		if showConsole then -- 1428
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1429
			return PushStyleVar("WindowRounding", 6, function() -- 1430
				return ShowConsole() -- 1431
			end) -- 1430
		end -- 1428
	end -- 1421
end) -- 1217
local MaxWidth <const> = 960 -- 1433
local toolOpen = false -- 1435
local filterText = nil -- 1436
allEntries.anyEntryMatched = false -- 1437
allEntries.match = function(name) -- 1438
	local res = not filterText or name:lower():match(filterText) -- 1439
	if res then -- 1440
		allEntries.anyEntryMatched = true -- 1440
	end -- 1440
	return res -- 1441
end -- 1438
allEntries.thinSep = function() -- 1443
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1443
		return SeparatorText("") -- 1443
	end) -- 1443
end -- 1443
entryWindow = threadLoop(function() -- 1445
	local connected = syncWebIDEControl() -- 1446
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1448
		if not allEntries.pendingPackagePath then -- 1449
			local path = App:takeReceivedFile() -- 1450
			if path ~= "" then -- 1451
				allEntries.pendingPackagePath = path -- 1451
			end -- 1451
		end -- 1449
		if allEntries.pendingPackagePath then -- 1452
			pendingUIMode = true -- 1452
		end -- 1452
	end -- 1448
	if (pendingUIMode ~= nil) then -- 1454
		local nextMode = pendingUIMode -- 1455
		pendingUIMode = nil -- 1456
		applyUIMode(nextMode) -- 1457
	end -- 1454
	if mobileMode and not connected then -- 1458
		if isInEntry and not feedHost then -- 1459
			applyUIMode(true) -- 1459
		end -- 1459
		return -- 1460
	end -- 1458
	if App.fpsLimited ~= config.fpsLimited then -- 1461
		config.fpsLimited = App.fpsLimited -- 1462
	end -- 1461
	if App.targetFPS ~= config.targetFPS then -- 1463
		config.targetFPS = App.targetFPS -- 1464
	end -- 1463
	if View.vsync ~= config.vsync then -- 1465
		config.vsync = View.vsync -- 1466
	end -- 1465
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1467
		config.fixedFPS = Director.scheduler.fixedFPS -- 1468
	end -- 1467
	if Director.profilerSending ~= config.webProfiler then -- 1469
		config.webProfiler = Director.profilerSending -- 1470
	end -- 1469
	if urlClicked then -- 1471
		local _, result = coroutine.resume(urlClicked) -- 1472
		if result then -- 1473
			coroutine.close(urlClicked) -- 1474
			urlClicked = nil -- 1475
		end -- 1473
	end -- 1471
	if not isInEntry then -- 1476
		return -- 1476
	end -- 1476
	local zh = useChinese -- 1477
	local themeColor = App.themeColor -- 1478
	if connected then -- 1479
		local width, height -- 1480
		do -- 1480
			local _obj_0 = App.visualSize -- 1480
			width, height = _obj_0.width, _obj_0.height -- 1480
		end -- 1480
		SetNextWindowBgAlpha(0.5) -- 1481
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1482
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1483
			Separator() -- 1484
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1485
			if iconTex then -- 1486
				Image(icon, Vec2(24, 24)) -- 1487
				SameLine() -- 1488
			end -- 1486
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1489
			TextColored(descColor, slogon) -- 1490
			return Separator() -- 1491
		end) -- 1483
		return -- 1492
	end -- 1479
	if not showEntry then -- 1493
		return -- 1493
	end -- 1493
	local fullWidth, height -- 1495
	do -- 1495
		local _obj_0 = App.visualSize -- 1495
		fullWidth, height = _obj_0.width, _obj_0.height -- 1495
	end -- 1495
	local width = math.min(MaxWidth, fullWidth) -- 1496
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1497
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1498
	SetNextWindowPos(Vec2.zero) -- 1499
	SetNextWindowBgAlpha(0) -- 1500
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1501
	do -- 1502
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1503
			return Begin("Dora Dev", windowFlags, function() -- 1504
				Dummy(Vec2(fullWidth - 20, 0)) -- 1505
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1506
				SameLine() -- 1507
				if Button(zh and "Go 模式" or "Go Mode") then -- 1508
					setUIMode("mobile") -- 1509
				end -- 1508
				if fullWidth >= 540 then -- 1510
					SameLine() -- 1511
					Dummy(Vec2(fullWidth - 540, 0)) -- 1512
					SameLine() -- 1513
					SetNextItemWidth(zh and -95 or -140) -- 1514
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1515
						"AutoSelectAll" -- 1515
					}) then -- 1515
						config.filter = filterBuf.text -- 1516
					end -- 1515
					SameLine() -- 1517
					if Button(zh and '下载' or 'Download') then -- 1518
						allClear() -- 1519
						enterDemoEntry({ -- 1521
							entryName = "ResourceDownloader", -- 1521
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1522
						}) -- 1520
					end -- 1518
				end -- 1510
				return Separator() -- 1523
			end) -- 1504
		end) -- 1503
	end -- 1502
	allEntries.anyEntryMatched = false -- 1525
	SetNextWindowPos(Vec2(0, 50)) -- 1526
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1527
	do -- 1528
		return PushStyleColor("WindowBg", transparant, function() -- 1529
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1530
				return PushStyleVar("Alpha", 1, function() -- 1531
					return Begin("Content", windowFlags, function() -- 1532
						local DemoViewWidth <const> = 220 -- 1533
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1534
						if filterText then -- 1535
							filterText = filterText:lower() -- 1535
						end -- 1535
						if App.platform == "Emscripten" then -- 1536
							Dora.globals.webProjects.draw(zh, themeColor) -- 1537
							allEntries.anyEntryMatched = true -- 1538
						end -- 1536
						if #gamesInDev > 0 then -- 1539
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1540
							Columns(columns, false) -- 1541
							local realViewWidth = GetColumnWidth() - 50 -- 1542
							for _index_0 = 1, #gamesInDev do -- 1543
								local game = gamesInDev[_index_0] -- 1543
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1544
								local displayName -- 1553
								if repo then -- 1553
									if zh then -- 1554
										displayName = repo.title.zh -- 1554
									else -- 1554
										displayName = repo.title.en -- 1554
									end -- 1554
								end -- 1553
								if displayName == nil then -- 1555
									displayName = gameName -- 1555
								end -- 1555
								if allEntries.match(displayName) then -- 1556
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1557
									SameLine() -- 1558
									TextWrapped(displayName) -- 1559
									if columns > 1 then -- 1560
										if bannerFile and bannerTex then -- 1561
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1562
											local displayWidth <const> = realViewWidth -- 1563
											texHeight = displayWidth * texHeight / texWidth -- 1564
											texWidth = displayWidth -- 1565
											Dummy(Vec2.zero) -- 1566
											SameLine() -- 1567
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1568
										end -- 1561
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1569
											enterDemoEntry(game) -- 1570
										end -- 1569
									else -- 1572
										if bannerFile and bannerTex then -- 1572
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1573
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1574
											local sizing = 0.8 -- 1575
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1576
											texWidth = displayWidth * sizing -- 1577
											if texWidth > 500 then -- 1578
												sizing = 0.6 -- 1579
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1580
												texWidth = displayWidth * sizing -- 1581
											end -- 1578
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1582
											Dummy(Vec2(padding, 0)) -- 1583
											SameLine() -- 1584
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1585
										end -- 1572
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1586
											enterDemoEntry(game) -- 1587
										end -- 1586
									end -- 1560
									if #tests == 0 and #examples == 0 then -- 1588
										allEntries.thinSep() -- 1589
									end -- 1588
									NextColumn() -- 1590
								end -- 1556
								local showSep = false -- 1591
								if #examples > 0 then -- 1592
									local showExample = false -- 1593
									for _index_1 = 1, #examples do -- 1594
										local _des_0 = examples[_index_1] -- 1594
										local entryName = _des_0.entryName -- 1594
										if allEntries.match(entryName) then -- 1595
											showExample = true -- 1595
											break -- 1595
										end -- 1595
									end -- 1594
									if showExample then -- 1596
										showSep = true -- 1597
										Columns(1, false) -- 1598
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1599
										SameLine() -- 1600
										local opened -- 1601
										if (filterText ~= nil) then -- 1601
											opened = showExample -- 1601
										else -- 1601
											opened = false -- 1601
										end -- 1601
										if game.exampleOpen == nil then -- 1602
											game.exampleOpen = opened -- 1602
										end -- 1602
										SetNextItemOpen(game.exampleOpen) -- 1603
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1604
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1605
												Columns(maxColumns, false) -- 1606
												for _index_1 = 1, #examples do -- 1607
													local example = examples[_index_1] -- 1607
													local entryName = example.entryName -- 1608
													if not allEntries.match(entryName) then -- 1609
														goto _continue_0 -- 1609
													end -- 1609
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1610
														if Button(entryName, Vec2(-1, 40)) then -- 1611
															enterDemoEntry(example) -- 1612
														end -- 1611
														return NextColumn() -- 1613
													end) -- 1610
													opened = true -- 1614
													::_continue_0:: -- 1608
												end -- 1607
											end) -- 1605
										end) -- 1604
										game.exampleOpen = opened -- 1615
									end -- 1596
								end -- 1592
								if #tests > 0 then -- 1616
									local showTest = false -- 1617
									for _index_1 = 1, #tests do -- 1618
										local _des_0 = tests[_index_1] -- 1618
										local entryName = _des_0.entryName -- 1618
										if allEntries.match(entryName) then -- 1619
											showTest = true -- 1619
											break -- 1619
										end -- 1619
									end -- 1618
									if showTest then -- 1620
										showSep = true -- 1621
										Columns(1, false) -- 1622
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1623
										SameLine() -- 1624
										local opened -- 1625
										if (filterText ~= nil) then -- 1625
											opened = showTest -- 1625
										else -- 1625
											opened = false -- 1625
										end -- 1625
										if game.testOpen == nil then -- 1626
											game.testOpen = opened -- 1626
										end -- 1626
										SetNextItemOpen(game.testOpen) -- 1627
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1628
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1629
												Columns(maxColumns, false) -- 1630
												for _index_1 = 1, #tests do -- 1631
													local test = tests[_index_1] -- 1631
													local entryName = test.entryName -- 1632
													if not allEntries.match(entryName) then -- 1633
														goto _continue_0 -- 1633
													end -- 1633
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1634
														if Button(entryName, Vec2(-1, 40)) then -- 1635
															enterDemoEntry(test) -- 1636
														end -- 1635
														return NextColumn() -- 1637
													end) -- 1634
													opened = true -- 1638
													::_continue_0:: -- 1632
												end -- 1631
											end) -- 1629
										end) -- 1628
										game.testOpen = opened -- 1639
									end -- 1620
								end -- 1616
								if showSep then -- 1640
									Columns(1, false) -- 1641
									allEntries.thinSep() -- 1642
									Columns(columns, false) -- 1643
								end -- 1640
							end -- 1543
						end -- 1539
						if #doraTools > 0 then -- 1644
							local showTool = false -- 1645
							for _index_0 = 1, #doraTools do -- 1646
								local _des_0 = doraTools[_index_0] -- 1646
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1646
								local displayName -- 1647
								if repo then -- 1647
									if zh then -- 1648
										displayName = repo.title.zh -- 1648
									else -- 1648
										displayName = repo.title.en -- 1648
									end -- 1648
								end -- 1647
								if displayName == nil then -- 1649
									displayName = entryName -- 1649
								end -- 1649
								if allEntries.match(displayName) then -- 1650
									showTool = true -- 1650
									break -- 1650
								end -- 1650
							end -- 1646
							if not showTool then -- 1651
								goto endEntry -- 1651
							end -- 1651
							Columns(1, false) -- 1652
							TextColored(themeColor, "Dora SSR:") -- 1653
							SameLine() -- 1654
							Text(zh and "开发支持" or "Development Support") -- 1655
							Separator() -- 1656
							if #doraTools > 0 then -- 1657
								local opened -- 1658
								if (filterText ~= nil) then -- 1658
									opened = showTool -- 1658
								else -- 1658
									opened = false -- 1658
								end -- 1658
								SetNextItemOpen(toolOpen) -- 1659
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1660
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1661
										Columns(maxColumns, false) -- 1662
										for _index_0 = 1, #doraTools do -- 1663
											local tool = doraTools[_index_0] -- 1663
											local entryName, repo = tool.entryName, tool.repo -- 1664
											local displayName -- 1665
											if repo then -- 1665
												if zh then -- 1666
													displayName = repo.title.zh -- 1666
												else -- 1666
													displayName = repo.title.en -- 1666
												end -- 1666
											end -- 1665
											if displayName == nil then -- 1667
												displayName = entryName -- 1667
											end -- 1667
											if not allEntries.match(displayName) then -- 1668
												goto _continue_0 -- 1668
											end -- 1668
											if Button(displayName, Vec2(-1, 40)) then -- 1669
												enterDemoEntry(tool) -- 1670
											end -- 1669
											NextColumn() -- 1671
											::_continue_0:: -- 1664
										end -- 1663
										Columns(1, false) -- 1672
										opened = true -- 1673
									end) -- 1661
								end) -- 1660
								toolOpen = opened -- 1674
							end -- 1657
						end -- 1644
						::endEntry:: -- 1675
						if not allEntries.anyEntryMatched then -- 1676
							SetNextWindowBgAlpha(0) -- 1677
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1678
							Begin("Entries Not Found", displayWindowFlags, function() -- 1679
								Separator() -- 1680
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1681
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1682
								return Separator() -- 1683
							end) -- 1679
						end -- 1676
						Columns(1, false) -- 1684
						Dummy(Vec2(100, 80)) -- 1685
						return ScrollWhenDraggingOnVoid() -- 1686
					end) -- 1532
				end) -- 1531
			end) -- 1530
		end) -- 1529
	end -- 1528
end) -- 1445
if not (App.platform == "Emscripten") then -- 1691
	local sceneModuleCache = moduleCache -- 1692
	moduleCache = { } -- 1693
	webStatus = oldRequire("Script.Dev.WebServer") -- 1694
	moduleCache = sceneModuleCache -- 1695
end -- 1691
local _anon_func_7 = function(saved) -- 1718
	local _val_0 = saved.kind -- 1718
	return "local" == _val_0 or "discover" == _val_0 -- 1718
end -- 1718
local _anon_func_8 = function(saved) -- 1722
	local _val_0 = saved.activeTab -- 1722
	return "local" == _val_0 or "discover" == _val_0 -- 1722
end -- 1722
startMobileUI = function() -- 1697
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1698
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1699
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1700
	local getMobileFeedResources -- 1701
	do -- 1701
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1701
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1701
	end -- 1701
	local loadCachedCatalog -- 1702
	do -- 1702
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1702
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1702
	end -- 1702
	local getResourceInstallPath, getInstalledCatalogResource -- 1703
	do -- 1703
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1703
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1703
	end -- 1703
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1704
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1705
	local feedOptions = nil -- 1706
	local mobileLaunchErrors = { } -- 1707
	local withMobileLaunchErrors -- 1708
	withMobileLaunchErrors = function(items) -- 1708
		for _index_0 = 1, #items do -- 1709
			local item = items[_index_0] -- 1709
			item.launchError = mobileLaunchErrors[item.id] -- 1710
		end -- 1709
		return items -- 1711
	end -- 1708
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1712
	local loadRememberedMobileFeedState -- 1713
	loadRememberedMobileFeedState = function() -- 1713
		local raw = rememberedMobileFeedData -- 1714
		if not (type(raw) == "string" and raw ~= "") then -- 1715
			return -- 1715
		end -- 1715
		local ok, saved = pcall(json.decode, raw) -- 1716
		if not (ok and type(saved) == "table") then -- 1717
			return -- 1717
		end -- 1717
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1718
			local state = { -- 1719
				activeTab = saved.kind -- 1719
			} -- 1719
			state[saved.kind] = saved -- 1720
			return state -- 1721
		end -- 1718
		local state = { -- 1722
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1722
		} -- 1722
		local _list_0 = { -- 1723
			"local", -- 1723
			"discover" -- 1723
		} -- 1723
		for _index_0 = 1, #_list_0 do -- 1723
			local kind = _list_0[_index_0] -- 1723
			local entry = saved[kind] -- 1724
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1725
				state[kind] = entry -- 1725
			end -- 1725
		end -- 1723
		return state -- 1726
	end -- 1713
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1727
		activeTab = "local" -- 1727
	} -- 1727
	local rememberMobileFeedEntry -- 1728
	rememberMobileFeedEntry = function(entry) -- 1728
		rememberedMobileFeedState.activeTab = entry.kind -- 1729
		rememberedMobileFeedState[entry.kind] = { -- 1731
			id = entry.id, -- 1731
			kind = entry.kind, -- 1732
			workDir = entry.workDir, -- 1733
			fileName = entry.fileName -- 1734
		} -- 1730
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1736
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1737
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1738
			rememberedMobileFeedData -- 1738
		}) -- 1738
	end -- 1728
	local restartMobileFeed -- 1739
	restartMobileFeed = function(entry) -- 1739
		if feedHost then -- 1740
			feedHost:removeFromParent(true) -- 1740
		end -- 1740
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1741
		local initialEntries = { } -- 1742
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1743
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1744
		feedOptions.initialEntries = initialEntries -- 1745
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1746
	end -- 1739
	local startMobilePlay -- 1747
	startMobilePlay = function(entry) -- 1747
		if HttpServer.wsConnectionCount > 0 then -- 1748
			return -- 1748
		end -- 1748
		local originFeed = feedHost -- 1749
		if remixHost then -- 1750
			remixHost:removeFromParent(true) -- 1750
		end -- 1750
		remixHost = nil -- 1751
		mobileLaunchErrors[entry.id] = nil -- 1752
		entry.launchError = nil -- 1753
		local playActive = true -- 1754
		local restoreMobileFeed -- 1755
		restoreMobileFeed = function() -- 1755
			if not playActive then -- 1756
				return -- 1756
			end -- 1756
			playActive = false -- 1757
			allClear() -- 1758
			isInEntry = true -- 1759
			currentEntry = nil -- 1760
			return restartMobileFeed(entry) -- 1761
		end -- 1755
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1763
			onExit = function() -- 1763
				return restoreMobileFeed() -- 1763
			end, -- 1763
			onRuntimeError = function() -- 1764
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1765
				return restoreMobileFeed() -- 1766
			end -- 1764
		})) -- 1762
		return thread(function() -- 1768
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1772
			if not playActive then -- 1773
				return -- 1773
			end -- 1773
			if success then -- 1774
				if originFeed and originFeed.parent then -- 1775
					originFeed.visible = false -- 1775
				end -- 1775
				return -- 1776
			end -- 1774
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1777
			return restoreMobileFeed() -- 1778
		end) -- 1768
	end -- 1747
	feedOptions = { -- 1780
		takeReceivedFile = function() -- 1780
			if allEntries.pendingPackagePath then -- 1781
				local path = allEntries.pendingPackagePath -- 1782
				allEntries.pendingPackagePath = nil -- 1783
				return path -- 1784
			end -- 1781
			return App:takeReceivedFile() -- 1785
		end, -- 1780
		onSwitchMode = function() -- 1786
			if HttpServer.wsConnectionCount == 0 then -- 1786
				pendingUIMode = false -- 1786
			end -- 1786
		end, -- 1786
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1787
		getLocalEntries = function(importedProjectPath) -- 1788
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1789
			feedOptions.dirtyProjectPath = nil -- 1790
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1791
			local cached = loadCachedCatalog() -- 1792
			if cached.success and cached.snapshot then -- 1793
				for _index_0 = 1, #items do -- 1794
					local entry = items[_index_0] -- 1794
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1795
					if resource then -- 1796
						entry.resource = resource -- 1797
						entry.catalogCommit = cached.snapshot.commit -- 1798
					end -- 1796
				end -- 1794
			end -- 1793
			return items -- 1799
		end, -- 1788
		syncDiscover = function(onProgress, onDone, force) -- 1800
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1800
		end, -- 1800
		getDiscoverEntries = function() -- 1801
			local cached = loadCachedCatalog() -- 1802
			if not (cached.success and cached.snapshot) then -- 1803
				return { } -- 1803
			end -- 1803
			local items = { } -- 1804
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1805
			for _index_0 = 1, #_list_0 do -- 1805
				local resource = _list_0[_index_0] -- 1805
				local installed = lifecycle.isMobileResourceReady(resource) -- 1806
				local installPath = getResourceInstallPath(resource.id) -- 1807
				items[#items + 1] = { -- 1809
					id = resource.id, -- 1809
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1810
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1811
					kind = "discover", -- 1812
					bannerFile = resource.bannerPath, -- 1813
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1814
					sourceUrl = resource.versions[1].sources[1].url, -- 1815
					workDir = installed and installPath or nil, -- 1816
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1817
					installed = installed, -- 1818
					resource = resource, -- 1819
					catalogCommit = cached.snapshot.commit, -- 1820
					launchError = mobileLaunchErrors[resource.id] -- 1821
				} -- 1808
			end -- 1805
			return items -- 1823
		end, -- 1801
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1824
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1825
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1826
			end), repairIncomplete, isCanceled) -- 1825
		end, -- 1824
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1828
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1829
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1830
			end), isCanceled) -- 1829
		end, -- 1828
		createProject = function(name, language) -- 1832
			local result = projectCreate.createMobileProject(name, language) -- 1833
			if not result.success then -- 1834
				return result -- 1834
			end -- 1834
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1835
			for _index_0 = 1, #_list_0 do -- 1835
				local entry = _list_0[_index_0] -- 1835
				if entry.workDir == result.workDir then -- 1836
					return { -- 1837
						success = true, -- 1837
						entry = entry -- 1837
					} -- 1837
				end -- 1836
			end -- 1835
			return { -- 1838
				success = false, -- 1838
				error = "created-project-not-found" -- 1838
			} -- 1838
		end, -- 1832
		onPlay = function(entry) -- 1839
			return startMobilePlay(entry) -- 1839
		end, -- 1839
		onRemix = function(entry) -- 1840
			if HttpServer.wsConnectionCount > 0 then -- 1841
				return -- 1841
			end -- 1841
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1842
			local originFeed = feedHost -- 1843
			feedHost.visible = false -- 1844
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1846
				entry = entry, -- 1846
				onProjectChanged = function(current) -- 1847
					feedOptions.dirtyProjectPath = current.workDir -- 1847
				end, -- 1847
				onBack = function() -- 1848
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1849
						originFeed:emit("RestoreFeedEntry", entry) -- 1850
						originFeed.visible = true -- 1851
					end -- 1849
				end, -- 1848
				onPlay = function(current) -- 1852
					return startMobilePlay(current) -- 1852
				end -- 1852
			})) -- 1845
		end -- 1840
	} -- 1779
	return restartMobileFeed() -- 1855
end -- 1697
if mobileMode then -- 1857
	applyUIMode(true) -- 1857
end -- 1857
return _module_0 -- 1
