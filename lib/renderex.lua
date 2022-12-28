local ffi = require("ffi")
local math = require("math")

local modname = ...
local M = {}

_G[modname] = M 
complex = M 

ffi.cdef[[
    typedef struct 
    {
        float x, y, z;
    } vec3_t;

    typedef struct 
    {
        unsigned char r, g, b, a;
    } color_t;

    typedef struct 
    {
        vec3_t pos;
        color_t color;
    } vtx_t;

    typedef struct 
    {
        vtx_t* vtx;
        unsigned int* idx;
    } graph_t;

    void* __stdcall GetModuleHandleA(const char* name);
    void* __stdcall GetProcAddress(void* module, const char* name);
    uint32_t __stdcall VirtualProtect(void* address, uint32_t size, uint32_t protect, uint32_t* old_protect);
    
    // renderex api
    void init(void* device, unsigned int screen_w, unsigned int screen_h);
    graph_t alloc_graph(unsigned int vtx_num, unsigned int idx_num);
    void post_data();
]]

function complex.init()
    -- load c lib
    complex.c = ffi.load("pandora/clib/renderex")
    -- search device
    complex.device = ffi.cast("void***", client.find_sig("shaderapidx9.dll", "A1 ? ? ? ? 50 8B 08 FF 51 0C") + 0x1)[0][0]
    -- get screen size
    complex.screen_size = {}
    complex.screen_size.w, complex.screen_size.h = render.get_screen()

    -- init renderex
    complex.c.init(complex.device, complex.screen_size.w, complex.screen_size.h)
    complex.inited = true
end

-- math helpers
function is_zero_2d(pos)
    if pos.x == 0 and pos.y == 0 then
        return true 
    end
    return false
end

function equal_2d(pos1, pos2)
    if pos1.x == pos2.x and pos1.y == pos2.y then 
        return true
    end
    return false
end

-- fill vertex
function set_vtx(graph, idx, pos, color)
    graph.vtx[idx].pos.x = pos.x 
    graph.vtx[idx].pos.y = pos.y
    graph.vtx[idx].pos.z = 0 
    graph.vtx[idx].color.r = color:r()
    graph.vtx[idx].color.g = color:g()
    graph.vtx[idx].color.b = color:b()
    graph.vtx[idx].color.a = color:a()
end

-- draw a filled triangle 
function complex.triangle_filled(pos1, pos2, pos3, color1, color2, color3)
    if color2 == nil then
        color2 = color1
    end

    if color3 == nil then
        color3 = color1
    end

    local graph = complex.c.alloc_graph(3, 3)
    set_vtx(graph, 0, pos1, color1)
    set_vtx(graph, 1, pos2, color2)
    set_vtx(graph, 2, pos3, color3)
    graph.idx[0] = 0 graph.idx[1] = 1 graph.idx[2] = 2
end 


function complex.circle_world_filled(pos, radius, color1, color2, sides)
    if color2 == nil then
        color2 = color1
    end
    
    if sides == nil then
        sides = 35
    end

    local step = math.pi * 2 / sides
    local prev_screen_pos = vector2d.new(0, 0)
    local screen_pos = vector2d.new(0, 0)
    local pos_w2s = vector2d.new(0, 0)

    if not render.world_to_screen(pos, pos_w2s) then
        return
    end

    for rotation = 0, math.pi * 2 + 0.001, step do
        local cpos = vector.new(radius * math.cos(rotation) + pos.x, radius * math.sin(rotation) + pos.y, pos.z)
        if render.world_to_screen(cpos, screen_pos) then
            if not equal_2d(screen_pos, prev_screen_pos) and not is_zero_2d(prev_screen_pos) then
                complex.triangle_filled(screen_pos, prev_screen_pos, pos_w2s, color2, color2, color1)
            end
        end
        prev_screen_pos.x = screen_pos.x 
        prev_screen_pos.y = screen_pos.y
    end
end

return complex

