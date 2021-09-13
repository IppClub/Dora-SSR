return function(csvData: string, maxDepth: integer, handler: function(depth: integer, name: string, op: string, value: string)): number, string
	print(csvData, maxDepth, handler)
	return 0.0, nil
end
