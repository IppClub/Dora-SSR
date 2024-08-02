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
root:gslot( -- 35
    "AppSizeChanged", -- 35
    function() -- 35
        local ____View_size_1 = View.size -- 36
        local width = ____View_size_1.width -- 36
        local height = ____View_size_1.height -- 36
        root:css(((("width: " .. tostring(width)) .. "; height: ") .. tostring(height)) .. "; flex-direction: column-reverse") -- 37
    end -- 35
) -- 35
local width = viewWidth - 200 -- 40
local height = viewHeight - 20 -- 41
local scroll = ScrollArea({ -- 42
    width = width, -- 43
    height = height, -- 44
    paddingX = 0, -- 45
    paddingY = 50, -- 46
    viewWidth = height, -- 47
    viewHeight = height -- 48
}) -- 48
scroll:addTo(root) -- 50
local border = LineRect({width = width, height = height, color = 4294967295}) -- 52
scroll.area:addChild(border) -- 53
root:slot( -- 54
    "AlignLayout", -- 54
    function(w, h) -- 54
        scroll.position = Vec2(w / 2, h / 2) -- 55
        w = w - 200 -- 56
        h = h - 20 -- 57
        local ____tolua_cast_4 = tolua.cast -- 58
        local ____opt_2 = scroll.view.children -- 58
        local label = ____tolua_cast_4(____opt_2 and ____opt_2.first, "Label") -- 58
        if label ~= nil then -- 58
            label.textWidth = w - fontSize -- 60
        end -- 60
        scroll:adjustSizeWithAlign( -- 62
            "Auto", -- 62
            10, -- 62
            Size(w, h) -- 62
        ) -- 62
        scroll.area:removeChild(border) -- 63
        border = LineRect({width = w, height = h, color = 4294967295}) -- 64
        scroll.area:addChild(border) -- 65
    end -- 54
) -- 54
local ____opt_5 = Label("sarasa-mono-sc-regular", fontSize) -- 54
local label = ____opt_5 and ____opt_5:addTo(scroll.view) -- 67
if label then -- 67
    label.alignment = "Left" -- 69
    label.textWidth = width - fontSize -- 70
    label.text = "" -- 71
end -- 71
local control = AlignNode():addTo(root) -- 74
control:css("height: 140; margin-bottom: 40") -- 75
local menu = Menu():addTo(control) -- 77
control:slot( -- 78
    "AlignLayout", -- 78
    function(w, h) -- 78
        menu.position = Vec2(w / 2, h / 2) -- 79
    end -- 78
) -- 78
local commands = setmetatable( -- 82
    {}, -- 82
    {__index = function(____, name) return function(____, ...) -- 82
        local args = {...} -- 82
        local argStrs = {} -- 84
        do -- 84
            local i = 1 -- 85
            while i <= select("#", args) do -- 85
                argStrs[#argStrs + 1] = tostring({select(i, args)}) -- 86
                i = i + 1 -- 85
            end -- 85
        end -- 85
        local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 88
        coroutine.yield("Command", msg) -- 89
    end end} -- 83
) -- 83
local runner = YarnRunner( -- 93
    testFile, -- 93
    "Start", -- 93
    {}, -- 93
    commands, -- 93
    true -- 93
) -- 93
local function setButtons(____, options) -- 95
    menu:removeAllChildren() -- 96
    local buttons = options or 1 -- 97
    menu.size = Size(140 * buttons, 140) -- 98
    do -- 98
        local i = 1 -- 99
        while i <= buttons do -- 99
            local circleButton = CircleButton({ -- 100
                text = options and tostring(i) or "Next", -- 101
                radius = 60, -- 102
                fontSize = 40 -- 103
            }):addTo(menu) -- 103
            circleButton:slot( -- 105
                "Tapped", -- 105
                function() -- 105
                    advance(nil, options) -- 106
                end -- 105
            ) -- 105
            i = i + 1 -- 99
        end -- 99
    end -- 99
    menu:alignItems() -- 109
end -- 95
advance = function(____, option) -- 112
    local action, result = runner:advance(option) -- 113
    if action == "Text" then -- 113
        local charName = "" -- 115
        if result.marks ~= nil then -- 115
            for ____, mark in ipairs(result.marks) do -- 117
                if mark.name == "char" and mark.attrs ~= nil then -- 117
                    charName = tostring(mark.attrs.name) .. ": " -- 119
                end -- 119
            end -- 119
        end -- 119
        texts[#texts + 1] = charName .. result.text -- 123
        if result.optionsFollowed then -- 123
            advance(nil) -- 125
        else -- 125
            setButtons(nil) -- 127
        end -- 127
    elseif action == "Option" then -- 127
        for i, op in ipairs(result) do -- 130
            if type(op) ~= "boolean" then -- 130
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 132
            end -- 132
        end -- 132
        setButtons(nil, #result) -- 135
    elseif action == "Command" then -- 135
        texts[#texts + 1] = result -- 137
        setButtons(nil) -- 138
    else -- 138
        menu:removeAllChildren() -- 140
        texts[#texts + 1] = result -- 141
    end -- 141
    if not label then -- 141
        return -- 143
    end -- 143
    label.text = table.concat(texts, "\n") -- 144
    scroll:adjustSizeWithAlign("Auto", 10) -- 145
    thread(function() -- 146
        scroll:scrollToPosY(label.y - label.height / 2) -- 147
    end) -- 146
end -- 112
advance(nil) -- 151
local testFilePaths = {testFile} -- 153
local testFileNames = {"Test/tutorial.yarn"} -- 154
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 155
    do -- 155
        if "yarn" ~= Path:getExt(file) then -- 155
            goto __continue29 -- 157
        end -- 157
        testFilePaths[#testFilePaths + 1] = Path(Content.writablePath, file) -- 159
        testFileNames[#testFileNames + 1] = Path:getFilename(file) -- 160
    end -- 160
    ::__continue29:: -- 160
end -- 160
local filteredPaths = testFilePaths -- 163
local filteredNames = testFileNames -- 164
local currentFile = 1 -- 166
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
    local ____App_visualSize_7 = App.visualSize -- 177
    local width = ____App_visualSize_7.width -- 177
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
            if ImGui.Button(zh and "筛选" or "Filter") then -- 193
                local filterText = string.lower(filterBuf.text) -- 195
                local filtered = __TS__ArrayFilter( -- 196
                    __TS__ArrayMap( -- 196
                        testFileNames, -- 196
                        function(____, n, i) return {n, testFilePaths[i + 1]} end -- 196
                    ), -- 196
                    function(____, it, i) -- 196
                        local matched = string.match( -- 197
                            string.lower(it[1]), -- 197
                            filterText -- 197
                        ) -- 197
                        if matched ~= nil then -- 197
                            return true -- 199
                        end -- 199
                        return false -- 201
                    end -- 196
                ) -- 196
                filteredNames = __TS__ArrayMap( -- 203
                    filtered, -- 203
                    function(____, f) return f[1] end -- 203
                ) -- 203
                filteredPaths = __TS__ArrayMap( -- 204
                    filtered, -- 204
                    function(____, f) return f[2] end -- 204
                ) -- 204
                currentFile = 1 -- 205
                if #filteredPaths > 0 then -- 205
                    runner = YarnRunner( -- 207
                        filteredPaths[currentFile], -- 207
                        "Start", -- 207
                        {}, -- 207
                        commands, -- 207
                        true -- 207
                    ) -- 207
                    texts = {} -- 208
                    advance(nil) -- 209
                end -- 209
            end -- 209
            local changed = false -- 212
            changed, currentFile = ImGui.Combo(zh and "文件" or "File", currentFile, filteredNames) -- 213
            if changed then -- 213
                runner = YarnRunner( -- 215
                    filteredPaths[currentFile], -- 215
                    "Start", -- 215
                    {}, -- 215
                    commands, -- 215
                    true -- 215
                ) -- 215
                texts = {} -- 216
                advance(nil) -- 217
            end -- 217
            ImGui.Text(zh and "变量" or "Variables") -- 219
            ImGui.Separator() -- 220
            for k, v in pairs(runner.state) do -- 221
                ImGui.Text((k .. ": ") .. tostring(v)) -- 222
            end -- 222
        end -- 180
    ) -- 180
    return false -- 225
end) -- 176
return ____exports -- 176