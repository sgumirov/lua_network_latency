require('printf')
ttool=false
debug=true

if ttool then
  require('t-init') --initializes box, fills data
end

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
    con = con+1
    print("Server: connection accepted")

    local handler = function(client)
      -- make sure we don't block waiting for this client's line
      client:settimeout(10)
      -- receive the line
      local line, err = client:receive()

      --while (not err and line ~= 'exit') do
      if not err then
        print("Server: received line="..line)
        -- if there was no error, send it back to the client
        if not ttool then 
          client:send(line .. "\n")
        else
          client.send(t-get(line))
        end 
        line, err = client:receive()
      end
      if (err) then print("Server: error="..err) end
      -- done with client, close the object
      client:close()
      --print("Server: closed con")
    end
    
    local h = coroutine.create(handler)
    coroutine.resume(h, client)
    print('Server: accepted connections count: '..con) 
  end
end

--overwrite system 'tostring' function to handle nils
_tostring = tostring
tostring = function (a)
  if nil == a then return 'NIL' else return _tostring(a) end
end

function client_run(host)
  print("Client started")
  local ITER = 1000000
  -- load namespace
  local socket = require("socket")
  local con = assert(socket.tcp())
  if (host == nil) then host = "127.0.0.1" end

  print("Client: Connecting")
  if con:connect(host, 44444) then
    con:settimeout(0)
    con:setoption('tcp-nodelay', true)
    print("Client: started benchmark")
    local t_total = 0, rcvdata, err
    local req = {}
    if debug then
      req[1] = {'a', 50, 'b', 100, 'c', 400, 'd', 101, 'data', 500} 
      req[2] = {'a', 50, 'b', 100, 'c', 400, 'd', 101, 'data', 500}
    else 
      print("TODO fill req")
      os.exit(1)  
    end
    local r, rcvdata, err
    t = os.time()
--    for i=1,ITER,1 do
      for k,v in pairs(req) do
        r = table.concat(v, " ").."\n"
        if (debug) then print("Client: req='"..r.."'") end
        local s = con:send(r)
        print("Client: sent. result="..tostring(s).." waiting for response...")
        rcvdata, err = con:receive()
        print("Client: response received (e=nil?"..tostring(err==nil)..", d==nil?"..tostring(rcvdata==nil))
        if (debug) then print("Client: res="..rcvdata) end --problem is here
        local dt = os.time()-t
        if err then
          print("ERROR, recv="..rcvdata)
          break
        end
      end
      if err then break end
--    end
    t_total = t_total + dt
    if not err then
      printf("%d iterations completed in: %s ms", ITER, tostring(1000*(t_total)))
      printf("latency is: %s us", tostring(1000000*(t_total)/ITER))
      printf("random result = %s\n", tostring(res[2]))
    else
      printf("Error while executing test: %s", tostring(err))
    end
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
    coroutine.resume(client, arg[2]) --host only. port always the same
  end
end


main()
