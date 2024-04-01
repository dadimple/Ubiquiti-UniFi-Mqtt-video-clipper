#!/bin/bash


# Save a videoclip at a specific timestamp from a camera recorded on a Ubiquiti UniFi Cloudkey. 
# The timestamp is obtained via MQTT (epoch time, example 1711964257). The recording time 
# before and after the timestamp can be set. 
# This script should be scheduled every minute. Therefore, a maximum of one clip per minute can be saved.

# For the purpose of testing the script:
# Publish persistent:  mosquitto_pub -r -h <BrokerIP> -m 1711964257 -t topic/clip
# Read:                mosquitto_sub -h <BrokerIP> -t topic/clip -C 1 -W 1
# Clear persistent:    mosquitto_pub -h <BrokerIP> -r -n -t topic/clip

### Configuration
UnifiUsername="account"				# UniFi account
UnifiPassword="password"			# password	
UnifiProtectServer="https://192.168.x.y"	# cloudkey IP		
CameraID="68..................fa"		# ID camera (Lookup in web browser url of UniFy Protect when viewing cam)
Storagepad="/volume1/seismic"			# Storage location
Before=10					# tijd in sec before timestamp
After=20					# tijd in sec after timestamp
BrokerIP="192.168.a.b"				# IP adres MQTT broker
MQTTtopic="topic/clip"				# MQTT topic 
CamName="Camera-1"				# Filename suffix
sleep 30					# wait time to be sure clip is stored.
CookiePath="/tmp/cookies.txt"

### Get  timestamp via MQTT
mqttdata=$(mosquitto_sub -t $MQTTtopic -C 1 -W 1 -h $BrokerIP)
echo "mqtt data: $mqttdata"
if [ -z "$mqttdata" ]
then
	echo "no data"
	exit 0
fi

timestamp=$(echo $mqttdata | cut -d"_" -f1)
echo "timestamp: $timestamp."

### calculate time-range
start=$(($timestamp-$Before))
start=$(($start*1000))
end=$(($timestamp+$After))
end=$(($end*1000))

### assemble filename
file=$(date -d @$timestamp +"%y%m%d-%H%M%S")
file="$file-$CamName"

echo $start
echo $end
echo "file: $file.mp4"

### Getting the Cookie into the jar
curl -X POST "$UnifiProtectServer/api/auth/login" -H "Content-Type: application/json" --insecure -d '{"username":"'$UnifiUsername'", "password":"'$UnifiPassword'"}' -c "$CookiePath" 2>&1 -k --silent > /dev/null

### Store videoclip
curl "$UnifiProtectServer/proxy/protect/api/video/export?camera=$CameraID&start=$start&end=$end" -H 'Cookie: TOKEN=' --cookie $CookiePath --cookie-jar $CookiePath -H 'Upgrade-Insecure-Requests: 1'  -k --silent --output $Storagepad/$file.mp4

## remove last mgtt message
mosquitto_pub -r -n -t $MQTTtopic -h $BrokerIP




