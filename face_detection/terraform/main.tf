
// IAM for Lambda Function
resource "aws_iam_role" "start_face_detection" {
  description        = "The role for start face detection"
  name               = var.start_face_detection
  assume_role_policy = file("policies/${var.start_face_detection}-role.json")
}

resource "aws_iam_policy" "start_face_detection" {
  description = "The policy for start face detection"
  name        = var.start_face_detection
  policy      = file("policies/${var.start_face_detection}-policy.json")
}

resource "aws_iam_role_policy_attachment" "start_face_detection" {
  role       = aws_iam_role.start_face_detection.name
  policy_arn = aws_iam_policy.start_face_detection.arn
}

// IAM for call sns from rekognition
resource "aws_iam_role" "call_sns_from_rekognition" {
  description        = "The role for rekognition to call sns"
  name               = "call-sns-from-rekognition"
  assume_role_policy = file("policies/call-sns-from-rekognition-role.json")
}

resource "aws_iam_policy" "call_sns_from_rekognition" {
  description = "The policy for rekognition to call sns"
  name        = "call-sns-from-rekognition"
  policy      = file("policies/call-sns-from-rekognition-policy.json")
}

resource "aws_iam_role_policy_attachment" "call_sns_from_rekognition" {
  role       = aws_iam_role.call_sns_from_rekognition.name
  policy_arn = aws_iam_policy.call_sns_from_rekognition.arn
}

// Lambda Function
data "archive_file" "start_face_detection" {
  type        = "zip"
  source_dir  = "../${var.start_face_detection}"
  output_path = "../output/${var.start_face_detection}.zip"
}

resource "aws_cloudwatch_log_group" "start_face_detection" {
  name              = "/aws/lambda/${var.start_face_detection}"
  retention_in_days = 7
}

resource "aws_lambda_function" "start_face_detection" {
  filename      = "../output/${var.start_face_detection}.zip"
  function_name = var.start_face_detection
  role          = aws_iam_role.start_face_detection.arn

  handler          = "main.main"
  source_code_hash = data.archive_file.start_face_detection.output_base64sha256
  runtime          = "python3.7"

  environment {
    variables = {
      ROLE_ARN      = aws_iam_role.call_sns_from_rekognition.arn
      SLACK_API_KEY = var.SLACK_API_KEY
      SNS_TOPIC_ARN = aws_sns_topic.get_face_detection.arn
    }
  }
}

resource "aws_lambda_permission" "start_face_detection" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_face_detection.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.start_face_detection.arn
}

resource "aws_s3_bucket" "start_face_detection" {
  bucket = "hoge-${var.environment}-${var.start_face_detection}"
}

resource "aws_s3_bucket_notification" "start_face_detection" {
  bucket = aws_s3_bucket.start_face_detection.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.start_face_detection.arn
    events              = ["s3:ObjectCreated:*"]
  }
}


// get face detection
resource "aws_iam_role" "get_face_detection" {
  description        = "The role for get face detection"
  name               = var.get_face_detection
  assume_role_policy = file("policies/${var.get_face_detection}-role.json")
}

resource "aws_iam_policy" "get_face_detection" {
  description = "The policy for get face detection"
  name        = var.get_face_detection
  policy      = file("policies/${var.get_face_detection}-policy.json")
}

resource "aws_iam_role_policy_attachment" "get_face_detection" {
  role       = aws_iam_role.get_face_detection.name
  policy_arn = aws_iam_policy.get_face_detection.arn
}

data "archive_file" "get_face_detection" {
  type        = "zip"
  source_dir  = "../${var.get_face_detection}"
  output_path = "../output/${var.get_face_detection}.zip"
}

resource "aws_cloudwatch_log_group" "get_face_detection" {
  name              = "/aws/lambda/${var.get_face_detection}"
  retention_in_days = 7
}

resource "aws_lambda_function" "get_face_detection" {
  filename      = "../output/${var.get_face_detection}.zip"
  function_name = var.get_face_detection
  role          = aws_iam_role.get_face_detection.arn

  handler          = "main.main"
  source_code_hash = data.archive_file.get_face_detection.output_base64sha256
  runtime          = "python3.7"

  environment {
    variables = {
      SLACK_API_KEY = var.SLACK_API_KEY
    }
  }
}

resource "aws_lambda_permission" "get_face_detection" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_face_detection.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.get_face_detection.arn
}

resource "aws_sns_topic" "get_face_detection" {
  name            = var.get_face_detection
  delivery_policy = file("policies/sns-delivery-policy.json")
}

resource "aws_sns_topic_subscription" "get_face_detection" {
  topic_arn = aws_sns_topic.get_face_detection.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.get_face_detection.arn
}
