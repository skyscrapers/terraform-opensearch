module "s3_snapshot" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  bucket = var.name

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
  control_object_ownership  = true
  object_ownership          = "BucketOwnerEnforced"
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.s3_snapshot_bucket.json
  replication_configuration = var.s3_replication_configuration
  force_destroy             = var.s3_force_destroy

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = var.bucket_key_enabled

      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.aws_kms_key_arn
        sse_algorithm     = var.aws_kms_key_arn != null ? "aws:kms" : "AES256"
      }
    }
  }

  versioning = {
    enabled = false
  }
}

data "aws_iam_policy_document" "s3_snapshot_bucket" {
  statement {
    sid    = "DenyWriteNonSnapshotRole"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:Put*",
      "s3:Delete*",
    ]

    resources = [
      "${module.s3_snapshot.s3_bucket_arn}/*",
    ]

    condition {
      test     = "ForAnyValue:StringNotEquals"
      variable = "aws:PrincipalArn"

      values = [
        aws_iam_role.snapshot_create.arn
      ]
    }
  }

  source_policy_documents = var.extra_bucket_policy == null ? null : [var.extra_bucket_policy]
}
