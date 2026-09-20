local Resources = require "src.Resources"
local Header    = require "src.entities.Header"
local Button    = require "src.entities.UI.Button"
---@class Window
---@field x number
---@field y number
---@field w integer
---@field h integer
---@field canvas love.Canvas
---@field title string
---@field header Header
---@field pid integer
---@field private outlineOffset number
---@field focus boolean
---@field closeButton Button
---@field minimiseButton Button
---@field maximiseButton Button
local Window    = {}
Window.__index  = Window

function Window.new(x, y, pid, w, h, title)
  local window = {
    x = x,
    y = y,
    pid = pid,

    w = w,
    h = h,

    title = title,
    outlineOffset = 1,
    focus = false
  }
  setmetatable(window, Window)

  window.header = Header.new(window)

  window.closeButton = Button.new({
    text = "X",
    font = Resources.manager:get("font-smaller"),

    anchorY = 0.5,
    anchorX = 1,

    offsetX = -4,
  }, window.header)

  window.minimiseButton = Button.new({
    text = "_ ",
    font = Resources.manager:get("font-smaller"),

    anchorY = 0.5,
    anchorX = 1,

    offsetX = -20,
  }, window.header)

  local sw, sh = window.w - 10, window.h - window.header.h - window.header.oy * 2 - 5
  window.canvas = love.graphics.newCanvas(sw, sh)

  return window
end

function Window:drawContent()
  local sx, sy = math.floor(self.x), math.floor(self.y + self.header.h + self.header.oy * 2)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(Resources.manager:get("font-small"))
  love.graphics.draw(self.canvas, sx + 5, sy)
end

function Window:update(delta)
  self.header:update(delta)

  self.closeButton:update(delta)
  self.minimiseButton:update(delta)
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

  -- Header Buttons
  self.closeButton:draw()
  self.minimiseButton:draw()

  love.graphics.setColor(1, 1, 1, 1)

  self:drawContent()

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
