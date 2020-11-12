#! /bin/bash
JunkDic=~/.Junk
cd $JunkDic
xfce4-terminal -e "watch -n15 md5sum  *.*"
