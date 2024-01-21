#!/bin/bash

################################################################################
### MacOS - Screen Saver - battery saver
### This script will turn off screen after "idletime"
### It will not block system, it just turn off screen
### When you move mouse or touch keyboard it will restore brightness
################################################################################

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

### 
### Setup timeout to dark screen
###
idletime="30"


###
cd $SCRIPT_DIR

###
### First of all 
### Check if its working or not
### if yes - exit
###
if [ -f "working" ]
    then
    exit 1
    fi

###
### Check if brightness is installed
### if not - install this
###
if [ ! -f packages.ok ]
    then
    echo "I will check if brightness is installed..."
    i=`brew list brightness | grep 'bin/brightness' | wc -l | xargs`
    if [ "$i" != "1" ]
	then
	echo "I will install brightness..."
	brew install brightness
	touch packages.ok
	else
	echo "It's installed :)"
	touch packages.ok
	fi
    fi

## check crontab
exists=`crontab -l | grep 'screensaver.sh' | wc -l | xargs`
if [ "$exists" != "1" ]
    then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!                                    !!"
    echo "!!          !!! ALERT !!!             !!"
    echo "!!                                    !!"
    echo "!! Add this to thecrontab             !!"
    echo "!!                                    !!"
    echo "!! # type:                            !!"
    echo "!! crontab -e                         !!"
    echo "!! # and add this line bellow:        !!"
    echo "!!                                    !!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo ""
    echo "* * * * * ${SCRIPT_DIR}/screensaver.sh > ${SCRIPT_DIR}/screensaver.log 2>&1"
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    fi

###
### Set script as working
###
touch working


###
### Function to turn screen on
###
function setlight {
    for i in $(seq 0 0.08 1);
    do
	brightness $i
	#sleep 0.1
	#echo $i
    done
    brightness 1
}

###
### Function to turn screem off
###
function setdark {
    for i in $(seq 1 -0.08 0);
    do
	brightness $i
	#echo $i
    done
    brightness 0
}



laststate="L"
echo "Start"

###
### Main loop
###
while true
    do
    idl=$"`ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}'`"
    echo "Idle time $idl"
    if [ $idl -gt $idletime ]
    then
	echo "Idle time is OK"
	if [ "$laststate" == "L" ]
	    then
	    echo "I will turn monitor off"
	    laststate="D"
	    setdark
	    fi
    else
	echo "Idle is not enought"
	if [ "$laststate" == "D" ]
	    then
	    echo "I will turn monitor on"
	    laststate="L"
	    setlight
	    fi
    fi
if [ "$laststate" == "L" ]
    then
    echo "Last state was Light - exit"
    rm -rf working
    exit
    fi
sleep 1
done
rm -rf working
