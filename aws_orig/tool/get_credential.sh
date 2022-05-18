#!/bin/bash

## Comman ENV : Echo Color
c_red='\033[0;31m'              ## Red Color
c_blue='\033[0;34m'             ## Blue Color
c_yellow='\033[1;33m'           ## Yello Color
c_orange='\033[0;33m'           ## Orange Color
c_green='\033[0;32m'            ## Green Color
c_lightred='\033[1;31m'
no_color='\033[0m'                    ## Unset Color(NoColor)

script_home=$(echo $0 | xargs dirname)


####### AWS  USER Credential list
PROFILE_NAME=${PROFILE_NAME:-"default"}

### USER modify config field  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
AWS_ACCOUNT_ID=229930918337           							### AWS SITE  IAM Infomation check
AWS_USER_ID="hnsong@iconloop.com"     							### AWS login Account
USER_OTP_CODE="UBIPHWSSKBJ6TMGMR6Q7L7POMCZMH7WKXHU2QG75HH632PPYUIGJBB3YOQM7ESBV"	### AWS MFA Code
Terraform_HOME="/app/terraform/aws_tbridge_single"					### Terraform provider file path or config file path
t_provider_file="${Terraform_HOME}/provider.tf"
## <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

temp_file="${script_home}/temp/aws_rg_list.txt"

#### AWS Clin install - aws cli version 2
function install_awscli {
	awscli_install_path="/app/aws_cli"
	mkdir -p ${awscli_install_path}

	yum install -y groff less glibc unzip
	cd ${awscli_install_path}
 	curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  	unzip awscliv2.zip
 	./aws/install -i /usr/local/aws-cli -b /usr/bin
 	 /usr/bin/aws --version
}


### aws cli  user credential create
function aws_configuration {

	echo -n "aws configure profile name ? (default: default) "
	read  ans_aws_config_profile

	export 	ans_aws_config_profile=${ans_aws_config_profile:-"default"}

	echo -n "aws configure access key id ? "
	read ans_aws_access_key_id

	echo -n "aws_secret_access_key ? "
	read ans_aws_secret_access_key


	echo -n "aws region ? "
	read ans_region

	ans_region=${ans_region:-"us-west-1"}

	if [ -z "${ans_aws_access_key_id}" ] || [ -z "${ans_aws_secret_access_key}" ] ; then
		echo "aws_access_key_id or ans_aws_secret_access_key Check please!!"
		exit 0
	fi

	if [ ! -d "$HOME/.aws" ] ; then
		mkdir -p $HOME/.aws
	fi

	if [ ! -f $HOME/.aws/config ] ; then
		touch $HOME/.aws/config
	fi

	if [ ! -f $HOME/.aws/credentials ] ; then
		touch $HOME/.aws/credentials
	fi


	{
	echo "[${ans_aws_config_profile}]"
	echo "region = ${ans_region}"
	echo "format = json"
	} >> $HOME/.aws/config

	{
	echo "[${ans_aws_config_profile}]"
	echo "aws_access_key_id = ${ans_aws_access_key_id}"
	echo "aws_secret_access_key = ${ans_aws_secret_access_key}"
	} >>  $HOME/.aws/credentials

	aws configure list --profile ${ans_aws_config_profile}

}



function region_list {

	if [ -z "${change_state}" ] ; then
		rg_list="
		미국_동부_(버지니아_북부)=us-east-1
		미국_동부_(오하이오)=us-east-2
		미국_서부_(캘리포니아)=us-west-1
		미국_서부_(오레곤)=us-west-2
		아프리카_(케이프타운)=af-south-1
		아시아_태평양_(홍콩)=ap-east-1
		아시아_태평양_(뭄바이)=ap-south-1
		아시아_태평양_(오사카)=ap-northeast-3
		아시아_태평양_(서울)=ap-northeast-2
		아시아_태평양_(싱가포르)=ap-southeast-1
		아시아_태평양_(시드니)=ap-southeast-2
		아시아_태평양_(도쿄)=ap-northeast-1
		캐나다_(중부)=ca-central-1
		유럽_(프랑크푸르트)=eu-central-1
		유럽_(아일랜드)=eu-west-1
		유럽_(런던)=eu-west-2
		유럽_(밀라노)=eu-south-1
		유럽_(파리)=eu-west-3
		유럽_(스톡홀름)=eu-north-1
		중동_(바레인)=me-south-1
		남아메리카_(상파울루)=sa-east-1"


		echo "  ++++++++  AWS Region List ++++++++"
		if [ -f "${temp_file}" ] ; then
			rm -rf ${temp_file}
		fi

		snum=1
		for rlist in ${rg_list} ; do
			rg_name_kr=$(echo ${rlist} | awk -F '=' '{print $1}' | sed -e "s/_/\ /g")

			#echo "rg_name_kr = ${#rg_name_kr}"
			rg_name_en=$(echo ${rlist} | awk -F '=' '{print $(NF)}' | sed -e "s/_/\ /g")
			printf "\t %3d ) %-20s => %-40s\n" "${snum}" "${rg_name_en}" "${rg_name_kr}"

			snum=$(( ${snum} + 1 ))
		done | tee -a ${temp_file}

		echo -en "Select AWS region number or Region name ?   "
		read ans_choice_region

		choice_region=$(cat < ${temp_file} | grep -E "\ ${ans_choice_region}\ " | awk '{print $3}' )

		#echo "choice_region == ${choice_region}"

		rm -rf ${temp_file}

		change_state="ok"
	fi
}

function get_aws_credential {

	echo "aws --profile ${PROFILE_NAME} sts get-session-token --serial-number arn:aws:iam::${AWS_ACCOUNT_ID}:mfa/${AWS_USER_ID}  --token-code ${MFA_CODE}"
	rst_credential=$(aws --profile ${PROFILE_NAME} sts get-session-token --serial-number arn:aws:iam::${AWS_ACCOUNT_ID}:mfa/${AWS_USER_ID}  --token-code ${MFA_CODE})

	if [ $? -ne 0 ] ;then
		aws_configuration
	fi

	get_AccessKeyId=`echo ${rst_credential}| jq -r ".Credentials.AccessKeyId"`
	get_SecretAccessKey=`echo ${rst_credential}| jq -r ".Credentials.SecretAccessKey"`
	get_SessionToken=`echo ${rst_credential}| jq -r ".Credentials.SessionToken"`
	get_Expiration=`echo ${rst_credential}| jq -r ".Credentials.Expiration"`

	region_list
	get_region=${choice_region}


	if [ -z "${get_SessionToken}" ] ; then
		echo "++ [ERROR] get aws credential ..... Check !!!!!"
		exit 1
	fi

	{
		echo "export AWS_ACCESS_KEY_ID=\"${get_AccessKeyId}\""
		echo "export AWS_SECRET_ACCESS_KEY=\"${get_SecretAccessKey}\""
		echo "export AWS_SESSION_TOKEN=\"${get_SessionToken}\""
		echo "export AWS_TOKEN_EXPIRE=\"${get_Expiration}\""
		echo "export AWS_DEFAULT_REGION=\"${get_region}\""
	} | tee ${aws_config_env_file}

	echo -e "\n\n${c_red} ++++  run command ====>     source ${aws_config_env_file}${nc}\n\n"

	chg_provider

}

function chg_provider {
	echo -en "${c_yellow}Do you want Change AWS region ?(yes/no)${no_color} "
	read ans_chg_region

	case ${ans_chg_region} in
		[Yy] | [Yy][Ee][Ss] )
			region_list
			source ${aws_config_env_file}
			sed -i "s/AWS_DEFAULT_REGION=\"${AWS_DEFAULT_REGION}\"/AWS_DEFAULT_REGION=\"${choice_region}\"/g" ${aws_config_env_file}
		;;
	esac

	echo -en "${c_green}Over write \"Terraform ${t_provider_file}\" ? (yes/no)${no_color} "
	read ans_overwrite

	case ${ans_overwrite} in
		"Yes" | "yes" | "YES" | "Y" | "y" )

		source ${aws_config_env_file}

		field_list="access_key secret_key token region"
		for fList in ${field_list} ; do
			case ${fList} in
				"access_key" )
					field_rst="${AWS_ACCESS_KEY_ID}"   ;;
				"secret_key" )
					field_rst="${AWS_SECRET_ACCESS_KEY}"   ;;
				"token" )
					field_rst="${AWS_SESSION_TOKEN}"   ;;
				"region" )
					field_rst="${AWS_DEFAULT_REGION}"   ;;
			esac

			line_num=`cat ${t_provider_file} | grep -n ${fList} | awk -F '[:]' '{print $1}'`
			sed -i "/${fList}/d" ${t_provider_file}
			echo "+++  sed -i \"${line_num} i\\  ${fList} = \\\"${field_rst}\\\"\" ${t_provider_file}"
			sed -i "${line_num} i\  ${fList} = \"${field_rst}\"" ${t_provider_file}
		done
		;;
		* )
			echo "ans_overwrite => ${ans_overwrite}"
		;;
	esac

}

#### pkg hcek
cat /etc/*lease  | grep -Ei "centos|redhat" > /devnull
if [ $? -eq 0 ] ; then
	rpm -qa | grep oathtool > /dev/null
	if [ $? -ne 0 ] ; then
		yum install -y oathtool
	fi
elif [ "$(cat /etc/*lease  | grep -Ei "ubuntu|debian" > /dev/null ; echo $?)" -eq 0 ] ; then
	dpkg -l | grep oathtool > /dev/null
	if [ $? -ne 0 ] ; then
		sudo apt-get install -y oathtool
	fi
fi

MFA_CODE=$(oathtool --base32 --totp ${USER_OTP_CODE})

#aws_config_env_file="$(echo $0 | xargs dirname)/aws_config_env"
aws_config_env_file="${HOME}/.aws/aws_config_env"


if [ $(whereis aws > /dev/null ; echo $?) -ne 0 ] ; then
	echo "Not install AWS CLI Command ...."

	echo -en "Do you want install aws cli command ?(yes/no) "
	read ans_awscli_install

	case ${ans_awscli_install} in
		[Yy] | [Yy][Ee][Ss] )
			install_awscli
		;;
		[Nn]|[Nn][Oo])
			exit 1
		;;
	esac
fi

if [ -f "${aws_config_env_file}" ] ; then
	source ${aws_config_env_file}
	token_expired=`date -d "${AWS_TOKEN_EXPIRE}" +'%s'`
	now_time=`date +%s`
	#echo "token_expired =  ${token_expired} /now_time = ${now_time}"
	#if [ "${token_expired}" -ge "${now_time}" ] ; then
	if [ "${now_time}" -ge "${token_expired}" ] ; then
		echo "++  get aws credential"
		rm -rf ${aws_config_env_file}

		get_aws_credential

	else
		echo -e "Not change Token"
		echo -e "${c_red} +++   run command ====>     source ${aws_config_env_file}\n\n${nc}"

		chg_provider

		exit 0
	fi
else
	get_aws_credential
fi
