resource "aws_security_group" "sg" {
  count       = var.vpc_id != null ? 1 : 0
  name        = "${var.project}-${var.environment}-${var.name}"
  description = "Security group for the ${var.project} Elasticsearch domain"
  vpc_id      = var.vpc_id
  tags        = local.tags
}
