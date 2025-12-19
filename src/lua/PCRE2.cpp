#include "../include/luaplayer.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>

static int lua_pcre2_match(lua_State *L) {
    int argc = lua_gettop(L);
    if (argc != 3) return luaL_error(L, "wrong number of arguments");

    size_t subject_len;
    PCRE2_SPTR8 subject_str = (PCRE2_SPTR8)luaL_checklstring(L, 1, &subject_len);
    PCRE2_SPTR8 pattern_str = (PCRE2_SPTR8)luaL_checkstring(L, 2);
    uint32_t options = luaL_checkinteger(L, 3);
    int err_code;
    size_t err_offset;

    pcre2_code *re = pcre2_compile(pattern_str, PCRE2_ZERO_TERMINATED, options, &err_code, &err_offset, NULL);
    if (!re) {
        lua_pushnil(L);

        lua_createtable(L, 0, 3);

        PCRE2_UCHAR buffer[256];
        pcre2_get_error_message(err_code, buffer, sizeof(buffer));
        lua_pushstring(L, (char *)buffer);
        lua_setfield(L, -2, "message");

        lua_pushinteger(L, err_code);
        lua_setfield(L, -2, "code");

        lua_pushinteger(L, (lua_Integer)err_offset);
        lua_setfield(L, -2, "offset");
        return 2;
    }

    pcre2_match_data *match_data = pcre2_match_data_create_from_pattern(re, NULL);
    lua_newtable(L);

    int master_table_index = lua_gettop(L);

    int match_count = 0;
    size_t current_offset = 0;

    while (current_offset <= subject_len) {
        int rc = pcre2_match(re, subject_str, subject_len, current_offset, 0, match_data, NULL);

        if (rc == PCRE2_ERROR_NOMATCH) break;

        if (rc < 0) {
            lua_pushinteger(L, rc);
            lua_setfield(L, -2, "error");
            pcre2_match_data_free(match_data);
            pcre2_code_free(re);
            return 1;
        };

        lua_newtable(L);

        for (int i = 0; i < rc; i++) {
            PCRE2_UCHAR8 *buffer;
            size_t buffer_len;
            int sub_rc = pcre2_substring_get_bynumber(match_data, i, &buffer, &buffer_len);

            if (sub_rc >= 0) {
                lua_pushlstring(L, (char *)buffer, buffer_len);
                pcre2_substring_free(buffer);
            } else {
                lua_pushnil(L);
            }
            lua_rawseti(L, -2, i + 1);
        }

        match_count++;
        lua_rawseti(L, master_table_index, match_count);

        size_t *ovector = pcre2_get_ovector_pointer(match_data);
        current_offset = ovector[1];

        if (ovector[0] == ovector[1]) {
            current_offset++;
        }
    }

    pcre2_match_data_free(match_data);
    pcre2_code_free(re);

    return 1;
}

static int lua_pcre2_get_error_message(lua_State *L) {
    int argc = lua_gettop(L);
    if (argc != 1) return luaL_error(L, "wrong number of arguments");
    PCRE2_UCHAR buf[120];
    int ret = pcre2_get_error_message(luaL_checkinteger(L, 1), buf, 120);
    if (ret) {
        lua_pushstring(L, (char *)buf);
    } else {
        lua_pushnil(L);
    }
    return 1;
}

static const luaL_Reg PCRE2_functions[] = {
    {"match",               lua_pcre2_match},
    // {"substitute",          lua_pcre2_substitute},
    {"get_error_message",  lua_pcre2_get_error_message}
};

#define LUA_FORWARD_INTMACRO(macro) lua_pushinteger(L, macro); lua_setglobal (L, #macro)

void luaPCRE2_init(lua_State *L) {
    lua_newtable(L);
    luaL_setfuncs(L, PCRE2_functions, 0);
    lua_setglobal(L, "PCRE2");

    LUA_FORWARD_INTMACRO(PCRE2_ERROR_NOMATCH);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_PARTIAL);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADMAGIC);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADMODE);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADOFFSET);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADOPTION);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADUTFOFFSET);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_CALLOUT);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_DEPTHLIMIT);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_HEAPLIMIT);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_INTERNAL);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_JIT_STACKLIMIT);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_MATCHLIMIT);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_NOMEMORY);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_NULL);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_RECURSELOOP);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_NOSUBSTRING);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_UNSET);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADREPLACEMENT);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADREPESCAPE);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_REPMISSINGBRACE);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADSUBSTITUTION);
    LUA_FORWARD_INTMACRO(PCRE2_ERROR_BADSUBSPATTERN);

    LUA_FORWARD_INTMACRO(PCRE2_ANCHORED);
    LUA_FORWARD_INTMACRO(PCRE2_ALLOW_EMPTY_CLASS);
    LUA_FORWARD_INTMACRO(PCRE2_ALT_BSUX);
    LUA_FORWARD_INTMACRO(PCRE2_ALT_CIRCUMFLEX);
    LUA_FORWARD_INTMACRO(PCRE2_ALT_EXTENDED_CLASS);
    LUA_FORWARD_INTMACRO(PCRE2_ALT_VERBNAMES);
    LUA_FORWARD_INTMACRO(PCRE2_AUTO_CALLOUT);
    LUA_FORWARD_INTMACRO(PCRE2_CASELESS);
    LUA_FORWARD_INTMACRO(PCRE2_DOLLAR_ENDONLY);
    LUA_FORWARD_INTMACRO(PCRE2_DOTALL);
    LUA_FORWARD_INTMACRO(PCRE2_DUPNAMES);
    LUA_FORWARD_INTMACRO(PCRE2_ENDANCHORED);
    LUA_FORWARD_INTMACRO(PCRE2_EXTENDED);
    LUA_FORWARD_INTMACRO(PCRE2_FIRSTLINE);
    LUA_FORWARD_INTMACRO(PCRE2_LITERAL);
    LUA_FORWARD_INTMACRO(PCRE2_MATCH_INVALID_UTF);
    LUA_FORWARD_INTMACRO(PCRE2_MATCH_UNSET_BACKREF);
    LUA_FORWARD_INTMACRO(PCRE2_MULTILINE);
    LUA_FORWARD_INTMACRO(PCRE2_NEVER_BACKSLASH_C);
    LUA_FORWARD_INTMACRO(PCRE2_NEVER_UCP);
    LUA_FORWARD_INTMACRO(PCRE2_NEVER_UTF);
    LUA_FORWARD_INTMACRO(PCRE2_NO_AUTO_CAPTURE);
    LUA_FORWARD_INTMACRO(PCRE2_NO_AUTO_POSSESS);
    LUA_FORWARD_INTMACRO(PCRE2_NO_DOTSTAR_ANCHOR);
    LUA_FORWARD_INTMACRO(PCRE2_NO_START_OPTIMIZE);
    LUA_FORWARD_INTMACRO(PCRE2_NO_UTF_CHECK);
    LUA_FORWARD_INTMACRO(PCRE2_UCP);
    LUA_FORWARD_INTMACRO(PCRE2_UNGREEDY);
    LUA_FORWARD_INTMACRO(PCRE2_USE_OFFSET_LIMIT);
    LUA_FORWARD_INTMACRO(PCRE2_UTF);
}
