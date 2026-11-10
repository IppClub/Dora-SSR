-- Package one x64 backend from a single verified staging directory.
local C = import("Tools.Godot.common", {rootdir = path.absolute(path.join(os.scriptdir(), "../.."))})
local UPGRADE = "6C06B597-3476-5181-AFBD-270E98D79035"
local function uuid(name)
    import("core.base.bytes")
    local namespace = ("6ba7b8119dad11d180b400c04fd430c8"):gsub("%x%x", function (pair) return string.char(tonumber(pair, 16)) end)
    local digest = hash.sha1(bytes(namespace .. name)):sub(1, 32)
    digest = digest:sub(1, 12) .. "5" .. digest:sub(14, 16) .. ("%x"):format(tonumber(digest:sub(17, 17), 16) % 4 + 8) .. digest:sub(18)
    return digest:sub(1, 8) .. "-" .. digest:sub(9, 12) .. "-" .. digest:sub(13, 16) .. "-" .. digest:sub(17, 20) .. "-" .. digest:sub(21)
end
local function escape(value) return tostring(value):gsub("&", "&amp;"):gsub('"', "&quot;"):gsub("<", "&lt;"):gsub(">", "&gt;") end
local function element(parent, name, attrs)
    local value = {name = name, attrs = attrs or {}, children = {}}
    if parent then parent.children[#parent.children + 1] = value end
    return value
end
local function xml(value)
    local result = {"<" .. value.name}
    for _, name in ipairs(C.keys(value.attrs)) do result[#result + 1] = " " .. name .. '="' .. escape(value.attrs[name]) .. '"' end
    if #value.children == 0 then return table.concat(result) .. "/>" end
    result[#result + 1] = ">"; for _, child in ipairs(value.children) do result[#result + 1] = xml(child) end
    result[#result + 1] = "</" .. value.name .. ">"; return table.concat(result)
end
function pe_x64(file)
    local stream = assert(io.open(file, "rb", {encoding = "binary"}))
    try {function ()
        assert(stream:read(2) == "MZ", "Not a Windows executable: " .. file)
        stream:seek("set", 60)
        local bytes = assert(stream:read(4), "Truncated PE")
        local a, b, c, d = bytes:byte(1, 4)
        stream:seek("set", a + b * 256 + c * 65536 + d * 16777216)
        assert(stream:read(6) == "PE\0\0\100\134", "Expected x64 PE: " .. file)
    end, finally {function (ok, errors) stream:close(); if not ok then raise(errors) end end}}
end
function package_windows(stage, output, backend, format, version, mode)
    stage, output = C.real(stage), C.real(output)
    C.choice(backend, {"d3d12", "wgl"}); C.choice(format, {"zip", "msi", "both"}); mode = C.choice(mode or "release", {"debug", "release"})
    version = version or C.load(path.join(C.root(), "Tools/dora-dora/package.json")).doraVersion
        or C.read(path.join(C.root(), "Source/Basic/Application.cpp")):match('DORA_VERSION%s+"([%d%.]+)"')
    local normalized, tail = assert(version):gsub("^v", ""):match("^(%d+%.%d+%.%d+)(.*)$")
    assert(normalized and (tail == "" or tail:startswith(".")), "Invalid MSI version"); version = normalized; os.mkdir(output)
    for _, name in ipairs({"Dora.exe", "wa.dll"}) do pe_x64(path.join(stage, name)) end
    local manifest_file = path.join(stage, "GodotRuntimeNotices/manifest.json")
    if os.isfile(manifest_file) then
        pe_x64(path.join(stage, "dora_godot.dll"))
        local manifest = C.load(manifest_file)
        assert(manifest.graphics_backend == backend and manifest.build_target == "template_" .. mode, "Wrong Godot backend or build mode")
        assert(C.equal(manifest.architectures, {"x86_64"}) and C.digest(path.join(stage, "dora_godot.dll")) == manifest.library_sha256, "Godot DLL architecture or digest mismatch")
        assert(type(manifest.artifacts) == "table" and not table.empty(manifest.artifacts), "Missing Godot runtime artifact inventory")
        for name, digest in pairs(manifest.artifacts) do if name ~= manifest.library then assert(C.digest(C.safe_file(path.directory(manifest_file), name)) == digest, "Missing or changed runtime artifact: " .. name) end end
    else assert(not os.exists(path.join(stage, "dora_godot.dll")), "Godot DLL has no runtime manifest") end
    C.save(path.join(stage, "DoraDistribution.json"), {schema = 1, architecture = "x64", backend = backend, version = version})
    assert(not os.exists(path.join(stage, "DoraInstallation.json")), "MSI marker must not be present in portable staging")
    local files, names = {}, {}
    for _, item in ipairs(table.join(C.files(stage), os.dirs(path.join(stage, "**")))) do assert(not os.islink(item), "Package contains symbolic links") end
    for _, file in ipairs(C.files(stage)) do
        local name = path.filename(file)
        if name ~= ".DS_Store" and not name:startswith("._") then files[#files + 1] = file; names[#names + 1] = C.relative(file, stage) end
    end
    local stem = "dora-ssr-v" .. version .. "-windows-x64" .. (backend == "wgl" and "-opengl" or "") .. (mode == "debug" and "-debug" or "")
    if format ~= "msi" then import("Tools.Godot.zip", {rootdir = C.root()}).archive(stage, path.join(output, stem .. ".zip"), names) end
    if format ~= "zip" then
        local work = path.join(output, "installer"); os.mkdir(work)
        local marker = path.join(work, "DoraInstallation.json"); C.save(marker, {schema = 1, format = "msi", upgradeCode = UPGRADE})
        local identity = {}; for _, file in ipairs(files) do identity[#identity + 1] = C.relative(file, stage) .. ":" .. C.digest(file) end
        identity = C.data_digest(table.concat(identity, "\n"))
        local wix = element(nil, "Wix", {xmlns = "http://wixtoolset.org/schemas/v4/wxs", ["xmlns:ui"] = "http://wixtoolset.org/schemas/v4/wxs/ui"})
        local product = element(wix, "Package", {Name = "Dora SSR", Manufacturer = "IppClub", Version = version, Language = "1033", Scope = "perUser", UpgradeCode = UPGRADE,
            ProductCode = uuid("https://dora-ssr.net/msi/" .. version .. "/" .. backend .. "/" .. identity)})
        element(product, "MajorUpgrade", {AllowSameVersionUpgrades = "yes", DowngradeErrorMessage = "A newer Dora SSR version is already installed."})
        element(product, "MediaTemplate", {EmbedCab = "yes", CompressionLevel = "high"})
        element(product, "Property", {Id = "ARPCOMMENTS", Value = "Dora SSR x64 " .. (backend == "wgl" and "OpenGL" or "D3D12")})
        local localdata = element(product, "StandardDirectory", {Id = "LocalAppDataFolder"})
        local programs = element(localdata, "Directory", {Id = "DoraPrograms", Name = "Programs"})
        local install = element(programs, "Directory", {Id = "INSTALLFOLDER", Name = "Dora SSR"})
        local feature = element(product, "Feature", {Id = "Main", Title = "Dora SSR", Level = "1"})
        local directories = {[""] = install}
        local function ident(prefix, value) return prefix .. C.data_digest(value):sub(1, 28) end
        local function directory(relative)
            if directories[relative] then return directories[relative] end
            local parent = relative:match("^(.*)/") or ""
            directories[relative] = element(directory(parent), "Directory", {Id = ident("D", relative), Name = path.filename(relative)})
            return directories[relative]
        end
        local function component(parent, key)
            local id = ident("C", key)
            local value = element(parent, "Component", {Id = id, Guid = uuid("https://dora-ssr.net/component/" .. key), Bitness = "always64"})
            element(value, "RegistryValue", {Root = "HKCU", Key = "Software\\IppClub\\DoraSSR\\Installer", Name = id, Type = "integer", Value = "1", KeyPath = "yes"})
            element(feature, "ComponentRef", {Id = id}); return value
        end
        for _, file in ipairs(table.join(files, {marker})) do
            local relative = file == marker and "DoraInstallation.json" or C.relative(file, stage)
            local parent = relative:match("^(.*)/") or ""
            element(component(directory(parent), relative), "File", {Id = ident("F", relative), Source = file, Name = path.filename(file)})
        end
        for _, relative in ipairs(C.keys(directories)) do element(component(directories[relative], "directory:" .. relative), "RemoveFolder", {Id = ident("R", relative), On = "uninstall"}) end
        local menu = element(element(product, "StandardDirectory", {Id = "ProgramMenuFolder"}), "Directory", {Id = "DoraMenu", Name = "Dora SSR"})
        local shortcut = component(menu, "shortcut")
        element(shortcut, "Shortcut", {Id = "DoraShortcut", Name = "Dora SSR", Target = "[INSTALLFOLDER]Dora.exe", WorkingDirectory = "INSTALLFOLDER", Arguments = '--asset "[INSTALLFOLDER]."'})
        element(shortcut, "RemoveFolder", {Id = "RemoveMenu", On = "uninstall"})
        element(product, "ui:WixUI", {Id = "WixUI_InstallDir", InstallDirectory = "INSTALLFOLDER"})
        local license = path.join(work, "license.rtf")
        local raw = C.read(path.join(C.root(), "LICENSE.txt")):gsub("\\", "\\\\"):gsub("{", "\\{"):gsub("}", "\\}"):gsub("\n", "\\par\n")
        C.write(license, "{\\rtf1\\ansi " .. raw .. "}"); element(product, "WixVariable", {Id = "WixUILicenseRtf", Value = license})
        local source = path.join(work, "Dora.wxs"); C.write(source, '<?xml version="1.0" encoding="UTF-8"?>\n' .. xml(wix))
        C.run("wix", {"build", source, "-arch", "x64", "-ext", "WixToolset.UI.wixext", "-o", path.join(output, stem .. ".msi")})
    end
    local hashes, sums = {}, {}
    for _, file in ipairs(os.files(path.join(output, stem .. ".*"))) do if table.contains({".zip", ".msi"}, path.extension(file)) then hashes[path.filename(file)] = C.digest(file) end end
    for _, name in ipairs(C.keys(hashes)) do sums[#sums + 1] = hashes[name] .. "  " .. name .. "\n" end
    C.write(path.join(output, "SHA256SUMS"), table.concat(sums)); return hashes
end
function main(...)
    local args = C.args({...}, {stage = "value", output = "value", backend = "value", format = "value", version = "value", mode = "value"})
    import("core.base.json"); print(C.serialize(package_windows(C.required(args, "stage"), C.required(args, "output"), C.required(args, "backend"), args.format or "both", args.version, args.mode)))
end
