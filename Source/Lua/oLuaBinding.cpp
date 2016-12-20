/*
** Lua binding: LuaBinding
** Generated automatically by tolua++-1.0.92 on Tue Dec 20 13:23:36 2016.
*/

#include "Lua/oLuaBinding.h"
using namespace Dorothy;

/* function to register type */
static void tolua_reg_types(lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"oContent");
 Mtolua_typeid(tolua_S,oContent,"oContent");
 tolua_usertype(tolua_S,"oObject");
 Mtolua_typeid(tolua_S,oObject,"oObject");
}

/* get function: id of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_id
static int tolua_get_oObject_unsigned_id(lua_State* tolua_S)
{
  oObject* self = (oObject*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'id'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->getId());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: luaRef of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_ref
static int tolua_get_oObject_unsigned_ref(lua_State* tolua_S)
{
  oObject* self = (oObject*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'luaRef'",NULL);
#endif
  tolua_pushnumber(tolua_S,(lua_Number)self->getLuaRef());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: objectCount of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_count
static int tolua_get_oObject_unsigned_count(lua_State* tolua_S)
{
  tolua_pushnumber(tolua_S,(lua_Number)oObject::getObjectCount());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: maxObjectCount of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_maxCount
static int tolua_get_oObject_unsigned_maxCount(lua_State* tolua_S)
{
  tolua_pushnumber(tolua_S,(lua_Number)oObject::getMaxObjectCount());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: luaRefCount of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_luaRefCount
static int tolua_get_oObject_unsigned_luaRefCount(lua_State* tolua_S)
{
  tolua_pushnumber(tolua_S,(lua_Number)oObject::getLuaRefCount());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: maxLuaRefCount of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_maxLuaRefCount
static int tolua_get_oObject_unsigned_maxLuaRefCount(lua_State* tolua_S)
{
  tolua_pushnumber(tolua_S,(lua_Number)oObject::getMaxLuaRefCount());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: luaCallbackCount of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_callRefCount
static int tolua_get_oObject_unsigned_callRefCount(lua_State* tolua_S)
{
  tolua_pushnumber(tolua_S,(lua_Number)oObject::getLuaCallbackCount());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: maxLuaCallbackCount of class  oObject */
#ifndef TOLUA_DISABLE_tolua_get_oObject_unsigned_maxCallRefCount
static int tolua_get_oObject_unsigned_maxCallRefCount(lua_State* tolua_S)
{
  tolua_pushnumber(tolua_S,(lua_Number)oObject::getMaxLuaCallbackCount());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* get function: writablePath of class  oContent */
#ifndef TOLUA_DISABLE_tolua_get_oContent_writablePath
static int tolua_get_oContent_writablePath(lua_State* tolua_S)
{
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable 'writablePath'",NULL);
#endif
  tolua_pushcppstring(tolua_S,(const char*)self->getWritablePath());
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* method: saveToFile of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_saveToFile00
static int tolua_LuaBinding_oContent_saveToFile00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring filename = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
   const _cstring content = ((  const _cstring)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'saveToFile'", NULL);
#endif
  {
   self->saveToFile(filename,content);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'saveToFile'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: isFileExist of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_exist00
static int tolua_LuaBinding_oContent_exist00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isFileExist'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isFileExist(path);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'exist'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createFolder of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_mkdir00
static int tolua_LuaBinding_oContent_mkdir00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'createFolder'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->createFolder(path);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'mkdir'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: isFolder of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_isdir00
static int tolua_LuaBinding_oContent_isdir00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isFolder'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isFolder(path);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isdir'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: removeFile of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_remove00
static int tolua_LuaBinding_oContent_remove00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'removeFile'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->removeFile(path);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'remove'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getFullPath of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_getFullPath00
static int tolua_LuaBinding_oContent_getFullPath00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring filename = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getFullPath'", NULL);
#endif
  {
   string tolua_ret = (string)  self->getFullPath(filename);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getFullPath'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addSearchPath of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_addSearchPath00
static int tolua_LuaBinding_oContent_addSearchPath00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addSearchPath'", NULL);
#endif
  {
   self->addSearchPath(path);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addSearchPath'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: removeSearchPath of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_removeSearchPath00
static int tolua_LuaBinding_oContent_removeSearchPath00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'removeSearchPath'", NULL);
#endif
  {
   self->removeSearchPath(path);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'removeSearchPath'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: oContent_getDirEntries of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_getEntries00
static int tolua_LuaBinding_oContent_getEntries00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring path = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
  bool isFolder = ((bool)  tolua_toboolean(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'oContent_getDirEntries'", NULL);
#endif
  {
   oContent_getDirEntries(self,path,isFolder);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getEntries'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: oContent_loadFile of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_loadFile00
static int tolua_LuaBinding_oContent_loadFile00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
   const _cstring filename = ((  const _cstring)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'oContent_loadFile'", NULL);
#endif
  {
   oContent_loadFile(self,filename);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'loadFile'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: oContent_setSearchPaths of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_setSearchPaths00
static int tolua_LuaBinding_oContent_setSearchPaths00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_istable(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
  int tolua_len = (int)lua_objlen(tolua_S,2);
   _cstring* paths = Mtolua_new_dim(_cstring, tolua_len);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'oContent_setSearchPaths'", NULL);
#endif
  {
#ifndef TOLUA_RELEASE
   if (!tolua_isstringarray(tolua_S,2,tolua_len,0,&tolua_err))
    goto tolua_lerror;
   else
#endif
   {
    for (int i=0;i<(int)tolua_len;i++)
    paths[i] = ((_cstring)  tolua_tofieldstring(tolua_S,2,i+1,0));
   }
  }
  {
   oContent_setSearchPaths(self,paths,tolua_len);
  }
  Mtolua_delete_dim(paths);
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setSearchPaths'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: oContent_setSearchPaths of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_setSearchPaths01
static int tolua_LuaBinding_oContent_setSearchPaths01(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_istable(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  oContent* self = (oContent*)  tolua_tousertype(tolua_S,1,0);
  int tolua_len = (int)lua_objlen(tolua_S,2);
   _cstring* paths = Mtolua_new_dim(_cstring, tolua_len);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'oContent_setSearchPaths'", NULL);
#endif
  {
#ifndef TOLUA_RELEASE
   if (!tolua_isstringarray(tolua_S,2,tolua_len,0,&tolua_err))
    goto tolua_lerror;
   else
#endif
   {
    for (int i=0;i<(int)tolua_len;i++)
    paths[i] = ((_cstring)  tolua_tofieldstring(tolua_S,2,i+1,0));
   }
  }
  {
   oContent_setSearchPaths(self,paths,tolua_len);
  }
  Mtolua_delete_dim(paths);
 }
 return 0;
tolua_lerror:
 return tolua_LuaBinding_oContent_setSearchPaths00(tolua_S);
}
#endif //#ifndef TOLUA_DISABLE

/* method: new_local of class  oContent */
#ifndef TOLUA_DISABLE_tolua_LuaBinding_oContent_new00_local
static int tolua_LuaBinding_oContent_new00_local(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"oContent",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   tolua_outside oContent* tolua_ret = (tolua_outside oContent*)  oContent_shared();
  tolua_pushobject(tolua_S,(void*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_LuaBinding_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"oObject","",tolua_collect_object);
  tolua_beginmodule(tolua_S,"oObject");
   tolua_variable(tolua_S,"id",tolua_get_oObject_unsigned_id,NULL);
   tolua_variable(tolua_S,"ref",tolua_get_oObject_unsigned_ref,NULL);
   tolua_variable(tolua_S,"count",tolua_get_oObject_unsigned_count,NULL);
   tolua_variable(tolua_S,"maxCount",tolua_get_oObject_unsigned_maxCount,NULL);
   tolua_variable(tolua_S,"luaRefCount",tolua_get_oObject_unsigned_luaRefCount,NULL);
   tolua_variable(tolua_S,"maxLuaRefCount",tolua_get_oObject_unsigned_maxLuaRefCount,NULL);
   tolua_variable(tolua_S,"callRefCount",tolua_get_oObject_unsigned_callRefCount,NULL);
   tolua_variable(tolua_S,"maxCallRefCount",tolua_get_oObject_unsigned_maxCallRefCount,NULL);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"oContent","",tolua_collect_object);
  tolua_beginmodule(tolua_S,"oContent");
   tolua_variable(tolua_S,"writablePath",tolua_get_oContent_writablePath,NULL);
   tolua_function(tolua_S,"saveToFile",tolua_LuaBinding_oContent_saveToFile00);
   tolua_function(tolua_S,"exist",tolua_LuaBinding_oContent_exist00);
   tolua_function(tolua_S,"mkdir",tolua_LuaBinding_oContent_mkdir00);
   tolua_function(tolua_S,"isdir",tolua_LuaBinding_oContent_isdir00);
   tolua_function(tolua_S,"remove",tolua_LuaBinding_oContent_remove00);
   tolua_function(tolua_S,"getFullPath",tolua_LuaBinding_oContent_getFullPath00);
   tolua_function(tolua_S,"addSearchPath",tolua_LuaBinding_oContent_addSearchPath00);
   tolua_function(tolua_S,"removeSearchPath",tolua_LuaBinding_oContent_removeSearchPath00);
   tolua_function(tolua_S,"getEntries",tolua_LuaBinding_oContent_getEntries00);
   tolua_function(tolua_S,"loadFile",tolua_LuaBinding_oContent_loadFile00);
   tolua_function(tolua_S,"setSearchPaths",tolua_LuaBinding_oContent_setSearchPaths01);
   tolua_call(tolua_S,MT_CALL,tolua_LuaBinding_oContent_new00_local);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}
