-- Simple example for what a client could look like using this system. The file could be named anything on the client.
local component = require("component")
local event = require("event")
local serial = require("serialization")
local m = component.modem
local fs = require("filesystem")

-- Port that we're going to send and receive data with
local port = 80

-- Port for handshakes
local handshakePort = 90

local function handshake()
    print("Please enter a random number for the handshake:")
    local num = io.read()
    if type(num) ~= "number" then num = 60 end
    local calc = (num + 50) * 2
    m.open(handshakePort)
    m.broadcast(handshakePort, num)
    local _, _, from, inPort, _, msg = event.pull(5, "modem_message")
    if msg == calc then
        local file = fs.open("/home/data/address", "w")
        file:write(from)
        file:close()
    elseif msg == nil then
        print("Handshake failed! Timeout.")
    else
        print("Handshake failed! Relay returned incorrect calculation.")
    end
    m.close(handshakePort)
end

if fs.exists("/home/data") == false then
    fs.makeDirectory("/home/data")
    handshake()
elseif fs.exists("/home/data/address") == false then
    handshake()
end

local file = fs.open("/home/data/address", "r")
local address = file:read(500)
file:close()

m.open(port)

print("Please type anything for the server!")

local data = io.read()

local table = serial.serialize({type = "test", value = data, tripType = "datacenter"})
m.send(address, port, table)

local _,_,from,port,_,msg = event.pull(5,"modem_message")

print("Response was: ")

local table = serial.unserialize(msg)

print(table.response)
