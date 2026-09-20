return function(kernel, pid)
  local System = {}

  function System.exit()
    kernel:kill(pid)
  end

  function System.execute(target, targetStream)
    return kernel:process(target, targetStream, pid)
  end

  function System.getCWD()
    return kernel:getCWD(pid)
  end

  function System.setCWD(path)
    return kernel:setCWD(pid, path)
  end

  return System
end
