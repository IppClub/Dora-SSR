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
			circleButton:onTapped(function() -- 101
				advance(options) -- 102
			end) -- 101
			i = i + 1 -- 95
		end -- 95
	end -- 95
	menu:alignItems() -- 105
end -- 91
advance = function(option) -- 108
	local action, result = runner:advance(option) -- 109
	if action == "Text" then -- 109
		local charName = "" -- 111
		if result.marks ~= nil then -- 111
			for ____, mark in ipairs(result.marks) do -- 113
				if mark.name == "char" and mark.attrs ~= nil then -- 113
					charName = tostring(mark.attrs.name) .. ": " -- 115
				end -- 115
			end -- 115
		end -- 115
		texts[#texts + 1] = charName .. result.text -- 119
		if result.optionsFollowed then -- 119
			advance() -- 121
		else -- 121
			setButtons() -- 123
		end -- 123
	elseif action == "Option" then -- 123
		for i, op in ipairs(result) do -- 126
			if type(op) ~= "boolean" then -- 126
				texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 128
			end -- 128
		end -- 128
		setButtons(#result) -- 131
	elseif action == "Command" then -- 131
		texts[#texts + 1] = result -- 133
		setButtons() -- 134
	else -- 134
		menu:removeAllChildren() -- 136
		texts[#texts + 1] = result -- 137
	end -- 137
	label.text = table.concat(texts, "\n") -- 139
	scroll:adjustSizeWithAlign("Auto", 10) -- 140
	thread(function() -- 141
		scroll:scrollToPosY(label.y - label.height / 2) -- 142
	end) -- 141
end -- 108
advance() -- 146
local testFilePaths = {testFile} -- 148
local testFileNames = {"Test/tutorial.yarn"} -- 149
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 150
	do -- 150
		if "yarn" ~= Path:getExt(file) then -- 150
			goto __continue26 -- 152
		end -- 152
		testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 154
		testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 155
	end -- 155
	::__continue26:: -- 155
end -- 155
local filteredPaths = testFilePaths -- 158
local filteredNames = testFileNames -- 159
local currentFile = 1 -- 161
local filterBuf = Buffer(20) -- 162
local windowFlags = { -- 163
	"NoDecoration", -- 164
	"NoSavedSettings", -- 165
	"NoFocusOnAppearing", -- 166
	"NoNav", -- 167
	"NoMove" -- 168
} -- 168
local inputTextFlags = {"AutoSelectAll"} -- 170
threadLoop(function() -- 171
	local ____App_visualSize_5 = App.visualSize -- 172
	local width = ____App_visualSize_5.width -- 172
	ImGui.SetNextWindowPos( -- 173
		Vec2(width - 10, 10), -- 173
		"Always", -- 173
		Vec2(1, 0) -- 173
	) -- 173
	ImGui.SetNextWindowSize( -- 174
		Vec2(230, 0), -- 174
		"Always" -- 174
	) -- 174
	ImGui.Begin( -- 175
		"Yarn Tester", -- 175
		windowFlags, -- 175
		function() -- 175
			ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 176
			ImGui.SameLine() -- 177
			ImGui.TextDisabled("(?)") -- 178
			if ImGui.IsItemHovered() then -- 178
				ImGui.BeginTooltip(function() -- 180
					ImGui.PushTextWrapPos( -- 181
						300, -- 181
						function() -- 181
							ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 182
						end -- 181
					) -- 181
				end) -- 180
			end -- 180
			ImGui.Separator() -- 186
			ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 187
			ImGui.SameLine() -- 188
			local function runFile() -- 189
				do -- 189
					local function ____catch(err) -- 189
						label.text = (("failed to load file " .. filteredPaths[currentFile]) .. "\n") .. tostring(err) -- 195
						scroll:adjustSizeWithAlign("Auto", 10) -- 196
					end -- 196
					local ____try, ____hasReturned = pcall(function() -- 196
						runner = YarnRunner( -- 191
							filteredPaths[currentFile], -- 191
							"Start", -- 191
							{}, -- 191
							commands, -- 191
							true -- 191
						) -- 191
						texts = {} -- 192
						advance() -- 193
					end) -- 193
					if not ____try then -- 193
						____catch(____hasReturned) -- 193
					end -- 193
				end -- 193
			end -- 189
			if ImGui.Button(zh and "筛选" or "Filter") then -- 189
				local filterText = string.lower(filterBuf.text) -- 200
				local filtered = __TS__ArrayFilter( -- 201
					__TS__ArrayMap( -- 201
						testFileNames, -- 201
						function(____, n, i) return {n, testFilePaths[i + 1]} end -- 201
					), -- 201
					function(____, it, i) -- 201
						local matched = string.match( -- 202
							string.lower(it[1]), -- 202
							filterText -- 202
						) -- 202
						if matched ~= nil then -- 202
							return true -- 204
						end -- 204
						return false -- 206
					end -- 201
				) -- 201
				filteredNames = __TS__ArrayMap( -- 208
					filtered, -- 208
					function(____, f) return f[1] end -- 208
				) -- 208
				filteredPaths = __TS__ArrayMap( -- 209
					filtered, -- 209
					function(____, f) return f[2] end -- 209
				) -- 209
				currentFile = 1 -- 210
				if #filteredPaths > 0 then -- 210
					runFile() -- 212
				end -- 212
			end -- 212
			local changed = false -- 215
			changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 216
			if changed then -- 216
				runFile() -- 218
			end -- 218
			if ImGui.Button(zh and "重载" or "Reload") then -- 218
				runFile() -- 221
			end -- 221
			ImGui.SameLine() -- 223
			ImGui.Text(zh and "变量：" or "Variables:") -- 224
			ImGui.Separator() -- 225
			for k, v in pairs(runner.state) do -- 226
				ImGui.Text((k .. ": ") .. tostring(v)) -- 227
			end -- 227
		end -- 175
	) -- 175
	return false -- 230
end) -- 171
return ____exports -- 171