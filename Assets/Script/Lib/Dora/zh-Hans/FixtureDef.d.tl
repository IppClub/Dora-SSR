local Object = require("Object").Type

-- 用于向物理体添加混合物的定义类。
local record FixtureDef
	embed Object
end

-- 表示混合物定义类对象的类。
local record FixtureDefClass
	type Type = FixtureDef
end

local fixtureDefClass: FixtureDefClass
return fixtureDefClass
