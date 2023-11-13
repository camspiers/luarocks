package.path = package.path .. ";./lua/?.lua"

local luarocks = require("rocks.luarocks")

luarocks.build()
