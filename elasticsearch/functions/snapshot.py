#!/usr/bin/env python3
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/curator.html

import boto3
from datetime import datetime
from requests_aws4auth import AWS4Auth
from elasticsearch import Elasticsearch, ElasticsearchException, RequestsHttpConnection
import logging
import curator
import os
import json

logger = logging.getLogger('curator')
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.INFO)

host = os.environ.get('HOST')
region = os.environ.get('REGION')
repository_name = os.environ.get('REPOSITORY')
retention = os.environ.get('RETENTION')
bucket = os.environ.get('BUCKET')
role_arn = os.environ.get('ROLE_ARN')

service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key,
                   region, service, session_token=credentials.token)


def lambda_handler(event, context):

    now = datetime.now()
    snapshot_prefix = 'automatic-'
    snapshot_name = snapshot_prefix + now.strftime("%Y%m%d%H%M%S")

    # Build the Elasticsearch client.
    es = Elasticsearch(
        hosts=[{'host': host, 'port': 443}],
        http_auth=awsauth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection,
        # Deleting snapshots can take a while, so keep the connection open for long enough to get a response.
        timeout=120
    )

    # REGISTER
    try:
        payload = {
            "type": "s3",
            "settings": {
                "bucket": bucket,
                "region": region,
                "role_arn": role_arn
            }
        }

        es.snapshot.create_repository(repository_name, json.dumps(payload))

    except (ElasticsearchException) as e:
        print(e)
        raise

    # DELETE
    try:
        snapshot_list = curator.SnapshotList(es, repository=repository_name)
        snapshot_list.filter_by_regex(kind='prefix', value=snapshot_prefix)
        snapshot_list.filter_by_age(
            source='creation_date', direction='older', unit='days', unit_count=int(retention))

        # Delete the old snapshots.
        curator.DeleteSnapshots(
            snapshot_list, retry_interval=30, retry_count=3).do_action()

    except (curator.exceptions.NoSnapshots) as e:
        # This is fine
        print(e)
    except (curator.exceptions.SnapshotInProgress, curator.exceptions.FailedExecution) as e:
        print(e)
        raise

    # CREATE
    try:
        index_list = curator.IndexList(es)

        # Take a new snapshot. This operation can take a while, so we don't want to wait for it to complete.
        curator.Snapshot(index_list, repository=repository_name,
                         name=snapshot_name, wait_for_completion=False).do_action()

    except (curator.exceptions.SnapshotInProgress, curator.exceptions.FailedExecution) as e:
        print(e)
        raise
