-- [yue]: Dev/GodotDependency.yue
local _module_0 = { } -- 1
local Content, Path -- 1
do -- 1
	local _obj_0 = require("Dora") -- 1
	Content, Path = _obj_0.Content, _obj_0.Path -- 1
end -- 1
local resourceExtensions = { -- 3
	pck = true, -- 3
	gd = true, -- 3
	gdc = true, -- 3
	tscn = true, -- 3
	scn = true, -- 3
	tres = true, -- 3
	gdshader = true, -- 3
	gdshaderinc = true, -- 3
	gdextension = true -- 3
} -- 3
local luaExtensions = { -- 4
	lua = true, -- 4
	yue = true, -- 4
	tl = true -- 4
} -- 4
local jsExtensions = { -- 5
	ts = true, -- 5
	tsx = true, -- 5
	js = true, -- 5
	jsx = true -- 5
} -- 5
local rawExtensions = { -- 6
	wasm = true, -- 6
	wa = true, -- 6
	rs = true, -- 6
	vs = true, -- 6
	bl = true, -- 6
	json = true -- 6
} -- 6
local maxCommentScanBytes = 1024 * 1024 -- 7
local maxScanBytes = 64 * 1024 * 1024 -- 8
local containsApi -- 10
containsApi = function(text) -- 10
	return text:find("%f[%w_]GodotNode%f[^%w_]") or text:find("%f[%w_]GodotPlayer%f[^%w_]") or text:find("%f[%w_]godotnode_[a-z_]+%f[^%w_]") -- 11
end -- 10
local blockEnd -- 14
blockEnd = function(text, closing, offset) -- 14
	local _, last = text:find(closing, offset, true) -- 15
	return last and last + 1 or #text + 1 -- 16
end -- 14
local quotedEnd -- 18
quotedEnd = function(text, quote, offset) -- 18
	repeat -- 19
		local marker = text:find("[\\" .. tostring(quote) .. "]", offset) -- 19
		if marker then -- 19
			if text:sub(marker, marker) == quote then -- 20
				return marker + 1 -- 20
			end -- 20
			offset = marker + 2 -- 21
		else -- 19
			break -- 19
		end -- 19
	until false -- 19
	return #text + 1 -- 22
end -- 18
local withoutComments -- 25
withoutComments = function(text, ext) -- 25
	local luaStyle = luaExtensions[ext] -- 26
	local jsStyle = jsExtensions[ext] -- 27
	local markers -- 28
	if luaStyle then -- 28
		markers = [=[[-%["']]=] -- 28
	elseif jsStyle then -- 28
		markers = [=[[/"'`]]=] -- 28
	else -- 28
		markers = "<" -- 28
	end -- 28
	local parts = { } -- 29
	local keepFrom = 1 -- 30
	local offset = 1 -- 31
	repeat -- 32
		local start = text:find(markers, offset) -- 32
		if start then -- 32
			local marker = text:sub(start, start) -- 33
			local nextTwo = text:sub(start, start + 1) -- 34
			local commentEnd = nil -- 35
			if luaStyle and nextTwo == "--" then -- 36
				local equals, body = text:match("^%[(=*)%[()", start + 2) -- 37
				if body then -- 38
					commentEnd = blockEnd(text, "]" .. tostring(equals) .. "]", body) -- 38
				else -- 38
					commentEnd = text:find("[\r\n]", start + 2) or #text + 1 -- 38
				end -- 38
			elseif jsStyle and nextTwo == "//" then -- 39
				commentEnd = text:find("[\r\n]", start + 2) or #text + 1 -- 40
			elseif jsStyle and nextTwo == "/*" then -- 41
				commentEnd = blockEnd(text, "*/", start + 2) -- 42
			elseif ext == "xml" and text:sub(start, start + 3) == "<!--" then -- 43
				commentEnd = blockEnd(text, "-->", start + 4) -- 44
			end -- 36
			if commentEnd then -- 45
				parts[#parts + 1] = text:sub(keepFrom, start - 1) -- 46
				parts[#parts + 1] = " " -- 47
				keepFrom = commentEnd -- 48
				offset = commentEnd -- 49
			elseif marker == '"' or marker == "'" or marker == '`' then -- 50
				offset = quotedEnd(text, marker, start + 1) -- 51
			elseif luaStyle and marker == "[" then -- 52
				local equals, body = text:match("^%[(=*)%[()", start) -- 53
				if body then -- 54
					offset = blockEnd(text, "]" .. tostring(equals) .. "]", body) -- 54
				else -- 54
					offset = start + 1 -- 54
				end -- 54
			elseif ext == "xml" and text:sub(start, start + 8) == "<![CDATA[" then -- 55
				offset = blockEnd(text, "]]>", start + 9) -- 56
			else -- 58
				offset = start + 1 -- 58
			end -- 45
		else -- 32
			break -- 32
		end -- 32
	until false -- 32
	parts[#parts + 1] = text:sub(keepFrom) -- 59
	return table.concat(parts) -- 60
end -- 25
local needsGodot -- 62
needsGodot = function(project) -- 62
	local _list_0 = Content:getAllFiles(project) -- 63
	for _index_0 = 1, #_list_0 do -- 63
		local file = _list_0[_index_0] -- 63
		local ext = Path:getExt(file):lower() -- 64
		if Path:getFilename(file):lower() == "project.godot" or resourceExtensions[ext] then -- 65
			return true -- 65
		end -- 65
		if ext == "res" or luaExtensions[ext] or jsExtensions[ext] or ext == "xml" or rawExtensions[ext] then -- 66
			local path = Path(project, file) -- 67
			local size = Content:getAttr(path) -- 68
			if size == nil or size > maxScanBytes then -- 70
				return true -- 70
			end -- 70
			if size == 0 then -- 71
				goto _continue_0 -- 71
			end -- 71
			local text = Content:loadAsync(path) -- 72
			if not text then -- 73
				return true -- 73
			end -- 73
			if ext == "res" then -- 74
				local magic = text:sub(1, 4) -- 75
				if magic == "RSRC" or magic == "RSCC" then -- 76
					return true -- 76
				end -- 76
			elseif containsApi(text) then -- 77
				if rawExtensions[ext] or size > maxCommentScanBytes then -- 78
					return true -- 79
				end -- 78
				if containsApi(withoutComments(text, ext)) then -- 80
					return true -- 80
				end -- 80
			end -- 74
		end -- 66
		::_continue_0:: -- 64
	end -- 63
	return false -- 81
end -- 62
_module_0["needsGodot"] = needsGodot -- 62
return _module_0 -- 1
