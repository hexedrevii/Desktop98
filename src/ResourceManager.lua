---@class ResourceManager
---@field private resources {name: string, resource: any}
local ResourceManager = {}
ResourceManager.__index = ResourceManager

function ResourceManager.new()
  local rm = {
    resources = {}
  }

  return setmetatable(rm, ResourceManager)
end

---@param name string
---@param resource any
function ResourceManager:add(name, resource)
  self.resources[name] = resource

  return self
end

---@return any
function ResourceManager:get(name)
  assert(self.resources[name] ~= nil, 'Resource ' .. name .. ' does not exist!')

  return self.resources[name]
end

return ResourceManager
