#!/bin/bash

# Ref: https://www.mythtv.org/wiki/Sleep_timer

SLEEPTIME=$1

sleep $(($SLEEPTIME * 60 - 60 ))
/usr/bin/mythutil --message --message_text="$(hostname) will go to sleep in about one minute. " --timeout=55 --bcastaddr 127.0.0.1
