variable "environment_name" {
  type        = string
  default     = "jfrog-xray"
  description = "The name of the environment. Used for the names of various resources."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to run the JFrog Xray resources in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to run the JFrog Xray resources in."
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Set whether to give the Xray task a public IP. Only turn this on if testing with only an internet gateway."
}

variable "database_subnet_group" {
  type        = string
  description = "This is probabably temporary too like."
}

variable "xray_version" {
  type        = string
  description = "Version of JFrog Xray you wish to run."
  default     = "3.36.2"
}

variable "artifactory_url" {
  type        = string
  description = "URL of the JFrog Artifactory/Platform service that Xray will be joined to."
}

variable "artifactory_join_key" {
  type        = string
  description = "Key to use in order to join Xray to the JFrog Artifactory/Platform service."
}

variable "xray_task_memory" {
  type        = number
  default = 2048
  description = "Amount of memory to be used for the Xray Fargate task."
}

variable "xray_task_cpu" {
  type        = number
  default = 1024
  description = "CPU value to be used for the Xray Fargate task."
}
