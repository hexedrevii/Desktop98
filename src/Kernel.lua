local VirtualFS = require "src.modules.VFS"
local WindowManager = require "src.modules.WindowManager"

local mkEnvironment = require "src.API.Environment"

local Kernel = {}

function Kernel:init()
  self.nextPid = 1

  VirtualFS:init()
  WindowManager:init()

  self.processes = {}
end

---@param path string
function Kernel:process(path, streams)
  local pid = self.nextPid
  self.nextPid = self.nextPid + 1

  streams = streams or {
    stdout = function(text)
      print("[STDOUT] " .. text)
    end
  }

  local content, contentErr = VirtualFS:read(path)
  if not content then
    print("Kernel: Could not create process " .. path .. ": " .. contentErr)
    return nil, contentErr
  end

  local chunk, chunkErr = loadstring(content)
  if not chunk then
    print("Kernel: Could not create process " .. path .. ": " .. chunkErr)
    return nil, chunkErr
  end

  jit.off(chunk, true)

  local env = mkEnvironment(self, pid, streams)

  setfenv(chunk, env)

  local lock = coroutine.create(function()
    local app = chunk()

    if type(app) == "table" then
      local delta, events = coroutine.yield()
      while true do
        if events then
          for _, event in ipairs(events) do
            -- First should ALWAYS be the event name
            local name = event[1]

            local callback = app[name]
            if type(callback) == "function" then
              callback(unpack(event, 2))
            end
          end
        end

        if type(app.run) == "function" then
          app.run(delta)
        end

        delta, events = coroutine.yield()
      end
    end
  end)

  local success, err = coroutine.resume(lock)
  if not success then
    print("Kernel: Process " .. path .. " crashed on start: " .. tostring(err))
    return nil, "Crash: " .. tostring(err)
  end

  if coroutine.status(lock) ~= "dead" then
    self.processes[pid] = {
      pid = pid,
      thread = lock,
      status = "running", -- MIIIIGHT be useless?
      events = {},        -- LOVE events translated so the Kernel can understand.
    }
  end

  return pid
end

function Kernel:update(delta)
  WindowManager:update(delta)

  for pid, process in pairs(self.processes) do
    debug.sethook(process.thread, function()
      error("Kernel: CPU Quota exceeded (Did you forget to break out of a loop?)")
    end, "", 1000)

    local success, err = coroutine.resume(process.thread, delta, process.events)

    -- Clear out watchdog
    debug.sethook(process.thread)

    -- Clear out events so they don't mess up
    process.events = {}

    if not success then
      print("Kernel: Process " .. tostring(pid) .. " crashed: " .. tostring(err))

      -- TODO: Kill
    elseif coroutine.status(process.thread) == "dead" then
      -- TODO: Kill
    end
  end
end

function Kernel:draw()
  WindowManager:draw()
end

function Kernel:keypressed(key)
  local pid = WindowManager:getFocusedPID()

  if pid and self.processes[pid] then
    table.insert(self.processes[pid].events, { "keypressed", key })
  end
end

function Kernel:textinput(text)
  local pid = WindowManager:getFocusedPID()

  if pid and self.processes[pid] then
    table.insert(self.processes[pid].events, { "textinput", text })
  end
end

function Kernel:mousepressed(x, y, button)
  WindowManager:mousepressed(x, y, button)
end

function Kernel:mousereleased(x, y, button)
  WindowManager:mousereleased(x, y, button)
end

return Kernel
