local Resources = require "src.Resources"
---@class Header
---@field parent Window
---@field w integer
---@field h integer
---@field drag boolean
---@field ox number
---@field oy number
---@field x number
---@field y number
---@field private dragX number
---@field private dragY number
local Header = {}
Header.__index = Header

---@param parent Window
function Header.new(parent)
  local header = {
    parent = parent,

    h = 20,
    w = 0, -- handled in update
    ox = 3,
    oy = 3,

    x = 0,
    y = 0,

    drag = false,
    dragX = 0,
    dragY = 0
  }

  return setmetatable(header, Header)
end

function Header:update(delta)
  self.w = self.parent.w - (self.ox * 2)

  if self.drag then
    local mx, my = love.mouse.getPosition()
    self.parent.x = mx - self.dragX
    self.parent.y = my - self.dragY
  end

  self.x = self.parent.x + self.ox
  self.y = self.parent.y + self.oy
end

function Header:draw()
  if self.parent.focus then
    love.graphics.setColor(Resources.colours.deep_blue)
  else
    love.graphics.setColor(Resources.colours.deep_grey)
  end

  -- Background
  love.graphics.rectangle("fill",
    math.floor(self.parent.x + self.ox),
    math.floor(self.parent.y + self.oy),
    self.w, self.h
  )

  -- Text
  love.graphics.setColor(Resources.colours.white)
  love.graphics.print(
    self.parent.title,
    Resources.manager:get("font-small"),
    math.floor(self.parent.x + self.ox + 2),
    math.floor(self.parent.y + self.oy + 2)
  )

  love.graphics.setColor(1, 1, 1, 1)
end

function Header:mousepressed(x, y, button)
  if button == 1 then
    local hx = self.parent.x + self.ox
    local hy = self.parent.y + self.oy

    if x >= hx and x <= hx + self.w and y >= hy and y <= hy + self.h then
      self.drag = true

      self.dragX = x - self.parent.x
      self.dragY = y - self.parent.y

      return true
    end

    return false
  end
end

function Header:mousereleased(x, y, button)
  if button == 1 then
    self.drag = false
  end
end

return Header
