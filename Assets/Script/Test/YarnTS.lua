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
local label = Label("sarasa-mono-sc-regular", fontSize):addTo(scroll.view) -- 50
label.alignment = "Left" -- 51
label.textWidth = width - fontSize -- 52
label.text = "" -- 53
local control = AlignNode({ -- 55
    hAlign = "Center", -- 56
    vAlign = "Bottom", -- 57
    alignOffset = Vec2(0, 200) -- 58
}):addTo(alignNode) -- 58
local commands = setmetatable( -- 61
    {}, -- 61
    {__index = function(____, name) return function(____, ...) -- 61
        local args = {...} -- 61
        local argStrs = {} -- 63
        do -- 63
            local i = 1 -- 64
            while i <= select("#", args) do -- 64
                argStrs[#argStrs + 1] = tostring({select(i, args)}) -- 65
                i = i + 1 -- 64
            end -- 64
        end -- 64
        local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 67
        coroutine.yield("Command", msg) -- 68
    end end} -- 62
) -- 62
local runner = YarnRunner( -- 72
    testFile, -- 72
    "Start", -- 72
    {}, -- 72
    commands, -- 72
    true -- 72
) -- 72
local menu = Menu():addTo(control) -- 74
local function setButtons(____, options) -- 76
    menu:removeAllChildren() -- 77
    local buttons = options or 1 -- 78
    menu.size = Size(140 * buttons, 140) -- 79
    do -- 79
        local i = 1 -- 80
        while i <= buttons do -- 80
            local circleButton = CircleButton({ -- 81
                text = options and tostring(i) or "Next", -- 82
                radius = 60, -- 83
                fontSize = 40 -- 84
            }):addTo(menu) -- 84
            circleButton:slot( -- 86
                "Tapped", -- 86
                function() -- 86
                    advance(nil, options) -- 87
                end -- 86
            ) -- 86
            i = i + 1 -- 80
        end -- 80
    end -- 80
    menu:alignItems() -- 90
end -- 76
advance = function(____, option) -- 93
    local action, result = runner:advance(option) -- 94
    if action == "Text" then -- 94
        local charName = "" -- 96
        if result.marks ~= nil then -- 96
            for ____, mark in ipairs(result.marks) do -- 98
                if mark.name == "char" and mark.attrs ~= nil then -- 98
                    charName = tostring(mark.attrs.name) .. ": " -- 100
                end -- 100
            end -- 100
        end -- 100
        texts[#texts + 1] = charName .. result.text -- 104
        if result.optionsFollowed then -- 104
            advance(nil) -- 106
        else -- 106
            setButtons(nil) -- 108
        end -- 108
    elseif action == "Option" then -- 108
        for i, op in ipairs(result) do -- 111
            if type(op) ~= "boolean" then -- 111
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 113
            end -- 113
        end -- 113
        setButtons(nil, #result) -- 116
    elseif action == "Command" then -- 116
        texts[#texts + 1] = result -- 118
        setButtons(nil) -- 119
    else -- 119
        menu:removeAllChildren() -- 121
        texts[#texts + 1] = result -- 122
    end -- 122
    label.text = table.concat(texts, "\n") -- 124
    root:alignLayout() -- 125
    thread(function() -- 126
        scroll:scrollToPosY(label.y - label.height / 2) -- 127
        return true -- 128
    end) -- 126
end -- 93
alignNode:alignLayout() -- 132
advance(nil) -- 133
local testFiles = {testFile} -- 135
local files = {testFile} -- 136
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 137
    do -- 137
        if "yarn" ~= Path:getExt(file) then -- 137
            goto __continue24 -- 139
        end -- 139
        testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 141
        files[#files + 1] = Path:getFilename(file) -- 142
    end -- 142
    ::__continue24:: -- 142
end -- 142
local currentFile = 1 -- 145
local windowFlags = { -- 146
    "NoDecoration", -- 147
    "NoSavedSettings", -- 148
    "NoFocusOnAppearing", -- 149
    "NoNav", -- 150
    "NoMove" -- 151
} -- 151
threadLoop(function() -- 153
    local ____App_visualSize_1 = App.visualSize -- 154
    local width = ____App_visualSize_1.width -- 154
    ImGui.SetNextWindowPos( -- 155
        Vec2(width - 10, 10), -- 155
        "Always", -- 155
        Vec2(1, 0) -- 155
    ) -- 155
    ImGui.SetNextWindowSize( -- 156
        Vec2(200, 0), -- 156
        "Always" -- 156
    ) -- 156
    ImGui.Begin( -- 157
        "Yarn Test", -- 157
        windowFlags, -- 157
        function() -- 157
            ImGui.Text("Yarn Tester") -- 158
            ImGui.Separator() -- 159
            local changed = false -- 160
            changed, currentFile = ImGui.Combo("File", currentFile, files) -- 161
            if changed then -- 161
                runner = YarnRunner( -- 163
                    testFiles[currentFile + 1], -- 163
                    "Start", -- 163
                    {}, -- 163
                    commands, -- 163
                    true -- 163
                ) -- 163
                texts = {} -- 164
                advance(nil) -- 165
            end -- 165
            ImGui.Text("Variables") -- 167
            ImGui.Separator() -- 168
            for k, v in pairs(runner.state) do -- 169
                ImGui.Text((k .. ": ") .. tostring(v)) -- 170
            end -- 170
        end -- 157
    ) -- 157
    return false -- 173
end) -- 153
return ____exports -- 153