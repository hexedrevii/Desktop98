local mkGraphics   = require "src.API.Graphics"
local mkSystem     = require "src.API.System"
local mkFilesystem = require "src.API.Filesystem"
local VirtualFS    = require "src.modules.VFS"

return function(kernel, pid, streams, masterPerms)
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

    printerr = function(...)
      local args = { ... }
      local str = ""

      for _, v in ipairs(args) do str = str .. tostring(v) .. "\t" end
      streams.stderr(str)
    end,

    graphics = mkGraphics(kernel, pid, masterPerms, streams),
    system = mkSystem(kernel, pid),
    fs = mkFilesystem(kernel, pid)
  }

  env.package = {
    loaded = {},
    path = "./?.lua;/lib/?.lua;/lib/?/init.lua;/sys/lib/?.lua;/sys/lib/?/init.lua"
  }

  env.require = function(module)
    -- Already loaded!
    if env.package.loaded[module] then
      return env.package.loaded[module]
    end

    -- Convert . to /
    local search = module:gsub("%.", "/")

    local content = nil
    local path = ""
    local errs = {}

    for template in string.gmatch(env.package.path, "[^;]+") do
      local test = template:gsub("?", search)

      if test:sub(1, 2) == "./" then
        local cwd = env.system.getCWD()
        if cwd:sub(-1) ~= "/" then
          cwd = cwd .. "/"
        end
        test = cwd .. test:sub(3)
      end

      local file, err = VirtualFS:read(test)
      if file then
        content = file
        path = test
        break
      else
        table.insert(errs, "No file " .. test .. ".")
      end
    end

    if not content then
      streams.stderr("module " .. module .. " not found\n" .. table.concat(errs, "\n"))
      error("module " .. module .. " not found\n" .. table.concat(errs, "\n"))
    end

    local chunk, err = load(content, path, "t", env)
    if not chunk then
      streams.stderr("Syntax error in " .. path .. ": " .. err)
      error("Syntax error in " .. path .. ": " .. err)
    end

    local result = chunk()
    if result == nil then
      result = true
    end

    env.package.loaded[module] = result
    return env.package.loaded[module]
  end

  return env
end
