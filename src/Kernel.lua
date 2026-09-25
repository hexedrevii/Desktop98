local VirtualFS = require "src.modules.VFS"
local WindowManager = require "src.modules.WindowManager"

local mkEnvironment = require "src.API.Environment"

local Kernel = {}

function Kernel:init()
  self.nextPid = 1

  self.CPUQuota = 10000

  self.utsname = {
    name = "Desktop98",
    version = "0.0.1-beta",
    branch = "DEVELOPER",
    machine = "LÖVE-" .. string.format("%d.%d.%d", love.getVersion())
  }

  VirtualFS:init()
  VirtualFS:readonly("/sys")

  WindowManager:init(self)

  self.processes = {}

  self:process("/sys/desktop/taskbar.lua", nil, nil, nil, true)
end

function Kernel:raise(pid, event)
  local process = self.processes[pid]

  if process then
    table.insert(process.events, event)
    return true
  end

  return false
end

function Kernel:broadcast(event)
  for pid, process in pairs(self.processes) do
    table.insert(process.events, event)
  end
end

--- Equivalent of calling SIGKILL
function Kernel:kill(pid)
  local process = self.processes[pid]
  if not process then
    return
  end

  local parent = process.parent
  if parent and self.processes[parent] then
    table.insert(self.processes[parent].events, { "childdied", pid })
  end

  -- Kill all children
  -- TODO: send them to an orphan process (init/launchd)
  for _, child in pairs(self.processes) do
    if child.parent == pid then
      child.parent = nil
    end
  end

  WindowManager:closeForPID(pid)
  self.processes[pid] = nil
end

--- Get Current Working Directory for a process
function Kernel:getCWD(pid)
  local process = self.processes[pid]

  if process then
    return process.cwd
  end

  return nil
end

--- Set Current Working Directory for a process
function Kernel:setCWD(pid, path)
  local process = self.processes[pid]
  if not process then
    return false
  end

  local raw = path
  if path:sub(1, 1) ~= "/" then
    if process.cwd == "/" then
      raw = "/" .. path
    else
      raw = process.cwd .. "/" .. path
    end
  end

  local normalised = VirtualFS:normalise(raw)
  local info, err = VirtualFS:getInfo(normalised)

  if info then
    if info == "directory" then
      process.cwd = normalised
      return true
    else
      return false, "Not a directory."
    end
  else
    return false, err
  end
end

function Kernel:getprocess(pid)
  return self.processes[pid]
end

---@param path string
---@param streams table? The output streams
---@param parent integer? The PID of the parent process
function Kernel:process(path, args, streams, parent, masterPermission)
  local pid = self.nextPid
  self.nextPid = self.nextPid + 1

  -- Setup inheritence
  local cwd = "/"
  if parent and self.processes[parent] then
    cwd = self.processes[parent].cwd
  end

  local absolute = path
  if absolute:sub(1, 1) ~= "/" then
    if cwd == "/" then
      absolute = "/" .. absolute
    else
      absolute = cwd .. "/" .. absolute
    end
  end

  absolute = VirtualFS:normalise(absolute)

  if not parent then
    cwd = absolute:match("(.*)/") or "/"
  end

  local vars = {}
  if parent and self.processes[parent] then
    for name, value in pairs(self.processes[parent].env) do
      vars[name] = value
    end
  end

  streams = streams
  if streams then
    streams.stdout = streams.stdout or function(text)
      print("[STDOUT " .. "(" .. pid .. ")] " .. text)
    end

    streams.stderr = streams.stderr or function(text)
      print("[STDERR " .. "(" .. pid .. ")] " .. text)
    end
  else
    streams = {
      stdout = function(text)
        print("[STDOUT " .. "(" .. pid .. ")] " .. text)
      end,

      stderr = function(text)
        print("[STDERR " .. "(" .. pid .. ")] " .. text)
      end
    }
  end

  local content, contentErr = VirtualFS:read(absolute)
  if not content then
    print("Kernel: Could not create process " .. absolute .. ": " .. contentErr)
    return nil, contentErr
  end

  local chunk, chunkErr = loadstring(content)
  if not chunk then
    print("Kernel: Could not create process " .. absolute .. ": " .. chunkErr)
    return nil, chunkErr
  end

  -- Turn off JIT only if we are on JIT system
  -- This can happen if we run in e.g. love.js (it uses lua 5.1)
  if jit then
    jit.off(chunk, true)
  end

  local env = mkEnvironment(self, pid, streams, masterPermission)

  setfenv(chunk, env)

  local lock = coroutine.create(function()
    local app = chunk()

    if type(app) == "table" then
      if type(app.init) == "function" then
        app.init(args or {})
      end

      local delta, events = coroutine.yield()
      while true do
        local die = false
        if events then
          for _, event in ipairs(events) do
            -- First should ALWAYS be the event name
            local name = event[1]

            local callback = app[name]
            if type(callback) == "function" then
              callback(unpack(event, 2))
            elseif name == "quit" then
              die = true
            end
          end
        end

        if die then break end

        if type(app.run) == "function" then
          app.run(delta)
        else
          break
        end

        delta, events = coroutine.yield()
      end
    end
  end)

  self.processes[pid] = {
    pid = pid,
    parent = parent,
    thread = lock,
    cwd = cwd,
    events = {}, -- LOVE events translated so the Kernel can understand.
    env = vars,
    master = masterPermission,
    streams = streams
  }

  debug.sethook(lock, function()
    error("Kernel: " .. absolute .. " crashed on start: CPU Quota exceeded.")
  end, "", self.CPUQuota)

  local success, err = coroutine.resume(lock)

  debug.sethook(lock)

  if not success then
    print("Kernel: Process " .. absolute .. " crashed on start: " .. tostring(err))

    WindowManager:closeForPID(pid)

    return nil, "Crash: " .. tostring(err)
  end

  return pid
end

function Kernel:update(delta)
  WindowManager:update(delta)

  for pid, process in pairs(self.processes) do
    debug.sethook(process.thread, function()
      process.streams.stderr("CPU Quota exceeded (Did you forget to break out of a loop?)")
      error("Kernel: CPU Quota exceeded (Did you forget to break out of a loop?)")
    end, "", self.CPUQuota)

    local success, err = coroutine.resume(process.thread, delta, process.events)

    -- Clear out watchdog
    debug.sethook(process.thread)

    -- Clear out events so they don't mess up
    process.events = {}

    -- Small guard
    -- Do not print error if thread is just dead
    -- This usually happens when an app just exits without return(?)
    if coroutine.status(process.thread) == "dead" then
      Kernel:kill(pid)
    elseif not success then
      process.streams.stderr("Process " .. tostring(pid) .. " crashed: " .. tostring(err))
      print("Kernel: Process " .. tostring(pid) .. " crashed: " .. tostring(err))

      self:kill(pid)
    elseif coroutine.status(process.thread) == "dead" then
      self:kill(pid)
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

function Kernel:resize(w, h)
  self:broadcast({ "resolution", w, h })
end

return Kernel
