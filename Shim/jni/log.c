#include <android_native_app_glue.h>
#include <android/log.h>

#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"

// LOG
int HSLog(lua_State *script) {
    if (lua_gettop(script) < 2) {
        return 0;
    }

    __android_log_write(lua_tointeger(script, 1), "smashhit", lua_tostring(script, 2));

    return 0;
}
// END LOG

int HSEnableLog(lua_State *script) {
    lua_register(script, "HSLog", HSLog);
    lua_pushinteger(script, ANDROID_LOG_INFO); lua_setglobal(script, "HS_LOG_INFO");
    lua_pushinteger(script, ANDROID_LOG_WARN); lua_setglobal(script, "HS_LOG_WARN");
    lua_pushinteger(script, ANDROID_LOG_ERROR); lua_setglobal(script, "HS_LOG_ERROR");
    
    return 0;
}
