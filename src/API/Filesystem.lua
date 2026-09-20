local VirtualFS = require "src.modules.VFS"

return function(pid)
  local Filesystem = {}

  function Filesystem.listDir(path)
    return VirtualFS:listDir(path)
  end

  return Filesystem
end
