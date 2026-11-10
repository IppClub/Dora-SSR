-- Lua implementation of the pinned upstream virtual/wrapper expansion rules.
function generate(root, emit)
    local U = import("codegen_util", {rootdir = os.scriptdir()})
    local virtual = path.join(root, "core/object/make_virtuals.py")
    local wrapper = path.join(root, "core/extension/make_wrappers.py")
    local function sub(text, values)
        for _, name in ipairs((function () local names = {}; for name in pairs(values) do names[#names + 1] = name end; table.sort(names, function (a, b) return #a > #b end); return names end)()) do text = U.replace(text, name, values[name]) end
        return text
    end
    local function expand(count, constant, returns, required, compat)
        local text = U.named(virtual, "proto")
        text = sub(text, {['$SCRIPTCALL'] = compat and "" or U.named(virtual, "script_call"), ['$SCRIPTHASMETHOD'] = compat and "" or U.named(virtual, "script_has_method")})
        local version, flags = tostring(count), "METHOD_FLAG_VIRTUAL"
        local info = ""
        if returns then
            version = version .. "R"
            text = sub(text, {['$RET'] = "m_ret,", ['$RVOID'] = "(void)r_ret;", ['$CALLPTRRETDEF'] = "PtrToArg<m_ret>::EncodeT ret;"})
            info = "method_info.return_val = GetTypeInfo<m_ret>::get_class_info();\\\n\t\tmethod_info.return_val_metadata = GetTypeInfo<m_ret>::METADATA;"
        else text = sub(text, {['$RET '] = "", ['\t\t$RVOID\\\n'] = "", ['\t\t\t$CALLPTRRETDEF\\\n'] = ""}) end
        if constant then version = version .. "C"; flags = flags .. " | METHOD_FLAG_CONST"; text = U.replace(text, "$CONST", "const")
        else text = U.replace(text, "$CONST ", "") end
        if required then
            version = version .. "_REQUIRED"; flags = flags .. " | METHOD_FLAG_VIRTUAL_REQUIRED"
            text = U.replace(text, "$REQCHECK", 'ERR_PRINT_ONCE("Required virtual method " + get_class() + "::" + #m_name + " must be overridden before calling.");')
        else text = U.replace(text, "\t\t$REQCHECK\\\n", "") end
        if compat then version = version .. "_COMPAT"; text = sub(text, {['$COMPAT'] = "true", ['$ALIAS'] = "m_alias,", ['$VARNAME'] = "m_alias"})
        else text = sub(text, {['$COMPAT'] = "false", ['$ALIAS '] = "", ['$VARNAME'] = "m_name"}) end
        text = sub(text, {['$METHOD_FLAGS'] = flags, ['$VER'] = version})
        local types, args, variants, variant_ptrs, pointers, encoded = {}, {}, {}, {}, {}, {}
        for i = 1, count do
            types[#types + 1] = "m_type" .. i; args[#args + 1] = "m_type" .. i .. " arg" .. i
            variants[#variants + 1] = "VariantInternal::make(arg" .. i .. ")"; variant_ptrs[#variant_ptrs + 1] = "&vargs[" .. (i - 1) .. "]"
            encoded[#encoded + 1] = "PtrToArg<m_type" .. i .. ">::EncodeT argval" .. i .. "; PtrToArg<m_type" .. i .. ">::encode(arg" .. i .. ", &argval" .. i .. ");\\\n"
            pointers[#pointers + 1] = "&argval" .. i
        end
        if count > 0 then
            if info ~= "" then info = info .. "\\\n\t\t" end
            info = info .. "_gdvirtual_set_method_info_args<" .. table.concat(types, ", ") .. ">(method_info);"
            text = sub(text, {['$CALLSIARGS'] = "Variant vargs[" .. count .. "] = { " .. table.concat(variants, ", ") .. " };\\\n\t\t\tconst Variant *vargptrs[" .. count .. "] = { " .. table.concat(variant_ptrs, ", ") .. " };",
                ['$CALLSIARGPASS'] = "(const Variant **)vargptrs, " .. count,
                ['$CALLPTRARGS'] = table.concat(encoded, "\t\t\t") .. "\t\t\tGDExtensionConstTypePtr argptrs[" .. count .. "] = { " .. table.concat(pointers, ", ") .. " };",
                ['$CALLPTRARGPASS'] = "reinterpret_cast<GDExtensionConstTypePtr *>(argptrs)"})
        else text = sub(text, {['\t\t\t$CALLSIARGS\\\n'] = "", ['$CALLSIARGPASS'] = "nullptr, 0", ['\t\t\t$CALLPTRARGS\\\n'] = "", ['$CALLPTRARGPASS'] = "nullptr"}) end
        if returns then
            args[#args + 1] = "m_ret &r_ret"
            text = sub(text, {['$CALLSIBEGIN'] = "Variant ret = ", ['$CALLSIRET'] = "r_ret = VariantCaster<m_ret>::cast(ret);", ['$CALLPTRRETPASS'] = "&ret", ['$CALLPTRRET'] = "r_ret = (m_ret)ret;"})
        else text = sub(text, {['$CALLSIBEGIN'] = "", ['\t\t\t\t$CALLSIRET\\\n'] = "", ['$CALLPTRRETPASS'] = "nullptr", ['\t\t\t\t$CALLPTRRET\\\n'] = ""}) end
        return sub(text, {[' $ARG'] = count > 0 and ", " .. table.concat(types, ", ") or "", ['$CALLARGS'] = table.concat(args, ", "),
            [info ~= "" and '$FILL_METHOD_INFO' or '\t\t$FILL_METHOD_INFO\\\n'] = info})
    end
    local text = U.named(virtual, "txt")
    for count = 0, 12 do
        text = text .. "/* " .. count .. " Arguments */\n\n"
        for _, kind in ipairs({{false, false}, {true, false}, {false, true}}) do
            for _, constant in ipairs({false, true}) do for _, returns in ipairs({false, true}) do text = text .. expand(count, constant, returns, kind[1], kind[2]) end end
        end
    end
    assert(not text:find("%$[%u_]+"), "Unexpanded virtual template field")
    emit("core/object/gdvirtual.gen.h", text)
    text = "#pragma once"
    for _, extension in ipairs({true, false}) do
        for count = 0, 12 do
            text = text .. "\n/* " .. (extension and "Extension" or "Module") .. " Wrapper " .. count .. " Arguments */\n"
            for _, constant in ipairs({false, true}) do for _, returns in ipairs({false, true}) do
                local types, args, calls = {}, {}, {}
                for i = 1, count do types[#types + 1] = "m_type" .. i; args[#args + 1] = "m_type" .. i .. " arg" .. i; calls[#calls + 1] = "arg" .. i end
                local body = U.named(wrapper, extension and "proto_ex" or "proto_mod")
                body = sub(body, {['$RETTYPE'] = returns and "m_ret, " or "", ['$RETVAL'] = returns and "m_ret" or "void",
                    ['$RETX'] = returns and "return" or "", ['$RETPRE'] = returns and "m_ret ret; ZeroInitializer<m_ret>::initialize(ret);\\\n" or "",
                    ['$RETPOST'] = returns and "return ret;\\\n" or "return;", ['$CONST'] = constant and "const" or "",
                    ['$VER'] = count .. (returns and "R" or "") .. (constant and "C" or ""),
                    ['$ARG'] = count > 0 and ", " .. table.concat(types, ", ") or "", ['$FUNCARGS'] = table.concat(args, ", "),
                    ['$CALLARGS'] = (extension and count > 0 and ", " or "") .. table.concat(calls, ", "), ['$RETREF'] = returns and ", ret" or ""})
                text = text .. body
            end end
        end
    end
    emit("core/extension/ext_wrappers.gen.h", text)
end
