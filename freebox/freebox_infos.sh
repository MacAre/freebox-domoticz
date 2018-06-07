#!/bin/bash
cd /home/pi/freebox
# Domoticz server **A MODIFIER**
DOMOTICZ_SERVER="192.168.1.145:8080"
# Freebox Server idx
FREEBOX_FW_IDX="6"
FREEBOX_UPTIME_IDX="5"
FREEBOX_ATM_UP_IDX="65"
FREEBOX_ATM_DOWN_IDX="64"
FREEBOX_DISKSPACE_IDX="57"
FREEBOX_SERIAL_HDD_IDX="326"
FREEBOX_MODELE_HDD_IDX="327"
FREEBOX_TEMP_CPUB_IDX="52"
FREEBOX_REC_EN_COURS_IDX="61"
FREEBOX_EMIS_EN_COURS_IDX="60"
FREEBOX_BANDWIDTH_DOWN_IDX="63"
FREEBOX_BANDWIDTH_UP_IDX="62"
FREEBOX_SERIAL_IDX="333"
FREEBOX_FEC_DOWN_IDX="334"
FREEBOX_CRC_DOWN_IDX="335"
FREEBOX_FEC_UP_IDX="336"
FREEBOX_CRC_UP_IDX="337"
FREEBOX_TEMP_CPUM_IDX="338"
FREEBOX_TEMP_SW_IDX="339"
FREEBOX_FAN_RPM_IDX="340"
FREEBOX_IPV4_IDX="341"
FREEBOX_IPV6_IDX="342"

# Password admin domoticz  **A MODIFIER** (inutile selon les configurations domoticz)
pwd=toto
#
function show_time () {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    echo "$day"%20jours%20"$hour"%20heures%20"$min"%20mn%20"$sec"%20secs
}
# Valeurs obtenu de votre freebox **A MODIFIER**
MY_APP_ID="Domoticz.app"
MY_APP_TOKEN="INSCRIRE_LE_TOKEN_ICI"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get xDSL data
answer=$(call_freebox_api '/connection/xdsl')
#echo " answer : ${answer} "
#echo " "
# extract max upload xDSL rate
uptime=$(get_json_value_for_key "$answer" 'result.status.uptime')
uptimefreebox=$(show_time ${uptime})
echo "Uptime : ${uptimefreebox} "

atm_up_rate=$(get_json_value_for_key "$answer" 'result.up.maxrate')
atm_up_rate=$(awk "BEGIN {printf \"%.1f\",${atm_up_rate}/1000}")
#up_max_rate=$(echo "$up_max_rate%20Mb/s")
atm_down_rate=$(get_json_value_for_key "$answer" 'result.down.rate')
atm_down_rate=$(awk "BEGIN {printf \"%.1f\",${atm_down_rate}/1000}")
#down_max_rate=$(echo "$down_max_rate%20Mb/s")

echo "Rate ATM down xDSL rate: ${atm_down_rate} "
echo "Rate ATM up xDSL: ${atm_up_rate} "

#Les FEC et CRC donnent en général une bonne indication sur un problème de qualité de ligne 
#FEC down :
fecd=$(get_json_value_for_key "$answer" 'result.down.fec')
echo "FEC Down : ${fecd}"
#CRC down :
crcd=$(get_json_value_for_key "$answer" 'result.down.crc')
echo "CRC Down : ${crcd}"
#FEC up :
fecu=$(get_json_value_for_key "$answer" 'result.up.fec')
echo "FEC Up : ${fecu}"
#CRC up :
crcu=$(get_json_value_for_key "$answer" 'result.up.crc')
echo "CRC Up : ${crcu}"

echo "************ CONNECTION ************"
answer=$(call_freebox_api '/connection')
debit_reception=$(get_json_value_for_key "$answer" 'result.rate_down')
debit_reception=$(awk "BEGIN {printf \"%.1f\",${debit_reception}/1000}")

debit_emission=$(get_json_value_for_key "$answer" 'result.rate_up')
debit_emission=$(awk "BEGIN {printf \"%.1f\",${debit_emission}/1000}")

bande_passante_maxi_reception=$(get_json_value_for_key "$answer" 'result.bandwidth_down')
bande_passante_maxi_reception=$(awk "BEGIN {printf \"%.1f\",${bande_passante_maxi_reception}/1000000}")

bande_passante_maxi_emission=$(get_json_value_for_key "$answer" 'result.bandwidth_up')
bande_passante_maxi_emission=$(awk "BEGIN {printf \"%.1f\",${bande_passante_maxi_emission}/1000000}")

# ipv4 ext: 
ipv4=$(get_json_value_for_key "$answer" 'result.ipv4')
echo "IPv4 EXT : ${ipv4}"
# ipv6 ext :
ipv6=$(get_json_value_for_key "$answer" 'result.ipv6')
echo "IPV6 : ${ipv6}"

echo "************ SYSTEM ************"

answer=$(call_freebox_api '/system')
#echo " answer : ${answer} "
#uptimefreebox=$(get_json_value_for_key "$answer" 'result.uptime')
fwfreebox=$(get_json_value_for_key "$answer" 'result.firmware_version')
num_serie_fbx=$(get_json_value_for_key "$answer" 'result.serial')
echo "Num Serie : ${num_serie_fbx} "
#echo "Uptime : ${uptimefreebox} "
echo "Firmware : ${fwfreebox} "

# Température CPUb: 
temperature_cpub=$(get_json_value_for_key "$answer" 'result.temp_cpub')
echo "Temperature CPU B : ${temperature_cpub}"
# Température CPUm: 
temperature_cpum=$(get_json_value_for_key "$answer" 'result.temp_cpum')
echo "Temperature CPU M : ${temperature_cpum}"
# Température SW: 
temperature_sw=$(get_json_value_for_key "$answer" 'result.temp_sw')
echo "Temperature SW : ${temperature_sw}"
# Vitesse Ventilateur: 
fan_rpm=$(get_json_value_for_key "$answer" 'result.fan_rpm')
echo "Fan RPM : ${fan_rpm}"

echo "************ HDD ************"
answer=$(call_freebox_api '/storage/disk')
answer=$(echo ${answer} | sed -e "s/\[//g" | sed -e "s/\]//g")
#echo " answer : ${answer} "
freediskspace=$(get_json_value_for_key "$answer" 'result.partitions.free_bytes')
freediskspace=$(echo $((${freediskspace}/1024/1024)))
freediskspace=$(awk "BEGIN {printf \"%.2f\",${freediskspace}/1024}")
#freediskspace=$(echo "${freediskspace}%20Go")
echo "Free space HD : ${freediskspace} "

num_serie=$(get_json_value_for_key "$answer" 'result.serial')
modele=$(get_json_value_for_key "$answer" 'result.model')

#
#Envoi des valeurs vers les devices virtuels
# Send data to Domoticz
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_FW_IDX&nvalue=0&svalue=$fwfreebox"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_UPTIME_IDX&nvalue=0&svalue=$uptimefreebox"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_ATM_UP_IDX&nvalue=0&svalue=$atm_up_rate"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_ATM_DOWN_IDX&nvalue=0&svalue=$atm_down_rate"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_DISKSPACE_IDX&nvalue=0&svalue=$freediskspace"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_SERIAL_HDD_IDX&nvalue=0&svalue=$num_serie"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_MODELE_HDD_IDX&nvalue=0&svalue=$modele"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_TEMP_CPUB_IDX&nvalue=0&svalue=$temperature_cpub"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_REC_EN_COURS_IDX&nvalue=0&svalue=$debit_reception"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_EMIS_EN_COURS_IDX&nvalue=0&svalue=$debit_emission"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_BANDWIDTH_UP_IDX&nvalue=0&svalue=$bande_passante_maxi_emission"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_BANDWIDTH_DOWN_IDX&nvalue=0&svalue=$bande_passante_maxi_reception"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_SERIAL_IDX&nvalue=0&svalue=$num_serie_fbx"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_FEC_DOWN_IDX&nvalue=0&svalue=$fecd"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_CRC_DOWN_IDX&nvalue=0&svalue=$crcd"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_FEC_UP_IDX&nvalue=0&svalue=$fecu"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_CRC_UP_IDX&nvalue=0&svalue=$crcu"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_TEMP_CPUM_IDX&nvalue=0&svalue=$temperature_cpum"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_TEMP_SW_IDX&nvalue=0&svalue=$temperature_sw"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_FAN_RPM_IDX&nvalue=0&svalue=$fan_rpm"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_IPV4_IDX&nvalue=0&svalue=$ipv4"
curl --silent -s -i -H  "Accept: application/json"  "http://login_password@admin_password@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$FREEBOX_IPV6_IDX&nvalue=0&svalue=$ipv6"
