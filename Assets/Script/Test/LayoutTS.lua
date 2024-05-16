-- [ts]: LayoutTS.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local AlignNode = ____Dora.AlignNode -- 2
local root = AlignNode(true) -- 4
root.showDebug = true -- 5
local node1 = AlignNode() -- 7
node1:css("\n\theight: 250;\n\tmargin: 10;\n\tpadding: 10;\n\talign-items: flex-start;\n\tflex-wrap: wrap;\n") -- 8
node1.showDebug = true -- 15
node1:addTo(root) -- 16
for _ = 1, 10 do -- 16
    local node = AlignNode() -- 19
    node:css("margin: 5; height: 50; width: 50;") -- 20
    node.showDebug = true -- 21
    node:addTo(node1) -- 22
end -- 22
return ____exports -- 22