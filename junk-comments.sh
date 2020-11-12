#! /bin/bash
#list of all the commands available
USAGE="usage: $0 < List all[-l]  Recover file [-r] Delete all[-d]  Show Total [-t] Run Watch[-w]  Termaint Watch[-k]" 
#clear screen 
printf "\033c"

#set trap with 2=SIGINT signal
trap ctrl_c 2;

#student details and date
echo -n "Kameran Youssef";
echo " S1038287" ;
date ;
echo " ";

#store path to the junk dirctory in JunkDic
JunkDic=~/.Junk;

#create .Junk dirctory if it doesn't exist
if [ ! -d $JunkDic ]; then
    mkdir -p $JunkDic;
fi

_list(){ 
#check if the user has any files in junk directory
if [ "$(ls -A $JunkDic)" ]; then
	cwd=$(pwd)	
	cd $JunkDic;
	#list all the files (size, name, type)
	stat -c "%s %n" *.*;
	cd $cwd
else
    echo "Junk is Empty";
fi
}

_recover(){
#check if file exist
if [ -f $JunkDic/$OPTARG ] ; then
	#move file from juck directory to user current working directory
	cwd=$(pwd);
	cd $JunkDic;
	mv $OPTARG $cwd;
	echo "$OPTARG Moved To $cwd "
	cd $cwd
else 
	echo "$OPTARG No such file available";
fi 
}

_delete(){
#check if the user has any files in junk directory
if [ "$(ls -A $JunkDic)" ]; then
	#delete all files in junk directory 
	rm $JunkDic/*.*;
	echo "All files have been removed";
else 
	echo "junk directory is already empty";
fi
}

_total(){
#set size to 0 
size=0
#loop to find all users
#find the all the user in passwd and use cut -d: -f1 to delimiter to the first field which is the username 
for user in $(cut -d: -f1 /etc/passwd); do
	#check if the user has .Junk directory 
	if [ -d  /home/$user/.Junk/ ]; then
		#check if the user has any files in junk directory
		 if [ "$(ls -A /home/$user/.Junk/)" ]; then 
			#find the size of junk directory
			size+=$( du -csb /home/$user/.Junk/*.* | grep total );
		fi	
	fi
done
echo -n "Junk total in bytes for all users: ";
# print variable,
# remove everything keep numbers and spaces,
# remove  any spaces at the beginning and end of the line,
# replace spaces with +,
# add the numbers.
echo $size | sed -e "s/[^0-9 ]//g" | sed -e "s/^ *//" | sed -e "s/ *$//" | sed -e "s/ /+/g" | bc;
#reset size to 0
size=0; 
}

_watch(){
#find the process id for watch 
pid=$(pidof watch);
#check if watch is running 
if [ -z "$pid" ]; then
	echo "executing watch commmand........";
	#run watch script 
	./watch.sh;
else
	echo "Watch is already running";
fi
}

_kill(){
#find the process id for watch 
pid=$(pidof watch);
#check if watch is running 
if [ -z "$pid" ]; then
	echo "Watch is not running";
else
	echo "Killing watch.......";
	#kill the runnig watch command 
	kill -9 $pid ;
fi
}

#if user hits ctrl-c
ctrl_c(){
#clear screen 
printf "\033c"

echo  -n "Exiting..... Total files in junk:";
cd ~/.Junk;
#check all the files and line count to get the total number of files 
ls -1 | wc -l;

exit $?
}

_checksSize(){
#check if the user has any files in junk directory
if [ "$(ls -A $JunkDic)" ]; then 
	#find the total size
	bytes+=$(du -csb $JunkDic/*.* | grep total | cut -f1)
	#check if junk directory exceeds 1Kbytes
	if [ "$bytes" -gt "999" ]; then
		echo "Junk directory exceeds 1 Kbytes";
		echo " ";
	fi 
fi
}

#Means from the given junk-skeleton 
while getopts :lr:dtwk args #options
do
_checksSize
  case $args in
     l)_list;;
     r)_recover $OPTARG;;
     d)_delete;; 
     t)_total;; 
     w)_watch;; 
     k)_kill;;     
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
  esac
done

((pos = OPTIND - 1))
shift $pos

PS3="option> "

if (( $# == 0 ))
then if (( $OPTIND == 1 )) 
 then 
 _checksSize
   select menu_list in list recover delete total watch kill exit
      do case $menu_list in
         "list") _list;;
         "recover") echo "Enter file name ?";
		    read OPTARG;
		    _recover $OPTARG;;
         "delete")_delete;;
         "total")_total;;
         "watch")_watch;;
         "kill")_kill;;
         "exit") exit 0 ;;
         *) echo "unknown option";;
         esac
      done
 fi
else echo "$USAGE"
fi
