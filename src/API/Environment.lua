local mkGraphics = require "src.API.Graphics"
local WindowManager = require "src.modules.WindowManager"

return function(kernel, pid, streams)
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
        return kernel:process(target, targetStream)
      end
    },

    graphics = mkGraphics(pid)
  }

  return env
end
