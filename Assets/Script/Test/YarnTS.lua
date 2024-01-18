-- [ts]: YarnTS.ts
local ____exports = {} -- 1
local advance -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 1
local AlignNode = require("UI.Control.Basic.AlignNode") -- 2
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 4
local LineRect = require("UI.View.Shape.LineRect") -- 6
local YarnRunner = require("YarnRunner") -- 7
local ____dora = require("dora") -- 8
local App = ____dora.App -- 8
local Content = ____dora.Content -- 8
local Label = ____dora.Label -- 8
local Menu = ____dora.Menu -- 8
local Path = ____dora.Path -- 8
local Size = ____dora.Size -- 8
local Vec2 = ____dora.Vec2 -- 8
local View = ____dora.View -- 8
local thread = ____dora.thread -- 8
local threadLoop = ____dora.threadLoop -- 8
local tolua = ____dora.tolua -- 8
local ImGui = require("ImGui") -- 10
local testFile = Path("Test", "tutorial.yarn") -- 12
local ____View_size_0 = View.size -- 14
local viewWidth = ____View_size_0.width -- 14
local viewHeight = ____View_size_0.height -- 14
local width = viewWidth - 200 -- 16
local height = viewHeight - 20 -- 17
local fontSize = math.floor(20 * App.devicePixelRatio) -- 19
local texts = {} -- 21
local alignNode = AlignNode({isRoot = true, inUI = false}) -- 23
local root = AlignNode({alignWidth = "w", alignHeight = "h"}):addTo(alignNode) -- 24
local scroll = ScrollArea({ -- 25
    width = width, -- 26
    height = height, -- 27
    paddingX = 0, -- 28
    paddingY = 50, -- 29
    viewWidth = height, -- 30
    viewHeight = height -- 31
}) -- 31
scroll:addTo(root) -- 33
local border = LineRect({width = width, height = height, color = 4294967295}) -- 35
scroll.area:addChild(border) -- 36
scroll:slot( -- 37
    "AlignLayout", -- 37
    function(w, h) -- 37
        scroll.position = Vec2(w / 2, h / 2) -- 38
        w = w - 200 -- 39
        h = h - 20 -- 40
        local label = tolua.cast(scroll.view.children.first, "Label") -- 41
        if label ~= nil then -- 41
            label.textWidth = w - fontSize -- 43
        end -- 43
        scroll:adjustSizeWithAlign( -- 45
            "Auto", -- 45
            10, -- 45
            Size(w, h) -- 45
        ) -- 45
        scroll.area:removeChild(border) -- 46
        border = LineRect({width = w, height = h, color = 4294967295}) -- 47
        scroll.area:addChild(border) -- 48
    end -- 37
) -- 37
local ____opt_1 = Label("sarasa-mono-sc-regular", fontSize) -- 37
local label = ____opt_1 and ____opt_1:addTo(scroll.view) -- 50
if label then -- 50
    label.alignment = "Left" -- 52
    label.textWidth = width - fontSize -- 53
    label.text = "" -- 54
end -- 54
local control = AlignNode({ -- 57
    hAlign = "Center", -- 58
    vAlign = "Bottom", -- 59
    alignOffset = Vec2(0, 200) -- 60
}):addTo(alignNode) -- 60
local commands = setmetatable( -- 63
    {}, -- 63
    {__index = function(____, name) return function(____, ...) -- 63
        local args = {...} -- 63
        local argStrs = {} -- 65
        do -- 65
            local i = 1 -- 66
            while i <= select("#", args) do -- 66
                argStrs[#argStrs + 1] = tostring({select(i, args)}) -- 67
                i = i + 1 -- 66
            end -- 66
        end -- 66
        local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 69
        coroutine.yield("Command", msg) -- 70
    end end} -- 64
) -- 64
local runner = YarnRunner( -- 74
    testFile, -- 74
    "Start", -- 74
    {}, -- 74
    commands, -- 74
    true -- 74
) -- 74
local menu = Menu():addTo(control) -- 76
local function setButtons(____, options) -- 78
    menu:removeAllChildren() -- 79
    local buttons = options or 1 -- 80
    menu.size = Size(140 * buttons, 140) -- 81
    do -- 81
        local i = 1 -- 82
        while i <= buttons do -- 82
            local circleButton = CircleButton({ -- 83
                text = options and tostring(i) or "Next", -- 84
                radius = 60, -- 85
                fontSize = 40 -- 86
            }):addTo(menu) -- 86
            circleButton:slot( -- 88
                "Tapped", -- 88
                function() -- 88
                    advance(nil, options) -- 89
                end -- 88
            ) -- 88
            i = i + 1 -- 82
        end -- 82
    end -- 82
    menu:alignItems() -- 92
end -- 78
advance = function(____, option) -- 95
    local action, result = runner:advance(option) -- 96
    if action == "Text" then -- 96
        local charName = "" -- 98
        if result.marks ~= nil then -- 98
            for ____, mark in ipairs(result.marks) do -- 100
                if mark.name == "char" and mark.attrs ~= nil then -- 100
                    charName = tostring(mark.attrs.name) .. ": " -- 102
                end -- 102
            end -- 102
        end -- 102
        texts[#texts + 1] = charName .. result.text -- 106
        if result.optionsFollowed then -- 106
            advance(nil) -- 108
        else -- 108
            setButtons(nil) -- 110
        end -- 110
    elseif action == "Option" then -- 110
        for i, op in ipairs(result) do -- 113
            if type(op) ~= "boolean" then -- 113
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 115
            end -- 115
        end -- 115
        setButtons(nil, #result) -- 118
    elseif action == "Command" then -- 118
        texts[#texts + 1] = result -- 120
        setButtons(nil) -- 121
    else -- 121
        menu:removeAllChildren() -- 123
        texts[#texts + 1] = result -- 124
    end -- 124
    if not label then -- 124
        return -- 126
    end -- 126
    label.text = table.concat(texts, "\n") -- 127
    root:alignLayout() -- 128
    thread(function() -- 129
        scroll:scrollToPosY(label.y - label.height / 2) -- 130
        return true -- 131
    end) -- 129
end -- 95
alignNode:alignLayout() -- 135
advance(nil) -- 136
local testFiles = {testFile} -- 138
local files = {testFile} -- 139
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 140
    do -- 140
        if "yarn" ~= Path:getExt(file) then -- 140
            goto __continue26 -- 142
        end -- 142
        testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 144
        files[#files + 1] = Path:getFilename(file) -- 145
    end -- 145
    ::__continue26:: -- 145
end -- 145
local currentFile = 1 -- 148
local windowFlags = { -- 149
    "NoDecoration", -- 150
    "NoSavedSettings", -- 151
    "NoFocusOnAppearing", -- 152
    "NoNav", -- 153
    "NoMove" -- 154
} -- 154
threadLoop(function() -- 156
    local ____App_visualSize_3 = App.visualSize -- 157
    local width = ____App_visualSize_3.width -- 157
    ImGui.SetNextWindowPos( -- 158
        Vec2(width - 10, 10), -- 158
        "Always", -- 158
        Vec2(1, 0) -- 158
    ) -- 158
    ImGui.SetNextWindowSize( -- 159
        Vec2(200, 0), -- 159
        "Always" -- 159
    ) -- 159
    ImGui.Begin( -- 160
        "Yarn Test", -- 160
        windowFlags, -- 160
        function() -- 160
            ImGui.Text("Yarn Tester") -- 161
            ImGui.Separator() -- 162
            local changed = false -- 163
            changed, currentFile = ImGui.Combo("File", currentFile, files) -- 164
            if changed then -- 164
                runner = YarnRunner( -- 166
                    testFiles[currentFile + 1], -- 166
                    "Start", -- 166
                    {}, -- 166
                    commands, -- 166
                    true -- 166
                ) -- 166
                texts = {} -- 167
                advance(nil) -- 168
            end -- 168
            ImGui.Text("Variables") -- 170
            ImGui.Separator() -- 171
            for k, v in pairs(runner.state) do -- 172
                ImGui.Text((k .. ": ") .. tostring(v)) -- 173
            end -- 173
        end -- 160
    ) -- 160
    return false -- 176
end) -- 156
return ____exports -- 156