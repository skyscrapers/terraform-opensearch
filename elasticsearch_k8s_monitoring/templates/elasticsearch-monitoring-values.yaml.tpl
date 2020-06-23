amazonService: true

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
    region: ${region}
%{if ! irsa_enabled ~}
    role: "${cloudwatch_exporter_role}"
%{ endif ~}
  serviceAccount:
    create: true
%{if irsa_enabled ~}
    annotations:
      eks.amazonaws.com/role-arn: "${cloudwatch_exporter_role}"
%{ endif ~}
  securityContext:
    runAsUser: 65534
    fsGroup: 65534
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
