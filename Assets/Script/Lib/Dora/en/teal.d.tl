local record teal
	tolua: function(codes: string, moduleName: string, searchPath: string): --[[lua codes]] string, --[[error]] string | nil
	toluaAsync: function(codes: string, moduleName: string, searchPath: string): --[[lua codes]] string, --[[error]] string | nil
	checkAsync: function(codes: string, moduleName: string, lax: boolean, searchPath: string): --[[passed]] boolean, {
		{
			--[[type]] string,
			--[[filename]] string,
			--[[row]] integer,
			--[[col]] integer,
			--[[msg]] string
		}
	} | nil
	enum CompleteItemType
		"variable"
		"function"
		"method"
		"field"
	end
	record CompleteResult
		success: boolean
		suggestions: {{--[[label]] string, --[[desc]] string, CompleteItemType}} | nil
	end
	completeAsync: function(codes: string, line: string, row: integer, searchPath: string): CompleteResult
	record InferResult
		record Info
			desc: string
			file: string
			row: number
			col: number
			key: string | nil
		end
		success: boolean
		infered: Info
	end
	inferAsync: function(codes: string, line: string, row: integer, searchPath: string): InferResult
	clear: function(reset?: boolean --[[false]])
end
return teal
