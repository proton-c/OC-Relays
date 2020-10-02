# OC-Relays
Framework/Concept for a "relay" system using OpenComputers in Minecraft.

Messages are sent to a "relay," which will forward the messages to a "data center."

Each relay has a corresponding "receiver" in the data center, which is a low-end computer connected to the relay via a Linked Card, that will forward the message to the main server in the data center. 

Then once the data center processes the request, the process will happen in reverse, and the response will reach the client.

Apologies in advance for any Spaghetti Code!
