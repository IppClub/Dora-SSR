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
local tolua = ____Dora.tolua -- 16
local ImGui = require("ImGui") -- 18
local zh = false -- 20
do -- 20
    local res = string.match(App.locale, "^zh") -- 22
    zh = res ~= nil and ImGui.IsFontLoaded() -- 23
end -- 23
local testFile = Path(Content.assetPath, "Script", "Test", "tutorial.yarn") -- 26
local fontSize = math.floor(20 * App.devicePixelRatio) -- 28
local texts = {} -- 30
local root = AlignNode() -- 32
local ____View_size_0 = View.size -- 33
local viewWidth = ____View_size_0.width -- 33
local viewHeight = ____View_size_0.height -- 33
root:css(((("width: " .. tostring(viewWidth)) .. "; height: ") .. tostring(viewHeight)) .. "; flex-direction: column-reverse") -- 34
root:onAppChange(function(settingName) -- 35
    if settingName == "Size" then -- 35
        local ____View_size_1 = View.size -- 37
        local width = ____View_size_1.width -- 37
        local height = ____View_size_1.height -- 37
        root:css(((("width: " .. tostring(width)) .. "; height: ") .. tostring(height)) .. "; flex-direction: column-reverse") -- 38
    end -- 38
end) -- 35
local width = viewWidth - 200 -- 42
local height = viewHeight - 20 -- 43
local scroll = ScrollArea({ -- 44
    width = width, -- 45
    height = height, -- 46
    paddingX = 0, -- 47
    paddingY = 50, -- 48
    viewWidth = height, -- 49
    viewHeight = height -- 50
}) -- 50
scroll:addTo(root) -- 52
local border = LineRect({width = width, height = height, color = 4294967295}) -- 54
scroll.area:addChild(border) -- 55
root:onAlignLayout(function(w, h) -- 56
    scroll.position = Vec2(w / 2, h / 2) -- 57
    w = w - 200 -- 58
    h = h - 20 -- 59
    local ____tolua_cast_4 = tolua.cast -- 60
    local ____opt_2 = scroll.view.children -- 60
    local label = ____tolua_cast_4(____opt_2 and ____opt_2.first, "Label") -- 60
    if label ~= nil then -- 60
        label.textWidth = w - fontSize -- 62
    end -- 62
    scroll:adjustSizeWithAlign( -- 64
        "Auto", -- 64
        10, -- 64
        Size(w, h) -- 64
    ) -- 64
    scroll.area:removeChild(border) -- 65
    border = LineRect({ -- 66
        x = 1, -- 66
        y = 1, -- 66
        width = w - 2, -- 66
        height = h - 2, -- 66
        color = 4294967295 -- 66
    }) -- 66
    scroll.area:addChild(border) -- 67
end) -- 56
local ____opt_5 = Label("sarasa-mono-sc-regular", fontSize) -- 56
local label = ____opt_5 and ____opt_5:addTo(scroll.view) -- 69
if label then -- 69
    label.alignment = "Left" -- 71
    label.textWidth = width - fontSize -- 72
    label.text = "" -- 73
end -- 73
local control = AlignNode():addTo(root) -- 76
control:css("height: 140; margin-bottom: 40") -- 77
local menu = Menu():addTo(control) -- 79
control:onAlignLayout(function(w, h) -- 80
    menu.position = Vec2(w / 2, h / 2) -- 81
end) -- 80
local commands = setmetatable( -- 84
    {}, -- 84
    {__index = function(self, name) -- 84
        return function(...) -- 86
            local args = {...} -- 86
            local argStrs = {} -- 87
            do -- 87
                local i = 0 -- 88
                while i < #args do -- 88
                    argStrs[#argStrs + 1] = tostring(args[i + 1]) -- 89
                    i = i + 1 -- 88
                end -- 88
            end -- 88
            local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 91
            coroutine.yield("Command", msg) -- 92
        end -- 86
    end} -- 85
) -- 85
local runner = YarnRunner( -- 97
    testFile, -- 97
    "Start", -- 97
    {}, -- 97
    commands, -- 97
    true -- 97
) -- 97
local function setButtons(options) -- 99
    menu:removeAllChildren() -- 100
    local buttons = options or 1 -- 101
    menu.size = Size(140 * buttons, 140) -- 102
    do -- 102
        local i = 1 -- 103
        while i <= buttons do -- 103
            local circleButton = CircleButton({ -- 104
                text = options and tostring(i) or "Next", -- 105
                radius = 60, -- 106
                fontSize = 40 -- 107
            }):addTo(menu) -- 107
            circleButton:onTapped(function() -- 109
                advance(options) -- 110
            end) -- 109
            i = i + 1 -- 103
        end -- 103
    end -- 103
    menu:alignItems() -- 113
end -- 99
advance = function(option) -- 116
    local action, result = runner:advance(option) -- 117
    if action == "Text" then -- 117
        local charName = "" -- 119
        if result.marks ~= nil then -- 119
            for ____, mark in ipairs(result.marks) do -- 121
                if mark.name == "char" and mark.attrs ~= nil then -- 121
                    charName = tostring(mark.attrs.name) .. ": " -- 123
                end -- 123
            end -- 123
        end -- 123
        texts[#texts + 1] = charName .. result.text -- 127
        if result.optionsFollowed then -- 127
            advance() -- 129
        else -- 129
            setButtons() -- 131
        end -- 131
    elseif action == "Option" then -- 131
        for i, op in ipairs(result) do -- 134
            if type(op) ~= "boolean" then -- 134
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 136
            end -- 136
        end -- 136
        setButtons(#result) -- 139
    elseif action == "Command" then -- 139
        texts[#texts + 1] = result -- 141
        setButtons() -- 142
    else -- 142
        menu:removeAllChildren() -- 144
        texts[#texts + 1] = result -- 145
    end -- 145
    if not label then -- 145
        return -- 147
    end -- 147
    label.text = table.concat(texts, "\n") -- 148
    scroll:adjustSizeWithAlign("Auto", 10) -- 149
    thread(function() -- 150
        scroll:scrollToPosY(label.y - label.height / 2) -- 151
    end) -- 150
end -- 116
advance() -- 155
local testFilePaths = {testFile} -- 157
local testFileNames = {"Test/tutorial.yarn"} -- 158
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 159
    do -- 159
        if "yarn" ~= Path:getExt(file) then -- 159
            goto __continue30 -- 161
        end -- 161
        testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 163
        testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 164
    end -- 164
    ::__continue30:: -- 164
end -- 164
local filteredPaths = testFilePaths -- 167
local filteredNames = testFileNames -- 168
local currentFile = 1 -- 170
local filterBuf = Buffer(20) -- 171
local windowFlags = { -- 172
    "NoDecoration", -- 173
    "NoSavedSettings", -- 174
    "NoFocusOnAppearing", -- 175
    "NoNav", -- 176
    "NoMove" -- 177
} -- 177
local inputTextFlags = {"AutoSelectAll"} -- 179
threadLoop(function() -- 180
    local ____App_visualSize_7 = App.visualSize -- 181
    local width = ____App_visualSize_7.width -- 181
    ImGui.SetNextWindowPos( -- 182
        Vec2(width - 10, 10), -- 182
        "Always", -- 182
        Vec2(1, 0) -- 182
    ) -- 182
    ImGui.SetNextWindowSize( -- 183
        Vec2(230, 0), -- 183
        "Always" -- 183
    ) -- 183
    ImGui.Begin( -- 184
        "Yarn Tester", -- 184
        windowFlags, -- 184
        function() -- 184
            ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 185
            ImGui.SameLine() -- 186
            ImGui.TextDisabled("(?)") -- 187
            if ImGui.IsItemHovered() then -- 187
                ImGui.BeginTooltip(function() -- 189
                    ImGui.PushTextWrapPos( -- 190
                        300, -- 190
                        function() -- 190
                            ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 191
                        end -- 190
                    ) -- 190
                end) -- 189
            end -- 189
            ImGui.Separator() -- 195
            ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 196
            ImGui.SameLine() -- 197
            if ImGui.Button(zh and "筛选" or "Filter") then -- 197
                local filterText = string.lower(filterBuf.text) -- 199
                local filtered = __TS__ArrayFilter( -- 200
                    __TS__ArrayMap( -- 200
                        testFileNames, -- 200
                        function(____, n, i) return {n, testFilePaths[i + 1]} end -- 200
                    ), -- 200
                    function(____, it, i) -- 200
                        local matched = string.match( -- 201
                            string.lower(it[1]), -- 201
                            filterText -- 201
                        ) -- 201
                        if matched ~= nil then -- 201
                            return true -- 203
                        end -- 203
                        return false -- 205
                    end -- 200
                ) -- 200
                filteredNames = __TS__ArrayMap( -- 207
                    filtered, -- 207
                    function(____, f) return f[1] end -- 207
                ) -- 207
                filteredPaths = __TS__ArrayMap( -- 208
                    filtered, -- 208
                    function(____, f) return f[2] end -- 208
                ) -- 208
                currentFile = 1 -- 209
                if #filteredPaths > 0 then -- 209
                    runner = YarnRunner( -- 211
                        filteredPaths[currentFile], -- 211
                        "Start", -- 211
                        {}, -- 211
                        commands, -- 211
                        true -- 211
                    ) -- 211
                    texts = {} -- 212
                    advance() -- 213
                end -- 213
            end -- 213
            local changed = false -- 216
            changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 217
            if changed then -- 217
                runner = YarnRunner( -- 219
                    filteredPaths[currentFile], -- 219
                    "Start", -- 219
                    {}, -- 219
                    commands, -- 219
                    true -- 219
                ) -- 219
                texts = {} -- 220
                advance() -- 221
            end -- 221
            ImGui.Text(zh and "变量" or "Variables") -- 223
            ImGui.Separator() -- 224
            for k, v in pairs(runner.state) do -- 225
                ImGui.Text((k .. ": ") .. tostring(v)) -- 226
            end -- 226
        end -- 184
    ) -- 184
    return false -- 229
end) -- 180
return ____exports -- 180