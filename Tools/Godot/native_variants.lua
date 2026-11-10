function variant_target(source, flags)
    local definitions = {}
    for _, flag in ipairs(flags) do
        local name, value = flag:match("^%-D([^=]+)=?(.*)$")
        if name then definitions[name] = value end
    end
    if source:startswith("thirdparty/pcre2/") and table.contains({"16", "32"}, definitions.PCRE2_CODE_UNIT_WIDTH) then
        return "godot-pcre2-" .. definitions.PCRE2_CODE_UNIT_WIDTH
    end
    if source:startswith("thirdparty/libjpeg-turbo/") and table.contains({"8", "12"}, definitions.BITS_IN_JSAMPLE) then
        return "godot-jpeg-" .. definitions.BITS_IN_JSAMPLE
    end
    raise("Unregistered same-source variant: " .. source)
end

function manifest_actions(text)
    local actions = {}
    for target, body in text:gmatch('target%("([^"]+)"%)\n    add_files%(%s*(.-)    %)\ntarget_end%(%)') do
        local flags = {}; for flag in body:gmatch('flag%("([^"]+)"%)') do flags[#flags + 1] = flag end
        for source in body:gmatch('source%("([^"]+)"%)') do actions[#actions + 1] = {target, source, flags} end
    end
    return actions
end

function validate_native_variants(text)
    local counts, seen, count = {}, {}, 0
    for _, row in ipairs(manifest_actions(text)) do
        local target, source, flags = table.unpack(row)
        local identity = target .. "\0" .. source
        assert(not seen[identity], "Duplicate source/configuration within one xmake target"); seen[identity] = true
        if target:startswith("godot-pcre2-") or target:startswith("godot-jpeg-") then
            assert(target == variant_target(source, flags), "Native variant target and compile macros differ")
            counts[target] = (counts[target] or 0) + 1; count = count + 1
        end
    end
    local expected = {["godot-pcre2-16"] = 31, ["godot-pcre2-32"] = 31, ["godot-jpeg-8"] = 24, ["godot-jpeg-12"] = 24}
    for target, total in pairs(expected) do assert(counts[target] == total, "Incomplete codec variant compilation inventory: " .. target) end
    for target in pairs(counts) do assert(expected[target], "Unexpected codec variant: " .. target) end
    return count
end
