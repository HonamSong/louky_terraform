#!/bin/bash 



for (( i=11;i<=40;i++ )) ; do 
	printf "  \"10.61.8.$i\""
        if [ $i -eq 40 ] ; then 
		printf "\n"
	else 
		printf ",\n"
	fi
done


echo ""
for (( i=11;i<=40;i++ )) ; do 
	printf "  \"10.61.9.$i\""
        if [ $i -eq 40 ] ; then 
		printf "\n"
	else 
		printf ",\n"
	fi
done

s_num=1 
e_num=60

while [ ${s_num} -le ${e_num} ] ; do
	inum=`seq -f "%02g" ${s_num} ${s_num}`

	printf " \"${inum}\""

	s_num=$(( ${s_num} + 2))
        if [ ${s_num} -gt ${e_num} ] ; then 
		printf "\n"
	else 
		printf ","
	fi
done

s_num=2 
e_num=60

while [ ${s_num} -le ${e_num} ] ; do
	inum=`seq -f "%02g" ${s_num} ${s_num}`

	printf " \"${inum}\""

	s_num=$(( ${s_num} + 2))
        if [ ${s_num} -gt ${e_num} ] ; then 
		printf "\n"
	else 
		printf ","
	fi
done

