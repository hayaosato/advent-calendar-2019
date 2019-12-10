resource "aws_ecr_repository" "default" {
  name                 = "beego-sample"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
