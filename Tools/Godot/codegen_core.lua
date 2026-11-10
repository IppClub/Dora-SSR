function generate(root, profile, emit)
    local C = import("common", {rootdir = os.scriptdir()})
    local U = import("codegen_util", {rootdir = os.scriptdir()})
    local function read(name) return C.read(path.join(root, name)):gsub("\r\n", "\n") end
    local function out(name, body) emit(name, U.wrapped(root, name, body)) end
    local function template(file, needle)
        for _, text in ipairs(U.literals(path.join(root, file))) do if text:find(needle, 1, true) then return text end end
        raise("Missing upstream literal: " .. needle)
    end
    local function render(file, needle, values) return U.render_template(template(file, needle), values) end
    out("core/disabled_classes.gen.h", "")
    local version = {}; for name, value in read("version.py"):gmatch("([%w_]+)%s*=%s*([^\n]+)") do version[name] = value:trim():gsub('^"', ''):gsub('"$', '') end
    version.build = os.getenv("BUILD_NAME") or "custom_build"; version.docs_branch = version.docs
    out("core/version_generated.gen.h", render("core/core_builders.py", "GODOT_VERSION_SHORT_NAME", version))
    out("core/version_hash.gen.cpp", render("core/core_builders.py", "GODOT_VERSION_HASH", {git_hash = "", git_timestamp = 0}))
    out("core/script_encryption_key.gen.cpp", render("core/core_builders.py", "script_encryption_key[32]", {["methods.format_buffer(buffer, 1)"] = U.buffer(string.rep("\0", 32), 1)}))
    local function compressed(file, template_file, needle, destination)
        local input = path.join(root, file)
        local data = U.compressed(input)
        local values = {["len(buffer)"] = #data, decomp_size = #read(file), ["methods.format_buffer(buffer, 1)"] = U.buffer(data, 1)}
        out(destination, (destination:find("certs", 1, true) and '#define _SYSTEM_CERTS_PATH ""\n' or '') .. render(template_file, needle, values))
    end
    compressed("thirdparty/certs/ca-bundle.crt", "core/core_builders.py", "BUILTIN_CERTS_ENABLED", "core/io/certs_compressed.gen.h")
    compressed("core/extension/gdextension_interface.json", "core/extension/make_interface_dumper.py", "TOOLS_ENABLED", "core/extension/gdextension_interface_dump.gen.h")
    for _, item in ipairs({{"AUTHORS.md", "authors", { ["Project Founders"] = "AUTHORS_FOUNDERS", ["Lead Developer"] = "AUTHORS_LEAD_DEVELOPERS", ["Project Manager"] = "AUTHORS_PROJECT_MANAGERS", Developers = "AUTHORS_DEVELOPERS"}},
        {"DONORS.md", "donors", {Patrons = "DONORS_PATRONS", ["Platinum sponsors"] = "DONORS_SPONSORS_PLATINUM", ["Gold sponsors"] = "DONORS_SPONSORS_GOLD", ["Silver sponsors"] = "DONORS_SPONSORS_SILVER", ["Diamond members"] = "DONORS_MEMBERS_DIAMOND", ["Titanium members"] = "DONORS_MEMBERS_TITANIUM", ["Platinum members"] = "DONORS_MEMBERS_PLATINUM", ["Gold members"] = "DONORS_MEMBERS_GOLD"}}}) do
        local body, reading = {}, false
        for line in (read(item[1]) .. "\n"):gmatch("(.-)\n") do
            if line:startswith("    ") and reading then body[#body + 1] = '\t"' .. U.escaped(line):trim() .. '",\n'
            elseif line:startswith("## ") then
                if reading then body[#body + 1] = "\tnullptr,\n};\n\n" end
                local section = item[3][line:sub(4):trim()]; reading = section ~= nil
                if section then body[#body + 1] = "inline constexpr const char *" .. section .. "[] = {\n" end
            end
        end
        if reading then body[#body + 1] = "\tnullptr,\n};\n\n" end
        out("core/" .. item[2] .. ".gen.h", table.concat(body))
    end
    -- Debian-style copyright paragraphs, preserving source project order.
    local lines = {}; for line in (read("COPYRIGHT.txt") .. "\n"):gmatch("(.-)\n") do if not line:startswith("#") then lines[#lines + 1] = line end end
    local projects, names, licenses, part, index = {}, {}, {}, {}, 1
    while index <= #lines do
        local tag, value = lines[index]:match("^([^:]+):(.*)$")
        if tag then
            local content = {value:trim()}; index = index + 1
            while lines[index] and lines[index]:startswith(" ") do content[#content + 1] = lines[index]:trim(); index = index + 1 end
            if table.contains({"Files", "Copyright", "License"}, tag) then part[tag] = content
            elseif tag == "Comment" and not table.empty(part) then
                local name = content[1]
                if not projects[name] then projects[name] = {}; names[#names + 1] = name end
                table.insert(projects[name], part)
            end
        else
            if part.License and not part.Files then licenses[#licenses + 1] = part.License end
            part = {}; index = index + 1
        end
    end
    local data, parts, part_indexes, part_count = {}, {}, {}, 0
    for _, name in ipairs(names) do
        part_indexes[name] = part_count
        for _, row in ipairs(projects[name]) do
            local fi = #data; table.join2(data, row.Files); local ci = #data; table.join2(data, row.Copyright)
            parts[#parts + 1] = ('\t{ "%s", &COPYRIGHT_INFO_DATA[%d], &COPYRIGHT_INFO_DATA[%d], %d, %d },\n'):format(U.escaped(row.License[1]), fi, ci, #row.Files, #row.Copyright)
            part_count = part_count + 1
        end
    end
    local body = {render("core/core_builders.py", "GODOT_LICENSE_TEXT", {["methods.to_raw_cstring(license_text)"] = U.raw(read("LICENSE.txt"))}), 'inline constexpr const char *COPYRIGHT_INFO_DATA[] = {\n'}
    for _, line in ipairs(data) do body[#body + 1] = '\t"' .. U.escaped(line) .. '",\n' end
    table.join2(body, {'};\n\ninline constexpr ComponentCopyrightPart COPYRIGHT_PROJECT_PARTS[] = {\n', table.concat(parts), '};\n\ninline constexpr int COPYRIGHT_INFO_COUNT = ' .. #names .. ';\ninline constexpr ComponentCopyright COPYRIGHT_INFO[] = {\n'})
    for _, name in ipairs(names) do body[#body + 1] = ('\t{ "%s", &COPYRIGHT_PROJECT_PARTS[%d], %d },\n'):format(U.escaped(name), part_indexes[name], #projects[name]) end
    body[#body + 1] = '};\n\ninline constexpr int LICENSE_COUNT = ' .. #licenses .. ';\ninline constexpr const char *LICENSE_NAMES[] = {\n'
    for _, license in ipairs(licenses) do body[#body + 1] = '\t"' .. U.escaped(license[1]) .. '",\n' end
    body[#body + 1] = '};\n\ninline constexpr const char *LICENSE_BODIES[] = {\n\n'
    for _, license in ipairs(licenses) do local content = {}; for i = 2, #license do content[#content + 1] = license[i] == "." and "" or license[i] end; body[#body + 1] = U.raw(content) .. ',\n\n' end
    body[#body + 1] = '};\n\n'; out("core/license.gen.h", table.concat(body))
    local profiler = ""
    if profile.profiler == "tracy" then
        profiler = "#define GODOT_USE_TRACY\n" .. (profile.profiler_sample_callstack and "#define TRACY_CALLSTACK 62\n" or "") .. (profile.profiler_track_memory and "#define GODOT_PROFILER_TRACK_MEMORY\n" or "") .. (profile.profiler_record_on_demand and "#define TRACY_ON_DEMAND\n" or "")
    elseif profile.profiler == "perfetto" then profiler = "#define GODOT_USE_PERFETTO\n"
    elseif profile.profiler == "instruments" then profiler = "#define GODOT_USE_INSTRUMENTS\n" .. (profile.profiler_sample_callstack and "#define INSTRUMENTS_SAMPLE_CALLSTACKS\n" or "") end
    out("core/profiling/profiling.gen.h", profiler)
    local mappings, order, warnings = {}, {}, {}
    local platforms = {Linux = "LINUXBSD", Windows = "WINDOWS", ["Mac OS X"] = "MACOS", Android = "ANDROID", iOS = "APPLE_EMBEDDED", Web = "WEB"}
    for _, file in ipairs({"core/input/gamecontrollerdb.txt", "core/input/godotcontrollerdb.txt"}) do
        local current
        for raw in read(file):gmatch("[^\r\n]+") do
            local line = raw:trim()
            if line:startswith("#") then
                local name = line:sub(2):trim()
                if platforms[name] then current = name; if not mappings[name] then mappings[name] = {order = {}, values = {}}; order[#order + 1] = name end end
            elseif line ~= "" and current then
                local guid = line:match("^[^,]+")
                local map = mappings[current]
                if map.values[guid] then warnings[#warnings + 1] = "// WARNING: DATABASE " .. file .. " OVERWROTE PRIOR MAPPING: " .. current .. " " .. map.values[guid] .. "\n" else map.order[#map.order + 1] = guid end
                map.values[guid] = line
            end
        end
    end
    body = {template("core/input/input_builders.py", "#include"), table.concat(warnings), 'const char *DefaultControllerMappings::mappings[] = {\n'}
    for _, name in ipairs(order) do
        body[#body + 1] = "#ifdef " .. platforms[name] .. "_ENABLED\n"
        for _, guid in ipairs(mappings[name].order) do body[#body + 1] = '\t"' .. mappings[name].values[guid] .. '",\n' end
        body[#body + 1] = "#endif // " .. platforms[name] .. "_ENABLED\n"
    end
    body[#body + 1] = "\tnullptr\n};\n"; out("core/input/default_controller_mappings.gen.cpp", table.concat(body))
    local enabled, includes, initialize, uninitialize = {}, {}, {}, {}
    local modules = table.clone(profile.enabled_modules); table.sort(modules, C.byte_less)
    for _, name in ipairs(modules) do enabled[#enabled + 1] = "#define MODULE_" .. name:upper() .. "_ENABLED\n" end
    out("modules/modules_enabled.gen.h", table.concat(enabled))
    local headers = os.files(path.join(root, "modules/*/register_types.h")); table.sort(headers, C.byte_less)
    for _, header in ipairs(headers) do
        local name = path.filename(path.directory(header))
        if not profile.register_enabled_only or table.contains(modules, name) then
            includes[#includes + 1] = '#include "modules/' .. name .. '/register_types.h"'
            initialize[#initialize + 1] = '#ifdef MODULE_' .. name:upper() .. '_ENABLED\n\tinitialize_' .. name .. '_module(p_level);\n#endif'
            uninitialize[#uninitialize + 1] = '#ifdef MODULE_' .. name:upper() .. '_ENABLED\n\tuninitialize_' .. name .. '_module(p_level);\n#endif'
        end
    end
    out("modules/register_module_types.gen.cpp", render("modules/modules_builders.py", '#include "register_module_types.h"', {mod_inc = table.concat(includes, "\n"), mod_init = table.concat(initialize, "\n"), mod_uninit = table.concat(uninitialize, "\n")}))
    includes, initialize, uninitialize = {}, {}, {}
    headers = os.files(path.join(root, "platform/*/api/api.h")); table.sort(headers, C.byte_less)
    for _, header in ipairs(headers) do local name = path.filename(path.directory(path.directory(header))); includes[#includes + 1] = '#include "' .. name .. '/api/api.h"'; initialize[#initialize + 1] = 'register_' .. name .. '_api();'; uninitialize[#uninitialize + 1] = 'unregister_' .. name .. '_api();' end
    out("platform/register_platform_apis.gen.cpp", render("platform/platform_builders.py", '#include "register_platform_apis.h"', {api_inc = table.concat(includes, "\n"), api_reg = table.concat(initialize, "\n\t"), api_unreg = table.concat(uninitialize, "\n\t")}))
    for _, file in ipairs(os.files(path.join(root, "platform/*/export/*.svg"))) do
        local name = path.basename(file)
        if name == "logo" or name == "run_icon" then
            local platform = path.filename(path.directory(path.directory(file)))
            out(C.relative(file, root):gsub("%.svg$", "_svg.gen.h"), "inline constexpr const char *_" .. platform .. "_" .. name .. "_svg = " .. U.raw(C.read(file)) .. ";\n")
        end
    end
    for _, item in ipairs({{"main/splash.png", "main/splash.gen.h", "main/main_builders.py", "boot_splash_bg_color"}, {"main/app_icon.png", "main/app_icon.gen.h", "main/main_builders.py", "app_icon_png"}, {"thirdparty/fonts/OpenSans_SemiBold.woff2", "scene/theme/default_font.gen.h", "scene/theme/default_theme_builders.py", "_font_"}}) do
        local data = C.read(path.join(root, item[1]))
        out(item[2], render(item[3], item[4], {["methods.format_buffer(buffer, 1)"] = U.buffer(data, 1), name = path.basename(item[1]), ["len(buffer)"] = #data}))
    end
    local icons, iconnames = {}, {}
    local files = os.files(path.join(root, "scene/theme/icons/*.svg")); table.sort(files, C.byte_less)
    for _, file in ipairs(files) do icons[#icons + 1] = U.raw(C.read(file)); iconnames[#iconnames + 1] = '"' .. path.basename(file) .. '"' end
    out("scene/theme/default_theme_icons.gen.h", render("scene/theme/icons/default_theme_icons_builders.py", "default_theme_icons_count", {["len(icons_names)"] = #icons, icons_raw_str = table.concat(icons, ",\n\t"), icons_names_str = table.concat(iconnames, ",\n\t")}))
    local ltc = {'/* WARNING, THIS FILE WAS GENERATED BY THE "make_ltc_lut.py" SCRIPT, DO NOT EDIT */ \n\n', '// LTC Lookup table for BRDF fitting by Eric Heitz (https://eheitzresearch.wordpress.com/415-2/) \n', 'static const int LTC_LUT_DIMENSIONS = 64; // 64x64\n'}
    for i = 1, 2 do local data, values = C.read(path.join(root, "servers/rendering/storage/ltc/ltc_lut" .. i .. ".dds")):sub(149), {}; for k = 1, #data do values[k] = ("0x%02x"):format(data:byte(k)) end; ltc[#ltc + 1] = 'static const uint8_t LTC_LUT' .. i .. '[] = {' .. table.concat(values, ",") .. '};\n\n' end
    emit("servers/rendering/storage/ltc_lut.gen.h", table.concat(ltc))
    for _, item in ipairs({{"Area", "area", 160, 560}, {"Search", "search", 64, 16}}) do
        local upper = item[2]:upper() .. "TEX"
        local constants = {upper .. "_WIDTH " .. item[3], upper .. "_HEIGHT " .. item[4], upper .. "_PITCH (" .. upper .. "_WIDTH" .. (item[2] == "area" and " * 2" or "") .. ")", upper .. "_SIZE (" .. upper .. "_HEIGHT * " .. upper .. "_PITCH)"}
        local defs = {}; for _, value in ipairs(constants) do defs[#defs + 1] = "#define " .. value .. "\n" end
        if item[2] == "search" then defs[3] = "#define SEARCHTEX_PITCH SEARCHTEX_WIDTH\n" end
        out("servers/rendering/renderer_rd/effects/smaa_" .. item[2] .. "_tex.gen.h", table.concat(defs) .. "\ninline constexpr const unsigned char " .. item[2] .. "_tex_png[] = {\n    " .. U.buffer(C.read(path.join(root, "thirdparty/smaa", item[1] .. "Tex.png")), 1) .. "\n};\n")
    end
end
