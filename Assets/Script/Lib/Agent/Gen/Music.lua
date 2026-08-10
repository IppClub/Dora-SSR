-- [ts]: Music.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Audio = ____Dora.Audio -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Path = ____Dora.Path -- 2
local emit = ____Dora.emit -- 2
local json = ____Dora.json -- 2
local MusicGenerator = Audio -- 222
local function notifyWebIDE(path) -- 224
	if HttpServer.wsConnectionCount == 0 then -- 224
		return -- 225
	end -- 225
	local payload = json.encode({name = "UpdateFile", file = path, exists = true, content = ""}) -- 226
	if payload then -- 226
		emit("AppWS", "Send", payload) -- 227
	end -- 227
end -- 224
local function reportProgress(hooks, value) -- 230
	local progress = math.max( -- 231
		0, -- 231
		math.min(1, value) -- 231
	) -- 231
	if progress < 0.1 then -- 231
		local ____opt_0 = hooks and hooks.onProgress -- 231
		if ____opt_0 ~= nil then -- 231
			____opt_0({ -- 233
				stage = "compose", -- 234
				progress = math.min(1, progress / 0.1), -- 235
				message = "preparing music arrangement" -- 236
			}) -- 236
		end -- 236
	elseif progress < 0.95 then -- 236
		local synthProgress = (progress - 0.1) / 0.85 -- 239
		local ____opt_4 = hooks and hooks.onProgress -- 239
		if ____opt_4 ~= nil then -- 239
			____opt_4({ -- 240
				stage = "synth", -- 241
				progress = math.max( -- 242
					0, -- 242
					math.min(1, synthProgress) -- 242
				), -- 242
				message = ("rendering music (" .. tostring(math.floor(synthProgress * 100))) .. "%)" -- 243
			}) -- 243
		end -- 243
	else -- 243
		local ____opt_8 = hooks and hooks.onProgress -- 243
		if ____opt_8 ~= nil then -- 243
			____opt_8({ -- 246
				stage = "write", -- 247
				progress = math.max( -- 248
					0, -- 248
					math.min(1, (progress - 0.95) / 0.05) -- 248
				), -- 248
				message = "writing music assets" -- 249
			}) -- 249
		end -- 249
	end -- 249
end -- 230
--- Returns a music definition unchanged so authored definitions remain type-checked and reusable.
function ____exports.defineMusic(definition) -- 257
	return definition -- 258
end -- 257
--- Generates the requested WAV or Ogg file and any companion assets.
-- 
-- Call this function from a yieldable Dora coroutine. Output paths are resolved relative to
-- `projectDir`. SoundFont filenames are resolved through the engine content search paths.
-- Inspect `result.success` before using the generated files.
-- 
-- @param projectDir The project directory where generated files are saved.
-- @param definition The exact score or procedural composition and its output options.
-- @param hooks Optional progress reporting callback.
-- @returns A success result containing generated project-relative paths, or a failure result with a message.
function ____exports.generateMusicAsync(projectDir, definition, hooks) -- 273
	local request = {projectDir = projectDir, definition = definition} -- 278
	local encoded, encodeError = json.encode(request, false, true) -- 282
	if not encoded then -- 282
		return {success = false, path = definition.output, message = "failed to encode music definition: " .. (encodeError or "unknown error")} -- 284
	end -- 284
	local response = MusicGenerator:renderMusicAsync( -- 290
		encoded, -- 290
		function(value) return reportProgress(hooks, value) end -- 290
	) -- 290
	if type(response) ~= "string" then -- 290
		return {success = false, path = definition.output, message = "music generator returned an invalid response"} -- 292
	end -- 292
	local decoded, decodeError = json.decode(response) -- 294
	if not decoded or type(decoded) ~= "table" then -- 294
		return {success = false, path = definition.output, message = "failed to decode music result: " .. (decodeError or "unknown error")} -- 296
	end -- 296
	local result = decoded -- 302
	if not result.success then -- 302
		return {success = false, path = result.path or definition.output, message = result.message} -- 304
	end -- 304
	do -- 304
		local i = 0 -- 310
		while i < #result.files do -- 310
			notifyWebIDE(Path(projectDir, result.files[i + 1])) -- 311
			i = i + 1 -- 310
		end -- 310
	end -- 310
	return result -- 313
end -- 273
return ____exports -- 273