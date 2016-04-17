#!/bin/bash
MONTH=$(date +"%m")
YEAR=$(date +"%Y")
DAY=$(date +"%d")
TIME=$(date +"%H%M")
HOUR=$(date +"%H")
MIN=$(date +"%M")
DIR="/home/josh/filebotlogs/$YEAR-$MONTH"

filebot -script "/home/josh/scripts/amc.groovy" "/mnt/MediaShare/Movies" --output "/mnt/MediaShare" --action test --conflict override -non-strict --def clean=y subtitles=en artwork=y backdrops=y >> "/home/josh/filebot.log" 2>&1

chmod 777 -R /mnt/MediaShare

echo Filebot Complete

if [ -d "$DIR" ]
then
        mv /home/josh/filebot.log /home/josh/filebotlogs/$YEAR-$MONTH/$DAY-$TIME.log
else
        mkdir /home/josh/filebotlogs/$YEAR-$MONTH
        mv /home/josh/filebot.log /home/josh/filebotlogs/$YEAR-$MONTH/$DAY-$TIME.log
fi

rm -rf /home/josh/filebot.log

echo Log Complete 
