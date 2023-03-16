locals {
  snapshot_resource_name     = "${var.name}-snapshot"
  snapshot_enabled_count     = var.s3_snapshots_enabled ? 1 : 0
  snapshot_enabled_vpc_count = var.s3_snapshots_enabled && var.vpc_id != null ? 1 : 0
}

## BUCKET

resource "aws_s3_bucket" "snapshot" {
  count = local.snapshot_enabled_count

  bucket = local.snapshot_resource_name
  acl    = "private"
  tags   = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "snapshot" {
  count = local.snapshot_enabled_count

  bucket                  = aws_s3_bucket.snapshot[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "deny_all_except_es" {
  count = local.snapshot_enabled_count

  bucket = aws_s3_bucket.snapshot[0].id
  policy = data.aws_iam_policy_document.deny_all_except_es[0].json
}

data "aws_iam_policy_document" "deny_all_except_es" {
  count = local.snapshot_enabled_count

  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.snapshot[0].arn}/*",
    ]

    condition {
      test     = "ForAnyValue:StringNotEquals"
      variable = "aws:PrincipalArn"

      values = [
        aws_iam_role.snapshot_create[0].arn
      ]
    }
  }
}

## CW LOGS

resource "aws_cloudwatch_log_group" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  name              = "/aws/lambda/${var.name}-snapshot"
  tags              = var.tags
  retention_in_days = var.s3_snapshots_logs_retention
}

## CREATE SNAPSHOT IAM ROLE

data "aws_iam_policy_document" "snapshot_create_assume" {
  count = local.snapshot_enabled_count

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "snapshot_create" {
  count = local.snapshot_enabled_count

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.snapshot[0].arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.snapshot[0].arn}/*"]
  }
}

resource "aws_iam_role" "snapshot_create" {
  count = local.snapshot_enabled_count

  name               = "${local.snapshot_resource_name}-s3put"
  description        = "Role used by OpenSearch for snapshotting to S3"
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.snapshot_create_assume[0].json
}

resource "aws_iam_role_policy" "snapshot_create" {
  count = local.snapshot_enabled_count

  role   = aws_iam_role.snapshot_create[0].id
  policy = data.aws_iam_policy_document.snapshot_create[0].json
}

## LAMBDA IAM ROLE

data "aws_iam_policy_document" "snapshot_lambda_assume" {
  count = local.snapshot_enabled_count

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.snapshot_create[0].arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["es:ESHttp*"]
    resources = ["${aws_elasticsearch_domain.es.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.snapshot_lambda[0].arn,
      "${aws_cloudwatch_log_group.snapshot_lambda[0].arn}:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  name               = "${local.snapshot_resource_name}-lambda"
  description        = "Role for the Elasticsearh snapshot Lambda function"
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.snapshot_lambda_assume[0].json
}

resource "aws_iam_role_policy" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  role   = aws_iam_role.snapshot_lambda[0].id
  policy = data.aws_iam_policy_document.snapshot_lambda[0].json
}

## SG

resource "aws_security_group" "snapshot_lambda" {
  count = local.snapshot_enabled_vpc_count

  name        = local.snapshot_resource_name
  description = "Security group for the ${var.name}-snapshot Lambda function"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "snapshot_lambda_egress" {
  count = local.snapshot_enabled_vpc_count

  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.snapshot_lambda[0].id
  source_security_group_id = aws_security_group.sg[0].id
}

resource "aws_security_group_rule" "snapshot_lambda_ingress" {
  count = local.snapshot_enabled_vpc_count

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg[0].id
  source_security_group_id = aws_security_group.snapshot_lambda[0].id
}

## LAMBDA

## Enable to (re-)build the zip
# data "archive_file" "snapshot_lambda" {
#   count = local.snapshot_enabled_count

#   type        = "zip"
#   output_path = "${path.module}/snapshot_lambda.zip"
#   source_dir  = "${path.module}/functions/"
# }

resource "aws_lambda_function" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  function_name = local.snapshot_resource_name
  description   = "Function to create S3-based OpenSearch snapshots"
  tags          = var.tags

  runtime          = "python3.8"
  handler          = "snapshot.lambda_handler"
  filename         = "${path.module}/snapshot_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/snapshot_lambda.zip")
  role             = aws_iam_role.snapshot_lambda[0].arn
  timeout          = var.s3_snapshots_lambda_timeout

  environment {
    variables = {
      BUCKET     = aws_s3_bucket.snapshot[0].id
      HOST       = aws_elasticsearch_domain.es.endpoint
      REGION     = data.aws_region.current.name
      REPOSITORY = "s3-manual"
      RETENTION  = var.s3_snapshots_retention
      ROLE_ARN   = aws_iam_role.snapshot_create[0].arn
    }
  }

  dynamic "vpc_config" {
    for_each = try([var.vpc_id], [])

    content {
      security_group_ids = aws_security_group.snapshot_lambda.*.id
      subnet_ids         = var.subnet_ids
    }
  }

  depends_on = [aws_cloudwatch_log_group.snapshot_lambda]
}

resource "aws_cloudwatch_event_rule" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  name                = local.snapshot_resource_name
  tags                = var.tags
  schedule_expression = "rate(${var.s3_snapshots_schedule_period} hours)"
}

resource "aws_cloudwatch_event_target" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  rule      = aws_cloudwatch_event_rule.snapshot_lambda[0].name
  target_id = local.snapshot_resource_name
  arn       = aws_lambda_function.snapshot_lambda[0].arn
}

resource "aws_lambda_permission" "snapshot_lambda" {
  count = local.snapshot_enabled_count

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_lambda[0].arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_lambda[0].arn
}

## MONITORING

locals {
  lambda_invocation_error_period_initial = (var.s3_snapshots_schedule_period + 2) * 60 * 60         # 2 hours more than the snapshot period
  lambda_invocation_error_period         = min(local.lambda_invocation_error_period_initial, 86400) # can be maximum 24 hrs
}

module "snapshot_lambda_monitoring" {
  count = var.s3_snapshots_enabled && var.s3_snapshots_monitoring_sns_topic_arn != null ? 1 : 0

  source          = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.2.0"
  lambda_function = aws_lambda_function.snapshot_lambda[0].function_name
  sns_topic_arn   = var.s3_snapshots_monitoring_sns_topic_arn

  lambda_invocation_error_threshold          = 1
  lambda_invocation_error_period             = local.lambda_invocation_error_period
  lambda_invocation_error_evaluation_periods = 1
  lambda_invocation_error_treat_missing_data = "breaching"
}
