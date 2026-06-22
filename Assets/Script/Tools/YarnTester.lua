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
local ____Dora = require("Dora") -- 16
local AlignNode = ____Dora.AlignNode -- 16
local App = ____Dora.App -- 16
local Buffer = ____Dora.Buffer -- 16
local Content = ____Dora.Content -- 16
local Label = ____Dora.Label -- 16
local Menu = ____Dora.Menu -- 16
local Path = ____Dora.Path -- 16
local Size = ____Dora.Size -- 16
local Vec2 = ____Dora.Vec2 -- 16
local View = ____Dora.View -- 16
local thread = ____Dora.thread -- 16
local threadLoop = ____Dora.threadLoop -- 16
local ImGui = require("ImGui") -- 18
local zh = false -- 20
do -- 20
	local res = string.match(App.locale, "^zh") -- 22
	zh = res ~= nil -- 23
end -- 23
local testFilePaths = {} -- 26
local testFileNames = {} -- 27
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 28
	do -- 28
		if "yarn" ~= Path:getExt(file) then -- 28
			goto __continue3 -- 30
		end -- 30
		testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 32
		testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 33
	end -- 33
	::__continue3:: -- 33
end -- 33
local filteredPaths = testFilePaths -- 36
local filteredNames = testFileNames -- 37
local currentFile = 1 -- 39
local fontScale = App.devicePixelRatio -- 41
local fontSize = math.floor(20 * fontScale) -- 42
local texts = {} -- 44
local root = AlignNode(true) -- 46
root:css("flex-direction: column-reverse") -- 47
local ____View_size_0 = View.size -- 49
local viewWidth = ____View_size_0.width -- 49
local viewHeight = ____View_size_0.height -- 49
local width = viewWidth - 100 -- 50
local height = viewHeight - 10 -- 51
local scroll = ScrollArea({ -- 52
	width = width, -- 53
	height = height, -- 54
	paddingX = 0, -- 55
	paddingY = 50, -- 56
	viewWidth = height, -- 57
	viewHeight = height -- 58
}) -- 58
scroll:addTo(root) -- 60
local ____opt_1 = Label("sarasa-mono-sc-regular", fontSize) -- 60
local label = ____opt_1 and ____opt_1:addTo(scroll.view) -- 62
if not label then -- 62
	error("failed to create label!") -- 64
end -- 64
label.scaleX = 1 / fontScale -- 66
label.scaleY = 1 / fontScale -- 67
label.alignment = "Left" -- 68
root:onAlignLayout(function(w, h) -- 70
	scroll.position = Vec2(w / 2, h / 2) -- 71
	w = w - 100 -- 72
	h = h - 10 -- 73
	label.textWidth = (w - fontSize) * fontScale -- 74
	scroll:adjustSizeWithAlign( -- 75
		"Auto", -- 75
		10, -- 75
		Size(w, h) -- 75
	) -- 75
	local ____opt_3 = scroll.area:getChildByTag("border") -- 75
	if ____opt_3 ~= nil then -- 75
		____opt_3:removeFromParent() -- 76
	end -- 76
	local border = LineRect({ -- 77
		x = 1, -- 77
		y = 1, -- 77
		width = w - 2, -- 77
		height = h - 2, -- 77
		color = 4294967295 -- 77
	}) -- 77
	scroll.area:addChild(border, 0, "border") -- 78
end) -- 70
local control = AlignNode():addTo(root) -- 81
control:css("height: 140; margin-bottom: 40") -- 82
local menu = Menu():addTo(control) -- 84
control:onAlignLayout(function(w, h) -- 85
	menu.position = Vec2(w / 2, h / 2) -- 86
end) -- 85
local commands = setmetatable( -- 89
	{}, -- 89
	{__index = function(self, name) -- 89
		return function(...) -- 91
			local args = {...} -- 91
			local argStrs = {} -- 92
			do -- 92
				local i = 0 -- 93
				while i < #args do -- 93
					argStrs[#argStrs + 1] = tostring(args[i + 1]) -- 94
					i = i + 1 -- 93
				end -- 93
			end -- 93
			local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 96
			coroutine.yield("Command", msg) -- 97
		end -- 91
	end} -- 90
) -- 90
local runner -- 102
if #filteredPaths > 0 then -- 102
	runner = YarnRunner( -- 104
		filteredPaths[currentFile], -- 104
		"Start", -- 104
		{}, -- 104
		commands, -- 104
		true -- 104
	) -- 104
end -- 104
local function setButtons(options) -- 107
	menu:removeAllChildren() -- 108
	local buttons = options or 1 -- 109
	menu.size = Size(80 * buttons, 80) -- 110
	do -- 110
		local i = 1 -- 111
		while i <= buttons do -- 111
			local circleButton = CircleButton({ -- 112
				text = options and tostring(i) or "Next", -- 113
				radius = 30, -- 114
				fontSize = 20 -- 115
			}):addTo(menu) -- 115
			local choice = options and i or nil -- 117
			circleButton:onTapped(function() -- 118
				advance(choice) -- 119
			end) -- 118
			i = i + 1 -- 111
		end -- 111
	end -- 111
	menu:alignItems() -- 122
end -- 107
advance = function(option) -- 125
	if not runner then -- 125
		return -- 126
	end -- 126
	local action, result = runner:advance(option) -- 127
	if action == "Text" then -- 127
		local charName = "" -- 129
		if result.marks ~= nil then -- 129
			for ____, mark in ipairs(result.marks) do -- 131
				if (mark.name == "Character" or mark.name == "char") and mark.attrs ~= nil then -- 131
					charName = tostring(mark.attrs.name) .. ": " -- 133
				end -- 133
			end -- 133
		end -- 133
		texts[#texts + 1] = charName .. result.text -- 137
		if result.optionsFollowed then -- 137
			advance() -- 139
		else -- 139
			setButtons() -- 141
		end -- 141
	elseif action == "Option" then -- 141
		for i, op in ipairs(result) do -- 144
			if type(op) ~= "boolean" then -- 144
				texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 146
			end -- 146
		end -- 146
		setButtons(#result) -- 149
	elseif action == "Command" then -- 149
		texts[#texts + 1] = result -- 151
		setButtons() -- 152
	else -- 152
		menu:removeAllChildren() -- 154
		texts[#texts + 1] = result -- 155
	end -- 155
	label.text = table.concat(texts, "\n") -- 157
	scroll:adjustSizeWithAlign("Auto", 10) -- 158
	thread(function() -- 159
		scroll:scrollToPosY(label.y - label.height / 2) -- 160
	end) -- 159
end -- 125
advance() -- 164
local filterBuf = Buffer(20) -- 166
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoFocusOnAppearing", "NoMove"} -- 167
local inputTextFlags = {"AutoSelectAll"} -- 173
threadLoop(function() -- 174
	local ____App_visualSize_5 = App.visualSize -- 175
	local width = ____App_visualSize_5.width -- 175
	ImGui.SetNextWindowPos( -- 176
		Vec2(width - 10, 10), -- 176
		"Always", -- 176
		Vec2(1, 0) -- 176
	) -- 176
	ImGui.SetNextWindowSize( -- 177
		Vec2(230, 0), -- 177
		"Always" -- 177
	) -- 177
	ImGui.Begin( -- 178
		"Yarn Tester", -- 178
		windowFlags, -- 178
		function() -- 178
			ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 179
			ImGui.SameLine() -- 180
			ImGui.TextDisabled("(?)") -- 181
			if ImGui.IsItemHovered() then -- 181
				ImGui.BeginTooltip(function() -- 183
					ImGui.PushTextWrapPos( -- 184
						300, -- 184
						function() -- 184
							ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 185
						end -- 184
					) -- 184
				end) -- 183
			end -- 183
			ImGui.Separator() -- 189
			ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 190
			ImGui.SameLine() -- 191
			local function runFile() -- 192
				do -- 192
					local function ____catch(err) -- 192
						label.text = (("failed to load file " .. filteredPaths[currentFile]) .. "\n") .. tostring(err) -- 198
						scroll:adjustSizeWithAlign("Auto", 10) -- 199
					end -- 199
					local ____try, ____hasReturned = pcall(function() -- 199
						runner = YarnRunner( -- 194
							filteredPaths[currentFile], -- 194
							"Start", -- 194
							{}, -- 194
							commands, -- 194
							true -- 194
						) -- 194
						texts = {} -- 195
						advance() -- 196
					end) -- 196
					if not ____try then -- 196
						____catch(____hasReturned) -- 196
					end -- 196
				end -- 196
			end -- 192
			if ImGui.Button(zh and "筛选" or "Filter") then -- 192
				local filterText = string.lower(filterBuf.text) -- 203
				local filtered = __TS__ArrayFilter( -- 204
					__TS__ArrayMap( -- 204
						testFileNames, -- 204
						function(____, n, i) return {n, testFilePaths[i + 1]} end -- 204
					), -- 204
					function(____, it, i) -- 204
						local matched = string.match( -- 205
							string.lower(it[1]), -- 205
							filterText -- 205
						) -- 205
						if matched ~= nil then -- 205
							return true -- 207
						end -- 207
						return false -- 209
					end -- 204
				) -- 204
				filteredNames = __TS__ArrayMap( -- 211
					filtered, -- 211
					function(____, f) return f[1] end -- 211
				) -- 211
				filteredPaths = __TS__ArrayMap( -- 212
					filtered, -- 212
					function(____, f) return f[2] end -- 212
				) -- 212
				currentFile = 1 -- 213
				if #filteredPaths > 0 then -- 213
					runFile() -- 215
				end -- 215
			end -- 215
			if #filteredNames == 0 then -- 215
				return -- 219
			end -- 219
			local changed = false -- 221
			changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 222
			if changed then -- 222
				runFile() -- 224
			end -- 224
			if ImGui.Button(zh and "重载" or "Reload") then -- 224
				runFile() -- 227
			end -- 227
			if runner then -- 227
				ImGui.SameLine() -- 230
				ImGui.Text(zh and "变量：" or "Variables:") -- 231
				ImGui.Separator() -- 232
				for k, v in pairs(runner.state) do -- 233
					ImGui.Text((k .. ": ") .. tostring(v)) -- 234
				end -- 234
			end -- 234
		end -- 178
	) -- 178
	return false -- 238
end) -- 174
return ____exports -- 174