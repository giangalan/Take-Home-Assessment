import boto3
api_healthcheck_url = "https://www.cloudflarestatus.com/api/v2/status.json"
s3 = "csv-healthcheck-bucket"
cloudwatch_namespace = "HealthCheck"
cloudwatch = boto3.client("cloudwatch")