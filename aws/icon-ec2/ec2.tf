
terraform {
  required_version = ">= 1.1.7"
  required_providers {
	aws = {
	  source                = "hashicorp/aws"
	  version               = "~> 4.0"
	  #configuration_aliases = [ aws.alter ]
	}
  }
}

locals {
  InstanceName         = "${local.region_name_rule}-${var.network_node_name}-${var.instance_name}"
  InstanceName_ctz     = "${local.region_name_rule}-${var.network_node_name}-${var.ctz_instance_name}"
  InstanceName_trk     = "${local.region_name_rule}-${var.network_node_name}-${var.last_instance_name}"
  last_count           = tonumber(var.create_instance_count) - 1
  ctz_count	           = tonumber(local.last_count) - tonumber(var.ctz_node_count)


  root_volume_type_gp3 = var.root_vol_type == "gp3" ? "true" : "false"
  root_volume_type_io2 = var.root_vol_type == "io2" ? "true" : local.root_volume_type_gp3
  Root_Volume_Type     = var.root_vol_type == "io1" ? "true" : local.root_volume_type_io2

  ebs_volume_type_gp3  = var.ebs_vol_type == "gp3" ? "true" : "false"
  ebs_volume_type_io2  = var.ebs_vol_type == "io2" ? "true" : local.ebs_volume_type_gp3
  Ebs_Volume_Type      = var.ebs_vol_type == "io1" ? "true" : local.ebs_volume_type_io2

  instance_sg_lists    = [
	var.module_sg_ssh,
	var.module_sg_alb,
	var.module_sg_websocket,
	var.module_sg_ngrinder
  ]

  ec2_instance_tags = {
	Team            = var.tag_Team
	User            = var.tag_User
	Role            = var.tag_Role
	Env             = var.tag_Env
	Product         = var.tag_Product
	EC2SchedulerMSG = var.tag_Ec2schedulermsg
	_TargetGroups   = var.tag_TargetGroups
	OperatingSystem = var.tag_OperatingSystem
	Distribution    = "terraform"
	#    Poc            = var.tag_Poc
  }

}

resource "aws_instance" "post_ec2_instance" {
  count 			= var.create_instance_count >= 1 ? var.create_instance_count : 0
  ami				= data.aws_ami.get_ami.id	## Default  image => amazon-ami_YYYYMMDD(ami id: ami-02923119989715c7b)
  instance_type 	= var.aws_instance_type		## default - c5.2xlarge

  # Network setting  ## subnet_id를 입력 하지 않을 경우 default VPC로 설정 된다.
  #subnet_id 		= var.module_subnet_id[count.index % 2]
  subnet_id 		= var.module_subnet_ids[count.index % 2].id

  # Security Group Adding
  security_groups	= local.instance_sg_lists

  # Static IP setting config for EC2 instance
  #private_ip           = cidrhost(var.module_subnet_cidr[tonumber(count.index % 2)], count.index + var.start_private_ip[tonumber(count.index % 2)])

  # IAM ROLE attach
  iam_instance_profile	= data.aws_iam_instance_profile.get_iam_profile.role_name

  # ssh Key Setting
  key_name 		= var.ec2_keypair_name		### ssh keypair name

  user_data = <<EOF
        #! /bin/bash
		echo '#!/bin/bash' > ~/set_hostname.sh
		echo 'count_idx="${var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 )}"' >> ~/set_hostname.sh
		echo 'set_hostname_num=$(seq -f "%02g" "$${count_idx}" "$${count_idx}")' >> ~/set_hostname.sh
        echo "sudo hostnamectl set-hostname --static \"${var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? local.InstanceName_trk : ( var.create_ctz_set_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ) : ( var.create_ctz_set_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName )}\$${set_hostname_num}\"" >> ~/set_hostname.sh

		/bin/bash ~/set_hostname.sh
        sudo sed -i "/set-hostname/d" /etc/cloud/cloud.cfg
        sudo sed -i "/update-hostname/d" /etc/cloud/cloud.cfg
        EOF

  # tags = merge(local.ec2_instance_tags , { Name = format("%s-%02d", (var.last_instance_set_flag == "1" ? (local.last_count == count.index ? local.InstanceName_trk : local.InstanceName) : local.InstanceName ), (var.last_instance_set_flag == "1" ? (local.last_count == count.index ? "1" : (count.index + 1)) : count.index + 1))})
  tags = merge(local.ec2_instance_tags ,
	{ Name = format(
	  "%s%02d",
	  ( var.last_instance_set_flag == "1" ?
	    (
		  local.last_count == count.index ?
		  local.InstanceName_trk : (
		    var.create_ctz_set_flag == "1" ? (
			  tonumber(local.ctz_count) <= count.index ?
			    local.InstanceName_ctz :
			  local.InstanceName
			) :
			local.InstanceName
		  )
		) :
	    (
	      var.create_ctz_set_flag == "1" ?
		    (
			  tonumber(local.ctz_count) <= count.index ?
			    local.InstanceName_ctz :
			    local.InstanceName
			) :
		    local.InstanceName
	    )
	  ),
	  ( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 ) )
	)
	}
  )

  ### root or EBS volumes
  root_block_device {
	delete_on_termination	= true 			          ## system default = true
	encrypted				= false		              ## encrypted volume default "false"
	volume_size				= var.root_vol_size	      ## default size = 150 gb
	volume_type				= var.root_vol_type	      ## default "gp3"
	iops					= local.Root_Volume_Type == "true" ? var.root_vol_iops : null
	throughput				= var.root_vol_type == "gp3" ? var.root_vol_throughput : null

	tags =  {
	  name = format("%s%02d-root-device",
		( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? local.InstanceName_trk : ( var.create_ctz_set_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ) : ( var.create_ctz_set_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ),
		( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 ) )
	  )
	}
  }

  ebs_block_device {
#	count					= var.ebs_blockdevice_set_flag == "true" ? 1 : 0
	device_name				= "/dev/sdb"
	delete_on_termination	= true 				        ## system default = true
	encrypted				= false			        	## encrypted volume default "false"
	volume_type				= var.ebs_blockdevice_set_flag == "true" ? var.ebs_vol_type : null	## default "gp3"
	volume_size				= var.ebs_blockdevice_set_flag == "true" ? var.ebs_vol_size : null 	## default size = 150 gb
	iops					= var.ebs_blockdevice_set_flag == "true" ? ( local.Ebs_Volume_Type == "true" ? var.ebs_vol_iops : null ) : null
	throughput				= var.ebs_blockdevice_set_flag == "true" ? ( var.ebs_vol_type == "gp3" ? var.ebs_vol_throughput : null ) : null

	tags =  {
	  name = format("%s%02d-ebs-device",
		( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? local.InstanceName_trk : ( var.create_ctz_set_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ) : ( var.create_ctz_set_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ),
		( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_set_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 ) )
	  )
	}
  }
}

resource "time_sleep" "wait_time_ec2_instance" {
  depends_on = [aws_instance.post_ec2_instance]

  create_duration = "10s"
}

data "aws_instances" "get_instance_peer_list" {

  filter {
	name   = "tag:Name"
	values = ["${local.InstanceName}*"]
  }

  depends_on = [time_sleep.wait_time_ec2_instance]
}

###############################################################################################################
# output

output "print_instance_name" {
  value = local.instance_name
}
output "Instance_ids" {
  #value = tolist(aws_instance.post_instance.*.id)
  value = tolist(aws_instance.post_ec2_instance.*.id)
}
##### instance id list
output "print_ec2_ids" {
  value = data.aws_instances.get_instance_peer_list.ids
}

#### print Instance private IP
output "print_private_ips" {
  value = tolist(data.aws_instance.get_instance_ip.*.private_ip)
}

output "print_public_ips" {
  value = tolist(data.aws_instance.get_instance_ip.*.public_ip)
}

output "print_instanceType_real" {
  value = tolist(data.aws_instance.get_instance_ip.*.instance_type)
}

