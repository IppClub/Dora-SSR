local stages = {"vertex", "fragment", "compute", "raygen", "any_hit", "closest_hit", "miss", "intersection"}
local function title(name) return (name:gsub("[%w]+", function (word) return word:sub(1, 1):upper() .. word:sub(2):lower() end):gsub("[_%.]", "")) end
function parse(root, file, gles)
    local C = import("common", {rootdir = os.scriptdir()})
    local data = {reading = "", uniforms = {}, texunits = {}, ubos = {}, feedbacks = {}, variant_names = {}, variant_defines = {}, specialization_names = {}, specialization_values = {}}
    local included = {}; for _, stage in ipairs(stages) do data[stage] = {}; included[stage] = {} end
    local function unique(list, value) if not table.contains(list, value) then list[#list + 1] = value end end
    local function include(filename, depth)
        assert(depth < 128, "Shader include recursion limit")
        local source = C.read(filename):gsub("\r\n", "\n")
        if source:sub(-1) ~= "\n" then source = source .. "\n" end
        local after_include = false
        for raw in source:gmatch("(.-)\n") do
            local line = not gles and not after_include and raw:gsub("//.*$", "") or raw
            after_include = false
            local mode = line:match("#%[([%w_]+)%]")
            local name, value = line:match("^(.-)=(.*)$")
            if mode then
                if mode ~= "modes" then data.reading = mode end
            elseif gles and name and (data.reading == "" or data.reading == "specializations") then
                if data.reading == "" then data.variant_names[#data.variant_names + 1] = name:trim():upper(); data.variant_defines[#data.variant_defines + 1] = value:trim()
                else data.specialization_names[#data.specialization_names + 1] = name:trim(); data.specialization_values[#data.specialization_values + 1] = value end
            else
                local target = line:match('#include%s+["<]([^">]+)[">]')
                if target then
                    after_include = true
                    local resolved = path.normalize(target:startswith("thirdparty/") and path.join(root, target) or path.join(path.directory(filename), target))
                    local set = included[data.reading]
                    if set and (not gles or data.reading == "vertex" or data.reading == "fragment") and not set[resolved] then set[resolved] = true; include(resolved, depth + 1) end
                else
                    if gles then
                        local unit = line:lower():match("texunit:%s*(.-)%s*$")
                        local ubo = line:lower():match("ubo:%s*(.-)%s*$")
                        if line:find("uniform", 1, true) then
                            local declaration
                            if unit or ubo then declaration = line:gsub("//.*$", ""):gsub("uniform", ""):gsub("highp", ""):gsub("[;{]", "")
                            elseif not line:find("{", 1, true) and line:find(";", 1, true) then declaration = line:gsub("uniform", ""):gsub(";", "") end
                            if declaration then
                                for part in declaration:gmatch("[^,]+") do
                                    local variable = part:trim():match("([^ ]+)$"):gsub("%[.*$", "")
                                    if unit or ubo then
                                        local list = unit and data.texunits or data.ubos
                                        local found = false; for _, pair in ipairs(list) do if pair[1] == variable then found = true end end
                                        if not found then list[#list + 1] = {variable, unit == "auto" and "-1" or tostring(assert(tonumber(unit or ubo), "Invalid shader binding")):gsub("%.0$", "")} end
                                    else unique(data.uniforms, variable) end
                                end
                            end
                        end
                        if line:trim():match("^out ") or line:trim():match("^flat ") then
                            local cleaned = line:gsub("flat ", ""):gsub("out ", ""):gsub("highp ", ""):gsub(";", "")
                            cleaned = cleaned:sub(cleaned:find(" ") or 1):trim()
                            local feedback, spec = cleaned:match("^(.-)//%s*tfb:%s*(.-)%s*$")
                            if feedback then data.feedbacks[#data.feedbacks + 1] = {feedback:trim(), spec} end
                        end
                    end
                    if data[data.reading] then data[data.reading][#data[data.reading] + 1] = line end
                end
            end
        end
        if after_include and data[data.reading] then data[data.reading][#data[data.reading] + 1] = "" end
    end
    include(file, 0)
    return data
end

function generate(root, emit)
    local C = import("common", {rootdir = os.scriptdir()})
    local U = import("codegen_util", {rootdir = os.scriptdir()})
    local function literal(file, needle)
        for _, value in ipairs(U.literals(path.join(root, file))) do if value:find(needle, 1, true) then return value end end
        raise("Missing upstream shader template: " .. needle)
    end
    local function render(file, needle, values) local text = literal(file, needle); return values and U.render_template(text, values) or text end
    local function out(name, body) emit(name, U.wrapped(root, name, body)) end
    local function raw_include(file, depth)
        assert(depth < 128, "Raw shader include recursion limit")
        local text, result = C.read(file):gsub("\r\n", "\n"), {}
        for line in text:gmatch("([^\n]*\n?)") do
            if line ~= "" then
                local target = line:match('#include%s+"([^"]+)"')
                result[#result + 1] = target and raw_include(path.join(path.directory(file), target), depth + 1) or line
            end
        end
        return table.concat(result)
    end
    local files = os.files(path.join(root, "servers/rendering/renderer_rd/shaders/**.glsl")); table.sort(files)
    for _, file in ipairs(files) do
        local relative = C.relative(file, root)
        if file:endswith("_inc.glsl") then
            if path.directory(file) == path.join(root, "servers/rendering/renderer_rd/shaders") then out(relative .. ".gen.h", "static const char " .. path.filename(file):gsub("%.glsl$", "_shader_glsl") .. "[] = {\n" .. U.raw(raw_include(file, 0)) .. "\n};\n") end
        else
            local data, body = parse(root, file, false), {}
            local class = title(path.basename(file)) .. "ShaderRD"
            body[#body + 1] = render("glsl_builders.py", '#include "servers/rendering/renderer_rd/shader_rd.h"', {class_name = class})
            local ray = false; for _, stage in ipairs(table.slice(stages, 4)) do if #data[stage] > 0 then ray = true end end
            if ray then
                for _, stage in ipairs(table.slice(stages, 4)) do
                    if #data[stage] > 0 then body[#body + 1] = render("glsl_builders.py", '_{stage}_code[]', {stage = stage, ['to_raw_cstring(lines)'] = U.raw(data[stage])})
                    else body[#body + 1] = render("glsl_builders.py", '*_{stage}_code = nullptr', {stage = stage}) end
                end
                body[#body + 1] = render("glsl_builders.py", 'setup_raytracing(', {class_name = class})
            elseif #data.compute > 0 then body[#body + 1] = render("glsl_builders.py", 'static const char *_vertex_code = nullptr;', {class_name = class, ['to_raw_cstring(header_data.compute_lines)'] = U.raw(data.compute)})
            else body[#body + 1] = render("glsl_builders.py", 'static const char _vertex_code[]', {class_name = class, ['to_raw_cstring(header_data.vertex_lines)'] = U.raw(data.vertex), ['to_raw_cstring(header_data.fragment_lines)'] = U.raw(data.fragment)}) end
            body[#body + 1] = "\t}\n};\n"; out(relative .. ".gen.h", table.concat(body))
        end
    end
    files = {}; for _, name in ipairs({"canvas", "feed", "scene", "sky", "canvas_occlusion", "canvas_sdf", "particles", "particles_copy", "skeleton", "tex_blit"}) do files[#files + 1] = path.join(root, "drivers/gles3/shaders", name .. ".glsl") end
    local effects = os.files(path.join(root, "drivers/gles3/shaders/effects/*.glsl")); table.sort(effects)
    for _, file in ipairs(effects) do if not file:endswith("_inc.glsl") then files[#files + 1] = file end end
    for _, file in ipairs(files) do
        local data, body, values = parse(root, file, true), {}, {}
        local function write(needle, substitutions) body[#body + 1] = render("gles3_builders.py", needle, substitutions) end
        values.out_file_class = title(path.basename(file)) .. "ShaderGLES3"
        values.defvariant = #data.variant_names == 0 and " = DEFAULT" or ""
        local defspec = 0; for i, value in ipairs(data.specialization_values) do if value:trim():upper() == "TRUE" or value:trim() == "1" then defspec = defspec + 2 ^ (i - 1) end end
        values.defspec = ("%.0f"):format(defspec)
        write('#include "drivers/gles3/shader_gles3.h"', values)
        if #data.uniforms > 0 then local names = {}; for _, name in ipairs(data.uniforms) do names[#names + 1] = name:upper() end; write('enum Uniforms', {uniforms = table.concat(names, ",\n\t\t")}) end
        write('enum ShaderVariant', {variant_names = #data.variant_names > 0 and table.concat(data.variant_names, ",\n\t\t") or "DEFAULT"})
        if #data.specialization_names > 0 then local names = {}; for i, name in ipairs(data.specialization_names) do names[#names + 1] = name:upper() .. " = " .. ("%.0f"):format(2 ^ (i - 1)) end; write('enum Specializations', {specialization_names = table.concat(names, ",\n\t\t")}) end
        write('bool version_bind_shader', values)
        if #data.uniforms > 0 then write('int version_get_uniform', values) end
        write('protected:')
        local function strings(items) local result = {}; for _, name in ipairs(items) do result[#result + 1] = '"' .. name .. '"' end; return table.concat(result, ",\n\t\t\t") end
        if #data.uniforms > 0 then write('char *_uniform_strings[]', {uniforms = strings(data.uniforms)}) else write('char **_uniform_strings = nullptr') end
        if #data.variant_defines > 0 then write('char *_variant_defines[]', {variant_defines = strings(data.variant_defines)}) else write('char **_variant_defines[]') end
        for _, item in ipairs({{"texunits", "TexUnitPair _texunit_pairs[]", "TexUnitPair *_texunit_pairs"}, {"ubos", "UBOPair _ubo_pairs[]", "UBOPair *_ubo_pairs"}}) do
            local pairs = {}; for _, pair in ipairs(data[item[1]]) do pairs[#pairs + 1] = '{ "' .. pair[1] .. '", ' .. pair[2] .. ' }' end
            if #pairs > 0 then write(item[2], {[item[1]] = table.concat(pairs, ",\n\t\t\t")}) else write(item[3]) end
        end
        if #data.specialization_names > 0 then
            local specs = {}; for i, name in ipairs(data.specialization_names) do local value = data.specialization_values[i]:trim():upper(); specs[#specs + 1] = '{ "' .. name .. '", ' .. ((value == "TRUE" or value == "1") and "true" or "false") .. ' }' end
            write('Specialization _spec_pairs[]', {specializations = table.concat(specs, ",\n\t\t\t")})
        else write('Specialization *_spec_pairs') end
        if #data.feedbacks > 0 then
            local feedbacks = {}; for _, pair in ipairs(data.feedbacks) do local mask = 0; for i, name in ipairs(data.specialization_names) do if name == pair[2] then mask = 2 ^ (i - 1) end end; feedbacks[#feedbacks + 1] = '{ "' .. pair[1] .. '", ' .. ("%.0f"):format(mask) .. ' }' end
            write('Feedback _feedbacks[]', {feedbacks = table.concat(feedbacks, ",\n\t\t\t")})
        else write('Feedback *_feedbacks') end
        values['to_raw_cstring(header_data.vertex_lines)'] = U.raw(data.vertex); values['to_raw_cstring(header_data.fragment_lines)'] = U.raw(data.fragment)
        for _, name in ipairs({"uniforms", "ubos", "feedbacks", "texunits", "specialization_names"}) do values['len(header_data.' .. name .. ')'] = #data[name] end
        values.variant_count = math.max(1, #data.variant_defines)
        write('static const char _vertex_code[]', values)
        out(C.relative(file, root) .. ".gen.h", table.concat(body))
    end
end
