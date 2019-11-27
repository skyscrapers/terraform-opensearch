amazonService:
  enabled: true

elasticsearch-exporter:
  resources:
    limits:
      memory: 48Mi
    requests:
      cpu: 5m
      memory: 48Mi
  es:
    uri: ${elasticsearch_endpoint}

prometheus-cloudwatch-exporter:
  resources:
    limits:
      memory: 160Mi
    requests:
      cpu: 5m
      memory: 160Mi
  aws:
    role: "${cloudwatch_exporter_role}"
  config: |-
    region: ${region}
    period_seconds: 60
    set_timestamp: false
    metrics:
    - aws_namespace: AWS/ES
      aws_metric_name: FreeStorageSpace
      aws_dimensions: [ClientId, DomainName]
      aws_dimension_select:
        DomainName: [${elasticsearch_domain}]
      aws_statistics: [Minimum, Maximum, Average, Sum]
