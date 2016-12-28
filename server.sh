#!/bin/bash
lua="tarantool"
killall $lua
cd src
echo "IP: "
ifconfig | grep "inet "
$lua remote_table_access.lua server 44444 &
$lua remote_table_access.lua server 55555 &
cd ..