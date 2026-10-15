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
	if Content:exist(Path(writablePath, ".upload")) then -- 776
		Content:remove(Path(writablePath, ".upload")) -- 776
	end -- 776
	if Content:exist(Path(writablePath, ".download")) then -- 777
		return Content:remove(Path(writablePath, ".download")) -- 777
	end -- 777
end -- 774
local waitForWebStart = true -- 779
thread(function() -- 780
	sleep(2) -- 781
	waitForWebStart = false -- 782
end) -- 780
local reloadDevEntry -- 784
reloadDevEntry = function() -- 784
	return thread(function() -- 784
		waitForWebStart = true -- 785
		doClean() -- 786
		allClear() -- 787
		_G.require = oldRequire -- 788
		Dora.require = oldRequire -- 789
		package.loaded["Script.Dev.Entry"] = nil -- 790
		package.loaded["Script.Dev.WebServer"] = nil -- 791
		return Director.systemScheduler:schedule(function() -- 792
			Routine:clear() -- 793
			oldRequire("Script.Dev.Entry") -- 794
			return true -- 795
		end) -- 792
	end) -- 784
end -- 784
local setWorkspace -- 797
setWorkspace = function(path) -- 797
	clearTempFiles() -- 798
	Content.writablePath = path -- 799
	config.writablePath = Content.writablePath -- 800
	return thread(function() -- 801
		sleep() -- 802
		return reloadDevEntry() -- 803
	end) -- 801
end -- 797
_module_0["setWorkspace"] = setWorkspace -- 797
local quit = false -- 805
local activeSearchId = 0 -- 807
local handleSearchFiles -- 809
handleSearchFiles = function(payload) -- 809
	if not payload then -- 810
		return -- 810
	end -- 810
	local id = payload.id -- 811
	if id == nil then -- 812
		return -- 812
	end -- 812
	activeSearchId = id -- 813
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 814
	if path == nil then -- 815
		path = "" -- 815
	end -- 815
	if exts == nil then -- 816
		exts = { } -- 816
	end -- 816
	if globs == nil then -- 817
		globs = { } -- 817
	end -- 817
	if extensionLevels == nil then -- 818
		extensionLevels = { } -- 818
	end -- 818
	if pattern == nil then -- 819
		pattern = "" -- 819
	end -- 819
	if pattern == "" then -- 821
		return -- 821
	end -- 821
	local useRegex = payload.useRegex == true -- 822
	local caseSensitive = payload.caseSensitive == true -- 823
	local includeContent = payload.includeContent ~= false -- 824
	local contentWindow = payload.contentWindow or 0 -- 825
	return Director.systemScheduler:schedule(once(function() -- 826
		local stopped = false -- 827
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 828
			if activeSearchId ~= id then -- 829
				stopped = true -- 830
				return true -- 831
			end -- 829
			emit("AppWS", "Send", json.encode({ -- 833
				name = "SearchFilesResult", -- 833
				id = id, -- 833
				result = result -- 833
			})) -- 832
			return false -- 835
		end) -- 828
		return emit("AppWS", "Send", json.encode({ -- 837
			name = "SearchFilesDone", -- 837
			id = id, -- 837
			stopped = stopped -- 837
		})) -- 836
	end)) -- 826
end -- 809
local stop -- 840
stop = function() -- 840
	if isInEntry then -- 841
		return false -- 841
	end -- 841
	allClear() -- 842
	isInEntry = true -- 843
	currentEntry = nil -- 844
	return true -- 845
end -- 840
_module_0["stop"] = stop -- 840
local getCurrentEntryStatus -- 847
getCurrentEntryStatus = function() -- 847
	local entry = currentEntry -- 848
	if not (entry and not isInEntry) then -- 849
		return { -- 849
			success = true, -- 849
			running = false, -- 849
			runId = allEntries.runId -- 849
		} -- 849
	end -- 849
	local status = { -- 851
		success = true, -- 851
		running = true, -- 852
		kind = entry.runKind or "file", -- 853
		runId = allEntries.runId, -- 854
		entryName = entry.entryName, -- 855
		fileName = entry.fileName -- 856
	} -- 850
	if entry.workDir then -- 857
		status.workDir = entry.workDir -- 857
	end -- 857
	if entry.projectRoot then -- 858
		status.projectRoot = entry.projectRoot -- 858
	end -- 858
	return status -- 859
end -- 847
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 847
local _anon_func_2 = function(_with_0) -- 878
	local _val_0 = App.platform -- 878
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 878
end -- 878
setupEventHandlers = function() -- 861
	local _with_0 = Director.postNode -- 862
	_with_0:onAppEvent(function(eventType) -- 863
		if "Quit" == eventType then -- 864
			quit = true -- 865
			allClear() -- 866
			return clearTempFiles() -- 867
		elseif "Shutdown" == eventType then -- 868
			return stop() -- 869
		end -- 863
	end) -- 863
	_with_0:onAppChange(function(settingName) -- 870
		if "Theme" == settingName then -- 871
			config.themeColor = App.themeColor:toARGB() -- 872
		elseif "Locale" == settingName then -- 873
			config.locale = App.locale -- 874
			updateLocale() -- 875
			return teal.clear(true) -- 876
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 877
			if _anon_func_2(_with_0) then -- 878
				if "FullScreen" == settingName then -- 880
					config.fullScreen = App.fullScreen -- 880
				elseif "Position" == settingName then -- 881
					local _obj_0 = App.winPosition -- 881
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 881
				elseif "Size" == settingName then -- 882
					local width, height -- 883
					do -- 883
						local _obj_0 = App.winSize -- 883
						width, height = _obj_0.width, _obj_0.height -- 883
					end -- 883
					config.winWidth = width -- 884
					config.winHeight = height -- 885
				end -- 879
			end -- 878
		end -- 870
	end) -- 870
	_with_0:onAppWS(function(event) -- 886
		if event.type == "Close" then -- 887
			if HttpServer.wsConnectionCount == 0 then -- 888
				updateEntries() -- 889
			end -- 888
			return -- 890
		end -- 887
		if not (event.type == "Receive") then -- 891
			return -- 891
		end -- 891
		local data = json.decode(event.msg) -- 892
		if not data then -- 893
			return -- 893
		end -- 893
		local _exp_0 = data.name -- 894
		if "SearchFiles" == _exp_0 then -- 895
			return handleSearchFiles(data) -- 896
		elseif "SearchFilesStop" == _exp_0 then -- 897
			if data.id == nil or data.id == activeSearchId then -- 898
				activeSearchId = 0 -- 899
			end -- 898
		end -- 894
	end) -- 886
	_with_0:slot("UpdateEntries", function() -- 900
		return updateEntries() -- 900
	end) -- 900
	return _with_0 -- 862
end -- 861
setupEventHandlers() -- 902
clearTempFiles() -- 903
local downloadFile -- 905
downloadFile = function(url, target) -- 905
	return Director.systemScheduler:schedule(once(function() -- 905
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 906
			if quit then -- 907
				return true -- 907
			end -- 907
			emit("AppWS", "Send", json.encode({ -- 909
				name = "Download", -- 909
				url = url, -- 909
				status = "downloading", -- 909
				progress = current / total -- 910
			})) -- 908
			return false -- 906
		end) -- 906
		return emit("AppWS", "Send", json.encode(success and { -- 913
			name = "Download", -- 913
			url = url, -- 913
			status = "completed", -- 913
			progress = 1.0 -- 914
		} or { -- 916
			name = "Download", -- 916
			url = url, -- 916
			status = "failed", -- 916
			progress = 0.0 -- 917
		})) -- 912
	end)) -- 905
end -- 905
_module_0["downloadFile"] = downloadFile -- 905
local _anon_func_3 = function(file, require, workDir) -- 929
	if workDir == nil then -- 929
		workDir = Path:getPath(file) -- 929
	end -- 929
	Content:insertSearchPath(1, workDir) -- 930
	local scriptPath = Path(workDir, "Script") -- 931
	if Content:exist(scriptPath) then -- 932
		Content:insertSearchPath(1, scriptPath) -- 933
	end -- 932
	local result = require(file) -- 934
	if "function" == type(result) then -- 935
		result() -- 935
	end -- 935
	return nil -- 936
end -- 929
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 965
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 965
	label.alignment = "Left" -- 966
	label.textWidth = width - fontSize -- 967
	label.text = err -- 968
	return label -- 965
end -- 965
local enterEntryAsync -- 920
enterEntryAsync = function(entry) -- 920
	allEntries.runId = allEntries.runId + 1 -- 921
	isInEntry = false -- 922
	App.idled = false -- 923
	emit(Profiler.EventName, "ClearLoader") -- 924
	currentEntry = entry -- 925
	local file, workDir = entry.fileName, entry.workDir -- 926
	sleep() -- 927
	return xpcall(_anon_func_3, function(msg) -- 936
		local err = debug.traceback(msg) -- 938
		Log("Error", err) -- 939
		allClear() -- 940
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 941
		local viewWidth, viewHeight -- 942
		do -- 942
			local _obj_0 = View.size -- 942
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 942
		end -- 942
		local width, height = viewWidth - 20, viewHeight - 20 -- 943
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 944
		Director.ui:addChild((function() -- 945
			local root = AlignNode() -- 945
			do -- 946
				local _obj_0 = App.bufferSize -- 946
				width, height = _obj_0.width, _obj_0.height -- 946
			end -- 946
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 947
			root:onAppChange(function(settingName) -- 948
				if settingName == "Size" then -- 948
					do -- 949
						local _obj_0 = App.bufferSize -- 949
						width, height = _obj_0.width, _obj_0.height -- 949
					end -- 949
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 950
				end -- 948
			end) -- 948
			root:addChild((function() -- 951
				local _with_0 = ScrollArea({ -- 952
					width = width, -- 952
					height = height, -- 953
					paddingX = 0, -- 954
					paddingY = 50, -- 955
					viewWidth = height, -- 956
					viewHeight = height -- 957
				}) -- 951
				root:onAlignLayout(function(w, h) -- 959
					_with_0.position = Vec2(w / 2, h / 2) -- 960
					w = w - 20 -- 961
					h = h - 20 -- 962
					_with_0.view.children.first.textWidth = w - fontSize -- 963
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 964
				end) -- 959
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 965
				return _with_0 -- 951
			end)()) -- 951
			return root -- 945
		end)()) -- 945
		return err -- 969
	end, file, require, workDir) -- 928
end -- 920
_module_0["enterEntryAsync"] = enterEntryAsync -- 920
local enterDemoEntry -- 971
enterDemoEntry = function(entry) -- 971
	return thread(function() -- 971
		return enterEntryAsync(entry) -- 971
	end) -- 971
end -- 971
local reloadCurrentEntry -- 973
reloadCurrentEntry = function() -- 973
	if currentEntry then -- 974
		allClear() -- 975
		return enterDemoEntry(currentEntry) -- 976
	end -- 974
end -- 973
Director.clearColor = Color(0xff1a1a1a) -- 978
local descColor = Color(0xffa1a1a1) -- 979
local extraOperations -- 981
do -- 981
	local isOSSLicenseExist = Content:exist("LICENSES") -- 982
	local ossLicenses = nil -- 983
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 984
	local failedSetFolder = false -- 985
	local statusFlags = { -- 986
		"NoResize", -- 986
		"NoMove", -- 986
		"NoCollapse", -- 986
		"AlwaysAutoResize", -- 986
		"NoSavedSettings" -- 986
	} -- 986
	extraOperations = function() -- 993
		local zh = useChinese -- 994
		if isDesktop then -- 995
			local alwaysOnTop = config.alwaysOnTop -- 996
			do -- 997
				local changed -- 997
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 997
				if changed then -- 997
					App.alwaysOnTop = alwaysOnTop -- 998
					config.alwaysOnTop = alwaysOnTop -- 999
				end -- 997
			end -- 997
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1000
			do -- 1001
				local changed -- 1001
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1001
				if changed then -- 1001
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1002
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1003
				end -- 1001
			end -- 1001
			SameLine() -- 1004
			TextColored(descColor, "(?)") -- 1005
			if IsItemHovered() then -- 1006
				BeginTooltip(function() -- 1007
					return PushTextWrapPos(360, function() -- 1008
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

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1009
					end) -- 1008
				end) -- 1007
			end -- 1006
		end -- 995
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1024
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
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1035
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1036
			if changed then -- 1036
				config.webIDEEnabled = webIDEEnabled -- 1037
				App.webIDEEnabled = webIDEEnabled -- 1038
			end -- 1036
		end -- 1035
		do -- 1039
			local themeColor = App.themeColor -- 1040
			local writablePath = config.writablePath -- 1041
			SeparatorText(zh and "工作目录" or "Workspace") -- 1042
			PushTextWrapPos(400, function() -- 1043
				return TextColored(themeColor, writablePath) -- 1044
			end) -- 1043
			if not isDesktop then -- 1045
				goto skipSetting -- 1045
			end -- 1045
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1046
			if Button(zh and "改变目录" or "Set Folder") then -- 1047
				App:openFileDialog(true, function(path) -- 1048
					if path == "" then -- 1049
						return -- 1049
					end -- 1049
					local relPath = Path:getRelative(Content.assetPath, path) -- 1050
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1051
						return setWorkspace(path) -- 1052
					else -- 1054
						failedSetFolder = true -- 1054
					end -- 1051
				end) -- 1048
			end -- 1047
			if failedSetFolder then -- 1055
				failedSetFolder = false -- 1056
				OpenPopup(popupName) -- 1057
			end -- 1055
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1058
			BeginPopupModal(popupName, statusFlags, function() -- 1059
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1060
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1061
					return CloseCurrentPopup() -- 1062
				end -- 1061
			end) -- 1059
			SameLine() -- 1063
			if Button(zh and "使用默认" or "Use Default") then -- 1064
				setWorkspace(Content.appPath) -- 1065
			end -- 1064
			Separator() -- 1066
			::skipSetting:: -- 1067
		end -- 1039
		if isOSSLicenseExist then -- 1068
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1069
				if not ossLicenses then -- 1070
					local licenseText = Content:load("LICENSES") -- 1071
					if licenseText then -- 1071
						ossLicenses = { } -- 1072
						licenseText = licenseText:gsub("\r\n", "\n") -- 1073
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1074
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1075
							if name then -- 1075
								ossLicenses[#ossLicenses + 1] = { -- 1076
									name, -- 1076
									text -- 1076
								} -- 1076
							end -- 1075
						end -- 1074
					end -- 1071
				end -- 1070
				if ossLicenses then -- 1077
					OpenPopup(ossLicensePopup) -- 1077
				end -- 1077
			end -- 1069
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1078
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1079
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1080
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1081
				return BeginPopupModal(ossLicensePopup, true, { -- 1084
					"NoSavedSettings" -- 1084
				}, function() -- 1085
					for _index_0 = 1, #ossLicenses do -- 1086
						local _des_0 = ossLicenses[_index_0] -- 1086
						local firstLine, text = _des_0[1], _des_0[2] -- 1086
						local name, license = firstLine:match("(.+): (.+)") -- 1088
						if name then -- 1088
							TextColored(themeColor, name) -- 1089
							SameLine() -- 1090
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1091
								return TextWrapped(text) -- 1091
							end) -- 1091
						end -- 1088
					end -- 1086
				end) -- 1081
			end) -- 1081
		end -- 1068
		if not App.debugging then -- 1094
			return -- 1094
		end -- 1094
		return TreeNode(zh and "开发操作" or "Development", function() -- 1095
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1096
				OpenPopup("build") -- 1096
			end -- 1096
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1097
				return BeginPopup("build", function() -- 1097
					if Selectable(zh and "编译" or "Compile") then -- 1098
						doCompile(false) -- 1098
					end -- 1098
					Separator() -- 1099
					if Selectable(zh and "压缩" or "Minify") then -- 1100
						doCompile(true) -- 1100
					end -- 1100
					Separator() -- 1101
					if Selectable(zh and "清理" or "Clean") then -- 1102
						return doClean() -- 1102
					end -- 1102
				end) -- 1097
			end) -- 1097
			if isInEntry then -- 1103
				if waitForWebStart then -- 1104
					BeginDisabled(function() -- 1105
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1105
					end) -- 1105
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1106
					reloadDevEntry() -- 1107
				end -- 1104
			end -- 1103
			do -- 1108
				local changed -- 1108
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1108
				if changed then -- 1108
					View.scale = scaleContent and screenScale or 1 -- 1109
				end -- 1108
			end -- 1108
			do -- 1110
				local changed -- 1110
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1110
				if changed then -- 1110
					config.engineDev = engineDev -- 1111
				end -- 1110
			end -- 1110
			do -- 1112
				local changed -- 1112
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1112
				if changed then -- 1112
					config.webIDETourCompleted = webIDETourCompleted -- 1113
				end -- 1112
			end -- 1112
			if testingThread then -- 1114
				return BeginDisabled(function() -- 1115
					return Button(zh and "开始自动测试" or "Test automatically") -- 1115
				end) -- 1115
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1116
				testingThread = thread(function() -- 1117
					local _ <close> = setmetatable({ }, { -- 1118
						__close = function() -- 1118
							allClear() -- 1119
							testingThread = nil -- 1120
							isInEntry = true -- 1121
							currentEntry = nil -- 1122
							return print("Testing done!") -- 1123
						end -- 1118
					}) -- 1118
					for _, entry in ipairs(allEntries) do -- 1124
						allClear() -- 1125
						print("Start " .. tostring(entry.entryName)) -- 1126
						enterDemoEntry(entry) -- 1127
						sleep(2) -- 1128
						print("Stop " .. tostring(entry.entryName)) -- 1129
					end -- 1124
				end) -- 1117
			end -- 1114
		end) -- 1095
	end -- 993
end -- 981
local icon = Path("Script", "Dev", "icon_s.png") -- 1131
local iconTex = nil -- 1132
thread(function() -- 1133
	if Cache:loadAsync(icon) then -- 1133
		iconTex = Texture2D(icon) -- 1133
	end -- 1133
end) -- 1133
local webStatus = nil -- 1135
local urlClicked = nil -- 1136
local authCode = string.format("%06d", math.random(0, 999999)) -- 1138
local authCodeTTL = 30.0 -- 1140
_module_0.getAuthCode = function() -- 1141
	return authCode -- 1141
end -- 1141
_module_0.invalidateAuthCode = function() -- 1142
	authCode = string.format("%06d", math.random(0, 999999)) -- 1143
	authCodeTTL = 30.0 -- 1144
end -- 1142
local AuthSession -- 1146
do -- 1146
	local pending = nil -- 1147
	local session = nil -- 1148
	AuthSession = { -- 1150
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1150
			pending = { -- 1152
				sessionId = sessionId, -- 1152
				confirmCode = confirmCode, -- 1153
				expiresAt = expiresAt, -- 1154
				ttl = ttl, -- 1155
				approved = false -- 1156
			} -- 1151
		end, -- 1150
		getPending = function() -- 1158
			return pending -- 1158
		end, -- 1158
		approvePending = function(sessionId) -- 1160
			if pending and pending.sessionId == sessionId then -- 1161
				pending.approved = true -- 1162
				return true -- 1163
			end -- 1161
			return false -- 1164
		end, -- 1160
		clearPending = function() -- 1166
			pending = nil -- 1166
		end, -- 1166
		setSession = function(sessionId, sessionSecret) -- 1168
			session = { -- 1170
				sessionId = sessionId, -- 1170
				sessionSecret = sessionSecret -- 1171
			} -- 1169
		end, -- 1168
		getSession = function() -- 1173
			return session -- 1173
		end -- 1173
	} -- 1149
end -- 1146
_module_0["AuthSession"] = AuthSession -- 1146
local transparant = Color(0x0) -- 1176
local windowFlags = { -- 1177
	"NoTitleBar", -- 1177
	"NoResize", -- 1177
	"NoMove", -- 1177
	"NoCollapse", -- 1177
	"NoSavedSettings", -- 1177
	"NoFocusOnAppearing", -- 1177
	"NoBringToFrontOnFocus" -- 1177
} -- 1177
local statusFlags = { -- 1186
	"NoTitleBar", -- 1186
	"NoResize", -- 1186
	"NoMove", -- 1186
	"NoCollapse", -- 1186
	"AlwaysAutoResize", -- 1186
	"NoSavedSettings" -- 1186
} -- 1186
local displayWindowFlags = { -- 1194
	"NoDecoration", -- 1194
	"NoSavedSettings", -- 1194
	"NoMove", -- 1194
	"NoScrollWithMouse", -- 1194
	"AlwaysAutoResize", -- 1194
	"NoFocusOnAppearing" -- 1194
} -- 1194
local gamepadInputWindowFlags = { -- 1202
	"NoDecoration", -- 1202
	"NoSavedSettings", -- 1202
	"NoMove", -- 1202
	"NoScrollbar", -- 1202
	"NoScrollWithMouse", -- 1202
	"NoFocusOnAppearing", -- 1202
	"NoBringToFrontOnFocus" -- 1202
} -- 1202
local initFooter = true -- 1211
local gamepadInputFocused = false -- 1212
local _anon_func_5 = function(allEntries, currentIndex) -- 1258
	if currentIndex > 1 then -- 1258
		return allEntries[currentIndex - 1] -- 1259
	else -- 1261
		return allEntries[#allEntries] -- 1261
	end -- 1258
end -- 1258
local _anon_func_6 = function(allEntries, currentIndex) -- 1265
	if currentIndex < #allEntries then -- 1265
		return allEntries[currentIndex + 1] -- 1266
	else -- 1268
		return allEntries[1] -- 1268
	end -- 1265
end -- 1265
footerWindow = threadLoop(function() -- 1213
	if mobileMode then -- 1214
		return -- 1214
	end -- 1214
	local zh = useChinese -- 1215
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1216
	if authCodeTTL <= 0 then -- 1217
		authCodeTTL = 30.0 -- 1218
		authCode = string.format("%06d", math.random(0, 999999)) -- 1219
	end -- 1217
	if HttpServer.wsConnectionCount > 0 then -- 1220
		return -- 1221
	end -- 1220
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1222
		if App.platform == "Emscripten" then -- 1223
			stop() -- 1225
		else -- 1227
			allClear() -- 1227
			App.devMode = false -- 1228
			App:shutdown() -- 1229
		end -- 1223
	end -- 1222
	do -- 1230
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1231
		if ctrl and Keyboard:isKeyDown("Q") then -- 1232
			stop() -- 1233
		end -- 1232
		if ctrl and Keyboard:isKeyDown("Z") then -- 1234
			reloadCurrentEntry() -- 1235
		end -- 1234
		if ctrl and Keyboard:isKeyDown(",") then -- 1236
			if showFooter then -- 1237
				showStats = not showStats -- 1237
			else -- 1237
				showStats = true -- 1237
			end -- 1237
			showFooter = true -- 1238
			config.showFooter = showFooter -- 1239
			config.showStats = showStats -- 1240
		end -- 1236
		if ctrl and Keyboard:isKeyDown(".") then -- 1241
			if showFooter then -- 1242
				showConsole = not showConsole -- 1242
			else -- 1242
				showConsole = true -- 1242
			end -- 1242
			showFooter = true -- 1243
			config.showFooter = showFooter -- 1244
			config.showConsole = showConsole -- 1245
		end -- 1241
		if ctrl and Keyboard:isKeyDown("/") then -- 1246
			showFooter = not showFooter -- 1247
			config.showFooter = showFooter -- 1248
		end -- 1246
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1249
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1250
		local currentIndex = nil -- 1251
		for i, entry in ipairs(allEntries) do -- 1252
			if currentEntry == entry then -- 1253
				currentIndex = i -- 1254
			end -- 1253
		end -- 1252
		if left then -- 1255
			allClear() -- 1256
			if currentIndex == nil then -- 1257
				currentIndex = #allEntries + 1 -- 1257
			end -- 1257
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1258
		end -- 1255
		if right then -- 1262
			allClear() -- 1263
			if currentIndex == nil then -- 1264
				currentIndex = 0 -- 1264
			end -- 1264
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1265
		end -- 1262
	end -- 1230
	if not showEntry then -- 1269
		return -- 1269
	end -- 1269
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1271
		reloadDevEntry() -- 1275
	end -- 1271
	if initFooter then -- 1276
		initFooter = false -- 1277
	end -- 1276
	local width, height -- 1279
	do -- 1279
		local _obj_0 = App.visualSize -- 1279
		width, height = _obj_0.width, _obj_0.height -- 1279
	end -- 1279
	if isInEntry then -- 1280
		gamepadInputFocused = false -- 1281
	else -- 1283
		SetNextWindowBgAlpha(0.0) -- 1283
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1284
		SetNextWindowPos(Vec2.zero, "Always") -- 1285
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1286
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1287
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1288
					if not gamepadInputFocused then -- 1289
						SetWindowFocus("DoraGamepadInput") -- 1290
						gamepadInputFocused = true -- 1291
					end -- 1289
				end) -- 1288
			end) -- 1287
		end) -- 1286
	end -- 1280
	if isInEntry or showFooter then -- 1293
		SetNextWindowSize(Vec2(width, 50)) -- 1294
		SetNextWindowPos(Vec2(0, height - 50)) -- 1295
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1296
			return PushStyleVar("WindowRounding", 0, function() -- 1297
				return Begin("Footer", windowFlags, function() -- 1298
					Separator() -- 1299
					if iconTex then -- 1300
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1301
							showStats = not showStats -- 1302
							config.showStats = showStats -- 1303
						end -- 1301
						SameLine() -- 1304
						if Button(">_", Vec2(30, 30)) then -- 1305
							showConsole = not showConsole -- 1306
							config.showConsole = showConsole -- 1307
						end -- 1305
					end -- 1300
					if isInEntry and config.updateNotification then -- 1308
						SameLine() -- 1309
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1310
							allClear() -- 1311
							config.updateNotification = false -- 1312
							enterDemoEntry({ -- 1314
								entryName = "SelfUpdater", -- 1314
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1315
							}) -- 1313
						end -- 1310
					end -- 1308
					if not isInEntry then -- 1316
						SameLine() -- 1317
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1318
						local currentIndex = nil -- 1319
						for i, entry in ipairs(allEntries) do -- 1320
							if currentEntry == entry then -- 1321
								currentIndex = i -- 1322
							end -- 1321
						end -- 1320
						if currentIndex then -- 1323
							if currentIndex > 1 then -- 1324
								SameLine() -- 1325
								if Button("<<", Vec2(30, 30)) then -- 1326
									allClear() -- 1327
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1328
								end -- 1326
							end -- 1324
							if currentIndex < #allEntries then -- 1329
								SameLine() -- 1330
								if Button(">>", Vec2(30, 30)) then -- 1331
									allClear() -- 1332
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1333
								end -- 1331
							end -- 1329
						end -- 1323
						SameLine() -- 1334
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1335
							reloadCurrentEntry() -- 1336
						end -- 1335
						if back then -- 1337
							allClear() -- 1338
							isInEntry = true -- 1339
							currentEntry = nil -- 1340
						end -- 1337
					end -- 1316
				end) -- 1298
			end) -- 1297
		end) -- 1296
	end -- 1293
	if isInEntry then -- 1342
		local showURL = true -- 1343
		local webIDEWidth -- 1344
		do -- 1344
			local base -- 1345
			if config.updateNotification then -- 1345
				base = 460 -- 1345
			else -- 1345
				base = 360 -- 1345
			end -- 1345
			local extra = 35 -- 1346
			webIDEWidth = base + extra -- 1347
		end -- 1344
		if width < webIDEWidth then -- 1348
			showURL = false -- 1348
		end -- 1348
		SetNextWindowBgAlpha(0.0) -- 1349
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1350
		Begin("Web IDE", displayWindowFlags, function() -- 1351
			local pending = AuthSession.getPending() -- 1352
			local hovered = false -- 1353
			if not pending and showURL then -- 1354
				do -- 1355
					local url -- 1355
					if webStatus ~= nil then -- 1355
						url = webStatus.url -- 1355
					end -- 1355
					if url then -- 1355
						if isDesktop and not config.fullScreen then -- 1356
							if urlClicked then -- 1357
								BeginDisabled(function() -- 1358
									return Button(url) -- 1358
								end) -- 1358
							elseif Button(url) then -- 1359
								urlClicked = once(function() -- 1360
									return sleep(5) -- 1360
								end) -- 1360
								App:openURL("http://localhost:8866") -- 1361
							end -- 1357
						else -- 1363
							TextColored(descColor, url) -- 1363
						end -- 1356
					else -- 1365
						TextColored(descColor, zh and '不可用' or 'not available') -- 1365
					end -- 1355
				end -- 1355
				hovered = IsItemHovered() -- 1366
			else -- 1368
				TextColored(descColor, "(?)") -- 1368
				hovered = IsItemHovered() -- 1369
			end -- 1354
			SameLine() -- 1370
			local themeColor = App.themeColor -- 1371
			if pending then -- 1372
				if not pending.approved then -- 1373
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1374
					local ttl = pending.ttl or 1 -- 1375
					PushStyleColor("Text", themeColor, function() -- 1376
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1377
						hovered = hovered or IsItemHovered() -- 1378
					end) -- 1376
					SameLine() -- 1379
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1380
						AuthSession.approvePending(pending.sessionId) -- 1381
					end -- 1380
					if hovered then -- 1382
						return BeginTooltip(function() -- 1383
							return PushTextWrapPos(280, function() -- 1384
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1385
							end) -- 1384
						end) -- 1383
					end -- 1382
				end -- 1373
			else -- 1387
				PushStyleColor("Text", themeColor, function() -- 1387
					ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1388
					hovered = hovered or IsItemHovered() -- 1389
				end) -- 1387
				if hovered then -- 1390
					return BeginTooltip(function() -- 1391
						return PushTextWrapPos(280, function() -- 1392
							local url -- 1393
							if webStatus ~= nil then -- 1393
								url = webStatus.url -- 1393
							end -- 1393
							if url then -- 1393
								local address -- 1394
								if showURL then -- 1394
									address = "Web IDE" -- 1394
								else -- 1394
									address = url -- 1394
								end -- 1394
								return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1395
							else -- 1397
								return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1397
							end -- 1393
						end) -- 1392
					end) -- 1391
				end -- 1390
			end -- 1372
		end) -- 1351
	end -- 1342
	if not isInEntry then -- 1398
		SetNextWindowSize(Vec2(50, 50)) -- 1399
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1400
		PushStyleColor("WindowBg", transparant, function() -- 1401
			return Begin("Show", displayWindowFlags, function() -- 1401
				if width >= 370 then -- 1402
					local changed -- 1403
					changed, showFooter = Checkbox("##dev", showFooter) -- 1403
					if changed then -- 1403
						config.showFooter = showFooter -- 1404
					end -- 1403
				end -- 1402
			end) -- 1401
		end) -- 1401
	end -- 1398
	if isInEntry or showFooter then -- 1406
		if showStats then -- 1407
			PushStyleVar("WindowRounding", 0, function() -- 1408
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1409
				SetNextWindowSize(Vec2(0, height - 50)) -- 1410
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1411
				config.showStats = showStats -- 1412
			end) -- 1408
		end -- 1407
		if showConsole then -- 1413
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1414
			return PushStyleVar("WindowRounding", 6, function() -- 1415
				return ShowConsole() -- 1416
			end) -- 1415
		end -- 1413
	end -- 1406
end) -- 1213
local MaxWidth <const> = 960 -- 1418
local toolOpen = false -- 1420
local filterText = nil -- 1421
allEntries.anyEntryMatched = false -- 1422
allEntries.match = function(name) -- 1423
	local res = not filterText or name:lower():match(filterText) -- 1424
	if res then -- 1425
		allEntries.anyEntryMatched = true -- 1425
	end -- 1425
	return res -- 1426
end -- 1423
allEntries.thinSep = function() -- 1428
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1428
		return SeparatorText("") -- 1428
	end) -- 1428
end -- 1428
entryWindow = threadLoop(function() -- 1430
	local connected = syncWebIDEControl() -- 1431
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1433
		if not allEntries.pendingPackagePath then -- 1434
			local path = App:takeReceivedFile() -- 1435
			if path ~= "" then -- 1436
				allEntries.pendingPackagePath = path -- 1436
			end -- 1436
		end -- 1434
		if allEntries.pendingPackagePath then -- 1437
			pendingUIMode = true -- 1437
		end -- 1437
	end -- 1433
	if (pendingUIMode ~= nil) then -- 1439
		local nextMode = pendingUIMode -- 1440
		pendingUIMode = nil -- 1441
		applyUIMode(nextMode) -- 1442
	end -- 1439
	if mobileMode and not connected then -- 1443
		if isInEntry and not feedHost then -- 1444
			applyUIMode(true) -- 1444
		end -- 1444
		return -- 1445
	end -- 1443
	if App.fpsLimited ~= config.fpsLimited then -- 1446
		config.fpsLimited = App.fpsLimited -- 1447
	end -- 1446
	if App.targetFPS ~= config.targetFPS then -- 1448
		config.targetFPS = App.targetFPS -- 1449
	end -- 1448
	if View.vsync ~= config.vsync then -- 1450
		config.vsync = View.vsync -- 1451
	end -- 1450
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1452
		config.fixedFPS = Director.scheduler.fixedFPS -- 1453
	end -- 1452
	if Director.profilerSending ~= config.webProfiler then -- 1454
		config.webProfiler = Director.profilerSending -- 1455
	end -- 1454
	if urlClicked then -- 1456
		local _, result = coroutine.resume(urlClicked) -- 1457
		if result then -- 1458
			coroutine.close(urlClicked) -- 1459
			urlClicked = nil -- 1460
		end -- 1458
	end -- 1456
	if not isInEntry then -- 1461
		return -- 1461
	end -- 1461
	local zh = useChinese -- 1462
	local themeColor = App.themeColor -- 1463
	if connected then -- 1464
		local width, height -- 1465
		do -- 1465
			local _obj_0 = App.visualSize -- 1465
			width, height = _obj_0.width, _obj_0.height -- 1465
		end -- 1465
		SetNextWindowBgAlpha(0.5) -- 1466
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1467
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1468
			Separator() -- 1469
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1470
			if iconTex then -- 1471
				Image(icon, Vec2(24, 24)) -- 1472
				SameLine() -- 1473
			end -- 1471
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1474
			TextColored(descColor, slogon) -- 1475
			return Separator() -- 1476
		end) -- 1468
		return -- 1477
	end -- 1464
	if not showEntry then -- 1478
		return -- 1478
	end -- 1478
	local fullWidth, height -- 1480
	do -- 1480
		local _obj_0 = App.visualSize -- 1480
		fullWidth, height = _obj_0.width, _obj_0.height -- 1480
	end -- 1480
	local width = math.min(MaxWidth, fullWidth) -- 1481
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1482
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1483
	SetNextWindowPos(Vec2.zero) -- 1484
	SetNextWindowBgAlpha(0) -- 1485
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1486
	do -- 1487
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1488
			return Begin("Dora Dev", windowFlags, function() -- 1489
				Dummy(Vec2(fullWidth - 20, 0)) -- 1490
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1491
				SameLine() -- 1492
				if Button(zh and "Go 模式" or "Go Mode") then -- 1493
					setUIMode("mobile") -- 1494
				end -- 1493
				if fullWidth >= 540 then -- 1495
					SameLine() -- 1496
					Dummy(Vec2(fullWidth - 540, 0)) -- 1497
					SameLine() -- 1498
					SetNextItemWidth(zh and -95 or -140) -- 1499
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1500
						"AutoSelectAll" -- 1500
					}) then -- 1500
						config.filter = filterBuf.text -- 1501
					end -- 1500
					SameLine() -- 1502
					if Button(zh and '下载' or 'Download') then -- 1503
						allClear() -- 1504
						enterDemoEntry({ -- 1506
							entryName = "ResourceDownloader", -- 1506
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1507
						}) -- 1505
					end -- 1503
				end -- 1495
				return Separator() -- 1508
			end) -- 1489
		end) -- 1488
	end -- 1487
	allEntries.anyEntryMatched = false -- 1510
	SetNextWindowPos(Vec2(0, 50)) -- 1511
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1512
	do -- 1513
		return PushStyleColor("WindowBg", transparant, function() -- 1514
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1515
				return PushStyleVar("Alpha", 1, function() -- 1516
					return Begin("Content", windowFlags, function() -- 1517
						local DemoViewWidth <const> = 220 -- 1518
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1519
						if filterText then -- 1520
							filterText = filterText:lower() -- 1520
						end -- 1520
						if App.platform == "Emscripten" then -- 1521
							Dora.globals.webProjects.draw(zh, themeColor) -- 1522
							allEntries.anyEntryMatched = true -- 1523
						end -- 1521
						if #gamesInDev > 0 then -- 1524
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1525
							Columns(columns, false) -- 1526
							local realViewWidth = GetColumnWidth() - 50 -- 1527
							for _index_0 = 1, #gamesInDev do -- 1528
								local game = gamesInDev[_index_0] -- 1528
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1529
								local displayName -- 1538
								if repo then -- 1538
									if zh then -- 1539
										displayName = repo.title.zh -- 1539
									else -- 1539
										displayName = repo.title.en -- 1539
									end -- 1539
								end -- 1538
								if displayName == nil then -- 1540
									displayName = gameName -- 1540
								end -- 1540
								if allEntries.match(displayName) then -- 1541
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1542
									SameLine() -- 1543
									TextWrapped(displayName) -- 1544
									if columns > 1 then -- 1545
										if bannerFile and bannerTex then -- 1546
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1547
											local displayWidth <const> = realViewWidth -- 1548
											texHeight = displayWidth * texHeight / texWidth -- 1549
											texWidth = displayWidth -- 1550
											Dummy(Vec2.zero) -- 1551
											SameLine() -- 1552
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1553
										end -- 1546
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1554
											enterDemoEntry(game) -- 1555
										end -- 1554
									else -- 1557
										if bannerFile and bannerTex then -- 1557
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1558
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1559
											local sizing = 0.8 -- 1560
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1561
											texWidth = displayWidth * sizing -- 1562
											if texWidth > 500 then -- 1563
												sizing = 0.6 -- 1564
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1565
												texWidth = displayWidth * sizing -- 1566
											end -- 1563
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1567
											Dummy(Vec2(padding, 0)) -- 1568
											SameLine() -- 1569
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1570
										end -- 1557
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1571
											enterDemoEntry(game) -- 1572
										end -- 1571
									end -- 1545
									if #tests == 0 and #examples == 0 then -- 1573
										allEntries.thinSep() -- 1574
									end -- 1573
									NextColumn() -- 1575
								end -- 1541
								local showSep = false -- 1576
								if #examples > 0 then -- 1577
									local showExample = false -- 1578
									for _index_1 = 1, #examples do -- 1579
										local _des_0 = examples[_index_1] -- 1579
										local entryName = _des_0.entryName -- 1579
										if allEntries.match(entryName) then -- 1580
											showExample = true -- 1580
											break -- 1580
										end -- 1580
									end -- 1579
									if showExample then -- 1581
										showSep = true -- 1582
										Columns(1, false) -- 1583
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1584
										SameLine() -- 1585
										local opened -- 1586
										if (filterText ~= nil) then -- 1586
											opened = showExample -- 1586
										else -- 1586
											opened = false -- 1586
										end -- 1586
										if game.exampleOpen == nil then -- 1587
											game.exampleOpen = opened -- 1587
										end -- 1587
										SetNextItemOpen(game.exampleOpen) -- 1588
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1589
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1590
												Columns(maxColumns, false) -- 1591
												for _index_1 = 1, #examples do -- 1592
													local example = examples[_index_1] -- 1592
													local entryName = example.entryName -- 1593
													if not allEntries.match(entryName) then -- 1594
														goto _continue_0 -- 1594
													end -- 1594
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1595
														if Button(entryName, Vec2(-1, 40)) then -- 1596
															enterDemoEntry(example) -- 1597
														end -- 1596
														return NextColumn() -- 1598
													end) -- 1595
													opened = true -- 1599
													::_continue_0:: -- 1593
												end -- 1592
											end) -- 1590
										end) -- 1589
										game.exampleOpen = opened -- 1600
									end -- 1581
								end -- 1577
								if #tests > 0 then -- 1601
									local showTest = false -- 1602
									for _index_1 = 1, #tests do -- 1603
										local _des_0 = tests[_index_1] -- 1603
										local entryName = _des_0.entryName -- 1603
										if allEntries.match(entryName) then -- 1604
											showTest = true -- 1604
											break -- 1604
										end -- 1604
									end -- 1603
									if showTest then -- 1605
										showSep = true -- 1606
										Columns(1, false) -- 1607
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1608
										SameLine() -- 1609
										local opened -- 1610
										if (filterText ~= nil) then -- 1610
											opened = showTest -- 1610
										else -- 1610
											opened = false -- 1610
										end -- 1610
										if game.testOpen == nil then -- 1611
											game.testOpen = opened -- 1611
										end -- 1611
										SetNextItemOpen(game.testOpen) -- 1612
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1613
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1614
												Columns(maxColumns, false) -- 1615
												for _index_1 = 1, #tests do -- 1616
													local test = tests[_index_1] -- 1616
													local entryName = test.entryName -- 1617
													if not allEntries.match(entryName) then -- 1618
														goto _continue_0 -- 1618
													end -- 1618
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1619
														if Button(entryName, Vec2(-1, 40)) then -- 1620
															enterDemoEntry(test) -- 1621
														end -- 1620
														return NextColumn() -- 1622
													end) -- 1619
													opened = true -- 1623
													::_continue_0:: -- 1617
												end -- 1616
											end) -- 1614
										end) -- 1613
										game.testOpen = opened -- 1624
									end -- 1605
								end -- 1601
								if showSep then -- 1625
									Columns(1, false) -- 1626
									allEntries.thinSep() -- 1627
									Columns(columns, false) -- 1628
								end -- 1625
							end -- 1528
						end -- 1524
						if #doraTools > 0 then -- 1629
							local showTool = false -- 1630
							for _index_0 = 1, #doraTools do -- 1631
								local _des_0 = doraTools[_index_0] -- 1631
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1631
								local displayName -- 1632
								if repo then -- 1632
									if zh then -- 1633
										displayName = repo.title.zh -- 1633
									else -- 1633
										displayName = repo.title.en -- 1633
									end -- 1633
								end -- 1632
								if displayName == nil then -- 1634
									displayName = entryName -- 1634
								end -- 1634
								if allEntries.match(displayName) then -- 1635
									showTool = true -- 1635
									break -- 1635
								end -- 1635
							end -- 1631
							if not showTool then -- 1636
								goto endEntry -- 1636
							end -- 1636
							Columns(1, false) -- 1637
							TextColored(themeColor, "Dora SSR:") -- 1638
							SameLine() -- 1639
							Text(zh and "开发支持" or "Development Support") -- 1640
							Separator() -- 1641
							if #doraTools > 0 then -- 1642
								local opened -- 1643
								if (filterText ~= nil) then -- 1643
									opened = showTool -- 1643
								else -- 1643
									opened = false -- 1643
								end -- 1643
								SetNextItemOpen(toolOpen) -- 1644
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1645
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1646
										Columns(maxColumns, false) -- 1647
										for _index_0 = 1, #doraTools do -- 1648
											local tool = doraTools[_index_0] -- 1648
											local entryName, repo = tool.entryName, tool.repo -- 1649
											local displayName -- 1650
											if repo then -- 1650
												if zh then -- 1651
													displayName = repo.title.zh -- 1651
												else -- 1651
													displayName = repo.title.en -- 1651
												end -- 1651
											end -- 1650
											if displayName == nil then -- 1652
												displayName = entryName -- 1652
											end -- 1652
											if not allEntries.match(displayName) then -- 1653
												goto _continue_0 -- 1653
											end -- 1653
											if Button(displayName, Vec2(-1, 40)) then -- 1654
												enterDemoEntry(tool) -- 1655
											end -- 1654
											NextColumn() -- 1656
											::_continue_0:: -- 1649
										end -- 1648
										Columns(1, false) -- 1657
										opened = true -- 1658
									end) -- 1646
								end) -- 1645
								toolOpen = opened -- 1659
							end -- 1642
						end -- 1629
						::endEntry:: -- 1660
						if not allEntries.anyEntryMatched then -- 1661
							SetNextWindowBgAlpha(0) -- 1662
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1663
							Begin("Entries Not Found", displayWindowFlags, function() -- 1664
								Separator() -- 1665
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1666
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1667
								return Separator() -- 1668
							end) -- 1664
						end -- 1661
						Columns(1, false) -- 1669
						Dummy(Vec2(100, 80)) -- 1670
						return ScrollWhenDraggingOnVoid() -- 1671
					end) -- 1517
				end) -- 1516
			end) -- 1515
		end) -- 1514
	end -- 1513
end) -- 1430
if not (App.platform == "Emscripten") then -- 1676
	local sceneModuleCache = moduleCache -- 1677
	moduleCache = { } -- 1678
	webStatus = oldRequire("Script.Dev.WebServer") -- 1679
	moduleCache = sceneModuleCache -- 1680
end -- 1676
local _anon_func_7 = function(saved) -- 1703
	local _val_0 = saved.kind -- 1703
	return "local" == _val_0 or "discover" == _val_0 -- 1703
end -- 1703
local _anon_func_8 = function(saved) -- 1707
	local _val_0 = saved.activeTab -- 1707
	return "local" == _val_0 or "discover" == _val_0 -- 1707
end -- 1707
startMobileUI = function() -- 1682
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1683
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1684
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1685
	local getMobileFeedResources -- 1686
	do -- 1686
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1686
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1686
	end -- 1686
	local loadCachedCatalog -- 1687
	do -- 1687
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1687
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1687
	end -- 1687
	local getResourceInstallPath, getInstalledCatalogResource -- 1688
	do -- 1688
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1688
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1688
	end -- 1688
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1689
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1690
	local feedOptions = nil -- 1691
	local mobileLaunchErrors = { } -- 1692
	local withMobileLaunchErrors -- 1693
	withMobileLaunchErrors = function(items) -- 1693
		for _index_0 = 1, #items do -- 1694
			local item = items[_index_0] -- 1694
			item.launchError = mobileLaunchErrors[item.id] -- 1695
		end -- 1694
		return items -- 1696
	end -- 1693
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1697
	local loadRememberedMobileFeedState -- 1698
	loadRememberedMobileFeedState = function() -- 1698
		local raw = rememberedMobileFeedData -- 1699
		if not (type(raw) == "string" and raw ~= "") then -- 1700
			return -- 1700
		end -- 1700
		local ok, saved = pcall(json.decode, raw) -- 1701
		if not (ok and type(saved) == "table") then -- 1702
			return -- 1702
		end -- 1702
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1703
			local state = { -- 1704
				activeTab = saved.kind -- 1704
			} -- 1704
			state[saved.kind] = saved -- 1705
			return state -- 1706
		end -- 1703
		local state = { -- 1707
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1707
		} -- 1707
		local _list_0 = { -- 1708
			"local", -- 1708
			"discover" -- 1708
		} -- 1708
		for _index_0 = 1, #_list_0 do -- 1708
			local kind = _list_0[_index_0] -- 1708
			local entry = saved[kind] -- 1709
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1710
				state[kind] = entry -- 1710
			end -- 1710
		end -- 1708
		return state -- 1711
	end -- 1698
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1712
		activeTab = "local" -- 1712
	} -- 1712
	local rememberMobileFeedEntry -- 1713
	rememberMobileFeedEntry = function(entry) -- 1713
		rememberedMobileFeedState.activeTab = entry.kind -- 1714
		rememberedMobileFeedState[entry.kind] = { -- 1716
			id = entry.id, -- 1716
			kind = entry.kind, -- 1717
			workDir = entry.workDir, -- 1718
			fileName = entry.fileName -- 1719
		} -- 1715
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1721
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1722
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1723
			rememberedMobileFeedData -- 1723
		}) -- 1723
	end -- 1713
	local restartMobileFeed -- 1724
	restartMobileFeed = function(entry) -- 1724
		if feedHost then -- 1725
			feedHost:removeFromParent(true) -- 1725
		end -- 1725
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1726
		local initialEntries = { } -- 1727
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1728
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1729
		feedOptions.initialEntries = initialEntries -- 1730
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1731
	end -- 1724
	local startMobilePlay -- 1732
	startMobilePlay = function(entry) -- 1732
		if HttpServer.wsConnectionCount > 0 then -- 1733
			return -- 1733
		end -- 1733
		local originFeed = feedHost -- 1734
		if remixHost then -- 1735
			remixHost:removeFromParent(true) -- 1735
		end -- 1735
		remixHost = nil -- 1736
		mobileLaunchErrors[entry.id] = nil -- 1737
		entry.launchError = nil -- 1738
		local playActive = true -- 1739
		local restoreMobileFeed -- 1740
		restoreMobileFeed = function() -- 1740
			if not playActive then -- 1741
				return -- 1741
			end -- 1741
			playActive = false -- 1742
			allClear() -- 1743
			isInEntry = true -- 1744
			currentEntry = nil -- 1745
			return restartMobileFeed(entry) -- 1746
		end -- 1740
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1748
			onExit = function() -- 1748
				return restoreMobileFeed() -- 1748
			end, -- 1748
			onRuntimeError = function() -- 1749
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1750
				return restoreMobileFeed() -- 1751
			end -- 1749
		})) -- 1747
		return thread(function() -- 1753
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1757
			if not playActive then -- 1758
				return -- 1758
			end -- 1758
			if success then -- 1759
				if originFeed and originFeed.parent then -- 1760
					originFeed.visible = false -- 1760
				end -- 1760
				return -- 1761
			end -- 1759
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1762
			return restoreMobileFeed() -- 1763
		end) -- 1753
	end -- 1732
	feedOptions = { -- 1765
		takeReceivedFile = function() -- 1765
			if allEntries.pendingPackagePath then -- 1766
				local path = allEntries.pendingPackagePath -- 1767
				allEntries.pendingPackagePath = nil -- 1768
				return path -- 1769
			end -- 1766
			return App:takeReceivedFile() -- 1770
		end, -- 1765
		onSwitchMode = function() -- 1771
			if HttpServer.wsConnectionCount == 0 then -- 1771
				pendingUIMode = false -- 1771
			end -- 1771
		end, -- 1771
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1772
		getLocalEntries = function(importedProjectPath) -- 1773
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1774
			feedOptions.dirtyProjectPath = nil -- 1775
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1776
			local cached = loadCachedCatalog() -- 1777
			if cached.success and cached.snapshot then -- 1778
				for _index_0 = 1, #items do -- 1779
					local entry = items[_index_0] -- 1779
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1780
					if resource then -- 1781
						entry.resource = resource -- 1782
						entry.catalogCommit = cached.snapshot.commit -- 1783
					end -- 1781
				end -- 1779
			end -- 1778
			return items -- 1784
		end, -- 1773
		syncDiscover = function(onProgress, onDone, force) -- 1785
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1785
		end, -- 1785
		getDiscoverEntries = function() -- 1786
			local cached = loadCachedCatalog() -- 1787
			if not (cached.success and cached.snapshot) then -- 1788
				return { } -- 1788
			end -- 1788
			local items = { } -- 1789
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1790
			for _index_0 = 1, #_list_0 do -- 1790
				local resource = _list_0[_index_0] -- 1790
				local installed = lifecycle.isMobileResourceReady(resource) -- 1791
				local installPath = getResourceInstallPath(resource.id) -- 1792
				items[#items + 1] = { -- 1794
					id = resource.id, -- 1794
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1795
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1796
					kind = "discover", -- 1797
					bannerFile = resource.bannerPath, -- 1798
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1799
					sourceUrl = resource.versions[1].sources[1].url, -- 1800
					workDir = installed and installPath or nil, -- 1801
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1802
					installed = installed, -- 1803
					resource = resource, -- 1804
					catalogCommit = cached.snapshot.commit, -- 1805
					launchError = mobileLaunchErrors[resource.id] -- 1806
				} -- 1793
			end -- 1790
			return items -- 1808
		end, -- 1786
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1809
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1810
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1811
			end), repairIncomplete, isCanceled) -- 1810
		end, -- 1809
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1813
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1814
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1815
			end), isCanceled) -- 1814
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
	} -- 1764
	return restartMobileFeed() -- 1840
end -- 1682
if mobileMode then -- 1842
	applyUIMode(true) -- 1842
end -- 1842
return _module_0 -- 1
