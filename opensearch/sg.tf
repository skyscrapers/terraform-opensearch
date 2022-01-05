resource "aws_security_group" "sg" {
  count       = var.vpc_id != null ? 1 : 0
  name        = var.name
  description = "Security group for the ${var.name} OpenSearch domain"
  vpc_id      = var.vpc_id
  tags        = var.tags

  lifecycle {
    ignore_changes = [
      description
    ]
  }
}
