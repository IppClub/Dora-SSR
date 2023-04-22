local Object = require("Object").Type

-- A definition object for fixtures added to physics bodies.
local record FixtureDef

	-- Inherits from `Object`.
	embed Object
end

-- A record representing the class object of FixtureDef.
local record FixtureDefClass
	type Type = FixtureDef
end

local fixtureDefClass: FixtureDefClass
return fixtureDefClass
