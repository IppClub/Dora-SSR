-- Preserve JSON object order where historical signed digests depend on it.
local orders, arrays = {}, {}
local function skip(text,position) local _,last=text:find("^%s*",position);return (last or position-1)+1 end
local function quoted(text,position)
    local start=position;position=position+1
    while position<=#text do
        local c=text:sub(position,position)
        if c=='\\' then position=position+2 elseif c=='"' then return text:sub(start,position),position+1 else position=position+1 end
    end
    raise("Unterminated JSON string")
end
local function annotate(text,node,position,json)
    position=skip(text,position);local c=text:sub(position,position)
    if c=='{' then
        local order={};orders[node]=order;position=skip(text,position+1)
        if text:sub(position,position)=='}' then return position+1 end
        while true do
            local encoded;encoded,position=quoted(text,position);local key=json.decode(encoded)
            order[#order+1]=key;position=skip(text,position);assert(text:sub(position,position)==':')
            position=annotate(text,node[key],position+1,json);position=skip(text,position)
            local delimiter=text:sub(position,position);position=position+1
            if delimiter=='}' then return position end
            assert(delimiter==',');position=skip(text,position)
        end
    elseif c=='[' then
        arrays[node]=true;json.mark_as_array(node);position=skip(text,position+1);local index=1
        if text:sub(position,position)==']' then return position+1 end
        while true do
            position=annotate(text,node[index],position,json);index=index+1;position=skip(text,position)
            local delimiter=text:sub(position,position);position=position+1
            if delimiter==']' then return position end
            assert(delimiter==',');position=skip(text,position)
        end
    elseif c=='"' then local _,last=quoted(text,position);return last
    else return text:find('[,}%]%s]',position) or #text+1 end
end
function decode(text)
    import("core.base.json")
    local function normalize(value)
        if value==json.null then return json.purenull end
        if type(value)=="table" then for key,item in pairs(value) do value[key]=normalize(item) end end
        return value
    end
    local value=normalize(json.decode(text));annotate(text,value,1,json);return value
end
local function quote(value)
    return '"' .. value:gsub('[\\"%z\1-\31]', function (character)
        return ({['\\'] = '\\\\', ['"'] = '\\"', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', ['\8'] = '\\b', ['\12'] = '\\f'})[character]
            or ('\\u%04x'):format(character:byte())
    end) .. '"'
end
local function encode_value(value,level,json,compact)
    if value==json.purenull then return "null" end
    if type(value)=="string" then return quote(value) end
    if type(value)~="table" then return (json.encode(value):gsub('\\/','/')) end
    local array=arrays[value] or json.is_marked_as_array(value) or #value>0
    local members={};local prefix=compact and '' or string.rep(' ',level*2);local indent=compact and '' or prefix..'  '
    if array then
        for _,item in ipairs(value) do members[#members+1]=indent..encode_value(item,level+1,json,compact) end
    else
        local seen={};local names={}
        for _,name in ipairs(orders[value] or {}) do if value[name]~=nil then names[#names+1]=name;seen[name]=true end end
        local extra={};for name in pairs(value) do if not seen[name] then extra[#extra+1]=name end end;table.sort(extra);table.join2(names,extra)
        for _,name in ipairs(names) do members[#members+1]=indent..quote(name)..(compact and ':' or ': ')..encode_value(value[name],level+1,json,compact) end
    end
    local first,last=array and '[' or '{',array and ']' or '}'
    if #members==0 then return first..last end
    if compact then return first..table.concat(members,',')..last end
    return first..'\n'..table.concat(members,',\n')..'\n'..prefix..last
end
function encode(value,compact)
    import("core.base.json");return encode_value(value,0,json,compact)
end
function keys(value)
    local result, seen, extra = {}, {}, {}
    for _, key in ipairs(orders[value] or {}) do if value[key] ~= nil then result[#result + 1] = key; seen[key] = true end end
    for key in pairs(value) do if not seen[key] then extra[#extra + 1] = key end end
    table.sort(extra); table.join2(result, extra); return result
end
