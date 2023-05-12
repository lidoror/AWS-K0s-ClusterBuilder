data "aws_ami" "amazon_linux_ami" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ec2_instance_type_offering" "ec2_instance_type" {
  filter {
    name   = "instance-type"
    values = var.ec2_instance_type
  }
  preferred_instance_types = var.ec2_instance_type
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_key_pair" "servers_key" {
  include_public_key = true

  filter {
    name   = "tag:Owner"
    values = [var.instance_key_tag]
  }
}

data "aws_availability_zones" "available_azs_ids" {
  state = "available"
}

data "aws_eip" "k0s_master_cluster_eip" {
  filter {
    name   = "tag:Owner"
    values = ["lidoror-k0s-master"]
  }
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
