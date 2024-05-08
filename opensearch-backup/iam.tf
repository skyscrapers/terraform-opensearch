data "aws_iam_policy_document" "snapshot_create_assume" {
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
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.s3_snapshot.s3_bucket_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = ["${module.s3_snapshot.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_role" "snapshot_create" {
  name               = "${var.name}-s3snapshotter"
  description        = "Role used by OpenSearch for snapshotting to S3"
  assume_role_policy = data.aws_iam_policy_document.snapshot_create_assume.json
}

resource "aws_iam_role_policy" "snapshot_create" {
  role   = aws_iam_role.snapshot_create.id
  policy = data.aws_iam_policy_document.snapshot_create.json
}
