local Utils = {
  nextID = 1
}

function Utils.pointrec(px, py, rx, ry, rw, rh)
  return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

function Utils.id()
  local id = Utils.nextID
  Utils.nextID = Utils.nextID + 1

  return tostring(id)
end

return Utils
