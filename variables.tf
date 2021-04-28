variable "region" {}
variable "vpc-id" {}
variable "cluster-name" {}
variable "eks-version" {}
variable "nodes-version" {}

variable "primary-instance-type" {
  type = string
}
variable "cluster-subnets-ids" {
  type    = list(string)
}
variable "primary-node-subnets-ids"{
  type = list(string)
}
variable "spot-node-subnets-ids"{
  type = list(string)
}
variable "spot-instance-types" {
  type    = list(string)
  default = []
}
variable "primary-nodes-count" {
  default = "1"
}
variable "primary-max-nodes-count" {
  default = "5"
}
variable "primary-min-nodes-count" {
  default = "1"
}
variable "eks-additional-security-groups" {
  type    = list(string)
  default = []
}
variable "nodes-additional-security-groups" {
  type    = list(string)
  default = []
}
variable "enable-private-access" {
  default = true
}
variable "enable-public-access" {
  default = false
}
variable "tags" {
  type = map(string)
}
variable "enable-spot-instances" {
  type = bool
}
   
