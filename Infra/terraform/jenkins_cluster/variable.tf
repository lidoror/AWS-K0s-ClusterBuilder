
//REGION
variable "region_to_deploy" {
  description = "The region of the project deployment"
  type = string
}


variable "resource_alias" {
  description = "Resource creator name"
  type        = string
}


//VPC VARS
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
}

//INSTANCE VARS
variable "ec2_instance_type" {
  description = "instance we use for the project"
  type = list(string)
}

variable "instance_key_tag" {
  description = "tag of the ssh key"
  type = string
}

