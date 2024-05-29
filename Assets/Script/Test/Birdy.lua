-- [tsx]: Birdy.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ParseFloat = ____lualib.__TS__ParseFloat -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
local Ease = ____Dora.Ease -- 3
local Line = ____Dora.Line -- 3
local Scale = ____Dora.Scale -- 3
local Vec2 = ____Dora.Vec2 -- 3
local tolua = ____Dora.tolua -- 3
toNode(React:createElement("sprite", {file = "Image/logo.png", scaleX = 0.2, scaleY = 0.2})) -- 5
local function Box(____, props) -- 14
    local numText = tostring(props.num) -- 15
    return React:createElement( -- 16
        "body", -- 16
        { -- 16
            type = "Dynamic", -- 16
            scaleX = 0, -- 16
            scaleY = 0, -- 16
            x = props.x, -- 16
            y = props.y, -- 16
            tag = numText -- 16
        }, -- 16
        React:createElement("rect-fixture", {width = 100, height = 100}), -- 16
        React:createElement( -- 16
            "draw-node", -- 16
            nil, -- 16
            React:createElement("rect-shape", { -- 16
                width = 100, -- 16
                height = 100, -- 16
                fillColor = 2281766911, -- 16
                borderWidth = 1, -- 16
                borderColor = 4278255615 -- 16
            }) -- 16
        ), -- 16
        React:createElement("label", {fontName = "sarasa-mono-sc-regular", fontSize = 40}, numText), -- 16
        props.children -- 23
    ) -- 23
end -- 14
local bird = useRef() -- 28
local score = useRef() -- 29
local start = Vec2.zero -- 31
local delta = Vec2.zero -- 32
local line = Line() -- 34
toNode(React:createElement( -- 36
    "physics-world", -- 36
    { -- 36
        onTapBegan = function(touch) -- 36
            start = touch.location -- 39
            line:clear() -- 40
        end, -- 38
        onTapMoved = function(touch) -- 38
            delta = delta:add(touch.delta) -- 43
            line:set({ -- 44
                start, -- 44
                start:add(delta) -- 44
            }) -- 44
        end, -- 42
        onTapEnded = function() -- 42
            if not bird.current then -- 42
                return -- 47
            end -- 47
            bird.current.velocity = delta:mul(Vec2(10, 10)) -- 48
            start = Vec2.zero -- 49
            delta = Vec2.zero -- 50
            line:clear() -- 51
        end -- 46
    }, -- 46
    React:createElement( -- 46
        "body", -- 46
        {type = "Static"}, -- 46
        React:createElement("rect-fixture", {centerY = -200, width = 2000, height = 10}), -- 46
        React:createElement( -- 46
            "draw-node", -- 46
            nil, -- 46
            React:createElement("rect-shape", {centerY = -200, width = 2000, height = 10, fillColor = 4294689792}) -- 46
        ) -- 46
    ), -- 46
    __TS__ArrayMap( -- 62
        { -- 62
            10, -- 62
            20, -- 62
            30, -- 62
            40, -- 62
            50 -- 62
        }, -- 62
        function(____, num, i) return React:createElement( -- 62
            Box, -- 63
            {num = num, x = 200, y = -150 + i * 100}, -- 63
            React:createElement( -- 63
                "sequence", -- 63
                nil, -- 63
                React:createElement("delay", {time = i * 0.2}), -- 63
                React:createElement("scale", {time = 0.3, start = 0, stop = 1}) -- 63
            ) -- 63
        ) end -- 63
    ), -- 63
    React:createElement( -- 63
        "body", -- 63
        { -- 63
            ref = bird, -- 63
            type = "Dynamic", -- 63
            x = -200, -- 63
            y = -150, -- 63
            onContactStart = function(other) -- 63
                if other.tag ~= "" and score.current then -- 63
                    local sc = __TS__ParseFloat(score.current.text) + __TS__ParseFloat(other.tag) -- 74
                    score.current.text = tostring(sc) -- 75
                    local ____tolua_cast_2 = tolua.cast -- 76
                    local ____opt_0 = other.children -- 76
                    local label = ____tolua_cast_2(____opt_0 and ____opt_0.last, "Label") -- 76
                    if label then -- 76
                        label.text = "" -- 77
                    end -- 77
                    other.tag = "" -- 78
                    other:perform(Scale(0.2, 0.7, 1)) -- 79
                end -- 79
            end -- 72
        }, -- 72
        React:createElement("disk-fixture", {radius = 50}), -- 72
        React:createElement( -- 72
            "draw-node", -- 72
            nil, -- 72
            React:createElement("dot-shape", {radius = 50, color = 4294901896}) -- 72
        ), -- 72
        React:createElement("label", {ref = score, fontName = "sarasa-mono-sc-regular", fontSize = 40}, "0"), -- 72
        React:createElement("scale", {time = 0.4, start = 0.3, stop = 1, easing = Ease.OutBack}) -- 72
    ) -- 72
)) -- 72
return ____exports -- 72