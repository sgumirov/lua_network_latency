#!/bin/bash
cd src
lua main1.lua server &
sleep 1
lua main1.lua client
killall lua
cd ..