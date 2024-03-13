-- [yue]: Script/Test/Yarn.yue
local Path = dora.Path -- 1
local Content = dora.Content -- 1
local View = dora.View -- 1
local math = _G.math -- 1
local App = dora.App -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local Label = dora.Label -- 1
local setmetatable = _G.setmetatable -- 1
local table = _G.table -- 1
local tostring = _G.tostring -- 1
local select = _G.select -- 1
local coroutine = _G.coroutine -- 1
local Menu = dora.Menu -- 1
local type = _G.type -- 1
local ipairs = _G.ipairs -- 1
local thread = dora.thread -- 1
local threadLoop = dora.threadLoop -- 1
local _module_0 = dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local Text = _module_0.Text -- 1
local Separator = _module_0.Separator -- 1
local Combo = _module_0.Combo -- 1
local pairs = _G.pairs -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 2
local YarnRunner = require("YarnRunner") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 4
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 5
local AlignNode = require("UI.Control.Basic.AlignNode") -- 6
local path = Path:getScriptPath(...) -- 8
Content:insertSearchPath(1, path) -- 9
local viewWidth, viewHeight -- 11
do -- 11
	local _obj_0 = View.size -- 11
	viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 11
end -- 11
local width, height = viewWidth - 200, viewHeight - 20 -- 13
local fontSize = math.floor(20 * App.devicePixelRatio) -- 15
local texts = { } -- 17
local root, label, scroll, control -- 19
do -- 21
	local _with_0 = AlignNode({ -- 21
		isRoot = true, -- 21
		inUI = false -- 21
	}) -- 21
	_with_0:addChild((function() -- 22
		root = AlignNode({ -- 22
			alignWidth = "w", -- 22
			alignHeight = "h" -- 22
		}) -- 22
		root:addChild((function() -- 23
			scroll = ScrollArea({ -- 24
				width = width, -- 24
				height = height, -- 25
				paddingX = 0, -- 26
				paddingY = 50, -- 27
				viewWidth = height, -- 28
				viewHeight = height -- 29
			}) -- 23
			scroll.border = LineRect({ -- 31
				width = width, -- 31
				height = height, -- 31
				color = 0xffffffff -- 31
			}) -- 31
			scroll.area:addChild(scroll.border) -- 32
			scroll:slot("AlignLayout", function(w, h) -- 33
				scroll.position = Vec2(w / 2, h / 2) -- 34
				w = w - 200 -- 35
				h = h - 20 -- 36
				scroll.view.children.first.textWidth = w - fontSize -- 37
				scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 38
				scroll.area:removeChild(scroll.border) -- 39
				scroll.border = LineRect({ -- 40
					width = w, -- 40
					height = h, -- 40
					color = 0xffffffff -- 40
				}) -- 40
				return scroll.area:addChild(scroll.border) -- 41
			end) -- 33
			scroll.view:addChild((function() -- 42
				label = Label("sarasa-mono-sc-regular", fontSize) -- 42
				label.alignment = "Left" -- 43
				label.textWidth = width - fontSize -- 44
				label.text = "" -- 45
				return label -- 42
			end)()) -- 42
			return scroll -- 23
		end)()) -- 23
		return root -- 22
	end)()) -- 22
	_with_0:addChild((function() -- 46
		control = AlignNode({ -- 46
			hAlign = "Center", -- 46
			vAlign = "Bottom" -- 46
		}) -- 46
		control.alignOffset = Vec2(0, 200) -- 47
		return control -- 46
	end)()) -- 46
	_with_0:alignLayout() -- 48
end -- 21
local commands = setmetatable({ }, { -- 50
	__index = function(self, name) -- 50
		return function(...) -- 50
			local msg = "[command]: " .. name .. " " .. table.concat((function(...) -- 51
				local _accum_0 = { } -- 51
				local _len_0 = 1 -- 51
				for i = 1, select('#', ...) do -- 51
					_accum_0[_len_0] = tostring(select(i, ...)) -- 51
					_len_0 = _len_0 + 1 -- 51
				end -- 51
				return _accum_0 -- 51
			end)(...), ", ") -- 51
			return coroutine.yield("Command", msg) -- 52
		end -- 52
	end -- 50
}) -- 50
local runner = YarnRunner("tutorial.yarn", "Start", { }, commands, true) -- 54
local menu -- 56
do -- 56
	local _with_0 = Menu() -- 56
	_with_0:addTo(control) -- 57
	menu = _with_0 -- 56
end -- 56
local advance -- 59
local setButtons -- 61
setButtons = function(options) -- 61
	menu:removeAllChildren() -- 62
	local buttons -- 63
	if options ~= nil then -- 63
		buttons = options -- 63
	else -- 63
		buttons = 1 -- 63
	end -- 63
	menu.size = Size(140 * buttons, 140) -- 65
	for i = 1, buttons do -- 66
		menu:addChild((function() -- 67
			local _with_0 = CircleButton({ -- 68
				text = options and tostring(i) or "Next", -- 68
				radius = 60, -- 69
				fontSize = 40 -- 70
			}) -- 67
			_with_0:slot("Tapped", function() -- 72
				if options then -- 73
					return advance(i) -- 74
				else -- 76
					return advance() -- 76
				end -- 73
			end) -- 72
			return _with_0 -- 67
		end)()) -- 67
	end -- 76
	menu:alignItems() -- 77
	return menu -- 64
end -- 61
advance = function(option) -- 79
	local action, result = runner:advance(option) -- 80
	if "Text" == action then -- 81
		local charName = "" -- 82
		if result.marks then -- 83
			local _list_0 = result.marks -- 84
			for _index_0 = 1, #_list_0 do -- 84
				local mark = _list_0[_index_0] -- 84
				do -- 85
					local _type_0 = type(mark) -- 85
					local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 85
					if _tab_0 then -- 85
						local attr = mark.name -- 85
						local name -- 85
						do -- 85
							local _obj_0 = mark.attrs -- 85
							local _type_1 = type(_obj_0) -- 85
							if "table" == _type_1 or "userdata" == _type_1 then -- 85
								name = _obj_0.name -- 85
							end -- 86
						end -- 86
						if attr ~= nil and name ~= nil then -- 85
							if attr == "char" then -- 86
								charName = tostring(name) .. ": " -- 86
							end -- 86
						end -- 85
					end -- 86
				end -- 86
			end -- 86
		end -- 83
		texts[#texts + 1] = charName .. result.text -- 87
		if result.optionsFollowed then -- 88
			advance() -- 89
		else -- 91
			setButtons() -- 91
		end -- 88
	elseif "Option" == action then -- 92
		for i, op in ipairs(result) do -- 93
			texts[#texts + 1] = "[" .. tostring(i) .. "]: " .. tostring(op.text) -- 94
		end -- 94
		setButtons(#result) -- 95
	elseif "Command" == action then -- 96
		texts[#texts + 1] = result -- 97
		setButtons() -- 98
	else -- 100
		menu:removeAllChildren() -- 100
		texts[#texts + 1] = result -- 101
	end -- 101
	label.text = table.concat(texts, "\n") -- 102
	root:alignLayout() -- 103
	return thread(function() -- 104
		return scroll:scrollToPosY(label.y - label.height / 2) -- 104
	end) -- 104
end -- 79
advance() -- 106
local testFiles = { -- 108
	"tutorial.yarn" -- 108
} -- 108
local files = { -- 109
	"tutorial.yarn" -- 109
} -- 109
local _list_0 = Content:getAllFiles(Content.writablePath) -- 110
for _index_0 = 1, #_list_0 do -- 110
	local file = _list_0[_index_0] -- 110
	if "yarn" ~= Path:getExt(file) then -- 111
		goto _continue_0 -- 111
	end -- 111
	testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 112
	files[#files + 1] = Path:getFilename(file) -- 113
	::_continue_0:: -- 111
end -- 113
local currentFile = 1 -- 115
local windowFlags = { -- 117
	"NoDecoration", -- 117
	"NoSavedSettings", -- 118
	"NoFocusOnAppearing", -- 119
	"NoNav", -- 120
	"NoMove" -- 121
} -- 116
return threadLoop(function() -- 122
	local width -- 123
	width = App.visualSize.width -- 123
	SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 124
	SetNextWindowSize(Vec2(200, 0), "Always") -- 125
	return Begin("Yarn Test", windowFlags, function() -- 126
		Text("Yarn Tester") -- 127
		Separator() -- 128
		local changed -- 129
		changed, currentFile = Combo("File", currentFile, files) -- 129
		if changed then -- 130
			runner = YarnRunner(testFiles[currentFile], "Start", { }, commands, true) -- 131
			texts = { } -- 132
			advance() -- 133
		end -- 130
		Text("Variables") -- 134
		Separator() -- 135
		for k, v in pairs(runner.state) do -- 136
			Text(tostring(k) .. ": " .. tostring(v)) -- 137
		end -- 137
	end) -- 137
end) -- 137
