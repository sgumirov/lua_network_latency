#!/bin/bash
lua="tarantool"
killall $lua
cd src/server
ifconfig | grep "inet " | grep "eth"
$lua server.lua 44444
cd ../..