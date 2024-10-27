# Variable to signal the current environment 
variable "env" {
  type        = string
  description = "Deployment Environment"
}

# Default tags
variable "default_tags" {
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

variable "namespace" {
  type        = string
  description = "Namespace"
}

# Provision public subnets in custom VPC
variable "public_cidr_blocks" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# VPC CIDR range
variable "vpc_cidr" {
  type        = string
  description = "VPC to host static web site"
}



