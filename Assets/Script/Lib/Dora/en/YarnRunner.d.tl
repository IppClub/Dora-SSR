-- The YarnRunner record is used for loading and executing Yarn narrative scripts.
local record YarnRunner

	-- Enum for types of results that can be returned.
	enum ResultType

		-- Represents textual results.
		"Text"

		-- Represents choices or options.
		"Option"

		-- Represents errors.
		"Error"

		-- Only for special test use.
		"Command"
	end

	-- Field for accessing Yarn script runtime variables.
	const state: {string: string | number | boolean}

	-- The metamethod to create a Yarn script runner.
	-- @param filename (string) The name of the Yarn file to load and execute.
	-- @param startTitle (string) The starting node/title in the Yarn script.
	-- @param state (table) [optional] Table for providing predefined variables.
	-- @param command ({string: function}) [optional] Table of commands to execute.
	-- @param testing (boolean) [optional] Boolean flag for testing mode. When in testing mode, the testing variables from Web IDE will be loaded. Defaults to `false`.
	-- @return (YarnRunner) Returns the YarnRunner object.
	metamethod __call: function(
		self: YarnRunner,
		filename: string,
		startTitle: string,
		state?: {string: string | number | boolean}, --[[{}]]
		command?: {string: function}, --[[{}]]
		testing?: boolean --[[false]]
	): YarnRunner

	-- Record to define markup attributes.
	record Markup

		-- Name of the markup.
		name: string

		-- Starting position of the markup.
		start: integer

		-- Ending position of the markup.
		stop: integer

		-- Attributes associated with the markup.
		attrs: {string: boolean | number | string} | nil
	end

	-- Record to define textual results with optional markup.
	record TextResult

		-- Textual content.
		text: string

		-- Optional markup for the text.
		marks: nil | {Markup}

		-- A flag indicating that advancing will yield an OptionResult as the next result.
		optionsFollowed: nil | boolean
	end

	-- Record to define options in the narrative.
	record OptionResult

		-- Gets element as TextResult when option is available，gets boolean false when option is unavailable。
		{TextResult | boolean}
	end

	-- Method to advance the narrative.
	-- @param choice (integer) [optional] Index of the choice if presented with options.
	-- @return (nil | ResultType) Returns nil if the narrative ended. Returns enum string result when YarnRunner is still running.
	-- @return (string | table) Depending on the narrative, it can return a type of result and the associated content:
	-- "Text" and a TextResult.
	-- "Option" and an OptionResult.
	-- "Error" and a string error message.
	-- nil and a string indecating the narrative ends.
	advance: function(self: YarnRunner, choice?: integer): nil | ResultType, string | table
end

return YarnRunner
