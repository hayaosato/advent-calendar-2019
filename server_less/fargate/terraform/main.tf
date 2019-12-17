resource "aws_iam_role" "default" {
  name               = var.service_name
  description        = "IAM Rolw for ${var.run_task}"
  assume_role_policy = file("${var.run_task}-role.json")
}

resource "aws_iam_policy" "default" {
  name        = var.service_name
  description = "IAM Policy for ${var.run_task}"
  policy      = file("${var.run_task}-policy.json")
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${var.run_task}"
  retention_in_days = 7
}

data archive_file "default" {
  type        = "zip"
  source_dir  = "../${var.run_task}"
  output_path = "${var.run_task}.zip"
}

resource "aws_lambda_function" "default" {
  filename         = "${var.run_task}.zip"
  function_name    = var.run_task
  role             = aws_iam_role.default.arn
  handler          = "main.main"
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = "python3.7"
  environment {
    variables = {
      CLUSTER_NAME      = var.service_name
      SUBNET_ID         = var.subnet_id
      SECURITY_GROUP_ID = var.security_group_id
    }
  }
}


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
