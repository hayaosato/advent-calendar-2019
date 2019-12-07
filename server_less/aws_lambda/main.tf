// IAM Role for Lambda Function
resource "aws_iam_role" "default" {
  name               = var.service_name
  description        = "IAM Rolw for ${var.service_name}"
  assume_role_policy = file("policies/${var.service_name}-role.json")
}

resource "aws_iam_policy" "default" {
  name        = var.service_name
  description = "IAM Policy for ${var.service_name}"
  policy      = file("policies/${var.service_name}-policy.json")
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
  output_path = "${var.service_name}.zip"
}

resource "aws_lambda_function" "default" {
  filename         = "${var.service_name}.zip"
  function_name    = var.service_name
  role             = aws_iam_role.default.arn
  handler          = "main.main"
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = "python3.7"
  environment {
    variables = {
      SLACK_API_KEY = var.SLACK_API_KEY
    }
  }
}

// SNS Resources
resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.default.arn
}

resource "aws_s3_bucket" "default" {
  bucket = var.service_name
}

resource "aws_s3_bucket_notification" "default" {
  bucket = aws_s3_bucket.default.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.default.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
