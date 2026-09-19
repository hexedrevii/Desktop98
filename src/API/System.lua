return function(kernel, pid)
  local System = {}

  function System.exit()
    kernel:kill(pid)
  end

  function System.execute(target, targetStream)
    return kernel:process(target, targetStream)
  end

  return System
end
