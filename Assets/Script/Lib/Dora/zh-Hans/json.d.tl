-- Dora的JSON库。
local record json

	-- 解析指定的JSON文本，并返回相应的表。
	-- @param json (string) 要解析的JSON文本。
	-- @param maxDepth (number) [可选] 解析的最大深度（默认为128）。
	-- @return (table | nil, nil | string) 表示JSON数据的表，如果文本不是有效的JSON，则返回nil和错误消息。
	decode: function(json: string, maxDepth?: integer): table | nil, nil | string

	-- 将指定的表转换为JSON文本。
	-- @param tab (table) 要转换的表。
	-- @return (string | nil, nil | string) 表示表的JSON文本，如果无法转储表，则返回nil和错误消息。
	encode: function(tab: table): string | nil, nil | string

	-- 用于表示JSON null的用户数据类型。
	record JsonNull
		userdata
	end

	-- 表示JSON null值。
	null: JsonNull
end

local j: json
return j
