local Resources = require "src.Resources"
---@class Button
---@field parent any
---@field w number
---@field h number
---@field x number
---@field y number
---@field offsetX number?
---@field offsetY number?
---@field anchorX number?
---@field anchorY number?
---@field private text string
---@field private font love.Font
---@field private image love.Image?
---@field private padding number
---@field private gap number
---@field private anchored boolean
local Button = {}
Button.__index = Button

---@class ButtonOptions
---@field text string
---@field font love.Font
---@field image love.Image?
---@field x number?
---@field y number?
---@field offsetX number?
---@field offsetY number?
---@field anchorX number? Anchor (0-1) X
---@field anchorY number? Anchor (0-1) Y
---@field gap number? Gap between image and text
local __opts = {}

---@param opts ButtonOptions
---@param parent any? Position relative to parent or screen
function Button.new(opts, parent)
  local button = {
    parent = parent,

    -- Optional since Anchor handles these
    x = opts.x or 0,
    y = opts.y or 0,

    anchorX = opts.anchorX,
    anchorY = opts.anchorY,

    offsetX = opts.offsetX or 0,
    offsetY = opts.offsetY or 0,

    gap = opts.gap or 0,

    text = opts.text,
    font = opts.font,
    image = opts.image,
  }

  button.anchored = button.anchorX or button.anchorY

  -- TODO: Make this not hardcoded
  button.padding = 2 -- Left,Right,Up,Down padding in pixels

  button.h = button.font:getHeight() + (button.padding * 2)
  if button.image then
    button.h = math.max(button.font:getHeight(), button.image:getHeight()) + (button.padding * 2)
  end

  button.w = button.font:getWidth(button.text) + button.gap + (button.padding * 2)
  if button.image then
    button.w = button.font:getWidth(button.text) + button.image:getWidth() + button.gap + (button.padding * 2)
  end

  return setmetatable(button, Button)
end

function Button:update(delta)
  if not self.anchored then
    if self.parent then
      self.x = self.parent.x + self.offsetX
      self.y = self.parent.y + self.offsetY
    end
  else
    local w, h = love.graphics.getDimensions()
    local ox, oy = 0, 0
    if self.parent then
      w, h = self.parent.w, self.parent.h
      ox, oy = self.parent.x, self.parent.y
    end

    if self.anchorX then
      self.x = ox + (w * self.anchorX) - (self.w * self.anchorX) + self.offsetX
    else
      self.x = self.parent.x + self.offsetX
    end

    if self.anchorY then
      self.y = oy + (h * self.anchorY) - (self.h * self.anchorY) + self.offsetY
    else
      self.y = self.parent.y + self.offsetY
    end
  end
end

function Button:draw()
  -- Body
  love.graphics.setColor(Resources.colours.grey)
  love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), math.floor(self.w), math.floor(self.h))

  -- Outlines
  -- Light
  love.graphics.setColor(Resources.colours.white)
  love.graphics.line(
    math.floor(self.x - 1), math.floor(self.y),
    math.floor(self.x - 1), math.floor(self.y + self.h)
  )

  love.graphics.line(
    math.floor(self.x), math.floor(self.y - 1),
    math.floor(self.x + self.w), math.floor(self.y - 1)
  )

  -- Dark
  love.graphics.setColor(Resources.colours.black)
  love.graphics.line(
    math.floor(self.x), math.floor(self.y + self.h + 1),
    math.floor(self.x + self.w), math.floor(self.y + self.h + 1)
  )

  love.graphics.line(
    math.floor(self.x + self.w + 1), math.floor(self.y),
    math.floor(self.x + self.w + 1), math.floor(self.y + self.h)
  )

  -- Text & image
  if not self.image then
    love.graphics.setFont(self.font)
    love.graphics.setColor(Resources.colours.white)
    love.graphics.print(self.text, math.floor(self.x + self.padding), math.floor(self.y + self.padding))
  else
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, math.floor(self.x + self.padding), math.floor(self.y + self.padding))

    love.graphics.setFont(self.font)
    love.graphics.setColor(Resources.colours.black)
    love.graphics.print(self.text,
      math.floor(self.x + self.padding + self.gap + self.image:getWidth()),
      math.floor(self.y + self.padding + self.image:getHeight() / 2 - self.font:getHeight() / 2)
    )
  end

  love.graphics.setColor(1, 1, 1, 1)
end

return Button
