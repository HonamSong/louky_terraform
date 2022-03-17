#!/bin/bash 

### create by hnsong (2021.05.10)

c_red='\033[0;31m'              ## Red Color
c_blue='\033[0;34m'             ## Blue Color
c_yellow='\033[1;33m'           ## Yello Color
c_orange='\033[0;33m'           ## Orange Color
c_green='\033[0;32m'            ## Green Color
c_lightred='\033[1;31m'
c_nocolor='\033[0m'

SCRIPT_HOME=$(echo $0 | xargs dirname)

	ip_list=`cd ${SCRIPT_HOME} ; cat ../terraform.tfstate | jq ".outputs.za_IP_JSON_Public.value"| tr -d "[],\""`

	for ipAddr in ${ip_list}; do
		curl -s http://${ipAddr}:9000/admin/chain > /dev/null 
		if [ $? -eq 0 ] ; then 
			Check_Url_Node="${ipAddr}"
			break ;
		fi
	done
	

getChain_all () {


	word_count="0"

	TempFile="${HOME}/.getChainData.temp"

        rm -rf ${TempFile}
	touch ${TempFile}

	#echo "curl -s http://${Check_Url_Node}:9000/admin/chain/$(curl -s http://${Check_Url_Node}:9000/admin/chain | jq -r .[0].cid) | jq -r \".config.seedAddress\" | sed -e \"s/:7100,/\n/g\" -e \"s/:7100//g\""
        node_iplist=`curl -s http://${Check_Url_Node}:9000/admin/chain/$(curl -s http://${Check_Url_Node}:9000/admin/chain | jq -r .[0].cid) | jq -r ".config.seedAddress" | sed -e "s/:7100,/\n/g" -e "s/:7100//g"`
	#echo "${node_iplist}"
	Idx=1

	printf " ++ Wait !."
        for nodeIp in ${node_iplist} ; do
                CID=$(curl -s ${nodeIp}:9000/admin/chain | jq -r ".[0].cid")
                NID=$(curl -s ${nodeIp}:9000/admin/chain | jq -r ".[0].nid")
                CHANNEL=$(curl -s ${nodeIp}:9000/admin/chain | jq -r ".[0].channel")
                STATE=$(curl -s ${nodeIp}:9000/admin/chain | jq -r ".[0].state")
                ROLE=$(curl -s http://${Check_Url_Node}:9000/admin/chain/$(curl -s http://${Check_Url_Node}:9000/admin/chain | jq -r ".[0].cid") | jq -r ".config.role")
                HEIGHT=$(curl -s ${nodeIp}:9000/admin/chain | jq -r ".[0].height")
		ADDRESS=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".setting.address")
		height_word_cnt=$(echo "${HEIGHT}" | wc -m)

		get_word_num=`printf "| %03d | %-16s | %-10s | %-5s | %-10s | %-10s | %-5d | %-45s | %-${height_word_cnt}d |\n" "${Idx}" "${nodeIp}" "${CID}" "${NID}" "${CHANNEL}" "${STATE}" "${ROLE}" "${ADDRESS}" "${HEIGHT}" | wc -m`

                if [ "${get_word_num}" -lt "${word_count}" ] ; then
                        word_count=${word_count}
                elif [ "${get_word_num}" -ge "${word_count}" ] ; then
                        word_count=${get_word_num}
                fi

		if [ -z "${height_count}" ] ; then 
			height_count=${height_word_cnt}
		else
                	if [ "${height_word_cnt}" -lt "${height_count}" ] ; then
                	        height_count=${height_count}
                	elif [ "${height_word_cnt}" -ge "${height_count}" ] ; then
                	        height_count=${height_word_cnt}
                	fi
		fi

                printf "| %03d | %-16s | %-10s | %-5s | %-10s | %-10s | %-5d | %-45s | %-${height_word_cnt}d |\n" "${Idx}" "${nodeIp}" "${CID}" "${NID}" "${CHANNEL}" "${STATE}" "${ROLE}" "${ADDRESS}" "${HEIGHT}" >> ${TempFile}

		Idx=$(( ${Idx} + 1))

		printf "."

        done

	echo -e "\n\n"

        for (( i=1; i<=${word_count} ; i++ )) ; do
                printf "="
                if [ ${i} -eq ${word_count} ] ; then
                        printf "\n"
                fi
        done

        printf "| %-3s | %-16s | %-10s | %-5s | %-10s | %-10s | %-5s | %-45s | %-${height_count}s |\n" "Idx" "IP ADDR" "CID" "NID" "CHANNEL" "STATE" "ROLE" "ADDRESS" "HEIGHT"

        for (( i=1; i<=${word_count} ; i++ )) ; do
                printf "-"
                if [ ${i} -eq ${word_count} ] ; then
                        printf "\n"
                fi
        done
	
        cat < ${TempFile} ; rm -rf ${TempFile}
        for (( i=1; i<=${word_count} ; i++ )) ; do
                printf "="
                if [ ${i} -eq ${word_count} ] ; then
                        printf "\n"
                fi
        done
}


getChain () {
        case $1 in
                "detail" )
                        echo -e "${c_green} ++ CMD :  curl -s http://${Check_Url_Node}:9000/admin/chain/$(curl -s http://${Check_Url_Node}:9000/admin/chain | jq -r .[0].cid) | jq ${c_nocolor}\n\n"
                        curl -s http://${Check_Url_Node}:9000/admin/chain/$(curl -s http://${Check_Url_Node}:9000/admin/chain | jq -r .[0].cid) | jq
                ;;

                "all" )
                        getChain_all
                ;;

                * )
                        echo -e "${c_green} ++ CMD : curl -s http://${Check_Url_Node}:9000/admin/chain | jq ${c_nocolor}\n\n"
                        curl -s http://${Check_Url_Node}:9000/admin/chain | jq
        esac
}

getSystem_all () {
	word_count=0
	TempFile="${HOME}/.getSystemData.temp"

        rm -rf ${TempFile}

        node_iplist=`curl -s http://${Check_Url_Node}:9000/admin/chain/$(curl -s http://${Check_Url_Node}:9000/admin/chain | jq -r .[0].cid) | jq -r ".config.seedAddress" | sed -e "s/:7100,/\n/g" -e "s/:7100//g"`

        for nodeIp in ${node_iplist} ; do
                Build_VERSION=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".buildVersion")
                Build_Tags=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".buildTags")
                Build_Tags_num=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".buildTags" | wc -m)
                ADDRESS=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".setting.address")
                ADDRESS_num=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".setting.address"| wc -m)
                rpcDump=$(curl -s ${nodeIp}:9000/admin/system | jq -r ".setting.rpcDump")
                config_eeInstances=$(curl -s ${nodeIp}:9000/admin/system/configure | jq -r ".eeInstances")
                config_rpcDefaultChannel=$(curl -s ${nodeIp}:9000/admin/system/configure | jq -r ".rpcDefaultChannel")
                config_rpcDefaultChannel_num=$(curl -s ${nodeIp}:9000/admin/system/configure | jq -r ".rpcDefaultChannel" | wc -w)
                config_rpcIncludeDebug=$(curl -s ${nodeIp}:9000/admin/system/configure | jq -r ".rpcIncludeDebug")

		if [ ${config_rpcDefaultChannel_num} -eq 0 ] ; then 
			config_rpcDefaultChannel=" Null "
		fi	


		get_word_num=`printf "| %-16s | %-15s | %-${Build_Tags_num}s | %-${ADDRESS_num}s | %-10s | %-12s | %-15s | %-s |\n" "${nodeIp}" "${Build_VERSION}" "${Build_Tags}" "${ADDRESS}" "${rpcDump}" "${config_eeInstances}" "${config_rpcIncludeDebug}" "${config_rpcDefaultChannel}"| wc -m`

                if [ "${get_word_num}" -lt "${word_count}" ] ; then
                        word_count=${word_count}
                elif [ "${get_word_num}" -ge "${word_count}" ] ; then
                        word_count=${get_word_num}
                fi

		if [ -z "${height_count}" ] ; then 
			height_count=${height_word_cnt}
		else
                	if [ "${height_word_cnt}" -lt "${height_count}" ] ; then
                	        height_count=${height_count}
                	elif [ "${height_word_cnt}" -ge "${height_count}" ] ; then
                	        height_count=${height_word_cnt}
                	fi
		fi

                printf "| %-16s | %-15s | %-${Build_Tags_num}s | %-${ADDRESS_num}s | %-10s | %-12s | %-15s | %-s |\n" "${nodeIp}" "${Build_VERSION}" "${Build_Tags}" "${ADDRESS}" "${rpcDump}" "${config_eeInstances}" "${config_rpcIncludeDebug}" "${config_rpcDefaultChannel}" >> ${TempFile}

        done

        for (( i=1; i<=${word_count} ; i++ )) ; do
                printf "="
                if [ ${i} -eq ${word_count} ] ; then
                        printf "\n"
                fi
        done

        printf "| %-16s | %-15s | %-${Build_Tags_num}s | %-${ADDRESS_num}s | %-10s | %-12s | %-15s | %-s |\n" "IP ADDR" "Build_VERSION" "Build_Tags" "ADDRESS" "rpcDump" "eeInstances" "rpcIncludeDebug" "rpcDefaultChannel"
        for (( i=1; i<=${word_count} ; i++ )) ; do
                printf "-"
                if [ ${i} -eq ${word_count} ] ; then
                        printf "\n"
                fi
        done

        cat < ${TempFile} ; rm -rf ${TempFile}

        for (( i=1; i<=${word_count} ; i++ )) ; do
                printf "="
                if [ ${i} -eq ${word_count} ] ; then
                        printf "\n"
                fi
        done

}

getSystem () {
	case $1 in 
			
		"all" ) 
			getSystem_all
		;;	

		* )
			 echo -e "${c_green} ++ CMD :  curl -s http://${Check_Url_Node}:9000/admin/system | jq \n\n"
			 curl -s http://${Check_Url_Node}:9000/admin/system | jq 
		;;
	esac	
}

print_help () {
	echo -e " ++ Help USAGE"
	echo -e "  USAGE ) $0 [chain|system] [null|all|detail]\n"

	echo -e "  ex) $0 chain [null|all|detail]"
	echo -e "   or "
	echo -e "  ex) $0 system [null|all]"
}


main () {
	if [ "$#" -eq 0 ] ; then 
		print_help
	fi

	case $1 in 
		[Cc][Hh][Aa][Ii][Nn] )
			getChain "$2"
		;;

		[Ss][Yy][Ss][Tt][Ee][Mm] )
			getSystem "$2"	
		;;	 

		"-h" | "--help" )
			print_help
		;;

		* )
			echo "\"Chain\" or \"system\" input argument!!" 
			print_help
		;;
	esac	
		

}

main $*

