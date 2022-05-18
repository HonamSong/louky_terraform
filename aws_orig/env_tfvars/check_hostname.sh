#!/bin/bash 

SCRIPT_HOME=$(echo $0 | xargs dirname)
ssh_cmd="ssh -oTCPKeepAlive=no -oServerAliveInterval=120 -oStrictHostKeyChecking=no"

ip_list=`cd ${SCRIPT_HOME} ; cat ../terraform.tfstate | jq ".outputs.za_IP_JSON_Public.value"`
cnt=0

printf "++ Get hostname .. Wait!!!"
for iplist in ${ip_list} ; do
	remote_ip=$(echo ${iplist} | tr -d "\"\,\]\[")
 	if [ $(echo ${remote_ip} | wc -w) -ne 0 ] ; then 
		cnt=$(( ${cnt} + 1 ))
		rhostname=`${ssh_cmd} -i ~/aws-key/tbridge ec2-user@${remote_ip}  "hostname" 2>/dev/null`

		printf "  - ${rhostname} , %-16s \n" "${remote_ip}" >> iptemp.temp
		printf "."
	fi 
done


echo -e "\n\n"
cat iptemp.temp | sort 
rm -rf iptemp.temp

echo -e "\n\nIP List count  = ${cnt}"

