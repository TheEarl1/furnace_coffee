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
    bmp180_0:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"
    bmp180_3:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"

  work: (my) ->
    my.pca9544a.setChannel0( () ->
      my.bmp180_0.readCoefficients( (err,val) ->
        if err
          console.log err
        else
          console.log val 
        my.pca9544a.setChannel3( () ->
          my.bmp180_3.readCoefficients( (err,val) ->
            if err
              console.log err
            else
              console.log val 
          )
        ) 
      )
    )
    every(20.seconds(), () ->
      my.pca9544a.setChannel0( () ->
        my.bmp180_0.getTemperature( (err,val) ->
          if err
            console.log err
          else
            console.log "0 Temp: " + val.temp.toString() + " : " + my.bmp180_0.ac1.toString(16)
        )
      ) 
      my.pca9544a.setChannel3( () ->
        my.bmp180_3.getTemperature( (err,val) ->
          if err
            console.log err
          else
            console.log "3 Temp: " + val.temp.toString() + " : " + my.bmp180_3.ac1.toString(16)
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
