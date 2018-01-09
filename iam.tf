resource "aws_iam_role" "role" {
  count       = "${var.snapshot_bucket_enabled ? 1 : 0}"
  name        = "${var.project}-${var.environment}-${var.name}-snapshot"
  description = "Role used for the Elasticsearch domain"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "snapshot_policy" {
  count       = "${var.snapshot_bucket_enabled ? 1 : 0}"
  name        = "${var.project}-${var.environment}-${var.name}-snapshot"
  description = "Policy allowing the Elasticsearch domain access to the snapshots S3 bucket"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "iam:PassRole"
      ],
      "Effect":"Allow",
      "Resource": [
        "${aws_s3_bucket.snapshot.arn}",
        "${aws_s3_bucket.snapshot.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "snapshot_policy_attachment" {
  count      = "${var.snapshot_bucket_enabled ? 1 : 0}"
  role       = "${aws_iam_role.role.id}"
  policy_arn = "${aws_iam_policy.snapshot_policy.arn}"
}
