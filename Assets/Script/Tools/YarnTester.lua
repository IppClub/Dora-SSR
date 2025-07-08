-- [ts]: YarnTester.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local advance -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 11
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 12
local LineRect = require("UI.View.Shape.LineRect") -- 14
local YarnRunner = require("YarnRunner") -- 15
local ____Dora = require("Dora") -- 17
local AlignNode = ____Dora.AlignNode -- 17
local App = ____Dora.App -- 17
local Buffer = ____Dora.Buffer -- 17
local Content = ____Dora.Content -- 17
local Label = ____Dora.Label -- 17
local Menu = ____Dora.Menu -- 17
local Path = ____Dora.Path -- 17
local Size = ____Dora.Size -- 17
local Vec2 = ____Dora.Vec2 -- 17
local View = ____Dora.View -- 17
local thread = ____Dora.thread -- 17
local threadLoop = ____Dora.threadLoop -- 17
local ImGui = require("ImGui") -- 19
local zh = false -- 21
do -- 21
	local res = string.match(App.locale, "^zh") -- 23
	zh = res ~= nil -- 24
end -- 24
local testFilePaths = {} -- 27
local testFileNames = {} -- 28
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 29
	do -- 29
		if "yarn" ~= Path:getExt(file) then -- 29
			goto __continue3 -- 31
		end -- 31
		testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 33
		testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 34
	end -- 34
	::__continue3:: -- 34
end -- 34
local filteredPaths = testFilePaths -- 37
local filteredNames = testFileNames -- 38
local currentFile = 1 -- 40
local fontScale = App.devicePixelRatio -- 42
local fontSize = math.floor(20 * fontScale) -- 43
local texts = {} -- 45
local root = AlignNode(true) -- 47
root:css("flex-direction: column-reverse") -- 48
local ____View_size_0 = View.size -- 50
local viewWidth = ____View_size_0.width -- 50
local viewHeight = ____View_size_0.height -- 50
local width = viewWidth - 100 -- 51
local height = viewHeight - 10 -- 52
local scroll = ScrollArea({ -- 53
	width = width, -- 54
	height = height, -- 55
	paddingX = 0, -- 56
	paddingY = 50, -- 57
	viewWidth = height, -- 58
	viewHeight = height -- 59
}) -- 59
scroll:addTo(root) -- 61
local ____opt_1 = Label("sarasa-mono-sc-regular", fontSize) -- 61
local label = ____opt_1 and ____opt_1:addTo(scroll.view) -- 63
if not label then -- 63
	error("failed to create label!") -- 65
end -- 65
label.scaleX = 1 / fontScale -- 67
label.scaleY = 1 / fontScale -- 68
label.alignment = "Left" -- 69
root:onAlignLayout(function(w, h) -- 71
	scroll.position = Vec2(w / 2, h / 2) -- 72
	w = w - 100 -- 73
	h = h - 10 -- 74
	label.textWidth = (w - fontSize) * fontScale -- 75
	scroll:adjustSizeWithAlign( -- 76
		"Auto", -- 76
		10, -- 76
		Size(w, h) -- 76
	) -- 76
	local ____opt_3 = scroll.area:getChildByTag("border") -- 76
	if ____opt_3 ~= nil then -- 76
		____opt_3:removeFromParent() -- 77
	end -- 77
	local border = LineRect({ -- 78
		x = 1, -- 78
		y = 1, -- 78
		width = w - 2, -- 78
		height = h - 2, -- 78
		color = 4294967295 -- 78
	}) -- 78
	scroll.area:addChild(border, 0, "border") -- 79
end) -- 71
local control = AlignNode():addTo(root) -- 82
control:css("height: 140; margin-bottom: 40") -- 83
local menu = Menu():addTo(control) -- 85
control:onAlignLayout(function(w, h) -- 86
	menu.position = Vec2(w / 2, h / 2) -- 87
end) -- 86
local commands = setmetatable( -- 90
	{}, -- 90
	{__index = function(self, name) -- 90
		return function(...) -- 92
			local args = {...} -- 92
			local argStrs = {} -- 93
			do -- 93
				local i = 0 -- 94
				while i < #args do -- 94
					argStrs[#argStrs + 1] = tostring(args[i + 1]) -- 95
					i = i + 1 -- 94
				end -- 94
			end -- 94
			local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 97
			coroutine.yield("Command", msg) -- 98
		end -- 92
	end} -- 91
) -- 91
local runner = nil -- 103
if #filteredPaths > 0 then -- 103
	runner = YarnRunner( -- 105
		filteredPaths[currentFile], -- 105
		"Start", -- 105
		{}, -- 105
		commands, -- 105
		true -- 105
	) -- 105
end -- 105
local function setButtons(options) -- 108
	menu:removeAllChildren() -- 109
	local buttons = options or 1 -- 110
	menu.size = Size(80 * buttons, 80) -- 111
	do -- 111
		local i = 1 -- 112
		while i <= buttons do -- 112
			local circleButton = CircleButton({ -- 113
				text = options and tostring(i) or "Next", -- 114
				radius = 30, -- 115
				fontSize = 20 -- 116
			}):addTo(menu) -- 116
			local choice = options and i or nil -- 118
			circleButton:onTapped(function() -- 119
				advance(choice) -- 120
			end) -- 119
			i = i + 1 -- 112
		end -- 112
	end -- 112
	menu:alignItems() -- 123
end -- 108
advance = function(option) -- 126
	if not runner then -- 126
		return -- 127
	end -- 127
	local action, result = runner:advance(option) -- 128
	if action == "Text" then -- 128
		local charName = "" -- 130
		if result.marks ~= nil then -- 130
			for ____, mark in ipairs(result.marks) do -- 132
				if (mark.name == "Character" or mark.name == "char") and mark.attrs ~= nil then -- 132
					charName = tostring(mark.attrs.name) .. ": " -- 134
				end -- 134
			end -- 134
		end -- 134
		texts[#texts + 1] = charName .. result.text -- 138
		if result.optionsFollowed then -- 138
			advance() -- 140
		else -- 140
			setButtons() -- 142
		end -- 142
	elseif action == "Option" then -- 142
		for i, op in ipairs(result) do -- 145
			if type(op) ~= "boolean" then -- 145
				texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 147
			end -- 147
		end -- 147
		setButtons(#result) -- 150
	elseif action == "Command" then -- 150
		texts[#texts + 1] = result -- 152
		setButtons() -- 153
	else -- 153
		menu:removeAllChildren() -- 155
		texts[#texts + 1] = result -- 156
	end -- 156
	label.text = table.concat(texts, "\n") -- 158
	scroll:adjustSizeWithAlign("Auto", 10) -- 159
	thread(function() -- 160
		scroll:scrollToPosY(label.y - label.height / 2) -- 161
	end) -- 160
end -- 126
advance() -- 165
local filterBuf = Buffer(20) -- 167
local windowFlags = { -- 168
	"NoDecoration", -- 169
	"NoSavedSettings", -- 170
	"NoFocusOnAppearing", -- 171
	"NoNav", -- 172
	"NoMove" -- 173
} -- 173
local inputTextFlags = {"AutoSelectAll"} -- 175
threadLoop(function() -- 176
	local ____App_visualSize_5 = App.visualSize -- 177
	local width = ____App_visualSize_5.width -- 177
	ImGui.SetNextWindowPos( -- 178
		Vec2(width - 10, 10), -- 178
		"Always", -- 178
		Vec2(1, 0) -- 178
	) -- 178
	ImGui.SetNextWindowSize( -- 179
		Vec2(230, 0), -- 179
		"Always" -- 179
	) -- 179
	ImGui.Begin( -- 180
		"Yarn Tester", -- 180
		windowFlags, -- 180
		function() -- 180
			ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 181
			ImGui.SameLine() -- 182
			ImGui.TextDisabled("(?)") -- 183
			if ImGui.IsItemHovered() then -- 183
				ImGui.BeginTooltip(function() -- 185
					ImGui.PushTextWrapPos( -- 186
						300, -- 186
						function() -- 186
							ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 187
						end -- 186
					) -- 186
				end) -- 185
			end -- 185
			ImGui.Separator() -- 191
			ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 192
			ImGui.SameLine() -- 193
			local function runFile() -- 194
				do -- 194
					local function ____catch(err) -- 194
						label.text = (("failed to load file " .. filteredPaths[currentFile]) .. "\n") .. tostring(err) -- 200
						scroll:adjustSizeWithAlign("Auto", 10) -- 201
					end -- 201
					local ____try, ____hasReturned = pcall(function() -- 201
						runner = YarnRunner( -- 196
							filteredPaths[currentFile], -- 196
							"Start", -- 196
							{}, -- 196
							commands, -- 196
							true -- 196
						) -- 196
						texts = {} -- 197
						advance() -- 198
					end) -- 198
					if not ____try then -- 198
						____catch(____hasReturned) -- 198
					end -- 198
				end -- 198
			end -- 194
			if ImGui.Button(zh and "筛选" or "Filter") then -- 194
				local filterText = string.lower(filterBuf.text) -- 205
				local filtered = __TS__ArrayFilter( -- 206
					__TS__ArrayMap( -- 206
						testFileNames, -- 206
						function(____, n, i) return {n, testFilePaths[i + 1]} end -- 206
					), -- 206
					function(____, it, i) -- 206
						local matched = string.match( -- 207
							string.lower(it[1]), -- 207
							filterText -- 207
						) -- 207
						if matched ~= nil then -- 207
							return true -- 209
						end -- 209
						return false -- 211
					end -- 206
				) -- 206
				filteredNames = __TS__ArrayMap( -- 213
					filtered, -- 213
					function(____, f) return f[1] end -- 213
				) -- 213
				filteredPaths = __TS__ArrayMap( -- 214
					filtered, -- 214
					function(____, f) return f[2] end -- 214
				) -- 214
				currentFile = 1 -- 215
				if #filteredPaths > 0 then -- 215
					runFile() -- 217
				end -- 217
			end -- 217
			if #filteredNames == 0 then -- 217
				return -- 221
			end -- 221
			local changed = false -- 223
			changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 224
			if changed then -- 224
				runFile() -- 226
			end -- 226
			if ImGui.Button(zh and "重载" or "Reload") then -- 226
				runFile() -- 229
			end -- 229
			if runner then -- 229
				ImGui.SameLine() -- 232
				ImGui.Text(zh and "变量：" or "Variables:") -- 233
				ImGui.Separator() -- 234
				for k, v in pairs(runner.state) do -- 235
					ImGui.Text((k .. ": ") .. tostring(v)) -- 236
				end -- 236
			end -- 236
		end -- 180
	) -- 180
	return false -- 240
end) -- 176
return ____exports -- 176