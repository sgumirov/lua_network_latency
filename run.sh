#!/bin/bash
cd src
lua main1.lua server &
lua main1.lua client
killall lua
cd ..