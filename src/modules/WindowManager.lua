local Window = require "src.entities.Window"
local WindowManager = {}

function WindowManager:init(kernel)
  ---@type Window[]
  self.windows = {}

  ---@type Window[]
  self.overlays = {}

  self.kernel = kernel
end

function WindowManager:window(pid, w, h, title, hints)
  local function closeRequest()
    self.kernel:raise(pid, { "quit" })
  end

  local instance = Window.new(100, 100, pid, w, h, title, closeRequest, hints)

  if not hints.no_focus then
    for _, window in ipairs(self.windows) do
      window.focus = false
    end

    instance.focus = true
  end

  if hints.docked then
    table.insert(self.overlays, instance)
  else
    table.insert(self.windows, instance)
  end

  return instance
end

function WindowManager:getFocusedPID()
  if #self.windows == 0 then
    return nil
  end

  local top = self.windows[#self.windows]
  return top.pid
end

function WindowManager:getWithHandle(handle)
  for _, window in ipairs(self.windows) do
    if window.id == handle then
      return window
    end
  end

  for _, overlay in ipairs(self.overlays) do
    if overlay.id == handle then
      return overlay
    end
  end

  return nil
end

function WindowManager:closeForPID(pid)
  for i = #self.windows, 1, -1 do
    local window = self.windows[i]
    if window.pid == pid then
      table.remove(self.windows, i)
    end
  end

  for i = #self.overlays, 1, -1 do
    if self.overlays[i].pid == pid then
      table.remove(self.overlays, i)
    end
  end

  if #self.windows ~= 0 then
    self.windows[#self.windows].focus = true
  end
end

function WindowManager:update(delta)
  for _, window in ipairs(self.windows) do window:update(delta) end
  for _, overlay in ipairs(self.overlays) do overlay:update(delta) end
end

function WindowManager:draw()
  for _, window in ipairs(self.windows) do window:draw() end
  for _, overlay in ipairs(self.overlays) do overlay:draw() end
end

function WindowManager:mousepressed(x, y, button)
  for i = #self.overlays, 1, -1 do
    local overlay = self.overlays[i]
    if overlay:mousepressed(x, y, button) then
      return
    end
  end

  for i = #self.windows, 1, -1 do
    local window = self.windows[i]

    if window:mousepressed(x, y, button) then
      if not window.hints.no_focus then
        table.remove(self.windows, i)
        table.insert(self.windows, window)

        for _, other in ipairs(self.windows) do
          other.focus = false
        end

        window.focus = true
      end

      break
    end
  end
end

function WindowManager:mousereleased(x, y, button)
  for _, window in ipairs(self.windows) do window:mousereleased(x, y, button) end
  for _, overlay in ipairs(self.overlays) do overlay:mousereleased(x, y, button) end
end

return WindowManager
