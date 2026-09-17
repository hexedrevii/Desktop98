local Resources = require "src.Resources"
local Game      = require "src.worlds.Game"

_G.unpack       = table.unpack or unpack

function love.load()
  Resources.manager:add("font", love.graphics.newFont("assets/W95F.otf", 21))
  Resources.manager:add("font-small", love.graphics.newFont("assets/W95F.otf", 18))

  Resources.worlds:set(Game)
end

function love.update(delta)
  Resources.worlds:update(delta)
end

function love.draw()
  Resources.worlds:draw()
end

function love.mousepressed(x, y, button)
  Resources.worlds:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  Resources.worlds:mousereleased(x, y, button)
end
