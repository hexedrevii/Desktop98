local mkGraphics = require "src.API.Graphics"
local mkSystem = require "src.API.System"

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
    type = type,

    print = function(...)
      local args = { ... }
      local str = ""

      for _, v in ipairs(args) do str = str .. tostring(v) .. "\t" end
      streams.stdout(str)
    end,

    graphics = mkGraphics(pid),
    system = mkSystem(kernel, pid)
  }

  return env
end
