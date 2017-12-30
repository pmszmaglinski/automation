#!/bin/sh

# Check disc I/O performance using dd (not perfect solution, but good enough in this example).
# Eeach disk is separate md raid device mounted in it's own directory where dd puts 'test' file
# We also check disc manufacturer to provide consistant output for each of them 
# (disk manufacturer, directory and calculated rate)

for devicedir in $(df -h | grep i-data | awk '{print $6}'); do
  for raiddevice in $(df -h | grep i-data | grep $devicedir | awk '{print $1}'); do

     discletters=$(cat /proc/mdstat | grep ${raiddevice##/dev/} | awk '{print $5}');

     manufacturer=$(smartctl -i /dev/${discletters:0:3} | grep 'Device Model' | awk '{print $3" "$4}')

     rate=$(dd bs=1M count=512 if=/dev/zero of=$devicedir/test conv=fsync 2>&1 | grep 'bytes' | awk '{print $7}');

     rm $devicedir/test;

     echo "Manufacturer $manufacturer in dir $devicedir has rate of $rate."

     done
done
