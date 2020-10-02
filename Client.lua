-- Simple example for what a client could look like using this system. The file could be named anything on the client.
local component = require("component")
local event = require("event")
local serial = require("serialization")
local m = component.modem
local fs = require("filesystem")

local file = fs.open("/home/data/address", "r")
local address = file:read(500)
file:close()

-- Port that we're going to send and receive data with
local port = 80

m.open(port)

print("Please type anything for the server!")

local data = io.read()

local table = serial.serialize({type = "test", value = data, tripType = "datacenter"})
m.send(address, port, table)

local _,_,from,port,_,msg = event.pull(5,"modem_message")

print("Response was: ")

local table = serial.unserialize(msg)

print(table.response)
