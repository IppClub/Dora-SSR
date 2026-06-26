-- [tsx]: Text.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Rect = ____Dora.Rect -- 1
local ____DoraX = require("DoraX") -- 3
local React = ____DoraX.React -- 3
local nvg = require("nvg") -- 4
local ____context = require("UIX.context") -- 5
local getUiContext = ____context.getUiContext -- 5
local ____PaintNode = require("UIX.paint.PaintNode") -- 6
local PaintNode = ____PaintNode.PaintNode -- 6
local ____helpers = require("UIX.layout.helpers") -- 8
local mergeStyle = ____helpers.mergeStyle -- 8
local textFromChildren = ____helpers.textFromChildren -- 8
local fontIds = {} -- 23
local wrapCharWidthRatio = 0.58 -- 24
local function getFontId(fontName) -- 26
	local fontId = fontIds[fontName] -- 27
	if fontId == nil or fontId == 0 then -- 27
		fontId = nvg.CreateFont(fontName) -- 29
		fontIds[fontName] = fontId -- 30
	end -- 30
	return fontId -- 32
end -- 26
local function toNvgAlign(alignment) -- 35
	if alignment == "Left" then -- 35
		return "Left" -- 36
	end -- 36
	if alignment == "Right" then -- 36
		return "Right" -- 37
	end -- 37
	return "Center" -- 38
end -- 35
local function splitLongWord(word, maxChars, out) -- 41
	local index = 0 -- 42
	while index < #word do -- 42
		out[#out + 1] = __TS__StringSubstring(word, index, index + maxChars) -- 44
		index = index + maxChars -- 45
	end -- 45
end -- 41
function ____exports.wrapTextLines(text, maxWidth, fontSize) -- 49
	local charWidth = math.max(1, fontSize * wrapCharWidthRatio) -- 50
	local maxChars = math.max( -- 51
		1, -- 51
		math.floor(maxWidth / charWidth) -- 51
	) -- 51
	local lines = {} -- 52
	for ____, paragraph in ipairs(__TS__StringSplit(text, "\n")) do -- 53
		local line = "" -- 54
		for ____, word in ipairs(__TS__StringSplit(paragraph, " ")) do -- 55
			do -- 55
				if word == "" then -- 55
					goto __continue11 -- 56
				end -- 56
				if #word > maxChars then -- 56
					if line ~= "" then -- 56
						lines[#lines + 1] = line -- 59
						line = "" -- 60
					end -- 60
					splitLongWord(word, maxChars, lines) -- 62
					goto __continue11 -- 63
				end -- 63
				local next = line == "" and word or (line .. " ") .. word -- 65
				if #next > maxChars then -- 65
					if line ~= "" then -- 65
						lines[#lines + 1] = line -- 67
					end -- 67
					line = word -- 68
				else -- 68
					line = next -- 70
				end -- 70
			end -- 70
			::__continue11:: -- 70
		end -- 70
		lines[#lines + 1] = line -- 73
	end -- 73
	return #lines > 0 and lines or ({""}) -- 75
end -- 49
local function measureTextWidth(text) -- 78
	local bounds = Rect(0, 0, 0, 0) -- 79
	return nvg.TextBounds(0, 0, text, bounds) -- 80
end -- 78
local function splitLongWordMeasured(word, maxWidth, out) -- 83
	local chunk = "" -- 84
	for i = 1, #word do -- 84
		local next = chunk .. __TS__StringSubstring(word, i - 1, i) -- 86
		if chunk ~= "" and measureTextWidth(next) > maxWidth then -- 86
			out[#out + 1] = chunk -- 88
			chunk = __TS__StringSubstring(word, i - 1, i) -- 89
		else -- 89
			chunk = next -- 91
		end -- 91
	end -- 91
	if chunk ~= "" then -- 91
		out[#out + 1] = chunk -- 94
	end -- 94
end -- 83
local function wrapTextLinesMeasured(text, maxWidth) -- 97
	local lines = {} -- 98
	for ____, paragraph in ipairs(__TS__StringSplit(text, "\n")) do -- 99
		local line = "" -- 100
		for ____, word in ipairs(__TS__StringSplit(paragraph, " ")) do -- 101
			do -- 101
				if word == "" then -- 101
					goto __continue28 -- 102
				end -- 102
				if measureTextWidth(word) > maxWidth then -- 102
					if line ~= "" then -- 102
						lines[#lines + 1] = line -- 105
						line = "" -- 106
					end -- 106
					splitLongWordMeasured(word, maxWidth, lines) -- 108
					goto __continue28 -- 109
				end -- 109
				local next = line == "" and word or (line .. " ") .. word -- 111
				if line ~= "" and measureTextWidth(next) > maxWidth then -- 111
					lines[#lines + 1] = line -- 113
					line = word -- 114
				else -- 114
					line = next -- 116
				end -- 116
			end -- 116
			::__continue28:: -- 116
		end -- 116
		lines[#lines + 1] = line -- 119
	end -- 119
	return #lines > 0 and lines or ({""}) -- 121
end -- 97
function ____exports.Text(props) -- 124
	local theme = getUiContext().theme -- 125
	local value = textFromChildren( -- 126
		props.children, -- 126
		props.text ~= nil and tostring(props.text) or "" -- 126
	) -- 126
	local fontSize = props.fontSize or theme.font.size.md -- 127
	local fontName = props.fontName or theme.font.name -- 128
	local hAlign = toNvgAlign(props.alignment) -- 129
	local lineHeight = props.lineHeight or fontSize * 1.25 -- 130
	local estimatedWidth = math.max(fontSize, #value * fontSize * 0.62 + 4) -- 131
	local estimatedHeight = math.max(fontSize, lineHeight) -- 132
	return React.createElement( -- 133
		"align-node", -- 133
		{ -- 133
			key = props.key, -- 133
			ref = props.ref, -- 133
			order = props.order, -- 133
			renderOrder = props.renderOrder, -- 133
			style = mergeStyle({width = estimatedWidth, height = estimatedHeight, alignItems = "center", justifyContent = "center"}, props.style), -- 133
			visible = props.visible, -- 133
			opacity = props.opacity -- 133
		}, -- 133
		React.createElement( -- 133
			PaintNode, -- 148
			{ -- 148
				key = "text-paint", -- 148
				painter = function(ctx) -- 148
					local x = hAlign == "Left" and 0 or (hAlign == "Right" and ctx.width or ctx.width * 0.5) -- 151
					nvg.FontFaceId(getFontId(fontName)) -- 152
					nvg.FontSize(fontSize) -- 153
					nvg.TextAlign(hAlign, "Middle") -- 154
					nvg.FillColor(Color(props.color or ctx.theme.colors.text.primary)) -- 155
					local lines = props.wrap == true and wrapTextLinesMeasured(value, ctx.width) or ({value}) -- 156
					local blockHeight = lineHeight * #lines -- 157
					local firstY = (ctx.height - blockHeight) * 0.5 + lineHeight * 0.5 -- 158
					nvg.Save() -- 159
					nvg.Scale(1, -1) -- 160
					for i = 1, #lines do -- 160
						local y = firstY + (#lines - i) * lineHeight -- 162
						nvg.Text(x, -y, lines[i]) -- 163
					end -- 163
					nvg.Restore() -- 165
				end -- 150
			} -- 150
		) -- 150
	) -- 150
end -- 124
return ____exports -- 124