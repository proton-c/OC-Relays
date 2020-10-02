-- This file would be placed in a server that would be used as a relay, and it would be in the location "/autorun.lua"
local component = require("component")
local event = require("event")
local serial = require("serialization")
local m = component.modem
local tunnel = component.tunnel
require("term").clear()

-- Port that we're going to send and receive data with
local port = 80

-- Port for handshakes
local handshakePort = 90

local function handshake(msg, from)
  msg.send(from, handshakePort, (msg + 50) * 2)
end

m.open(port)
m.open(handshakePort)

print("Relay starting!")

while true do
  local _,_,from,inPort,_,msg = event.pull("modem_message")
  if inPort == handshakePort and type(msg) == "number" then
    handshake(msg, from)
  elseif inPort == port or inPort == 0 then
    local table = serial.unserialize(msg)
    print("New request! Destination: "..table.tripType)
    if type(table) == "table" then
      if table.tripType == "datacenter" then
        print("Sending request to the datacenter...")
        table.clientAddress = from
        table = serial.serialize(table)
        tunnel.send(table)
      elseif table.tripType == "client" then
        print("Sending request to the client...")
        m.send(table.clientAddress, port, msg)
      end 
    end
  end
end
