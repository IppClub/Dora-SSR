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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "authRequired") -- 50
config:load() -- 80
if not (config.writablePath ~= nil) then -- 82
	config.writablePath = Content.appPath -- 83
end -- 82
if not (config.webIDEConnected ~= nil) then -- 85
	config.webIDEConnected = false -- 86
end -- 85
if (config.fpsLimited ~= nil) then -- 88
	App.fpsLimited = config.fpsLimited -- 89
else -- 91
	config.fpsLimited = App.fpsLimited -- 91
end -- 88
if (config.targetFPS ~= nil) then -- 93
	App.targetFPS = math.floor(config.targetFPS) -- 94
else -- 96
	config.targetFPS = App.targetFPS -- 96
end -- 93
if (config.vsync ~= nil) then -- 98
	View.vsync = config.vsync -- 99
else -- 101
	config.vsync = View.vsync -- 101
end -- 98
if (config.fixedFPS ~= nil) then -- 103
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 104
else -- 106
	config.fixedFPS = Director.scheduler.fixedFPS -- 106
end -- 103
if not (config.showPreview ~= nil) then -- 108
	config.showPreview = true -- 109
end -- 108
if not (config.webIDETourCompleted ~= nil) then -- 111
	config.webIDETourCompleted = false -- 112
end -- 111
if not (config.authRequired ~= nil) then -- 114
	local _val_0 = App.platform -- 115
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 115
end -- 114
HttpServer.authRequired = config.authRequired -- 116
local showEntry = true -- 118
isDesktop = false -- 120
if (function() -- 121
	local _val_0 = App.platform -- 121
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 121
end)() then -- 121
	isDesktop = true -- 122
	if config.fullScreen then -- 123
		App.fullScreen = true -- 124
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 125
		local size = Size(config.winWidth, config.winHeight) -- 126
		if App.winSize ~= size then -- 127
			App.winSize = size -- 128
		end -- 127
		local winX, winY -- 129
		do -- 129
			local _obj_0 = App.winPosition -- 129
			winX, winY = _obj_0.x, _obj_0.y -- 129
		end -- 129
		if (config.winX ~= nil) then -- 130
			winX = config.winX -- 131
		else -- 133
			config.winX = -1 -- 133
		end -- 130
		if (config.winY ~= nil) then -- 134
			winY = config.winY -- 135
		else -- 137
			config.winY = -1 -- 137
		end -- 134
		App.winPosition = Vec2(winX, winY) -- 138
	end -- 123
	if (config.alwaysOnTop ~= nil) then -- 139
		App.alwaysOnTop = config.alwaysOnTop -- 140
	else -- 142
		config.alwaysOnTop = false -- 142
	end -- 139
end -- 121
if (config.themeColor ~= nil) then -- 144
	App.themeColor = Color(config.themeColor) -- 145
else -- 147
	config.themeColor = App.themeColor:toARGB() -- 147
end -- 144
if not (config.locale ~= nil) then -- 149
	config.locale = App.locale -- 150
end -- 149
local showStats = false -- 152
if (config.showStats ~= nil) then -- 153
	showStats = config.showStats -- 154
else -- 156
	config.showStats = showStats -- 156
end -- 153
local showConsole = false -- 158
if (config.showConsole ~= nil) then -- 159
	showConsole = config.showConsole -- 160
else -- 162
	config.showConsole = showConsole -- 162
end -- 159
local showFooter = true -- 164
if (config.showFooter ~= nil) then -- 165
	showFooter = config.showFooter -- 166
else -- 168
	config.showFooter = showFooter -- 168
end -- 165
local setFooterVisible -- 170
setFooterVisible = function(visible) -- 170
	if visible == nil then -- 170
		visible = true -- 170
	end -- 170
	showFooter = visible -- 171
	config.showFooter = showFooter -- 172
end -- 170
_module_0["setFooterVisible"] = setFooterVisible -- 170
local filterBuf = Buffer(20) -- 174
if (config.filter ~= nil) then -- 175
	filterBuf.text = config.filter -- 176
else -- 178
	config.filter = "" -- 178
end -- 175
local engineDev = false -- 180
if (config.engineDev ~= nil) then -- 181
	engineDev = config.engineDev -- 182
else -- 184
	config.engineDev = engineDev -- 184
end -- 181
if (config.webProfiler ~= nil) then -- 186
	Director.profilerSending = config.webProfiler -- 187
else -- 189
	config.webProfiler = true -- 189
	Director.profilerSending = true -- 190
end -- 186
if not (config.drawerWidth ~= nil) then -- 192
	config.drawerWidth = 200 -- 193
end -- 192
_module_0.getConfig = function() -- 195
	return config -- 195
end -- 195
_module_0.getEngineDev = function() -- 196
	if not App.debugging then -- 197
		return false -- 197
	end -- 197
	return config.engineDev -- 198
end -- 196
local _anon_func_0 = function() -- 203
	local _val_0 = App.platform -- 203
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 203
end -- 203
_module_0.connectWebIDE = function() -- 200
	if not config.webIDEConnected then -- 201
		config.webIDEConnected = true -- 202
		if _anon_func_0() then -- 203
			local ratio = App.winSize.width / App.visualSize.width -- 204
			App.winSize = Size(640 * ratio, 480 * ratio) -- 205
		end -- 203
	end -- 201
end -- 200
local updateCheck -- 207
updateCheck = function() -- 207
	return thread(function() -- 207
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 208
		if res then -- 208
			local data = json.decode(res) -- 209
			if data then -- 209
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 210
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 211
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 212
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 213
				if na < a then -- 214
					goto not_new_version -- 215
				end -- 214
				if na == a then -- 216
					if nb < b then -- 217
						goto not_new_version -- 218
					end -- 217
					if nb == b then -- 219
						if nc < c then -- 220
							goto not_new_version -- 221
						end -- 220
						if nc == c then -- 222
							goto not_new_version -- 223
						end -- 222
					end -- 219
				end -- 216
				config.updateNotification = true -- 224
				::not_new_version:: -- 225
				config.lastUpdateCheck = os.time() -- 226
			end -- 209
		end -- 208
	end) -- 207
end -- 207
if (config.lastUpdateCheck ~= nil) then -- 228
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 229
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 230
		updateCheck() -- 231
	end -- 230
else -- 233
	updateCheck() -- 233
end -- 228
local Set, Struct, LintYueGlobals, GSplit -- 235
do -- 235
	local _obj_0 = require("Utils") -- 235
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 235
end -- 235
local yueext = yue.options.extension -- 236
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 238
local building = false -- 240
local getAllFiles -- 242
getAllFiles = function(path, exts, recursive) -- 242
	if recursive == nil then -- 242
		recursive = true -- 242
	end -- 242
	local filters = Set(exts) -- 243
	local files -- 244
	if recursive then -- 244
		files = Content:getAllFiles(path) -- 245
	else -- 247
		files = Content:getFiles(path) -- 247
	end -- 244
	local _accum_0 = { } -- 248
	local _len_0 = 1 -- 248
	for _index_0 = 1, #files do -- 248
		local file = files[_index_0] -- 248
		if not filters[Path:getExt(file)] then -- 249
			goto _continue_0 -- 249
		end -- 249
		_accum_0[_len_0] = file -- 250
		_len_0 = _len_0 + 1 -- 249
		::_continue_0:: -- 249
	end -- 248
	return _accum_0 -- 248
end -- 242
_module_0["getAllFiles"] = getAllFiles -- 242
local getFileEntries -- 252
getFileEntries = function(path, recursive, excludeFiles) -- 252
	if recursive == nil then -- 252
		recursive = true -- 252
	end -- 252
	if excludeFiles == nil then -- 252
		excludeFiles = nil -- 252
	end -- 252
	local entries = { } -- 253
	local excludes -- 254
	if excludeFiles then -- 254
		excludes = Set(excludeFiles) -- 255
	end -- 254
	local _list_0 = getAllFiles(path, { -- 256
		"lua", -- 256
		"xml", -- 256
		yueext, -- 256
		"tl" -- 256
	}, recursive) -- 256
	for _index_0 = 1, #_list_0 do -- 256
		local file = _list_0[_index_0] -- 256
		local entryName = Path:getName(file) -- 257
		if excludes and excludes[entryName] then -- 258
			goto _continue_0 -- 259
		end -- 258
		local fileName = Path:replaceExt(file, "") -- 260
		fileName = Path(path, fileName) -- 261
		local entryAdded -- 262
		for _index_1 = 1, #entries do -- 262
			local _des_0 = entries[_index_1] -- 262
			local ename, efile = _des_0.entryName, _des_0.fileName -- 262
			if entryName == ename and efile == fileName then -- 263
				entryAdded = true -- 263
				break -- 263
			end -- 263
		end -- 262
		if entryAdded then -- 264
			goto _continue_0 -- 264
		end -- 264
		local entry = { -- 265
			entryName = entryName, -- 265
			fileName = fileName -- 265
		} -- 265
		entries[#entries + 1] = entry -- 266
		::_continue_0:: -- 257
	end -- 256
	table.sort(entries, function(a, b) -- 267
		return a.entryName < b.entryName -- 267
	end) -- 267
	return entries -- 268
end -- 252
local getProjectEntries -- 270
getProjectEntries = function(path, noPreview) -- 270
	if noPreview == nil then -- 270
		noPreview = false -- 270
	end -- 270
	local entries = { } -- 271
	local _list_0 = Content:getDirs(path) -- 272
	for _index_0 = 1, #_list_0 do -- 272
		local dir = _list_0[_index_0] -- 272
		if dir:match("^%.") then -- 273
			goto _continue_0 -- 273
		end -- 273
		local _list_1 = getAllFiles(Path(path, dir), { -- 274
			"lua", -- 274
			"xml", -- 274
			yueext, -- 274
			"tl", -- 274
			"wasm" -- 274
		}) -- 274
		for _index_1 = 1, #_list_1 do -- 274
			local file = _list_1[_index_1] -- 274
			if "init" == Path:getName(file):lower() then -- 275
				local fileName = Path:replaceExt(file, "") -- 276
				fileName = Path(path, dir, fileName) -- 277
				local projectPath = Path:getPath(fileName) -- 278
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 279
				local repo = nil -- 280
				if Content:exist(repoFile) then -- 281
					local str = Content:load(repoFile) -- 282
					if str then -- 282
						repo = json.decode(str) -- 283
					end -- 282
				end -- 281
				local entryName = Path:getName(projectPath) -- 284
				local entryAdded -- 285
				for _index_2 = 1, #entries do -- 285
					local _des_0 = entries[_index_2] -- 285
					local ename, efile = _des_0.entryName, _des_0.fileName -- 285
					if entryName == ename and efile == fileName then -- 286
						entryAdded = true -- 286
						break -- 286
					end -- 286
				end -- 285
				if entryAdded then -- 287
					goto _continue_1 -- 287
				end -- 287
				local examples = { } -- 288
				local tests = { } -- 289
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 290
				if Content:exist(examplePath) then -- 291
					local _list_2 = getFileEntries(examplePath) -- 292
					for _index_2 = 1, #_list_2 do -- 292
						local _des_0 = _list_2[_index_2] -- 292
						local name, ePath = _des_0.entryName, _des_0.fileName -- 292
						local entry = { -- 294
							entryName = name, -- 294
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 295
							workDir = projectPath -- 296
						} -- 293
						examples[#examples + 1] = entry -- 298
					end -- 292
				end -- 291
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 299
				if Content:exist(testPath) then -- 300
					local _list_2 = getFileEntries(testPath) -- 301
					for _index_2 = 1, #_list_2 do -- 301
						local _des_0 = _list_2[_index_2] -- 301
						local name, tPath = _des_0.entryName, _des_0.fileName -- 301
						local entry = { -- 303
							entryName = name, -- 303
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 304
							workDir = projectPath -- 305
						} -- 302
						tests[#tests + 1] = entry -- 307
					end -- 301
				end -- 300
				local entry = { -- 308
					entryName = entryName, -- 308
					fileName = fileName, -- 308
					examples = examples, -- 308
					tests = tests, -- 308
					repo = repo -- 308
				} -- 308
				local bannerFile -- 309
				do -- 309
					local _val_0 -- 309
					repeat -- 309
						if noPreview then -- 310
							_val_0 = nil -- 310
							break -- 310
						end -- 310
						if not config.showPreview then -- 311
							_val_0 = nil -- 311
							break -- 311
						end -- 311
						local f = Path(projectPath, ".dora", "banner.jpg") -- 312
						if Content:exist(f) then -- 313
							_val_0 = f -- 313
							break -- 313
						end -- 313
						f = Path(projectPath, ".dora", "banner.png") -- 314
						if Content:exist(f) then -- 315
							_val_0 = f -- 315
							break -- 315
						end -- 315
						f = Path(projectPath, "Image", "banner.jpg") -- 316
						if Content:exist(f) then -- 317
							_val_0 = f -- 317
							break -- 317
						end -- 317
						f = Path(projectPath, "Image", "banner.png") -- 318
						if Content:exist(f) then -- 319
							_val_0 = f -- 319
							break -- 319
						end -- 319
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 320
						if Content:exist(f) then -- 321
							_val_0 = f -- 321
							break -- 321
						end -- 321
					until true -- 309
					bannerFile = _val_0 -- 309
				end -- 309
				if bannerFile then -- 323
					thread(function() -- 323
						if Cache:loadAsync(bannerFile) then -- 324
							local bannerTex = Texture2D(bannerFile) -- 325
							if bannerTex then -- 325
								entry.bannerFile = bannerFile -- 326
								entry.bannerTex = bannerTex -- 327
							end -- 325
						end -- 324
					end) -- 323
				end -- 323
				entries[#entries + 1] = entry -- 328
			end -- 275
			::_continue_1:: -- 275
		end -- 274
		::_continue_0:: -- 273
	end -- 272
	table.sort(entries, function(a, b) -- 329
		return a.entryName < b.entryName -- 329
	end) -- 329
	return entries -- 330
end -- 270
_module_0["getProjectEntries"] = getProjectEntries -- 270
local gamesInDev -- 332
local doraTools -- 333
local allEntries -- 334
local isToolEntry -- 336
isToolEntry = function(entry) -- 336
	do -- 337
		local _type_0 = type(entry) -- 337
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 337
		if _tab_0 then -- 337
			local categories -- 337
			do -- 337
				local _obj_0 = entry.repo -- 337
				local _type_1 = type(_obj_0) -- 337
				if "table" == _type_1 or "userdata" == _type_1 then -- 337
					categories = _obj_0.categories -- 337
				end -- 337
			end -- 337
			if categories ~= nil then -- 337
				for _index_0 = 1, #categories do -- 338
					local category = categories[_index_0] -- 338
					if "string" == type(category) and category:lower() == "tool" then -- 339
						return true -- 340
					end -- 339
				end -- 338
			end -- 337
		end -- 337
	end -- 337
	return false -- 336
end -- 336
local getEntryTitle -- 342
getEntryTitle = function(entry) -- 342
	local title -- 343
	do -- 343
		local repo = entry.repo -- 343
		if repo then -- 343
			if repo.title and "table" == type(repo.title) then -- 344
				if useChinese then -- 345
					title = repo.title.zh -- 345
				else -- 345
					title = repo.title.en -- 345
				end -- 345
			end -- 344
		end -- 343
	end -- 343
	if title ~= nil then -- 346
		return title -- 346
	else -- 346
		return entry.entryName -- 346
	end -- 346
end -- 342
local updateEntries -- 348
updateEntries = function() -- 348
	local projectEntries = getProjectEntries(Content.writablePath) -- 349
	gamesInDev = { } -- 350
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 351
	for _index_0 = 1, #doraTools do -- 352
		local tool = doraTools[_index_0] -- 352
		tool.kind = "tool" -- 353
		tool.builtin = true -- 354
	end -- 352
	for _index_0 = 1, #projectEntries do -- 355
		local entry = projectEntries[_index_0] -- 355
		if isToolEntry(entry) then -- 356
			entry.kind = "tool" -- 357
			doraTools[#doraTools + 1] = entry -- 358
		else -- 360
			entry.kind = "game" -- 360
			gamesInDev[#gamesInDev + 1] = entry -- 361
		end -- 356
	end -- 355
	allEntries = { } -- 362
	for _index_0 = 1, #gamesInDev do -- 363
		local game = gamesInDev[_index_0] -- 363
		allEntries[#allEntries + 1] = game -- 364
		local examples, tests = game.examples, game.tests -- 365
		for _index_1 = 1, #examples do -- 366
			local example = examples[_index_1] -- 366
			allEntries[#allEntries + 1] = example -- 367
		end -- 366
		for _index_1 = 1, #tests do -- 368
			local test = tests[_index_1] -- 368
			allEntries[#allEntries + 1] = test -- 369
		end -- 368
	end -- 363
end -- 348
updateEntries() -- 371
local getLaunchEntries -- 373
getLaunchEntries = function(refresh) -- 373
	if refresh == nil then -- 373
		refresh = false -- 373
	end -- 373
	if refresh then -- 374
		updateEntries() -- 374
	end -- 374
	local toInfo -- 375
	toInfo = function(entry, kind) -- 375
		local file = entry.fileName -- 376
		local asProj = not entry.builtin -- 377
		return { -- 379
			name = getEntryTitle(entry), -- 379
			file = file, -- 380
			kind = kind, -- 381
			asProj = asProj -- 382
		} -- 378
	end -- 375
	local games -- 384
	do -- 384
		local _accum_0 = { } -- 384
		local _len_0 = 1 -- 384
		for _index_0 = 1, #gamesInDev do -- 384
			local game = gamesInDev[_index_0] -- 384
			_accum_0[_len_0] = toInfo(game, "game") -- 384
			_len_0 = _len_0 + 1 -- 384
		end -- 384
		games = _accum_0 -- 384
	end -- 384
	local tools -- 385
	do -- 385
		local _accum_0 = { } -- 385
		local _len_0 = 1 -- 385
		for _index_0 = 1, #doraTools do -- 385
			local tool = doraTools[_index_0] -- 385
			_accum_0[_len_0] = toInfo(tool, "tool") -- 385
			_len_0 = _len_0 + 1 -- 385
		end -- 385
		tools = _accum_0 -- 385
	end -- 385
	return { -- 386
		games = games, -- 386
		tools = tools -- 386
	} -- 386
end -- 373
_module_0["getLaunchEntries"] = getLaunchEntries -- 373
local doCompile -- 388
doCompile = function(minify) -- 388
	if building then -- 389
		return -- 389
	end -- 389
	building = true -- 390
	local startTime = App.runningTime -- 391
	local luaFiles = { } -- 392
	local yueFiles = { } -- 393
	local xmlFiles = { } -- 394
	local tlFiles = { } -- 395
	local writablePath = Content.writablePath -- 396
	local buildPaths = { -- 398
		{ -- 399
			Content.assetPath, -- 399
			Path(writablePath, ".build"), -- 400
			"" -- 401
		} -- 398
	} -- 397
	for _index_0 = 1, #gamesInDev do -- 404
		local _des_0 = gamesInDev[_index_0] -- 404
		local fileName = _des_0.fileName -- 404
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 405
		buildPaths[#buildPaths + 1] = { -- 407
			Path(writablePath, gamePath), -- 407
			Path(writablePath, ".build", gamePath), -- 408
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 409
			gamePath -- 410
		} -- 406
	end -- 404
	for _index_0 = 1, #buildPaths do -- 411
		local _des_0 = buildPaths[_index_0] -- 411
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 411
		if not Content:exist(inputPath) then -- 412
			goto _continue_0 -- 412
		end -- 412
		local _list_0 = getAllFiles(inputPath, { -- 414
			"lua" -- 414
		}) -- 414
		for _index_1 = 1, #_list_0 do -- 414
			local file = _list_0[_index_1] -- 414
			luaFiles[#luaFiles + 1] = { -- 416
				file, -- 416
				Path(inputPath, file), -- 417
				Path(outputPath, file), -- 418
				gamePath -- 419
			} -- 415
		end -- 414
		local _list_1 = getAllFiles(inputPath, { -- 421
			yueext -- 421
		}) -- 421
		for _index_1 = 1, #_list_1 do -- 421
			local file = _list_1[_index_1] -- 421
			yueFiles[#yueFiles + 1] = { -- 423
				file, -- 423
				Path(inputPath, file), -- 424
				Path(outputPath, Path:replaceExt(file, "lua")), -- 425
				searchPath, -- 426
				gamePath -- 427
			} -- 422
		end -- 421
		local _list_2 = getAllFiles(inputPath, { -- 429
			"xml" -- 429
		}) -- 429
		for _index_1 = 1, #_list_2 do -- 429
			local file = _list_2[_index_1] -- 429
			xmlFiles[#xmlFiles + 1] = { -- 431
				file, -- 431
				Path(inputPath, file), -- 432
				Path(outputPath, Path:replaceExt(file, "lua")), -- 433
				gamePath -- 434
			} -- 430
		end -- 429
		local _list_3 = getAllFiles(inputPath, { -- 436
			"tl" -- 436
		}) -- 436
		for _index_1 = 1, #_list_3 do -- 436
			local file = _list_3[_index_1] -- 436
			if not file:match(".*%.d%.tl$") then -- 437
				tlFiles[#tlFiles + 1] = { -- 439
					file, -- 439
					Path(inputPath, file), -- 440
					Path(outputPath, Path:replaceExt(file, "lua")), -- 441
					searchPath, -- 442
					gamePath -- 443
				} -- 438
			end -- 437
		end -- 436
		::_continue_0:: -- 412
	end -- 411
	local paths -- 445
	do -- 445
		local _tbl_0 = { } -- 445
		local _list_0 = { -- 446
			luaFiles, -- 446
			yueFiles, -- 446
			xmlFiles, -- 446
			tlFiles -- 446
		} -- 446
		for _index_0 = 1, #_list_0 do -- 446
			local files = _list_0[_index_0] -- 446
			for _index_1 = 1, #files do -- 447
				local file = files[_index_1] -- 447
				_tbl_0[Path:getPath(file[3])] = true -- 445
			end -- 445
		end -- 445
		paths = _tbl_0 -- 445
	end -- 445
	for path in pairs(paths) do -- 449
		Content:mkdir(path) -- 449
	end -- 449
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 451
	local fileCount = 0 -- 452
	local errors = { } -- 453
	for _index_0 = 1, #yueFiles do -- 454
		local _des_0 = yueFiles[_index_0] -- 454
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 454
		local filename -- 455
		if gamePath then -- 455
			filename = Path(gamePath, file) -- 455
		else -- 455
			filename = file -- 455
		end -- 455
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 456
			if not codes then -- 457
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 458
				return -- 459
			end -- 457
			local success, result = LintYueGlobals(codes, globals) -- 460
			local yueCodes -- 461
			if not success then -- 462
				yueCodes = Content:load(input) -- 463
				if yueCodes then -- 463
					local CheckTIC80Code -- 464
					do -- 464
						local _obj_0 = require("Utils") -- 464
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 464
					end -- 464
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 465
					if isTIC80 then -- 466
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 467
					end -- 466
				end -- 463
			end -- 462
			if success then -- 468
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 469
			else -- 471
				if yueCodes then -- 471
					local globalErrors = { } -- 472
					for _index_1 = 1, #result do -- 473
						local _des_1 = result[_index_1] -- 473
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 473
						local countLine = 1 -- 474
						local code = "" -- 475
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 476
							if countLine == line then -- 477
								code = lineCode -- 478
								break -- 479
							end -- 477
							countLine = countLine + 1 -- 480
						end -- 476
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 481
					end -- 473
					if #globalErrors > 0 then -- 482
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 482
					end -- 482
				else -- 484
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 484
				end -- 471
				if #errors == 0 then -- 485
					return codes -- 485
				end -- 485
			end -- 468
		end, function(success) -- 456
			if success then -- 486
				print("Yue compiled: " .. tostring(filename)) -- 486
			end -- 486
			fileCount = fileCount + 1 -- 487
		end) -- 456
	end -- 454
	thread(function() -- 489
		for _index_0 = 1, #xmlFiles do -- 490
			local _des_0 = xmlFiles[_index_0] -- 490
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 490
			local filename -- 491
			if gamePath then -- 491
				filename = Path(gamePath, file) -- 491
			else -- 491
				filename = file -- 491
			end -- 491
			local sourceCodes = Content:loadAsync(input) -- 492
			local codes, err = xml.tolua(sourceCodes) -- 493
			if not codes then -- 494
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 495
			else -- 497
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 497
				print("Xml compiled: " .. tostring(filename)) -- 498
			end -- 494
			fileCount = fileCount + 1 -- 499
		end -- 490
	end) -- 489
	thread(function() -- 501
		for _index_0 = 1, #tlFiles do -- 502
			local _des_0 = tlFiles[_index_0] -- 502
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 502
			local filename -- 503
			if gamePath then -- 503
				filename = Path(gamePath, file) -- 503
			else -- 503
				filename = file -- 503
			end -- 503
			local sourceCodes = Content:loadAsync(input) -- 504
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 505
			if not codes then -- 506
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 507
			else -- 509
				Content:saveAsync(output, codes) -- 509
				print("Teal compiled: " .. tostring(filename)) -- 510
			end -- 506
			fileCount = fileCount + 1 -- 511
		end -- 502
	end) -- 501
	return thread(function() -- 513
		wait(function() -- 514
			return fileCount == totalFiles -- 514
		end) -- 514
		if minify then -- 515
			local _list_0 = { -- 516
				yueFiles, -- 516
				xmlFiles, -- 516
				tlFiles -- 516
			} -- 516
			for _index_0 = 1, #_list_0 do -- 516
				local files = _list_0[_index_0] -- 516
				for _index_1 = 1, #files do -- 516
					local file = files[_index_1] -- 516
					local output = Path:replaceExt(file[3], "lua") -- 517
					luaFiles[#luaFiles + 1] = { -- 519
						Path:replaceExt(file[1], "lua"), -- 519
						output, -- 520
						output -- 521
					} -- 518
				end -- 516
			end -- 516
			local FormatMini -- 523
			do -- 523
				local _obj_0 = require("luaminify") -- 523
				FormatMini = _obj_0.FormatMini -- 523
			end -- 523
			for _index_0 = 1, #luaFiles do -- 524
				local _des_0 = luaFiles[_index_0] -- 524
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 524
				if Content:exist(input) then -- 525
					local sourceCodes = Content:loadAsync(input) -- 526
					local res, err = FormatMini(sourceCodes) -- 527
					if res then -- 528
						Content:saveAsync(output, res) -- 529
						print("Minify: " .. tostring(file)) -- 530
					else -- 532
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 532
					end -- 528
				else -- 534
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 534
				end -- 525
			end -- 524
			package.loaded["luaminify.FormatMini"] = nil -- 535
			package.loaded["luaminify.ParseLua"] = nil -- 536
			package.loaded["luaminify.Scope"] = nil -- 537
			package.loaded["luaminify.Util"] = nil -- 538
		end -- 515
		local errorMessage = table.concat(errors, "\n") -- 539
		if errorMessage ~= "" then -- 540
			print(errorMessage) -- 540
		end -- 540
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 541
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 542
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 543
		Content:clearPathCache() -- 544
		teal.clear() -- 545
		yue.clear() -- 546
		building = false -- 547
	end) -- 513
end -- 388
local doClean -- 549
doClean = function() -- 549
	if building then -- 550
		return -- 550
	end -- 550
	local writablePath = Content.writablePath -- 551
	local targetDir = Path(writablePath, ".build") -- 552
	Content:clearPathCache() -- 553
	if Content:remove(targetDir) then -- 554
		return print("Cleaned: " .. tostring(targetDir)) -- 555
	end -- 554
end -- 549
local screenScale = 2.0 -- 557
local scaleContent = false -- 558
local isInEntry = true -- 559
local currentEntry = nil -- 560
local footerWindow = nil -- 562
local entryWindow = nil -- 563
local testingThread = nil -- 564
local setupEventHandlers = nil -- 566
local allClear -- 568
allClear = function() -- 568
	for _index_0 = 1, #Routine do -- 569
		local routine = Routine[_index_0] -- 569
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 571
			goto _continue_0 -- 572
		else -- 574
			Routine:remove(routine) -- 574
		end -- 570
		::_continue_0:: -- 570
	end -- 569
	for _index_0 = 1, #moduleCache do -- 575
		local module = moduleCache[_index_0] -- 575
		package.loaded[module] = nil -- 576
	end -- 575
	moduleCache = { } -- 577
	Director:cleanup() -- 578
	Entity:clear() -- 579
	Platformer.Data:clear() -- 580
	Platformer.UnitAction:clear() -- 581
	Audio:stopAll(0.2) -- 582
	Struct:clear() -- 583
	View.postEffect = nil -- 584
	View.scale = scaleContent and screenScale or 1 -- 585
	Director.clearColor = Color(0xff1a1a1a) -- 586
	teal.clear() -- 587
	yue.clear() -- 588
	for _, item in pairs(ubox()) do -- 589
		local node = tolua.cast(item, "Node") -- 590
		if node then -- 590
			node:cleanup() -- 590
		end -- 590
	end -- 589
	collectgarbage() -- 591
	collectgarbage() -- 592
	Wasm:clear() -- 593
	thread(function() -- 594
		sleep() -- 595
		return Cache:removeUnused() -- 596
	end) -- 594
	setupEventHandlers() -- 597
	Content.searchPaths = searchPaths -- 598
	App.idled = true -- 599
end -- 568
_module_0["allClear"] = allClear -- 568
local clearTempFiles -- 601
clearTempFiles = function() -- 601
	local writablePath = Content.writablePath -- 602
	Content:remove(Path(writablePath, ".upload")) -- 603
	return Content:remove(Path(writablePath, ".download")) -- 604
end -- 601
local waitForWebStart = true -- 606
thread(function() -- 607
	sleep(2) -- 608
	waitForWebStart = false -- 609
end) -- 607
local reloadDevEntry -- 611
reloadDevEntry = function() -- 611
	return thread(function() -- 611
		waitForWebStart = true -- 612
		doClean() -- 613
		allClear() -- 614
		_G.require = oldRequire -- 615
		Dora.require = oldRequire -- 616
		package.loaded["Script.Dev.Entry"] = nil -- 617
		package.loaded["Script.Dev.WebServer"] = nil -- 618
		return Director.systemScheduler:schedule(function() -- 619
			Routine:clear() -- 620
			oldRequire("Script.Dev.Entry") -- 621
			return true -- 622
		end) -- 619
	end) -- 611
end -- 611
local setWorkspace -- 624
setWorkspace = function(path) -- 624
	clearTempFiles() -- 625
	Content.writablePath = path -- 626
	config.writablePath = Content.writablePath -- 627
	return thread(function() -- 628
		sleep() -- 629
		return reloadDevEntry() -- 630
	end) -- 628
end -- 624
_module_0["setWorkspace"] = setWorkspace -- 624
local quit = false -- 632
local activeSearchId = 0 -- 634
local handleSearchFiles -- 636
handleSearchFiles = function(payload) -- 636
	if not payload then -- 637
		return -- 637
	end -- 637
	local id = payload.id -- 638
	if id == nil then -- 639
		return -- 639
	end -- 639
	activeSearchId = id -- 640
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 641
	if path == nil then -- 642
		path = "" -- 642
	end -- 642
	if exts == nil then -- 643
		exts = { } -- 643
	end -- 643
	if globs == nil then -- 644
		globs = { } -- 644
	end -- 644
	if extensionLevels == nil then -- 645
		extensionLevels = { } -- 645
	end -- 645
	if pattern == nil then -- 646
		pattern = "" -- 646
	end -- 646
	if pattern == "" then -- 648
		return -- 648
	end -- 648
	local useRegex = payload.useRegex == true -- 649
	local caseSensitive = payload.caseSensitive == true -- 650
	local includeContent = payload.includeContent ~= false -- 651
	local contentWindow = payload.contentWindow or 0 -- 652
	return Director.systemScheduler:schedule(once(function() -- 653
		local stopped = false -- 654
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 655
			if activeSearchId ~= id then -- 656
				stopped = true -- 657
				return true -- 658
			end -- 656
			emit("AppWS", "Send", json.encode({ -- 660
				name = "SearchFilesResult", -- 660
				id = id, -- 660
				result = result -- 660
			})) -- 659
			return false -- 662
		end) -- 655
		return emit("AppWS", "Send", json.encode({ -- 664
			name = "SearchFilesDone", -- 664
			id = id, -- 664
			stopped = stopped -- 664
		})) -- 663
	end)) -- 653
end -- 636
local stop -- 667
stop = function() -- 667
	if isInEntry then -- 668
		return false -- 668
	end -- 668
	allClear() -- 669
	isInEntry = true -- 670
	currentEntry = nil -- 671
	return true -- 672
end -- 667
_module_0["stop"] = stop -- 667
local getCurrentEntryStatus -- 674
getCurrentEntryStatus = function() -- 674
	local entry = currentEntry -- 675
	if not (entry and not isInEntry) then -- 676
		return { -- 676
			success = true, -- 676
			running = false -- 676
		} -- 676
	end -- 676
	local status = { -- 678
		success = true, -- 678
		running = true, -- 679
		kind = entry.runKind or "file", -- 680
		entryName = entry.entryName, -- 681
		fileName = entry.fileName -- 682
	} -- 677
	if entry.workDir then -- 683
		status.workDir = entry.workDir -- 683
	end -- 683
	if entry.projectRoot then -- 684
		status.projectRoot = entry.projectRoot -- 684
	end -- 684
	return status -- 685
end -- 674
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 674
local _anon_func_1 = function(_with_0) -- 704
	local _val_0 = App.platform -- 704
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 704
end -- 704
setupEventHandlers = function() -- 687
	local _with_0 = Director.postNode -- 688
	_with_0:onAppEvent(function(eventType) -- 689
		if "Quit" == eventType then -- 690
			quit = true -- 691
			allClear() -- 692
			return clearTempFiles() -- 693
		elseif "Shutdown" == eventType then -- 694
			return stop() -- 695
		end -- 689
	end) -- 689
	_with_0:onAppChange(function(settingName) -- 696
		if "Theme" == settingName then -- 697
			config.themeColor = App.themeColor:toARGB() -- 698
		elseif "Locale" == settingName then -- 699
			config.locale = App.locale -- 700
			updateLocale() -- 701
			return teal.clear(true) -- 702
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 703
			if _anon_func_1(_with_0) then -- 704
				if "FullScreen" == settingName then -- 706
					config.fullScreen = App.fullScreen -- 706
				elseif "Position" == settingName then -- 707
					local _obj_0 = App.winPosition -- 707
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 707
				elseif "Size" == settingName then -- 708
					local width, height -- 709
					do -- 709
						local _obj_0 = App.winSize -- 709
						width, height = _obj_0.width, _obj_0.height -- 709
					end -- 709
					config.winWidth = width -- 710
					config.winHeight = height -- 711
				end -- 705
			end -- 704
		end -- 696
	end) -- 696
	_with_0:onAppWS(function(event) -- 712
		if event.type == "Close" then -- 713
			if HttpServer.wsConnectionCount == 0 then -- 714
				updateEntries() -- 715
			end -- 714
			return -- 716
		end -- 713
		if not (event.type == "Receive") then -- 717
			return -- 717
		end -- 717
		local data = json.decode(event.msg) -- 718
		if not data then -- 719
			return -- 719
		end -- 719
		local _exp_0 = data.name -- 720
		if "SearchFiles" == _exp_0 then -- 721
			return handleSearchFiles(data) -- 722
		elseif "SearchFilesStop" == _exp_0 then -- 723
			if data.id == nil or data.id == activeSearchId then -- 724
				activeSearchId = 0 -- 725
			end -- 724
		end -- 720
	end) -- 712
	_with_0:slot("UpdateEntries", function() -- 726
		return updateEntries() -- 726
	end) -- 726
	return _with_0 -- 688
end -- 687
setupEventHandlers() -- 728
clearTempFiles() -- 729
local downloadFile -- 731
downloadFile = function(url, target) -- 731
	return Director.systemScheduler:schedule(once(function() -- 731
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 732
			if quit then -- 733
				return true -- 733
			end -- 733
			emit("AppWS", "Send", json.encode({ -- 735
				name = "Download", -- 735
				url = url, -- 735
				status = "downloading", -- 735
				progress = current / total -- 736
			})) -- 734
			return false -- 732
		end) -- 732
		return emit("AppWS", "Send", json.encode(success and { -- 739
			name = "Download", -- 739
			url = url, -- 739
			status = "completed", -- 739
			progress = 1.0 -- 740
		} or { -- 742
			name = "Download", -- 742
			url = url, -- 742
			status = "failed", -- 742
			progress = 0.0 -- 743
		})) -- 738
	end)) -- 731
end -- 731
_module_0["downloadFile"] = downloadFile -- 731
local _anon_func_2 = function(file, require, workDir) -- 754
	if workDir == nil then -- 754
		workDir = Path:getPath(file) -- 754
	end -- 754
	Content:insertSearchPath(1, workDir) -- 755
	local scriptPath = Path(workDir, "Script") -- 756
	if Content:exist(scriptPath) then -- 757
		Content:insertSearchPath(1, scriptPath) -- 758
	end -- 757
	local result = require(file) -- 759
	if "function" == type(result) then -- 760
		result() -- 760
	end -- 760
	return nil -- 761
end -- 754
local _anon_func_3 = function(_with_0, err, fontSize, width) -- 790
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 790
	label.alignment = "Left" -- 791
	label.textWidth = width - fontSize -- 792
	label.text = err -- 793
	return label -- 790
end -- 790
local enterEntryAsync -- 746
enterEntryAsync = function(entry) -- 746
	isInEntry = false -- 747
	App.idled = false -- 748
	emit(Profiler.EventName, "ClearLoader") -- 749
	currentEntry = entry -- 750
	local file, workDir = entry.fileName, entry.workDir -- 751
	sleep() -- 752
	return xpcall(_anon_func_2, function(msg) -- 761
		local err = debug.traceback(msg) -- 763
		Log("Error", err) -- 764
		allClear() -- 765
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 766
		local viewWidth, viewHeight -- 767
		do -- 767
			local _obj_0 = View.size -- 767
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 767
		end -- 767
		local width, height = viewWidth - 20, viewHeight - 20 -- 768
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 769
		Director.ui:addChild((function() -- 770
			local root = AlignNode() -- 770
			do -- 771
				local _obj_0 = App.bufferSize -- 771
				width, height = _obj_0.width, _obj_0.height -- 771
			end -- 771
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 772
			root:onAppChange(function(settingName) -- 773
				if settingName == "Size" then -- 773
					do -- 774
						local _obj_0 = App.bufferSize -- 774
						width, height = _obj_0.width, _obj_0.height -- 774
					end -- 774
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 775
				end -- 773
			end) -- 773
			root:addChild((function() -- 776
				local _with_0 = ScrollArea({ -- 777
					width = width, -- 777
					height = height, -- 778
					paddingX = 0, -- 779
					paddingY = 50, -- 780
					viewWidth = height, -- 781
					viewHeight = height -- 782
				}) -- 776
				root:onAlignLayout(function(w, h) -- 784
					_with_0.position = Vec2(w / 2, h / 2) -- 785
					w = w - 20 -- 786
					h = h - 20 -- 787
					_with_0.view.children.first.textWidth = w - fontSize -- 788
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 789
				end) -- 784
				_with_0.view:addChild(_anon_func_3(_with_0, err, fontSize, width)) -- 790
				return _with_0 -- 776
			end)()) -- 776
			return root -- 770
		end)()) -- 770
		return err -- 794
	end, file, require, workDir) -- 753
end -- 746
_module_0["enterEntryAsync"] = enterEntryAsync -- 746
local enterDemoEntry -- 796
enterDemoEntry = function(entry) -- 796
	return thread(function() -- 796
		return enterEntryAsync(entry) -- 796
	end) -- 796
end -- 796
local reloadCurrentEntry -- 798
reloadCurrentEntry = function() -- 798
	if currentEntry then -- 799
		allClear() -- 800
		return enterDemoEntry(currentEntry) -- 801
	end -- 799
end -- 798
Director.clearColor = Color(0xff1a1a1a) -- 803
local descColor = Color(0xffa1a1a1) -- 804
local extraOperations -- 806
do -- 806
	local isOSSLicenseExist = Content:exist("LICENSES") -- 807
	local ossLicenses = nil -- 808
	local ossLicenseOpen = false -- 809
	local failedSetFolder = false -- 810
	local statusFlags = { -- 811
		"NoResize", -- 811
		"NoMove", -- 811
		"NoCollapse", -- 811
		"AlwaysAutoResize", -- 811
		"NoSavedSettings" -- 811
	} -- 811
	extraOperations = function() -- 818
		local zh = useChinese -- 819
		if isDesktop then -- 820
			local alwaysOnTop = config.alwaysOnTop -- 821
			local changed -- 822
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 822
			if changed then -- 822
				App.alwaysOnTop = alwaysOnTop -- 823
				config.alwaysOnTop = alwaysOnTop -- 824
			end -- 822
		end -- 820
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 825
		do -- 830
			local changed -- 830
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 830
			if changed then -- 830
				config.showPreview = showPreview -- 831
				updateEntries() -- 832
				if not showPreview then -- 833
					thread(function() -- 834
						collectgarbage() -- 835
						return Cache:removeUnused("Texture") -- 836
					end) -- 834
				end -- 833
			end -- 830
		end -- 830
		do -- 837
			local changed -- 837
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 837
			if changed then -- 837
				config.authRequired = authRequired -- 838
				HttpServer.authRequired = authRequired -- 839
			end -- 837
		end -- 837
		SameLine() -- 840
		TextColored(descColor, "(?)") -- 841
		if IsItemHovered() then -- 842
			BeginTooltip(function() -- 843
				return PushTextWrapPos(280, function() -- 844
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 845
				end) -- 844
			end) -- 843
		end -- 842
		do -- 846
			local themeColor = App.themeColor -- 847
			local writablePath = config.writablePath -- 848
			SeparatorText(zh and "工作目录" or "Workspace") -- 849
			PushTextWrapPos(400, function() -- 850
				return TextColored(themeColor, writablePath) -- 851
			end) -- 850
			if not isDesktop then -- 852
				goto skipSetting -- 852
			end -- 852
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 853
			if Button(zh and "改变目录" or "Set Folder") then -- 854
				App:openFileDialog(true, function(path) -- 855
					if path == "" then -- 856
						return -- 856
					end -- 856
					local relPath = Path:getRelative(Content.assetPath, path) -- 857
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 858
						return setWorkspace(path) -- 859
					else -- 861
						failedSetFolder = true -- 861
					end -- 858
				end) -- 855
			end -- 854
			if failedSetFolder then -- 862
				failedSetFolder = false -- 863
				OpenPopup(popupName) -- 864
			end -- 862
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 865
			BeginPopupModal(popupName, statusFlags, function() -- 866
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 867
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 868
					return CloseCurrentPopup() -- 869
				end -- 868
			end) -- 866
			SameLine() -- 870
			if Button(zh and "使用默认" or "Use Default") then -- 871
				setWorkspace(Content.appPath) -- 872
			end -- 871
			Separator() -- 873
			::skipSetting:: -- 874
		end -- 846
		if isOSSLicenseExist then -- 875
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 876
				if not ossLicenses then -- 877
					ossLicenses = { } -- 878
					local licenseText = Content:load("LICENSES") -- 879
					ossLicenseOpen = (licenseText ~= nil) -- 880
					if ossLicenseOpen then -- 880
						licenseText = licenseText:gsub("\r\n", "\n") -- 881
						for license in GSplit(licenseText, "\n--------\n", true) do -- 882
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 883
							if name then -- 883
								ossLicenses[#ossLicenses + 1] = { -- 884
									name, -- 884
									text -- 884
								} -- 884
							end -- 883
						end -- 882
					end -- 880
				else -- 886
					ossLicenseOpen = true -- 886
				end -- 877
			end -- 876
			if ossLicenseOpen then -- 887
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 888
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 889
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 890
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 891
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 894
						"NoSavedSettings" -- 894
					}, function() -- 895
						for _index_0 = 1, #ossLicenses do -- 895
							local _des_0 = ossLicenses[_index_0] -- 895
							local firstLine, text = _des_0[1], _des_0[2] -- 895
							local name, license = firstLine:match("(.+): (.+)") -- 896
							TextColored(themeColor, name) -- 897
							SameLine() -- 898
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 899
								return TextWrapped(text) -- 899
							end) -- 899
						end -- 895
					end) -- 891
				end) -- 891
			end -- 887
		end -- 875
		if not App.debugging then -- 901
			return -- 901
		end -- 901
		return TreeNode(zh and "开发操作" or "Development", function() -- 902
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 903
				OpenPopup("build") -- 903
			end -- 903
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 904
				return BeginPopup("build", function() -- 904
					if Selectable(zh and "编译" or "Compile") then -- 905
						doCompile(false) -- 905
					end -- 905
					Separator() -- 906
					if Selectable(zh and "压缩" or "Minify") then -- 907
						doCompile(true) -- 907
					end -- 907
					Separator() -- 908
					if Selectable(zh and "清理" or "Clean") then -- 909
						return doClean() -- 909
					end -- 909
				end) -- 904
			end) -- 904
			if isInEntry then -- 910
				if waitForWebStart then -- 911
					BeginDisabled(function() -- 912
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 912
					end) -- 912
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 913
					reloadDevEntry() -- 914
				end -- 911
			end -- 910
			do -- 915
				local changed -- 915
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 915
				if changed then -- 915
					View.scale = scaleContent and screenScale or 1 -- 916
				end -- 915
			end -- 915
			do -- 917
				local changed -- 917
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 917
				if changed then -- 917
					config.engineDev = engineDev -- 918
				end -- 917
			end -- 917
			do -- 919
				local changed -- 919
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 919
				if changed then -- 919
					config.webIDETourCompleted = webIDETourCompleted -- 920
				end -- 919
			end -- 919
			if testingThread then -- 921
				return BeginDisabled(function() -- 922
					return Button(zh and "开始自动测试" or "Test automatically") -- 922
				end) -- 922
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 923
				testingThread = thread(function() -- 924
					local _ <close> = setmetatable({ }, { -- 925
						__close = function() -- 925
							allClear() -- 926
							testingThread = nil -- 927
							isInEntry = true -- 928
							currentEntry = nil -- 929
							return print("Testing done!") -- 930
						end -- 925
					}) -- 925
					for _, entry in ipairs(allEntries) do -- 931
						allClear() -- 932
						print("Start " .. tostring(entry.entryName)) -- 933
						enterDemoEntry(entry) -- 934
						sleep(2) -- 935
						print("Stop " .. tostring(entry.entryName)) -- 936
					end -- 931
				end) -- 924
			end -- 921
		end) -- 902
	end -- 818
end -- 806
local icon = Path("Script", "Dev", "icon_s.png") -- 938
local iconTex = nil -- 939
thread(function() -- 940
	if Cache:loadAsync(icon) then -- 940
		iconTex = Texture2D(icon) -- 940
	end -- 940
end) -- 940
local webStatus = nil -- 942
local urlClicked = nil -- 943
local authCode = string.format("%06d", math.random(0, 999999)) -- 945
local authCodeTTL = 30.0 -- 947
_module_0.getAuthCode = function() -- 948
	return authCode -- 948
end -- 948
_module_0.invalidateAuthCode = function() -- 949
	authCode = string.format("%06d", math.random(0, 999999)) -- 950
	authCodeTTL = 30.0 -- 951
end -- 949
local AuthSession -- 953
do -- 953
	local pending = nil -- 954
	local session = nil -- 955
	AuthSession = { -- 957
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 957
			pending = { -- 959
				sessionId = sessionId, -- 959
				confirmCode = confirmCode, -- 960
				expiresAt = expiresAt, -- 961
				ttl = ttl, -- 962
				approved = false -- 963
			} -- 958
		end, -- 957
		getPending = function() -- 965
			return pending -- 965
		end, -- 965
		approvePending = function(sessionId) -- 967
			if pending and pending.sessionId == sessionId then -- 968
				pending.approved = true -- 969
				return true -- 970
			end -- 968
			return false -- 971
		end, -- 967
		clearPending = function() -- 973
			pending = nil -- 973
		end, -- 973
		setSession = function(sessionId, sessionSecret) -- 975
			session = { -- 977
				sessionId = sessionId, -- 977
				sessionSecret = sessionSecret -- 978
			} -- 976
		end, -- 975
		getSession = function() -- 980
			return session -- 980
		end -- 980
	} -- 956
end -- 953
_module_0["AuthSession"] = AuthSession -- 953
local transparant = Color(0x0) -- 983
local windowFlags = { -- 984
	"NoTitleBar", -- 984
	"NoResize", -- 984
	"NoMove", -- 984
	"NoCollapse", -- 984
	"NoSavedSettings", -- 984
	"NoFocusOnAppearing", -- 984
	"NoBringToFrontOnFocus" -- 984
} -- 984
local statusFlags = { -- 993
	"NoTitleBar", -- 993
	"NoResize", -- 993
	"NoMove", -- 993
	"NoCollapse", -- 993
	"AlwaysAutoResize", -- 993
	"NoSavedSettings" -- 993
} -- 993
local displayWindowFlags = { -- 1001
	"NoDecoration", -- 1001
	"NoSavedSettings", -- 1001
	"NoMove", -- 1001
	"NoScrollWithMouse", -- 1001
	"AlwaysAutoResize", -- 1001
	"NoFocusOnAppearing" -- 1001
} -- 1001
local gamepadInputWindowFlags = { -- 1009
	"NoDecoration", -- 1009
	"NoSavedSettings", -- 1009
	"NoMove", -- 1009
	"NoScrollbar", -- 1009
	"NoScrollWithMouse", -- 1009
	"NoFocusOnAppearing", -- 1009
	"NoBringToFrontOnFocus" -- 1009
} -- 1009
local initFooter = true -- 1018
local gamepadInputFocused = false -- 1019
local _anon_func_4 = function(allEntries, currentIndex) -- 1060
	if currentIndex > 1 then -- 1060
		return allEntries[currentIndex - 1] -- 1061
	else -- 1063
		return allEntries[#allEntries] -- 1063
	end -- 1060
end -- 1060
local _anon_func_5 = function(allEntries, currentIndex) -- 1067
	if currentIndex < #allEntries then -- 1067
		return allEntries[currentIndex + 1] -- 1068
	else -- 1070
		return allEntries[1] -- 1070
	end -- 1067
end -- 1067
footerWindow = threadLoop(function() -- 1020
	local zh = useChinese -- 1021
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1022
	if authCodeTTL <= 0 then -- 1023
		authCodeTTL = 30.0 -- 1024
		authCode = string.format("%06d", math.random(0, 999999)) -- 1025
	end -- 1023
	if HttpServer.wsConnectionCount > 0 then -- 1026
		return -- 1027
	end -- 1026
	if Keyboard:isKeyDown("Escape") then -- 1028
		allClear() -- 1029
		App.devMode = false -- 1030
		App:shutdown() -- 1031
	end -- 1028
	do -- 1032
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1033
		if ctrl and Keyboard:isKeyDown("Q") then -- 1034
			stop() -- 1035
		end -- 1034
		if ctrl and Keyboard:isKeyDown("Z") then -- 1036
			reloadCurrentEntry() -- 1037
		end -- 1036
		if ctrl and Keyboard:isKeyDown(",") then -- 1038
			if showFooter then -- 1039
				showStats = not showStats -- 1039
			else -- 1039
				showStats = true -- 1039
			end -- 1039
			showFooter = true -- 1040
			config.showFooter = showFooter -- 1041
			config.showStats = showStats -- 1042
		end -- 1038
		if ctrl and Keyboard:isKeyDown(".") then -- 1043
			if showFooter then -- 1044
				showConsole = not showConsole -- 1044
			else -- 1044
				showConsole = true -- 1044
			end -- 1044
			showFooter = true -- 1045
			config.showFooter = showFooter -- 1046
			config.showConsole = showConsole -- 1047
		end -- 1043
		if ctrl and Keyboard:isKeyDown("/") then -- 1048
			showFooter = not showFooter -- 1049
			config.showFooter = showFooter -- 1050
		end -- 1048
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1051
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1052
		local currentIndex = nil -- 1053
		for i, entry in ipairs(allEntries) do -- 1054
			if currentEntry == entry then -- 1055
				currentIndex = i -- 1056
			end -- 1055
		end -- 1054
		if left then -- 1057
			allClear() -- 1058
			if currentIndex == nil then -- 1059
				currentIndex = #allEntries + 1 -- 1059
			end -- 1059
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 1060
		end -- 1057
		if right then -- 1064
			allClear() -- 1065
			if currentIndex == nil then -- 1066
				currentIndex = 0 -- 1066
			end -- 1066
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1067
		end -- 1064
	end -- 1032
	if not showEntry then -- 1071
		return -- 1071
	end -- 1071
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1073
		reloadDevEntry() -- 1077
	end -- 1073
	if initFooter then -- 1078
		initFooter = false -- 1079
	end -- 1078
	local width, height -- 1081
	do -- 1081
		local _obj_0 = App.visualSize -- 1081
		width, height = _obj_0.width, _obj_0.height -- 1081
	end -- 1081
	if isInEntry then -- 1082
		gamepadInputFocused = false -- 1083
	else -- 1085
		SetNextWindowBgAlpha(0.0) -- 1085
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1086
		SetNextWindowPos(Vec2.zero, "Always") -- 1087
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1088
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1089
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1090
					if not gamepadInputFocused then -- 1091
						SetWindowFocus("DoraGamepadInput") -- 1092
						gamepadInputFocused = true -- 1093
					end -- 1091
				end) -- 1090
			end) -- 1089
		end) -- 1088
	end -- 1082
	if isInEntry or showFooter then -- 1095
		SetNextWindowSize(Vec2(width, 50)) -- 1096
		SetNextWindowPos(Vec2(0, height - 50)) -- 1097
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1098
			return PushStyleVar("WindowRounding", 0, function() -- 1099
				return Begin("Footer", windowFlags, function() -- 1100
					Separator() -- 1101
					if iconTex then -- 1102
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1103
							showStats = not showStats -- 1104
							config.showStats = showStats -- 1105
						end -- 1103
						SameLine() -- 1106
						if Button(">_", Vec2(30, 30)) then -- 1107
							showConsole = not showConsole -- 1108
							config.showConsole = showConsole -- 1109
						end -- 1107
					end -- 1102
					if isInEntry and config.updateNotification then -- 1110
						SameLine() -- 1111
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1112
							allClear() -- 1113
							config.updateNotification = false -- 1114
							enterDemoEntry({ -- 1116
								entryName = "SelfUpdater", -- 1116
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1117
							}) -- 1115
						end -- 1112
					end -- 1110
					if not isInEntry then -- 1118
						SameLine() -- 1119
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1120
						local currentIndex = nil -- 1121
						for i, entry in ipairs(allEntries) do -- 1122
							if currentEntry == entry then -- 1123
								currentIndex = i -- 1124
							end -- 1123
						end -- 1122
						if currentIndex then -- 1125
							if currentIndex > 1 then -- 1126
								SameLine() -- 1127
								if Button("<<", Vec2(30, 30)) then -- 1128
									allClear() -- 1129
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1130
								end -- 1128
							end -- 1126
							if currentIndex < #allEntries then -- 1131
								SameLine() -- 1132
								if Button(">>", Vec2(30, 30)) then -- 1133
									allClear() -- 1134
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1135
								end -- 1133
							end -- 1131
						end -- 1125
						SameLine() -- 1136
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1137
							reloadCurrentEntry() -- 1138
						end -- 1137
						if back then -- 1139
							allClear() -- 1140
							isInEntry = true -- 1141
							currentEntry = nil -- 1142
						end -- 1139
					end -- 1118
				end) -- 1100
			end) -- 1099
		end) -- 1098
	end -- 1095
	if isInEntry then -- 1144
		local showURL = true -- 1145
		local webIDEWidth -- 1146
		do -- 1146
			local base -- 1147
			if config.updateNotification then -- 1147
				base = 460 -- 1147
			else -- 1147
				base = 360 -- 1147
			end -- 1147
			local extra -- 1148
			if config.authRequired then -- 1148
				extra = 35 -- 1148
			else -- 1148
				extra = 0 -- 1148
			end -- 1148
			webIDEWidth = base + extra -- 1149
		end -- 1146
		if width < webIDEWidth then -- 1150
			showURL = false -- 1150
		end -- 1150
		SetNextWindowBgAlpha(0.0) -- 1151
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1152
		Begin("Web IDE", displayWindowFlags, function() -- 1153
			local pending = AuthSession.getPending() -- 1154
			local hovered = false -- 1155
			if not pending and showURL then -- 1156
				do -- 1157
					local url -- 1157
					if webStatus ~= nil then -- 1157
						url = webStatus.url -- 1157
					end -- 1157
					if url then -- 1157
						if isDesktop and not config.fullScreen then -- 1158
							if urlClicked then -- 1159
								BeginDisabled(function() -- 1160
									return Button(url) -- 1160
								end) -- 1160
							elseif Button(url) then -- 1161
								urlClicked = once(function() -- 1162
									return sleep(5) -- 1162
								end) -- 1162
								App:openURL("http://localhost:8866") -- 1163
							end -- 1159
						else -- 1165
							TextColored(descColor, url) -- 1165
						end -- 1158
					else -- 1167
						TextColored(descColor, zh and '不可用' or 'not available') -- 1167
					end -- 1157
				end -- 1157
				hovered = IsItemHovered() -- 1168
			else -- 1170
				TextColored(descColor, "(?)") -- 1170
				hovered = IsItemHovered() -- 1171
			end -- 1156
			SameLine() -- 1172
			local themeColor = App.themeColor -- 1173
			if pending then -- 1174
				if not pending.approved then -- 1175
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1176
					local ttl = pending.ttl or 1 -- 1177
					PushStyleColor("Text", themeColor, function() -- 1178
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1179
						hovered = hovered or IsItemHovered() -- 1180
					end) -- 1178
					SameLine() -- 1181
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1182
						AuthSession.approvePending(pending.sessionId) -- 1183
					end -- 1182
					if hovered then -- 1184
						return BeginTooltip(function() -- 1185
							return PushTextWrapPos(280, function() -- 1186
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1187
							end) -- 1186
						end) -- 1185
					end -- 1184
				end -- 1175
			else -- 1189
				if config.authRequired then -- 1189
					PushStyleColor("Text", themeColor, function() -- 1190
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1191
						hovered = hovered or IsItemHovered() -- 1192
					end) -- 1190
					if hovered then -- 1193
						return BeginTooltip(function() -- 1194
							return PushTextWrapPos(280, function() -- 1195
								local url -- 1196
								if webStatus ~= nil then -- 1196
									url = webStatus.url -- 1196
								end -- 1196
								if url then -- 1196
									local address -- 1197
									if showURL then -- 1197
										address = "Web IDE" -- 1197
									else -- 1197
										address = url -- 1197
									end -- 1197
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1198
								else -- 1200
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1200
								end -- 1196
							end) -- 1195
						end) -- 1194
					end -- 1193
				else -- 1202
					if hovered then -- 1202
						return BeginTooltip(function() -- 1203
							return PushTextWrapPos(280, function() -- 1204
								local url -- 1205
								if webStatus ~= nil then -- 1205
									url = webStatus.url -- 1205
								end -- 1205
								if url then -- 1205
									local address -- 1206
									if showURL then -- 1206
										address = "Web IDE" -- 1206
									else -- 1206
										address = url -- 1206
									end -- 1206
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1207
								else -- 1209
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1209
								end -- 1205
							end) -- 1204
						end) -- 1203
					end -- 1202
				end -- 1189
			end -- 1174
		end) -- 1153
	end -- 1144
	if not isInEntry then -- 1211
		SetNextWindowSize(Vec2(50, 50)) -- 1212
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1213
		PushStyleColor("WindowBg", transparant, function() -- 1214
			return Begin("Show", displayWindowFlags, function() -- 1214
				if width >= 370 then -- 1215
					local changed -- 1216
					changed, showFooter = Checkbox("##dev", showFooter) -- 1216
					if changed then -- 1216
						config.showFooter = showFooter -- 1217
					end -- 1216
				end -- 1215
			end) -- 1214
		end) -- 1214
	end -- 1211
	if isInEntry or showFooter then -- 1219
		if showStats then -- 1220
			PushStyleVar("WindowRounding", 0, function() -- 1221
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1222
				SetNextWindowSize(Vec2(0, height - 50)) -- 1223
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1224
				config.showStats = showStats -- 1225
			end) -- 1221
		end -- 1220
		if showConsole then -- 1226
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1227
			return PushStyleVar("WindowRounding", 6, function() -- 1228
				return ShowConsole() -- 1229
			end) -- 1228
		end -- 1226
	end -- 1219
end) -- 1020
local MaxWidth <const> = 960 -- 1231
local toolOpen = false -- 1233
local filterText = nil -- 1234
local anyEntryMatched = false -- 1235
local match -- 1236
match = function(name) -- 1236
	local res = not filterText or name:lower():match(filterText) -- 1237
	if res then -- 1238
		anyEntryMatched = true -- 1238
	end -- 1238
	return res -- 1239
end -- 1236
local sep -- 1241
sep = function() -- 1241
	return SeparatorText("") -- 1241
end -- 1241
local thinSep -- 1242
thinSep = function() -- 1242
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1242
end -- 1242
entryWindow = threadLoop(function() -- 1244
	if App.fpsLimited ~= config.fpsLimited then -- 1245
		config.fpsLimited = App.fpsLimited -- 1246
	end -- 1245
	if App.targetFPS ~= config.targetFPS then -- 1247
		config.targetFPS = App.targetFPS -- 1248
	end -- 1247
	if View.vsync ~= config.vsync then -- 1249
		config.vsync = View.vsync -- 1250
	end -- 1249
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1251
		config.fixedFPS = Director.scheduler.fixedFPS -- 1252
	end -- 1251
	if Director.profilerSending ~= config.webProfiler then -- 1253
		config.webProfiler = Director.profilerSending -- 1254
	end -- 1253
	if urlClicked then -- 1255
		local _, result = coroutine.resume(urlClicked) -- 1256
		if result then -- 1257
			coroutine.close(urlClicked) -- 1258
			urlClicked = nil -- 1259
		end -- 1257
	end -- 1255
	if not showEntry then -- 1260
		return -- 1260
	end -- 1260
	if not isInEntry then -- 1261
		return -- 1261
	end -- 1261
	local zh = useChinese -- 1262
	local themeColor = App.themeColor -- 1263
	if HttpServer.wsConnectionCount > 0 then -- 1264
		local width, height -- 1265
		do -- 1265
			local _obj_0 = App.visualSize -- 1265
			width, height = _obj_0.width, _obj_0.height -- 1265
		end -- 1265
		SetNextWindowBgAlpha(0.5) -- 1266
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1267
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1268
			Separator() -- 1269
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1270
			if iconTex then -- 1271
				Image(icon, Vec2(24, 24)) -- 1272
				SameLine() -- 1273
			end -- 1271
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1274
			TextColored(descColor, slogon) -- 1275
			return Separator() -- 1276
		end) -- 1268
		return -- 1277
	end -- 1264
	local fullWidth, height -- 1279
	do -- 1279
		local _obj_0 = App.visualSize -- 1279
		fullWidth, height = _obj_0.width, _obj_0.height -- 1279
	end -- 1279
	local width = math.min(MaxWidth, fullWidth) -- 1280
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1281
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1282
	SetNextWindowPos(Vec2.zero) -- 1283
	SetNextWindowBgAlpha(0) -- 1284
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1285
	do -- 1286
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1287
			return Begin("Dora Dev", windowFlags, function() -- 1288
				Dummy(Vec2(fullWidth - 20, 0)) -- 1289
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1290
				if fullWidth >= 400 then -- 1291
					SameLine() -- 1292
					Dummy(Vec2(fullWidth - 400, 0)) -- 1293
					SameLine() -- 1294
					SetNextItemWidth(zh and -95 or -140) -- 1295
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1296
						"AutoSelectAll" -- 1296
					}) then -- 1296
						config.filter = filterBuf.text -- 1297
					end -- 1296
					SameLine() -- 1298
					if Button(zh and '下载' or 'Download') then -- 1299
						allClear() -- 1300
						enterDemoEntry({ -- 1302
							entryName = "ResourceDownloader", -- 1302
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1303
						}) -- 1301
					end -- 1299
				end -- 1291
				return Separator() -- 1304
			end) -- 1288
		end) -- 1287
	end -- 1286
	anyEntryMatched = false -- 1306
	SetNextWindowPos(Vec2(0, 50)) -- 1307
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1308
	do -- 1309
		return PushStyleColor("WindowBg", transparant, function() -- 1310
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1311
				return PushStyleVar("Alpha", 1, function() -- 1312
					return Begin("Content", windowFlags, function() -- 1313
						local DemoViewWidth <const> = 220 -- 1314
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1315
						if filterText then -- 1316
							filterText = filterText:lower() -- 1316
						end -- 1316
						if #gamesInDev > 0 then -- 1317
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1318
							Columns(columns, false) -- 1319
							local realViewWidth = GetColumnWidth() - 50 -- 1320
							for _index_0 = 1, #gamesInDev do -- 1321
								local game = gamesInDev[_index_0] -- 1321
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1322
								local displayName -- 1331
								if repo then -- 1331
									if zh then -- 1332
										displayName = repo.title.zh -- 1332
									else -- 1332
										displayName = repo.title.en -- 1332
									end -- 1332
								end -- 1331
								if displayName == nil then -- 1333
									displayName = gameName -- 1333
								end -- 1333
								if match(displayName) then -- 1334
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1335
									SameLine() -- 1336
									TextWrapped(displayName) -- 1337
									if columns > 1 then -- 1338
										if bannerFile then -- 1339
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1340
											local displayWidth <const> = realViewWidth -- 1341
											texHeight = displayWidth * texHeight / texWidth -- 1342
											texWidth = displayWidth -- 1343
											Dummy(Vec2.zero) -- 1344
											SameLine() -- 1345
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1346
										end -- 1339
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1347
											enterDemoEntry(game) -- 1348
										end -- 1347
									else -- 1350
										if bannerFile then -- 1350
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1351
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1352
											local sizing = 0.8 -- 1353
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1354
											texWidth = displayWidth * sizing -- 1355
											if texWidth > 500 then -- 1356
												sizing = 0.6 -- 1357
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1358
												texWidth = displayWidth * sizing -- 1359
											end -- 1356
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1360
											Dummy(Vec2(padding, 0)) -- 1361
											SameLine() -- 1362
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1363
										end -- 1350
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1364
											enterDemoEntry(game) -- 1365
										end -- 1364
									end -- 1338
									if #tests == 0 and #examples == 0 then -- 1366
										thinSep() -- 1367
									end -- 1366
									NextColumn() -- 1368
								end -- 1334
								local showSep = false -- 1369
								if #examples > 0 then -- 1370
									local showExample = false -- 1371
									for _index_1 = 1, #examples do -- 1372
										local _des_0 = examples[_index_1] -- 1372
										local entryName = _des_0.entryName -- 1372
										if match(entryName) then -- 1373
											showExample = true -- 1373
											break -- 1373
										end -- 1373
									end -- 1372
									if showExample then -- 1374
										showSep = true -- 1375
										Columns(1, false) -- 1376
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1377
										SameLine() -- 1378
										local opened -- 1379
										if (filterText ~= nil) then -- 1379
											opened = showExample -- 1379
										else -- 1379
											opened = false -- 1379
										end -- 1379
										if game.exampleOpen == nil then -- 1380
											game.exampleOpen = opened -- 1380
										end -- 1380
										SetNextItemOpen(game.exampleOpen) -- 1381
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1382
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1383
												Columns(maxColumns, false) -- 1384
												for _index_1 = 1, #examples do -- 1385
													local example = examples[_index_1] -- 1385
													local entryName = example.entryName -- 1386
													if not match(entryName) then -- 1387
														goto _continue_0 -- 1387
													end -- 1387
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1388
														if Button(entryName, Vec2(-1, 40)) then -- 1389
															enterDemoEntry(example) -- 1390
														end -- 1389
														return NextColumn() -- 1391
													end) -- 1388
													opened = true -- 1392
													::_continue_0:: -- 1386
												end -- 1385
											end) -- 1383
										end) -- 1382
										game.exampleOpen = opened -- 1393
									end -- 1374
								end -- 1370
								if #tests > 0 then -- 1394
									local showTest = false -- 1395
									for _index_1 = 1, #tests do -- 1396
										local _des_0 = tests[_index_1] -- 1396
										local entryName = _des_0.entryName -- 1396
										if match(entryName) then -- 1397
											showTest = true -- 1397
											break -- 1397
										end -- 1397
									end -- 1396
									if showTest then -- 1398
										showSep = true -- 1399
										Columns(1, false) -- 1400
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1401
										SameLine() -- 1402
										local opened -- 1403
										if (filterText ~= nil) then -- 1403
											opened = showTest -- 1403
										else -- 1403
											opened = false -- 1403
										end -- 1403
										if game.testOpen == nil then -- 1404
											game.testOpen = opened -- 1404
										end -- 1404
										SetNextItemOpen(game.testOpen) -- 1405
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1406
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1407
												Columns(maxColumns, false) -- 1408
												for _index_1 = 1, #tests do -- 1409
													local test = tests[_index_1] -- 1409
													local entryName = test.entryName -- 1410
													if not match(entryName) then -- 1411
														goto _continue_0 -- 1411
													end -- 1411
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1412
														if Button(entryName, Vec2(-1, 40)) then -- 1413
															enterDemoEntry(test) -- 1414
														end -- 1413
														return NextColumn() -- 1415
													end) -- 1412
													opened = true -- 1416
													::_continue_0:: -- 1410
												end -- 1409
											end) -- 1407
										end) -- 1406
										game.testOpen = opened -- 1417
									end -- 1398
								end -- 1394
								if showSep then -- 1418
									Columns(1, false) -- 1419
									thinSep() -- 1420
									Columns(columns, false) -- 1421
								end -- 1418
							end -- 1321
						end -- 1317
						if #doraTools > 0 then -- 1422
							local showTool = false -- 1423
							for _index_0 = 1, #doraTools do -- 1424
								local _des_0 = doraTools[_index_0] -- 1424
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1424
								local displayName -- 1425
								if repo then -- 1425
									if zh then -- 1426
										displayName = repo.title.zh -- 1426
									else -- 1426
										displayName = repo.title.en -- 1426
									end -- 1426
								end -- 1425
								if displayName == nil then -- 1427
									displayName = entryName -- 1427
								end -- 1427
								if match(displayName) then -- 1428
									showTool = true -- 1428
									break -- 1428
								end -- 1428
							end -- 1424
							if not showTool then -- 1429
								goto endEntry -- 1429
							end -- 1429
							Columns(1, false) -- 1430
							TextColored(themeColor, "Dora SSR:") -- 1431
							SameLine() -- 1432
							Text(zh and "开发支持" or "Development Support") -- 1433
							Separator() -- 1434
							if #doraTools > 0 then -- 1435
								local opened -- 1436
								if (filterText ~= nil) then -- 1436
									opened = showTool -- 1436
								else -- 1436
									opened = false -- 1436
								end -- 1436
								SetNextItemOpen(toolOpen) -- 1437
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1438
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1439
										Columns(maxColumns, false) -- 1440
										for _index_0 = 1, #doraTools do -- 1441
											local tool = doraTools[_index_0] -- 1441
											local entryName, repo = tool.entryName, tool.repo -- 1442
											local displayName -- 1443
											if repo then -- 1443
												if zh then -- 1444
													displayName = repo.title.zh -- 1444
												else -- 1444
													displayName = repo.title.en -- 1444
												end -- 1444
											end -- 1443
											if displayName == nil then -- 1445
												displayName = entryName -- 1445
											end -- 1445
											if not match(displayName) then -- 1446
												goto _continue_0 -- 1446
											end -- 1446
											if Button(displayName, Vec2(-1, 40)) then -- 1447
												enterDemoEntry(tool) -- 1448
											end -- 1447
											NextColumn() -- 1449
											::_continue_0:: -- 1442
										end -- 1441
										Columns(1, false) -- 1450
										opened = true -- 1451
									end) -- 1439
								end) -- 1438
								toolOpen = opened -- 1452
							end -- 1435
						end -- 1422
						::endEntry:: -- 1453
						if not anyEntryMatched then -- 1454
							SetNextWindowBgAlpha(0) -- 1455
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1456
							Begin("Entries Not Found", displayWindowFlags, function() -- 1457
								Separator() -- 1458
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1459
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1460
								return Separator() -- 1461
							end) -- 1457
						end -- 1454
						Columns(1, false) -- 1462
						Dummy(Vec2(100, 80)) -- 1463
						return ScrollWhenDraggingOnVoid() -- 1464
					end) -- 1313
				end) -- 1312
			end) -- 1311
		end) -- 1310
	end -- 1309
end) -- 1244
webStatus = oldRequire("Script.Dev.WebServer") -- 1467
return _module_0 -- 1
