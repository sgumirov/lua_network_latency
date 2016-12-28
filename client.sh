#!/bin/bash
lua="tarantool"
killall $lua
cd src
$lua remote_table_access.lua client 192.168.3.100
cd ..