# Dora integration

Dora vendors the LuaSocket 3.1.0 sources in `src`. The xmake targets build the
cross-platform TCP/UDP and MIME cores as reusable objects and as a standalone
static library. Dora's curated Love archive consumes the object target so both
the Dora and Love Lua states resolve the same implementation. The HTTP Lua
module contains a small Dora-specific HTTPS dispatch to the XRT-backed module.
Platform-specific Unix-domain and serial modules are intentionally not
registered.

HTTPS requests made through `socket.http` or `ssl.https` use Dora's XRT HTTP
client. This provides the LuaSocket/LuaSec high-level `request` forms without
embedding LuaSec or exposing a general-purpose TLS socket wrapper.

The upstream Lua modules are embedded so they can be loaded in isolated Love
states and Love worker states without opening `package.path` or `package.cpath`.
After updating an upstream Lua file, regenerate the checked-in header with:

```sh
python3 Source/3rdParty/LuaSocket/generate_lua_scripts.py
```
