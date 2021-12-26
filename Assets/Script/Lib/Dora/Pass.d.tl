local Object = require("Object").Type
local Color = require("Color").Type
local record Pass
	embed Object
	grabPass: boolean
	set: function(self: Pass,
		name: string,
		var1: number,
		var2?: number --[[0]],
		var3?: number --[[0]],
		var4?: number --[[0]])
	set: function(self: Pass, name: string, var: Color)
end
local record PassClass
	type Type = Pass
	metamethod __call: function(cls: PassClass, vertShader: string, fragShader: string): Pass
end
local passClass: PassClass
return passClass
