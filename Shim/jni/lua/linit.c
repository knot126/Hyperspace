/*
** $Id: linit.c,v 1.14.1.1 2007/12/27 13:02:25 roberto Exp $
** Initialization of libraries for lua.c
** See Copyright Notice in lua.h
*/


#define linit_c
#define LUA_LIB

#include "lua.h"

#include "lualib.h"
#include "lauxlib.h"

// #include <dlfcn.h>
// extern void *gLibsmashhitHandle;

#include "andrleaf.h"

// static const luaL_Reg lualibs[] = {
// //	 {"", luaopen_base},
// //	 {LUA_LOADLIBNAME, luaopen_package}, -- PACKAGE CAUSES CRASH AT SCRIPT UNLOAD TIME !
// //	 {LUA_TABLIBNAME, luaopen_table},
//	 // {LUA_IOLIBNAME, luaopen_io},
//	 // {LUA_OSLIBNAME, luaopen_os},
//	 {LUA_STRLIBNAME, luaopen_string},
//	 {LUA_MATHLIBNAME, luaopen_math},
//	 // {LUA_DBLIBNAME, luaopen_debug},
//	 {NULL, NULL}
// };

extern Leaf *gLeaf;

static const char *gLibsToOpen[] = {
	"luaopen_table",
	"luaopen_string",
	"luaopen_math",
	NULL,
};

LUALIB_API void luaL_openlibs (lua_State *L) {
	for (size_t i = 0; gLibsToOpen[i] != NULL; i++) {
		lua_pushcfunction(L, LeafSymbolAddr(gLeaf, gLibsToOpen[i]));
		lua_pushstring(L, gLibsToOpen[i] + 8);
		lua_call(L, 1, 0);
	}
	
	
//	 const luaL_Reg *lib = lualibs;
//	 for (; lib->func; lib++) {
//		 lua_pushcfunction(L, lib->func);
//		 lua_pushstring(L, lib->name);
//		 lua_call(L, 1, 0);
//	 }
// #ifndef USE_LEAF
//	 // Fixes some weird stuff that happens when we use the libshim.so one
//	 // Mainly a crash somewhere down the call stack in lua_rawseti
//	 lua_pushcfunction(L, (lua_CFunction) dlsym(gLibsmashhitHandle, "luaopen_table"));
//	 lua_pushstring(L, "table");
//	 lua_call(L, 1, 0);
// #endif
}

