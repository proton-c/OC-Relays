-- This file would be placed in a server that would be used as a main data center server. It would be in the file location "/autorun.lua"
local component = require("component")
local event = require("event")
local serial = require("serialization")
local m = component.modem
require("term").clear()

-- Port that we're going to send and receive data with
local port = 80

-- Port for handshakes
local handshakePort = 90

m.open(port)
m.open(handshakePort)

local function handshake(msg, from)
    print("Handshake\n")
    m.send(from, handshakePort, msg)
end

print("Starting datacenter!")

while true do
    local _, _, from, inPort, _, msg = event.pull("modem_message")
    print("Got a request:")
    if inPort == handshakePort then
        handshake(msg, from)
    elseif inPort == port then
        local table = serial.unserialize(msg)
        if table.type == "test" then
            print("Test Request\n")
            table.response = "You sent "..table.value.." to the server!"
            table.tripType = "client"
            table.value = nil
            table = serial.serialize(table)
            m.send(from, port, table)
        end
    end
end
