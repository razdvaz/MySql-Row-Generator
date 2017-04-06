#!/bin/bash
echo "start---------------!";
for line in $(cat config.txt)
do
	IFS=':' read -ra input <<< "$line"
	if [ "${input[0]}" = "user" ];then user="${input[1]}";fi
	if [ "${input[0]}" = "password" ];then password="${input[1]}";fi
	if [ "${input[0]}" = "database" ];then database="${input[1]}";fi
	if [ "${input[0]}" = "table" ];then table="${input[1]}";fi
	if [ "${input[0]}" = "iteration" ];then iteration="${input[1]}";fi
	if [ "${input[0]}" = "fields" ];then fields="${input[1]}";fi
	if [ "${input[0]}" = "value" ];then IFS=',' read -ra value <<< "${input[1]}";fi
	if [ "${input[0]}" = "intrand" ];then IFS=',' read -ra intrand <<< "${input[1]}";fi
	if [ "${input[0]}" = "textrand" ];then IFS=',' read -ra textrand <<< "${input[1]}";fi
done

for ((var=0;var<iteration;var++))
do
	length=${#textrand[*]};
	declare -a val;
	echo $var;
	for i in ${value[*]}
	do
		if [ "$i" = "textrand" ];then val[${#val[*]}]=${textrand[$((RANDOM%length))]};fi
		if [ "$i" = "intrand" ];then 
			number=0;
			while [ "$number" -le "${intrand[0]}" ]
			do
		  		number=$RANDOM;
		  		let "number %= ${intrand[1]}";
		  		val[${#val[*]}]=$number;
			done
		fi
	done

	sIFS=$IFS; 
	IFS=$',';
	out=${val[*]}
	IFS=$sIFS

mysql -u $user -p$password << EOF
	USE $database;
	INSERT INTO $table ($fields) VALUE ($out);
EOF
unset val;
done
exit 0