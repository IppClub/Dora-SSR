-- Offline API documentation from the pinned Godot XML; run with xmake lua.
local ROOT = path.absolute(path.join(os.scriptdir(), "../.."))
local function children(node, name)
    local result = {}
    for _, child in ipairs(node.children or {}) do
        if child.name == name then result[#result + 1] = child end
    end
    return result
end
local function child(node, name) return children(node, name)[1] end
local function dedent(value)
    local lines, prefix = value:split("\n", {plain = true, strict = true}), nil
    for _, line in ipairs(lines) do
        if line:find("%S") then
            local indent = line:match("^([ \t]*)")
            prefix = prefix or indent
            while prefix ~= "" and indent:sub(1, #prefix) ~= prefix do prefix = prefix:sub(1, -2) end
        end
    end
    if prefix and prefix ~= "" then
        for i, line in ipairs(lines) do if line:sub(1, #prefix) == prefix then lines[i] = line:sub(#prefix + 1) end end
    end
    return table.concat(lines, "\n"):trim()
end
local function normal_markup(value)
    for tag, marker in pairs({b = "**", i = "*"}) do value = value:gsub("%[" .. tag .. "%]", marker):gsub("%[/" .. tag .. "%]", marker) end
    value = value:gsub("%[br%]", "\n")
    value = value:gsub("%[(%w+) ([^%]]+)%]", function(kind, symbol)
        if ({method=true, member=true, signal=true, enum=true, constant=true, param=true})[kind] then return "`" .. symbol .. "`" end
        return "[" .. kind .. " " .. symbol .. "]"
    end)
    return value:gsub("%[([@%w_]+)%]", "`%1`")
end
local function text(node, xml)
    if not node then return "" end
    local value = dedent(xml.text_of(node))
    value = value:gsub("%[csharp[^%]]*%].-%[/csharp%]", ""):gsub('%[codeblock lang="?csharp"?%].-%[/codeblock%]', "")
    value = value:gsub("%[codeblocks%]", ""):gsub("%[/codeblocks%]", "")
    value = value:gsub("%[gdscript[^%]]*%]", "```gdscript\n"):gsub("%[/gdscript%]", "\n```")
    value = value:gsub("%[codeblock([^%]]*)%]", function(attrs) return "```" .. (attrs:match('lang="?([%w+%-]+)') or "gdscript") .. "\n" end):gsub("%[/codeblock%]", "\n```")
    for _, tag in ipairs({"code", "kbd"}) do value = value:gsub("%["..tag.."%]", "`"):gsub("%[/"..tag.."%]", "`") end
    value = value:gsub("%[code%s+[^%]]+%]", "`")
    local parts, position = {}, 1
    while position <= #value do
        local first = value:find("`", position, true)
        if not first then parts[#parts+1] = normal_markup(value:sub(position)); break end
        parts[#parts+1] = normal_markup(value:sub(position, first-1))
        local token = value:sub(first, first+2) == "```" and "```" or "`"
        local last = value:find(token, first+#token, true)
        local newline = value:find("\n", first+1, true)
        if token == "`" and newline and last and newline < last then last = nil end
        if not last then parts[#parts+1] = "`"; position=first+1
        else
        parts[#parts+1] = value:sub(first, last+#token-1); position = last+#token
        end
    end
    return table.concat(parts):trim()
end
local function api_type(attrs)
    local value = attrs.enum or attrs.type or "Variant"
    if value:startswith("typedarray::") then value = "Array[" .. value:sub(13) .. "]" end
    return value
end
local function signature(node, name)
    local params = children(node, "param")
    table.sort(params, function(a,b) return tonumber(a.attrs.index or 0) < tonumber(b.attrs.index or 0) end)
    local values = {}
    for _, param in ipairs(params) do
        local attrs=param.attrs; local value=(attrs.name or "") .. ": " .. api_type(attrs)
        if attrs.default then value=value .. " = " .. attrs.default end
        values[#values+1]=value
    end
    local returns=child(node,"return")
    return name .. "(" .. table.concat(values, ", ") .. ") -> " .. (returns and api_type(returns.attrs) or "void")
end
local function render(node, source, version, xml)
    local attrs=node.attrs; local name=attrs.name
    local lines={"# "..name,"","Godot: "..version,"Language: English","Source: "..source,""}
    local function append(values) for _, value in ipairs(values) do lines[#lines+1]=value end end
    if attrs.inherits then append({"Inherits: `"..attrs.inherits.."`","Parent reference: @dora-doc/godot-api/classes/"..attrs.inherits..".md",""}) end
    append({"Reference availability is not runtime support. Editor-only APIs, C#/Mono and native GDExtensions are not supported by Dora Godot game development.",""})
    if name:startswith("Editor") then append({"Editor reference: this class is not a supported Dora game runtime API.",""}) end
    for _, part in ipairs({"brief_description","description"}) do local value=text(child(node,part),xml);if value~="" then append({value,""}) end end
    for _, pair in ipairs({{"constructors","constructor"},{"methods","method"},{"operators","operator"},{"signals","signal"},{"members","member"},{"constants","constant"},{"annotations","annotation"}}) do
        local group=child(node,pair[1]);local tag=pair[2]
        for _, item in ipairs(group and children(group,tag) or {}) do
            local item_attrs=item.attrs;local symbol=item_attrs.name or ""
            append({"## "..name.."."..symbol,"","Kind: "..tag})
            if tag=="member" or tag=="constant" then
                append({"Type: `"..(item_attrs.type or "Variant").."`"})
                for _, key in ipairs({"default","value","enum","setter","getter"}) do if item_attrs[key] then append({key..": `"..item_attrs[key].."`"}) end end
            else append({"```gdscript",signature(item,symbol),"```"}) end
            for _, key in ipairs({"qualifiers","deprecated","experimental"}) do if item_attrs[key] then append({key..": "..item_attrs[key]}) end end
            local value=text((tag=="member" or tag=="constant") and item or child(item,"description"),xml)
            if value~="" then append({"",value}) end
            append({""})
        end
    end
    return table.concat(lines,"\n"):rtrim().."\n"
end
function generate(source, output, check)
    import("core.base.xml")
    import("core.base.json")
    import("core.base.bytes")
    local upstream=path.join(source,"UPSTREAM.json");local metadata=json.loadfile(upstream)
    local inputs=os.files(path.join(source,"doc/classes/*.xml"));table.sort(inputs)
    local modules=os.files(path.join(source,"modules/**/doc_classes/*.xml"));table.sort(modules);table.join2(inputs,modules)
    local documents,buffers={}, {assert(io.readfile(upstream))}
    for _, file in ipairs(inputs) do
        local relative=path.relative(file,source):gsub("\\","/");local data=assert(io.readfile(file))
        table.join2(buffers,{relative,"\0",data})
        local node=xml.decode(data);local name=node.attrs.name
        assert(name and name:match("^[@%w_]+$"),"Invalid Godot class name: "..relative)
        local target="classes/"..name..".md";assert(not documents[target],"Duplicate class: "..name)
        documents[target]=render(node,relative,metadata.version,xml)
    end
    documents["README.md"]=assert(io.readfile(path.join(ROOT,"Tools/Godot/api_docs.md")))
    for _, name in ipairs({"LICENSE.txt","COPYRIGHT.txt"}) do documents[name]=assert(io.readfile(path.join(source,name))) end
    local manifest={format_version=1,godot_version=metadata.version,upstream_commit=metadata.upstream_commit,source_sha256=hash.sha256(bytes(table.concat(buffers))),class_count=#inputs,language="en",files={}}
    for name,value in pairs(documents) do manifest.files[name]=hash.sha256(bytes(value)) end
    documents["manifest.json"]=json.encode(manifest,{pretty=true,indent=2,orderkeys=true}).."\n"
    local actual={}; for _,file in ipairs(os.files(path.join(output,"**"))) do actual[path.relative(file,output):gsub("\\","/")]=true end
    if not table.empty(actual) then
        local previous=json.loadfile(path.join(output,"manifest.json"))
        assert(previous.format_version==1 and previous.godot_version and type(previous.files)=="table","Refusing to replace non-generated documentation")
    end
    local changed=false
    for name in pairs(actual) do if not documents[name] then changed=true;if not check then os.rm(path.join(output,name)) end end end
    for name,value in pairs(documents) do
        local target=path.join(output,name)
        if not os.isfile(target) or io.readfile(target)~=value then changed=true;if not check then os.mkdir(path.directory(target));io.writefile(target,value) end end
    end
    assert(not check or not changed,"Godot API docs are missing or stale; run xmake lua Tools/Godot/generate_api_docs.lua")
    print("Godot API docs: %d classes, %s, %s",#inputs,metadata.version,check and "verified" or changed and "updated" or "unchanged")
    return manifest
end
function main(...)
    import("core.base.option")
    local args=option.parse({...},{{nil,"source","kv",path.join(ROOT,"Source/3rdParty/Godot"),"Pinned Godot source"},{nil,"output","kv",path.join(ROOT,"Assets/Doc/godot-api"),"Generated docs directory"},{nil,"check","k",nil,"Verify output without writing"}})
    generate(args.source,args.output,args.check)
end
