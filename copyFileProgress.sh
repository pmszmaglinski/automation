#!/bin/sh

# Skrypt informuje o ilosci skopiowanego pliku i szybkosci kopiowanie.
# Przydatny gdy os (busybox) nie wspiera progresu kopiowania
# TODO - zakonczenie skryptu po skpiowaniu (while srcFile < dstFile)
#        wymaga przekazania informacji o zrodle

file=/i-data/0aa2669a/temp/oldNas.tar

clear
echo "Zbieram dane..."
while true; do

  if [[ ! -z "$oldSize" ]] || [[ ! -z "$newSize" ]]; then
    echo "Skopiowano $(($newSize/(1024*1024))) MB z predkoscia $((($newSize-$oldSize)/(1024*1024))) MB/s"
  fi
  
  oldSize=$(ls -l $file | awk '{print $5}'); 
  sleep 1;
  newSize=$(ls -l $file | awk '{print $5}');

  clear
done
