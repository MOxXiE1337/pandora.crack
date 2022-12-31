local modname = ...
local M = {}

_G[modname] = M 
complex = M 

local ffi = require("ffi")

ffi.cdef[[
    unsigned int VirtualProtect(void* address, unsigned int size, unsigned int protect, unsigned int* old_protect);
]]

function complex.new(vftable)
    local hookex = {}
    local origins = {}
    local old_protect = ffi.new("unsigned int[1]")
    local cvftable = ffi.cast("unsigned int*", vftable)
    
    hookex.vftable = vftable

    -- hook a virtual function, return original function 
    hookex.hook = function(self, cast, detour, index)
        -- record original function
        origins[index] = cvftable[index]
        -- overwrite function address 
        ffi.C.VirtualProtect(cvftable + index, 4, 0x4, old_protect)
        cvftable[index] = ffi.cast("unsigned int", ffi.cast(cast, detour))
        ffi.C.VirtualProtect(cvftable + index, 4, old_protect[0], old_protect)
        -- return original function 
        return ffi.cast(cast, origins[index])
    end

    -- unhook a virtual function, return true if unhooked successfully 
    hookex.unhook = function(self, index)
        -- hooked?
        if origins[index] == nil then
            return false 
        end
        -- overwrite function address
        ffi.C.VirtualProtect(cvftable + index, 4, 0x4, old_protect)
        cvftable[index] = origins[index]
        ffi.C.VirtualProtect(cvftable + index, 4, old_protect[0], old_protect)
        -- set original function to nil 
        origins[index] = nil
        return true
    end

    -- unhook all the functions you hooked
    hookex.unhook_all = function(self)
        for idx, address in pairs(origins) do 
            if address ~= nil then
                -- why u can't call unhook???
                ffi.C.VirtualProtect(cvftable + idx, 4, 0x4, old_protect)
                cvftable[idx] = origins[idx]
                ffi.C.VirtualProtect(cvftable + idx, 4, old_protect[0], old_protect)
                origins[idx] = nil
            end
        end
    end

    return hookex
end

return complex 

