locals {
  vpc_enabled = var.vpc_id == "" ? false : true

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

  cluster_config = {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_enabled ? var.dedicated_master_count : 0
    dedicated_master_type    = var.dedicated_master_enabled ? var.dedicated_master_type : ""
    zone_awareness_enabled   = var.zone_awareness_enabled
  }

  ebs_options = {
    ebs_enabled = contains(var.ephemeral_list, var.instance_type) ? false : true
    volume_type = contains(var.ephemeral_list, var.instance_type) ? "" : var.volume_type
    volume_size = contains(var.ephemeral_list, var.instance_type) ? 0 : var.volume_size
    iops        = var.volume_type == "io1" ? var.volume_iops : 0
  }

  snapshot_options = {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }
}

data "aws_region" "current" {
}

resource "aws_elasticsearch_domain" "es" {
  count                 = local.vpc_enabled ? 1 : 0
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  elasticsearch_version = var.elasticsearch_version
  dynamic "cluster_config" {
    for_each = [local.cluster_config]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      dedicated_master_count   = lookup(cluster_config.value, "dedicated_master_count", null)
      dedicated_master_enabled = lookup(cluster_config.value, "dedicated_master_enabled", null)
      dedicated_master_type    = lookup(cluster_config.value, "dedicated_master_type", null)
      instance_count           = lookup(cluster_config.value, "instance_count", null)
      instance_type            = lookup(cluster_config.value, "instance_type", null)
      zone_awareness_enabled   = lookup(cluster_config.value, "zone_awareness_enabled", null)
    }
  }
  dynamic "ebs_options" {
    for_each = [local.ebs_options]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      ebs_enabled = ebs_options.value.ebs_enabled
      iops        = lookup(ebs_options.value, "iops", null)
      volume_size = lookup(ebs_options.value, "volume_size", null)
      volume_type = lookup(ebs_options.value, "volume_type", null)
    }
  }
  dynamic "snapshot_options" {
    for_each = [local.snapshot_options]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      automated_snapshot_start_hour = snapshot_options.value.automated_snapshot_start_hour
    }
  }
  tags = local.tags

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = var.options_rest_action_multi_allow_explicit_index
    "indices.fielddata.cache.size"           = var.options_indices_fielddata_cache_size
    "indices.query.bool.max_clause_count"    = var.options_indices_query_bool_max_clause_count
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

  vpc_options {
    security_group_ids = concat(aws_security_group.sg.*.id, var.security_group_ids)
    subnet_ids         = var.subnet_ids
  }

  cognito_options {
    enabled          = var.cognito_enabled
    user_pool_id     = var.cognito_user_pool_id
    identity_pool_id = var.cognito_identity_pool_id
    role_arn         = var.cognito_role_arn
  }
}

resource "aws_elasticsearch_domain" "public_es" {
  count                 = local.vpc_enabled ? 0 : 1
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  elasticsearch_version = var.elasticsearch_version
  dynamic "cluster_config" {
    for_each = [local.cluster_config]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      dedicated_master_count   = lookup(cluster_config.value, "dedicated_master_count", null)
      dedicated_master_enabled = lookup(cluster_config.value, "dedicated_master_enabled", null)
      dedicated_master_type    = lookup(cluster_config.value, "dedicated_master_type", null)
      instance_count           = lookup(cluster_config.value, "instance_count", null)
      instance_type            = lookup(cluster_config.value, "instance_type", null)
      zone_awareness_enabled   = lookup(cluster_config.value, "zone_awareness_enabled", null)
    }
  }
  dynamic "ebs_options" {
    for_each = [local.ebs_options]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      ebs_enabled = ebs_options.value.ebs_enabled
      iops        = lookup(ebs_options.value, "iops", null)
      volume_size = lookup(ebs_options.value, "volume_size", null)
      volume_type = lookup(ebs_options.value, "volume_type", null)
    }
  }
  dynamic "snapshot_options" {
    for_each = [local.snapshot_options]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      automated_snapshot_start_hour = snapshot_options.value.automated_snapshot_start_hour
    }
  }
  tags = local.tags

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = var.options_rest_action_multi_allow_explicit_index
    "indices.fielddata.cache.size"           = var.options_indices_fielddata_cache_size
    "indices.query.bool.max_clause_count"    = var.options_indices_query_bool_max_clause_count
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
