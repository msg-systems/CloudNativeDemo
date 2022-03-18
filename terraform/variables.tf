# TF_VAR_region
variable "region" {
  description = "The name of the AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "profile" {
  description = "The name of the AWS profile in the credentials file"
  type        = string
  default     = "default"
}

variable "app_repo_name" {
  description = "The repository name for the application repository to create, several resources base their name on this"
  type        = string
}

variable "app_conatiner_port" {
  description = "The port of the running container"
  type        = number
  default     = 8910
}
