-- Collect Go's selected source files across the supported target matrix.
local targets = {{"darwin", "arm64"}, {"darwin", "amd64"}, {"ios", "arm64"}, {"ios", "amd64"},
    {"linux", "amd64"}, {"linux", "arm64"}, {"windows", "386"}, {"windows", "amd64"},
    {"android", "arm"}, {"android", "arm64"}, {"android", "386"}, {"android", "amd64"}}
local fields = {"GoFiles", "CgoFiles", "CFiles", "CXXFiles", "MFiles", "HFiles", "FFiles", "SFiles",
    "SwigFiles", "SwigCXXFiles", "SysoFiles", "EmbedFiles"}
local legal = {"LICENSE", "LICENSE.md", "LICENSE.txt", "COPYING", "COPYING.md", "NOTICE", "NOTICE.md",
    "PATENTS", "AUTHORS", "CONTRIBUTORS"}

function parse_json_stream(text)
    import("core.base.json")
    local result, start, depth, quoted, escaped = {}, nil, 0, false, false
    for index = 1, #text do
        local char = text:sub(index, index)
        if quoted then
            if escaped then escaped = false
            elseif char == "\\" then escaped = true
            elseif char == '"' then quoted = false end
        elseif char == '"' then quoted = true
        elseif char == "{" then
            if depth == 0 then start = index end
            depth = depth + 1
        elseif char == "}" then
            depth = depth - 1; assert(depth >= 0, "Invalid go list JSON stream")
            if depth == 0 then result[#result + 1] = json.decode(text:sub(start, index)); start = nil end
        elseif depth == 0 then assert(char:match("%s"), "Unexpected go list output") end
    end
    assert(depth == 0 and not quoted, "Incomplete go list JSON stream")
    return result
end

function collect(root, module_path, vendor)
    root = path.normalize(path.absolute(root))
    local keep = {}
    for _, target in ipairs(targets) do
        -- Source sync historically skips windows/amd64; keep that inventory stable.
        if vendor or target[1] ~= "windows" or target[2] ~= "amd64" then
            local envs = {GOOS = target[1], GOARCH = target[2], CGO_ENABLED = "1"}
            if vendor then envs.GOFLAGS = "-mod=vendor" end
            local output = os.iorunv("go", {"list", "-deps", "-json", "."}, {curdir = root, envs = envs})
            for _, package in ipairs(parse_json_stream(output)) do
                local directory = package.Dir and path.normalize(path.absolute(package.Dir))
                if directory and (directory == root or directory:startswith(root .. path.sep()))
                    and (not module_path or (package.Module and package.Module.Path == module_path)) then
                    for _, field in ipairs(fields) do
                        for _, name in ipairs(package[field] or {}) do keep[path.normalize(path.join(directory, name))] = true end
                    end
                    if not vendor then
                        for _, name in ipairs(legal) do keep[path.join(directory, name)] = true end
                    end
                end
            end
        end
    end
    return keep
end

function collect_source(source, destination, module_path)
    source = path.normalize(path.absolute(source))
    local keep = collect(source, module_path, false)
    for _, name in ipairs({"go.mod", "go.sum", "main.go", "wa.gomobile", "wa.def", "LICENSE", "LICENSE.md", "README.md"}) do
        keep[path.join(source, name)] = true
    end
    for file in pairs(keep) do
        if os.isfile(file) then
            local target = path.join(destination, path.relative(file, source))
            os.mkdir(path.directory(target)); os.cp(file, target)
        end
    end
end

function collect_vendor(root)
    root = path.normalize(path.absolute(root))
    local keep = collect(root, nil, true)
    for _, file in ipairs(os.files(path.join(root, "**"))) do
        if table.contains(legal, path.filename(file)) or path.filename(file) == "modules.txt" then keep[file] = true end
    end
    local vendor = path.join(root, "vendor")
    for _, file in ipairs(os.files(path.join(vendor, "**"))) do if not keep[file] then os.rm(file) end end
    local directories = os.dirs(path.join(vendor, "**"))
    table.sort(directories, function (a, b) return #a > #b end)
    for _, directory in ipairs(directories) do
        if #os.files(path.join(directory, "*")) == 0 and #os.dirs(path.join(directory, "*")) == 0 then os.rmdir(directory) end
    end
end
