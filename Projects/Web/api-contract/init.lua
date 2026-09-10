local D = require("Dora")
for _, name in ipairs({"wait", "once", "loop", "cycle", "thread", "threadLoop", "sleep"}) do
	assert(type(D[name]) == "function", name)
end
for _, name in ipairs({"App", "Content", "Director", "View", "Audio", "Controller", "Keyboard", "DB", "HttpClient", "Shader"}) do
	assert(type(D[name]) == "userdata", "Singleton not initialized: " .. name)
end
for _, name in ipairs(require("expected")) do
	local item = {Dora = D}
	for part in name:gmatch("[^.]+") do
		assert(item, "Missing API parent: " .. name)
		item = item[part]
	end
	assert(type(item) == "function", "Missing API: " .. name)
end
for class, names in pairs({
	Spine = {"containsPoint", "intersectsSegment"},
	DragonBone = {"containsPoint", "intersectsSegment"},
	Particle = {"onFinished"}, Playable = {"onAnimationEnd"},
	Body = {"onBodyEnter", "onBodyLeave", "onContactStart", "onContactEnd"},
	AlignNode = {"onAlignLayout"}, EffekNode = {"onEffekEnd"},
}) do
	for _, name in ipairs(names) do assert(type(D[class][name]) == "function", class .. "." .. name) end
end
local v = D.Vec2(3, 4)
assert(v:mul(2):equals(D.Vec2(6, 8)))
assert(v:add(D.Vec2(1, 2)):sub(D.Vec2(1, 2)):equals(v))
assert(v:div(2):equals(D.Vec2(1.5, 2)))
assert(D.Size(2, 3):mul(D.Vec2(2, 2)):equals(D.Size(4, 6)))
assert(D.Rect(0, 0, 2, 3):equals(D.Rect(0, 0, 2, 3)))
assert(tostring(v) == "Vec2(3.0, 4.0)" or tostring(v) == "Vec2(3, 4)")
assert(D.rgba(1, 2, 3, 1):toARGB() == D.Color(1, 2, 3, 255):toARGB())
local value, err = D.json.decode("invalid json")
assert(value == nil and err)
assert(D.json.decode(D.json.encode({ok = true})).ok)
local packed = D.ML.QLearner:pack({4, 4}, {2, 3})
local unpacked = D.ML.QLearner:unpack({4, 4}, packed)
assert(unpacked[1] == 2 and unpacked[2] == 3)
local q = D.ML.QLearner()
q:load({})
assert(type(q.matrix) == "table")
assert(D.Director.entry)
local luaCode = assert(D.yue.to_lua("return 42"))
assert(assert(load(luaCode))() == 42)
D.thread(function()
	assert(D.Content:saveAsync("/user/api-contract.txt", "hello"))
	assert(D.Content:loadAsync("/user/api-contract.txt") == "hello")
	assert(D.Content:copyAsync("/user/api-contract.txt", "/user/api-contract-copy.txt"))
	assert(D.Content:loadAsync("/user/api-contract-copy.txt") == "hello")
	assert(D.DB:execAsync("CREATE TABLE IF NOT EXISTS web_api_test (value INTEGER)") >= 0)
	assert(D.DB:execAsync("DELETE FROM web_api_test") >= 0)
	assert(D.DB:insertAsync("web_api_test", {{42}}))
	assert(D.DB:queryAsync("SELECT value FROM web_api_test")[1][1] == 42)
	print("DORA_WEB_API_CONTRACT_PASSED")
end)
