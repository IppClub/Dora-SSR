local moon = require("moon")
for k, v in pairs(moon) do
  rawset(builtin,k,v)
  rawset(_G,k,v)
end
return moon
