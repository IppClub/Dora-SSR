-- Exercise both production CLI HTTP entry points without building a Rust project.
local file = assert(io.open('Assets/Script/Dev/cli.lua'))
local source = file:read('*a'); file:close()
local function section(first, last)
 return source:sub(assert(source:find(first, 1, true)), assert(source:find(last, 1, true)) - 1)
end
local code = section('local function baseUrl', 'local function postJson')
 .. section('local function urlEncode', 'local function runRemoteFile')
 .. '\nreturn tryPostJson, uploadFile'
local requests = {}
local env = setmetatable({
 CLI = {
  readFile=function() return '\0asm\1\0\0\0' end,
  http=function(method, url, headers, body)
   requests[#requests+1] = {method=method, url=url, headers=headers, body=body}
   assert(headers['Sec-Fetch-Site']=='same-origin', 'local request missing authentication context')
   return {netStatus=0, statusCode=200, body='{}'}
  end,
 },
 json={encode=function() return '{}' end, decode=function() return {} end},
 filename=function() return 'test.wasm' end,
 pathJoin=function(a,b) return a..'/'..b end,
 fail=error, print=function() end,
}, {__index=_G})
local post, upload = assert(load(code, 'production CLI HTTP', 't', env))()
for _, host in ipairs({'127.0.0.1', 'localhost'}) do
 local opts={host=host, port=8866, timeout=10}
 assert(post(opts, '/status', {}))
 assert(upload(opts, 'test.wasm', '/target with spaces')=='/target with spaces/test.wasm')
end
assert(#requests==4)
assert(requests[1].headers['Content-Type']=='application/json')
assert(requests[2].headers['Content-Type']:match('^multipart/form%-data; boundary='))
assert(requests[2].url:find('/upload?path=%2Ftarget%20with%20spaces', 1, true))
assert(requests[2].body:find('\0asm', 1, true))
print('CLI local auth: JSON and multipart requests passed for both loopback hosts')
