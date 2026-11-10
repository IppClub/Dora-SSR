-- Data-only projects; editor work stays in owned copies of author repositories.
local C = import("common", {rootdir = os.scriptdir()})
local PLATFORMS = {"macOS", "Linux", "Windows Desktop", "Android", "iOS", "Web"}
local SKIP = {[".git"] = true, [".godot"] = true, [".svn"] = true, [".hg"] = true}
function constants() return {GAME_FORMAT = "dora-godot-game", GODOT_VERSION = {4, 7}, PLATFORMS = PLATFORMS} end
function digest(file) return C.digest(file) end
function write_json(file, value) C.save(file, value) end
local function within(file, parent) file, parent = C.real(file), C.real(parent); return file == parent or file:startswith(parent .. path.sep()) end
function source_files(root)
    local result = {}
    local function visit(directory)
        local entries = os.filedirs(path.join(directory, "*")); table.sort(entries)
        for _, file in ipairs(entries) do
            local name = path.filename(file)
            if not (SKIP[name] and os.isdir(file)) and name ~= ".DS_Store" and name ~= ".git" then
                assert(not os.islink(file), "Project symlinks must be materialized before delivery: " .. file)
                if os.isdir(file) then visit(file) else assert(os.isfile(file), "Project contains a non-regular file"); result[#result + 1] = file end
            end
        end
    end
    visit(root); return result
end
function fingerprint(root) return C.snapshot(root, source_files(root)) end
function find_project(source, selection)
    source = C.real(source)
    if os.isfile(source) and path.filename(source) == "project.godot" then assert(not selection, "--project is only valid with a repository directory"); return path.directory(source) end
    assert(os.isdir(source), "Expected a project.godot file or repository directory")
    if selection then
        local chosen = C.real(path.join(source, selection)); assert(within(chosen, source), "Selected project escapes its repository")
        if path.filename(chosen) == "project.godot" then chosen = path.directory(chosen) end
        assert(os.isfile(path.join(chosen, "project.godot")), "Selected directory has no project.godot"); return chosen
    end
    if os.isfile(path.join(source, "project.godot")) then return source end
    local projects = {}
    local function visit(directory)
        if os.isfile(path.join(directory, "project.godot")) then projects[#projects + 1] = directory; assert(#projects <= 128, "Too many projects; select --project"); return end
        local dirs = os.dirs(path.join(directory, "*")); table.sort(dirs)
        for _, child in ipairs(dirs) do if not SKIP[path.filename(child)] and not os.islink(child) then visit(child) end end
    end
    visit(source); assert(#projects == 1, "Select a project with --project; candidates: " .. table.concat(projects, ", ")); return projects[1]
end
function config_strings(text)
    import("core.base.json")
    local result, section = {}, ""
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local name = line:match("^%s*%[([^%]]+)%]%s*$")
        if name then section = name else
            local key, encoded = line:match('^%s*([^=;]+)%s*=%s*(".*")%s*$')
            if key then try {function () result[section .. "/" .. key:trim()] = json.decode(encoded) end} end
        end
    end
    return result
end
function inspect_project(source, selection)
    local project = find_project(source, selection)
    local text = C.read(path.join(project, "project.godot")):gsub("^\239\187\191", "")
    assert(("\n" .. text .. "\n"):match("\n%s*config_version%s*=%s*5%s*\n"), "This player accepts Godot 4 projects; convert Godot 3 projects first")
    local metadata, files = config_strings(text), source_files(project)
    local extensions = C.array(); for _, file in ipairs(files) do if file:endswith(".gdextension") then extensions[#extensions + 1] = C.relative(file, project) end end
    assert(metadata["application/run/main_scene"], "The project has no application/run/main_scene")
    local git
    try {function ()
        os.iorunv("git", {"-C", project, "ls-files", "--error-unmatch", "--", "project.godot"}, {timeout = 15000})
        local revision = os.iorunv("git", {"-C", project, "rev-parse", "HEAD"}, {timeout = 15000}):trim()
        local top = os.iorunv("git", {"-C", project, "rev-parse", "--show-toplevel"}, {timeout = 15000}):trim()
        local relative = C.relative(project, top)
        git = {revision = revision, subdirectory = relative, dirty = os.iorunv("git", {"-C", top, "status", "--porcelain", "--", relative}, {timeout = 15000}):trim() ~= ""}
    end}
    local features = text:match("config/features%s*=%s*PackedStringArray%((.-)%)") or ""
    return {kind = "project", project = project, title = metadata["application/config/name"] or path.filename(project), main_scene = metadata["application/run/main_scene"],
        rendering_method = metadata["rendering/renderer/rendering_method"] or "default", requires_csharp = features:find('"C#"', 1, true) ~= nil,
        native_extensions = extensions, import_cache_present = os.isdir(path.join(project, ".godot/imported")), source_files = #files, git = git or C.null()}
end
function require_supported(info)
    assert(not info.requires_csharp, "Godot C#/Mono is disabled in Dora; this project requires C#")
    assert(#info.native_extensions == 0, "Native GDExtension delivery needs platform sidecars; unsupported in this data-only package")
end
function run_command(command, log, timeout, options) import("command_job", {rootdir = os.scriptdir()}).run_command(command, log, timeout, options) end
function editor_identity(executable)
    import("lib.detect.find_tool")
    local file = C.real((find_tool(executable) or {}).program or executable)
    assert(os.isfile(file), "Set --godot or DORA_GODOT_EDITOR to a Godot 4.7 editor executable")
    local version = os.iorunv(file, {"--version"}, {timeout = 30000}):trim()
    local major, minor, suffix = version:match("^(%d+)%.(%d+)%.%d+%.stable(.*)$")
    if not major then major, minor, suffix = version:match("^(%d+)%.(%d+)%.stable(.*)$") end
    assert(major == "4" and minor == "7" and (suffix == "" or suffix:startswith(".")), "The importer must be Godot 4.7 stable; found " .. version)
    return {path = file, version = version, sha256 = C.digest(file)}
end
function prepare(source, output, editor, selection, timeout)
    local info = inspect_project(source, selection); require_supported(info)
    assert(not os.islink(output), "Use a new preparation output directory")
    output = C.real(output); assert(not os.exists(output), "Use a new preparation output directory")
    local original = info.project
    assert(not within(output, os.isdir(source) and source or original), "Preparation output must be outside the author project/repository")
    local identity, before = editor_identity(editor), fingerprint(original)
    local project = path.join(output, "project"); os.mkdir(project)
    for name in pairs(before) do C.copy(path.join(original, name), path.join(project, name)) end
    run_command({identity.path, "--headless", "--path", project, "--editor", "--import"}, path.join(output, "import.log"), timeout or 300)
    assert(C.equal(fingerprint(original), before), "Author project changed during preparation; discard this preparation")
    C.save(path.join(output, "prepared.json"), {format = "dora-godot-prepared-project", version = 1, project = "project", source = info, editor = identity,
        source_files_sha256 = before, prepared_files_sha256 = fingerprint(project)})
    return {prepared = true, project = project, receipt = path.join(output, "prepared.json"), editor_version = identity.version, source_unchanged = true}
end
function inspect_pck(file)
    local total, stream = os.filesize(file), assert(io.open(file, "rb"))
    local result
    try {function ()
        local function read(count) local data = stream:read(count); assert(data and #data == count, "Truncated PCK"); return data end
        local function u32() local a, b, c, d = read(4):byte(1, 4); return a + b * 256 + c * 65536 + d * 16777216 end
        local function u64() local low, high = u32(), u32(); assert(high < 2097152, "PCK integer exceeds exact range"); return low + high * 4294967296 end
        assert(read(4) == "GDPC", "Expected a standalone Godot PCK")
        local version, major, minor, patch, flags = u32(), u32(), u32(), u32(), u32()
        assert(table.contains({2, 3, 4}, version) and major == 4 and minor <= 7, "PCK requires an unsupported Godot version")
        assert(flags == 0 or flags == 2, "Encrypted/sparse/patch PCKs are not supported")
        local base = u64(); local directory = version >= 3 and u64() or 96
        assert(directory <= total - 4 and base <= total, "PCK offsets exceed file")
        stream:seek("set", directory)
        local count = u32(); assert(count > 0 and count <= math.min(1000000, math.floor(total / 40)), "Invalid PCK file count")
        local names = {}
        for _ = 1, count do
            local length = u32(); assert(length > 0 and length <= 65536, "Invalid PCK path length")
            local name = read(length):gsub("%z+$", ""):gsub("^res://", "")
            C.safe_relative(name); assert(not name:find(":", 1, true) and not name:find("%z") and not names[name], "Unsafe/duplicate PCK resource path")
            assert(utf8.len(name), "Invalid UTF-8 PCK path")
            local offset, size = u64(), u64(); read(16)
            assert(u32() == 0 and base + offset + size <= total, "Unsupported encrypted/patch entry or invalid resource extent")
            assert(not name:match("%.gdextension$") and not name:match("%.cs$") and not name:match("%.csproj$"), "This data-only package does not include C# or native extensions")
            names[name] = true
        end
        assert(names["project.binary"] or names["project.godot"], "PCK contains no project configuration")
        result = {kind = "pck", project = C.real(file), pack_version = version, godot_version = ("%d.%d.%d"):format(major, minor, patch), resource_count = count, sha256 = C.digest(file), bytes = total}
    end, finally {function (ok, errors) stream:close(); if not ok then raise(errors) end end}}
    return result
end
local function valid_id(id) return type(id) == "string" and #id >= 1 and #id <= 128 and id:match("^[a-z0-9][a-z0-9._%-]*$") end
function verify_game(package)
    package = C.real(package)
    local file = C.safe_file(package, "game.json"); assert(os.filesize(file) <= 4 * 1024 ^ 2, "Game manifest exceeds metadata size limit")
    local manifest = C.load(file)
    assert(manifest.format == "dora-godot-game" and manifest.format_version == 1, "Unsupported game package format")
    assert(type(manifest.title) == "string" and manifest.title ~= "" and type(manifest.version) == "string" and manifest.version ~= "", "Game title/version metadata missing")
    assert(valid_id(manifest.id), "Invalid game ID")
    local runtime = manifest.runtime or {}
    assert((runtime.godot == "4.6" or runtime.godot == "4.7") and runtime.mono == false and #C.keys(runtime) == 2, "Game requires unsupported runtime")
    C.choice(manifest.platform, PLATFORMS)
    assert(type(manifest.artifacts) == "table" and manifest.artifacts["game.pck"] and manifest.entry == "game.pck", "Game PCK inventory missing")
    for name, item in pairs(manifest.artifacts) do
        assert(name ~= "game.json" and not name:find(":", 1, true) and not name:find("%z"), "Unsafe game artifact path")
        local artifact = C.safe_file(package, name)
        assert(type(item) == "table" and item.bytes == os.filesize(artifact) and item.sha256 == C.digest(artifact), "Game artifact missing, unsafe or changed: " .. name)
    end
    local actual = {}; for _, artifact in ipairs(C.files(package)) do local name = C.relative(artifact, package); if name ~= "game.json" then actual[name] = true end end
    assert(C.equal(C.keys(actual), C.keys(manifest.artifacts)), "Game artifact inventory differs")
    import("core.base.json")
    assert(type(manifest.licenses) == "table" and (#manifest.licenses > 0 or json.is_marked_as_array(manifest.licenses)), "Invalid game license inventory")
    for _, name in ipairs(manifest.licenses) do assert(type(name) == "string" and manifest.artifacts[name], "Game license inventory incomplete") end
    local pack = inspect_pck(path.join(package, "game.pck"))
    return {kind = "game", verified = true, project = pack.project, id = manifest.id, title = manifest.title, platform = manifest.platform, manifest_sha256 = C.digest(file), pack = pack}
end
function inspect(source, selection)
    source = C.real(source)
    if os.isdir(source) and (selection or os.isfile(path.join(source, "project.godot"))) then return inspect_project(source, selection) end
    if os.isfile(source) and path.filename(source) == "game.json" then return verify_game(path.directory(source)) end
    if os.isdir(source) and os.isfile(path.join(source, "game.json")) then
        local manifest; try {function () local file = path.join(source, "game.json"); if os.filesize(file) <= 4 * 1024 ^ 2 then manifest = C.load(file) end end}
        if type(manifest) == "table" and manifest.format == "dora-godot-game" then return verify_game(source) end
    end
    if os.isfile(source) and source:lower():endswith(".pck") then return inspect_pck(source) end
    return inspect_project(source, selection)
end
function presets(project)
    local file = path.join(project, "export_presets.cfg"); if not os.isfile(file) then return {} end
    local values, result = config_strings(C.read(file):gsub("^\239\187\191", "")), {}
    for _, key in ipairs(C.keys(values)) do if key:match("^preset%.%d+/name$") then result[#result + 1] = {name = values[key], platform = values[key:gsub("/name$", "/platform")]} end end
    return result
end
function export_game(source, output, work, editor, game_id, version, selection, preset, platform, timeout)
    assert(valid_id(game_id), "Use a stable lowercase game ID")
    assert(not os.exists(output) and not os.islink(output), "Use a new game package output directory")
    local author = find_project(source, selection)
    assert(not within(output, os.isdir(source) and source or author), "Game package output must be outside author project/repository")
    assert(not within(output, work) and not within(work, output), "Game package and build work directories must not overlap")
    local prepared = prepare(source, work, editor, selection, timeout)
    local project = prepared.project
    local available, matches = presets(project), {}
    if preset then for _, value in ipairs(available) do if value.name == preset then matches[#matches + 1] = value end end
    elseif #available == 1 then matches = available
    elseif #available == 0 and table.contains(PLATFORMS, platform) then
        local options = {macOS = 'binary_format/architecture="universal"', Linux = 'binary_format/architecture="x86_64"', ["Windows Desktop"] = 'binary_format/architecture="x86_64"', Android = 'architectures/arm64-v8a=true', iOS = 'application/targeted_device_family=2', Web = 'variant/extensions_support=false'}
        import("core.base.json")
        C.write(path.join(project, "export_presets.cfg"), '[preset.0]\nname="Dora Player"\nplatform=' .. json.encode(platform) .. '\nrunnable=true\nexport_filter="all_resources"\ninclude_filter=""\nexclude_filter=""\nexport_path=""\nscript_export_mode=2\n[preset.0.options]\n' .. options[platform] .. '\n')
        matches = {{name = "Dora Player", platform = platform}}
    end
    assert(#matches == 1 and table.contains(PLATFORMS, matches[1].platform), "Select --preset, or --platform for a project without presets")
    local selected = matches[1]; assert(not platform or selected.platform == platform, "Selected preset targets a different platform")
    output = C.real(output); os.mkdir(path.directory(output))
    local package = output .. ".building-" .. hash.uuid4()
    try {function ()
        os.mkdir(package)
        local receipt = C.load(path.join(work, "prepared.json"))
        run_command({receipt.editor.path, "--headless", "--path", project, "--export-pack", selected.name, path.join(package, "game.pck")}, path.join(work, "export.log"), timeout or 300)
        inspect_pck(path.join(package, "game.pck"))
        local licenses = C.array()
        for _, name in ipairs({"LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING", "NOTICE", "CREDITS.md"}) do
            local original = path.join(project, name)
            if not os.isfile(original) then original = path.join(os.isdir(source) and source or path.directory(C.real(source)), name) end
            if os.isfile(original) and not os.islink(original) then C.copy(original, path.join(package, "licenses", name)); licenses[#licenses + 1] = "licenses/" .. name end
        end
        local artifacts = {}; for _, file in ipairs(C.files(package)) do artifacts[C.relative(file, package)] = {sha256 = C.digest(file), bytes = os.filesize(file)} end
        import("core.base.json")
        C.save(path.join(package, "game.json"), {format = "dora-godot-game", format_version = 1, id = game_id, title = receipt.source.title, version = version or "0.1.0",
            runtime = {godot = "4.7", mono = false}, entry = "game.pck", platform = selected.platform, export_preset = selected.name, rendering_method = receipt.source.rendering_method,
            source = {git = receipt.source.git, files_sha256 = C.data_digest(C.serialize(receipt.source_files_sha256, true))}, editor_version = receipt.editor.version, licenses = licenses, artifacts = artifacts})
        verify_game(package); assert(not os.exists(output), "Game package output appeared during export"); os.mv(package, output)
    end, finally {function (ok, errors) os.tryrm(package); if not ok then raise(errors) end end}}
    return verify_game(output)
end
function archive_game(package, output)
    local verified = verify_game(package); package = C.real(package)
    assert(not os.exists(output) and not os.islink(output) and not within(output, package), "Choose a new archive path outside game package")
    os.mkdir(path.directory(output))
    local names = {"game.json"}; table.join2(names, C.keys(C.load(path.join(package, "game.json")).artifacts))
    local temporary = C.real(output) .. ".building-" .. hash.uuid4()
    try {function ()
        import("zip", {rootdir = os.scriptdir()}).stored_archive(package, temporary, names)
        assert(not os.exists(output) and not os.islink(output), "Archive output appeared during packaging")
        os.mv(temporary, output)
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    return {archived = true, archive = C.real(output), sha256 = C.digest(output), bytes = os.filesize(output), id = verified.id}
end
local function unpack(archive, output, check, max_bytes, max_files, repository)
    assert(not os.exists(output) and not os.islink(output), "Install into a new game directory")
    assert(max_bytes >= 1 and max_files >= 1, "Installation size/file limits must be positive")
    output = C.real(output); os.mkdir(path.directory(output))
    local temporary = output .. ".installing-" .. hash.uuid4()
    try {function ()
        import("zip", {rootdir = os.scriptdir()}).extract(archive, temporary, max_bytes, max_files)
        if repository then
            for _, directory in ipairs(os.dirs(path.join(temporary, "**"))) do if SKIP[path.filename(directory)] then os.tryrm(directory) end end
        end
        local package = temporary
        if repository then local children = os.filedirs(path.join(package, "*")); if #children == 1 and os.isdir(children[1]) then package = children[1] end end
        check(package); assert(not os.exists(output), "Install output appeared during verification"); os.mv(package, output)
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
end
function install_game(archive, output, max_bytes, max_files) unpack(archive, output, verify_game, max_bytes or 4 * 1024 ^ 3, max_files or 10000); return verify_game(output) end
function import_repository(archive, output, max_bytes, max_files) unpack(archive, output, function () end, max_bytes or 4 * 1024 ^ 3, max_files or 100000, true); return {imported = true, repository = C.real(output), archive_sha256 = C.digest(archive)} end
