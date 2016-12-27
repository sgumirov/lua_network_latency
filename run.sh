#!/bin/bash
lua="lua5.1"
cd src
$lua remote_table_access.lua server &
sleep 1
$lua remote_table_access.lua client
killall $lua
cd ..