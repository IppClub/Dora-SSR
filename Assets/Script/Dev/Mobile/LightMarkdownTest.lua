-- [ts]: LightMarkdownTest.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local ____LightMarkdown = require("Dev.Mobile.LightMarkdown") -- 2
local parseLightMarkdown = ____LightMarkdown.parseLightMarkdown -- 2
do -- 2
	local function ____catch(____error) -- 2
		Content:save( -- 10
			"/tmp/dora-mobile-light-markdown.result", -- 10
			"failed: " .. tostring(____error) -- 10
		) -- 10
	end -- 10
	local ____try, ____hasReturned = pcall(function() -- 10
		local blocks = parseLightMarkdown("# 标题\n## 二级\n- 项目\n- [x] 完成\n**重点**\n```ts\nconst x = 1\n```") -- 5
		if table.concat( -- 5
			__TS__ArrayMap( -- 6
				blocks, -- 6
				function(____, item) return item.kind end -- 6
			), -- 6
			"," -- 6
		) ~= "heading1,heading2,list,task,paragraph,code" then -- 6
			error( -- 6
				__TS__New(Error, "block kinds mismatch"), -- 6
				0 -- 6
			) -- 6
		end -- 6
		if blocks[5].text ~= "重点" then -- 6
			error( -- 7
				__TS__New(Error, "inline emphasis cleanup mismatch"), -- 7
				0 -- 7
			) -- 7
		end -- 7
		Content:save("/tmp/dora-mobile-light-markdown.result", "passed") -- 8
	end) -- 8
	if not ____try then -- 8
		____catch(____hasReturned) -- 8
	end -- 8
end -- 8
return ____exports -- 8