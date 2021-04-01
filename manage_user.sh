#!/bin/sh

action=$1
ip=$2
file_name="authorized_ip.txt"

CheckReturnCode()
{
        if [ $? != 0 ]
        then
                echo "Failed"
                exit 1
        fi
}

check_existe_file()
{
	if [ -e $file_name ]
	then
		break
	else
		touch $file_name
	fi
}

reset_table()
{
	sudo iptables -F
	CheckReturnCode
}

filter_table()
{
	sudo iptables -A INPUT -p tcp --destination-port 1194 -j DROP
	sudo iptables -A INPUT -p udp --destination-port 1194 -j DROP
	CheckReturnCode
}

add_previous_user()
{
	check_existe_file
	cat $file_name | while read temp
	do
		if [ ! -z $temp ]
		then
			sudo iptables -A INPUT -p tcp -s $temp --dport 1194 -j ACCEPT
        		sudo iptables -A INPUT -p udp -s $temp --dport 1194 -j ACCEPT
			CheckReturnCode
		fi
	done
}

add_user()
{
	reset_table
	sudo iptables -A INPUT -p tcp -s $ip --dport 1194 -j ACCEPT
	sudo iptables -A INPUT -p udp -s $ip --dport 1194 -j ACCEPT
	add_previous_user
	filter_table
	echo $ip >> $file_name
	CheckReturnCode
}

delete_user()
{
	reset_table
	sed -i 's/'$ip'/ /g' $file_name
	add_previous_user
	filter_table
	CheckReturnCode
}

if [ $action = "add" ]
then
	add_user
elif [ $action = "delete" ]
then
	delete_user
fi
