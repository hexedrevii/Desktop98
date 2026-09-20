local Resources = require "src.Resources"
local Kernel    = require "src.Kernel"

_G.unpack       = table.unpack or unpack

function love.load()
  love.keyboard.setTextInput(true)
  love.filesystem.setIdentity("Desktop98")

  love.graphics.setDefaultFilter("nearest", "nearest")
  Resources.manager:add("font", love.graphics.newFont("assets/W95F.otf", 21))
  Resources.manager:add("font-small", love.graphics.newFont("assets/W95F.otf", 18))
  Resources.manager:add("font-smaller", love.graphics.newFont("assets/W95F.otf", 10))

  Resources.manager:add("start-icon", love.graphics.newImage("assets/windows.png"))

  Kernel:init()
  Kernel:process("/bin/terminal.lua")
  Kernel:process("/bin/welcome.lua")
end

function love.update(delta)
  Kernel:update(delta)
end

function love.draw()
  love.graphics.clear(1, 1, 1, 1)
  Kernel:draw()
end

function love.keypressed(key)
  Kernel:keypressed(key)
end

function love.textinput(text)
  Kernel:textinput(text)
end

function love.mousepressed(x, y, button)
  Kernel:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  Kernel:mousereleased(x, y, button)
end
