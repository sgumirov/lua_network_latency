-- CONFIG
ttool=true
local debug=false
PORT=44444
REPEATS=1
if debug then ITER=1 else ITER = 10000 end
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

_print = print
print = function (s)
  if debug then _print(s) end
end

eprint = function (s)
  print(s)
end

local function server()
  eprint("Starting server at port: "..PORT)  
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
      client:send(res.."\n")
      line = readline(client)
      if 'exit' == trim12(line) then print("Server: exit -> closing client") break end
    end
    if line == nil then eprint("Server: error="..client:error()) end
    -- done with client, close the object
    --client:close()
    eprint("Server: closed con")
    eprint('Server: accepted connections count: '..con) 
  end)
end

--overwrite system 'tostring' function to handle nils
_tostring = tostring
tostring = function (a)
  if nil == a then return 'NIL' else return _tostring(a) end
end

local function client_run(host)
  eprint("Client started")
  if host == "" or host == nil then host = "127.0.0.1" end

  print("Client: Connecting")
  local con = socket.tcp_connect(host, PORT)
  if not con:error() then
    --con:setoption('tcp-nodelay', true)
    local t_total = 0
    local req = {}
    --[[if not debug then
      req[1] = {'a', 50, 'b', 100, 'c', 400, 'd', 101, 'data', 500} 
      req[2] = {'a', 50, 'b', 100, 'c', 400, 'd', 101, 'data', 500}
      req[3] = {'exit'}
    else]]-- 
      local rndtable = function()
        --todo add 'data' table
        return string.char(string.byte('a')+math.random(4)-1) 
      end
      local rndindex = function()
        return math.random(MAX) 
      end
      eprint("Client: benchmark test preparation")
      local t = os.clock()
      for i=1,ITER,1 do
        --req[i] = {rndtable(), rndindex(), rndtable(), rndindex(), rndtable(), rndindex(), rndtable(), rndindex()}
        req[i] = {rndtable(), rndindex()}
      end
      print("SIZE="..table.getn(req[1]))
      req[ITER+1]={'exit'}
      t = os.clock()-t
      printf("Client: benchmark test preparation FINISHED in %s ns\n", tostring(1000000000*t))
    --end
    eprint("Client: started benchmark")
    local r, line, err, dt=0
    t = os.clock()
    for i=1,REPEATS,1 do
      for k,v in pairs(req) do
        r = table.concat(v, " ").."\n"
        if (debug) then print("Client: req='"..trim12(r).."'") end
        local s = con:send(r)
        print("Client: sent. result="..tostring(s).." waiting for response...")
        line = readline(con) --con:receive()
        print("Client: response received (err?"..tostring(line==nil)..")")
        if debug and not err then print("Client: response="..trim12(line)) end
        if err then
          eprint("Client ERROR="..con:error())
          break
        end
      end
      --if err then break end
    end
    t_total = os.clock()-t
    if not err then
      printf("%d iterations (req length=%d) completed in: %s ms\n", ITER, #(req[1])/2, tostring(1000*(t_total)))
      printf("latency is: %s ns\n", tostring(1000000000*(t_total)/ITER))
    else
      eprint("Error while executing test: %s", tostring(err))
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
