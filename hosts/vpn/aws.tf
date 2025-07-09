provider "aws" {
	region = "us-east-1"
}

data "aws_ami" "nixos_arm64" {
	owners      = [ "427812963091" ]
	most_recent = true
	filter {
		name   = "name"
		values = [ "nixos/24.11*" ]
	}
	filter {
		name   = "architecture"
		values = [ "arm64" ]
	}
}

resource "aws_key_pair" "deployer" {
	key_name   = "vpn-deployer"
	public_key = file("~/.ssh/aws.pub")
}

resource "aws_security_group" "vpn" {
	name        = "vpn-sg"
	description = "ssh, wireguard"
	ingress {
		from_port   = 51820
		to_port     = 51820
		protocol    = "udp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
}

resource "aws_instance" "vpn" {
	ami                         = data.aws_ami.nixos_arm64.id
	instance_type               = "t4g.micro"
	key_name                    = aws_key_pair.deployer.key_name
	vpc_security_group_ids      = [ aws_security_group.vpn.id ]
	associate_public_ip_address = true

	root_block_device {
		volume_type = "gp3"
		volume_size = 20
		encrypted   = true
	}

	ebs_block_device {
		device_name = "/dev/xvdh"
		volume_size = 50
		volume_type = "gp3"
		encrypted   = true
	}
}

output "public_ip" {
	value = aws_instance.vpn.public_ip
}
