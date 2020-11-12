#! /bin/bash
USAGE="usage: $0 < List all[-l]  Recover file [-r] Delete all[-d]  Show Total [-t] Run Watch[-w]  Termaint Watch[-k]" 

printf "\033c"
trap ctrl_c 2



echo -n "Kameran Youssef";
echo " S1038287" ;
date 
echo " ";


JunkDic=~/.Junk;


if [ ! -d $JunkDic ]; then
    mkdir -p $JunkDic
fi

_list(){ 
if [ "$(ls -A $JunkDic)" ]; then
	cwd=$(pwd)	
	cd $JunkDic
	stat -c "%s %n" *.*
	cd $cwd
else
    echo "Junk is Empty";
fi
}
_recover(){
if [ -f $JunkDic/$OPTARG ] ; then
	cwd=$(pwd)
	cd $JunkDic
	mv $OPTARG $cwd;
	echo "$OPTARG Moved To $cwd ";
	cd $cwd
else 
	echo "$OPTARG No such file available";
fi 
}

_delete(){
if [ "$(ls -A $JunkDic)" ]; then 
	rm $JunkDic/*.*
	echo "All files have been removed";
else 
	echo "junk directory is already empty";
fi
}

_total(){
size=0
for user in $(cut -d: -f1 /etc/passwd); do
	if [ -d  /home/$user/.Junk/ ]; then
		 if [ "$(ls -A /home/$user/.Junk/)" ]; then 
			size+=$( du -csb /home/$user/.Junk/*.* | grep total );
		fi	
	fi
done
echo -n "Junk total in bytes for all users: ";
echo $size | sed -e "s/[^0-9 ]//g" | sed -e "s/^ *//" | sed -e "s/ *$//" | sed -e "s/ /+/g" | bc

size=0 
}

_watch(){ 
pid=$(pidof watch);
if [ -z "$pid" ]; then
	echo "executing watch commmand........";
	./watch.sh
else
	echo "Watch is already running";
fi
}

_kill(){
pid=$(pidof watch)
if [ -z "$pid" ]; then
	echo "Watch is not running";
else
	echo "Killing watch.......";
	kill -9 $pid 
fi
}

ctrl_c(){
printf "\033c";

echo  -n " Exiting..... Total files in junk:";
cd ~/.Junk
ls -1 | wc -l

exit $?
}

_checksSize(){
if [ "$(ls -A $JunkDic)" ]; then 
	bytes+=$(du -csb $JunkDic/*.* | grep total | cut -f1)
	if [ "$bytes" -gt "999" ]; then
		echo "Junk directory exceeds 1 Kbytes";
		echo " ";
	fi 
fi
}

while getopts :lr:dtwk args 
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
      do 
	case $menu_list in
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
