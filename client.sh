#!/bin/bash
lua="tarantool"
#killall $lua
cd src
$lua remote_table_access.lua client 127.0.0.1 44444
cd ..