local Resources = require "src.Resources"
local Taskbar = {}
Taskbar.__index = Taskbar

function Taskbar.new()
  local task = {
    h = 45,
    w = 0, -- Handled in update

    y = 0, -- Handled in update
    x = 0,
  }

  return setmetatable(task, Taskbar)
end

function Taskbar:update(delta)
  local w, h = love.graphics.getDimensions()
  self.w = w
  self.y = h - self.h
end

function Taskbar:draw()
  -- Outline
  love.graphics.setColor(Resources.colours.white)
  love.graphics.rectangle("fill", 0, math.floor(self.y - 2), self.w, self.h)

  -- Body
  love.graphics.setColor(Resources.colours.grey)
  love.graphics.rectangle("fill", 0, math.floor(self.y), self.w, self.h)

  love.graphics.setColor(1, 1, 1, 1)
end

return Taskbar
