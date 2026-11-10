function generate(root, emit)
    local C = import("common", {rootdir = os.scriptdir()})
    local U = import("codegen_util", {rootdir = os.scriptdir()})
    local data = C.load(path.join(root, "core/extension/gdextension_interface.json"))
    local output = {}
    local function write(text) output[#output + 1] = text end
    local function allowed(value, required, optional)
        local names = {}; for _, name in ipairs(table.join(required, optional or {})) do names[name] = true end
        for name in pairs(value) do assert(names[name], "Unknown interface key: " .. name) end
        for _, name in ipairs(required) do assert(value[name] ~= nil, "Missing interface key: " .. name) end
    end
    allowed(data, {"_copyright", "$schema", "format_version", "types", "interface"})
    local valid = {}; for _, name in ipairs({"void", "int8_t", "uint8_t", "int16_t", "uint16_t", "int32_t", "uint32_t", "int64_t", "uint64_t", "size_t", "char", "char16_t", "char32_t", "wchar_t", "float", "double"}) do valid[name] = true end
    local function check_type(name)
        assert(name ~= "void" and name ~= "const void", "Invalid non-pointer void interface type")
        assert(valid[name:gsub("^const ", ""):gsub("%*$", "")], "Unknown interface type: " .. name)
    end
    local function format_type(name, identifier)
        if name:endswith("*") then name = name:sub(1, -2) .. " *" end
        return name .. (identifier and ((name:endswith("*") and "" or " ") .. identifier) or "")
    end
    local function doc(lines, indent)
        indent = indent or ""
        if #lines == 1 then write(indent .. "/* " .. lines[1] .. " */\n"); return end
        for i, line in ipairs(lines) do write(indent .. (i == 1 and "/*" or " *") .. (line ~= "" and " " .. line or "") .. "\n") end
        write(indent .. " */\n")
    end
    local function deprecated(value)
        allowed(value, {"since"}, {"message", "replace_with"})
        return "Deprecated in Godot " .. value.since .. "." .. (value.message and " " .. value.message or "") .. (value.replace_with and " Use `" .. value.replace_with .. "` instead." or "")
    end
    local function comment(value) return value.deprecated and " /* " .. deprecated(value.deprecated) .. " */" or "" end
    local function args(arguments)
        local result = {}
        for _, arg in ipairs(arguments or {}) do allowed(arg, {"type"}, {"name", "description"}); check_type(arg.type); result[#result + 1] = format_type(arg.type, arg.name) end
        return table.concat(result, ", ")
    end
    local function fn(value, name, no_comment)
        if value.return_value then check_type(value.return_value.type) end
        write("typedef " .. format_type(value.return_value and value.return_value.type or "void", "(*" .. (name or value.name) .. ")(" .. args(value.arguments) .. ")") .. ";" .. (no_comment and "" or comment(value)) .. "\n")
    end
    local templates = U.literals(path.join(root, "core/extension/make_interface_header.py"))
    for _, value in ipairs(templates) do if value:find("#ifndef __cplusplus", 1, true) then write(value) end end
    local handles, replacements = {}, {}
    for _, value in ipairs(data.types) do
        if value.description then doc(value.description) end
        if value.deprecated then deprecated(value.deprecated); if value.deprecated.replace_with then replacements[#replacements + 1] = {value.name, value.deprecated.replace_with} end end
        if value.kind == "handle" then
            allowed(value, {"name", "kind"}, {"is_const", "is_uninitialized", "parent", "description", "deprecated"})
            if value.parent then assert(handles[value.parent], "Unknown handle parent") end
            write("typedef " .. format_type(value.is_const and "const void*" or "void*", value.name) .. ";" .. comment(value) .. "\n"); handles[value.name] = true
        elseif value.kind == "alias" then
            allowed(value, {"name", "kind", "type"}, {"description", "deprecated"}); check_type(value.type)
            write("typedef " .. format_type(value.type, value.name) .. ";" .. comment(value) .. "\n")
        elseif value.kind == "enum" then
            allowed(value, {"name", "kind", "values"}, {"is_bitfield", "description", "deprecated"}); write("typedef enum {\n")
            for _, item in ipairs(value.values) do allowed(item, {"name", "value"}, {"description", "deprecated"}); if item.description then doc(item.description, "\t") end; write("\t" .. item.name .. " = " .. (type(item.value) == "number" and ("%.0f"):format(item.value) or item.value) .. ",\n") end
            write("} " .. value.name .. ";" .. comment(value) .. "\n\n")
        elseif value.kind == "function" then
            allowed(value, {"name", "kind", "arguments"}, {"return_value", "description", "deprecated"}); fn(value)
        elseif value.kind == "struct" then
            allowed(value, {"name", "kind", "members"}, {"description", "deprecated"}); write("typedef struct {\n")
            for _, member in ipairs(value.members) do allowed(member, {"name", "type"}, {"description"}); check_type(member.type); if member.description then doc(member.description, "\t") end; write("\t" .. format_type(member.type, member.name) .. ";\n") end
            write("} " .. value.name .. ";" .. comment(value) .. "\n\n")
        else raise("Unknown interface kind: " .. tostring(value.kind)) end
        valid[value.name] = value
    end
    local function check_replacements(rows, inventory)
        for _, row in ipairs(rows) do assert(inventory[row[2]] and (type(inventory[row[2]]) ~= "table" or not inventory[row[2]].deprecated), "Unknown/deprecated replacement for " .. row[1]) end
    end
    check_replacements(replacements, valid)
    replacements = {}; local interfaces = {}
    for _, value in ipairs(data.interface) do
        allowed(value, {"name", "arguments", "since", "description"}, {"return_value", "see", "legacy_type_name", "deprecated"})
        local lines = {"@name " .. value.name, "@since " .. value.since}
        if value.deprecated then lines[#lines + 1] = "@deprecated " .. deprecated(value.deprecated); if value.deprecated.replace_with then replacements[#replacements + 1] = {value.name, value.deprecated.replace_with} end end
        table.join2(lines, {"", value.description[1]})
        if #value.description > 1 then lines[#lines + 1] = ""; table.join2(lines, table.slice(value.description, 2)) end
        lines[#lines + 1] = ""
        for _, arg in ipairs(value.arguments) do assert(arg.description, "Interface argument missing docs"); lines[#lines + 1] = "@param " .. arg.name .. " " .. table.concat(arg.description, " ") end
        if value.return_value then assert(value.return_value.description, "Interface return missing docs"); table.join2(lines, {"", "@return " .. table.concat(value.return_value.description, " ")}) end
        if value.see then lines[#lines + 1] = ""; for _, see in ipairs(value.see) do lines[#lines + 1] = "@see " .. see end end
        write("/**\n"); for _, line in ipairs(lines) do write(" *" .. (line ~= "" and " " .. line or "") .. "\n") end; write(" */\n")
        local name = value.name:gsub("([^_]+)_?", function (word) return word:sub(1, 1):upper() .. word:sub(2):lower() end)
        fn(value, "GDExtensionInterface" .. name, true); write("\n"); interfaces[value.name] = value
    end
    check_replacements(replacements, interfaces)
    write("#ifdef __cplusplus\n}\n#endif\n")
    emit("core/extension/gdextension_interface.gen.h", U.wrapped(root, "gdextension_interface.gen.h", table.concat(output)))
end
