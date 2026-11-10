-- Data-only readers for upstream templates; no Python evaluator/interpreter.
function unescape(text)
    return (text:gsub("\\(.)", {n = "\n", r = "\r", t = "\t", a = "\7", b = "\8", f = "\12", v = "\11", ['\\'] = '\\', ['"'] = '"', ["'"] = "'", ['\n'] = ''}))
end
function literals(file)
    local text = assert(io.readfile(file))
    local result = {}
    for value in text:gmatch('"""(.-)"""') do result[#result + 1] = unescape(value) end
    return result
end
function named(file, name)
    local text = assert(io.readfile(file))
    return unescape(assert(text:match(name .. '%s*=%s*"""(.-)"""'), "Missing upstream template: " .. name))
end
function replace(text, before, after)
    local pattern = before:gsub("(%W)", "%%%1")
    return (text:gsub(pattern, function () return after end))
end
function render_template(text, values)
    text = replace(replace(text, "{{", "\1"), "}}", "\2")
    text = text:gsub("{(.-)}", function (name) return tostring(assert(values[name], "Unknown template field: " .. name)) end)
    return replace(replace(text, "\1", "{"), "\2", "}")
end
function escaped(value)
    return (value:gsub('[\\"\7\8\12\n\r\t\11]', {['\\'] = '\\\\', ['"'] = '\\"', ['\7'] = '\\a', ['\8'] = '\\b', ['\12'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', ['\11'] = '\\v'}))
end
function raw(value)
    if type(value) == "table" then value = table.concat(value, "\n") .. "\n" end
    local segments, offset = {}, 1
    while offset <= #value + 1 do
        local segment = value:sub(offset, offset + 16383)
        local final = #segment < 16384
        if #segment == 16384 then
            local last
            local start = 1
            while true do local found = segment:find("\n\n", start, true); if not found then break end; last = found; start = found + 1 end
            if last then segment = segment:sub(1, last)
            else
                local index = #segment
                while index > 0 and segment:byte(index) >= 128 and segment:byte(index) < 192 do index = index - 1 end
                local byte = segment:byte(index)
                if byte and byte >= 192 then
                    local size = byte < 224 and 2 or byte < 240 and 3 or 4
                    if index + size - 1 > #segment then segment = segment:sub(1, index - 1) end
                end
            end
        end
        segments[#segments + 1] = 'R"<!>(' .. segment .. ')<!>"'; offset = offset + #segment
        if final then break end
    end
    return #segments == 1 and segments[1] or "(" .. table.concat(segments, " ") .. ")"
end
function buffer(data, indent)
    local words = {}; for index = 1, #data do words[#words + 1] = tostring(data:byte(index)) end
    local text, lines = table.concat(words, ", "), {}
    local width = 120 - (indent or 0) - 1
    while text:find(", ", 1, true) do
        local last = 0
        for index = 1, width + 1 do if text:sub(index, index + 1) == ", " then last = index end end
        if last == 0 then break end
        lines[#lines + 1] = string.rep("\t", indent or 0) .. text:sub(1, last)
        text = text:sub(last + 2)
    end
    lines[#lines + 1] = text
    return table.concat(lines, "\n")
end
function wrapped(root, filename, body)
    local title = path.filename(filename)
    local template = named(path.join(root, "methods.py"), "TEMPLATE")
    local text = template:format(title .. string.rep(" ", math.max(0, 70 - #title)))
        .. "\n/* THIS FILE IS GENERATED. EDITS WILL BE LOST. */\n\n"
    if filename:endswith(".h") or filename:endswith(".inc") then text = text .. "#pragma once\n\n" end
    return text .. (body:trim() ~= "" and body:trim() or "/* NO CONTENT */") .. "\n"
end
function compressed(file)
    local C = import("common", {rootdir = os.scriptdir()})
    import("lib.detect.find_tool")
    local temporary = os.tmpfile() .. ".gz"
    local result
    try {function ()
        local gzip = find_tool("gzip")
        if gzip then
            os.runv(gzip.program, {"-n", "-9", "-c", file}, {stdout = temporary})
        else
            local seven = assert(find_tool("7z"), "Godot codegen requires gzip or 7z for Deflate compression")
            os.tryrm(temporary)
            os.runv(seven.program, {"a", "-tgzip", "-mx=9", temporary, file})
        end
        local data = C.read(temporary)
        assert(data:sub(1, 3) == "\31\139\8", "Expected gzip Deflate stream")
        local flags, offset = data:byte(4), 11
        if math.floor(flags / 4) % 2 == 1 then local size = data:byte(offset) + data:byte(offset + 1) * 256; offset = offset + 2 + size end
        for _, bit in ipairs({8, 16}) do if math.floor(flags / bit) % 2 == 1 then offset = assert(data:find("\0", offset, true)) + 1 end end
        if math.floor(flags / 2) % 2 == 1 then offset = offset + 2 end
        local input, a, b = C.read(file), 1, 0
        for index = 1, #input do a = (a + input:byte(index)) % 65521; b = (b + a) % 65521 end
        local checksum = b * 65536 + a
        result = "\120\218" .. data:sub(offset, -9) .. string.char(math.floor(checksum / 16777216), math.floor(checksum / 65536) % 256, math.floor(checksum / 256) % 256, checksum % 256)
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    return result
end
