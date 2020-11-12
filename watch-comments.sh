#! /bin/bash
#store path to the junk dirctory in JunkDic
JunkDic=~/.Junk
cd $JunkDic
#run watch command to update .Junk dirctory and all the files every 15s
xfce4-terminal -e "watch -n15 md5sum  *.*"
