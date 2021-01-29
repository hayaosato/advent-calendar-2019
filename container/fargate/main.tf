resource "aws_ecr_repository" "default" {
  name                 = var.image_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "$(aws ecr get-login --no-include-email --region ${var.region})"
  }

  provisioner "local-exec" {
    command = "docker build -t ${var.image_name} ${var.docker_dir}"
  }

  provisioner "local-exec" {
    command = "docker tag ${var.image_name}:latest ${aws_ecr_repository.default.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.default.repository_url}"
  }
}
