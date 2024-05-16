-- [ts]: YarnTS.ts
local ____exports = {} -- 1
local advance -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 2
local AlignNode = require("UI.Control.Basic.AlignNode") -- 3
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 5
local LineRect = require("UI.View.Shape.LineRect") -- 7
local YarnRunner = require("YarnRunner") -- 8
local ____Dora = require("Dora") -- 9
local App = ____Dora.App -- 9
local Content = ____Dora.Content -- 9
local Label = ____Dora.Label -- 9
local Menu = ____Dora.Menu -- 9
local Path = ____Dora.Path -- 9
local Size = ____Dora.Size -- 9
local Vec2 = ____Dora.Vec2 -- 9
local View = ____Dora.View -- 9
local thread = ____Dora.thread -- 9
local threadLoop = ____Dora.threadLoop -- 9
local tolua = ____Dora.tolua -- 9
local ImGui = require("ImGui") -- 11
local testFile = Path(Content.assetPath, "Script", "Test", "tutorial.yarn") -- 13
local ____View_size_0 = View.size -- 15
local viewWidth = ____View_size_0.width -- 15
local viewHeight = ____View_size_0.height -- 15
local width = viewWidth - 200 -- 17
local height = viewHeight - 20 -- 18
local fontSize = math.floor(20 * App.devicePixelRatio) -- 20
local texts = {} -- 22
local alignNode = AlignNode({isRoot = true, inUI = false}) -- 24
local root = AlignNode({alignWidth = "w", alignHeight = "h"}):addTo(alignNode) -- 25
local scroll = ScrollArea({ -- 26
    width = width, -- 27
    height = height, -- 28
    paddingX = 0, -- 29
    paddingY = 50, -- 30
    viewWidth = height, -- 31
    viewHeight = height -- 32
}) -- 32
scroll:addTo(root) -- 34
local border = LineRect({width = width, height = height, color = 4294967295}) -- 36
scroll.area:addChild(border) -- 37
scroll:slot( -- 38
    "AlignLayout", -- 38
    function(w, h) -- 38
        scroll.position = Vec2(w / 2, h / 2) -- 39
        w = w - 200 -- 40
        h = h - 20 -- 41
        local ____tolua_cast_3 = tolua.cast -- 42
        local ____opt_1 = scroll.view.children -- 42
        local label = ____tolua_cast_3(____opt_1 and ____opt_1.first, "Label") -- 42
        if label ~= nil then -- 42
            label.textWidth = w - fontSize -- 44
        end -- 44
        scroll:adjustSizeWithAlign( -- 46
            "Auto", -- 46
            10, -- 46
            Size(w, h) -- 46
        ) -- 46
        scroll.area:removeChild(border) -- 47
        border = LineRect({width = w, height = h, color = 4294967295}) -- 48
        scroll.area:addChild(border) -- 49
    end -- 38
) -- 38
local ____opt_4 = Label("sarasa-mono-sc-regular", fontSize) -- 38
local label = ____opt_4 and ____opt_4:addTo(scroll.view) -- 51
if label then -- 51
    label.alignment = "Left" -- 53
    label.textWidth = width - fontSize -- 54
    label.text = "" -- 55
end -- 55
local control = AlignNode({ -- 58
    hAlign = "Center", -- 59
    vAlign = "Bottom", -- 60
    alignOffset = Vec2(0, 200) -- 61
}):addTo(alignNode) -- 61
local commands = setmetatable( -- 64
    {}, -- 64
    {__index = function(____, name) return function(____, ...) -- 64
        local args = {...} -- 64
        local argStrs = {} -- 66
        do -- 66
            local i = 1 -- 67
            while i <= select("#", args) do -- 67
                argStrs[#argStrs + 1] = tostring({select(i, args)}) -- 68
                i = i + 1 -- 67
            end -- 67
        end -- 67
        local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 70
        coroutine.yield("Command", msg) -- 71
    end end} -- 65
) -- 65
local runner = YarnRunner( -- 75
    testFile, -- 75
    "Start", -- 75
    {}, -- 75
    commands, -- 75
    true -- 75
) -- 75
local menu = Menu():addTo(control) -- 77
local function setButtons(____, options) -- 79
    menu:removeAllChildren() -- 80
    local buttons = options or 1 -- 81
    menu.size = Size(140 * buttons, 140) -- 82
    do -- 82
        local i = 1 -- 83
        while i <= buttons do -- 83
            local circleButton = CircleButton({ -- 84
                text = options and tostring(i) or "Next", -- 85
                radius = 60, -- 86
                fontSize = 40 -- 87
            }):addTo(menu) -- 87
            circleButton:slot( -- 89
                "Tapped", -- 89
                function() -- 89
                    advance(nil, options) -- 90
                end -- 89
            ) -- 89
            i = i + 1 -- 83
        end -- 83
    end -- 83
    menu:alignItems() -- 93
end -- 79
advance = function(____, option) -- 96
    local action, result = runner:advance(option) -- 97
    if action == "Text" then -- 97
        local charName = "" -- 99
        if result.marks ~= nil then -- 99
            for ____, mark in ipairs(result.marks) do -- 101
                if mark.name == "char" and mark.attrs ~= nil then -- 101
                    charName = tostring(mark.attrs.name) .. ": " -- 103
                end -- 103
            end -- 103
        end -- 103
        texts[#texts + 1] = charName .. result.text -- 107
        if result.optionsFollowed then -- 107
            advance(nil) -- 109
        else -- 109
            setButtons(nil) -- 111
        end -- 111
    elseif action == "Option" then -- 111
        for i, op in ipairs(result) do -- 114
            if type(op) ~= "boolean" then -- 114
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 116
            end -- 116
        end -- 116
        setButtons(nil, #result) -- 119
    elseif action == "Command" then -- 119
        texts[#texts + 1] = result -- 121
        setButtons(nil) -- 122
    else -- 122
        menu:removeAllChildren() -- 124
        texts[#texts + 1] = result -- 125
    end -- 125
    if not label then -- 125
        return -- 127
    end -- 127
    label.text = table.concat(texts, "\n") -- 128
    root:alignLayout() -- 129
    thread(function() -- 130
        scroll:scrollToPosY(label.y - label.height / 2) -- 131
        return true -- 132
    end) -- 130
end -- 96
alignNode:alignLayout() -- 136
advance(nil) -- 137
local testFiles = {testFile} -- 139
local files = {testFile} -- 140
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 141
    do -- 141
        if "yarn" ~= Path:getExt(file) then -- 141
            goto __continue26 -- 143
        end -- 143
        testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 145
        files[#files + 1] = Path:getFilename(file) -- 146
    end -- 146
    ::__continue26:: -- 146
end -- 146
local currentFile = 1 -- 149
local windowFlags = { -- 150
    "NoDecoration", -- 151
    "NoSavedSettings", -- 152
    "NoFocusOnAppearing", -- 153
    "NoNav", -- 154
    "NoMove" -- 155
} -- 155
threadLoop(function() -- 157
    local ____App_visualSize_6 = App.visualSize -- 158
    local width = ____App_visualSize_6.width -- 158
    ImGui.SetNextWindowPos( -- 159
        Vec2(width - 10, 10), -- 159
        "Always", -- 159
        Vec2(1, 0) -- 159
    ) -- 159
    ImGui.SetNextWindowSize( -- 160
        Vec2(200, 0), -- 160
        "Always" -- 160
    ) -- 160
    ImGui.Begin( -- 161
        "Yarn Test", -- 161
        windowFlags, -- 161
        function() -- 161
            ImGui.Text("Yarn Tester (Typescript)") -- 162
            ImGui.Separator() -- 163
            local changed = false -- 164
            changed, currentFile = ImGui.Combo("File", currentFile, files) -- 165
            if changed then -- 165
                runner = YarnRunner( -- 167
                    testFiles[currentFile + 1], -- 167
                    "Start", -- 167
                    {}, -- 167
                    commands, -- 167
                    true -- 167
                ) -- 167
                texts = {} -- 168
                advance(nil) -- 169
            end -- 169
            ImGui.Text("Variables") -- 171
            ImGui.Separator() -- 172
            for k, v in pairs(runner.state) do -- 173
                ImGui.Text((k .. ": ") .. tostring(v)) -- 174
            end -- 174
        end -- 161
    ) -- 161
    return false -- 177
end) -- 157
return ____exports -- 157