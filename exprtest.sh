#!/bin/bash
lua="tarantool"
#killall $lua
cd src
$lua main.lua 127.0.0.1 44444
#$lua client.lua 127.0.0.1 44444
cd ..
