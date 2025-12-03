-- [yue]: Script/Dev/Entry.yue
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local ShowConsole = _module_0.ShowConsole -- 1
local package = _G.package -- 1
local DB = Dora.DB -- 1
local View = Dora.View -- 1
local Director = Dora.Director -- 1
local Size = Dora.Size -- 1
local Vec2 = Dora.Vec2 -- 1
local Color = Dora.Color -- 1
local Buffer = Dora.Buffer -- 1
local thread = Dora.thread -- 1
local HttpClient = Dora.HttpClient -- 1
local json = Dora.json -- 1
local tonumber = _G.tonumber -- 1
local os = _G.os -- 1
local yue = Dora.yue -- 1
local SetDefaultFont = _module_0.SetDefaultFont -- 1
local table = _G.table -- 1
local Cache = Dora.Cache -- 1
local Texture2D = Dora.Texture2D -- 1
local pairs = _G.pairs -- 1
local tostring = _G.tostring -- 1
local string = _G.string -- 1
local print = _G.print -- 1
local xml = Dora.xml -- 1
local teal = Dora.teal -- 1
local wait = Dora.wait -- 1
local Routine = Dora.Routine -- 1
local Entity = Dora.Entity -- 1
local Platformer = Dora.Platformer -- 1
local Audio = Dora.Audio -- 1
local ubox = Dora.ubox -- 1
local tolua = Dora.tolua -- 1
local collectgarbage = _G.collectgarbage -- 1
local Wasm = Dora.Wasm -- 1
local sleep = Dora.sleep -- 1
local HttpServer = Dora.HttpServer -- 1
local once = Dora.once -- 1
local emit = Dora.emit -- 1
local Profiler = Dora.Profiler -- 1
local xpcall = _G.xpcall -- 1
local debug = _G.debug -- 1
local Log = Dora.Log -- 1
local math = _G.math -- 1
local AlignNode = Dora.AlignNode -- 1
local Label = Dora.Label -- 1
local Checkbox = _module_0.Checkbox -- 1
local SeparatorText = _module_0.SeparatorText -- 1
local PushTextWrapPos = _module_0.PushTextWrapPos -- 1
local TextColored = _module_0.TextColored -- 1
local Button = _module_0.Button -- 1
local SameLine = _module_0.SameLine -- 1
local Separator = _module_0.Separator -- 1
local SetNextWindowPosCenter = _module_0.SetNextWindowPosCenter -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local PushStyleVar = _module_0.PushStyleVar -- 1
local Begin = _module_0.Begin -- 1
local TreeNode = _module_0.TreeNode -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local OpenPopup = _module_0.OpenPopup -- 1
local BeginPopup = _module_0.BeginPopup -- 1
local Selectable = _module_0.Selectable -- 1
local BeginDisabled = _module_0.BeginDisabled -- 1
local setmetatable = _G.setmetatable -- 1
local ipairs = _G.ipairs -- 1
local threadLoop = Dora.threadLoop -- 1
local Keyboard = Dora.Keyboard -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local ImageButton = _module_0.ImageButton -- 1
local ImGui = Dora.ImGui -- 1
local SetNextWindowBgAlpha = _module_0.SetNextWindowBgAlpha -- 1
local TextDisabled = _module_0.TextDisabled -- 1
local IsItemHovered = _module_0.IsItemHovered -- 1
local BeginTooltip = _module_0.BeginTooltip -- 1
local Text = _module_0.Text -- 1
local PushStyleColor = _module_0.PushStyleColor -- 1
local ShowStats = _module_0.ShowStats -- 1
local coroutine = _G.coroutine -- 1
local Image = _module_0.Image -- 1
local Dummy = _module_0.Dummy -- 1
local SetNextItemWidth = _module_0.SetNextItemWidth -- 1
local InputText = _module_0.InputText -- 1
local Columns = _module_0.Columns -- 1
local GetColumnWidth = _module_0.GetColumnWidth -- 1
local NextColumn = _module_0.NextColumn -- 1
local SetNextItemOpen = _module_0.SetNextItemOpen -- 1
local PushID = _module_0.PushID -- 1
local ScrollWhenDraggingOnVoid = _module_0.ScrollWhenDraggingOnVoid -- 1
local _module_0 = { } -- 1
local Content, Path -- 11
do -- 11
	local _obj_0 = Dora -- 11
	Content, Path = _obj_0.Content, _obj_0.Path -- 11
end -- 11
local type <const> = type -- 12
App.idled = true -- 14
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
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected") -- 50
config:load() -- 77
if not (config.writablePath ~= nil) then -- 79
	config.writablePath = Content.appPath -- 80
end -- 79
if not (config.webIDEConnected ~= nil) then -- 82
	config.webIDEConnected = false -- 83
end -- 82
if (config.fpsLimited ~= nil) then -- 85
	App.fpsLimited = config.fpsLimited -- 86
else -- 88
	config.fpsLimited = App.fpsLimited -- 88
end -- 85
if (config.targetFPS ~= nil) then -- 90
	App.targetFPS = config.targetFPS -- 91
else -- 93
	config.targetFPS = App.targetFPS -- 93
end -- 90
if (config.vsync ~= nil) then -- 95
	View.vsync = config.vsync -- 96
else -- 98
	config.vsync = View.vsync -- 98
end -- 95
if (config.fixedFPS ~= nil) then -- 100
	Director.scheduler.fixedFPS = config.fixedFPS -- 101
else -- 103
	config.fixedFPS = Director.scheduler.fixedFPS -- 103
end -- 100
local showEntry = true -- 105
isDesktop = false -- 107
if (function() -- 108
	local _val_0 = App.platform -- 108
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 108
end)() then -- 108
	isDesktop = true -- 109
	if config.fullScreen then -- 110
		App.fullScreen = true -- 111
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 112
		local size = Size(config.winWidth, config.winHeight) -- 113
		if App.winSize ~= size then -- 114
			App.winSize = size -- 115
		end -- 114
		local winX, winY -- 116
		do -- 116
			local _obj_0 = App.winPosition -- 116
			winX, winY = _obj_0.x, _obj_0.y -- 116
		end -- 116
		if (config.winX ~= nil) then -- 117
			winX = config.winX -- 118
		else -- 120
			config.winX = -1 -- 120
		end -- 117
		if (config.winY ~= nil) then -- 121
			winY = config.winY -- 122
		else -- 124
			config.winY = -1 -- 124
		end -- 121
		App.winPosition = Vec2(winX, winY) -- 125
	end -- 110
	if (config.alwaysOnTop ~= nil) then -- 126
		App.alwaysOnTop = config.alwaysOnTop -- 127
	else -- 129
		config.alwaysOnTop = true -- 129
	end -- 126
end -- 108
if (config.themeColor ~= nil) then -- 131
	App.themeColor = Color(config.themeColor) -- 132
else -- 134
	config.themeColor = App.themeColor:toARGB() -- 134
end -- 131
if not (config.locale ~= nil) then -- 136
	config.locale = App.locale -- 137
end -- 136
local showStats = false -- 139
if (config.showStats ~= nil) then -- 140
	showStats = config.showStats -- 141
else -- 143
	config.showStats = showStats -- 143
end -- 140
local showConsole = false -- 145
if (config.showConsole ~= nil) then -- 146
	showConsole = config.showConsole -- 147
else -- 149
	config.showConsole = showConsole -- 149
end -- 146
local showFooter = true -- 151
if (config.showFooter ~= nil) then -- 152
	showFooter = config.showFooter -- 153
else -- 155
	config.showFooter = showFooter -- 155
end -- 152
local filterBuf = Buffer(20) -- 157
if (config.filter ~= nil) then -- 158
	filterBuf.text = config.filter -- 159
else -- 161
	config.filter = "" -- 161
end -- 158
local engineDev = false -- 163
if (config.engineDev ~= nil) then -- 164
	engineDev = config.engineDev -- 165
else -- 167
	config.engineDev = engineDev -- 167
end -- 164
if (config.webProfiler ~= nil) then -- 169
	Director.profilerSending = config.webProfiler -- 170
else -- 172
	config.webProfiler = true -- 172
	Director.profilerSending = true -- 173
end -- 169
if not (config.drawerWidth ~= nil) then -- 175
	config.drawerWidth = 200 -- 176
end -- 175
_module_0.getConfig = function() -- 178
	return config -- 178
end -- 178
_module_0.getEngineDev = function() -- 179
	if not App.debugging then -- 180
		return false -- 180
	end -- 180
	return config.engineDev -- 181
end -- 179
local _anon_func_0 = function(App) -- 186
	local _val_0 = App.platform -- 186
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 186
end -- 186
_module_0.connectWebIDE = function() -- 183
	if not config.webIDEConnected then -- 184
		config.webIDEConnected = true -- 185
		if _anon_func_0(App) then -- 186
			local ratio = App.winSize.width / App.visualSize.width -- 187
			App.winSize = Size(640 * ratio, 480 * ratio) -- 188
		end -- 186
	end -- 184
end -- 183
local updateCheck -- 190
updateCheck = function() -- 190
	return thread(function() -- 190
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 191
		if res then -- 191
			local data = json.decode(res) -- 192
			if data then -- 192
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 193
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 194
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 195
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 196
				if na < a then -- 197
					goto not_new_version -- 198
				end -- 197
				if na == a then -- 199
					if nb < b then -- 200
						goto not_new_version -- 201
					end -- 200
					if nb == b then -- 202
						if nc < c then -- 203
							goto not_new_version -- 204
						end -- 203
						if nc == c then -- 205
							goto not_new_version -- 206
						end -- 205
					end -- 202
				end -- 199
				config.updateNotification = true -- 207
				::not_new_version:: -- 208
				config.lastUpdateCheck = os.time() -- 209
			end -- 192
		end -- 191
	end) -- 190
end -- 190
if (config.lastUpdateCheck ~= nil) then -- 211
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 212
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 213
		updateCheck() -- 214
	end -- 213
else -- 216
	updateCheck() -- 216
end -- 211
local Set, Struct, LintYueGlobals, GSplit -- 218
do -- 218
	local _obj_0 = require("Utils") -- 218
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 218
end -- 218
local yueext = yue.options.extension -- 219
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 221
local building = false -- 223
local getAllFiles -- 225
getAllFiles = function(path, exts, recursive) -- 225
	if recursive == nil then -- 225
		recursive = true -- 225
	end -- 225
	local filters = Set(exts) -- 226
	local files -- 227
	if recursive then -- 227
		files = Content:getAllFiles(path) -- 228
	else -- 230
		files = Content:getFiles(path) -- 230
	end -- 227
	local _accum_0 = { } -- 231
	local _len_0 = 1 -- 231
	for _index_0 = 1, #files do -- 231
		local file = files[_index_0] -- 231
		if not filters[Path:getExt(file)] then -- 232
			goto _continue_0 -- 232
		end -- 232
		_accum_0[_len_0] = file -- 233
		_len_0 = _len_0 + 1 -- 232
		::_continue_0:: -- 232
	end -- 231
	return _accum_0 -- 231
end -- 225
_module_0["getAllFiles"] = getAllFiles -- 225
local getFileEntries -- 235
getFileEntries = function(path, recursive, excludeFiles) -- 235
	if recursive == nil then -- 235
		recursive = true -- 235
	end -- 235
	if excludeFiles == nil then -- 235
		excludeFiles = nil -- 235
	end -- 235
	local entries = { } -- 236
	local excludes -- 237
	if excludeFiles then -- 237
		excludes = Set(excludeFiles) -- 238
	end -- 237
	local _list_0 = getAllFiles(path, { -- 239
		"lua", -- 239
		"xml", -- 239
		yueext, -- 239
		"tl" -- 239
	}, recursive) -- 239
	for _index_0 = 1, #_list_0 do -- 239
		local file = _list_0[_index_0] -- 239
		local entryName = Path:getName(file) -- 240
		if excludes and excludes[entryName] then -- 241
			goto _continue_0 -- 242
		end -- 241
		local fileName = Path:replaceExt(file, "") -- 243
		fileName = Path(path, fileName) -- 244
		local entryAdded -- 245
		do -- 245
			local _accum_0 -- 245
			for _index_1 = 1, #entries do -- 245
				local _des_0 = entries[_index_1] -- 245
				local ename, efile = _des_0[1], _des_0[2] -- 245
				if entryName == ename and efile == fileName then -- 246
					_accum_0 = true -- 246
					break -- 246
				end -- 246
			end -- 245
			entryAdded = _accum_0 -- 245
		end -- 245
		if entryAdded then -- 247
			goto _continue_0 -- 247
		end -- 247
		local entry = { -- 248
			entryName, -- 248
			fileName -- 248
		} -- 248
		entries[#entries + 1] = entry -- 249
		::_continue_0:: -- 240
	end -- 239
	table.sort(entries, function(a, b) -- 250
		return a[1] < b[1] -- 250
	end) -- 250
	return entries -- 251
end -- 235
local getProjectEntries -- 253
getProjectEntries = function(path) -- 253
	local entries = { } -- 254
	local _list_0 = Content:getDirs(path) -- 255
	for _index_0 = 1, #_list_0 do -- 255
		local dir = _list_0[_index_0] -- 255
		if dir:match("^%.") then -- 256
			goto _continue_0 -- 256
		end -- 256
		local _list_1 = getAllFiles(Path(path, dir), { -- 257
			"lua", -- 257
			"xml", -- 257
			yueext, -- 257
			"tl", -- 257
			"wasm" -- 257
		}) -- 257
		for _index_1 = 1, #_list_1 do -- 257
			local file = _list_1[_index_1] -- 257
			if "init" == Path:getName(file):lower() then -- 258
				local fileName = Path:replaceExt(file, "") -- 259
				fileName = Path(path, dir, fileName) -- 260
				local entryName = Path:getName(Path:getPath(fileName)) -- 261
				local entryAdded -- 262
				do -- 262
					local _accum_0 -- 262
					for _index_2 = 1, #entries do -- 262
						local _des_0 = entries[_index_2] -- 262
						local ename, efile = _des_0[1], _des_0[2] -- 262
						if entryName == ename and efile == fileName then -- 263
							_accum_0 = true -- 263
							break -- 263
						end -- 263
					end -- 262
					entryAdded = _accum_0 -- 262
				end -- 262
				if entryAdded then -- 264
					goto _continue_1 -- 264
				end -- 264
				local examples = { } -- 265
				local tests = { } -- 266
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 267
				if Content:exist(examplePath) then -- 268
					local _list_2 = getFileEntries(examplePath) -- 269
					for _index_2 = 1, #_list_2 do -- 269
						local _des_0 = _list_2[_index_2] -- 269
						local name, ePath = _des_0[1], _des_0[2] -- 269
						local entry = { -- 271
							name, -- 271
							Path(path, dir, Path:getPath(file), ePath), -- 271
							workDir = Path:getPath(fileName) -- 272
						} -- 270
						examples[#examples + 1] = entry -- 274
					end -- 269
				end -- 268
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 275
				if Content:exist(testPath) then -- 276
					local _list_2 = getFileEntries(testPath) -- 277
					for _index_2 = 1, #_list_2 do -- 277
						local _des_0 = _list_2[_index_2] -- 277
						local name, tPath = _des_0[1], _des_0[2] -- 277
						local entry = { -- 279
							name, -- 279
							Path(path, dir, Path:getPath(file), tPath), -- 279
							workDir = Path:getPath(fileName) -- 280
						} -- 278
						tests[#tests + 1] = entry -- 282
					end -- 277
				end -- 276
				local entry = { -- 283
					entryName, -- 283
					fileName, -- 283
					examples, -- 283
					tests -- 283
				} -- 283
				local bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.png") -- 284
				if not Content:exist(bannerFile) then -- 285
					bannerFile = Path(path, Path:getPath(fileName), "Image", "banner.jpg") -- 286
					if not Content:exist(bannerFile) then -- 287
						bannerFile = nil -- 287
					end -- 287
				end -- 285
				if bannerFile then -- 288
					thread(function() -- 288
						if Cache:loadAsync(bannerFile) then -- 289
							local bannerTex = Texture2D(bannerFile) -- 290
							if bannerTex then -- 290
								entry[#entry + 1] = bannerFile -- 291
								entry[#entry + 1] = bannerTex -- 292
							end -- 290
						end -- 289
					end) -- 288
				end -- 288
				entries[#entries + 1] = entry -- 293
			end -- 258
			::_continue_1:: -- 258
		end -- 257
		::_continue_0:: -- 256
	end -- 255
	table.sort(entries, function(a, b) -- 294
		return a[1] < b[1] -- 294
	end) -- 294
	return entries -- 295
end -- 253
local gamesInDev -- 297
local doraTools -- 298
local allEntries -- 299
local updateEntries -- 301
updateEntries = function() -- 301
	gamesInDev = getProjectEntries(Content.writablePath) -- 302
	doraTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 303
	allEntries = { } -- 305
	for _index_0 = 1, #gamesInDev do -- 306
		local game = gamesInDev[_index_0] -- 306
		allEntries[#allEntries + 1] = game -- 307
		local examples, tests = game[3], game[4] -- 308
		for _index_1 = 1, #examples do -- 309
			local example = examples[_index_1] -- 309
			allEntries[#allEntries + 1] = example -- 310
		end -- 309
		for _index_1 = 1, #tests do -- 311
			local test = tests[_index_1] -- 311
			allEntries[#allEntries + 1] = test -- 312
		end -- 311
	end -- 306
end -- 301
updateEntries() -- 314
local doCompile -- 316
doCompile = function(minify) -- 316
	if building then -- 317
		return -- 317
	end -- 317
	building = true -- 318
	local startTime = App.runningTime -- 319
	local luaFiles = { } -- 320
	local yueFiles = { } -- 321
	local xmlFiles = { } -- 322
	local tlFiles = { } -- 323
	local writablePath = Content.writablePath -- 324
	local buildPaths = { -- 326
		{ -- 327
			Content.assetPath, -- 327
			Path(writablePath, ".build"), -- 328
			"" -- 329
		} -- 326
	} -- 325
	for _index_0 = 1, #gamesInDev do -- 332
		local _des_0 = gamesInDev[_index_0] -- 332
		local entryFile = _des_0[2] -- 332
		local gamePath = Path:getPath(Path:getRelative(entryFile, writablePath)) -- 333
		buildPaths[#buildPaths + 1] = { -- 335
			Path(writablePath, gamePath), -- 335
			Path(writablePath, ".build", gamePath), -- 336
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 337
			gamePath -- 338
		} -- 334
	end -- 332
	for _index_0 = 1, #buildPaths do -- 339
		local _des_0 = buildPaths[_index_0] -- 339
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 339
		if not Content:exist(inputPath) then -- 340
			goto _continue_0 -- 340
		end -- 340
		local _list_0 = getAllFiles(inputPath, { -- 342
			"lua" -- 342
		}) -- 342
		for _index_1 = 1, #_list_0 do -- 342
			local file = _list_0[_index_1] -- 342
			luaFiles[#luaFiles + 1] = { -- 344
				file, -- 344
				Path(inputPath, file), -- 345
				Path(outputPath, file), -- 346
				gamePath -- 347
			} -- 343
		end -- 342
		local _list_1 = getAllFiles(inputPath, { -- 349
			yueext -- 349
		}) -- 349
		for _index_1 = 1, #_list_1 do -- 349
			local file = _list_1[_index_1] -- 349
			yueFiles[#yueFiles + 1] = { -- 351
				file, -- 351
				Path(inputPath, file), -- 352
				Path(outputPath, Path:replaceExt(file, "lua")), -- 353
				searchPath, -- 354
				gamePath -- 355
			} -- 350
		end -- 349
		local _list_2 = getAllFiles(inputPath, { -- 357
			"xml" -- 357
		}) -- 357
		for _index_1 = 1, #_list_2 do -- 357
			local file = _list_2[_index_1] -- 357
			xmlFiles[#xmlFiles + 1] = { -- 359
				file, -- 359
				Path(inputPath, file), -- 360
				Path(outputPath, Path:replaceExt(file, "lua")), -- 361
				gamePath -- 362
			} -- 358
		end -- 357
		local _list_3 = getAllFiles(inputPath, { -- 364
			"tl" -- 364
		}) -- 364
		for _index_1 = 1, #_list_3 do -- 364
			local file = _list_3[_index_1] -- 364
			if not file:match(".*%.d%.tl$") then -- 365
				tlFiles[#tlFiles + 1] = { -- 367
					file, -- 367
					Path(inputPath, file), -- 368
					Path(outputPath, Path:replaceExt(file, "lua")), -- 369
					searchPath, -- 370
					gamePath -- 371
				} -- 366
			end -- 365
		end -- 364
		::_continue_0:: -- 340
	end -- 339
	local paths -- 373
	do -- 373
		local _tbl_0 = { } -- 373
		local _list_0 = { -- 374
			luaFiles, -- 374
			yueFiles, -- 374
			xmlFiles, -- 374
			tlFiles -- 374
		} -- 374
		for _index_0 = 1, #_list_0 do -- 374
			local files = _list_0[_index_0] -- 374
			for _index_1 = 1, #files do -- 375
				local file = files[_index_1] -- 375
				_tbl_0[Path:getPath(file[3])] = true -- 373
			end -- 373
		end -- 373
		paths = _tbl_0 -- 373
	end -- 373
	for path in pairs(paths) do -- 377
		Content:mkdir(path) -- 377
	end -- 377
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 379
	local fileCount = 0 -- 380
	local errors = { } -- 381
	for _index_0 = 1, #yueFiles do -- 382
		local _des_0 = yueFiles[_index_0] -- 382
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 382
		local filename -- 383
		if gamePath then -- 383
			filename = Path(gamePath, file) -- 383
		else -- 383
			filename = file -- 383
		end -- 383
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 384
			if not codes then -- 385
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 386
				return -- 387
			end -- 385
			local success, result = LintYueGlobals(codes, globals) -- 388
			if success then -- 389
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 390
				codes = codes:gsub("%s*local%s*_ENV%s*=%s*Dora[^%w_$][^\n\r]+[\n\r%s]*", "\n") -- 391
				codes = codes:gsub("^\n*", "") -- 392
				if not (result == "") then -- 393
					result = result .. "\n" -- 393
				end -- 393
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(result) .. tostring(codes) -- 394
			else -- 396
				local yueCodes = Content:load(input) -- 396
				if yueCodes then -- 396
					local globalErrors = { } -- 397
					for _index_1 = 1, #result do -- 398
						local _des_1 = result[_index_1] -- 398
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 398
						local countLine = 1 -- 399
						local code = "" -- 400
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 401
							if countLine == line then -- 402
								code = lineCode -- 403
								break -- 404
							end -- 402
							countLine = countLine + 1 -- 405
						end -- 401
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 406
					end -- 398
					errors[#errors + 1] = table.concat(globalErrors, "\n") -- 407
				else -- 409
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 409
				end -- 396
			end -- 389
		end, function(success) -- 384
			if success then -- 410
				print("Yue compiled: " .. tostring(filename)) -- 410
			end -- 410
			fileCount = fileCount + 1 -- 411
		end) -- 384
	end -- 382
	thread(function() -- 413
		for _index_0 = 1, #xmlFiles do -- 414
			local _des_0 = xmlFiles[_index_0] -- 414
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 414
			local filename -- 415
			if gamePath then -- 415
				filename = Path(gamePath, file) -- 415
			else -- 415
				filename = file -- 415
			end -- 415
			local sourceCodes = Content:loadAsync(input) -- 416
			local codes, err = xml.tolua(sourceCodes) -- 417
			if not codes then -- 418
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 419
			else -- 421
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 421
				print("Xml compiled: " .. tostring(filename)) -- 422
			end -- 418
			fileCount = fileCount + 1 -- 423
		end -- 414
	end) -- 413
	thread(function() -- 425
		for _index_0 = 1, #tlFiles do -- 426
			local _des_0 = tlFiles[_index_0] -- 426
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 426
			local filename -- 427
			if gamePath then -- 427
				filename = Path(gamePath, file) -- 427
			else -- 427
				filename = file -- 427
			end -- 427
			local sourceCodes = Content:loadAsync(input) -- 428
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 429
			if not codes then -- 430
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 431
			else -- 433
				Content:saveAsync(output, codes) -- 433
				print("Teal compiled: " .. tostring(filename)) -- 434
			end -- 430
			fileCount = fileCount + 1 -- 435
		end -- 426
	end) -- 425
	return thread(function() -- 437
		wait(function() -- 438
			return fileCount == totalFiles -- 438
		end) -- 438
		if minify then -- 439
			local _list_0 = { -- 440
				yueFiles, -- 440
				xmlFiles, -- 440
				tlFiles -- 440
			} -- 440
			for _index_0 = 1, #_list_0 do -- 440
				local files = _list_0[_index_0] -- 440
				for _index_1 = 1, #files do -- 440
					local file = files[_index_1] -- 440
					local output = Path:replaceExt(file[3], "lua") -- 441
					luaFiles[#luaFiles + 1] = { -- 443
						Path:replaceExt(file[1], "lua"), -- 443
						output, -- 444
						output -- 445
					} -- 442
				end -- 440
			end -- 440
			local FormatMini -- 447
			do -- 447
				local _obj_0 = require("luaminify") -- 447
				FormatMini = _obj_0.FormatMini -- 447
			end -- 447
			for _index_0 = 1, #luaFiles do -- 448
				local _des_0 = luaFiles[_index_0] -- 448
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 448
				if Content:exist(input) then -- 449
					local sourceCodes = Content:loadAsync(input) -- 450
					local res, err = FormatMini(sourceCodes) -- 451
					if res then -- 452
						Content:saveAsync(output, res) -- 453
						print("Minify: " .. tostring(file)) -- 454
					else -- 456
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 456
					end -- 452
				else -- 458
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 458
				end -- 449
			end -- 448
			package.loaded["luaminify.FormatMini"] = nil -- 459
			package.loaded["luaminify.ParseLua"] = nil -- 460
			package.loaded["luaminify.Scope"] = nil -- 461
			package.loaded["luaminify.Util"] = nil -- 462
		end -- 439
		local errorMessage = table.concat(errors, "\n") -- 463
		if errorMessage ~= "" then -- 464
			print(errorMessage) -- 464
		end -- 464
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 465
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 466
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 467
		Content:clearPathCache() -- 468
		teal.clear() -- 469
		yue.clear() -- 470
		building = false -- 471
	end) -- 437
end -- 316
local doClean -- 473
doClean = function() -- 473
	if building then -- 474
		return -- 474
	end -- 474
	local writablePath = Content.writablePath -- 475
	local targetDir = Path(writablePath, ".build") -- 476
	Content:clearPathCache() -- 477
	if Content:remove(targetDir) then -- 478
		return print("Cleaned: " .. tostring(targetDir)) -- 479
	end -- 478
end -- 473
local screenScale = 2.0 -- 481
local scaleContent = false -- 482
local isInEntry = true -- 483
local currentEntry = nil -- 484
local footerWindow = nil -- 486
local entryWindow = nil -- 487
local testingThread = nil -- 488
local setupEventHandlers = nil -- 490
local allClear -- 492
allClear = function() -- 492
	local _list_0 = Routine -- 493
	for _index_0 = 1, #_list_0 do -- 493
		local routine = _list_0[_index_0] -- 493
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 495
			goto _continue_0 -- 496
		else -- 498
			Routine:remove(routine) -- 498
		end -- 494
		::_continue_0:: -- 494
	end -- 493
	for _index_0 = 1, #moduleCache do -- 499
		local module = moduleCache[_index_0] -- 499
		package.loaded[module] = nil -- 500
	end -- 499
	moduleCache = { } -- 501
	Director:cleanup() -- 502
	Entity:clear() -- 503
	Platformer.Data:clear() -- 504
	Platformer.UnitAction:clear() -- 505
	Audio:stopStream(0.5) -- 506
	Struct:clear() -- 507
	View.postEffect = nil -- 508
	View.scale = scaleContent and screenScale or 1 -- 509
	Director.clearColor = Color(0xff1a1a1a) -- 510
	teal.clear() -- 511
	yue.clear() -- 512
	for _, item in pairs(ubox()) do -- 513
		local node = tolua.cast(item, "Node") -- 514
		if node then -- 514
			node:cleanup() -- 514
		end -- 514
	end -- 513
	collectgarbage() -- 515
	collectgarbage() -- 516
	Wasm:clear() -- 517
	thread(function() -- 518
		sleep() -- 519
		return Cache:removeUnused() -- 520
	end) -- 518
	setupEventHandlers() -- 521
	Content.searchPaths = searchPaths -- 522
	App.idled = true -- 523
end -- 492
_module_0["allClear"] = allClear -- 492
local clearTempFiles -- 525
clearTempFiles = function() -- 525
	local writablePath = Content.writablePath -- 526
	Content:remove(Path(writablePath, ".upload")) -- 527
	return Content:remove(Path(writablePath, ".download")) -- 528
end -- 525
local waitForWebStart = true -- 530
thread(function() -- 531
	sleep(2) -- 532
	waitForWebStart = false -- 533
end) -- 531
local reloadDevEntry -- 535
reloadDevEntry = function() -- 535
	return thread(function() -- 535
		waitForWebStart = true -- 536
		doClean() -- 537
		allClear() -- 538
		_G.require = oldRequire -- 539
		Dora.require = oldRequire -- 540
		package.loaded["Script.Dev.Entry"] = nil -- 541
		return Director.systemScheduler:schedule(function() -- 542
			Routine:clear() -- 543
			oldRequire("Script.Dev.Entry") -- 544
			return true -- 545
		end) -- 542
	end) -- 535
end -- 535
local setWorkspace -- 547
setWorkspace = function(path) -- 547
	Content.writablePath = path -- 548
	config.writablePath = Content.writablePath -- 549
	return thread(function() -- 550
		sleep() -- 551
		return reloadDevEntry() -- 552
	end) -- 550
end -- 547
local quit = false -- 554
local _anon_func_1 = function(App, _with_0) -- 570
	local _val_0 = App.platform -- 570
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 570
end -- 570
setupEventHandlers = function() -- 556
	local _with_0 = Director.postNode -- 557
	_with_0:onAppEvent(function(eventType) -- 558
		if eventType == "Quit" then -- 558
			quit = true -- 559
			allClear() -- 560
			return clearTempFiles() -- 561
		end -- 558
	end) -- 558
	_with_0:onAppChange(function(settingName) -- 562
		if "Theme" == settingName then -- 563
			config.themeColor = App.themeColor:toARGB() -- 564
		elseif "Locale" == settingName then -- 565
			config.locale = App.locale -- 566
			updateLocale() -- 567
			return teal.clear(true) -- 568
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 569
			if _anon_func_1(App, _with_0) then -- 570
				if "FullScreen" == settingName then -- 572
					config.fullScreen = App.fullScreen -- 572
				elseif "Position" == settingName then -- 573
					local _obj_0 = App.winPosition -- 573
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 573
				elseif "Size" == settingName then -- 574
					local width, height -- 575
					do -- 575
						local _obj_0 = App.winSize -- 575
						width, height = _obj_0.width, _obj_0.height -- 575
					end -- 575
					config.winWidth = width -- 576
					config.winHeight = height -- 577
				end -- 571
			end -- 570
		end -- 562
	end) -- 562
	_with_0:onAppWS(function(eventType) -- 578
		if eventType == "Close" then -- 578
			if HttpServer.wsConnectionCount == 0 then -- 579
				return updateEntries() -- 580
			end -- 579
		end -- 578
	end) -- 578
	_with_0:slot("UpdateEntries", function() -- 581
		return updateEntries() -- 581
	end) -- 581
	return _with_0 -- 557
end -- 556
setupEventHandlers() -- 583
clearTempFiles() -- 584
local downloadFile -- 586
downloadFile = function(url, target) -- 586
	return Director.systemScheduler:schedule(once(function() -- 586
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 587
			if quit then -- 588
				return true -- 588
			end -- 588
			emit("AppWS", "Send", json.encode({ -- 590
				name = "Download", -- 590
				url = url, -- 590
				status = "downloading", -- 590
				progress = current / total -- 591
			})) -- 589
			return false -- 587
		end) -- 587
		return emit("AppWS", "Send", json.encode(success and { -- 594
			name = "Download", -- 594
			url = url, -- 594
			status = "completed", -- 594
			progress = 1.0 -- 595
		} or { -- 597
			name = "Download", -- 597
			url = url, -- 597
			status = "failed", -- 597
			progress = 0.0 -- 598
		})) -- 593
	end)) -- 586
end -- 586
_module_0["downloadFile"] = downloadFile -- 586
local stop -- 601
stop = function() -- 601
	if isInEntry then -- 602
		return false -- 602
	end -- 602
	allClear() -- 603
	isInEntry = true -- 604
	currentEntry = nil -- 605
	return true -- 606
end -- 601
_module_0["stop"] = stop -- 601
local _anon_func_2 = function(Content, Path, file, require, type, workDir) -- 616
	if workDir == nil then -- 616
		workDir = Path:getPath(file) -- 616
	end -- 616
	Content:insertSearchPath(1, workDir) -- 617
	local scriptPath = Path(workDir, "Script") -- 618
	if Content:exist(scriptPath) then -- 619
		Content:insertSearchPath(1, scriptPath) -- 620
	end -- 619
	local result = require(file) -- 621
	if "function" == type(result) then -- 622
		result() -- 622
	end -- 622
	return nil -- 623
end -- 616
local _anon_func_3 = function(Label, _with_0, err, fontSize, width) -- 652
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 652
	label.alignment = "Left" -- 653
	label.textWidth = width - fontSize -- 654
	label.text = err -- 655
	return label -- 652
end -- 652
local enterEntryAsync -- 608
enterEntryAsync = function(entry) -- 608
	isInEntry = false -- 609
	App.idled = false -- 610
	emit(Profiler.EventName, "ClearLoader") -- 611
	currentEntry = entry -- 612
	local file, workDir = entry[2], entry.workDir -- 613
	sleep() -- 614
	return xpcall(_anon_func_2, function(msg) -- 623
		local err = debug.traceback(msg) -- 625
		Log("Error", err) -- 626
		allClear() -- 627
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 628
		local viewWidth, viewHeight -- 629
		do -- 629
			local _obj_0 = View.size -- 629
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 629
		end -- 629
		local width, height = viewWidth - 20, viewHeight - 20 -- 630
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 631
		Director.ui:addChild((function() -- 632
			local root = AlignNode() -- 632
			do -- 633
				local _obj_0 = App.bufferSize -- 633
				width, height = _obj_0.width, _obj_0.height -- 633
			end -- 633
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 634
			root:onAppChange(function(settingName) -- 635
				if settingName == "Size" then -- 635
					do -- 636
						local _obj_0 = App.bufferSize -- 636
						width, height = _obj_0.width, _obj_0.height -- 636
					end -- 636
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 637
				end -- 635
			end) -- 635
			root:addChild((function() -- 638
				local _with_0 = ScrollArea({ -- 639
					width = width, -- 639
					height = height, -- 640
					paddingX = 0, -- 641
					paddingY = 50, -- 642
					viewWidth = height, -- 643
					viewHeight = height -- 644
				}) -- 638
				root:onAlignLayout(function(w, h) -- 646
					_with_0.position = Vec2(w / 2, h / 2) -- 647
					w = w - 20 -- 648
					h = h - 20 -- 649
					_with_0.view.children.first.textWidth = w - fontSize -- 650
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 651
				end) -- 646
				_with_0.view:addChild(_anon_func_3(Label, _with_0, err, fontSize, width)) -- 652
				return _with_0 -- 638
			end)()) -- 638
			return root -- 632
		end)()) -- 632
		return err -- 656
	end, Content, Path, file, require, type, workDir) -- 615
end -- 608
_module_0["enterEntryAsync"] = enterEntryAsync -- 608
local enterDemoEntry -- 658
enterDemoEntry = function(entry) -- 658
	return thread(function() -- 658
		return enterEntryAsync(entry) -- 658
	end) -- 658
end -- 658
local reloadCurrentEntry -- 660
reloadCurrentEntry = function() -- 660
	if currentEntry then -- 661
		allClear() -- 662
		return enterDemoEntry(currentEntry) -- 663
	end -- 661
end -- 660
Director.clearColor = Color(0xff1a1a1a) -- 665
local isOSSLicenseExist = Content:exist("LICENSES") -- 667
local ossLicenses = nil -- 668
local ossLicenseOpen = false -- 669
local extraOperations -- 671
extraOperations = function() -- 671
	local zh = useChinese -- 672
	if isDesktop then -- 673
		local themeColor = App.themeColor -- 674
		local alwaysOnTop, writablePath = config.alwaysOnTop, config.writablePath -- 675
		do -- 676
			local changed -- 676
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 676
			if changed then -- 676
				App.alwaysOnTop = alwaysOnTop -- 677
				config.alwaysOnTop = alwaysOnTop -- 678
			end -- 676
		end -- 676
		SeparatorText(zh and "工作目录" or "Workspace") -- 679
		PushTextWrapPos(400, function() -- 680
			return TextColored(themeColor, writablePath) -- 681
		end) -- 680
		if Button(zh and "改变目录" or "Set Folder") then -- 682
			App:openFileDialog(true, function(path) -- 683
				if path ~= "" then -- 684
					return setWorkspace(path) -- 684
				end -- 684
			end) -- 683
		end -- 682
		SameLine() -- 685
		if Button(zh and "使用默认" or "Use Default") then -- 686
			setWorkspace(Content.appPath) -- 687
		end -- 686
		Separator() -- 688
	end -- 673
	if isOSSLicenseExist then -- 689
		if Button(zh and '开源协议' or 'OSS Licenses') then -- 690
			if not ossLicenses then -- 691
				ossLicenses = { } -- 692
				local licenseText = Content:load("LICENSES") -- 693
				ossLicenseOpen = (licenseText ~= nil) -- 694
				if ossLicenseOpen then -- 694
					licenseText = licenseText:gsub("\r\n", "\n") -- 695
					for license in GSplit(licenseText, "\n--------\n", true) do -- 696
						local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 697
						if name then -- 697
							ossLicenses[#ossLicenses + 1] = { -- 698
								name, -- 698
								text -- 698
							} -- 698
						end -- 697
					end -- 696
				end -- 694
			else -- 700
				ossLicenseOpen = true -- 700
			end -- 691
		end -- 690
		if ossLicenseOpen then -- 701
			local width, height, themeColor -- 702
			do -- 702
				local _obj_0 = App -- 702
				width, height, themeColor = _obj_0.visualSize.width, _obj_0.visualSize.height, _obj_0.themeColor -- 702
			end -- 702
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 703
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 704
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 705
				ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 708
					"NoSavedSettings" -- 708
				}, function() -- 709
					for _index_0 = 1, #ossLicenses do -- 709
						local _des_0 = ossLicenses[_index_0] -- 709
						local firstLine, text = _des_0[1], _des_0[2] -- 709
						local name, license = firstLine:match("(.+): (.+)") -- 710
						TextColored(themeColor, name) -- 711
						SameLine() -- 712
						TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 713
							return TextWrapped(text) -- 713
						end) -- 713
					end -- 709
				end) -- 705
			end) -- 705
		end -- 701
	end -- 689
	if not App.debugging then -- 715
		return -- 715
	end -- 715
	return TreeNode(zh and "开发操作" or "Development", function() -- 716
		if Button(zh and "脚本编译测试" or "Script Build Test") then -- 717
			OpenPopup("build") -- 717
		end -- 717
		PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 718
			return BeginPopup("build", function() -- 718
				if Selectable(zh and "编译" or "Compile") then -- 719
					doCompile(false) -- 719
				end -- 719
				Separator() -- 720
				if Selectable(zh and "压缩" or "Minify") then -- 721
					doCompile(true) -- 721
				end -- 721
				Separator() -- 722
				if Selectable(zh and "清理" or "Clean") then -- 723
					return doClean() -- 723
				end -- 723
			end) -- 718
		end) -- 718
		if isInEntry then -- 724
			if waitForWebStart then -- 725
				BeginDisabled(function() -- 726
					return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 726
				end) -- 726
			elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 727
				reloadDevEntry() -- 728
			end -- 725
		end -- 724
		do -- 729
			local changed -- 729
			changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 729
			if changed then -- 729
				View.scale = scaleContent and screenScale or 1 -- 730
			end -- 729
		end -- 729
		do -- 731
			local changed -- 731
			changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 731
			if changed then -- 731
				config.engineDev = engineDev -- 732
			end -- 731
		end -- 731
		if testingThread then -- 733
			return BeginDisabled(function() -- 734
				return Button(zh and "开始自动测试" or "Test automatically") -- 734
			end) -- 734
		elseif Button(zh and "开始自动测试" or "Test automatically") then -- 735
			testingThread = thread(function() -- 736
				local _ <close> = setmetatable({ }, { -- 737
					__close = function() -- 737
						allClear() -- 738
						testingThread = nil -- 739
						isInEntry = true -- 740
						currentEntry = nil -- 741
						return print("Testing done!") -- 742
					end -- 737
				}) -- 737
				for _, entry in ipairs(allEntries) do -- 743
					allClear() -- 744
					print("Start " .. tostring(entry[1])) -- 745
					enterDemoEntry(entry) -- 746
					sleep(2) -- 747
					print("Stop " .. tostring(entry[1])) -- 748
				end -- 743
			end) -- 736
		end -- 733
	end) -- 716
end -- 671
local icon = Path("Script", "Dev", "icon_s.png") -- 750
local iconTex = nil -- 751
thread(function() -- 752
	if Cache:loadAsync(icon) then -- 752
		iconTex = Texture2D(icon) -- 752
	end -- 752
end) -- 752
local webStatus = nil -- 754
local urlClicked = nil -- 755
local descColor = Color(0xffa1a1a1) -- 756
local transparant = Color(0x0) -- 758
local windowFlags = { -- 759
	"NoTitleBar", -- 759
	"NoResize", -- 759
	"NoMove", -- 759
	"NoCollapse", -- 759
	"NoSavedSettings", -- 759
	"NoFocusOnAppearing", -- 759
	"NoBringToFrontOnFocus" -- 759
} -- 759
local statusFlags = { -- 768
	"NoTitleBar", -- 768
	"NoResize", -- 768
	"NoMove", -- 768
	"NoCollapse", -- 768
	"AlwaysAutoResize", -- 768
	"NoSavedSettings" -- 768
} -- 768
local displayWindowFlags = { -- 776
	"NoDecoration", -- 776
	"NoSavedSettings", -- 776
	"NoNav", -- 776
	"NoMove", -- 776
	"NoScrollWithMouse", -- 776
	"AlwaysAutoResize" -- 776
} -- 776
local initFooter = true -- 784
local _anon_func_4 = function(allEntries, currentIndex) -- 820
	if currentIndex > 1 then -- 820
		return allEntries[currentIndex - 1] -- 821
	else -- 823
		return allEntries[#allEntries] -- 823
	end -- 820
end -- 820
local _anon_func_5 = function(allEntries, currentIndex) -- 827
	if currentIndex < #allEntries then -- 827
		return allEntries[currentIndex + 1] -- 828
	else -- 830
		return allEntries[1] -- 830
	end -- 827
end -- 827
footerWindow = threadLoop(function() -- 785
	local zh = useChinese -- 786
	if HttpServer.wsConnectionCount > 0 then -- 787
		return -- 788
	end -- 787
	if Keyboard:isKeyDown("Escape") then -- 789
		allClear() -- 790
		App:shutdown() -- 791
	end -- 789
	do -- 792
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 793
		if ctrl and Keyboard:isKeyDown("Q") then -- 794
			stop() -- 795
		end -- 794
		if ctrl and Keyboard:isKeyDown("Z") then -- 796
			reloadCurrentEntry() -- 797
		end -- 796
		if ctrl and Keyboard:isKeyDown(",") then -- 798
			if showFooter then -- 799
				showStats = not showStats -- 799
			else -- 799
				showStats = true -- 799
			end -- 799
			showFooter = true -- 800
			config.showFooter = showFooter -- 801
			config.showStats = showStats -- 802
		end -- 798
		if ctrl and Keyboard:isKeyDown(".") then -- 803
			if showFooter then -- 804
				showConsole = not showConsole -- 804
			else -- 804
				showConsole = true -- 804
			end -- 804
			showFooter = true -- 805
			config.showFooter = showFooter -- 806
			config.showConsole = showConsole -- 807
		end -- 803
		if ctrl and Keyboard:isKeyDown("/") then -- 808
			showFooter = not showFooter -- 809
			config.showFooter = showFooter -- 810
		end -- 808
		local left = ctrl and Keyboard:isKeyDown("Left") -- 811
		local right = ctrl and Keyboard:isKeyDown("Right") -- 812
		local currentIndex = nil -- 813
		for i, entry in ipairs(allEntries) do -- 814
			if currentEntry == entry then -- 815
				currentIndex = i -- 816
			end -- 815
		end -- 814
		if left then -- 817
			allClear() -- 818
			if currentIndex == nil then -- 819
				currentIndex = #allEntries + 1 -- 819
			end -- 819
			enterDemoEntry(_anon_func_4(allEntries, currentIndex)) -- 820
		end -- 817
		if right then -- 824
			allClear() -- 825
			if currentIndex == nil then -- 826
				currentIndex = 0 -- 826
			end -- 826
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 827
		end -- 824
	end -- 792
	if not showEntry then -- 831
		return -- 831
	end -- 831
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 833
		reloadDevEntry() -- 837
	end -- 833
	if initFooter then -- 838
		initFooter = false -- 839
	end -- 838
	local width, height -- 841
	do -- 841
		local _obj_0 = App.visualSize -- 841
		width, height = _obj_0.width, _obj_0.height -- 841
	end -- 841
	if isInEntry or showFooter then -- 842
		SetNextWindowSize(Vec2(width, 50)) -- 843
		SetNextWindowPos(Vec2(0, height - 50)) -- 844
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 845
			return PushStyleVar("WindowRounding", 0, function() -- 846
				return Begin("Footer", windowFlags, function() -- 847
					Separator() -- 848
					if iconTex then -- 849
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 850
							showStats = not showStats -- 851
							config.showStats = showStats -- 852
						end -- 850
						SameLine() -- 853
						if Button(">_", Vec2(30, 30)) then -- 854
							showConsole = not showConsole -- 855
							config.showConsole = showConsole -- 856
						end -- 854
					end -- 849
					if isInEntry and config.updateNotification then -- 857
						SameLine() -- 858
						if ImGui.Button(zh and "更新可用" or "Update") then -- 859
							allClear() -- 860
							config.updateNotification = false -- 861
							enterDemoEntry({ -- 863
								"SelfUpdater", -- 863
								Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 864
							}) -- 862
						end -- 859
					end -- 857
					if not isInEntry then -- 866
						SameLine() -- 867
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 868
						local currentIndex = nil -- 869
						for i, entry in ipairs(allEntries) do -- 870
							if currentEntry == entry then -- 871
								currentIndex = i -- 872
							end -- 871
						end -- 870
						if currentIndex then -- 873
							if currentIndex > 1 then -- 874
								SameLine() -- 875
								if Button("<<", Vec2(30, 30)) then -- 876
									allClear() -- 877
									enterDemoEntry(allEntries[currentIndex - 1]) -- 878
								end -- 876
							end -- 874
							if currentIndex < #allEntries then -- 879
								SameLine() -- 880
								if Button(">>", Vec2(30, 30)) then -- 881
									allClear() -- 882
									enterDemoEntry(allEntries[currentIndex + 1]) -- 883
								end -- 881
							end -- 879
						end -- 873
						SameLine() -- 884
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 885
							reloadCurrentEntry() -- 886
						end -- 885
						if back then -- 887
							allClear() -- 888
							isInEntry = true -- 889
							currentEntry = nil -- 890
						end -- 887
					end -- 866
				end) -- 847
			end) -- 846
		end) -- 845
	end -- 842
	local showWebIDE = isInEntry -- 892
	if config.updateNotification then -- 893
		if width < 460 then -- 894
			showWebIDE = false -- 895
		end -- 894
	else -- 897
		if width < 360 then -- 897
			showWebIDE = false -- 898
		end -- 897
	end -- 893
	if showWebIDE then -- 899
		SetNextWindowBgAlpha(0.0) -- 900
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 901
		Begin("Web IDE", displayWindowFlags, function() -- 902
			do -- 903
				local url -- 903
				if webStatus ~= nil then -- 903
					url = webStatus.url -- 903
				end -- 903
				if url then -- 903
					if isDesktop and not config.fullScreen then -- 904
						if urlClicked then -- 905
							BeginDisabled(function() -- 906
								return Button(url) -- 906
							end) -- 906
						elseif Button(url) then -- 907
							urlClicked = once(function() -- 908
								return sleep(5) -- 908
							end) -- 908
							App:openURL("http://localhost:8866") -- 909
						end -- 905
					else -- 911
						TextColored(descColor, url) -- 911
					end -- 904
				else -- 913
					TextColored(descColor, zh and '不可用' or 'not available') -- 913
				end -- 903
			end -- 903
			SameLine() -- 914
			TextDisabled('(?)') -- 915
			if IsItemHovered() then -- 916
				return BeginTooltip(function() -- 917
					return PushTextWrapPos(280, function() -- 918
						return Text(zh and '在本机或是本地局域网连接的其他设备上，使用浏览器访问这个地址来使用 Web IDE' or 'You can use the Web IDE by accessing this address in a browser on this machine or other devices connected to the local network') -- 919
					end) -- 918
				end) -- 917
			end -- 916
		end) -- 902
	end -- 899
	if not isInEntry then -- 921
		SetNextWindowSize(Vec2(50, 50)) -- 922
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 923
		PushStyleColor("WindowBg", transparant, function() -- 924
			return Begin("Show", displayWindowFlags, function() -- 924
				if width >= 370 then -- 925
					local changed -- 926
					changed, showFooter = Checkbox("##dev", showFooter) -- 926
					if changed then -- 926
						config.showFooter = showFooter -- 927
					end -- 926
				end -- 925
			end) -- 924
		end) -- 924
	end -- 921
	if isInEntry or showFooter then -- 929
		if showStats then -- 930
			PushStyleVar("WindowRounding", 0, function() -- 931
				SetNextWindowPos(Vec2(0, 0), "Always") -- 932
				SetNextWindowSize(Vec2(0, height - 50)) -- 933
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 934
				config.showStats = showStats -- 935
			end) -- 931
		end -- 930
		if showConsole then -- 936
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 937
			return PushStyleVar("WindowRounding", 6, function() -- 938
				return ShowConsole() -- 939
			end) -- 938
		end -- 936
	end -- 929
end) -- 785
local MaxWidth <const> = 960 -- 941
local toolOpen = false -- 943
local filterText = nil -- 944
local anyEntryMatched = false -- 945
local match -- 946
match = function(name) -- 946
	local res = not filterText or name:lower():match(filterText) -- 947
	if res then -- 948
		anyEntryMatched = true -- 948
	end -- 948
	return res -- 949
end -- 946
local sep -- 951
sep = function() -- 951
	return SeparatorText("") -- 951
end -- 951
local thinSep -- 952
thinSep = function() -- 952
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 952
end -- 952
entryWindow = threadLoop(function() -- 954
	if App.fpsLimited ~= config.fpsLimited then -- 955
		config.fpsLimited = App.fpsLimited -- 956
	end -- 955
	if App.targetFPS ~= config.targetFPS then -- 957
		config.targetFPS = App.targetFPS -- 958
	end -- 957
	if View.vsync ~= config.vsync then -- 959
		config.vsync = View.vsync -- 960
	end -- 959
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 961
		config.fixedFPS = Director.scheduler.fixedFPS -- 962
	end -- 961
	if Director.profilerSending ~= config.webProfiler then -- 963
		config.webProfiler = Director.profilerSending -- 964
	end -- 963
	if urlClicked then -- 965
		local _, result = coroutine.resume(urlClicked) -- 966
		if result then -- 967
			coroutine.close(urlClicked) -- 968
			urlClicked = nil -- 969
		end -- 967
	end -- 965
	if not showEntry then -- 970
		return -- 970
	end -- 970
	if not isInEntry then -- 971
		return -- 971
	end -- 971
	local zh = useChinese -- 972
	if HttpServer.wsConnectionCount > 0 then -- 973
		local themeColor = App.themeColor -- 974
		local width, height -- 975
		do -- 975
			local _obj_0 = App.visualSize -- 975
			width, height = _obj_0.width, _obj_0.height -- 975
		end -- 975
		SetNextWindowBgAlpha(0.5) -- 976
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 977
		Begin("Web IDE Connected", displayWindowFlags, function() -- 978
			Separator() -- 979
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 980
			if iconTex then -- 981
				Image(icon, Vec2(24, 24)) -- 982
				SameLine() -- 983
			end -- 981
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 984
			TextColored(descColor, slogon) -- 985
			return Separator() -- 986
		end) -- 978
		return -- 987
	end -- 973
	local themeColor = App.themeColor -- 989
	local fullWidth, height -- 990
	do -- 990
		local _obj_0 = App.visualSize -- 990
		fullWidth, height = _obj_0.width, _obj_0.height -- 990
	end -- 990
	local width = math.min(MaxWidth, fullWidth) -- 991
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 992
	local maxColumns = math.max(math.floor(width / 200), 1) -- 993
	SetNextWindowPos(Vec2.zero) -- 994
	SetNextWindowBgAlpha(0) -- 995
	SetNextWindowSize(Vec2(fullWidth, 60)) -- 996
	do -- 997
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 998
			return Begin("Dora Dev", windowFlags, function() -- 999
				Dummy(Vec2(fullWidth - 20, 0)) -- 1000
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1001
				if fullWidth >= 400 then -- 1002
					SameLine() -- 1003
					Dummy(Vec2(fullWidth - 400, 0)) -- 1004
					SameLine() -- 1005
					SetNextItemWidth(zh and -95 or -140) -- 1006
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1007
						"AutoSelectAll" -- 1007
					}) then -- 1007
						config.filter = filterBuf.text -- 1008
					end -- 1007
					SameLine() -- 1009
					if Button(zh and '下载' or 'Download') then -- 1010
						allClear() -- 1011
						enterDemoEntry({ -- 1013
							"ResourceDownloader", -- 1013
							Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1014
						}) -- 1012
					end -- 1010
				end -- 1002
				Separator() -- 1016
				return Dummy(Vec2(fullWidth - 20, 0)) -- 1017
			end) -- 999
		end) -- 998
	end -- 997
	anyEntryMatched = false -- 1019
	SetNextWindowPos(Vec2(0, 50)) -- 1020
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1021
	do -- 1022
		return PushStyleColor("WindowBg", transparant, function() -- 1023
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1024
				return PushStyleVar("Alpha", 1, function() -- 1025
					return Begin("Content", windowFlags, function() -- 1026
						local DemoViewWidth <const> = 320 -- 1027
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1028
						if filterText then -- 1029
							filterText = filterText:lower() -- 1029
						end -- 1029
						if #gamesInDev > 0 then -- 1030
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1031
							Columns(columns, false) -- 1032
							local realViewWidth = GetColumnWidth() - 50 -- 1033
							for _index_0 = 1, #gamesInDev do -- 1034
								local game = gamesInDev[_index_0] -- 1034
								local gameName, fileName, examples, tests, bannerFile, bannerTex = game[1], game[2], game[3], game[4], game[5], game[6] -- 1035
								if match(gameName) then -- 1036
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1037
									SameLine() -- 1038
									TextWrapped(gameName) -- 1039
									if columns > 1 then -- 1040
										if bannerFile then -- 1041
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1042
											local displayWidth <const> = realViewWidth -- 1043
											texHeight = displayWidth * texHeight / texWidth -- 1044
											texWidth = displayWidth -- 1045
											Dummy(Vec2.zero) -- 1046
											SameLine() -- 1047
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1048
										end -- 1041
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1049
											enterDemoEntry(game) -- 1050
										end -- 1049
									else -- 1052
										if bannerFile then -- 1052
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1053
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1054
											local sizing = 0.8 -- 1055
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1056
											texWidth = displayWidth * sizing -- 1057
											if texWidth > 500 then -- 1058
												sizing = 0.6 -- 1059
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1060
												texWidth = displayWidth * sizing -- 1061
											end -- 1058
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1062
											Dummy(Vec2(padding, 0)) -- 1063
											SameLine() -- 1064
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1065
										end -- 1052
										if Button(tostring(zh and "开始运行" or "Game Start") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1066
											enterDemoEntry(game) -- 1067
										end -- 1066
									end -- 1040
									if #tests == 0 and #examples == 0 then -- 1068
										thinSep() -- 1069
									end -- 1068
									NextColumn() -- 1070
								end -- 1036
								local showSep = false -- 1071
								if #examples > 0 then -- 1072
									local showExample = false -- 1073
									do -- 1074
										local _accum_0 -- 1074
										for _index_1 = 1, #examples do -- 1074
											local _des_0 = examples[_index_1] -- 1074
											local name = _des_0[1] -- 1074
											if match(name) then -- 1075
												_accum_0 = true -- 1075
												break -- 1075
											end -- 1075
										end -- 1074
										showExample = _accum_0 -- 1074
									end -- 1074
									if showExample then -- 1076
										showSep = true -- 1077
										Columns(1, false) -- 1078
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1079
										SameLine() -- 1080
										local opened -- 1081
										if (filterText ~= nil) then -- 1081
											opened = showExample -- 1081
										else -- 1081
											opened = false -- 1081
										end -- 1081
										if game.exampleOpen == nil then -- 1082
											game.exampleOpen = opened -- 1082
										end -- 1082
										SetNextItemOpen(game.exampleOpen) -- 1083
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1084
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1085
												Columns(maxColumns, false) -- 1086
												for _index_1 = 1, #examples do -- 1087
													local example = examples[_index_1] -- 1087
													if not match(example[1]) then -- 1088
														goto _continue_0 -- 1088
													end -- 1088
													PushID(tostring(gameName) .. " " .. tostring(example[1]) .. " example", function() -- 1089
														if Button(example[1], Vec2(-1, 40)) then -- 1090
															enterDemoEntry(example) -- 1091
														end -- 1090
														return NextColumn() -- 1092
													end) -- 1089
													opened = true -- 1093
													::_continue_0:: -- 1088
												end -- 1087
											end) -- 1085
										end) -- 1084
										game.exampleOpen = opened -- 1094
									end -- 1076
								end -- 1072
								if #tests > 0 then -- 1095
									local showTest = false -- 1096
									do -- 1097
										local _accum_0 -- 1097
										for _index_1 = 1, #tests do -- 1097
											local _des_0 = tests[_index_1] -- 1097
											local name = _des_0[1] -- 1097
											if match(name) then -- 1098
												_accum_0 = true -- 1098
												break -- 1098
											end -- 1098
										end -- 1097
										showTest = _accum_0 -- 1097
									end -- 1097
									if showTest then -- 1099
										showSep = true -- 1100
										Columns(1, false) -- 1101
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1102
										SameLine() -- 1103
										local opened -- 1104
										if (filterText ~= nil) then -- 1104
											opened = showTest -- 1104
										else -- 1104
											opened = false -- 1104
										end -- 1104
										if game.testOpen == nil then -- 1105
											game.testOpen = opened -- 1105
										end -- 1105
										SetNextItemOpen(game.testOpen) -- 1106
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1107
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1108
												Columns(maxColumns, false) -- 1109
												for _index_1 = 1, #tests do -- 1110
													local test = tests[_index_1] -- 1110
													if not match(test[1]) then -- 1111
														goto _continue_0 -- 1111
													end -- 1111
													PushID(tostring(gameName) .. " " .. tostring(test[1]) .. " test", function() -- 1112
														if Button(test[1], Vec2(-1, 40)) then -- 1113
															enterDemoEntry(test) -- 1114
														end -- 1113
														return NextColumn() -- 1115
													end) -- 1112
													opened = true -- 1116
													::_continue_0:: -- 1111
												end -- 1110
											end) -- 1108
										end) -- 1107
										game.testOpen = opened -- 1117
									end -- 1099
								end -- 1095
								if showSep then -- 1118
									Columns(1, false) -- 1119
									thinSep() -- 1120
									Columns(columns, false) -- 1121
								end -- 1118
							end -- 1034
						end -- 1030
						if #doraTools > 0 then -- 1122
							local showTool = false -- 1123
							do -- 1124
								local _accum_0 -- 1124
								for _index_0 = 1, #doraTools do -- 1124
									local _des_0 = doraTools[_index_0] -- 1124
									local name = _des_0[1] -- 1124
									if match(name) then -- 1125
										_accum_0 = true -- 1125
										break -- 1125
									end -- 1125
								end -- 1124
								showTool = _accum_0 -- 1124
							end -- 1124
							if not showTool then -- 1126
								goto endEntry -- 1126
							end -- 1126
							Columns(1, false) -- 1127
							TextColored(themeColor, "Dora SSR:") -- 1128
							SameLine() -- 1129
							Text(zh and "开发支持" or "Development Support") -- 1130
							Separator() -- 1131
							if #doraTools > 0 then -- 1132
								local opened -- 1133
								if (filterText ~= nil) then -- 1133
									opened = showTool -- 1133
								else -- 1133
									opened = false -- 1133
								end -- 1133
								SetNextItemOpen(toolOpen) -- 1134
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1135
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1136
										Columns(maxColumns, false) -- 1137
										for _index_0 = 1, #doraTools do -- 1138
											local example = doraTools[_index_0] -- 1138
											if not match(example[1]) then -- 1139
												goto _continue_0 -- 1139
											end -- 1139
											if Button(example[1], Vec2(-1, 40)) then -- 1140
												enterDemoEntry(example) -- 1141
											end -- 1140
											NextColumn() -- 1142
											::_continue_0:: -- 1139
										end -- 1138
										Columns(1, false) -- 1143
										opened = true -- 1144
									end) -- 1136
								end) -- 1135
								toolOpen = opened -- 1145
							end -- 1132
						end -- 1122
						::endEntry:: -- 1146
						if not anyEntryMatched then -- 1147
							SetNextWindowBgAlpha(0) -- 1148
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1149
							Begin("Entries Not Found", displayWindowFlags, function() -- 1150
								Separator() -- 1151
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1152
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1153
								return Separator() -- 1154
							end) -- 1150
						end -- 1147
						Columns(1, false) -- 1155
						Dummy(Vec2(100, 80)) -- 1156
						return ScrollWhenDraggingOnVoid() -- 1157
					end) -- 1026
				end) -- 1025
			end) -- 1024
		end) -- 1023
	end -- 1022
end) -- 954
webStatus = require("Script.Dev.WebServer") -- 1159
return _module_0 -- 1
