local Resources = require "src.Resources"
local Header    = require "src.entities.Header"
local Button    = require "src.entities.UI.Button"
local Utils     = require "src.Utils"
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
---@field hints table<string, boolean>
---@field id number
local Window    = {}
Window.__index  = Window

function Window.new(x, y, pid, w, h, title, closeRequest, hints)
  local window = {
    id = Utils.id(),
    x = x,
    y = y,
    pid = pid,

    w = w,
    h = h,

    title = title,
    outlineOffset = 1,
    focus = false,
    hints = hints
  }
  setmetatable(window, Window)

  if not hints.no_header then
    window.header = Header.new(window)

    window.closeButton = Button.new({
      text = "X",
      font = Resources.manager:get("font-smaller"),

      anchorY = 0.5,
      anchorX = 1,

      offsetX = -4,
      onPressed = function()
        if closeRequest then
          closeRequest()
        end
      end
    }, window.header)

    window.minimiseButton = Button.new({
      text = "_ ",
      font = Resources.manager:get("font-smaller"),

      anchorY = 0.5,
      anchorX = 1,

      offsetX = -20,
      onPressed = function()

      end
    }, window.header)
  end

  local sw, sh
  if hints.no_header then
    sw, sh = w, h
  else
    sw, sh = window.w - 10, window.h - window.header.h - window.header.oy * 2 - 5
  end

  window.canvas = love.graphics.newCanvas(sw, sh)

  return window
end

function Window:setPosition(x, y)
  self.x = x
  self.y = y
end

function Window:resize(nw, nh)
  local ow, oh = self.w, self.h

  nw = nw or ow
  nh = nh or oh

  if nw == ow and nh == oh then
    return
  end

  local sw, sh
  if self.hints.no_header then
    sw, sh = nw, nh
  else
    sw, sh = nw - 10, nh - self.header.h - self.header.oy * 2 - 5
  end

  local new = love.graphics.newCanvas(sw, sh)

  love.graphics.setCanvas(new)
  love.graphics.setColor(1, 1, 1, 1)

  love.graphics.draw(self.canvas, 0, 0)

  love.graphics.setCanvas()

  self.canvas = new

  self.w = nw
  self.h = nh
end

function Window:drawContent()
  local sx, sy
  if self.hints.no_header then
    sx, sy = math.floor(self.x), math.floor(self.y)
  else
    sx, sy = math.floor(self.x + 5), math.floor(self.y + self.header.h + self.header.oy * 2)
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, sx, sy)
end

function Window:update(delta)
  if not self.hints.no_header then
    self.header:update(delta)

    self.closeButton:update(delta)
    self.minimiseButton:update(delta)
  end
end

function Window:draw()
  love.graphics.setColor(Resources.colours.grey)

  -- Body
  if not self.hints.no_background then
    love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.w, self.h)
  end

  if not self.hints.borderless then
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
  end

  if not self.hints.no_header then
    -- Header
    self.header:draw()

    -- Header Buttons
    self.closeButton:draw()
    self.minimiseButton:draw()
  end

  love.graphics.setColor(1, 1, 1, 1)

  self:drawContent()

  love.graphics.setColor(1, 1, 1, 1)
end

function Window:mousepressed(x, y, button)
  if not self.hints.no_header then
    if self.closeButton:mousepressed(x, y, button) then
      return true
    end

    if self.minimiseButton:mousepressed(x, y, button) then
      return false
    end

    if self.header:mousepressed(x, y, button) then
      return true
    end
  end

  if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
    return true
  end

  return false
end

function Window:mousereleased(x, y, button)
  if not self.hints.no_header then
    self.closeButton:mousereleased(x, y, button)
    self.minimiseButton:mousereleased(x, y, button)

    self.header:mousereleased(x, y, button)
  end
end

return Window
