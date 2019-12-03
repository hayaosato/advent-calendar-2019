// IAM Role for Lambda Function
resource "aws_iam_role" "default" {
  name               = var.service_name
  description        = "IAM Rolw for ${var.service_name}"
  assume_role_policy = file("${var.service_name}-role.json")
}

resource "aws_iam_policy" "default" {
  name        = var.service_name
  description = "IAM Policy for ${var.service_name}"
  policy      = file("${var.service_name}-policy.json")
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

// Lambda Function Resources
resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${var.service_name}"
  retention_in_days = 7
}

data archive_file "default" {
  type        = "zip"
  source_dir  = "src"
  output_path = var.output_path
}

resource "aws_lambda_function" "default" {
  filename         = var.output_path
  function_name    = var.service_name
  role             = aws_iam_role.default.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = "python3.6"
  environment {
    variables = {
      SLACK_API_KEY = var.SLACK_API_KEY
    }
  }
}

// SNS Resources
resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.default.arn
}

resource "aws_sns_topic" "default" {
  name            = var.service_name
  delivery_policy = file("sns_delivery_policy.json")
}

resource "aws_sns_topic_subscription" "default" {
  topic_arn = aws_sns_topic.default.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.default.arn
}
