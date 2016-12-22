local function main_udp()
  --
  -- apt install lua5.2 lua-socket
  --
  
  local socket = require("socket")
  local udp = assert(socket.udp())
  local data
  
  udp:settimeout(1)
  assert(udp:setsockname("*",0))
  assert(udp:setpeername("example.com",1234))
  
  for i = 0, 2, 1 do
    assert(udp:send("ping"))
    data = udp:receive()
    if data then
      break
    end
  end
  
  
  if data == nil then
    print("timeout")
  else
    print(data)
  end
end

local function main_tcp()
  -- load namespace
  local socket = require("socket")
  -- create a TCP socket and bind it to the local host, at any port
  local server = assert(socket.bind("*", 44444))
  -- find out which port the OS chose for us
  local ip, port = server:getsockname()
  -- print a message informing what's up
  print("Please telnet to localhost on port " .. port)
  print("After connecting, you have 10s to enter a line to be echoed")
  local con = 0 --counter
  -- loop forever waiting for clients
  while 1 do
    -- wait for a connection from any client
    local client = server:accept()
    
    local handler = function(client)
      -- make sure we don't block waiting for this client's line
      client:settimeout(10)
      -- receive the line
      local line, err = client:receive()

      while (not err and line ~= 'exit') do
        -- if there was no error, send it back to the client
        client:send(line .. "\n")
        line, err = client:receive()
      end
      -- done with client, close the object
      client:close()
    end
    
    local h = coroutine.create(handler)
    coroutine.resume(h)
    con = con+1
    print('accepted connection #'..con) 
  end
end


local function main()
  --main_udp()
  local run = coroutine.create(main_tcp())
  coroutine.resume(run)
  
end


main()