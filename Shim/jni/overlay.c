/**
 * Handle asset dir overlays for Hyperspace
 */

#include <android_native_app_glue.h>
#include <android/log.h>
#include <string.h>
#include <stdlib.h>

#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"

#include "util.h"
#include "smashhit.h"

unsigned char (*ResMan_load)(ResMan *this, QiString *path, QiOutputStream *output);
void (*QiOutputStream_writeBuffer)(QiOutputStream *this, void *buffer, size_t length);

unsigned char HSResMan_load(ResMan *this, QiString *path, QiOutputStream *output) {
	__android_log_print(ANDROID_LOG_INFO, TAG, "HSResMan_load %s", path->data ? path->data : path->cached);
	
	return ResMan_load(this, path, output);
}

void HSOverlayInit(struct android_app *app, Leaf *leaf) {
	// TODO: 32bit
	QiOutputStream_writeBuffer = KNGetSymbolAddr("_ZN14QiOutputStream11writeBufferEPKvm");
	
	// Hook res man load
	KNHookFunction(KNGetSymbolAddr("_ZN6ResMan4loadERK8QiStringR14QiOutputStream"), HSResMan_load, (void **) &ResMan_load);
}

int HSEnableOverlay(lua_State *script) {
	return 0;
}
