-- [ts]: TruncatedEditRecovery.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Utils = require("Agent.Utils") -- 2
local safeJsonDecode = ____Utils.safeJsonDecode -- 2
local function recoverJsonStringProperty(text, key) -- 16
	local marker = ("\"" .. key) .. "\"" -- 17
	local markerIndex = (string.find(text, marker, nil, true) or 0) - 1 -- 18
	if markerIndex < 0 then -- 18
		return nil -- 19
	end -- 19
	local colonIndex = (string.find( -- 20
		text, -- 20
		":", -- 20
		math.max(markerIndex + #marker + 1, 1), -- 20
		true -- 20
	) or 0) - 1 -- 20
	if colonIndex < 0 then -- 20
		return nil -- 21
	end -- 21
	local quoteIndex = colonIndex + 1 -- 22
	while quoteIndex < #text do -- 22
		local code = __TS__StringCharCodeAt(text, quoteIndex) -- 24
		if code ~= 32 and code ~= 9 and code ~= 10 and code ~= 13 then -- 24
			break -- 25
		end -- 25
		quoteIndex = quoteIndex + 1 -- 26
	end -- 26
	if quoteIndex >= #text or __TS__StringCharCodeAt(text, quoteIndex) ~= 34 then -- 26
		return nil -- 28
	end -- 28
	local escaped = false -- 29
	do -- 29
		local i = quoteIndex + 1 -- 30
		while i < #text do -- 30
			do -- 30
				local code = __TS__StringCharCodeAt(text, i) -- 31
				if escaped then -- 31
					escaped = false -- 33
					goto __continue9 -- 34
				end -- 34
				if code == 92 then -- 34
					escaped = true -- 37
					goto __continue9 -- 38
				end -- 38
				if code == 34 then -- 38
					local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(text, quoteIndex, i + 1)) .. "}") -- 41
					if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 41
						return {value = decoded.value, complete = true} -- 43
					end -- 43
					return nil -- 45
				end -- 45
			end -- 45
			::__continue9:: -- 45
			i = i + 1 -- 30
		end -- 30
	end -- 30
	local fragment = __TS__StringSlice(text, quoteIndex) -- 48
	do -- 48
		local trim = 0 -- 49
		while trim <= 6 and trim <= #fragment - 1 do -- 49
			local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(fragment, 0, #fragment - trim)) .. "\"}") -- 50
			if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 50
				return {value = decoded.value, complete = false} -- 52
			end -- 52
			trim = trim + 1 -- 49
		end -- 49
	end -- 49
	return nil -- 55
end -- 16
local function recoverDirectEditObject(fragment, start, completeObject) -- 66
	if completeObject then -- 66
		local decoded = safeJsonDecode(fragment) -- 68
		if not decoded or type(decoded) ~= "table" then -- 68
			return nil -- 69
		end -- 69
		local obj = decoded -- 70
		if type(obj.path) ~= "string" or type(obj.old_str) ~= "string" or type(obj.new_str) ~= "string" then -- 70
			return nil -- 71
		end -- 71
		return { -- 72
			start = start, -- 72
			path = obj.path, -- 72
			oldStr = obj.old_str, -- 72
			newStr = obj.new_str, -- 72
			newStrComplete = true -- 72
		} -- 72
	end -- 72
	local pathMarker = (string.find(fragment, "\"path\"", nil, true) or 0) - 1 -- 74
	local editsMarker = (string.find(fragment, "\"edits\"", nil, true) or 0) - 1 -- 75
	if pathMarker < 0 or editsMarker >= 0 and editsMarker < pathMarker then -- 75
		return nil -- 76
	end -- 76
	local path = recoverJsonStringProperty(fragment, "path") -- 77
	local oldStr = recoverJsonStringProperty(fragment, "old_str") -- 78
	local newStr = recoverJsonStringProperty(fragment, "new_str") -- 79
	if not (path and path.complete) or not (oldStr and oldStr.complete) or not newStr then -- 79
		return nil -- 80
	end -- 80
	if not newStr.complete and #newStr.value == 0 then -- 80
		return nil -- 81
	end -- 81
	return { -- 82
		start = start, -- 83
		path = path.value, -- 84
		oldStr = oldStr.value, -- 85
		newStr = newStr.value, -- 86
		newStrComplete = newStr.complete -- 87
	} -- 87
end -- 66
local function recoverEditObjects(argumentsText) -- 91
	local starts = {} -- 92
	local recovered = {} -- 93
	local quote = false -- 94
	local escaped = false -- 95
	do -- 95
		local i = 0 -- 96
		while i < #argumentsText do -- 96
			do -- 96
				local code = __TS__StringCharCodeAt(argumentsText, i) -- 97
				if quote then -- 97
					if escaped then -- 97
						escaped = false -- 99
					elseif code == 92 then -- 99
						escaped = true -- 100
					elseif code == 34 then -- 100
						quote = false -- 101
					end -- 101
					goto __continue26 -- 102
				end -- 102
				if code == 34 then -- 102
					quote = true -- 105
					goto __continue26 -- 106
				end -- 106
				if code == 123 then -- 106
					starts[#starts + 1] = i -- 109
					goto __continue26 -- 110
				end -- 110
				if code == 125 and #starts > 0 then -- 110
					local start = table.remove(starts) -- 113
					local edit = recoverDirectEditObject( -- 114
						__TS__StringSlice(argumentsText, start, i + 1), -- 114
						start, -- 114
						true -- 114
					) -- 114
					if edit then -- 114
						recovered[#recovered + 1] = edit -- 115
					end -- 115
				end -- 115
			end -- 115
			::__continue26:: -- 115
			i = i + 1 -- 96
		end -- 96
	end -- 96
	do -- 96
		local i = #starts - 1 -- 118
		while i >= 0 do -- 118
			local start = starts[i + 1] -- 119
			local edit = recoverDirectEditObject( -- 120
				__TS__StringSlice(argumentsText, start), -- 120
				start, -- 120
				false -- 120
			) -- 120
			if edit then -- 120
				recovered[#recovered + 1] = edit -- 122
				break -- 123
			end -- 123
			i = i - 1 -- 118
		end -- 118
	end -- 118
	__TS__ArraySort( -- 126
		recovered, -- 126
		function(____, left, right) return left.start - right.start end -- 126
	) -- 126
	return recovered -- 127
end -- 91
--- Recover only edit objects whose path, old string, and generated new-string
-- prefix are independently decodable. Unattributed trailing fragments are
-- deliberately discarded instead of guessing their target.
function ____exports.planTruncatedEditRecovery(toolCalls) -- 133
	if not toolCalls or #toolCalls == 0 then -- 133
		return nil -- 136
	end -- 136
	do -- 136
		local i = #toolCalls - 1 -- 137
		while i >= 0 do -- 137
			do -- 137
				local ____opt_4 = toolCalls[i + 1] -- 137
				local fn = ____opt_4 and ____opt_4["function"] -- 138
				if not fn or fn.name ~= "edit_file" or type(fn.arguments) ~= "string" then -- 138
					goto __continue42 -- 139
				end -- 139
				local edits = recoverEditObjects(fn.arguments) -- 140
				if #edits == 0 then -- 140
					goto __continue42 -- 141
				end -- 141
				local targets = {} -- 142
				local recoveredNewStrCharacters = 0 -- 143
				local incompleteStringCount = 0 -- 144
				for ____, edit in ipairs(edits) do -- 145
					if __TS__ArrayIndexOf(targets, edit.path) < 0 then -- 145
						targets[#targets + 1] = edit.path -- 146
					end -- 146
					recoveredNewStrCharacters = recoveredNewStrCharacters + #edit.newStr -- 147
					if not edit.newStrComplete then -- 147
						incompleteStringCount = incompleteStringCount + 1 -- 148
					end -- 148
				end -- 148
				local useLegacyForm = #edits == 1 and __TS__StringStartsWith( -- 150
					__TS__StringTrim(fn.arguments), -- 151
					"{" -- 151
				) and (string.find(fn.arguments, "\"edits\"", nil, true) or 0) - 1 < 0 -- 151
				local params = useLegacyForm and ({path = edits[1].path, old_str = edits[1].oldStr, new_str = edits[1].newStr}) or ({edits = __TS__ArrayMap( -- 153
					edits, -- 158
					function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 158
				)}) -- 158
				return { -- 160
					params = params, -- 161
					targets = targets, -- 162
					operationCount = #edits, -- 163
					recoveredNewStrCharacters = recoveredNewStrCharacters, -- 164
					incompleteStringCount = incompleteStringCount -- 165
				} -- 165
			end -- 165
			::__continue42:: -- 165
			i = i - 1 -- 137
		end -- 137
	end -- 137
	return nil -- 168
end -- 133
return ____exports -- 133