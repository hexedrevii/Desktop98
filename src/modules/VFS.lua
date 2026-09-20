local VirtualFS = {
  root = "rootfs"
}

---@param path string
local function resolve(path)
  local clean = VirtualFS:normalise(path)
  local relative = clean:gsub("%.%.", "")

  if relative == "" then
    return VirtualFS.root
  else
    return VirtualFS.root .. "/" .. relative
  end
end

function VirtualFS:init()
  local info = love.filesystem.getInfo(self.root)

  if not info then
    love.filesystem.createDirectory("rootfs")
  end
end

function VirtualFS:normalise(path)
  local stack = {}

  for part in string.gmatch(path, "[^/]+") do
    if part == "." then
    elseif part == ".." then
      table.remove(stack)
    else
      table.insert(stack, part)
    end
  end

  if #stack == 0 then return "/" end

  return "/" .. table.concat(stack, "/")
end

function VirtualFS:getInfo(path)
  path = resolve(path)

  local info = love.filesystem.getInfo(path)
  if info then
    return info.type
  end

  return nil, "No such file or directory."
end

--- Lists the contents of a directory
---@param path string
function VirtualFS:listDir(path)
  local info = self:getInfo(path)
  if info and info == "directory" then
    local real = resolve(path)
    return love.filesystem.getDirectoryItems(real)
  else
    return nil, "Not a directory."
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
