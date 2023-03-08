local record teal
	tolua: function(codes: string, moduleName: string): string, string | nil
	reset: function()
	check: function(codes: string, moduleName: string): boolean, {
		{
			--[[type]] string,
			--[[filename]] string,
			--[[row]] integer,
			--[[col]] integer,
			--[[msg]] string
		}
	} | nil
end
return teal
