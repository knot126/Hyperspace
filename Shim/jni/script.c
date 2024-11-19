#include <android_native_app_glue.h>
#include <android/log.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"

#include "smashhit.h"
#include "util.h"

char *gAndroidInternalDataPath;

// Lua libs
int HSEnableLog(lua_State *script);
int HSEnableHttp(lua_State *script);
int HSEnableOverlay(lua_State *script);

void (*real_script_load_func)(Script *this, QiString *path);

static void script_load_hook(Script *this, QiString *path) {
	real_script_load_func(this, path);
	
	HSEnableLog(*this->script->state);
	HSEnableHttp(*this->script->state);
	HSEnableOverlay(*this->script->state);
}

// script module
void HSScriptInit(struct android_app *app, Leaf *leaf) {
	// Install the lua extensions, but only for menu and hud scripts
	KNHookFunction(KNGetSymbolAddr("_ZN6Script4loadERK8QiString"), &script_load_hook, (void *) &real_script_load_func);
	
	// Set internal and external data paths
	gAndroidInternalDataPath = strdup(app->activity->internalDataPath);
}
