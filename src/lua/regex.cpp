#include "../include/luaplayer.h"
#include <stdint.h>

#include <regex>
#include <string>

static int lua_search(lua_State *L) {
    int argc = lua_gettop(L);
    if (argc != 2) return luaL_error(L, "wrong number of arguments");
    std::string text = luaL_checkstring(L, 1);
    std::regex pattern(luaL_checkstring(L, 2));
    std::smatch matches;

    if (std::regex_search(text, matches, pattern)) {
        lua_newtable(L);
        for (unsigned i=0; i<matches.size(); ++i) {
            lua_pushinteger(L, i);
            lua_pushstring(L, matches[i].str().c_str());
            lua_settable(L, -3);
        }
    } else {
        lua_pushnil(L);
    }
    return 1;
}


static const luaL_Reg regex_functions[] = {
    {"search",              lua_search},
};

#define LUA_FORWARD_INTMACRO(macro) lua_pushinteger(L, macro); lua_setglobal (L, #macro)

void luaRegex_init(lua_State *L) {
    lua_newtable(L);
    luaL_setfuncs(L, regex_functions, 0);
    lua_setglobal(L, "regex");

    // LUA_FORWARD_INTMACRO(PAD_SELECT);
}
