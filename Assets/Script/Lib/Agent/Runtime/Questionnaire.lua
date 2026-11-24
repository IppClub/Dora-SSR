-- [ts]: Questionnaire.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Utils = require("Agent.Utils") -- 2
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 2
local function isRecord(value) -- 40
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 41
end -- 40
local function trimText(value) -- 44
	local trimmed = string.match(value, "^%s*(.-)%s*$") -- 45
	return trimmed or "" -- 46
end -- 44
local function cleanString(value, maxLength) -- 49
	if type(value) ~= "string" then -- 49
		return "" -- 50
	end -- 50
	local text = trimText(sanitizeUTF8(value)) -- 51
	local nextPos = utf8.offset(text, maxLength + 1) -- 52
	return nextPos == nil and text or string.sub(text, 1, nextPos - 1) -- 53
end -- 49
local function cleanBoolean(value, fallback) -- 56
	if fallback == nil then -- 56
		fallback = false -- 56
	end -- 56
	local ____temp_0 -- 57
	if type(value) == "boolean" then -- 57
		____temp_0 = value -- 57
	else -- 57
		____temp_0 = fallback -- 57
	end -- 57
	return ____temp_0 -- 57
end -- 56
local function isSafeIdentifier(value) -- 60
	if value == "" then -- 60
		return false -- 61
	end -- 61
	do -- 61
		local i = 0 -- 62
		while i < #value do -- 62
			local code = __TS__StringCharCodeAt(value, i) -- 63
			local allowed = code >= 48 and code <= 57 or code >= 65 and code <= 90 or code >= 97 and code <= 122 or code == 45 or code == 95 -- 64
			if not allowed then -- 64
				return false -- 69
			end -- 69
			i = i + 1 -- 62
		end -- 62
	end -- 62
	return true -- 71
end -- 60
function ____exports.normalizeQuestionnaire(value) -- 74
	if not isRecord(value) then -- 74
		return {success = false, message = "ask_user requires an object"} -- 77
	end -- 77
	if not __TS__ArrayIsArray(value.questions) or #value.questions < 1 or #value.questions > 8 then -- 77
		return {success = false, message = "ask_user requires 1 to 8 questions"} -- 79
	end -- 79
	local ids = {} -- 81
	local questions = {} -- 82
	do -- 82
		local i = 0 -- 83
		while i < #value.questions do -- 83
			local raw = value.questions[i + 1] -- 84
			if not isRecord(raw) then -- 84
				return { -- 85
					success = false, -- 85
					message = ("question " .. tostring(i + 1)) .. " must be an object" -- 85
				} -- 85
			end -- 85
			local id = cleanString(raw.id, 64) -- 86
			local prompt = cleanString(raw.prompt, 500) -- 87
			local ____type = cleanString(raw.type, 32) -- 88
			if not isSafeIdentifier(id) then -- 88
				return { -- 89
					success = false, -- 89
					message = ("question " .. tostring(i + 1)) .. " has invalid id" -- 89
				} -- 89
			end -- 89
			if ids[id] then -- 89
				return {success = false, message = "duplicate question id: " .. id} -- 90
			end -- 90
			if prompt == "" then -- 90
				return {success = false, message = ("question " .. id) .. " requires prompt"} -- 91
			end -- 91
			if ____type ~= "single_choice" and ____type ~= "multiple_choice" and ____type ~= "text" then -- 91
				return {success = false, message = ("question " .. id) .. " has invalid type"} -- 93
			end -- 93
			ids[id] = true -- 95
			local question = { -- 96
				id = id, -- 97
				prompt = prompt, -- 98
				type = ____type, -- 99
				required = cleanBoolean(raw.required, true), -- 100
				allowOther = ____type ~= "text" -- 101
			} -- 101
			local description = cleanString(raw.description, 1000) -- 103
			if description ~= "" then -- 103
				question.description = description -- 104
			end -- 104
			local placeholder = cleanString(raw.placeholder, 200) -- 105
			if placeholder ~= "" then -- 105
				question.placeholder = placeholder -- 106
			end -- 106
			if ____type == "text" and raw.options ~= nil then -- 106
				return {success = false, message = ("text question " .. id) .. " cannot define options"} -- 108
			end -- 108
			if ____type ~= "text" then -- 108
				if not __TS__ArrayIsArray(raw.options) or #raw.options < 2 or #raw.options > 8 then -- 108
					return {success = false, message = ("question " .. id) .. " requires 2 to 8 options"} -- 112
				end -- 112
				local optionIds = {} -- 114
				local recommendedCount = 0 -- 115
				question.options = {} -- 116
				do -- 116
					local j = 0 -- 117
					while j < #raw.options do -- 117
						local rawOption = raw.options[j + 1] -- 118
						if not isRecord(rawOption) then -- 118
							return { -- 119
								success = false, -- 119
								message = ((("question " .. id) .. " option ") .. tostring(j + 1)) .. " must be an object" -- 119
							} -- 119
						end -- 119
						local optionId = cleanString(rawOption.id, 64) -- 120
						local label = cleanString(rawOption.label, 160) -- 121
						if not isSafeIdentifier(optionId) or optionIds[optionId] then -- 121
							return {success = false, message = ("question " .. id) .. " has an invalid or duplicate option id"} -- 122
						end -- 122
						if label == "" then -- 122
							return {success = false, message = ((("question " .. id) .. " option ") .. optionId) .. " requires label"} -- 123
						end -- 123
						optionIds[optionId] = true -- 124
						local recommended = cleanBoolean(rawOption.recommended, false) -- 125
						if recommended then -- 125
							recommendedCount = recommendedCount + 1 -- 126
						end -- 126
						local option = {id = optionId, label = label, recommended = recommended} -- 127
						local optionDescription = cleanString(rawOption.description, 600) -- 128
						if optionDescription ~= "" then -- 128
							option.description = optionDescription -- 129
						end -- 129
						local ____question_options_1 = question.options -- 129
						____question_options_1[#____question_options_1 + 1] = option -- 130
						j = j + 1 -- 117
					end -- 117
				end -- 117
				if ____type == "single_choice" and recommendedCount > 1 then -- 117
					return {success = false, message = ("single-choice question " .. id) .. " may have at most one recommended option"} -- 133
				end -- 133
			end -- 133
			questions[#questions + 1] = question -- 136
			i = i + 1 -- 83
		end -- 83
	end -- 83
	local firstQuestion = value.questions[1] -- 139
	local title = cleanString(value.title, 120) -- 140
	if title == "" then -- 140
		title = cleanString(firstQuestion.title, 120) -- 141
	end -- 141
	if title == "" then -- 141
		title = cleanString(questions[1].prompt, 120) -- 142
	end -- 142
	local schema = {title = title, questions = questions} -- 143
	local description = cleanString(value.description, 2000) -- 144
	if description ~= "" then -- 144
		schema.description = description -- 145
	end -- 145
	return {success = true, schema = schema} -- 146
end -- 74
function ____exports.validateQuestionnaireAnswers(schema, value) -- 149
	if not __TS__ArrayIsArray(value) then -- 149
		return {success = false, message = "answers must be an array"} -- 152
	end -- 152
	local byQuestionId = {} -- 153
	do -- 153
		local i = 0 -- 154
		while i < #value do -- 154
			local item = value[i + 1] -- 155
			if not isRecord(item) then -- 155
				return { -- 156
					success = false, -- 156
					message = ("answer " .. tostring(i + 1)) .. " must be an object" -- 156
				} -- 156
			end -- 156
			local questionId = cleanString(item.questionId, 64) -- 157
			if not isSafeIdentifier(questionId) or byQuestionId[questionId] then -- 157
				return {success = false, message = "answers contain an invalid or duplicate questionId"} -- 158
			end -- 158
			byQuestionId[questionId] = item -- 159
			i = i + 1 -- 154
		end -- 154
	end -- 154
	if #value ~= #schema.questions then -- 154
		return {success = false, message = "answers must include every question exactly once"} -- 161
	end -- 161
	local answers = {} -- 162
	do -- 162
		local i = 0 -- 163
		while i < #schema.questions do -- 163
			do -- 163
				local question = schema.questions[i + 1] -- 164
				local raw = byQuestionId[question.id] -- 165
				if raw == nil then -- 165
					return {success = false, message = ("question " .. question.id) .. " is missing"} -- 166
				end -- 166
				local status = raw.status == "skipped" and "skipped" or (raw.status == "answered" and "answered" or "") -- 167
				if status == "" then -- 167
					return {success = false, message = ("question " .. question.id) .. " has invalid status"} -- 168
				end -- 168
				if status == "skipped" then -- 168
					if question.required then -- 168
						return {success = false, message = ("question " .. question.id) .. " is required and cannot be skipped"} -- 170
					end -- 170
					answers[#answers + 1] = {questionId = question.id, status = "skipped"} -- 171
					goto __continue46 -- 172
				end -- 172
				if question.type == "text" then -- 172
					local answer = cleanString(raw.text, 8000) -- 175
					if question.required and answer == "" then -- 175
						return {success = false, message = ("question " .. question.id) .. " is required"} -- 176
					end -- 176
					answers[#answers + 1] = {questionId = question.id, status = "answered", text = answer} -- 177
					goto __continue46 -- 178
				end -- 178
				local optionIds = {} -- 180
				do -- 180
					local j = 0 -- 181
					while j < #(question.options or ({})) do -- 181
						optionIds[(question.options or ({}))[j + 1].id] = true -- 181
						j = j + 1 -- 181
					end -- 181
				end -- 181
				local selected = __TS__ArrayIsArray(raw.selectedOptionIds) and __TS__ArrayFilter( -- 182
					raw.selectedOptionIds, -- 183
					function(____, item) return type(item) == "string" end -- 183
				) or ({}) -- 183
				local unique = {} -- 185
				do -- 185
					local j = 0 -- 186
					while j < #selected do -- 186
						local id = cleanString(selected[j + 1], 64) -- 187
						if not optionIds[id] then -- 187
							return {success = false, message = ("question " .. question.id) .. " has an invalid option"} -- 188
						end -- 188
						if __TS__ArrayIndexOf(unique, id) < 0 then -- 188
							unique[#unique + 1] = id -- 189
						end -- 189
						j = j + 1 -- 186
					end -- 186
				end -- 186
				local otherText = cleanString(raw.otherText, 8000) -- 191
				if otherText ~= "" and question.allowOther ~= true then -- 191
					return {success = false, message = ("question " .. question.id) .. " does not allow a custom answer"} -- 192
				end -- 192
				local selectionCount = #unique + (otherText ~= "" and 1 or 0) -- 193
				if question.required and selectionCount == 0 then -- 193
					return {success = false, message = ("question " .. question.id) .. " is required"} -- 194
				end -- 194
				if question.type == "single_choice" and selectionCount > 1 then -- 194
					return {success = false, message = ("question " .. question.id) .. " allows one answer"} -- 195
				end -- 195
				local answer = {questionId = question.id, status = "answered", selectedOptionIds = unique} -- 196
				if otherText ~= "" then -- 196
					answer.otherText = otherText -- 197
				end -- 197
				answers[#answers + 1] = answer -- 198
			end -- 198
			::__continue46:: -- 198
			i = i + 1 -- 163
		end -- 163
	end -- 163
	return {success = true, answers = answers} -- 200
end -- 149
return ____exports -- 149