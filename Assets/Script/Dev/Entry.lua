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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "agentLLMConfigVersion", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 60
config:load() -- 96
if not (config.writablePath ~= nil) then -- 98
	config.writablePath = Content.appPath -- 99
end -- 98
if not (config.webIDEConnected ~= nil) then -- 101
	config.webIDEConnected = false -- 102
end -- 101
if (config.fpsLimited ~= nil) then -- 104
	App.fpsLimited = config.fpsLimited -- 105
else -- 107
	config.fpsLimited = App.fpsLimited -- 107
end -- 104
if (config.targetFPS ~= nil) then -- 109
	App.targetFPS = math.floor(config.targetFPS) -- 110
else -- 112
	config.targetFPS = App.targetFPS -- 112
end -- 109
if (config.vsync ~= nil) then -- 114
	View.vsync = config.vsync -- 115
else -- 117
	config.vsync = View.vsync -- 117
end -- 114
if (config.fixedFPS ~= nil) then -- 119
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 120
else -- 122
	config.fixedFPS = Director.scheduler.fixedFPS -- 122
end -- 119
if not (config.showPreview ~= nil) then -- 124
	config.showPreview = true -- 125
end -- 124
if not (config.mobileFeed ~= nil) then -- 127
	local _val_0 = App.platform -- 128
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 128
end -- 127
if not (config.webIDETourCompleted ~= nil) then -- 130
	config.webIDETourCompleted = false -- 131
end -- 130
if not (config.authRequired ~= nil) then -- 133
	local _val_0 = App.platform -- 134
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 134
end -- 133
HttpServer.authRequired = config.authRequired -- 135
local showEntry = true -- 137
isDesktop = false -- 139
if (function() -- 140
	local _val_0 = App.platform -- 140
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 140
end)() then -- 140
	isDesktop = true -- 141
	if config.fullScreen then -- 142
		App.fullScreen = true -- 143
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 144
		local size = Size(config.winWidth, config.winHeight) -- 145
		if App.winSize ~= size then -- 146
			App.winSize = size -- 147
		end -- 146
		local winX, winY -- 148
		do -- 148
			local _obj_0 = App.winPosition -- 148
			winX, winY = _obj_0.x, _obj_0.y -- 148
		end -- 148
		if (config.winX ~= nil) then -- 149
			winX = config.winX -- 150
		else -- 152
			config.winX = -1 -- 152
		end -- 149
		if (config.winY ~= nil) then -- 153
			winY = config.winY -- 154
		else -- 156
			config.winY = -1 -- 156
		end -- 153
		App.winPosition = Vec2(winX, winY) -- 157
	end -- 142
	if (config.alwaysOnTop ~= nil) then -- 158
		App.alwaysOnTop = config.alwaysOnTop -- 159
	else -- 161
		config.alwaysOnTop = false -- 161
	end -- 158
	if (config.virtualGamepadEnabled ~= nil) then -- 162
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 163
	else -- 165
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 165
	end -- 162
end -- 140
if (config.themeColor ~= nil) then -- 167
	App.themeColor = Color(config.themeColor) -- 168
else -- 170
	config.themeColor = App.themeColor:toARGB() -- 170
end -- 167
if not (config.locale ~= nil) then -- 172
	config.locale = App.locale -- 173
end -- 172
local showStats = false -- 175
if (config.showStats ~= nil) then -- 176
	showStats = config.showStats -- 177
else -- 179
	config.showStats = showStats -- 179
end -- 176
local showConsole = false -- 181
if (config.showConsole ~= nil) then -- 182
	showConsole = config.showConsole -- 183
else -- 185
	config.showConsole = showConsole -- 185
end -- 182
local showFooter = true -- 187
if (config.showFooter ~= nil) then -- 188
	showFooter = config.showFooter -- 189
else -- 191
	config.showFooter = showFooter -- 191
end -- 188
local setFooterVisible -- 193
setFooterVisible = function(visible) -- 193
	if visible == nil then -- 193
		visible = true -- 193
	end -- 193
	showFooter = visible -- 194
	config.showFooter = showFooter -- 195
end -- 193
_module_0["setFooterVisible"] = setFooterVisible -- 193
local filterBuf = Buffer(20) -- 197
if (config.filter ~= nil) then -- 198
	filterBuf.text = config.filter -- 199
else -- 201
	config.filter = "" -- 201
end -- 198
local engineDev = false -- 203
if (config.engineDev ~= nil) then -- 204
	engineDev = config.engineDev -- 205
else -- 207
	config.engineDev = engineDev -- 207
end -- 204
if (config.webProfiler ~= nil) then -- 209
	Director.profilerSending = config.webProfiler -- 210
else -- 212
	config.webProfiler = true -- 212
	Director.profilerSending = true -- 213
end -- 209
if not (config.drawerWidth ~= nil) then -- 215
	config.drawerWidth = 200 -- 216
end -- 215
_module_0.getConfig = function() -- 218
	return config -- 218
end -- 218
_module_0.getEngineDev = function() -- 219
	if not App.debugging then -- 220
		return false -- 220
	end -- 220
	return config.engineDev -- 221
end -- 219
local _anon_func_0 = function() -- 226
	local _val_0 = App.platform -- 226
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 226
end -- 226
_module_0.connectWebIDE = function() -- 223
	if not config.webIDEConnected then -- 224
		config.webIDEConnected = true -- 225
		if _anon_func_0() then -- 226
			local ratio = App.winSize.width / App.visualSize.width -- 227
			App.winSize = Size(640 * ratio, 480 * ratio) -- 228
		end -- 226
	end -- 224
end -- 223
local updateCheck -- 230
updateCheck = function() -- 230
	return thread(function() -- 230
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 231
		if res then -- 231
			local data = json.decode(res) -- 232
			if data then -- 232
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 233
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 234
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 235
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 236
				if na < a then -- 237
					goto not_new_version -- 238
				end -- 237
				if na == a then -- 239
					if nb < b then -- 240
						goto not_new_version -- 241
					end -- 240
					if nb == b then -- 242
						if nc < c then -- 243
							goto not_new_version -- 244
						end -- 243
						if nc == c then -- 245
							goto not_new_version -- 246
						end -- 245
					end -- 242
				end -- 239
				config.updateNotification = true -- 247
				::not_new_version:: -- 248
				config.lastUpdateCheck = os.time() -- 249
			end -- 232
		end -- 231
	end) -- 230
end -- 230
if (config.lastUpdateCheck ~= nil) then -- 251
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 252
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 253
		updateCheck() -- 254
	end -- 253
else -- 256
	updateCheck() -- 256
end -- 251
local Set, Struct, LintYueGlobals, GSplit -- 258
do -- 258
	local _obj_0 = require("Utils") -- 258
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 258
end -- 258
local yueext = yue.options.extension -- 259
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 261
local building = false -- 263
local getAllFiles -- 265
getAllFiles = function(path, exts, recursive) -- 265
	if recursive == nil then -- 265
		recursive = true -- 265
	end -- 265
	local filters = Set(exts) -- 266
	local files -- 267
	if recursive then -- 267
		files = Content:getAllFiles(path) -- 268
	else -- 270
		files = Content:getFiles(path) -- 270
	end -- 267
	local _accum_0 = { } -- 271
	local _len_0 = 1 -- 271
	for _index_0 = 1, #files do -- 271
		local file = files[_index_0] -- 271
		if not filters[Path:getExt(file)] then -- 272
			goto _continue_0 -- 272
		end -- 272
		_accum_0[_len_0] = file -- 273
		_len_0 = _len_0 + 1 -- 272
		::_continue_0:: -- 272
	end -- 271
	return _accum_0 -- 271
end -- 265
_module_0["getAllFiles"] = getAllFiles -- 265
local getFileEntries -- 275
getFileEntries = function(path, recursive, excludeFiles) -- 275
	if recursive == nil then -- 275
		recursive = true -- 275
	end -- 275
	if excludeFiles == nil then -- 275
		excludeFiles = nil -- 275
	end -- 275
	local entries = { } -- 276
	local excludes -- 277
	if excludeFiles then -- 277
		excludes = Set(excludeFiles) -- 278
	end -- 277
	local _list_0 = getAllFiles(path, { -- 279
		"lua", -- 279
		"xml", -- 279
		yueext, -- 279
		"tl" -- 279
	}, recursive) -- 279
	for _index_0 = 1, #_list_0 do -- 279
		local file = _list_0[_index_0] -- 279
		local entryName = Path:getName(file) -- 280
		if excludes and excludes[entryName] then -- 281
			goto _continue_0 -- 282
		end -- 281
		local fileName = Path:replaceExt(file, "") -- 283
		fileName = Path(path, fileName) -- 284
		local entryAdded -- 285
		for _index_1 = 1, #entries do -- 285
			local _des_0 = entries[_index_1] -- 285
			local ename, efile = _des_0.entryName, _des_0.fileName -- 285
			if entryName == ename and efile == fileName then -- 286
				entryAdded = true -- 286
				break -- 286
			end -- 286
		end -- 285
		if entryAdded then -- 287
			goto _continue_0 -- 287
		end -- 287
		local entry = { -- 288
			entryName = entryName, -- 288
			fileName = fileName -- 288
		} -- 288
		entries[#entries + 1] = entry -- 289
		::_continue_0:: -- 280
	end -- 279
	table.sort(entries, function(a, b) -- 290
		return a.entryName < b.entryName -- 290
	end) -- 290
	return entries -- 291
end -- 275
local allEntries = { -- 293
	dirty = { }, -- 293
	hasDirty = false, -- 293
	runId = 0 -- 293
} -- 293
allEntries.scanDir = function(path, dir, noPreview) -- 295
	if noPreview == nil then -- 295
		noPreview = false -- 295
	end -- 295
	local entries = { } -- 296
	if not dir:match("^%.") then -- 297
		local _list_0 = getAllFiles(Path(path, dir), { -- 298
			"lua", -- 298
			"xml", -- 298
			yueext, -- 298
			"tl", -- 298
			"wasm" -- 298
		}) -- 298
		for _index_0 = 1, #_list_0 do -- 298
			local file = _list_0[_index_0] -- 298
			if "init" == Path:getName(file):lower() then -- 299
				local fileName = Path:replaceExt(file, "") -- 300
				fileName = Path(path, dir, fileName) -- 301
				local projectPath = Path:getPath(fileName) -- 302
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 303
				local repo = nil -- 304
				if Content:exist(repoFile) then -- 305
					local str = Content:load(repoFile) -- 306
					if str then -- 306
						repo = json.decode(str) -- 307
					end -- 306
				end -- 305
				local entryName = Path:getName(projectPath) -- 308
				local entryAdded -- 309
				for _index_1 = 1, #entries do -- 309
					local _des_0 = entries[_index_1] -- 309
					local ename, efile = _des_0.entryName, _des_0.fileName -- 309
					if entryName == ename and efile == fileName then -- 310
						entryAdded = true -- 310
						break -- 310
					end -- 310
				end -- 309
				if entryAdded then -- 311
					goto _continue_0 -- 311
				end -- 311
				local examples = { } -- 312
				local tests = { } -- 313
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 314
				if Content:exist(examplePath) then -- 315
					local _list_1 = getFileEntries(examplePath) -- 316
					for _index_1 = 1, #_list_1 do -- 316
						local _des_0 = _list_1[_index_1] -- 316
						local name, ePath = _des_0.entryName, _des_0.fileName -- 316
						local entry = { -- 318
							entryName = name, -- 318
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 319
							workDir = projectPath -- 320
						} -- 317
						examples[#examples + 1] = entry -- 322
					end -- 316
				end -- 315
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 323
				if Content:exist(testPath) then -- 324
					local _list_1 = getFileEntries(testPath) -- 325
					for _index_1 = 1, #_list_1 do -- 325
						local _des_0 = _list_1[_index_1] -- 325
						local name, tPath = _des_0.entryName, _des_0.fileName -- 325
						local entry = { -- 327
							entryName = name, -- 327
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 328
							workDir = projectPath -- 329
						} -- 326
						tests[#tests + 1] = entry -- 331
					end -- 325
				end -- 324
				local entry = { -- 332
					entryName = entryName, -- 332
					fileName = fileName, -- 332
					projectPath = projectPath, -- 332
					examples = examples, -- 332
					tests = tests, -- 332
					repo = repo -- 332
				} -- 332
				local bannerFile -- 333
				do -- 333
					local _val_0 -- 333
					repeat -- 333
						if noPreview then -- 334
							_val_0 = nil -- 334
							break -- 334
						end -- 334
						if not config.showPreview then -- 335
							_val_0 = nil -- 335
							break -- 335
						end -- 335
						local f = Path(projectPath, ".dora", "banner.jpg") -- 336
						if Content:exist(f) then -- 337
							_val_0 = f -- 337
							break -- 337
						end -- 337
						f = Path(projectPath, ".dora", "banner.png") -- 338
						if Content:exist(f) then -- 339
							_val_0 = f -- 339
							break -- 339
						end -- 339
						f = Path(projectPath, "Image", "banner.jpg") -- 340
						if Content:exist(f) then -- 341
							_val_0 = f -- 341
							break -- 341
						end -- 341
						f = Path(projectPath, "Image", "banner.png") -- 342
						if Content:exist(f) then -- 343
							_val_0 = f -- 343
							break -- 343
						end -- 343
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 344
						if Content:exist(f) then -- 345
							_val_0 = f -- 345
							break -- 345
						end -- 345
					until true -- 333
					bannerFile = _val_0 -- 333
				end -- 333
				if bannerFile then -- 347
					entry.bannerFile = bannerFile -- 350
					thread(function() -- 351
						if Cache:loadAsync(bannerFile) then -- 352
							local bannerTex = Texture2D(bannerFile) -- 353
							if bannerTex then -- 353
								entry.bannerTex = bannerTex -- 354
							end -- 353
						end -- 352
					end) -- 351
				end -- 347
				entries[#entries + 1] = entry -- 355
			end -- 299
			::_continue_0:: -- 299
		end -- 298
	end -- 297
	return entries -- 356
end -- 295
local getProjectEntries -- 358
getProjectEntries = function(path, noPreview) -- 358
	if noPreview == nil then -- 358
		noPreview = false -- 358
	end -- 358
	local entries = { } -- 359
	local _list_0 = Content:getDirs(path) -- 360
	for _index_0 = 1, #_list_0 do -- 360
		local dir = _list_0[_index_0] -- 360
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 361
		for _index_1 = 1, #_list_1 do -- 361
			local entry = _list_1[_index_1] -- 361
			entries[#entries + 1] = entry -- 362
		end -- 361
	end -- 360
	table.sort(entries, function(a, b) -- 363
		return a.entryName < b.entryName -- 363
	end) -- 363
	return entries -- 364
end -- 358
_module_0["getProjectEntries"] = getProjectEntries -- 358
local gamesInDev -- 366
local doraTools -- 367
local isToolEntry -- 369
isToolEntry = function(entry) -- 369
	do -- 370
		local _type_0 = type(entry) -- 370
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 370
		if _tab_0 then -- 370
			local categories -- 370
			do -- 370
				local _obj_0 = entry.repo -- 370
				local _type_1 = type(_obj_0) -- 370
				if "table" == _type_1 or "userdata" == _type_1 then -- 370
					categories = _obj_0.categories -- 370
				end -- 370
			end -- 370
			if categories ~= nil then -- 370
				for _index_0 = 1, #categories do -- 371
					local category = categories[_index_0] -- 371
					if "string" == type(category) and category:lower() == "tool" then -- 372
						return true -- 373
					end -- 372
				end -- 371
			end -- 370
		end -- 370
	end -- 370
	return false -- 369
end -- 369
local getEntryTitle -- 375
getEntryTitle = function(entry) -- 375
	local title -- 376
	do -- 376
		local repo = entry.repo -- 376
		if repo then -- 376
			if repo.title and "table" == type(repo.title) then -- 377
				if useChinese then -- 378
					title = repo.title.zh -- 378
				else -- 378
					title = repo.title.en -- 378
				end -- 378
			end -- 377
		end -- 376
	end -- 376
	if title ~= nil then -- 379
		return title -- 379
	else -- 379
		return entry.entryName -- 379
	end -- 379
end -- 375
allEntries.rebuildEntries = function() -- 381
	gamesInDev = { } -- 382
	do -- 383
		local _accum_0 = { } -- 383
		local _len_0 = 1 -- 383
		local _list_0 = allEntries.builtinTools -- 383
		for _index_0 = 1, #_list_0 do -- 383
			local tool = _list_0[_index_0] -- 383
			_accum_0[_len_0] = tool -- 383
			_len_0 = _len_0 + 1 -- 383
		end -- 383
		doraTools = _accum_0 -- 383
	end -- 383
	local _list_0 = allEntries.projectEntries -- 384
	for _index_0 = 1, #_list_0 do -- 384
		local entry = _list_0[_index_0] -- 384
		if isToolEntry(entry) then -- 385
			entry.kind = "tool" -- 386
			doraTools[#doraTools + 1] = entry -- 387
		else -- 389
			entry.kind = "game" -- 389
			gamesInDev[#gamesInDev + 1] = entry -- 390
		end -- 385
	end -- 384
	for i = #allEntries, 1, -1 do -- 391
		allEntries[i] = nil -- 392
	end -- 391
	for _index_0 = 1, #gamesInDev do -- 393
		local game = gamesInDev[_index_0] -- 393
		allEntries[#allEntries + 1] = game -- 394
		local examples, tests = game.examples, game.tests -- 395
		for _index_1 = 1, #examples do -- 396
			local example = examples[_index_1] -- 396
			allEntries[#allEntries + 1] = example -- 397
		end -- 396
		for _index_1 = 1, #tests do -- 398
			local test = tests[_index_1] -- 398
			allEntries[#allEntries + 1] = test -- 399
		end -- 398
	end -- 393
end -- 381
local updateEntries -- 401
updateEntries = function() -- 401
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 402
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 403
	local _list_0 = allEntries.builtinTools -- 404
	for _index_0 = 1, #_list_0 do -- 404
		local tool = _list_0[_index_0] -- 404
		tool.kind = "tool" -- 405
		tool.builtin = true -- 406
	end -- 404
	return allEntries.rebuildEntries() -- 407
end -- 401
allEntries.refreshDirtyProjects = function() -- 409
	if not allEntries.hasDirty then -- 410
		return -- 410
	end -- 410
	local dirty = allEntries.dirty -- 411
	allEntries.dirty = { } -- 412
	allEntries.hasDirty = false -- 413
	for projectPath in pairs(dirty) do -- 414
		do -- 415
			local _accum_0 = { } -- 415
			local _len_0 = 1 -- 415
			local _list_0 = allEntries.projectEntries -- 415
			for _index_0 = 1, #_list_0 do -- 415
				local entry = _list_0[_index_0] -- 415
				if entry.projectPath ~= projectPath then -- 415
					_accum_0[_len_0] = entry -- 415
					_len_0 = _len_0 + 1 -- 415
				end -- 415
			end -- 415
			allEntries.projectEntries = _accum_0 -- 415
		end -- 415
		local parentPath = Path:getPath(projectPath) -- 416
		local dir = Path:getFilename(projectPath) -- 417
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 418
		for _index_0 = 1, #_list_0 do -- 418
			local entry = _list_0[_index_0] -- 418
			if entry.projectPath == projectPath then -- 419
				do -- 420
					local _obj_0 = allEntries.projectEntries -- 420
					_obj_0[#_obj_0 + 1] = entry -- 420
				end -- 420
				break -- 421
			end -- 419
		end -- 418
	end -- 414
	table.sort(allEntries.projectEntries, function(a, b) -- 422
		return a.entryName < b.entryName -- 422
	end) -- 422
	return allEntries.rebuildEntries() -- 423
end -- 409
updateEntries() -- 425
local getLaunchEntries -- 427
getLaunchEntries = function(refresh) -- 427
	if refresh == nil then -- 427
		refresh = false -- 427
	end -- 427
	if refresh then -- 428
		updateEntries() -- 428
	end -- 428
	local toInfo -- 429
	toInfo = function(entry, kind) -- 429
		local file = entry.fileName -- 430
		local asProj = not entry.builtin -- 431
		return { -- 433
			name = getEntryTitle(entry), -- 433
			file = file, -- 434
			kind = kind, -- 435
			asProj = asProj -- 436
		} -- 432
	end -- 429
	local games -- 438
	do -- 438
		local _accum_0 = { } -- 438
		local _len_0 = 1 -- 438
		for _index_0 = 1, #gamesInDev do -- 438
			local game = gamesInDev[_index_0] -- 438
			_accum_0[_len_0] = toInfo(game, "game") -- 438
			_len_0 = _len_0 + 1 -- 438
		end -- 438
		games = _accum_0 -- 438
	end -- 438
	local tools -- 439
	do -- 439
		local _accum_0 = { } -- 439
		local _len_0 = 1 -- 439
		for _index_0 = 1, #doraTools do -- 439
			local tool = doraTools[_index_0] -- 439
			_accum_0[_len_0] = toInfo(tool, "tool") -- 439
			_len_0 = _len_0 + 1 -- 439
		end -- 439
		tools = _accum_0 -- 439
	end -- 439
	return { -- 440
		games = games, -- 440
		tools = tools -- 440
	} -- 440
end -- 427
_module_0["getLaunchEntries"] = getLaunchEntries -- 427
local _anon_func_1 = function(entry, useChinese) -- 457
	local _obj_0 = entry.repo -- 457
	if _obj_0 ~= nil then -- 457
		local _obj_1 = _obj_0.description -- 457
		if _obj_1 ~= nil then -- 457
			return _obj_1[useChinese and "zh" or "en"] -- 457
		end -- 457
		return nil -- 457
	end -- 457
	return nil -- 457
end -- 457
local getMobileFeedEntries -- 442
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 442
	if refresh == nil then -- 442
		refresh = false -- 442
	end -- 442
	if dirtyProjectPath == nil then -- 442
		dirtyProjectPath = nil -- 442
	end -- 442
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 443
		allEntries.dirty[dirtyProjectPath] = true -- 444
		allEntries.hasDirty = true -- 445
	end -- 443
	if refresh then -- 446
		allEntries.dirty = { } -- 447
		allEntries.hasDirty = false -- 448
		updateEntries() -- 449
	else -- 451
		allEntries.refreshDirtyProjects() -- 451
	end -- 446
	local items = { } -- 452
	for _index_0 = 1, #gamesInDev do -- 453
		local entry = gamesInDev[_index_0] -- 453
		items[#items + 1] = { -- 455
			id = entry.entryName, -- 455
			title = getEntryTitle(entry), -- 456
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 457
			fileName = entry.fileName, -- 458
			workDir = Path:getPath(entry.fileName), -- 459
			bannerFile = entry.bannerFile, -- 460
			kind = "local" -- 461
		} -- 454
	end -- 453
	return items -- 463
end -- 442
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 442
local doCompile -- 465
doCompile = function(minify) -- 465
	if building then -- 466
		return -- 466
	end -- 466
	building = true -- 467
	local startTime = App.runningTime -- 468
	local luaFiles = { } -- 469
	local yueFiles = { } -- 470
	local xmlFiles = { } -- 471
	local tlFiles = { } -- 472
	local writablePath = Content.writablePath -- 473
	local buildPaths = { -- 475
		{ -- 476
			Content.assetPath, -- 476
			Path(writablePath, ".build"), -- 477
			"" -- 478
		} -- 475
	} -- 474
	for _index_0 = 1, #gamesInDev do -- 481
		local _des_0 = gamesInDev[_index_0] -- 481
		local fileName = _des_0.fileName -- 481
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 482
		buildPaths[#buildPaths + 1] = { -- 484
			Path(writablePath, gamePath), -- 484
			Path(writablePath, ".build", gamePath), -- 485
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 486
			gamePath -- 487
		} -- 483
	end -- 481
	for _index_0 = 1, #buildPaths do -- 488
		local _des_0 = buildPaths[_index_0] -- 488
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 488
		if not Content:exist(inputPath) then -- 489
			goto _continue_0 -- 489
		end -- 489
		local _list_0 = getAllFiles(inputPath, { -- 491
			"lua" -- 491
		}) -- 491
		for _index_1 = 1, #_list_0 do -- 491
			local file = _list_0[_index_1] -- 491
			luaFiles[#luaFiles + 1] = { -- 493
				file, -- 493
				Path(inputPath, file), -- 494
				Path(outputPath, file), -- 495
				gamePath -- 496
			} -- 492
		end -- 491
		local _list_1 = getAllFiles(inputPath, { -- 498
			yueext -- 498
		}) -- 498
		for _index_1 = 1, #_list_1 do -- 498
			local file = _list_1[_index_1] -- 498
			yueFiles[#yueFiles + 1] = { -- 500
				file, -- 500
				Path(inputPath, file), -- 501
				Path(outputPath, Path:replaceExt(file, "lua")), -- 502
				searchPath, -- 503
				gamePath -- 504
			} -- 499
		end -- 498
		local _list_2 = getAllFiles(inputPath, { -- 506
			"xml" -- 506
		}) -- 506
		for _index_1 = 1, #_list_2 do -- 506
			local file = _list_2[_index_1] -- 506
			xmlFiles[#xmlFiles + 1] = { -- 508
				file, -- 508
				Path(inputPath, file), -- 509
				Path(outputPath, Path:replaceExt(file, "lua")), -- 510
				gamePath -- 511
			} -- 507
		end -- 506
		local _list_3 = getAllFiles(inputPath, { -- 513
			"tl" -- 513
		}) -- 513
		for _index_1 = 1, #_list_3 do -- 513
			local file = _list_3[_index_1] -- 513
			if not file:match(".*%.d%.tl$") then -- 514
				tlFiles[#tlFiles + 1] = { -- 516
					file, -- 516
					Path(inputPath, file), -- 517
					Path(outputPath, Path:replaceExt(file, "lua")), -- 518
					searchPath, -- 519
					gamePath -- 520
				} -- 515
			end -- 514
		end -- 513
		::_continue_0:: -- 489
	end -- 488
	local paths -- 522
	do -- 522
		local _tbl_0 = { } -- 522
		local _list_0 = { -- 523
			luaFiles, -- 523
			yueFiles, -- 523
			xmlFiles, -- 523
			tlFiles -- 523
		} -- 523
		for _index_0 = 1, #_list_0 do -- 523
			local files = _list_0[_index_0] -- 523
			for _index_1 = 1, #files do -- 524
				local file = files[_index_1] -- 524
				_tbl_0[Path:getPath(file[3])] = true -- 522
			end -- 522
		end -- 522
		paths = _tbl_0 -- 522
	end -- 522
	for path in pairs(paths) do -- 526
		Content:mkdir(path) -- 526
	end -- 526
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 528
	local fileCount = 0 -- 529
	local errors = { } -- 530
	for _index_0 = 1, #yueFiles do -- 531
		local _des_0 = yueFiles[_index_0] -- 531
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 531
		local filename -- 532
		if gamePath then -- 532
			filename = Path(gamePath, file) -- 532
		else -- 532
			filename = file -- 532
		end -- 532
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 533
			if not codes then -- 534
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 535
				return -- 536
			end -- 534
			local success, result = LintYueGlobals(codes, globals) -- 537
			local yueCodes -- 538
			if not success then -- 539
				yueCodes = Content:load(input) -- 540
				if yueCodes then -- 540
					local CheckTIC80Code -- 541
					do -- 541
						local _obj_0 = require("Utils") -- 541
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 541
					end -- 541
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 542
					if isTIC80 then -- 543
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 544
					end -- 543
				end -- 540
			end -- 539
			if success then -- 545
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 546
			else -- 548
				if yueCodes then -- 548
					local globalErrors = { } -- 549
					for _index_1 = 1, #result do -- 550
						local _des_1 = result[_index_1] -- 550
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 550
						local countLine = 1 -- 551
						local code = "" -- 552
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 553
							if countLine == line then -- 554
								code = lineCode -- 555
								break -- 556
							end -- 554
							countLine = countLine + 1 -- 557
						end -- 553
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 558
					end -- 550
					if #globalErrors > 0 then -- 559
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 559
					end -- 559
				else -- 561
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 561
				end -- 548
				if #errors == 0 then -- 562
					return codes -- 562
				end -- 562
			end -- 545
		end, function(success) -- 533
			if success then -- 563
				print("Yue compiled: " .. tostring(filename)) -- 563
			end -- 563
			fileCount = fileCount + 1 -- 564
		end) -- 533
	end -- 531
	thread(function() -- 566
		for _index_0 = 1, #xmlFiles do -- 567
			local _des_0 = xmlFiles[_index_0] -- 567
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 567
			local filename -- 568
			if gamePath then -- 568
				filename = Path(gamePath, file) -- 568
			else -- 568
				filename = file -- 568
			end -- 568
			local sourceCodes = Content:loadAsync(input) -- 569
			local codes, err = xml.tolua(sourceCodes) -- 570
			if not codes then -- 571
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 572
			else -- 574
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 574
				print("Xml compiled: " .. tostring(filename)) -- 575
			end -- 571
			fileCount = fileCount + 1 -- 576
		end -- 567
	end) -- 566
	thread(function() -- 578
		for _index_0 = 1, #tlFiles do -- 579
			local _des_0 = tlFiles[_index_0] -- 579
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 579
			local filename -- 580
			if gamePath then -- 580
				filename = Path(gamePath, file) -- 580
			else -- 580
				filename = file -- 580
			end -- 580
			local sourceCodes = Content:loadAsync(input) -- 581
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 582
			if not codes then -- 583
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 584
			else -- 586
				Content:saveAsync(output, codes) -- 586
				print("Teal compiled: " .. tostring(filename)) -- 587
			end -- 583
			fileCount = fileCount + 1 -- 588
		end -- 579
	end) -- 578
	return thread(function() -- 590
		wait(function() -- 591
			return fileCount == totalFiles -- 591
		end) -- 591
		if minify then -- 592
			local _list_0 = { -- 593
				yueFiles, -- 593
				xmlFiles, -- 593
				tlFiles -- 593
			} -- 593
			for _index_0 = 1, #_list_0 do -- 593
				local files = _list_0[_index_0] -- 593
				for _index_1 = 1, #files do -- 593
					local file = files[_index_1] -- 593
					local output = Path:replaceExt(file[3], "lua") -- 594
					luaFiles[#luaFiles + 1] = { -- 596
						Path:replaceExt(file[1], "lua"), -- 596
						output, -- 597
						output -- 598
					} -- 595
				end -- 593
			end -- 593
			local FormatMini -- 600
			do -- 600
				local _obj_0 = require("luaminify") -- 600
				FormatMini = _obj_0.FormatMini -- 600
			end -- 600
			for _index_0 = 1, #luaFiles do -- 601
				local _des_0 = luaFiles[_index_0] -- 601
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 601
				if Content:exist(input) then -- 602
					local sourceCodes = Content:loadAsync(input) -- 603
					local res, err = FormatMini(sourceCodes) -- 604
					if res then -- 605
						Content:saveAsync(output, res) -- 606
						print("Minify: " .. tostring(file)) -- 607
					else -- 609
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 609
					end -- 605
				else -- 611
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 611
				end -- 602
			end -- 601
			package.loaded["luaminify.FormatMini"] = nil -- 612
			package.loaded["luaminify.ParseLua"] = nil -- 613
			package.loaded["luaminify.Scope"] = nil -- 614
			package.loaded["luaminify.Util"] = nil -- 615
		end -- 592
		local errorMessage = table.concat(errors, "\n") -- 616
		if errorMessage ~= "" then -- 617
			print(errorMessage) -- 617
		end -- 617
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 618
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 619
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 620
		Content:clearPathCache() -- 621
		teal.clear() -- 622
		yue.clear() -- 623
		building = false -- 624
	end) -- 590
end -- 465
local doClean -- 626
doClean = function() -- 626
	if building then -- 627
		return -- 627
	end -- 627
	local writablePath = Content.writablePath -- 628
	local targetDir = Path(writablePath, ".build") -- 629
	Content:clearPathCache() -- 630
	if Content:remove(targetDir) then -- 631
		return print("Cleaned: " .. tostring(targetDir)) -- 632
	end -- 631
end -- 626
local screenScale = 2.0 -- 634
local scaleContent = false -- 635
local isInEntry = true -- 636
local currentEntry = nil -- 637
local footerWindow = nil -- 639
local entryWindow = nil -- 640
local testingThread = nil -- 641
local mobileMode = config.mobileFeed -- 642
local pendingUIMode = nil -- 643
local feedHost = nil -- 644
local remixHost = nil -- 645
local startMobileUI = nil -- 646
local webControlled = false -- 647
local mobileHosts = { } -- 648
local suspendedMobileHosts = { } -- 649
local trackMobileHost -- 651
trackMobileHost = function(host) -- 651
	do -- 652
		local _accum_0 = { } -- 652
		local _len_0 = 1 -- 652
		for _index_0 = 1, #mobileHosts do -- 652
			local item = mobileHosts[_index_0] -- 652
			if item.parent then -- 652
				_accum_0[_len_0] = item -- 652
				_len_0 = _len_0 + 1 -- 652
			end -- 652
		end -- 652
		mobileHosts = _accum_0 -- 652
	end -- 652
	mobileHosts[#mobileHosts + 1] = host -- 653
	return host -- 654
end -- 651
local clearMobileUI -- 656
clearMobileUI = function() -- 656
	for _index_0 = 1, #mobileHosts do -- 657
		local host = mobileHosts[_index_0] -- 657
		if host.parent then -- 658
			host:removeFromParent(true) -- 658
		end -- 658
	end -- 657
	mobileHosts = { } -- 659
	suspendedMobileHosts = { } -- 660
	feedHost = nil -- 661
	remixHost = nil -- 662
end -- 656
local syncWebIDEControl -- 664
syncWebIDEControl = function() -- 664
	local connected = HttpServer.wsConnectionCount > 0 -- 665
	if connected then -- 666
		pendingUIMode = nil -- 667
		for _index_0 = 1, #mobileHosts do -- 668
			local host = mobileHosts[_index_0] -- 668
			if not host.parent then -- 669
				goto _continue_0 -- 669
			end -- 669
			if not (suspendedMobileHosts[host] ~= nil) then -- 670
				suspendedMobileHosts[host] = host.visible -- 671
				host:emit("SuspendLocalUI") -- 672
			end -- 670
			host.visible = false -- 673
			::_continue_0:: -- 669
		end -- 668
	elseif webControlled then -- 674
		for host, visible in pairs(suspendedMobileHosts) do -- 675
			if host.parent then -- 676
				host.visible = visible -- 677
				host:emit("ResumeLocalUI") -- 678
			end -- 676
		end -- 675
		suspendedMobileHosts = { } -- 679
	end -- 666
	webControlled = connected -- 680
	return connected -- 681
end -- 664
local getUIMode -- 683
getUIMode = function() -- 683
	return mobileMode and "mobile" or "traditional" -- 683
end -- 683
_module_0["getUIMode"] = getUIMode -- 683
local setUIMode -- 684
setUIMode = function(mode) -- 684
	if not (("mobile" == mode or "traditional" == mode)) then -- 685
		return false -- 685
	end -- 685
	if HttpServer.wsConnectionCount > 0 then -- 686
		return false -- 686
	end -- 686
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 687
		return false -- 687
	end -- 687
	local wantsMobile = mode == "mobile" -- 688
	if wantsMobile == mobileMode then -- 689
		return true -- 689
	end -- 689
	if mobileMode then -- 690
		if not (feedHost and feedHost.visible) then -- 691
			return false -- 691
		end -- 691
		feedHost:emit("SwitchUIMode") -- 693
		return pendingUIMode == false -- 694
	end -- 690
	pendingUIMode = true -- 695
	return true -- 696
end -- 684
_module_0["setUIMode"] = setUIMode -- 684
local applyUIMode -- 698
applyUIMode = function(enabled) -- 698
	if HttpServer.wsConnectionCount > 0 then -- 700
		return false -- 700
	end -- 700
	if enabled then -- 701
		local ok, err = pcall(startMobileUI) -- 702
		if not ok then -- 703
			if feedHost then -- 704
				feedHost:removeFromParent(true) -- 704
			end -- 704
			feedHost = nil -- 705
			mobileMode = false -- 706
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 707
			return false -- 708
		end -- 703
	else -- 710
		clearMobileUI() -- 710
		updateEntries() -- 711
	end -- 701
	mobileMode = enabled -- 712
	config.mobileFeed = enabled -- 713
	return true -- 714
end -- 698
local setupEventHandlers = nil -- 716
local allClear -- 718
allClear = function() -- 718
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 720
		clearMobileUI() -- 720
	end -- 720
	local systemNodes = { } -- 723
	local preserveSystemNode -- 724
	preserveSystemNode = function(node) -- 724
		if systemNodes[node] then -- 725
			return -- 725
		end -- 725
		systemNodes[node] = true -- 726
		do -- 727
			local clip = tolua.cast(node, "ClipNode") -- 727
			if clip then -- 727
				if clip.stencil then -- 728
					preserveSystemNode(clip.stencil) -- 728
				end -- 728
			end -- 727
		end -- 727
		return node:eachChild(function(child) -- 729
			preserveSystemNode(child) -- 730
			return false -- 731
		end) -- 729
	end -- 724
	for _index_0 = 1, #Routine do -- 732
		local routine = Routine[_index_0] -- 732
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 734
			goto _continue_0 -- 735
		else -- 737
			Routine:remove(routine) -- 737
		end -- 733
		::_continue_0:: -- 733
	end -- 732
	for _index_0 = 1, #moduleCache do -- 738
		local module = moduleCache[_index_0] -- 738
		package.loaded[module] = nil -- 739
	end -- 738
	moduleCache = { } -- 740
	Director:cleanup() -- 741
	Entity:clear() -- 742
	Platformer.Data:clear() -- 743
	Platformer.UnitAction:clear() -- 744
	Audio:stopAll(0.2) -- 745
	Struct:clear() -- 746
	View.nearPlaneDistance = 0.1 -- 749
	View.farPlaneDistance = 10000 -- 750
	View.fieldOfView = 45 -- 751
	View.postEffect = nil -- 752
	View.scale = scaleContent and screenScale or 1 -- 753
	Director.clearColor = Color(0xff1a1a1a) -- 754
	teal.clear() -- 755
	yue.clear() -- 756
	preserveSystemNode(Director.systemUI) -- 759
	for _, item in pairs(ubox()) do -- 760
		local node = tolua.cast(item, "Node") -- 761
		if node then -- 761
			if not systemNodes[node] then -- 762
				node:cleanup() -- 762
			end -- 762
		end -- 761
	end -- 760
	collectgarbage() -- 763
	collectgarbage() -- 764
	Wasm:clear() -- 765
	thread(function() -- 766
		sleep() -- 767
		return Cache:removeUnused() -- 768
	end) -- 766
	setupEventHandlers() -- 769
	Content.searchPaths = searchPaths -- 770
	App.idled = true -- 771
end -- 718
_module_0["allClear"] = allClear -- 718
local clearTempFiles -- 773
clearTempFiles = function() -- 773
	local writablePath = Content.writablePath -- 774
	if Content:exist(Path(writablePath, ".upload")) then -- 775
		Content:remove(Path(writablePath, ".upload")) -- 775
	end -- 775
	if Content:exist(Path(writablePath, ".download")) then -- 776
		return Content:remove(Path(writablePath, ".download")) -- 776
	end -- 776
end -- 773
local waitForWebStart = true -- 778
thread(function() -- 779
	sleep(2) -- 780
	waitForWebStart = false -- 781
end) -- 779
local reloadDevEntry -- 783
reloadDevEntry = function() -- 783
	return thread(function() -- 783
		waitForWebStart = true -- 784
		doClean() -- 785
		allClear() -- 786
		_G.require = oldRequire -- 787
		Dora.require = oldRequire -- 788
		package.loaded["Script.Dev.Entry"] = nil -- 789
		package.loaded["Script.Dev.WebServer"] = nil -- 790
		return Director.systemScheduler:schedule(function() -- 791
			Routine:clear() -- 792
			oldRequire("Script.Dev.Entry") -- 793
			return true -- 794
		end) -- 791
	end) -- 783
end -- 783
local setWorkspace -- 796
setWorkspace = function(path) -- 796
	clearTempFiles() -- 797
	Content.writablePath = path -- 798
	config.writablePath = Content.writablePath -- 799
	return thread(function() -- 800
		sleep() -- 801
		return reloadDevEntry() -- 802
	end) -- 800
end -- 796
_module_0["setWorkspace"] = setWorkspace -- 796
local quit = false -- 804
local activeSearchId = 0 -- 806
local handleSearchFiles -- 808
handleSearchFiles = function(payload) -- 808
	if not payload then -- 809
		return -- 809
	end -- 809
	local id = payload.id -- 810
	if id == nil then -- 811
		return -- 811
	end -- 811
	activeSearchId = id -- 812
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 813
	if path == nil then -- 814
		path = "" -- 814
	end -- 814
	if exts == nil then -- 815
		exts = { } -- 815
	end -- 815
	if globs == nil then -- 816
		globs = { } -- 816
	end -- 816
	if extensionLevels == nil then -- 817
		extensionLevels = { } -- 817
	end -- 817
	if pattern == nil then -- 818
		pattern = "" -- 818
	end -- 818
	if pattern == "" then -- 820
		return -- 820
	end -- 820
	local useRegex = payload.useRegex == true -- 821
	local caseSensitive = payload.caseSensitive == true -- 822
	local includeContent = payload.includeContent ~= false -- 823
	local contentWindow = payload.contentWindow or 0 -- 824
	return Director.systemScheduler:schedule(once(function() -- 825
		local stopped = false -- 826
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 827
			if activeSearchId ~= id then -- 828
				stopped = true -- 829
				return true -- 830
			end -- 828
			emit("AppWS", "Send", json.encode({ -- 832
				name = "SearchFilesResult", -- 832
				id = id, -- 832
				result = result -- 832
			})) -- 831
			return false -- 834
		end) -- 827
		return emit("AppWS", "Send", json.encode({ -- 836
			name = "SearchFilesDone", -- 836
			id = id, -- 836
			stopped = stopped -- 836
		})) -- 835
	end)) -- 825
end -- 808
local stop -- 839
stop = function() -- 839
	if isInEntry then -- 840
		return false -- 840
	end -- 840
	allClear() -- 841
	isInEntry = true -- 842
	currentEntry = nil -- 843
	return true -- 844
end -- 839
_module_0["stop"] = stop -- 839
local getCurrentEntryStatus -- 846
getCurrentEntryStatus = function() -- 846
	local entry = currentEntry -- 847
	if not (entry and not isInEntry) then -- 848
		return { -- 848
			success = true, -- 848
			running = false, -- 848
			runId = allEntries.runId -- 848
		} -- 848
	end -- 848
	local status = { -- 850
		success = true, -- 850
		running = true, -- 851
		kind = entry.runKind or "file", -- 852
		runId = allEntries.runId, -- 853
		entryName = entry.entryName, -- 854
		fileName = entry.fileName -- 855
	} -- 849
	if entry.workDir then -- 856
		status.workDir = entry.workDir -- 856
	end -- 856
	if entry.projectRoot then -- 857
		status.projectRoot = entry.projectRoot -- 857
	end -- 857
	return status -- 858
end -- 846
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 846
local _anon_func_2 = function(_with_0) -- 877
	local _val_0 = App.platform -- 877
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 877
end -- 877
setupEventHandlers = function() -- 860
	local _with_0 = Director.postNode -- 861
	_with_0:onAppEvent(function(eventType) -- 862
		if "Quit" == eventType then -- 863
			quit = true -- 864
			allClear() -- 865
			return clearTempFiles() -- 866
		elseif "Shutdown" == eventType then -- 867
			return stop() -- 868
		end -- 862
	end) -- 862
	_with_0:onAppChange(function(settingName) -- 869
		if "Theme" == settingName then -- 870
			config.themeColor = App.themeColor:toARGB() -- 871
		elseif "Locale" == settingName then -- 872
			config.locale = App.locale -- 873
			updateLocale() -- 874
			return teal.clear(true) -- 875
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 876
			if _anon_func_2(_with_0) then -- 877
				if "FullScreen" == settingName then -- 879
					config.fullScreen = App.fullScreen -- 879
				elseif "Position" == settingName then -- 880
					local _obj_0 = App.winPosition -- 880
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 880
				elseif "Size" == settingName then -- 881
					local width, height -- 882
					do -- 882
						local _obj_0 = App.winSize -- 882
						width, height = _obj_0.width, _obj_0.height -- 882
					end -- 882
					config.winWidth = width -- 883
					config.winHeight = height -- 884
				end -- 878
			end -- 877
		end -- 869
	end) -- 869
	_with_0:onAppWS(function(event) -- 885
		if event.type == "Close" then -- 886
			if HttpServer.wsConnectionCount == 0 then -- 887
				updateEntries() -- 888
			end -- 887
			return -- 889
		end -- 886
		if not (event.type == "Receive") then -- 890
			return -- 890
		end -- 890
		local data = json.decode(event.msg) -- 891
		if not data then -- 892
			return -- 892
		end -- 892
		local _exp_0 = data.name -- 893
		if "SearchFiles" == _exp_0 then -- 894
			return handleSearchFiles(data) -- 895
		elseif "SearchFilesStop" == _exp_0 then -- 896
			if data.id == nil or data.id == activeSearchId then -- 897
				activeSearchId = 0 -- 898
			end -- 897
		end -- 893
	end) -- 885
	_with_0:slot("UpdateEntries", function() -- 899
		return updateEntries() -- 899
	end) -- 899
	return _with_0 -- 861
end -- 860
setupEventHandlers() -- 901
clearTempFiles() -- 902
local downloadFile -- 904
downloadFile = function(url, target) -- 904
	return Director.systemScheduler:schedule(once(function() -- 904
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 905
			if quit then -- 906
				return true -- 906
			end -- 906
			emit("AppWS", "Send", json.encode({ -- 908
				name = "Download", -- 908
				url = url, -- 908
				status = "downloading", -- 908
				progress = current / total -- 909
			})) -- 907
			return false -- 905
		end) -- 905
		return emit("AppWS", "Send", json.encode(success and { -- 912
			name = "Download", -- 912
			url = url, -- 912
			status = "completed", -- 912
			progress = 1.0 -- 913
		} or { -- 915
			name = "Download", -- 915
			url = url, -- 915
			status = "failed", -- 915
			progress = 0.0 -- 916
		})) -- 911
	end)) -- 904
end -- 904
_module_0["downloadFile"] = downloadFile -- 904
local _anon_func_3 = function(file, require, workDir) -- 928
	if workDir == nil then -- 928
		workDir = Path:getPath(file) -- 928
	end -- 928
	Content:insertSearchPath(1, workDir) -- 929
	local scriptPath = Path(workDir, "Script") -- 930
	if Content:exist(scriptPath) then -- 931
		Content:insertSearchPath(1, scriptPath) -- 932
	end -- 931
	local result = require(file) -- 933
	if "function" == type(result) then -- 934
		result() -- 934
	end -- 934
	return nil -- 935
end -- 928
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 964
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 964
	label.alignment = "Left" -- 965
	label.textWidth = width - fontSize -- 966
	label.text = err -- 967
	return label -- 964
end -- 964
local enterEntryAsync -- 919
enterEntryAsync = function(entry) -- 919
	allEntries.runId = allEntries.runId + 1 -- 920
	isInEntry = false -- 921
	App.idled = false -- 922
	emit(Profiler.EventName, "ClearLoader") -- 923
	currentEntry = entry -- 924
	local file, workDir = entry.fileName, entry.workDir -- 925
	sleep() -- 926
	return xpcall(_anon_func_3, function(msg) -- 935
		local err = debug.traceback(msg) -- 937
		Log("Error", err) -- 938
		allClear() -- 939
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 940
		local viewWidth, viewHeight -- 941
		do -- 941
			local _obj_0 = View.size -- 941
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 941
		end -- 941
		local width, height = viewWidth - 20, viewHeight - 20 -- 942
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 943
		Director.ui:addChild((function() -- 944
			local root = AlignNode() -- 944
			do -- 945
				local _obj_0 = App.bufferSize -- 945
				width, height = _obj_0.width, _obj_0.height -- 945
			end -- 945
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 946
			root:onAppChange(function(settingName) -- 947
				if settingName == "Size" then -- 947
					do -- 948
						local _obj_0 = App.bufferSize -- 948
						width, height = _obj_0.width, _obj_0.height -- 948
					end -- 948
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 949
				end -- 947
			end) -- 947
			root:addChild((function() -- 950
				local _with_0 = ScrollArea({ -- 951
					width = width, -- 951
					height = height, -- 952
					paddingX = 0, -- 953
					paddingY = 50, -- 954
					viewWidth = height, -- 955
					viewHeight = height -- 956
				}) -- 950
				root:onAlignLayout(function(w, h) -- 958
					_with_0.position = Vec2(w / 2, h / 2) -- 959
					w = w - 20 -- 960
					h = h - 20 -- 961
					_with_0.view.children.first.textWidth = w - fontSize -- 962
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 963
				end) -- 958
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 964
				return _with_0 -- 950
			end)()) -- 950
			return root -- 944
		end)()) -- 944
		return err -- 968
	end, file, require, workDir) -- 927
end -- 919
_module_0["enterEntryAsync"] = enterEntryAsync -- 919
local enterDemoEntry -- 970
enterDemoEntry = function(entry) -- 970
	return thread(function() -- 970
		return enterEntryAsync(entry) -- 970
	end) -- 970
end -- 970
local reloadCurrentEntry -- 972
reloadCurrentEntry = function() -- 972
	if currentEntry then -- 973
		allClear() -- 974
		return enterDemoEntry(currentEntry) -- 975
	end -- 973
end -- 972
Director.clearColor = Color(0xff1a1a1a) -- 977
local descColor = Color(0xffa1a1a1) -- 978
local extraOperations -- 980
do -- 980
	local isOSSLicenseExist = Content:exist("LICENSES") -- 981
	local ossLicenses = nil -- 982
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 983
	local failedSetFolder = false -- 984
	local statusFlags = { -- 985
		"NoResize", -- 985
		"NoMove", -- 985
		"NoCollapse", -- 985
		"AlwaysAutoResize", -- 985
		"NoSavedSettings" -- 985
	} -- 985
	extraOperations = function() -- 992
		local zh = useChinese -- 993
		if isDesktop then -- 994
			local alwaysOnTop = config.alwaysOnTop -- 995
			do -- 996
				local changed -- 996
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 996
				if changed then -- 996
					App.alwaysOnTop = alwaysOnTop -- 997
					config.alwaysOnTop = alwaysOnTop -- 998
				end -- 996
			end -- 996
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 999
			do -- 1000
				local changed -- 1000
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1000
				if changed then -- 1000
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1001
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1002
				end -- 1000
			end -- 1000
			SameLine() -- 1003
			TextColored(descColor, "(?)") -- 1004
			if IsItemHovered() then -- 1005
				BeginTooltip(function() -- 1006
					return PushTextWrapPos(360, function() -- 1007
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1008
					end) -- 1007
				end) -- 1006
			end -- 1005
		end -- 994
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1023
		do -- 1028
			local changed -- 1028
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1028
			if changed then -- 1028
				config.showPreview = showPreview -- 1029
				updateEntries() -- 1030
				if not showPreview then -- 1031
					thread(function() -- 1032
						collectgarbage() -- 1033
						return Cache:removeUnused("Texture") -- 1034
					end) -- 1032
				end -- 1031
			end -- 1028
		end -- 1028
		do -- 1035
			local changed -- 1035
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1035
			if changed then -- 1035
				config.authRequired = authRequired -- 1036
				HttpServer.authRequired = authRequired -- 1037
			end -- 1035
		end -- 1035
		SameLine() -- 1038
		TextColored(descColor, "(?)") -- 1039
		if IsItemHovered() then -- 1040
			BeginTooltip(function() -- 1041
				return PushTextWrapPos(280, function() -- 1042
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1043
				end) -- 1042
			end) -- 1041
		end -- 1040
		do -- 1044
			local themeColor = App.themeColor -- 1045
			local writablePath = config.writablePath -- 1046
			SeparatorText(zh and "工作目录" or "Workspace") -- 1047
			PushTextWrapPos(400, function() -- 1048
				return TextColored(themeColor, writablePath) -- 1049
			end) -- 1048
			if not isDesktop then -- 1050
				goto skipSetting -- 1050
			end -- 1050
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1051
			if Button(zh and "改变目录" or "Set Folder") then -- 1052
				App:openFileDialog(true, function(path) -- 1053
					if path == "" then -- 1054
						return -- 1054
					end -- 1054
					local relPath = Path:getRelative(Content.assetPath, path) -- 1055
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1056
						return setWorkspace(path) -- 1057
					else -- 1059
						failedSetFolder = true -- 1059
					end -- 1056
				end) -- 1053
			end -- 1052
			if failedSetFolder then -- 1060
				failedSetFolder = false -- 1061
				OpenPopup(popupName) -- 1062
			end -- 1060
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1063
			BeginPopupModal(popupName, statusFlags, function() -- 1064
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1065
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1066
					return CloseCurrentPopup() -- 1067
				end -- 1066
			end) -- 1064
			SameLine() -- 1068
			if Button(zh and "使用默认" or "Use Default") then -- 1069
				setWorkspace(Content.appPath) -- 1070
			end -- 1069
			Separator() -- 1071
			::skipSetting:: -- 1072
		end -- 1044
		if isOSSLicenseExist then -- 1073
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1074
				if not ossLicenses then -- 1075
					local licenseText = Content:load("LICENSES") -- 1076
					if licenseText then -- 1076
						ossLicenses = { } -- 1077
						licenseText = licenseText:gsub("\r\n", "\n") -- 1078
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1079
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1080
							if name then -- 1080
								ossLicenses[#ossLicenses + 1] = { -- 1081
									name, -- 1081
									text -- 1081
								} -- 1081
							end -- 1080
						end -- 1079
					end -- 1076
				end -- 1075
				if ossLicenses then -- 1082
					OpenPopup(ossLicensePopup) -- 1082
				end -- 1082
			end -- 1074
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1083
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1084
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1085
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1086
				return BeginPopupModal(ossLicensePopup, true, { -- 1089
					"NoSavedSettings" -- 1089
				}, function() -- 1090
					for _index_0 = 1, #ossLicenses do -- 1091
						local _des_0 = ossLicenses[_index_0] -- 1091
						local firstLine, text = _des_0[1], _des_0[2] -- 1091
						local name, license = firstLine:match("(.+): (.+)") -- 1093
						if name then -- 1093
							TextColored(themeColor, name) -- 1094
							SameLine() -- 1095
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1096
								return TextWrapped(text) -- 1096
							end) -- 1096
						end -- 1093
					end -- 1091
				end) -- 1086
			end) -- 1086
		end -- 1073
		if not App.debugging then -- 1099
			return -- 1099
		end -- 1099
		return TreeNode(zh and "开发操作" or "Development", function() -- 1100
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1101
				OpenPopup("build") -- 1101
			end -- 1101
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1102
				return BeginPopup("build", function() -- 1102
					if Selectable(zh and "编译" or "Compile") then -- 1103
						doCompile(false) -- 1103
					end -- 1103
					Separator() -- 1104
					if Selectable(zh and "压缩" or "Minify") then -- 1105
						doCompile(true) -- 1105
					end -- 1105
					Separator() -- 1106
					if Selectable(zh and "清理" or "Clean") then -- 1107
						return doClean() -- 1107
					end -- 1107
				end) -- 1102
			end) -- 1102
			if isInEntry then -- 1108
				if waitForWebStart then -- 1109
					BeginDisabled(function() -- 1110
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1110
					end) -- 1110
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1111
					reloadDevEntry() -- 1112
				end -- 1109
			end -- 1108
			do -- 1113
				local changed -- 1113
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1113
				if changed then -- 1113
					View.scale = scaleContent and screenScale or 1 -- 1114
				end -- 1113
			end -- 1113
			do -- 1115
				local changed -- 1115
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1115
				if changed then -- 1115
					config.engineDev = engineDev -- 1116
				end -- 1115
			end -- 1115
			do -- 1117
				local changed -- 1117
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1117
				if changed then -- 1117
					config.webIDETourCompleted = webIDETourCompleted -- 1118
				end -- 1117
			end -- 1117
			if testingThread then -- 1119
				return BeginDisabled(function() -- 1120
					return Button(zh and "开始自动测试" or "Test automatically") -- 1120
				end) -- 1120
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1121
				testingThread = thread(function() -- 1122
					local _ <close> = setmetatable({ }, { -- 1123
						__close = function() -- 1123
							allClear() -- 1124
							testingThread = nil -- 1125
							isInEntry = true -- 1126
							currentEntry = nil -- 1127
							return print("Testing done!") -- 1128
						end -- 1123
					}) -- 1123
					for _, entry in ipairs(allEntries) do -- 1129
						allClear() -- 1130
						print("Start " .. tostring(entry.entryName)) -- 1131
						enterDemoEntry(entry) -- 1132
						sleep(2) -- 1133
						print("Stop " .. tostring(entry.entryName)) -- 1134
					end -- 1129
				end) -- 1122
			end -- 1119
		end) -- 1100
	end -- 992
end -- 980
local icon = Path("Script", "Dev", "icon_s.png") -- 1136
local iconTex = nil -- 1137
thread(function() -- 1138
	if Cache:loadAsync(icon) then -- 1138
		iconTex = Texture2D(icon) -- 1138
	end -- 1138
end) -- 1138
local webStatus = nil -- 1140
local urlClicked = nil -- 1141
local authCode = string.format("%06d", math.random(0, 999999)) -- 1143
local authCodeTTL = 30.0 -- 1145
_module_0.getAuthCode = function() -- 1146
	return authCode -- 1146
end -- 1146
_module_0.invalidateAuthCode = function() -- 1147
	authCode = string.format("%06d", math.random(0, 999999)) -- 1148
	authCodeTTL = 30.0 -- 1149
end -- 1147
local AuthSession -- 1151
do -- 1151
	local pending = nil -- 1152
	local session = nil -- 1153
	AuthSession = { -- 1155
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1155
			pending = { -- 1157
				sessionId = sessionId, -- 1157
				confirmCode = confirmCode, -- 1158
				expiresAt = expiresAt, -- 1159
				ttl = ttl, -- 1160
				approved = false -- 1161
			} -- 1156
		end, -- 1155
		getPending = function() -- 1163
			return pending -- 1163
		end, -- 1163
		approvePending = function(sessionId) -- 1165
			if pending and pending.sessionId == sessionId then -- 1166
				pending.approved = true -- 1167
				return true -- 1168
			end -- 1166
			return false -- 1169
		end, -- 1165
		clearPending = function() -- 1171
			pending = nil -- 1171
		end, -- 1171
		setSession = function(sessionId, sessionSecret) -- 1173
			session = { -- 1175
				sessionId = sessionId, -- 1175
				sessionSecret = sessionSecret -- 1176
			} -- 1174
		end, -- 1173
		getSession = function() -- 1178
			return session -- 1178
		end -- 1178
	} -- 1154
end -- 1151
_module_0["AuthSession"] = AuthSession -- 1151
local transparant = Color(0x0) -- 1181
local windowFlags = { -- 1182
	"NoTitleBar", -- 1182
	"NoResize", -- 1182
	"NoMove", -- 1182
	"NoCollapse", -- 1182
	"NoSavedSettings", -- 1182
	"NoFocusOnAppearing", -- 1182
	"NoBringToFrontOnFocus" -- 1182
} -- 1182
local statusFlags = { -- 1191
	"NoTitleBar", -- 1191
	"NoResize", -- 1191
	"NoMove", -- 1191
	"NoCollapse", -- 1191
	"AlwaysAutoResize", -- 1191
	"NoSavedSettings" -- 1191
} -- 1191
local displayWindowFlags = { -- 1199
	"NoDecoration", -- 1199
	"NoSavedSettings", -- 1199
	"NoMove", -- 1199
	"NoScrollWithMouse", -- 1199
	"AlwaysAutoResize", -- 1199
	"NoFocusOnAppearing" -- 1199
} -- 1199
local gamepadInputWindowFlags = { -- 1207
	"NoDecoration", -- 1207
	"NoSavedSettings", -- 1207
	"NoMove", -- 1207
	"NoScrollbar", -- 1207
	"NoScrollWithMouse", -- 1207
	"NoFocusOnAppearing", -- 1207
	"NoBringToFrontOnFocus" -- 1207
} -- 1207
local initFooter = true -- 1216
local gamepadInputFocused = false -- 1217
local _anon_func_5 = function(allEntries, currentIndex) -- 1263
	if currentIndex > 1 then -- 1263
		return allEntries[currentIndex - 1] -- 1264
	else -- 1266
		return allEntries[#allEntries] -- 1266
	end -- 1263
end -- 1263
local _anon_func_6 = function(allEntries, currentIndex) -- 1270
	if currentIndex < #allEntries then -- 1270
		return allEntries[currentIndex + 1] -- 1271
	else -- 1273
		return allEntries[1] -- 1273
	end -- 1270
end -- 1270
footerWindow = threadLoop(function() -- 1218
	if mobileMode then -- 1219
		return -- 1219
	end -- 1219
	local zh = useChinese -- 1220
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1221
	if authCodeTTL <= 0 then -- 1222
		authCodeTTL = 30.0 -- 1223
		authCode = string.format("%06d", math.random(0, 999999)) -- 1224
	end -- 1222
	if HttpServer.wsConnectionCount > 0 then -- 1225
		return -- 1226
	end -- 1225
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1227
		if App.platform == "Emscripten" then -- 1228
			stop() -- 1230
		else -- 1232
			allClear() -- 1232
			App.devMode = false -- 1233
			App:shutdown() -- 1234
		end -- 1228
	end -- 1227
	do -- 1235
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1236
		if ctrl and Keyboard:isKeyDown("Q") then -- 1237
			stop() -- 1238
		end -- 1237
		if ctrl and Keyboard:isKeyDown("Z") then -- 1239
			reloadCurrentEntry() -- 1240
		end -- 1239
		if ctrl and Keyboard:isKeyDown(",") then -- 1241
			if showFooter then -- 1242
				showStats = not showStats -- 1242
			else -- 1242
				showStats = true -- 1242
			end -- 1242
			showFooter = true -- 1243
			config.showFooter = showFooter -- 1244
			config.showStats = showStats -- 1245
		end -- 1241
		if ctrl and Keyboard:isKeyDown(".") then -- 1246
			if showFooter then -- 1247
				showConsole = not showConsole -- 1247
			else -- 1247
				showConsole = true -- 1247
			end -- 1247
			showFooter = true -- 1248
			config.showFooter = showFooter -- 1249
			config.showConsole = showConsole -- 1250
		end -- 1246
		if ctrl and Keyboard:isKeyDown("/") then -- 1251
			showFooter = not showFooter -- 1252
			config.showFooter = showFooter -- 1253
		end -- 1251
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1254
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1255
		local currentIndex = nil -- 1256
		for i, entry in ipairs(allEntries) do -- 1257
			if currentEntry == entry then -- 1258
				currentIndex = i -- 1259
			end -- 1258
		end -- 1257
		if left then -- 1260
			allClear() -- 1261
			if currentIndex == nil then -- 1262
				currentIndex = #allEntries + 1 -- 1262
			end -- 1262
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1263
		end -- 1260
		if right then -- 1267
			allClear() -- 1268
			if currentIndex == nil then -- 1269
				currentIndex = 0 -- 1269
			end -- 1269
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1270
		end -- 1267
	end -- 1235
	if not showEntry then -- 1274
		return -- 1274
	end -- 1274
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1276
		reloadDevEntry() -- 1280
	end -- 1276
	if initFooter then -- 1281
		initFooter = false -- 1282
	end -- 1281
	local width, height -- 1284
	do -- 1284
		local _obj_0 = App.visualSize -- 1284
		width, height = _obj_0.width, _obj_0.height -- 1284
	end -- 1284
	if isInEntry then -- 1285
		gamepadInputFocused = false -- 1286
	else -- 1288
		SetNextWindowBgAlpha(0.0) -- 1288
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1289
		SetNextWindowPos(Vec2.zero, "Always") -- 1290
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1291
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1292
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1293
					if not gamepadInputFocused then -- 1294
						SetWindowFocus("DoraGamepadInput") -- 1295
						gamepadInputFocused = true -- 1296
					end -- 1294
				end) -- 1293
			end) -- 1292
		end) -- 1291
	end -- 1285
	if isInEntry or showFooter then -- 1298
		SetNextWindowSize(Vec2(width, 50)) -- 1299
		SetNextWindowPos(Vec2(0, height - 50)) -- 1300
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1301
			return PushStyleVar("WindowRounding", 0, function() -- 1302
				return Begin("Footer", windowFlags, function() -- 1303
					Separator() -- 1304
					if iconTex then -- 1305
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1306
							showStats = not showStats -- 1307
							config.showStats = showStats -- 1308
						end -- 1306
						SameLine() -- 1309
						if Button(">_", Vec2(30, 30)) then -- 1310
							showConsole = not showConsole -- 1311
							config.showConsole = showConsole -- 1312
						end -- 1310
					end -- 1305
					if isInEntry and config.updateNotification then -- 1313
						SameLine() -- 1314
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1315
							allClear() -- 1316
							config.updateNotification = false -- 1317
							enterDemoEntry({ -- 1319
								entryName = "SelfUpdater", -- 1319
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1320
							}) -- 1318
						end -- 1315
					end -- 1313
					if not isInEntry then -- 1321
						SameLine() -- 1322
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1323
						local currentIndex = nil -- 1324
						for i, entry in ipairs(allEntries) do -- 1325
							if currentEntry == entry then -- 1326
								currentIndex = i -- 1327
							end -- 1326
						end -- 1325
						if currentIndex then -- 1328
							if currentIndex > 1 then -- 1329
								SameLine() -- 1330
								if Button("<<", Vec2(30, 30)) then -- 1331
									allClear() -- 1332
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1333
								end -- 1331
							end -- 1329
							if currentIndex < #allEntries then -- 1334
								SameLine() -- 1335
								if Button(">>", Vec2(30, 30)) then -- 1336
									allClear() -- 1337
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1338
								end -- 1336
							end -- 1334
						end -- 1328
						SameLine() -- 1339
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1340
							reloadCurrentEntry() -- 1341
						end -- 1340
						if back then -- 1342
							allClear() -- 1343
							isInEntry = true -- 1344
							currentEntry = nil -- 1345
						end -- 1342
					end -- 1321
				end) -- 1303
			end) -- 1302
		end) -- 1301
	end -- 1298
	if isInEntry then -- 1347
		local showURL = true -- 1348
		local webIDEWidth -- 1349
		do -- 1349
			local base -- 1350
			if config.updateNotification then -- 1350
				base = 460 -- 1350
			else -- 1350
				base = 360 -- 1350
			end -- 1350
			local extra -- 1351
			if config.authRequired then -- 1351
				extra = 35 -- 1351
			else -- 1351
				extra = 0 -- 1351
			end -- 1351
			webIDEWidth = base + extra -- 1352
		end -- 1349
		if width < webIDEWidth then -- 1353
			showURL = false -- 1353
		end -- 1353
		SetNextWindowBgAlpha(0.0) -- 1354
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1355
		Begin("Web IDE", displayWindowFlags, function() -- 1356
			local pending = AuthSession.getPending() -- 1357
			local hovered = false -- 1358
			if not pending and showURL then -- 1359
				do -- 1360
					local url -- 1360
					if webStatus ~= nil then -- 1360
						url = webStatus.url -- 1360
					end -- 1360
					if url then -- 1360
						if isDesktop and not config.fullScreen then -- 1361
							if urlClicked then -- 1362
								BeginDisabled(function() -- 1363
									return Button(url) -- 1363
								end) -- 1363
							elseif Button(url) then -- 1364
								urlClicked = once(function() -- 1365
									return sleep(5) -- 1365
								end) -- 1365
								App:openURL("http://localhost:8866") -- 1366
							end -- 1362
						else -- 1368
							TextColored(descColor, url) -- 1368
						end -- 1361
					else -- 1370
						TextColored(descColor, zh and '不可用' or 'not available') -- 1370
					end -- 1360
				end -- 1360
				hovered = IsItemHovered() -- 1371
			else -- 1373
				TextColored(descColor, "(?)") -- 1373
				hovered = IsItemHovered() -- 1374
			end -- 1359
			SameLine() -- 1375
			local themeColor = App.themeColor -- 1376
			if pending then -- 1377
				if not pending.approved then -- 1378
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1379
					local ttl = pending.ttl or 1 -- 1380
					PushStyleColor("Text", themeColor, function() -- 1381
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1382
						hovered = hovered or IsItemHovered() -- 1383
					end) -- 1381
					SameLine() -- 1384
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1385
						AuthSession.approvePending(pending.sessionId) -- 1386
					end -- 1385
					if hovered then -- 1387
						return BeginTooltip(function() -- 1388
							return PushTextWrapPos(280, function() -- 1389
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1390
							end) -- 1389
						end) -- 1388
					end -- 1387
				end -- 1378
			else -- 1392
				if config.authRequired then -- 1392
					PushStyleColor("Text", themeColor, function() -- 1393
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1394
						hovered = hovered or IsItemHovered() -- 1395
					end) -- 1393
					if hovered then -- 1396
						return BeginTooltip(function() -- 1397
							return PushTextWrapPos(280, function() -- 1398
								local url -- 1399
								if webStatus ~= nil then -- 1399
									url = webStatus.url -- 1399
								end -- 1399
								if url then -- 1399
									local address -- 1400
									if showURL then -- 1400
										address = "Web IDE" -- 1400
									else -- 1400
										address = url -- 1400
									end -- 1400
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1401
								else -- 1403
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1403
								end -- 1399
							end) -- 1398
						end) -- 1397
					end -- 1396
				else -- 1405
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
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1410
								else -- 1412
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1412
								end -- 1408
							end) -- 1407
						end) -- 1406
					end -- 1405
				end -- 1392
			end -- 1377
		end) -- 1356
	end -- 1347
	if not isInEntry then -- 1414
		SetNextWindowSize(Vec2(50, 50)) -- 1415
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1416
		PushStyleColor("WindowBg", transparant, function() -- 1417
			return Begin("Show", displayWindowFlags, function() -- 1417
				if width >= 370 then -- 1418
					local changed -- 1419
					changed, showFooter = Checkbox("##dev", showFooter) -- 1419
					if changed then -- 1419
						config.showFooter = showFooter -- 1420
					end -- 1419
				end -- 1418
			end) -- 1417
		end) -- 1417
	end -- 1414
	if isInEntry or showFooter then -- 1422
		if showStats then -- 1423
			PushStyleVar("WindowRounding", 0, function() -- 1424
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1425
				SetNextWindowSize(Vec2(0, height - 50)) -- 1426
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1427
				config.showStats = showStats -- 1428
			end) -- 1424
		end -- 1423
		if showConsole then -- 1429
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1430
			return PushStyleVar("WindowRounding", 6, function() -- 1431
				return ShowConsole() -- 1432
			end) -- 1431
		end -- 1429
	end -- 1422
end) -- 1218
local MaxWidth <const> = 960 -- 1434
local toolOpen = false -- 1436
local filterText = nil -- 1437
allEntries.anyEntryMatched = false -- 1438
allEntries.match = function(name) -- 1439
	local res = not filterText or name:lower():match(filterText) -- 1440
	if res then -- 1441
		allEntries.anyEntryMatched = true -- 1441
	end -- 1441
	return res -- 1442
end -- 1439
allEntries.thinSep = function() -- 1444
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1444
		return SeparatorText("") -- 1444
	end) -- 1444
end -- 1444
entryWindow = threadLoop(function() -- 1446
	local connected = syncWebIDEControl() -- 1447
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1449
		if not allEntries.pendingPackagePath then -- 1450
			local path = App:takeReceivedFile() -- 1451
			if path ~= "" then -- 1452
				allEntries.pendingPackagePath = path -- 1452
			end -- 1452
		end -- 1450
		if allEntries.pendingPackagePath then -- 1453
			pendingUIMode = true -- 1453
		end -- 1453
	end -- 1449
	if (pendingUIMode ~= nil) then -- 1455
		local nextMode = pendingUIMode -- 1456
		pendingUIMode = nil -- 1457
		applyUIMode(nextMode) -- 1458
	end -- 1455
	if mobileMode and not connected then -- 1459
		if isInEntry and not feedHost then -- 1460
			applyUIMode(true) -- 1460
		end -- 1460
		return -- 1461
	end -- 1459
	if App.fpsLimited ~= config.fpsLimited then -- 1462
		config.fpsLimited = App.fpsLimited -- 1463
	end -- 1462
	if App.targetFPS ~= config.targetFPS then -- 1464
		config.targetFPS = App.targetFPS -- 1465
	end -- 1464
	if View.vsync ~= config.vsync then -- 1466
		config.vsync = View.vsync -- 1467
	end -- 1466
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1468
		config.fixedFPS = Director.scheduler.fixedFPS -- 1469
	end -- 1468
	if Director.profilerSending ~= config.webProfiler then -- 1470
		config.webProfiler = Director.profilerSending -- 1471
	end -- 1470
	if urlClicked then -- 1472
		local _, result = coroutine.resume(urlClicked) -- 1473
		if result then -- 1474
			coroutine.close(urlClicked) -- 1475
			urlClicked = nil -- 1476
		end -- 1474
	end -- 1472
	if not isInEntry then -- 1477
		return -- 1477
	end -- 1477
	local zh = useChinese -- 1478
	local themeColor = App.themeColor -- 1479
	if connected then -- 1480
		local width, height -- 1481
		do -- 1481
			local _obj_0 = App.visualSize -- 1481
			width, height = _obj_0.width, _obj_0.height -- 1481
		end -- 1481
		SetNextWindowBgAlpha(0.5) -- 1482
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1483
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1484
			Separator() -- 1485
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1486
			if iconTex then -- 1487
				Image(icon, Vec2(24, 24)) -- 1488
				SameLine() -- 1489
			end -- 1487
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1490
			TextColored(descColor, slogon) -- 1491
			return Separator() -- 1492
		end) -- 1484
		return -- 1493
	end -- 1480
	if not showEntry then -- 1494
		return -- 1494
	end -- 1494
	local fullWidth, height -- 1496
	do -- 1496
		local _obj_0 = App.visualSize -- 1496
		fullWidth, height = _obj_0.width, _obj_0.height -- 1496
	end -- 1496
	local width = math.min(MaxWidth, fullWidth) -- 1497
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1498
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1499
	SetNextWindowPos(Vec2.zero) -- 1500
	SetNextWindowBgAlpha(0) -- 1501
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1502
	do -- 1503
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1504
			return Begin("Dora Dev", windowFlags, function() -- 1505
				Dummy(Vec2(fullWidth - 20, 0)) -- 1506
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1507
				SameLine() -- 1508
				if Button(zh and "Go 模式" or "Go Mode") then -- 1509
					setUIMode("mobile") -- 1510
				end -- 1509
				if fullWidth >= 540 then -- 1511
					SameLine() -- 1512
					Dummy(Vec2(fullWidth - 540, 0)) -- 1513
					SameLine() -- 1514
					SetNextItemWidth(zh and -95 or -140) -- 1515
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1516
						"AutoSelectAll" -- 1516
					}) then -- 1516
						config.filter = filterBuf.text -- 1517
					end -- 1516
					SameLine() -- 1518
					if Button(zh and '下载' or 'Download') then -- 1519
						allClear() -- 1520
						enterDemoEntry({ -- 1522
							entryName = "ResourceDownloader", -- 1522
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1523
						}) -- 1521
					end -- 1519
				end -- 1511
				return Separator() -- 1524
			end) -- 1505
		end) -- 1504
	end -- 1503
	allEntries.anyEntryMatched = false -- 1526
	SetNextWindowPos(Vec2(0, 50)) -- 1527
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1528
	do -- 1529
		return PushStyleColor("WindowBg", transparant, function() -- 1530
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1531
				return PushStyleVar("Alpha", 1, function() -- 1532
					return Begin("Content", windowFlags, function() -- 1533
						local DemoViewWidth <const> = 220 -- 1534
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1535
						if filterText then -- 1536
							filterText = filterText:lower() -- 1536
						end -- 1536
						if App.platform == "Emscripten" then -- 1537
							Dora.globals.webProjects.draw(zh, themeColor) -- 1538
							allEntries.anyEntryMatched = true -- 1539
						end -- 1537
						if #gamesInDev > 0 then -- 1540
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1541
							Columns(columns, false) -- 1542
							local realViewWidth = GetColumnWidth() - 50 -- 1543
							for _index_0 = 1, #gamesInDev do -- 1544
								local game = gamesInDev[_index_0] -- 1544
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1545
								local displayName -- 1554
								if repo then -- 1554
									if zh then -- 1555
										displayName = repo.title.zh -- 1555
									else -- 1555
										displayName = repo.title.en -- 1555
									end -- 1555
								end -- 1554
								if displayName == nil then -- 1556
									displayName = gameName -- 1556
								end -- 1556
								if allEntries.match(displayName) then -- 1557
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1558
									SameLine() -- 1559
									TextWrapped(displayName) -- 1560
									if columns > 1 then -- 1561
										if bannerFile and bannerTex then -- 1562
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1563
											local displayWidth <const> = realViewWidth -- 1564
											texHeight = displayWidth * texHeight / texWidth -- 1565
											texWidth = displayWidth -- 1566
											Dummy(Vec2.zero) -- 1567
											SameLine() -- 1568
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1569
										end -- 1562
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1570
											enterDemoEntry(game) -- 1571
										end -- 1570
									else -- 1573
										if bannerFile and bannerTex then -- 1573
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1574
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1575
											local sizing = 0.8 -- 1576
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1577
											texWidth = displayWidth * sizing -- 1578
											if texWidth > 500 then -- 1579
												sizing = 0.6 -- 1580
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1581
												texWidth = displayWidth * sizing -- 1582
											end -- 1579
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1583
											Dummy(Vec2(padding, 0)) -- 1584
											SameLine() -- 1585
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1586
										end -- 1573
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1587
											enterDemoEntry(game) -- 1588
										end -- 1587
									end -- 1561
									if #tests == 0 and #examples == 0 then -- 1589
										allEntries.thinSep() -- 1590
									end -- 1589
									NextColumn() -- 1591
								end -- 1557
								local showSep = false -- 1592
								if #examples > 0 then -- 1593
									local showExample = false -- 1594
									for _index_1 = 1, #examples do -- 1595
										local _des_0 = examples[_index_1] -- 1595
										local entryName = _des_0.entryName -- 1595
										if allEntries.match(entryName) then -- 1596
											showExample = true -- 1596
											break -- 1596
										end -- 1596
									end -- 1595
									if showExample then -- 1597
										showSep = true -- 1598
										Columns(1, false) -- 1599
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1600
										SameLine() -- 1601
										local opened -- 1602
										if (filterText ~= nil) then -- 1602
											opened = showExample -- 1602
										else -- 1602
											opened = false -- 1602
										end -- 1602
										if game.exampleOpen == nil then -- 1603
											game.exampleOpen = opened -- 1603
										end -- 1603
										SetNextItemOpen(game.exampleOpen) -- 1604
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1605
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1606
												Columns(maxColumns, false) -- 1607
												for _index_1 = 1, #examples do -- 1608
													local example = examples[_index_1] -- 1608
													local entryName = example.entryName -- 1609
													if not allEntries.match(entryName) then -- 1610
														goto _continue_0 -- 1610
													end -- 1610
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1611
														if Button(entryName, Vec2(-1, 40)) then -- 1612
															enterDemoEntry(example) -- 1613
														end -- 1612
														return NextColumn() -- 1614
													end) -- 1611
													opened = true -- 1615
													::_continue_0:: -- 1609
												end -- 1608
											end) -- 1606
										end) -- 1605
										game.exampleOpen = opened -- 1616
									end -- 1597
								end -- 1593
								if #tests > 0 then -- 1617
									local showTest = false -- 1618
									for _index_1 = 1, #tests do -- 1619
										local _des_0 = tests[_index_1] -- 1619
										local entryName = _des_0.entryName -- 1619
										if allEntries.match(entryName) then -- 1620
											showTest = true -- 1620
											break -- 1620
										end -- 1620
									end -- 1619
									if showTest then -- 1621
										showSep = true -- 1622
										Columns(1, false) -- 1623
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1624
										SameLine() -- 1625
										local opened -- 1626
										if (filterText ~= nil) then -- 1626
											opened = showTest -- 1626
										else -- 1626
											opened = false -- 1626
										end -- 1626
										if game.testOpen == nil then -- 1627
											game.testOpen = opened -- 1627
										end -- 1627
										SetNextItemOpen(game.testOpen) -- 1628
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1629
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1630
												Columns(maxColumns, false) -- 1631
												for _index_1 = 1, #tests do -- 1632
													local test = tests[_index_1] -- 1632
													local entryName = test.entryName -- 1633
													if not allEntries.match(entryName) then -- 1634
														goto _continue_0 -- 1634
													end -- 1634
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1635
														if Button(entryName, Vec2(-1, 40)) then -- 1636
															enterDemoEntry(test) -- 1637
														end -- 1636
														return NextColumn() -- 1638
													end) -- 1635
													opened = true -- 1639
													::_continue_0:: -- 1633
												end -- 1632
											end) -- 1630
										end) -- 1629
										game.testOpen = opened -- 1640
									end -- 1621
								end -- 1617
								if showSep then -- 1641
									Columns(1, false) -- 1642
									allEntries.thinSep() -- 1643
									Columns(columns, false) -- 1644
								end -- 1641
							end -- 1544
						end -- 1540
						if #doraTools > 0 then -- 1645
							local showTool = false -- 1646
							for _index_0 = 1, #doraTools do -- 1647
								local _des_0 = doraTools[_index_0] -- 1647
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1647
								local displayName -- 1648
								if repo then -- 1648
									if zh then -- 1649
										displayName = repo.title.zh -- 1649
									else -- 1649
										displayName = repo.title.en -- 1649
									end -- 1649
								end -- 1648
								if displayName == nil then -- 1650
									displayName = entryName -- 1650
								end -- 1650
								if allEntries.match(displayName) then -- 1651
									showTool = true -- 1651
									break -- 1651
								end -- 1651
							end -- 1647
							if not showTool then -- 1652
								goto endEntry -- 1652
							end -- 1652
							Columns(1, false) -- 1653
							TextColored(themeColor, "Dora SSR:") -- 1654
							SameLine() -- 1655
							Text(zh and "开发支持" or "Development Support") -- 1656
							Separator() -- 1657
							if #doraTools > 0 then -- 1658
								local opened -- 1659
								if (filterText ~= nil) then -- 1659
									opened = showTool -- 1659
								else -- 1659
									opened = false -- 1659
								end -- 1659
								SetNextItemOpen(toolOpen) -- 1660
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1661
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1662
										Columns(maxColumns, false) -- 1663
										for _index_0 = 1, #doraTools do -- 1664
											local tool = doraTools[_index_0] -- 1664
											local entryName, repo = tool.entryName, tool.repo -- 1665
											local displayName -- 1666
											if repo then -- 1666
												if zh then -- 1667
													displayName = repo.title.zh -- 1667
												else -- 1667
													displayName = repo.title.en -- 1667
												end -- 1667
											end -- 1666
											if displayName == nil then -- 1668
												displayName = entryName -- 1668
											end -- 1668
											if not allEntries.match(displayName) then -- 1669
												goto _continue_0 -- 1669
											end -- 1669
											if Button(displayName, Vec2(-1, 40)) then -- 1670
												enterDemoEntry(tool) -- 1671
											end -- 1670
											NextColumn() -- 1672
											::_continue_0:: -- 1665
										end -- 1664
										Columns(1, false) -- 1673
										opened = true -- 1674
									end) -- 1662
								end) -- 1661
								toolOpen = opened -- 1675
							end -- 1658
						end -- 1645
						::endEntry:: -- 1676
						if not allEntries.anyEntryMatched then -- 1677
							SetNextWindowBgAlpha(0) -- 1678
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1679
							Begin("Entries Not Found", displayWindowFlags, function() -- 1680
								Separator() -- 1681
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1682
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1683
								return Separator() -- 1684
							end) -- 1680
						end -- 1677
						Columns(1, false) -- 1685
						Dummy(Vec2(100, 80)) -- 1686
						return ScrollWhenDraggingOnVoid() -- 1687
					end) -- 1533
				end) -- 1532
			end) -- 1531
		end) -- 1530
	end -- 1529
end) -- 1446
if not (App.platform == "Emscripten") then -- 1692
	local sceneModuleCache = moduleCache -- 1693
	moduleCache = { } -- 1694
	webStatus = oldRequire("Script.Dev.WebServer") -- 1695
	moduleCache = sceneModuleCache -- 1696
end -- 1692
local _anon_func_7 = function(saved) -- 1719
	local _val_0 = saved.kind -- 1719
	return "local" == _val_0 or "discover" == _val_0 -- 1719
end -- 1719
local _anon_func_8 = function(saved) -- 1723
	local _val_0 = saved.activeTab -- 1723
	return "local" == _val_0 or "discover" == _val_0 -- 1723
end -- 1723
startMobileUI = function() -- 1698
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1699
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1700
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1701
	local getMobileFeedResources -- 1702
	do -- 1702
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1702
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1702
	end -- 1702
	local loadCachedCatalog -- 1703
	do -- 1703
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1703
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1703
	end -- 1703
	local getResourceInstallPath, getInstalledCatalogResource -- 1704
	do -- 1704
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1704
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1704
	end -- 1704
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1705
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1706
	local feedOptions = nil -- 1707
	local mobileLaunchErrors = { } -- 1708
	local withMobileLaunchErrors -- 1709
	withMobileLaunchErrors = function(items) -- 1709
		for _index_0 = 1, #items do -- 1710
			local item = items[_index_0] -- 1710
			item.launchError = mobileLaunchErrors[item.id] -- 1711
		end -- 1710
		return items -- 1712
	end -- 1709
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1713
	local loadRememberedMobileFeedState -- 1714
	loadRememberedMobileFeedState = function() -- 1714
		local raw = rememberedMobileFeedData -- 1715
		if not (type(raw) == "string" and raw ~= "") then -- 1716
			return -- 1716
		end -- 1716
		local ok, saved = pcall(json.decode, raw) -- 1717
		if not (ok and type(saved) == "table") then -- 1718
			return -- 1718
		end -- 1718
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1719
			local state = { -- 1720
				activeTab = saved.kind -- 1720
			} -- 1720
			state[saved.kind] = saved -- 1721
			return state -- 1722
		end -- 1719
		local state = { -- 1723
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1723
		} -- 1723
		local _list_0 = { -- 1724
			"local", -- 1724
			"discover" -- 1724
		} -- 1724
		for _index_0 = 1, #_list_0 do -- 1724
			local kind = _list_0[_index_0] -- 1724
			local entry = saved[kind] -- 1725
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1726
				state[kind] = entry -- 1726
			end -- 1726
		end -- 1724
		return state -- 1727
	end -- 1714
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1728
		activeTab = "local" -- 1728
	} -- 1728
	local rememberMobileFeedEntry -- 1729
	rememberMobileFeedEntry = function(entry) -- 1729
		rememberedMobileFeedState.activeTab = entry.kind -- 1730
		rememberedMobileFeedState[entry.kind] = { -- 1732
			id = entry.id, -- 1732
			kind = entry.kind, -- 1733
			workDir = entry.workDir, -- 1734
			fileName = entry.fileName -- 1735
		} -- 1731
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1737
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1738
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1739
			rememberedMobileFeedData -- 1739
		}) -- 1739
	end -- 1729
	local restartMobileFeed -- 1740
	restartMobileFeed = function(entry) -- 1740
		if feedHost then -- 1741
			feedHost:removeFromParent(true) -- 1741
		end -- 1741
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1742
		local initialEntries = { } -- 1743
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1744
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1745
		feedOptions.initialEntries = initialEntries -- 1746
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1747
	end -- 1740
	local startMobilePlay -- 1748
	startMobilePlay = function(entry) -- 1748
		if HttpServer.wsConnectionCount > 0 then -- 1749
			return -- 1749
		end -- 1749
		local originFeed = feedHost -- 1750
		if remixHost then -- 1751
			remixHost:removeFromParent(true) -- 1751
		end -- 1751
		remixHost = nil -- 1752
		mobileLaunchErrors[entry.id] = nil -- 1753
		entry.launchError = nil -- 1754
		local playActive = true -- 1755
		local restoreMobileFeed -- 1756
		restoreMobileFeed = function() -- 1756
			if not playActive then -- 1757
				return -- 1757
			end -- 1757
			playActive = false -- 1758
			allClear() -- 1759
			isInEntry = true -- 1760
			currentEntry = nil -- 1761
			return restartMobileFeed(entry) -- 1762
		end -- 1756
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1764
			onExit = function() -- 1764
				return restoreMobileFeed() -- 1764
			end, -- 1764
			onRuntimeError = function() -- 1765
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1766
				return restoreMobileFeed() -- 1767
			end -- 1765
		})) -- 1763
		return thread(function() -- 1769
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1773
			if not playActive then -- 1774
				return -- 1774
			end -- 1774
			if success then -- 1775
				if originFeed and originFeed.parent then -- 1776
					originFeed.visible = false -- 1776
				end -- 1776
				return -- 1777
			end -- 1775
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1778
			return restoreMobileFeed() -- 1779
		end) -- 1769
	end -- 1748
	feedOptions = { -- 1781
		takeReceivedFile = function() -- 1781
			if allEntries.pendingPackagePath then -- 1782
				local path = allEntries.pendingPackagePath -- 1783
				allEntries.pendingPackagePath = nil -- 1784
				return path -- 1785
			end -- 1782
			return App:takeReceivedFile() -- 1786
		end, -- 1781
		onSwitchMode = function() -- 1787
			if HttpServer.wsConnectionCount == 0 then -- 1787
				pendingUIMode = false -- 1787
			end -- 1787
		end, -- 1787
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1788
		getLocalEntries = function(importedProjectPath) -- 1789
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1790
			feedOptions.dirtyProjectPath = nil -- 1791
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1792
			local cached = loadCachedCatalog() -- 1793
			if cached.success and cached.snapshot then -- 1794
				for _index_0 = 1, #items do -- 1795
					local entry = items[_index_0] -- 1795
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1796
					if resource then -- 1797
						entry.resource = resource -- 1798
						entry.catalogCommit = cached.snapshot.commit -- 1799
					end -- 1797
				end -- 1795
			end -- 1794
			return items -- 1800
		end, -- 1789
		syncDiscover = function(onProgress, onDone, force) -- 1801
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1801
		end, -- 1801
		getDiscoverEntries = function() -- 1802
			local cached = loadCachedCatalog() -- 1803
			if not (cached.success and cached.snapshot) then -- 1804
				return { } -- 1804
			end -- 1804
			local items = { } -- 1805
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1806
			for _index_0 = 1, #_list_0 do -- 1806
				local resource = _list_0[_index_0] -- 1806
				local installed = lifecycle.isMobileResourceReady(resource) -- 1807
				local installPath = getResourceInstallPath(resource.id) -- 1808
				items[#items + 1] = { -- 1810
					id = resource.id, -- 1810
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1811
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1812
					kind = "discover", -- 1813
					bannerFile = resource.bannerPath, -- 1814
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1815
					sourceUrl = resource.versions[1].sources[1].url, -- 1816
					workDir = installed and installPath or nil, -- 1817
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1818
					installed = installed, -- 1819
					resource = resource, -- 1820
					catalogCommit = cached.snapshot.commit, -- 1821
					launchError = mobileLaunchErrors[resource.id] -- 1822
				} -- 1809
			end -- 1806
			return items -- 1824
		end, -- 1802
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1825
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1826
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1827
			end), repairIncomplete, isCanceled) -- 1826
		end, -- 1825
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1829
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1830
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1831
			end), isCanceled) -- 1830
		end, -- 1829
		createProject = function(name, language) -- 1833
			local result = projectCreate.createMobileProject(name, language) -- 1834
			if not result.success then -- 1835
				return result -- 1835
			end -- 1835
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1836
			for _index_0 = 1, #_list_0 do -- 1836
				local entry = _list_0[_index_0] -- 1836
				if entry.workDir == result.workDir then -- 1837
					return { -- 1838
						success = true, -- 1838
						entry = entry -- 1838
					} -- 1838
				end -- 1837
			end -- 1836
			return { -- 1839
				success = false, -- 1839
				error = "created-project-not-found" -- 1839
			} -- 1839
		end, -- 1833
		onPlay = function(entry) -- 1840
			return startMobilePlay(entry) -- 1840
		end, -- 1840
		onRemix = function(entry) -- 1841
			if HttpServer.wsConnectionCount > 0 then -- 1842
				return -- 1842
			end -- 1842
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1843
			local originFeed = feedHost -- 1844
			feedHost.visible = false -- 1845
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1847
				entry = entry, -- 1847
				onProjectChanged = function(current) -- 1848
					feedOptions.dirtyProjectPath = current.workDir -- 1848
				end, -- 1848
				onBack = function() -- 1849
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1850
						originFeed:emit("RestoreFeedEntry", entry) -- 1851
						originFeed.visible = true -- 1852
					end -- 1850
				end, -- 1849
				onPlay = function(current) -- 1853
					return startMobilePlay(current) -- 1853
				end -- 1853
			})) -- 1846
		end -- 1841
	} -- 1780
	return restartMobileFeed() -- 1856
end -- 1698
if mobileMode then -- 1858
	applyUIMode(true) -- 1858
end -- 1858
return _module_0 -- 1
