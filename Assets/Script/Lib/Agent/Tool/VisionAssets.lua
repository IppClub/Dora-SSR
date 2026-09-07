-- [ts]: VisionAssets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local ____Workspace = require("Agent.Tool.Workspace") -- 3
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 3
____exports.VISION_MAX_IMAGE_BYTES = 4 * 1024 * 1024 -- 5
--- Identify a PNG or JPEG payload within the size budget; PNG also yields dimensions.
function ____exports.inspectImage(data) -- 8
	if #data < 12 or #data > ____exports.VISION_MAX_IMAGE_BYTES then -- 8
		error("invalid or oversized image") -- 9
	end -- 9
	if string.byte(data, 1) == 255 and string.byte(data, 2) == 216 and string.byte(data, 3) == 255 then -- 9
		return {format = "jpeg"} -- 11
	end -- 11
	if string.byte(data, 1) == 137 and string.sub(data, 2, 8) == "PNG\r\n\n" then -- 11
		if #data < 33 then -- 11
			error("invalid PNG image") -- 14
		end -- 14
		local function integer(offset) -- 15
			local a, b, c, d = string.byte(data, offset, offset + 3) -- 16
			return ((a * 256 + b) * 256 + c) * 256 + d -- 17
		end -- 15
		local width = integer(17) -- 19
		local height = integer(21) -- 19
		if width < 1 or height < 1 then -- 19
			error("invalid PNG dimensions") -- 20
		end -- 20
		return {format = "png", width = width, height = height} -- 21
	end -- 21
	error("unsupported image format; use PNG or JPEG") -- 23
end -- 8
function ____exports.projectVisionDir(workDir) -- 26
	return Path(workDir, ".agent", "vision") -- 27
end -- 26
--- Recent capture files under .agent/vision for resume/compression context.
function ____exports.listRecentProjectImages(workDir) -- 31
	local dir = ____exports.projectVisionDir(workDir) -- 32
	if not Content:exist(dir) then -- 32
		return {} -- 33
	end -- 33
	local files = {} -- 34
	for ____, file in ipairs(Content:getFiles(dir)) do -- 35
		if __TS__StringEndsWith(file, ".png") or __TS__StringEndsWith(file, ".jpg") or __TS__StringEndsWith(file, ".jpeg") then -- 35
			files[#files + 1] = file -- 36
		end -- 36
	end -- 36
	__TS__ArraySort( -- 38
		files, -- 38
		function(____, a, b) return a < b and 1 or (a > b and -1 or 0) end -- 38
	) -- 38
	return __TS__ArrayMap( -- 39
		__TS__ArraySlice(files, 0, 6), -- 39
		function(____, file) return {path = ".agent/vision/" .. file} end -- 39
	) -- 39
end -- 31
local function encodeDataUrl(data) -- 42
	local mime = require("mime") -- 43
	local encoded = mime.b64(data) -- 44
	if not encoded then -- 44
		error("Unable to encode image") -- 45
	end -- 45
	local inspected = ____exports.inspectImage(data) -- 46
	local prefix = inspected.format == "jpeg" and "data:image/jpeg;base64," or "data:image/png;base64," -- 47
	return prefix .. encoded -- 48
end -- 42
local function sessionProjectRoot(sessionId) -- 52
	if type(sessionId) ~= "number" or sessionId < 1 or sessionId ~= math.floor(sessionId) then -- 52
		error("invalid session") -- 53
	end -- 53
	local rows = DB:query("SELECT project_root FROM agent.AgentSession WHERE id=?", {sessionId}) -- 54
	if not rows or #rows ~= 1 or type(rows[1][1]) ~= "string" then -- 54
		error("vision session is unavailable") -- 55
	end -- 55
	return rows[1][1] -- 56
end -- 52
--- Load any project-relative PNG/JPEG image for UI display.
function ____exports.getSessionVisionImageFromPath(sessionId, path) -- 60
	do -- 60
		local function ____catch(_) -- 60
			return true, {success = false, message = "Vision image is unavailable, invalid, or outside the project"} -- 71
		end -- 71
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 71
			if type(path) ~= "string" or __TS__StringTrim(path) == "" then -- 71
				error("invalid image path") -- 62
			end -- 62
			local projectRoot = sessionProjectRoot(sessionId) -- 63
			local fullPath = resolveWorkspaceFilePath( -- 64
				projectRoot, -- 64
				__TS__StringTrim(path) -- 64
			) -- 64
			if not fullPath then -- 64
				error("path escapes the project") -- 65
			end -- 65
			local data = Content:load(fullPath) -- 66
			if not data then -- 66
				error("image is unavailable") -- 67
			end -- 67
			local inspected = ____exports.inspectImage(data) -- 68
			return true, { -- 69
				success = true, -- 69
				path = __TS__StringTrim(path), -- 69
				format = inspected.format, -- 69
				width = inspected.width, -- 69
				height = inspected.height, -- 69
				dataUrl = encodeDataUrl(data) -- 69
			} -- 69
		end) -- 69
		if not ____try then -- 69
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 69
		end -- 69
		if ____hasReturned then -- 69
			return ____returnValue -- 61
		end -- 61
	end -- 61
end -- 60
return ____exports -- 60