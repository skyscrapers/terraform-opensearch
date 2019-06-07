locals {
  tags = merge(
    var.tags,
    {
      "Name"        = "${var.project}-${var.environment}-${var.name}"
      "Environment" = var.environment
      "Project"     = var.project
    },
  )

  tags_noname = merge(
    var.tags,
    {
      "Environment" = var.environment
      "Project"     = var.project
    },
  )
}

data "aws_region" "current" {}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_enabled ? var.dedicated_master_count : 0
    dedicated_master_type    = var.dedicated_master_enabled ? var.dedicated_master_type : ""
    zone_awareness_enabled   = var.zone_awareness_enabled
  }

  ebs_options {
    ebs_enabled = contains(var.ephemeral_list, var.instance_type) ? false : true
    volume_type = contains(var.ephemeral_list, var.instance_type) ? null : var.volume_type
    volume_size = contains(var.ephemeral_list, var.instance_type) ? null : var.volume_size
    iops        = var.volume_type == "io1" ? var.volume_iops : null
  }

  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }

  tags = local.tags

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = tostring(var.options_rest_action_multi_allow_explicit_index)
    "indices.fielddata.cache.size"           = tostring(var.options_indices_fielddata_cache_size)
    "indices.query.bool.max_clause_count"    = tostring(var.options_indices_query_bool_max_clause_count)
  }

  encrypt_at_rest {
    enabled = var.disable_encrypt_at_rest ? false : contains(var.encryption_list, var.instance_type)
  }

  log_publishing_options {
    enabled                  = var.logging_enabled
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cwl_index.arn
  }

  log_publishing_options {
    enabled                  = var.logging_enabled
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cwl_search.arn
  }

  dynamic "vpc_options" {
    for_each = [var.vpc_id]

    content {
      security_group_ids = concat(aws_security_group.sg.*.id, var.security_group_ids)
      subnet_ids         = var.subnet_ids
    }
  }

  cognito_options {
    enabled          = var.cognito_enabled
    user_pool_id     = var.cognito_user_pool_id
    identity_pool_id = var.cognito_identity_pool_id
    role_arn         = var.cognito_role_arn
  }
}

resource "aws_cloudwatch_log_group" "cwl_index" {
  name              = "${var.project}/${var.environment}/${var.name}/index_slow_logs"
  retention_in_days = var.logging_retention
  tags              = local.tags_noname
}

resource "aws_cloudwatch_log_group" "cwl_search" {
  name              = "${var.project}/${var.environment}/${var.name}/search_slow_logs"
  retention_in_days = var.logging_retention
  tags              = local.tags_noname
}

resource "aws_s3_bucket" "snapshot" {
  count  = var.snapshot_bucket_enabled ? 1 : 0
  bucket = "${var.project}-${var.environment}-${var.name}-snapshot"
  acl    = "private"
  tags   = local.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}
