local VirtualFS = require "src.modules.VFS"

return function(kernel, pid)
  local Filesystem = {}

  local function getAbsolute(path)
    local abs = path

    if path:sub(1, 1) ~= "/" then
      local cwd = kernel:getCWD(pid)

      if cwd:sub(-1) ~= "/" then
        cwd = cwd .. "/"
      end

      if path:sub(1, 2) == "./" then
        abs = cwd .. path:sub(3)
      else
        abs = cwd .. path
      end
    end

    return abs
  end

  function Filesystem.listDir(path)
    local abs = getAbsolute(path)
    return VirtualFS:listDir(abs)
  end

  function Filesystem.read(path)
    local abs = getAbsolute(path)
    return VirtualFS:read(abs)
  end

  function Filesystem.remove(path, recurse)
    local abs = getAbsolute(path)
    return VirtualFS:remove(abs, recurse)
  end

  function Filesystem.exists(path)
    local abs = getAbsolute(path)
    local info = VirtualFS:getInfo(abs)
    return info ~= nil
  end

  return Filesystem
end
