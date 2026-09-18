local ResourceManager = require "src.ResourceManager"

local Resources = {
  manager = ResourceManager.new(),

  colours = {
    deep_grey = { 0.506, 0.506, 0.506 },
    grey = { 0.765, 0.765, 0.765 },
    white = { 0.992, 1, 1 },
    deep_blue = { 0.004, 0, 0.506 },
    default_green = { 0, 0.502, 0.502 },
    black = { 0, 0, 0 },
    pink = { 1, 0, 0.506 }
  }
}

return Resources
