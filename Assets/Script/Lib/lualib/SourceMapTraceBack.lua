local function __TS__SourceMapTraceBack(fileName, sourceMap)
	_G.__TS__sourcemap = _G.__TS__sourcemap or ({})
	_G.__TS__sourcemap[fileName] = sourceMap
	if _G.__TS__originalTraceback == nil then
		local originalTraceback = debug.traceback
		_G.__TS__originalTraceback = originalTraceback
		debug.traceback = function(thread, message, level)
			local trace
			if thread == nil and message == nil and level == nil then
				trace = originalTraceback()
			elseif __TS__StringIncludes(_VERSION, "Lua 5.0") then
				trace = originalTraceback((("[Level " .. tostring(level)) .. "] ") .. tostring(message))
			else
				trace = originalTraceback(thread, message, level)
			end
			if type(trace) ~= "string" then
				return trace
			end
			local function replacer(____, file, srcFile, line)
				local fileSourceMap = _G.__TS__sourcemap[file]
				if fileSourceMap ~= nil and fileSourceMap[line] ~= nil then
					local data = fileSourceMap[line]
					if type(data) == "number" then
						return (srcFile .. ":") .. tostring(data)
					end
					return (data.file .. ":") .. tostring(data.line)
				end
				return (file .. ":") .. line
			end
			local result = string.gsub(
				trace,
				"(%S+)%.lua:(%d+)",
				function(file, line) return replacer(nil, file .. ".lua", file .. ".ts", line) end
			)
			local function stringReplacer(____, file, line)
				local fileSourceMap = _G.__TS__sourcemap[file]
				if fileSourceMap ~= nil and fileSourceMap[line] ~= nil then
					local chunkName = (__TS__Match(file, "%[string \"([^\"]+)\"%]"))
					local sourceName = string.gsub(chunkName, ".lua$", ".ts")
					local data = fileSourceMap[line]
					if type(data) == "number" then
						return (sourceName .. ":") .. tostring(data)
					end
					return (data.file .. ":") .. tostring(data.line)
				end
				return (file .. ":") .. line
			end
			result = string.gsub(
				result,
				"(%[string \"[^\"]+\"%]):(%d+)",
				function(file, line) return stringReplacer(nil, file, line) end
			)
			return result
		end
	end
end
