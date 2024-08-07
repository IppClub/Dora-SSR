-- [tsx]: VGButton.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Node = ____Dora.Node -- 3
local Size = ____Dora.Size -- 3
local nvg = require("nvg") -- 4
local function Button(self, props) -- 6
    local light = nvg.LinearGradient( -- 7
        0, -- 7
        80, -- 7
        0, -- 7
        0, -- 7
        Color(4294967295), -- 7
        Color(4278255615) -- 7
    ) -- 7
    local dark = nvg.LinearGradient( -- 8
        0, -- 8
        80, -- 8
        0, -- 8
        0, -- 8
        Color(4294967295), -- 8
        Color(4294689792) -- 8
    ) -- 8
    local paint = light -- 9
    local function onCreate() -- 10
        local node = Node() -- 11
        node.size = Size(100, 100) -- 12
        local fontId = nvg.CreateFont("sarasa-mono-sc-regular") -- 13
        node:schedule(function() -- 14
            nvg.ApplyTransform(node) -- 15
            nvg.BeginPath() -- 16
            nvg.RoundedRect( -- 17
                0, -- 17
                0, -- 17
                100, -- 17
                100, -- 17
                10 -- 17
            ) -- 17
            nvg.StrokeColor(Color(4294967295)) -- 18
            nvg.StrokeWidth(5) -- 19
            nvg.Stroke() -- 20
            nvg.FillPaint(paint) -- 21
            nvg.Fill() -- 22
            nvg.ClosePath() -- 23
            nvg.FontFaceId(fontId) -- 24
            nvg.FontSize(32) -- 25
            nvg.FillColor(Color(4278190080)) -- 26
            nvg.Scale(1, -1) -- 27
            nvg.Text(50, -30, "OK") -- 28
            return false -- 29
        end) -- 14
        return node -- 31
    end -- 10
    return React:createElement( -- 33
        "custom-node", -- 33
        { -- 33
            onCreate = onCreate, -- 33
            onTapBegan = function() -- 33
                paint = dark -- 36
                return paint -- 36
            end, -- 36
            onTapEnded = function() -- 36
                paint = light -- 37
                return paint -- 37
            end, -- 37
            onTapped = props.onClick, -- 37
            children = props.children -- 37
        } -- 37
    ) -- 37
end -- 6
toNode(React:createElement( -- 44
    Button, -- 45
    {onClick = function() return print("Clicked") end}, -- 45
    React:createElement( -- 45
        "sequence", -- 45
        nil, -- 45
        React:createElement("move-x", {time = 1, start = 0, stop = 200}), -- 45
        React:createElement("angle", {time = 1, start = 0, stop = 360}), -- 45
        React:createElement("scale", {time = 1, start = 1, stop = 4}) -- 45
    ) -- 45
)) -- 45
return ____exports -- 45