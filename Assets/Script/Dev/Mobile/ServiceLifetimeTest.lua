-- Call prepare before /run + /stop and verify afterwards. No model requests.
local D = require("Dora")
local T = {}
local function find()
 local result
 D.Director.systemUI:eachChild(function(n)
  if n.tag == "mobile-service-lifetime-test" then result=n; return true end
  return false
 end)
 return result
end
function T.prepare()
 local previous=find()
 if previous then previous:removeFromParent(true) end
 local session=require("Agent.Session")
 local host=D.Node()
 host.tag="mobile-service-lifetime-test"
 host:addTo(D.Director.systemUI)
 host:slot("Verify",function()
  assert(require("Agent.Session") == session,"Agent service instance changed during scene cleanup")
  D.Content:save("/tmp/dora-mobile-service-lifetime.result","passed agentModuleIdentity=1\n")
 end)
end
function T.verify()
 assert(find(),"service lifetime test host lost"):emit("Verify")
 find():removeFromParent(true)
end
return T
