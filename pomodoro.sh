#!/bin/bash

# Config variables
work_time=15
break_time=5

msg_start="[P]"
work_prefix="[W] "
break_prefix="[B] "

start_color="#b39df3"
break_color="#a7df78"
work_color="#f39660"

break_command="notify-send -t 2500 'Grab a tea'"
work_command="notify-send -t 2500 'Time to work!'"

pom_path="/tmp/pomodoro"

function display () {
	min=$(expr $s / 60)
	sek=$(expr $s % 60)
	if [ $min -eq 0 ]
	then
		min=00
	elif [ $min -lt 10 ]
	then
		min=0$min
	fi
	if [ $sek -lt 10 ]
	then
		sek=0$sek
	fi
	case $2 in
		w)
			echo $work_prefix$min:$sek
			echo $min:$sek
			echo $work_color
		;;
		b)
			echo $break_prefix$min:$sek
			echo $min:$sek
			echo $break_color
		;;
	esac
}

if [ -f $pom_path ] && [ $(wc -l $pom_path | awk '{print $1}') -eq 2 ]
then
	p=$(sed '1 d' $pom_path) # time
	t=$(sed '2 d' $pom_path) # mode
	case $t in
		w) dur=$work_time;;
		b) dur=$break_time;;
	esac 
	now=$(date +%s)
	s=$(expr $dur - $now + $p)
	if [ $s -le 0 ] # if time less than 0 then switch mode
	then
		case $t in
			w)
				echo b > $pom_path
				eval $break_command
			;;
			b)
				echo w > $pom_path
				eval $work_command
			;;
		esac
		echo $now >> $pom_path
	fi
	display $s $t
else
	echo $msg_start
	echo $msg_start
	echo $start_color
fi

case $BLOCK_BUTTON in
	1)
		if [ -f $pom_path ]; then # if file exists then stop reset timer
			rm $pom_path
		else
			echo w > $pom_path # else start timer
			date +%s >> $pom_path
		fi
	;;
esac
