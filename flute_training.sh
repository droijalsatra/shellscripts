#!/bin/bash

### Script for my son Jan, and his hard flute school-training :P
### Execute as root or with sudo permissions 'cause modprobe need it. 

### Enable your beep with: (sudo) modprobe pcspkr 
### and you can enable it permanently removing pcspkr from modprobe blacklist (if needed)
### editing conf file: sudo vi /etc/modprobe.d/blacklist.conf

### A note shows (and sounds) at the top of your screen, and you will have 
### your selected number of seconds in order to reproduce it
### You can decrease seconds between notes progressively, in order to 
### improve your flute skills. Good luck! :)

clear
modprobe pcspkr
echo -e "FLUTE's LITTLE TRAINING PROGRAM";
echo -e "*******************************";
echo
echo -e "Select the number of seconds between notes.";
echo -e "(Think about you need to place your fingers and hold them";
echo -e " in order to get a nice and clean sound)";
echo
echo -e "(3-5 seconds - EXPERT Level)";
echo -e "(5-10 seconds - INTERMEDIATE Level)";
echo -e "(+10 seconds - You need more practice)";
echo
echo -e "(CTRL-C at any moment to quit)";
echo
echo -e "HOW MUCH SECONDS BETWEEN NOTES? (Enter the number of seconds and press ENTER)"; read seconds;
clear

while :
do
  INPUT_STRING=$(( ( RANDOM % 8 )  + 1 ))
  case $INPUT_STRING in

        1)
                echo "C (low)"
                beep -f 261 -l 1000
                ;;
        2)
                echo "D"
                beep -f 293 -l 1000
                ;;
        3)
                echo "E"
                beep -f 329 -l 1000
                ;;
        4)
                echo "F"
                beep -f 349 -l 1000
                ;;
        5)
                echo "G"
                beep -f 392 -l 1000
                ;;
        6)
                echo "A"
                beep -f 440 -l 1000
                ;;
        7)
                echo "B"
                beep -f 493 -l 1000
                ;;
        8)
                echo "C (high)"
                beep -f 513 -l 1000
                ;;

        *)
                echo ""
                ;;
  esac

sleep $seconds;
clear
done
