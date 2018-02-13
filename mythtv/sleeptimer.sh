#!/bin/bash

# Ref: https://www.mythtv.org/wiki/Sleep_timer

# maximum allowed sleeptime in minutes
# if a keypress would make the sleeptimer exceed this value
# the shutdown gets cancelled
MAXSLEEPTIME=140

# the increment of the sleep timer in minutes
# when the sleep timer key is pressed
SLEEPINCREMENT=30

sleepWarningScript=sleepWarning.sh

# determine script's path
SCRIPTPATH=$(dirname $(which $0))

# Get scheduled shutdown time

# Method 1: Read from file
# oldSleepTimeMicrosec=$(cat /run/systemd/shutdown/scheduled | grep -oP '(?<=USEC=).*')

# Method 2: Read from dbus
loginQuery="$(qdbus --literal --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.DBus.Properties.Get org.freedesktop.login1.Manager ScheduledShutdown)"
scheduleActive=$(echo $loginQuery | grep -oP '(?<=").*(?=")')

oldSleepTimeMicrosec=$(echo $loginQuery | grep -oP '(?<=", ).*(?=]])')
oldSleepTimeSec=${oldSleepTimeMicrosec::-6}
oldSleepTimeStr=$(date -d "@${oldSleepTimeSec}" +"%Y%m%dT%H:%M:%S")

currentTimeSec=$(date +%s)
timeDiffFromNowSec=$((($oldSleepTimeSec - $currentTimeSec)))
timeDiffFromNowMin=$((($timeDiffFromNowSec / 60)))

if [ -z "$scheduleActive" ]; then
	OLDSLEEPTIME=
else
	OLDSLEEPTIME=$timeDiffFromNowMin
fi

[ -z "${OLDSLEEPTIME}" ] && OLDSLEEPTIME=0
NEWSLEEPTIME=$(($OLDSLEEPTIME + $SLEEPINCREMENT))

# kill former instances of shutdown and sleepwarning
/sbin/shutdown -c >/dev/null 2>&1
/usr/bin/pkill -f ${sleepWarningScript} >/dev/null 2>&1

# set new sleepvalue or cancel sleep timer if it exceeds MAXSLEEPTIME
if [ $NEWSLEEPTIME -gt $MAXSLEEPTIME ]; then
	/usr/bin/mythutil --message --message_text="Sleep timer off." --timeout=3 --bcastaddr 127.0.0.1 &
	exit 0
fi

# start shutdown
sudo /sbin/shutdown --poweroff +${NEWSLEEPTIME} >/dev/null 2>&1 &

# show message to user, that sleeptime was initiated
/usr/bin/mythutil --message --message_text="$(hostname) will go to sleep in $NEWSLEEPTIME minutes." --timeout=3 --bcastaddr 127.0.0.1 &

# Warn ~ one minute before we really go to sleep
$SCRIPTPATH/${sleepWarningScript} $NEWSLEEPTIME &
