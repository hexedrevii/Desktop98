local Colour = {}
Colour.__index = Colour

function Colour.new(r, g, b, a)
  local clr = {
    r = r,
    g = g,
    b = b,
    a = a or 1
  }

  return setmetatable(clr, Colour)
end

function Colour:raw()
  return self.r, self.g, self.b, self.a
end

return Colour
