
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
    description = "SSH"
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Server"
    from_port = 6443
    protocol  = "tcp"
    to_port   = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "KUBELET (10250) - kube-scheduler (10251) - kube-controller-manager (10252)"
    from_port = 10250
    to_port   = 10252
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "KUBE PROXY"
    from_port = 10256
    to_port   = 10256
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Calico VXLAN overlay (connection between workers)"
    from_port = 4789
    to_port   = 4789
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "konnectivity server"
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


resource "aws_iam_policy" "k0s_master_iam_policy" {
  name = "${var.resource_alias}-k0s_master_policy"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:UpdateAutoScalingGroup",
            "ec2:AttachVolume",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateRoute",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:CreateVolume",
            "ec2:DeleteRoute",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteVolume",
            "ec2:DescribeInstances",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumesModifications",
            "ec2:DescribeVpcs",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeAvailabilityZones",
            "ec2:DetachVolume",
            "ec2:ModifyInstanceAttribute",
            "ec2:ModifyVolume",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInternetGateways",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
            "elasticloadbalancing:AttachLoadBalancerToSubnets",
            "elasticloadbalancing:ConfigureHealthCheck",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateLoadBalancerListeners",
            "elasticloadbalancing:CreateLoadBalancerPolicy",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteLoadBalancerListeners",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeLoadBalancerPolicies",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:DetachLoadBalancerFromSubnets",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
            "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
            "kms:DescribeKey"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
            }
          }
        }
      ]
    }
  )
}


resource "aws_iam_role" "k0s_master_role" {
  name = "${var.resource_alias}-k0s-master-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags = {
    Name: "${var.resource_alias}-k0s-master-role"
    Terraform: "true"
  }
}

resource "aws_iam_role_policy_attachment" "k0s_role_policy_attachment" {
  policy_arn = aws_iam_policy.k0s_master_iam_policy.arn
  role       = aws_iam_role.k0s_master_role.name

}

resource "aws_iam_instance_profile" "k0s_master_instance_profile" {
  name = "${var.resource_alias}-k0s-master-instance-profile"
  role = aws_iam_role.k0s_master_role.name
}

resource "local_file" "instances_ip" {
  filename = "instances_ip"
  content  = jsonencode({
    k0s_master = module.ec2_instance_k0s_master.public_ip,
    nodes      = values(module.ec2_instance_k0s_workers)[*].public_ip
  })
}