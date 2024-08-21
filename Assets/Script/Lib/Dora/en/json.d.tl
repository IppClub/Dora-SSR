-- JSON library for Dora.
local record json

	-- Parses the specified JSON text and returns the corresponding table.
	-- @param json (string) The JSON text to parse.
	-- @param maxDepth (number) [optional] The maximum depth of parsing (default is 128).
	-- @return (table) The table representing the JSON data, or nil if the text is not valid JSON.
	load: function(json: string, maxDepth?: integer): table | nil

	-- Dumps the specified table into a JSON text.
	-- @param tab (table) The table to dump.
	-- @return (string) The JSON text representing the table, or nil if the table cannot be dumped.
	dump: function(tab: table): string | nil

	-- An user data type for JSON null.
	record JsonNull
		userdata
	end

	-- Represents a JSON null value.
	null: JsonNull
end

local j: json
return j
