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
    pca9544a:
      driver: "pca9544a"
      connection: "raspi"
      address: "0x73"
    bmp1801:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"
    bmp1802:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"

  work: (my) ->
    every(20.seconds(), () ->
      my.pca9544a.setChannel0( () ->
        my.bmp1801.getTemperature( (err,val) ->
          if err
            console.log err
          else
            console.log "0 Temp: " + val.temp.toString()
        )
      ) 
    )
    every(20.seconds(), () ->
      my.pca9544a.setChannel3( () ->
        my.bmp1802.getTemperature( (err,val) ->
          if err
            console.log err
          else
            console.log "3 Temp: " + val.temp.toString()
        )
      ) 
    )
    every(5.seconds(), () ->
      console.log "ping"
    )

# console.log robot_config

cylon.robot(robot_config)
	
cylon.start()
server = express()
console.log "Staring up..."
server.get '/', (req, res) ->
  res.json "Hello world"

server.listen(8081)
