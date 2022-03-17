### Terraform v0.14.7
###  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance


######++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
######++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

locals {
  InstanceName 		= "${local.region_name_rule}-${var.network_node_name}-${var.instance_name}"
  InstanceName_ctz 	= "${local.region_name_rule}-${var.network_node_name}-${var.ctz_node_instance_name}"
  InstanceName_trk 	= "${local.region_name_rule}-${var.network_node_name}-${var.last_instance_name}"
  last_count		= tonumber(var.create_instance_count) - 1 
  ctz_count		= tonumber(local.last_count) - tonumber(var.ctz_node_count)
}

resource "aws_instance" "create_instance" {
  count 		= var.create_instance_count
  ami			= data.aws_ami.get_ami.id	## Default  iamge => amazon-ami_YYYYMMDD(ami id: ami-02923119989715c7b)
  instance_type 	= var.aws_instance_type		## default - c5.2xlarge

  ## Network seting   ## subnet_id를 입력하지 않을 경우 default VPC로 설정된다. 
  subnet_id 		= var.module_subnet_id[count.index % 2]

  ### Security Group Adding
  security_groups	= local.instance_sg_lists

  ### Static IP setting config for EC2 instance
  #private_ip           = cidrhost(var.module_subnet_cidr[tonumber(count.index % 2)], count.index + var.start_private_ip[tonumber(count.index % 2)])

  ### IAM ROLE attach
  iam_instance_profile	= data.aws_iam_instance_profile.get_iam_profile.role_name

  ### ssh Key Setting 
  key_name 		= var.ec2_keypair_name		### ssh keypair name


  user_data = <<EOF
                #! /bin/bash
		echo '#!/bin/bash' > ~/set_hostname.sh
		echo 'count_idx="${var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 )}"' >> ~/set_hostname.sh
		echo 'set_hostname_num=$(seq -f "%02g" "$${count_idx}" "$${count_idx}")' >> ~/set_hostname.sh
                echo "sudo hostnamectl set-hostname --static \"${var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? local.InstanceName_trk : ( var.create_ctz_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ) : ( var.create_ctz_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName )}\$${set_hostname_num}\"" >> ~/set_hostname.sh
		/bin/bash  ~/set_hostname.sh
                sudo sed -i "/set-hostname/d" /etc/cloud/cloud.cfg
                sudo sed -i "/update-hostname/d" /etc/cloud/cloud.cfg
        EOF

  #tags = merge(local.ec2_instance_tags , { Name = format("%s-%02d", (var.last_instance_set_flag == "1" ? (local.last_count == count.index ? local.InstanceName_trk : local.InstanceName) : local.InstanceName ), (var.last_instance_set_flag == "1" ? (local.last_count == count.index ? "1" : (count.index + 1)) : count.index + 1))})
  tags = merge(local.ec2_instance_tags ,
                 { Name = format("%s%02d",
                                  ( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? local.InstanceName_trk : ( var.create_ctz_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ) : ( var.create_ctz_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ),
                                  ( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 ) ) 
			)
                 }
              )

  ### root or EBS volumes
  root_block_device {
    delete_on_termination 	= true 				## system default = true 
    encrypted 		  	= false				## encrypted Volume default "false" 
    iops			= var.root_vol_iops
    volume_type 		= var.instance_root_vol_type	## default "gp3"
    volume_size 		= var.instance_root_vol_size	## Default size = 150 GB

    tags =  {
       Name = format("%s%02d-root-device", 
                                  ( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? local.InstanceName_trk : ( var.create_ctz_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ) : ( var.create_ctz_flag == "1" ? ( tonumber(local.ctz_count) <= count.index ? local.InstanceName_ctz : local.InstanceName) : local.InstanceName ) ),
                                  ( var.last_instance_set_flag == "1" ? ( local.last_count == count.index ? "1" : ( var.create_ctz_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1) :  count.index + 1) ) : ( var.create_ctz_flag == "1" ? ( local.ctz_count <= count.index ? ( count.index + 1 - tonumber(local.ctz_count) ) : count.index + 1 ) : count.index + 1 ) ) 
                    )
    }
  }
}


resource "time_sleep" "wait_time_ec2" {
  depends_on = [aws_instance.create_instance]

  create_duration = "10s"
}

data "aws_instances" "get_instance_peer_list" {

  filter {
    name   = "tag:Name"
    values = ["${local.InstanceName}*"]
  }
  
  depends_on = [time_sleep.wait_time_ec2]
}


########
resource "aws_ebs_volume" "create_ebs_vol" {
  availability_zone = "us-west-2a"
  size              = 40
  type		    = "gp3"    	## EBS Volume type "gp2" or "gp3" or "io2" or "io3"
  iops		    = "3000"    ## default = 3000 / only type 
  throughput	    = "256" 	## default = 256

  tags = {
    Name = "HelloWorld"
  }
}
