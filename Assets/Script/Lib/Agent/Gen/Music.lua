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
	if not HttpServer or HttpServer.wsConnectionCount == 0 then -- 224
		return -- 228
	end -- 228
	local payload = json.encode({name = "UpdateFile", file = path, exists = true, content = ""}) -- 229
	if payload then -- 229
		emit("AppWS", "Send", payload) -- 230
	end -- 230
end -- 224
local function reportProgress(hooks, value) -- 233
	local progress = math.max( -- 234
		0, -- 234
		math.min(1, value) -- 234
	) -- 234
	if progress < 0.1 then -- 234
		local ____opt_0 = hooks and hooks.onProgress -- 234
		if ____opt_0 ~= nil then -- 234
			____opt_0({ -- 236
				stage = "compose", -- 237
				progress = math.min(1, progress / 0.1), -- 238
				message = "preparing music arrangement" -- 239
			}) -- 239
		end -- 239
	elseif progress < 0.95 then -- 239
		local synthProgress = (progress - 0.1) / 0.85 -- 242
		local ____opt_4 = hooks and hooks.onProgress -- 242
		if ____opt_4 ~= nil then -- 242
			____opt_4({ -- 243
				stage = "synth", -- 244
				progress = math.max( -- 245
					0, -- 245
					math.min(1, synthProgress) -- 245
				), -- 245
				message = ("rendering music (" .. tostring(math.floor(synthProgress * 100))) .. "%)" -- 246
			}) -- 246
		end -- 246
	else -- 246
		local ____opt_8 = hooks and hooks.onProgress -- 246
		if ____opt_8 ~= nil then -- 246
			____opt_8({ -- 249
				stage = "write", -- 250
				progress = math.max( -- 251
					0, -- 251
					math.min(1, (progress - 0.95) / 0.05) -- 251
				), -- 251
				message = "writing music assets" -- 252
			}) -- 252
		end -- 252
	end -- 252
end -- 233
--- Returns a music definition unchanged so authored definitions remain type-checked and reusable.
function ____exports.defineMusic(definition) -- 260
	return definition -- 261
end -- 260
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
function ____exports.generateMusicAsync(projectDir, definition, hooks) -- 276
	local request = {projectDir = projectDir, definition = definition} -- 281
	local encoded, encodeError = json.encode(request, false, true) -- 285
	if not encoded then -- 285
		return {success = false, path = definition.output, message = "failed to encode music definition: " .. (encodeError or "unknown error")} -- 287
	end -- 287
	local response = MusicGenerator:renderMusicAsync( -- 293
		encoded, -- 293
		function(value) return reportProgress(hooks, value) end -- 293
	) -- 293
	if type(response) ~= "string" then -- 293
		return {success = false, path = definition.output, message = "music generator returned an invalid response"} -- 295
	end -- 295
	local decoded, decodeError = json.decode(response) -- 297
	if not decoded or type(decoded) ~= "table" then -- 297
		return {success = false, path = definition.output, message = "failed to decode music result: " .. (decodeError or "unknown error")} -- 299
	end -- 299
	local result = decoded -- 305
	if not result.success then -- 305
		return {success = false, path = result.path or definition.output, message = result.message} -- 307
	end -- 307
	do -- 307
		local i = 0 -- 313
		while i < #result.files do -- 313
			notifyWebIDE(Path(projectDir, result.files[i + 1])) -- 314
			i = i + 1 -- 313
		end -- 313
	end -- 313
	return result -- 316
end -- 276
return ____exports -- 276