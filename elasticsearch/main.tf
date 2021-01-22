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

data "aws_subnet" "private" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

locals {
  # For Public domains, get number of multiple zones instances can span
  instance_az = var.vpc_id == null && var.instance_count >= 3 ? 3 : var.vpc_id == null && var.instance_count == 2 ? 2 : null

  # For private domains, get number of multiple zones instances can span within available subnets
  subnet_az = var.instance_count >= 3 && length(distinct(data.aws_subnet.private[*].availability_zone)) >= 3 ? 3 : var.instance_count >= 2 && length(distinct(data.aws_subnet.private[*].availability_zone)) >= 2 ? 2 : null

  zone_awareness_enabled = local.instance_az != null ? true : local.subnet_az != null ? true : false

  availability_zone_count = local.instance_az == 3 ? 3 : local.subnet_az == 3 ? 3 : 2
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type

    dedicated_master_enabled = var.warm_enabled || var.dedicated_master_enabled
    dedicated_master_count   = var.warm_enabled || var.dedicated_master_enabled ? var.dedicated_master_count : null
    dedicated_master_type    = var.warm_enabled || var.dedicated_master_enabled ? var.dedicated_master_type : null

    warm_enabled = var.warm_enabled
    warm_count   = var.warm_enabled ? var.warm_count : null
    warm_type    = var.warm_enabled ? var.warm_type : null

    zone_awareness_enabled   = var.zone_awareness_enabled != null ? var.zone_awareness_enabled : local.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled == true || local.zone_awareness_enabled == true ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count != null ? var.availability_zone_count : local.availability_zone_count
      }
    }
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
    "indices.fielddata.cache.size"           = var.options_indices_fielddata_cache_size != null ? tostring(var.options_indices_fielddata_cache_size) : ""
    "indices.query.bool.max_clause_count"    = tostring(var.options_indices_query_bool_max_clause_count)
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest
    kms_key_id = var.encrypt_at_rest_kms_key_id
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption
  }

  domain_endpoint_options {
    enforce_https       = var.endpoint_enforce_https
    tls_security_policy = var.endpoint_tls_security_policy
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

  log_publishing_options {
    enabled                  = var.application_logging_enabled
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cwl_application.arn
  }

  dynamic "vpc_options" {
    for_each = var.vpc_id == null ? [] : [var.vpc_id]

    content {
      security_group_ids = concat(aws_security_group.sg.*.id, var.security_group_ids)
      subnet_ids         = var.subnet_ids
    }
  }

  cognito_options {
    enabled          = var.cognito_enabled
    user_pool_id     = var.cognito_enabled ? var.cognito_user_pool_id : ""
    identity_pool_id = var.cognito_enabled ? var.cognito_identity_pool_id : ""
    role_arn         = var.cognito_enabled ? var.cognito_role_arn : ""
  }
}
