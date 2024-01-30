variable "function_name" {
  type = string
  description = "The lambda function name."
  default = "detector-lambda"
}

variable "repository_name" {
  type = string
  description = "The ECR name."
  default = "ocv-dnn-detector-lambda"
}

variable "image_tag" {
  type = string
  description = "(default: latest) The image tag to use."
  default = "latest"
}

variable "log_group_retention_in_days" {
  type = number
  description = "(default: 7) The number of days to store cloudwatch logs."
  default = 7
}

variable "memory_size" {
  type = number
  description = "(default: 1024) Lambda memory allotment."
  default = 1024
}

variable "timeout" {
  type = number
  description = "(default: 10) Lambda timeout limit."
  default = 10
}
