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
    {__index = function(____, name) return function(____, ...) -- 84
        local args = {...} -- 84
        local argStrs = {} -- 86
        do -- 86
            local i = 1 -- 87
            while i <= select("#", args) do -- 87
                argStrs[#argStrs + 1] = tostring({select(i, args)}) -- 88
                i = i + 1 -- 87
            end -- 87
        end -- 87
        local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 90
        coroutine.yield("Command", msg) -- 91
    end end} -- 85
) -- 85
local runner = YarnRunner( -- 95
    testFile, -- 95
    "Start", -- 95
    {}, -- 95
    commands, -- 95
    true -- 95
) -- 95
local function setButtons(____, options) -- 97
    menu:removeAllChildren() -- 98
    local buttons = options or 1 -- 99
    menu.size = Size(140 * buttons, 140) -- 100
    do -- 100
        local i = 1 -- 101
        while i <= buttons do -- 101
            local circleButton = CircleButton({ -- 102
                text = options and tostring(i) or "Next", -- 103
                radius = 60, -- 104
                fontSize = 40 -- 105
            }):addTo(menu) -- 105
            circleButton:onTapped(function() -- 107
                advance(nil, options) -- 108
            end) -- 107
            i = i + 1 -- 101
        end -- 101
    end -- 101
    menu:alignItems() -- 111
end -- 97
advance = function(____, option) -- 114
    local action, result = runner:advance(option) -- 115
    if action == "Text" then -- 115
        local charName = "" -- 117
        if result.marks ~= nil then -- 117
            for ____, mark in ipairs(result.marks) do -- 119
                if mark.name == "char" and mark.attrs ~= nil then -- 119
                    charName = tostring(mark.attrs.name) .. ": " -- 121
                end -- 121
            end -- 121
        end -- 121
        texts[#texts + 1] = charName .. result.text -- 125
        if result.optionsFollowed then -- 125
            advance(nil) -- 127
        else -- 127
            setButtons(nil) -- 129
        end -- 129
    elseif action == "Option" then -- 129
        for i, op in ipairs(result) do -- 132
            if type(op) ~= "boolean" then -- 132
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 134
            end -- 134
        end -- 134
        setButtons(nil, #result) -- 137
    elseif action == "Command" then -- 137
        texts[#texts + 1] = result -- 139
        setButtons(nil) -- 140
    else -- 140
        menu:removeAllChildren() -- 142
        texts[#texts + 1] = result -- 143
    end -- 143
    if not label then -- 143
        return -- 145
    end -- 145
    label.text = table.concat(texts, "\n") -- 146
    scroll:adjustSizeWithAlign("Auto", 10) -- 147
    thread(function() -- 148
        scroll:scrollToPosY(label.y - label.height / 2) -- 149
    end) -- 148
end -- 114
advance(nil) -- 153
local testFilePaths = {testFile} -- 155
local testFileNames = {"Test/tutorial.yarn"} -- 156
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 157
    do -- 157
        if "yarn" ~= Path:getExt(file) then -- 157
            goto __continue30 -- 159
        end -- 159
        testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 161
        testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 162
    end -- 162
    ::__continue30:: -- 162
end -- 162
local filteredPaths = testFilePaths -- 165
local filteredNames = testFileNames -- 166
local currentFile = 1 -- 168
local filterBuf = Buffer(20) -- 169
local windowFlags = { -- 170
    "NoDecoration", -- 171
    "NoSavedSettings", -- 172
    "NoFocusOnAppearing", -- 173
    "NoNav", -- 174
    "NoMove" -- 175
} -- 175
local inputTextFlags = {"AutoSelectAll"} -- 177
threadLoop(function() -- 178
    local ____App_visualSize_7 = App.visualSize -- 179
    local width = ____App_visualSize_7.width -- 179
    ImGui.SetNextWindowPos( -- 180
        Vec2(width - 10, 10), -- 180
        "Always", -- 180
        Vec2(1, 0) -- 180
    ) -- 180
    ImGui.SetNextWindowSize( -- 181
        Vec2(230, 0), -- 181
        "Always" -- 181
    ) -- 181
    ImGui.Begin( -- 182
        "Yarn Tester", -- 182
        windowFlags, -- 182
        function() -- 182
            ImGui.Text(zh and "Yarn 测试工具" or "Yarn Tester") -- 183
            ImGui.SameLine() -- 184
            ImGui.TextDisabled("(?)") -- 185
            if ImGui.IsItemHovered() then -- 185
                ImGui.BeginTooltip(function() -- 187
                    ImGui.PushTextWrapPos( -- 188
                        300, -- 188
                        function() -- 188
                            ImGui.Text(zh and "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" or "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.") -- 189
                        end -- 188
                    ) -- 188
                end) -- 187
            end -- 187
            ImGui.Separator() -- 193
            ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 194
            ImGui.SameLine() -- 195
            if ImGui.Button(zh and "筛选" or "Filter") then -- 195
                local filterText = string.lower(filterBuf.text) -- 197
                local filtered = __TS__ArrayFilter( -- 198
                    __TS__ArrayMap( -- 198
                        testFileNames, -- 198
                        function(____, n, i) return {n, testFilePaths[i + 1]} end -- 198
                    ), -- 198
                    function(____, it, i) -- 198
                        local matched = string.match( -- 199
                            string.lower(it[1]), -- 199
                            filterText -- 199
                        ) -- 199
                        if matched ~= nil then -- 199
                            return true -- 201
                        end -- 201
                        return false -- 203
                    end -- 198
                ) -- 198
                filteredNames = __TS__ArrayMap( -- 205
                    filtered, -- 205
                    function(____, f) return f[1] end -- 205
                ) -- 205
                filteredPaths = __TS__ArrayMap( -- 206
                    filtered, -- 206
                    function(____, f) return f[2] end -- 206
                ) -- 206
                currentFile = 1 -- 207
                if #filteredPaths > 0 then -- 207
                    runner = YarnRunner( -- 209
                        filteredPaths[currentFile], -- 209
                        "Start", -- 209
                        {}, -- 209
                        commands, -- 209
                        true -- 209
                    ) -- 209
                    texts = {} -- 210
                    advance(nil) -- 211
                end -- 211
            end -- 211
            local changed = false -- 214
            changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 215
            if changed then -- 215
                runner = YarnRunner( -- 217
                    filteredPaths[currentFile], -- 217
                    "Start", -- 217
                    {}, -- 217
                    commands, -- 217
                    true -- 217
                ) -- 217
                texts = {} -- 218
                advance(nil) -- 219
            end -- 219
            ImGui.Text(zh and "变量" or "Variables") -- 221
            ImGui.Separator() -- 222
            for k, v in pairs(runner.state) do -- 223
                ImGui.Text((k .. ": ") .. tostring(v)) -- 224
            end -- 224
        end -- 182
    ) -- 182
    return false -- 227
end) -- 178
return ____exports -- 178