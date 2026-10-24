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
local HttpServer <const> = HttpServer -- 11
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
		if not (path == "Script.Dev.AgentHost" or path == "Script.Dev.AgentStoragePanel" or path:match("^Agent[./]")) then -- 24
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "agentLLMConfigVersion", "mobileRemixLLMConfigId", "mobileLargeText", "webIDEEnabled") -- 60
config:load() -- 96
if not (config.webIDEEnabled ~= nil) then -- 98
	config.webIDEEnabled = true -- 99
end -- 98
App.webIDEEnabled = config.webIDEEnabled -- 100
if not (config.writablePath ~= nil) then -- 102
	config.writablePath = Content.appPath -- 103
end -- 102
if not (config.webIDEConnected ~= nil) then -- 105
	config.webIDEConnected = false -- 106
end -- 105
if (config.fpsLimited ~= nil) then -- 108
	App.fpsLimited = config.fpsLimited -- 109
else -- 111
	config.fpsLimited = App.fpsLimited -- 111
end -- 108
if (config.targetFPS ~= nil) then -- 113
	App.targetFPS = math.floor(config.targetFPS) -- 114
else -- 116
	config.targetFPS = App.targetFPS -- 116
end -- 113
if (config.vsync ~= nil) then -- 118
	View.vsync = config.vsync -- 119
else -- 121
	config.vsync = View.vsync -- 121
end -- 118
if (config.fixedFPS ~= nil) then -- 123
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 124
else -- 126
	config.fixedFPS = Director.scheduler.fixedFPS -- 126
end -- 123
if not (config.showPreview ~= nil) then -- 128
	config.showPreview = true -- 129
end -- 128
if not (config.mobileFeed ~= nil) then -- 131
	local _val_0 = App.platform -- 132
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 132
end -- 131
if not (config.webIDETourCompleted ~= nil) then -- 134
	config.webIDETourCompleted = false -- 135
end -- 134
local showEntry = true -- 138
isDesktop = false -- 140
if (function() -- 141
	local _val_0 = App.platform -- 141
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 141
end)() then -- 141
	isDesktop = true -- 142
	if config.fullScreen then -- 143
		App.fullScreen = true -- 144
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 145
		local size = Size(config.winWidth, config.winHeight) -- 146
		if App.winSize ~= size then -- 147
			App.winSize = size -- 148
		end -- 147
		local winX, winY -- 149
		do -- 149
			local _obj_0 = App.winPosition -- 149
			winX, winY = _obj_0.x, _obj_0.y -- 149
		end -- 149
		if (config.winX ~= nil) then -- 150
			winX = config.winX -- 151
		else -- 153
			config.winX = -1 -- 153
		end -- 150
		if (config.winY ~= nil) then -- 154
			winY = config.winY -- 155
		else -- 157
			config.winY = -1 -- 157
		end -- 154
		App.winPosition = Vec2(winX, winY) -- 158
	end -- 143
	if (config.alwaysOnTop ~= nil) then -- 159
		App.alwaysOnTop = config.alwaysOnTop -- 160
	else -- 162
		config.alwaysOnTop = false -- 162
	end -- 159
	if (config.virtualGamepadEnabled ~= nil) then -- 163
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 164
	else -- 166
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 166
	end -- 163
end -- 141
if (config.themeColor ~= nil) then -- 168
	App.themeColor = Color(config.themeColor) -- 169
else -- 171
	config.themeColor = App.themeColor:toARGB() -- 171
end -- 168
if not (config.locale ~= nil) then -- 173
	config.locale = App.locale -- 174
end -- 173
local showStats = false -- 176
if (config.showStats ~= nil) then -- 177
	showStats = config.showStats -- 178
else -- 180
	config.showStats = showStats -- 180
end -- 177
local showConsole = false -- 182
if (config.showConsole ~= nil) then -- 183
	showConsole = config.showConsole -- 184
else -- 186
	config.showConsole = showConsole -- 186
end -- 183
local showFooter = true -- 188
if (config.showFooter ~= nil) then -- 189
	showFooter = config.showFooter -- 190
else -- 192
	config.showFooter = showFooter -- 192
end -- 189
local setFooterVisible -- 194
setFooterVisible = function(visible) -- 194
	if visible == nil then -- 194
		visible = true -- 194
	end -- 194
	showFooter = visible -- 195
	config.showFooter = showFooter -- 196
end -- 194
_module_0["setFooterVisible"] = setFooterVisible -- 194
local filterBuf = Buffer(20) -- 198
if (config.filter ~= nil) then -- 199
	filterBuf.text = config.filter -- 200
else -- 202
	config.filter = "" -- 202
end -- 199
local engineDev = false -- 204
if (config.engineDev ~= nil) then -- 205
	engineDev = config.engineDev -- 206
else -- 208
	config.engineDev = engineDev -- 208
end -- 205
if (config.webProfiler ~= nil) then -- 210
	Director.profilerSending = config.webProfiler -- 211
else -- 213
	config.webProfiler = true -- 213
	Director.profilerSending = true -- 214
end -- 210
if not (config.drawerWidth ~= nil) then -- 216
	config.drawerWidth = 200 -- 217
end -- 216
_module_0.getConfig = function() -- 219
	return config -- 219
end -- 219
_module_0.getEngineDev = function() -- 220
	if not App.debugging then -- 221
		return false -- 221
	end -- 221
	return config.engineDev -- 222
end -- 220
local _anon_func_0 = function() -- 227
	local _val_0 = App.platform -- 227
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 227
end -- 227
_module_0.connectWebIDE = function() -- 224
	if not config.webIDEConnected then -- 225
		config.webIDEConnected = true -- 226
		if _anon_func_0() then -- 227
			local ratio = App.winSize.width / App.visualSize.width -- 228
			App.winSize = Size(640 * ratio, 480 * ratio) -- 229
		end -- 227
	end -- 225
end -- 224
local updateCheck -- 231
updateCheck = function() -- 231
	return thread(function() -- 231
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 232
		if res then -- 232
			local data = json.decode(res) -- 233
			if data then -- 233
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 234
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 235
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 236
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 237
				if na < a then -- 238
					goto not_new_version -- 239
				end -- 238
				if na == a then -- 240
					if nb < b then -- 241
						goto not_new_version -- 242
					end -- 241
					if nb == b then -- 243
						if nc < c then -- 244
							goto not_new_version -- 245
						end -- 244
						if nc == c then -- 246
							goto not_new_version -- 247
						end -- 246
					end -- 243
				end -- 240
				config.updateNotification = true -- 248
				::not_new_version:: -- 249
				config.lastUpdateCheck = os.time() -- 250
			end -- 233
		end -- 232
	end) -- 231
end -- 231
if (config.lastUpdateCheck ~= nil) then -- 252
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 253
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 254
		updateCheck() -- 255
	end -- 254
else -- 257
	updateCheck() -- 257
end -- 252
local Set, Struct, LintYueGlobals, GSplit -- 259
do -- 259
	local _obj_0 = require("Utils") -- 259
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 259
end -- 259
local yueext = yue.options.extension -- 260
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 262
local building = false -- 264
local getAllFiles -- 266
getAllFiles = function(path, exts, recursive) -- 266
	if recursive == nil then -- 266
		recursive = true -- 266
	end -- 266
	local filters = Set(exts) -- 267
	local files -- 268
	if recursive then -- 268
		files = Content:getAllFiles(path) -- 269
	else -- 271
		files = Content:getFiles(path) -- 271
	end -- 268
	local _accum_0 = { } -- 272
	local _len_0 = 1 -- 272
	for _index_0 = 1, #files do -- 272
		local file = files[_index_0] -- 272
		if not filters[Path:getExt(file)] then -- 273
			goto _continue_0 -- 273
		end -- 273
		_accum_0[_len_0] = file -- 274
		_len_0 = _len_0 + 1 -- 273
		::_continue_0:: -- 273
	end -- 272
	return _accum_0 -- 272
end -- 266
_module_0["getAllFiles"] = getAllFiles -- 266
local getFileEntries -- 276
getFileEntries = function(path, recursive, excludeFiles) -- 276
	if recursive == nil then -- 276
		recursive = true -- 276
	end -- 276
	if excludeFiles == nil then -- 276
		excludeFiles = nil -- 276
	end -- 276
	local entries = { } -- 277
	local excludes -- 278
	if excludeFiles then -- 278
		excludes = Set(excludeFiles) -- 279
	end -- 278
	local _list_0 = getAllFiles(path, { -- 280
		"lua", -- 280
		"xml", -- 280
		yueext, -- 280
		"tl" -- 280
	}, recursive) -- 280
	for _index_0 = 1, #_list_0 do -- 280
		local file = _list_0[_index_0] -- 280
		local entryName = Path:getName(file) -- 281
		if excludes and excludes[entryName] then -- 282
			goto _continue_0 -- 283
		end -- 282
		local fileName = Path:replaceExt(file, "") -- 284
		fileName = Path(path, fileName) -- 285
		local entryAdded -- 286
		for _index_1 = 1, #entries do -- 286
			local _des_0 = entries[_index_1] -- 286
			local ename, efile = _des_0.entryName, _des_0.fileName -- 286
			if entryName == ename and efile == fileName then -- 287
				entryAdded = true -- 287
				break -- 287
			end -- 287
		end -- 286
		if entryAdded then -- 288
			goto _continue_0 -- 288
		end -- 288
		local entry = { -- 289
			entryName = entryName, -- 289
			fileName = fileName -- 289
		} -- 289
		entries[#entries + 1] = entry -- 290
		::_continue_0:: -- 281
	end -- 280
	table.sort(entries, function(a, b) -- 291
		return a.entryName < b.entryName -- 291
	end) -- 291
	return entries -- 292
end -- 276
local allEntries = { -- 294
	dirty = { }, -- 294
	hasDirty = false, -- 294
	runId = 0 -- 294
} -- 294
allEntries.scanDir = function(path, dir, noPreview) -- 296
	if noPreview == nil then -- 296
		noPreview = false -- 296
	end -- 296
	local entries = { } -- 297
	if not dir:match("^%.") then -- 298
		local _list_0 = getAllFiles(Path(path, dir), { -- 299
			"lua", -- 299
			"xml", -- 299
			yueext, -- 299
			"tl", -- 299
			"wasm" -- 299
		}) -- 299
		for _index_0 = 1, #_list_0 do -- 299
			local file = _list_0[_index_0] -- 299
			if "init" == Path:getName(file):lower() then -- 300
				local fileName = Path:replaceExt(file, "") -- 301
				fileName = Path(path, dir, fileName) -- 302
				local projectPath = Path:getPath(fileName) -- 303
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 304
				local repo = nil -- 305
				if Content:exist(repoFile) then -- 306
					local str = Content:load(repoFile) -- 307
					if str then -- 307
						repo = json.decode(str) -- 308
					end -- 307
				end -- 306
				local entryName = Path:getName(projectPath) -- 309
				local entryAdded -- 310
				for _index_1 = 1, #entries do -- 310
					local _des_0 = entries[_index_1] -- 310
					local ename, efile = _des_0.entryName, _des_0.fileName -- 310
					if entryName == ename and efile == fileName then -- 311
						entryAdded = true -- 311
						break -- 311
					end -- 311
				end -- 310
				if entryAdded then -- 312
					goto _continue_0 -- 312
				end -- 312
				local examples = { } -- 313
				local tests = { } -- 314
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 315
				if Content:exist(examplePath) then -- 316
					local _list_1 = getFileEntries(examplePath) -- 317
					for _index_1 = 1, #_list_1 do -- 317
						local _des_0 = _list_1[_index_1] -- 317
						local name, ePath = _des_0.entryName, _des_0.fileName -- 317
						local entry = { -- 319
							entryName = name, -- 319
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 320
							workDir = projectPath -- 321
						} -- 318
						examples[#examples + 1] = entry -- 323
					end -- 317
				end -- 316
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 324
				if Content:exist(testPath) then -- 325
					local _list_1 = getFileEntries(testPath) -- 326
					for _index_1 = 1, #_list_1 do -- 326
						local _des_0 = _list_1[_index_1] -- 326
						local name, tPath = _des_0.entryName, _des_0.fileName -- 326
						local entry = { -- 328
							entryName = name, -- 328
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 329
							workDir = projectPath -- 330
						} -- 327
						tests[#tests + 1] = entry -- 332
					end -- 326
				end -- 325
				local entry = { -- 333
					entryName = entryName, -- 333
					fileName = fileName, -- 333
					projectPath = projectPath, -- 333
					examples = examples, -- 333
					tests = tests, -- 333
					repo = repo -- 333
				} -- 333
				local bannerFile -- 334
				do -- 334
					local _val_0 -- 334
					repeat -- 334
						if noPreview then -- 335
							_val_0 = nil -- 335
							break -- 335
						end -- 335
						if not config.showPreview then -- 336
							_val_0 = nil -- 336
							break -- 336
						end -- 336
						local f = Path(projectPath, ".dora", "banner.jpg") -- 337
						if Content:exist(f) then -- 338
							_val_0 = f -- 338
							break -- 338
						end -- 338
						f = Path(projectPath, ".dora", "banner.png") -- 339
						if Content:exist(f) then -- 340
							_val_0 = f -- 340
							break -- 340
						end -- 340
						f = Path(projectPath, "Image", "banner.jpg") -- 341
						if Content:exist(f) then -- 342
							_val_0 = f -- 342
							break -- 342
						end -- 342
						f = Path(projectPath, "Image", "banner.png") -- 343
						if Content:exist(f) then -- 344
							_val_0 = f -- 344
							break -- 344
						end -- 344
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 345
						if Content:exist(f) then -- 346
							_val_0 = f -- 346
							break -- 346
						end -- 346
					until true -- 334
					bannerFile = _val_0 -- 334
				end -- 334
				if bannerFile then -- 348
					entry.bannerFile = bannerFile -- 351
					thread(function() -- 352
						if Cache:loadAsync(bannerFile) then -- 353
							local bannerTex = Texture2D(bannerFile) -- 354
							if bannerTex then -- 354
								entry.bannerTex = bannerTex -- 355
							end -- 354
						end -- 353
					end) -- 352
				end -- 348
				entries[#entries + 1] = entry -- 356
			end -- 300
			::_continue_0:: -- 300
		end -- 299
	end -- 298
	return entries -- 357
end -- 296
local getProjectEntries -- 359
getProjectEntries = function(path, noPreview) -- 359
	if noPreview == nil then -- 359
		noPreview = false -- 359
	end -- 359
	local entries = { } -- 360
	local _list_0 = Content:getDirs(path) -- 361
	for _index_0 = 1, #_list_0 do -- 361
		local dir = _list_0[_index_0] -- 361
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 362
		for _index_1 = 1, #_list_1 do -- 362
			local entry = _list_1[_index_1] -- 362
			entries[#entries + 1] = entry -- 363
		end -- 362
	end -- 361
	table.sort(entries, function(a, b) -- 364
		return a.entryName < b.entryName -- 364
	end) -- 364
	return entries -- 365
end -- 359
_module_0["getProjectEntries"] = getProjectEntries -- 359
local gamesInDev -- 367
local doraTools -- 368
local isToolEntry -- 370
isToolEntry = function(entry) -- 370
	do -- 371
		local _type_0 = type(entry) -- 371
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 371
		if _tab_0 then -- 371
			local categories -- 371
			do -- 371
				local _obj_0 = entry.repo -- 371
				local _type_1 = type(_obj_0) -- 371
				if "table" == _type_1 or "userdata" == _type_1 then -- 371
					categories = _obj_0.categories -- 371
				end -- 371
			end -- 371
			if categories ~= nil then -- 371
				for _index_0 = 1, #categories do -- 372
					local category = categories[_index_0] -- 372
					if "string" == type(category) and category:lower() == "tool" then -- 373
						return true -- 374
					end -- 373
				end -- 372
			end -- 371
		end -- 371
	end -- 371
	return false -- 370
end -- 370
local getEntryTitle -- 376
getEntryTitle = function(entry) -- 376
	local title -- 377
	do -- 377
		local repo = entry.repo -- 377
		if repo then -- 377
			if repo.title and "table" == type(repo.title) then -- 378
				if useChinese then -- 379
					title = repo.title.zh -- 379
				else -- 379
					title = repo.title.en -- 379
				end -- 379
			end -- 378
		end -- 377
	end -- 377
	if title ~= nil then -- 380
		return title -- 380
	else -- 380
		return entry.entryName -- 380
	end -- 380
end -- 376
allEntries.rebuildEntries = function() -- 382
	gamesInDev = { } -- 383
	do -- 384
		local _accum_0 = { } -- 384
		local _len_0 = 1 -- 384
		local _list_0 = allEntries.builtinTools -- 384
		for _index_0 = 1, #_list_0 do -- 384
			local tool = _list_0[_index_0] -- 384
			_accum_0[_len_0] = tool -- 384
			_len_0 = _len_0 + 1 -- 384
		end -- 384
		doraTools = _accum_0 -- 384
	end -- 384
	local _list_0 = allEntries.projectEntries -- 385
	for _index_0 = 1, #_list_0 do -- 385
		local entry = _list_0[_index_0] -- 385
		if isToolEntry(entry) then -- 386
			entry.kind = "tool" -- 387
			doraTools[#doraTools + 1] = entry -- 388
		else -- 390
			entry.kind = "game" -- 390
			gamesInDev[#gamesInDev + 1] = entry -- 391
		end -- 386
	end -- 385
	for i = #allEntries, 1, -1 do -- 392
		allEntries[i] = nil -- 393
	end -- 392
	for _index_0 = 1, #gamesInDev do -- 394
		local game = gamesInDev[_index_0] -- 394
		allEntries[#allEntries + 1] = game -- 395
		local examples, tests = game.examples, game.tests -- 396
		for _index_1 = 1, #examples do -- 397
			local example = examples[_index_1] -- 397
			allEntries[#allEntries + 1] = example -- 398
		end -- 397
		for _index_1 = 1, #tests do -- 399
			local test = tests[_index_1] -- 399
			allEntries[#allEntries + 1] = test -- 400
		end -- 399
	end -- 394
end -- 382
local updateEntries -- 402
updateEntries = function() -- 402
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 403
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 404
	local _list_0 = allEntries.builtinTools -- 405
	for _index_0 = 1, #_list_0 do -- 405
		local tool = _list_0[_index_0] -- 405
		tool.kind = "tool" -- 406
		tool.builtin = true -- 407
	end -- 405
	return allEntries.rebuildEntries() -- 408
end -- 402
allEntries.refreshDirtyProjects = function() -- 410
	if not allEntries.hasDirty then -- 411
		return -- 411
	end -- 411
	local dirty = allEntries.dirty -- 412
	allEntries.dirty = { } -- 413
	allEntries.hasDirty = false -- 414
	for projectPath in pairs(dirty) do -- 415
		do -- 416
			local _accum_0 = { } -- 416
			local _len_0 = 1 -- 416
			local _list_0 = allEntries.projectEntries -- 416
			for _index_0 = 1, #_list_0 do -- 416
				local entry = _list_0[_index_0] -- 416
				if entry.projectPath ~= projectPath then -- 416
					_accum_0[_len_0] = entry -- 416
					_len_0 = _len_0 + 1 -- 416
				end -- 416
			end -- 416
			allEntries.projectEntries = _accum_0 -- 416
		end -- 416
		local parentPath = Path:getPath(projectPath) -- 417
		local dir = Path:getFilename(projectPath) -- 418
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 419
		for _index_0 = 1, #_list_0 do -- 419
			local entry = _list_0[_index_0] -- 419
			if entry.projectPath == projectPath then -- 420
				do -- 421
					local _obj_0 = allEntries.projectEntries -- 421
					_obj_0[#_obj_0 + 1] = entry -- 421
				end -- 421
				break -- 422
			end -- 420
		end -- 419
	end -- 415
	table.sort(allEntries.projectEntries, function(a, b) -- 423
		return a.entryName < b.entryName -- 423
	end) -- 423
	return allEntries.rebuildEntries() -- 424
end -- 410
updateEntries() -- 426
local getLaunchEntries -- 428
getLaunchEntries = function(refresh) -- 428
	if refresh == nil then -- 428
		refresh = false -- 428
	end -- 428
	if refresh then -- 429
		updateEntries() -- 429
	end -- 429
	local toInfo -- 430
	toInfo = function(entry, kind) -- 430
		local file = entry.fileName -- 431
		local asProj = not entry.builtin -- 432
		return { -- 434
			name = getEntryTitle(entry), -- 434
			file = file, -- 435
			kind = kind, -- 436
			asProj = asProj -- 437
		} -- 433
	end -- 430
	local games -- 439
	do -- 439
		local _accum_0 = { } -- 439
		local _len_0 = 1 -- 439
		for _index_0 = 1, #gamesInDev do -- 439
			local game = gamesInDev[_index_0] -- 439
			_accum_0[_len_0] = toInfo(game, "game") -- 439
			_len_0 = _len_0 + 1 -- 439
		end -- 439
		games = _accum_0 -- 439
	end -- 439
	local tools -- 440
	do -- 440
		local _accum_0 = { } -- 440
		local _len_0 = 1 -- 440
		for _index_0 = 1, #doraTools do -- 440
			local tool = doraTools[_index_0] -- 440
			_accum_0[_len_0] = toInfo(tool, "tool") -- 440
			_len_0 = _len_0 + 1 -- 440
		end -- 440
		tools = _accum_0 -- 440
	end -- 440
	return { -- 441
		games = games, -- 441
		tools = tools -- 441
	} -- 441
end -- 428
_module_0["getLaunchEntries"] = getLaunchEntries -- 428
local _anon_func_1 = function(entry, useChinese) -- 458
	local _obj_0 = entry.repo -- 458
	if _obj_0 ~= nil then -- 458
		local _obj_1 = _obj_0.description -- 458
		if _obj_1 ~= nil then -- 458
			return _obj_1[useChinese and "zh" or "en"] -- 458
		end -- 458
		return nil -- 458
	end -- 458
	return nil -- 458
end -- 458
local getMobileFeedEntries -- 443
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 443
	if refresh == nil then -- 443
		refresh = false -- 443
	end -- 443
	if dirtyProjectPath == nil then -- 443
		dirtyProjectPath = nil -- 443
	end -- 443
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 444
		allEntries.dirty[dirtyProjectPath] = true -- 445
		allEntries.hasDirty = true -- 446
	end -- 444
	if refresh then -- 447
		allEntries.dirty = { } -- 448
		allEntries.hasDirty = false -- 449
		updateEntries() -- 450
	else -- 452
		allEntries.refreshDirtyProjects() -- 452
	end -- 447
	local items = { } -- 453
	for _index_0 = 1, #gamesInDev do -- 454
		local entry = gamesInDev[_index_0] -- 454
		items[#items + 1] = { -- 456
			id = entry.entryName, -- 456
			title = getEntryTitle(entry), -- 457
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 458
			fileName = entry.fileName, -- 459
			workDir = Path:getPath(entry.fileName), -- 460
			bannerFile = entry.bannerFile, -- 461
			kind = "local" -- 462
		} -- 455
	end -- 454
	return items -- 464
end -- 443
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 443
local doCompile -- 466
doCompile = function(minify) -- 466
	if building then -- 467
		return -- 467
	end -- 467
	building = true -- 468
	local startTime = App.runningTime -- 469
	local luaFiles = { } -- 470
	local yueFiles = { } -- 471
	local xmlFiles = { } -- 472
	local tlFiles = { } -- 473
	local writablePath = Content.writablePath -- 474
	local buildPaths = { -- 476
		{ -- 477
			Content.assetPath, -- 477
			Path(writablePath, ".build"), -- 478
			"" -- 479
		} -- 476
	} -- 475
	for _index_0 = 1, #gamesInDev do -- 482
		local _des_0 = gamesInDev[_index_0] -- 482
		local fileName = _des_0.fileName -- 482
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 483
		buildPaths[#buildPaths + 1] = { -- 485
			Path(writablePath, gamePath), -- 485
			Path(writablePath, ".build", gamePath), -- 486
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 487
			gamePath -- 488
		} -- 484
	end -- 482
	for _index_0 = 1, #buildPaths do -- 489
		local _des_0 = buildPaths[_index_0] -- 489
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 489
		if not Content:exist(inputPath) then -- 490
			goto _continue_0 -- 490
		end -- 490
		local _list_0 = getAllFiles(inputPath, { -- 492
			"lua" -- 492
		}) -- 492
		for _index_1 = 1, #_list_0 do -- 492
			local file = _list_0[_index_1] -- 492
			luaFiles[#luaFiles + 1] = { -- 494
				file, -- 494
				Path(inputPath, file), -- 495
				Path(outputPath, file), -- 496
				gamePath -- 497
			} -- 493
		end -- 492
		local _list_1 = getAllFiles(inputPath, { -- 499
			yueext -- 499
		}) -- 499
		for _index_1 = 1, #_list_1 do -- 499
			local file = _list_1[_index_1] -- 499
			yueFiles[#yueFiles + 1] = { -- 501
				file, -- 501
				Path(inputPath, file), -- 502
				Path(outputPath, Path:replaceExt(file, "lua")), -- 503
				searchPath, -- 504
				gamePath -- 505
			} -- 500
		end -- 499
		local _list_2 = getAllFiles(inputPath, { -- 507
			"xml" -- 507
		}) -- 507
		for _index_1 = 1, #_list_2 do -- 507
			local file = _list_2[_index_1] -- 507
			xmlFiles[#xmlFiles + 1] = { -- 509
				file, -- 509
				Path(inputPath, file), -- 510
				Path(outputPath, Path:replaceExt(file, "lua")), -- 511
				gamePath -- 512
			} -- 508
		end -- 507
		local _list_3 = getAllFiles(inputPath, { -- 514
			"tl" -- 514
		}) -- 514
		for _index_1 = 1, #_list_3 do -- 514
			local file = _list_3[_index_1] -- 514
			if not file:match(".*%.d%.tl$") then -- 515
				tlFiles[#tlFiles + 1] = { -- 517
					file, -- 517
					Path(inputPath, file), -- 518
					Path(outputPath, Path:replaceExt(file, "lua")), -- 519
					searchPath, -- 520
					gamePath -- 521
				} -- 516
			end -- 515
		end -- 514
		::_continue_0:: -- 490
	end -- 489
	local paths -- 523
	do -- 523
		local _tbl_0 = { } -- 523
		local _list_0 = { -- 524
			luaFiles, -- 524
			yueFiles, -- 524
			xmlFiles, -- 524
			tlFiles -- 524
		} -- 524
		for _index_0 = 1, #_list_0 do -- 524
			local files = _list_0[_index_0] -- 524
			for _index_1 = 1, #files do -- 525
				local file = files[_index_1] -- 525
				_tbl_0[Path:getPath(file[3])] = true -- 523
			end -- 523
		end -- 523
		paths = _tbl_0 -- 523
	end -- 523
	for path in pairs(paths) do -- 527
		Content:mkdir(path) -- 527
	end -- 527
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 529
	local fileCount = 0 -- 530
	local errors = { } -- 531
	for _index_0 = 1, #yueFiles do -- 532
		local _des_0 = yueFiles[_index_0] -- 532
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 532
		local filename -- 533
		if gamePath then -- 533
			filename = Path(gamePath, file) -- 533
		else -- 533
			filename = file -- 533
		end -- 533
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 534
			if not codes then -- 535
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 536
				return -- 537
			end -- 535
			local success, result = LintYueGlobals(codes, globals) -- 538
			local yueCodes -- 539
			if not success then -- 540
				yueCodes = Content:load(input) -- 541
				if yueCodes then -- 541
					local CheckTIC80Code -- 542
					do -- 542
						local _obj_0 = require("Utils") -- 542
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 542
					end -- 542
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 543
					if isTIC80 then -- 544
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 545
					end -- 544
				end -- 541
			end -- 540
			if success then -- 546
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 547
			else -- 549
				if yueCodes then -- 549
					local globalErrors = { } -- 550
					for _index_1 = 1, #result do -- 551
						local _des_1 = result[_index_1] -- 551
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 551
						local countLine = 1 -- 552
						local code = "" -- 553
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 554
							if countLine == line then -- 555
								code = lineCode -- 556
								break -- 557
							end -- 555
							countLine = countLine + 1 -- 558
						end -- 554
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 559
					end -- 551
					if #globalErrors > 0 then -- 560
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 560
					end -- 560
				else -- 562
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 562
				end -- 549
				if #errors == 0 then -- 563
					return codes -- 563
				end -- 563
			end -- 546
		end, function(success) -- 534
			if success then -- 564
				print("Yue compiled: " .. tostring(filename)) -- 564
			end -- 564
			fileCount = fileCount + 1 -- 565
		end) -- 534
	end -- 532
	thread(function() -- 567
		for _index_0 = 1, #xmlFiles do -- 568
			local _des_0 = xmlFiles[_index_0] -- 568
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 568
			local filename -- 569
			if gamePath then -- 569
				filename = Path(gamePath, file) -- 569
			else -- 569
				filename = file -- 569
			end -- 569
			local sourceCodes = Content:loadAsync(input) -- 570
			local codes, err = xml.tolua(sourceCodes) -- 571
			if not codes then -- 572
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 573
			else -- 575
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 575
				print("Xml compiled: " .. tostring(filename)) -- 576
			end -- 572
			fileCount = fileCount + 1 -- 577
		end -- 568
	end) -- 567
	thread(function() -- 579
		for _index_0 = 1, #tlFiles do -- 580
			local _des_0 = tlFiles[_index_0] -- 580
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 580
			local filename -- 581
			if gamePath then -- 581
				filename = Path(gamePath, file) -- 581
			else -- 581
				filename = file -- 581
			end -- 581
			local sourceCodes = Content:loadAsync(input) -- 582
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 583
			if not codes then -- 584
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 585
			else -- 587
				Content:saveAsync(output, codes) -- 587
				print("Teal compiled: " .. tostring(filename)) -- 588
			end -- 584
			fileCount = fileCount + 1 -- 589
		end -- 580
	end) -- 579
	return thread(function() -- 591
		wait(function() -- 592
			return fileCount == totalFiles -- 592
		end) -- 592
		if minify then -- 593
			local _list_0 = { -- 594
				yueFiles, -- 594
				xmlFiles, -- 594
				tlFiles -- 594
			} -- 594
			for _index_0 = 1, #_list_0 do -- 594
				local files = _list_0[_index_0] -- 594
				for _index_1 = 1, #files do -- 594
					local file = files[_index_1] -- 594
					local output = Path:replaceExt(file[3], "lua") -- 595
					luaFiles[#luaFiles + 1] = { -- 597
						Path:replaceExt(file[1], "lua"), -- 597
						output, -- 598
						output -- 599
					} -- 596
				end -- 594
			end -- 594
			local FormatMini -- 601
			do -- 601
				local _obj_0 = require("luaminify") -- 601
				FormatMini = _obj_0.FormatMini -- 601
			end -- 601
			for _index_0 = 1, #luaFiles do -- 602
				local _des_0 = luaFiles[_index_0] -- 602
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 602
				if Content:exist(input) then -- 603
					local sourceCodes = Content:loadAsync(input) -- 604
					local res, err = FormatMini(sourceCodes) -- 605
					if res then -- 606
						Content:saveAsync(output, res) -- 607
						print("Minify: " .. tostring(file)) -- 608
					else -- 610
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 610
					end -- 606
				else -- 612
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 612
				end -- 603
			end -- 602
			package.loaded["luaminify.FormatMini"] = nil -- 613
			package.loaded["luaminify.ParseLua"] = nil -- 614
			package.loaded["luaminify.Scope"] = nil -- 615
			package.loaded["luaminify.Util"] = nil -- 616
		end -- 593
		local errorMessage = table.concat(errors, "\n") -- 617
		if errorMessage ~= "" then -- 618
			print(errorMessage) -- 618
		end -- 618
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 619
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 620
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 621
		Content:clearPathCache() -- 622
		teal.clear() -- 623
		yue.clear() -- 624
		building = false -- 625
	end) -- 591
end -- 466
local doClean -- 627
doClean = function() -- 627
	if building then -- 628
		return -- 628
	end -- 628
	local writablePath = Content.writablePath -- 629
	local targetDir = Path(writablePath, ".build") -- 630
	Content:clearPathCache() -- 631
	if Content:remove(targetDir) then -- 632
		return print("Cleaned: " .. tostring(targetDir)) -- 633
	end -- 632
end -- 627
local screenScale = 2.0 -- 635
local scaleContent = false -- 636
local isInEntry = true -- 637
local currentEntry = nil -- 638
local footerWindow = nil -- 640
local entryWindow = nil -- 641
local testingThread = nil -- 642
local mobileMode = config.mobileFeed -- 643
local pendingUIMode = nil -- 644
local feedHost = nil -- 645
local remixHost = nil -- 646
local startMobileUI = nil -- 647
local webControlled = false -- 648
local mobileHosts = { } -- 649
local suspendedMobileHosts = { } -- 650
local trackMobileHost -- 652
trackMobileHost = function(host) -- 652
	do -- 653
		local _accum_0 = { } -- 653
		local _len_0 = 1 -- 653
		for _index_0 = 1, #mobileHosts do -- 653
			local item = mobileHosts[_index_0] -- 653
			if item.parent then -- 653
				_accum_0[_len_0] = item -- 653
				_len_0 = _len_0 + 1 -- 653
			end -- 653
		end -- 653
		mobileHosts = _accum_0 -- 653
	end -- 653
	mobileHosts[#mobileHosts + 1] = host -- 654
	return host -- 655
end -- 652
local clearMobileUI -- 657
clearMobileUI = function() -- 657
	for _index_0 = 1, #mobileHosts do -- 658
		local host = mobileHosts[_index_0] -- 658
		if host.parent then -- 659
			host:removeFromParent(true) -- 659
		end -- 659
	end -- 658
	mobileHosts = { } -- 660
	suspendedMobileHosts = { } -- 661
	feedHost = nil -- 662
	remixHost = nil -- 663
end -- 657
local syncWebIDEControl -- 665
syncWebIDEControl = function() -- 665
	local connected = HttpServer.wsConnectionCount > 0 -- 666
	if connected then -- 667
		pendingUIMode = nil -- 668
		for _index_0 = 1, #mobileHosts do -- 669
			local host = mobileHosts[_index_0] -- 669
			if not host.parent then -- 670
				goto _continue_0 -- 670
			end -- 670
			if not (suspendedMobileHosts[host] ~= nil) then -- 671
				suspendedMobileHosts[host] = host.visible -- 672
				host:emit("SuspendLocalUI") -- 673
			end -- 671
			host.visible = false -- 674
			::_continue_0:: -- 670
		end -- 669
	elseif webControlled then -- 675
		for host, visible in pairs(suspendedMobileHosts) do -- 676
			if host.parent then -- 677
				host.visible = visible -- 678
				host:emit("ResumeLocalUI") -- 679
			end -- 677
		end -- 676
		suspendedMobileHosts = { } -- 680
	end -- 667
	webControlled = connected -- 681
	return connected -- 682
end -- 665
local getUIMode -- 684
getUIMode = function() -- 684
	return mobileMode and "mobile" or "traditional" -- 684
end -- 684
_module_0["getUIMode"] = getUIMode -- 684
local setUIMode -- 685
setUIMode = function(mode) -- 685
	if not (("mobile" == mode or "traditional" == mode)) then -- 686
		return false -- 686
	end -- 686
	if HttpServer.wsConnectionCount > 0 then -- 687
		return false -- 687
	end -- 687
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 688
		return false -- 688
	end -- 688
	local wantsMobile = mode == "mobile" -- 689
	if wantsMobile == mobileMode then -- 690
		return true -- 690
	end -- 690
	if mobileMode then -- 691
		if not (feedHost and feedHost.visible) then -- 692
			return false -- 692
		end -- 692
		feedHost:emit("SwitchUIMode") -- 694
		return pendingUIMode == false -- 695
	end -- 691
	pendingUIMode = true -- 696
	return true -- 697
end -- 685
_module_0["setUIMode"] = setUIMode -- 685
local applyUIMode -- 699
applyUIMode = function(enabled) -- 699
	if HttpServer.wsConnectionCount > 0 then -- 701
		return false -- 701
	end -- 701
	if enabled then -- 702
		local ok, err = pcall(startMobileUI) -- 703
		if not ok then -- 704
			if feedHost then -- 705
				feedHost:removeFromParent(true) -- 705
			end -- 705
			feedHost = nil -- 706
			mobileMode = false -- 707
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 708
			return false -- 709
		end -- 704
	else -- 711
		clearMobileUI() -- 711
		updateEntries() -- 712
	end -- 702
	mobileMode = enabled -- 713
	config.mobileFeed = enabled -- 714
	return true -- 715
end -- 699
local setupEventHandlers = nil -- 717
local allClear -- 719
allClear = function() -- 719
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 721
		clearMobileUI() -- 721
	end -- 721
	local systemNodes = { } -- 724
	local preserveSystemNode -- 725
	preserveSystemNode = function(node) -- 725
		if systemNodes[node] then -- 726
			return -- 726
		end -- 726
		systemNodes[node] = true -- 727
		do -- 728
			local clip = tolua.cast(node, "ClipNode") -- 728
			if clip then -- 728
				if clip.stencil then -- 729
					preserveSystemNode(clip.stencil) -- 729
				end -- 729
			end -- 728
		end -- 728
		return node:eachChild(function(child) -- 730
			preserveSystemNode(child) -- 731
			return false -- 732
		end) -- 730
	end -- 725
	for _index_0 = 1, #Routine do -- 733
		local routine = Routine[_index_0] -- 733
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 735
			goto _continue_0 -- 736
		else -- 738
			Routine:remove(routine) -- 738
		end -- 734
		::_continue_0:: -- 734
	end -- 733
	for _index_0 = 1, #moduleCache do -- 739
		local module = moduleCache[_index_0] -- 739
		package.loaded[module] = nil -- 740
	end -- 739
	moduleCache = { } -- 741
	Director:cleanup() -- 742
	Entity:clear() -- 743
	Platformer.Data:clear() -- 744
	Platformer.UnitAction:clear() -- 745
	Audio:stopAll(0.2) -- 746
	Struct:clear() -- 747
	View.nearPlaneDistance = 0.1 -- 750
	View.farPlaneDistance = 10000 -- 751
	View.fieldOfView = 45 -- 752
	View.postEffect = nil -- 753
	View.scale = scaleContent and screenScale or 1 -- 754
	Director.clearColor = Color(0xff1a1a1a) -- 755
	teal.clear() -- 756
	yue.clear() -- 757
	preserveSystemNode(Director.systemUI) -- 760
	for _, item in pairs(ubox()) do -- 761
		local node = tolua.cast(item, "Node") -- 762
		if node then -- 762
			if not systemNodes[node] then -- 763
				node:cleanup() -- 763
			end -- 763
		end -- 762
	end -- 761
	collectgarbage() -- 764
	collectgarbage() -- 765
	Wasm:clear() -- 766
	thread(function() -- 767
		sleep() -- 768
		return Cache:removeUnused() -- 769
	end) -- 767
	setupEventHandlers() -- 770
	Content.searchPaths = searchPaths -- 771
	App.idled = true -- 772
end -- 719
_module_0["allClear"] = allClear -- 719
local clearTempFiles -- 774
clearTempFiles = function() -- 774
	local writablePath = Content.writablePath -- 775
	local uploadPath = Path(writablePath, ".upload") -- 776
	if Content:exist(uploadPath) then -- 777
		local _list_0 = Content:getDirs(uploadPath) -- 779
		for _index_0 = 1, #_list_0 do -- 779
			local dir = _list_0[_index_0] -- 779
			if dir ~= "resume" then -- 780
				Content:remove(Path(uploadPath, dir)) -- 780
			end -- 780
		end -- 779
		local _list_1 = Content:getFiles(uploadPath) -- 781
		for _index_0 = 1, #_list_1 do -- 781
			local file = _list_1[_index_0] -- 781
			Content:remove(Path(uploadPath, file)) -- 782
		end -- 781
	end -- 777
	if Content:exist(Path(writablePath, ".download")) then -- 783
		return Content:remove(Path(writablePath, ".download")) -- 783
	end -- 783
end -- 774
local waitForWebStart = true -- 785
thread(function() -- 786
	sleep(2) -- 787
	waitForWebStart = false -- 788
end) -- 786
local reloadDevEntry -- 790
reloadDevEntry = function() -- 790
	return thread(function() -- 790
		waitForWebStart = true -- 791
		doClean() -- 792
		allClear() -- 793
		_G.require = oldRequire -- 794
		Dora.require = oldRequire -- 795
		package.loaded["Script.Dev.Entry"] = nil -- 796
		package.loaded["Script.Dev.WebServer"] = nil -- 797
		return Director.systemScheduler:schedule(function() -- 798
			Routine:clear() -- 799
			oldRequire("Script.Dev.Entry") -- 800
			return true -- 801
		end) -- 798
	end) -- 790
end -- 790
local setWorkspace -- 803
setWorkspace = function(path) -- 803
	clearTempFiles() -- 804
	Content.writablePath = path -- 805
	config.writablePath = Content.writablePath -- 806
	return thread(function() -- 807
		sleep() -- 808
		return reloadDevEntry() -- 809
	end) -- 807
end -- 803
_module_0["setWorkspace"] = setWorkspace -- 803
local quit = false -- 811
local activeSearchId = 0 -- 813
local handleSearchFiles -- 815
handleSearchFiles = function(payload) -- 815
	if not payload then -- 816
		return -- 816
	end -- 816
	local id = payload.id -- 817
	if id == nil then -- 818
		return -- 818
	end -- 818
	activeSearchId = id -- 819
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 820
	if path == nil then -- 821
		path = "" -- 821
	end -- 821
	if exts == nil then -- 822
		exts = { } -- 822
	end -- 822
	if globs == nil then -- 823
		globs = { } -- 823
	end -- 823
	if extensionLevels == nil then -- 824
		extensionLevels = { } -- 824
	end -- 824
	if pattern == nil then -- 825
		pattern = "" -- 825
	end -- 825
	if pattern == "" then -- 827
		return -- 827
	end -- 827
	local useRegex = payload.useRegex == true -- 828
	local caseSensitive = payload.caseSensitive == true -- 829
	local includeContent = payload.includeContent ~= false -- 830
	local contentWindow = payload.contentWindow or 0 -- 831
	return Director.systemScheduler:schedule(once(function() -- 832
		local stopped = false -- 833
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 834
			if activeSearchId ~= id then -- 835
				stopped = true -- 836
				return true -- 837
			end -- 835
			emit("AppWS", "Send", json.encode({ -- 839
				name = "SearchFilesResult", -- 839
				id = id, -- 839
				result = result -- 839
			})) -- 838
			return false -- 841
		end) -- 834
		return emit("AppWS", "Send", json.encode({ -- 843
			name = "SearchFilesDone", -- 843
			id = id, -- 843
			stopped = stopped -- 843
		})) -- 842
	end)) -- 832
end -- 815
local stop -- 846
stop = function() -- 846
	if isInEntry then -- 847
		return false -- 847
	end -- 847
	allClear() -- 848
	isInEntry = true -- 849
	currentEntry = nil -- 850
	return true -- 851
end -- 846
_module_0["stop"] = stop -- 846
local getCurrentEntryStatus -- 853
getCurrentEntryStatus = function() -- 853
	local entry = currentEntry -- 854
	if not (entry and not isInEntry) then -- 855
		return { -- 855
			success = true, -- 855
			running = false, -- 855
			runId = allEntries.runId -- 855
		} -- 855
	end -- 855
	local status = { -- 857
		success = true, -- 857
		running = true, -- 858
		kind = entry.runKind or "file", -- 859
		runId = allEntries.runId, -- 860
		entryName = entry.entryName, -- 861
		fileName = entry.fileName -- 862
	} -- 856
	if entry.workDir then -- 863
		status.workDir = entry.workDir -- 863
	end -- 863
	if entry.projectRoot then -- 864
		status.projectRoot = entry.projectRoot -- 864
	end -- 864
	return status -- 865
end -- 853
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 853
local _anon_func_2 = function(_with_0) -- 884
	local _val_0 = App.platform -- 884
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 884
end -- 884
setupEventHandlers = function() -- 867
	local _with_0 = Director.postNode -- 868
	_with_0:onAppEvent(function(eventType) -- 869
		if "Quit" == eventType then -- 870
			quit = true -- 871
			allClear() -- 872
			return clearTempFiles() -- 873
		elseif "Shutdown" == eventType then -- 874
			return stop() -- 875
		end -- 869
	end) -- 869
	_with_0:onAppChange(function(settingName) -- 876
		if "Theme" == settingName then -- 877
			config.themeColor = App.themeColor:toARGB() -- 878
		elseif "Locale" == settingName then -- 879
			config.locale = App.locale -- 880
			updateLocale() -- 881
			return teal.clear(true) -- 882
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 883
			if _anon_func_2(_with_0) then -- 884
				if "FullScreen" == settingName then -- 886
					config.fullScreen = App.fullScreen -- 886
				elseif "Position" == settingName then -- 887
					local _obj_0 = App.winPosition -- 887
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 887
				elseif "Size" == settingName then -- 888
					local width, height -- 889
					do -- 889
						local _obj_0 = App.winSize -- 889
						width, height = _obj_0.width, _obj_0.height -- 889
					end -- 889
					config.winWidth = width -- 890
					config.winHeight = height -- 891
				end -- 885
			end -- 884
		end -- 876
	end) -- 876
	_with_0:onAppWS(function(event) -- 892
		if event.type == "Close" then -- 893
			if HttpServer.wsConnectionCount == 0 then -- 894
				updateEntries() -- 895
			end -- 894
			return -- 896
		end -- 893
		if not (event.type == "Receive") then -- 897
			return -- 897
		end -- 897
		local data = json.decode(event.msg) -- 898
		if not data then -- 899
			return -- 899
		end -- 899
		local _exp_0 = data.name -- 900
		if "SearchFiles" == _exp_0 then -- 901
			return handleSearchFiles(data) -- 902
		elseif "SearchFilesStop" == _exp_0 then -- 903
			if data.id == nil or data.id == activeSearchId then -- 904
				activeSearchId = 0 -- 905
			end -- 904
		end -- 900
	end) -- 892
	_with_0:slot("UpdateEntries", function() -- 906
		return updateEntries() -- 906
	end) -- 906
	return _with_0 -- 868
end -- 867
setupEventHandlers() -- 908
clearTempFiles() -- 909
local downloadFile -- 911
downloadFile = function(url, target) -- 911
	return Director.systemScheduler:schedule(once(function() -- 911
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 912
			if quit then -- 913
				return true -- 913
			end -- 913
			emit("AppWS", "Send", json.encode({ -- 915
				name = "Download", -- 915
				url = url, -- 915
				status = "downloading", -- 915
				progress = current / total -- 916
			})) -- 914
			return false -- 912
		end) -- 912
		return emit("AppWS", "Send", json.encode(success and { -- 919
			name = "Download", -- 919
			url = url, -- 919
			status = "completed", -- 919
			progress = 1.0 -- 920
		} or { -- 922
			name = "Download", -- 922
			url = url, -- 922
			status = "failed", -- 922
			progress = 0.0 -- 923
		})) -- 918
	end)) -- 911
end -- 911
_module_0["downloadFile"] = downloadFile -- 911
local _anon_func_3 = function(file, require, workDir) -- 935
	if workDir == nil then -- 935
		workDir = Path:getPath(file) -- 935
	end -- 935
	Content:insertSearchPath(1, workDir) -- 936
	local scriptPath = Path(workDir, "Script") -- 937
	if Content:exist(scriptPath) then -- 938
		Content:insertSearchPath(1, scriptPath) -- 939
	end -- 938
	local result = require(file) -- 940
	if "function" == type(result) then -- 941
		result() -- 941
	end -- 941
	return nil -- 942
end -- 935
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 971
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 971
	label.alignment = "Left" -- 972
	label.textWidth = width - fontSize -- 973
	label.text = err -- 974
	return label -- 971
end -- 971
local enterEntryAsync -- 926
enterEntryAsync = function(entry) -- 926
	allEntries.runId = allEntries.runId + 1 -- 927
	isInEntry = false -- 928
	App.idled = false -- 929
	emit(Profiler.EventName, "ClearLoader") -- 930
	currentEntry = entry -- 931
	local file, workDir = entry.fileName, entry.workDir -- 932
	sleep() -- 933
	return xpcall(_anon_func_3, function(msg) -- 942
		local err = debug.traceback(msg) -- 944
		Log("Error", err) -- 945
		allClear() -- 946
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 947
		local viewWidth, viewHeight -- 948
		do -- 948
			local _obj_0 = View.size -- 948
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 948
		end -- 948
		local width, height = viewWidth - 20, viewHeight - 20 -- 949
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 950
		Director.ui:addChild((function() -- 951
			local root = AlignNode() -- 951
			do -- 952
				local _obj_0 = App.bufferSize -- 952
				width, height = _obj_0.width, _obj_0.height -- 952
			end -- 952
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 953
			root:onAppChange(function(settingName) -- 954
				if settingName == "Size" then -- 954
					do -- 955
						local _obj_0 = App.bufferSize -- 955
						width, height = _obj_0.width, _obj_0.height -- 955
					end -- 955
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 956
				end -- 954
			end) -- 954
			root:addChild((function() -- 957
				local _with_0 = ScrollArea({ -- 958
					width = width, -- 958
					height = height, -- 959
					paddingX = 0, -- 960
					paddingY = 50, -- 961
					viewWidth = height, -- 962
					viewHeight = height -- 963
				}) -- 957
				root:onAlignLayout(function(w, h) -- 965
					_with_0.position = Vec2(w / 2, h / 2) -- 966
					w = w - 20 -- 967
					h = h - 20 -- 968
					_with_0.view.children.first.textWidth = w - fontSize -- 969
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 970
				end) -- 965
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 971
				return _with_0 -- 957
			end)()) -- 957
			return root -- 951
		end)()) -- 951
		return err -- 975
	end, file, require, workDir) -- 934
end -- 926
_module_0["enterEntryAsync"] = enterEntryAsync -- 926
local enterDemoEntry -- 977
enterDemoEntry = function(entry) -- 977
	return thread(function() -- 977
		return enterEntryAsync(entry) -- 977
	end) -- 977
end -- 977
local reloadCurrentEntry -- 979
reloadCurrentEntry = function() -- 979
	if currentEntry then -- 980
		allClear() -- 981
		return enterDemoEntry(currentEntry) -- 982
	end -- 980
end -- 979
Director.clearColor = Color(0xff1a1a1a) -- 984
local descColor = Color(0xffa1a1a1) -- 985
local extraOperations -- 987
do -- 987
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 988
	local isOSSLicenseExist = Content:exist("LICENSES") -- 989
	local ossLicenses = nil -- 990
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 991
	local failedSetFolder = false -- 992
	local statusFlags = { -- 993
		"NoResize", -- 993
		"NoMove", -- 993
		"NoCollapse", -- 993
		"AlwaysAutoResize", -- 993
		"NoSavedSettings" -- 993
	} -- 993
	extraOperations = function() -- 1000
		local zh = useChinese -- 1001
		if isDesktop then -- 1002
			local alwaysOnTop = config.alwaysOnTop -- 1003
			do -- 1004
				local changed -- 1004
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1004
				if changed then -- 1004
					App.alwaysOnTop = alwaysOnTop -- 1005
					config.alwaysOnTop = alwaysOnTop -- 1006
				end -- 1004
			end -- 1004
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1007
			do -- 1008
				local changed -- 1008
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1008
				if changed then -- 1008
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1009
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1010
				end -- 1008
			end -- 1008
			SameLine() -- 1011
			TextColored(descColor, "(?)") -- 1012
			if IsItemHovered() then -- 1013
				BeginTooltip(function() -- 1014
					return PushTextWrapPos(360, function() -- 1015
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1016
					end) -- 1015
				end) -- 1014
			end -- 1013
		end -- 1002
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1031
		do -- 1035
			local changed -- 1035
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1035
			if changed then -- 1035
				config.showPreview = showPreview -- 1036
				updateEntries() -- 1037
				if not showPreview then -- 1038
					thread(function() -- 1039
						collectgarbage() -- 1040
						return Cache:removeUnused("Texture") -- 1041
					end) -- 1039
				end -- 1038
			end -- 1035
		end -- 1035
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1042
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1043
			if changed then -- 1043
				config.webIDEEnabled = webIDEEnabled -- 1044
				App.webIDEEnabled = webIDEEnabled -- 1045
			end -- 1043
		end -- 1042
		do -- 1046
			local themeColor = App.themeColor -- 1047
			local writablePath = config.writablePath -- 1048
			SeparatorText(zh and "工作目录" or "Workspace") -- 1049
			PushTextWrapPos(400, function() -- 1050
				return TextColored(themeColor, writablePath) -- 1051
			end) -- 1050
			if not isDesktop then -- 1052
				goto skipSetting -- 1052
			end -- 1052
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1053
			if Button(zh and "改变目录" or "Set Folder") then -- 1054
				App:openFileDialog(true, function(path) -- 1055
					if path == "" then -- 1056
						return -- 1056
					end -- 1056
					local relPath = Path:getRelative(Content.assetPath, path) -- 1057
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1058
						return setWorkspace(path) -- 1059
					else -- 1061
						failedSetFolder = true -- 1061
					end -- 1058
				end) -- 1055
			end -- 1054
			if failedSetFolder then -- 1062
				failedSetFolder = false -- 1063
				OpenPopup(popupName) -- 1064
			end -- 1062
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1065
			BeginPopupModal(popupName, statusFlags, function() -- 1066
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1067
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1068
					return CloseCurrentPopup() -- 1069
				end -- 1068
			end) -- 1066
			SameLine() -- 1070
			if Button(zh and "使用默认" or "Use Default") then -- 1071
				setWorkspace(Content.appPath) -- 1072
			end -- 1071
			Separator() -- 1073
			::skipSetting:: -- 1074
		end -- 1046
		renderAgentStorage(zh) -- 1075
		if isOSSLicenseExist then -- 1076
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1077
				if not ossLicenses then -- 1078
					local licenseText = Content:load("LICENSES") -- 1079
					if licenseText then -- 1079
						ossLicenses = { } -- 1080
						licenseText = licenseText:gsub("\r\n", "\n") -- 1081
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1082
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1083
							if name then -- 1083
								ossLicenses[#ossLicenses + 1] = { -- 1084
									name, -- 1084
									text -- 1084
								} -- 1084
							end -- 1083
						end -- 1082
					end -- 1079
				end -- 1078
				if ossLicenses then -- 1085
					OpenPopup(ossLicensePopup) -- 1085
				end -- 1085
			end -- 1077
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1086
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1087
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1088
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1089
				return BeginPopupModal(ossLicensePopup, true, { -- 1092
					"NoSavedSettings" -- 1092
				}, function() -- 1093
					for _index_0 = 1, #ossLicenses do -- 1094
						local _des_0 = ossLicenses[_index_0] -- 1094
						local firstLine, text = _des_0[1], _des_0[2] -- 1094
						local name, license = firstLine:match("(.+): (.+)") -- 1096
						if name then -- 1096
							TextColored(themeColor, name) -- 1097
							SameLine() -- 1098
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1099
								return TextWrapped(text) -- 1099
							end) -- 1099
						end -- 1096
					end -- 1094
				end) -- 1089
			end) -- 1089
		end -- 1076
		if not App.debugging then -- 1102
			return -- 1102
		end -- 1102
		return TreeNode(zh and "开发操作" or "Development", function() -- 1103
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1104
				OpenPopup("build") -- 1104
			end -- 1104
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1105
				return BeginPopup("build", function() -- 1105
					if Selectable(zh and "编译" or "Compile") then -- 1106
						doCompile(false) -- 1106
					end -- 1106
					Separator() -- 1107
					if Selectable(zh and "压缩" or "Minify") then -- 1108
						doCompile(true) -- 1108
					end -- 1108
					Separator() -- 1109
					if Selectable(zh and "清理" or "Clean") then -- 1110
						return doClean() -- 1110
					end -- 1110
				end) -- 1105
			end) -- 1105
			if isInEntry then -- 1111
				if waitForWebStart then -- 1112
					BeginDisabled(function() -- 1113
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1113
					end) -- 1113
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1114
					reloadDevEntry() -- 1115
				end -- 1112
			end -- 1111
			do -- 1116
				local changed -- 1116
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1116
				if changed then -- 1116
					View.scale = scaleContent and screenScale or 1 -- 1117
				end -- 1116
			end -- 1116
			do -- 1118
				local changed -- 1118
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1118
				if changed then -- 1118
					config.engineDev = engineDev -- 1119
				end -- 1118
			end -- 1118
			do -- 1120
				local changed -- 1120
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1120
				if changed then -- 1120
					config.webIDETourCompleted = webIDETourCompleted -- 1121
				end -- 1120
			end -- 1120
			if testingThread then -- 1122
				return BeginDisabled(function() -- 1123
					return Button(zh and "开始自动测试" or "Test automatically") -- 1123
				end) -- 1123
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1124
				testingThread = thread(function() -- 1125
					local _ <close> = setmetatable({ }, { -- 1126
						__close = function() -- 1126
							allClear() -- 1127
							testingThread = nil -- 1128
							isInEntry = true -- 1129
							currentEntry = nil -- 1130
							return print("Testing done!") -- 1131
						end -- 1126
					}) -- 1126
					for _, entry in ipairs(allEntries) do -- 1132
						allClear() -- 1133
						print("Start " .. tostring(entry.entryName)) -- 1134
						enterDemoEntry(entry) -- 1135
						sleep(2) -- 1136
						print("Stop " .. tostring(entry.entryName)) -- 1137
					end -- 1132
				end) -- 1125
			end -- 1122
		end) -- 1103
	end -- 1000
end -- 987
local icon = Path("Script", "Dev", "icon_s.png") -- 1139
local iconTex = nil -- 1140
thread(function() -- 1141
	if Cache:loadAsync(icon) then -- 1141
		iconTex = Texture2D(icon) -- 1141
	end -- 1141
end) -- 1141
local webStatus = nil -- 1143
local urlClicked = nil -- 1144
local authCode = string.format("%06d", math.random(0, 999999)) -- 1146
local authCodeTTL = 30.0 -- 1148
_module_0.getAuthCode = function() -- 1149
	return authCode -- 1149
end -- 1149
_module_0.invalidateAuthCode = function() -- 1150
	authCode = string.format("%06d", math.random(0, 999999)) -- 1151
	authCodeTTL = 30.0 -- 1152
end -- 1150
local AuthSession -- 1154
do -- 1154
	local pending = nil -- 1155
	local session = nil -- 1156
	AuthSession = { -- 1158
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1158
			pending = { -- 1160
				sessionId = sessionId, -- 1160
				confirmCode = confirmCode, -- 1161
				expiresAt = expiresAt, -- 1162
				ttl = ttl, -- 1163
				approved = false -- 1164
			} -- 1159
		end, -- 1158
		getPending = function() -- 1166
			return pending -- 1166
		end, -- 1166
		approvePending = function(sessionId) -- 1168
			if pending and pending.sessionId == sessionId then -- 1169
				pending.approved = true -- 1170
				return true -- 1171
			end -- 1169
			return false -- 1172
		end, -- 1168
		clearPending = function() -- 1174
			pending = nil -- 1174
		end, -- 1174
		setSession = function(sessionId, sessionSecret) -- 1176
			session = { -- 1178
				sessionId = sessionId, -- 1178
				sessionSecret = sessionSecret -- 1179
			} -- 1177
		end, -- 1176
		getSession = function() -- 1181
			return session -- 1181
		end -- 1181
	} -- 1157
end -- 1154
_module_0["AuthSession"] = AuthSession -- 1154
local transparant = Color(0x0) -- 1184
local windowFlags = { -- 1185
	"NoTitleBar", -- 1185
	"NoResize", -- 1185
	"NoMove", -- 1185
	"NoCollapse", -- 1185
	"NoSavedSettings", -- 1185
	"NoFocusOnAppearing", -- 1185
	"NoBringToFrontOnFocus" -- 1185
} -- 1185
local statusFlags = { -- 1194
	"NoTitleBar", -- 1194
	"NoResize", -- 1194
	"NoMove", -- 1194
	"NoCollapse", -- 1194
	"AlwaysAutoResize", -- 1194
	"NoSavedSettings" -- 1194
} -- 1194
local displayWindowFlags = { -- 1202
	"NoDecoration", -- 1202
	"NoSavedSettings", -- 1202
	"NoMove", -- 1202
	"NoScrollWithMouse", -- 1202
	"AlwaysAutoResize", -- 1202
	"NoFocusOnAppearing" -- 1202
} -- 1202
local gamepadInputWindowFlags = { -- 1210
	"NoDecoration", -- 1210
	"NoSavedSettings", -- 1210
	"NoMove", -- 1210
	"NoScrollbar", -- 1210
	"NoScrollWithMouse", -- 1210
	"NoFocusOnAppearing", -- 1210
	"NoBringToFrontOnFocus" -- 1210
} -- 1210
local initFooter = true -- 1219
local gamepadInputFocused = false -- 1220
local _anon_func_5 = function(allEntries, currentIndex) -- 1266
	if currentIndex > 1 then -- 1266
		return allEntries[currentIndex - 1] -- 1267
	else -- 1269
		return allEntries[#allEntries] -- 1269
	end -- 1266
end -- 1266
local _anon_func_6 = function(allEntries, currentIndex) -- 1273
	if currentIndex < #allEntries then -- 1273
		return allEntries[currentIndex + 1] -- 1274
	else -- 1276
		return allEntries[1] -- 1276
	end -- 1273
end -- 1273
footerWindow = threadLoop(function() -- 1221
	if mobileMode then -- 1222
		return -- 1222
	end -- 1222
	local zh = useChinese -- 1223
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1224
	if authCodeTTL <= 0 then -- 1225
		authCodeTTL = 30.0 -- 1226
		authCode = string.format("%06d", math.random(0, 999999)) -- 1227
	end -- 1225
	if HttpServer.wsConnectionCount > 0 then -- 1228
		return -- 1229
	end -- 1228
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1230
		if App.platform == "Emscripten" then -- 1231
			stop() -- 1233
		else -- 1235
			allClear() -- 1235
			App.devMode = false -- 1236
			App:shutdown() -- 1237
		end -- 1231
	end -- 1230
	do -- 1238
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1239
		if ctrl and Keyboard:isKeyDown("Q") then -- 1240
			stop() -- 1241
		end -- 1240
		if ctrl and Keyboard:isKeyDown("Z") then -- 1242
			reloadCurrentEntry() -- 1243
		end -- 1242
		if ctrl and Keyboard:isKeyDown(",") then -- 1244
			if showFooter then -- 1245
				showStats = not showStats -- 1245
			else -- 1245
				showStats = true -- 1245
			end -- 1245
			showFooter = true -- 1246
			config.showFooter = showFooter -- 1247
			config.showStats = showStats -- 1248
		end -- 1244
		if ctrl and Keyboard:isKeyDown(".") then -- 1249
			if showFooter then -- 1250
				showConsole = not showConsole -- 1250
			else -- 1250
				showConsole = true -- 1250
			end -- 1250
			showFooter = true -- 1251
			config.showFooter = showFooter -- 1252
			config.showConsole = showConsole -- 1253
		end -- 1249
		if ctrl and Keyboard:isKeyDown("/") then -- 1254
			showFooter = not showFooter -- 1255
			config.showFooter = showFooter -- 1256
		end -- 1254
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1257
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1258
		local currentIndex = nil -- 1259
		for i, entry in ipairs(allEntries) do -- 1260
			if currentEntry == entry then -- 1261
				currentIndex = i -- 1262
			end -- 1261
		end -- 1260
		if left then -- 1263
			allClear() -- 1264
			if currentIndex == nil then -- 1265
				currentIndex = #allEntries + 1 -- 1265
			end -- 1265
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1266
		end -- 1263
		if right then -- 1270
			allClear() -- 1271
			if currentIndex == nil then -- 1272
				currentIndex = 0 -- 1272
			end -- 1272
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1273
		end -- 1270
	end -- 1238
	if not showEntry then -- 1277
		return -- 1277
	end -- 1277
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1279
		reloadDevEntry() -- 1283
	end -- 1279
	if initFooter then -- 1284
		initFooter = false -- 1285
	end -- 1284
	local width, height -- 1287
	do -- 1287
		local _obj_0 = App.visualSize -- 1287
		width, height = _obj_0.width, _obj_0.height -- 1287
	end -- 1287
	if isInEntry then -- 1288
		gamepadInputFocused = false -- 1289
	else -- 1291
		SetNextWindowBgAlpha(0.0) -- 1291
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1292
		SetNextWindowPos(Vec2.zero, "Always") -- 1293
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1294
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1295
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1296
					if not gamepadInputFocused then -- 1297
						SetWindowFocus("DoraGamepadInput") -- 1298
						gamepadInputFocused = true -- 1299
					end -- 1297
				end) -- 1296
			end) -- 1295
		end) -- 1294
	end -- 1288
	if isInEntry or showFooter then -- 1301
		SetNextWindowSize(Vec2(width, 50)) -- 1302
		SetNextWindowPos(Vec2(0, height - 50)) -- 1303
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1304
			return PushStyleVar("WindowRounding", 0, function() -- 1305
				return Begin("Footer", windowFlags, function() -- 1306
					Separator() -- 1307
					if iconTex then -- 1308
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1309
							showStats = not showStats -- 1310
							config.showStats = showStats -- 1311
						end -- 1309
						SameLine() -- 1312
						if Button(">_", Vec2(30, 30)) then -- 1313
							showConsole = not showConsole -- 1314
							config.showConsole = showConsole -- 1315
						end -- 1313
					end -- 1308
					if isInEntry and config.updateNotification then -- 1316
						SameLine() -- 1317
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1318
							allClear() -- 1319
							config.updateNotification = false -- 1320
							enterDemoEntry({ -- 1322
								entryName = "SelfUpdater", -- 1322
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1323
							}) -- 1321
						end -- 1318
					end -- 1316
					if not isInEntry then -- 1324
						SameLine() -- 1325
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1326
						local currentIndex = nil -- 1327
						for i, entry in ipairs(allEntries) do -- 1328
							if currentEntry == entry then -- 1329
								currentIndex = i -- 1330
							end -- 1329
						end -- 1328
						if currentIndex then -- 1331
							if currentIndex > 1 then -- 1332
								SameLine() -- 1333
								if Button("<<", Vec2(30, 30)) then -- 1334
									allClear() -- 1335
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1336
								end -- 1334
							end -- 1332
							if currentIndex < #allEntries then -- 1337
								SameLine() -- 1338
								if Button(">>", Vec2(30, 30)) then -- 1339
									allClear() -- 1340
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1341
								end -- 1339
							end -- 1337
						end -- 1331
						SameLine() -- 1342
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1343
							reloadCurrentEntry() -- 1344
						end -- 1343
						if back then -- 1345
							allClear() -- 1346
							isInEntry = true -- 1347
							currentEntry = nil -- 1348
						end -- 1345
					end -- 1324
				end) -- 1306
			end) -- 1305
		end) -- 1304
	end -- 1301
	if isInEntry then -- 1350
		local showURL = true -- 1351
		local webIDEWidth -- 1352
		do -- 1352
			local base -- 1353
			if config.updateNotification then -- 1353
				base = 460 -- 1353
			else -- 1353
				base = 360 -- 1353
			end -- 1353
			local extra = 35 -- 1354
			webIDEWidth = base + extra -- 1355
		end -- 1352
		if width < webIDEWidth then -- 1356
			showURL = false -- 1356
		end -- 1356
		SetNextWindowBgAlpha(0.0) -- 1357
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1358
		Begin("Web IDE", displayWindowFlags, function() -- 1359
			local pending = AuthSession.getPending() -- 1360
			local hovered = false -- 1361
			if not pending and showURL then -- 1362
				do -- 1363
					local url -- 1363
					if webStatus ~= nil then -- 1363
						url = webStatus.url -- 1363
					end -- 1363
					if url then -- 1363
						if isDesktop and not config.fullScreen then -- 1364
							if urlClicked then -- 1365
								BeginDisabled(function() -- 1366
									return Button(url) -- 1366
								end) -- 1366
							elseif Button(url) then -- 1367
								urlClicked = once(function() -- 1368
									return sleep(5) -- 1368
								end) -- 1368
								App:openURL("http://localhost:8866") -- 1369
							end -- 1365
						else -- 1371
							TextColored(descColor, url) -- 1371
						end -- 1364
					else -- 1373
						TextColored(descColor, zh and '不可用' or 'not available') -- 1373
					end -- 1363
				end -- 1363
				hovered = IsItemHovered() -- 1374
			else -- 1376
				TextColored(descColor, "(?)") -- 1376
				hovered = IsItemHovered() -- 1377
			end -- 1362
			SameLine() -- 1378
			local themeColor = App.themeColor -- 1379
			if pending then -- 1380
				if not pending.approved then -- 1381
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1382
					local ttl = pending.ttl or 1 -- 1383
					PushStyleColor("Text", themeColor, function() -- 1384
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1385
						hovered = hovered or IsItemHovered() -- 1386
					end) -- 1384
					SameLine() -- 1387
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1388
						AuthSession.approvePending(pending.sessionId) -- 1389
					end -- 1388
					if hovered then -- 1390
						return BeginTooltip(function() -- 1391
							return PushTextWrapPos(280, function() -- 1392
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1393
							end) -- 1392
						end) -- 1391
					end -- 1390
				end -- 1381
			else -- 1395
				PushStyleColor("Text", themeColor, function() -- 1395
					ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1396
					hovered = hovered or IsItemHovered() -- 1397
				end) -- 1395
				if hovered then -- 1398
					return BeginTooltip(function() -- 1399
						return PushTextWrapPos(280, function() -- 1400
							local url -- 1401
							if webStatus ~= nil then -- 1401
								url = webStatus.url -- 1401
							end -- 1401
							if url then -- 1401
								local address -- 1402
								if showURL then -- 1402
									address = "Web IDE" -- 1402
								else -- 1402
									address = url -- 1402
								end -- 1402
								return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1403
							else -- 1405
								return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1405
							end -- 1401
						end) -- 1400
					end) -- 1399
				end -- 1398
			end -- 1380
		end) -- 1359
	end -- 1350
	if not isInEntry then -- 1406
		SetNextWindowSize(Vec2(50, 50)) -- 1407
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1408
		PushStyleColor("WindowBg", transparant, function() -- 1409
			return Begin("Show", displayWindowFlags, function() -- 1409
				if width >= 370 then -- 1410
					local changed -- 1411
					changed, showFooter = Checkbox("##dev", showFooter) -- 1411
					if changed then -- 1411
						config.showFooter = showFooter -- 1412
					end -- 1411
				end -- 1410
			end) -- 1409
		end) -- 1409
	end -- 1406
	if isInEntry or showFooter then -- 1414
		if showStats then -- 1415
			PushStyleVar("WindowRounding", 0, function() -- 1416
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1417
				SetNextWindowSize(Vec2(0, height - 50)) -- 1418
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1419
				config.showStats = showStats -- 1420
			end) -- 1416
		end -- 1415
		if showConsole then -- 1421
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1422
			return PushStyleVar("WindowRounding", 6, function() -- 1423
				return ShowConsole() -- 1424
			end) -- 1423
		end -- 1421
	end -- 1414
end) -- 1221
local MaxWidth <const> = 960 -- 1426
local toolOpen = false -- 1428
local filterText = nil -- 1429
allEntries.anyEntryMatched = false -- 1430
allEntries.match = function(name) -- 1431
	local res = not filterText or name:lower():match(filterText) -- 1432
	if res then -- 1433
		allEntries.anyEntryMatched = true -- 1433
	end -- 1433
	return res -- 1434
end -- 1431
allEntries.thinSep = function() -- 1436
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1436
		return SeparatorText("") -- 1436
	end) -- 1436
end -- 1436
entryWindow = threadLoop(function() -- 1438
	local connected = syncWebIDEControl() -- 1439
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1441
		if not allEntries.pendingPackagePath then -- 1442
			local path = App:takeReceivedFile() -- 1443
			if path ~= "" then -- 1444
				allEntries.pendingPackagePath = path -- 1444
			end -- 1444
		end -- 1442
		if allEntries.pendingPackagePath then -- 1445
			pendingUIMode = true -- 1445
		end -- 1445
	end -- 1441
	if (pendingUIMode ~= nil) then -- 1447
		local nextMode = pendingUIMode -- 1448
		pendingUIMode = nil -- 1449
		applyUIMode(nextMode) -- 1450
	end -- 1447
	if mobileMode and not connected then -- 1451
		if isInEntry and not feedHost then -- 1452
			applyUIMode(true) -- 1452
		end -- 1452
		return -- 1453
	end -- 1451
	if App.fpsLimited ~= config.fpsLimited then -- 1454
		config.fpsLimited = App.fpsLimited -- 1455
	end -- 1454
	if App.targetFPS ~= config.targetFPS then -- 1456
		config.targetFPS = App.targetFPS -- 1457
	end -- 1456
	if View.vsync ~= config.vsync then -- 1458
		config.vsync = View.vsync -- 1459
	end -- 1458
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1460
		config.fixedFPS = Director.scheduler.fixedFPS -- 1461
	end -- 1460
	if Director.profilerSending ~= config.webProfiler then -- 1462
		config.webProfiler = Director.profilerSending -- 1463
	end -- 1462
	if urlClicked then -- 1464
		local _, result = coroutine.resume(urlClicked) -- 1465
		if result then -- 1466
			coroutine.close(urlClicked) -- 1467
			urlClicked = nil -- 1468
		end -- 1466
	end -- 1464
	if not isInEntry then -- 1469
		return -- 1469
	end -- 1469
	local zh = useChinese -- 1470
	local themeColor = App.themeColor -- 1471
	if connected then -- 1472
		local width, height -- 1473
		do -- 1473
			local _obj_0 = App.visualSize -- 1473
			width, height = _obj_0.width, _obj_0.height -- 1473
		end -- 1473
		SetNextWindowBgAlpha(0.5) -- 1474
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1475
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1476
			Separator() -- 1477
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1478
			if iconTex then -- 1479
				Image(icon, Vec2(24, 24)) -- 1480
				SameLine() -- 1481
			end -- 1479
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1482
			TextColored(descColor, slogon) -- 1483
			return Separator() -- 1484
		end) -- 1476
		return -- 1485
	end -- 1472
	if not showEntry then -- 1486
		return -- 1486
	end -- 1486
	local fullWidth, height -- 1488
	do -- 1488
		local _obj_0 = App.visualSize -- 1488
		fullWidth, height = _obj_0.width, _obj_0.height -- 1488
	end -- 1488
	local width = math.min(MaxWidth, fullWidth) -- 1489
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1490
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1491
	SetNextWindowPos(Vec2.zero) -- 1492
	SetNextWindowBgAlpha(0) -- 1493
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1494
	do -- 1495
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1496
			return Begin("Dora Dev", windowFlags, function() -- 1497
				Dummy(Vec2(fullWidth - 20, 0)) -- 1498
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1499
				SameLine() -- 1500
				if Button(zh and "Go 模式" or "Go Mode") then -- 1501
					setUIMode("mobile") -- 1502
				end -- 1501
				if fullWidth >= 540 then -- 1503
					SameLine() -- 1504
					Dummy(Vec2(fullWidth - 540, 0)) -- 1505
					SameLine() -- 1506
					SetNextItemWidth(zh and -95 or -140) -- 1507
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1508
						"AutoSelectAll" -- 1508
					}) then -- 1508
						config.filter = filterBuf.text -- 1509
					end -- 1508
					SameLine() -- 1510
					if Button(zh and '下载' or 'Download') then -- 1511
						allClear() -- 1512
						enterDemoEntry({ -- 1514
							entryName = "ResourceDownloader", -- 1514
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1515
						}) -- 1513
					end -- 1511
				end -- 1503
				return Separator() -- 1516
			end) -- 1497
		end) -- 1496
	end -- 1495
	allEntries.anyEntryMatched = false -- 1518
	SetNextWindowPos(Vec2(0, 50)) -- 1519
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1520
	do -- 1521
		return PushStyleColor("WindowBg", transparant, function() -- 1522
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1523
				return PushStyleVar("Alpha", 1, function() -- 1524
					return Begin("Content", windowFlags, function() -- 1525
						local DemoViewWidth <const> = 220 -- 1526
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1527
						if filterText then -- 1528
							filterText = filterText:lower() -- 1528
						end -- 1528
						if App.platform == "Emscripten" then -- 1529
							Dora.globals.webProjects.draw(zh, themeColor) -- 1530
							allEntries.anyEntryMatched = true -- 1531
						end -- 1529
						if #gamesInDev > 0 then -- 1532
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1533
							Columns(columns, false) -- 1534
							local realViewWidth = GetColumnWidth() - 50 -- 1535
							for _index_0 = 1, #gamesInDev do -- 1536
								local game = gamesInDev[_index_0] -- 1536
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1537
								local displayName -- 1546
								if repo then -- 1546
									if zh then -- 1547
										displayName = repo.title.zh -- 1547
									else -- 1547
										displayName = repo.title.en -- 1547
									end -- 1547
								end -- 1546
								if displayName == nil then -- 1548
									displayName = gameName -- 1548
								end -- 1548
								if allEntries.match(displayName) then -- 1549
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1550
									SameLine() -- 1551
									TextWrapped(displayName) -- 1552
									if columns > 1 then -- 1553
										if bannerFile and bannerTex then -- 1554
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1555
											local displayWidth <const> = realViewWidth -- 1556
											texHeight = displayWidth * texHeight / texWidth -- 1557
											texWidth = displayWidth -- 1558
											Dummy(Vec2.zero) -- 1559
											SameLine() -- 1560
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1561
										end -- 1554
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1562
											enterDemoEntry(game) -- 1563
										end -- 1562
									else -- 1565
										if bannerFile and bannerTex then -- 1565
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1566
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1567
											local sizing = 0.8 -- 1568
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1569
											texWidth = displayWidth * sizing -- 1570
											if texWidth > 500 then -- 1571
												sizing = 0.6 -- 1572
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1573
												texWidth = displayWidth * sizing -- 1574
											end -- 1571
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1575
											Dummy(Vec2(padding, 0)) -- 1576
											SameLine() -- 1577
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1578
										end -- 1565
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1579
											enterDemoEntry(game) -- 1580
										end -- 1579
									end -- 1553
									if #tests == 0 and #examples == 0 then -- 1581
										allEntries.thinSep() -- 1582
									end -- 1581
									NextColumn() -- 1583
								end -- 1549
								local showSep = false -- 1584
								if #examples > 0 then -- 1585
									local showExample = false -- 1586
									for _index_1 = 1, #examples do -- 1587
										local _des_0 = examples[_index_1] -- 1587
										local entryName = _des_0.entryName -- 1587
										if allEntries.match(entryName) then -- 1588
											showExample = true -- 1588
											break -- 1588
										end -- 1588
									end -- 1587
									if showExample then -- 1589
										showSep = true -- 1590
										Columns(1, false) -- 1591
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1592
										SameLine() -- 1593
										local opened -- 1594
										if (filterText ~= nil) then -- 1594
											opened = showExample -- 1594
										else -- 1594
											opened = false -- 1594
										end -- 1594
										if game.exampleOpen == nil then -- 1595
											game.exampleOpen = opened -- 1595
										end -- 1595
										SetNextItemOpen(game.exampleOpen) -- 1596
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1597
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1598
												Columns(maxColumns, false) -- 1599
												for _index_1 = 1, #examples do -- 1600
													local example = examples[_index_1] -- 1600
													local entryName = example.entryName -- 1601
													if not allEntries.match(entryName) then -- 1602
														goto _continue_0 -- 1602
													end -- 1602
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1603
														if Button(entryName, Vec2(-1, 40)) then -- 1604
															enterDemoEntry(example) -- 1605
														end -- 1604
														return NextColumn() -- 1606
													end) -- 1603
													opened = true -- 1607
													::_continue_0:: -- 1601
												end -- 1600
											end) -- 1598
										end) -- 1597
										game.exampleOpen = opened -- 1608
									end -- 1589
								end -- 1585
								if #tests > 0 then -- 1609
									local showTest = false -- 1610
									for _index_1 = 1, #tests do -- 1611
										local _des_0 = tests[_index_1] -- 1611
										local entryName = _des_0.entryName -- 1611
										if allEntries.match(entryName) then -- 1612
											showTest = true -- 1612
											break -- 1612
										end -- 1612
									end -- 1611
									if showTest then -- 1613
										showSep = true -- 1614
										Columns(1, false) -- 1615
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1616
										SameLine() -- 1617
										local opened -- 1618
										if (filterText ~= nil) then -- 1618
											opened = showTest -- 1618
										else -- 1618
											opened = false -- 1618
										end -- 1618
										if game.testOpen == nil then -- 1619
											game.testOpen = opened -- 1619
										end -- 1619
										SetNextItemOpen(game.testOpen) -- 1620
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1621
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1622
												Columns(maxColumns, false) -- 1623
												for _index_1 = 1, #tests do -- 1624
													local test = tests[_index_1] -- 1624
													local entryName = test.entryName -- 1625
													if not allEntries.match(entryName) then -- 1626
														goto _continue_0 -- 1626
													end -- 1626
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1627
														if Button(entryName, Vec2(-1, 40)) then -- 1628
															enterDemoEntry(test) -- 1629
														end -- 1628
														return NextColumn() -- 1630
													end) -- 1627
													opened = true -- 1631
													::_continue_0:: -- 1625
												end -- 1624
											end) -- 1622
										end) -- 1621
										game.testOpen = opened -- 1632
									end -- 1613
								end -- 1609
								if showSep then -- 1633
									Columns(1, false) -- 1634
									allEntries.thinSep() -- 1635
									Columns(columns, false) -- 1636
								end -- 1633
							end -- 1536
						end -- 1532
						if #doraTools > 0 then -- 1637
							local showTool = false -- 1638
							for _index_0 = 1, #doraTools do -- 1639
								local _des_0 = doraTools[_index_0] -- 1639
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1639
								local displayName -- 1640
								if repo then -- 1640
									if zh then -- 1641
										displayName = repo.title.zh -- 1641
									else -- 1641
										displayName = repo.title.en -- 1641
									end -- 1641
								end -- 1640
								if displayName == nil then -- 1642
									displayName = entryName -- 1642
								end -- 1642
								if allEntries.match(displayName) then -- 1643
									showTool = true -- 1643
									break -- 1643
								end -- 1643
							end -- 1639
							if not showTool then -- 1644
								goto endEntry -- 1644
							end -- 1644
							Columns(1, false) -- 1645
							TextColored(themeColor, "Dora SSR:") -- 1646
							SameLine() -- 1647
							Text(zh and "开发支持" or "Development Support") -- 1648
							Separator() -- 1649
							if #doraTools > 0 then -- 1650
								local opened -- 1651
								if (filterText ~= nil) then -- 1651
									opened = showTool -- 1651
								else -- 1651
									opened = false -- 1651
								end -- 1651
								SetNextItemOpen(toolOpen) -- 1652
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1653
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1654
										Columns(maxColumns, false) -- 1655
										for _index_0 = 1, #doraTools do -- 1656
											local tool = doraTools[_index_0] -- 1656
											local entryName, repo = tool.entryName, tool.repo -- 1657
											local displayName -- 1658
											if repo then -- 1658
												if zh then -- 1659
													displayName = repo.title.zh -- 1659
												else -- 1659
													displayName = repo.title.en -- 1659
												end -- 1659
											end -- 1658
											if displayName == nil then -- 1660
												displayName = entryName -- 1660
											end -- 1660
											if not allEntries.match(displayName) then -- 1661
												goto _continue_0 -- 1661
											end -- 1661
											if Button(displayName, Vec2(-1, 40)) then -- 1662
												enterDemoEntry(tool) -- 1663
											end -- 1662
											NextColumn() -- 1664
											::_continue_0:: -- 1657
										end -- 1656
										Columns(1, false) -- 1665
										opened = true -- 1666
									end) -- 1654
								end) -- 1653
								toolOpen = opened -- 1667
							end -- 1650
						end -- 1637
						::endEntry:: -- 1668
						if not allEntries.anyEntryMatched then -- 1669
							SetNextWindowBgAlpha(0) -- 1670
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1671
							Begin("Entries Not Found", displayWindowFlags, function() -- 1672
								Separator() -- 1673
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1674
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1675
								return Separator() -- 1676
							end) -- 1672
						end -- 1669
						Columns(1, false) -- 1677
						Dummy(Vec2(100, 80)) -- 1678
						return ScrollWhenDraggingOnVoid() -- 1679
					end) -- 1525
				end) -- 1524
			end) -- 1523
		end) -- 1522
	end -- 1521
end) -- 1438
if not (App.platform == "Emscripten") then -- 1684
	local sceneModuleCache = moduleCache -- 1685
	moduleCache = { } -- 1686
	webStatus = oldRequire("Script.Dev.WebServer") -- 1687
	moduleCache = sceneModuleCache -- 1688
end -- 1684
local _anon_func_7 = function(saved) -- 1711
	local _val_0 = saved.kind -- 1711
	return "local" == _val_0 or "discover" == _val_0 -- 1711
end -- 1711
local _anon_func_8 = function(saved) -- 1715
	local _val_0 = saved.activeTab -- 1715
	return "local" == _val_0 or "discover" == _val_0 -- 1715
end -- 1715
startMobileUI = function() -- 1690
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1691
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1692
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1693
	local getMobileFeedResources -- 1694
	do -- 1694
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1694
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1694
	end -- 1694
	local loadCachedCatalog -- 1695
	do -- 1695
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1695
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1695
	end -- 1695
	local getResourceInstallPath, getInstalledCatalogResource -- 1696
	do -- 1696
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1696
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1696
	end -- 1696
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1697
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1698
	local feedOptions = nil -- 1699
	local mobileLaunchErrors = { } -- 1700
	local withMobileLaunchErrors -- 1701
	withMobileLaunchErrors = function(items) -- 1701
		for _index_0 = 1, #items do -- 1702
			local item = items[_index_0] -- 1702
			item.launchError = mobileLaunchErrors[item.id] -- 1703
		end -- 1702
		return items -- 1704
	end -- 1701
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1705
	local loadRememberedMobileFeedState -- 1706
	loadRememberedMobileFeedState = function() -- 1706
		local raw = rememberedMobileFeedData -- 1707
		if not (type(raw) == "string" and raw ~= "") then -- 1708
			return -- 1708
		end -- 1708
		local ok, saved = pcall(json.decode, raw) -- 1709
		if not (ok and type(saved) == "table") then -- 1710
			return -- 1710
		end -- 1710
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1711
			local state = { -- 1712
				activeTab = saved.kind -- 1712
			} -- 1712
			state[saved.kind] = saved -- 1713
			return state -- 1714
		end -- 1711
		local state = { -- 1715
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1715
		} -- 1715
		local _list_0 = { -- 1716
			"local", -- 1716
			"discover" -- 1716
		} -- 1716
		for _index_0 = 1, #_list_0 do -- 1716
			local kind = _list_0[_index_0] -- 1716
			local entry = saved[kind] -- 1717
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1718
				state[kind] = entry -- 1718
			end -- 1718
		end -- 1716
		return state -- 1719
	end -- 1706
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1720
		activeTab = "local" -- 1720
	} -- 1720
	local rememberMobileFeedEntry -- 1721
	rememberMobileFeedEntry = function(entry) -- 1721
		rememberedMobileFeedState.activeTab = entry.kind -- 1722
		rememberedMobileFeedState[entry.kind] = { -- 1724
			id = entry.id, -- 1724
			kind = entry.kind, -- 1725
			workDir = entry.workDir, -- 1726
			fileName = entry.fileName -- 1727
		} -- 1723
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1729
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1730
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1731
			rememberedMobileFeedData -- 1731
		}) -- 1731
	end -- 1721
	local restartMobileFeed -- 1732
	restartMobileFeed = function(entry) -- 1732
		if feedHost then -- 1733
			feedHost:removeFromParent(true) -- 1733
		end -- 1733
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1734
		local initialEntries = { } -- 1735
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1736
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1737
		feedOptions.initialEntries = initialEntries -- 1738
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1739
	end -- 1732
	local startMobilePlay -- 1740
	startMobilePlay = function(entry) -- 1740
		if HttpServer.wsConnectionCount > 0 then -- 1741
			return -- 1741
		end -- 1741
		local originFeed = feedHost -- 1742
		if remixHost then -- 1743
			remixHost:removeFromParent(true) -- 1743
		end -- 1743
		remixHost = nil -- 1744
		mobileLaunchErrors[entry.id] = nil -- 1745
		entry.launchError = nil -- 1746
		local playActive = true -- 1747
		local restoreMobileFeed -- 1748
		restoreMobileFeed = function() -- 1748
			if not playActive then -- 1749
				return -- 1749
			end -- 1749
			playActive = false -- 1750
			allClear() -- 1751
			isInEntry = true -- 1752
			currentEntry = nil -- 1753
			return restartMobileFeed(entry) -- 1754
		end -- 1748
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1756
			onExit = function() -- 1756
				return restoreMobileFeed() -- 1756
			end, -- 1756
			onRuntimeError = function() -- 1757
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1758
				return restoreMobileFeed() -- 1759
			end -- 1757
		})) -- 1755
		return thread(function() -- 1761
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1765
			if not playActive then -- 1766
				return -- 1766
			end -- 1766
			if success then -- 1767
				if originFeed and originFeed.parent then -- 1768
					originFeed.visible = false -- 1768
				end -- 1768
				return -- 1769
			end -- 1767
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1770
			return restoreMobileFeed() -- 1771
		end) -- 1761
	end -- 1740
	feedOptions = { -- 1773
		takeReceivedFile = function() -- 1773
			if allEntries.pendingPackagePath then -- 1774
				local path = allEntries.pendingPackagePath -- 1775
				allEntries.pendingPackagePath = nil -- 1776
				return path -- 1777
			end -- 1774
			return App:takeReceivedFile() -- 1778
		end, -- 1773
		onSwitchMode = function() -- 1779
			if HttpServer.wsConnectionCount == 0 then -- 1779
				pendingUIMode = false -- 1779
			end -- 1779
		end, -- 1779
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1780
		getLocalEntries = function(importedProjectPath) -- 1781
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1782
			feedOptions.dirtyProjectPath = nil -- 1783
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1784
			local cached = loadCachedCatalog() -- 1785
			if cached.success and cached.snapshot then -- 1786
				for _index_0 = 1, #items do -- 1787
					local entry = items[_index_0] -- 1787
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1788
					if resource then -- 1789
						entry.resource = resource -- 1790
						entry.catalogCommit = cached.snapshot.commit -- 1791
					end -- 1789
				end -- 1787
			end -- 1786
			return items -- 1792
		end, -- 1781
		syncDiscover = function(onProgress, onDone, force) -- 1793
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1793
		end, -- 1793
		getDiscoverEntries = function() -- 1794
			local cached = loadCachedCatalog() -- 1795
			if not (cached.success and cached.snapshot) then -- 1796
				return { } -- 1796
			end -- 1796
			local items = { } -- 1797
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1798
			for _index_0 = 1, #_list_0 do -- 1798
				local resource = _list_0[_index_0] -- 1798
				local installed = lifecycle.isMobileResourceReady(resource) -- 1799
				local installPath = getResourceInstallPath(resource.id) -- 1800
				items[#items + 1] = { -- 1802
					id = resource.id, -- 1802
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1803
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1804
					kind = "discover", -- 1805
					bannerFile = resource.bannerPath, -- 1806
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1807
					sourceUrl = resource.versions[1].sources[1].url, -- 1808
					workDir = installed and installPath or nil, -- 1809
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1810
					installed = installed, -- 1811
					resource = resource, -- 1812
					catalogCommit = cached.snapshot.commit, -- 1813
					launchError = mobileLaunchErrors[resource.id] -- 1814
				} -- 1801
			end -- 1798
			return items -- 1816
		end, -- 1794
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1817
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1818
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1819
			end), repairIncomplete, isCanceled) -- 1818
		end, -- 1817
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1821
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1822
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1823
			end), isCanceled) -- 1822
		end, -- 1821
		createProject = function(name, language) -- 1825
			local result = projectCreate.createMobileProject(name, language) -- 1826
			if not result.success then -- 1827
				return result -- 1827
			end -- 1827
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1828
			for _index_0 = 1, #_list_0 do -- 1828
				local entry = _list_0[_index_0] -- 1828
				if entry.workDir == result.workDir then -- 1829
					return { -- 1830
						success = true, -- 1830
						entry = entry -- 1830
					} -- 1830
				end -- 1829
			end -- 1828
			return { -- 1831
				success = false, -- 1831
				error = "created-project-not-found" -- 1831
			} -- 1831
		end, -- 1825
		onPlay = function(entry) -- 1832
			return startMobilePlay(entry) -- 1832
		end, -- 1832
		onRemix = function(entry) -- 1833
			if HttpServer.wsConnectionCount > 0 then -- 1834
				return -- 1834
			end -- 1834
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1835
			local originFeed = feedHost -- 1836
			feedHost.visible = false -- 1837
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1839
				entry = entry, -- 1839
				onProjectChanged = function(current) -- 1840
					feedOptions.dirtyProjectPath = current.workDir -- 1840
				end, -- 1840
				onBack = function() -- 1841
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1842
						originFeed:emit("RestoreFeedEntry", entry) -- 1843
						originFeed.visible = true -- 1844
					end -- 1842
				end, -- 1841
				onPlay = function(current) -- 1845
					return startMobilePlay(current) -- 1845
				end -- 1845
			})) -- 1838
		end -- 1833
	} -- 1772
	return restartMobileFeed() -- 1848
end -- 1690
if mobileMode then -- 1850
	applyUIMode(true) -- 1850
end -- 1850
return _module_0 -- 1
