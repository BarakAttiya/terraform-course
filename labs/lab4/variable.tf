variable "environment" {
  description = "Define the environment type: dev, staging, or prod"
  type        = string
  default     = "prod" # dev
}

variable "high_availability" {
  description = "Whether to enable high availability (true or false)"
  type        = bool
  default     = true # false
}