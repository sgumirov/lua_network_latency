MAX = 1000 --number of values in tables

math.randomseed(os.time())

--initialize and fill datamodel tables to use for dereferencing expressions
--this function is used from shard_main.lua, so should be on top
local function init_db()
  box.cfg{
    wal_mode = "none",
  }
  local a,b,c,d,data
  a=box.schema.space.create('a')
  b=box.schema.space.create('b')
  c=box.schema.space.create('c')
  d=box.schema.space.create('d')
  data=box.schema.space.create('data')
  a:create_index('primary', {parts={1, 'STR'}})
  b:create_index('primary', {parts={1, 'STR'}})
  c:create_index('primary', {parts={1, 'STR'}})
  d:create_index('primary', {parts={1, 'STR'}})
  data:create_index('primary', {parts={1, 'STR'}})
  for i = 1, MAX, 1 do
    box.space.a:insert{tostring(i), string.char(string.byte('a')+math.random(4)-1)}
    box.space.b:insert{tostring(i), string.char(string.byte('a')+math.random(4)-1)}
    box.space.c:insert{tostring(i), string.char(string.byte('a')+math.random(4)-1)}
    box.space.d:insert{tostring(i), tostring(math.random(MAX))}
    box.space['data']:insert{tostring(i), tostring(MAX-i+1)}
  end
end

local function memget(table_name, row)
  --printf("get(%s, %s)=", table_name, row)
  local tmp
  row = tonumber(row)
  if     table_name == 'a' then tmp=a[row]
  elseif table_name == 'b' then tmp=b[row]
  elseif table_name == 'c' then tmp=c[row]
  elseif table_name == 'd' then tmp=d[row]
  elseif table_name == 'data' then tmp=data[row]
  end
  --print(tmp)
  return tmp
end

local function init_inmem()
  a={}
  b={}
  c={}
  d={}
  data={}
  for i = 1, MAX, 1 do
    a[i] = string.char(string.byte('a')+math.random(4)-1)
    b[i] = string.char(string.byte('a')+math.random(4)-1)
    c[i] = string.char(string.byte('a')+math.random(4)-1)
    d[i] = tostring(math.random(MAX))
    data[i] = tostring(MAX-i+1)
  end
  return a,b,c,d,data
end

if ttool then
  init_db()
else
  init_inmem()
end

local function dbget(table_name, row)
  printf("get_db(%s; %s)\n", table_name, row)
  return box.space[table_name]:select(tostring(row))[1][2]
end

function tget(l)
  local k = {}
  for word in l:gmatch("%w+") do table.insert(k, word) end
  local ret = {}
  local tname
  if ttool then
    for i=1,#k,2 do
      tname = k[i]
      table.insert(ret, dbget(tname, k[i+1]))
    end
  else
    for i=1,#k,2 do
      tname = k[i]
      table.insert(ret, memget(tname, k[i+1]))
    end
  end
  return table.concat(ret, " ")
end

