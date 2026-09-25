local Colour = require "src.API.Colour"
local WindowManager = require "src.modules.WindowManager"
local VirtualFS = require "src.modules.VFS"

return function(pid, master)
  local drawing = false

  local Graphics = {}

  local wmHints = {}
  local ALLOWED_HINTS = {
    no_focus = true,
    borderless = true,
    no_header = true,
    no_background = true,
    docked = true
  }
  local hintData = {
    NO_FOCUS = "no_focus",
    BORDERLESS = "borderless",
    NO_HEADER = "no_header",
    NO_BACKGROUND = "no_background",
    TYPE_DOCK = "docked"
  }
  Graphics.WM = setmetatable({}, {
    __index = hintData,
    __newindex = function(t, key, value)
      error("Security Violation: graphics.WM is read-only.")
    end,

    __metatable = false
  })

  function Graphics.window(w, h, title, hints)
    hints = hints or {}

    for _, hint in ipairs(hints) do
      if not ALLOWED_HINTS[hint] then
        error("graphics.window: Invalid window hint '" .. tostring(hint) .. "'")
      end

      if hint == "docked" and not master then
        error("graphics.window: Security Violation: No permission for that.")
      end

      wmHints[hint] = true
    end

    local real = WindowManager:window(pid, w, h, title, wmHints)

    -- Proxy
    return {
      __INTERNAL_window_handle = real.id,

      setDimensions = function(nw, nh)
        real:resize(nw, nh)
      end,

      setPosition = function(nx, ny)
        real:setPosition(nx, ny)
      end,

      getDimensions = function()
        local ww, wh = real.canvas:getDimensions()
        return ww, wh
      end
    }
  end

  function Graphics.getDimensions()
    local w, h = love.graphics.getDimensions()
    return w, h
  end

  function Graphics.beginDrawing(window)
    if type(window) ~= "table" and not window.__INTERNAL_window_handle then
      error("Graphics API: Invalid window object")
    end

    if drawing then
      -- TODO: Kernel error crash (Cannot enter draw while already drawing)
    end

    local real = WindowManager:getWithHandle(window.__INTERNAL_window_handle)
    if not real then
      error("STOP FUCKING WITH THE HANDLES.")
    end

    if real.pid ~= pid then
      -- TODO: Kernel error crash (Cannot draw to another Process)
    end

    love.graphics.setCanvas(real.canvas)
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
    red = Colour.new(1, 0, 0),

    os = {
      grey = Colour.new(0.765, 0.765, 0.765),
      dark_grey = Colour.new(0.506, 0.506, 0.506),
      dark_blue = Colour.new(0.004, 0, 0.506),
    }
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

  function Graphics.line(sx, sy, ex, ey, colour)
    colour = colour or Graphics.colours.white

    love.graphics.setColor(colour:raw())
    love.graphics.line(sx, sy, ex, ey)
    love.graphics.setColor(1, 1, 1, 1)
  end

  return Graphics
end
