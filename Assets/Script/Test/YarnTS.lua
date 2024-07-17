-- [ts]: YarnTS.ts
local ____exports = {} -- 1
local advance -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 2
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 5
local YarnRunner = require("YarnRunner") -- 6
local ____Dora = require("Dora") -- 7
local AlignNode = ____Dora.AlignNode -- 7
local App = ____Dora.App -- 7
local Content = ____Dora.Content -- 7
local Label = ____Dora.Label -- 7
local Menu = ____Dora.Menu -- 7
local Path = ____Dora.Path -- 7
local Size = ____Dora.Size -- 7
local Vec2 = ____Dora.Vec2 -- 7
local View = ____Dora.View -- 7
local thread = ____Dora.thread -- 7
local threadLoop = ____Dora.threadLoop -- 7
local tolua = ____Dora.tolua -- 7
local ImGui = require("ImGui") -- 9
local testFile = Path(Content.assetPath, "Script", "Test", "tutorial.yarn") -- 11
local fontSize = math.floor(20 * App.devicePixelRatio) -- 13
local texts = {} -- 15
local root = AlignNode() -- 17
local ____View_size_0 = View.size -- 18
local viewWidth = ____View_size_0.width -- 18
local viewHeight = ____View_size_0.height -- 18
root:css(((("width: " .. tostring(viewWidth)) .. "; height: ") .. tostring(viewHeight)) .. "; flex-direction: column-reverse") -- 19
root:gslot( -- 20
    "AppSizeChanged", -- 20
    function() -- 20
        local ____View_size_1 = View.size -- 21
        local width = ____View_size_1.width -- 21
        local height = ____View_size_1.height -- 21
        root:css(((("width: " .. tostring(width)) .. "; height: ") .. tostring(height)) .. "; flex-direction: column-reverse") -- 22
    end -- 20
) -- 20
local width = viewWidth - 200 -- 25
local height = viewHeight - 20 -- 26
local scroll = ScrollArea({ -- 27
    width = width, -- 28
    height = height, -- 29
    paddingX = 0, -- 30
    paddingY = 50, -- 31
    viewWidth = height, -- 32
    viewHeight = height -- 33
}) -- 33
scroll:addTo(root) -- 35
local border = LineRect({width = width, height = height, color = 4294967295}) -- 37
scroll.area:addChild(border) -- 38
root:slot( -- 39
    "AlignLayout", -- 39
    function(w, h) -- 39
        scroll.position = Vec2(w / 2, h / 2) -- 40
        w = w - 200 -- 41
        h = h - 20 -- 42
        local ____tolua_cast_4 = tolua.cast -- 43
        local ____opt_2 = scroll.view.children -- 43
        local label = ____tolua_cast_4(____opt_2 and ____opt_2.first, "Label") -- 43
        if label ~= nil then -- 43
            label.textWidth = w - fontSize -- 45
        end -- 45
        scroll:adjustSizeWithAlign( -- 47
            "Auto", -- 47
            10, -- 47
            Size(w, h) -- 47
        ) -- 47
        scroll.area:removeChild(border) -- 48
        border = LineRect({width = w, height = h, color = 4294967295}) -- 49
        scroll.area:addChild(border) -- 50
    end -- 39
) -- 39
local ____opt_5 = Label("sarasa-mono-sc-regular", fontSize) -- 39
local label = ____opt_5 and ____opt_5:addTo(scroll.view) -- 52
if label then -- 52
    label.alignment = "Left" -- 54
    label.textWidth = width - fontSize -- 55
    label.text = "" -- 56
end -- 56
local control = AlignNode():addTo(root) -- 59
control:css("height: 140; margin-bottom: 40") -- 60
local menu = Menu():addTo(control) -- 62
control:slot( -- 63
    "AlignLayout", -- 63
    function(w, h) -- 63
        menu.position = Vec2(w / 2, h / 2) -- 64
    end -- 63
) -- 63
local commands = setmetatable( -- 67
    {}, -- 67
    {__index = function(____, name) return function(____, ...) -- 67
        local args = {...} -- 67
        local argStrs = {} -- 69
        do -- 69
            local i = 1 -- 70
            while i <= select("#", args) do -- 70
                argStrs[#argStrs + 1] = tostring({select(i, args)}) -- 71
                i = i + 1 -- 70
            end -- 70
        end -- 70
        local msg = (("[command]: " .. name) .. " ") .. table.concat(argStrs, ", ") -- 73
        coroutine.yield("Command", msg) -- 74
    end end} -- 68
) -- 68
local runner = YarnRunner( -- 78
    testFile, -- 78
    "Start", -- 78
    {}, -- 78
    commands, -- 78
    true -- 78
) -- 78
local function setButtons(____, options) -- 80
    menu:removeAllChildren() -- 81
    local buttons = options or 1 -- 82
    menu.size = Size(140 * buttons, 140) -- 83
    do -- 83
        local i = 1 -- 84
        while i <= buttons do -- 84
            local circleButton = CircleButton({ -- 85
                text = options and tostring(i) or "Next", -- 86
                radius = 60, -- 87
                fontSize = 40 -- 88
            }):addTo(menu) -- 88
            circleButton:slot( -- 90
                "Tapped", -- 90
                function() -- 90
                    advance(nil, options) -- 91
                end -- 90
            ) -- 90
            i = i + 1 -- 84
        end -- 84
    end -- 84
    menu:alignItems() -- 94
end -- 80
advance = function(____, option) -- 97
    local action, result = runner:advance(option) -- 98
    if action == "Text" then -- 98
        local charName = "" -- 100
        if result.marks ~= nil then -- 100
            for ____, mark in ipairs(result.marks) do -- 102
                if mark.name == "char" and mark.attrs ~= nil then -- 102
                    charName = tostring(mark.attrs.name) .. ": " -- 104
                end -- 104
            end -- 104
        end -- 104
        texts[#texts + 1] = charName .. result.text -- 108
        if result.optionsFollowed then -- 108
            advance(nil) -- 110
        else -- 110
            setButtons(nil) -- 112
        end -- 112
    elseif action == "Option" then -- 112
        for i, op in ipairs(result) do -- 115
            if type(op) ~= "boolean" then -- 115
                texts[#texts + 1] = (("[" .. tostring(i)) .. "]: ") .. op.text -- 117
            end -- 117
        end -- 117
        setButtons(nil, #result) -- 120
    elseif action == "Command" then -- 120
        texts[#texts + 1] = result -- 122
        setButtons(nil) -- 123
    else -- 123
        menu:removeAllChildren() -- 125
        texts[#texts + 1] = result -- 126
    end -- 126
    if not label then -- 126
        return -- 128
    end -- 128
    label.text = table.concat(texts, "\n") -- 129
    scroll:adjustSizeWithAlign("Auto", 10) -- 130
    thread(function() -- 131
        scroll:scrollToPosY(label.y - label.height / 2) -- 132
    end) -- 131
end -- 97
advance(nil) -- 136
local testFiles = {testFile} -- 138
local files = {testFile} -- 139
for ____, file in ipairs(Content:getAllFiles(Content.writablePath)) do -- 140
    do -- 140
        if "yarn" ~= Path:getExt(file) then -- 140
            goto __continue28 -- 142
        end -- 142
        testFiles[#testFiles + 1] = Path(Content.writablePath, file) -- 144
        files[#files + 1] = Path:getFilename(file) -- 145
    end -- 145
    ::__continue28:: -- 145
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
    local ____App_visualSize_7 = App.visualSize -- 157
    local width = ____App_visualSize_7.width -- 157
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
            ImGui.Text("Yarn Tester (Typescript)") -- 161
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