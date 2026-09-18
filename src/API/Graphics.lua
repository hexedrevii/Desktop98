local Colour = require "src.API.Colour"

return function(pid)
  local drawing = false

  local Graphics = {}

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
    black = Colour.new(0, 0, 0)
  }

  Graphics.Colour = Colour

  function Graphics.clear(colour)
    if not drawing then
      -- TODO: Kernel error crash (Cannot draw while not drawing)
    end

    love.graphics.clear(colour:raw())
  end

  function Graphics.print(text, x, y, colour)
    if not drawing then
      -- TODO: Kernel error crash (Cannot end draw while not drawing)
    end

    colour = colour or Graphics.colours.white

    love.graphics.setColor(colour:raw())
    love.graphics.print(text, math.floor(x), math.floor(y))
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
