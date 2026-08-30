local D=require("Dora")
local function find(root,tag)
 if root.tag==tag then return root end
 local found;root:eachChild(function(n) found=find(n,tag);return found~=nil end);return found
end
local function text(root)
 local label=D.tolua.cast(root,"Label"); local s=label and label.text or ""
 root:eachChild(function(n) s=s..text(n);return false end);return s
end
return function()
 local host=assert(find(D.Director.systemUI,"remix-transcript-test"),"lost Remix host after run")
 assert(find(host,"remix-input"),"lost input after run")
 local scroll=assert(find(host,"remix-scroll"),"lost scroll after run")
 assert(scroll.area.stencil,"lost clipping stencil")
 host:emit("TestAfterRun")
 D.thread(function()
  D.sleep(0.5)
  assert(text(host):find("运行之后仍持续更新",1,true),"polling did not survive run/stop")
  local input=find(host,"remix-input")
  input:emit("TextInput","继续输入")
  assert(find(host,"remix-input-text").text=="草稿你好继续输入","input callback did not survive run/stop")
  D.App:saveScreenshot("/tmp/dora-remix-lifecycle-fixed")
  D.Content:save("/tmp/dora-remix-lifecycle-fixed.result","passed nodes=1 polling=1 input=1 stencil=1\n")
 end)
end
