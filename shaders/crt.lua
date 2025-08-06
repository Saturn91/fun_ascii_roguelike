local shaderCode = [[
    extern float intensity;
    extern float scanlineHeight;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
        vec4 pixel = Texel(texture, texture_coords);
        
        // Calculate the scanline pattern
        float scanline = mod(pixel_coords.y, scanlineHeight) * intensity / 100.0;

        // Apply the scanlines to the pixel color
        pixel.rgb += scanline;
        
        return pixel * color;
    }
]]

local crtShader = love.graphics.newShader(shaderCode)

local CRT = {}

function CRT.apply()
    crtShader:send("intensity", -20)
    crtShader:send("scanlineHeight", 2)
    love.graphics.setShader(crtShader)
end

return CRT