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
	zh = res ~= nil and ImGui.IsFontLoaded() -- 23
end -- 23
local testFile = Path(Content.assetPath, "Script", "Test", "tutorial.yarn") -- 26
local fontScale = App.devicePixelRatio -- 28
local fontSize = math.floor(20 * fontScale) -- 29
local texts = {} -- 31
local root = AlignNode(true) -- 33
root:css("flex-direction: column-reverse") -- 34
local ____View_size_0 = View.size -- 36
local viewWidth = ____View_size_0.width -- 36
local viewHeight = ____View_size_0.height -- 36
local width = viewWidth - 100 -- 37
local height = viewHeight - 10 -- 38
local scroll = ScrollArea({ -- 39
	width = width, -- 40
	height = height, -- 41
	paddingX = 0, -- 42
	paddingY = 50, -- 43
	viewWidth = height, -- 44
	viewHeight = height -- 45
}) -- 45
scroll:addTo(root) -- 47
local ____opt_1 = Label("sarasa-mono-sc-regular", fontSize) -- 47
local label = ____opt_1 and ____opt_1:addTo(scroll.view) -- 49
if not label then -- 49
	error("failed to create label!") -- 51
end -- 51
label.scaleX = 1 / fontScale -- 53
label.scaleY = 1 / fontScale -- 54
label.alignment = "Left" -- 55
root:onAlignLayout(function(w, h) -- 57
	scroll.position = Vec2(w / 2, h / 2) -- 58
	w = w - 100 -- 59
	h = h - 10 -- 60
	label.textWidth = (w - fontSize) * fontScale -- 61
	scroll:adjustSizeWithAlign( -- 62
		"Auto", -- 62
		10, -- 62
		Size(w, h) -- 62
	) -- 62
	local ____opt_3 = scroll.area:getChildByTag("border") -- 62
	if ____opt_3 ~= nil then -- 62
		____opt_3:removeFromParent() -- 63
	end -- 63
	local border = LineRect({ -- 64
		x = 1, -- 64
		y = 1, -- 64
		width = w - 2, -- 64
		height = h - 2, -- 64
		color = 4294967295 -- 64
	}) -- 64
	scroll.area:addChild(border, 0, "border") -- 65
end) -- 57
local control = AlignNode():addTo(root) -- 68
control:css("height: 140; margin-bottom: 40") -- 69
local menu = Menu():addTo(control) -- 71
control:onAlignLayout(function(w, h) -- 72
	menu.position = Vec2(w / 2, h / 2) -- 73
end) -- 72
local commands = setmetatable( -- 76
	{}, -- 76
	{__index = function(self, name) -- 76
		return function(...) -- 78
			local args = {...} -- 78
			local argStrs = {} -- 79
			do -- 79
				local i = 0 -- 80
				while i < #args do -- 80
					argStrs[#argStrs + 1] = tostring(args[i + 1]) -- 81
					i = i + 1 -- 80
				end -- 80
			end -- 80
			local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 83
			coroutine.yield("Command", msg) -- 84
		end -- 78
	end} -- 77
) -- 77
local runner = YarnRunner( -- 89
	testFile, -- 89
	"Start", -- 89
	{}, -- 89
	commands, -- 89
	true -- 89
) -- 89
local function setButtons(options) -- 91
	menu:removeAllChildren() -- 92
	local buttons = options or 1 -- 93
	menu.size = Size(80 * buttons, 80) -- 94
	do -- 94
		local i = 1 -- 95
		while i <= buttons do -- 95
			local circleButton = CircleButton({ -- 96
				text = options and tostring(i) or "Next", -- 97
				radius = 30, -- 98
				fontSize = 20 -- 99
			}):addTo(menu) -- 99
			local choice = options and i or nil -- 101
			circleButton:onTapped(function() -- 102
				advance(choice) -- 103
			end) -- 102
			i = i + 1 -- 95
		end -- 95
	end -- 95
	menu:alignItems() -- 106
end -- 91
advance = function(option) -- 109
	local action, result = runner:advance(option) -- 110
	if action == "Text" then -- 110
		local charName = "" -- 112
		if result.marks ~= nil then -- 112
			for ____, mark in ipairs(result.marks) do -- 114
				if (mark.name == "Character" or mark.name == "char") and mark.attrs ~= nil then -- 114
					charName = tostring(mark.attrs.name) .. ": " -- 116
				end -- 116
			end -- 116
		end -- 116
		texts[#texts + 1] = charName .. result.text -- 120
		if result.optionsFollowed then -- 120
			advance() -- 122
		else -- 122
			setButtons() -- 124
		end -- 124
	elseif action == "Option" then -- 124
		for i, op in ipairs(result) do -- 127
			if type(op) ~= "boolean" then -- 127
				texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 129
			end -- 129
		end -- 129
		setButtons(#result) -- 132
	elseif action == "Command" then -- 132
		texts[#texts + 1] = result -- 134
		setButtons() -- 135
	else -- 135
		menu:removeAllChildren() -- 137
		texts[#texts + 1] = result -- 138
	end -- 138
	label.text = table.concat(texts, "\n") -- 140
	scroll:adjustSizeWithAlign("Auto", 10) -- 141
	thread(function() -- 142
		scroll:scrollToPosY(label.y - label.height / 2) -- 143
	end) -- 142
end -- 109
advance() -- 147
local testFilePaths = {testFile} -- 149
local testFileNames = {"Test/tutorial.yarn"} -- 150
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 151
	do -- 151
		if "yarn" ~= Path:getExt(file) then -- 151
			goto __continue28 -- 153
		end -- 153
		testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 155
		testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 156
	end -- 156
	::__continue28:: -- 156
end -- 156
local filteredPaths = testFilePaths -- 159
local filteredNames = testFileNames -- 160
local currentFile = 1 -- 162
local filterBuf = Buffer(20) -- 163
local windowFlags = { -- 164
	"NoDecoration", -- 165
	"NoSavedSettings", -- 166
	"NoFocusOnAppearing", -- 167
	"NoNav", -- 168
	"NoMove" -- 169
} -- 169
local inputTextFlags = {"AutoSelectAll"} -- 171
threadLoop(function() -- 172
	local ____App_visualSize_5 = App.visualSize -- 173
	local width = ____App_visualSize_5.width -- 173
	ImGui.SetNextWindowPos( -- 174
		Vec2(width - 10, 10), -- 174
		"Always", -- 174
		Vec2(1, 0) -- 174
	) -- 174
	ImGui.SetNextWindowSize( -- 175
		Vec2(230, 0), -- 175
		"Always" -- 175
	) -- 175
	ImGui.Begin( -- 176
		"Yarn Tester", -- 176
		windowFlags, -- 176
		function() -- 176
			ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 177
			ImGui.SameLine() -- 178
			ImGui.TextDisabled("(?)") -- 179
			if ImGui.IsItemHovered() then -- 179
				ImGui.BeginTooltip(function() -- 181
					ImGui.PushTextWrapPos( -- 182
						300, -- 182
						function() -- 182
							ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 183
						end -- 182
					) -- 182
				end) -- 181
			end -- 181
			ImGui.Separator() -- 187
			ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 188
			ImGui.SameLine() -- 189
			local function runFile() -- 190
				do -- 190
					local function ____catch(err) -- 190
						label.text = (("failed to load file " .. filteredPaths[currentFile]) .. "\n") .. tostring(err) -- 196
						scroll:adjustSizeWithAlign("Auto", 10) -- 197
					end -- 197
					local ____try, ____hasReturned = pcall(function() -- 197
						runner = YarnRunner( -- 192
							filteredPaths[currentFile], -- 192
							"Start", -- 192
							{}, -- 192
							commands, -- 192
							true -- 192
						) -- 192
						texts = {} -- 193
						advance() -- 194
					end) -- 194
					if not ____try then -- 194
						____catch(____hasReturned) -- 194
					end -- 194
				end -- 194
			end -- 190
			if ImGui.Button(zh and "筛选" or "Filter") then -- 190
				local filterText = string.lower(filterBuf.text) -- 201
				local filtered = __TS__ArrayFilter( -- 202
					__TS__ArrayMap( -- 202
						testFileNames, -- 202
						function(____, n, i) return {n, testFilePaths[i + 1]} end -- 202
					), -- 202
					function(____, it, i) -- 202
						local matched = string.match( -- 203
							string.lower(it[1]), -- 203
							filterText -- 203
						) -- 203
						if matched ~= nil then -- 203
							return true -- 205
						end -- 205
						return false -- 207
					end -- 202
				) -- 202
				filteredNames = __TS__ArrayMap( -- 209
					filtered, -- 209
					function(____, f) return f[1] end -- 209
				) -- 209
				filteredPaths = __TS__ArrayMap( -- 210
					filtered, -- 210
					function(____, f) return f[2] end -- 210
				) -- 210
				currentFile = 1 -- 211
				if #filteredPaths > 0 then -- 211
					runFile() -- 213
				end -- 213
			end -- 213
			local changed = false -- 216
			changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 217
			if changed then -- 217
				runFile() -- 219
			end -- 219
			if ImGui.Button(zh and "重载" or "Reload") then -- 219
				runFile() -- 222
			end -- 222
			ImGui.SameLine() -- 224
			ImGui.Text(zh and "变量：" or "Variables:") -- 225
			ImGui.Separator() -- 226
			for k, v in pairs(runner.state) do -- 227
				ImGui.Text((k .. ": ") .. tostring(v)) -- 228
			end -- 228
		end -- 176
	) -- 176
	return false -- 231
end) -- 172
return ____exports -- 172