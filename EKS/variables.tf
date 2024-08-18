variable "region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "The availability zones to use"
  type = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "instance_type" {
  description = "The type of instance to use"
  default     = "t2.micro"
}

variable "cluster_name" {
  description = "The name of EKS Cluster"
  default = "eks-poc-cluster"
}

variable "cluster_version" {
  description = "EKS Cluster version"
  default = "1.29"
}

variable "enable_cluster_log_types" {
  type = list(string)
  default = [ "api", "authenticator", "audit", "scheduler", "controllerManager" ]
}

variable "instance_types" {
  description = "EKS Cluster node group instance type"
  default = "t3.small"
}

variable "desired_size" {
  default = "2"
}

variable "max_size" {
  default = "5"
}

variable "min_size" {
  default = "2"
}

variable "max_unavailable" {
  default = "1"
}

variable "csi_driver" {
  default = "v1.32.0-eksbuild.1"
}

# variable "ami_id" {}

# variable "alb_ingress" {}
# variable "alb_ingress_image_tag" {}


# variable "domain" {}
# variable "hosted_zone_id" {}
# variable "environment" {}
# variable "external_dns" {}