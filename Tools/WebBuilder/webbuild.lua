-- Template-based Web exports; engine chunks remain byte-for-byte unchanged.
local C = import("Tools.Godot.common", {rootdir = path.absolute(path.join(os.scriptdir(), "../.."))})
local Z = import("Tools.Godot.zip", {rootdir = C.root()})
local function decode(value) import("core.base.json"); return json.decode(value) end
local function encode(value) return C.serialize(value, true) end
local function unquote(value) return (value:gsub("%%(%x%x)", function (byte) return string.char(tonumber(byte, 16)) end)) end
local function quote(value) return (value:gsub("[^A-Za-z0-9_%.%-%~!%*'()/]", function (byte) return ("%%%02X"):format(byte:byte()) end)) end
local function validate(name)
    local valid = type(name) == "string" and name ~= "" and not name:find("\\", 1, true) and not name:find("[%z\1-\31]") and not name:match("^%a:") and not name:startswith("/") and not name:find("//", 1, true) and not name:endswith("/")
    for part in name:gmatch("[^/]+") do if part == "." or part == ".." then valid = false end end
    assert(valid, "invalid package path: " .. name)
end
local function read(root, name) validate(name); return C.read(C.safe_file(root, name)) end
local function config(root)
    local body, encoded = read(root, "html-loader.js"):match("^(.*}%)%()(%{.*%})%);?%s*$")
    assert(body and encoded, "Template loader trailing config JSON not found")
    return body, decode(encoded)
end
local function with_directory(input, action)
    if os.isdir(input) then return action(C.real(input)) end
    assert(os.isfile(input), "Expected an export ZIP or directory")
    local temporary, result = os.tmpfile() .. "-web-template", nil
    try {function () Z.extract(input, temporary); result = action(temporary) end,
        finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    return result
end
function apply_compat_patches(html)
    local U = import("Tools.Godot.codegen_util", {rootdir = C.root()})
    html = U.replace(html, '<meta name="viewport" content="width=device-width,initial-scale=1">', '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">')
    html = U.replace(html, 'canvas { display: block; }', 'canvas { display: block; touch-action: none; -webkit-user-select: none; user-select: none; -webkit-touch-callout: none; -webkit-tap-highlight-color: transparent; }')
    local patch = '<script>(function(){var u=function(){try{window.DoraWebPlatform&&DoraWebPlatform.unlockAudio&&DoraWebPlatform.unlockAudio()}catch(e){}try{window.Module&&Module.doraAudio&&Module.doraAudio.resume&&Module.doraAudio.resume()}catch(e){}};'
        .. "['pointerdown','touchstart','click','keydown'].forEach(function(ev){window.addEventListener(ev,u,{passive:true})});" .. '})();</script></body>'
    return (html:gsub('</body>', function () return patch end, 1))
end
function verify(input, quiet)
    local problems = with_directory(input, function (root)
        local runtime = decode(read(root, "runtime.json"))
        local issues, actual = {}, {}
        for _, file in ipairs(C.files(root)) do local name = C.relative(file, root); if name ~= "runtime.json" then actual[name] = true end end
        for name, meta in pairs(runtime.files) do
            validate(name)
            if not actual[name] then issues[#issues + 1] = "Missing runtime file: " .. name
            else local data = read(root, name); if #data ~= meta.size or C.data_digest(data) ~= meta.sha256 then issues[#issues + 1] = "content mismatch: " .. name end end
            actual[name] = nil
        end
        if not table.empty(actual) then issues[#issues + 1] = "Unlisted runtime files" end
        local _, loader = config(root)
        for _, item in ipairs(loader.manifest.files) do
            validate(item.path)
            local url = unquote(item.url)
            local record = loader.records[url]
            if not record then issues[#issues + 1] = "Missing delivery record: " .. item.path
            else
                local script = read(root, record.script)
                local encoded_url, payload = script:match('^DoraHtmlPackage%.deliver%((".-"),("[A-Za-z0-9+/=]*")%);%s*$')
                if not encoded_url or decode(encoded_url) ~= url then issues[#issues + 1] = "invalid project delivery: " .. item.path
                else
                    import("core.base.base64")
                    local data = base64.decode(decode(payload)):str()
                    for _, meta in ipairs({item, record}) do if #data ~= meta.size or C.data_digest(data) ~= meta.sha256 then issues[#issues + 1] = "project content mismatch: " .. item.path end end
                end
            end
        end
        return issues
    end)
    if not quiet then print(#problems == 0 and "VERIFY OK: " .. input or "VERIFY FAIL: " .. table.concat(problems, "; ")) end
    return problems
end
function build(args)
    return with_directory(C.required(args, "template"), function (root)
        local body, original = config(root)
        local runtime = decode(read(root, "runtime.json"))
        local engine_version = (original.manifest or {}).engineVersion or runtime.engineVersion
        assert(engine_version and original.records and not table.empty(original.records), "Template engine metadata missing")
        local records, scripts, last = {}, {}, -1
        for url, record in pairs(original.records) do
            if not url:startswith("assets/") then records[url] = record; scripts[record.script] = true; last = math.max(last, assert(tonumber(record.script:match("(%d+)%.js$")))) end
        end
        local project, order = {}, {}
        local function add(name, data) validate(name); if project[name] == nil then order[#order + 1] = name end; project[name] = data end
        if args.audio then
            assert(os.isdir(args.audio), "audio directory not found")
            local files = os.files(path.join(args.audio, "*")); table.sort(files)
            for _, file in ipairs(files) do if file:lower():endswith(".wav") then add("Audio/" .. path.filename(file), C.read(file)) end end
        end
        for _, extra in ipairs(args.extra or {}) do
            if os.isfile(extra) then add(path.filename(extra), C.read(extra))
            else assert(os.isdir(extra), "Extra asset missing: " .. extra); for _, file in ipairs(C.files(extra)) do add(path.filename(path.normalize(extra)) .. "/" .. C.relative(file, extra), C.read(file)) end end
        end
        local entry = C.read(C.required(args, "entry"))
        if args["entry-src"] then add(args["entry-src"], entry) end
        add("init.lua", entry)
        local lualib = args.lualib or "auto"
        if lualib ~= "none" then
            local file = lualib == "auto" and path.join(path.directory(C.real(args.entry)), "lualib_bundle.lua") or lualib
            if os.isfile(file) then add("lualib_bundle.lua", C.read(file)) else assert(lualib == "auto", "Lualib bundle missing") end
        end
        local files, manifest = {}, {}
        for _, name in ipairs({"dora-player-runtime.js", "dora-web-features.json", "dora-logo.png", "LICENSE-Dora.txt", "LICENSES.3rdparty.md", "NOTICE.txt", "README-Web.txt", "index.html"}) do if os.isfile(path.join(root, name)) then files[name] = read(root, name) end end
        for name in pairs(scripts) do files[name] = read(root, name) end
        import("core.base.base64")
        for index, name in ipairs(order) do
            local data = project[name]; local digest = C.data_digest(data)
            local url, script = "assets/" .. digest .. "/" .. name, "html-assets/" .. (last + index) .. ".js"
            records[url] = {script = script, size = #data, sha256 = digest}
            manifest[#manifest + 1] = {path = name, url = quote(url), size = #data, sha256 = digest, startup = true}
            files[script] = 'DoraHtmlPackage.deliver(' .. encode(url) .. ',"' .. base64.encode(data) .. '");\n'
        end
        files["html-loader.js"] = body .. encode({manifest = {format = "dora-web-game", version = 1, engineVersion = engine_version, profile = "dora-preset", entry = "init.lua", files = manifest}, records = records}) .. ');'
        if not args["no-compat-patches"] then files["index.html"] = apply_compat_patches(assert(files["index.html"])) end
        local inventory = {}; for name, data in pairs(files) do inventory[name] = {size = #data, sha256 = C.data_digest(data)} end
        files["runtime.json"] = encode({version = 1, engineVersion = engine_version, sourceFingerprint = runtime.sourceFingerprint or runtime.sourceCommit or engine_version, sourceCommit = runtime.sourceCommit, files = inventory, format = "html"})
        local output = C.real(C.required(args, "out"))
        assert(not os.exists(output) or (os.isdir(output) and #os.files(path.join(output, "*")) == 0 and #os.dirs(path.join(output, "*")) == 0), "output directory must be empty")
        os.mkdir(output); for name, data in pairs(files) do C.write(path.join(output, name), data) end
        if args.zip then Z.archive(output, C.real(args.zip), C.keys(files)) end
        if not args.quiet then print("built %d files (engine %s, %d project files) -> %s", #C.keys(files), engine_version, #order, output) end
        return files
    end)
end
function main(...)
    local args = C.args({...}, {template = "value", entry = "value", out = "value", zip = "value", audio = "value", extra = "many", ["entry-src"] = "value", lualib = "value", ["no-compat-patches"] = "flag", quiet = "flag"})
    build(args); assert(#verify(args.zip or args.out, args.quiet) == 0, "Web package verification failed")
end
