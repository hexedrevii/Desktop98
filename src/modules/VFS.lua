local VirtualFS = {
  root = "rootfs"
}

---@param path string
local function resolve(path)
  local clean = path:gsub("^/+", "")
  clean = clean:gsub("%.%.", "")

  return VirtualFS.root .. "/" .. clean
end

function VirtualFS:init()
  local info = love.filesystem.getInfo(self.root)

  if not info then
    love.filesystem.createDirectory("rootfs")
  end
end

---Read a file.
---@param path string
---@return string? File contents
---@return string? Error message
function VirtualFS:read(path)
  local real = resolve(path)

  local info = love.filesystem.getInfo(real)
  if not info or info.type ~= "file" then
    return nil, "No such file"
  end

  return love.filesystem.read(real), nil
end

return VirtualFS
