#!/bin/bash

##### Leaves only 5 latest backups in specified dirs ######
DIRS_TO_CLEAN=("/soft/backups/databases" "/soft/backups/websites" "/soft/backups/vpn")
DIR_NUM=${#DIRS_TO_CLEAN[@]}
TAB_INDEX=$DIR_NUM-1


for (( i=0; $i <= $TAB_INDEX; i++ ));
        do
        ######### Operacje na poszczegolnym katalogu z tablicy ##########
        cd ${DIRS_TO_CLEAN[$i]}
        ######### Pozostawienie 5 najnowszych plików w katalogu #########
        (ls -t | head -n 5;ls)|sort|uniq -u|xargs rm
done
