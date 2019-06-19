data "aws_iam_policy_document" "cwl_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.cwl_index.arn}:*",
      "${aws_cloudwatch_log_group.cwl_search.arn}:*",
      "${aws_cloudwatch_log_group.cwl_app.arn}:*",
    ]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "snapshot_policy" {
  count = var.snapshot_bucket_enabled ? 1 : 0

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "iam:PassRole",
    ]

    resources = [
      aws_s3_bucket.snapshot[0].arn,
      "${aws_s3_bucket.snapshot[0].arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "assume_policy" {
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

resource "aws_cloudwatch_log_resource_policy" "cwl_resource_policy" {
  policy_name     = "${var.project}-${var.environment}-${var.name}-cwl-policy"
  policy_document = data.aws_iam_policy_document.cwl_policy.json
}

resource "aws_iam_role" "role" {
  count              = var.snapshot_bucket_enabled ? 1 : 0
  name               = "${var.project}-${var.environment}-${var.name}-snapshot"
  description        = "Role used for the Elasticsearch domain"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_policy" "snapshot_policy" {
  count       = var.snapshot_bucket_enabled ? 1 : 0
  name        = "${var.project}-${var.environment}-${var.name}-snapshot"
  description = "Policy allowing the Elasticsearch domain access to the snapshots S3 bucket"
  policy      = data.aws_iam_policy_document.snapshot_policy[0].json
}

resource "aws_iam_role_policy_attachment" "snapshot_policy_attachment" {
  count      = var.snapshot_bucket_enabled ? 1 : 0
  role       = aws_iam_role.role[0].id
  policy_arn = aws_iam_policy.snapshot_policy[0].arn
}
