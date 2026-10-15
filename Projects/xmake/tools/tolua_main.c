#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <direct.h>
#define dora_chdir _chdir
#else
#include <unistd.h>
#define dora_chdir chdir
#endif

int luaopen_lfs(lua_State *L);

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s <tolua++.lua>\n", argv[0]);
        return 2;
    }

    size_t script_size = strlen(argv[1]) + 1;
    char *script = (char *)malloc(script_size);
    if (!script) {
        fputs("failed to copy tolua script path\n", stderr);
        return 1;
    }
    memcpy(script, argv[1], script_size);
    char *filename = script;
    char *slash = strrchr(script, '/');
#if defined(_WIN32)
    char *backslash = strrchr(script, '\\');
    if (!slash || (backslash && backslash > slash)) {
        slash = backslash;
    }
#endif
    if (slash) {
        *slash = '\0';
        filename = slash + 1;
        if (dora_chdir(script) != 0) {
            fprintf(stderr, "failed to enter tolua script directory: %s\n", script);
            free(script);
            return 1;
        }
    }

    lua_State *L = luaL_newstate();
    if (!L) {
        fputs("failed to create Lua state\n", stderr);
        free(script);
        return 1;
    }
    luaL_openlibs(L);

    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_pushcfunction(L, luaopen_lfs);
    lua_setfield(L, -2, "lfs");
    lua_pop(L, 2);

    if (luaL_loadfile(L, filename) != 0 || lua_pcall(L, 0, LUA_MULTRET, 0) != 0) {
        fprintf(stderr, "%s\n", lua_tostring(L, -1));
        lua_close(L);
        free(script);
        return 1;
    }
    lua_close(L);
    free(script);
    return 0;
}
