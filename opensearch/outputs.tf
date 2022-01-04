output "arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_elasticsearch_domain.es.arn
}

output "domain_id" {
  description = "ID of the OpenSearch domain"
  value       = aws_elasticsearch_domain.es.domain_id
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = aws_elasticsearch_domain.es.domain_name
}

output "endpoint" {
  description = "DNS endpoint of the OpenSearch domain"
  value       = aws_elasticsearch_domain.es.endpoint
}

output "kibana_endpoint" {
  description = "DNS endpoint of Kibana"
  value       = aws_elasticsearch_domain.es.endpoint
}

output "domain_region" {
  description = "Region of the OpenSearch domain"
  value       = data.aws_region.current.name
}

output "sg_id" {
  description = "ID of the OpenSearch security group"
  value       = join("", aws_security_group.sg.*.id)
}
