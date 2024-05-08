-- [tsx]: LayoutTSX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____dora_2Dx = require("dora-x") -- 2
local React = ____dora_2Dx.React -- 2
local toNode = ____dora_2Dx.toNode -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local ImGui = require("ImGui") -- 5
local current = nil -- 7
local function Test(name, jsx) -- 9
    return { -- 10
        name = name, -- 10
        test = function() -- 10
            current = toNode(React:createElement("align-node", {windowRoot = true, style = {padding = 10, flexDirection = "row"}}, jsx)) -- 11
        end -- 10
    } -- 10
end -- 9
local tests = { -- 19
    Test( -- 21
        "Align Content", -- 21
        React:createElement( -- 21
            "align-node", -- 21
            {showDebug = true, style = { -- 21
                width = 200, -- 24
                height = 250, -- 25
                padding = 10, -- 26
                alignContent = "flex-start", -- 27
                flexWrap = "wrap" -- 28
            }}, -- 28
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 28
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 28
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 28
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 28
        ) -- 28
    ), -- 28
    Test( -- 37
        "Align Items", -- 37
        React:createElement( -- 37
            "align-node", -- 37
            {showDebug = true, style = {width = 200, height = 250, padding = 10, alignItems = "flex-start"}}, -- 37
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 50, width = 50, alignSelf = "center"}}), -- 37
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 37
        ) -- 37
    ), -- 37
    Test( -- 57
        "Aspect Ratio", -- 57
        React:createElement( -- 57
            "align-node", -- 57
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 57
            React:createElement("align-node", {style = {margin = 5, height = 50, aspectRatio = 1}, showDebug = true}), -- 57
            React:createElement("align-node", {style = {margin = 5, height = 50, aspectRatio = 1.5}, showDebug = true}) -- 57
        ) -- 57
    ), -- 57
    Test( -- 69
        "Display", -- 69
        React:createElement( -- 69
            "align-node", -- 69
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 69
            React:createElement("align-node", {style = {margin = 5, height = 50, display = "none"}, showDebug = true}), -- 69
            React:createElement("align-node", {style = {margin = 5, height = 50, display = "flex"}, showDebug = true}) -- 69
        ) -- 69
    ), -- 69
    Test( -- 81
        "Flex Basis, Grow, and Shrink", -- 81
        React:createElement( -- 81
            React.Fragment, -- 81
            nil, -- 81
            React:createElement( -- 81
                "align-node", -- 81
                {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 81
                React:createElement("align-node", {style = {margin = 5, flexBasis = 50}, showDebug = true}) -- 81
            ), -- 81
            React:createElement( -- 81
                "align-node", -- 81
                {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 81
                React:createElement("align-node", {style = {margin = 5, flexGrow = 0.25}, showDebug = true}), -- 81
                React:createElement("align-node", {style = {margin = 5, flexGrow = 0.75}, showDebug = true}) -- 81
            ), -- 81
            React:createElement( -- 81
                "align-node", -- 81
                {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 81
                React:createElement("align-node", {style = {margin = 5, flexShrink = 5, height = 150}, showDebug = true}), -- 81
                React:createElement("align-node", {style = {margin = 5, flexShrink = 10, height = 150}, showDebug = true}) -- 81
            ) -- 81
        ) -- 81
    ), -- 81
    Test( -- 114
        "Flex Direction", -- 114
        React:createElement( -- 114
            "align-node", -- 114
            {showDebug = true, style = {width = 200, height = 200, padding = 10, flexDirection = "column"}}, -- 114
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 114
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 114
        ) -- 114
    ), -- 114
    Test( -- 127
        "Flex Wrap", -- 127
        React:createElement( -- 127
            "align-node", -- 127
            {showDebug = true, style = {width = 200, height = 150, padding = 10, flexWrap = "wrap"}}, -- 127
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 127
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 127
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 127
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 127
        ) -- 127
    ), -- 127
    Test( -- 142
        "Gap", -- 142
        React:createElement( -- 142
            "align-node", -- 142
            {showDebug = true, style = { -- 142
                width = 200, -- 145
                height = 250, -- 146
                padding = 10, -- 147
                flexWrap = "wrap", -- 148
                gap = 10 -- 149
            }}, -- 149
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 149
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 149
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 149
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 149
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}) -- 149
        ) -- 149
    ), -- 149
    Test( -- 159
        "Insets", -- 159
        React:createElement( -- 159
            "align-node", -- 159
            {showDebug = true, style = {width = 200, height = 200}}, -- 159
            React:createElement("align-node", {showDebug = true, style = {height = 50, width = 50, top = 50, left = 50}}) -- 159
        ) -- 159
    ), -- 159
    Test( -- 176
        "Justify Content", -- 176
        React:createElement( -- 176
            "align-node", -- 176
            {showDebug = true, style = {width = 200, height = 200, padding = 10, justifyContent = "flex-end"}}, -- 176
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 176
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 176
        ) -- 176
    ), -- 176
    Test( -- 189
        "Layout Direction", -- 189
        React:createElement( -- 189
            "align-node", -- 189
            {showDebug = true, style = {width = 200, height = 200, padding = 10, direction = "rtl"}}, -- 189
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 189
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 189
        ) -- 189
    ), -- 189
    Test( -- 202
        "Margin, Padding, and Border", -- 202
        React:createElement( -- 202
            "align-node", -- 202
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 202
            React:createElement("align-node", {showDebug = true, style = {margin = 5, padding = 20, border = 20, height = 50}}), -- 202
            React:createElement("align-node", {style = {height = 50}, showDebug = true}) -- 202
        ) -- 202
    ), -- 202
    Test( -- 221
        "Position", -- 221
        React:createElement( -- 221
            "align-node", -- 221
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 221
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 50, top = 20, position = "relative"}}) -- 221
        ) -- 221
    ), -- 221
    Test( -- 239
        "Min/Max Width and Height", -- 239
        React:createElement( -- 239
            "align-node", -- 239
            {showDebug = true, style = {width = 200, height = 250, margin = 20, padding = 10}}, -- 239
            React:createElement("align-node", {style = {margin = 5, height = 25}, showDebug = true}), -- 239
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 100, maxHeight = 25}}), -- 239
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 25, minHeight = 50}}), -- 239
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 25, maxWidth = 25}}), -- 239
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 25, width = 25, minWidth = 50}}) -- 239
        ) -- 239
    ), -- 239
    Test( -- 280
        "Width and Height", -- 280
        React:createElement( -- 280
            "align-node", -- 280
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 280
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = "50%", width = "65%"}}) -- 280
        ) -- 280
    ) -- 280
} -- 280
tests[1]:test() -- 298
local testNames = __TS__ArrayMap( -- 300
    tests, -- 300
    function(____, t) return t.name end -- 300
) -- 300
local currentTest = 1 -- 302
local windowFlags = { -- 303
    "NoDecoration", -- 304
    "NoSavedSettings", -- 305
    "NoFocusOnAppearing", -- 306
    "NoNav", -- 307
    "NoMove" -- 308
} -- 308
threadLoop(function() -- 310
    local ____App_visualSize_0 = App.visualSize -- 311
    local width = ____App_visualSize_0.width -- 311
    ImGui.SetNextWindowPos( -- 312
        Vec2(width - 10, 10), -- 312
        "Always", -- 312
        Vec2(1, 0) -- 312
    ) -- 312
    ImGui.SetNextWindowSize( -- 313
        Vec2(200, 0), -- 313
        "Always" -- 313
    ) -- 313
    ImGui.Begin( -- 314
        "Layout", -- 314
        windowFlags, -- 314
        function() -- 314
            ImGui.Text("Layout (TSX)") -- 315
            ImGui.Separator() -- 316
            local changed = false -- 317
            changed, currentTest = ImGui.Combo("Test", currentTest, testNames) -- 318
            if changed then -- 318
                if current then -- 318
                    current:removeFromParent() -- 321
                end -- 321
                tests[currentTest]:test() -- 323
            end -- 323
        end -- 314
    ) -- 314
    return false -- 326
end) -- 310
return ____exports -- 310