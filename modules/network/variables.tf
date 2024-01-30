variable "vpc_name" {
  type = string
  description = "(default: vpc-rcv) The VPC name."
  default = "vpc-rcv"
}

variable "vpc_cidr_block" {
  type = string
  description = "(default: 10.0.0.0/16) The VPC cidr block to use."
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type = string
  description = "(default: 10.0.0.0/20) The VPC subnet cidr block to use."
  default = "10.0.0.0/20"
}
