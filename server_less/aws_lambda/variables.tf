variable "service_name" {
  default     = "difference_lambda"
  description = "The service name of Architecture"
}

variable "output_path" {
  default     = "output.zip"
  description = "Name of the output zip file"
}

variable "SLACK_API_KEY" {
  description = "Slack API Token"
}
