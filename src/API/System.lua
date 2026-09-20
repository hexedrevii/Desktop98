return function(kernel, pid)
  local System = {}

  function System.exit()
    kernel:kill(pid)
  end

  function System.execute(target, targetStream, args)
    return kernel:process(target, args, targetStream, pid)
  end

  function System.uname()
    local info = {}
    for key, value in pairs(kernel.utsname) do
      info[key] = value
    end

    return info
  end

  function System.getenv(name)
    local process = kernel:getprocess(pid)
    if process then
      return process.env[name]
    end

    return nil
  end

  function System.setenv(name, value)
    local process = kernel:getprocess(pid)
    if process then
      process.env[name] = value
      return true
    end

    return false, "No process by PID " .. pid .. " exists."
  end

  function System.getCWD()
    return kernel:getCWD(pid)
  end

  function System.setCWD(path)
    return kernel:setCWD(pid, path)
  end

  return System
end
