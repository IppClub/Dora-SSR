-- Execute the checked-in WebServer resource bootstrap, including binary markers.
local root = arg[1] or '.'
local file = assert(io.open(root .. '/Assets/Script/Dev/WebServer.lua', 'rb'))
local source = file:read('a'); file:close()
local marker = assert(source:find('\tlocal doraWeb = Path', 1, true))
local first = assert(source:sub(1, marker - 1):match('.*()thread%(function%(%)'))
local last = assert(source:find('\n\tif App.platform == "Emscripten"', marker, true))
local code = source:sub(first, last - 1) .. '\nend)'

local function fixture(compressed)
 local stored, copies = {}, 0
 local content = {assetPath = '/assets', appPath = '/app'}
 local app = {version = 'test-v1'}
 local prefix, ready = '/assets/www/', '/app/.www/dora-ready'
 function content:exist(name) return stored[name] ~= nil end
 function content:load(name) return assert(stored[name], name) end
 function content:save(name, value) stored[name] = value; return true end
 function content:remove(name)
  local remove = {}
  for key in pairs(stored) do if key:sub(1, #name + 1) == name .. '/' then remove[#remove + 1] = key end end
  for _, key in ipairs(remove) do stored[key] = nil end
  return true
 end
 function content:copyAsync(from, to)
  copies = copies + 1
  local values = {}
  for key, value in pairs(stored) do
   if key:sub(1, #from + 1) == from .. '/' then values[to .. key:sub(#from + 1)] = value end
  end
  for key, value in pairs(values) do stored[key] = value end
  return true
 end
 local suffix = compressed and '.gz' or ''
 for _, name in ipairs({'index.html', 'heavy-assets.json', 'web-player/runtime.json', 'compiler.html'}) do
  stored[prefix .. name .. suffix] = '\31\139\8\0stored-' .. name
 end
 if compressed then stored[prefix .. 'precompressed-assets.json'] = 'manifest-1' end
 local env = {Content = content, App = app, Path = function(...) return table.concat({...}, '/') end,
  thread = function(fn) fn() end, table = table, print = function() end}
 local run = assert(load(code, '@production-web-bootstrap', 't', env))
 run(); assert(copies == 1 and stored[ready]); assert(stored['/app/.www/index.html' .. suffix])
 local initial = stored[ready]
 run(); assert(copies == 1 and stored[ready] == initial)
 if compressed then
  stored[prefix .. 'precompressed-assets.json'] = 'manifest-2'
  run(); assert(copies == 2 and stored[ready] ~= initial)
 end
 local before = copies
 stored[prefix .. 'compiler.html' .. suffix] = 'changed-compiler'
 run(); assert(copies == before + 1)
 app.version = 'test-v2'; run(); assert(copies == before + 2)
 assert(not compressed or stored[prefix .. 'index.html'] == nil)
end
fixture(true); fixture(false)
print('PASS: production WebServer bootstrap copies gzip-only/legacy assets and detects manifest, compiler and engine changes')
