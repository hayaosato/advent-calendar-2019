provider "google" {
  credentials = file(var.credential_path)
  project     = var.project_name
  region      = var.region
}

provider "archive" {}
