local component = require("component")
local event = require("event")
local serial = require("serialization")
local m = component.modem
local tunnel = component.tunnel
local fs = require("filesystem")
local term = require("term")

-- Port that we're going to send and receive data with
local port = 80

-- Port for handshakes
local handshakePort = 90

local function handshake()
    m.open(handshakePort)
    
    local cont = true

    while cont do
        print("Bruh")
        m.broadcast(handshakePort, 96)
        local _, _, from, port, _, msg = event.pull(5, "modem_message")
        if port == handshakePort and msg == 96 then
            if fs.exists("/data/address") then fs.remove("/data/address") end
            local file = fs.open("/data/address", "w")
            file:write(from)
            file:close()
            cont = false
        end
    end

    m.close(handshakePort)
end

if fs.exists("/data") == false then
    fs.makeDirectory("/data")
    handshake()
elseif fs.exists("/data/address") == false then
    handshake()
end

local file = fs.open("/data/address", "r")
local dataCenter = file:read(500)
file:close()

term.clear()

print("Receiver starting!")

m.open(port)

while true do
    local _,_,from,_,_,msg = event.pull("modem_message")
    local table = serial.unserialize(msg)
    if table.tripType == "datacenter" then
        print("Sending request to the datacenter...")
        m.send(dataCenter, port, msg)
    elseif table.tripType == "client" then
        print("Sending request to the relay...")
        table = serial.serialize(table)
        tunnel.send(table)
    end
end