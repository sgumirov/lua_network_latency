ttool=false
debug=true
PORT=44444
REPEATS=1
if debug then ITER=1 else ITER = 10000 end
require('t-init')

socket=require('socket')
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

--error print
local eprint = function (s)
  _print(s)
end

function server_run(prt)
  if prt ~= nil then PORT = prt end
  eprint("Starting server at port: "..PORT)  
  local result = socket.tcp_server('0.0.0.0', PORT, function(client)
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
  if nil == result then 
    eprint("Server: cannot bind to "..PORT)
    os.exit(-1)
  end
end

function main()
  server_run(arg[1])
end

main()
