local modname = ...
local M = {}

_G[modname] = M 
complex = M 

local ffi = require("ffi")
local callbacksex = ffi.load("pandora/clib/callbacksex")

ffi.cdef[[
    typedef void (__stdcall* unload_callback_fn)();
    void reg_unload(void* callback, const char* pdr_lua_name);
    void dereg_unload(void* callback, const char* pdr_lua_name);
]]

function complex.register(name, callback)
    if name == "unload" then
        return callbacksex.reg_unload(ffi.cast("unload_callback_fn", callback), e9319306_721a_064e_43a0_68259aa188eb)
    end
    return callbacks.register(name, callback)
end

function complex.deregister(name, callback)
    if name == "unload" then
        return callbacksex.dereg_unload(ffi.cast("unload_callback_fn", callback), e9319306_721a_064e_43a0_68259aa188eb)
    end
    return callbacks.deregister(name, callback)
end

return complex
