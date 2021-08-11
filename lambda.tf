resource "aws_lambda_function" "lambda_tf" {
    filename            = "lambda.zip"
    function_name       = "lambda_handler"
    role                = "${aws_iam_role.ram_for_lambda.arn}"
    handler             = "lambda.lambda_handler"
    runtime             = "python3.7"

    source_code_hash = "${filebase4sha256("lambda.zip")}"
    depends_on       = ["aws_iam_role.iam_for_lambda"]
      
    } 

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
    name                = "/aws/lambda/${aws_lambda_function.lambda_tf.function_name}"
    retention_in_days   =   14
    depends_on          =   ["aws_lambda_function.lambda_tf"]
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
 
}

output "lambdafunction-details" {
    value = "${aws_lambda_function.lambda_tf}"
}