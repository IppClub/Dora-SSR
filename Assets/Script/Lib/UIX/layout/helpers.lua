-- [ts]: helpers.ts
local ____exports = {} -- 1
function ____exports.mergeStyle(base, override) -- 3
	local style = {} -- 4
	for k, v in pairs(base) do -- 5
		style[k] = v -- 6
	end -- 6
	if override ~= nil then -- 6
		for k, v in pairs(override) do -- 9
			style[k] = v -- 10
		end -- 10
	end -- 10
	return style -- 13
end -- 3
function ____exports.textFromChildren(children, fallback) -- 16
	if children == nil then -- 16
		return fallback or "" -- 17
	end -- 17
	if type(children) == "string" or type(children) == "number" then -- 17
		return tostring(children) -- 18
	end -- 18
	if type(children) == "table" then -- 18
		local list = children -- 20
		local text = "" -- 21
		for i = 1, #list do -- 21
			local item = list[i] -- 23
			if type(item) == "string" or type(item) == "number" then -- 23
				text = text .. tostring(item) -- 25
			end -- 25
		end -- 25
		return text ~= "" and text or (fallback or "") -- 28
	end -- 28
	return fallback or "" -- 30
end -- 16
return ____exports -- 16