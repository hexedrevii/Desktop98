local VirtualFS = require "src.modules.VFS"
local WindowManager = require "src.modules.WindowManager"

local mkGraphics = require "src.API.Graphics"

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

  local env = {
    table = table,
    string = string,
    math = math,
    pairs = pairs,
    ipairs = ipairs,
    unpack = unpack,
    tostring = tostring,
    tonumber = tonumber,

    print = function(...)
      local args = { ... }
      local str = ""

      for _, v in ipairs(args) do str = str .. tostring(v) .. "\t" end
      streams.stdout(str)
    end,

    window = function(w, h, title)
      return WindowManager:window(pid, w, h, title)
    end,

    system = {
      execute = function(target, targetStream)
        return self:process(target, targetStream)
      end
    },

    graphics = mkGraphics(pid)
  }

  setfenv(chunk, env)
  local success, data = pcall(chunk)
  if not success then
    print("Kernel: Could not create process " .. path .. " crashed on start: " .. tostring(data))
    return nil, "Crash: " .. tostring(data)
  end

  if data and type(data) == "table" then
    table.insert(self.processes, pid, {
      pid = pid,
      instance = data or {},
      status = "running",
    })
  end

  return pid
end

function Kernel:update(delta)
  WindowManager:update(delta)

  for _, process in pairs(self.processes) do
    -- The App has an actual instance and not a one-and-done
    if process.instance then
      -- Has a "run" function (which is just the update/draw mangled)
      if type(process.instance.run) == "function" then
        -- Optional delta arg
        local success, err = pcall(process.instance.run, delta)

        if not success then
          print("Kernel: Process " .. process.pid .. " crashed! Error: " .. tostring(err))

          -- TODO: Kill process (in kernel, AND wm)
        end
      end
    end
  end
end

function Kernel:draw()
  WindowManager:draw()
end

function Kernel:keypressed(key)
  local pid = WindowManager:getFocusedPID()

  if pid and self.processes[pid] then
    local app = self.processes[pid].instance
    if app and type(app.keypressed) == "function" then
      local success, err = pcall(app.keypressed, key)
      if not success then
        print("App " .. pid .. " crashed on keypress: " .. tostring(err))
      end
    end
  end
end

function Kernel:textinput(text)
  local pid = WindowManager:getFocusedPID()

  if pid and self.processes[pid] then
    local app = self.processes[pid].instance
    if app and type(app.textinput) == "function" then
      local success, err = pcall(app.textinput, text)
      if not success then
        print("App " .. pid .. " crashed on textinput: " .. tostring(err))
      end
    end
  end
end

function Kernel:mousepressed(x, y, button)
  WindowManager:mousepressed(x, y, button)
end

function Kernel:mousereleased(x, y, button)
  WindowManager:mousereleased(x, y, button)
end

return Kernel
