local VirtualFS = {
  root = "rootfs",

  protected = {}
}

---@param path string
local function resolve(path)
  local clean = VirtualFS:normalise(path)
  local relative = clean:gsub("%.%.", "")

  if relative == "" then
    return VirtualFS.root
  else
    return VirtualFS.root .. relative
  end
end

local function recurseDelete(physical)
  local info = love.filesystem.getInfo(physical)
  if not info then
    return true
  end

  if info.type == "directory" then
    local items = love.filesystem.getDirectoryItems(physical)
    for _, item in ipairs(items) do
      local child = physical .. "/" .. item

      local success = recurseDelete(child)
      if not success then
        return false, "Could not delete " .. child
      end
    end
  end

  return love.filesystem.remove(physical)
end

function VirtualFS:init()
  local info = love.filesystem.getInfo(self.root)

  if not info then
    love.filesystem.createDirectory("rootfs")

    love.filesystem.createDirectory("rootfs/bin")
    love.filesystem.createDirectory("rootfs/apps")
    love.filesystem.createDirectory("rootfs/sys")
  end
end

--- Makes a folder readonly
function VirtualFS:readonly(path)
  local info, err = self:getInfo(path)
  if not info then
    return false, err
  end

  table.insert(self.protected, self:normalise(path))
  return true
end

function VirtualFS:isReadonly(path)
  local clean = self:normalise(path)

  for _, protected in ipairs(self.protected) do
    if clean == protected or clean:sub(1, #protected + 1) == protected .. "/" then
      return true
    end
  end

  return false
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

function VirtualFS:translate(path)
  return resolve(path)
end

function VirtualFS:getInfo(path)
  path = resolve(path)

  local info = love.filesystem.getInfo(path)
  if info then
    return info.type
  end

  return nil, path .. ": No such file or directory."
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

function VirtualFS:remove(path, recurse)
  if self:isReadonly(path) then
    return nil, "Could not remove " .. path .. " Read-Only filesystem."
  end

  local info, ierr = self:getInfo(path)
  if not info then
    return false, ierr
  end

  local physical = self:translate(path)
  if recurse then
    local success, err = recurseDelete(physical)
    if not success then
      return false, err
    end

    return true
  end

  local success = love.filesystem.remove(path)
  if not success then
    return false, "Could not erase file " .. path .. " (Is it a populated directory?)"
  end

  return true
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
