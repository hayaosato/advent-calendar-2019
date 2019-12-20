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
      TASK_DEFINITION   = aws_ecs_task_definition.default.revision
    }
  }
}

resource "aws_s3_bucket" "default" {
  bucket = var.run_task
}

resource "aws_s3_bucket_notification" "default" {
  bucket = aws_s3_bucket.default.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.default.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.default.arn
}


// Fargate resources
resource "aws_cloudwatch_log_group" "fargate" {
  name = "/ecs/${var.service_name}"
}

resource "aws_ecs_cluster" "fargate" {
  name = var.service_name
}

resource "aws_iam_role" "fargate" {
  name               = "fargate-${var.service_name}"
  description        = "IAM Rolw for ${var.service_name}"
  assume_role_policy = file("${var.service_name}-role.json")
}

resource "aws_iam_policy" "fargate" {
  name        = "fargate-${var.service_name}"
  description = "IAM Policy for ${var.service_name}"
  policy      = file("${var.service_name}-policy.json")
}

resource "aws_iam_role_policy_attachment" "fargate" {
  role       = aws_iam_role.fargate.name
  policy_arn = aws_iam_policy.fargate.arn
}

resource "aws_ecs_task_definition" "default" {
  family                = var.service_name
  container_definitions = <<EOF
[
  {
    "name": "${var.service_name}",
    "image": "${var.ecr_image_arn}",
    "essential": true,
    "memory": 256
  }
]
EOF
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.fargate.arn
  cpu = 1024
  memory = 2048
  requires_compatibilities = ["FARGATE"]
}
