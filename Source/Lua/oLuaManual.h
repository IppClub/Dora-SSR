#ifndef __DOROTHY_LUA_OLUAMANUAL_H__
#define __DOROTHY_LUA_OLUAMANUAL_H__

NS_DOROTHY_BEGIN

/* oContent */
void __oContent_loadFile(lua_State* L, oContent* self, const char* filename);
#define oContent_loadFile(self,filename) {__oContent_loadFile(tolua_S,self,filename);return 1;}
void __oContent_getDirEntries(lua_State* L, oContent* self, const char* path, bool isFolder);
#define oContent_getDirEntries(self,path,isFolder) {__oContent_getDirEntries(tolua_S,self,path,isFolder);return 1;}
void oContent_setSearchPaths(oContent* self, char* paths[], int length);
inline oContent* oContent_shared() { return &oSharedContent; }

NS_DOROTHY_END

#endif // __DOROTHY_LUA_OLUAMANUAL_H__
