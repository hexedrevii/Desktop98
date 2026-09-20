local Colour = require "src.API.Colour"
local WindowManager = require "src.modules.WindowManager"
local VirtualFS = require "src.modules.VFS"

return function(pid)
  local drawing = false

  local Graphics = {}

  function Graphics.window(w, h, title)
    return WindowManager:window(pid, w, h, title)
  end

  function Graphics.beginDrawing(window)
    if drawing then
      -- TODO: Kernel error crash (Cannot enter draw while already drawing)
    end

    if window.pid ~= pid then
      -- TODO: Kernel error crash (Cannot draw to another Process)
    end

    love.graphics.setCanvas(window.canvas)
    drawing = true
  end

  function Graphics.endDrawing()
    if not drawing then
      -- TODO: Kernel error crash (Cannot end draw while not drawing)
    end

    love.graphics.setCanvas()
    drawing = false
  end

  Graphics.colours = {
    white = Colour.new(1, 1, 1),
    black = Colour.new(0, 0, 0),
    red = Colour.new(1, 0, 0)
  }

  Graphics.Colour = Colour

  Graphics.font = {}
  function Graphics.font.new(path, size)
    size = size or 12

    local physical = VirtualFS:translate(path)

    local success, font = pcall(love.graphics.newFont, physical, size)
    if not success then
      return nil, "Could not load font: " .. tostring(font)
    end

    return font
  end

  local default = Graphics.font.new("/sys/W95F.otf", 18)
  if not default then
    print("Could not load default font? (Did you delete it.)")
    love.event.quit()
  end

  function Graphics.font.getDefaultFont()
    return default
  end

  function Graphics.clear(colour)
    if not drawing then
      -- TODO: Kernel error crash (Cannot draw while not drawing)
    end

    love.graphics.clear(colour:raw())
  end

  function Graphics.print(text, x, y, colour, font)
    if not drawing then
      -- TODO: Kernel error crash (Cannot end draw while not drawing)
    end

    colour = colour or Graphics.colours.white
    font = font or default

    love.graphics.setColor(colour:raw())
    love.graphics.print(text, font, math.floor(x), math.floor(y))
    love.graphics.setColor(1, 1, 1, 1)
  end

  function Graphics.rectangle(x, y, w, h, colour, mode)
    if not drawing then
      -- TODO: Kernel error crash (Cannot draw while not drawing)
    end

    mode = mode or "fill"
    colour = colour or Graphics.colours.white

    love.graphics.setColor(colour:raw())
    love.graphics.rectangle(mode, math.floor(x), math.floor(y), math.floor(w), math.floor(h))
    love.graphics.setColor(1, 1, 1, 1)
  end

  return Graphics
end
