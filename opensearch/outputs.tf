output "arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.os.arn
}

output "domain_id" {
  description = "ID of the OpenSearch domain"
  value       = aws_opensearch_domain.os.domain_id
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = aws_opensearch_domain.os.domain_name
}

output "endpoint" {
  description = "DNS endpoint of the OpenSearch domain"
  value       = aws_opensearch_domain.os.endpoint
}

output "kibana_endpoint" {
  description = "DNS endpoint of Kibana"
  value       = aws_opensearch_domain.os.endpoint
}

output "domain_region" {
  description = "Region of the OpenSearch domain"
  value       = data.aws_region.current.region
}

output "sg_id" {
  description = "ID of the OpenSearch security group"
  value       = join("", aws_security_group.sg.*.id)
}
