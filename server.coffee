express = require 'express'
cylon = require 'cylon'
lock = new (require 'rwlock')() 

getConfig = (bmp180) -> 
  ['ac1','ac2','ac3','ac4','ac5','ac6','b1','b2','mb','mc','md'].reduce (o, k) -> 
    o[k] = bmp180[k]
    return o
  ,{}

getCoefficients = (setChannel,bmp180) ->
  lock.writeLock 'i2c1_0x73',(release) -> 
    setChannel () ->
      bmp180.readCoefficients (err,val) ->
        if err
          console.log err
        release()

getMeasurement = (index,setChannel,bmp180) ->
      lock.writeLock 'i2c1_0x73',(release) -> 
        setChannel () ->
          bmp180.getPressure 1,(err,val) ->
            if err
              console.log err
            else
              val.time=timestamp = Math.floor(Date.now() / 1000)
              console.log index + " " + JSON.stringify(val)
              release()

#cylon.api()

robot_config = 
  name: "test"
  connections:
    raspi: 
      adaptor: "raspi"
  devices:
    pca9544a:
      driver: "pca9544a"
      connection: "raspi"
      address: "0x73"
    bmp180_0:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"
    bmp180_1:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"
    bmp180_2:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"
    bmp180_3:
      driver: "bmp180"
      connection: "raspi"
      address: "0x77"

  work: (my) ->
    getCoefficients my.pca9544a.setChannel3, my.bmp180_3
    getCoefficients my.pca9544a.setChannel2, my.bmp180_2
    getCoefficients my.pca9544a.setChannel1, my.bmp180_1
    getCoefficients my.pca9544a.setChannel0, my.bmp180_0
    every 20.seconds(), () ->
      getMeasurement 3, my.pca9544a.setChannel3, my.bmp180_3
      getMeasurement 2, my.pca9544a.setChannel2, my.bmp180_2
      getMeasurement 1, my.pca9544a.setChannel1, my.bmp180_1
      getMeasurement 0, my.pca9544a.setChannel0, my.bmp180_0

cylon.robot(robot_config)
	
cylon.start()
server = express()
server.get '/', (req, res) ->
  res.json "Hello world"

server.listen(8081)
