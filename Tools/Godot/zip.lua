-- Inspect ZIP metadata in Lua before passing an archive to xmake's extractor.
local function integer(data, offset, count)
    local value = 0
    for index = count - 1, 0, -1 do value = value * 256 + assert(data:byte(offset + index), "Truncated ZIP") end
    return value
end
function entries(file)
    local C = import("common", {rootdir = os.scriptdir()})
    local stream = assert(io.open(file, "rb", {encoding = "binary"}))
    local total = os.filesize(file)
    local data = {}
    function data:sub(first, last)
        stream:seek("set", first - 1)
        local count = last - first + 1
        if count <= 0 then return "" end
        return assert(stream:read(count), "Truncated ZIP")
    end
    function data:byte(index) return self:sub(index, index):byte() end
    local function parse()
    local ending
    for index = total - 21, math.max(1, total - 65557), -1 do
        if data:sub(index, index + 3) == "PK\5\6" and index + 21 + integer(data, index + 20, 2) == total then ending = index; break end
    end
    assert(ending, "ZIP end directory not found")
    assert(integer(data, ending + 4, 2) == 0 and integer(data, ending + 6, 2) == 0, "Split ZIP archives are unsupported")
    local count, offset = integer(data, ending + 10, 2), integer(data, ending + 16, 4) + 1
    if count == 65535 or offset == 4294967296 then
        local locator = ending - 20
        assert(data:sub(locator, locator + 3) == "PK\6\7", "Missing ZIP64 locator")
        local record = integer(data, locator + 8, 8) + 1
        assert(data:sub(record, record + 3) == "PK\6\6", "Invalid ZIP64 directory")
        count, offset = integer(data, record + 32, 8), integer(data, record + 48, 8) + 1
    end
    assert(offset <= ending, "Invalid ZIP directory offset")
    local result, seen = {}, {}
    for _ = 1, count do
        assert(data:sub(offset, offset + 3) == "PK\1\2", "Invalid ZIP central directory")
        local length, extra, comment = integer(data, offset + 28, 2), integer(data, offset + 30, 2), integer(data, offset + 32, 2)
        local name = data:sub(offset + 46, offset + 45 + length)
        local directory = name:endswith("/")
        local clean = directory and name:sub(1, -2) or name
        C.safe_relative(clean)
        assert(not clean:find(":", 1, true) and not clean:find("[%z\1-\31]") and not seen[clean], "Unsafe/duplicate ZIP path")
        seen[clean] = true
        local flags, attributes = integer(data, offset + 8, 2), integer(data, offset + 38, 4)
        assert(flags % 2 == 0 and math.floor(attributes / 65536) % 65536 - math.floor(attributes / 65536) % 4096 ~= 40960,
            "Encrypted or symlink ZIP entry")
        local size = integer(data, offset + 24, 4)
        if size == 4294967295 then
            local position, limit = offset + 46 + length, offset + 46 + length + extra
            local found = false
            while position + 4 <= limit do
                local kind, bytes = integer(data, position, 2), integer(data, position + 2, 2)
                assert(position + 4 + bytes <= limit, "Truncated ZIP extra record")
                if kind == 1 then assert(bytes >= 8, "Truncated ZIP64 size"); size = integer(data, position + 4, 8); found = true; break end
                position = position + 4 + bytes
            end
            assert(found and size < 9007199254740992, "Invalid ZIP64 size")
        end
        result[#result + 1] = {name = name, directory = directory, bytes = size}
        offset = offset + 46 + length + extra + comment
        assert(offset <= ending, "ZIP central directory exceeds archive")
    end
    return result
    end
    local result
    try {function () result = parse() end,
        finally {function (ok, errors) stream:close(); if not ok then raise(errors) end end}}
    return result
end
function stored_archive(directory, output, names)
    local C = import("common", {rootdir = os.scriptdir()})
    import("core.base.bit")
    local function le(value, size)
        local chars = {}; for index = 1, size do chars[index] = string.char(value % 256); value = math.floor(value / 256) end
        assert(value == 0, "ZIP integer overflow"); return table.concat(chars)
    end
    local crc_table = {}
    for value = 0, 255 do
        local crc = value
        for _ = 1, 8 do crc = crc % 2 == 1 and bit.bxor(bit.rshift(crc, 1), 3988292384) or bit.rshift(crc, 1) end
        crc_table[value] = crc
    end
    local stream = assert(io.open(output, "wb", {encoding = "binary"}))
    local central, offset = {}, 0
    try {function ()
        for _, name in ipairs(names) do
            local file = C.safe_file(directory, name); local size = os.filesize(file)
            local function chunks(action)
                local input = assert(io.open(file, "rb", {encoding = "binary"}))
                try {function () local remaining = size; while remaining > 0 do local data = assert(input:read(math.min(remaining, 1024 * 1024))); remaining = remaining - #data; action(data) end end,
                    finally {function (ok, errors) input:close(); if not ok then raise(errors) end end}}
            end
            local crc = 4294967295
            chunks(function (data) for index = 1, #data do crc = bit.bxor(bit.rshift(crc, 8), crc_table[bit.band(bit.bxor(crc, data:byte(index)), 255)]) end end)
            crc = bit.bxor(crc, 4294967295) % 4294967296
            local flags = name:find("[\128-\255]") and 2048 or 0
            local extra = le(1, 2) .. le(16, 2) .. le(size, 8) .. le(size, 8)
            local header = "PK\3\4" .. le(45, 2) .. le(flags, 2) .. le(0, 2) .. le(0, 2) .. le(33, 2) .. le(crc, 4)
                .. le(4294967295, 4) .. le(4294967295, 4) .. le(#name, 2) .. le(#extra, 2) .. name .. extra
            stream:write(header); chunks(function (data) stream:write(data) end)
            local metadata = ""
            if size >= 4294967295 then metadata = le(size, 8) .. le(size, 8) end
            if offset >= 4294967295 then metadata = metadata .. le(offset, 8) end
            if metadata ~= "" then metadata = le(1, 2) .. le(#metadata, 2) .. metadata end
            central[#central + 1] = "PK\1\2" .. le(813, 2) .. le(45, 2) .. le(flags, 2) .. le(0, 2) .. le(0, 2) .. le(33, 2) .. le(crc, 4)
                .. le(math.min(size, 4294967295), 4) .. le(math.min(size, 4294967295), 4) .. le(#name, 2) .. le(#metadata, 2)
                .. le(0, 2) .. le(0, 2) .. le(0, 2) .. le(2175008768, 4) .. le(math.min(offset, 4294967295), 4) .. name .. metadata
            offset = offset + #header + size
        end
        local directory_text = table.concat(central); stream:write(directory_text)
        if #names >= 65535 or offset >= 4294967295 or #directory_text >= 4294967295 then
            stream:write("PK\6\6" .. le(44, 8) .. le(813, 2) .. le(45, 2) .. le(0, 4) .. le(0, 4) .. le(#names, 8) .. le(#names, 8) .. le(#directory_text, 8) .. le(offset, 8))
            stream:write("PK\6\7" .. le(0, 4) .. le(offset + #directory_text, 8) .. le(1, 4))
        end
        stream:write("PK\5\6" .. le(0, 2) .. le(0, 2) .. le(math.min(#names, 65535), 2) .. le(math.min(#names, 65535), 2)
            .. le(math.min(#directory_text, 4294967295), 4) .. le(math.min(offset, 4294967295), 4) .. le(0, 2))
    end, finally {function (ok, errors) stream:close(); if not ok then os.tryrm(output); raise(errors) end end}}
end
function extract(file, destination, max_bytes, max_files)
    local C = import("common", {rootdir = os.scriptdir()})
    local inventory, total = entries(file), 0
    assert(#inventory <= (max_files or 100000), "ZIP exceeds file limit")
    for _, item in ipairs(inventory) do total = total + item.bytes end
    assert(total <= (max_bytes or 4 * 1024 ^ 3), "ZIP exceeds expanded size limit")
    C.extract(file, destination, {extension = ".zip"})
    for _, item in ipairs(inventory) do
        if not item.directory then assert(os.filesize(C.safe_file(destination, item.name)) == item.bytes, "Extracted ZIP size differs") end
    end
    return inventory
end
function archive(directory, output, names)
    local A = import("utils.archive")
    local files = names
    if not files then
        files = {}; for _, file in ipairs(os.files(path.join(directory, "**"))) do files[#files + 1] = path.relative(file, directory) end
        table.sort(files)
    end
    A.archive(output, files, {curdir = directory, extension = ".zip"})
end
