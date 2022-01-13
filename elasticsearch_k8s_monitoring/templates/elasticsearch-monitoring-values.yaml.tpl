amazonService: true

%{ if length(sla) > 0 ~}
sla: ${sla}
%{ endif ~}

prometheus-elasticsearch-exporter:
  resources:
    limits:
      memory: ${es_exporter_memory}
    requests:
      cpu: 5m
      memory: ${es_exporter_memory}
  es:
    uri: ${elasticsearch_endpoint}
    indices: false
    indices_settings: false
    shards: false

prometheus-cloudwatch-exporter:
  resources:
    limits:
      memory: ${cw_exporter_memory}
    requests:
      cpu: 5m
      memory: ${cw_exporter_memory}
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
    - aws_namespace: AWS/ES
      aws_metric_name: ClusterIndexWritesBlocked
      aws_dimensions: [ClientId, DomainName]
      aws_dimension_select:
        DomainName: [${elasticsearch_domain}]
      aws_statistics: [Maximum]
