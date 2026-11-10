-- Shared xmake-Lua support for repository-owned Godot build tools.
local ROOT=path.normalize(path.absolute(path.join(os.scriptdir(),"../..")))
function root() return ROOT end
function read(file) return assert(io.readfile(file,{encoding="binary"}),"Cannot read "..file) end
function write(file,value) os.mkdir(path.directory(file));io.writefile(file,value,{encoding="binary"}) end
function load(file) return import("ordered_json",{rootdir=os.scriptdir()}).decode(read(file)) end
function serialize(value,compact) return import("ordered_json",{rootdir=os.scriptdir()}).encode(value,compact) end
function save(file,value) write(file,serialize(value).."\n") end
function array(values) import("core.base.json");return json.mark_as_array(values or {}) end
function null() import("core.base.json");return json.purenull end
function digest(file) return hash.sha256(file) end
function data_digest(value) import("core.base.bytes");return hash.sha256(bytes(value)) end
function relative(file,base) return path.relative(file,base):gsub("\\","/") end
function real(file,depth)
    depth=depth or 0;assert(depth<256,"Symlink/path recursion limit: "..file)
    file=path.normalize(path.absolute(file));local parent=path.directory(file)
    if not parent or parent==file then return file end
    if os.islink(file) then return real(path.absolute(os.readlink(file),parent),depth+1) end
    return path.join(real(parent,depth+1),path.filename(file))
end
function safe_relative(name)
    assert(type(name)=="string" and name~="" and not name:find("\\",1,true) and not name:match("^[/~]") and not name:match("^%a:"),"Unsafe relative path: "..tostring(name))
    for part in name:gmatch("[^/]+") do assert(part~=".." and part~=".","Unsafe relative path: "..name) end
    assert(not name:find("//",1,true),"Unsafe relative path: "..name)
    return name
end
function safe_file(base,name)
    safe_relative(name);local file=path.join(base,name)
    assert(os.isfile(file) and not os.islink(file),"Missing/unsafe input: "..name)
    local actual=real(file);local parent=real(base)
    assert(actual and parent and (actual==parent or actual:startswith(parent..path.sep())),"Input escapes root: "..name)
    return file
end
-- Lua string comparison follows LC_COLLATE; build outputs must use byte order.
function byte_less(a,b)
    for i=1,math.min(#a,#b) do
        local left,right=a:byte(i),b:byte(i)
        if left~=right then return left<right end
    end
    return #a<#b
end
function files(base)
    local result=os.files(path.join(base,"**"));table.sort(result);return result
end
function keys(values) local result={};for key in pairs(values) do result[#result+1]=key end;table.sort(result);return result end
function copy(source,destination)
    if os.isfile(destination) and digest(source)==digest(destination) then return false end
    os.mkdir(path.directory(destination));os.cp(source,destination);return true
end
function args(argv, definitions)
    local result={positional={}};local i=1
    while i<=#argv do
        local token=argv[i]
        if token=="--help" or token=="-h" then
            print("Usage: xmake lua <tool.lua> [options]")
            for _,key in ipairs(keys(definitions)) do
                print("  --%s%s",key,definitions[key]=="flag" and "" or " VALUE")
            end
            os.exit(0)
        end
        if token:startswith("--") then
            local key,value=token:match("^%-%-([^=]+)=(.*)$")
            key=key or token:sub(3)
            local spec=definitions[key];assert(spec,"Unknown option: --"..key)
            if spec=="flag" then assert(value==nil,"Flag takes no value: "..key);value=true
            elseif value==nil then i=i+1;value=argv[i];assert(value and not value:startswith("--"),"Missing value: --"..key) end
            if spec=="many" then result[key]=result[key] or {};table.insert(result[key],value) else result[key]=value end
        else result.positional[#result.positional+1]=token end
        i=i+1
    end
    return result
end
function required(args,key) return assert(args[key],"Missing --"..key) end
function choice(value,values)
    for _,candidate in ipairs(values) do if value==candidate then return value end end
    raise("Unsupported value: %s",tostring(value))
end
function number(value,minimum,maximum)
    local result=tonumber(value);assert(result and result==result and result~=math.huge and result~=-math.huge and result>=minimum and (not maximum or result<=maximum),"Invalid number: "..tostring(value));return result
end
function run(tool,arguments,opt)
    opt=opt or {};os.vrunv(tool,arguments,opt)
end
function tool(name,arguments,opt)
    local file=path.join(ROOT,"Tools/Godot",name..".lua")
    run(os.programfile(),table.join({"lua",file},arguments or {}),opt)
end
function download(url,destination)
    import("net.http");os.mkdir(path.directory(destination));http.download(url,destination)
end
function extract(archive_file,destination,opt)
    import("utils.archive");os.mkdir(destination);archive.extract(archive_file,destination,opt)
end
function snapshot(base,inputs)
    local result={};for _,file in ipairs(inputs or files(base)) do if os.isfile(file) then result[relative(file,base)]=digest(file) end end;return result
end
function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
