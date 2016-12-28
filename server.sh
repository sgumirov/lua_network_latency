#!/bin/bash
lua="tarantool"
killall $lua
cd src
echo "IP: "
ifconfig | grep "inet "
$lua remote_table_access.lua server &
$lua remote_table_access.lua server &
cd ..