-- CONFIG
ttool=false
local debug=true
PORT=44444
if debug then ITER=1 else ITER = 1000000 end
-- END CONFIG

-- init
fiber=require('fiber')
socket=require('socket')
require('printf')
require('t-init') --initializes box, fills data
-- end init

local con = 0 --con counter

local function readline(sock)
  return sock:read('\n')
end

local function trim12(s)
  if s == nil then return nil end
  local from = s:match"^%s*()"
  return from > #s and "" or s:match(".*%S", from)
end

local function server()
  print("Starting server at port: "..PORT)  
  socket.tcp_server('0.0.0.0', PORT, function(client)
    con = con+1
    print("Server: connection accepted")
    -- receive the line
    local line = readline(client)
    print(line)

    while (line ~= nil and line ~= 'exit') do
    --if not err then
      print("Server: received line="..line)
      -- if there was no error, send it back to the client
      local res = tget(line)
      print("Server response: ")
      print(res)
      client:send(res)
      line = readline(client)
      if 'exit' == trim12(line) then print("Server: exit -> closing client") break end
    end
    if line == nil then print("Server: error="..client:error()) end
    -- done with client, close the object
    --client:close()
    print("Server: closed con")
    print('Server: accepted connections count: '..con) 
  end)
end

--overwrite system 'tostring' function to handle nils
_tostring = tostring
tostring = function (a)
  if nil == a then return 'NIL' else return _tostring(a) end
end

-- =============== socket helpers =================== --
function tcp_connect(host, port)
  local ainfo = box.socket.getaddrinfo(host, port, nil, { protocol = 'tcp' })
  if ainfo == nil then
    error( box.errno.strerror(box.errno()) )
  end
  for i, a in pairs(ainfo) do
    local s = box.socket(a.family, a.type, a.protocol)
    if s == nil then
      error( box.errno.strerror(box.errno()) )
    end

    s:nonblock(true)

    if s:sysconnect(a.host, a.port) then
      return s
    end
  end

  error("Can't connect to " .. host .. ":" .. port)
end
--end socket helpers--

local function client_run(host)
  print("Client started")
  if host == "" or host == nil then host = "127.0.0.1" end

  print("Client: Connecting")
  local con = socket.tcp_connect(host, PORT)
  if not con:error() then
    --con:setoption('tcp-nodelay', true)
    print("Client: started benchmark")
    local t_total = 0
    local req = {}
    if debug then
      req[1] = {'a', 50, 'b', 100, 'c', 400, 'd', 101, 'data', 500} 
      req[2] = {'a', 50, 'b', 100, 'c', 400, 'd', 101, 'data', 500}
      req[3] = {'exit'}
    else 
      print("TODO fill req")
      os.exit(1)  
    end
    local r, line, err
    t = os.time()
    for i=1,ITER,1 do
      for k,v in pairs(req) do
        r = table.concat(v, " ").."\n"
        if (debug) then print("Client: req='"..r.."'") end
        local s = con:send(r)
        print("Client: sent. result="..tostring(s).." waiting for response...")
        line = con:readline(con) --con:receive()
        print("Client: response received (err?"..tostring(line==nil)..")")
        if debug and not err then print("Client: response="..line) end --problem is here
        local dt = os.time()-t
        if err then
          print("Client ERROR="..con:error())
          break
        end
      end
      if err then break end
    end
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
  if arg[1] == 'server' then
    server()
  else
    client_run(arg[2])
  end
end


main()
