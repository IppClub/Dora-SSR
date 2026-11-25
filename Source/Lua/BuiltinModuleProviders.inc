// Shared by Lua registration and the Web compiler's module inventory.
DORA_NATIVE_LUA_MODULE("socket.core", luaopen_socket_core, 0)
DORA_NATIVE_LUA_MODULE("dora.remix_voice", luaopen_dora_remix_voice, 0)
DORA_LUA_MODULE("mime.core", luaopen_mime_core, 0)
DORA_LUA_MODULE("dora.https", luaopen_dora_https, 0)
DORA_LUA_MODULE("bit32", dora_open_bit32, 1)
