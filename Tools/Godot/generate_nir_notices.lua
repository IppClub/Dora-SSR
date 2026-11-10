-- Read pinned source archives as data; do not execute their generators.
local C = import("common", {rootdir = os.scriptdir()})
local MESA_SHA = "15a688666aca976d1479c8bd43d319a55613da9a91aaf42a07691daec96ba7be"
local NIR_SHA = "21ba3c0532caa580b50c530aefc851686b747b41d7984c228bcc0cef7ef5db82"
local COMMIT = "5005a50879b11b953ade113fccd13a208f706ba0"
function constants() return {MESA_SHA = MESA_SHA, NIR_SHA = NIR_SHA, MESA_COMMIT = COMMIT} end
function read_archive(file, expected, prefix)
    assert(C.digest(file) == expected, "Unrecognized source archive: " .. file)
    local temporary, files = os.tmpfile() .. "-notice-sources", {}
    try {function ()
        C.extract(file, temporary)
        for _, item in ipairs(C.files(temporary)) do
            local name = C.relative(item, temporary)
            assert(name:startswith(prefix .. "/"), "Unexpected source archive prefix")
            name = name:sub(#prefix + 2); C.safe_relative(name); files[name] = C.read(item)
        end
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    return files
end
function comments(text)
    local candidates = {}
    for first, last in text:gmatch("()/%*.-%*/()") do candidates[#candidates + 1] = {first, last} end
    for first, last in text:gmatch("()<!%-%-[^>]*%-%->()") do candidates[#candidates + 1] = {first, last} end
    local start, offset = nil, 1
    local content = text; if content:sub(-1) ~= "\n" then content = content .. "\n" end
    for line in content:gmatch("([^\n]*\n)") do
        local is_comment = line:match("^[ \t]*//") or line:match("^[ \t]*#")
        if is_comment then start = start or offset
        elseif start then candidates[#candidates + 1] = {start, offset}; start = nil end
        offset = offset + #line
    end
    if start then candidates[#candidates + 1] = {start, #text + 1} end
    table.sort(candidates, function (a, b) return a[1] < b[1] end)
    local result, ending = {}, 0
    for _, range in ipairs(candidates) do
        if range[1] >= ending then
            ending = range[2]
            local block = text:sub(range[1], range[2] - 1):trim(); local lower = block:lower()
            for _, term in ipairs({"copyright", "spdx", "license", "licence", "permission", "public domain", "warranty", "all rights reserved"}) do
                if lower:find(term, 1, true) then result[#result + 1] = block; break end
            end
        end
    end
    return result
end
function archive_object_names(data)
    assert(data:startswith("!<arch>\n"), "Invalid static archive")
    local offset, names, longnames, seen = 9, {}, "", {}
    while offset <= #data do
        local header = data:sub(offset, offset + 59); assert(#header == 60 and header:sub(-2) == "`\n", "Invalid ar header")
        local size = assert(tonumber(header:sub(49, 58)))
        local member = data:sub(offset + 60, offset + 59 + size); assert(#member == size, "Truncated ar member")
        local name = header:sub(1, 16):trim()
        if name == "//" then longnames = member
        elseif name ~= "/" and name ~= "/SYM64/" then
            if name:startswith("/") then local index = assert(tonumber(name:sub(2))) + 1; local last = assert(longnames:find("/\n", index, true)); name = longnames:sub(index, last - 1)
            else name = name:gsub("/+$", "") end
            assert(name:endswith(".windows.x86_64.o") and member:sub(1, 2) == "\100\134", "Non AMD64 archive object: " .. name)
            assert(not seen[name], "Duplicate ar object"); seen[name] = true; names[#names + 1] = name
        end
        offset = offset + 60 + size + size % 2
    end
    assert(#names == 309, "Expected 309 archive objects"); return names
end
function map_objects(sdk, selected, nir, script)
    local U = import("codegen_util", {rootdir = os.scriptdir()})
    local sources, generators = {}, {}
    for name in pairs(selected) do if name:match("%.c$") or name:match("%.cpp$") then local stem = path.basename(name); assert(not sources[stem], "Ambiguous source basename"); sources[stem] = name end end
    local literal = assert(nir.SConstruct:match("custom_build_steps%s*=%s*(%b[])"), "Missing literal upstream build metadata")
    local strings = {}; for text in literal:gmatch('"(.-)"') do strings[#strings + 1] = U.unescape(text) end
    assert(#strings % 3 == 0, "Invalid literal build metadata")
    -- Validate that only list punctuation, whitespace and quoted data were consumed.
    assert(literal:gsub('".-"', ''):gsub("[%[%],%s]", '') == '', "Nonliteral upstream build metadata")
    for index = 1, #strings, 3 do if strings[index + 2]:endswith(".c") then generators[path.basename(strings[index + 2])] = {strings[index], strings[index + 1], strings[index + 2], "SConstruct"} end end
    local section = assert(script:match("run_custom_steps_at_source%(%) {(.-)copy_file%(%) {"))
    for folder, command in section:gmatch("    run_step (%S+) '([^']+)'") do
        for output in command:gmatch("%$OUTDIR/([%w_%.]+%.c)") do generators[path.basename(output)] = {folder, command, output, "update_mesa.sh"} end
    end
    local mapped, direct, generated = {}, 0, 0
    for _, name in ipairs(archive_object_names(C.read(path.join(sdk, "bin/libNIR.windows.x86_64.a")))) do
        local stem = name:match("^(.-)%.windows%.")
        if sources[stem] then mapped[#mapped + 1] = {object = name, source = "mesa/" .. sources[stem]}; direct = direct + 1
        else
            local step = assert(generators[stem], "Unmapped archive object: " .. name)
            local generator = step[1] .. "/" .. step[2]:match("^%S+"); assert(selected[generator], "Missing generator source")
            mapped[#mapped + 1] = {object = name, generated_source = step[1] .. "/" .. step[3], generator = "mesa/" .. generator, command = step[2], command_origin = step[4]}; generated = generated + 1
        end
    end
    assert(direct == 299 and generated == 10, "Object/source mapping counts changed"); return mapped
end
function generate(args)
    local J = import("ordered_json", {rootdir = os.scriptdir()})
    local sdk = C.required(args, "sdk-root")
    import("verify_d3d12_sdk", {rootdir = os.scriptdir()}).verify(sdk, path.join(C.root(), "Projects/xmake/godot/windows_d3d12_sdk.json"))
    local mesa = read_archive(C.required(args, "mesa-source"), MESA_SHA, "mesa-" .. COMMIT)
    local nir = read_archive(C.required(args, "nir-source"), NIR_SHA, "godot-nir-static-25.3.1-1")
    local script = nir["update_mesa.sh"]
    local section = assert(script:match("copy_sources%(%) {(.-)blacklist_sources%(%)"))
    local selected = {}
    local function glob(name, pattern) return name:match("^" .. pattern:gsub("(%W)", "%%%1"):gsub("%%%*", ".*"):gsub("%%%?", ".") .. "$") ~= nil end
    for line in section:gmatch("[^\n]+") do
        local kind, folder, pattern = line:match("^%s+copy_([%w_]+)%s+(%S+)%s*(%S*)%s*$")
        if kind and not folder:find("$", 1, true) then
            folder = folder == "." and "" or folder
            for name in pairs(mesa) do
                local parent = name:match("^(.*)/") or "."
                local extension = path.extension(name)
                if parent == folder and ((kind == "subir_sources" and table.contains({".c", ".cpp", ".h"}, extension)) or (kind == "subir_headers" and extension == ".h") or (kind == "file" and glob(path.filename(name), pattern))) then selected[name] = true end
            end
        end
    end
    for name in script:gmatch("%s+rm godot%-mesa/(%S+)") do selected[name] = nil end
    assert(#C.keys(selected) == 696, "NIR source selection changed: " .. #C.keys(selected))
    local custom = assert(script:match("copy_custom_steps_sources%(%) {(.-)copy_sources%(%)"))
    for folder, name in custom:gmatch("copy_file[ \t]+(%S+)[ \t]+(%S+)") do selected[folder .. "/" .. name] = true end
    for _, name in ipairs({"src/util/blake3/README", "VERSION", "bin/git_sha1_gen.py", "src/compiler/spirv/spirv_info_gen.py", "src/compiler/spirv/vtn_gather_types_c.py", "src/compiler/spirv/spirv.core.grammar.json"}) do selected[name] = true end
    local object_sources = map_objects(sdk, selected, nir, script)
    local records, groups, group_order, group_index = {}, {}, {}, {}
    local function collect(name, data)
        local blocks = comments(data)
        if name:endswith(".json") then local document = J.decode(data); if document.copyright then blocks[#blocks + 1] = type(document.copyright) == "table" and table.concat(document.copyright, "\n") or tostring(document.copyright) end end
        records[#records + 1] = {path = name, sha256 = C.data_digest(data), notice_blocks = #blocks}
        for _, block in ipairs(blocks) do
            if not groups[block] then groups[block] = {}; group_order[#group_order + 1] = block; group_index[block] = #group_order end
            table.insert(groups[block], name)
        end
    end
    local temporary, compared, generated = os.tmpfile() .. "-nir-notices", 0, {}
    try {function ()
        for _, name in ipairs(C.keys(selected)) do C.write(path.join(temporary, "godot-mesa", name), assert(mesa[name], name)) end
        local patch = path.join(temporary, "godot.patch"); C.write(patch, nir["godot-patches/01_godot_nir_goodies.patch"])
        os.iorunv("patch", {"--batch", "--fuzz=0", "-p1", "-i", patch}, {curdir = temporary})
        for _, name in ipairs(C.keys(selected)) do collect("mesa/" .. name, C.read(path.join(temporary, "godot-mesa", name))) end
        local headers = os.files(path.join(sdk, "godot-mesa/**.h")); table.sort(headers)
        for _, file in ipairs(headers) do
            local name = C.relative(file, path.join(sdk, "godot-mesa")); local original = path.join(temporary, "godot-mesa", name)
            if os.isfile(original) then assert(C.read(original):gsub("\r\n", "\n") == C.read(file):gsub("\r\n", "\n"), "SDK/source header mismatch: " .. name); compared = compared + 1
            else generated[#generated + 1] = name; collect("sdk-generated/" .. name, C.read(file)) end
        end
        assert(compared == 397 and #generated == 11, "SDK header selection changed")
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    for _, name in ipairs(C.keys(nir)) do if table.contains({".h", ".c", ".cpp"}, path.extension(name)) and (name:startswith("vulkan/") or name:startswith("drivers/")) then collect("godot-nir-static/" .. name, nir[name]) end end
    local text = {'Godot NIR 25.3.1-1 — third-party notices\n', 'Mesa commit: ' .. COMMIT .. '\n', 'Includes source/header/generator notices conservatively. Headers in this inventory\nmay not contribute code to the runtime. Individual notices retain their own scope.\nObject/source mapping and source acquisition are recorded separately.\n'}
    local full = {{"Godot NIR wrapper license", nir["LICENSE.md"]}, {"Vulkan headers license", nir["vulkan/LICENSE.txt"]}, {"Mesa licensing overview", mesa["docs/license.rst"]}}
    for _, name in ipairs({"MIT", "Apache-2.0", "BSL-1.0", "SGI-B-2.0"}) do full[#full + 1] = {"Mesa licenses/" .. name, mesa["licenses/" .. name]} end
    local directory = path.join(os.scriptdir(), "licenses/nir-25.3.1-1")
    local blake = path.join(directory, "blake3-1.8.2"); local blake_sources = C.load(path.join(blake, "sources.json"))
    for _, item in ipairs(blake_sources) do local data = C.read(path.join(blake, item.file)); assert(C.data_digest(data) == item.sha256, "BLAKE3 input changed"); if item.file:startswith("LICENSE_") then full[#full + 1] = {"BLAKE3 1.8.2 " .. item.file, data} end end
    full[#full + 1] = {"BLAKE3 upstream license choices", assert(C.read(path.join(blake, "README.md")):match("## Licenses(.-)## "))}
    full[#full + 1] = {"Mesa BLAKE3 provenance", mesa["src/util/blake3/README"]}
    for _, row in ipairs(full) do table.join2(text, {"\n" .. string.rep("=", 72) .. "\n" .. row[1] .. "\n\n", row[2], "\n"}) end
    local lineage_path = path.join(directory, "SOURCE_LINEAGE.json"); local lineage = C.load(lineage_path); assert(lineage.mesa_commit == COMMIT)
    local inherited, record_paths = {}, {}; for _, record in ipairs(records) do record_paths[record.path] = true end
    for _, entry in ipairs(lineage.historical_notices) do
        assert(path.filename(entry.file) == entry.file); local data = C.read(path.join(directory, entry.file)); assert(C.data_digest(data) == entry.notice_sha256 and record_paths[entry.applies_to], "Historical notice changed")
        table.join2(text, {"\n" .. string.rep("=", 72) .. "\nHistorical predecessor notice for ", entry.applies_to, "\nSource: ", entry.source_path, "\nSource commit: ", entry.source_ref, "\n\n", data, "\n"})
        local copy = table.clone(entry); copy.notice_text = data; inherited[#inherited + 1] = copy
    end
    table.join2(text, {"\n" .. string.rep("=", 72) .. "\nGallium pipe_box component notice\n\n", C.read(path.join(directory, "box-component.NOTICE.txt"))})
    local blocks = table.clone(group_order); table.sort(blocks, function (a, b)
        if groups[a][1] == groups[b][1] then return group_index[a] < group_index[b] end
        return groups[a][1] < groups[b][1]
    end)
    for _, block in ipairs(blocks) do table.join2(text, {"\n" .. string.rep("=", 72) .. "\nFiles:\n", table.concat(groups[block], "\n"), "\n\n", block, "\n"}) end
    local output = C.required(args, "output"); os.mkdir(output)
    local notice = path.join(output, "GODOT-NIR-THIRD-PARTY-NOTICES.txt"); C.write(notice, table.concat(text))
    local missing = {}; for _, record in ipairs(records) do if record.notice_blocks == 0 then missing[#missing + 1] = record.path end end
    local provenance = {schema = 3, godot_nir_tag = "25.3.1-1", mesa_commit = COMMIT, mesa_source_sha256 = MESA_SHA, nir_source_sha256 = NIR_SHA,
        object_sources = object_sources, object_mapping_scope = "All 309 static archive members matched by unique source basename or literal upstream generator metadata; not a full rebuild or final-link contribution proof",
        blake3_license_sources = blake_sources, patch_sha256 = C.data_digest(nir["godot-patches/01_godot_nir_goodies.patch"]), sdk_matching_headers = compared,
        sdk_generated_headers = generated, notice_sha256 = C.digest(notice), files = records, files_without_notice_blocks = missing,
        historical_notice_sources = inherited, source_lineage_registry_sha256 = C.digest(lineage_path), scope = "Conservative notice inventory, not a binary link contribution or legal opinion"}
    local review_file = path.join(directory, "LICENSE_REVIEW.json"); local review = J.decode(C.read(review_file))
    import("verify_nir_review", {rootdir = os.scriptdir()}).verify_review(review, provenance, false)
    for name, expected in pairs(review.evidence) do assert(C.digest(path.join(directory, name)) == expected, "License review evidence changed: " .. name) end
    for _, header in ipairs(review.header_notice_sources or {}) do local data = mesa[header.source]; assert(C.data_digest(data) == header.source_sha256); assert(C.read(path.join(directory, header.notice_file)):trim() == table.concat(comments(data), "\n\n"), "License header notice changed") end
    provenance.license_review = review; provenance.license_review_sha256 = C.digest(review_file)
    -- Ordered encoding preserves the legacy review digest inside the provenance.
    C.write(path.join(output, "GODOT-NIR-PROVENANCE.json"), J.encode(provenance) .. "\n")
    return {files = #records, notice_groups = #blocks, bytes = os.filesize(notice)}
end
function main(...)
    local args = C.args({...}, {["mesa-source"] = "value", ["nir-source"] = "value", ["sdk-root"] = "value", output = "value"})
    import("core.base.json"); print(json.encode(generate(args)))
end
