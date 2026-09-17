local Window = require "src.entities.Window"
local Resources = require "src.Resources"
local Game = {}

function Game:init()
  ---@type [Window]
  self.windows = {}

  table.insert(self.windows, Window.new(400, 300, "Hello, World! qQpP123456789"))
  table.insert(self.windows, Window.new(400, 300, "Meow!"))
end

function Game:update(delta)
  for _, window in ipairs(self.windows) do
    window:update()
  end
end

function Game:draw()
  love.graphics.clear(Resources.colours.default_green)

  for _, window in ipairs(self.windows) do
    window:draw()
  end
end

function Game:mousepressed(x, y, button)
  for i = #self.windows, 1, -1 do
    local window = self.windows[i]

    if window:mousepressed(x, y, button) then
      table.remove(self.windows, i)
      table.insert(self.windows, window)

      -- Window focus
      for _, other in ipairs(self.windows) do
        other.focus = false
      end

      window.focus = true

      break
    end
  end
end

function Game:mousereleased(x, y, button)
  for _, window in ipairs(self.windows) do
    window:mousereleased(x, y, button)
  end
end

return Game
