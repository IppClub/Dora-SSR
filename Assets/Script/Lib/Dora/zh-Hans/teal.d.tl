local record teal
	tolua: function(codes: string, moduleName: string, searchPath: string): --[[lua codes]] string, --[[error]] string | nil
	toluaAsync: function(codes: string, moduleName: string, searchPath: string): --[[lua codes]] string, --[[error]] string | nil
	enum ErrorType
		"parsing"
		"syntax"
		"type"
		"warning"
		"crash"
	end
	type CheckResult = {
		--[[type]] ErrorType,
		--[[filename]] string,
		--[[row]] integer,
		--[[col]] integer,
		--[[msg]] string
	}
	checkAsync: function(codes: string, moduleName: string, lax: boolean, searchPath: string): --[[passed]] boolean, {CheckResult} | nil
	enum CompleteItemType
		"variable"
		"function"
		"method"
		"field"
		"keyword"
	end
	type CompleteResult = {
		--[[label]] string,
		--[[desc]] string,
		CompleteItemType
	}
	completeAsync: function(codes: string, line: string, row: integer, searchPath: string): {CompleteResult}
	record InferResult
		desc: string
		file: string
		row: number
		col: number
		key: string | nil
	end
	inferAsync: function(codes: string, line: string, row: integer, searchPath: string): InferResult | nil
	getSignatureAsync: function(codes: string, line: string, row: integer, searchPath: string): {InferResult}
	clear: function(reset?: boolean --[[false]])
end
return teal
