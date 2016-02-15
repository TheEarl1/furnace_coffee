cylon = require 'cylon'
lock = new (require 'rwlock')()

htu21d = new (require 'htu21d-i2c')()
graphite = (require 'graphite').createClient('plaintext://web01:2003/')

prefix = 'stats.hvacpi.sensors.'

getDualMeasurement = (index,setChannel,bmp180) ->
  lock.writeLock 'i2c1_0x73',(release) -> 
    setChannel () ->
      bmp180.getPressure 1,(err,val) ->
        if err
          console.log err
        else
          htu21d.readTemperature (temp2) ->
            htu21d.readHumidity (humidity) ->
              val[prefix + index + '.temp2'] = temp2
              val[prefix + index + '.humid'] = humidity
              val[prefix + index + '.temp'] = val.temp
              val[prefix + index + '.press'] = val.press
              delete val.press
              delete val.temp
              console.log index + " " + JSON.stringify(val)
              graphite.write val, (err) ->
                if err
                  console.log err
              release()

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
              val[prefix + index + '.temp'] = val.temp
              val[prefix + index + '.press'] = val.press
              delete val.press
              delete val.temp
              console.log JSON.stringify(val)
              graphite.write val, (err) ->
                if err
                  console.log err
              release()

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
    getMeasurement 3, my.pca9544a.setChannel3, my.bmp180_3
    getMeasurement 2, my.pca9544a.setChannel2, my.bmp180_2
    getDualMeasurement 1, my.pca9544a.setChannel1, my.bmp180_1
    getDualMeasurement 0, my.pca9544a.setChannel0, my.bmp180_0
    every 60.seconds(), () ->
      getMeasurement 3, my.pca9544a.setChannel3, my.bmp180_3
      getMeasurement 2, my.pca9544a.setChannel2, my.bmp180_2
      getDualMeasurement 1, my.pca9544a.setChannel1, my.bmp180_1
      getDualMeasurement 0, my.pca9544a.setChannel0, my.bmp180_0

cylon.robot(robot_config)
	
cylon.start()
