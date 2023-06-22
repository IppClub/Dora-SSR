local record YarnRunner
	enum ResultType
		"Text"
		"Option"
	end
	metamethod __call: function(
		self: YarnRunner,
		filename: string,
		startTitle: string,
		state?: table --[[{}]],
		command?: {string: function} --[[{}]],
		testing?: boolean --[[false]],
		doraSyntax?: boolean --[[false]]
	): YarnRunner
	record Markup
		name: string
		start: integer
		stop: integer
		attrs: {string: any}
	end
	record TextResult
		text: string
		marks: {Markup}
	end
	record OptionResult
		{TextResult | boolean}
	end
	advance: function(self: YarnRunner, choice?: integer): nil | ResultType, nil | table --[[TextResult | OptionResult]]
end

return YarnRunner