---@class WorldController
---@field private active World
local WorldController = {}
WorldController.__index = WorldController

---@class World
---@field init function?
---@field update function
---@field draw function
---@field mousepressed function?
---@field mousereleased function?
---@field resize function?
local _world = {}

---@return WorldController
function WorldController.new()
  local w = {
    active = nil
  }

  return setmetatable(w, WorldController);
end

---@param new World
function WorldController:set(new)
  self.active = new
  if self.active.init then
    self.active:init()
  end
end

function WorldController:update(dt)
  if self.active then
    self.active:update(dt)
  end
end

function WorldController:draw()
  if self.active then
    self.active:draw()
  end
end

function WorldController:mousepressed(x, y, button)
  if self.active and self.active.mousepressed then
    self.active:mousepressed(x, y, button)
  end
end

function WorldController:mousereleased(x, y, button)
  if self.active and self.active.mousereleased then
    self.active:mousereleased(x, y, button)
  end
end

function WorldController:resize(w, h)
  if self.active and self.active.resize then
    self.active:resize(w, h)
  end
end

return WorldController
