eset:       Resets the SCK
version:     Shows versions and Hardware ID
rcause:      Show last reset cause (debug)
outlevel:    Shows/sets output level: outlevel [0:silent, 1:normal, 2:verbose]
help:        Duhhhh!!
pinmux:      Shows SAMD pin mapping status
flash:       Shows and manage flash memory state [no-param -> info] [-format (be careful)] [-dump sect-num (0-2040)] [-sector sect-num] [-recover sect-num/all net/sd]
sensor:      Shows/sets sensor state or interval: sensor sensor-name [-enable or -disable] [-interval interval(seconds)]
monitor:     Continously read sensor: monitor [-sd] [-notime] [-noms] [sensorName[,sensorNameN]]
debug:       Toggle debug messages: debug [-sdcard] [-flash] [-speed] [-serial]
read:        Reads sensor: read [sensorName]
control:     Control sensor: control [sensorName] [command]
free:        Shows the amount of free RAM memory
i2c:         Search the I2C bus for devices
power:       Controls/shows power config: power [-info (extra info)] [-batcap mAh] [-otg on/off] [-charge on/off] [-sleep min (0-disable)]
config:      Shows/sets configuration: config [-defaults] [-mode sdcard/network] [-pubint seconds] [-readint seconds] [-wifi "ssid" ["pass"]] [-token token] [-sanity(reset) on/off]
esp:         Controls or shows info from ESP: esp [-on -off -sleep -wake -reboot -flash]
netinfo:     Shows network information
time:        Shows/sets date and time: time [epoch time] [-sync]
hello:       Sends MQTT hello to platform
shell:       Shows or sets shell mode: shell [-on] [-off]
publish:     Publish custom mqtt message: mqtt ["topic" "message"]
offline:     Configure offline periods and WiFi retry interval: [-retryint seconds] [-period start-hour end-hour (UTC 0-23)]
mqttsrv:     Configure mqtt server address and port: [-host serverName] [-port portNum]
ntpsrv:      Configure ntp server address and port: [-host serverName] [-port portNum]
sleep:       Send the kit to sleep
led:         Changes led brightness: led [percent]
file:        SD card file operations: [-ls] [-rm filename] [-less filename] [-allcsv]
