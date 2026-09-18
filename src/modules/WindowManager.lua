local Window = require "src.entities.Window"
local WindowManager = {}

function WindowManager:init()
  ---@type Window[]
  self.windows = {}
end

function WindowManager:window(pid, w, h, title)
  local instance = Window.new(100, 100, pid, w, h, title)

  for _, window in ipairs(self.windows) do
    window.focus = false
  end

  instance.focus = true

  table.insert(self.windows, instance)
  return instance
end

function WindowManager:getFocusedPID()
  if #self.windows == 0 then
    return nil
  end

  local top = self.windows[#self.windows]
  return top.pid
end

function WindowManager:update(delta)
  for _, window in ipairs(self.windows) do
    window:update(delta)
  end
end

function WindowManager:draw()
  for _, window in ipairs(self.windows) do
    window:draw()
  end
end

function WindowManager:mousepressed(x, y, button)
  for i = #self.windows, 1, -1 do
    local window = self.windows[i]

    if window:mousepressed(x, y, button) then
      table.remove(self.windows, i)
      table.insert(self.windows, window)

      for _, other in ipairs(self.windows) do
        other.focus = false
      end

      window.focus = true

      break
    end
  end
end

function WindowManager:mousereleased(x, y, button)
  for _, window in ipairs(self.windows) do
    window:mousereleased(x, y, button)
  end
end

return WindowManager
