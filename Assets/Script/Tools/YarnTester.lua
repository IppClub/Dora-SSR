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
local windowFlags = { -- 167
	"NoDecoration", -- 168
	"NoSavedSettings", -- 169
	"NoFocusOnAppearing", -- 170
	"NoNav", -- 171
	"NoMove" -- 172
} -- 172
local inputTextFlags = {"AutoSelectAll"} -- 174
threadLoop(function() -- 175
	local ____App_visualSize_5 = App.visualSize -- 176
	local width = ____App_visualSize_5.width -- 176
	ImGui.SetNextWindowPos( -- 177
		Vec2(width - 10, 10), -- 177
		"Always", -- 177
		Vec2(1, 0) -- 177
	) -- 177
	ImGui.SetNextWindowSize( -- 178
		Vec2(230, 0), -- 178
		"Always" -- 178
	) -- 178
	ImGui.Begin( -- 179
		"Yarn Tester", -- 179
		windowFlags, -- 179
		function() -- 179
			ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 180
			ImGui.SameLine() -- 181
			ImGui.TextDisabled("(?)") -- 182
			if ImGui.IsItemHovered() then -- 182
				ImGui.BeginTooltip(function() -- 184
					ImGui.PushTextWrapPos( -- 185
						300, -- 185
						function() -- 185
							ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 186
						end -- 185
					) -- 185
				end) -- 184
			end -- 184
			ImGui.Separator() -- 190
			ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 191
			ImGui.SameLine() -- 192
			local function runFile() -- 193
				do -- 193
					local function ____catch(err) -- 193
						label.text = (("failed to load file " .. filteredPaths[currentFile]) .. "\n") .. tostring(err) -- 199
						scroll:adjustSizeWithAlign("Auto", 10) -- 200
					end -- 200
					local ____try, ____hasReturned = pcall(function() -- 200
						runner = YarnRunner( -- 195
							filteredPaths[currentFile], -- 195
							"Start", -- 195
							{}, -- 195
							commands, -- 195
							true -- 195
						) -- 195
						texts = {} -- 196
						advance() -- 197
					end) -- 197
					if not ____try then -- 197
						____catch(____hasReturned) -- 197
					end -- 197
				end -- 197
			end -- 193
			if ImGui.Button(zh and "筛选" or "Filter") then -- 193
				local filterText = string.lower(filterBuf.text) -- 204
				local filtered = __TS__ArrayFilter( -- 205
					__TS__ArrayMap( -- 205
						testFileNames, -- 205
						function(____, n, i) return {n, testFilePaths[i + 1]} end -- 205
					), -- 205
					function(____, it, i) -- 205
						local matched = string.match( -- 206
							string.lower(it[1]), -- 206
							filterText -- 206
						) -- 206
						if matched ~= nil then -- 206
							return true -- 208
						end -- 208
						return false -- 210
					end -- 205
				) -- 205
				filteredNames = __TS__ArrayMap( -- 212
					filtered, -- 212
					function(____, f) return f[1] end -- 212
				) -- 212
				filteredPaths = __TS__ArrayMap( -- 213
					filtered, -- 213
					function(____, f) return f[2] end -- 213
				) -- 213
				currentFile = 1 -- 214
				if #filteredPaths > 0 then -- 214
					runFile() -- 216
				end -- 216
			end -- 216
			if #filteredNames == 0 then -- 216
				return -- 220
			end -- 220
			local changed = false -- 222
			changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 223
			if changed then -- 223
				runFile() -- 225
			end -- 225
			if ImGui.Button(zh and "重载" or "Reload") then -- 225
				runFile() -- 228
			end -- 228
			if runner then -- 228
				ImGui.SameLine() -- 231
				ImGui.Text(zh and "变量：" or "Variables:") -- 232
				ImGui.Separator() -- 233
				for k, v in pairs(runner.state) do -- 234
					ImGui.Text((k .. ": ") .. tostring(v)) -- 235
				end -- 235
			end -- 235
		end -- 179
	) -- 179
	return false -- 239
end) -- 175
return ____exports -- 175