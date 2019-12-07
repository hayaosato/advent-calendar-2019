data "archive_file" "source" {
  type        = "zip"
  source_dir  = "src"
  output_path = "${var.service_name}.zip"
}

resource "google_storage_bucket" "source" {
  name     = "${var.service_name}_source"
  location = "${var.region}"
  labels = {
    service = var.service_name
    source  = "true"
  }
}

resource "google_storage_bucket_object" "source" {
  name   = "${var.service_name}.zip"
  bucket = google_storage_bucket.source.name
  source = "${var.service_name}.zip"
}

resource "google_storage_bucket" "trigger" {
  name     = "${var.service_name}_trigger"
  location = "${var.region}"
  labels = {
    service = var.service_name
  }
  force_destroy = true
}

resource "google_cloudfunctions_function" "default" {
  name        = var.service_name
  description = "Function of ${var.service_name}"
  runtime     = "python37"

  available_memory_mb   = var.available_memory_mb
  source_archive_bucket = google_storage_bucket.source.name
  source_archive_object = google_storage_bucket_object.source.name
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.trigger.name
  }
  entry_point = var.entry_point

  environment_variables = {
    SLACK_API_KEY = var.SLACK_API_KEY
  }
}
