-- [ts]: LayoutTS.ts
local ____exports = {} -- 1
local ____dora = require("dora") -- 1
local AlignNode = ____dora.AlignNode -- 1
local root = AlignNode(true) -- 3
root.showDebug = true -- 4
local node1 = AlignNode() -- 6
node1:css("\n\theight: 250;\n\tmargin: 10;\n\tpadding: 10;\n\talign-items: flex-start;\n\tflex-wrap: wrap;\n") -- 7
node1.showDebug = true -- 14
node1:addTo(root) -- 15
for _ = 1, 10 do -- 15
    local node = AlignNode() -- 18
    node:css("margin: 5; height: 50; width: 50;") -- 19
    node.showDebug = true -- 20
    node:addTo(node1) -- 21
end -- 21
return ____exports -- 21