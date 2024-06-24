variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Region in which terraform manages EKS cluster"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr"
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}


variable "node_group_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "project-name" {
  type    = string
  default = "DEMO-EKS"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "dev"
    "owners"      = "govardhan"
  }
}

variable "eks_node_role_policy" {
  type = set(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}