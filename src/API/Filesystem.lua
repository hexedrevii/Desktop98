local VirtualFS = require "src.modules.VFS"

return function(pid)
  local Filesystem = {}

  function Filesystem.listDir(path)
    return VirtualFS:listDir(path)
  end

  function Filesystem.exists(path)
    local info = VirtualFS:getInfo(path)
    return info ~= nil
  end

  return Filesystem
end
