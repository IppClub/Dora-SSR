-- Keep WebServer's clone target check aligned with the backend command parser.
local f=assert(io.open('Assets/Script/Dev/WebServer.lua'))
local source=f:read('*a');f:close()
local first=assert(source:find('local gitShellSplit',1,true))
local last=assert(source:find('local gitPathInsideRepo',first,true))
local Path=setmetatable({
 getFilename=function(_,s) return s:match('[^/]+$') or '' end,
 getRelative=function(_,p,root) return p:sub(#root+2) end,
}, {__call=function(_,root,child)return root..'/'..child end})
local env=setmetatable({Path=Path},{__index=_G})
local split,target=assert(load(source:sub(first,last-1)..'\nreturn gitShellSplit,gitCloneTargetPath','production clone parser','t',env))()
local cases={
 {'clone https://example/repo.git','repo'},
 {'clone --depth 1 https://example/repo.git escape','escape'},
 {'git clone -b main https://example/repo.git --depth 1 escape','escape'},
 {'clone https://example/repo.git " escape "',' escape '},
 {'clone https://example/repo.git "repo\194\160"','repo\194\160'},
 {"clone 'https://example/repo ' ",'repo '},
 {"clone https://example/repo.git 'a\\b'",'a\\b'},
 {'clone https://example/repo.git leaf\vname','leaf\vname'},
 {'clone git@example:repo.git','repo'},
 {'clone --unknown https://example/repo.git',false},
 {'clone --depth',false},
 {'clone https://example/repo.git one two',false},
}
for _,case in ipairs(cases) do
 local got=target('/root',case[1]);local expected=case[2] and '/root/'..case[2] or nil
 assert(got==expected,case[1]..': '..tostring(got)..' != '..tostring(expected))
end
assert(split("clone 'a\\b'")[2]=='a\\b')
print('Git clone path parsing: 12 option, whitespace, quoting and invalid-command cases passed')
