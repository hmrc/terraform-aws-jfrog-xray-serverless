variable "environment_name" {
  type        = string
  default     = "jfrog-xray"
  description = "The name of the environment. Used for the names of various resources."
}

variable "security_group_id" {
  type        = string
  description = "Security group to use for all the things. Probably will be replaced."
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
