-- [tsx]: TilemapTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local scale = 1 / App.devicePixelRatio -- 5
local tileNodeRef = useRef() -- 6
toNode(React:createElement( -- 8
    "align-node", -- 8
    { -- 8
        windowRoot = true, -- 8
        onTapMoved = function(touch) -- 8
            if tileNodeRef.current then -- 8
                tileNodeRef.current.position = tileNodeRef.current.position:add(touch.delta) -- 11
            end -- 11
        end -- 9
    }, -- 9
    React:createElement("tile-node", {ref = tileNodeRef, file = "TMX/platform.tmx", filter = "Point"}) -- 9
)) -- 9
return ____exports -- 9