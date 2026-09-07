
variable "project_tag" {
  description = "The Tag used to identify all resources belonging to this project"
  type        = string
  default     = "week2-vpc-lab"
}

variable "region" {
  description = "The aws region where the infrastructure is deployed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC"
  type        = string
  default     = "10.0.0.0/16"

}
variable "public_subnet_cidr" {
  description = "The CIDR of the public subnet"
  type        = string
  default     = "10.0.1.0/24"

}
variable "private_subnet_cidr" {
  description = "The CIDR of the private subnet"
  type        = string
  default     = "10.0.2.0/24"

}
variable "availability_zone" {
  description = "Tha availablity zone of the proposed infrastructure"
  type        = list(string)
  default     = ["us-east-1a"]

}

variable "instance_type" {
  description = "The EC2 instance"
  type        = string
  default     = "t3.micro"

}

variable "allowed_account_id" {
  description = "The list of accounts to which a particular infrastructure build is supposed to happen"
  type        = list(string)

}

