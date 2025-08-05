local fonts = {}

function fonts.loadFont(fontName, path)
    fonts[fontName] = love.graphics.newFont(path, 120)
end

-- Load default fonts
fonts.loadFont("dejaVuSansMono", "assets/fonts/DejaVuSansMono.ttf")
fonts.loadFont("ibm-mono", "assets/fonts/Ac437_IBM_BIOS.ttf")

return fonts