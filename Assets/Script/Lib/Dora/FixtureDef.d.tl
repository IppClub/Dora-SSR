local Object = require("Object").Type
local record FixtureDef
	embed Object
end
local record FixtureDefClass
	type Type = FixtureDef
end
local fixtureDefClass: FixtureDefClass
return fixtureDefClass
