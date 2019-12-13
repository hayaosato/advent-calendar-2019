resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "docker build -t ${var.image_name} ${var.docker_dir}"
  }

  provisioner "local-exec" {
    command = "gcloud auth configure-docker"
  }

  provisioner "local-exec" {
    command = "docker tag ${var.image_name} ${var.hostname}/${var.project_id}/${var.image_name}"
  }

  provisioner "local-exec" {
    command = "docker push ${var.hostname}/${var.project_id}/${var.image_name}"
  }
}

resource "google_cloud_run_service" "default" {
  name     = "${var.image_name}"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.hostname}/${var.project_id}/${var.image_name}"
        resources {
          limits = { "memory" : "512Mi" }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
