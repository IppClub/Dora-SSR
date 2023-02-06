local type CompileCodeHandler = function(
	codes: string,
	err: string,
	globals: {{string, integer, integer}}
): string | nil

return function(
		sourceFile: string,
		targetFile: string,
		compileCodesHandler: CompileCodeHandler,
		callback: function(result: boolean)
	)
	print(sourceFile, targetFile, compileCodesHandler, callback)
end
