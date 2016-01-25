express = require 'express'
cylon = require 'cylon'

cylon.api()

robot_config = 
  name: "test"
  connections:
    loopback: 
      adaptor: "loopback" 
    raspi: 
      adaptor: "raspi"
  devices:
    ping:
      driver: "ping"
      connection: "loopback"
    bmp180:
      driver: "bmp180"
      connection: "raspi"

  work: (my) ->
    every(20.seconds(), () ->
      console.log "Temp:"
      my.bmp180.getTemperature( (err,val) ->
        console.log err if err
        console.log val
      )
    ) 
    every(1.seconds(), () ->
      console.log "ping"
    )
    after(5.seconds(), () ->
      console.log "five more seconds..."
    )

# console.log robot_config

cylon.robot(robot_config)
	
cylon.start()
server = express()
console.log "Staring up..."
server.get '/', (req, res) ->
  res.json "Hello world"

server.listen(8081)
