-- [yue]: Script/Test/Yarn.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local App = Dora.App -- 1
local math = _G.math -- 1
local AlignNode = Dora.AlignNode -- 1
local View = Dora.View -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local Label = Dora.Label -- 1
local Menu = Dora.Menu -- 1
local setmetatable = _G.setmetatable -- 1
local table = _G.table -- 1
local select = _G.select -- 1
local tostring = _G.tostring -- 1
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
local xpcall = _G.xpcall -- 1
local debug = _G.debug -- 1
local pairs = _G.pairs -- 1
local YarnRunner = require("YarnRunner") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 4
local CircleButton = require("UI.Control.Basic.CircleButton") -- 5
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 6
local path = Path:getScriptPath(...) -- 8
Content:insertSearchPath(1, path) -- 9
local fontScale = App.devicePixelRatio -- 11
local fontSize = math.floor(20 * fontScale) -- 12
local texts = { } -- 14
local root, label, scroll, control, menu -- 16
do -- 18
	root = AlignNode(true) -- 18
	local viewWidth, viewHeight -- 19
	do -- 19
		local _obj_0 = View.size -- 19
		viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 19
	end -- 19
	root:css("flex-direction: column-reverse") -- 20
	local width <const>, height <const> = viewWidth - 100, viewHeight - 10 -- 21
	root:addChild((function() -- 22
		scroll = ScrollArea({ -- 23
			width = width, -- 23
			height = height, -- 24
			paddingX = 0, -- 25
			paddingY = 50, -- 26
			viewWidth = height, -- 27
			viewHeight = height -- 28
		}) -- 22
		root:onAlignLayout(function(w, h) -- 30
			scroll.position = Vec2(w / 2, h / 2) -- 31
			w = w - 100 -- 32
			h = h - 10 -- 33
			scroll.view.children.first.textWidth = (w - fontSize) * fontScale -- 34
			scroll:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 35
			do -- 36
				local _obj_0 = scroll.area:getChildByTag("border") -- 36
				if _obj_0 ~= nil then -- 36
					_obj_0:removeFromParent() -- 36
				end -- 36
			end -- 36
			local border = LineRect({ -- 37
				x = 1, -- 37
				y = 1, -- 37
				width = w - 2, -- 37
				height = h - 2, -- 37
				color = 0xffffffff -- 37
			}) -- 37
			return scroll.area:addChild(border, 0, "border") -- 38
		end) -- 30
		scroll.view:addChild((function() -- 39
			label = Label("sarasa-mono-sc-regular", fontSize) -- 39
			do -- 40
				local _tmp_0 = 1 / fontScale -- 40
				label.scaleX = _tmp_0 -- 40
				label.scaleY = _tmp_0 -- 40
			end -- 40
			label.alignment = "Left" -- 41
			label.textWidth = (width - fontSize) * fontScale -- 42
			label.text = "" -- 43
			return label -- 39
		end)()) -- 39
		return scroll -- 22
	end)()) -- 22
	root:addChild((function() -- 44
		control = AlignNode() -- 44
		control:css("height: 140; margin-bottom: 40") -- 45
		menu = Menu() -- 46
		control:addChild(menu) -- 47
		control:onAlignLayout(function(w, h) -- 48
			menu.position = Vec2(w / 2, h / 2) -- 49
		end) -- 48
		return control -- 44
	end)()) -- 44
end -- 18
local _anon_func_0 = function(select, tostring, ...) -- 52
	local _accum_0 = { } -- 52
	local _len_0 = 1 -- 52
	for i = 1, select('#', ...) do -- 52
		_accum_0[_len_0] = tostring(select(i, ...)) -- 52
		_len_0 = _len_0 + 1 -- 52
	end -- 52
	return _accum_0 -- 52
end -- 52
local commands = setmetatable({ }, { -- 51
	__index = function(_self, name) -- 51
		return function(...) -- 51
			local msg = "[command]: " .. name .. " " .. table.concat(_anon_func_0(select, tostring, ...), ", ") -- 52
			return coroutine.yield("Command", msg) -- 53
		end -- 53
	end -- 51
}) -- 51
local testFiles = { -- 55
	Path(Content.assetPath, "Script", "Test", "tutorial.yarn") -- 55
} -- 55
local files = { -- 56
	"Test/tutorial.yarn" -- 56
} -- 56
local runner = YarnRunner(testFiles[1], "Start", { }, commands, true) -- 58
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
	menu.size = Size(80 * buttons, 80) -- 66
	for i = 1, buttons do -- 67
		menu:addChild((function() -- 68
			local _with_0 = CircleButton({ -- 69
				text = options and tostring(i) or "Next", -- 69
				radius = 30, -- 70
				fontSize = 20 -- 71
			}) -- 68
			_with_0:onTapped(function() -- 73
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
						if attr == "Character" then -- 87
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
local _list_0 = Content:getAllFiles(Content.writablePath) -- 109
for _index_0 = 1, #_list_0 do -- 109
	local file = _list_0[_index_0] -- 109
	if "yarn" ~= Path:getExt(file) then -- 110
		goto _continue_0 -- 110
	end -- 110
	testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 111
	files[#files + 1] = Path:getFilename(file) -- 112
	::_continue_0:: -- 110
end -- 112
local currentFile = 1 -- 114
local windowFlags = { -- 116
	"NoDecoration", -- 116
	"NoSavedSettings", -- 116
	"NoFocusOnAppearing", -- 116
	"NoNav", -- 116
	"NoMove" -- 116
} -- 116
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
			xpcall(function() -- 132
				runner = YarnRunner(testFiles[currentFile], "Start", { }, commands, true) -- 133
				texts = { } -- 134
				return advance() -- 135
			end, function(err) -- 139
				local msg = debug.traceback(err) -- 137
				label.text = "failed to load file " .. tostring(testFiles[currentFile]) .. "\n" .. tostring(msg) -- 138
				return scroll:adjustSizeWithAlign("Auto", 10) -- 139
			end) -- 139
		end -- 131
		Text("Variables") -- 140
		Separator() -- 141
		for k, v in pairs(runner.state) do -- 142
			Text(tostring(k) .. ": " .. tostring(v)) -- 143
		end -- 143
	end) -- 143
end) -- 143
