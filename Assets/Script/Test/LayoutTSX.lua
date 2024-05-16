-- [tsx]: LayoutTSX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Vec2 = ____Dora.Vec2 -- 3
local threadLoop = ____Dora.threadLoop -- 3
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
        "App", -- 21
        React:createElement( -- 21
            "align-node", -- 21
            {style = {width = 250, height = 475, padding = 10}, showDebug = true}, -- 21
            React:createElement( -- 21
                "align-node", -- 21
                {style = {flex = 1, gap = {10, 0}}, showDebug = true}, -- 21
                React:createElement("align-node", {style = {height = 60}, showDebug = true}), -- 21
                React:createElement("align-node", {style = {flex = 1, margin = 10}, showDebug = true}), -- 21
                React:createElement("align-node", {style = {flex = 2, margin = 10}, showDebug = true}), -- 21
                React:createElement( -- 21
                    "align-node", -- 21
                    {showDebug = true, style = { -- 21
                        position = "absolute", -- 29
                        width = "100%", -- 30
                        bottom = 0, -- 31
                        height = 64, -- 32
                        flexDirection = "row", -- 33
                        alignItems = "center", -- 34
                        justifyContent = "space-around" -- 35
                    }}, -- 35
                    React:createElement("align-node", {style = {height = 40, width = 40}, showDebug = true}), -- 35
                    React:createElement("align-node", {style = {height = 40, width = 40}, showDebug = true}), -- 35
                    React:createElement("align-node", {style = {height = 40, width = 40}, showDebug = true}), -- 35
                    React:createElement("align-node", {style = {height = 40, width = 40}, showDebug = true}) -- 35
                ) -- 35
            ) -- 35
        ) -- 35
    ), -- 35
    Test( -- 47
        "Align Content", -- 47
        React:createElement( -- 47
            "align-node", -- 47
            {showDebug = true, style = { -- 47
                width = 200, -- 50
                height = 250, -- 51
                padding = 10, -- 52
                alignContent = "flex-start", -- 53
                flexWrap = "wrap" -- 54
            }}, -- 54
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 54
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 54
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 54
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 54
        ) -- 54
    ), -- 54
    Test( -- 63
        "Align Items", -- 63
        React:createElement( -- 63
            "align-node", -- 63
            {showDebug = true, style = {width = 200, height = 250, padding = 10, alignItems = "flex-start"}}, -- 63
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 50, width = 50, alignSelf = "center"}}), -- 63
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 63
        ) -- 63
    ), -- 63
    Test( -- 83
        "Aspect Ratio", -- 83
        React:createElement( -- 83
            "align-node", -- 83
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 83
            React:createElement("align-node", {style = {margin = 5, height = 50, aspectRatio = 1}, showDebug = true}), -- 83
            React:createElement("align-node", {style = {margin = 5, height = 50, aspectRatio = 1.5}, showDebug = true}) -- 83
        ) -- 83
    ), -- 83
    Test( -- 95
        "Display", -- 95
        React:createElement( -- 95
            "align-node", -- 95
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 95
            React:createElement("align-node", {style = {margin = 5, height = 50, display = "none"}, showDebug = true}), -- 95
            React:createElement("align-node", {style = {margin = 5, height = 50, display = "flex"}, showDebug = true}) -- 95
        ) -- 95
    ), -- 95
    Test( -- 107
        "Flex Basis, Grow, and Shrink", -- 107
        React:createElement( -- 107
            React.Fragment, -- 107
            nil, -- 107
            React:createElement( -- 107
                "align-node", -- 107
                {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 107
                React:createElement("align-node", {style = {margin = 5, flexBasis = 50}, showDebug = true}) -- 107
            ), -- 107
            React:createElement( -- 107
                "align-node", -- 107
                {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 107
                React:createElement("align-node", {style = {margin = 5, flexGrow = 0.25}, showDebug = true}), -- 107
                React:createElement("align-node", {style = {margin = 5, flexGrow = 0.75}, showDebug = true}) -- 107
            ), -- 107
            React:createElement( -- 107
                "align-node", -- 107
                {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 107
                React:createElement("align-node", {style = {margin = 5, flexShrink = 5, height = 150}, showDebug = true}), -- 107
                React:createElement("align-node", {style = {margin = 5, flexShrink = 10, height = 150}, showDebug = true}) -- 107
            ) -- 107
        ) -- 107
    ), -- 107
    Test( -- 140
        "Flex Direction", -- 140
        React:createElement( -- 140
            "align-node", -- 140
            {showDebug = true, style = {width = 200, height = 200, padding = 10, flexDirection = "column"}}, -- 140
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 140
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 140
        ) -- 140
    ), -- 140
    Test( -- 153
        "Flex Wrap", -- 153
        React:createElement( -- 153
            "align-node", -- 153
            {showDebug = true, style = {width = 200, height = 150, padding = 10, flexWrap = "wrap"}}, -- 153
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 153
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 153
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 153
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 153
        ) -- 153
    ), -- 153
    Test( -- 168
        "Gap", -- 168
        React:createElement( -- 168
            "align-node", -- 168
            {showDebug = true, style = { -- 168
                width = 200, -- 171
                height = 250, -- 172
                padding = 10, -- 173
                flexWrap = "wrap", -- 174
                gap = 10 -- 175
            }}, -- 175
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 175
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 175
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 175
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}), -- 175
            React:createElement("align-node", {style = {height = 50, width = 50}, showDebug = true}) -- 175
        ) -- 175
    ), -- 175
    Test( -- 185
        "Insets", -- 185
        React:createElement( -- 185
            "align-node", -- 185
            {showDebug = true, style = {width = 200, height = 200}}, -- 185
            React:createElement("align-node", {showDebug = true, style = {height = 50, width = 50, top = 50, left = 50}}) -- 185
        ) -- 185
    ), -- 185
    Test( -- 202
        "Justify Content", -- 202
        React:createElement( -- 202
            "align-node", -- 202
            {showDebug = true, style = {width = 200, height = 200, padding = 10, justifyContent = "flex-end"}}, -- 202
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 202
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 202
        ) -- 202
    ), -- 202
    Test( -- 215
        "Layout Direction", -- 215
        React:createElement( -- 215
            "align-node", -- 215
            {showDebug = true, style = {width = 200, height = 200, padding = 10, direction = "rtl"}}, -- 215
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}), -- 215
            React:createElement("align-node", {style = {margin = 5, height = 50, width = 50}, showDebug = true}) -- 215
        ) -- 215
    ), -- 215
    Test( -- 228
        "Margin, Padding, and Border", -- 228
        React:createElement( -- 228
            "align-node", -- 228
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 228
            React:createElement("align-node", {showDebug = true, style = {margin = 5, padding = 20, border = 20, height = 50}}), -- 228
            React:createElement("align-node", {style = {height = 50}, showDebug = true}) -- 228
        ) -- 228
    ), -- 228
    Test( -- 247
        "Position", -- 247
        React:createElement( -- 247
            "align-node", -- 247
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 247
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 50, top = 20, position = "relative"}}) -- 247
        ) -- 247
    ), -- 247
    Test( -- 265
        "Min/Max Width and Height", -- 265
        React:createElement( -- 265
            "align-node", -- 265
            {showDebug = true, style = {width = 200, height = 250, margin = 20, padding = 10}}, -- 265
            React:createElement("align-node", {style = {margin = 5, height = 25}, showDebug = true}), -- 265
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 100, maxHeight = 25}}), -- 265
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 25, minHeight = 50}}), -- 265
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 25, maxWidth = 25}}), -- 265
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = 25, width = 25, minWidth = 50}}) -- 265
        ) -- 265
    ), -- 265
    Test( -- 306
        "Width and Height", -- 306
        React:createElement( -- 306
            "align-node", -- 306
            {showDebug = true, style = {width = 200, height = 200, padding = 10}}, -- 306
            React:createElement("align-node", {showDebug = true, style = {margin = 5, height = "50%", width = "65%"}}) -- 306
        ) -- 306
    ) -- 306
} -- 306
tests[1]:test() -- 324
local testNames = __TS__ArrayMap( -- 326
    tests, -- 326
    function(____, t) return t.name end -- 326
) -- 326
local currentTest = 1 -- 328
local windowFlags = { -- 329
    "NoDecoration", -- 330
    "NoSavedSettings", -- 331
    "NoFocusOnAppearing", -- 332
    "NoNav", -- 333
    "NoMove" -- 334
} -- 334
threadLoop(function() -- 336
    local ____App_visualSize_0 = App.visualSize -- 337
    local width = ____App_visualSize_0.width -- 337
    ImGui.SetNextWindowPos( -- 338
        Vec2(width - 10, 10), -- 338
        "Always", -- 338
        Vec2(1, 0) -- 338
    ) -- 338
    ImGui.SetNextWindowSize( -- 339
        Vec2(200, 0), -- 339
        "Always" -- 339
    ) -- 339
    ImGui.Begin( -- 340
        "Layout", -- 340
        windowFlags, -- 340
        function() -- 340
            ImGui.Text("Layout (TSX)") -- 341
            ImGui.Separator() -- 342
            local changed = false -- 343
            changed, currentTest = ImGui.Combo("Test", currentTest, testNames) -- 344
            if changed then -- 344
                if current then -- 344
                    current:removeFromParent() -- 347
                end -- 347
                tests[currentTest]:test() -- 349
            end -- 349
        end -- 340
    ) -- 340
    return false -- 352
end) -- 336
return ____exports -- 336