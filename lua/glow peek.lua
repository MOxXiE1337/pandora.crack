-- pandora.crack's glow peek
-- made by MOxXiE
-- QQ: 938583253 Discord: lex-1337#2220

local ffi = require "ffi"

ffi.cdef[[
   typedef struct 
   {
        float x;
        float y;
        float z;
    } vec3_t;

   typedef struct 
    {
        void* base_address;
        void* allocation_base;
        uint32_t allocation_protect;
        uint32_t size;
        uint32_t state;
        uint32_t protect;
        uint32_t type;
    } MEMORY_BASIC_INFORMATION;
    
    uint32_t __stdcall VirtualQuery(void* address, MEMORY_BASIC_INFORMATION* mbi, uint32_t size);
]]

-- ui
ui.add_label("glow peek by moxxie")
ui.add_label("color")
local peek_color = ui.add_cog("color", true, false)
local peek_alpha1 = ui.add_slider("alpha1", 0, 255)
local peek_alpha2 = ui.add_slider("alpha2", 0, 255)

-- check version
function is_crack_version()
    local mbi = ffi.new("MEMORY_BASIC_INFORMATION[1]")
    ffi.C.VirtualQuery(ffi.cast("void*", 0x40B50000), mbi, 28)
    if mbi[0].size == 0x74C000 then
        return true
    else
        return false
    end
end

-- check if you are running pandora crack version
if not is_crack_version() then
    client.log("this lua can only run on cracked version!", color.new(255, 0, 0, 255))
    return
end

-- patch old circle
ffi.cast("uint16_t*", 0x40DC5AB4)[0] = 0x9090

-- draw our peek circle
callbacks.register("paint", function()

    -- read peek position
    local ffi_peek_pos = ffi.cast("vec3_t*", 0x411EFA10)
    local peek_pos = vector.new(ffi_peek_pos.x, ffi_peek_pos.y, ffi_peek_pos.z)

    -- not peeking?
    if peek_pos.x == 0 and peek_pos.y == 0 and peek_pos.z == 0 then
        return
    end

    -- draw our circle
    local color_unit = (peek_alpha1:get() - peek_alpha2:get()) / 16
    for i = 0, 15 do
        local o_peek_color = peek_color:get_color()
        render.circle_world(peek_pos, 16 - i * 1, color.new(0, 0, 0, 0), color.new(o_peek_color:r(), o_peek_color:g(), o_peek_color:b(), peek_alpha2:get() + color_unit * i))
    end
end)








