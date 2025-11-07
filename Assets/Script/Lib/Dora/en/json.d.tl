-- JSON library for Dora.
local record json

	-- Parses the specified JSON text and returns the corresponding table.
	-- @param json (string) The JSON text to parse.
	-- @param maxDepth (number) [optional] The maximum depth of parsing (default is 128).
	-- @return (table | nil, nil | string) The table representing the JSON data, or nil with an error message if the JSON text cannot be parsed.
	decode: function(json: string, maxDepth?: integer): table | nil, nil | string

	-- Dumps the specified table into a JSON text.
	-- @param tab (table) The table to dump.
	-- @return (string) The JSON text representing the table, or nil with an error message if the table cannot be dumped.
	encode: function(tab: table): string | nil, nil | string

	-- An user data type for JSON null.
	record JsonNull
		userdata
	end

	-- Represents a JSON null value.
	null: JsonNull
end

local j: json
return j
