-- [ts]: AgentQuestionnaire.ts
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
	local title = cleanString(value.title, 120) -- 78
	if title == "" then -- 78
		return {success = false, message = "ask_user requires title"} -- 79
	end -- 79
	if not __TS__ArrayIsArray(value.questions) or #value.questions < 1 or #value.questions > 8 then -- 79
		return {success = false, message = "ask_user requires 1 to 8 questions"} -- 81
	end -- 81
	local ids = {} -- 83
	local questions = {} -- 84
	do -- 84
		local i = 0 -- 85
		while i < #value.questions do -- 85
			local raw = value.questions[i + 1] -- 86
			if not isRecord(raw) then -- 86
				return { -- 87
					success = false, -- 87
					message = ("question " .. tostring(i + 1)) .. " must be an object" -- 87
				} -- 87
			end -- 87
			local id = cleanString(raw.id, 64) -- 88
			local prompt = cleanString(raw.prompt, 500) -- 89
			local ____type = cleanString(raw.type, 32) -- 90
			if not isSafeIdentifier(id) then -- 90
				return { -- 91
					success = false, -- 91
					message = ("question " .. tostring(i + 1)) .. " has invalid id" -- 91
				} -- 91
			end -- 91
			if ids[id] then -- 91
				return {success = false, message = "duplicate question id: " .. id} -- 92
			end -- 92
			if prompt == "" then -- 92
				return {success = false, message = ("question " .. id) .. " requires prompt"} -- 93
			end -- 93
			if ____type ~= "single_choice" and ____type ~= "multiple_choice" and ____type ~= "text" then -- 93
				return {success = false, message = ("question " .. id) .. " has invalid type"} -- 95
			end -- 95
			ids[id] = true -- 97
			local question = { -- 98
				id = id, -- 99
				prompt = prompt, -- 100
				type = ____type, -- 101
				required = cleanBoolean(raw.required, true), -- 102
				allowOther = ____type ~= "text" -- 103
			} -- 103
			local description = cleanString(raw.description, 1000) -- 105
			if description ~= "" then -- 105
				question.description = description -- 106
			end -- 106
			local placeholder = cleanString(raw.placeholder, 200) -- 107
			if placeholder ~= "" then -- 107
				question.placeholder = placeholder -- 108
			end -- 108
			if ____type == "text" and raw.options ~= nil then -- 108
				return {success = false, message = ("text question " .. id) .. " cannot define options"} -- 110
			end -- 110
			if ____type ~= "text" then -- 110
				if not __TS__ArrayIsArray(raw.options) or #raw.options < 2 or #raw.options > 8 then -- 110
					return {success = false, message = ("question " .. id) .. " requires 2 to 8 options"} -- 114
				end -- 114
				local optionIds = {} -- 116
				local recommendedCount = 0 -- 117
				question.options = {} -- 118
				do -- 118
					local j = 0 -- 119
					while j < #raw.options do -- 119
						local rawOption = raw.options[j + 1] -- 120
						if not isRecord(rawOption) then -- 120
							return { -- 121
								success = false, -- 121
								message = ((("question " .. id) .. " option ") .. tostring(j + 1)) .. " must be an object" -- 121
							} -- 121
						end -- 121
						local optionId = cleanString(rawOption.id, 64) -- 122
						local label = cleanString(rawOption.label, 160) -- 123
						if not isSafeIdentifier(optionId) or optionIds[optionId] then -- 123
							return {success = false, message = ("question " .. id) .. " has an invalid or duplicate option id"} -- 124
						end -- 124
						if label == "" then -- 124
							return {success = false, message = ((("question " .. id) .. " option ") .. optionId) .. " requires label"} -- 125
						end -- 125
						optionIds[optionId] = true -- 126
						local recommended = cleanBoolean(rawOption.recommended, false) -- 127
						if recommended then -- 127
							recommendedCount = recommendedCount + 1 -- 128
						end -- 128
						local option = {id = optionId, label = label, recommended = recommended} -- 129
						local optionDescription = cleanString(rawOption.description, 600) -- 130
						if optionDescription ~= "" then -- 130
							option.description = optionDescription -- 131
						end -- 131
						local ____question_options_1 = question.options -- 131
						____question_options_1[#____question_options_1 + 1] = option -- 132
						j = j + 1 -- 119
					end -- 119
				end -- 119
				if ____type == "single_choice" and recommendedCount > 1 then -- 119
					return {success = false, message = ("single-choice question " .. id) .. " may have at most one recommended option"} -- 135
				end -- 135
			end -- 135
			questions[#questions + 1] = question -- 138
			i = i + 1 -- 85
		end -- 85
	end -- 85
	local schema = {title = title, questions = questions} -- 140
	local description = cleanString(value.description, 2000) -- 141
	if description ~= "" then -- 141
		schema.description = description -- 142
	end -- 142
	return {success = true, schema = schema} -- 143
end -- 74
function ____exports.validateQuestionnaireAnswers(schema, value) -- 146
	if not __TS__ArrayIsArray(value) then -- 146
		return {success = false, message = "answers must be an array"} -- 149
	end -- 149
	local byQuestionId = {} -- 150
	do -- 150
		local i = 0 -- 151
		while i < #value do -- 151
			local item = value[i + 1] -- 152
			if not isRecord(item) then -- 152
				return { -- 153
					success = false, -- 153
					message = ("answer " .. tostring(i + 1)) .. " must be an object" -- 153
				} -- 153
			end -- 153
			local questionId = cleanString(item.questionId, 64) -- 154
			if not isSafeIdentifier(questionId) or byQuestionId[questionId] then -- 154
				return {success = false, message = "answers contain an invalid or duplicate questionId"} -- 155
			end -- 155
			byQuestionId[questionId] = item -- 156
			i = i + 1 -- 151
		end -- 151
	end -- 151
	if #value ~= #schema.questions then -- 151
		return {success = false, message = "answers must include every question exactly once"} -- 158
	end -- 158
	local answers = {} -- 159
	do -- 159
		local i = 0 -- 160
		while i < #schema.questions do -- 160
			do -- 160
				local question = schema.questions[i + 1] -- 161
				local raw = byQuestionId[question.id] -- 162
				if not raw then -- 162
					return {success = false, message = ("question " .. question.id) .. " is missing"} -- 163
				end -- 163
				local status = raw.status == "skipped" and "skipped" or (raw.status == "answered" and "answered" or "") -- 164
				if status == "" then -- 164
					return {success = false, message = ("question " .. question.id) .. " has invalid status"} -- 165
				end -- 165
				if status == "skipped" then -- 165
					if question.required then -- 165
						return {success = false, message = ("question " .. question.id) .. " is required and cannot be skipped"} -- 167
					end -- 167
					answers[#answers + 1] = {questionId = question.id, status = "skipped"} -- 168
					goto __continue45 -- 169
				end -- 169
				if question.type == "text" then -- 169
					local answer = cleanString(raw.text, 8000) -- 172
					if question.required and answer == "" then -- 172
						return {success = false, message = ("question " .. question.id) .. " is required"} -- 173
					end -- 173
					answers[#answers + 1] = {questionId = question.id, status = "answered", text = answer} -- 174
					goto __continue45 -- 175
				end -- 175
				local optionIds = {} -- 177
				do -- 177
					local j = 0 -- 178
					while j < #(question.options or ({})) do -- 178
						optionIds[(question.options or ({}))[j + 1].id] = true -- 178
						j = j + 1 -- 178
					end -- 178
				end -- 178
				local selected = __TS__ArrayIsArray(raw.selectedOptionIds) and __TS__ArrayFilter( -- 179
					raw.selectedOptionIds, -- 180
					function(____, item) return type(item) == "string" end -- 180
				) or ({}) -- 180
				local unique = {} -- 182
				do -- 182
					local j = 0 -- 183
					while j < #selected do -- 183
						local id = cleanString(selected[j + 1], 64) -- 184
						if not optionIds[id] then -- 184
							return {success = false, message = ("question " .. question.id) .. " has an invalid option"} -- 185
						end -- 185
						if __TS__ArrayIndexOf(unique, id) < 0 then -- 185
							unique[#unique + 1] = id -- 186
						end -- 186
						j = j + 1 -- 183
					end -- 183
				end -- 183
				local otherText = cleanString(raw.otherText, 8000) -- 188
				if otherText ~= "" and question.allowOther ~= true then -- 188
					return {success = false, message = ("question " .. question.id) .. " does not allow a custom answer"} -- 189
				end -- 189
				local selectionCount = #unique + (otherText ~= "" and 1 or 0) -- 190
				if question.required and selectionCount == 0 then -- 190
					return {success = false, message = ("question " .. question.id) .. " is required"} -- 191
				end -- 191
				if question.type == "single_choice" and selectionCount > 1 then -- 191
					return {success = false, message = ("question " .. question.id) .. " allows one answer"} -- 192
				end -- 192
				local answer = {questionId = question.id, status = "answered", selectedOptionIds = unique} -- 193
				if otherText ~= "" then -- 193
					answer.otherText = otherText -- 194
				end -- 194
				answers[#answers + 1] = answer -- 195
			end -- 195
			::__continue45:: -- 195
			i = i + 1 -- 160
		end -- 160
	end -- 160
	return {success = true, answers = answers} -- 197
end -- 146
return ____exports -- 146