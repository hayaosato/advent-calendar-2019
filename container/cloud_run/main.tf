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
