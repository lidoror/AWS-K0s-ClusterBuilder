
provider "aws" {
  region = var.region_to_deploy
}


//S3 BUCKET
resource "aws_s3_bucket" "bucket_1" {
  bucket = "${var.resource_alias}-${terraform.workspace}"
  tags = {
    Terraform = "true"
    Creator = var.resource_alias
    Env = terraform.workspace
  }
}

resource "aws_s3_bucket_versioning" "dev_bucket_versioning" {
  bucket = aws_s3_bucket.bucket_1.id
  versioning_configuration {
    status = "Enabled"
  }
}

//SECURITY GROUPS


resource "aws_security_group" "k0s_sg_master" {
  name = "k0s_sg-master"
  vpc_id = module.app_vpc.vpc_id

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  //DASHBOARD PORT
  ingress {
    from_port = 30001
    protocol  = "tcp"
    to_port   = 30001
    cidr_blocks = ["0.0.0.0/0"]
  }
  //API SERVER
  ingress {
    from_port = 6443
    protocol  = "tcp"
    to_port   = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Terraform = "true"
    Instance = "k0s-master-sg"
  }
}


resource "aws_security_group" "k0s_sg_nodes" {
  name = "k0s_sg-workers"
  vpc_id = module.app_vpc.vpc_id

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  //API SERVER
  ingress {
    from_port = 6443
    protocol  = "tcp"
    to_port   = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }
//KUBELET (10250) - kube-scheduler (10251) - kube-controller-manager (10252)
  ingress {
    from_port = 10250
    to_port   = 10252
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
// KUBE PROXY
  ingress {
    from_port = 10256
    to_port   = 10256
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
//Calico VXLAN overlay (connection between workers)
  ingress {
    from_port = 4789
    to_port   = 4789
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
//konnectivity server
  ingress {
    from_port = 8132
    to_port   = 8133
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Terraform = "true"
    Instance = "k0s-node-sg"
  }
}

//EIP ASSOCIATION
resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2_instance_k0s_master.id
  allocation_id = data.aws_eip.k0s_master_cluster_eip.id
}