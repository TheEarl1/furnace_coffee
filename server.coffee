express = require 'express'
cylon = require 'cylon'

cylon.api()

bob = 
  name: "test"
  connections:
    loopback: 
      adaptor: "loopback" 
  devices:
    ping:
      driver: "ping"

  work: (my) ->
    every(1.seconds(), () ->
      console.log "ping"
    )
    after(5.seconds(), () ->
      console.log "five more seconds..."
    )

console.log bob

cylon.robot(bob)
	
cylon.start()
server = express()
console.log "Staring up..."
server.get '/', (req, res) ->
  res.json "Hello world"

server.listen(8081)
