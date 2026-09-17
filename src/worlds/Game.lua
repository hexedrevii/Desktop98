local Window    = require "src.entities.Window"
local Resources = require "src.Resources"
local Taskbar   = require "src.entities.Taskbar"
local Button    = require "src.entities.UI.Button"
local Game      = {}

function Game:init()
  ---@type [Window]
  self.windows = {}

  table.insert(self.windows, Window.new(400, 300, "Hello, World! qQpP123456789"))
  table.insert(self.windows, Window.new(400, 300, "Meow!"))

  self.taskbar = Taskbar.new()

  self.btn = Button.new({
    font = Resources.manager:get("font"),
    text = "Start",
    image = Resources.manager:get("start-icon"),

    gap = 3,

    offsetX = 5,
    anchorY = 0.5
  }, self.taskbar)
end

function Game:update(delta)
  local w, h = love.graphics.getDimensions()
  for _, window in ipairs(self.windows) do
    window:update(delta)

    -- Taskbar can't cover window
    window.y = math.min(window.y, h - 70)
  end

  self.taskbar:update(delta)
  self.btn:update(delta)
end

function Game:draw()
  love.graphics.clear(Resources.colours.default_green)

  for _, window in ipairs(self.windows) do
    window:draw()
  end

  self.taskbar:draw()

  self.btn:draw()
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
