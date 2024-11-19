#define HTTP_IMPLEMENTATION
#include <netinet/in.h>
#include "extern/http.h"

#include <string.h>
#include <android/log.h>

#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"

typedef struct {
    http_t *context;
} HSHttpContext;

enum {
    HS_HTTP_PENDING = 1,
    HS_HTTP_DONE,
    HS_HTTP_ERROR,
};

// HTTP
int HSHttpRequest(lua_State *script) {
    /**
     * Create an HTTP GET or POST request. The first argument should be a
     * url string. The second argument is an optional POST body. If a body
     * is not specified GET is used instead of POST.
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    const char *url = lua_tostring(script, 1);
    
    if (!url) {
        lua_pushnil(script);
        return 1;
    }
    
    http_t *request;
    
    if (lua_gettop(script) == 1) {
        request = http_get(url, NULL);
    }
    else {
        size_t size = 0;
        const char *body = lua_tolstring(script, 2, &size);
        
        request = http_post(url, body, size, NULL);
    }
    
    if (!request) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_newuserdata(script, sizeof *ctx);
    ctx->context = request;
    
    return 1;
}

int HSHttpUpdate(lua_State *script) {
    /**
     * Process the HTTP request. If still processing, return nil. If the request
     * errored, return HS_HTTP_ERROR. If the request succeeded, return HS_HTTP_DONE.
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (!ctx || !ctx->context) {
        lua_pushnil(script);
        return 1;
    }
    
    http_status_t status = http_process(ctx->context);
    
    switch (status) {
        case HTTP_STATUS_PENDING:
            lua_pushinteger(script, HS_HTTP_PENDING);
            break;
        case HTTP_STATUS_FAILED:
            lua_pushinteger(script, HS_HTTP_ERROR);
            break;
        case HTTP_STATUS_COMPLETED:
            lua_pushinteger(script, HS_HTTP_DONE);
            break;
        default:
            lua_pushinteger(script, HS_HTTP_ERROR);
            break;
    }
    
    return 1;
}

int HSHttpData(lua_State *script) {
    /**
     * Return the data if succeeded and still allocated, otherwise return nil.
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (!ctx || !ctx->context) {
        lua_pushnil(script);
        return 1;
    }
    
    if (ctx->context->status == HTTP_STATUS_COMPLETED) {
        lua_pushlstring(script, ctx->context->response_data, ctx->context->response_size);
    }
    else {
        lua_pushnil(script);
    }
    
    return 1;
}

int HSHttpDataSize(lua_State *script) {
    /**
     * Return the size of the data or 0 if there is none.
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (!ctx || !ctx->context) {
        lua_pushinteger(script, 0);
        return 1;
    }
    
    lua_pushinteger(script, ctx->context->response_size);
    
    return 1;
}

int HSHttpContentType(lua_State *script) {
    /**
     * Return a string representing the content type of the data
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (!ctx || !ctx->context) {
        lua_pushnil(script);
        return 1;
    }
    
    if (ctx->context->content_type && strlen(ctx->context->content_type) != 0) {
        lua_pushstring(script, ctx->context->content_type);
    }
    else {
        lua_pushnil(script);
    }
    
    return 1;
}

int HSHttpError(lua_State *script) {
    /**
     * Return a string describing the HTTP error.
     * Note that the string may be empty even if there is an error, such as when
     * there are connection issues.
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (!ctx || !ctx->context) {
        lua_pushnil(script);
        return 1;
    }
    
    if (ctx->context->reason_phrase) {
        lua_pushstring(script, ctx->context->reason_phrase);
    }
    else {
        lua_pushnil(script);
    }
    
    return 1;
}

int HSHttpErrorCode(lua_State *script) {
    /**
     * Return the integer HTTP error code. Note that an error code of zero does not
     * mean there is not an error, for example in the condition of connection
     * issues.
     */
    
    if (lua_gettop(script) < 1) {
        lua_pushnil(script);
        return 1;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (!ctx || !ctx->context) {
        lua_pushnil(script);
        return 1;
    }
    
    lua_pushinteger(script, ctx->context->status_code);
    
    return 1;
}

int HSHttpRelease(lua_State *script) {
    /**
     * Release the http request context.
     */
    
    if (lua_gettop(script) < 1) {
        return 0;
    }
    
    HSHttpContext *ctx = lua_touserdata(script, 1);
    
    if (ctx) {
        http_release(ctx->context);
        ctx->context = NULL;
    }
    
    return 0;
}
// END HTTP

int HSEnableHttp(lua_State *script) {
    lua_register(script, "HSHttpRequest", HSHttpRequest);
    lua_register(script, "HSHttpUpdate", HSHttpUpdate);
    lua_register(script, "HSHttpData", HSHttpData);
    lua_register(script, "HSHttpDataSize", HSHttpDataSize);
    lua_register(script, "HSHttpContentType", HSHttpContentType);
    lua_register(script, "HSHttpError", HSHttpError);
    lua_register(script, "HSHttpErrorCode", HSHttpErrorCode);
    lua_register(script, "HSHttpRelease", HSHttpRelease);
    lua_pushinteger(script, HS_HTTP_PENDING); lua_setglobal(script, "HS_HTTP_PENDING");
    lua_pushinteger(script, HS_HTTP_DONE); lua_setglobal(script, "HS_HTTP_DONE");
    lua_pushinteger(script, HS_HTTP_ERROR); lua_setglobal(script, "HS_HTTP_ERROR");

    return 0;
}
