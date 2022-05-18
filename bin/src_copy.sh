#!/bin/bash 

remote_ip="20.20.5.74"
remote_user="root"
remote_path="/app/terraform/new/aws"

local_path="${HOME}/work/hnsong/terraform/aws"

ssh_cmd="ssh -oStrictHostKeyChecking=no"
scp_cmd="scp -oStrictHostKeyChecking=no"

ssh_keyfile="${HOME}/aws-key/loopvm.pem"
rsync_opt="-avPzl -r --progress --delete "

echo "rsync ${rsync_opt} -e \"${ssh_cmd} -i ${ssh_keyfile}\" ${local_path}/* ${remote_user}@${remote_ip}:${remote_path}/"
rsync ${rsync_opt} -e "${ssh_cmd} -i ${ssh_keyfile}" ${local_path}/* ${remote_user}@${remote_ip}:${remote_path}/
