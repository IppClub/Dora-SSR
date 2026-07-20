-- [ts]: AgentQuestionnaire.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Utils = require("Agent.Utils") -- 2
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 2
local function isRecord(value) -- 42
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 43
end -- 42
local function trimText(value) -- 46
	local trimmed = string.match(value, "^%s*(.-)%s*$") -- 47
	return trimmed or "" -- 48
end -- 46
local function cleanString(value, maxLength) -- 51
	if type(value) ~= "string" then -- 51
		return "" -- 52
	end -- 52
	local text = trimText(sanitizeUTF8(value)) -- 53
	local nextPos = utf8.offset(text, maxLength + 1) -- 54
	return nextPos == nil and text or string.sub(text, 1, nextPos - 1) -- 55
end -- 51
local function cleanBoolean(value, fallback) -- 58
	if fallback == nil then -- 58
		fallback = false -- 58
	end -- 58
	local ____temp_0 -- 59
	if type(value) == "boolean" then -- 59
		____temp_0 = value -- 59
	else -- 59
		____temp_0 = fallback -- 59
	end -- 59
	return ____temp_0 -- 59
end -- 58
local function cleanInteger(value, fallback, minValue, maxValue) -- 62
	local result = type(value) == "number" and __TS__NumberIsFinite(value) and math.floor(value) or fallback -- 63
	if result < minValue then -- 63
		result = minValue -- 64
	end -- 64
	if result > maxValue then -- 64
		result = maxValue -- 65
	end -- 65
	return result -- 66
end -- 62
local function isSafeIdentifier(value) -- 69
	if value == "" then -- 69
		return false -- 70
	end -- 70
	do -- 70
		local i = 0 -- 71
		while i < #value do -- 71
			local code = __TS__StringCharCodeAt(value, i) -- 72
			local allowed = code >= 48 and code <= 57 or code >= 65 and code <= 90 or code >= 97 and code <= 122 or code == 45 or code == 95 -- 73
			if not allowed then -- 73
				return false -- 78
			end -- 78
			i = i + 1 -- 71
		end -- 71
	end -- 71
	return true -- 80
end -- 69
function ____exports.normalizeQuestionnaire(value) -- 83
	if not isRecord(value) then -- 83
		return {success = false, message = "ask_user requires an object"} -- 86
	end -- 86
	local title = cleanString(value.title, 120) -- 87
	if title == "" then -- 87
		return {success = false, message = "ask_user requires title"} -- 88
	end -- 88
	if not __TS__ArrayIsArray(value.questions) or #value.questions < 1 or #value.questions > 8 then -- 88
		return {success = false, message = "ask_user requires 1 to 8 questions"} -- 90
	end -- 90
	local ids = {} -- 92
	local questions = {} -- 93
	do -- 93
		local i = 0 -- 94
		while i < #value.questions do -- 94
			local raw = value.questions[i + 1] -- 95
			if not isRecord(raw) then -- 95
				return { -- 96
					success = false, -- 96
					message = ("question " .. tostring(i + 1)) .. " must be an object" -- 96
				} -- 96
			end -- 96
			local id = cleanString(raw.id, 64) -- 97
			local prompt = cleanString(raw.prompt, 500) -- 98
			local ____type = cleanString(raw.type, 32) -- 99
			if not isSafeIdentifier(id) then -- 99
				return { -- 100
					success = false, -- 100
					message = ("question " .. tostring(i + 1)) .. " has invalid id" -- 100
				} -- 100
			end -- 100
			if ids[id] then -- 100
				return {success = false, message = "duplicate question id: " .. id} -- 101
			end -- 101
			if prompt == "" then -- 101
				return {success = false, message = ("question " .. id) .. " requires prompt"} -- 102
			end -- 102
			if ____type ~= "single_choice" and ____type ~= "multiple_choice" and ____type ~= "text" then -- 102
				return {success = false, message = ("question " .. id) .. " has invalid type"} -- 104
			end -- 104
			ids[id] = true -- 106
			local question = { -- 107
				id = id, -- 108
				prompt = prompt, -- 109
				type = ____type, -- 110
				required = cleanBoolean(raw.required, true) -- 111
			} -- 111
			local description = cleanString(raw.description, 1000) -- 113
			if description ~= "" then -- 113
				question.description = description -- 114
			end -- 114
			local placeholder = cleanString(raw.placeholder, 200) -- 115
			if placeholder ~= "" then -- 115
				question.placeholder = placeholder -- 116
			end -- 116
			question.allowOther = cleanBoolean(raw.allowOther, false) -- 117
			if ____type == "text" and (raw.options ~= nil or raw.minSelections ~= nil or raw.maxSelections ~= nil) then -- 117
				return {success = false, message = ("text question " .. id) .. " cannot define options or selection bounds"} -- 119
			end -- 119
			if ____type ~= "text" then -- 119
				if not __TS__ArrayIsArray(raw.options) or #raw.options < 2 or #raw.options > 8 then -- 119
					return {success = false, message = ("question " .. id) .. " requires 2 to 8 options"} -- 123
				end -- 123
				local optionIds = {} -- 125
				local recommendedCount = 0 -- 126
				question.options = {} -- 127
				do -- 127
					local j = 0 -- 128
					while j < #raw.options do -- 128
						local rawOption = raw.options[j + 1] -- 129
						if not isRecord(rawOption) then -- 129
							return { -- 130
								success = false, -- 130
								message = ((("question " .. id) .. " option ") .. tostring(j + 1)) .. " must be an object" -- 130
							} -- 130
						end -- 130
						local optionId = cleanString(rawOption.id, 64) -- 131
						local label = cleanString(rawOption.label, 160) -- 132
						if not isSafeIdentifier(optionId) or optionIds[optionId] then -- 132
							return {success = false, message = ("question " .. id) .. " has an invalid or duplicate option id"} -- 133
						end -- 133
						if label == "" then -- 133
							return {success = false, message = ((("question " .. id) .. " option ") .. optionId) .. " requires label"} -- 134
						end -- 134
						optionIds[optionId] = true -- 135
						local recommended = cleanBoolean(rawOption.recommended, false) -- 136
						if recommended then -- 136
							recommendedCount = recommendedCount + 1 -- 137
						end -- 137
						local option = {id = optionId, label = label, recommended = recommended} -- 138
						local optionDescription = cleanString(rawOption.description, 600) -- 139
						if optionDescription ~= "" then -- 139
							option.description = optionDescription -- 140
						end -- 140
						local ____question_options_1 = question.options -- 140
						____question_options_1[#____question_options_1 + 1] = option -- 141
						j = j + 1 -- 128
					end -- 128
				end -- 128
				if ____type == "single_choice" and recommendedCount > 1 then -- 128
					return {success = false, message = ("single-choice question " .. id) .. " may have at most one recommended option"} -- 144
				end -- 144
				if ____type == "multiple_choice" then -- 144
					local choiceCount = #question.options + (question.allowOther and 1 or 0) -- 147
					question.minSelections = cleanInteger(raw.minSelections, question.required and 1 or 0, 0, choiceCount) -- 148
					question.maxSelections = cleanInteger(raw.maxSelections, choiceCount, 1, choiceCount) -- 149
					if question.minSelections > question.maxSelections then -- 149
						return {success = false, message = ("question " .. id) .. " has invalid selection bounds"} -- 150
					end -- 150
					if recommendedCount > question.maxSelections then -- 150
						return { -- 152
							success = false, -- 152
							message = (((("multiple-choice question " .. id) .. " recommends ") .. tostring(recommendedCount)) .. " options but maxSelections is ") .. tostring(question.maxSelections) -- 152
						} -- 152
					end -- 152
				end -- 152
			end -- 152
			questions[#questions + 1] = question -- 156
			i = i + 1 -- 94
		end -- 94
	end -- 94
	local schema = {title = title, questions = questions} -- 158
	local description = cleanString(value.description, 2000) -- 159
	if description ~= "" then -- 159
		schema.description = description -- 160
	end -- 160
	return {success = true, schema = schema} -- 161
end -- 83
function ____exports.validateQuestionnaireAnswers(schema, value) -- 164
	if not __TS__ArrayIsArray(value) then -- 164
		return {success = false, message = "answers must be an array"} -- 167
	end -- 167
	local byQuestionId = {} -- 168
	do -- 168
		local i = 0 -- 169
		while i < #value do -- 169
			local item = value[i + 1] -- 170
			if not isRecord(item) then -- 170
				return { -- 171
					success = false, -- 171
					message = ("answer " .. tostring(i + 1)) .. " must be an object" -- 171
				} -- 171
			end -- 171
			local questionId = cleanString(item.questionId, 64) -- 172
			if not isSafeIdentifier(questionId) or byQuestionId[questionId] then -- 172
				return {success = false, message = "answers contain an invalid or duplicate questionId"} -- 173
			end -- 173
			byQuestionId[questionId] = item -- 174
			i = i + 1 -- 169
		end -- 169
	end -- 169
	if #value ~= #schema.questions then -- 169
		return {success = false, message = "answers must include every question exactly once"} -- 176
	end -- 176
	local answers = {} -- 177
	do -- 177
		local i = 0 -- 178
		while i < #schema.questions do -- 178
			do -- 178
				local question = schema.questions[i + 1] -- 179
				local raw = byQuestionId[question.id] -- 180
				if not raw then -- 180
					return {success = false, message = ("question " .. question.id) .. " is missing"} -- 181
				end -- 181
				local status = raw.status == "skipped" and "skipped" or (raw.status == "answered" and "answered" or "") -- 182
				if status == "" then -- 182
					return {success = false, message = ("question " .. question.id) .. " has invalid status"} -- 183
				end -- 183
				if status == "skipped" then -- 183
					if question.required then -- 183
						return {success = false, message = ("question " .. question.id) .. " is required and cannot be skipped"} -- 185
					end -- 185
					answers[#answers + 1] = {questionId = question.id, status = "skipped"} -- 186
					goto __continue51 -- 187
				end -- 187
				if question.type == "text" then -- 187
					local answer = cleanString(raw.text, 8000) -- 190
					if question.required and answer == "" then -- 190
						return {success = false, message = ("question " .. question.id) .. " is required"} -- 191
					end -- 191
					answers[#answers + 1] = {questionId = question.id, status = "answered", text = answer} -- 192
					goto __continue51 -- 193
				end -- 193
				local optionIds = {} -- 195
				do -- 195
					local j = 0 -- 196
					while j < #(question.options or ({})) do -- 196
						optionIds[(question.options or ({}))[j + 1].id] = true -- 196
						j = j + 1 -- 196
					end -- 196
				end -- 196
				local selected = __TS__ArrayIsArray(raw.selectedOptionIds) and __TS__ArrayFilter( -- 197
					raw.selectedOptionIds, -- 198
					function(____, item) return type(item) == "string" end -- 198
				) or ({}) -- 198
				local unique = {} -- 200
				do -- 200
					local j = 0 -- 201
					while j < #selected do -- 201
						local id = cleanString(selected[j + 1], 64) -- 202
						if not optionIds[id] then -- 202
							return {success = false, message = ("question " .. question.id) .. " has an invalid option"} -- 203
						end -- 203
						if __TS__ArrayIndexOf(unique, id) < 0 then -- 203
							unique[#unique + 1] = id -- 204
						end -- 204
						j = j + 1 -- 201
					end -- 201
				end -- 201
				local otherText = cleanString(raw.otherText, 8000) -- 206
				if otherText ~= "" and question.allowOther ~= true then -- 206
					return {success = false, message = ("question " .. question.id) .. " does not allow a custom answer"} -- 207
				end -- 207
				local selectionCount = #unique + (otherText ~= "" and 1 or 0) -- 208
				if question.required and selectionCount == 0 then -- 208
					return {success = false, message = ("question " .. question.id) .. " is required"} -- 209
				end -- 209
				if question.type == "single_choice" and selectionCount > 1 then -- 209
					return {success = false, message = ("question " .. question.id) .. " allows one answer"} -- 210
				end -- 210
				if question.type == "multiple_choice" then -- 210
					if selectionCount < (question.minSelections or 0) or selectionCount > (question.maxSelections or selectionCount) then -- 210
						return {success = false, message = ("question " .. question.id) .. " does not meet the selection bounds"} -- 213
					end -- 213
				end -- 213
				local answer = {questionId = question.id, status = "answered", selectedOptionIds = unique} -- 216
				if otherText ~= "" then -- 216
					answer.otherText = otherText -- 217
				end -- 217
				answers[#answers + 1] = answer -- 218
			end -- 218
			::__continue51:: -- 218
			i = i + 1 -- 178
		end -- 178
	end -- 178
	return {success = true, answers = answers} -- 220
end -- 164
return ____exports -- 164