-- [ts]: AgentToolRegistry.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local resolveText, getToolDescription, getToolRules, getParameterDescription, createFunctionToolSchemaFromPrompt, BUILT_IN_AGENT_TOOL_NAMES -- 1
function resolveText(value, context) -- 131
	return type(value) == "string" and value or value(context) -- 132
end -- 132
function getToolDescription(tool, context) -- 135
	return resolveText(tool.description, context) -- 136
end -- 136
function getToolRules(tool, context) -- 139
	return __TS__ArrayMap( -- 140
		tool.rules or ({}), -- 140
		function(____, rule) return resolveText(rule, context) end -- 140
	) -- 140
end -- 140
function getParameterDescription(parameter, context) -- 143
	return resolveText(parameter.description, context) -- 144
end -- 144
function createFunctionToolSchemaFromPrompt(tool, context) -- 147
	local properties = {} -- 148
	local required = {} -- 149
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 150
		local property = { -- 151
			type = parameter.type, -- 152
			description = getParameterDescription(parameter, context) -- 153
		} -- 153
		if parameter.enum ~= nil then -- 153
			property.enum = parameter.enum -- 156
		end -- 156
		if parameter.items ~= nil then -- 156
			property.items = parameter.items -- 159
		end -- 159
		properties[parameter.name] = property -- 161
		if parameter.required == true then -- 161
			required[#required + 1] = parameter.name -- 163
		end -- 163
	end -- 163
	local parameters = {type = "object", properties = properties} -- 166
	if #required > 0 then -- 166
		parameters.required = required -- 171
	end -- 171
	local rules = getToolRules(tool, context) -- 173
	return { -- 174
		type = "function", -- 175
		["function"] = { -- 176
			name = tool.name, -- 177
			description = table.concat( -- 178
				{ -- 178
					getToolDescription(tool, context), -- 178
					table.unpack(rules) -- 178
				}, -- 178
				" " -- 178
			), -- 178
			parameters = parameters -- 179
		} -- 179
	} -- 179
end -- 179
function ____exports.isKnownToolName(name) -- 625
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 626
end -- 625
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 779
	return __TS__ArrayMap( -- 780
		tools, -- 780
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 781
	) -- 781
end -- 779
BUILT_IN_AGENT_TOOL_NAMES = { -- 25
	"read_file", -- 26
	"edit_file", -- 27
	"delete_file", -- 28
	"grep_files", -- 29
	"search_dora_api", -- 30
	"glob_files", -- 31
	"build", -- 32
	"fetch_url", -- 33
	"generate_sfx", -- 34
	"generate_music", -- 35
	"generate_music_variation", -- 36
	"execute_command", -- 37
	"list_sub_agents", -- 38
	"spawn_sub_agent", -- 39
	"ask_user", -- 40
	"finish" -- 41
} -- 41
function ____exports.findUnsupportedDoraTsEdit(path, newStr) -- 83
	local normalized = string.lower(path) -- 84
	if not (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tsx")) or __TS__StringEndsWith(normalized, ".d.ts") then -- 84
		return nil -- 85
	end -- 85
	local isTestFile = __TS__StringEndsWith(normalized, "test.ts") or __TS__StringEndsWith(normalized, "test.tsx") -- 86
	local checks = { -- 87
		{"Math.random", "inject a deterministic RNG or use supported bounded arithmetic"}, -- 88
		{"Math.hypot", "use Math.sqrt(x * x + y * y)"}, -- 89
		{"Math.imul", "use ordinary bounded multiplication"}, -- 90
		{"KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"}, -- 91
		{"ReturnType<typeof", "annotate Dora factory instances with X.Type"} -- 92
	} -- 92
	local lines = __TS__StringSplit(newStr, "\n") -- 94
	do -- 94
		local i = 0 -- 95
		while i < #lines do -- 95
			do -- 95
				local trimmed = __TS__StringTrim(lines[i + 1]) -- 96
				if __TS__StringStartsWith(trimmed, "//") or __TS__StringStartsWith(trimmed, "/*") or __TS__StringStartsWith(trimmed, "*") then -- 96
					goto __continue5 -- 97
				end -- 97
				local uncommented = __TS__StringSplit(lines[i + 1], "//")[1] or "" -- 98
				local code = "" -- 99
				local quote = "" -- 100
				local escaped = false -- 101
				do -- 101
					local j = 0 -- 102
					while j < #uncommented do -- 102
						local char = __TS__StringAccess(uncommented, j) -- 103
						if quote ~= "" then -- 103
							if escaped then -- 103
								escaped = false -- 105
							elseif char == "\\" then -- 105
								escaped = true -- 106
							elseif char == quote then -- 106
								quote = "" -- 107
							end -- 107
							code = code .. " " -- 108
						elseif char == "\"" or char == "'" or char == "`" then -- 108
							quote = char -- 110
							code = code .. " " -- 111
						else -- 111
							code = code .. char -- 113
						end -- 113
						j = j + 1 -- 102
					end -- 102
				end -- 102
				for ____, ____value in ipairs(checks) do -- 116
					local token = ____value[1] -- 116
					local replacement = ____value[2] -- 116
					if (string.find(code, token, nil, true) or 0) - 1 >= 0 then -- 116
						return ((token .. " is unsupported in Dora TypeScript; ") .. replacement) .. ". The edit was not applied. Correct this replacement before continuing." -- 118
					end -- 118
				end -- 118
				if isTestFile then -- 118
					local compactCode = table.concat( -- 122
						__TS__StringSplit( -- 122
							table.concat( -- 122
								__TS__StringSplit(code, " "), -- 122
								"" -- 122
							), -- 122
							"\t" -- 122
						), -- 122
						"" -- 122
					) -- 122
					if (string.find(compactCode, "||true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "check(true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "assert(true", nil, true) or 0) - 1 >= 0 then -- 122
						return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied." -- 124
					end -- 124
				end -- 124
			end -- 124
			::__continue5:: -- 124
			i = i + 1 -- 95
		end -- 95
	end -- 95
	return nil -- 128
end -- 83
____exports.AGENT_TOOL_PROMPTS = { -- 184
	{ -- 185
		name = "read_file", -- 186
		roles = {"main", "sub"}, -- 187
		workModes = {"code", "plan"}, -- 188
		description = "Read a specific line range from a file.", -- 189
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read, or an exact @dora-doc/... path returned by search_dora_api."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 190
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", "Paths returned by search_dora_api are authoritative built-in documentation paths and can be read directly without modifying them."}, -- 195
		parallelSafe = true -- 199
	}, -- 199
	{ -- 201
		name = "edit_file", -- 202
		roles = {"main", "sub"}, -- 203
		workModes = {"code", "plan"}, -- 204
		description = "Make changes to a file.", -- 205
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 206
		rules = { -- 211
			"old_str and new_str MUST be different.", -- 212
			"old_str must match existing text exactly when it is non-empty.", -- 213
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 214
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 215
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 216
		} -- 216
	}, -- 216
	{ -- 219
		name = "delete_file", -- 220
		roles = {"main", "sub"}, -- 221
		workModes = {"code", "plan"}, -- 222
		description = "Remove a file.", -- 223
		parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}} -- 224
	}, -- 224
	{ -- 228
		name = "grep_files", -- 229
		roles = {"main", "sub"}, -- 230
		workModes = {"code", "plan"}, -- 231
		description = "Search text patterns inside files.", -- 232
		parameters = { -- 233
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 234
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 235
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 236
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 237
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 238
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 239
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 240
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 241
		}, -- 241
		rules = { -- 243
			"`path` may point to either a directory or a single file.", -- 244
			"This is content search (grep), not filename search.", -- 245
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 246
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 247
			"`caseSensitive` defaults to false.", -- 248
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 249
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 250
		}, -- 250
		preExecutable = true, -- 252
		parallelSafe = true -- 253
	}, -- 253
	{ -- 255
		name = "glob_files", -- 256
		roles = {"main", "sub"}, -- 257
		workModes = {"code", "plan"}, -- 258
		description = "Enumerate files under a directory.", -- 259
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 260
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 265
		preExecutable = true, -- 269
		parallelSafe = true -- 270
	}, -- 270
	{ -- 272
		name = "search_dora_api", -- 273
		roles = {"main", "sub"}, -- 274
		workModes = {"code", "plan"}, -- 275
		description = "Search Dora SSR game engine docs and tutorials.", -- 276
		parameters = { -- 277
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 278
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 279
			{name = "programmingLanguage", type = "string", enum = { -- 280
				"ts", -- 280
				"tsx", -- 280
				"lua", -- 280
				"yue", -- 280
				"teal", -- 280
				"tl", -- 280
				"wa" -- 280
			}, description = "Preferred language variant to search."}, -- 280
			{ -- 281
				name = "limit", -- 281
				type = "number", -- 281
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 281
			}, -- 281
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 282
		}, -- 282
		rules = { -- 284
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 285
			"Every result file uses the @dora-doc/api/... or @dora-doc/tutorial/... namespace and is readable with read_file.", -- 286
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 287
			"`useRegex` defaults to false whenever supported by a search tool.", -- 288
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 289
		}, -- 289
		preExecutable = true, -- 291
		parallelSafe = true -- 292
	}, -- 292
	{ -- 294
		name = "build", -- 295
		roles = {"main", "sub"}, -- 296
		workModes = {"code"}, -- 297
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 298
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 299
		rules = {"Read the result and then decide whether another action is needed."} -- 302
	}, -- 302
	{ -- 306
		name = "fetch_url", -- 307
		roles = {"main", "sub"}, -- 308
		workModes = {"code"}, -- 309
		description = "Download a single HTTP or HTTPS resource into the project.", -- 310
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 311
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 315
	}, -- 315
	{ -- 321
		name = "generate_sfx", -- 322
		roles = {"main", "sub"}, -- 323
		workModes = {"code"}, -- 324
		description = "Synthesize a retro sound effect (sfxr-style) and save it as a WAV file in the project. Use this to create game audio assets directly instead of asking the user to provide them.", -- 325
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative output path ending in .wav, e.g. Audio/jump.wav. An existing file is overwritten."}, { -- 326
			name = "type", -- 328
			type = "string", -- 328
			required = true, -- 328
			enum = { -- 328
				"jump", -- 328
				"explosion", -- 328
				"hit", -- 328
				"pickup", -- 328
				"laser", -- 328
				"powerup", -- 328
				"click", -- 328
				"random" -- 328
			}, -- 328
			description = "Sound preset to synthesize. random picks one of the other presets at random." -- 328
		}, {name = "seed", type = "number", description = "Optional integer seed. The same type and seed always produce the same sound; omit for a time-seeded variant."}, {name = "volume", type = "number", description = "Optional output volume from 0 to 1. Defaults to 0.8."}}, -- 328
		rules = {"Generated files are mono 16-bit 44.1 kHz WAV, at most a few seconds long.", "Play generated effects with Audio.play (WAV sound effects) or an audio-source node; use Audio.playStream only for long background music.", "To iterate on a sound, call again with a different seed; to reproduce a sound exactly, keep the same type and seed.", "The success result reports the saved path, duration, byte size, and the seed actually used."} -- 332
	}, -- 332
	{ -- 339
		name = "generate_music", -- 340
		roles = {"main", "sub"}, -- 341
		workModes = {"code"}, -- 342
		description = "Compose and synthesize deterministic retro background music, then save it as a loop-ready WAV file in the project. Use this when a game needs original background music rather than a short sound effect.", -- 343
		parameters = { -- 344
			{name = "path", type = "string", required = true, description = "Workspace-relative output path ending in .wav, e.g. Audio/forest_theme.wav. An existing file is overwritten."}, -- 345
			{ -- 346
				name = "style", -- 346
				type = "string", -- 346
				required = true, -- 346
				enum = { -- 346
					"chiptune", -- 346
					"adventure", -- 346
					"calm", -- 346
					"tense", -- 346
					"victory", -- 346
					"random" -- 346
				}, -- 346
				description = "Musical style. random deterministically chooses one of the other styles from the seed." -- 346
			}, -- 346
			{name = "seed", type = "number", description = "Optional integer seed controlling the key, progression, melody, and arrangement. The same arguments reproduce the same track."}, -- 347
			{name = "duration", type = "number", description = "Approximate duration in seconds, clamped to 4-32 and rounded to complete 4/4 bars for seamless looping. Defaults to 16."}, -- 348
			{name = "bpm", type = "number", description = "Optional tempo from 60 to 200 BPM. Each style has its own default."}, -- 349
			{name = "volume", type = "number", description = "Optional master volume from 0 to 1. Defaults to 0.65."}, -- 350
			{name = "intensity", type = "number", description = "Arrangement intensity from 0 to 1. Controls drums, bass activity, harmony density, and melodic range. Defaults to 0.6."}, -- 351
			{name = "key", type = "string", enum = { -- 352
				"random", -- 352
				"C", -- 352
				"C#", -- 352
				"D", -- 352
				"D#", -- 352
				"E", -- 352
				"F", -- 352
				"F#", -- 352
				"G", -- 352
				"G#", -- 352
				"A", -- 352
				"A#", -- 352
				"B" -- 352
			}, description = "Optional musical key. Defaults to random."}, -- 352
			{name = "mode", type = "string", enum = { -- 353
				"auto", -- 353
				"major", -- 353
				"minor", -- 353
				"pentatonic", -- 353
				"harmonic_minor", -- 353
				"dorian", -- 353
				"phrygian", -- 353
				"chromatic" -- 353
			}, description = "Optional scale or mode. auto uses the style default."}, -- 353
			{name = "progression", type = "string", description = "Optional comma-separated Roman-numeral chord progression, e.g. i,VI,III,VII or I,V,vi,IV."}, -- 354
			{name = "structure", type = "string", description = "Comma-separated section form such as A,A,B,A. Repeated labels reproduce the same motif. Defaults to A,A,B,A."}, -- 355
			{name = "bars_per_section", type = "number", description = "Bars per structure section, clamped to 1-8. Defaults to 2."}, -- 356
			{name = "melody_complexity", type = "number", description = "Melodic density, interval range, and ornamentation from 0 to 1. Defaults to 0.55."}, -- 357
			{name = "rhythm_complexity", type = "number", description = "Rhythmic activity and syncopation from 0 to 1. Defaults to 0.45."}, -- 358
			{name = "variation", type = "number", description = "Amount of section-to-section mutation from 0 to 1. Defaults to 0.25."}, -- 359
			{name = "lead_instrument", type = "string", enum = { -- 360
				"auto", -- 360
				"square", -- 360
				"pulse", -- 360
				"saw", -- 360
				"triangle", -- 360
				"sine", -- 360
				"organ", -- 360
				"bell", -- 360
				"pluck", -- 360
				"fm", -- 360
				"pad", -- 360
				"guitar", -- 360
				"strings" -- 360
			}, description = "Lead synthesizer voice. auto uses the style default."}, -- 360
			{name = "bass_instrument", type = "string", enum = { -- 361
				"auto", -- 361
				"square", -- 361
				"pulse", -- 361
				"saw", -- 361
				"triangle", -- 361
				"sine", -- 361
				"organ", -- 361
				"pluck", -- 361
				"fm", -- 361
				"sub", -- 361
				"guitar" -- 361
			}, description = "Bass synthesizer voice."}, -- 361
			{name = "harmony_instrument", type = "string", enum = { -- 362
				"auto", -- 362
				"square", -- 362
				"pulse", -- 362
				"saw", -- 362
				"triangle", -- 362
				"sine", -- 362
				"organ", -- 362
				"bell", -- 362
				"pluck", -- 362
				"fm", -- 362
				"pad", -- 362
				"guitar", -- 362
				"strings" -- 362
			}, description = "Arpeggio and pad synthesizer voice."}, -- 362
			{name = "stereo", type = "boolean", description = "Generate stereo audio with per-part panning. Defaults to true."}, -- 363
			{name = "reverb", type = "number", description = "Reverb amount from 0 to 1. Defaults to the style preset."}, -- 364
			{name = "delay", type = "number", description = "Tempo-synced delay amount from 0 to 1. Defaults to the style preset."}, -- 365
			{name = "chorus", type = "number", description = "Stereo chorus width from 0 to 1. Defaults to the style preset."}, -- 366
			{name = "distortion", type = "number", description = "Soft distortion amount from 0 to 1. Defaults to the style preset."}, -- 367
			{name = "bit_crush", type = "number", description = "Bit-crusher amount from 0 to 1. Zero disables it."}, -- 368
			{name = "low_pass", type = "number", description = "Low-pass filtering amount from 0 to 1. Zero disables it; higher values make the mix darker."}, -- 369
			{name = "stems", type = "boolean", description = "Also export synchronized melody, bass, harmony, and drums WAV stems."}, -- 370
			{name = "intro_bars", type = "number", description = "Export a separate intro segment with 0-8 bars. Defaults to 0."}, -- 371
			{name = "outro_bars", type = "number", description = "Export a separate outro segment with 0-8 bars. Defaults to 0."}, -- 372
			{name = "stinger", type = "string", enum = {"none", "victory", "failure", "both"}, description = "Optionally export one-bar victory and/or failure stingers."}, -- 373
			{name = "export_midi", type = "boolean", description = "Also export the generated note arrangement as a Standard MIDI file."} -- 374
		}, -- 374
		rules = { -- 376
			"Generated music is deterministic 16-bit 44.1 kHz PCM WAV and consists of complete 4/4 bars with click-free loop boundaries.", -- 377
			"Use Audio.playStream for generated background music; reserve Audio.play for short WAV sound effects.", -- 378
			"When stems are enabled, create synchronized AudioSource nodes for _melody, _bass, _harmony, and _drums, start them together, and adapt intensity through their volumes.", -- 379
			"Every generation writes a .music.json sidecar that can be passed to generate_music_variation; optional MIDI output can be continued in a DAW.", -- 380
			"Try a different seed for another composition while keeping the same style, duration, and BPM.", -- 381
			"The success result reports the actual bar-rounded duration, tempo, key, style, byte size, and seed." -- 382
		} -- 382
	}, -- 382
	{ -- 385
		name = "generate_music_variation", -- 386
		roles = {"main", "sub"}, -- 387
		workModes = {"code"}, -- 388
		description = "Regenerate a controlled variation from a .music.json project created by generate_music, preserving its tempo, key, form, instruments, and export settings unless overridden.", -- 389
		parameters = { -- 390
			{name = "project", type = "string", required = true, description = "Workspace-relative .music.json project path."}, -- 391
			{name = "path", type = "string", required = true, description = "Workspace-relative output WAV path for the new variation."}, -- 392
			{name = "seed", type = "number", description = "Optional replacement seed. Omit to deterministically derive the next seed from the project."}, -- 393
			{name = "style", type = "string", enum = { -- 394
				"chiptune", -- 394
				"adventure", -- 394
				"calm", -- 394
				"tense", -- 394
				"victory" -- 394
			}, description = "Optional style override."}, -- 394
			{name = "intensity", type = "number", description = "Optional intensity override from 0 to 1."}, -- 395
			{name = "variation", type = "number", description = "Optional mutation amount override from 0 to 1."} -- 396
		}, -- 396
		rules = {"Use this instead of starting from scratch when several intensity levels or alternate takes must remain musically compatible.", "The source project is never modified; the new WAV receives its own .music.json sidecar."} -- 398
	}, -- 398
	{ -- 403
		name = "execute_command", -- 404
		roles = {"main", "sub"}, -- 405
		workModes = {"code"}, -- 406
		description = "Execute a controlled engine command.", -- 407
		parameters = { -- 408
			{ -- 409
				name = "mode", -- 409
				type = "string", -- 409
				required = true, -- 409
				enum = {"lua", "git"}, -- 409
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 409
			}, -- 409
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 410
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 411
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 412
			{name = "timeoutSeconds", type = "number", description = "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call."} -- 413
		}, -- 413
		rules = { -- 415
			"This tool is available only when the user enables command execution for the current Agent task.", -- 416
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 417
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 418
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.", -- 419
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.", -- 420
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 421
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 422
			"Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.", -- 423
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 424
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 425
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 426
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 427
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten." -- 428
		} -- 428
	}, -- 428
	{ -- 431
		name = "finish", -- 432
		roles = {"main", "sub"}, -- 433
		workModes = {"code", "plan"}, -- 434
		description = "End the task and provide a structured completion handoff.", -- 435
		parameters = { -- 436
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 437
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 438
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 439
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 450
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 451
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 452
		}, -- 452
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 465
	}, -- 465
	{ -- 471
		name = "list_sub_agents", -- 472
		roles = {"main"}, -- 473
		workModes = {"code"}, -- 474
		description = "Query sub-agent state under the current main session.", -- 475
		parameters = {{name = "status", type = "string", enum = { -- 476
			"active_or_recent", -- 477
			"running", -- 477
			"done", -- 477
			"failed", -- 477
			"all" -- 477
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 477
		rules = { -- 482
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 483
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 484
			"limit defaults to a small recent window. Use offset to page older items.", -- 485
			"query filters by title, goal, or summary text.", -- 486
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 487
		}, -- 487
		parallelSafe = true -- 489
	}, -- 489
	{ -- 491
		name = "spawn_sub_agent", -- 492
		roles = {"main"}, -- 493
		workModes = {"code"}, -- 494
		description = "Create and start a sub agent session for delegated implementation work.", -- 495
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 496
		rules = { -- 502
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 503
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 504
			"The spawned sub agent inherits the current session tool capabilities.", -- 505
			"title should be short and specific.", -- 506
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 507
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 508
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 509
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 510
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 511
			"filesHint is an optional list of likely files or directories." -- 512
		} -- 512
	}, -- 512
	{ -- 515
		name = "ask_user", -- 516
		roles = {"main"}, -- 517
		workModes = {"plan"}, -- 518
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 519
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 520
			name = "questions", -- 524
			type = "array", -- 525
			required = true, -- 526
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option. A multiple-choice question may recommend a set no larger than maxSelections.", -- 527
			items = {type = "object", properties = { -- 528
				id = {type = "string"}, -- 531
				prompt = {type = "string"}, -- 532
				description = {type = "string"}, -- 533
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 534
				required = {type = "boolean"}, -- 535
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark a recommended set no larger than maxSelections."}}, required = {"id", "label"}}}, -- 536
				allowOther = {type = "boolean"}, -- 549
				placeholder = {type = "string"}, -- 550
				minSelections = {type = "number"}, -- 551
				maxSelections = {type = "number"} -- 552
			}, required = {"id", "prompt", "type"}} -- 552
		}}, -- 552
		rules = { -- 558
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_api.", -- 559
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 560
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set and must not exceed maxSelections.", -- 561
			"ask_user must be the only tool call in the response.", -- 562
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 563
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 564
		} -- 564
	} -- 564
} -- 564
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 569
local function hasRole(tool, role) -- 573
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 574
end -- 573
local function hasWorkMode(tool, workMode) -- 577
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 578
end -- 577
local function getToolPrompt(name) -- 581
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 582
		if tool.name == name then -- 582
			return tool -- 583
		end -- 583
	end -- 583
	return nil -- 585
end -- 581
local function isToolCapabilityEnabled(tool, options) -- 588
	if not ____exports.isKnownToolName(tool.name) then -- 588
		return false -- 589
	end -- 589
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 590
end -- 588
local function formatParameterList(tool) -- 594
	local parameters = tool.parameters or ({}) -- 595
	if #parameters == 0 then -- 595
		return "" -- 596
	end -- 596
	return table.concat( -- 597
		__TS__ArrayMap( -- 597
			parameters, -- 597
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 598
		), -- 598
		", " -- 599
	) -- 599
end -- 594
local function formatToolPrompt(tool, index, context) -- 602
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 603
	local parameterList = formatParameterList(tool) -- 604
	if parameterList ~= "" then -- 604
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 606
	end -- 606
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 608
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 609
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 610
	end -- 610
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 612
		lines[#lines + 1] = "\t- " .. rule -- 613
	end -- 613
	return table.concat(lines, "\n") -- 615
end -- 602
local function formatXMLRepairToolReference(tool) -- 618
	local parameterList = formatParameterList(tool) -- 619
	local params = parameterList ~= "" and parameterList or "none" -- 620
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 621
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 622
end -- 618
function ____exports.getAllowedToolsForRole(role, options) -- 629
	return __TS__ArrayMap( -- 630
		__TS__ArrayFilter( -- 630
			____exports.AGENT_TOOL_PROMPTS, -- 630
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 631
		), -- 631
		function(____, tool) return tool.name end -- 632
	) -- 632
end -- 629
function ____exports.buildCurrentToolAvailabilityGuidance() -- 635
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 636
end -- 635
function ____exports.getToolPromptsForRole(role, options) -- 643
	return __TS__ArrayFilter( -- 648
		____exports.AGENT_TOOL_PROMPTS, -- 648
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 648
	) -- 648
end -- 643
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 655
	"message", -- 656
	"outcome", -- 657
	"validation", -- 658
	"knownIssues", -- 659
	"assumptions", -- 660
	"learningCandidates" -- 661
} -- 661
local function getDecisionToolPromptsForRole(role, options) -- 664
	local tools = ____exports.getToolPromptsForRole(role, options) -- 669
	if role ~= "sub" then -- 669
		return tools -- 670
	end -- 670
	return __TS__ArrayMap( -- 671
		tools, -- 671
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 671
			{}, -- 671
			tool, -- 672
			{parameters = __TS__ArrayMap( -- 671
				tool.parameters or ({}), -- 673
				function(____, parameter) return __TS__ObjectAssign( -- 673
					{}, -- 673
					parameter, -- 674
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 673
				) end -- 673
			)} -- 673
		) end -- 673
	) -- 673
end -- 664
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 680
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 685
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 686
	local sections = __TS__ArrayMap( -- 687
		tools, -- 687
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 687
	) -- 687
	if (options and options.includeXmlRules) == true then -- 687
		local reasonTools = table.concat( -- 689
			__TS__ArrayMap( -- 689
				__TS__ArrayFilter( -- 689
					tools, -- 689
					function(____, tool) return tool.name ~= "finish" end -- 690
				), -- 690
				function(____, tool) return tool.name end -- 691
			), -- 691
			", " -- 692
		) -- 692
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 693
	end -- 693
	local body = table.concat(sections, "\n\n") -- 699
	return title ~= "" and (title .. "\n") .. body or body -- 700
end -- 680
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 703
	return ____exports.buildToolDefinitionsDetailed( -- 711
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 712
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 717
	) -- 717
end -- 703
function ____exports.buildXMLRepairToolReference(role, options) -- 725
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 726
	local ____array_28 = __TS__SparseArrayNew( -- 726
		"Allowed tools and XML params:", -- 732
		table.unpack(__TS__ArrayMap( -- 733
			tools, -- 733
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 733
		)) -- 733
	) -- 733
	__TS__SparseArrayPush( -- 733
		____array_28, -- 733
		"", -- 734
		"XML shape:", -- 735
		"- Wrap the decision in exactly one <tool_call> root.", -- 736
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 737
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 738
		"- Inside <params>, use one child tag per parameter name above." -- 739
	) -- 739
	local lines = {__TS__SparseArraySpread(____array_28)} -- 731
	return table.concat(lines, "\n") -- 741
end -- 725
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 744
	____exports.getToolPromptsForRole("sub"), -- 745
	{title = "Available tools:"} -- 746
) -- 746
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 749
	__TS__ArrayFilter( -- 750
		____exports.getToolPromptsForRole("main"), -- 750
		function(____, tool) return __TS__ArrayIndexOf( -- 751
			__TS__ArrayMap( -- 751
				____exports.getToolPromptsForRole("sub"), -- 751
				function(____, subTool) return subTool.name end -- 751
			), -- 751
			tool.name -- 751
		) < 0 end -- 751
	), -- 751
	{title = ""} -- 752
) -- 752
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 755
	__TS__ArrayFilter( -- 756
		____exports.AGENT_TOOL_PROMPTS, -- 756
		function(____, tool) return tool.name == "finish" end -- 756
	), -- 756
	{title = "", includeXmlRules = true} -- 757
) -- 757
function ____exports.canPreExecuteTool(tool) -- 760
	local prompt = getToolPrompt(tool) -- 761
	return (prompt and prompt.preExecutable) == true -- 762
end -- 760
function ____exports.canRunToolInParallel(tool) -- 765
	local prompt = getToolPrompt(tool) -- 766
	return (prompt and prompt.parallelSafe) == true -- 767
end -- 765
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 770
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 771
	return ____exports.buildDecisionToolSchemaForTools( -- 772
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 772
		context -- 776
	) -- 776
end -- 770
return ____exports -- 770