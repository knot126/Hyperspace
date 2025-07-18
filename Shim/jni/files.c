#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"

int HSWriteFile(lua_State *script) {
	/**
	 * (nil|boolean) success = HSWriteFile((string) path, (string) contents)
	 * 
	 * Write a files contents to the given path. Returns either nil or false on
	 * failure or true on success.
	 */
	
	if (lua_gettop(script) < 2) {
		return 0;
	}
	
	const char *path = lua_tostring(script, 1);
	size_t size;
	const char *data = lua_tolstring(script, 2, &size);
	
	if (!path || !data) {
		return 0;
	}
	
	FILE *file = fopen(path, "wb");
	
	if (!file) {
		return 0;
	}
	
	size_t written = fwrite(data, 1, size, file);
	
	fclose(file);
	
	lua_pushboolean(script, written == size);
	return 1;
}

int HSReadFile(lua_State *script) {
	/**
	 * (string|nil) contents = HSReadFile((string) path)
	 * 
	 * Read the file at path, return nil if failed or a string with the contents
	 * of the file if not.
	 */
	
	if (lua_gettop(script) < 1) {
		return 0;
	}
	
	const char *path = lua_tostring(script, 1);
	
	if (!path) {
		return 0;
	}
	
	FILE *file = fopen(path, "rb");
	
	if (!file) {
		return 0;
	}
	
	// Return codes? Who cares :P
	// Reads the size of the file since there's no way to do this normally
	fseek(file, 0, SEEK_END);
	size_t size = ftell(file);
	fseek(file, 0, SEEK_SET);
	
	// Empty strings can take a shortcut, also bypasses the behaviour of malloc
	// not really being defined.
	if (size == 0) {
		lua_pushliteral(script, "");
		fclose(file);
		return 1;
	}
	
	// Allocate memory for contents
	char *data = malloc(size);
	
	if (!data) {
		fclose(file);
		return 0;
	}
	
	// Read contents into memory
	size_t readen = fread(data, 1, size, file);
	fclose(file); // close the file
	
	// Push it as lua data
	if (readen == size) {
		lua_pushlstring(script, data, size);
	}
	else {
		lua_pushnil(script);
	}
	
	free(data); // always free the data
	
	return 1;
}

int HSRenameFile(lua_State *script) {
	/**
	 * (bool) success = HSRenameFile((string) old_path, (string) new_path)
	 * 
	 * Rename the file at old_path to new_path. Returns true on success, or
	 * false on failure.
	 */
	
	if (lua_gettop(script) < 1) {
		return 0;
	}
	
	const char *old_path = lua_tostring(script, 1);
	const char *new_path = lua_tostring(script, 2);
	
	if (!old_path || !new_path) {
		return 0;
	}
	
	int status = rename(old_path, new_path);
	
	lua_pushboolean(script, status == 0);
	
	return 1;
}

int HSDeleteFile(lua_State *script) {
	/**
	 * (bool) success = HSDeleteFile((string) path)
	 * 
	 * Delete a file at the given path, returning true if successful or false
	 * if not.
	 */
	
	if (lua_gettop(script) < 1) {
		return 0;
	}
	
	const char *path = lua_tostring(script, 1);
	
	if (!path) {
		return 0;
	}
	
	int status = remove(path);
	
	lua_pushboolean(script, status == 0);
	
	return 1;
}

int HSIsFile(lua_State *script) {
	/**
	 * (bool) is_file = HSIsFile((string) path)
	 * 
	 * Check if the file at path can be opened in read mode, e.g. that the path
	 * exists, is a file and the user has permission to read it.
	 */
	
	if (lua_gettop(script) < 1) {
		return 0;
	}
	
	const char *path = lua_tostring(script, 1);
	
	if (!path) {
		return 0;
	}
	
	FILE *f = fopen(path, "rb");
	
	lua_pushboolean(script, f != 0);
	
	if (f) {
		fclose(f);
	}
	
	return 1;
}

int HSMakeDir(lua_State *script) {
	if (lua_gettop(script) < 1) {
		return 0;
	}
	
	const char *dirname = lua_tostring(script, 1);
	
	if (!dirname) {
		lua_pushboolean(script, 0);
		return 1;
	}
	
	int status = mkdir(dirname, 0777);
	
	lua_pushboolean(script, status == 0);
	
	return 1;
}

extern char *gAndroidInternalDataPath;

int HSGetInternalDataPath(lua_State *script) {
	lua_pushstring(script, gAndroidInternalDataPath);
	return 1;
}

int HSEnableFile(lua_State *script) {
	lua_register(script, "HSWriteFile", HSWriteFile);
	lua_register(script, "HSReadFile", HSReadFile);
	lua_register(script, "HSRenameFile", HSRenameFile);
	lua_register(script, "HSDeleteFile", HSDeleteFile);
	lua_register(script, "HSIsFile", HSIsFile);
	lua_register(script, "HSMakeDir", HSMakeDir);
	lua_register(script, "HSGetInternalDataPath", HSGetInternalDataPath);
	
	return 0;
}
