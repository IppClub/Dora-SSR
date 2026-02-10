-- JSON library for Dora.
local record json

	-- Parses the specified JSON text and returns the corresponding table.
	-- @param json (string) The JSON text to parse.
	-- @param maxDepth (number) [optional] The maximum depth of parsing (default is 128).
	-- @param allowcomments (boolean) [optional] Whether to allow comments in the JSON text (default is false).
	-- @return (table | nil, nil | string) The table representing the JSON data, or nil with an error message if the JSON text cannot be parsed.
	decode: function(json: string, maxDepth?: integer, allowcomments?: boolean): table | nil, nil | string

	-- Dumps the specified table into a JSON text.
	-- @param tab (table) The table to dump.
	-- @param format (boolean) [optional] Whether to format the JSON text (default is false).
	-- @param empty_as_array (boolean) [optional] Whether to convert empty tables to arrays (default is false).
	-- @param num_as_str (boolean) [optional] Whether to convert numbers to strings (default is false).
	-- @param maxdepth (number) [optional] The maximum depth of conversion (default is 128).
	-- @return (string) The JSON text representing the table, or nil with an error message if the table cannot be dumped.
	encode: function(tab: table, format?: boolean, empty_as_array?: boolean, num_as_str?: boolean, maxdepth?: integer): string | nil, nil | string

	-- An user data type for JSON null.
	record JsonNull
		userdata
	end

	-- Represents a JSON null value.
	null: JsonNull
end

local j: json
return j
