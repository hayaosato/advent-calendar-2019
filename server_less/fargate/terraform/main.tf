resource "aws_ecs_cluster" "default" {
  name = var.service_name
}

resource "aws_ecs_task_definition" "default" {
  family                = var.service_name
  container_definitions = <<EOF
[
  {
    "name": "first",
    "image": "244178420992.dkr.ecr.ap-northeast-1.amazonaws.com/sample-python",
    "essential": true,
    "memory": 256
  }
]
EOF
}
