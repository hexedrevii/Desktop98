local Resources = require "src.Resources"
local Header    = require "src.entities.Header"
---@class Window
---@field x number
---@field y number
---@field w integer
---@field h integer
---@field title string
---@field header Header
---@field private outlineOffset number
---@field focus boolean
local Window    = {}
Window.__index  = Window

function Window.new(w, h, title)
  local window = {
    x = 100,
    y = 100,

    w = w,
    h = h,

    title = title,
    outlineOffset = 1,
    focus = false
  }
  setmetatable(window, Window)

  window.header = Header.new(window)

  return window
end

function Window:update(delta)
  self.header:update(delta)
end

function Window:draw()
  love.graphics.setColor(Resources.colours.grey)

  -- Body
  love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.w, self.h)

  -- Outlines
  love.graphics.setLineWidth(self.outlineOffset)

  -- Light
  love.graphics.setColor(Resources.colours.white)
  love.graphics.line(
    math.floor(self.x - self.outlineOffset), math.floor(self.y),
    math.floor(self.x - self.outlineOffset), math.floor(self.y + self.h)
  )

  love.graphics.line(
    math.floor(self.x), math.floor(self.y - self.outlineOffset),
    math.floor(self.x + self.w), math.floor(self.y - self.outlineOffset)
  )

  -- Dark
  love.graphics.setColor(Resources.colours.black)
  love.graphics.line(
    math.floor(self.x), math.floor(self.y + self.h + self.outlineOffset),
    math.floor(self.x + self.w), math.floor(self.y + self.h + self.outlineOffset)
  )

  love.graphics.line(
    math.floor(self.x + self.w + self.outlineOffset), math.floor(self.y),
    math.floor(self.x + self.w + self.outlineOffset), math.floor(self.y + self.h)
  )

  -- Header
  self.header:draw()

  love.graphics.setColor(1, 1, 1, 1)
end

function Window:mousepressed(x, y, button)
  if self.header:mousepressed(x, y, button) then
    return true
  end

  if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
    return true
  end

  return false
end

function Window:mousereleased(x, y, button)
  self.header:mousereleased(x, y, button)
end

return Window
