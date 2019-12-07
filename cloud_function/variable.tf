variable "credential_path" {
  description = "Path to credential"
}

variable "project_name" {
  description = "Name of the GCP project"
}

variable "SLACK_API_KEY" {
  description = "Slack API Token"
}

variable "service_name" {
  description = "Name of the service"
  default     = "munesato_service"
}

variable "region" {
  default = "asia-northeast1"
}

variable "available_memory_mb" {
  description = "Memory (in MB), available to the function. Default value is 256MB. Allowed values are: 128MB, 256MB, 512MB, 1024MB, and 2048MB."
  default     = 128
}

variable "entry_point" {
  description = "Name of the function that will be executed when the Google Cloud Function is triggered."
  default     = "main"
}

