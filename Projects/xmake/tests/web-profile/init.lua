local Dora = require("Dora")
assert(Dora.Node and Dora.DrawNode and Dora.Director, "portable engine bindings are missing")
local node = Dora.DrawNode()
node:drawDot(Dora.Vec2(0, 0), 40, Dora.Color(0xff40c080))
local optional = Dora.Model3D ~= nil
if optional then
    assert(Dora.View3D and Dora.LoveNode, "custom 3D/Love bindings are missing")
    assert(Dora.Audio.renderMusicAsync, "custom music binding is missing")
    Dora.thread(function()
        assert(Dora.Content:loadAsync("LoveFixture/main.lua"))
        local love = Dora.LoveNode("LoveFixture")
        assert(love, "custom Love runtime did not initialize")
        love:addTo(Dora.Director.entry)
        print("Dora Web packaged LoveNode verified")
        print("XMAKE_WEB_CUSTOM_BINDINGS_OK")
    end)
else
    assert(Dora.Model3D == nil and Dora.LoveNode == nil, "optional runtime leaked into core profile")
    print("XMAKE_WEB_CORE_BINDINGS_OK")
end
