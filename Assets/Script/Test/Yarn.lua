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
local runner = YarnRunner("tutorial.yarn", "Start", { }, commands, true) -- 58
local advance -- 60
local setButtons -- 62
setButtons = function(options) -- 62
	menu:removeAllChildren() -- 63
	local buttons -- 64
	if options ~= nil then -- 64
		buttons = options -- 64
	else -- 64
		buttons = 1 -- 64
	end -- 64
	menu.size = Size(140 * buttons, 140) -- 66
	for i = 1, buttons do -- 67
		menu:addChild((function() -- 68
			local _with_0 = CircleButton({ -- 69
				text = options and tostring(i) or "Next", -- 69
				radius = 60, -- 70
				fontSize = 40 -- 71
			}) -- 68
			_with_0:slot("Tapped", function() -- 73
				if options then -- 74
					return advance(i) -- 75
				else -- 77
					return advance() -- 77
				end -- 74
			end) -- 73
			return _with_0 -- 68
		end)()) -- 68
	end -- 77
	menu:alignItems() -- 78
	return menu -- 65
end -- 62
advance = function(option) -- 80
	local action, result = runner:advance(option) -- 81
	if "Text" == action then -- 82
		local charName = "" -- 83
		if result.marks then -- 84
			local _list_0 = result.marks -- 85
			for _index_0 = 1, #_list_0 do -- 85
				local mark = _list_0[_index_0] -- 85
				local _type_0 = type(mark) -- 86
				local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 86
				if _tab_0 then -- 86
					local attr = mark.name -- 86
					local name -- 86
					do -- 86
						local _obj_0 = mark.attrs -- 86
						local _type_1 = type(_obj_0) -- 86
						if "table" == _type_1 or "userdata" == _type_1 then -- 86
							name = _obj_0.name -- 86
						end -- 87
					end -- 87
					if attr ~= nil and name ~= nil then -- 86
						if attr == "char" then -- 87
							charName = tostring(name) .. ": " -- 87
						end -- 87
					end -- 86
				end -- 87
			end -- 87
		end -- 84
		texts[#texts + 1] = charName .. result.text -- 88
		if result.optionsFollowed then -- 89
			advance() -- 90
		else -- 92
			setButtons() -- 92
		end -- 89
	elseif "Option" == action then -- 93
		for i, op in ipairs(result) do -- 94
			texts[#texts + 1] = "[" .. tostring(i) .. "]: " .. tostring(op.text) -- 95
		end -- 95
		setButtons(#result) -- 96
	elseif "Command" == action then -- 97
		texts[#texts + 1] = result -- 98
		setButtons() -- 99
	else -- 101
		menu:removeAllChildren() -- 101
		texts[#texts + 1] = result -- 102
	end -- 102
	label.text = table.concat(texts, "\n") -- 103
	scroll:adjustSizeWithAlign("Auto", 10) -- 104
	return thread(function() -- 105
		return scroll:scrollToPosY(label.y - label.height / 2) -- 105
	end) -- 105
end -- 80
advance() -- 107
local testFiles = { -- 109
	"tutorial.yarn" -- 109
} -- 109
local files = { -- 110
	"tutorial.yarn" -- 110
} -- 110
local _list_0 = Content:getAllFiles(Content.writablePath) -- 111
for _index_0 = 1, #_list_0 do -- 111
	local file = _list_0[_index_0] -- 111
	if "yarn" ~= Path:getExt(file) then -- 112
		goto _continue_0 -- 112
	end -- 112
	testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 113
	files[#files + 1] = Path:getFilename(file) -- 114
	::_continue_0:: -- 112
end -- 114
local currentFile = 1 -- 116
local windowFlags = { -- 118
	"NoDecoration", -- 118
	"NoSavedSettings", -- 119
	"NoFocusOnAppearing", -- 120
	"NoNav", -- 121
	"NoMove" -- 122
} -- 117
return threadLoop(function() -- 123
	local width -- 124
	width = App.visualSize.width -- 124
	SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 125
	SetNextWindowSize(Vec2(200, 0), "Always") -- 126
	return Begin("Yarn Test", windowFlags, function() -- 127
		Text("Yarn Tester (Yuescript)") -- 128
		Separator() -- 129
		local changed -- 130
		changed, currentFile = Combo("File", currentFile, files) -- 130
		if changed then -- 131
			runner = YarnRunner(testFiles[currentFile], "Start", { }, commands, true) -- 132
			texts = { } -- 133
			advance() -- 134
		end -- 131
		Text("Variables") -- 135
		Separator() -- 136
		for k, v in pairs(runner.state) do -- 137
			Text(tostring(k) .. ": " .. tostring(v)) -- 138
		end -- 138
	end) -- 138
end) -- 138
