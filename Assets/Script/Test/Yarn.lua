-- [yue]: Script/Test/Yarn.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local View = Dora.View -- 1
local math = _G.math -- 1
local App = Dora.App -- 1
local AlignNode = Dora.AlignNode -- 1
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
local YarnRunner = require("YarnRunner") -- 2
local LineRect = require("UI.View.Shape.LineRect") -- 3
local CircleButton = require("UI.Control.Basic.CircleButton") -- 4
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 5
local path = Path:getScriptPath(...) -- 7
Content:insertSearchPath(1, path) -- 8
local viewWidth, viewHeight -- 10
do -- 10
	local _obj_0 = View.size -- 10
	viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 10
end -- 10
local width, height = viewWidth - 200, viewHeight - 20 -- 12
local fontSize = math.floor(20 * App.devicePixelRatio) -- 14
local texts = { } -- 16
local root, label, scroll, control, menu -- 18
do -- 20
	root = AlignNode() -- 20
	do -- 21
		local _obj_0 = View.size -- 21
		width, height = _obj_0.width, _obj_0.height -- 21
	end -- 21
	root:css("width: " .. tostring(width) .. "; height: " .. tostring(height) .. "; flex-direction: column-reverse") -- 22
	root:gslot("AppSizeChanged", function() -- 23
		do -- 24
			local _obj_0 = View.size -- 24
			width, height = _obj_0.width, _obj_0.height -- 24
		end -- 24
		return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height) .. "; flex-direction: column-reverse") -- 25
	end) -- 23
	root:addChild((function() -- 26
		scroll = ScrollArea({ -- 27
			width = width, -- 27
			height = height, -- 28
			paddingX = 0, -- 29
			paddingY = 50, -- 30
			viewWidth = height, -- 31
			viewHeight = height -- 32
		}) -- 26
		scroll.border = LineRect({ -- 34
			width = width, -- 34
			height = height, -- 34
			color = 0xffffffff -- 34
		}) -- 34
		scroll.area:addChild(scroll.border) -- 35
		root:slot("AlignLayout", function(w, h) -- 36
			scroll.position = Vec2(w / 2, h / 2) -- 37
			w = w - 200 -- 38
			h = h - 20 -- 39
			scroll.view.children.first.textWidth = w - fontSize -- 40
			scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 41
			scroll.area:removeChild(scroll.border) -- 42
			scroll.border = LineRect({ -- 43
				width = w, -- 43
				height = h, -- 43
				color = 0xffffffff -- 43
			}) -- 43
			return scroll.area:addChild(scroll.border) -- 44
		end) -- 36
		scroll.view:addChild((function() -- 45
			label = Label("sarasa-mono-sc-regular", fontSize) -- 45
			label.alignment = "Left" -- 46
			label.textWidth = width - fontSize -- 47
			label.text = "" -- 48
			return label -- 45
		end)()) -- 45
		return scroll -- 26
	end)()) -- 26
	root:addChild((function() -- 49
		control = AlignNode() -- 49
		control:css("height: 140; margin-bottom: 40") -- 50
		menu = Menu() -- 51
		control:addChild(menu) -- 52
		control:slot("AlignLayout", function(w, h) -- 53
			menu.position = Vec2(w / 2, h / 2) -- 54
		end) -- 53
		return control -- 49
	end)()) -- 49
end -- 20
local _anon_func_0 = function(select, tostring, ...) -- 57
	local _accum_0 = { } -- 57
	local _len_0 = 1 -- 57
	for i = 1, select('#', ...) do -- 57
		_accum_0[_len_0] = tostring(select(i, ...)) -- 57
		_len_0 = _len_0 + 1 -- 57
	end -- 57
	return _accum_0 -- 57
end -- 57
local commands = setmetatable({ }, { -- 56
	__index = function(self, name) -- 56
		return function(...) -- 56
			local msg = "[command]: " .. name .. " " .. table.concat(_anon_func_0(select, tostring, ...), ", ") -- 57
			return coroutine.yield("Command", msg) -- 58
		end -- 58
	end -- 56
}) -- 56
local runner = YarnRunner("tutorial.yarn", "Start", { }, commands, true) -- 60
local advance -- 62
local setButtons -- 64
setButtons = function(options) -- 64
	menu:removeAllChildren() -- 65
	local buttons -- 66
	if options ~= nil then -- 66
		buttons = options -- 66
	else -- 66
		buttons = 1 -- 66
	end -- 66
	menu.size = Size(140 * buttons, 140) -- 68
	for i = 1, buttons do -- 69
		menu:addChild((function() -- 70
			local _with_0 = CircleButton({ -- 71
				text = options and tostring(i) or "Next", -- 71
				radius = 60, -- 72
				fontSize = 40 -- 73
			}) -- 70
			_with_0:slot("Tapped", function() -- 75
				if options then -- 76
					return advance(i) -- 77
				else -- 79
					return advance() -- 79
				end -- 76
			end) -- 75
			return _with_0 -- 70
		end)()) -- 70
	end -- 79
	menu:alignItems() -- 80
	return menu -- 67
end -- 64
advance = function(option) -- 82
	local action, result = runner:advance(option) -- 83
	if "Text" == action then -- 84
		local charName = "" -- 85
		if result.marks then -- 86
			local _list_0 = result.marks -- 87
			for _index_0 = 1, #_list_0 do -- 87
				local mark = _list_0[_index_0] -- 87
				local _type_0 = type(mark) -- 88
				local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 88
				if _tab_0 then -- 88
					local attr = mark.name -- 88
					local name -- 88
					do -- 88
						local _obj_0 = mark.attrs -- 88
						local _type_1 = type(_obj_0) -- 88
						if "table" == _type_1 or "userdata" == _type_1 then -- 88
							name = _obj_0.name -- 88
						end -- 89
					end -- 89
					if attr ~= nil and name ~= nil then -- 88
						if attr == "char" then -- 89
							charName = tostring(name) .. ": " -- 89
						end -- 89
					end -- 88
				end -- 89
			end -- 89
		end -- 86
		texts[#texts + 1] = charName .. result.text -- 90
		if result.optionsFollowed then -- 91
			advance() -- 92
		else -- 94
			setButtons() -- 94
		end -- 91
	elseif "Option" == action then -- 95
		for i, op in ipairs(result) do -- 96
			texts[#texts + 1] = "[" .. tostring(i) .. "]: " .. tostring(op.text) -- 97
		end -- 97
		setButtons(#result) -- 98
	elseif "Command" == action then -- 99
		texts[#texts + 1] = result -- 100
		setButtons() -- 101
	else -- 103
		menu:removeAllChildren() -- 103
		texts[#texts + 1] = result -- 104
	end -- 104
	label.text = table.concat(texts, "\n") -- 105
	scroll:adjustSizeWithAlign("Auto", 10) -- 106
	return thread(function() -- 107
		return scroll:scrollToPosY(label.y - label.height / 2) -- 107
	end) -- 107
end -- 82
advance() -- 109
local testFiles = { -- 111
	"tutorial.yarn" -- 111
} -- 111
local files = { -- 112
	"tutorial.yarn" -- 112
} -- 112
local _list_0 = Content:getAllFiles(Content.writablePath) -- 113
for _index_0 = 1, #_list_0 do -- 113
	local file = _list_0[_index_0] -- 113
	if "yarn" ~= Path:getExt(file) then -- 114
		goto _continue_0 -- 114
	end -- 114
	testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 115
	files[#files + 1] = Path:getFilename(file) -- 116
	::_continue_0:: -- 114
end -- 116
local currentFile = 1 -- 118
local windowFlags = { -- 120
	"NoDecoration", -- 120
	"NoSavedSettings", -- 121
	"NoFocusOnAppearing", -- 122
	"NoNav", -- 123
	"NoMove" -- 124
} -- 119
return threadLoop(function() -- 125
	local width -- 126
	width = App.visualSize.width -- 126
	SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 127
	SetNextWindowSize(Vec2(200, 0), "Always") -- 128
	return Begin("Yarn Test", windowFlags, function() -- 129
		Text("Yarn Tester (Yuescript)") -- 130
		Separator() -- 131
		local changed -- 132
		changed, currentFile = Combo("File", currentFile, files) -- 132
		if changed then -- 133
			runner = YarnRunner(testFiles[currentFile], "Start", { }, commands, true) -- 134
			texts = { } -- 135
			advance() -- 136
		end -- 133
		Text("Variables") -- 137
		Separator() -- 138
		for k, v in pairs(runner.state) do -- 139
			Text(tostring(k) .. ": " .. tostring(v)) -- 140
		end -- 140
	end) -- 140
end) -- 140
