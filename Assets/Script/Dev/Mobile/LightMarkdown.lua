-- [ts]: LightMarkdown.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local function cleanInline(text) -- 8
	local result = (string.gsub(text, "%*%*", "")) -- 9
	result = (string.gsub(result, "__", "")) -- 10
	result = (string.gsub(result, "`", "")) -- 11
	return result -- 12
end -- 8
function ____exports.parseLightMarkdown(source) -- 15
	local blocks = {} -- 16
	local lines = __TS__StringSplit(source, "\n") -- 17
	local code = false -- 18
	do -- 18
		local i = 0 -- 19
		while i < #lines do -- 19
			do -- 19
				local raw = __TS__StringTrim(lines[i + 1]) -- 20
				if string.sub(raw, 1, 3) == "```" then -- 20
					code = not code -- 21
					goto __continue5 -- 21
				end -- 21
				if raw == "" then -- 21
					goto __continue5 -- 22
				end -- 22
				if code then -- 22
					blocks[#blocks + 1] = {kind = "code", text = raw} -- 23
					goto __continue5 -- 23
				end -- 23
				if string.sub(raw, 1, 3) == "## " then -- 23
					blocks[#blocks + 1] = { -- 24
						kind = "heading2", -- 24
						text = cleanInline(string.sub(raw, 4)) -- 24
					} -- 24
					goto __continue5 -- 24
				end -- 24
				if string.sub(raw, 1, 2) == "# " then -- 24
					blocks[#blocks + 1] = { -- 25
						kind = "heading1", -- 25
						text = cleanInline(string.sub(raw, 3)) -- 25
					} -- 25
					goto __continue5 -- 25
				end -- 25
				if string.sub(raw, 1, 6) == "- [ ] " then -- 25
					blocks[#blocks + 1] = { -- 26
						kind = "task", -- 26
						text = "□ " .. cleanInline(string.sub(raw, 7)) -- 26
					} -- 26
					goto __continue5 -- 26
				end -- 26
				if string.sub(raw, 1, 6) == "- [x] " or string.sub(raw, 1, 6) == "- [X] " then -- 26
					blocks[#blocks + 1] = { -- 27
						kind = "task", -- 27
						text = "■ " .. cleanInline(string.sub(raw, 7)) -- 27
					} -- 27
					goto __continue5 -- 27
				end -- 27
				if string.sub(raw, 1, 2) == "- " or string.sub(raw, 1, 2) == "* " then -- 27
					blocks[#blocks + 1] = { -- 28
						kind = "list", -- 28
						text = "• " .. cleanInline(string.sub(raw, 3)) -- 28
					} -- 28
					goto __continue5 -- 28
				end -- 28
				blocks[#blocks + 1] = { -- 29
					kind = "paragraph", -- 29
					text = cleanInline(raw) -- 29
				} -- 29
			end -- 29
			::__continue5:: -- 29
			i = i + 1 -- 19
		end -- 19
	end -- 19
	return blocks -- 31
end -- 15
return ____exports -- 15