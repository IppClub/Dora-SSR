-- [ts]: BinaryMetadata.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local ____Utils = require("Agent.Utils") -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local HEADER_BYTES = 64 * 1024 -- 7
local OGG_TAIL_MAX_FILE_BYTES = 16 * 1024 * 1024 -- 8
local function byte(data, offset) -- 33
	local value = string.byte(data, offset + 1) -- 34
	return value or 0 -- 35
end -- 33
local function text(data, offset, length) -- 37
	return string.sub(data, offset + 1, offset + length) -- 38
end -- 37
local function le(data, offset, length) -- 40
	local value = 0 -- 41
	do -- 41
		local i = length - 1 -- 42
		while i >= 0 do -- 42
			value = value * 256 + byte(data, offset + i) -- 42
			i = i - 1 -- 42
		end -- 42
	end -- 42
	return value -- 43
end -- 40
local function be(data, offset, length) -- 45
	local value = 0 -- 46
	do -- 46
		local i = 0 -- 47
		while i < length do -- 47
			value = value * 256 + byte(data, offset + i) -- 47
			i = i + 1 -- 47
		end -- 47
	end -- 47
	return value -- 48
end -- 45
local function image(format, width, height) -- 50
	if width <= 0 or height <= 0 or width > 2147483647 or height > 2147483647 then -- 50
		return nil -- 51
	end -- 51
	return { -- 52
		kind = "image", -- 52
		format = format, -- 52
		source = "header", -- 52
		width = width, -- 52
		height = height -- 52
	} -- 52
end -- 50
local function imageMetadata(data, size) -- 55
	if #data >= 33 and byte(data, 0) == 137 and text(data, 1, 7) == "PNG\r\n\n" and be(data, 8, 4) == 13 and text(data, 12, 4) == "IHDR" then -- 55
		return image( -- 58
			"png", -- 58
			be(data, 16, 4), -- 58
			be(data, 20, 4) -- 58
		) -- 58
	end -- 58
	if #data >= 13 and (text(data, 0, 6) == "GIF87a" or text(data, 0, 6) == "GIF89a") then -- 58
		return image( -- 61
			"gif", -- 61
			le(data, 6, 2), -- 61
			le(data, 8, 2) -- 61
		) -- 61
	end -- 61
	if #data >= 26 and text(data, 0, 2) == "BM" then -- 61
		local dibSize = le(data, 14, 4) -- 64
		if dibSize == 12 then -- 64
			return image( -- 65
				"bmp", -- 65
				le(data, 18, 2), -- 65
				le(data, 20, 2) -- 65
			) -- 65
		end -- 65
		if dibSize >= 40 and #data >= 54 then -- 65
			local height = le(data, 22, 4) -- 67
			return image( -- 68
				"bmp", -- 68
				le(data, 18, 4), -- 68
				height >= 2147483648 and 4294967296 - height or height -- 68
			) -- 68
		end -- 68
	end -- 68
	if #data >= 4 and byte(data, 0) == 255 and byte(data, 1) == 216 then -- 68
		local offset = 2 -- 72
		do -- 72
			local count = 0 -- 73
			while count < 1024 and offset + 4 <= #data do -- 73
				do -- 73
					if byte(data, offset) ~= 255 then -- 73
						break -- 74
					end -- 74
					while offset < #data and byte(data, offset) == 255 do -- 74
						offset = offset + 1 -- 75
					end -- 75
					local ____byte_2 = byte -- 76
					local ____data_1 = data -- 76
					local ____offset_0 = offset -- 76
					offset = ____offset_0 + 1 -- 76
					local marker = ____byte_2(____data_1, ____offset_0) -- 76
					if marker == 217 or marker == 218 then -- 76
						break -- 77
					end -- 77
					if marker == 1 or marker >= 208 and marker <= 215 then -- 77
						goto __continue20 -- 78
					end -- 78
					local length = be(data, offset, 2) -- 79
					if length < 2 or offset + length > #data then -- 79
						break -- 80
					end -- 80
					if marker >= 192 and marker <= 207 and marker ~= 196 and marker ~= 200 and marker ~= 204 and length >= 8 then -- 80
						local channels = byte(data, offset + 7) -- 82
						if channels > 0 and length >= 8 + 3 * channels then -- 82
							return image( -- 83
								"jpeg", -- 83
								be(data, offset + 5, 2), -- 83
								be(data, offset + 3, 2) -- 83
							) -- 83
						end -- 83
					end -- 83
					offset = offset + length -- 85
				end -- 85
				::__continue20:: -- 85
				count = count + 1 -- 73
			end -- 73
		end -- 73
	end -- 73
	if #data >= 20 and text(data, 0, 4) == "RIFF" and text(data, 8, 4) == "WEBP" then -- 73
		local ____end = le(data, 4, 4) + 8 -- 89
		if ____end > size then -- 89
			return nil -- 90
		end -- 90
		do -- 90
			local offset = 12 -- 91
			while offset + 8 <= #data do -- 91
				local tag = text(data, offset, 4) -- 92
				local length = le(data, offset + 4, 4) -- 92
				local payload = offset + 8 -- 92
				if payload + length > ____end then -- 92
					break -- 93
				end -- 93
				if tag == "VP8X" and length >= 10 and payload + 10 <= #data then -- 93
					return image( -- 95
						"webp", -- 95
						le(data, payload + 4, 3) + 1, -- 95
						le(data, payload + 7, 3) + 1 -- 95
					) -- 95
				end -- 95
				if tag == "VP8L" and length >= 5 and payload + 5 <= #data and byte(data, payload) == 47 then -- 95
					return image( -- 98
						"webp", -- 98
						le(data, payload + 1, 2) % 16384 + 1, -- 98
						math.floor(le(data, payload + 2, 3) / 64) % 16384 + 1 -- 99
					) -- 99
				end -- 99
				if tag == "VP8 " and length >= 10 and payload + 10 <= #data and byte(data, payload + 3) == 157 and byte(data, payload + 4) == 1 and byte(data, payload + 5) == 42 then -- 99
					return image( -- 103
						"webp", -- 103
						le(data, payload + 6, 2) % 16384, -- 103
						le(data, payload + 8, 2) % 16384 -- 103
					) -- 103
				end -- 103
				offset = payload + length + length % 2 -- 105
			end -- 105
		end -- 105
	end -- 105
	return nil -- 108
end -- 55
local function wavMetadata(data, size) -- 111
	if #data < 12 or text(data, 0, 4) ~= "RIFF" or text(data, 8, 4) ~= "WAVE" then -- 111
		return nil -- 112
	end -- 112
	local ____end = le(data, 4, 4) + 8 -- 113
	if ____end > size or ____end < 12 then -- 113
		return nil -- 114
	end -- 114
	local meta = {kind = "audio", format = "wav", source = "header"} -- 115
	local format = 0 -- 116
	local blockAlign = 0 -- 116
	local byteRate = 0 -- 116
	local dataBytes -- 116
	do -- 116
		local offset = 12 -- 117
		while offset + 8 <= #data and offset + 8 <= ____end do -- 117
			local tag = text(data, offset, 4) -- 118
			local length = le(data, offset + 4, 4) -- 118
			local payload = offset + 8 -- 118
			if length > ____end - payload then -- 118
				return nil -- 119
			end -- 119
			if tag == "fmt " and length >= 16 and payload + 16 <= #data then -- 119
				format = le(data, payload, 2) -- 121
				meta.channels = le(data, payload + 2, 2) -- 122
				meta.sampleRate = le(data, payload + 4, 4) -- 123
				byteRate = le(data, payload + 8, 4) -- 124
				blockAlign = le(data, payload + 12, 2) -- 125
				meta.bitsPerSample = le(data, payload + 14, 2) -- 126
				if format == 65534 and length >= 40 and payload + 40 <= #data then -- 126
					format = le(data, payload + 24, 2) -- 127
				end -- 127
			elseif tag == "data" then -- 127
				dataBytes = length -- 128
			end -- 128
			offset = payload + length + length % 2 -- 129
		end -- 129
	end -- 129
	if meta.channels == nil or meta.channels <= 0 or meta.sampleRate == nil or meta.sampleRate <= 0 then -- 129
		return nil -- 131
	end -- 131
	if format == 1 or format == 3 then -- 131
		meta.codec = format == 1 and "pcm" or "ieee-float" -- 133
		local bits = meta.bitsPerSample or 0 -- 134
		local ____temp_3 -- 135
		if format == 1 then -- 135
			____temp_3 = bits == 8 or bits == 16 or bits == 24 or bits == 32 -- 135
		else -- 135
			____temp_3 = bits == 32 or bits == 64 -- 135
		end -- 135
		local validBits = ____temp_3 -- 135
		if dataBytes ~= nil and validBits and blockAlign == meta.channels * bits / 8 and byteRate == meta.sampleRate * blockAlign and dataBytes % blockAlign == 0 then -- 135
			meta.durationSeconds = dataBytes / byteRate -- 138
		end -- 138
	end -- 138
	return meta -- 141
end -- 111
local function flacMetadata(data) -- 144
	if #data < 42 or text(data, 0, 4) ~= "fLaC" or byte(data, 4) % 128 ~= 0 or be(data, 5, 3) ~= 34 then -- 144
		return nil -- 146
	end -- 146
	local sampleRate = be(data, 18, 3) / 16 -- 147
	local rate = math.floor(sampleRate) -- 148
	local bits = byte(data, 20) % 2 * 16 + math.floor(byte(data, 21) / 16) + 1 -- 149
	if rate <= 0 or bits < 4 or bits > 32 then -- 149
		return nil -- 150
	end -- 150
	local samples = byte(data, 21) % 16 * 4294967296 + be(data, 22, 4) -- 151
	return { -- 152
		kind = "audio", -- 152
		format = "flac", -- 152
		codec = "flac", -- 152
		source = "header", -- 152
		sampleRate = rate, -- 152
		channels = math.floor(byte(data, 20) / 2) % 8 + 1, -- 153
		bitsPerSample = bits, -- 154
		durationSeconds = samples > 0 and samples / rate or nil -- 155
	} -- 155
end -- 144
local function oggMetadata(path, data, size) -- 158
	if #data < 28 or text(data, 0, 4) ~= "OggS" or byte(data, 4) ~= 0 or byte(data, 5) ~= 2 then -- 158
		return nil -- 159
	end -- 159
	local segments = byte(data, 26) -- 160
	local packet = 27 + segments -- 160
	if segments == 0 or packet + 19 > #data then -- 160
		return nil -- 161
	end -- 161
	local packetBytes = 0 -- 162
	local complete = false -- 162
	do -- 162
		local i = 0 -- 163
		while i < segments do -- 163
			local length = byte(data, 27 + i) -- 164
			packetBytes = packetBytes + length -- 165
			if length < 255 then -- 165
				complete = true -- 166
				break -- 166
			end -- 166
			i = i + 1 -- 163
		end -- 163
	end -- 163
	if not complete or packet + packetBytes > #data then -- 163
		return nil -- 168
	end -- 168
	local meta = {kind = "audio", format = "ogg", source = "header"} -- 169
	local preSkip = 0 -- 170
	if packetBytes == 30 and byte(data, packet) == 1 and text(data, packet + 1, 6) == "vorbis" and le(data, packet + 7, 4) == 0 and byte(data, packet + 29) % 2 == 1 then -- 170
		meta.codec = "vorbis" -- 173
		meta.channels = byte(data, packet + 11) -- 174
		meta.sampleRate = le(data, packet + 12, 4) -- 175
	elseif packetBytes >= 19 and text(data, packet, 8) == "OpusHead" and byte(data, packet + 8) <= 15 then -- 175
		meta.codec = "opus" -- 177
		meta.channels = byte(data, packet + 9) -- 178
		meta.sampleRate = 48000 -- 179
		preSkip = le(data, packet + 10, 2) -- 180
	else -- 180
		return nil -- 181
	end -- 181
	if meta.channels == nil or meta.channels <= 0 or meta.sampleRate == nil or meta.sampleRate <= 0 then -- 181
		return nil -- 182
	end -- 182
	if size > OGG_TAIL_MAX_FILE_BYTES then -- 182
		return meta -- 183
	end -- 183
	local tail = size <= #data and data or Content:read( -- 184
		path, -- 184
		math.max(0, size - HEADER_BYTES), -- 184
		HEADER_BYTES -- 184
	) -- 184
	local serial = le(data, 14, 4) -- 185
	do -- 185
		local offset = #tail - 27 -- 186
		while offset >= 0 do -- 186
			do -- 186
				if text(tail, offset, 4) ~= "OggS" or byte(tail, offset + 4) ~= 0 or math.floor(byte(tail, offset + 5) / 4) % 2 ~= 1 or le(tail, offset + 14, 4) ~= serial then -- 186
					goto __continue64 -- 188
				end -- 188
				local count = byte(tail, offset + 26) -- 189
				local ____end = offset + 27 + count -- 190
				if ____end > #tail then -- 190
					goto __continue64 -- 191
				end -- 191
				do -- 191
					local i = 0 -- 192
					while i < count do -- 192
						____end = ____end + byte(tail, offset + 27 + i) -- 192
						i = i + 1 -- 192
					end -- 192
				end -- 192
				local high = le(tail, offset + 10, 4) -- 193
				if ____end ~= #tail or high > 2097151 then -- 193
					goto __continue64 -- 194
				end -- 194
				local samples = high * 4294967296 + le(tail, offset + 6, 4) - preSkip -- 195
				if samples >= 0 then -- 195
					meta.durationSeconds = samples / meta.sampleRate -- 196
				end -- 196
				break -- 197
			end -- 197
			::__continue64:: -- 197
			offset = offset - 1 -- 186
		end -- 186
	end -- 186
	return meta -- 199
end -- 158
local function glbMetadata(data, size) -- 202
	if #data < 20 or text(data, 0, 4) ~= "glTF" or le(data, 4, 4) ~= 2 or le(data, 8, 4) ~= size then -- 202
		return nil -- 203
	end -- 203
	local length = le(data, 12, 4) -- 204
	if text(data, 16, 4) ~= "JSON" or length > size - 20 or length % 4 ~= 0 then -- 204
		return nil -- 205
	end -- 205
	local meta = {kind = "model", format = "glb", version = 2, source = "header"} -- 206
	if 20 + length <= #data then -- 206
		local doc = safeJsonDecode(text(data, 20, length)) -- 208
		if doc and type(doc) == "table" then -- 208
			local record = doc -- 210
			if __TS__ArrayIsArray(record.meshes) then -- 210
				meta.meshCount = #record.meshes -- 211
			end -- 211
			if __TS__ArrayIsArray(record.materials) then -- 211
				meta.materialCount = #record.materials -- 212
			end -- 212
			if __TS__ArrayIsArray(record.animations) then -- 212
				meta.animationCount = #record.animations -- 213
			end -- 213
		end -- 213
	end -- 213
	return meta -- 216
end -- 202
--- Header-derived facts only: never return raw bytes, tags, JSON bodies or decoded media.
function ____exports.readBinaryResourceMetadata(path, size) -- 220
	do -- 220
		local function ____catch(_) -- 220
			return true, {metadataMessage = "Binary metadata inspection failed; binary content remains unavailable."} -- 228
		end -- 228
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 228
			local data = Content:read( -- 222
				path, -- 222
				0, -- 222
				math.min(size, HEADER_BYTES) -- 222
			) -- 222
			if data == "" then -- 222
				return true, {metadataMessage = "Binary metadata could not be read."} -- 223
			end -- 223
			local metadata = imageMetadata(data, size) or wavMetadata(data, size) or flacMetadata(data) or oggMetadata(path, data, size) or glbMetadata(data, size) -- 224
			return true, metadata and ({metadata = metadata}) or ({metadataMessage = "Unsupported format, invalid header, or metadata beyond the bounded header scan."}) -- 226
		end) -- 226
		if not ____try then -- 226
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 226
		end -- 226
		if ____hasReturned then -- 226
			return ____returnValue -- 221
		end -- 221
	end -- 221
end -- 220
return ____exports -- 220