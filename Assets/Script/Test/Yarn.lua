-- [yue]: Script/Test/Yarn.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local math = _G.math -- 1
local App = Dora.App -- 1
local AlignNode = Dora.AlignNode -- 1
local View = Dora.View -- 1
local tostring = _G.tostring -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local Label = Dora.Label -- 1
local Menu = Dora.Menu -- 1
local setmetatable = _G.setmetatable -- 1
local table = _G.table -- 1
local select = _G.select -- 1
local coroutine = _G.coroutine -- 1
local type = _G.type -- 1
local ipairs = _G.ipairs -- 1
local thread = Dora.thread -- 1
local threadLoop = Dora.threadLoop -- 1
local _module_0 = Dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local Text = _module_0.Text -- 1
local Separator = _module_0.Separator -- 1
local Combo = _module_0.Combo -- 1
local pairs = _G.pairs -- 1
local YarnRunner = require("YarnRunner") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 4
local CircleButton = require("UI.Control.Basic.CircleButton") -- 5
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 6
local path = Path:getScriptPath(...) -- 8
Content:insertSearchPath(1, path) -- 9
local fontSize = math.floor(20 * App.devicePixelRatio) -- 11
local texts = { } -- 13
local root, label, scroll, control, menu -- 15
do -- 17
	root = AlignNode() -- 17
	local viewWidth, viewHeight -- 18
	do -- 18
		local _obj_0 = View.size -- 18
		viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 18
	end -- 18
	root:css("width: " .. tostring(viewWidth) .. "; height: " .. tostring(viewHeight) .. "; flex-direction: column-reverse") -- 19
	root:gslot("AppSizeChanged", function() -- 20
		local width, height -- 21
		do -- 21
			local _obj_0 = View.size -- 21
			width, height = _obj_0.width, _obj_0.height -- 21
		end -- 21
		return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height) .. "; flex-direction: column-reverse") -- 22
	end) -- 20
	local width <const>, height <const> = viewWidth - 200, viewHeight - 20 -- 23
	root:addChild((function() -- 24
		scroll = ScrollArea({ -- 25
			width = width, -- 25
			height = height, -- 26
			paddingX = 0, -- 27
			paddingY = 50, -- 28
			viewWidth = height, -- 29
			viewHeight = height -- 30
		}) -- 24
		scroll.border = LineRect({ -- 32
			width = width, -- 32
			height = height, -- 32
			color = 0xffffffff -- 32
		}) -- 32
		scroll.area:addChild(scroll.border) -- 33
		root:slot("AlignLayout", function(w, h) -- 34
			scroll.position = Vec2(w / 2, h / 2) -- 35
			w = w - 200 -- 36
			h = h - 20 -- 37
			scroll.view.children.first.textWidth = w - fontSize -- 38
			scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 39
			scroll.area:removeChild(scroll.border) -- 40
			scroll.border = LineRect({ -- 41
				width = w, -- 41
				height = h, -- 41
				color = 0xffffffff -- 41
			}) -- 41
			return scroll.area:addChild(scroll.border) -- 42
		end) -- 34
		scroll.view:addChild((function() -- 43
			label = Label("sarasa-mono-sc-regular", fontSize) -- 43
			label.alignment = "Left" -- 44
			label.textWidth = width - fontSize -- 45
			label.text = "" -- 46
			return label -- 43
		end)()) -- 43
		return scroll -- 24
	end)()) -- 24
	root:addChild((function() -- 47
		control = AlignNode() -- 47
		control:css("height: 140; margin-bottom: 40") -- 48
		menu = Menu() -- 49
		control:addChild(menu) -- 50
		control:slot("AlignLayout", function(w, h) -- 51
			menu.position = Vec2(w / 2, h / 2) -- 52
		end) -- 51
		return control -- 47
	end)()) -- 47
end -- 17
local _anon_func_0 = function(select, tostring, ...) -- 55
	local _accum_0 = { } -- 55
	local _len_0 = 1 -- 55
	for i = 1, select('#', ...) do -- 55
		_accum_0[_len_0] = tostring(select(i, ...)) -- 55
		_len_0 = _len_0 + 1 -- 55
	end -- 55
	return _accum_0 -- 55
end -- 55
local commands = setmetatable({ }, { -- 54
	__index = function(_self, name) -- 54
		return function(...) -- 54
			local msg = "[command]: " .. name .. " " .. table.concat(_anon_func_0(select, tostring, ...), ", ") -- 55
			return coroutine.yield("Command", msg) -- 56
		end -- 56
	end -- 54
}) -- 54
local testFiles = { -- 58
	Path(Content.assetPath, "Script", "Test", "tutorial.yarn") -- 58
} -- 58
local files = { -- 59
	"Test/tutorial.yarn" -- 59
} -- 59
local runner = YarnRunner(testFiles[1], "Start", { }, commands, true) -- 61
local advance -- 63
local setButtons -- 65
setButtons = function(options) -- 65
	menu:removeAllChildren() -- 66
	local buttons -- 67
	if options ~= nil then -- 67
		buttons = options -- 67
	else -- 67
		buttons = 1 -- 67
	end -- 67
	menu.size = Size(140 * buttons, 140) -- 69
	for i = 1, buttons do -- 70
		menu:addChild((function() -- 71
			local _with_0 = CircleButton({ -- 72
				text = options and tostring(i) or "Next", -- 72
				radius = 60, -- 73
				fontSize = 40 -- 74
			}) -- 71
			_with_0:slot("Tapped", function() -- 76
				if options then -- 77
					return advance(i) -- 78
				else -- 80
					return advance() -- 80
				end -- 77
			end) -- 76
			return _with_0 -- 71
		end)()) -- 71
	end -- 80
	menu:alignItems() -- 81
	return menu -- 68
end -- 65
advance = function(option) -- 83
	local action, result = runner:advance(option) -- 84
	if "Text" == action then -- 85
		local charName = "" -- 86
		if result.marks then -- 87
			local _list_0 = result.marks -- 88
			for _index_0 = 1, #_list_0 do -- 88
				local mark = _list_0[_index_0] -- 88
				local _type_0 = type(mark) -- 89
				local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 89
				if _tab_0 then -- 89
					local attr = mark.name -- 89
					local name -- 89
					do -- 89
						local _obj_0 = mark.attrs -- 89
						local _type_1 = type(_obj_0) -- 89
						if "table" == _type_1 or "userdata" == _type_1 then -- 89
							name = _obj_0.name -- 89
						end -- 90
					end -- 90
					if attr ~= nil and name ~= nil then -- 89
						if attr == "char" then -- 90
							charName = tostring(name) .. ": " -- 90
						end -- 90
					end -- 89
				end -- 90
			end -- 90
		end -- 87
		texts[#texts + 1] = charName .. result.text -- 91
		if result.optionsFollowed then -- 92
			advance() -- 93
		else -- 95
			setButtons() -- 95
		end -- 92
	elseif "Option" == action then -- 96
		for i, op in ipairs(result) do -- 97
			texts[#texts + 1] = "[" .. tostring(i) .. "]: " .. tostring(op.text) -- 98
		end -- 98
		setButtons(#result) -- 99
	elseif "Command" == action then -- 100
		texts[#texts + 1] = result -- 101
		setButtons() -- 102
	else -- 104
		menu:removeAllChildren() -- 104
		texts[#texts + 1] = result -- 105
	end -- 105
	label.text = table.concat(texts, "\n") -- 106
	scroll:adjustSizeWithAlign("Auto", 10) -- 107
	return thread(function() -- 108
		return scroll:scrollToPosY(label.y - label.height / 2) -- 108
	end) -- 108
end -- 83
advance() -- 110
local _list_0 = Content:getAllFiles(Content.writablePath) -- 112
for _index_0 = 1, #_list_0 do -- 112
	local file = _list_0[_index_0] -- 112
	if "yarn" ~= Path:getExt(file) then -- 113
		goto _continue_0 -- 113
	end -- 113
	testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 114
	files[#files + 1] = Path:getFilename(file) -- 115
	::_continue_0:: -- 113
end -- 115
local currentFile = 1 -- 117
local windowFlags = { -- 119
	"NoDecoration", -- 119
	"NoSavedSettings", -- 120
	"NoFocusOnAppearing", -- 121
	"NoNav", -- 122
	"NoMove" -- 123
} -- 118
return threadLoop(function() -- 124
	local width -- 125
	width = App.visualSize.width -- 125
	SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 126
	SetNextWindowSize(Vec2(200, 0), "Always") -- 127
	return Begin("Yarn Test", windowFlags, function() -- 128
		Text("Yarn Tester (Yuescript)") -- 129
		Separator() -- 130
		local changed -- 131
		changed, currentFile = Combo("File", currentFile, files) -- 131
		if changed then -- 132
			runner = YarnRunner(testFiles[currentFile], "Start", { }, commands, true) -- 133
			texts = { } -- 134
			advance() -- 135
		end -- 132
		Text("Variables") -- 136
		Separator() -- 137
		for k, v in pairs(runner.state) do -- 138
			Text(tostring(k) .. ": " .. tostring(v)) -- 139
		end -- 139
	end) -- 139
end) -- 139
