#!/bin/bash

# Required programs installed
# - lm_sensors

# Script path necessary for proper file mapping
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${SCRIPTPATH}/settings
# Temperature variables declaration

varTempCore0=$(sensors | awk '/Core 0/{print $3}' | sed 's/+//;s/°C//;s/.0//')
varTempCore1=$(sensors | awk '/Core 1/{print $3}' | sed 's/+//;s/°C//;s/.0//')
varTempCore2=$(sensors | awk '/Core 2/{print $3}' | sed 's/+//;s/°C//;s/.0//')
varTempCore3=$(sensors | awk '/Core 3/{print $3}' | sed 's/+//;s/°C//;s/.0//')

# Set severity to -1
severity="-1"

# Main part of script

function checkTemp () {
for variable in $varTempCore0 $varTempCore1 $varTempCore2 $varTempCore3
#severity     0 [OK]     1 [WARN]     2 [CRITICAL]
do
	if [ $variable -ge $varTempCrit ] ; then
		# CRITICAL
		#echo "Critical temp (${variable})"
		currentSeverity=2
		if [ $currentSeverity -gt $severity ] ; then severity=$currentSeverity ; titleSuffix="CRITICAL" ; fi
	fi
	if [ $variable -ge $varTempWarn ] && [ $variable -lt $varTempCrit ] ; then
		# WARNING
		#echo "Warning temp (${variable})"
		currentSeverity=1
		if [ $currentSeverity -gt $severity ] ; then severity=$currentSeverity ; titleSuffix="WARNING" ; fi
	fi
	if [ $variable -lt $varTempWarn ] ; then
		# TEMPERATURE OK
		#echo "OK temp (${variable})"
		currentSeverity=0
		if [ $currentSeverity -gt $severity ] ; then severity=$currentSeverity ; fi
	fi
done
}

#Call the checkTemp function
checkTemp

echo SEVERITY $severity

# Send Pushover notification, if temperature threshold limit is on WARNING or CRITICAL level.
if [ ${severity} -gt 0 ] ; then
	source ${SCRIPTPATH}/pushover.sh
        varTitle="${hostname} - temperature monitor - ${titleSuffix}"
        varMessage="CPU0 - temp: ${varTempCore0}°C   CPU1 - temp: ${varTempCore1}°C   CPU2 - temp: ${varTempCore2}°C   CPU3 - temp: ${varTempCore3}°C"
	curlPushover
fi
