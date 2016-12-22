require('printf')

local function server()
  -- load namespace
  local socket = require("socket")
  -- create a TCP socket and bind it to the local host, at any port
  local server = assert(socket.bind("*", 44444))
  -- find out which port the OS chose for us
  local ip, port = server:getsockname()
  -- print a message informing what's up
  print("Please telnet to localhost on port " .. port)
--  print("After connecting, you have 10s to enter a line to be echoed")
  local con = 0 --counter
  -- loop forever waiting for clients
  while 1 do
    -- wait for a connection from any client
    local client = server:accept()
    print("Server: connection accepted")
    
    local handler = function(client)
      -- make sure we don't block waiting for this client's line
      --client:settimeout(10)
      -- receive the line
      local line, err = client:receive()

      while (not err and line ~= 'exit') do
        -- if there was no error, send it back to the client
        client:send(line .. "\n")
        line, err = client:receive()
      end
      if (err) then print("ERROR="..err) end
      -- done with client, close the object
      client:close()
      print("Server: closed con")
    end
    
    local h = coroutine.create(handler)
    coroutine.resume(h, client)
    con = con+1
    print('accepted connection #'..con) 
  end
end

function client_run()
  print("Client started")
  local ITER = 1 --10000
  -- load namespace
  local socket = require("socket")
  local con = assert(socket.tcp())

  print("Client: Connecting")
  if con:connect("127.0.0.1", 44444) then
    con:settimeout(0)
    con:setoption('tcp-nodelay', true)
    local data = "request"
    print("Client: started benchmark")
    t = os.time()
    for i=1,ITER,1 do
      con:send(data.."\n")
      local rcvdata, err = con:receive()
      if err then
        print("ERROR, recv="..rcvdata)
      end
    end
    local dt = os.time()-t
    printf("%d iterations completed in %s ms", ITER, tostring(1000*(dt)))
  else
    print("Client: cannot connect")
  end
end

local function main()
  --main_udp()
  if arg[1] == 'server' then
    local server_coroutine = coroutine.create(server())
    coroutine.resume(server_coroutine)
  else
    local client = coroutine.create(client_run)
    coroutine.resume(client)
  end
end


main()